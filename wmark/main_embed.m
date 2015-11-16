% --- global settings

% save workspace
save('main_embed.mat');
clear all

% a suitable temporary directory must be set. v210 encoding/decoding uses
% the directory set here. 5-10GB free space might be needed, depending on
% the input/output videos and the number of frames used in the tests.
setenv('temp','e:\tmp');

global FFMPEG
FFMPEG = 'e:\ffmpeg-20150530-git-2e15f07-win64-static\bin\ffmpeg.exe';
global FFPROBE
FFPROBE = 'e:\ffmpeg-20150530-git-2e15f07-win64-static\bin\ffprobe.exe';

% y4m video file IO functions collected into a structure for ease of use
y4m_io = struct(...
    'open', @y4m_open, ...
    'create', @y4m_create, ...
    'close', @y4m_close, ...
    'getframe', @y4m_getframe, ...
    'putframe', @y4m_putframe);

% v210 video file IO functions collected into a structure for ease of use
v210_io = struct(...
    'open', @v210_open, ...
    'create', @v210_create, ...
    'close', @v210_close, ...
    'getframe', @v210_getframe, ...
    'putframe', @v210_putframe);

% --- algorithm parameters

% if one wants to run the program with y4m video files:
% io = y4m_io;
% in_filename = 'e:\yuv\crew_4cif.y4m';
% out_filename = 'e:\yuv\crew_out.y4m';
% ...

% by default v210 video files are used:
io = v210_io;
L_in_filename = 'e:\3dsample\3D_41_LEFT.mov';
R_in_filename = 'e:\3dsample\3D_41_RIGHT.mov';
L_out_filename = 'e:\3dsample\out\3D_41_LEFT.mov';
R_out_filename = 'e:\3dsample\out\3D_41_RIGHT.mov';

% the original watermark image
wmark_filename = 'e:\freelancer\wmark\pavilon-med.jpg';

% the modification strength of the DWT coefficients. 0.1 is suggested
% but other values are accepeted as well. it must be greater than 0, too
% big values (>0.5) might cause visible artifacts on the video and the
% reconstruction might be bad quality (because of pixel values that are
% computed from the strongly changed coefficients might not be represented
% in the 10 bit output sample range).
wmark_str = 0.1;

% DWT subband to use. this is the number of haar wavelet decomposition levels.
% 3 is suggested which means using coeffs in HL3, HH3 and LH3. modified coeffs
% at this scale represent 8x8 image areas. the value must be greater than 0.
% too big values (>3) are not suggested.
dwt_scale = 3;

% --- main

% load grayscale wmark and convert to [0..1] range
wmark_img = imread(wmark_filename);
if size(wmark_img, 3) == 3
    wmark_img = rgb2gray(wmark_img);
end
wmark_img = double(wmark_img)/255;

