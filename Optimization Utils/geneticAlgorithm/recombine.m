function children = recombine(parents, nChild, fitness, varargin)
% helper function for genetic algorithm
% recombines parents into a new generation of children

p = inputParser;
addParameter(p, 'parent1Contribution', 0.75)
p.StructExpand = false;
parse(p, varargin{:});

%% Select pairs to be parents based on fitness
% select who will be the parents based on the 
% probabilities in parentLikelihood

if any(fitness>0.4)
    % if any individual carries >50% of the probability mass 
    % it basically guarantees that children will have two of the same parents
    % so calculate excess fitness and redistribute the probability mass
    overfit = fitness(fitness>0.4);
    excessFit = overfit-ones(1,size(overfit,2))*0.4; % maximum fitness = 40%
    fitness(fitness<=0.4)=fitness(fitness<=0.4)+(sum(excessFit)/size(fitness(fitness<=0.4),2));
    fitness(fitness>0.4)=0.4;
    fitness = fitness./sum(fitness);
end

bins = [0, cumsum(fitness)];

% These loops prevents the children from 
% having two of the same parent

whosAparent = histcounts(rand(1,nChild*2), bins);


[parentId,nTimesParent]=sort(whosAparent, 'descend');
parentInds = repelem(nTimesParent, parentId);
for u = 1:nChild
    pairs(u,1) = parentInds(1);
    remaining = parentInds(parentInds~=pairs(u,1));
    if ~isempty(remaining)
        p2ind = randperm(size(remaining,2),1)+sum(parentInds==pairs(u,1));
        pairs(u,2) = parentInds(p2ind);
        parentInds([1, p2ind])=[];
    else
        pairs(u,2) = parentInds(end);
    end  
end

% unsort the pairs so images aren't shown in a specific order
pairs = pairs(randperm(size(pairs,1)),:);

%% Make babies from each pair of parents

% for convenience, parent 1 (column one) is the one that contributes
% most (75%) to the child
children = zeros(size(parents,1), nChild);
for c = 1:nChild
    rents = parents(:,pairs(c,:));
    p1Genes = rand(size(parents,1),1)<p.Results.parent1Contribution;
    children(p1Genes,c) = rents(p1Genes,1);
    children(~p1Genes,c) = rents(~p1Genes,2);
end




