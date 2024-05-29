function plotERPsAndROIs(subjectDataset, fufaDataset, roiDataset, plotSavePath)

subjectDatasetInfo = subjectDataset.info;

subjects = subjectDatasetInfo.subjects;
numSubjects = length(subjects);

blocks = subjectDatasetInfo.blocks;
numBlocks = length(blocks);

conditions = subjectDatasetInfo.conditions;
numConditions = length(conditions);

morphs = subjectDatasetInfo.morphs;
numMorphSets = length(morphs(:, 1));

for iSubject = 1:numSubjects
    subject = subjects(iSubject);
    subjectField = sprintf('subject%d', subject);
    
    for iBlock = 1:numBlocks
        block = blocks{iBlock};
        blockField = sprintf('%s', block);

        subjectData = subjectDataset.(subjectField).(blockField);

        fufaData = fufaDataset.(subjectField).(blockField).probe_irrelevant;

        roiData = roiDataset.(subjectField).(blockField).probe_irrelevant;

        for iMorphSet = 1:numMorphSets
            morphSet = morphs(iMorphSet, :);
            morphField = sprintf('morph%s', sprintf('_%d', morphSet));

            if isfield(fufaData, morphField)
            
                fufaERP = fufaData.(morphField).erp;
                fufaTrials = fufaData.(morphField).trials;
                ROI = roiData.(morphField);
    
                morphLabel = ['morphs ' num2str(ROI.morphSet, '%d, ')];
    
                channels = ROI.channels;
    
                erpRoiPlot = figure('Visible', 'off');
                set(gcf, 'Position', [0, -90, 2000, 900])
                subplot(2, numConditions, [3, 4])
                plotROI(ROI, fufaERP, fufaTrials);
    
                for iCondition = 1:numConditions
                    condition = conditions{iCondition};
                    conditionField = sprintf('%s', condition);

                    if isfield(subjectData.(conditionField), morphField)
    
                        erpData = subjectData.(conditionField).(morphField).erp;
        
                        channelNo = find(ismember(erpData.label, channels));
                        channelIDs = strjoin(channels, ', ');
        
                        subplot(2, numConditions, iCondition)
                        plot(erpData.time, erpData.avg(channelNo, :), 'LineWidth', 2.5, 'DisplayName', morphLabel)
                        title(sprintf('Event-Related Potential (ERP) to %s %s at %s', blockField, morphLabel, channelIDs), sprintf('subject %d, %s block, %s condition)', subject, blockField, conditionField));
                        xlabel('Time (seconds)', 'FontSize', 12);
                        ylabel('Amplitude (\muV)', 'FontSize', 12);
                        xlim([-0.5, 1.5]);
                        ylim([-35, 35]);
                        xticks(-0.5:0.1:1.5);
                        yticks(-35:5:35);
                        xline(0, '--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
                        yline(0, '--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
                        xline(-0.2, '--', 'LineWidth', 1.5, 'Color', [0.7, 0.7, 0.7], 'HandleVisibility', 'off');           
                        box off
                        grid on
        
                        xline(ROI.startTime, 'LineWidth', 1.5, 'LineStyle', '--', 'Color', 'r');
                        xline(ROI.endTime, 'LineWidth', 1.5, 'LineStyle', '--', 'Color', 'r');

                    else
                        warning('No data found for %s, %s, %s, %s. Skipping ERP plot for this condition...\n', subjectField, blockField, conditionField, morphField)
                        continue
                    end

                end

            else
                warning('No FuFA data found for %s, %s, %s. Skipping to next FuFA data struct...\n', subjectField, blockField, morphField)
                continue
            end

            fprintf('\n Plotting ERPs & ROI for %s, %s, %s \n', subjectField, blockField, morphLabel)

            plotSaveName = sprintf('ERP-ROI_%s_%s_%s.png', subjectField, blockField, morphField);
            saveas(erpRoiPlot, [plotSavePath, plotSaveName]);

        end
    end
end
