function [ features  ] = extractColorFeatures( I, colorspace)
%EXTRACTHISTOGRAMFEATURES Summary of this function goes here
%   Detailed explanation goes here

if isa(I,'matlab.io.datastore.ImageDatastore')
    features = zeros(numel(I.Files), 6);
    for i=1:numel(I.Files)
        if mod(i,100) == 0
            fprintf('Sample %d/%d\n', i, numel(I.Files));
        end
        features(i,:) = doExtract(I.readimage(i),colorspace);
    end
else
    features = doExtract(I, colorspace);
end

end

function [ features ] = doExtract(image, colorspace)
if strcmpi(colorspace,'lab')
    image = rgb2lab(image);
    
    a = image(:,:,2);
    a = a(:);
    b = image(:,:,3);
    b = b(:);
else
    image = rgb2hsv(image);
    
    a = image(:,:,1);
    a = a(:);
    b = image(:,:,2);
    b = b(:);
end

features = [mean(a) mean(b) std(a) std(b) skewness(a) skewness(b)];
end

