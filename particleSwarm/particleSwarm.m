function history = particleSwarm(varargin)

% Runs Particle Swarm Optimization to test for the best latent vectors that
% drive a neural population

% 1.) to initialize, run without the history input
% 2.) on subsequent calls, inputing the history struct updates it and
%     generates new stimuli vectors in the 'stim' field

% Fields of History:
% stim: cell array (1 x nGenerations) of matrices where each column is a vector
%       representation of an image. The matricies are nDims x nParticles
%
% response: a cell array (1 x nGenerations) of matricies where each column
%           is a vector of neural responses (spike counts, etc). Matricies
%           are nNeurons x nParticles


% Parameters:
% PSO is balanced between exploring and exploiting the space by using vector addition.
% These two arguments allow for different methods to be employed to that end.
% The default options are 'adept' and 'hive'.
%
% explorePart: ('adept') Uses kernel regression to estimate the local
%               gradient, independently for each particle, and moves the 
%               particles in a step along that gradient.
% exploitPart: ('hive') Particles move toward other particles that resulted
%               in better neural responses. These trajectories are weighed
%               by how much better each other point is than the current
%               location.
%

% nDims: dimensionality of the stimulus set. eg. the latent dimensionality
%        of our GAN is 128 (Fruend and Stalker 2018)
%
% nParticles: The number of particles that are searching the stimulus space
% 
% startRadius: all particles are initiated on a hypersphere in the stimulus
%              space with this radius
%
% randStart: initiate the particles with random vectors or to use a
%            systematic basis set. True/False
%
% optimizeFor: 'norm' or 'variance'. How to evaluate what a 'good' response
%               is.



p = inputParser;
defaultDims = 128;
nParticles = 64;
defaultRadius = 15;
addParameter(p, 'nDims', defaultDims, @isnumeric);
addParameter(p, 'nParticles', nParticles);
addParameter(p, 'startRadius', defaultRadius);
addParameter(p, 'randStart', true);
addParameter(p, 'optimizeFor', 'norm');
addParameter(p, 'exploreType', 'adept');
addParameter(p, 'exploitType', 'hive');
addParameter(p, 'stimSpace', 'gan');
addParameter(p, 'reinitialize', false);
addParameter(p, 'momentum', 0.5)
addParameter(p, 'exploreWeight', 2);
addParameter(p, 'exploitWeight', 2);
addOptional(p,'history', struct('oldVelocity', 0));
p.StructExpand = false;
parse(p, varargin{:});
history = p.Results.history;
nDims = p.Results.nDims;
optimizeFor = p.Results.optimizeFor;
startRadius = p.Results.startRadius;
randStart = p.Results.randStart;
stimSpace = p.Results.stimSpace;

% this is for convenience
assert(mod(nDims, nParticles)==0, 'particleSwarm: nParticles must be a factor of nDims');

%% Initialize

nMultiples = nDims/nParticles;
for m = 1:nMultiples
    beginZeros = repmat(zeros(nParticles), m-1,1);
    endZeros = repmat(zeros(nParticles), nMultiples-m,1);
    basisVals{m} = cat(1,beginZeros, eye(nParticles).*startRadius);
    basisVals{m} = cat(1, basisVals{m}, endZeros);
end

