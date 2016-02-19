function createCalibrationFile()

[filename, filepath] = uigetfile('hydrophoneCalibrationFiles/*.xls');
[data, txt, ~] = xlsread(fullfile(filepath, filename));
freq = data(:, 1);
sens = data(:, 3);

tmp = strsplit(filename, '.');
matFilename = strcat(filepath, tmp{1}, '.mat');
save(matFilename, 'freq', 'sens');