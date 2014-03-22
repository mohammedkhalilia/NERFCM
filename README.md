Non-Euclidean Relational Fuzzy _c_-Means
==========================================

Overview
------------------------------------------
Non-Euclidean Relational Fuzzy _c_-Means (NERFCM) algorithm was proposed by Hathaway and Bezdek (see [1]). RFCM expects the input _D_ to be an Euclidean dissimilarity matrix. However, it is not always guaranteed that _D_ is Euclidean, and if it is not Euclidean the duality relationalship between RFCM and FCM will be violated and cause RFCM to fail if the relational distances become negative. 

To overcome this problem, NERFCM will heal/repair _D_ on the fly.

Directories Included in the Toolbox
------------------------------------------
`Data/` - datasets used by the demo scripts

`Functions/` - the MATLAB functions used in iRFCM

`Results/` - the location where NERFCM toolbox stores the results

Setup
------------------------------------------
You can either download a zip file and extract it to your preferred location. Or clone this repository using git

`git clone https://github.com/mohammedkhalilia/NERFCM.git`

Then add the directory to your MATLAB path.

NERFCM Configurations
------------------------------------------

### Input

iRFCM allows the user to define their own configurations using MATLAB struct. Those configurations are explained in the `Functions/irfcm.m` function, but we will explain here as well. 
Example 4 breifly demonstrates how to define options for iRFCM. The iRFCM options are defined in a structure with the following fields/members:

`fuzzifier` - (default 2) controls the fuzzifiness of the partition. The default value is fuzzifier=2. To produce a hard partition set the fuzzifier to smaller value like 1.1.

`epsilon` - (default 0.0001) this is the tolernace for the convergence criteria. The default is epsilon=0.0001.

`maxIter` - (default 100) maximim number of iterations the algorithm is allowed to run. If convergence is not reached, then the algorithm is forced to terminate which it reaches maxIter.

`initType` - (default 2) iRFCM starts by initializing the relational cluster centers _V_. There are two ways that iRFCM can initialize _V_. If initType = 2 then _c_ rows are randomly selected from D to initialize the _c_ relational cluster centers. If initType = 1, then it is random initialization.

### Output
The output is also a structure with the following fields:

 `options`    - this field contains the options structure to iRFCM described above

 `V`         - _c_ x _d_ matrix containing relationa cluster centers _V_.

 `U`         - _c_ x _n_ fuzzy partition matrix.

 `terminationIter` - the iteration number at which iRFCM convereged 

 `blockerCount` - number of times the self-healing module was activated

Examples (Mutation Dataset)
-----------------------------------------

### Example: Clustering the Mutation Dataset

    %load the mutation dataset (for details on the Mutation dataset see ref. [2])
    %NOTE: the dissimilarities here are not squared
    load Data/animal_mutation.csv;
	D = animal_mutation;
    
    %% NERFCM configurations/options (those are the default values)
	options.fuzzifier        = 2;
	options.epsilon          = 0.0001;
	options.maxIter          = 100;
	options.initType         = 2;

	%set the number of clusters to 4
	c = 4;
	
	%% Run NERFCM on the squared dissimilarities
	out = inerfcm(D.^2,c,options);

References
------------------------------------------
1. R. J. Hathaway, J. W. Davenport, and J. C. Bezdek, “Relational duals of the c-means clustering algorithms,” Pattern Recognition, vol. 22, no. 2, pp. 205–212, Jan. 1989.

2. W. Fitch and E. Margoliash, “Construction of phylogenetic trees,” Science (80-. )., 1967.

