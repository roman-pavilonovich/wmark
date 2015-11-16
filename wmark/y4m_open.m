function fd = y4m_open(filename)
% Y4M_OPEN Opens a y4m video file for reading.
%   fd = Y4M_OPEN(filename) Open the y4m video with filename.
%
%   Only 8bit 4:2:0 subsampling is supported. The result is a descriptor which
%   should be passed to Y4M_GETFRAME and Y4M_CLOSE functions.

    filep = dir(filename); 
    filesize = filep.bytes;    
	fd.fd = fopen(filename, 'r');
	[hdrstr, hdrsize] = textscan(fd.fd, '%s', 1, 'delimiter', '\n');
    parts = strsplit(char(hdrstr{1}), ' ');

    assert(strcmp(parts{1}, 'YUV4MPEG2'), 'not a y4m file');
	width = textscan(parts{2}, 'W%d');
	height = textscan(parts{3}, 'H%d');
	fpsval = textscan(parts{4}, 'F%d:%d');
	interlacing = textscan(parts{5}, 'I%c');
	arval = textscan(parts{6}, 'A%d:%d');
    cspace = cell(1);
    cspace{1} = 420;
    if size(parts,2) > 6 && strfind(parts{7}, 'C')
        cspace = textscan(parts{7}, 'C%d');
    end
    assert(cspace{1} == 420, 'unsupported subsampling');
    
    framesize = (width{1} * height{1} * 3) / 2;
    nframes = (filesize - hdrsize)/(6 + framesize);
    
    fd.width = width{1};
    fd.height = height{1};
    fd.length = nframes;
    fd.fpsval1 = fpsval{1};
    fd.fpsval2 = fpsval{2};
    fd.interlacing = interlacing{1};
    fd.arval1 = arval{1};
    fd.arval2 = arval{2};
    fd.cspace = cspace{1};
    fd.framesize = framesize;
end
