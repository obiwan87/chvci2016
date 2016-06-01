function [ output_args ] = testThresholds( sloth, convnet, classifier, parameters, thresholds, varargin )
%TESTTHRESHOLDS Summary of this function goes here
%   Detailed explanation goes here

precisionArray = zeros(numel(thresholds));
recallArray = zeros(numel(thresholds));

for i = 1:numel(thresholds)
    [stats, detection_results, precision, recall] = twoStepSegmentation(sloth, convnet, classifier, parameters, threshold(i), varargin);
    precisionArray(i) = precision;
    recallArray(i) = recall;

end

plot(precisionArray, recallArray);
xlabel('Precision');
ylabel('Recall');