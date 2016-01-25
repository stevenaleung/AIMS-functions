function data = readAIMS(fileName, plots, folderName, newcAxis, newAxis)

% readAIMS - This code reads AIM files containing hydrophone data.
%
% -- inputs --
% fileName          string input for the data file. It should end in '.AIM'
%
% optional:
% plots             {true} | false      flag determining whether plots should be displayed.
% folderName        folder containing AIMS data should it not be the current directory
% newcAxis          new colorbar axis. New colorbar axis can be specified
%                   numerically in the form [min max] where min and max specify
%                   the limits for the colorbar axis. Or, the new colorbar axis
%                   can be copied from another scan's colorbar axis, in which
%                   case newcAxis is a string input (e.g. 'scanXZaddon'). By
%                   default, readAIMS will match the colorbar axis with the
%                   corresponding skullAbsent / skullPresent scan if such axes
%                   exist. If newcAxis is [], readAIMS will not set a new
%                   colorbar axis.
% newAxis           vector input in the form [xMin xMax yMin yMax] in units of mm
%
% -- outputs --
% data              structure containing raw data, parameter name, axis labels,
%                   axis tick marks, & color axis
%
%
% -- edit history --
% Patrick Ye, Butts Pauly Lab, Stanford University
% 2015-11-23 SAL    


% if plots should be displayed
if nargin == 1
    plots = 1;
end

% if foldername is/isn't specified
if nargin <= 2
    folderName = pwd;
else
    startFolder = pwd;
    cd(folderName)
end

% the data looks like this
%       -10 -9.8 ... 10     <-- axis 1
% -10   data ..........
% -9.8  ...............
%  .    ...............
%  .    ...............
%  .    ...............
%  10   ...............
%  
%
%  ^
%  axis 2

% AIMSfile = loadTextFile(fileName);
% inds = findLines(AIMSfile, '2D Scan Data');
% numParams = numel(inds);

% calculate number of header lines before data starts
text = fileread(fileName);
dataHeader = '2D Scan Data';
newline = '[\n]';
n = regexp(text, newline);
m = regexp(text, dataHeader);
numParams = numel(m);
numHeaderLines = zeros(size(m));
for i = 1:numParams
    numHeaderLines(i) = sum(n<m(i));
end

rawData = cell(numParams, 1);
paramName = cell(numParams, 1);
for i = 1:numParams
    % read file
    fid = fopen(fileName);
    c = textscan(fid, '%f', 'Headerlines', numHeaderLines(i)+1); % may not be 252 lines for every file...
    data = c{1};
    fclose(fid);

    % find out what parameter it is
    paramHeader = sprintf('Parameter %d', i-1);
    param = regexp(text, paramHeader);
    ind = find(param < n, 1, 'first');
    paramName{i} = text(param+length(paramHeader)+1:n(ind)-2);

    % calculate x axis properties
    x = regexp(text, '[\n]First Axis');
    xAxisNum = str2double(text(x+12));
    xName = axisAIMS(str2double(text(x+12)));
    dx = data(2) - data(1);
    xMin = data(1);

    xMaxIndex = n(numHeaderLines+2)-2;
    a = text(xMaxIndex);
    while isspace(a) ~= 1
        xMaxIndex = xMaxIndex - 1;
        a = text(xMaxIndex);
    end
    xMax = str2double(text(xMaxIndex:n(numHeaderLines+2)-2));

    numXPoints = (xMax - xMin) / dx + 1;
    numXPoints = int32(numXPoints);
    xAxis = data(1:numXPoints);

    % 1 mm offset for AIMS software because it doesn't run if Left/Right axis
    % starts at 0 mm
    if xMin == 1 && xAxisNum == 0
        xAxis = xAxis - 1;
    end

    % move first row into an axis variable
    data = data(numXPoints+1:end);

    % reshape matrix
    bigData = reshape(data, numXPoints+1, []);
    bigData = bigData';
    rawData{i} = bigData(:, 2:end);
    
    % y axis properties
    yAxis = bigData(:, 1);
    y = regexp(text, '[\n]Second Axis');
    yName = axisAIMS(str2double(text(y+13)));

    % -------
    % VOLTAGE plot (note: up down is switched compared to AIMS plots)
    if plots
        figure;
        if strcmp(paramName{i}, 'Negative Peak Voltage')
            % invert the values for peak negative voltage so that the plots have
            % similar color axes
            imagesc([xAxis(1) xAxis(end)], [yAxis(1) yAxis(end)], -rawData{i}) % Vpp
        else
            imagesc([xAxis(1) xAxis(end)], [yAxis(1) yAxis(end)], rawData{i}) % Vpp
        end
        colormap(hot)
        colorbar
        title(sprintf('%s, %s', fileName, paramName{i}));
        xlabel(xName)
        ylabel(yName)
        h = colorbar;
        xlabel(h, 'Vpp')
        if nargin == 4 % if new axis are requested
            axis(newAxis)
        end
        axis equal
        axis([xAxis(1) xAxis(end) yAxis(1) yAxis(end)])

    % new cAxis specified
    if nargin >= 3
        if isnumeric(newcAxis) % if numeric new cAxis specified and nonzero
            if numel(newcAxis) == 2 % skip if newcAxis == []
                caxis(newcAxis);
            end
        elseif ischar(newcAxis) % if new cAxis is the cAxis from another scan
            load(newcAxis)
            eval(['cAxis = ' newcAxis '.cAxis;'])
            caxis(cAxis);
        end
    end

    cAxis = caxis;
    cAxis(1) = 0; % set cAxis min to 0
    caxis(cAxis);
    end
end

clear data
variables = {'rawData', 'paramName', 'xAxis', 'yAxis', 'xName', 'yName'}; % if plots==0, can't save a cAxis
% variables = {'rawData', 'paramName', 'xAxis', 'yAxis', 'cAxis', 'xName', 'yName'};
for i = 1:length(variables)
    data.(variables{i}) = eval(variables{i});
end

end


function axisName = axisAIMS(n)

% axisAIMS - This code converts axis number from AIM files to axis name.
%    axisName = axisAIMS(n)
%    n is a integer input which is the axis number.
%    axisName is a string output for the axis name corresponding to the
%       axis number.
%
% Patrick Ye
% Butts Pauly Lab, Stanford University
% http://kbplab.stanford.edu

    switch n
        case 0
            axisName = 'Left/Right (mm)';
        case 1
            axisName = 'Front/Back (mm)';
        case 2
            axisName = 'Up/Down (mm)';
    end
end