% initialize all fields of the structure
if ~isfield(history, 'stim')
    % different defaults are required for different stimulus spaces
    switch stimSpace
        case 'gabor'
            if isfield(history, 'nGabors')
                nGabors = history.nGabors;
            else
                nGabors = 32;
            end
            history.stim = {[rand(nParticles,nGabors)*20,rand(nParticles,nGabors)*20,rand(nParticles,nGabors)*2*pi,rand(nParticles,nGabors)]'};
        case 'dot'
            history.stim = {randDotParams(nParticles)};
            % circular stimulus spaces are tricky (eg. "orientation" wraps)
            [~, history.paramBounds] = randDotParams(nParticles);
        case 'gan'
            % trying something initialize with the full space
%             history.stim = {repmat(linspace(-8,8,64),nDims,1 )};
            history.stim = {normc(randn(nDims,nParticles)).*startRadius}; % random gan latent space
    end
    history.w = p.Results.momentum; % momentum term 
    history.c1 = p.Results.exploreWeight; % weight for explore component
    history.c2 = p.Results.exploitWeight; % weight for exploit component
    history.optimizeFor = optimizeFor;
    history.stimSpace = stimSpace;
    history.exploreType = p.Results.exploreType;
    history.exploitType = p.Results.exploitType;
    history.response = [];
    history.globalBest = [];
    history.personalBest = [];
    return;
end

% in case the algorithm stops making progress or converges, flag to do a
% single generation that moves particles into a new space
if p.Results.reinitialize
    newStim = normc(randn(nDims,nParticles)).*startRadius;
    history.stim{end} = newStim; 
    return;
end

%% Update Population Best and Personal Best Values
% optimization can be done on the norm of the population response vector or
% the variance of the population response vector 
% for now just norm is allowed

switch optimizeFor
    case 'norm'
        norms = sqrt(sum(history.response{end}.^2, 1));
        winner = find(norms==max(norms),1);
        if size(winner, 2)>1
            winner = winner(:,1);
        end
        
%         % initialize these fields with the only available values
%         if ~isfield(history, 'globalBest')
%             history.globalBest = {history.stim{end}(:,winner); history.response{end}(:,winner)};
%             history.personalBest = {history.stim{end}; history.response{end}};  
%         end
        
        % because I preallocated an empty array
        if ~isempty(history.globalBest)
            % if any new best guesses appear, save them
            if norm(history.globalBest{2}(:,end)) <= norms(winner)
                history.globalBest{1,:} = cat(2, history.globalBest{1,:}, history.stim{end}(:,winner));
                history.globalBest{2,:} = cat(2, history.globalBest{2,:}, history.response{end}(:,winner));
            else % otherwise the global best is whatever the last one was
                history.globalBest{1,:} = cat(2, history.globalBest{1,:}, history.globalBest{1,:}(:,end));
                history.globalBest{2,:} = cat(2, history.globalBest{2,:}, history.globalBest{2,:}(:,end));
            end
        else % this is gen 1 and globalBest is empty
            % format the cell array for future calls
            history.globalBest = cell(2,1);
            % insert the best particle from gen 1
            history.globalBest{1,:} = history.stim{end}(:,winner);
            history.globalBest{2,:} = history.response{end}(:,winner);
        end
        
        % save any changes to the personal best guess
        if isempty(history.personalBest)
            history.personalBest = cell(2,1);
            history.personalBest{1} = zeros(size(history.stim{end},1), nParticles);
            history.personalBest{2} = zeros(size(history.response{end},1), nParticles);
        end
        personalNorms = sqrt(sum(history.personalBest{2}.^2,1));
        particleImproveIndx = norms > personalNorms(:,:,end);
        newPersonalBests = history.personalBest{1}(:,:,end);
        newPersonalBestResponses = history.personalBest{2}(:,:,end);
        newPersonalBests(:,particleImproveIndx) = history.stim{end}(:,particleImproveIndx);
        newPersonalBestResponses(:,particleImproveIndx) = history.response{end}(:,particleImproveIndx);
        if min(size(newPersonalBests))~=0
            history.personalBest{1,:} = cat(3, history.personalBest{1,:}, newPersonalBests);
            history.personalBest{2,:} = cat(3, history.personalBest{2,:}, newPersonalBestResponses);
        end
end


%% Calculate Next Stimulus for each Particle

% if this is the first three generations initiate randomly
if size(history.stim,2)<3
    switch history.stimSpace
        case 'gabor'
            if isfield(history, 'nGabors')
                nGabors = history.nGabors;
            else
                nGabors = 32;
            end
            history.stim = [history.stim, {[rand(nParticles,nGabors)*20,rand(nParticles,nGabors)*20,rand(nParticles,nGabors)*2*pi,rand(nParticles,nGabors)]'}];
        case 'dot'
            history.stim = [history.stim, {randDotParams(nParticles)}];
        case 'gan'
            history.stim = [history.stim, {normc(randn(nDims,nParticles)).*startRadius}]; % random gan latent space
    end
    
else % Run the Optimization

    % if particles are too close
%     distMat = tril(dist(history.stim{end}));
%     avgDist = mean(distMat(distMat~=0));
%     if avgDist<=2 
%         % ramp up the explore part
%         convergeScalingFactor = 3;
%     else
        convergeScalingFactor=1;
%     end


    randComponent1 = rand(1,nParticles);
    randComponent2 = rand(1,nParticles);
    
    switch p.Results.exploreType
        case 'adept' % gradient estimation
%             explorePart = normc(adeptComponent(history));
            explorePart = normc(adeptComponentHS(history));
        case 'vanilla' % vanilla particle swarm
            explorePart = normc(history.personalBest{1}(:,:,end)-history.stim{end});
        case 'random' % random stimuli 
            newRads = randn(1,nParticles)*3+12;
            history.stim = cat(2, history.stim, {normc(randn(nDims,nParticles)).*newRads});
            return
    end
    switch p.Results.exploitType
        case 'vanilla' % vanilla particle swarm
            exploitPart = normc(history.globalBest{1}(:,end)-history.stim{end});
        case 'hive' % weighted vectors by how much better each other particle is
            exploitPart = hiveComponent(history);
        case 'none' % for solo 'adept' testing
            exploitPart = zeros(nDims, nParticles);
    end
    
    % Combine all the parts into the new Velocity
    newVelocity = history.w*history.oldVelocity + history.c1*randComponent1.*explorePart.*convergeScalingFactor + history.c2*randComponent2.*exploitPart;
    % take larger steps if too close to origin
    % this is because too close to the origin in gan space is all identical
    l2norms = sqrt(sum((history.stim{end} + newVelocity).^2,1)); %l2norm in latent space
    scalingFactor = ones(1,size(l2norms,2));
    scalingFactor(l2norms<7)=3;
    newStim = {history.stim{end} + newVelocity.*scalingFactor};
    
%     % for some stimulus spaces, there may be hard boundaries on the parameters
%     switch history.stimSpace
%         case 'dot'
%             % find where the velocities took a parameter too far
%             tooLow = newStim<history.paramBounds(:,1);
%             tooHigh = newStim>history.paramBounds(:,2);
%             replaceIndxLow = repmat(history.paramBounds(:,1),1, nParticles);
%             replaceIndxHigh = repmat(history.paramBounds(:,2),1, nParticles);
%             newStim(tooLow)= replaceIndxLow(tooLow);
%             newStim(tooHigh) = replaceIndxHigh(tooHigh);
%             % Some parameters must be whole numbers
%             integerVals = false(22,nParticles);
%             integerVals([1,2,4,5,14,15],:) = true;
%             newStim(integerVals) = round(newStim(integerVals));
%             
%             newVelocity = newStim-history.stim{end}; % so the algorithm knows the actual velocity of this round
%     end
    
    history.oldVelocity = newVelocity; % save this current velocity for the momentum term in the next generation
    history.stim = cat(2, history.stim, newStim); 
    
end
