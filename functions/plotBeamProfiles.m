function plotBeamProfiles(data, inds, newcAxis, newAxis)

% plotBeamProfiles
%   This code takes a structure containing hydrophone data and plots the beam
%   profiles.
%
% -- usage --
% plotBeamProfiles(data, 1:3, [0 0.1], [-5 5 -5 5]);
%
% -- inputs --
% data          	structure containing hydrophone data. this was an output of
%                       readAIMS.m
% inds              indices of the parameters to be plotted
%
% optional:
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
% -- edit history --
% 2016-01-25 SAL    moved code out of readAIMS.m and into its own function

%% create beam profile plots
% VOLTAGE plot (note: up down is switched compared to AIMS plots)
filename = data.filename;
rawData = data.rawData;
paramNames = data.paramNames;
xAxis = data.xAxis;
yAxis = data.yAxis;
xAxisName = data.xAxisName;
yAxisName = data.yAxisName;

for i = inds
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
    title({filename; paramNames{i}});
    xlabel(xAxisName);
    ylabel(yAxisName);
    h = colorbar;
    xlabel(h, 'Vpp')                                % TODO: verify we can make this assumption
    axis equal
    if exist('newAxis', 'var') % if new axes are requested
        axis(newAxis);
    else
        axis([xAxis(1) xAxis(end) yAxis(1) yAxis(end)]);
    end

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

end %for i

