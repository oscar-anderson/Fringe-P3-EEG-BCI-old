function acrossSubjectsERPs = generateGrandAvgs(acrossSubjectsDataset, channel)

info = acrossSubjectsDataset.info;
blocks = info.blocks;
numBlocks = length(blocks);
conditions = info.conditions;
numConditions = length(conditions);
morphSets = info.morphs;
numMorphSets = length(morphSets(:, 1));

acrossSubjectsERPs = struct();

for iBlock = 1:numBlocks
    blockField = blocks{iBlock};
    blockPlotLabel = sprintf('%s block', blockField);

    for iCondition = 1:numConditions
        conditionField = conditions{iCondition};
        conditionPlotLabel = sprintf('%s condition', conditionField);

        for iSet = 1:numMorphSets
            morphs = morphSets(iSet, :);
            morphField = sprintf(['morph', sprintf('_%d', morphs)]);
            morphPlotLabel = sprintf(['morphs ', sprintf('%s', num2str(morphs, '%d, '))]);
            morphPlotLabel(end) = [];

            ERPs = acrossSubjectsDataset.(blockField).(conditionField).(morphField);

            % Exclude data fields missing ERPs.
            if any(cellfun(@isempty, ERPs))
                missingErpIdx = cellfun(@isempty, ERPs);
                ERPs = ERPs(~missingErpIdx);
            end

            numERPs = length(ERPs);

            cfg = [];
            grandAvg = ft_timelockgrandaverage(cfg, ERPs{:});

            acrossSubjectsERPs.(blockField).(conditionField).(morphField) = grandAvg;

            fig = figure('Visible', 'off'); % Create a new figure with visibility off.
            set(fig, 'Position', get(0, 'Screensize')); % Set figure size to fullscreen.
            
            if strcmp(blockField, 'trump')
                lineColour = [1, 0.45, 0.25]; % Orange.
            elseif strcmp(blockField, 'markle')
                lineColour = [1, 0.3, 0.9]; % Pink.
            elseif strcmp(blockField, 'incidental')
                lineColour = [0, 0.5, 1]; % Blue.
            end

            channelNo = find(strcmp(channel, grandAvg.label));
            grandAvgPlot = plot(grandAvg.time, grandAvg.avg(channelNo, :), 'LineWidth', 4, 'Color', lineColour);
            plotTitle = 'Grand Average Event-Related Potential (Across-Subjects ERP)';
            plotSubtitle = sprintf('(%s - %s - %s - %s)', blockPlotLabel, conditionPlotLabel, morphPlotLabel, channel);
            title(plotTitle, plotSubtitle, 'FontSize', 14, 'FontWeight', 'bold');
            xlabel('Time (seconds)', 'FontSize', 13);
            ylabel('Amplitude (\muV)', 'FontSize', 13);
            xlim([-0.5 1.5]);
            ylim([-5 8]);
            xticks(-0.5:0.1:1.5);
            yticks(-10:1:10);
            xline(0, '--', 'LineWidth', 1.5);
            yline(0, '--', 'LineWidth', 1.5);
            text(-0.5, -12, sprintf('Note. %d total subject ERPs comprising this grand average.', numERPs), FontSize = 11);
            grid on
            box off

            savePath = '/rds/projects/2017/schofiaj-01/oscar/Fringe-P3-investigation/group-level/data/5-ERPs/grandAvg/';
            saveName = sprintf('grandAvg_%s_%s_%s.png', blockField, conditionField, morphField);
            saveas(grandAvgPlot, [savePath, saveName]);

        end
    end
end
