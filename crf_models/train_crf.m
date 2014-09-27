clear
clc

%% load data and set constants
features = csvread('../random_forest_votes.csv');
features = features(:, [1:2, 4, 6:8, 10:11, 13, 15:17, 19:21]);
targets = int32(csvread('../../data/train_targets.csv', 1, 1));
targets(:, [1, 2, 5, 6]) = targets(:, [1, 2, 5, 6]) + 1;
[nInstances, nNodes] = size(targets);
nStates = [3, 2, 4, 3, 2, 4, 4];

%% features, feature maps, edge struct
[Xnode, Xedge, nodeMap, edgeMap, edgeStruct] = crf_parameters(features, nStates);

%% SGD training
nParams = max([nodeMap(:); edgeMap(:)]);
w = zeros(nParams,1);
maxIter = 100;
stepSize = logspace(0, -8, maxIter*nInstances);
ll = zeros(maxIter*nInstances, 1);
for iter = 1:maxIter*nInstances
    i = ceil(rand*nInstances);
    funObj = @(w)UGM_CRF_NLL(w,Xnode(i,:,:),Xedge(i,:,:),targets(i,:),nodeMap,edgeMap,edgeStruct,@UGM_Infer_LBP);
    [f,g] = funObj(w);
    ll(iter) = f;
    
    if mod(i, 10000) == 0
        fprintf('Iter = %d of %d (fsub = %f)\n',iter,maxIter*nInstances,f);
    end
    
    w = w - stepSize(iter)*g;
end
save('weights.mat', 'w')

%% get in-sample error
targets(:, [1, 2, 5, 6]) = targets(:, [1, 2, 5, 6]) - 1;
[marginals, sequences] = crf_output(w, Xnode, Xedge, nodeMap, edgeMap, edgeStruct, features);
marginalsCorrect = (marginals == targets);
sequencesCorrect = (sequences == targets);
merror = sum(sum(marginalsCorrect, 2) == 7)/nInstances;
serror = sum(sum(sequencesCorrect, 2) == 7)/nInstances;