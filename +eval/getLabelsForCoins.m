function [ trueLabels, missedCoins ] = getLabelsForCoins( annotations, bboxes )
%GETLABELSFORCOINS Compare segmentation results to labeled truth and assign
%labels to found coins
%   Detailed explanation goes here
disp('Retrieving true labels for suspected coins...');
overlaps = zeros(size(bboxes, 1), numel(annotations));
for i=1:size(bboxes, 1)
    for j=1:numel(annotations)
        overlaps(i,j) = seg.determineOverlap2(bboxes(i,1), bboxes(i,2), ...
            bboxes(i,3), bboxes(i,4), annotations(j).x, annotations(j).y, ...
            annotations(j).width, annotations(j).height);
    end
end

[maxes, indexes] = max(overlaps);
trueLabels = cell(size(bboxes, 1), 1);
missed = zeros(numel(annotations));
for j=1:numel(annotations)
    if maxes(j) > 0.5
        trueLabels{indexes(j)} = annotations(j).class;
    else
        missed(j) = 1;
    end
end
e = cellfun('isempty', trueLabels);
trueLabels(e) = {'FP'};

missedCoins = annotations(missed(:) == 1);

end

