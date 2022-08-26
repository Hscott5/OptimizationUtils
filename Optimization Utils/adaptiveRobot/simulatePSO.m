
set(0,'DefaultFigureWindowStyle','docked')

%% Test Optimization code pso
nNeurons = 50;
nGens = 80;
nSim = 30;
c = 10; % number of latents that each neuron is invariant to
exploitType = 'vanilla';
exploreType = 'adept';
peak = 50*ones(1,nNeurons);
[neurons, tuning, groundTruth] = generateArtificialPopulation(nNeurons, c,'distrobution', 'groundTruth');
globalBestNorm = sqrt(sum(artificialResponse(neurons, tuning, peak, groundTruth).^2,2));

for sim = 1:nSim % for each simulation
    history = particleSwarm('nParticles', 64, 'randStart', true, 'exploitType', exploitType, 'exploreType', exploreType); % initialize particle swarm
    for g = 1:nGens % for each generation
        for t = 1:size(history.stim{end},2) % for each particle
            % append the response of each neron to each particle to history
            history.response{g}(:,t) = artificialResponse(neurons, tuning, peak, history.stim{end}(:,t)); 
        end
        % give the particleSwarm algorithm the stimuli and neural responses to
        % update the history
        history = particleSwarm(history, 'nParticles', 64, 'randStart', true, 'exploitType', exploitType, 'exploreType', exploreType);
        fprintf('Current Generation: %d \nBest Response Norm: %f \nGlobal Max Norm: %f \nAverage Step Size: %f \nAverage Pairwise Distance: %f\n', g, sqrt(sum(history.globalBest{2}(:,end).^2)), globalBestNorm ,mean(sqrt(sum(history.oldVelocity.^2))), mean(mean(dist(history.stim{end}))))
        distanceToBest = dist([history.globalBest{1}(:,end), groundTruth]);
        fprintf('Distance to Peak: %f\n \n', distanceToBest(1,2));
    end
    bestNorms(sim) = sqrt(sum(history.globalBest{2}(:,end).^2));
    bestPoints(:,sim) = history.globalBest{1}(:,end);
    sqrt(sum(history.globalBest{1}.^2,1));
end



% plot the values of each latent for each simulation
figure
imagesc(bestPoints)
colorbar
axis square
title('PSO output for 40 Simulations')
xlabel('Simulation')
ylabel('Best latent point after 80 Generations')

% gather all information into a results structure
latentNorms = sqrt(sum(bestPoints.^2, 1));
resultsNew.meanR = mean(latentNorms);
resultsNew.stdR = std(latentNorms);
resultsNew.stdLatents = std(bestPoints')';
resultsNew.meanStdLatents = mean(resultsNew.stdLatents);
resultsNew.points = bestPoints;

% Distance matrix
pairWiseDists = pdist(bestPoints');
pairWiseDists = squareform(pairWiseDists);
y = pairWiseDists;
y(y==0)= mean(mean(y));

figure
imagesc(y)
colorbar
axis square
title('Pairwise Distance Matrix (diagonal=mean)')

%% 
%% Test Optimization code pso
nNeurons = 100;
nGens = 100;
nSim = 30;
c = 128;
exploitType = 'hive';
exploreType = 'adept';
peak = 50*ones(1,nNeurons);
[neurons, tuning, groundTruth] = generateArtificialPopulation(nNeurons, c,'distrobution', 'groundTruth');
globalBestNorm = sqrt(sum(artificialResponse(neurons, tuning, peak, groundTruth).^2,2));

for sim = 1:nSim % for each simulation
    history = particleSwarm('nParticles', 64, 'randStart', true, 'exploitType', exploitType, 'exploreType', exploreType); % initialize particle swarm
    for g = 1:nGens % for each generation
        for t = 1:size(history.stim{end},2) % for each particle
            % append the response of each neron to each particle to history
            history.response{g}(:,t) = artificialResponse(neurons, tuning, peak, history.stim{end}(:,t)); 
        end
        % give the particleSwarm algorithm the stimuli and neural responses to
        % update the history
        history = particleSwarm(history, 'nParticles', 64, 'randStart', true, 'exploitType', exploitType, 'exploreType', exploreType);
        fprintf('Current Generation: %d \nBest Response Norm: %f \nGlobal Max Norm: %f \nAverage Step Size: %f \nAverage Pairwise Distance: %f\n', g, sqrt(sum(history.globalBest{2}(:,end).^2)), globalBestNorm ,mean(sqrt(sum(history.oldVelocity.^2))), mean(mean(dist(history.stim{end}))))
        distanceToBest = dist([history.globalBest{1}(:,end), groundTruth]);
        fprintf('Distance to Peak: %f\n \n', distanceToBest(1,2));
    end
    bestNorms(sim) = sqrt(sum(history.globalBest{2}(:,end).^2));
    bestPoints(:,sim) = history.globalBest{1}(:,end);
    sqrt(sum(history.globalBest{1}.^2,1));
end


