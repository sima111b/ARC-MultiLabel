warning off;

clc;
clear;
restoredefaultpath;
addpath(genpath(pwd));
% profile -memory on;
% Please set the matrices in a way that the last dimention defines the
% number of entities in the matrix
load('dataset address');

%%Initialization **************************************************************************************
save_after=20;
n_training=size(groundTruth,2);
maxiteration=1000;
global n_node_features;
global n_nodes;
global n_word2vec_features;
global n_pairs;
n_nodes=size(word2vecFeatures,2); % number of classes
n_word2vec_features=size(word2vecFeatures,1); %word2vec features
n_node_features=size(nodeFeatures,1);
n_pairs=(n_nodes*(n_nodes-1))/2;
indVec=zeros(20000,3);
indCtr=1;
weight_size_node=n_node_features;
weight_size_pairwise=n_word2vec_features;

theta_node=randn(n_nodes,weight_size_node);
theta_node_all=zeros(n_nodes,maxiteration);

theta_pairwise=abs(randn(n_word2vec_features,1)); % 300 *1
thetea_pairwise_all=zeros(n_word2vec_features,maxiteration);

feature_pairwise=feature_pairwise_generator(ones(n_nodes,1),word2vecFeatures,1); %81*81*300
groundTruth_labels=groundTruth(:,1:n_training);

avg_game_value_maximizer = zeros(maxiteration,1);  % the avg of game values over training examples
avg_objective_value_maximizer=zeros(maxiteration,1);

avg_grads_magnitude_node = zeros(maxiteration,1); %
avg_grads_magnitude_pairwise = zeros(maxiteration,1); %

sum_game_value_maximizer_batch=0;
sum_objective_value_maximizer_batch=0;

sum_objective_value_maximizer_total=0; % the sum of objective function values over training examples
sum_game_value_maximizer_total=0;

sum_grad_batch_node = zeros (n_nodes,weight_size_node);  % % the sum of gradients over training examples in each batch
sum_grad_batch_pairwise = zeros (weight_size_pairwise,1);  % % the sum of gradients over training examples in each batch

avg_grad_batch_node = zeros (n_nodes,weight_size_node);
avg_grad_batch_pairwise = zeros (weight_size_pairwise,1);

% adagrad ********************************************
%https://xcorr.net/2014/01/23/adagrad-eliminating-learning-rates-in-stochastic-gradient-descent/
autocorr = 0.95;
fudge_factor=1e-6; %for numerical stability
master_stepsize = 1e-2;
historical_grad_node= zeros (n_nodes,weight_size_node);
historical_grad_pairwise= zeros (weight_size_pairwise,1);
%********************************************
batchSize=10;
n_batch=n_training/batchSize;

