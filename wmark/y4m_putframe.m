function y4m_putframe(fd, frame)
% Y4M_PUTFRAME Writes a frame into a y4m video file.
%   Y4M_PUTFRAME(fd, frame) Writes a YUV frame into the file represented by fd.
%
%   fd must be a descriptor returned by Y4M_CREATE, frame must have Y,U,V fields.

    fprintf(fd.fd, 'FRAME\n');      
    fwrite(fd.fd, frame.Y', 'uchar');
    fwrite(fd.fd, frame.U', 'uchar');
    fwrite(fd.fd, frame.V', 'uchar');
end
