%% Data
%sloth = io.readsloth('~/Desktop/coins/401/labels.json');
%data = io.extractregions(sloth, '~/Desktop/coins/regions', 'ReadFcn' , @(x) imresize(x, [320 320]));


%% Training

k = 400;
imageCount = numel(data(:,1));
descriptors = {imageCount};
descriptorsPerImage = zeros(imageCount, 1);
labels = {imageCount};

% Get SIFT descriptors from all images
tic
for i = 1:imageCount
    I = single(rgb2gray(imread(data{i})));
    [f, d] = vl_sift(I);
    descriptors{i} = d;
    descriptorsPerImage(i) = size(d, 2);
    labels{i} = data{i, 2};
end
D = horzcat(descriptors{1:imageCount});
toc

% Use k-means to cluster descriptors
tic
[c, a] = vl_kmeans(single(D), k, 'Initialization', 'plusplus');
toc

% Assign descriptors of each image to clusters to get feature vectors
features = zeros(imageCount, k);
descCounter = 0;
for j = 1:imageCount
    for i = 1:descriptorsPerImage(j)
        bin = a(descCounter + i);
        features(j, bin) = features(j, bin) + 1;
    end
    descCounter = descCounter + descriptorsPerImage(j);
end
% Optional - transform to binary features, might be better for SVM
features = sign(features);



% SVM
%classifier = fitcecoc(features, labels);