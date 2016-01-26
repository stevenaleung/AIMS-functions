function axisName = axisNum2Name(n)

% axisNum2Name - This code converts axis number from AIM files to axis name.
%    axisName = axisNum2Name(n)
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
