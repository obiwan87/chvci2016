function [ overlap ] = determineOverlap( x1, y1, w1, h1, x2, y2, w2, h2 )
%DETERMINEOVERLAP determines the overlap in percent (of R1) between two rectangles

    A1 = w1 * h1;
    % Intersection
    i1 = min(x1 + w1, x2 + w2) - max(x1, x2);
    i2 = min(y1, y2) - max(y1 - h1, y2 - h2);
    
    if i1 <= 0 || i2 <= 0
        overlap = 0;
    else
        overlap = (i1 * i2) / A1;
    end
end

