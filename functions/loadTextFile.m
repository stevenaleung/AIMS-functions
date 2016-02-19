function txt = loadTextFile(filename)

% loadTextFile
%   Open text file and import all lines into a cell array.
%
% -- inputs --
% filename          name of the file
%
% -- outputs --
% txt               cell array containing every line of the file
%
% -- edit history --
% SAL 2015-08-05    created
% SAL 2015-08-18    added documentation
% SAL 2015-12-25    replaced while loop with textscan()

%% open file
fid = fopen(filename);

%% load lines into cell array
tmp = textscan(fid, '%s', 'delimiter', '\n');
txt = tmp{1};

%% close file
fclose(fid);

