function mov = particleMovies(history)
% history is a structure created from particleSwarm.m used for
% adaptive stimulus selection
nParticles = size(history.stim{1},2);
allStim = cat(3,history.stim{:});


allIms = send2py(struct('type', 'movie','frames',cat(2,history.stim{:}) ));

for g = 1:size(history.response,2)
    mov{g} = allIms( ((g-1)*nParticles+1):g*nParticles );
end
