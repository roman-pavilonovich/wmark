function result = direct_dwt(I, level)
% DIRECT_DWT Haar type DWT decomposition up to the specified level
%   result = DIRECT_DWT(I, level) Decompose I up to level and store the coefs in result
%
%   result will be an array of structures. an array element represents a decomposition level.
%   result(i).cA is the accumulation matrix, result(i).cH, .cV and .cD store the matrices of 
%   coefficients of wavelets in the horizontal, vertical and diagonal direction, respectively.
%   For example, result(3).cA, .cH, .cV and .cH are often denoted by LL(3), HL(3), LH(3) and
%   HH(3). The size of the coefficient matrices are always halved between decomposition levels.

    A = I;
    for l=1:level
        [result(l).cA, result(l).cH, result(l).cV, result(l).cD] = dwt2(A, 'haar');
        A = result(l).cA;
    end
end
