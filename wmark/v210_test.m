

global FFMPEG
FFMPEG = 'e:\ffmpeg-20150530-git-2e15f07-win64-static\bin\ffmpeg.exe';
global FFPROBE
FFPROBE = 'e:\ffmpeg-20150530-git-2e15f07-win64-static\bin\ffprobe.exe';

infn = 'e:\yuv\coff3.mov';
outfn = 'e:\yuv\coff3_out.mov';

in = v210_open(infn);
out = v210_create(outfn, in);

for i=1:in.length
    frame = v210_getframe(in);
    v210_putframe(out, frame);
end

v210_close(in);
v210_close(out);