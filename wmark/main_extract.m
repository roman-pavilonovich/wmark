% --- global settings

% save workspace
save('main_extract.mat');
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
L_in_filename = 'e:\3dsample\out\3D_41_LEFT_attack_ref.mov';
R_in_filename = 'e:\3dsample\out\3D_41_RIGHT_attack_ref.mov';
L_out_filename = 'e:\3dsample\out\3D_41_LEFT_attacked.mov';
R_out_filename = 'e:\3dsample\out\3D_41_RIGHT_attacked.mov';

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

% prepare for measurement of reconstructed quality
recon_quality = [];

% load grayscale wmark and convert to [0..1] range
wmark_img = imread(wmark_filename);
if size(wmark_img, 3) == 3
    wmark_img = rgb2gray(wmark_img);
end
wmark_img = double(wmark_img)/255;

% extract,  let's use 5 frames for the tests
L_fin = io.open(L_in_filename, 5);
R_fin = io.open(R_in_filename, 5);
L_fout = io.open(L_out_filename, 5);
R_fout = io.open(R_out_filename, 5);
for f=1:L_fin.length
    
    % get original and wmarked L/R frames
    L_frame = io.getframe(L_fin);
    R_frame = io.getframe(R_fin);
    LW_frame = io.getframe(L_fout);
    RW_frame = io.getframe(R_fout);
    
    % compute and combine noise gate on L/R
    L_ng_map = noise_gate(L_frame.Y, dwt_scale);
    R_ng_map = noise_gate(R_frame.Y, dwt_scale);
    ng_map = L_ng_map | R_ng_map;
    % ng_idx = list of coef positions where noise gate allows embedding
    ng_idx = find(ng_map);
    
    % L/R_ng_coefs = list of L/R coefs on ng-enabled positions
    % (stored together as V, H, D column vectors)
    L_dwt_coefs = direct_dwt(L_frame.Y, dwt_scale);
    L_ng_coefs = [ ...
        L_dwt_coefs(dwt_scale).cV(ng_idx) ...
        L_dwt_coefs(dwt_scale).cH(ng_idx) ...
        L_dwt_coefs(dwt_scale).cD(ng_idx) ];
    R_dwt_coefs = direct_dwt(R_frame.Y, dwt_scale);
    R_ng_coefs = [ ...
        R_dwt_coefs(dwt_scale).cV(ng_idx) ...
        R_dwt_coefs(dwt_scale).cH(ng_idx) ...
        R_dwt_coefs(dwt_scale).cD(ng_idx) ];

    % choose largest amplitude of V,H,D 
    % lng_idx = index of largest of V,H,D in L/R_ng_coefs
    % L/R_lng_coefs = largest amplitude coefs from L/R_ng_coefs
    [ds_ng_coefs, ds_idx] = sort(min(abs(L_ng_coefs), abs(R_ng_coefs)), 2); % min???
    lng_idx = find(ds_idx == 3);
    L_lng_coefs = L_ng_coefs(lng_idx);
    R_lng_coefs = R_ng_coefs(lng_idx);
    
    % order selected coefs
    [as_lng_coefs, as_lng_idx] = sort(min(abs(L_lng_coefs), abs(R_lng_coefs)), 'descend'); % min???
    L_as_lng_coefs = L_lng_coefs(as_lng_idx);
    R_as_lng_coefs = R_lng_coefs(as_lng_idx);

    % same for L/R wmarked frames but do not recompute indices
    
    % L/R_ng_coefs = list of L/R coefs on ng-enabled positions
    % (stored together as V, H, D column vectors)
    LW_dwt_coefs = direct_dwt(LW_frame.Y, dwt_scale);
    LW_ng_coefs = [ ...
        LW_dwt_coefs(dwt_scale).cV(ng_idx) ...
        LW_dwt_coefs(dwt_scale).cH(ng_idx) ...
        LW_dwt_coefs(dwt_scale).cD(ng_idx) ];
    RW_dwt_coefs = direct_dwt(RW_frame.Y, dwt_scale);
    RW_ng_coefs = [ ...
        RW_dwt_coefs(dwt_scale).cV(ng_idx) ...
        RW_dwt_coefs(dwt_scale).cH(ng_idx) ...
        RW_dwt_coefs(dwt_scale).cD(ng_idx) ];

    % choose largest amplitude of V,H,D 
    % lng_idx = index of largest of V,H,D in L/R_ng_coefs
    % L/R_lng_coefs = largest amplitude coefs from L/R_ng_coefs
    LW_lng_coefs = LW_ng_coefs(lng_idx);
    RW_lng_coefs = RW_ng_coefs(lng_idx);
    
    % order selected coefs
    LW_as_lng_coefs = LW_lng_coefs(as_lng_idx);
    RW_as_lng_coefs = RW_lng_coefs(as_lng_idx);
    
    % extract L/R wmark parts and obtain the so-far accumulated final watermark image
    w = extract_wmark(LW_as_lng_coefs, L_as_lng_coefs, wmark_str);
    L_rwmark = wmark_put_for_frame(w, size(wmark_img), f, 1);
    w = extract_wmark(RW_as_lng_coefs, R_as_lng_coefs, wmark_str);
    R_rwmark = wmark_put_for_frame(w, size(wmark_img), f, 2);

    % show reconstructed wmark
    % figure;
    % subplot(1,3,1); imshow(wmark_img);
    % subplot(1,3,2); imshow(L_rwmark);
    % subplot(1,3,3); imshow(R_rwmark);
    
    % measure correlation with the original watermark
    recon_quality = [recon_quality; corr2(L_rwmark, wmark_img) corr2(R_rwmark, wmark_img)]; 
    disp( [ 'quality for frame #' num2str(f) ' L: ' num2str(recon_quality(end,1)) ' R: ' num2str(recon_quality(end,2)) ] ); 
end
% close all video files
io.close(L_fin);
io.close(R_fin);
io.close(L_fout);
io.close(R_fout);

% restore workspace, except recon_quality
save('recon_quality.mat', 'recon_quality');
clear all
load('main_extract.mat');
load('recon_quality.mat', 'recon_quality');