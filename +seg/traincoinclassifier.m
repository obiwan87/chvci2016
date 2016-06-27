function [classifier] = traincoinclassifier(sloth, path, convnet, parameters, overlap)

display('Circle Detection: ');
tic
[~, detection_results] = seg.evalcircles(sloth, parameters, ...
            'RequiredOverlap', overlap, 'MergeCircles', false, 'Method', 'Naive');
toc

display('Region Extraction: ');
tic
io.extractregions(detection_results, path, ... 
    'FileStructure', 'ClassFolders', 'ReadFcn', @(x) imresize(x, [50 50]));
toc

display('Feature Extraction: ');
tic
imds = imageDatastore(path, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
featureLayer = 'fc7';
trainingFeatures = activations(convnet, imds, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');
toc

display('Classifier Training: ');
tic
classifier = fitcecoc(trainingFeatures, imds.Labels, ...
    'Learners', 'Linear', 'Coding', 'onevsall', 'ObservationsIn', 'columns');
toc
end