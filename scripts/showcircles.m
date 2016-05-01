for i=1:size(radius_ranges,1)
    centers = cs{i};
    radii = rs{i}
    h = [viscircles(centers,radii) h]
end

