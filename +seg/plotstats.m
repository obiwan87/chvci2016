function plotstats( stats, overlaps, t )
%PLOTSTATS Summary of this function goes here
%   Detailed explanation goes here

precision = cell2mat(stats(:,:,5));
precision(isnan(precision)) = 0;
precision = mean(precision);

recall = cell2mat(stats(:,:,6));
recall(isnan(recall)) = 0;
recall = mean(recall);
%avg = (precision + recall)/2;

if nargin <= 2
    title('Find Coins ROC');
else 
    title(t);
end
hold on 
plot(recall, precision, '-*');
plot(recall, overlaps, '-*');
%plot(overlaps, avg);
hold off
legend('ROC', 'Threshold','Location', 'northoutside','Orientation','horizontal');
xlabel('Recall');
ylabel('Precision / Threshold');


end

