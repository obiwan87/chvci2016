function [ stats ] = evalcircles( sloth, varargin )
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
%   'MinRadius'         Minimum radius to look for
%   'MaxRadius'         Maximum radius to look for
%   'Steps'             Array with step sizes to use for radius range
%   'ObjectPolarity'    Variable for imfindcircles (default: bright)
%   'Sensitivity'       Variable for imfindcircles (default: 0.95)
%   'RequiredOverlap'   Percentage of rectangle overlap required for 
%                       evaluation to count as correctly found


opts = parse_inputs(varargin{:});

totalAssumed = 0;
totalCoins = 0;
totalFound = 0;
stats = cell(2,6);


for i = 1:numel(sloth.annotations)
    % open file, find circles, get boxes
    a = sloth.annotations{i};
    stats{i, 1} = a.filename;
    I = imread(fullfile(sloth.path, a.filename));
    [centers, radii] = getcircles(I, 'MinRadius', opts.MinRadius, ...
        'MaxRadius', opts.MaxRadius, 'Steps', opts.Steps, ...
        'ObjectPolarity', opts.ObjectPolarity, 'Sensitivity', ...
        opts.Sensitivity);
    boxes = circlestoboxes(centers, radii);
    
    % keep track of which coins were found
    foundcoins = zeros(numel(a.annotations), 1);
    found = 0;
    
    % iterate over suspected matches
    for j = 1:size(boxes, 1);
        maxOverlap = 0;
        bestMatch = 0;
        % check all labels for match
        for k = 1:numel(a.annotations)
            label = a.annotations{k};
            % determine overlap to find best matching bounding box
            overlap = determineOverlap(label.x, label.y, label.width, ...
                label.height, boxes(j, 1), boxes(j, 2), boxes(j, 3), ...
                boxes(j, 3));
            if overlap > maxOverlap && foundcoins(k) == 0
                maxOverlap = overlap;
                bestMatch = k;
            end
        end
        if maxOverlap > opts.RequiredOverlap
            foundcoins(k) = 1;
            found = found + 1;
        end
    end
    
    % update detailed stats
    stats{i, 2} = size(boxes, 1);
    stats{i, 3} = numel(a.annotations);
    stats{i, 4} = found;
    stats{i, 5} = found / size(boxes, 1); % precision
    stats{i, 6} = found / numel(a.annotations); % recall
    
    
    % update global stats
    totalAssumed = totalAssumed + size(boxes, 1);
    totalCoins = totalCoins + numel(a.annotations);
    totalFound = totalFound + found;
    
    
end

    disp(strcat('Total precision: ', num2str(totalFound / totalAssumed)));
    disp(strcat('Total recall: ', num2str(totalFound / totalCoins)));

end


function [opts] = parse_inputs(varargin) 
    input_data = inputParser;
    input_data.CaseSensitive = false;
    input_data.StructExpand = true;
    
    input_data.addOptional('MinRadius', 10);
    input_data.addOptional('MaxRadius', 80);
    input_data.addOptional('Steps', [10 15]);
    input_data.addOptional('ObjectPolarity', 'bright');
    input_data.addOptional('Sensitivity', 0.95);
    input_data.addOptional('RequiredOverlap', 0.9);

    parse(input_data, varargin{:});
    
    opts.MinRadius = input_data.Results.MinRadius;
    opts.MaxRadius = input_data.Results.MaxRadius;
    opts.Steps = input_data.Results.Steps;
    opts.ObjectPolarity = input_data.Results.ObjectPolarity;
    opts.Sensitivity = input_data.Results.Sensitivity;
    opts.RequiredOverlap = input_data.Results.RequiredOverlap;

end
