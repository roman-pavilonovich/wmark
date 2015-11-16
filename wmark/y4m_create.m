function fd = y4m_create(filename, hdr)
% Y4M_CREATE Creates a y4m video file for writing.
%   fd = Y4M_CREATE(filename, hdr) Create an y4m video with filename with properties
%   decribed in hdr.
%
%   The hdr parameter is a structure that is returned by a call to Y4M_OPEN. The
%   typical use of this function is to open a video file with Y4M_OPEN, and pass
%   the descriptor that is returned to another call to Y4M_CREATE, in order to
%   create a video file with exactly the same properties (expect the filename).

    fd.fd = fopen(filename, 'w');
    fd.width = hdr.width;
    fd.height = hdr.height;
    
    fprintf(fd.fd, '%s ', 'YUV4MPEG2');
    fprintf(fd.fd, 'W%d ', hdr.width);
    fprintf(fd.fd, 'H%d ', hdr.height);
    fprintf(fd.fd, 'F%d:%d ', hdr.fpsval1, hdr.fpsval2);
	fprintf(fd.fd, 'I%c ', hdr.interlacing);
    fprintf(fd.fd, 'A%d:%d ', hdr.arval1, hdr.arval2);
    fprintf(fd.fd, 'C%d ', hdr.cspace);
    fprintf(fd.fd, '\n');
end
