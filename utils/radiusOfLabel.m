function [ radius, coin ] = radiusOfLabel( label )
%RADIUSOFLABEL Summary of this function goes here
%   Detailed explanation goes here

label = char(label);
gradii = [16.25 18.75 21.25 19.75 22.25 24.25 23.25 25.75];

if regexp(label, '^1(_front|_back)?$')
    radius = gradii(1);
    coin = 1;
elseif regexp(label, '^2(_front|_back)?$')
    radius = gradii(2);
    coin = 2;
elseif regexp(label, '^5(_front|_back)?$')
    radius = gradii(3);
    coin = 5;
elseif regexp(label, '^10(_front|_back)?$')
    radius = gradii(4);
    coin = 10;
elseif regexp(label, '^20(_front|_back)?$')
    radius = gradii(5);
    coin = 20;
elseif regexp(label, '^50(_front|_back)?$')
    radius = gradii(6);
    coin = 50;
elseif regexp(label, '^100(_front|_back)?.*$')
    radius = gradii(7);
    coin = 100;
elseif regexp(label, '^200(_front|_back)?$')
    radius = gradii(8);
    coin = 200;
else
    disp(label);
end

end

