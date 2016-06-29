%% Data
%sloth = io.readsloth('C:\Users\Lenovo\Desktop\coins\labels-front-back.json');
%sloth = io.readsloth('C:\Users\Lenovo\Desktop\data\front_side\labels.json');
%sloth = io.readsloth('C:\Users\Lenovo\Desktop\data\501\labels-front-back.json');
%data = io.extractregions(sloth, 'C:\Users\Lenovo\Desktop\data\front_regions','FileStructure', 'ClassFolders','ReadFcn' , @(x) imresize(x, [80 80]));


%% Training
imgs = imageDatastore('C:\Users\Lenovo\Desktop\data\front_regions',...
    'LabelSource', 'foldernames', 'includeSubfolders', true);

[trainingSet, testSet] = splitEachLabel(imgs, 0.7, 'randomize');

numClusters = 64 ;

binSize = 24 ;
magnif = 5 ;
x = 64;

descriptors = {length(trainingSet.Labels)};



% Get SIFT descriptors from all images

for i = 1:length(trainingSet.Labels)
    
    Is = single(rgb2gray(readimage(trainingSet,i)));
    I = vl_imsmooth(Is, sqrt((binSize/magnif)^2 - .25)) ;
    [f, d] = vl_dsift(I, 'size', binSize) ;
    descriptors{i} = d;
    
end

D = horzcat(descriptors{1:length(trainingSet.Labels)});


% GMM


[means, covariances, priors] = vl_gmm(single(D), numClusters) ;


training_features = zeros(length(trainingSet.Labels), 2*numClusters*128);
for i = 1:length(length(trainingSet.Labels))
    
   
    training_features(i,:) = vl_fisher(single(D(:,(1+x*(i-1)):(x+x*(i-1)))), means, covariances, priors);
    
end


training_labels = trainingSet.Labels;
classifier = fitcecoc(training_features, training_labels);


%TESTING


test_features = zeros(length(testSet.Labels), 2*numClusters*128);
test_descriptors = {length(testSet.Labels)};

for i = 1:length(testSet.Files)
    
    Is = single(rgb2gray(readimage(testSet,i)));
    I = vl_imsmooth(Is, sqrt((binSize/magnif)^2 - .25)) ;
    [f, d_test] = vl_dsift(I, 'size', binSize) ;
    test_descriptors{i} = d_test;
    
end

D_test = horzcat(test_descriptors{1:length(testSet.Labels)});
for i = 1:length(length(testSet.Labels))
    
   
    test_features(i,:) = vl_fisher(single(D_test(:,(1+x*(i-1)):(x+x*(i-1)))), means, covariances, priors);
    
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
