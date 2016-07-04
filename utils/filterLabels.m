function [ imds ] = filterLabels( imds, include )
%FILTERLABELS Summary of this function goes here
%   Detailed explanation goes here

[imds1, imds2] = splitEachLabel(imds, 0.5, 'Include', include);
imds.Files = [imds1.Files; imds2.Files];
imds.Labels = [imds1.Labels; imds2.Labels];

end

