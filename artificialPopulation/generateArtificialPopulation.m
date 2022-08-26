function [pref, tuning, groundTruth] = generateArtificialPopulation(varargin)

% generateArtificialPopulation(nNeurons=100, nInvariantDims=5, name, value)

%% Parse input
p = inputParser;
defaultDims = 128;
addParameter(p, 'nDims', defaultDims, @isnumeric);
addParameter(p, 'distrobution', 'uniformGaussian');
addParameter(p, 'tuningSigma', [])
addOptional(p, 'nNeurons', 100);
addOptional(p, 'nInvariantDims', 5);
parse(p, varargin{:});
nDims = p.Results.nDims;
N = p.Results.nNeurons;
nInvariantDims = p.Results.nInvariantDims;
% if isempty(p.Results.tuningSigma)
%     tuningSigma = 3;
% else
%     tuningSigma = p.Results.tuningSigma;
% end

%% Actual Function

pref = normc(randn(nDims,N)).*sqrt(nDims);

switch p.Results.distrobution
    case 'uniformGaussian'
        tuning = repmat(eye(nDims),1,1,N)./nDims;
    case 'randInvariant'
        tuning = repmat(eye(nDims),1,1,N)./nDims;
        for t = 1:N
            x = randperm(nDims, nInvariantDims);
            tuning(x,:,t) = 0;
        end
    case 'randVariant'
        tuning = repmat(eye(nDims),1,1,N)./nDims;
        for t = 1:N
            x = randperm(nDims, nInvariantDims);
            tuning(x,:,t) = rand(nInvariantDims,1).*tuning(x,:,t)*2;
        end
    case 'groundTruth'
        groundTruth = normc(randn(nDims,1)).*sqrt(nDims);
        tuning = repmat(eye(nDims),1,1,N)./(nDims/1.5);
        pref = randn(nDims,N)+groundTruth;
end
