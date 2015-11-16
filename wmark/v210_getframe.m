function frame = v210_getframe(fd)
% V210_GETFRAME Reads a frame from a V210 video file.
%   frame = V210_GETFRAME(fd) Reads a YUV frame from the file represented by fd.
%
%   fd must be a descriptor returned by V210_OPEN, frame will have Y,U,V fields.
%   This function reads a frame from the temporary raw video file that is generated
%   by the previous call to V210_OPEN, and not from the original v210 video. The
%   returned frame will have Y,U,V fields, all are matrices of 16bit samples.

    Y = fread(fd.fd, [fd.width fd.height], 'uint16');
    frame.Y = Y';
    U = fread(fd.fd, [fd.width/2 fd.height], 'uint16');
    frame.U = U';
    V = fread(fd.fd, [fd.width/2 fd.height], 'uint16');
    frame.V = V';
end
