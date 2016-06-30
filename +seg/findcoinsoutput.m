function [out1, out2, out3, out4, out5] = findcoinsoutput( filename, hogClassifier, parameters, mergeCirclesThreshold)
%FINDCOINSOUTPUT Summary of this function goes here
%   Detailed explanation goes here
if ischar(filename)
    frame = imread(filename);
else
    frame = filename;
end
[centers, radii, c0, r0, c1, r1, c2, r2] = seg.findcoins(frame, hogClassifier, parameters, mergeCirclesThreshold);
heatmapframe = zeros(size(frame,1),size(frame,2));
boxes = seg.circlestoboxes(c1,r1);
for i=1:numel(r1)
    % (x1, y1) (x2, y1), (x2, y2), (x1, y2), (x1, y1)
    x1 = boxes(i,1);
    x2 = boxes(i,1) + boxes(i,3);
    y1 = boxes(i,2);
    y2 = boxes(i,2) + boxes(i,4);
    
    x = round([x1 x2 x2 x1 x1]);
    y = round([y1 y1 y2 y2 y1]);
    m = double(poly2mask(x,y,size(frame,1), size(frame,2)));
    heatmapframe = heatmapframe + m;
end
heatmapframe = mat2gray(heatmapframe);

%first step
out1 = insertShape(frame, 'circle', [c0 r0], 'LineWidth', 3, 'color', 'red');
%heatmap
out2 = insertShape(heatmapframe, 'circle', [c1 repmat(3,size(c1,1),1)], 'LineWidth', 3, 'color', 'blue');
%before merging
out3 = insertShape(frame, 'circle', [c1 r1], 'LineWidth', 3, 'color', 'blue');
%cluster estimation
out4 = insertShape(frame, 'circle', [c2 r2], 'LineWidth', 3, 'color', 'yellow');
%final output
out5 = insertShape(frame, 'circle', [centers radii], 'LineWidth', 3, 'color', 'green');


end

