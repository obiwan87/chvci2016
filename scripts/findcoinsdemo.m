% % %% Load Data
% % % You can comment out this entire section  after the first execution
% % 
% %path = 'C:\Users\Lenovo\Desktop\data2\labels-fb-total.json'; % change path
% %imds = imageDatastore(path, 'LabelSource', 'foldernames', 'includeSubfolders', false);
% % 
% % % Loads the variable convnet
% %convnet = helperImportMatConvNet('C:\Users\Lenovo\Documents\MATLAB\alexnet.mat');
% load('C:\Users\Lenovo\Documents\MATLAB\classifiers-compact.mat', 'convnet'); % change path
% %allcoinsclassifier = 'C:\Users\Lenovo\Desktop\data2\allcoinsclassifier.mat';
% % 
% % % just sent you this on slack
% % % it contains the variables coinDetector and colorClassifier
% % % |coinDetector| is used to segment the image
% % % |colorClassifier| returns a color response (copper, brass, 1-2-euro) 
% % % for each found region
% load('C:\Users\Lenovo\Documents\MATLAB\classifiers-compact.mat');
% load('C:\Users\Lenovo\Desktop\data2\allcoinsclassifier.mat'); 

% 
% % Sets AlexNet in coinDetector
%coinDetector.Classifier.Convnet = convnet;
% 
%sloth = io.readsloth('M:\home\simon\uni\cvhci\data\unseen.json');
% %

root_dir = 'M:\home\simon\uni\cvhci\data\evaluation-full';
sloth = io.readsloth(fullfile(root_dir, 'labels-2.json'));
results_dir = 'M:\home\simon\uni\cvhci\data\results_coin_detection\11';
mkdir(results_dir);

%% Reset 
DetectedLabels = [];
GroundTruthLabels = [];

%% Test for 10 random images
%for i=1:numel(imds.Files) 
for i=randperm(numel(sloth.annotations)) %i=1:numel(sloth.annotations)%
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

    
    %% Classify actual coin values with 2 different approaches
    predictedLabels = predict(allcoinsclassifier, I, bboxes);
    %predictedLabelsBySize = classifyBySize(bboxes, predictedLabels);
    
    detected_coinsvalue = sumCoinValue(predictedLabels) / 100;
    %detected_coinsvalue_bysize = sumCoinValue(predictedLabelsBySize) / 100;
    
    GroundTruthLabels = [GroundTruthLabels; categorical(trueLabels)];
    DetectedLabels =  [DetectedLabels; predictedLabels];
    for miss = 1:numel(missedCoins)
        DetectedLabels =  [DetectedLabels ; categorical(cellstr(missedCoins(miss).class))];
        GroundTruthLabels = [GroundTruthLabels; categorical(cellstr('FN'))];
    end  
    
    
    %Annotate images with coin types
    colors = eval.getAnnotationColors(predictedLabels, trueLabels);
    misses = numel(missedCoins);
    
    %Resize Image for display
    Iresized = io.scaleimage(I, 500, 'absolute');
    f = size(Iresized,1) / size(I,1);
    
    out = insertObjectAnnotation(Iresized, 'circle', [centers radii]*f, cellstr(char(predictedLabels)), 'Color', colors, 'FontSize',14, 'LineWidth',3);
    for m=1:numel(missedCoins)
        out = insertObjectAnnotation(out, 'rectangle', [missedCoins(m).x missedCoins(m).y missedCoins(m).width missedCoins(m).height]*f, missedCoins(m).class, 'Color', 'white');
    end
    
    if numel(missedCoins) > 0
        missedCoinsValue = sumCoinValue({missedCoins.class})/100;
    else 
        missedCoinsValue = 0;
    end
    
    out = insertText(out, [0 0], sprintf('GT: %.2f € / D: %.2f €', ground_truth_coinsvalue, detected_coinsvalue), 'FontSize', 14);
    out = insertText(out, [0 25], sprintf('%i coins missed: %.2f € ', misses, missedCoinsValue), 'FontSize', 14);
    
    
    h = figure;        
    imshow(out);
    %export_fig(h, fullfile(results_dir, sprintf('%d.png',i)), '-png', '-r100');
    euro =  floor(detected_coinsvalue);
    cent = (detected_coinsvalue - euro)*100;
    
    euro = num2str(euro);
    cent = num2str(cent);
    
    if(strcmp(euro, '1'))
        euro = 'Ein';
    end
    
    if(strcmp(cent, '1'))
        cent = 'Ein';
    end
    
    tts(sprintf('%s Euro und %s Cent!', euro, cent), 'Microsoft Hedda Desktop - German', -1, 16000);
    k = waitforbuttonpress;
    
    close(h);        
    
    
    %tts(sprintf('%.2f Euro', detected_coinsvalue), 'Microsoft Hedda Desktop - German', 3, 16000);    
end

grouporder= strtrim({ '1_front  ' ; '2_front  ' ; '5_front  '; ...
    '10_front ' ;'20_front '; '50_front '; '100_front' ;'200_front'; '1_back   ' ; '2_back   ' ; '5_back   '  ;'10_back  ' ;'20_back  '; '50_back  ';...
     '100_back ' ;'200_back '; 'FP       '; 'FN       '});
[confMat, order] = confusionmat(GroundTruthLabels, DetectedLabels, 'order', grouporder);
grouporder(17) = cellstr('FP(false)');
grouporder(18) = cellstr('FN(miss)');
labels = grouporder;
confMatP = bsxfun(@rdivide,confMat,sum(confMat,2));


