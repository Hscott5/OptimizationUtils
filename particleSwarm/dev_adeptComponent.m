function [result, bestGradient] = adeptComponent(history)

    % get gradient for all particles, output the small step in that direction

    h = 200;
    nParticles = size(history.stim{1}, 2);
    nNeurons = size(history.response{1},1); 
    nDims = size(history.stim{1},1);
    recentStim = history.stim{end};
    pastStim = cat(3, history.stim{1:end-1});
    responses = cat(2,history.response{1:end-1});
    nStim = size(pastStim,3);
    responseNorms = sqrt(sum(responses.^2, 2));
    nGen = size(pastStim,3);
    kern = adaptiveKernalRegress(recentStim,pastStim);
    kern = kern(:)';
    pastStim = cat(2, history.stim{1:end-1});
    
    particleHistory = mat2cell(pastStim, 128,ones(1,size(pastStim,2)));
    differenceFun = @(x) x-pastStim;
    pairwiseDists = cellfun(differenceFun, particleHistory(:), 'UniformOutput', false);
    pairwiseDists = cat(3, pairwiseDists{:});
    wNumer = 2*sum(pairwiseDists.*kern,3).*kern;
    w = wNumer/(h^2*(sum(kern)).^2);
%     w = reshape(w, nDims, nParticles, nGen);
    
    responsesSeparated = mat2cell(responses, nNeurons, ones(1,size(responses,2)));
    responseDifferences = @(x) norm(x) + sqrt(sum((x-responses).^2,1)); % how clustered points are in response space
    A_k = cellfun(responseDifferences, responsesSeparated, 'UniformOutput', false);
    A_k = sum(cat(1,A_k{:}),1);
%     A_k = reshape(A_k, nParticles,nGen);
    result = normc(w*A_k'-recentStim);
           
    
            
end




