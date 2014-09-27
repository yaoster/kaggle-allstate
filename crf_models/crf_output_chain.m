function [marginals, sequences] = crf_output_chain(w, Xnode, Xedge, nodeMap, edgeMap, edgeStruct)

nInstances = size(Xnode, 1);
marginals = zeros(nInstances, edgeStruct.nNodes);
sequences = zeros(nInstances, edgeStruct.nNodes);

for i = 1:nInstances
    [nodePot,edgePot] = UGM_CRF_makePotentials(w, Xnode, Xedge, nodeMap, edgeMap, edgeStruct, i);
    [nodeBel, belSeq] = max(UGM_Infer_Exact(nodePot, edgePot, edgeStruct), [], 2);
    decodeSeq = UGM_Decode_Exact(nodePot, edgePot, edgeStruct);
    marginals(i, :) = belSeq';
    sequences(i, :) = decodeSeq';
end

marginals(:, [1, 2, 5, 6]) = marginals(:, [1, 2, 5, 6]) - 1;
sequences(:, [1, 2, 5, 6]) = sequences(:, [1, 2, 5, 6]) - 1;