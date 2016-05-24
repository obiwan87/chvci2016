function [ boxes ] = circlestoboxes( centers, radii )
%CIRCLESTOBOXES Generates bounding box representation for the circles
%   Detailed explanation goes here
boxes = zeros(0,3);

for i=1:size(centers,1)
    x = centers(i, 1) - radii(i);
    y = centers(i, 2) - radii(i);
    width = 2 * radii(i);
    boxes = cat(1, boxes, [x, y, width]);
end



end

