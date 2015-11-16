function wmark_attack_crop(a, wmark_file, att_file, ori_file, ref_file)
% WMARK_ATTACK_CROP Attacks a watermarked video by cropping the frames.
%   WMARK_ATTACK_CROP(a, wmark_file, att_file, ori_file, ref_file) Attack
%     the video named wmark_file and save it with a name passed in att_file.
%   
%   a is the attack level in the range [1..5]. The video name ori_file is
%   simply copied with the name passed in ref_file. The a value controls
%   the size of cropping. a x 5% is cropped on both left and right side.
%   The frame size is left unchanged, the cropping is implemented by setting
%   all pixels values to zero in the 'cropped' area.
   
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
    for f=1:wfin.length
        wframe = io.getframe(wfin);
        oframe = io.getframe(ofin);

        % remove content on both sides, Y
        w = size(wframe.Y, 2)/20*a;
        wframe.Y(:,1:w) = 0;
        wframe.Y(:,end-w:end) = 0;

        % remove content on both sides, U and V
        w = size(wframe.U, 2)/20*a;
        wframe.U(:,1:w) = 0;
        wframe.U(:,end-w:end) = 0;
        wframe.V(:,1:w) = 0;
        wframe.V(:,end-w:end) = 0;
        
        io.putframe(afout, wframe); 
        io.putframe(rfout, oframe); 
        disp( ['frame ' num2str(f) ' written'] );
    end
    io.close(wfin);
    io.close(ofin);
    io.close(afout);
    io.close(rfout);
end