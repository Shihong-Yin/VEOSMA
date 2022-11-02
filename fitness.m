% 将编码转换成具体调度方案，并获取调度方案的最大完工时间
function finishTime = fitness(data,X)
[rows,cols] = size(data);
jobQty = rows;  machQty = cols/2;
[~, Ind] = sort(X);
IntX = mod(Ind,jobQty)+1;
% IntX = ceil(Ind/machQty); % IntX表示编码序列
schedule = zeros(jobQty*machQty,5);
% 定义中间数组
jobCanStartTime = zeros(1,jobQty);
jobProcessId = ones(1,jobQty);
for i = 1:jobQty*machQty
    % 获取编码中当前作业号,i位置的数字
    nowJobId = IntX(i);
    nowProcId = jobProcessId(nowJobId);
    nowMachId = data(nowJobId,2*nowProcId-1);
    nowProcTime = data(nowJobId,2*nowProcId);
    machSch = schedule(schedule(:,3)==nowMachId,:);
    jobCanST = jobCanStartTime(nowJobId);
    if size(machSch,1) == 0 % 设备还没有安排作业
        startTime = jobCanStartTime(nowJobId);
        endTime = startTime+nowProcTime;
    else % 设备已经安排了作业
        machSch = sortrows(machSch,4); % 对当前机器上的每个作业按开始时间排序
        rows = size(machSch,1);
        % 处理第一行已排作业，检查是否能将当前作业排到该作业之前
        done = 0;
        if jobCanST < machSch(1,4)
            if machSch(1,4)-jobCanST >= nowProcTime
                startTime = jobCanST;
                endTime = startTime+nowProcTime;
                done = 1;
            end
        end
        if done == 0
            for j = 2:rows
                if jobCanST < machSch(j,4)
                    if machSch(j,4)-max(jobCanST,machSch(j-1,5)) >= nowProcTime
                        startTime = max(jobCanST,machSch(j-1,5));
                        endTime = startTime+nowProcTime;
                        done = 1;
                        break;
                    end
                end
            end
        end
        if done == 0 % 表示该作业不能排到该设备已有作业之前
            startTime = max(jobCanST,machSch(rows,5));
            endTime = startTime+nowProcTime;
        end
    end
    schedule(i,:) = [nowJobId,nowProcId,nowMachId,startTime,endTime];
    jobCanStartTime(nowJobId) = endTime;
    jobProcessId(nowJobId) = jobProcessId(nowJobId)+1;
end
finishTime = max(schedule(:,5));
end
% Developer: Shihong Yin