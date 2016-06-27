classdef (Abstract) CoinClassifier < handle
    %COINCLASSIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Abstract, Access=public)
        predictedLabels = predict(data)
    end
    
end

