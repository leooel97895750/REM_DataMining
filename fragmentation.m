close all;
clear;

alldir = ["P001_o_20141118", 'P001_x_20141125', 'P002_o_20141128', 'P002_x_20141122_2', 'P003_o_20141201_1', 'P003_x_20141122_1', 'P004_o_20141130', 'P004_x_20141123_2', 'P005_o_20141127', 'P005_x_20141123_1', 'P006_o_20141129_1', 'P006_x_20141206_1', 'P007_o_20141201_2', 'P007_x_20141209', 'P009_o_20141202', 'P009_x_20141205', 'P010_o_20141203', 'P010_x_20141206_3', 'P011_o_20141211', 'P011_x_20141206_2', 'P012_o_20141208', 'P012_x_20141226', 'P013_o_20150122', 'P013_x_20150226', 'P014_o_20150106', 'P014_x_20150114', 'P015_o_20150121', 'P015_x_20150128', 'P016_o_20150116', 'P016_x_20150130', 'P017_o_20150120', 'P017_x_20150209', 'P018_o_20150216', 'P018_x_20150204', 'P019_o_20150224', 'P019_x_20150203', 'P020_o_20150409', 'P020_x_20150429', 'P021_o_20150205', 'P021_x_20150320', 'P022_o_20150210', 'P022_x_20150414', 'P023_o_20150225', 'P023_x_20150212', 'P024_o_20150515', 'P024_x_20150506', 'P025_o_20150402', 'P025_x_20150428', 'P026_o_20150323', 'P026_x_20150330', 'P027_o_20150427', 'P027_x_20150302', 'P028_o_20150401', 'P028_x_20150421', 'P029_o_20150310', 'P029_x_20150324', 'P030_o_20150326', 'P030_x_20150422', 'P031_o_20150317', 'P031_x_20150309', 'P032_o_20150325', 'P032_x_20150305', 'P033_o_20150430', 'P033_x_20150505', 'P034_o_20150410', 'P034_x_20150417', 'P035_o_20150511', 'P035_x_20150508', 'P036_o_20150507', 'P036_x_20150512', 'P037_o_20150423', 'P037_x_20150416', 'P038_o_20150313', 'P038_x_20150319', 'P039_o_20150407', 'P039_x_20150424', 'P040_o_20150318', 'P040_x_20150303'];
testdir = ["P001_o_20141118", 'P001_x_20141125'];

summary6 = readtable('summary6.csv');

for i = 1:length(alldir)
    
    % 匯入資料
    % eeg = load(strcat('G:\共用雲端硬碟\Sleep center data\REM片斷化\', alldir(i), '\edf_data.mat'));
    stage = load(strcat('G:\共用雲端硬碟\Sleep center data\REM片斷化\', alldir(i), '\stage.dat'));
    event = load(strcat('G:\共用雲端硬碟\Sleep center data\REM片斷化\', alldir(i), '\event.mat'));
    
    % REM數值
    a1 = 0;
    a2 = 0;
    a3 = 0;
    a4 = 0;
    
    for j = 1:length(event.event_name)
        % REM的事件
        eStage = cell2mat(event.event_stage(j));
        if eStage == -1
            % Arosual: 1呼吸事件、2腿動、3自發、4腿動
            eName = cell2mat(event.event_name(j));
            if eName == "Arousal 1 ARO RES" || eName == "Arousal 2 ARO Limb" || eName == "Arousal 3 ARO SPONT" || eName == "Arousal 4 ARO PLM"
                eDuration = cell2mat(event.event_duration(j));
                % 區分 micro arousal(<3)、macro arousal(>=3)
                if eDuration >=3 && eDuration <=15
                    % 區分不同 arousal
                    if eName == "Arousal 1 ARO RES"
                        a1 = a1 + 1;
                    elseif eName == "Arousal 2 ARO Limb"
                        a2 = a1 + 1;
                    elseif eName == "Arousal 3 ARO SPONT"
                        a3 = a3 + 1;
                    elseif eName == "Arousal 4 ARO PLM"
                        a4 = a4 + 1;
                    end
                end
            end
        end
    end
    
    disp(['a1: ', num2str(a1), ', a2: ', num2str(a2), ', a3: ', num2str(a3), ', a4: ', num2str(a4)]);
    disp(ceil(i/2));
    disp(44+mod(i,2));
    summary6(ceil(i/2), 45-mod(i,2)) = {a1};
    summary6(ceil(i/2), 47-mod(i,2)) = {a2};
    summary6(ceil(i/2), 49-mod(i,2)) = {a3};
    summary6(ceil(i/2), 51-mod(i,2)) = {a4};
    
end