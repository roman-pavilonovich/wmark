
% a suitable temporary directory must be set. v210 encoding/decoding uses
% the directory set here. 5-10GB free space might be needed, depending on
% the input/output videos and the number of frames used in the tests.
setenv('temp','e:\tmp');

% the FFPMPEG library is also used by some attacks
global FFMPEG
FFMPEG = 'e:\ffmpeg-20150530-git-2e15f07-win64-static\bin\ffmpeg.exe';
global FFPROBE
FFPROBE = 'e:\ffmpeg-20150530-git-2e15f07-win64-static\bin\ffprobe.exe';

% as these filenames are hard-coded in main_embed and main_extract
% change these values together with those

% input
L_in_filename = 'e:\3dsample\3D_41_LEFT.mov';
R_in_filename = 'e:\3dsample\3D_41_RIGHT.mov';

% wmarked
L_out_filename = 'e:\3dsample\out\3D_41_LEFT.mov';
R_out_filename = 'e:\3dsample\out\3D_41_RIGHT.mov';

% attacked
L_att_filename = 'e:\3dsample\out\3D_41_LEFT_attacked.mov';
R_att_filename = 'e:\3dsample\out\3D_41_RIGHT_attacked.mov';

% reference
L_ref_filename = 'e:\3dsample\out\3D_41_LEFT_attack_ref.mov';
R_ref_filename = 'e:\3dsample\out\3D_41_RIGHT_attack_ref.mov';


% we choose the attacking function here: compress / drop / crop frames
% attack_fn = @wmark_attack_h264;
% attack_fn = @wmark_attack_drop;
attack_fn = @wmark_attack_crop;

% if we already have the wmarked vide file, we can skip embedding
% main_embed

% let's generate "attacked" files, but no attack first, just copy, for reference
copyfile(L_out_filename, L_att_filename);
copyfile(R_out_filename, R_att_filename);
copyfile(L_in_filename, L_ref_filename);
copyfile(R_in_filename, R_ref_filename);

% extract
main_extract

% these copies are no longer needed
delete(L_att_filename);
delete(R_att_filename);
delete(L_ref_filename);
delete(R_ref_filename);

% save reference quality
all_quality{1} = recon_quality;

% now the real attacks, 5 different levels
for attack=1:5

    % attack the wmarked videos using the chosen attacking function
    attack_fn(attack, L_out_filename, L_att_filename, L_in_filename, L_ref_filename);
    attack_fn(attack, R_out_filename, R_att_filename, R_in_filename, R_ref_filename);

    % try to extract wmark
    main_extract

    % attacked and reference videos are no longer needed
    delete(L_att_filename);
    delete(R_att_filename);
    delete(L_ref_filename);
    delete(R_ref_filename);

    % add new quality data
    all_quality{attack+1} = recon_quality;

end
