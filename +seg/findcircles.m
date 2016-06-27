function [ centers, radii, scores ] = findcircles( image, parameters )
%FINDCIRCLES Summary of this function goes here
%   Detailed explanation goes here

if ischar(image)
    image = imread(image);
end

% f = cell2mat({parameters.radiusRange});
% radiusRange = f(1):f(end);
% 
% im = rgb2gray(image);
% e = edge(im, 'canny');
% h = circle_hough(e, radiusRange, 'same', 'normalise');
% peaks = circle_houghpeaks(h, radiusRange, 'nhoodxy', 15, 'nhoodr', 21, 'npeaks', 10);
% centers = peaks(1:2,:)';
% radii = peaks(3,:)';
% scores = repmat(1/numel(radii), numel(radii),1);
% figure
% imshow(im)
% viscircles(peaks(1:2,:)', peaks(3,:)')

%results for this image
centers = [];
radii = [];
scores = [];
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

