function [ simage ] = scaleimage(image, f, mode)

input = size(image);

if strcmpi(mode, 'absolute')
    d = input;
    [~, mi] = max(d);
    scale = f / d(mi);
    output(mi) = f;
    n = mod(mi*2,3);
    output(n) = scale * input(n);
end

if strcmpi(mode, 'relative') 
    output = input .* f;
end

simage = imresize(image, output);

end

