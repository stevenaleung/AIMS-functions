function Pa = volts2pressure(data, f, units, SN)

% Vpp2intensity - This code converts peak-to-peak voltage (V) as measured
%                 from a HNR-0500 hydrophone to Pa peak pressure.
%
% -- inputs --
% data          vector input for voltage values to convert to intensity
% frequency     vector input (same size as data) representing the 
%               US frequency (in MHz) at which data was collected 
% units         string input specifying units of data
%   - Vpp       peak to peak voltage
%   - V         DC to peak voltage
%   - mVpp      peak to peak mV
%   - mV        DC to peak mV
% SN            hydrophone serial number (4 digits)
%
%
% -- outputs --
% Pa            peak pressure in Pascals
%
%
% Assumed parameters:
% - Density of transmission fluid (water) is 1000 kg/m^3
% - Speed of sound in water = 1500 m/s @ 25 degC
%
% -- edit history --
% Patrick Ye, Butts Pauly Lab, Stanford University
% SAL 2015-11-23
% Patrick Ye, 1/19/16


% if no frequency and/or units specified, error message
if nargin == 1
    error('Please specify frequency of transducer.')
elseif nargin == 2
    error('Please specify units of input values.')
elseif nargin == 3
    errormsg = ['Please specify hydrophone serial number.\n'...
        'Old hydrophone: 1516\n'...
        'New hydrophone: 1572\n'...
        'Willmann lab hydrophone: 1663'];
    error('a:a:a', errormsg)
end

% convert whatever the input units are to mV
if strcmp(units, 'Vpp')     % peak to peak voltage
    Vpp = data;
    mVpp = Vpp * 1000;
    mV   = mVpp / 2;
elseif strcmp(units, 'V')   % voltage amplitude
    V = data;
    mV = V * 1000;
elseif strcmp(units, 'mVpp')
    mVpp = data;
    mV = mVpp / 2;
elseif strcmp(units, 'mV')
    mV = data;
end

% load hydrophone sensitivity values
if SN == 1516
    load freqSensitivity_sn1516.mat % formerly freqSensitivity.mat
elseif SN == 1572
    load freqSensitivity_sn1572.mat % formerly freqSensitivityNew.mat
elseif SN == 1633
    load freqSensitivity_sn1663.mat
end

% based on frequency, look up hydrophone sensitivity
% exception for frequencies out of calibrated range
if f < min(freq) || f > max(freq)
    warning('requested frequency out of range, closest frequency used')
    if f < min(freq)
        f = min(freq);
    else
        f = max(freq);
    end
end

idx = ones(size(f));
for i = 1:size(f, 1)
    for j = 1:size(f, 2)
        tmp = abs(freq - f(i,j));
        ind = find(tmp < 1e-15);
        if isempty(ind)
            [~, ind] = min(tmp);
        end
        idx(i,j) = ind;
    end
end
s = sens(idx); % sensitivities (V/Pa) for the input frequencies
Pa = mV ./ s / 1e3; % Pa, peak pressure.

% the conversion written out:
%
%  mV |  1 V   | 1 Pa |
% ----|--------|------| = Pa, peak pressure
%     | 1e3 mV | n V  |

end