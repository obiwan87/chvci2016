function [ scaled_sloth ] = scaledataset( sloth, f, root_dir_scaled, varargin )
%SCALEDATASET Scales images and corresponding sloth annotations file.
%
%   The scaled images are placed in 'root_dir_scaled'. The folder structure
%   and filenames of the dataset will be mirrored. Files will not be 
%   overwritten, to avoid data loss. A version of the scaled annotations
%   file will be placed in 'root_dir_scaled'.
%
%   Usage Example:
%   
%   To scale all images indicated in labels.json to a max edge size of 500
%   pixels and place the in 'scaled/' use: 
%
%   io.scaledataset('labels.json', 500, 'scaled/', 'mode', 'absolute');
%
%
%   Parameters
%   --------------------------------------------------------------------
%   sloth               Annotations file path or structure returned by 
%                       io.readsloth().
%   f                   Scaling output size or factor (see 'mode').
%   root_dir_scaled     Path scaled images will be stored in.
%
%   Options
%   --------------------------------------------------------------------
%   'mode'              'absolute' 
%                       Resizes the images such that the larger
%                       edge is scaled to 'f'. Image ratio will be kept.
%
%                       'relative'              
%                       Resizes the image according to passed scale
%                       factor 'f'. If two-dimensional, 'f' will be applied
%                       separately to width and height. If 'f' is one-
%                       dimensional both width and height will be scaled 
%                       equally. 

if ~isstruct(sloth) 
    sloth = readsloth(sloth);
end

opts = parseInputs(varargin{:});


%Path for original image
root_dir_orig = sloth.path;


scaled_sloth = sloth;
scaled_sloth.path = root_dir_scaled;


if ~exist(root_dir_scaled, 'dir')
    mkdir(root_dir_scaled);
end
text = '';
tic
for i=1:numel(sloth.annotations)
    
    %Filename of the current image
    imagefilename = scaled_sloth.annotations{i}.filename;
    [pathstr, ~, ~] = fileparts(imagefilename);
    
    %make path for new scaled file
    s_image_path = fullfile(root_dir_scaled, pathstr);
    s_image_full = fullfile(root_dir_scaled, imagefilename);
    
    %create path for new scaled image
    if ~exist(s_image_path, 'dir')        
        mkdir(s_image_path);
    end
    
    %read original, unscaled image
    image_orig = imread( fullfile(root_dir_orig, imagefilename) );
    
    %get size of original image
    d = size(image_orig);
    
    %scale it according to opts (relative or absolute) and f (=factors or
    %outputsize)
    [nd, scale] = scalesize(d(1:2), f, opts);
    
    %skip if file already exists
    if ~exist(s_image_full, 'file') 
        %resize image according to calculate new dimensions
        image_resize = imresize(image_orig, nd);

        %save image to new path    
        imwrite(image_resize, s_image_full);    
    end
    
    for j=1:numel(scaled_sloth.annotations{i}.annotations)
        
        %read annotation shape dimensions
        d = [scaled_sloth.annotations{i}.annotations{j}.width, ...
                 scaled_sloth.annotations{i}.annotations{j}.height];
        
        %read annotation shape position
        p = [scaled_sloth.annotations{i}.annotations{j}.x, ...
         scaled_sloth.annotations{i}.annotations{j}.y];
     
        %scale them
        np = p .* scale;
        nd = d .* scale;
        
        %save them back in sloth strutcture
        scaled_sloth.annotations{i}.annotations{j}.width = nd(1);
        scaled_sloth.annotations{i}.annotations{j}.x = np(1);
        
        scaled_sloth.annotations{i}.annotations{j}.height = nd(2);
        scaled_sloth.annotations{i}.annotations{j}.y = np(2);
    end 
    fprintf(repmat('\b', 1, length(text)));
    text = sprintf('Image %i / %i \n', i, numel(sloth.annotations));
    fprintf(text);
end

savejson('', scaled_sloth.annotations, fullfile(root_dir_scaled, scaled_sloth.json));
fprintf('Elapsed time %.2f', toc);
end

