load bc_train_filtered
bcTrainData
load bc_proggenes231

[tf, idx] = ismember(bcProgGeneList.Accession, bcTrainData.Accession);
progValues = bcTrainData.Log10Ratio(idx, :);
progAccession = bcTrainData.Accession(idx);
progSamples = bcTrainData.Samples;

progValues = progValues([1:35 197:231],:);
progAccession = progAccession([1:35 197:231]);

cg_s = clustergram(progValues, 'RowLabels', progAccession,...
                               'ColumnLabels', progSamples,...
                               'Cluster', 'Row',...
                               'ImputeFun', @knnimpute)