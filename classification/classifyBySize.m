function [ classes ] = classifyBySize( boxes, metals )
%CLASSIFYBYSIZE Classifies coins using size ratios and type of metal
%   Detailed explanation goes here

if (length(metals) < 2)
    classes = 0;
    return
end

diameters = boxes(:, 3);

% Sizes of Euro coins
k = {1, 2, 5, 10, 20, 50, 100, 200};
v = {16.25, 18.75, 21.25, 19.75, 22.25, 24.25, 23.25, 25.75};
coinSizes = containers.Map(k,v);

% Get the possible classes for each box
possibleClasses = {length(metals)};

for i = 1:length(metals)
    if (strcmp(metals(i), 'Copper'))
        possibleClasses{i} = [1 2 5];
    elseif (strcmp(metals(i), 'Brass'))
        possibleClasses{i} = [10 20 50];
    else
        possibleClasses{i} = [100 200];
    end
end
    
% Write all possibilities into a matrix
allCombs = allcomb(possibleClasses{:});

% For each combination, compute the error to true values
distances = zeros(length(allCombs), 1);
for i = 1:length(allCombs)
    sse = 0;
    for j = 1:(length(metals) - 1)
        k = j + 1;
        while (k <= length(metals))
            trueRatio = coinSizes(allCombs(i,j)) / coinSizes(allCombs(i,k));
            obsRatio = diameters(j) / diameters(k);
            sse = sse + (obsRatio - trueRatio)^2;
            k = k + 1;
        end
    end
    distances(i) = sqrt(sse);
end

% Find combination with minimal error
[M,I] = min(distances);
classes = allCombs(I,:);

end

