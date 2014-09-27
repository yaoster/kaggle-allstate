function [Xnode, Xedge, nodeMap, edgeMap, edgeStruct] = crf_parameters_l1(features, nStates)

nNodes = length(nStates);

%% make edge struct
% adj = -1*eye(nNodes) + 1;
adj = zeros(nNodes);
adj(1,5) = 1;
adj(1,6) = 1;
adj(2,5) = 1;
adj(3,4) = 1;
adj = adj + adj';
edgeStruct = UGM_makeEdgeStruct(adj, nStates);

[nInstances, nFeatures] = size(features);
nFeatures = nFeatures + 1;
Xnode = zeros(nInstances, nFeatures, nNodes);
Xnode(:, 1, :) = 1;
%% uncomment for features shared across nodes
for m = 2:nFeatures
    for j = 1:nNodes
        Xnode(:, m, j) = features(:, m - 1);
    end
end
%% uncomment for node-specific features
% Xnode(:, 2:3, 1) = features(:, 1:2);
% Xnode(:, 4, 2) = features(:, 3);
% Xnode(:, 5:7, 3) = features(:, 4:6);
% Xnode(:, 8:9, 4) = features(:, 7:8);
% Xnode(:, 10, 5) = features(:, 9);
% Xnode(:, 11:13, 6) = features(:, 10:12);
% Xnode(:, 14:16, 7) = features(:, 13:15);

%% uncomment for no edge features
% Xedge = ones(nInstances, 1, nEdges);

%% uncomment for edge features
Xedge = UGM_makeEdgeFeatures(Xnode, edgeStruct.edgeEnds, ones(nFeatures, 1));

nNodeFeatures = size(Xnode, 2);
nEdgeFeatures = size(Xedge, 2);
nEdges = edgeStruct.nEdges;

%% make nodeMap and edgeMap - nodeMap is (node, state, feature number)
% nodeMap(node, state, feature)
nodeMap = zeros(nNodes, max(nStates), nNodeFeatures, 'int32');
counter = 1;
for n = 1:nNodes
    for s = 1:nStates(n)
        if nStates(n) == 2 && s == 2
            continue
        end
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
            for f = 1:nEdgeFeatures
                edgeMap(s1, s2, e, f) = counter;
                counter = counter + 1;
            end
        end
    end
end
