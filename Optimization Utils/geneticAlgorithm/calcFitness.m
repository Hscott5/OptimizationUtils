function fitness = calcFitness(input)

% from XDREAM paper (Ponce et al. 2019)
% zscore firing rates within generation
%   then scale with "selectiveness factor" of 0.5
%   then pass through a softmax function to make them probabilities
% = fitness

% Z-score the L2 norms
zs = zscore(sqrt(sum(input.^2,1)));

% Scale
scaled = zs;

% softmax function
fitness = exp(scaled)./sum(exp(scaled));



