%DATA
%sloth = io.readsloth('C:\Users\Lenovo\Desktop\data\front_side\labels.json');
%data = io.extractregions(sloth, 'C:\Users\Lenovo\Desktop\data\front_regions','FileStructure', 'ClassFolders','ReadFcn' , @(x) imresize(x, [227 227]));

%TRAINING

imgs = imageDatastore('C:\Users\Lenovo\Desktop\data\front_regions',...
    'LabelSource', 'foldernames', 'includeSubfolders', true);

tbl = countEachLabel(imgs);
[trainingSet, testSet] = splitEachLabel(imgs, 0.3, 'randomize');


%HOG param 
cellSize = [24 24];




%just to get hog features length
rgb = readimage(trainingSet,1);
[hog_8x8, vis8x8] = extractHOGFeatures(rgb,'CellSize', cellSize);
hogFeatureSize = length(hog_8x8);


features = zeros(length(trainingSet.Files), hogFeatureSize);

for i = 1:length(trainingSet.Files)
    
    rgb = readimage(trainingSet,i);
    features(i,:) = extractHOGFeatures(rgb , 'CellSize', cellSize);
    
end

%Training classifier
training_labels = trainingSet.Labels;
classifier = fitcecoc(features, training_labels);

%HERE TESTING
test_features = zeros(length(testSet.Files), hogFeatureSize);
for i = 1:length(testSet.Files)
    
    rgb = readimage(testSet,i);
    test_features(i,:) = extractHOGFeatures(rgb , 'CellSize', cellSize);
    
end

predictedLabels = predict(classifier, test_features);

testLabels = testSet.Labels;
grouporder= cellstr([ '1_front  ' ; '2_front  ' ; '5_front  '  ; '10_front ' ;'20_front '; '50_front ';...
    '100_front' ;'200_front']);
[confMat, order] = confusionmat(testLabels, predictedLabels,'order',grouporder );

labels=grouporder;
confMat = bsxfun(@rdivide,confMat,sum(confMat,2));
heatmap(confMat, labels, labels, 1,'Colormap','red','ShowAllTicks',1,'UseLogColorMap',true,'Colorbar',true);
%HeatMap(confMat,'RowLabels',labels,'ColumnLabels',labels,'Annotate', true, 'AnnotColor', [1 1 0])
