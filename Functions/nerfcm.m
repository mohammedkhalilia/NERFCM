function output = nerfcm(R, c, options)
%% 
%   Non-Euclidean Relational Fuzzy c-Means (NERFCM) for clustering dissimilarity
%	data proposed in [1]. Since RFCM is the relational dual of Fuzzy c-Means (FCM), 
%	it expects the input relational matrix R to be Euclidean. Otherwise, RFCM can fail to
%   execute due encountering negative relational distances. NERFCM attempts
%   to solve this problem by self-healing the disimilarity matrix onthe fly.
%
% Usage: output = nerfcm(R,c,options)
%   options is a struct with the following default values:
%
%       fuzzifier        = 2;
%       epsilon          = 0.001;   
%       maxIter          = 100;     
%       initType         = 2;       
%
%   Explanation of those fields is provided below
%
% output    - structure containing:
%               U: fuzzy partition
%               V: cluster centers/coefficients
%               terminationIter: the number of iterations at termination
%               maxIter: maximum number iterations allowed
%
% R         - the relational (dissimilarity) data matrix of size n x n
% c         - number of clusters
% fuzzifier - fuzzifier, default 2
% epsilon   - convergence criteria, default 0.0001
% initType  - initialize relational cluster centers V
%               1 = random initialization
%               2 = randomly choose c rows from D
% maxIter   - the maximum number fo iterations, default 100
%
% Refs:
%   [1] R. J. Hathaway and J. C. Bezdek, “Nerf c-means: Non-Euclidean 
%       relational fuzzy clustering,” Pattern Recognition, vol. 27, no. 3, pp. 429–437, Mar. 1994.


    %% iRFCM default values
    m = 2; epsilon = 0.0001;maxIter = 100;
    
    %% Overwrite iRFCM options by the user defined options
    if nargin == 3 && isstruct(options)
        fields = fieldnames(options);
        for i=1:length(fields)
           switch fields{i}
               case 'fuzzifier', m = options.fuzzifier;
               case 'epsilon', epsilon = options.epsilon; 
               case 'initType', initType = options.initType; 
               case 'maxIter', maxIter = options.maxIter;
           end
        end
    end
    
    %% Initialize variables
    D = R;n=size(D,1);d = zeros(c,n);bcount = 0;
    numIter=0;stepSize=epsilon;beta=0.0001; U=Inf(c,n);
    
    %initialize relational cluster centers
    V = init_centers(initType, n, c, D);
    
    %% Begin the main loop:
    while  numIter < maxIter && stepSize >= epsilon
        U0 = U;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Compute the relational distances between "clusters" and points
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i=1:c
            d(i,:)=D*V(i,:)'-V(i,:)*D*V(i,:)'/2;
        end
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Check for failure, are any of the d < 0?
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        negIdx = find(d(:) < 0)';
        if ~isempty(negIdx)
           fprintf('t=%d: found %d negative relational distances.\n',numIter, length(negIdx));
           
           %tranform the distance matrices here
           [D d beta] = heal(D,d,V,beta,negIdx);
           bcount = bcount + 1;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Update the partition matrix U
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %First, compute U for only those k points where d > 0
        [~, k] = find(d > 0);
        
        d=d.^(1/(m-1));
        tmp = sum(1./d(:,k));
        U = zeros(c,n);
        U(:,k) = (1./d(:,k))./(ones(c,1)*tmp);
        
        %Second, for the points with d = 0
        %find the clusters and the points where d = 0
        [clusters, points] = find(d == 0);
        uniquePoints = unique(points)';
        
        for k = uniquePoints
            %some k might have a zero distance to more than one cluster
            idx = find(points == k);
            sub = sub2ind([c n],clusters(idx),points(idx));
            
            %The membership is 1/number of clusters to which k has d = 0
            U(sub) =  1/length(idx);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Update cluster prototypes V
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        V=U.^m;  
        V = V./(sum(V,2) * ones(1,n));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Update the step size
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		stepSize=max(max(abs(U-U0)));
        
        numIter = numIter + 1;
    end
    
    %prepare output structure
    output = struct('U',U,...
                    'V',V,...
                    'terminationIter',numIter,...
                    'blockerCount',bcount);
                
    if nargin == 3,output.options = options;end
end
