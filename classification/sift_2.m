%% Data
%sloth = io.readsloth('~/Desktop/coins/401/labels.json');
%data = io.extractregions(sloth, '~/Desktop/coins/regions', 'ReadFcn' , @(x) imresize(x, [320 320]));


%% Training
imgs = imageDatastore('C:\Users\Lenovo\Desktop\data\front_regions',...
    'LabelSource', 'foldernames', 'includeSubfolders', true);

[trainingSet, testSet] = splitEachLabel(imgs, 0.7, 'randomize');

peak_thresh = 2;
k = 100;
edge=5;

descriptors = {length(trainingSet.Labels)};
descriptorsPerImage = zeros(length(trainingSet.Labels), 1);


% Get SIFT descriptors from all images

for i = 1:length(trainingSet.Labels)
    
    I = single(rgb2gray(readimage(trainingSet,i)));
    [f, d] = vl_sift(I , 'PeakThresh', peak_thresh, 'EdgeThresh', edge,'Octaves',7,'FirstOctave',0 ,'Levels', 3);
    descriptors{i} = d;
    descriptorsPerImage(i) = size(d, 2);
    
end
training_labels = trainingSet.Labels;
D = horzcat(descriptors{1:length(trainingSet.Labels)});


% Use k-means to cluster descriptors

[centers, a] = vl_kmeans(single(D), k, 'Initialization', 'plusplus');


% Assign descriptors of each image to clusters to get feature vectors
features = zeros(length(trainingSet.Labels), k);
descCounter = 0;
for j = 1:length(trainingSet.Labels)
    descriptor = horzcat(descriptors{j});
    for i = 1:descriptorsPerImage(j)  
        [~, cluster] = min(vl_alldist(single(descriptor(:,i)), centers)) ; 
        features(j, cluster) = features(j, cluster) + 1;
    end
    
    descCounter = descCounter + descriptorsPerImage(j);
end
% Optional - transform to binary features, might be better for SVM
%features = sign(features);



% SVM
classifier = fitcecoc(features, training_labels);


testdescriptors = {length(trainingSet.Labels)};
testdescriptorsPerImage = zeros(length(trainingSet.Labels), 1);

for i = 1:length(testSet.Files)
    
    I = single(rgb2gray(readimage(testSet,i)));
    [f_test, d_test] = vl_sift(I , 'PeakThresh', peak_thresh, 'EdgeThresh', edge,'Octaves',7,'FirstOctave',0 ,'Levels', 3);
    testdescriptors{i} = d_test;
    testdescriptorsPerImage(i) = size(d_test, 2);
    
end
test_labels = testSet.Labels;
D_test = horzcat(testdescriptors{1:length(testSet.Files)});




testfeatures = zeros(length(testSet.Labels), k);
descCounter = 0;
for j = 1:length(testSet.Labels)
    
    descriptor = horzcat(testdescriptors{j});
    
    for i = 1:testdescriptorsPerImage(j)
        [~, cluster] = min(vl_alldist(single(descriptor(:,i)), centers)) ; 
        testfeatures(j, cluster) = testfeatures(j, cluster) + 1;
        
        
        
    end
    descCounter = descCounter + testdescriptorsPerImage(j);
end




predictedLabels = predict(classifier, testfeatures);


testLabels = testSet.Labels;
grouporder= cellstr([ '1_front  ' ; '2_front  ' ; '5_front  '  ; '10_front ' ;'20_front '; '50_front ';...
    '100_front' ;'200_front']);
[confMat, order] = confusionmat(testLabels, predictedLabels,'order',grouporder );

labels=grouporder;
confMat = bsxfun(@rdivide,confMat,sum(confMat,2));
heatmap(confMat, labels, labels, 1,'Colormap','red','ShowAllTicks',1,'UseLogColorMap',true,'Colorbar',true);