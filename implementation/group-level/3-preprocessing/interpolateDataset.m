function interpolatedDataset = interpolateDataset(cleanDataset, method)

numSubjects = length(cleanDataset);
interpolatedDataset = cell(1, numSubjects);

for iSubject = 1:numSubjects
    data = cleanDataset{iSubject};

    interpolatedDataset{iSubject} = interpolateMissing(data, method);
end

end
