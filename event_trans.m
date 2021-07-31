clc
clear

fpath = uigetdir;
InputDir = fpath;
OutputDir = [fpath '\event_dat'];
subdir = dir([InputDir '\']);%load all sub directory in the folder

cnt=1;

file_txt = dir([fpath '\' '*.txt']);%load all .txt files in the folder
for k=1:length(file_txt)
    if strcmp(file_txt(k).name(1:end), 'event_data.txt')==1
        event_folder(cnt) = file_txt(k);
        cnt=cnt+1;
    end
end


%event_folder=dir('G:\共用雲端硬碟\Sleep center data\REM片斷化\20141122_1\event_data.txt');
stage_T=containers.Map(["REM","AWAKE","STAGE 1","STAGE 2","STAGE 3","STAGE 4","N1","N2","N3","N4","Unscored"],[-1,0,1,2,3,4,1,2,3,4,-2]);
for i=1:length(event_folder)
    FID=fopen([event_folder(i).folder '\' event_folder(i).name],'r');
    textdata=fscanf(FID,'%c');
    fclose(FID);
    tmp=textdata(1);
    event=[];
    idx=1;
    now=1;
    for j=1:length(textdata)-1
        if isequal(textdata(j+1),',')
            event{now,idx}=tmp;
            idx=idx+1;
            tmp=[];
        elseif idx==8  && isstrprop(textdata(j+1),'digit')
            event{now,idx}=tmp;
            idx=1;
            now=now+1;
            tmp=textdata(j+1);
        else
            tmp=[tmp textdata(j+1)];
        end
        
    end
%     FID=fopen([event_folder(i).folder '\start_time.dat'],'r');
%     start_time=fscanf(FID,'%c');
%     fclose(FID);
%     tmp=[];
%     for j=1:length(start_time)
%         if isequal( start_time(j) , '.')
%             tmp=[tmp  ':'];
%         elseif ~isequal( start_time(j) , ',')
%             tmp=[tmp start_time(j)];
%         end
%     end
    
%     start_time=tmp;
    event_time={event{:,1}}';
    event_epoch={event{:,2}}';
    event_stage={event{:,3}}';
    event_name={event{:,4}}';
    event_duration={event{:,5}}';
    event_SPO2={event{:,6}}';
    event_decrease={event{:,7}}';
    event_direction={event{:,8}}';
%     event_second=Time2Second(event_time,start_time)';
    for j=1:length(event(:,1))
        event_stage{j}=stage_T(string(event_stage{j}));
        event_epoch{j}=str2double(event_epoch{j});
%         event_second{j}=str2double(event_second{j})-30*(event_epoch{j}-1);
        cidx=find(event_duration{j}==':');
        event_duration{j}=str2double(event_duration{j}(1:cidx-1))*60+str2double(event_duration{j}(cidx+1:end));
        
    end
%     save([event_folder(i).folder  '\event.mat'],'event_direction','event_decrease','event_SPO2','event_duration','event_name','event_stage','event_epoch','event_time','event_second');
    
     save([event_folder(i).folder(1:34) '\event_mat' event_folder(i).folder(35:end) '_event.mat'],'event_direction','event_decrease','event_SPO2','event_duration','event_name','event_stage','event_epoch','event_time');
    
    
    
    
    
end

function result=Time2Second(timevalue,target)
if length(target)==9
    tH=str2double(target(1:2));
    tM=str2double(target(4:5));
    tS=str2double(target(7:8));
else
    tH=str2double(target(1));
    tH=tH+24;
    tM=str2double(target(3:4));
    tS=str2double(target(6:7));
end
for i=1:length(timevalue)
    if length(timevalue{i})==8
        rH=str2double(timevalue{i}(1:2));
        rM=str2double(timevalue{i}(4:5));
        rS=str2double(timevalue{i}(7:8));
    else
        rH=str2double(timevalue{i}(1));
        rH=rH+24;
        rM=str2double(timevalue{i}(3:4));
        rS=str2double(timevalue{i}(6:7));
    end
   result{i}=(rH-tH)*3600+(rM-tM)*60+(rS-tS); 
end
end