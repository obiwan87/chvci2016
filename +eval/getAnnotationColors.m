function [ colors ] = getAnnotationColors( predictedLabels, trueLabels )
%GETANNOTATIONCOLORS Generate colors to display coins in output
%   Detailed explanation goes here
colors = cell(numel(trueLabels), 1);
for i=1:numel(trueLabels)
    if predictedLabels(i) == char(trueLabels(i))
        colors(i) = {'green'};
    elseif strcmp(trueLabels(i), 'FP')
        colors(i) = {'magenta'};
    else
        colors(i) = {'red'};
    end
end

end

