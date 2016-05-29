function [ overlap ] = determineOverlap2(  x1, y1, w1, h1, x2, y2, w2, h2 )
%DETERMINEOVERLAP2 Jaccardi distance
%
%   area(intersection(Rect1, Rect2)) / (area(Rect1) + area(Rect2) - area(intersection(Rect1, Rect2)))

intarea = rectint([x1 y1 w1 h1], [x2 y2 w2 h2]);
a = w1*h1 + w2*h2 - intarea;


overlap = intarea / a;

end

