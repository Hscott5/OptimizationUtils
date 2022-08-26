function vecs = hiveComponent(history)
% a function to determine how to exploit the optimization space for
% particle swarm. used as a replacement of the global best
% weighted vector average for the difference between the current point and
% all other points that have better responses
parseHistory(history);
maxGens2Consider = 5;
currentPoints = history.stim{end};
currentResponses = history.response{end};
if size(history.response,2)>maxGens2Consider
    responses = cat(2,history.response{end-maxGens2Consider:end});
    allPoints = cat(2,history.stim{end-maxGens2Consider:end});
else
    responses = cat(2,history.response{:});
    allPoints = cat(2,history.stim{:});
end

switch history.optimizeFor
    case 'norm'
        norms = sqrt(sum(responses.^2,1));
        for p = 1:nParticles
            betterFilt = norms>sqrt(sum(currentResponses(:,p).^2,1));
            betterPoints = allPoints(:,betterFilt);
            weights = sqrt(sum(responses(:,betterFilt).^2,1))-sqrt(sum(currentResponses(:,p).^2,1));
            weights = weights./sum(weights);
            vecs(:,p) = sum(normc(betterPoints-currentPoints(:,p)).*weights,2);
        end
    case 'variance'
        vars = var(responses,[],1);
        for p = 1:nParticles
            betterFilt = vars>var(currentResponses(:,p));
            betterPoints = allPoints(:,betterFilt);
            weights = var(responses(:,betterFilt),[],1)-var(currentResponses(:,p));
            weights = weights./sum(weights);
            vecs(:,p) = sum(normc(betterPoints-currentPoints(:,p)).*weights,2);
        end
end

vecs = normc(vecs);