function plotParticleVelocities(history)

points = cat(3,history.stim{:});
difference = diff(points,1,3);
velocities = squeeze(sqrt(sum(difference.^2,1)));
figure;
plot(velocities')






