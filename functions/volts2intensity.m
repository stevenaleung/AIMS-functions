function I = volts2intensity(data, f, units)

% Vpp2intensity - This code converts peak-to-peak voltage (V) as measured
%                 from a HNR-0500 hydrophone to instantaneous intensity W/cm^2
%                 SPTP (spatial peak temporal peak).
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
%
% -- outputs --
% I             vector output in units of W/cm^2
%
%
% Assumed parameters:
% - Density of transmission fluid (water) is 1000 kg/m^3
% - Speed of sound in water = 1500 m/s @ 25 degC
%
% -- edit history --
% Patrick Ye, Butts Pauly Lab, Stanford University
% SAL 2015-11-23

Pa = volts2pressure(data, f, units);

% calculate pulse average acoustic intensity (Prms, or Pmax/sqrt(2))
Wm2 = Pa.^2 / 2 / 1000 / 1500; % W/m^2
I = Wm2 / (100^2);             % W/cm^2

end