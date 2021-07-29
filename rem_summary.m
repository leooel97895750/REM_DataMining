close all;
clear;

% 選擇資料夾內任意檔案
[file, path] = uigetfile('*.mat', 'select file', 'G:\共用雲端硬碟\Sleep center data\REM片斷化');
eeg = load([path, 'edf_data.mat']);
stage = load([path, 'stage.dat']);
event = load([path, 'event.mat']);

% 取出訊號資料
c1 = eeg.data(1,:); % c3c4
c2 = eeg.data(2,:); % o1o2
c3 = eeg.data(3,:); % f3f4
e1 = eeg.data(4,:); % 眼動
e2 = eeg.data(5,:); % 眼動

% sampling rate
fs = 256;
slen = length(e1);
et = [1:slen]/fs;
st = [1:length(stage)];

% 整體眼動與階段圖
figure(1);
subplot(3,1,1), plot(et, e1);
xlim([1 30]);
title('channel4 眼動');
subplot(3,1,2), plot(et, e2);
xlim([1 30]);
title('channel5 眼動');
subplot(3,1,3), plot(st, stage);
xlim([1 30]);
title('stage');

% 取出rem 的區段, 紀錄於陣列
remIndex = [];
first = 1;
isBreak = 0;
for i = 1:length(stage)
    if stage(i) == -1  % 當stage為rem時
        disp(i);
        if isBreak == 0
            first = i;
            isBreak = 1;
        elseif i == length(sl) %當最後一筆資料也是rem時
            remIndex(end+1) = first;
            remIndex(end+1) = i;
        end
        isBreak = 1;
    else
        if isBreak == 1
            remIndex(end+1) = first;
            remIndex(end+1) = i;
        end
        isBreak = 0;
    end
end
clear first i isBreak;
