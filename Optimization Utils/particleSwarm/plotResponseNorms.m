function plotResponseNorms(history)

responses = history.response;
norms = cellfun(@(x) sqrt(sum(x.^2,1)), responses, 'UniformOutput', false);
norms = cat(1,norms{:});
figure
plot(norms);
xlabel('Generation');
ylabel('Response Norm');
