clc
clear
close
tic

alldir = ["P017_o_20150120", 'P017_x_20150209', 'P018_o_20150216', 'P018_x_20150204', 'P019_o_20150224', 'P019_x_20150203', 'P020_o_20150409', 'P020_x_20150429', 'P021_o_20150205', 'P021_x_20150320', 'P022_o_20150210', 'P022_x_20150414', 'P023_o_20150225', 'P023_x_20150212', 'P024_o_20150515', 'P024_x_20150506', 'P025_o_20150402', 'P025_x_20150428', 'P026_o_20150323', 'P026_x_20150330', 'P027_o_20150427', 'P027_x_20150302', 'P028_o_20150401', 'P028_x_20150421', 'P029_o_20150310', 'P029_x_20150324', 'P030_o_20150326', 'P030_x_20150422', 'P031_o_20150317', 'P031_x_20150309', 'P032_o_20150325', 'P032_x_20150305', 'P033_o_20150430', 'P033_x_20150505', 'P034_o_20150410', 'P034_x_20150417', 'P035_o_20150511', 'P035_x_20150508', 'P036_o_20150507', 'P036_x_20150512', 'P037_o_20150423', 'P037_x_20150416', 'P038_o_20150313', 'P038_x_20150319', 'P039_o_20150407', 'P039_x_20150424', 'P040_o_20150318', 'P040_x_20150303'];
fpath = uigetdir('G:\共用雲端硬碟\Sleep center data\REM片斷化');
for i = 1:length(alldir)
    InputDir = strcat(fpath, '\', alldir(i));
    OutputDir = strcat(fpath, '\', alldir(i));
    files = dir(strcat(InputDir, '\', '*.edf')); %load all .edf files in the folder
    filesNumber = length(files);

    if exist(OutputDir,'dir')~=7
            mkdir(OutputDir);
    end

    for f = 1:filesNumber
        [hdr, data] = edfread(strcat(InputDir, '\', files(f).name));
        %load([InputDir files(f).name]);
        fprintf('file(%d/%d): %s is loaded.\n',f,filesNumber,files(f).name(1:end-4));

        save(strcat(OutputDir,'\',files(f).name(1:end-4),'.mat'),'data');
        fprintf('file(%d/%d): %s is saved.\n',f,filesNumber,files(f).name(1:end-4));

        %clear data
        close all
    end
end

