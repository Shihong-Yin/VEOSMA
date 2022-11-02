% 根据调度方案绘制甘特图程序
function drawGant(schedule)
rows = size(schedule,1);
maxMachId = max(schedule(:,2));
jobQty = max(schedule(:,1));
mycolor = 0.5.*rand(jobQty,3)+0.5;
figure
ylim([0 maxMachId+1])
for i = 1:rows
    x = schedule(i,4:5);
    y = [schedule(i,2) schedule(i,2)];
    line(x,y,'lineWidth',15,'color',mycolor(schedule(i,1),:))
    procId = schedule(i,3);
    jobId = schedule(i,1);
    txt = ['[' int2str(jobId) ',' int2str(procId) ']'];
    text(mean(x),y(1),txt,'HorizontalAlignment','center')
end
end
% Developer: Shihong Yin