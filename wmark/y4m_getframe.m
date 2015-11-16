function frame = y4m_getframe(fd)
% Y4M_GETFRAME Reads a frame fom a y4m video file.
%   frame = Y4M_GETFRAME(fd) Reads a YUV frame from the file represented by fd.
%
%   fd must be a descriptor returned by Y4M_OPEN, frame will have Y,U,V fields.
%   No per-frame parameters are supported and 8bit 4:2:0 subsampling is assumed.

    framesize = fd.width*fd.height*3/2;
    fread(fd.fd, 6, 'uchar');
    data = fread(fd.fd, framesize, 'uchar');
      
    width_h = fd.width/2;
    height_h = fd.height/2;

    Y = data(1:fd.width * fd.height);
    frame.Y = reshape(Y, fd.width, fd.height)';
    
    offset = fd.width*fd.height + 1;
    U = data(offset:offset+(width_h * height_h)-1);
    frame.U = reshape(U, width_h, height_h)';
    
    offset = offset + (width_h * height_h);
    V = data(offset:offset+(width_h * height_h)-1);
    frame.V = reshape(V, width_h, height_h)';
end
