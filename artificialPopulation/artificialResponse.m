function [y,xShift] = artificialResponse(pref,tuning,peak, x, withVariance)
% y = artificialResponse(cell, cell, vector)
%    pref: the ith column of pref is the latent vector that evokes the
%    maximum response from the ith neuron
%
%    tuning: a positive definite matrix  that describes
%    the neuron's tuning in the high-D latent space. 3 dimensional array,
%    where the first two dimensions equal the dimensionality of the latent
%    space, so that tuning(:,:,i) is the tuning matrix for the ith neuron
%
%    peak: an N-by-1 vector where the ith element is the maximum firing
%    rate for the ith neuron
%  
%    x: the latent vector to get responses for
%
%    y: vector of response values for each neuron
%
%    withVariance: whether or not to add poisson variability to the
%    responses

% for backwards compatibility
if nargin<5
    withVariance=false;
end

x = x(:);
xShift = x-pref;
for n = 1:size(pref,2) % iterate through neurons
    y(n) = peak(n).*exp(-xShift(:,n)'*tuning(:,:,n)*xShift(:,n));
end

if withVariance
    y = poissrnd(y);
end

