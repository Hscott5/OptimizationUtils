function [result] = adeptComponentHS(history)


maxGenerations = 50;
warning('off','MATLAB:nearlySingularMatrix')

if size(history.stim,2)<=maxGenerations
    stim = cat(3, history.stim{:});
    responses = cat(3, history.response{:});
else
    stim = cat(3, history.stim{end-maxGenerations:end});
    responses = cat(3, history.response{end-maxGenerations:end});
end
% I preallocate stim so remove a generation if the numbers don't line up
if size(stim,3)>size(responses,3)
    stim = stim(:,:,1:size(responses,3));
end


% L2 norm as response variable (nParticles x nGenerations)
responseVar = squeeze(sqrt(sum(responses.^2,1)));


% iterate through particles
for part = 1: size(responses,2)
    particleStim = squeeze(stim(:,part,:))';
    % Beta matrix of a linear regression of the form (x'*x)^-1*x'*Y
    result(:,part) = inv(particleStim'*particleStim)*particleStim'*responseVar(part,:)';
end




