function [opts] = parseInputs(varargin) 
    input_data = inputParser;
    input_data.CaseSensitive = false;
    input_data.StructExpand = true;
    
    input_data.addOptional('mode', 'absolute', @(x) strcmpi(x, 'absolute') || strcmpi(x, 'relative'));
    
    parse(input_data, varargin{:});
    
    opts.mode = input_data.Results.mode;
end