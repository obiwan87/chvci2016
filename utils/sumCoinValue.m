function [ v ] = sumCoinValue( labels )
%SUMCOINVALUE Summary of this function goes here
%   Detailed explanation goes here

v = 0;
for i=1:numel(labels)
    label = char(labels(i));
    
    coin = coinValue(label);
    v = v + coin;
end
end

