classdef HogClassifier < CoinClassifier
    %HOGCLASSIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Classifier = [];
        ImageSize = [];
        Convnet = [];
        AlexNetSvm = [];
        UseAlexNet = true;
        UseHog = false;
    end
    
    methods(Access=public)
        function obj=HogClassifier(classifier, convnet, alexnetsvm, imagesize, useAlexNet)
            obj.Classifier = classifier;
            obj.Convnet = convnet;
            obj.AlexNetSvm = alexnetsvm;
            obj.ImageSize = imagesize;
            obj.UseAlexNet = useAlexNet;
        end
        
        function predictedLabels = predict(obj, images)
            if obj.UseHog
                nocoinlabel = obj.Classifier.ClassNames(1);
                %hog
                hog = extractHOGFeatures(images(:,:,:,1));
                features = zeros(size(images,4), size(hog,2));
                for i=1:size(images,4)
                    hog = extractHOGFeatures(images(:,:,:,i));
                    features(i,:) = hog;
                end
                
                [predictedLabels, ~, pbscores] = predict(obj.Classifier, features);
            end
            
            if obj.UseAlexNet
                %Alex net                
                if exist('pbscores', 'var')
                    coinscores = abs(pbscores(obj.Classifier.ClassNames(1) == predictedLabels));                    
                    idx = find(nocoinlabel == predictedLabels);
                    ii = idx(coinscores<1.5);
                else
                    ii = 1:size(images,4);
                end
                
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
    
end

