function [ output, scale ] = scalesize(input, f, opts)

if strcmpi(opts.mode, 'absolute')
    d = input;
    [~, mi] = max(d);
    scale = f / d(mi);
    output(mi) = f;
    n = mod(mi*2,3);
    output(n) = scale * input(n);
    scale = [scale scale];
end

if strcmpi(opts.mode, 'relative') 
    output = input .* f;
    scale = f;
end

end

