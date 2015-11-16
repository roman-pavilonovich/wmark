function y4m_close(fd)
% Y4M_CLOSE Closes a y4m video file.
%   Y4M_CLOSE(fd) Close the video file described by fd.
%
%   The fd must be a descriptor returned by Y4M_CREATE or Y4M_OPEN. That is,
%   this function must be used to close all y4m video files, both opened for
%   reading and writing.

    fclose(fd.fd);
end
