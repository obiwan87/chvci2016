function plotstats( stats, overlaps, t )
%PLOTSTATS Summary of this function goes here
%   Detailed explanation goes here

precision = mean(cell2mat(stats(:,:,5)));
recall = mean(cell2mat(stats(:,:,6)));

if nargin <= 2
    title('Find Coins ROC');
else 
    title(t);
end
hold on 
plot(recall, precision, '-*');
plot(recall, overlaps, '-*');
hold off
legend('ROC', 'Threshold','Location','northoutside','Orientation','horizontal');
xlabel('Recall')
ylabel('Precision / Threshold');
axis([0,1,0,1])


end

