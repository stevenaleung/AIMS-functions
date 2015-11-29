% findWaveformVpp_FT.m
% Patrick Ye
% http://kbplab.stanford.edu/

function Vpp = findWaveformVpp_FT(time, volt, freq)

V = fft(volt);
V = fftshift(V);
f = ((1:length(time))-(length(time)/2+1))/10; % centers DC frequency at 0, divide by 10 for 10 microsecond sampling
mag = abs(V);
Vpp = 2*2*mag(f==freq) / length(volt); % one 2 for 1/2 amplitude of sine, another 2 for peak-peak voltage

end