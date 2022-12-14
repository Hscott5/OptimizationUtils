function [result, bestGradient] = adeptComponent(history, useFullHistory)

    % get gradient for each particle, output the small step in that direction
    if nargin<2
        useFullHistory = false;
    end
    h = 200;
    nParticles = size(history.stim{1}, 2);
    nLatents = size(history.stim{1},1);
    nNeurons = size(history.response{1},1); 
    maxGenerationsForFull = 3;
    
    if ~useFullHistory
        recentStim = history.stim{end};
        pastStim = cat(3, history.stim{1:end-1});
        responses = cat(3,history.response{1:end-1});
        nStim = size(pastStim,3);
        responseNorms = sqrt(sum(responses.^2, 3));

        kern = adaptiveKernalRegress(recentStim,pastStim);
        if size(kern,1)==1
            kern = kern';
        end
        for d = 1:nParticles
            thing = mat2cell(squeeze(pastStim(:,d,:)), 128,ones(1,size(pastStim,3)));
            wrapper = @(x) x-squeeze(pastStim(:,d,:));
            particleDists = cellfun(wrapper, thing, 'UniformOutput', false);
            particleDists = cat(3, particleDists{:});
            wNumer = 2*kern(d,:).*sum(particleDists.*repmat(kern(d,:), 128,1,size(kern,2)), 3);
%                 wNumer = 2*sum(particleDists.*kern(d,:),3).*kern(d,:);
            w = wNumer/(h^2*sum(kern(d,:)).^2);

            responsesSeparated = mat2cell(squeeze(responses(:,d,:)), nNeurons, ones(1,size(responses,3)));
            wrapper = @(x) norm(x) + sqrt(sum((x-squeeze(responses(:,d,:))).^2,1));
            A_k = cellfun(wrapper, responsesSeparated, 'UniformOutput', false);
            A_k = cat(1,A_k{:});
            result(:,d) = mean(w*A_k',2);
        end
    else
        % added this if because there is a memory issue with too many
        % generations
        if size(history.stim,2)<maxGenerationsForFull+1
            recentStim = history.stim{end};
            pastStim = cat(2, history.stim{1:end-1});
            responses = cat(2,history.response{1:end-1});
            newResponse = history.response{end};
            nStim = size(pastStim,2);
            responseNorms = sqrt(sum(responses.^2, 1));
        else
            recentStim = history.stim{end};
            pastStim = cat(2, history.stim{end-maxGenerationsForFull:end-1});
            responses = cat(2,history.response{end-maxGenerationsForFull:end-1});
            newResponse = history.response{end};
            nStim = size(pastStim,2);
            responseNorms = sqrt(sum(responses.^2, 1));
        end

        kern = adaptiveKernalRegress(recentStim,pastStim);
        result = zeros(nLatents,nParticles);
        wrapper = @(x) x-pastStim;
        wrapper2 = @(x) norm(x) + sqrt(sum((x-responses).^2,1));
        for d = 1:nParticles
            thing = mat2cell(pastStim, 128,ones(1,size(pastStim,2)));
            particleDists = cellfun(wrapper, thing, 'UniformOutput', false);
            particleDists = cat(3, particleDists{:});
%             wNumer = 2*kern(d,:).*sum(particleDists.*repmat(kern(d,:), 128,1,size(kern,2)), 3);
                        wNumer = 2*sum(particleDists.*kern(d,:),3).*kern(d,:);
            w = wNumer/(h^2*sum(kern(d,:)).^2);
            responsesSeparated = mat2cell(responses, nNeurons, ones(1,size(responses,2)));
            A_k = cellfun(wrapper2, responsesSeparated, 'UniformOutput', false);
            A_k = cat(1,A_k{:});
            result(:,d) = mean(w*A_k',2);
        end

    
    end
end




