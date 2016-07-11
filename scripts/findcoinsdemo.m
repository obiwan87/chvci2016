% %% Load Data
% % You can comment out this entire section  after the first execution
% 
path = '~/Desktop/coins/data'; % change path
imds = imageDatastore(path, 'LabelSource', 'foldernames', 'includeSubfolders', true);
% 
% % Loads the variable convnet
%load('alex-net.mat', 'convnet'); % change path
% 
% % just sent you this on slack
% % it contains the variables coinDetector and colorClassifier
% % |coinDetector| is used to segment the image
% % |colorClassifier| returns a color response (copper, brass, 1-2-euro) 
% % for each found region
%load('classifiers-compact.mat'); 
% 
% % Sets AlexNet in coinDetector
% coinDetector.Classifier.Convnet = convnet;
% 
% %sloth = io.readsloth('~/Desktop/coins/data/labels-fb-total.json');
% %root_dir = 'M:\home\simon\uni\cvhci\data\all\';
%results_dir = 'M:\home\simon\uni\cvhci\data\results_coin_detection_unseen';
%mkdir(results_dir);

%% Test for 10 random images
%for i=1:numel(imds.Files) 
for i=1:numel(sloth.annotations)        
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
    predictedLabels = predict(colorClassifier, I, bboxes);        
    
    %Resize Image for display
    Iresized = io.scaleimage(I, 500, 'absolute');
    f = size(Iresized,1) / size(I,1);
    
    %Annotate picture coin colors
    out1 = insertObjectAnnotation(Iresized, 'circle', [centers radii]*f, cellstr(char(predictedLabels)),'FontSize',14, 'LineWidth',3);
    
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
        out2 = insertObjectAnnotation(Iresized, 'rectangle', [missedCoins(m).x missedCoins(m).y missedCoins(m).width missedCoins(m).height], missedCoins(m).class, 'Color', 'white');
    end
    
    out2 = insertText(out2, [0 0], sprintf('GT: %.2f € / D: %.2f €', ground_truth_coinsvalue, detected_coinsvalue), 'FontSize', 14);
    out2 = insertText(out2, [0 25], sprintf('%i coins missed€', misses), 'FontSize', 14);
    
    %out3 = insertObjectAnnotation(Iresized, 'circle', [centers radii]*f, cellstr(char(predictedLabelsBySize)), 'FontSize',14, 'LineWidth',3);    
    %out3 = insertText(out3, [0 0], sprintf('GT: %.2f € / D: %.2f €', ground_truth_coinsvalue, detected_coinsvalue_bysize), 'FontSize', 14);
    
    h = figure;        
    imshow(out2);
    export_fig(h, fullfile(results_dir, sprintf('%d.png',i)), '-png', '-r300');
    %close(h);
    
    %h = figure;        
    %imshow(out3);
    %export_fig(h, fullfile(results_dir, sprintf('%d-bysize.png',i)), '-png', '-r300');
    %close(h);
    
    h = figure;  
    imshow(out1);
    export_fig(h, fullfile(results_dir, sprintf('%d-color.png',i)), '-png', '-r300');
    close(h);
    
    
    %tts(sprintf('%.2f Euro', detected_coinsvalue), 'Microsoft Hedda Desktop - German', 3, 16000);    
end
