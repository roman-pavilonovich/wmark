function w = extract_wmark(Iw, I, strength)
% EXTRACT_WMARK Extracts a watermark vector from carrier vectors using a given strength
%   w = EXTRACT_WMARK(Iw, I, strength) Extracts watermark w that was embedded with 
%   strength, from the original carrier vector I and the modified carrier vector Iw.
%
%   The length of the extracted wmark will be the shortest of length of I and length of
%   Iw. Usually the lengths will be the same since I and Iw are constructed with the same
%   computation from the original and watermarked data.

    % wmark length
    len = min(size(Iw, 1), size(I, 1));
    
    w = zeros(len, 1);
    w(1:len) = (1/strength) * (Iw(1:len) ./ I(1:len) - 1);

end
