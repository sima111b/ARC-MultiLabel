function [p_maximizer,p_minimizer,game_value_maximizer,s_maximizer_nodes,s_minimizer_nodes]=...
    game_step(nodeFeatures,word2vecFeatures,feature_pairwise,groundTruth_label,theta_node,theta_pairwise)
global n_nodes;
global n_pairs;
global n_word2vec_features;
lagrangianPotentials_pairwise=zeros(n_nodes,n_nodes);
lagrangianPotentials_node=(theta_node*nodeFeatures)'/n_nodes;
    lagrangianPotentials_pairwise=lagrangianPotentials_pairwise./n_pairs;
    lagrangianPotentials_node_gt=lagrangianPotentials_node*groundTruth_label;
    groundTruth_features_pairwise=feature_pairwise_generator(groundTruth_label,word2vecFeatures,0);
    templagrangianPotentials_pairwise_gt=zeros(n_nodes,n_nodes);
    for slice = 1 :n_nodes
        for sl=1:n_nodes
            templagrangianPotentials_pairwise_gt(slice,sl)=(reshape(groundTruth_features_pairwise(slice,sl,:),1,n_word2vec_features)*theta_pairwise)'; 
        end
    end
    lagrangianPotentials_piarwise_gt=(sum(sum(templagrangianPotentials_pairwise_gt)))/n_pairs;
    [p_maximizer,game_value_maximizer,s_maximizer_labels]=...
        DOMMulti(groundTruth_label,theta_node,nodeFeatures,lagrangianPotentials_node,theta_pairwise,word2vecFeatures,lagrangianPotentials_pairwise);
    sum_objective_value_maximizer=sum_objective_value_maximizer+(lagrangianPotentials_node_gt)+(lagrangianPotentials_piarwise_gt)+game_value_maximizer(1);
    sum_game_value_maximizer=sum_game_value_maximizer+ game_value_maximizer(1);
    maximizer_size=size(s_maximizer_labels,1);
    maximizer_expectation_pairwise=zeros(n_nodes,n_nodes,300);
    
    for id=1:maximizer_size
        maximizer_expectation_pairwise=maximizer_expectation_pairwise+(p_maximizer(id)*feature_pairwise_generator(double(s_maximizer_labels(id,:)),word2vecFeatures,0));
    end
    sample_grad_node=((groundTruth_label)-(p_maximizer'*double(s_maximizer_labels))')*nodeFeatures';
    sample_grad_pairwise=(groundTruth_features_pairwise)-maximizer_expectation_pairwise;
    
    
end



