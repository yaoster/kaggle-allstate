clear
clc

% do not regularize bias coefs
% try different lambdas for node/edge features
% try all edges?
% .1, .01 best so far

lambdaSpace = [.1];
options.maxIter = 250;
merrors = zeros(length(lambdaSpace));
serrors = zeros(length(lambdaSpace));

%% load data and set constants, load features
features = csvread('../random_forest_votes.csv');
features = features(:, [1:2, 4, 6:8, 10:11, 13, 15:17, 19:21]);
targets = int32(csvread('../../data/train_targets.csv', 1, 1));
targets(:, [1, 2, 5, 6]) = targets(:, [1, 2, 5, 6]) + 1;
% test_features = features(70001:size(features, 1),:);
% test_targets = targets(70001:size(features, 1),:);
% test_targets(:, [1, 2, 5, 6]) = test_targets(:, [1, 2, 5, 6]) - 1;
% features = features(1:70000,:);
% targets = targets(1:70000,:);
[nInstances, nNodes] = size(targets);
nStates = [3, 2, 4, 3, 2, 4, 4];

[Xnode, Xedge, nodeMap, edgeMap, edgeStruct] = crf_parameters_l1(features, nStates);
% [Xnode_test, Xedge_test, nodeMap_test, edgeMap_test, edgeStruct_test] = crf_parameters_l1(test_features, nStates);
w = zeros(max([nodeMap(:); edgeMap(:)]),1);

for regi = 1:length(lambdaSpace)
    for regj = 1:length(lambdaSpace)
        regCoefNodes = lambdaSpace(regi);
        regCoefEdges = lambdaSpace(regj);
        lambda = regCoefNodes * ones(size(w));
        for n = 1:nNodes
            for s = 1:nStates(n)
                if nStates(n) == 2 && s == 2
                    continue
                end
                lambda(nodeMap(n, s, 1)) = 0;
            end
        end
        lambda((max(nodeMap(:)) + 1):length(lambda)) = regCoefEdges * lambda((max(nodeMap(:)) + 1):length(lambda));
        funObj = @(w)UGM_CRF_NLL(w,Xnode,Xedge,targets,nodeMap,edgeMap,edgeStruct,@UGM_Infer_Exact);
        w = L1General2_PSSgb(funObj,w,lambda,options);
        save('crf_l1_reg.mat', 'w')

        %% get in-sample error
%         [marginals, sequences] = crf_output_chain(w, Xnode, Xedge, nodeMap, edgeMap, edgeStruct);
%         targets(:, [1, 2, 5, 6]) = targets(:, [1, 2, 5, 6]) - 1;
%         marginalsCorrect = (marginals == targets);
%         sequencesCorrect = (sequences == targets);
%         merror = sum(sum(marginalsCorrect, 2) == 7)/nInstances;
%         serror = sum(sum(sequencesCorrect, 2) == 7)/nInstances;

        %% get test error
%         [marginals, sequences] = crf_output_chain(w, Xnode_test, Xedge_test, nodeMap_test, edgeMap_test, edgeStruct_test);
%         marginalsCorrect = (marginals == test_targets);
%         sequencesCorrect = (sequences == test_targets);
%         test_merror = sum(sum(marginalsCorrect, 2) == 7)/size(test_features,1);
%         test_serror = sum(sum(sequencesCorrect, 2) == 7)/size(test_features,1);
%         disp(test_merror)
%         disp(test_serror)
%         
%         merrors(regi, regj) = test_merror;
%         serrors(regi, regj) = test_serror;
    end
end