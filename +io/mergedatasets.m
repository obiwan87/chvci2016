function [ msloth ] = mergedatasets( root_dir_merged, varargin )
%MERGEDATASETS Summary of this function goes here
%   Detailed explanation goes here

msloth = struct('path', root_dir_merged);
msloth.annotations = {};
msloth.json = 'labels.json';

for i=1:numel(varargin)
    
    sloth = varargin{i};
    root = sloth.path;
    
    for j=1:numel(sloth.annotations)
        a = sloth.annotations{j};
        [pathstr, ~, ~] = fileparts(a.filename);
        dest = fullfile(root_dir_merged, pathstr); 
        if ~exist(dest, 'dir')
            mkdir(dest);
        end
        copyfile(fullfile(root, a.filename), dest);
    end    
    msloth.annotations = num2cell(vertcat(msloth.annotations{:}, sloth.annotations{:}))';
end

savejson('', msloth.annotations, fullfile(msloth.path, msloth.json));

end

