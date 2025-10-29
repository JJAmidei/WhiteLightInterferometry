N = 2; % Number of Runs

rootFolder = 'C:\Users\dadam\OneDrive\Documents\MATLAB\WhiteLightInterferometer\Team32025';

xCenCorrection = 0; 

sessionTag = datestr(now, 'yyyymmdd');
DataFolder = fullfile(rootFolder, ['WLI_With_Glass_1_' sessionTag]);
rawFolder = fullfile(DataFolder, 'RawData');
procFolder = fullfile(DataFolder, 'ProcessedData');


mkdir(DataFolder);

fprintf('===================\n');
fprintf('WLI Batch Run Started: %s\n', sessionTag);
fprintf('Root Directory: %s\n', DataFolder);
fprintf('===================\n\n');

for i = 1:N
    fprintf('-----------------------------------------------------\n')
    fprintf('Run %d of %d started at %s\n', i, N);


    try

        [dataArray, xLinear, xLinearStage] = WLI_TakeData_Glass(xCenCorrection);

        runTime = datestr(now, 'yyyymmdd');
        rawFile = sprintf('raw_data_%03d_%s.mat', i, runTime);
        rawPath = fullfile(DataFolder, rawFile);
        save(rawPath, 'dataArray', 'xLinear', 'xLinearStage', 'xCenCorrection', 'runTime');
        

        fprintf('Raw Data saved: %s\n', rawPath);

        result = WLI_processData(dataArray, xLinear);

        procFile = sprintf('processed_data_%03d_%s.mat', i, runTime);
        procPath = fullfile(DataFolder, procFile);
        save(procPath, 'result', 'xLinear', 'xLinearStage', 'xCenCorrection', 'runTime');


        fprintf('Processed data saved: %s\n', procPath);
    
    catch ME
        fprintf(2, 'Run %d failed: %s\n', i, ME.message);
        errName = sprintf('ERROR_run_%03d_%s.mat', i, datestr(now, 'yyyymmdd'));
        save(fullfile(DataFolder, errName), 'ME', 'i');

    end
end

fprintf('\n=========================\n');
fprintf('All %d runs completed.\n', N);
fprintf('===========================\n');
