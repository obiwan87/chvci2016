function [ centers, radii, c0, r0, c1, r1, c2, r2 ] = findcoins( image, classifier, parameters, circleMergeThreshold )
%FINDCOINS Summary of this function goes here
%   Detailed explanation goes here

if nargin < 5
    circleMergeThreshold = 1.5;
end
tic
disp('Find circles...')
[c0, r0, ~] = seg.findcircles(image, parameters);
toc

%Convert centers and radii to bounding boxes
boxes = seg.circlestoboxes(c0, r0); 

%Load image to memory
if ischar(image)
    image = imread(image);
end

tic
disp('Cropping found regions ...');
imagesize = classifier.ImageSize;
if size(image,3) > 1
    region_images = zeros(imagesize(1),imagesize(2),3,size(boxes,1));
else
    region_images = zeros(imagesize(1),imagesize(2),size(boxes,1));
end
%image
for j=1:size(boxes,1)
    if size(image,3) > 1
        %crop and resize for alexnet feature extraction
        region_images(:,:,:,j) = imresize(imcrop(image, boxes(j,:)), imagesize);
    else 
        region_images(:,:,j) = imresize(imcrop(image, boxes(j,:)), imagesize);
    end
end
toc

tic
disp('Predicting coin/no-coin...');
label = predict(classifier, region_images);
toc

label = cellfun(@(x) strcmp(x, 'coin'), cellstr(char(label)));

coinboxes = boxes(label==1,:);
[c1, r1] = seg.boxestocircles(coinboxes);

%from all coinboxes, find those overlapping more than overlap
%and linearly combine them according to their score
[c2, r2] = seg.boxestocircles(coinboxes);
[c2, r2] = seg.removeCirclesInCircles(c2, r2, circleMergeThreshold);

k = numel(r2);

if(k > 0)
    [idx,centers] = kmeans(c1, k, 'Replicates', 3);
    radii = zeros(size(centers,1),1);
    for i=1:k
        radii(i) = mean(r1(idx == i));
    end
else
    centers = [];
    radii = [];
end

end


