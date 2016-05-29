function [ centers, radii, scores ] = findcircles( image, parameters )
%FINDCIRCLES Summary of this function goes here
%   Detailed explanation goes here


results = [];

if ischar(image)
    image = imread(image);
end

centers = [];
radii = [];
scores = [];

%results for this image
for j=1:numel(parameters)
    p = parameters(j);
    I = p.preprocessor(image);
    [cs, rs, ss] = imfindcircles(I, parameters(j).radiusRange, ...
        'ObjectPolarity', p.objectPolarity, ...
        'Sensitivity', p.sensitivity);

    centers = [centers; cs]; %#ok<*AGROW>
    radii = [radii; rs];
    scores = [scores; ss];

end


end

