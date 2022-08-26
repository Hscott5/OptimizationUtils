function output = mutate(input, varargin)
% helper function for genetic algorithm
% adds mutations to the vectors
% each column of input is an individual

p = inputParser;
addParameter(p, 'mutationRate', 0.25)
addParameter(p, 'mutationDist', 'gaussian')
addParameter(p, 'sigm', 2)
parse(p, varargin{:});
sigm = p.Results.sigm;

output = input;
switch p.Results.mutationDist
    case 'gaussian'
        for c = 1:size(input,2)
            mutInd = rand(size(input,1),1)<p.Results.mutationRate;
            output(mutInd,c) = randn(sum(mutInd),1)*sigm;
        end
end





