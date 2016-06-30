classdef HoughCoinDetector < handle
    %COINSEGMENTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Parameters = seg.parametergrid({[15 30], [31 46], [47 55], [55 60]}, {'dark', 'bright'}, num2cell(0.97));
        CircleMergeThreshold = 1.5;
        Classifier = [];
        Preprocessor = @(x) io.scaleimage(x, 500, 'absolute');
    end

    methods
        function obj = HoughCoinDetector(classifier, parameters)
            if nargin > 1
                obj.Parameters = parameters;
            end
                        
            obj.Classifier = classifier;
        end
        
        function [centers, radii, bboxes] = findcoins(obj, image)      
            origsize = [size(image,1) size(image,2)];            
            image = obj.Preprocessor(image);
            scaledsize = [size(image,1) size(image,2)];
            
            f = origsize ./ scaledsize;
            
            [centers, radii] = seg.findcoins(image, obj.Classifier, ...
               obj.Parameters, obj.CircleMergeThreshold);
           
            %scale back regions
            radii = mean(f) * radii;            
            centers = centers .* repmat(f, size(centers,1),1);
            
            bboxes = seg.circlestoboxes(centers, radii);
        end   
    end
    
end

