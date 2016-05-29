function [ image_annotations ] = generateStruct( boxes, filename )
%GENERATESTRUCT Generates a struct that can be passed to extractregions()
%
% boxes - an array where rows contain x, y, and width of the bounding
% square, as is return by th function circlestoboxes
%
% filename - the path to the image file

image_annotations = struct('annotations', {cell(1,size(boxes,1))}, ... 
    'class', 'image', 'filename', filename);


for i=1:size(boxes,1)
    image_annotations.annotations{i} = struct('x', boxes(i,1), ...
        'y', boxes(i,2), 'width', boxes(i,3), 'height', boxes(i,3), ...
        'type', 'rect');
end


end
