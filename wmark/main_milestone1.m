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
l_in_filename = 'e:\3dsample\3D_41_LEFT.mov';
r_in_filename = 'e:\3dsample\3D_41_RIGHT.mov';
l_out_filename = 'e:\3dsample\out\3D_41_LEFT.mov';
r_out_filename = 'e:\3dsample\out\3D_41_RIGHT.mov';

wmark_filename = 'e:\freelancer\wmark\pavilon-med.jpg';
wmark_str = .1;
dwt_scale = 3;

% --- main

% prepare wmark
wmark_img = imread(wmark_filename);
if size(wmark_img, 3) == 3
    wmark_g = double(rgb2gray(wmark_img))/255;
else
    wmark_g = double(wmark_img)/255;
end
wmark = reshape(wmark_g, [ size(wmark_g, 2) * size(wmark_g,1) 1 ] );

% embed
fin(1) = io.open(l_in_filename);
fin(2) = io.open(r_in_filename);
fout(1) = io.create(l_out_filename, fin(1));
fout(2) = io.create(r_out_filename, fin(2));
for f=1:10 % <- first 10 frames for now, change to fin(1).length for full length
    for v=1:2
        frame = io.getframe(fin(v));

        ng_map = noise_gate(frame.Y, dwt_scale);
        ng_idx = find(ng_map);
        dwt_coefs = direct_dwt(frame.Y, dwt_scale);
        ng_coefs = [ ...
            dwt_coefs(dwt_scale).cV(ng_idx) ...
            dwt_coefs(dwt_scale).cH(ng_idx) ...
            dwt_coefs(dwt_scale).cD(ng_idx) ];

        [ds_ng_coefs, ds_idx] = sort(abs(ng_coefs), 2);
        l_ng_coefs_idx = find(ds_idx == 3);
        l_ng_coefs = ng_coefs(l_ng_coefs_idx);
        [as_l_ng_coefs, as_idx] = sort(l_ng_coefs);

        modified = ng_coefs;
        l_ng_modified = l_ng_coefs;
        as_l_ng_modified = embed_wmark(as_l_ng_coefs, wmark, wmark_str);
        l_ng_modified(as_idx) = as_l_ng_modified; 
        modified(l_ng_coefs_idx) = l_ng_modified;

        dwt_coefs(dwt_scale).cV(ng_idx) = modified(:, 1);
        dwt_coefs(dwt_scale).cH(ng_idx) = modified(:, 2);
        dwt_coefs(dwt_scale).cD(ng_idx) = modified(:, 3);

        Y = inverse_dwt(dwt_coefs);
        disp( [ 'frame #' num2str(f) ' maxd = ' num2str(max(max(abs(frame.Y-Y)))) ] );
        frame.Y = Y;

        io.putframe(fout(v), frame);
    end    
end
io.close(fin(1));
io.close(fin(2));
io.close(fout(1));
io.close(fout(2));

