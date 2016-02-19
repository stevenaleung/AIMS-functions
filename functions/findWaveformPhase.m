% findWaveformPhase.m
% Patrick Ye
% http://kbplab.stanford.edu/
%
% Calculates phase (radians) of a sinusoidal signal
%
% Inputs:
% - time vector
% - voltage vector
% - frequency of signal (relative to time vector)
% - time offset
% 
% Outputs:
% - phase in radians
%
% Notes: function uses sine as the reference function for phase
% Idea source: http://www.mathworks.com/support/solutions/en/data/1-1CATV/?solution..

function phase = findWaveformPhase(time, volt, freq, timeOffset)

V = fft(volt);
V = fftshift(V);
f = ((1:length(time))-(length(time)/2+1))/10; % centers DC frequency at 0, divide by 10 for 10 microsecond sampling
% mag = abs(V)/length(volt);
phi = angle(V);
phiSine = phi(f==freq) + pi / 2; % radians, pi/2 is correction for FT of sine

phaseTime = phiSine / (-2*pi*freq); % us, fourier transform linear phase, negative sign for sine
timeTrue = phaseTime + timeOffset;  % account for when oscilloscope started measuring

T = 1/freq; % period in microseconds
phase = timeTrue / T * 2*pi; % radians, inclouding time offset

% figure
% subplot(2, 1, 1)
% plot(f, abs(V))
% xlabel('frequency (MHz)')
% 
% subplot(2, 1, 2)
% plot(f, angle(V))

end