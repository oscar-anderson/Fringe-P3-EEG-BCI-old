function preprocessedDataset = preprocess(dataset, baselineWindow, bpFreq, bsFreq, refChannel, artifactThreshold)

% Description:
    % preprocess() applies the blanket preprocessing steps to all data in
    % the dataset.

    % Input:
        % dataset = cell array comprising FieldTrip data structs to be preprocessed.
        % baselineWindow = array containing start and end of baseline window (seconds).
        % bpFreq = bandpass frequency range, specified as [lowFreq highFreq] in Hz.
        % bsFreq = array containing min and max frequency of band-stop filter (Hz).
        % refChannel = cell array of strings for channels to re-reference to.
        % artifactThreshold = array containing min and max amplitude to permit in data (mV)

     % Output:
        % preprocessedDataset = 

numData = length(dataset);
preprocessedDataset = cell(size(dataset));

for iData = 1:numData
    
    data = dataset{iData};
    
    cfg = [];
    
    % Baseline correct.
    cfg.demean = 'yes';
    cfg.baselinewindow = baselineWindow;

    % Detrend.
    cfg.detrend = 'yes';
    
    % Band-pass filter.
    cfg.bpfilter = 'yes';
    cfg.bpfreq = bpFreq;
    cfg.bpfilttype = 'fir';
    
    % Band-stop filter.
    cfg.bsfilter = 'yes';
    cfg.bsfilttype = 'fir';
    cfg.bsfreq = bsFreq;
    
    % Re-reference.
    cfg.reref = 'yes';
    cfg.refmethod = 'avg';
    cfg.channel = {'Fp1', 'AF3', 'F7', 'F3', 'FC1', 'FC5', 'T7', 'C3', 'CP1', 'CP5', 'P7', 'P3', 'Pz', 'PO3', 'O1', 'Oz', 'O2', 'Po4', 'P4', 'P8', 'CP6', 'CP2', 'C4', 'T8', 'FC6', 'FC2', 'F4', 'F8', 'AF4', 'Fp2', 'Fz', 'Cz', 'A1', 'A2', 'LEOG', 'REOG', 'UEOG', 'DEOG', 'EXG7', 'EXG8'};
    cfg.refchannel = refChannel;
    
    % Apply pre-processing.
    dataset{iData} = ft_preprocessing(cfg, data);

    % Display number of trials in preprocessed data before thresholding.
    fprintf('\n\nNumber of trials in data file %d data pre-thresholding: %d\n\n', iData, length(dataset{iData}.trial));
    
    % Apply objective artifact exclusion threshold.
    data = dataset{iData};

    % Check number of trials in data before thresholding.
    numTrialsPre = length(dataset{iData}.trial);

    cfg = [];
    cfg.artfctdef.threshold.channel = {'Fp1', 'AF3', 'F7', 'F3', 'FC1', 'FC5', 'T7', 'C3', 'CP1', 'CP5', 'P7', 'P3', 'Pz', 'PO3', 'O1', 'Oz', 'O2', 'Po4', 'P4', 'P8', 'CP6', 'CP2', 'C4', 'T8', 'FC6', 'FC2', 'F4', 'F8', 'AF4', 'Fp2', 'Fz', 'Cz', 'A1', 'A2', 'LEOG', 'REOG', 'UEOG', 'DEOG', 'EXG7', 'EXG8'};
    cfg.artfctdef.threshold.bpfilter = 'no';
    cfg.artfctdef.threshold.min = threshold(1);
    cfg.artfctdef.threshold.max = threshold(2);
    
    [cfg, artifact] = ft_artifact_threshold(cfg, data);
    
    preprocessedDataset{iData} = ft_rejectartifact(cfg, data);

    numTrialsPost = length(preprocessedDataset{iData}.trial);
    numTrialsRemoved = numTrialsPre - numTrialsPost;
    fprintf('\n\nNumber of trials removed from data file %d through thresholding: %d\n\n', iData, numTrialsRemoved);

end
