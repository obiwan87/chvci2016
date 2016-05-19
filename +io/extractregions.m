function [labels] = extractregions ( sloth, regions_dir, varargin)
%EXTRACTREGIONS Extracts annotated regions.
%   Extracts annotated regions and stores them in regions_dir. Creates 
%   a file region-labels.txt that maps the region file to its corresponding
%   class. 
%
%   Parameters
%   ---------------------------------------------------------------------
%   sloth          Sloth config (see readsloth())
%   regions_dir    Root directory of region files
%
%   Options
%   ---------------------------------------------------------------------
%   'labelmode'    'folder'
%                  Puts each file in folder named after its class.
%                   
%                  'file'
%                  Mirrors the folder structure of the original files.
%                  
%  
%



opts = parse_inputs(varargin{:});

root_dir_path = sloth.path;
readfcn = opts.readfcn;

if ~exist(regions_dir, 'dir') 
    mkdir(regions_dir)
end

labels = {};

k = 1;
for i=1:numel(sloth.annotations)
    a = sloth.annotations{i};
    image = imread(fullfile(root_dir_path, a.filename));
    [pathstr, name, ext] = fileparts(a.filename);
    
    if ~strcmp(opts.labelmode, 'folder')
        if ~exist( fullfile(regions_dir, pathstr) , 'dir')
            mkdir(fullfile(regions_dir, pathstr));
        end
    end
    
    for j=1:numel(a.annotations)
        label = a.annotations{j};
        rect = [label.x label.y label.width label.height];
        label_class = label.class;
                
        region_image = imcrop(image, rect);
        region_filename = sprintf('%s-%03d%s', name, j, ext);
        
        region_filepath = fullfile(regions_dir);

        if strcmp(opts.labelmode, 'folder')
            region_filepath = fullfile(region_filepath, label_class);
            if ~exist(region_filepath, 'dir') 
                mkdir(region_filepath)
            end
        end
        
        region_filepath = fullfile(region_filepath, region_filename);
        
        if ~exist(region_filename, 'file') 
            region_image = readfcn(region_image);
            imwrite(region_image, region_filepath);            
        end  
        
        labels{k,1} = region_filepath;
        labels{k,2} = label_class;
        
        k = k + 1;
    end    
end

labelfile = fullfile(regions_dir, 'region-labels.txt');

if ~exist(labelfile, 'file')
    fileID = fopen(labelfile, 'w');
else 
    fileID = fopen(labelfile, 'a');
end

formatSpec = '%s %s\n';

[nrows, ~] = size(labels);

for row = 1:nrows
    fprintf(fileID, formatSpec, labels{row,:});
end

fclose(fileID);

end

function [opts] = parse_inputs(varargin) 
    input_data = inputParser;
    input_data.CaseSensitive = false;
    input_data.StructExpand = true;
    
    input_data.addOptional('labelmode', 'file', @(x) strcmpi(x, 'file') || strcmpi(x, 'folder'));
    input_data.addOptional('readfcn', @(x) x, @(x) isa(x, 'function_handle'));
    
    parse(input_data, varargin{:});
    
    opts.labelmode = input_data.Results.labelmode;
    opts.readfcn = input_data.Results.readfcn;
end