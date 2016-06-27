function [ centers, radii, c0, r0, c1, r1, c2, r2 ] = findcoins( image, classifier, parameters, overlap, circleMergeThreshold )
%FINDCOINS Summary of this function goes here
%   Detailed explanation goes here

if nargin < 5
    circleMergeThreshold = 1.5;
end
tic
disp('Find circles...')
[c0, r0, scores] = seg.findcircles(image, parameters);
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
%features = activations(convnet, region_images, 'fc7', 'MiniBatchSize', 32);
%label = char(predict(classifier, features));
label = predict(classifier, region_images);
toc

label = cellfun(@(x) strcmp(x, 'coin'), cellstr(char(label)));

coinboxes = boxes(label==1,:);
[c1, r1] = seg.boxestocircles(coinboxes);

%from all coinboxes, find those overlapping more than overlap
%and linearly combine them according to their score

A = Inf(size(coinboxes,1)); 
for j=1:(size(coinboxes,1))
    a = coinboxes(j,:);
    for k=1:size(coinboxes,1)
        b = coinboxes(k,:);
        o = seg.determineOverlap2(a(1), a(2), a(3), a(4), ...
          b(1), b(2), b(3), b(4));   
        A(k, j) = o;             
    end
end
[~, ii] = sort(sum(A),'descend');

mboxes = [];
for j=1:size(A,1)    
    v = A(:,ii(j));
    jj = find(v >= overlap);
    if ~isempty(jj)
        s = repmat(scores(jj) / sum(scores(jj)),1,4);
        mbox = sum(coinboxes(jj,:) .* s,1);
        mboxes = [mboxes; mbox];
    end
end

[c2, r2] = seg.boxestocircles(coinboxes);
[c2, r2] = seg.removeCirclesInCircles(c2, r2, circleMergeThreshold);

k = numel(r2);

if(k > 0)
    [idx,centers] = kmeans(c1, k);
    radii = zeros(size(centers,1),1);
    for i=1:k
        radii(i) = mean(r1(idx == i));
    end
else
    centers = [];
    radii = [];
end

end


