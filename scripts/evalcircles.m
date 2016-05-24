function [ stats ] = evalcircles( sloth, requiredOverlap )
%EVALCIRCLES Applies segmentation and evaluates performance
%
%   Iterates over all annotated images listed in the given sloth file,
%   performs segmentation and compares results to labels by looking for the
%   closest overlapping bounding box. Use requiredOverlap parameter to set
%   the percentage of overlap neccessary to count as correctly found.
%   Statistics are output in the stats cell using the following format: 
%   stats = {Filename, #Assumed, #Coins(Reference), #Found, Precision,
%   Recall}

totalAssumed = 0;
totalCoins = 0;
totalFound = 0;
stats = cell(2,6);


for i = 1:2%numel(sloth.annotations)
    % open file, find circles, get boxes
    a = sloth.annotations{i};
    stats{i, 1} = a.filename;
    I = imread(fullfile(sloth.path, a.filename));
    [centers, radii] = getcircles(I);
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
        if maxOverlap > requiredOverlap
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

