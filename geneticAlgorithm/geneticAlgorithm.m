function history = geneticAlgorithm(varargin)

% structure = geneticAlgorithm(varargin)
% 1.) to start, run the function with whatever parameters you want 
% 2.) every subsequent run should include the previous generations "history"
%     structure as an input.
%     - this history input should include the responses to the current
%     generation in the history.response field. history.stim and
%     history.response should be cell arrays of the same size
%     1xnGenerations



%%
p = inputParser;
defaultDims = 128; %nLatents in current GAN model
populationSize = 64; % number of images per generation
defaultRadius = 15; % L2-norm of initial latent vectors (radius in latent space matters) 

addParameter(p, 'nDims', defaultDims, @isnumeric);
addParameter(p, 'populationSize', populationSize);
addParameter(p, 'startRadius', defaultRadius);
addParameter(p, 'optimizeFor', 'norm');
addParameter(p, 'mutationSigma', 0.75);
addParameter(p, 'parent1Contribution', 0.75);
addParameter(p, 'mutationRate', 0.25);
addParameter(p, 'nKeep', 10); % # of unaltered vectors to keep for next gen
addOptional(p,'history', struct('oldVelocity', 0));
p.StructExpand = false;
parse(p, varargin{:});
history = p.Results.history;
nDims = p.Results.nDims;
startRadius = p.Results.startRadius;

% if run for the first time, initialize and save parameters
if ~isfield(history, 'stim')
    history.stim = {normc(randn(nDims,populationSize)).*startRadius};
    history.nChild = p.Results.populationSize-p.Results.nKeep;
    history.mutationRate=p.Results.mutationRate;
    history.mutationSigma=p.Results.mutationSigma;
    history.parent1Contribution=p.Results.parent1Contribution;
    return
end


%% Generate Next set of latents

% XDream - Ponce et al. 2019           
% 1.) zscore firing rates within generation
%       then scale with "selectiveness factor" of 0.5
%       then pass through a softmax function to make them probabilities
%       = fitness

% 2.) keep top 10 unaltered
%       add 30 "children" by recombining from last generation
%       probability of being a parent = fitness
%       parents contribute unevenly 75%/25%
%       then children genes mutate at 25% rate (mutation rate)
%        - mutations drawn from 0-centered Gaussian with sig 0.75


% fit = probability of being a parent
fit = calcFitness(history.response{end});

% select best images to keep
bestInd = sort(fit, 'descend');
parents2Keep = history.stim{end}(:,ismember(fit, bestInd(1:p.Results.nKeep)));

% if this is the first generation, initialize
if ~isfield(history, 'globalBest')
    history.globalBest{1,:} = history.stim{end}(:,ismember(fit, bestInd(1)));
    history.globalBest{2,:} = history.response{end}(:,ismember(fit, bestInd(1)));
% else update the current best estimate
elseif sqrt(sum(history.globalBest{2,:}(:,end).^2,2))< sqrt(sum(history.response{end}(:,ismember(fit, bestInd(1))).^2,1))
    history.globalBest{1,:} = cat(2,history.globalBest{1,:},history.stim{end}(:,ismember(fit, bestInd(1))) );
    history.globalBest{2,:} = cat(2,history.globalBest{2,:},history.response{end}(:,ismember(fit, bestInd(1))) );
end

%% Make Babies

children = recombine(history.stim{end},history.nChild, fit, 'parent1Contribution', p.Results.parent1Contribution); 
children = mutate(children, 'sigm', p.Results.mutationSigma, 'mutationRate', p.Results.mutationRate);

%% Add next generation to history structure for evaluation

allVecs = [parents2Keep, children];
history.stim{end+1} = allVecs(:, randperm(size(allVecs,2)));







