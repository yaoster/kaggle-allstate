clear
clc

%% load data and parameters and set constants
load crf_edge_features_regularized_minimal_edges
features = csvread('../random_forest_test_votes.csv');
features = features(:, [1:2, 4, 6:8, 10:11, 13, 15:17, 19:21]);
nInstances = size(features, 1);
nNodes = 7;
nStates = [3, 2, 4, 3, 2, 4, 4];

%% test model
[Xnode, Xedge, nodeMap, edgeMap, edgeStruct] = crf_parameters_minedges(features, nStates);
[marginals, sequences] = crf_output_chain(w, Xnode, Xedge, nodeMap, edgeMap, edgeStruct);

%% write output
customers = csvread('../../data/test_customers.csv', 1, 0);
moutput = 'crf_l2_reg_marginals.csv';
soutput = 'crf_l2_reg_sequences.csv';
mfile = fopen(moutput, 'w');
sfile = fopen(soutput, 'w');
fprintf(mfile, 'customer_ID,plan\n');
fprintf(sfile, 'customer_ID,plan\n');
for i = 1:nInstances
    fprintf(mfile, '%i,%i%i%i%i%i%i%i\n', customers(i), marginals(i,:));
    fprintf(sfile, '%i,%i%i%i%i%i%i%i\n', customers(i), sequences(i,:));
end
