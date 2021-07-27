close all;
clear;

% 選擇腦波檔案
% eeg = load('edf_data.mat');
[file, path] = uigetfile('*.mat', 'select file', 'G:\共用雲端硬碟\Sleep center data\REM片斷化');
eeg = load([path, file]);

final_rem_second = 0;
final_wink_second = 0;

% 取出channel4(眼動)、channel5(眼動)、stage
e1 = eeg.data(4,:);
e2 = eeg.data(5,:);
stage = load([path, 'stage.dat']);

% 取channel 1、2、3 驗證用
c1 = eeg.data(1,:); % c3c4
c2 = eeg.data(2,:); % o1o2
c3 = eeg.data(3,:); % f3f4

% 根據資料更改
fs = 256;
slen = length(e1);
t = [1:slen]/fs;
st = [1:floor(slen/(fs*30))];
sl = [1:length(stage)];

% 畫出波型 以30秒為範圍觀察

figure(1);
subplot(3,1,1), plot(t, e1);
xlim([1 30]);
title('channel4 眼動');

subplot(3,1,2), plot(t, e2);
xlim([1 30]);
title('channel5 眼動');

subplot(3,1,3), plot(sl, stage);
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

% 取出片段觀察
fnumber = 1;
for i = 1:length(remIndex)/2
    fnumber = fnumber + 2;
    idx1 = (remIndex(i*2-1)-1)*30*fs;
    idx2 = (remIndex(i*2)-1)*30*fs;
    e1_seg = e1(idx1:idx2);
    e2_seg = e2(idx1:idx2);
    t_seg = t(idx1:idx2);
    
    b = ones(1, ceil(fs/10))/ceil(fs/10);
    % 抓取反向眼動
    % 相減平方法 取出反向特徵
    seg_rev = e1_seg - e2_seg;
    seg_rev = abs(seg_rev);
    seg_rev = seg_rev .* 0.5;
    
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
    
    %標準化陣列 0~1 (過大的眼動可能讓其他數值降低)
    %seg_diff = (seg_diff - min(seg_diff)) ./ max(seg_diff);
    
    % 模糊化 根據fs來做moving average 此例為26點平均
%     b = ones(1, ceil(fs/10))/ceil(fs/10);
    seg_diff = filter(b, 1, seg_diff);
    seg_rev = filter(b, 1, seg_rev);
    seg_sum = seg_rev + seg_diff;
    seg_sum = filter(b, 1, seg_sum);
    
    
    
    % 算秒數
    second_block_index = [];
    isHead = 0;
    for j = 1:length(seg_sum)
        % 找高於threshold的第一個值
        threshold1 = 0.025;
        threshold2 = 1;
        if seg_sum(j) > threshold1 && seg_sum(j) < threshold2 && isHead == 0
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
            if block_max < threshold1 && seg_sum(j) < threshold2
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
    xlim([t_seg(1) t_seg(30*256)]);
    
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
    disp(total_wink_second);
    final_wink_second = final_wink_second + total_wink_second;
    
    total_rem_second = t_seg(end) - t_seg(1);
    disp(total_rem_second);
    final_rem_second = final_rem_second + total_rem_second;
    
end

% 結果: 眼動秒數/總rem秒數
disp('------------------------------------');
disp(round(final_wink_second));
disp(round(final_rem_second));
result = round(final_wink_second)/round(final_rem_second);
disp(result);

