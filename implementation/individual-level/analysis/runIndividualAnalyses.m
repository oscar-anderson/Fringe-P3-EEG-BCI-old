function resultsTable = runIndividualAnalyses(subjectDataset, resultsSavePath, varargin)

datasetInfo = subjectDataset.info;

subjects = datasetInfo.subjects;
numSubjects = length(subjects);

blocks = datasetInfo.blocks;
numBlocks = length(blocks);

morphSets = datasetInfo.morphs;
numMorphSets = length(morphSets(:, 1));

if ~strcmp(resultsSavePath(end), '/')
    resultsSavePath = [resultsSavePath, '/'];
end
plotsFolderPath = [resultsSavePath, 'plots/'];

% Initialise table.
tableVariables = {'subject', 'block', 'morphs', 'cluster', 'p', 'start', 'end', ...
    'channels', 'sum_t', 'max_t', 'n_probe', 'n_irrelevant', 'df', 'cohens_d'};
tableVarTypes = {'double', 'char', 'char', 'double', 'double', 'double', 'double', ...
    'cell', 'double', 'double', 'double', 'double', 'double', 'double'};
numTableColumns = length(tableVariables);

resultsTable = table('Size', [0, numTableColumns], 'VariableNames', tableVariables, 'VariableTypes', tableVarTypes);

for iSubject = 1:numSubjects
    subject = subjects(iSubject);
    subjectField = sprintf('subject%d', subject);

    for iBlock = 1:numBlocks
        block = blocks{iBlock};
        blockField = sprintf('%s', block);

        for iSet = 1:numMorphSets
            morphs = morphSets(iSet, :);
            morphField = sprintf('morph%s', sprintf('_%d', morphs));

            if ~isfield(subjectDataset.(subjectField).(blockField).probe, sprintf('%s', morphField)) || ...
                    ~isfield(subjectDataset.(subjectField).(blockField).irrelevant, sprintf('%s', morphField))
                continue
            elseif length(subjectDataset.(subjectField).(blockField).probe.(morphField).trials.trial) == 1 || ...
                length(subjectDataset.(subjectField).(blockField).irrelevant.(morphField).trials.trial) == 1
                continue
            else
                probeData = subjectDataset.(subjectField).(blockField).probe.(morphField).trials;
                irrelevantData = subjectDataset.(subjectField).(blockField).irrelevant.(morphField).trials;
            
                if nargin > 2
                    ROI = varargin{1}.(subjectField).(blockField).probe_irrelevant.(morphField);
                    
                    individualLevelResults.(subjectField).(blockField).(morphField) = runIndividualAnalysis(probeData, irrelevantData, ROI);
                    
                    results = individualLevelResults.(subjectField).(blockField).(morphField);
                else
                    individualLevelResults.(subjectField).(blockField).(morphField) = runIndividualAnalysis(probeData, irrelevantData);
  
                    results = individualLevelResults.(subjectField).(blockField).(morphField);
                end

                resultsFilename = sprintf('%s_%s_%s.mat', subjectField, blockField, morphField);
                save(fullfile(resultsSavePath, resultsFilename), 'results');
        
                format shortG
                if isfield(results, 'posclusters')

                    sigClustersIdx = find([results.posclusters(:).prob] < 0.05);
                    numSigClusters = length(sigClustersIdx);

                    if isempty(sigClustersIdx)

                        fprintf('\n\n No significant positive clusters found for %s - %s - probe vs. irrelevant - %s \n\n', subjectField, blockField, morphField);

                        iCluster = 1;
                        [clusterChannelNums, clusterSamples] = find(results.posclusterslabelmat == iCluster);
                        pValue = results.posclusters(iCluster).prob;
                        startSample = min(clusterSamples);
                        endSample = max(clusterSamples);
                        startTime = results.time(startSample);
                        endTime = results.time(endSample);
                        channels = strjoin(unique(results.label(clusterChannelNums), 'stable'), ', ');
                        summedT = sum(results.stat(find(results.posclusterslabelmat(:) == iCluster)));
                        maxT = max(results.stat(find(results.posclusterslabelmat(:) == iCluster)));
                        nProbe = length(probeData.trial);
                        nIrrelevant = length(irrelevantData.trial);
                        df = nProbe + nIrrelevant - 2;
                        cohensD = maxT / sqrt(df);

                        newTableRow = {subject, blockField, morphField, iCluster, pValue, startTime, endTime, channels, summedT, maxT, nProbe, nIrrelevant, df, cohensD};
                        resultsTable = [resultsTable; newTableRow];
                        
                    elseif ~isempty(sigClustersIdx)

                        fprintf('\n\n %d significant clusters found for %s - %s - probe vs. irrelevant - %s \n\n', numSigClusters, subjectField, blockField, morphField);

                        for iCluster = 1:numSigClusters
                            [clusterChannelNums, clusterSamples] = find(results.posclusterslabelmat == iCluster);
                            pValue = results.posclusters(iCluster).prob;
                            startSample = min(clusterSamples);
                            endSample = max(clusterSamples);
                            startTime = results.time(startSample);
                            endTime = results.time(endSample);
                            channels = strjoin(unique(results.label(clusterChannelNums), 'stable'), ', ');
                            summedT = sum(results.stat(find(results.posclusterslabelmat(:) == iCluster)));
                            maxT = max(results.stat(find(results.posclusterslabelmat(:) == iCluster)));
                            nProbe = length(probeData.trial);
                            nIrrelevant = length(irrelevantData.trial);
                            df = nProbe + nIrrelevant - 2;
                            cohensD = maxT / sqrt(df);

                            newTableRow = {subject, block, morphField, iCluster, pValue, startTime, endTime, channels, summedT, maxT, nProbe, nIrrelevant, df, cohensD};
                            resultsTable = [resultsTable; newTableRow];
                        end

                        pngSaveName = sprintf('individualResults_%s_%s_%s', subjectField, blockField, morphField);
                        plotSignificantClusters(results, [plotsFolderPath, pngSaveName]);

                    end

                else 
                    fprintf('\n\n No positive clusters found for %s - %s - probe vs. irrelevant - %s \n\n', subjectField, blockField, morphField);
                    newTableRow = {subject, block, morphField, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN};
                    resultsTable = [resultsTable; newTableRow];
                end
            end
        end
    end
end

tableSavePath = [resultsSavePath, 'interpolatedResultsTable.xlsx'];
writetable(resultsTable, tableSavePath)

end
