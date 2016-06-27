classdef HogClassifier < CoinClassifier
    %HOGCLASSIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Classifier = [];   
        ImageSize = [];
        Convnet = [];
        AlexNetSvm = [];
    end
    
    methods(Access=public)
        function obj=HogClassifier(classifier, convnet, alexnetsvm, imagesize)
            obj.Classifier = classifier;
            obj.Convnet = convnet;
            obj.AlexNetSvm = alexnetsvm;
            obj.ImageSize = imagesize;
        end
        function predictedLabels = predict(obj, images)
            %hog
            features = zeros(size(images,4),size(obj.Classifier.X,2));
            for i=1:size(images,4)
                hog = extractHOGFeatures(images(:,:,:,i));
                features(i,:) = hog;
            end
            
            [predictedLabels, ~, pbscores] = predict(obj.Classifier, features);
            
            %Alex net
            coinscores = abs(pbscores(obj.Classifier.ClassNames(1) == predictedLabels));
            idx = find(obj.Classifier.ClassNames(1) == predictedLabels);           
            ii = idx(coinscores<1.5);
            alexnetimages = images(:,:,:,ii);
            if numel(alexnetimages) > 0 
                imgs = zeros(227,227,3,numel(ii));                
                for i=1:numel(ii)
                    imgs(:,:,:,i) = imresize(alexnetimages(:,:,:,i),[227 227]);
                end
                
                featureLayer = 'fc7';
                features = activations(obj.Convnet, imgs, featureLayer, ...
                    'MiniBatchSize', 32);
                p = predict(obj.AlexNetSvm, features);
                predictedLabels(ii) = p;
            end
        end
        
    end
    
end

