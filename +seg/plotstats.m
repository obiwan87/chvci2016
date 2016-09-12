
%PLOTSTATS Summary of this function goes here
%   Detailed explanation goes here

precision = cell2mat(stats(:,:,5));
precision(isnan(precision)) = 1;
precision = mean(precision);

recall = cell2mat(stats(:,:,6));
recall = mean(recall, 'omitnan');
%avg = (precision + recall)/2;

%if nargin <= 2
    
%else 
%    title(t);
%end
h = figure;
h.Color = 'w';
hold on 
plot(recall, precision, '-', 'LineWidth', 2);
hold off

xlabel('Recall');
ylabel('Precision');
title('Segmentation: Precision / Recall');
export_fig(h, 'M:\home\simon\uni\cvhci\plots\precision-recall-seg.png', '-png', '-r300');

h = figure;
h.Color = 'w';
stem(overlaps*100, (2*recall .* precision) ./ (recall + precision), 'LineWidth', 2.5);
ax = gca;
ax.XAxis.TickLabelFormat = '%.1f %%';
ax.XLim = [30 100];
ylabel('F1 Score');
xlabel('Overlap Required for TP');
title('Segmentation: F1 Score');
export_fig(h, 'M:\home\simon\uni\cvhci\plots\f1-seg.png', '-png', '-r300');
