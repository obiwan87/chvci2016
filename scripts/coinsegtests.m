function coinsegtests(I)

step = [10 15];
cs = cell(numel(step));
rs = cell(numel(step));

min_range = 10;
max_range = 80;
tic
for j=1:numel(step)
    radius_ranges = [min_range:step(j):max_range; (min_range+step(j)):step(j):(max_range+step(j))]';
    cs{j} = cell(size(radius_ranges,1),1);
    rs{j} = cell(size(radius_ranges,1),1);
    for i=1:size(radius_ranges,1)
        [cs{j}{i}, rs{j}{i}]= imfindcircles(I,[radius_ranges(i,1) radius_ranges(i, 2)],'ObjectPolarity', 'bright', 'Sensitivity', 0.95); 
    end
end
toc
imshow(I)

for j=1:numel(step)
    for i=1:size(radius_ranges,1)
        centers = cs{j}{i};
        radii = rs{j}{i};
        viscircles(centers,radii);
    end
end
clear centers radii

end