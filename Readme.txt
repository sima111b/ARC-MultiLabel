
1- Download Maxflow algorithm from "https://www.mathworks.com/matlabcentral/fileexchange/21310-maxflow?requestedDomain=www.mathworks.com"
2- Follow the instruction to install Maxflow.
3- Download Groubi optimizer from "http://www.gurobi.com/downloads/gurobi-optimizer".
4- Follow the instruction to install Groubi optimizer.
5- Compute the word2vec features using the functions which is provided in "word2vec" folder.
6- The main function for training is: miniMaxMultiLabel.m
7- Test function is:miniMaxMultiLabel_test.m
8- theta_node and theta_pairwise are learning parameters, save them and call them in the test function.
9- bibtex1.mat is the sample dataset:
	- It has 3 matrices:
				1- groundTruth
				2- nodeFeatures
				3- word2vecFeatures
