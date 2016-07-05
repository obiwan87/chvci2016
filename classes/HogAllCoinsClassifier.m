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
                img = imcrop(image, bboxes(i,:));
                
                imgresized = imresize(img, [80 80]);
                hogFeatures = extractHOGFeatures(imgresized, 'CellSize', [8 8]);
                
                colorFeatures = cls.extractColorFeatures(img, 'lab');
                features = [hogFeatures colorFeatures];
                
                predictedLabels(i) = obj.Classifier.predictFcn(table(features));
            end
        end
    end
    
end

