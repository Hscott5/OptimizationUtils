%% OptimizationUtils Demo

% Author: Hayden Scott 2022

%% generate a simulated neural population

params=struct();
params.nNeurons = 100;                      % how many neurons in the population
nGenerations = 100;                         % how many generations over which to optimize
nSimulations = 1;                           % how many times to start the optimization over
params.nParticles = 64;                     % how many samples per generation
params.nInvariantDims = 26;                 % number of variables that each neuron is invariant to
params.peak = 100*ones(1,params.nNeurons);  % peak firing rate for neurons
params.tuningWidth = 60;                    % width of the gaussian tuning curve

params.exploitType = 'hive';                % attractive force to better valued samples
params.exploreType = 'adept';               % follow local gradients to explore
params.exploitWeight = 2;                   % how much to weight the exploit component
params.exploreWeight = 1.5;                 % how much to weight the explore component
params.momentum = 0.4;                      % the momentum term helps avoid local minima
params.withVariance=true;                   % add poisson variance to the neural responses

% pref: an nVariable by nNeuron matrix where each column is the preferred
% values for that neuron
%
% tuning: an nVariable x nVariable x nNeuron tensor where each 2D slice is
% a covariance matrix for each neuron across variables. Allows for
% dependent interactions between varaibles 
[params.pref, params.tuning] = generateArtificialPopulation(params.nNeurons,...
    'distribution', 'groundTruth', ... % neural preferences are pulled from a single distribution
    'tuningWidth', params.tuningWidth,...
    'nInvariantDims', params.nInvariantDims);


%% particleSwarm

% initialize a structure with the default values
history=particleSwarm;
% or
% history=geneticAlgorithm;

% iterate through generations
for generation=1:nGenerations
    % evaluate the neural response function at each value
    for t = 1:params.nParticles % for each particle
        % evaluate the neural responses and append
        history.response{generation}(:,t) = artificialResponse(params.pref, params.tuning, params.peak, history.stim{end}(:,t), params.withVariance); 
    end
    % evaluate the optimization
    history = particleSwarm(history);
    % or
    % history = geneticAlgorithm(history);
end


