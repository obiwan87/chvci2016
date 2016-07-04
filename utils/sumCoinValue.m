function [ v ] = sumCoinValue( labels )
%SUMCOINVALUE Summary of this function goes here
%   Detailed explanation goes here

v = 0;
for i=1:numel(labels)
    label = char(labels(i));
    if regexp(label, '^1(_front|_back)?$')
        coin = 1;
    elseif regexp(label, '^2(_front|_back)?$')
        coin = 2;
    elseif regexp(label, '^5(_front|_back)?$')
        coin = 5;
    elseif regexp(label, '^10(_front|_back)?$')
        coin = 10;
    elseif regexp(label, '^20(_front|_back)?$')
        coin = 20;
    elseif regexp(label, '^50(_front|_back)?$')
        coin = 50;
    elseif regexp(label, '^100(_front|_back)?.*$')
        coin = 100;
    elseif regexp(label, '^200(_front|_back)?$')
        coin = 200;
    else
        coin = 100;
    end
    
    v = v + coin;
end
end

