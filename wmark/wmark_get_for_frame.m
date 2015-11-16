function w = wmark_get_for_frame(wmark, f)
% WMARK_GET_FOR_FRAME Computes a watermark part for embedding into a frame
%   w = WMARK_GET_FOR_FRAME(wmark, f) Computes watermark part w from
%   the full watermark image wmark for embedding into frame number f.
%
%   If the watermark image is not fully embedded into each video frame (i.e.
%   it's not a simple frame-by-frame watermarking), then a part of the full
%   watermark image needs to be computed for a given frame. This function cuts
%   the watermark image pixel values into 5 slices and returns a slice for a
%   given frame. The first slice contains the values in [0 .. 0.2], the second 
%   slice represents [0.2 .. 0.4] etc. For example if a pixel have a value of
%   0.43 then in the first slice it's represented with 0.2, in the second slice
%   it's 0.2 again, in the 3rd it's 0.03, in the 4th, 5th slice it's 0.
%
%       ____ 1.0
%                   slice 5
%       ____ 0.8 
%                   slice 4
%       ____ 0.6 
%                   slice 3
%    X  ____ 0.4 
%    X              slice 2
%    X  ____ 0.2
%    X              slice 1
%    X  ____ 0.0  
%   0.43
%
%   The watermark pixel values must be already scaled into [0..1]. The returned
%   watermark part is scaled again so that the values fill the [0..1] range and 
%   will be put into a column vector. Note that these parts can be reconstructed
%   with the WMARK_PUT_FOR_FRAME function from *any* 5 subsequent frames.

    slices = 5;
    w = reshape(wmark, [ size(wmark, 2) * size(wmark,1) 1 ] );
    w = w - ones(size(w)) * mod(f, slices)/slices;
    w = max(zeros(size(w)), w);
    w = min(w, ones(size(w))/slices);
    w = -w * slices;
end
