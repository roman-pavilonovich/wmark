function fd = v210_create(filename, hdr)
% V210_CREATE Creates a v210 video file for writing.
%   fd = V210_CREATE(filename, hdr) Create a v210 video with filename with properties
%   decribed in hdr.
%
%   The hdr parameter is a structure that is returned by a call to V210_OPEN. The
%   typical use of this function is to open a video file with V210_OPEN, and pass
%   the descriptor that is returned to another call to V210_CREATE, in order to
%   create a video file with exactly the same properties (expect the filename).
%   Note that this function will not create the final output file, instead it
%   creates a temporary raw video file which will be encoded when the file is 
%   closed using a call to V210_CLOSE.

    fd.filename = filename;
    fd.yuvname = tempname;
    fd.width = hdr.width;
    fd.height = hdr.height;
    fd.fps = hdr.fps;
    fd.mode = 1;
    
    fd.fd = fopen(fd.yuvname, 'w');
end
