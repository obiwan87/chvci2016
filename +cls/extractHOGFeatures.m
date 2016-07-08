function [ features ] = extractHOGFeatures( data, rotations, varargin )
%EXTRACTHOGFEATURES Summary of this function goes here
%   Detailed explanation goes here

if isa(data, 'matlab.io.datastore.ImageDatastore')
    I = data.readimage(1);
    f = extractHOGFeatures(I, varargin{:});
    
    features = zeros(numel(data.Files)*numel(rotations), size(f,2));
    
    for i=1:numel(data.Files)
        if mod(i, 100) == 0
            fprintf('Sample %i/%i \n', i, numel(data.Files));
        end
        I = data.readimage(i);
        
        if numel(rotations) > 1
            for j=1:numel(rotations)
                I = imrotate(I, rotations(j), 'bilinear', 'crop');
                features(i+j-1, :) = extractHOGFeatures(I, varargin{:});
            end
        else 
            features(i, :) = extractHOGFeatures(I, varargin{:});
        end
    end
end

end

