function data = readAIMS(fileName, plotFlag, newcAxis, newAxis)

% readAIMS
%   This code reads and parses AIMS files containing hydrophone data. The output
%   contains all the data in MATLAB usable format.
%
% -- inputs --
% fileName          string input for the data file path. It should end in '.AIM'
%
% optional:
% plotFlag          {true} | false      flag determining whether plotFlag should be displayed.
% newcAxis          new colorbar axis. New colorbar axis can be specified
%                       numerically in the form [min max] where min and max
%                       specify the limits for the colorbar axis. Or, the new
%                       colorbar axis can be copied from another scan's colorbar
%                       axis, in which case newcAxis is a string input (e.g.
%                       'scanXZaddon'). By default, readAIMS will match the
%                       colorbar axis with the corresponding skullAbsent /
%                       skullPresent scan if such axes exist. If newcAxis is [],
%                       readAIMS will not set a new colorbar axis.
% newAxis           vector input in the form [xMin xMax yMin yMax] in units of mm
%
% -- outputs --
% data              structure containing raw data, parameter name, axis labels,
%                       axis tick marks, & color axis
%
%
% -- edit history --
% Patrick Ye, Butts Pauly Lab, Stanford University
% 2015-11-23 SAL    
% 2016-01-19 SAL    modified function to handle multiple data parameters
% 2016-01-25 SAL    refactored code

% if plotFlag should be displayed
if nargin == 1
    plotFlag = true;
end

% the data looks like this
%       -10 -9.8 ... 10     <- first axis
% -10   data ..........
% -9.8  ...............
%  .    ...............
%  .    ...............
%  .    ...............
%  10   ...............
%  
%
%  ^
%  second axis

%% setup
% load the .AIM file and grab all the relevant parameters:
%   collected parameters, size of data matrix, axis names, axis bounds, etc.
aimsFile = loadTextFile(fileName);
dataStartInds = findLines(aimsFile, '2D Scan Data');

% collected parameters
paramInds = findLines(aimsFile, 'Parameter');
numParams = numel(paramInds);

% size of data matrix
yCountInd = findLines(aimsFile, 'YCount');
tmp = strsplit(aimsFile{yCountInd});
dataNumRows = str2double(tmp{2});

xCountInd = findLines(aimsFile, 'XCount');
tmp = strsplit(aimsFile{xCountInd});
dataNumCols = str2double(tmp{2});

% axis names
firstAxisInd = findLines(aimsFile, 'First Axis');
tmp = strsplit(aimsFile{firstAxisInd(1)});
xAxisNum = str2double(tmp{3});
xAxisName = axisNum2Name(xAxisNum);

secondAxisInd = findLines(aimsFile, 'Second Axis');
tmp = strsplit(aimsFile{secondAxisInd(1)});
yAxisNum = str2double(tmp{3});
yAxisName = axisNum2Name(yAxisNum);

% get entire axis
xMinInd = findLines(aimsFile, 'XMin');
tmp = strsplit(aimsFile{xMinInd});
xMin = str2double(tmp{2});

xMaxInd = findLines(aimsFile, 'XMax');
tmp = strsplit(aimsFile{xMaxInd});
xMax = str2double(tmp{2});

yMinInd = findLines(aimsFile, 'YMin');
tmp = strsplit(aimsFile{yMinInd});
yMin = str2double(tmp{2});

yMaxInd = findLines(aimsFile, 'YMax');
tmp = strsplit(aimsFile{yMaxInd});
yMax = str2double(tmp{2});


%% read the data into MATLAB usable format
rawData = cell(numParams, 1);
paramNames = cell(numParams, 1);
for i = 1:numParams       
    % find out what parameter this is
    param = aimsFile{paramInds(i)};
    paramNames{i} = param(13:end);

    % read data from file. textscan() stops reading additional lines once an
    % empty line is reached
    fid = fopen(fileName);
    tmp = textscan(fid, '%f', 'headerlines', dataStartInds(i)); 
    data = tmp{1};
    fclose(fid);
    
    % the data matrix contains x- and y-axis values that we absolutely do care about. we
    % prepend a 0 in order to get the right number of elements
    % (cols+1)*(rows+1). afterwards, we can reshape the data and remove the
    % first row and first column (the axis values).
    data = [0; data];
    data = reshape(data, [dataNumCols+1, dataNumRows+1]);
    xAxis = data(2:end, 1);
    yAxis = data(1, 2:end);
    data = data(2:end, 2:end);
    data = data';
    rawData{i} = data;
        
    % 1 mm offset for AIMS software because it doesn't run if Left/Right axis
    % starts at 0 mm
    if xMin == 1 && xAxisNum == 0
        xAxis = xAxis - 1;
    end
end %for i

%% create beam profile plots
% VOLTAGE plot (note: up down is switched compared to AIMS plots)
if plotFlag
    cAxis = cell(numParams, 1);
    for i = 1:numParams
        figure;
        if strcmp(paramNames{i}, 'Negative Peak Voltage')
            % invert the values for peak negative voltage so that the plots have
            % similar color axes
            imagesc([xAxis(1) xAxis(end)], [yAxis(1) yAxis(end)], -rawData{i});
        else
            imagesc([xAxis(1) xAxis(end)], [yAxis(1) yAxis(end)], rawData{i});
        end
        colormap(hot);
        colorbar;
        title({fileName; paramNames{i}});
        xlabel(xAxisName);
        ylabel(yAxisName);
        h = colorbar;
        xlabel(h, 'Vpp')                                % TODO: verify we can make this assumption
        if nargin == 4 % if new axis are requested
            axis(newAxis);
        else
            axis([xAxis(1) xAxis(end) yAxis(1) yAxis(end)]);
        end
        axis equal
        
        % if a new cAxis is specified, change the cAxis of the plot
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
        
        cAxis{i} = caxis;
        
    end %for i
end %if plotFlag

%% export relevant information in a structure
clear data
variables = {'rawData'; 'paramNames'; 'xAxis'; 'yAxis'; 'xMin'; 'yMin'; 'xMax'; 'yMax'; 'xAxisName'; 'yAxisName'};
if plotFlag
    variables = [variables; {'cAxis'}];
end
for i = 1:length(variables)
    data.(variables{i}) = eval(variables{i});
end

