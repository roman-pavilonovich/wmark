function fd = v210_open(filename, max_length)
% V210_OPEN Opens a v210 video file for reading.
%   fd = V210_OPEN(filename) Open the v210 video with filename.
%   fd = V210_OPEN(filename, max_length) Open the v210 video for reading max_length frames.
%
%   It is implemented using ffprobe and ffmpeg. The result is a descriptor which
%   should be passed to V210_GETFRAME and V210_CLOSE functions. The ffprobe tool
%   is used to obtain video properties like frame size and length, and these are
%   stored in the descriptor structure for later use. Always video stream #0 is
%   used. Then the video stream is decoded using ffmpeg and the result is stored
%   in a temporary file which a raw video without any container and 10 bit samples
%   are converted to 16bit (note that there is no quality change here, as this is
%   only a 6bit left-shift operation which is fully reversible). This operation
%   can take some time depending on the length and disk IO speed. A message is
%   printed when the loading starts and ends.
%
%   The global FFPROBE and FFMPEG workspace variables must be set to the full path
%   of the ffprobe and ffmpeg programs, respectively.  

    global FFPROBE
    global FFMPEG
        
    [st, out] = system([ FFPROBE ...
        ' -v error -select_streams v:0' ...
        ' -show_entries stream=width' ...
        ' -show_entries stream=height' ...
        ' -show_entries stream=avg_frame_rate' ...
        ' -show_entries stream=nb_frames' ...
        ' -of default=noprint_wrappers=1:nokey=1' ...
        ' ' filename ]);
    parts = strsplit(out);
    
    fd.mode = 0;
    fd.filename = filename;
    fd.yuvname = tempname;
    fd.width = str2num(parts{1});
    fd.height = str2num(parts{2});
    fd.fps = eval(parts{3});
    fd.length = str2num(parts{4});

    if nargin > 1
        fd.length = min(fd.length, max_length);
    end

    disp( [ 'Loading ' filename '...' ] ); 
    [st, out] = system([ FFMPEG ...
        ' -vcodec v210' ...
        ' -i ' filename ...
        ' -f rawvideo -pix_fmt yuv422p16le' ...
        ' -vframes ' num2str(fd.length) ... 
        ' ' fd.yuvname ] );
    fd.fd = fopen(fd.yuvname, 'r');
    disp( [ 'Loading ' filename ' done.' ] ); 
end
