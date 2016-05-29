function [ centers, radii ] = boxestocircles( boxes )
%BOXESTOCIRCLES Summary of this function goes here
%   Detailed explanation goes here

centers = zeros(size(boxes,1),2);
radii = zeros(size(boxes,1),1);
for i=1:size(boxes,1)
    centers(i,:) = boxes(i,1:2) + boxes(i,3:4)/2;
    radii(i) = boxes(i,3)/2;
end

end

