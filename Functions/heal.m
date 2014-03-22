function [D d beta] = heal(D, d, V, beta, negIdx)

    [c n] = size(d);
    
    %get the index to the cluster and the point that caused the
    %negative distance
    [clusters, points]=ind2sub([c n],negIdx);
    uniqueClusters = unique(clusters);
    tmp = zeros(c,n);
            
    for i = uniqueClusters
    	k = points(clusters == i);
        tmp(i,k) = V(i,:)*V(i,:)' - 2*V(i,k) + 1;
	end
            
    deltaBeta = max(max((-2.*d(negIdx))./tmp(negIdx)));
    d(negIdx) = d(negIdx) + (deltaBeta/2).*tmp(negIdx);
    D = D + deltaBeta * (ones(n)-eye(n));
    beta = beta + deltaBeta;
end

