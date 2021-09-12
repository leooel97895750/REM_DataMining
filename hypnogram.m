close all
clear all

people=3;
[file, path] = uigetfile('*.mat', 'select file', 'G:\共用雲端硬碟\Sleep center data\REM片斷化');
data=readcell([path, 'hyp_data.txt']);
%event = load([path, 'event.mat']);


epoch=length(data(:,1));
hyp=zeros(epoch,people);
i = 1;
for j=1:epoch
    if data{j,i} == 'W'
        hyp(j,i) = 0;
    elseif data{j,i} == 1 | data{j,i} == 'N1'
        hyp(j,i) = 1;
    elseif data{j,i} == 2 | data{j,i} == 'N2'
        hyp(j,i) = 2;
    elseif data{j,i} == 3 | data{j,i} == 'N3'
        hyp(j,i) = 3;
    elseif data{j,i} == 'R'
        hyp(j,i) = -1;
    end
end
hf = figure;
hf=colordef(hf,'white'); %Set color scheme
hf.Color='w'; 
for i=1:people
    hyp1=hyp(:,i);

    subplot(people,1,i);
    hold on
    grid on
    W=hyp1==0;
    R=hyp1==-1;
    bar(R,'FaceColor','#A2142F','BarWidth',1)
        
    N1=hyp1==1;
    bar(N1*-1,'FaceColor','#EDB120','BarWidth',1)
    
    N2=hyp1==2;
    bar(N2*-2,'FaceColor','#77AC30','BarWidth',1)
    
    N3=hyp1==3;
    bar(N3*-3,'FaceColor','#0072BD','BarWidth',1)
    
    axis tight;
    ylim([-3 1])
    yticklabels({'N3','N2','N1','W','R'});
end