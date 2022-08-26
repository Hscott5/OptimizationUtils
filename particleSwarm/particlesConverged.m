function result = particlesConverged(history, varargin)

p = inputParser;
addParameter(p, 'convergeType', 'distance');
addParameter(p, 'criticalVal', []);
parse(p,varargin{:})
convergeType = p.Results.convergeType;
criticalVal = p.Results.criticalVal;

if isempty(criticalVal) && isfield(history, 'convergeCriticalVal')
    criticalVal = history.convergeCriticalVal;
else
    criticalVal = 16;
end
points = history.stim{end};
 
switch convergeType
    case 'variance'
    case 'distance'
        dists = dist(points);
        result = mean(mean(dists))<criticalVal;
end

