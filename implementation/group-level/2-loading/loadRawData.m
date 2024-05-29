function rawDataset = loadRawData(fileNames, rawDataPath)

cd(rawDataPath);

numFiles = length(fileNames);
rawDataset = cell(1, numFiles);

for iFile = 1:numFiles
    dataFile = fileNames{iFile};
    cfg = [];
    cfg.dataset = dataFile;
    cfg.trialdef.eventtype = 'STATUS'; % Trials are marked as type 'STATUS'.
    cfg.trialdef.eventvalue = 111:170; % Select relevant trials by markers.
    cfg.trialdef.prestim = 0.5; % Specify time to include pre-probe.
    cfg.trialdef.poststim = 1.5; % Specify time to include post-probe.
    cfg = ft_definetrial(cfg);

    % Load data into structs.
    rawDataset{iFile} = ft_preprocessing(cfg);
end
