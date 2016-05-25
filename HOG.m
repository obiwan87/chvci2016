%DATA
%sloth = io.readsloth('C:\Users\Lenovo\Desktop\data\front_side\front.json');
%data = io.extractregions(sloth, 'C:\Users\Lenovo\Desktop\data\regions','ReadFcn' , @(x) imresize(x, [320 320]));

%TRAINING


cellSize = [8 8];
rgb = imread(data{1});

%just to get hog features length
[hog_8x8, vis8x8] = extractHOGFeatures(rgb,'CellSize', cellSize);
hogFeatureSize = length(hog_8x8);


trainingFeatures = [];
trainingLabels   = [];
features = zeros(numel(data(:,1)), hogFeatureSize);
labels = zeros(numel(data(:,1)),1);
for i = 1:(numel(data(:,1)))
    
    rgb = imread(data{i});
    features(i,:) = extractHOGFeatures(rgb, 'CellSize', cellSize);
    labels(i,1) = str2num(data{i,2});
end

%Training classifier
%classifier = fitcecoc(features, labels);

%HERE SHOULD BE TESTING
%predictedLabels = predict(classifier, test_features);
%confMat = confusionmat(test_labels, predictedLabels);
