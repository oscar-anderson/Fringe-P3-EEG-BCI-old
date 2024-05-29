function subjectDataset = getSubjectDataset(cleanDataset, morphSets, conditionType)

% Description:
    % Extracts trials and computes ERPs to specified morph sets, either for
    % each probe and irrelevant condition, or across both probe and
    % irrelevant conditions.

% Initialise experiment parameters.
numSubjects = length(cleanDataset);
subjects = 1:numSubjects;
blocks = {'trump', 'markle', 'incidental'};
numBlocks = length(blocks);

switch conditionType
    case 'separate'
        conditions = {'probe', 'irrelevant'};
    case 'combined'
        conditions = {'probe_irrelevant'};
end

numConditions = length(conditions);

% Extract relevant morph trials and organise into dataset struct.
subjectDataset = struct();
numMorphSets = length(morphSets(:, 1));

for iSubject = 1:numSubjects
    subjectField = sprintf('subject%d', iSubject);
    subjectData = cleanDataset{iSubject};

    for iBlock = 1:numBlocks
        block = blocks{iBlock};
        blockField = sprintf('%s', block);

        for iCondition = 1:numConditions
            condition = conditions{iCondition};
            conditionField = sprintf('%s', condition);

        for iSet = 1:numMorphSets
            morphs = morphSets(iSet, :);
            morphField = sprintf('morph%s', sprintf('_%d', morphs));

            % Organise dataset into sets of trials for individual-level analysis.
            trialData = createTrialData(subjectData, block, condition, morphs);

            if isempty(trialData.trial)
                continue
            else
                
                % Re-apply baseline correction following ICA/artifact rejection.
                cfg = [];
                cfg.preproc.demean = 'yes';
                cfg.preproc.baselinewindow = [-0.2, 0];
                cfg.preproc.detrend = 'yes';

                trialData = ft_preprocessing(cfg, trialData);

                subjectDataset.(subjectField).(blockField).(conditionField).(morphField).trials = trialData;

                % Compute ERPs of trial sets for group-level analysis.
                cfg = [];
                cfg.channel = 'all';
                cfg.keeptrials = 'no';
                cfg.trials = 'all';
                cfg.latency = 'all';
                cfg.preproc.demean = 'yes';
                cfg.preproc.baselinewindow = [-0.2, 0];
                cfg.preproc.detrend = 'yes';
                
                erp = ft_timelockanalysis(cfg, trialData);
                
                subjectDataset.(subjectField).(blockField).(conditionField).(morphField).erp = erp;
            end
        end
        end
    end
end

subjectDataset.info.subjects = subjects;
subjectDataset.info.blocks = blocks;
subjectDataset.info.conditions = conditions;
subjectDataset.info.morphs = morphSets;

end
