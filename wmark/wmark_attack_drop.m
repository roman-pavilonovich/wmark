function wmark_attack_drop(a, wmark_file, att_file, ori_file, ref_file)
% WMARK_ATTACK_DROP Attacks a watermarked video frame dropping.
%   WMARK_ATTACK_DROP(a, wmark_file, att_file, ori_file, ref_file) Drop some
%     frames fro the video named wmark_file and save it with a name passed
%     in att_file.
%   
%   a is the attack level in the range [1..5]. The video name ori_file is
%   modified the same way and saved with the name passed in ref_file.
%   The a value controls the number of dropped frames. 1: keep 1 frame,
%   drop 1 frame. 2: keep 1 frame then drop 2 frames, 3: keep 1 frame then
%   drop 3 frames, etc.
     
    io = struct(...
        'open', @v210_open, ...
        'create', @v210_create, ...
        'close', @v210_close, ...
        'getframe', @v210_getframe, ...
        'putframe', @v210_putframe);

    wfin = io.open(wmark_file, 30);
    ofin = io.open(ori_file, 30);
    afout = io.create(att_file, wfin);
    rfout = io.create(ref_file, ofin);
    dropped = 0;
    for f=1:wfin.length
        % read and drop frames until drop-counter reaches the passed value
        wframe = io.getframe(wfin);
        oframe = io.getframe(ofin);
        if dropped < a
            dropped = dropped+1;
            disp( ['frame ' num2str(f) ' dropped (' num2str(dropped) '/' num2str(a) ')' ] );
            continue;
        end
        % we dropped enough frames, now let's write out one frame and
        % restart the drop-counter
        io.putframe(afout, wframe); 
        io.putframe(rfout, oframe); 
        disp( ['frame ' num2str(f) ' written'] );
        dropped = 0;
    end
    io.close(wfin);
    io.close(ofin);
    io.close(afout);
    io.close(rfout);
end