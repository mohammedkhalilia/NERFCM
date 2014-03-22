function V = init_centers(type, n, c, D)
%%
%
% Intialize relational cluster centers using two different technqiues.
%
% Usage V = init_centers(type, n, c, D)
%
% type  - 1 = random initialization
%         2 = radomly choose c rows from D for initialization
% n     - number of objects
% c     - number of clusters
% D     - nxn dissimilarity data, ONLY needed if you choose type = 2

    switch type
        case 1
            V = rand(c,n);
            V = V./(sum(V,2) * ones(1,n));
            
        case 2
            idx = randperm(n,c);
            V = D(idx,:);
            V = V./(sum(V,2) * ones(1,n));
    end
end