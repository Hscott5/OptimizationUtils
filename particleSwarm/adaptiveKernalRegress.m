function y = adaptiveKernalRegress(stim1, stim2, varargin)

% stim1 = vector
% stim2 = vector || matrix (history)

    if nargin ==2 
        h = 200;
    else
        h = varargin{1};
    end

    if min(size(stim2))==1 % if its just a single vector
        y = exp(-norm(stim2-stim1)^2/h^2);
    else
        try
            y = exp(-l2Norm(stim2-stim1, 1).^2./h^2);
        catch
            s2 = permute(repmat(stim2, 1,1,size(stim1,2)), [1,3,2]);
            y = exp(-l2Norm(s2-stim1, 1).^2./h^2);
        end
    end

function z = l2Norm(input, dim)
    z = squeeze(sqrt(sum(input.^2,dim)));


