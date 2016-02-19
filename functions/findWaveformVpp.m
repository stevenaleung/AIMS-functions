% findWaveformVpp.m
% Patrick Ye
% http://kbplab.stanford.edu/

function Vpp = findWaveformVpp(~, volt)

Vpp = max(max(volt)) - min(min(volt));

end