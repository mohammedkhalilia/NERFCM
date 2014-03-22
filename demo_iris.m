%clear MATLAB workspace
clear
close all

%load Iris dataset and compute the sup norm squared dissimilarity
X = load('Data/iris.csv');
D = squareform(pdist(X,'chebychev'));
n = size(D,1);

%compute the normalized dissimilarity image from D
f = figure('Visible','off');imagesc(D.^2);colormap('gray');colorbar;
print(f, '-djpeg', 'Results/Iris/Iris.jpg');
        
%% iRFCM configurations/options (those are the default values)
options.fuzzifier        = 2;
options.epsilon          = 0.0001;
options.maxIter          = 100;
options.initType         = 2;

%set the number of clusters to 3
c= 3;

%% Run NERFCM
out = inerfcm(D.^2,c,options);
    
%save the partition matrix for this delta
U = out.U;
dlmwrite(sprintf('Results/Iris/U(%d).csv',c),U, 'delimiter',',');

%save the induced dissimilarity image for this delta
%Ref. J. Huband and J. Bezdek, “VCV2– Visual cluster validity,” Comput. Intell. Res. Front., 2008.
uu = 1 - ((U'*U)./max(max(U'*U)));
f = figure('Visible','off');imagesc(uu);colormap('gray');caxis([0 1]);
print(f, '-djpeg', sprintf('Results/Iris/UU(%d).jpg',c));