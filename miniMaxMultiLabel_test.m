function [ loss]= miniMaxMultiLabel_test(dataset_test, theta_node, theta_pairwise)

restoredefaultpath;
addpath(genpath(pwd));
load(dataset_test); % dataset_test includes groundTruth, nodeFeatures, word2vecFeatures matrices

%%Initialization **************************************************************************************
n_test=size(groundTruth,2);
global n_node_features;
global n_nodes;
global n_word2vec_features;
global n_pairs;
n_nodes=size(word2vecFeatures,2); % number of classes
n_word2vec_features=size(word2vecFeatures,1); %word2vec features
n_node_features=size(nodeFeatures,1);
n_pairs=(n_nodes*(n_nodes-1))/2;
weight_size_node=n_node_features;
weight_size_pairwise=n_word2vec_features;

feature_pairwise=feature_pairwise_generator(ones(n_nodes,1),word2vecFeatures,1); %81*81*300
groundTruth_labels=groundTruth(:,1:n_test);
loss=0;
    lagrangianPotentials_pairwise=zeros(n_nodes,n_nodes);
predictions=zeros(n_test,n_nodes);
 for slice = 1 : n_nodes
        for sl=1:n_nodes
            lagrangianPotentials_pairwise(slice,sl)=reshape(feature_pairwise(slice,sl,:),1,size(feature_pairwise,3))*theta_pairwise; 
        end  
    end
        lagrangianPotentials_pairwise=lagrangianPotentials_pairwise./n_pairs;

%% Test

    for idx=1:n_test
    
    lagrangianPotentials_node=(theta_nodes*nodeFeatures);
   [p_maximizer,game_value_maximizer,s_maximizer_labels]=...
        DOMMulti(groundTruth_label,theta_node,nodeFeatures,lagrangianPotentials_node,theta_pairwise,word2vecFeatures,lagrangianPotentials_pairwise);
        
    [k,maxIndex]=max(p_maximizer);
    predicted_labels=s_maximizer_labels(maxIndex,:);
   hammingLoss=pdist2(groundTruth,predicted_labels,'hamming');
   loss=loss+hammingLoss;
        end
loss=loss/n_test;
end
      
       

