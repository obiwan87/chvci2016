function [ centers, radii ] = findcoins( image, convnet, classifier, parameters, overlap )
%FINDCOINS Summary of this function goes here
%   Detailed explanation goes here

[centers, radii, scores] = seg.findcircles(image, parameters);

%Convert centers and radii to bounding boxes
boxes = seg.circlestoboxes(centers, radii); 

%Load image to memory
if ischar(image)
    image = imread(image);
end

%save bounding boxes classified as coins here
coinboxes = [];

region_images = zeros(227,227,3,size(boxes,1));
%image
for j=1:size(boxes,1)
    %crop and resize for alexnet feature extraction
    region_images(:,:,:,j) = imresize(imcrop(image, boxes(j,:)), [227 227]);
end

features = activations(convnet, region_images, 'fc7', 'MiniBatchSize', 32);
label = char(predict(classifier, features));
label = cellfun(@(x) strcmp(x, 'coin'), cellstr(char(label)));

coinboxes = boxes(label==1,:);

[centers, radii] = seg.boxestocircles(coinboxes);
% figure
% imshow(image);
% viscircles(centers, radii)

%from all coinboxes, find those overlapping more than overlap
%and linearly combine them according to their score

A = Inf(size(coinboxes,1)); 
%for j=1:(size(coinboxes,1)-1)
for j=1:(size(coinboxes,1))
    a = coinboxes(j,:);
    %for k=(j+1):size(coinboxes,1)
    for k=1:size(coinboxes,1)
        b = coinboxes(k,:);
        o = seg.determineOverlap2(a(1), a(2), a(3), a(4), ...
          b(1), b(2), b(3), b(4));   
        A(k, j) = o;     
        
    end
end
[~, ii] = sort(sum(A),'descend');
B = A;

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

[centers, radii] = seg.boxestocircles(mboxes);
[centers, radii] = seg.removeCirclesInCircles(centers, radii, 1.1);
%[centers, radii] = seg.removeCirclesInCircles(centers, radii);

% figure
% imshow(image);
% viscircles(centers, radii)

end


