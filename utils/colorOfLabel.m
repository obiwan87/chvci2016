function [ color ] = colorOfLabel( label )
%COLOROFLABEL Summary of this function goes here
%   Detailed explanation goes here

[~,coin] = radiusOfLabel(label);

if coin == 1 || coin == 2 || coin == 5
    color = 'copper';
end 

if coin == 10 || coin == 20 || coin == 50
    color = 'brass';
end

if coin == 100
    color = '100';
end

if coin == 200
    color = '200';
end

end

