function [y,xShift] = dev_artificialResponse(pref,tuning,peak, x)
% y = artificialResponse(cell, cell, vector)
%    pref: the ith column of pref is the latent vector that evokes the
%    maximum response from the ith neuron
%
%    tuning: a positive definite matrix (like a covariance) that describes
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

x = x(:);

xShift = x-pref;

for n = 1:size(pref,2)
    y(n) = peak(n).*exp(-xShift(:,n)'*tuning(:,:,n)*xShift(:,n));
end

% exp((-0.5*(x-mo)'*sig^-1*(x-mo))./10.^3)./sqrt(((2.*pi).^(size(x,1)./100)).*det(sig))*10.^9;








