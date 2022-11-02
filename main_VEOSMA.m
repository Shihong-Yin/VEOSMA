clear;clc
close all
Algorithm_name = 'VEOSMA';
Alphabet = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T',...
    'U','V','W','X','Y','Z','AA','AB','AC','AD','AE','AF','AG','AH','AI','AJ','AK','AL','AM','AN',...
    'AO','AP','AQ','AR','AS','AT','AU','AV','AW','AX','AY','AZ','BA','BB','BC','BD','BE','BF','BG','BH',...
    'BI','BJ','BK','BL','BM','BN','BO','BP','BQ','BR','BS','BT','BU','BV','BW','BX','BY','BZ','CA','CB','CC','CD'};
Irecord = [1,13,25,47,69,91,99,111,133,145,157,169,181,193,210,227,244,261,278,300,...
    322,344,366,388,400,412,424,436,448,465,482,499,516,533,555,577,599,621,643,675,...
    707,739,771,803,820,837,854,871,888,900,912,924,936,948,960,972,984,996,1008,1030,...
    1052,1074,1096,1118,1140,1162,1184,1206,1228,1280,1332,1384,1436,1488,1540,1592,1644,1696,1748,1770,1792,1814];
lb = 0;  ub = 1;
Pop_size = 25; % Number of search agents
Max_iter = 100; % Maximum number of iterations
runs = 20; % Change the number of runs
for num = 1:82 % Inatances 1:82
    clear Positions
    I = Irecord(num);
    [~,Name] = xlsread('JSSPdataset.xlsx','Sheet1',['A',num2str(I)]);  I = I+1;
    Scale = xlsread('JSSPdataset.xlsx','Sheet1',['A',num2str(I),':B',num2str(I)]);  n = Scale(1);  m = Scale(2);  I = I+1;
    Data = xlsread('JSSPdataset.xlsx','Sheet1',['A',num2str(I),':',Alphabet{2*m},num2str(I+n-1)]);
    dim = n*m;
    fullCols = size(Data,2); 
    cols = 1:2:fullCols; 
    Data(:,cols) = Data(:,cols)+1; 
    tic
    for i = 1:runs
        [Destination_fitness,bestPositions,Convergence_curve] = VEOSMA(Pop_size,Max_iter,lb,ub,dim,Data);
        Fitness(i,:) = Destination_fitness;
        Positions(i,:) = bestPositions;
        Curve(i,:) = Convergence_curve;
    end
    Time = toc;
    [~, Ind] = sort(Fitness);
    bestPositions = Positions(Ind(1),:);
    Convergence_curve = sum(Curve,1)/runs;
    % Save the results
    status0 = xlswrite('Contrast JSSP.xlsx',Name,Algorithm_name,[Alphabet{num},'1']);
    status1 = xlswrite('Contrast JSSP.xlsx',Time,Algorithm_name,[Alphabet{num},'3']);
    status2 = xlswrite('Contrast JSSP.xlsx',Fitness,Algorithm_name,[Alphabet{num},'5']);
    status3 = xlswrite('Contrast JSSP.xlsx',Convergence_curve',Algorithm_name,[Alphabet{num},'30']);
    status4 = xlswrite('Contrast JSSP.xlsx',bestPositions',Algorithm_name,[Alphabet{num},'150']); % The length is changing
    s=1;
    while ~(status0 && status1 && status2 && status3 && status4) && (s<10)
        pause(30)
        status0 = xlswrite('Contrast JSSP.xlsx',Name,Algorithm_name,[Alphabet{num},'1']);
        status1 = xlswrite('Contrast JSSP.xlsx',Time,Algorithm_name,[Alphabet{num},'3']);
        status2 = xlswrite('Contrast JSSP.xlsx',Fitness,Algorithm_name,[Alphabet{num},'5']);
        status3 = xlswrite('Contrast JSSP.xlsx',Convergence_curve',Algorithm_name,[Alphabet{num},'30']);
        status4 = xlswrite('Contrast JSSP.xlsx',bestPositions',Algorithm_name,[Alphabet{num},'150']);
        s = s+1;  disp(['write = ',num2str(s)])
    end
    % Display the results
    disp([Algorithm_name,':case ',num2str(num)])
    disp(['Mean fitness: ',num2str(Convergence_curve(end))])
    disp(['Execution time: ',num2str(Time)])
end
% Draw the Gantt chart
optSch = createSchedule(Data,bestPositions);
drawGant(optSch);
% Developer: Shihong Yin