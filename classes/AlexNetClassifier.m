classdef AlexNetClassifier
    %ALEXNETCLASSIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ImageSize = [227 227];
        Classifier = [];
        Convnet = [];
        BatchSize = 32;
    end
    
    methods
        function obj = AlexNetClassifier(classifier, convnet)
            obj.Classifier = classifier;
            obj.Convnet = convnet;
        end
        
        function predictedLabels = predict(obj, images)
            features = activations(obj.Convnet, images, 'fc7', 'MiniBatchSize', obj.BatchSize);
            predictedLabels = predict(classifier, features);
        end
    end
    
end

