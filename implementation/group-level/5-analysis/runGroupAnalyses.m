function groupLevelResults = runAllGroupAnalyses(groupLevelERPs, resultsSavePath)

groupLevelResults = struct();
groupLevelResults.info = groupLevelERPs.info;

blocks = groupLevelResults.info.blocks;
numBlocks = length(blocks);

morphSets = groupLevelResults.info.morphs;
numMorphSets = length(morphSets(:, 1));

% Ensure resultsSavePath is folder.
if ~strcmp(resultsSavePath(end), '/')
    resultsSavePath = [resultsSavePath, '/'];
end

plotsFolderPath = [resultsSavePath, 'plots/'];

for iBlock = 1:numBlocks
    blockField = blocks{iBlock};

    for iSet = 1:numMorphSets
        morphs = morphSets(iSet, :);
        morphField = sprintf('morph%s', sprintf('_%d', morphs));

        probeField = 'probe';
        irrelevantField = 'irrelevant';

        % Select groups of ERPs to contrast.
        probeData = groupLevelERPs.(blockField).(probeField).(morphField);
        irrelevantData = groupLevelERPs.(blockField).(irrelevantField).(morphField);

        % Skip any ERPs that do not have a probe/irrelevant equivalent.
        if any(cellfun(@isempty, probeData))
            missingERPs = cellfun(@isempty, probeData);
            irrelevantData = irrelevantData(~missingERPs);
            probeData = probeData(~missingERPs);
        end

        if any(cellfun(@isempty, irrelevantData))
            missingERPs = cellfun(@isempty, irrelevantData);
            probeData = probeData(~missingERPs);
            irrelevantData = irrelevantData(~missingERPs);
        end

        % Run statistical test.
        groupLevelResults.(blockField).(morphField) = runGroupAnalysis(probeData, irrelevantData);

        % Save results.
        results = groupLevelResults.(blockField).(morphField);

        format shortG

        if isfield(results, 'posclusters')
            sigClustersIdx = find([results.posclusters(:).prob] < 0.05);
            numSigClusters = length(sigClustersIdx);
            if numSigClusters > 0
                fprintf('\n\n%d significant clusters found for %s - probe vs. irrelevant - %s\n\n', numSigClusters, blockField, morphField);
                results.keyStats = struct();
                for iCluster = 1:numSigClusters
                    clusterField = sprintf('cluster%d', iCluster);
                    results.keyStats.(clusterField).pValue = results.posclusters(iCluster).prob;
                    results.keyStats.(clusterField).sumSampleT = sum(results.stat(find(results.posclusterslabelmat(:) == iCluster)));
                    results.keyStats.(clusterField).maxSampleT = max(results.stat(find(results.posclusterslabelmat(:) == iCluster)));
                    results.keyStats.(clusterField).numProbeERPs = numel(probeData);
                    results.keyStats.(clusterField).numIrrelevantERPs = numel(irrelevantData);
                    results.keyStats.(clusterField).df = (results.keyStats.(clusterField).numProbeERPs + results.keyStats.(clusterField).numIrrelevantERPs) - 2;
                    results.keyStats.(clusterField).cohensD = results.keyStats.(clusterField).maxSampleT / sqrt(results.keyStats.(clusterField).df);
                end
                pngSaveName = sprintf('groupResults_%s_%s', blockField, morphField);
                plotSignificantClusters(results, [plotsFolderPath, pngSaveName]);
            elseif numSigClusters == 0
                fprintf('\n\nNo significant positive clusters found for %s - probe vs. irrelevant - %s\n\n', blockField, morphField);
            elseif isempty(results.posclusters)
                fprintf('\n\nNo positive clusters found for %s - probe vs. irrelevant - %s\n\n', blockField, morphField);
            end
        end

        resultsFilename = sprintf('groupLevelResults_%s_%s.mat', blockField, morphField);
        save(fullfile(resultsSavePath, resultsFilename), 'results');

    end
end
end
