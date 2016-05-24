function [ centers, radii ] = getcircles( I , varargin)
%GETCIRCLES Detects circles in an image and returns their centers and radii
%   Circles within other circles are excluded
% Options:
%   'MinRadius'         Minimum radius to look for
%   'MaxRadius'         Maximum radius to look for
%   'Steps'             Array with step sizes to use for radius range
%   'ObjectPolarity'    Variable for imfindcircles (default: bright)
%   'Sensitivity'       Variable for imfindcircles (default: 0.95)


opts = parse_inputs(varargin{:});

centers = zeros(0, 2);
radii = zeros(0, 1);

%find circles for different parameters
for j=1:numel(opts.Steps)
    radius_ranges = [opts.MinRadius:opts.Steps(j):opts.MaxRadius; ...
        (opts.MinRadius+opts.Steps(j)):opts.Steps(j):(opts.MaxRadius+opts.Steps(j))]';

    for i=1:size(radius_ranges,1)
        [c, r]= imfindcircles(I,[radius_ranges(i,1) radius_ranges(i, 2)], ...
            'ObjectPolarity', opts.ObjectPolarity, 'Sensitivity', opts.Sensitivity);
        centers = cat(1, centers, c);
        radii = cat(1, radii, r);
    end
    
end


% sort circles by radius
circles = cat(2, centers, radii);
sc = sortrows(circles, 3);


% remove circles within circles
i = 1;
j = 2;
removed = 0;
while i < size(sc, 1) && j <= size(sc, 1)
    while j <= size(sc, 1)
        % if circle at i is inside circle at j, set radius to 0 
        distance = sqrt((sc(i, 1) - sc(j, 1))^2 + (sc(i, 2) - sc(j, 2))^2);
        % add 10% tolerance to catch circles "almost" inside each other
        if  distance + sc(i, 3) < 1.1 * sc(j, 3)
            sc(i, 3) = 0;
            i = i + 1;
            j = i + 1;
            removed = removed + 1;
        else 
            j = j + 1;
        end
    end
    i = i + 1;
    j = i + 1;
end

sc = sortrows(sc, 3);
scFinal = sc(removed+1:size(sc, 1), 1:3);


centers = scFinal(:, 1:2);
radii = scFinal(:, 3);

% imshow(I);
% viscircles(centers,radii);

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
    
    parse(input_data, varargin{:});
    
    opts.MinRadius = input_data.Results.MinRadius;
    opts.MaxRadius = input_data.Results.MaxRadius;
    opts.Steps = input_data.Results.Steps;
    opts.ObjectPolarity = input_data.Results.ObjectPolarity;
    opts.Sensitivity = input_data.Results.Sensitivity;
end