% embed, let's use 30 frames for the tests
L_fin = io.open(L_in_filename, 30);
R_fin = io.open(R_in_filename, 30);
L_fout = io.create(L_out_filename, L_fin);
R_fout = io.create(R_out_filename, R_fin);
for f=1:L_fin.length

    % choose a watermark part to be embedded in this frame
    wmark = wmark_get_for_frame(wmark_img, f);
    
    % get L/R frames
    L_frame = io.getframe(L_fin);
    R_frame = io.getframe(R_fin);
    
    % MSE-based subimages
    side = find_subimage(L_frame.Y, R_frame.Y, dwt_scale);
    L_subY = L_frame.Y(:, side+1:end);
    R_subY = R_frame.Y(:, 1:end-side);

    % compute and combine noise gate on L/R
    L_ng_map = noise_gate(L_subY, dwt_scale);
    R_ng_map = noise_gate(R_subY, dwt_scale);
    ng_map = L_ng_map | R_ng_map;
    % ng_idx = list of coef positions where noise gate allows embedding
    ng_idx = find(ng_map);

    % L/R_ng_coefs = list of L/R coefs on ng-enabled positions
    % (stored together as V, H, D column vectors)
    L_dwt_coefs = direct_dwt(L_subY, dwt_scale);
    L_ng_coefs = [ ...
        L_dwt_coefs(dwt_scale).cV(ng_idx) ...
        L_dwt_coefs(dwt_scale).cH(ng_idx) ...
        L_dwt_coefs(dwt_scale).cD(ng_idx) ];
    R_dwt_coefs = direct_dwt(R_subY, dwt_scale);
    R_ng_coefs = [ ...
        R_dwt_coefs(dwt_scale).cV(ng_idx) ...
        R_dwt_coefs(dwt_scale).cH(ng_idx) ...
        R_dwt_coefs(dwt_scale).cD(ng_idx) ];

    % choose largest amplitude of V,H,D 
    % lng_idx = index of largest of V,H,D in L/R_ng_coefs
    % L/R_lng_coefs = largest amplitude coefs from L/R_ng_coefs
    [ds_ng_coefs, ds_idx] = sort(min(abs(L_ng_coefs), abs(R_ng_coefs)), 2);
    lng_idx = find(ds_idx == 3);
    L_lng_coefs = L_ng_coefs(lng_idx);
    R_lng_coefs = R_ng_coefs(lng_idx);
    
    % order selected coefs
    [as_lng_coefs, as_lng_idx] = sort(min(abs(L_lng_coefs), abs(R_lng_coefs)), 'descend');
    L_as_lng_coefs = L_lng_coefs(as_lng_idx);
    R_as_lng_coefs = R_lng_coefs(as_lng_idx);

    % make copies of coef lists before modifying (not all elements will be modified,
    % and only modified ones will be copied back, that's why we need initially
    % unmodified 'modified' versions of all coef lists)
    L_ng_mod = L_ng_coefs;
    R_ng_mod = R_ng_coefs;
    L_lng_mod = L_lng_coefs;
    R_lng_mod = R_lng_coefs;

    % embed wmark into amplitude-sorted largest noise-gate enabled coefs
    L_as_lng_mod = embed_wmark(L_as_lng_coefs, wmark, wmark_str);
    R_as_lng_mod = embed_wmark(R_as_lng_coefs, wmark, wmark_str);

    % copy modified part back to list of largest ng-enabled coefs
    L_lng_mod(as_lng_idx) = L_as_lng_mod; 
    R_lng_mod(as_lng_idx) = R_as_lng_mod; 

    % then copy modified part back to list of ng-enabled coefs
    L_ng_mod(lng_idx) = L_lng_mod;
    R_ng_mod(lng_idx) = R_lng_mod;

    % then copy back modified part to all coefs (V,H,D)
    L_dwt_coefs(dwt_scale).cV(ng_idx) = L_ng_mod(:, 1);
    L_dwt_coefs(dwt_scale).cH(ng_idx) = L_ng_mod(:, 2);
    L_dwt_coefs(dwt_scale).cD(ng_idx) = L_ng_mod(:, 3);
    R_dwt_coefs(dwt_scale).cV(ng_idx) = R_ng_mod(:, 1);
    R_dwt_coefs(dwt_scale).cH(ng_idx) = R_ng_mod(:, 2);
    R_dwt_coefs(dwt_scale).cD(ng_idx) = R_ng_mod(:, 3);

    % inverse DWT, measure max changes, put back Y to L/R frame
    Y = inverse_dwt(L_dwt_coefs);
    disp( [ 'l-frame #' num2str(f) ' maxd = ' num2str(max(max(abs(L_subY-Y)))) ] );
    L_subY = Y;
    Y = inverse_dwt(R_dwt_coefs);
    disp( [ 'r-frame #' num2str(f) ' maxd = ' num2str(max(max(abs(R_subY-Y)))) ] );
    R_subY = Y;

    % write back subimages
    L_frame.Y(:, side+1:end) = L_subY;
    R_frame.Y(:, 1:end-side) = R_subY;
    
    % write out L/R frames
    io.putframe(L_fout, L_frame);
    io.putframe(R_fout, R_frame);

end
% close all video files
io.close(L_fin);
io.close(R_fin);
io.close(L_fout);
io.close(R_fout);

% restore workspace
clear all
load('main_embed.mat');
