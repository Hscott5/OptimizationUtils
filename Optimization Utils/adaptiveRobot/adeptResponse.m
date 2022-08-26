function response = adeptResponse(stims, latents, responses)


stims = stims';
dists = pdist2(latents,stims);
[closestIndx, ~] = find(dists==min(dists));
response = responses(closestIndx,:)';


