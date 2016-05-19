function [ scaled_sloth ] = scalesloth( sloth, f, varargin )
%SCALESLOTH Scales the annotations according to width and height scale
%factor.
%   Scales a sloth annotations structure with respect to scalef. If scalef
%   is two dimensional the first element will be used as x-scaling factor
%   and the second as y-scaling factor. If it contains one element, both
%   axes will be scaled equally with respect to scalef.

opts = parseInputs(varargin{:});


scale = [0 0];
if strcmpi(opts.mode, 'relative')
    if numel(f) == 1
        scale = [f f];   
    else 
        scale = f;
    end
else 
    scale = f;
end
    

%Matlab creates deepcopy of structs (also 'sloth' is passed by struct-value)
scaled_sloth = sloth;
for i=1:numel(scaled_sloth.annotations) 
    for j=1:numel(scaled_sloth.annotations{i}.annotations)         
        
        d = [scaled_sloth.annotations{i}.annotations{j}.width, ...
                 scaled_sloth.annotations{i}.annotations{j}.height];
             
        p = [scaled_sloth.annotations{i}.annotations{j}.x, ...
                 scaled_sloth.annotations{i}.annotations{j}.y];
        
        [nd, s] = scalesize(d, scale, opts);
        np = p .* s;
        
        scaled_sloth.annotations{i}.annotations{j}.width = nd(1);
        scaled_sloth.annotations{i}.annotations{j}.x = np(1);
        
        scaled_sloth.annotations{i}.annotations{j}.height = nd(2);
        scaled_sloth.annotations{i}.annotations{j}.y = np(2);
    end
end

end
