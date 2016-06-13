%% Data
path = '~/Desktop/coins/regions';
sloth = io.readsloth('~/Desktop/coins/401/labels.json');

display('Extracting regions');
tic
io.extractregions(sloth, path, 'FileStructure', 'ClassFolders', ...
    'ReadFcn' , @(x) imresize(x, [320 320]));
imds = imageDatastore(path, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
toc
%% Training

k = 500;
imageCount = length(imds.Files);
descriptors = {imageCount};
descriptorsPerImage = zeros(imageCount, 1);

% Get SIFT descriptors from all images
display('Obtain SIFT descriptors');
tic
for i = 1:imageCount
    I = single(rgb2gray(readimage(imds, i)));
    [f, d] = vl_sift(I);
    descriptors{i} = d;
    descriptorsPerImage(i) = size(d, 2);
end
D = horzcat(descriptors{1:imageCount});
toc

display('K-Means');
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
%classifier = fitcecoc(features, imds.Labels);