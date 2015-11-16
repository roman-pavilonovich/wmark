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

% --- main

fin(1) = io.open(l_in_filename);
fin(2) = io.open(r_in_filename);

for f=1:1
    frame(1) = io.getframe(fin(1));
    frame(2) = io.getframe(fin(2));
    
    %{
    sh = 120;
    w = size(frame(1).Y, 2);
    frame(2).Y(:,1:w-sh) = frame(1).Y(:,sh+1:w);
    %}
    
    shift = find_subimage(frame(1).Y/65535, frame(2).Y/65535, 1);
end

io.close(fin(1));
io.close(fin(2));

