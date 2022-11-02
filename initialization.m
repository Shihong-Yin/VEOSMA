%% Initialize function
function [Cin,domain] = initialization(SearchAgents_no,dim,ub,lb)
Boundary_no = size(ub,2); % Numnber of boundaries
% If the boundaries of all variables are equal and user enter a signle
% Number for both ub and lb
if Boundary_no == 1
    Cin = rand(SearchAgents_no,dim).*(ub-lb)+lb;
    domain = ones(1,dim)*(ub-lb);
end
% If each variable has a different lb and ub
if Boundary_no > 1
    for i = 1:dim
        ub_i = ub(i);
        lb_i = lb(i);
        Cin(:,i) = rand(SearchAgents_no,1).*(ub_i-lb_i)+lb_i;
    end
    domain = ones(1,dim).*(ub-lb);
end