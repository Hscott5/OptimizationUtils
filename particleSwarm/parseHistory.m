function parseHistory(history)



evalin('caller', 'nParticles = size(history.stim{1}, 2);');
evalin('caller', 'nNeurons = size(history.response{1},1);');
evalin('caller', 'nDims = size(history.stim{1},1);');


