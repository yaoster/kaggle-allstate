clear
clc

features = csvread('random_forest_votes.csv');
features = features(:, [1:2, 4, 6:8, 10:11, 13, 15:17, 19:21]);
targets = int32(csvread('../data/train_targets.csv', 1, 1));
targets(:, 1) = targets(:, 1) + 1;
targets(:, 2) = targets(:, 2) + 1;
targets(:, 5) = targets(:, 5) + 1;
targets(:, 6) = targets(:, 6) + 1;
% features = features(1:1000,:);
% targets = targets(1:1000,:);

%% constants
[nInstances, nNodes] = size(targets);
nStates = [3, 2, 4, 3, 2, 4, 4];
nFeatures = size(features, 2) + 1;

%% features
Xnode = zeros(nInstances, nFeatures, nNodes);
Xnode(:, 1, :) = 1;
for m = 2:nFeatures
    for j = 1:nNodes
        Xnode(:, m, j) = features(:, m - 1);
    end
end
%Xedge = UGM_makeEdgeFeatures(Xnode, edgeStruct.edgeEnds, 1:nFeatures);
Xedge = ones(nInstances, 1, nEdges);
nNodeFeatures = size(Xnode, 2);
nEdgeFeatures = size(Xedge, 2);

%% make nodeMap and edgeMap - nodeMap is (node, state, feature number)
% nodeMap(node, state, feature)
nodeMap = zeros(nNodes, max(nStates), nNodeFeatures, 'int32');
counter = 1;
for n = 1:nNodes
    %for s = 1:(nStates(n) - 1)
    for s = 1:nStates(n)
        for f = 1:nNodeFeatures
            nodeMap(n, s, f) = counter;
            counter = counter + 1;
        end
    end
end
% edgeMap(state1, state2, edge, feature)
edgeMap = zeros(max(nStates), max(nStates), nEdges, nEdgeFeatures, 'int32');
for e = 1:nEdges
    for s1 = 1:nStates(edgeStruct.edgeEnds(e, 1))
        for s2 = 1:nStates(edgeStruct.edgeEnds(e, 2))
%             if s1 == nStates(edgeStruct.edgeEnds(e, 1)) && ...
%                s2 == nStates(edgeStruct.edgeEnds(e, 2))
%                 continue
%             end
            edgeMap(s1, s2, e, 1) = counter;
            counter = counter + 1;
        end
    end
end

%% Training
nParams = max([nodeMap(:);edgeMap(:)]);
w = zeros(nParams,1);
maxIter = 100;

% % Optimize
% edgeStruct.useMex = false;
% w = minFunc(@UGM_CRF_NLL,w,[],Xnode,Xedge,targets,nodeMap,edgeMap, ...
%     edgeStruct,@UGM_Infer_LBP);

%% Train with Stochastic gradient descent for the same amount of time
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

[nodePot,edgePot] = UGM_CRF_makePotentials(w,Xnode,Xedge,nodeMap,edgeMap,edgeStruct,10000);
nodeBel = UGM_Infer_LBP(nodePot,edgePot,edgeStruct);
