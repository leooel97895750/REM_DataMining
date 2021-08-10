close all
clear

[file, path] = uigetfile('*.mat', 'select file', 'G:\共用雲端硬碟\Sleep center data\REM片斷化');
stage = load([path, 'stage.dat']);

rem_count = 0;
n3_count = 0;
wake_count = 0;
for i = 1:length(stage)
    if(stage(i) == -1)
        rem_count = rem_count + 1;
    end
    if(stage(i) == 3)
        n3_count = n3_count + 1;
    end
    if(stage(i) == 0)
        wake_count = wake_count + 1;
    end
end