classdef HogAllCoinsClassifier < handle
    %COLORCLASSIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Classifier = [];        
    end
    
    methods
        function obj=HogAllCoinsClassifier(classifier)
            obj.Classifier = classifier;
        end
        
        function predictedLabels = predict(obj, image, bboxes)            
            predictedLabels = repmat(obj.Classifier.ClassificationKNN.ClassNames(1), size(bboxes,1), 1);
            for i=1:size(bboxes,1)
                coin = imresize(imcrop(image, bboxes(i,:)), [80 80]);
                hogFeatures = extractHOGFeatures(coin, 'CellSize', [8 8]);
                predictedLabels(i) = obj.Classifier.predictFcn(table(hogFeatures));
            end
        end
    end
    
end

