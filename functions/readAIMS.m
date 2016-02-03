function data = readAIMS(filename)

% readAIMS
%   This code reads and parses AIMS files containing hydrophone data. The output
%   contains all the data in MATLAB usable format.
%
% -- inputs --
% filename          string input for the data file path. It should end in '.AIM'
%
% -- outputs --
% data              structure containing raw data, parameter name, axis labels,
%                       axis tick marks
%
% -- edit history --
% Patrick Ye, Butts Pauly Lab, Stanford University
% 2015-11-23 SAL    
% 2016-01-19 SAL    modified function to handle multiple data parameters
% 2016-01-25 SAL    refactored code

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
aimsFile = loadTextFile(filename);
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

% axis bounds
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

xAxis = [xMin xMax];
yAxis = [yMin yMax];

%% read the data into MATLAB usable format
rawData = cell(numParams, 1);
paramNames = cell(numParams, 1);
for i = 1:numParams       
    % find out what parameter this is
    param = aimsFile{paramInds(i)};
    paramNames{i} = param(13:end);

    % read data from file. textscan() stops reading additional lines once an
    % empty line is reached
    fid = fopen(filename);
    tmp = textscan(fid, '%f', 'headerlines', dataStartInds(i)); 
    data = tmp{1};
    fclose(fid);
    
    % the data matrix contains x- and y-axis values that we don't care about. we
    % prepend a 0 in order to get the right number of elements
    % (cols+1)*(rows+1). afterwards, we can reshape the data and remove the
    % first row and first column (the axis values).
    data = [0; data];
    data = reshape(data, [dataNumCols+1, dataNumRows+1]);
    data = data(2:end, 2:end);
    data = data';
    rawData{i} = data;
        
    % 1 mm offset for AIMS software because it doesn't run if Left/Right axis
    % starts at 0 mm
    if xMin == 1 && xAxisNum == 0
        xAxis = xAxis - 1;
    end
end %for i

%% export relevant information in a structure
clear data
variables = {'filename'; 'rawData'; 'paramNames'; 'xAxis'; 'yAxis'; 'xAxisName'; 'yAxisName'};
for i = 1:length(variables)
    data.(variables{i}) = eval(variables{i});
end

