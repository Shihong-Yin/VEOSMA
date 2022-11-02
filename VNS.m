function Xbest = VNS(Xb,data)
X = Xb;
[rows,cols] = size(data);
jobQty = rows;  machQty = cols/2;
Len = jobQty*machQty;
CostX = fitness(data,X);
step = 0;
while step <= Len
    i = randi(Len);  j = randi(Len);
    while i == j
        j = randi(Len);
    end
    XX = Exchanging(X,i,j);
    CostXX = fitness(data,XX);
    if CostXX < CostX
        X = XX;  CostX = CostXX;
    end
    step = step+1;
end
if fitness(data,X) < fitness(data,Xb)
    Xbest = X;
else
    Xbest = Xb;
end
end
% Developer: Shihong Yin