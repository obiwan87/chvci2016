function [ stats, detection_results, precision, recall ] = twoStepSegmentation( sloth, convnet, classifier, parameters, threshold, varargin)
%TWOSTEPSEGMENTATION Summary of this function goes here
%   Detailed explanation goes here
%EVALCIRCLES Applies segmentation and evaluates performance
%
%   Iterates over all annotated images listed in the given sloth file,
%   performs segmentation and compares results to labels by looking for the
%   closest overlapping bounding box. Use requiredOverlap parameter to set
%   the percentage of overlap neccessary to count as correctly found.
%   Statistics are output in the stats cell using the following format: 
%   stats = {Filename, #Assumed, #Coins(Reference), #Found, Precision,
%   Recall}
% Options:
%   'RequiredOverlap'   Percentage of rectangle overlap required for 
%                       evaluation to count as correctly found


opts = parse_inputs(varargin{:});

totalAssumed = 0;
totalCoins = 0;
totalFound = 0;
stats = cell(2,6);

%Save hits and non-hits
detection_results = struct();
detection_results.path = sloth.path;
detection_results.annotations = {cell(numel(sloth.annotations,1))};

for i = 1:numel(sloth.annotations)
    % open file, find circles, get boxes
    a = sloth.annotations{i};
    stats{i, 1} = a.filename;
    filename = fullfile(sloth.path, a.filename);
    image = imread(filename);
    
    %Find circles for this image, for different variation of parameters
    [centers, radii] = seg.findcoins(image, convnet, classifier, parameters, threshold);
       
    boxes = seg.circlestoboxes(centers, radii);
    
    % keep track of which coins were found
    foundcoins = zeros(numel(a.annotations), 1);
    found = 0;
    assumed = 0;
    
    %save results for this image here
    regions = seg.generateStruct(boxes, a.filename);
    matches = java.util.HashSet;
    % iterate over suspected matches
    for j = 1:size(boxes, 1);
        maxOverlap = 0;
        bestMatch = 0;
        % check all labels for match
        for k = 1:numel(a.annotations)
            label = a.annotations{k};
            % determine overlap to find best matching bounding box
            overlap = seg.determineOverlap2(label.x, label.y, label.width, ...
                label.height, boxes(j, 1), boxes(j, 2), boxes(j, 3), ...
                boxes(j, 3));
            if overlap > maxOverlap
                maxOverlap = overlap;
                bestMatch = k;
            end
        end
        regions.annotations{j}.class = 'no-coin';
        assumed = assumed + 1;
        if maxOverlap > opts.RequiredOverlap            
            regions.annotations{j}.class = 'coin';
            if ~matches.contains(bestMatch) && bestMatch > 0
                foundcoins(bestMatch) = 1;
                found = found + 1;
            end
            matches.add(bestMatch);
        end
    end
    
    % update detailed stats
    stats{i, 2} = assumed;
    stats{i, 3} = numel(a.annotations);
    stats{i, 4} = found;
    stats{i, 5} = found / assumed; % precision
    stats{i, 6} = found / numel(a.annotations); % recall
    
    
    % update global stats
    totalAssumed = totalAssumed + assumed;
    totalCoins = totalCoins + numel(a.annotations);
    totalFound = totalFound + found;
    
    detection_results.annotations{i} = regions;
end

    precision = totalFound / totalAssumed;
    recall = totalFound / totalCoins;

    disp(strcat('Total precision: ', num2str(precision)));
    disp(strcat('Total recall: ', num2str(recall)));

end


function [opts] = parse_inputs(varargin) 
    input_data = inputParser;
    input_data.CaseSensitive = false;
    input_data.StructExpand = true;
    
    input_data.addOptional('RequiredOverlap', 0.9);
    input_data.addOptional('CircleMergeTolerance', 1.1);
    parse(input_data, varargin{:});    
    
    opts.RequiredOverlap = input_data.Results.RequiredOverlap;
    opts.CircleMergeTolerance = input_data.Results.CircleMergeTolerance;

end

