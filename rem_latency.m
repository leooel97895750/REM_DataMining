close all;
clear;

[file, path] = uigetfile('*.mat', 'select file', 'G:\共用雲端硬碟\Sleep center data\REM片斷化');
stage = load([path, 'stage.dat']);
sl = [1:length(stage)];

rem_lat = 0;
for i = 1:length(stage)
    if(stage(i) == -1)
        rem_lat = i*30;
        break;
    end
end

disp(rem_lat);