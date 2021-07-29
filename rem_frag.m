close all;
clear;

% 起始紀錄時間
% st = duration('21:27:15', 'InputFormat', 'hh:mm:ss');
[file, path] = uigetfile('*.mat', 'select file', 'G:\共用雲端硬碟\Sleep center data\REM片斷化');
event = load([path, file]);
stage = load([path, 'stage.dat']);
sl = [1:length(stage)];

figure();
plot(sl, stage);
title('stage');
axis tight;

total_rem_arousal = 0;
for i = 1:length(event.event_name)
    if(string(event.event_stage(i)) == '-1')
        if(string(event.event_name(i)) == 'Arousal 1 ARO RES' || string(event.event_name(i)) == 'Arousal 2 ARO Limb' || string(event.event_name(i)) == 'Arousal 3 ARO SPONT' || string(event.event_name(i)) == 'Arousal 4 ARO PLM')
%             disp(string(event.event_name(i)));
%             disp(string(event.event_epoch(i)));
%             disp(string(event.event_time(i)));
%             if(i ~= length(event.event_name) && string(event.event_stage(i+1)) ~= '-1')
%                 starttime = duration(event.event_time(i), 'InputFormat', 'hh:mm:ss');
%                 disp(seconds(starttime));
%             end
            total_rem_arousal = total_rem_arousal + cell2mat(event.event_duration(i));
        end
    end
end

disp('---------------------');
disp(total_rem_arousal);