%% Training
for itr = 1:maxiteration
    
    order = randperm ( n_training);

    sum_objective_value_maximizer_total=0;
    sum_game_value_maximizer_total=0;
    
    for idx=1:batchSize:n_training
        sum_objective_value_maximizer_batch=0;
        sum_game_value_maximizer_batch=0;

        for bindex=idx:(idx+batchSize-1)
            ind=order(bindex);
            
            [sample_grad_node,sample_grad_pairwise,sum_game_value_maximizer,sum_objective_value_maximizer]=...
                game_step(nodeFeatures(:,ind),word2vecFeatures,feature_pairwise,groundTruth_labels(:,ind),theta_node,theta_pairwise);
            sum_grad_batch_node=sum_grad_batch_node+sample_grad_node; 
            sum_grad_batch_pairwise=sum_grad_batch_pairwise+(reshape(sum(sum(sample_grad_pairwise)),weight_size_pairwise,1))/n_pairs;
            sum_game_value_maximizer_batch=sum_game_value_maximizer_batch+sum_game_value_maximizer;
            sum_objective_value_maximizer_batch=sum_objective_value_maximizer_batch+sum_objective_value_maximizer; 
        end
      
        avg_grad_batch_node=sum_grad_batch_node./batchSize;
        sum_grad_batch_node= zeros (n_nodes,weight_size_node);
        
        avg_grad_batch_pairwise=sum_grad_batch_pairwise./batchSize;
        sum_grad_batch_pairwise= zeros (weight_size_pairwise,1);
        
        sum_game_value_maximizer_total=sum_game_value_maximizer_total+(sum_game_value_maximizer_batch./batchSize);
        sum_objective_value_maximizer_total=sum_objective_value_maximizer_total+(sum_objective_value_maximizer_batch./batchSize);
        %% adagrad
     
        historical_grad_node=historical_grad_node+(avg_grad_batch_node.^2);
        historical_grad_pairwise=historical_grad_pairwise+(avg_grad_batch_pairwise.^2);
        adjusted_grad_node=avg_grad_batch_node./(sqrt(historical_grad_node)+fudge_factor);
        adjusted_grad_pairwise=avg_grad_batch_pairwise./(sqrt(historical_grad_pairwise)+fudge_factor);
        
        %% gradient update
        theta_node=theta_node - master_stepsize * adjusted_grad_node;
        theta_pairwise=theta_pairwise - master_stepsize * adjusted_grad_pairwise;
        theta_pairwise=max(theta_pairwise,0);
        
    end
    thetea_pairwise_all(:,itr)=theta_pairwise;
    theta_node_all(:,itr)=sum(theta_node,2)/n_node_features;
    
    avg_game_value_maximizer(itr) = sum_game_value_maximizer_total/n_batch; %n_training; % average
    sum_game_value_maximizer_total=0;
    
    avg_objective_value_maximizer(itr)= sum_objective_value_maximizer_total/n_batch; %n_training;
        if (sum_objective_value_maximizer_total<0)
            itr
            ind
        end
    sum_objective_value_maximizer_total=0;
    
    avg_grads_magnitude_node(itr) = (1/(n_nodes*weight_size_node))*sum(sum(abs(adjusted_grad_node)));
    avg_grads_magnitude_pairwise(itr) = (1/weight_size_pairwise)*sum(abs(adjusted_grad_pairwise));
    
    %%
    
    if (itr == maxiteration)
        
        disp('exceeded maximum iteration');
        
        break_condition = 'exceeded maximum iteration';
        
    end
    
    if( mod (itr, save_after) == 0 ) % based on data size, itr takes variable times. so save on update count instead
        
        %*****************************************************************
        
        fig=figure('Visible','off','Position', [0 0 1024 800]);
        
        plot(avg_objective_value_maximizer(1:itr));
        
        figName='avgObjectiveplot.png';
        
        saveas(fig, figName);
        %*****************************************************************
        
        fig=figure('Visible','off','Position', [0 0 1024 800]);
        
        plot(avg_grads_magnitude_node(1:itr));
        
        figName='gradplot_node.png';
        
        saveas(fig, figName);
        
        %*****************************************************************
        
        fig=figure('Visible','off','Position', [0 0 1024 800]);
        
        plot(avg_grads_magnitude_pairwise(1:itr));
        
        figName='gradplot_pairwise.png';
        
        saveas(fig, figName);
        %*****************************************************************
        fig=figure('Visible','off','Position', [0 0 1024 800]);
        
        plot(theta_node_all(:,1:itr)');
        
        figName='thetaplot_node.png';
        
        saveas(fig, figName);
        %*****************************************************************
        fig=figure('Visible','off','Position', [0 0 1024 800]);
        
        plot(thetea_pairwise_all(:,1:itr)');
        
        figName='thetaplot_pairwise.png';
        
        saveas(fig, figName);
        %*****************************************************************
        
        fig=figure('Visible','off','Position', [0 0 1024 800]);
        
        plot( avg_game_value_maximizer(1:itr));
        
        figName='avg_game_values_gpu.png';
        
        saveas(fig, figName);
        %*****************************************************************
        
        save theta_node theta_node;
        save theta_pairwise theta_pairwise;
    end
end

%% logging

fig=figure('Visible','off','Position', [0 0 1024 800]);

plot(avg_grads_magnitude_node(1:itr));

saveas(fig,'finalgradplot_gpu.png');

save('lastrunallFeatures_gpu.mat');

fileID = fopen('output_gpu.txt','w');

fprintf(fileID, [break_condition '\n']);

