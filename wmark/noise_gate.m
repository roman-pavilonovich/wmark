function map = noise_gate(I, scale)
% NOISE_GATE Computes map of positions enabled for watermarking at a given scale
%   map = NOISE_GATE(I, scale) Compute noise gate map of image I at scale
%
%   This function classifies texture complexity for 2^scale x 2^scale image areas.
%   It applies a canny filter on the result of a range filter, both with default
%   parameters. The resulting map is then dilated and scaled down with a factor of
%   2^scale. Note that the resizing is done with a box filter which gives 1 at a
%   position if the majority of the pixels in the original 2^scale x 2^scale area
%   is 1 (i.e. classified as complex texture).

    r = rangefilt(I);
    e = edge(r, 'canny');
    d = imdilate(e, strel('disk', 2));
    map = imresize(d, 2^-scale, 'box');
end
