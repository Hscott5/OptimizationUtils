function [history, paramStruct] = testOptimization(paramStruct)

% paramStruct contains any and all information needed for the simulated
% neural population as well as testing the optimization

if nargin<1
    paramStruct = defaultOptimParams();
end



%% Test Optimization code
nNeurons = paramStruct.nNeurons;
nGens = paramStruct.nGens;
nSim = paramStruct.nSim;
nLatents = paramStruct.nLatents;
exploitType = paramStruct.exploitType;
exploreType = paramStruct.exploreType;
nParticles = paramStruct.nParticles;
peak = paramStruct.maxFR*ones(1,nNeurons);
if ~isfield(paramStruct, 'neurons')
    [neurons, tuning, groundTruth] = generateArtificialPopulation(nNeurons, nLatents,'distrobution', 'groundTruth', 'nDims', paramStruct.nLatents);
    globalBestNorm = sqrt(sum(artificialResponse(neurons, tuning, peak, groundTruth).^2,2));
    paramStruct.neurons = neurons;
    paramStruct.tuning = tuning;
    paramStruct.groundTruth = groundTruth;
    paramStruct.globalBestNorm = globalBestNorm;
else
    neurons = paramStruct.neurons;
    tuning = paramStruct.tuning;
    groundTruth = paramStruct.groundTruth;
    globalBestNorm = paramStruct.globalBestNorm;
end

for sim = 1:nSim % for each simulation
    switch paramStruct.optimization
        case 'pso'
            history = particleSwarm('nParticles', nParticles, 'randStart', paramStruct.randStart, 'exploitType', exploitType, 'exploreType', exploreType, 'fullAdept', paramStruct.fullAdept, 'optimizeFor', paramStruct.optimizeFor, 'nDims', paramStruct.nLatents); % initialize particle swarm
        case 'genetic'
            history = geneticAlgorithm('populationSize', nParticles);
    end
    
    for g = 1:nGens % for each generation
        for t = 1:nParticles % for each particle
            % append the response of each neron to each particle to history
            history.response{g}(:,t) = artificialResponse(neurons, tuning, peak, history.stim{end}(:,t)); 
        end
        % give the particleSwarm algorithm the stimuli and neural responses to
        % update the history
        switch paramStruct.optimization
            case 'pso'
                history = particleSwarm(history, 'nParticles', nParticles, 'randStart', paramStruct.randStart, 'exploitType', exploitType, 'exploreType', exploreType, 'nDims', paramStruct.nLatents);
                if paramStruct.verbose
                    fprintf('Current Generation: %d \nBest Response Norm: %f \nGlobal Max Norm: %f \nAverage Step Size: %f \nAverage Pairwise Distance: %f\n',...
                        g, sqrt(sum(history.globalBest{2}(:,end).^2)), globalBestNorm ,mean(sqrt(sum(history.oldVelocity.^2))), mean(mean(dist(history.stim{end}))))
                    distanceToBest = dist([history.globalBest{1}(:,end), groundTruth]);
                    fprintf('Distance to Peak: %f\n \n', distanceToBest(1,2));
                end
            case 'genetic'
                history = geneticAlgorithm(history, 'populationSize', nParticles, 'mutationSigma', paramStruct.mutationSigma);
                bestForGen = max(sqrt(sum(history.response{end}.^2,1)));
                fprintf('Current Generation: %d \nBest Response Norm for Gen: %f \nGlobal Max Norm: %f \nAverage Pairwise Distance: %f\n \n',...
                        g, bestForGen, globalBestNorm ,mean(mean(dist(history.stim{end}))))
                
        end
        
    end
%     bestNorms(sim) = sqrt(sum(history.globalBest{2}(:,end).^2));
%     bestPoints(:,sim) = history.globalBest{1}(:,end);
%     sqrt(sum(history.globalBest{1}.^2,1));
end

