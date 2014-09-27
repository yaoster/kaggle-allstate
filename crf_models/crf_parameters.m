function [Xnode, Xedge, nodeMap, edgeMap, edgeStruct] = crf_parameters(features, nStates)

nNodes = length(nStates);

%% make edge struct
adj = -1*eye(nNodes) + 1;
edgeStruct = UGM_makeEdgeStruct(adj, nStates);
nEdges = edgeStruct.nEdges;

[nInstances, nFeatures] = size(features);
nFeatures = nFeatures + 1;
Xnode = zeros(nInstances, nFeatures, nNodes);
Xnode(:, 1, :) = 1;
for m = 2:nFeatures
    for j = 1:nNodes
        Xnode(:, m, j) = features(:, m - 1);
    end
end
Xedge = ones(nInstances, 1, nEdges);

nNodeFeatures = size(Xnode, 2);
nEdgeFeatures = size(Xedge, 2);
nEdges = edgeStruct.nEdges;

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
