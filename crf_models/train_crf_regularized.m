% clear
% clc

regCoef = .000001;
maxIter = 10;

%% load data and set constants
features = csvread('../random_forest_votes.csv');
features = features(:, [1:2, 4, 6:8, 10:11, 13, 15:17, 19:21]);
targets = int32(csvread('../../data/train_targets.csv', 1, 1));
targets(:, [1, 2, 5, 6]) = targets(:, [1, 2, 5, 6]) + 1;
% test_features = features(70001:size(features, 1),:);
% test_targets = targets(70001:size(features, 1),:);
% features = features(1:70000,:);
% targets = targets(1:70000,:);
[nInstances, nNodes] = size(targets);
nStates = [3, 2, 4, 3, 2, 4, 4];

%% features, feature maps, edge struct
[Xnode, Xedge, nodeMap, edgeMap, edgeStruct] = crf_parameters(features, nStates);

%% SGD training
nParams = max([nodeMap(:); edgeMap(:)]);
w = zeros(nParams,1);
lambda = regCoef*ones(size(w));
for n = 1:nNodes
    for s = 1:nStates(n)
        lambda(nodeMap(n, s, 1)) = 0;
    end
end
lambda((max(nodeMap(:)) + 1):length(lambda)) = 0;

% stepSize = logspace(0, -8, maxIter*nInstances);
stepSize = linspace(1, 1e-8, maxIter*nInstances);
ll = zeros(maxIter*nInstances, 1);
for iter = 1:maxIter*nInstances
    i = ceil(rand*nInstances);
    funObj = @(w)penalizedL2(w,@UGM_CRF_NLL,lambda,Xnode(i,:,:),Xedge(i,:,:),targets(i,:),nodeMap,edgeMap,edgeStruct,@UGM_Infer_LBP);
    [f,g] = funObj(w);
    ll(iter) = f;
    
    if mod(i, 10000) == 0
        fprintf('Iter = %d of %d (fsub = %f)\n',iter,maxIter*nInstances,f);
    end
    
    w = w - stepSize(iter)*g;
end
save('crf_regularized.mat', 'w')

%% get in-sample error
targets(:, [1, 2, 5, 6]) = targets(:, [1, 2, 5, 6]) - 1;
[marginals, sequences] = crf_output(w, Xnode, Xedge, nodeMap, edgeMap, edgeStruct, features);
marginalsCorrect = (marginals == targets);
sequencesCorrect = (sequences == targets);
merror = sum(sum(marginalsCorrect, 2) == 7)/nInstances;
serror = sum(sum(sequencesCorrect, 2) == 7)/nInstances;

%% get test error
% [Xnode, Xedge, nodeMap, edgeMap, edgeStruct] = crf_parameters(test_features, nStates);
% test_targets(:, [1, 2, 5, 6]) = test_targets(:, [1, 2, 5, 6]) - 1;
% [marginals, sequences] = crf_output(w, Xnode, Xedge, nodeMap, edgeMap, edgeStruct, test_features);
% marginalsCorrect = (marginals == test_targets);
% sequencesCorrect = (sequences == test_targets);
% test_merror = sum(sum(marginalsCorrect, 2) == 7)/size(test_features,1);
% test_serror = sum(sum(sequencesCorrect, 2) == 7)/size(test_features,1);
% disp(test_merror)
% disp(test_serror)