function I = inverse_dwt(coefs)
% INVERSE_DWT Haar type inverse DWT transform of a previous DWT result
%   I = INVERSE_DWT(coefs) Compute image I from the DWT coefficients in coef
%
%   coefs must have the same format as described for the result of DIRECT_DWT.
%   The typical use of this function is to call DIRECT_DWT first, optionally
%   modify some coefficients in the resulting array of structures, then call
%   this INVERSE_DWT function with the array of structures.

    level = size(coefs, 2);
    I = coefs(level).cA;
    for l=level:-1:1
        coefs(l).cA = I;
        I = idwt2(coefs(l).cA, coefs(l).cH, coefs(l).cV, coefs(l).cD, 'haar');
    end
end
