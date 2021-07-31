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
fs = 200;
slen = length(e1);
et = [1:slen]/fs;
st = [1:length(stage)];

% 約略計算sampling rate
per30 = length(e1) / length(stage);
afs = per30 / 30;

% 整體眼動與階段圖
figure(1);
subplot(3,1,1), plot(et, e1);
title('channel4 眼動');
subplot(3,1,2), plot(et, e2);
title('channel5 眼動');
subplot(3,1,3), plot(st, stage);
axis tight;
title('stage');

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

% 計算rem總次數、總時間、平均時間
remNumber = 0;
totalRemDuration = 0;
for i = 1:length(remIndex)/2
    remNumber = remNumber + 1;
    idx1 = (remIndex(i*2-1)-1)*30;
    idx2 = (remIndex(i*2)-1)*30;
    totalRemDuration = totalRemDuration + (idx2 - idx1);
end
avgRemDuration = totalRemDuration / remNumber;
disp(['rem總次數: ', num2str(remNumber)]);
disp(['rem總時間: ', num2str(totalRemDuration)]);
disp(['平均rem時間: ', num2str(round(avgRemDuration))]);

% 計算rem fragmentation
total_rem_arousal = 0;
for i = 1:length(event.event_name)
    if(string(event.event_stage(i)) == '-1')
        if(string(event.event_name(i)) == 'Arousal 1 ARO RES' || string(event.event_name(i)) == 'Arousal 2 ARO Limb' || string(event.event_name(i)) == 'Arousal 3 ARO SPONT' || string(event.event_name(i)) == 'Arousal 4 ARO PLM')
            total_rem_arousal = total_rem_arousal + cell2mat(event.event_duration(i));
        end
    end
end
disp(['rem fragmentation: ', num2str(total_rem_arousal)]);
disp(['rem fragmentation ratio: ', num2str(total_rem_arousal/totalRemDuration)]);

% 取出片段計算 rem density
final_rem_second = 0;
final_wink_second = 0;
fnumber = 1;
for i = 1:length(remIndex)/2
    fnumber = fnumber + 2;
    idx1 = (remIndex(i*2-1)-1)*30*fs;
    idx2 = (remIndex(i*2)-1)*30*fs;
    e1_seg = e1(idx1:idx2);
    e2_seg = e2(idx1:idx2);
    t_seg = et(idx1:idx2);
    
    b = ones(1, ceil(fs/10))/ceil(fs/10);

    % 相減平方法 取出反向特徵
    seg_rev = e1_seg - e2_seg;
    seg_rev = abs(seg_rev);
    seg_rev = seg_rev .* 0.25;
    
    % 後相減前項 抓出眼動陡峭程度
    e1_seg_f = filter(b, 1, e1_seg);
    e2_seg_f = filter(b, 1, e2_seg);
    e1_seg_f = e1_seg_f .^ 2;
    e2_seg_f = e2_seg_f .^ 2;
    seg_e1_diff = diff(e1_seg_f);
    seg_e2_diff = diff(e2_seg_f);
    seg_diff = abs(seg_e1_diff) + abs(seg_e2_diff);
    seg_diff = [seg_diff, seg_diff(end)];
    % 眼動震幅主要在0.5以內，因此反向眼動相減最大越為1，sampling rate為256的情況下，將前項減後項的值*256會符合反向眼動特徵
    seg_diff = seg_diff .* fs;
    seg_diff = seg_diff .* 2;
    
    % 模糊化 根據fs來做moving average 此例為26點平均
    seg_diff = filter(b, 1, seg_diff);
    seg_rev = filter(b, 1, seg_rev);
    seg_sum = seg_rev + seg_diff;
    seg_sum = filter(b, 1, seg_sum);

    % 算秒數
    second_block_index = [];
    isHead = 0;
    for j = 1:length(seg_sum)
        % 找高於threshold的第一個值
        threshold1 = 0.02;
        threshold2 = 1;
        if seg_sum(j) > threshold1 && isHead == 0
            second_block_index(end+1) = j;
            isHead = 1;
        % 找範圍內是否還有後續
        elseif isHead == 1
            block_max = 0;
            % 以一秒為單位
            search = fs;
            if j+search <= length(seg_sum)
                block_max = max(seg_sum(j:j+search));
            else
                block_max = max(seg_sum(j:length(seg_sum)));
            end
            if block_max < threshold1
                second_block_index(end+1) = j;
                isHead = 0;
            end
        end
    end

    figure(fnumber);
    plot(t_seg, c1(idx1:idx2)+1.2, 'k');hold on;
    plot(t_seg, c2(idx1:idx2)+0.9, 'k');hold on;
    plot(t_seg, c3(idx1:idx2)+0.6, 'k');hold on;
    plot(t_seg, e1_seg+0.3, 'b');hold on;
    plot(t_seg, e2_seg, 'b');hold on;
    plot(t_seg, seg_diff-0.5, 'c');hold on;
    plot(t_seg, seg_rev-0.5, 'm');hold on;
    plot(t_seg, seg_sum-0.5, 'r');hold on;
    xlim([t_seg(1) t_seg(30*fs)]);
    
    figure(fnumber+1);
    plot(t_seg, c1(idx1:idx2)+1.2, 'k');hold on;
    plot(t_seg, c2(idx1:idx2)+0.9, 'k');hold on;
    plot(t_seg, c3(idx1:idx2)+0.6, 'k');hold on;
    plot(t_seg, e1_seg+0.3, 'b');hold on;
    plot(t_seg, e2_seg, 'b');hold on;
    plot(t_seg, seg_diff-0.5, 'c');hold on;
    plot(t_seg, seg_rev-0.5, 'm');hold on;
    plot(t_seg, seg_sum-0.5, 'r');hold on;
    axis tight;
    
    % 畫出區間，刪除過小的區間
    total_wink = 0;
    for k = 1:length(second_block_index)/2
        index1 = second_block_index(k*2-1);
        index2 = second_block_index(k*2);
        if (t_seg(index2) - t_seg(index1)) > 0.1
            total_wink = total_wink + (t_seg(index2) - t_seg(index1));
            
            figure(fnumber);
            second_block = patch([t_seg(index1) t_seg(index2) t_seg(index2) t_seg(index1)], [-0.5 -0.5 1.5 1.5], 'b');
            second_block.FaceAlpha = 0.1;
            hold on;

            figure(fnumber+1);
            second_block = patch([t_seg(index1) t_seg(index2) t_seg(index2) t_seg(index1)], [-0.5 -0.5 1.5 1.5], 'b');
            second_block.FaceAlpha = 0.1;
            hold on;
            
        end
    end
    
    total_wink_second = total_wink;
    final_wink_second = final_wink_second + total_wink_second;
    total_rem_second = t_seg(end) - t_seg(1);
    final_rem_second = final_rem_second + total_rem_second;
end
disp(['快速眼動時間: ', num2str(round(final_wink_second))]);
result = round(final_wink_second)/round(final_rem_second);
disp(['rem density: ', num2str(result)]);

