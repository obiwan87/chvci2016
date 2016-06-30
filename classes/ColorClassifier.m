classdef ColorClassifier < handle
    %COLORCLASSIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Classifier = [];        
    end
    
    methods
        function obj=ColorClassifier(classifier)
            obj.Classifier = classifier;
        end
        
        function predictedLabels = predict(obj, image, bboxes)            
            predictedLabels = repmat(obj.Classifier.ClassificationKNN.ClassNames(1), size(bboxes,1), 1);
            for i=1:size(bboxes,1)
                coin = imcrop(image, bboxes(i,:));
                colorfeatures = cls.extractColorFeatures(coin, 'lab');
                predictedLabels(i) = obj.Classifier.predictFcn(table(colorfeatures));
            end
        end
    end
    
end

