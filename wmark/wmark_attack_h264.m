function wmark_attack_h264(a, wmark_file, att_file, ori_file, ref_file)
% WMARK_ATTACK_H264 Attacks a watermarked video by H264 compression.
%   WMARK_ATTACK_H264(a, wmark_file, att_file, ori_file, ref_file) Compress
%     the video named wmark_file and save it with a name passed in att_file.
%   
%   a is the attack level in the range [1..5]. The video name ori_file is
%   simply copied with the name passed in ref_file. The a value controls
%   the QP value of the H264 codec. Bit depth and 4:2:2 subsampling is kept.
   
    global FFMPEG
    tmpname = [tempname '.avi'];
    
    disp([ 'Encoding ' wmark_file ' to h264 file: ' tmpname ]);
    [st, out] = system([ FFMPEG ...
        ' -i ' wmark_file ...
        ' -y -c libx264 -pix_fmt yuv422p10le' ...
        ' -crf ' num2str(a*3) ...
        ' ' tmpname ]);
    disp('Encoding done');
    
    disp([ 'Decoding h264 file ' tmpname ' to ' att_file ]);
    [st, out] = system([ FFMPEG ...
        ' -i ' tmpname ...
        ' -y -c v210' ...
        ' ' att_file]);
    disp('Decoding done');
    
    copyfile(ori_file, ref_file);
    delete(tmpname);
end