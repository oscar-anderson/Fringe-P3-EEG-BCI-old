function roiDataset = findROIs(fufaDataset, searchWindow, volumeToSearch, roiSavePath)

warning on

info = fufaDataset.info;

subjects = info.subjects;
numSubjects = length(subjects);

blocks = info.blocks;
numBlocks = length(blocks);

conditions = info.conditions;
numConditions = length(conditions);

morphSets = info.morphs;
numMorphSets = length(morphSets(:, 1));

timeWindow = searchWindow.time; % Time window (seconds).
channelWindow = searchWindow.space; % Space window (n channels).

% Volume to search (seconds).
volumeStart = volumeToSearch.latency(1);
volumeEnd = volumeToSearch.latency(end);

% Volume to search (channels).
volumeChannels = volumeToSearch.channels; % Cell array containing channel names.

% Initialise ROI dataset struct.
roiDataset = struct();

for iSubject = 1:numSubjects
    subject = subjects(iSubject);
    subjectField = sprintf('subject%d', subject);

    for iBlock = 1:numBlocks
        block = blocks{iBlock};
        blockField = sprintf('%s', block);

        for iCondition = 1:numConditions
            condition = conditions{iCondition};
            conditionField = sprintf('%s', condition);

            for iMorphSet = 1:numMorphSets
                morphSet = morphSets(iMorphSet, :);
                morphField = sprintf('morph%s', sprintf('_%d', morphSet));

                fprintf('\n Finding ROI in FuFA for %s - %s - %s... \n', subjectField, blockField, morphField)

                % Extract FuFA trials and ERP to search through.
                if isfield(fufaDataset.(subjectField).(blockField).(conditionField), sprintf('%s', morphField))
                    fufaData = fufaDataset.(subjectField).(blockField).(conditionField).(morphField);
                    fufaTrials = fufaData.trials;
                    FuFA = fufaData.erp;
                else
                    warning('No FuFA data found for %s - %s - %s. Skipping to next FuFA data struct...', subjectField, blockField, morphField)
                    continue
                end

                % Convert input time window to samples for iteration.
                samplingRate = fufaTrials.fsample;
                sampleWindow = round(timeWindow * samplingRate);

                % Specify samples in data to search through.
                volumeSamples = find(FuFA.time >= volumeStart & FuFA.time <= volumeEnd);
                numVolumeSamples = length(volumeSamples);
                numSampleIterations = numVolumeSamples - sampleWindow + 1;

                % Specify channels in data to search through.
                dataChannels = FuFA.label;

                % Handle errors in input channels.
                numDuplicates = length(volumeChannels) - length(unique(volumeChannels));
                if numDuplicates > 0
                    warning('Duplicates in volumeToSearch.channels input. Removing %d duplicates... \n', numDuplicates)
                    volumeChannels = unique(volumeChannels); % Remove any duplicates.
                end

                if ~isempty(setdiff(volumeChannels, dataChannels)) % Check input volume channels are valid.
                    invalidChannels = setdiff(volumeChannels, dataChannels);
                    volumeChannels = intersect(volumeChannels, dataChannels);
                    warning('%s in volumeToSearch.channels input not found in FuFA. Proceeding without these channels...', strjoin(invalidChannels, ', '))
                end

                numVolumeChannels = length(volumeChannels);
                numChannelIterations = numVolumeChannels - channelWindow + 1;
                volumeChannelNums = find(ismember(dataChannels, volumeChannels));

                % Initialise field to store window average amplitude.
                ROI.avgAmplitude = [];

                for iSample = 1:numSampleIterations
                    startSample = volumeSamples(iSample);
                    
                    for iChannel = 1:numChannelIterations
                        startChannelNum = volumeChannelNums(iChannel);

                        newWindow = FuFA.avg(startChannelNum:(startChannelNum + channelWindow) - 1, startSample:(startSample + sampleWindow) - 1);
                        newAvgAmplitude = mean(newWindow(:));

                        if iSample == 1 && iChannel == 1 || newAvgAmplitude > ROI.avgAmplitude
                            ROI.avgAmplitude = newAvgAmplitude;
                            ROI.startTime = FuFA.time(startSample);
                            ROI.endTime = FuFA.time((startSample + sampleWindow) - 1);
                            ROI.channels = FuFA.label(startChannelNum:(startChannelNum + channelWindow) - 1);
                            ROI.startSample = startSample;
                            ROI.endSample = (startSample + sampleWindow) - 1;
                            ROI.channelIdxs = find(ismember(FuFA.label, ROI.channels));
                        end
                    end
                end

                ROI.subject = subject;
                ROI.block = block;
                ROI.condition = condition;
                ROI.morphSet = morphSet;
                roiDataset.(subjectField).(blockField).(conditionField).(morphField) = ROI;

                resultsSaveName = sprintf('ROI_%s_%s_%s.mat', subjectField, blockField, morphField);
                save(fullfile(roiSavePath, resultsSaveName), 'ROI');

                if length(fufaTrials.trial) == 1
                    warning('FuFA for %s - %s - %s data comprises only one trial. \n', subjectField, blockField, morphField)
                end

%                 roiPlot = plotROI(ROI, FuFA, fufaTrials);
% 
%                 plotsSavePath = [resultsSavePath, 'plots/'];
%                 plotSaveName = sprintf('roiPlot_%s_%s_%s_%s.png', subjectField, blockField, conditionField, morphField);
%                 saveas(roiPlot, [plotsSavePath, plotSaveName]);

                fprintf('ROI for %s - %s - %s found. \n', subjectField, blockField, morphField)

                close

            end
        end
    end
end

end
