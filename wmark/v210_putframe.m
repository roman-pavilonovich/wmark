function v210_putframe(fd, frame)
% V210_PUTFRAME Writes a frame into a v210 video file.
%   V210_PUTFRAME(fd, frame) Writes a YUV frame into the file represented by fd.
%
%   fd must be a descriptor returned by V210_CREATE, frame must have Y,U,V fields.
%   This function does not write the frame directly into the v210 video file, instead
%   it writes the frame into a temporary raw video file that will be encoded into
%   the final container format when the video is closed using a call to V210_CLOSE.

    fwrite(fd.fd, uint16(frame.Y'), 'uint16');
    fwrite(fd.fd, uint16(frame.U'), 'uint16');
    fwrite(fd.fd, uint16(frame.V'), 'uint16');
end
