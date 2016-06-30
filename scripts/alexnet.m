%% Extract ROIs
io.extractregions(sloth, 'C:\Users\thesp\home\uni\cvhci\data\all - regions');

%% Setup Datastore
% Before doing this, we extracted the ROIs from our labeled dataset.

imds = imageDatastore('C:\Users\thesp\home\uni\cvhci\data\all - regions',...
    'LabelSource', 'foldernames', 'includeSubfolders', true);

tbl = countEachLabel(imds)

%% Split Test and Training-Set and extract Features
[trainingSet, testSet] = splitEachLabel(imds, 0.3, 'randomize');
featureLayer = 'fc7';
trainingFeatures = activations(convnet, trainingSet, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');

trainingLabels = trainingSet.Labels;

%% Train SVM
% Train multiclass SVM classifier using a fast linear solver, and set
% 'ObservationsIn' to 'columns' to match the arrangement used for training
% features.
classifier = fitcecoc(trainingFeatures, trainingLabels, ...
    'Learners', 'Linear', 'Coding', 'onevsall', 'ObservationsIn', 'columns');

% Extract test features using the CNN
testFeatures = activations(convnet, testSet, featureLayer, 'MiniBatchSize',32);

% Pass CNN image features to trained classifier
predictedLabels = predict(classifier, testFeatures);

% Get the known labels
testLabels = testSet.Labels;

% Tabulate the results using a confusion matrix.
[confMat, order] = confusionmat(testLabels, predictedLabels);

% Convert confusion matrix into percentage form
confMat = bsxfun(@rdivide,confMat,sum(confMat,2));

heatmap(confMat, char(order), char(order), 1,'Colormap','red','ShowAllTicks',1,'UseLogColorMap',true,'Colorbar',true);