function [p_maximizer,game_value_maximizer,s_maximizer_binary]= DOMMulti(gt,theta_node,nodeFeature,lagrangianPotentials_node,theta_pairwise,word2vecFeatures,lagrangianPotentials_pairwise)

global n_nodes;
global n_pairs;
global n_node_features;
n_strategies=2^n_nodes-1;
global n_word2vec_features;
s_maximizer_index= 1;%randi(n_strategies-1,1,1)  %maximizer strategies- an index of possible_strategies
s_minimizer_index=2;%randi(n_strategies-1,1,1) %maximizer strategies- an index of possible_strategies
maxCondition=1;
minCondition=1;
global n_solutions;
p_maximizer=1;
lp_pairwise=cell(1,1000);
s_minimizer_binary=dec2bin(s_minimizer_index,n_nodes)-48;
s_maximizer_binary=dec2bin(s_maximizer_index,n_nodes)-48;
n_maximizer_st=1;
tempFeature=feature_pairwise_generator(double(s_maximizer_binary)',word2vecFeatures,0);
lagrangianPotentials_pairwise_maximizer=zeros(n_nodes,n_nodes);
for slice = 1 : n_nodes
    for sl=1:n_nodes
        lagrangianPotentials_pairwise_maximizer(slice,sl)=reshape(tempFeature(slice,sl,:),1,300)*theta_pairwise; %feature_pairwise bala mosalasii hast va
    end
end
lp_pairwise{n_maximizer_st}=(sum(sum(lagrangianPotentials_pairwise_maximizer)))/n_pairs; %


while (minCondition || maxCondition)
    game_matrix_loss=pdist2(s_minimizer_binary,s_maximizer_binary,'hamming');
    lagrangianPotentials_maximizer_nodes=double(s_maximizer_binary)*lagrangianPotentials_node';
    lagrangianPotentials_maximizer_total=lagrangianPotentials_maximizer_nodes'+[lp_pairwise{1:n_maximizer_st}];
    [p_minimizer,game_value_minimizer]=findMinimizerProbabilities(lagrangianPotentials_maximizer_total,game_matrix_loss,p_maximizer);
    [p_maximizer,game_value_maximizer]=findMaximizerProbabilities(lagrangianPotentials_maximizer_total,game_matrix_loss,p_minimizer);    
    [cut_binary,max_best_value]= findBestS_maximizer(s_minimizer_binary,lagrangianPotentials_node,lagrangianPotentials_pairwise,p_minimizer);
   
    if (checkExistence(s_maximizer_binary',cut_binary))
        maxCondition=0;
        
    else
        
        maxCondition=1;
        s_maximizer_binary=[s_maximizer_binary;cut_binary'];
        n_maximizer_st=n_maximizer_st+1;
        lagrangianPotentials_maximizer_nodes=double(s_maximizer_binary)*lagrangianPotentials_node';
        tempFeature=feature_pairwise_generator(double(cut_binary)',word2vecFeatures,0);
        
        for slice = 1 : n_nodes
            for sl=1:n_nodes
                lagrangianPotentials_pairwise_maximizer(slice,sl)=reshape(tempFeature(slice,sl,:),1,300)*theta_pairwise; 
            end
        end
        lp_pairwise{n_maximizer_st}=(sum(sum(lagrangianPotentials_pairwise_maximizer)))/n_pairs;
        
        lagrangianPotentials_maximizer_total=lagrangianPotentials_maximizer_nodes'+[lp_pairwise{1:n_maximizer_st}];
        
        
    end
    game_matrix_loss=pdist2(s_minimizer_binary,s_maximizer_binary,'hamming');
    
    [p_maximizer,game_value_maximizer]=findMaximizerProbabilities(lagrangianPotentials_maximizer_total,game_matrix_loss,p_minimizer);
    if(isnan(game_value_maximizer))
        break;
    end
    s_minimizer= findBestS_minimizer(s_maximizer_binary,p_maximizer);
    
    if (checkExistence(s_minimizer_binary',s_minimizer))
        minCondition=0;
        
    else
        
        minCondition=1;
        s_minimizer_binary=[s_minimizer_binary;s_minimizer'];
        
    end
    
    game_matrix_loss=pdist2(s_minimizer_binary,s_maximizer_binary,'hamming');
    
    
    [p_minimizer,game_value_minimizer]=findMinimizerProbabilities(lagrangianPotentials_maximizer_total,game_matrix_loss,p_maximizer);
    
    [p_maximizer,game_value_maximizer]=findMaximizerProbabilities(lagrangianPotentials_maximizer_total,game_matrix_loss,p_minimizer);
    
end
