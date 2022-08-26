function velocities = particleVelocities(history)
% returns the length of the step vector for each particle
% velocities is an nParticles by nGenerations-1 matrix
allPoints = cat(3,history.stim{:});
v = diff(allPoints,1,3);
velocities = squeeze(sqrt(sum(v.^2,1)));


