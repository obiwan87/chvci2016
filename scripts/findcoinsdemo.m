% %% Load Data
% % You can comment out this entire section  after the first execution
% 
%path = 'C:\Users\Lenovo\Desktop\data2\labels-fb-total.json'; % change path
%imds = imageDatastore(path, 'LabelSource', 'foldernames', 'includeSubfolders', false);
% 
% % Loads the variable convnet
%convnet = helperImportMatConvNet('C:\Users\Lenovo\Documents\MATLAB\alexnet.mat');
load('C:\Users\Lenovo\Documents\MATLAB\classifiers-compact.mat', 'convnet'); % change path
%allcoinsclassifier = 'C:\Users\Lenovo\Desktop\data2\allcoinsclassifier.mat';
% 
% % just sent you this on slack
% % it contains the variables coinDetector and colorClassifier
% % |coinDetector| is used to segment the image
% % |colorClassifier| returns a color response (copper, brass, 1-2-euro) 
% % for each found region
load('C:\Users\Lenovo\Documents\MATLAB\classifiers-compact.mat');
load('C:\Users\Lenovo\Desktop\data2\allcoinsclassifier.mat'); 

% 
% % Sets AlexNet in coinDetector
%coinDetector.Classifier.Convnet = convnet;
% 
sloth = io.readsloth('C:\Users\Lenovo\Desktop\data2\labels-fb-total.json');
% %
root_dir = 'C:\Users\Lenovo\Desktop\data2';
results_dir = 'C:\Users\Lenovo\Desktop\data2\results';
%mkdir(results_dir);

DetectedLabels = [];
GroundTruthLabels = [];

%% Test for 10 random images
%for i=1:numel(imds.Files) 
for i=1:40%numel(sloth.annotations)        
    %% Preprocessing
    I = imread(fullfile(root_dir, sloth.annotations{i}.filename));
    %I = imds.readimage(i);
    
    %Read labeled data
    ground_truth_coinsvalue = NaN;
    trueLabels = NaN;
    if exist('sloth', 'var')
        annotations = [sloth.annotations{i}.annotations{:}];
        labels = {annotations.class};    
        ground_truth_coinsvalue = sumCoinValue(labels) / 100;
    end
        
    %% Segmentation
    [centers, radii, bboxes] = findcoins(coinDetector, I);
    if exist('sloth', 'var')
        [trueLabels, missedCoins] = eval.getLabelsForCoins(annotations, bboxes);
    end
    
    %% Classify found coins by their color features (brass, copper, 1-2-euro)
    disp('Classifying...');
    %predictedLabels = predict(colorClassifier, I, bboxes);        
    
    %Resize Image for display
    Iresized = io.scaleimage(I, 500, 'absolute');
    f = size(Iresized,1) / size(I,1);
    
    %Annotate picture coin colors
    %out1 = insertObjectAnnotation(Iresized, 'circle', [centers radii]*f, cellstr(char(predictedLabels)),'FontSize',14, 'LineWidth',3);
    
    %figure; imshow(imresize(out1, 0.2));  
    
    %% Classify actual coin values with 2 different approaches
    predictedLabels = predict(allcoinsclassifier, I, bboxes);
    %predictedLabelsBySize = classifyBySize(bboxes, predictedLabels);
    
    detected_coinsvalue = sumCoinValue(predictedLabels) / 100;
    %detected_coinsvalue_bysize = sumCoinValue(predictedLabelsBySize) / 100;
    
    %Annotate images with coin types
    
    
    colors = eval.getAnnotationColors(predictedLabels, trueLabels);
    misses = numel(missedCoins);
    out2 = insertObjectAnnotation(Iresized, 'circle', [centers radii]*f, cellstr(char(predictedLabels)), 'Color', colors, 'FontSize',14, 'LineWidth',3);
    for m=1:numel(missedCoins)
        out2 = insertObjectAnnotation(out2, 'rectangle', [missedCoins(m).x missedCoins(m).y missedCoins(m).width missedCoins(m).height]*f, missedCoins(m).class, 'Color', 'white');
    end
    
    out2 = insertText(out2, [0 0], sprintf('GT: %.2f € / D: %.2f €', ground_truth_coinsvalue, detected_coinsvalue), 'FontSize', 14);
    out2 = insertText(out2, [0 25], sprintf('%i coins missed€', misses), 'FontSize', 14);
    
    
    %out3 = insertObjectAnnotation(Iresized, 'circle', [centers radii]*f, cellstr(char(predictedLabelsBySize)), 'FontSize',14, 'LineWidth',3);    
    %out3 = insertText(out3, [0 0], sprintf('GT: %.2f € / D: %.2f €', ground_truth_coinsvalue, detected_coinsvalue_bysize), 'FontSize', 14);
    
    GroundTruthLabels = [GroundTruthLabels; categorical(trueLabels)];
    DetectedLabels =  [DetectedLabels; predictedLabels];
    for miss = 1:numel(missedCoins)
        DetectedLabels =  [DetectedLabels ; categorical(cellstr(missedCoins(miss).class))];
        GroundTruthLabels = [GroundTruthLabels; categorical(cellstr('FN'))];
    end   
    %h = figure;        
    %imshow(out2);
    %export_fig(h, fullfile(results_dir, sprintf('%d.png',i)), '-png', '-r300');
    %close(h);
    
    %h = figure;        
    %imshow(out3);
    %export_fig(h, fullfile(results_dir, sprintf('%d-bysize.png',i)), '-png', '-r300');
    %close(h);
    
    %h = figure;  
    %imshow(out1);
    
    %export_fig(h, fullfile(results_dir, sprintf('%d.png',i)), '-png', '-r300');
    %close(h);
    
    
    %tts(sprintf('%.2f Euro', detected_coinsvalue), 'Microsoft Hedda Desktop - German', 3, 16000);    
end

grouporder= cellstr([ '1_front  ' ; '2_front  ' ; '5_front  '  ;'1_back   ' ; '2_back   ' ; '5_back   '  ;...
    '10_front ' ;'20_front '; '50_front ';'10_back  ' ;'20_back  '; '50_back  ';...
    '100_front' ;'200_front'; '100_back ' ;'200_back '; 'FP       '; 'FN       ']);
[confMat, order] = confusionmat(GroundTruthLabels, DetectedLabels, 'order', grouporder);
grouporder(17) = cellstr('FP(false)');
grouporder(18) = cellstr('FN(miss)');
labels = grouporder;
confMat = bsxfun(@rdivide,confMat,sum(confMat,2));
heatmap(confMat, labels, labels, 1,'Colormap','red','ShowAllTicks',1,'UseLogColorMap',true,'Colorbar',true);
