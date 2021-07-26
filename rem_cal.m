close all;
clear;
% eeg = load('edf_data.mat');
[file, path] = uigetfile('*.mat', 'select file', 'G:\共用雲端硬碟\Sleep center data\REM片斷化');
eeg = load([path, file]);

final_rem_second = 0;
final_wink_second = 0;

% 取出channel4、channel5、stage
e1 = eeg.data(4,:);
e2 = eeg.data(5,:);
stage = load([path, 'stage.dat']);

% 取channel 1、2、3 驗證用
c1 = eeg.data(1,:);
c2 = eeg.data(2,:);
c3 = eeg.data(3,:);

% 根據資料更改
fs = 256;
slen = length(e1);
t = [1:slen]/fs;
st = [1:floor(slen/(fs*30))];
sl = [1:length(stage)];

% 畫出波型
figure(1); % channel4 眼動
plot(t, e1);
title('channel4 眼動');
axis tight;
figure(2); % channel5 眼動
plot(t, e2);
title('channel5 眼動');
axis tight;
figure(3); % stage(-1:rem, 0:wake, 1:n1, 2:n2, 3:n3)
plot(sl, stage);
title('stage');
axis tight;

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

% 取出片段觀察
for i = 1:length(remIndex)/2
    index1 = (remIndex(i*2-1)-1)*30*fs;
    index2 = (remIndex(i*2)-1)*30*fs;
    e1_seg = e1(index1:index2);
    e2_seg = e2(index1:index2);
    t_seg = t(index1:index2);
    figure;
    plot(t_seg, c1(index1:index2)+2, 'm');hold on;
    plot(t_seg, c2(index1:index2)+1.5, 'm');hold on;
    plot(t_seg, c3(index1:index2)+1, 'm');hold on;
    plot(t_seg, e1_seg, 'b');hold on;
    plot(t_seg, e2_seg, 'g');hold on;
    
    % 抓取反向眼動
    % 相減平方法
    seg_diff = e1_seg - e2_seg;
    seg_diff = seg_diff .^ 2;
    %標準化陣列 0~1 (過大的眼動可能讓其他數值降低)
    %seg_diff = (seg_diff - min(seg_diff)) ./ max(seg_diff);
    seg_diff = seg_diff .* 10;
    % 模糊化
    b = ones(1, ceil(fs/10))/ceil(fs/10);
    seg_diff = filter(b, 1, seg_diff);    
    
    plot(t_seg, seg_diff - 1, 'r');
    hold on;
    axis tight;
    
    % 算秒數
    second_block_index = [];
    isHead = 0;
    for j = 1:length(seg_diff)
        % 找高於threshold的第一個值
        threshold = 0.003;
        if seg_diff(j) > threshold && isHead == 0
            second_block_index(end+1) = j;
            isHead = 1;
        % 找範圍內是否還有後續
        elseif isHead == 1
            block_max = 0;
            % 以一秒為單位
            search = fs;
            if j+search <= length(seg_diff)
                block_max = max(seg_diff(j:j+search));
            else
                block_max = max(seg_diff(j:length(seg_diff)));
            end
            if block_max < threshold
                second_block_index(end+1) = j;
                isHead = 0;
            end
        end
    end
    % 畫出區間，刪除過小的區間
    total_wink = 0;
    for k = 1:length(second_block_index)/2
        index1 = second_block_index(k*2-1);
        index2 = second_block_index(k*2);
        
        if (t_seg(index2) - t_seg(index1)) > 0.1
            total_wink = total_wink + (t_seg(index2) - t_seg(index1));
            second_block = patch([t_seg(index1) t_seg(index2) t_seg(index2) t_seg(index1)], [-1 -1 0.2 0.2], 'b');
            second_block.FaceAlpha = 0.2;
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

