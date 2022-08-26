function mov = makeParticleMovie(history, varargin)

p = inputParser;
addParameter(p, 'imScale', 10)
parse(p, varargin{:});
scale = p.Results.imScale

images = particleMovies(history);
nParticles = size(history.stim{1},2);
nGens = size(history.response,2);
for p = 1:nParticles
    for g = 1:nGens
        rez{p}(:,:,:,g) = imresize(images{p}(:,:,:,g),scale);
    end
end

for p = 1:8
    mov((p-1)*size(rez{1},1)+(1:size(rez{1},1)),:,:,:) = cat(2, rez{(p-1)*8+1:(p-1)*8+8});
end

% v = VideoWriter('simulationMov.avi');
% v.FrameRate = 6;
% open(v)
% writeVideo(v, mov)
% close(v)

