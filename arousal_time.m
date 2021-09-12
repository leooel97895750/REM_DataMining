close all
clear

% 選擇資料夾內任意檔案
[file, path] = uigetfile('*.mat', 'select file', 'G:\共用雲端硬碟\Sleep center data\REM片斷化');
%eeg = load([path, 'edf_data.mat']);
stage = load([path, 'stage.dat']);
event = load([path, 'event.mat']);

st = [1:length(stage)];

% 取出rem 的區段, 紀錄於陣列
remIndex = [];
first = 1;
isBreak = 0;
for i = 1:length(stage)
    if stage(i) == -1  % 當stage為rem時
        if isBreak == 0
            first = i;
            isBreak = 1;
        elseif i == length(st) %當最後一筆資料也是rem時
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

for i = 1:length(remIndex)/2
    idx1 = (remIndex(i*2-1)-1);
    idx2 = (remIndex(i*2)-1);
    
    % 搜尋arousal出現位置
    arousal = zeros(1, 29);
    arousal(5) = 1;
    
    figure();
    N3=arousal==1;
    bar(N3*1,'FaceColor','#0072BD','BarWidth',0.1)
    axis tight;
    ylim([0 1])
    yticklabels({'REM','Arousal'});
end