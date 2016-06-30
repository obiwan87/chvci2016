%DATA
%sloth = io.readsloth('C:\Users\Lenovo\Desktop\data\front_side\labels.json');
%data = io.extractregions(sloth, 'C:\Users\Lenovo\Desktop\data\front_regions','FileStructure', 'ClassFolders','ReadFcn' , @(x) imresize(x, [227 227]));

%TRAINING

% imds = imageDatastore('C:\Users\Lenovo\Desktop\data\front_regions',...
%     'LabelSource', 'foldernames', 'includeSubfolders', true);

front = {'1_front','2_front','5_front','10_front','20_front','50_front','100_front','200_front'};
back = {'1_back','2_back','5_back','10_back','20_back','50_back','100_back','200_back'};

coinset = front;

tbl = countEachLabel(imds_orig);
minSetCount = min(tbl{:,2});
[testSet, trainingSet] = splitEachLabel(imds_orig, 0.3, 'randomize', 'Include', coinset);

%[trainingSet, testSet] = splitEachLabel(imds_orig, 0.3, 'randomize');

%HOG param 
cellSize = [8 8];

%just to get hog features length
rgb = readimage(trainingSet,1);
imgsize = [size(rgb,1) size(rgb,2)];
[hog_8x8, vis8x8] = extractHOGFeatures(rgb,'CellSize', cellSize);
hogFeatureSize = length(hog_8x8);

rotations = 10:10:350;
rotations = 1;
features = zeros(length(trainingSet.Files)*numel(rotations), hogFeatureSize);

training_labels = trainingSet.Labels;
training_labels = repmat(training_labels, 1, numel(rotations));
training_labels = training_labels(:);
for i = 1:length(trainingSet.Files)    
    rgb = readimage(trainingSet,i);
    for j=1:numel(rotations)
         rgb = imrotate(rgb, rot, 'bilinear', 'crop');
         features(i+j-1,:) = extractHOGFeatures(rgb , 'CellSize', cellSize);
    end    
end

test_features = zeros(length(testSet.Files), hogFeatureSize);
for i = 1:length(testSet.Files)    
    rgb = readimage(testSet,i);
    test_features(i,:) = extractHOGFeatures(rgb , 'CellSize', cellSize);    
end


%Training classifier

t = templateSVM('Standardize',1,'KernelFunction','linear');
classifier = fitcecoc(features, training_labels, 'Learners', t);

%HERE TESTING
predictedLabels = predict(classifier, test_features);

testLabels = testSet.Labels;
grouporder = coinset;
%%
[confMat, order] = confusionmat(testLabels, predictedLabels,'order',grouporder );

labels=grouporder;
confMat = bsxfun(@rdivide,confMat,sum(confMat,2))*100;
h = figure;
h.Color = 'w';
h.Position = [ 680   294   928   684 ];
heatmap(confMat, labels, labels, '%.1f %%','Colormap','red','ShowAllTicks',1,'UseLogColorMap',true,'Colorbar',true);
title(sprintf('Cell Size %d x %d, Image Size %d x %d', cellSize(1), cellSize(2), imgsize(1), imgsize(2)));
%HeatMap(confMat,'RowLabels',labels,'ColumnLabels',labels,'Annotate', true, 'AnnotColor', [1 1 0])
