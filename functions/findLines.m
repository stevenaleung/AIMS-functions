function inds = findLines(txt, substr)
    
% findLines
%   Find all lines (in cell array) that contain the given substring
%
% -- inputs --
% txt               cell array containing every line of the file
% substr            substring to search for
%
% -- outputs --
% inds              indices of all lines containing the substring
%
% -- edit history --
% SAL 2015-12-25    created

fnc = @(line) ~isempty(strfind(line, substr));      % anon func: determine if a line contains a substring
target = cellfun(fnc, txt);                         % apply the anon func to every line in the cell array   

inds = find(target);
