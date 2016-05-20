function [ imagelist ] = getimagelist( sloth )
%IMAGELIST Returns an image list of the corresponding sloth annotations
    
t = cell2mat(sloth.annotations(:));

imagelist = fullfile(sloth.path, {t.filename})';

end

