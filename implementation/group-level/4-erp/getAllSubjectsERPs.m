function allSubjectERPs = getAllSubjectERPs(subjectDataset)

allSubjectERPs = struct();
allSubjectERPs.info = subjectDataset.info;

subjects = subjectDataset.info.subjects;
numSubjects = length(subjects);

blocks = subjectDataset.info.blocks;
numBlocks = length(blocks);

conditions = subjectDataset.info.conditions;
numConditions = length(conditions);

morphSets = subjectDataset.info.morphs;
numMorphSets = length(morphSets(:, 1));

for iBlock = 1:numBlocks
    blockField = blocks{iBlock};

    for iCondition = 1:numConditions
        conditionField = conditions{iCondition};

        for iSet = 1:numMorphSets

            morphs = morphSets(iSet, :);
            morphField = sprintf('morph%s', sprintf('_%d', morphs));

            for iSubject = 1:numSubjects
                subjectField = sprintf('subject%d', iSubject);

                if isfield(subjectDataset.(subjectField).(blockField).(conditionField), sprintf('%s', morphField))
                    allSubjectERPs.(blockField).(conditionField).(morphField){iSubject} ...
                    = subjectDataset.(subjectField).(blockField).(conditionField).(morphField).erp;
                else
                    continue
                end
            end
        end
    end
end

end
