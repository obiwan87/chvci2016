function [ parameter_grid ] = parametergrid( radiusRanges, objectPolarity, sensitivity, preprocessor)
%PARAMETERGRID Generates a combination of all parameters passed.
% 
% 'preprocessor' is an optional parameter and is a function handle that can
% be used for preprocessing the image before passing it to the
% circle-detector. Its default value is '@(x) x', i.e. the identity
% function.
% 
% Usage Example:
% ------------------------------------------------------------------
% 
% seg.parametergrid({ [10 15], [15 20] }, {'dark', 'bright'}, ...
%                       num2cell(0.9:0.01:0.95))
% 
% Output: 24x1 struct array with fields
%
%     radiusRange     objectPolarity    sensitivity    preprocessor
%     [10 15]    	  'dark'      	    [0.9000]       @(x)x
%     [10 15]    	  'dark'      	    [0.9100]       @(x)x
%     [10 15]    	  'dark'      	    [0.9200]       @(x)x
%     [10 15]    	  'dark'      	    [0.9300]       @(x)x
%     [10 15]    	  'dark'      	    [0.9400]       @(x)x
%     [10 15]    	  'dark'      	    [0.9500]       @(x)x
%     [10 15]    	  'bright'    	    [0.9000]       @(x)x
%     [10 15]    	  'bright'    	    [0.9100]       @(x)x
%     [10 15]    	  'bright'    	    [0.9200]       @(x)x
%     [10 15]    	  'bright'    	    [0.9300]       @(x)x
%     [10 15]    	  'bright'    	    [0.9400]       @(x)x
%     [10 15]    	  'bright'    	    [0.9500]       @(x)x
%     [10 15]    	  'dark'      	    [0.9000]       @(x)x
%     [10 15]    	  'dark'      	    [0.9100]       @(x)x
%     [10 15]    	  'dark'      	    [0.9200]       @(x)x
%     [10 15]    	  'dark'      	    [0.9300]       @(x)x
%     [10 15]    	  'dark'      	    [0.9400]       @(x)x
%     [10 15]    	  'dark'      	    [0.9500]       @(x)x
%     [10 15]    	  'bright'    	    [0.9000]       @(x)x
%     [10 15]    	  'bright'    	    [0.9100]       @(x)x
%     [10 15]    	  'bright'    	    [0.9200]       @(x)x
%     [10 15]    	  'bright'    	    [0.9300]       @(x)x
%     [10 15]    	  'bright'    	    [0.9400]       @(x)x
%     [10 15]    	  'bright'    	    [0.9500]       @(x)x

if nargin < 4
    preprocessor = {@(x) x};
end

g = allcomb(radiusRanges, objectPolarity, sensitivity, preprocessor);
parameter_grid = repmat(struct('radiusRange', [0 0], 'objectPolarity', '', 'sensitivity', 0.0), size(g,1), 1);

for i=1:size(g,1)
    parameter_grid(i).radiusRange = g{i,1};
    parameter_grid(i).objectPolarity = g{i,2};
    parameter_grid(i).sensitivity = g{i,3};
    parameter_grid(i).preprocessor = g{i,4};
end

end

