% --- global settings

clear all
setenv('temp','e:\tmp');

global FFMPEG
FFMPEG = 'e:\ffmpeg-20150530-git-2e15f07-win64-static\bin\ffmpeg.exe';
global FFPROBE
FFPROBE = 'e:\ffmpeg-20150530-git-2e15f07-win64-static\bin\ffprobe.exe';

y4m_io = struct(...
    'open', @y4m_open, ...
    'create', @y4m_create, ...
    'close', @y4m_close, ...
    'getframe', @y4m_getframe, ...
    'putframe', @y4m_putframe);
v210_io = struct(...
    'open', @v210_open, ...
    'create', @v210_create, ...
    'close', @v210_close, ...
    'getframe', @v210_getframe, ...
    'putframe', @v210_putframe);

% --- algorithm parameters

% io = y4m_io;
% in_filename = 'e:\yuv\crew_4cif.y4m';
% out_filename = 'e:\yuv\crew_out.y4m';

io = v210_io;
L_in_filename = 'e:\3dsample\3D_41_LEFT.mov';
R_in_filename = 'e:\3dsample\3D_41_RIGHT.mov';
L_out_filename = 'e:\3dsample\out\3D_41_LEFT.mov';
R_out_filename = 'e:\3dsample\out\3D_41_RIGHT.mov';

wmark_filename = 'e:\freelancer\wmark\pavilon-med.jpg';
wmark_str = .1;
dwt_scale = 3;

% --- main

wmark_img = imread(wmark_filename);
if size(wmark_img, 3) == 3
    wmark_img = rgb2gray(wmark_img);
end
wmark_img = double(wmark_img)/255;

% embed
L_fin = io.open(L_in_filename, 10);
R_fin = io.open(R_in_filename, 10);
L_fout = io.create(L_out_filename, L_fin);
R_fout = io.create(R_out_filename, R_fin);
for f=1:L_fin.length

    wmark = wmark_get_for_frame(wmark_img, f);
    
    L_frame = io.getframe(L_fin);
    R_frame = io.getframe(R_fin);

    side = find_subimage(L_frame.Y, R_frame.Y, dwt_scale);
    L_subY = L_frame.Y(:, side+1:end);
    R_subY = R_frame.Y(:, 1:end-side);

    L_ng_map = noise_gate(L_subY, dwt_scale);
    R_ng_map = noise_gate(R_subY, dwt_scale);
    ng_map = L_ng_map | R_ng_map;
    ng_idx = find(ng_map);

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

    [ds_ng_coefs, ds_idx] = sort(min(abs(L_ng_coefs), abs(R_ng_coefs)), 2);
    lng_idx = find(ds_idx == 3);
    L_lng_coefs = L_ng_coefs(lng_idx);
    R_lng_coefs = R_ng_coefs(lng_idx);
    
    [as_lng_coefs, as_lng_idx] = sort(min(abs(L_lng_coefs), abs(R_lng_coefs)), 'descend');
    L_as_lng_coefs = L_lng_coefs(as_lng_idx);
    R_as_lng_coefs = R_lng_coefs(as_lng_idx);

    L_ng_mod = L_ng_coefs;
    R_ng_mod = R_ng_coefs;
    L_lng_mod = L_lng_coefs;
    R_lng_mod = R_lng_coefs;

    L_as_lng_mod = embed_wmark(L_as_lng_coefs, wmark, wmark_str);
    R_as_lng_mod = embed_wmark(R_as_lng_coefs, wmark, wmark_str);

    L_lng_mod(as_lng_idx) = L_as_lng_mod; 
    R_lng_mod(as_lng_idx) = R_as_lng_mod; 

    L_ng_mod(lng_idx) = L_lng_mod;
    R_ng_mod(lng_idx) = R_lng_mod;

    L_dwt_coefs(dwt_scale).cV(ng_idx) = L_ng_mod(:, 1);
    L_dwt_coefs(dwt_scale).cH(ng_idx) = L_ng_mod(:, 2);
    L_dwt_coefs(dwt_scale).cD(ng_idx) = L_ng_mod(:, 3);
    R_dwt_coefs(dwt_scale).cV(ng_idx) = R_ng_mod(:, 1);
    R_dwt_coefs(dwt_scale).cH(ng_idx) = R_ng_mod(:, 2);
    R_dwt_coefs(dwt_scale).cD(ng_idx) = R_ng_mod(:, 3);

    Y = inverse_dwt(L_dwt_coefs);
    disp( [ 'l-frame #' num2str(f) ' maxd = ' num2str(max(max(abs(L_subY-Y)))) ] );
    L_subY = Y;
    Y = inverse_dwt(R_dwt_coefs);
    disp( [ 'r-frame #' num2str(f) ' maxd = ' num2str(max(max(abs(R_subY-Y)))) ] );
    R_subY = Y;

    L_frame.Y(:, side+1:end) = L_subY;
    R_frame.Y(:, 1:end-side) = R_subY;
    
    io.putframe(L_fout, L_frame);
    io.putframe(R_fout, R_frame);

end
io.close(L_fin);
io.close(R_fin);
io.close(L_fout);
io.close(R_fout);
