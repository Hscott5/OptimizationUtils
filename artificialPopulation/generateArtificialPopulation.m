function [pref, tuning, groundTruth] = generateArtificialPopulation(varargin)

% generateArtificialPopulation(nNeurons=100, nInvariantDims=5, name, value)

%% Parse input
p = inputParser;
defaultDims = 128;
addParameter(p, 'nDims', defaultDims, @isnumeric);
addParameter(p, 'distribution', 'uniformGaussian');
addParameter(p, 'tuningWidth', 50)
addOptional(p, 'nNeurons', 100);
addOptional(p, 'nInvariantDims', 0);
parse(p, varargin{:});
nDims = p.Results.nDims;
N = p.Results.nNeurons;
nInvariantDims = p.Results.nInvariantDims;
tuneWidth = p.Results.tuningWidth;

%% Actual Function

pref = normc(randn(nDims,N)).*sqrt(nDims);

switch p.Results.distribution
    case 'uniformGaussian'
        tuning = repmat(eye(nDims),1,1,N)./tuneWidth;
    case 'randInvariant'
        tuning = repmat(eye(nDims),1,1,N)./tuneWidth;
        for t = 1:N
            x = randperm(nDims, nInvariantDims);
            tuning(x,:,t) = 0;
        end
    case 'randVariant'
        tuning = repmat(eye(nDims),1,1,N)./tuneWidth;
        for t = 1:N
            x = randperm(nDims, nInvariantDims);
            tuning(x,:,t) = rand(nInvariantDims,1).*tuning(x,:,t)*2;
        end
    case 'groundTruth'
        groundTruth = normc(randn(nDims,1)).*sqrt(nDims);
        tuning = repmat(eye(nDims),1,1,N)./(tuneWidth);
        if nInvariantDims>0
            inv = randperm(nDims,nInvariantDims);
            tuning(inv, :,:)=0;
        end
        pref = randn(nDims,N) + groundTruth;
end
