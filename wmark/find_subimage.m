function side = find_subimage(lY, rY, scale, lU, rU, lV, rV)
% FIND_SUBIMAGE Finds similar common subimages of the views, based on MSE.
%   side = FIND_SUBIMAGE(lY, rY, scale) Compare Y planes at the given scale
%   side = FIND_SUBIMAGE(lY, rY, scale, lU, rU, lV, rV) Also use chroma (U,V)
%   
%   Finds the width that must be ignored on the left side of the left view (lY)
%   and the right side of the right view (lY), in order to get the minimal MSE
%   difference between the remaining parts. Then the remaining right part of the
%   left view and the remaining left part of right view are considered common
%   subimages. This width is returned. Since the views are first scaled down
%   with the factor of 2^scale, the returned with will be a multiple of 2^scale.

    s_lY = imresize(lY, 2^-scale, 'box');
    s_rY = imresize(rY, size(s_lY), 'box');
    
    if nargin > 3
        s_lU = imresize(lU, size(s_lY), 'box');
        s_rU = imresize(rU, size(s_lY), 'box');
        s_lV = imresize(lV, size(s_lY), 'box');
        s_rV = imresize(rV, size(s_lY), 'box');
    else
        s_lU = zeros(size(s_lY));
        s_rU = zeros(size(s_lY));
        s_lV = zeros(size(s_lY));
        s_rV = zeros(size(s_lY));
    end
    
    [h w] = size(s_lY);
    for side=0:w/8
        lsub = [ s_lY(:, side+1:w) s_lU(:, side+1:w) s_lV(:, side+1:w) ];
        rsub = [ s_rY(:, 1:w-side) s_rU(:, 1:w-side) s_rV(:, 1:w-side) ];
        mse(side+1) = sum(sum(sum((lsub-rsub).^2))) / ((w-side)*h);
    end
    
    [min_mse, best_side] = min(mse);
    side = (best_side-1) * 2^scale;
end
