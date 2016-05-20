function [imagelist] = extractregions ( sloth, regions_dir, varargin)
%EXTRACTREGIONS Extracts annotated regions.
%   Extracts annotated regions and stores them in regions_dir. Creates 
%   a file region-labels.txt that maps the region file to its corresponding
%   class. 
%
%   Parameters
%   ---------------------------------------------------------------------
%   sloth          Sloth labels (see readsloth())
%   regions_dir    Root directory of region files
%
%   Options
%   ---------------------------------------------------------------------
%   'FileStructure'    'ClassFolders'
%                       Puts each file in folder named after its class.
%                   
%                      'Mirror' (Default)
%                       Mirrors the folder structure of the original files.
%   
%   'ReadFcn'          Function handle for image preprocessing. You can use
%                      this to e.g. resize for Alex-Net. 
%   
%   'Labeled'          Boolean value that indicates if the dataset is 
%                      labeled (Default: True)
%  
%   Output
%   ---------------------------------------------------------------------
%   labels         Cell array that contains mapping from extracted image 
%                  region file to its class label
%
%  Usage Example:
%  ----------------------------------------------------------------------
%
%  %Reads images indicated in parsed sloth file and saves extracted regions
%  %to image files in 'regions/' subfolder. Resizes each region to 227x227 
%  %to use them in Alex-Net.%Places the regions in subfolders 
%  %<class>/<region-image>. 
%
%  labels = io.extractregions(sloth, 'regions/', ...
%                     'FileStructure', 'ClassFolders', ...
%                     'ReadFcn', @(x) imresize(x, [227 227]));
%

opts = parse_inputs(varargin{:});

root_dir_path = sloth.path;

if(~opts.Labeled)
    opts.FileStructure = 'Mirror';
end

readfcn = opts.ReadFcn;

if ~exist(regions_dir, 'dir') 
    mkdir(regions_dir)
end

imagelist = {};

k = 1;
for i=1:numel(sloth.annotations)
    a = sloth.annotations{i};
    image = imread(fullfile(root_dir_path, a.filename));
    [pathstr, name, ext] = fileparts(a.filename);
    
    if ~strcmp(opts.FileStructure, 'ClassFolders')
        if ~exist( fullfile(regions_dir, pathstr) , 'dir')
            mkdir(fullfile(regions_dir, pathstr));
        end
    end
    
    for j=1:numel(a.annotations)
        b = a.annotations{j};
        rect = [b.x b.y b.width b.height];
        
                
        region_image = imcrop(image, rect);
        region_filename = sprintf('%s-%03d%s', name, j, ext);
        
        region_filepath = fullfile(regions_dir);
        
        if opts.Labeled
            label_class = b.class; 
        end
        
        if strcmp(opts.FileStructure, 'ClassFolders')            
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
        
        imagelist{k,1} = region_filepath;
        if opts.Labeled
            imagelist{k,2} = label_class;
        end
        
        k = k + 1;
    end    
end

labelfile = fullfile(regions_dir, 'region-labels.txt');

if ~exist(labelfile, 'file')
    fileID = fopen(labelfile, 'w');
else 
    fileID = fopen(labelfile, 'a');
end

if opts.Labeled
    formatSpec = '%s %s\n';
else 
    formatSpec = '%s \n';
end

[nrows, ~] = size(imagelist);

for row = 1:nrows
    fprintf(fileID, formatSpec, imagelist{row,:});
end

fclose(fileID);

end

function [opts] = parse_inputs(varargin) 
    input_data = inputParser;
    input_data.CaseSensitive = false;
    input_data.StructExpand = true;
    
    input_data.addOptional('Labeled', true);
    input_data.addOptional('FileStructure', 'Mirror', @(x) strcmpi(x, 'Mirror') || strcmpi(x, 'ClassFolders'));
    input_data.addOptional('ReadFcn', @(x) x, @(x) isa(x, 'function_handle'));
    
    parse(input_data, varargin{:});
    
    opts.Labeled = input_data.Results.Labeled;
    opts.FileStructure = input_data.Results.FileStructure;
    opts.ReadFcn = input_data.Results.ReadFcn;
end