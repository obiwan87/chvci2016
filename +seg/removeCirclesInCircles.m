function [ centers, radii ] = removeCirclesInCircles( centers, radii )
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
end

