function trialData = getTrialData(subjectData, block, condition, morphs)

% Description:
    % This produces a FieldTrip data struct containing only the trials for the
    % input selection of morphs.

% Input:
    % subjectData = FieldTrip data struct for given subject.
    % block = String containing block name (trump/markle/incidental).
    % condition = String containing condition (probe/irrelevant).
    % morphs = Numerical array containing morphs (1:10) to get trials for.

% Output:
    % trialData = FieldTrip data struct containing specified subject trials.

% Initialise trial markers for each morph presentation.
switch condition
    case 'probe'
        switch block
            case 'trump'
                trialMarkers = 141:150;
                relevantTrialMarkers = trialMarkers(morphs);
            case 'markle'
                trialMarkers = 151:160;
                relevantTrialMarkers = trialMarkers(morphs);
            case 'incidental'
                trialMarkers = 161:170;
                relevantTrialMarkers = trialMarkers(morphs);
        end
    case 'irrelevant'
        switch block
            case 'trump'
                trialMarkers = 111:120;
                relevantTrialMarkers = trialMarkers(morphs);
            case 'markle'
                trialMarkers = 121:130;
                relevantTrialMarkers = trialMarkers(morphs);
            case 'incidental'
                trialMarkers = 131:140;
                relevantTrialMarkers = trialMarkers(morphs);
        end
    case 'probe_irrelevant'
        switch block
            case 'trump'
                probeMarkers = 141:150;
                irrelevantMarkers = 111:120;
                relevantTrialMarkers = [probeMarkers(morphs), irrelevantMarkers(morphs)];
            case 'markle'
                probeMarkers = 151:160;
                irrelevantMarkers = 121:130;
                relevantTrialMarkers = [probeMarkers(morphs), irrelevantMarkers(morphs)];
            case 'incidental'
                probeMarkers = 161:170;
                irrelevantMarkers = 131:140;
                relevantTrialMarkers = [probeMarkers(morphs), irrelevantMarkers(morphs)];
        end
end

% Find relevant trials in data.
trialsIdx = find(ismember(subjectData.trialinfo, relevantTrialMarkers));

% Return data struct containing relevant trials.
cfg = [];
cfg.trials = trialsIdx;
trialData = ft_selectdata(cfg, subjectData);

end
