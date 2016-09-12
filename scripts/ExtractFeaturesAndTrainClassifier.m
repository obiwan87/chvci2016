%Load Sloth: IMPORTANT! Make sure you are using _front / _back labels !!!!

root_dir = 'M:\home\simon\uni\cvhci\data\';
sloth = io.readsloth(fullfile(root_dir, 'labels-fb-total.json'));

regions_dir = 'M:\home\simon\uni\cvhci\data\all-regions-front-back';
sloth_regions = io.extractregions(sloth, regions_dir, 'FileStructure', 'ClassFolders');

imds = imageDatastore(regions_dir, 'LabelSource', 'foldernames', 'includeSubfolders', true);

%Set preprocessor for hog
imds.ReadFcn = @(x) imresize(imread(x), [80 80]);
hogFeatures = cls.extractHOGFeatures(imds, 0, 'CellSize', [8 8]);

%Restore preprocessor for color features (we want to use as many pixels as
%possible)
imds.ReadFcn = @readDatastoreImage;
colorFeatures = cls.extractColorFeatures(imds, 'lab');
features = [hogFeatures colorFeatures];
data = table(features, imds.Labels);

trainedClassifier = cls.trainAllCoinsClassifier(data);
allcoinsclassifier = HogAllCoinsClassifier(trainedClassifier);

%Have fun!
