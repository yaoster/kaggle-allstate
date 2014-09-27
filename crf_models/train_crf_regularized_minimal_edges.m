% clear
% clc

% try minimal features
% try eliminating redundant state features
% try regularizing all coefs

lambdaspace = [0];
merrors = zeros(length(lambdaspace));
serrors = zeros(length(lambdaspace));

regCoefNodes = .00001;
regCoefEdges = .001;
maxIter = 5;

%% load data and set constants, load features
features = csvread('../random_forest_votes.csv');
features = features(:, [1:2, 4, 6:8, 10:11, 13, 15:17, 19:21]);
targets = int32(csvread('../../data/train_targets.csv', 1, 1));
targets(:, [1, 2, 5, 6]) = targets(:, [1, 2, 5, 6]) + 1;
test_features = features(70001:size(features, 1),:);
test_targets = targets(70001:size(features, 1),:);
features = features(1:70000,:);
targets = targets(1:70000,:);
[nInstances, nNodes] = size(targets);
nStates = [3, 2, 4, 3, 2, 4, 4];

[Xnode, Xedge, nodeMap, edgeMap, edgeStruct] = crf_parameters_minedges(features, nStates);
[Xnode_test, Xedge_test, nodeMap_test, edgeMap_test, edgeStruct_test] = crf_parameters_minedges(test_features, nStates);
test_targets(:, [1, 2, 5, 6]) = test_targets(:, [1, 2, 5, 6]) - 1;

for regi = 1:length(lambdaspace)
    for regj = 1:length(lambdaspace)
        disp([regi, regj])
        regCoefNodes = 1e-7;
        regCoefEdges = .01;

        %% SGD training
        nParams = max([nodeMap(:); edgeMap(:)]);
        w = zeros(nParams,1);
        % lambda = regCoef*ones(size(w));
        % for n = 1:nNodes
        %     for s = 1:nStates(n)
        %         if nStates(n) == 2 && s == 2
        %             continue
        %         end
        %         lambda(nodeMap(n, s, 1)) = 0;
        %     end
        % end
        % lambda((max(nodeMap(:)) + 1):length(lambda)) = 0;
        lambda = ones(size(w));
        lambda(1:max(nodeMap(:))) = regCoefNodes*lambda(1:max(nodeMap(:)));
        lambda((max(nodeMap(:)) + 1):length(lambda)) = regCoefEdges*lambda((max(nodeMap(:)) + 1):length(lambda));

        %stepSize = logspace(0, -8, maxIter*nInstances);
        stepSize = linspace(1, 1e-8, maxIter*nInstances);
        ll = zeros(maxIter*nInstances, 1);
        for iter = 1:maxIter*nInstances
            i = ceil(rand*nInstances);
            funObj = @(w)penalizedL2(w,@UGM_CRF_NLL,lambda,Xnode(i,:,:),Xedge(i,:,:),targets(i,:),nodeMap,edgeMap,edgeStruct,@UGM_Infer_Exact);
            [f,g] = funObj(w);
            ll(iter) = f;

            if mod(i, 50000) == 0
                fprintf('Iter = %d of %d (fsub = %f)\n',iter,maxIter*nInstances,f);
            end

            w = w - stepSize(iter)*g;
        end
        %save('crf_edge_features_regularized_minimal_edges.mat', 'w')

        %% get in-sample error
%         targets(:, [1, 2, 5, 6]) = targets(:, [1, 2, 5, 6]) - 1;
%         [marginals, sequences] = crf_output_chain(w, Xnode, Xedge, nodeMap, edgeMap, edgeStruct);
%         marginalsCorrect = (marginals == targets);
%         sequencesCorrect = (sequences == targets);
%         merror = sum(sum(marginalsCorrect, 2) == 7)/nInstances;
%         serror = sum(sum(sequencesCorrect, 2) == 7)/nInstances;

        %% get test error
        [marginals, sequences] = crf_output_chain(w, Xnode_test, Xedge_test, nodeMap_test, edgeMap_test, edgeStruct_test);
        marginalsCorrect = (marginals == test_targets);
        sequencesCorrect = (sequences == test_targets);
        test_merror = sum(sum(marginalsCorrect, 2) == 7)/size(test_features,1);
        test_serror = sum(sum(sequencesCorrect, 2) == 7)/size(test_features,1);
        disp(test_merror)
        disp(test_serror)
        
        merrors(regi, regj) = test_merror;
        serrors(regi, regj) = test_serror;
    end
end