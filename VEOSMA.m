% Equilibrium Optimizer and Slime Mould Algorithm with Centroid
% Opposition-based Computation and Variable Neighborhood Search
function [bestFitness,bestPositions,Convergence_curve] = VEOSMA(Pop_size,Max_iter,lb,ub,dim,data)
rand('seed',sum(100 * clock)); % Random number seed
V = 1;  a1 = 2;  a2 = 1;  GP = 0.5; % EO parameters
z = 0.6; % SMA parameter
Jr = 0.3; % Learning rate
% Initialize the population of slime mould
X = initialization(Pop_size,dim,ub,lb);
for i = 1:Pop_size
    Fitness(i,1) = fitness(data,X(i,:));
end
weight = ones(Pop_size,dim); % Fitness weight of each slime mould
% Centroid opposition-based computation
M = zeros(1,dim);
for i = 1:dim
    M(i) = M(i)+sum(X(:,i));
end
M = M/Pop_size; % Center of mass point
OX = 2*M-X; % Opposite position
for i = 1:Pop_size
    AllFitness_OX(i,1) = fitness(data,OX(i,:));
    if AllFitness_OX(i) < Fitness(i)
        X(i,:) = OX(i,:);  Fitness(i) = AllFitness_OX(i);
    end
end
C_old = X;  fit_old = Fitness;
Convergence_curve = zeros(1,Max_iter);
% Main loop
for it = 1:Max_iter
    % Fitness evaluation
    for i = 1:Pop_size
        Fitness(i,1) = fitness(data,X(i,:));
    end
    % Centroid opposition-based computation
    if rand < Jr
        M = zeros(1,dim);
        for i = 1:dim
            M(i) = M(i)+sum(X(:,i));
        end
        M = M/Pop_size; % Center of mass point
        OX = 2*M-X; % Opposite position
        for i = 1:Pop_size
            AllFitness_OX(i,1) = fitness(data,OX(i,:));
            if AllFitness_OX(i) < Fitness(i)
                X(i,:) = OX(i,:);  Fitness(i) = AllFitness_OX(i);
            end
        end
    end
    % Memory pooling mechanism to preserve the optimal position of individual history
    for i = 1:Pop_size
        if fit_old(i) < Fitness(i)
            Fitness(i) = fit_old(i);  X(i,:) = C_old(i,:);
        end
    end
    C_old = X;  fit_old = Fitness; % C_old is equivalent to a memory pool, the original SMA has no greedy selection
    % Update the equilibrium pool
    [Order,Index] = sort(Fitness);
    bestPositions = X(Index(1),:);  bestFitness = Order(1);
    Ceq2 = X(Index(2),:);  Ceq3 = X(Index(3),:);  Ceq4 = X(Index(4),:);
    Ceq_ave = (bestPositions+Ceq2+Ceq3+Ceq4)/4; % Average candidate solution
    C_pool = [bestPositions; Ceq2; Ceq3; Ceq4; Ceq_ave]; % Equilibrium pool
    worstFitness = Order(Pop_size);
    S = bestFitness-worstFitness+eps; % Plus eps to avoid denominator zero
    % Calculate the fitness weight of each slime mould
    for i = 1:Pop_size
        if i <= Pop_size/2
            weight(Index(i),:) = 1+rand(1,dim)*log10((bestFitness-Order(i))/S+1);
        else
            weight(Index(i),:) = 1-rand(1,dim)*log10((bestFitness-Order(i))/S+1);
        end
    end
    % Update EO parameters
    t = (1-it/Max_iter)^(a2*it/Max_iter);
    lambda = rand(Pop_size,dim);
    r1 = rand(Pop_size,1);
    r2 = rand(Pop_size,1);
    rn = randi(size(C_pool,1),Pop_size,1);
    % Update SMA parameters
    a = atanh(1-(it/Max_iter));
    vb = unifrnd(-a,a,Pop_size,dim);
    b = 1-it/Max_iter;
    vc = unifrnd(-b,b,Pop_size,dim);
    p = tanh(abs(Fitness-bestFitness));
    r = rand(Pop_size,dim);
    A = randi([1,Pop_size],Pop_size,dim); % Two positions randomly selected from population
    B = randi([1,Pop_size],Pop_size,dim);
    % Update the Position of search agents
    for i = 1:Pop_size
        if rand < z
            Ceq = C_pool(rn(i,1),:); % Select a solution randomly from the equilibrium pool
            F = a1*sign(r(i,:)-0.5).*(exp(-lambda(i,:).*t)-1); % Calculate the exponential term coefficient
            GCP = 0.5*r1(i,1)*ones(1,dim)*(r2(i,1)>=GP); % Calculate the mass generation rate
            G = (GCP.*(Ceq-lambda(i,:).*X(i,:))).*F;
            X(i,:) = Ceq+(X(i,:)-Ceq).*F+(G./lambda(i,:)*V).*(1-F); % Update position
        else
            for j = 1:dim
                if r(i,j) < p(i)
                    X(i,j) = bestPositions(j)+vb(i,j)*(weight(i,j)*X(A(i,j),j)-X(B(i,j),j));
                else
                    X(i,j) = X(i,j)+vc(i,j)*X(i,j);
                end
            end
        end
    end
    %% Variable neighborhood search
    for i = 1:Pop_size
        VNS_X(i,:) = VNS(X(i,:),data); % Self-learning by the VNS
        VNS_Fitness(i,1) = fitness(data,VNS_X(i,:));
        if VNS_Fitness(i) < Fitness(i) % Greedy selection
            X(i,:) = VNS_X(i,:);
            Fitness(i) = VNS_Fitness(i);
            if Fitness(i) < bestFitness
                bestPositions = X(i,:);
                bestFitness = Fitness(i);
            end
        end
    end
    Convergence_curve(it) = bestFitness;
end
end
% Developer: Shihong Yin