function Iw = embed_wmark(I, w, strength)
% EMBED_WMARK Embeds a watermark vector into a carrier vector using a given strength
%   Iw = EMBED_WMARK(I, w, strength) Embed watermark w into carrier I with strength
%
%   Both the carrier I and the watermark w are column vectors of values. The actual
%   length of modification will be the shortest of length of I and length of w. If
%   the watermark is shorter, some carrier values will be unmodified. If the carrier
%   is shorter, some watermark values (the last ones) will not be embedded.
        
    % embedding length: shortest
    len = min(size(I, 1), size(w, 1));
    
    Iw = I;
    Iw(1:len) = I(1:len) .* ( w(1:len) * strength + 1); 
    
end
