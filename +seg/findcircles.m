function [ results ] = findcircles( imagelist, parameters )
%FINDCIRCLES Summary of this function goes here
%   Detailed explanation goes here

if isstruct(imagelist)
    if isfield(imagelist, 'annotations')
        %probably sloth annotation struct
        imagelist = io.getimagelist(imagelist);
    end
end

results = [];

for i=1:numel(imagelist)
    image = imread(imagelist{i});
    
    %results for this image
    image_results = struct();
    image_results.image = imagelist{i};
    image_results.results = [];
    
    for j=1:numel(parameters)
        p = parameters(j);
        I = p.preprocessor(image);
        [centers, radii] = imfindcircles(I, parameters(j).radiusRange, ...
            'ObjectPolarity', p.objectPolarity, ...
            'Sensitivity', p.sensitivity);
        
        result = struct('parameters', p, 'centers', centers, 'radii', radii);
        image_results.results = [ image_results.results result]; 
        
    end
    %results of all images
    results = [results image_results];
end

end

