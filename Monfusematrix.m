close all
clear 
[file, path] = uigetfile('*.mat', 'select file', 'G:\共用雲端硬碟\Sleep center data\REM片斷化');
%stage = load([path, 'stage.dat']);
data=readcell([path, 'stage.dat']);
num2stage=containers.Map([1 2 3 4 5],["W","N1","N2","N3","R"]);
stage2num=containers.Map(["W","N1","N2","N3","REM"],[0 1 2 3 -1 ]);
stage2num2=containers.Map([0,1,2,3,-1],[1 2 3 4 5]);
people=7;
CM=zeros(people,people);
stage_precent= zeros(people,people);
epoch=length(data(:,1))-1;
hyp=zeros(epoch,people);
hf = figure;
hf=colordef(hf,'white'); %Set color scheme
hf.Color='w'; 
for i=1:people
    for j=1:epoch
        hyp(j,i)=stage2num(data{j+1,i+1});
    end
    hyp1=hyp(:,i);
    for j=1:i
        hyp2=hyp(:,j);
        CM(j,i)=length(find(hyp1==hyp2))/length(hyp1);
        CM(i,j)=length(find(hyp1==hyp2))/length(hyp1);
    end
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
       stage(i,1)=length(find(hyp1==-1));
    stage(i,2)=length(find(hyp1==0));
    stage(i,3)=length(find(hyp1==1));
    stage(i,4)=length(find(hyp1==2));
    stage(i,5)=length(find(hyp1==3));
    stage_precent(i,1)=length(find(hyp1==-1))/epoch;
    stage_precent(i,2)=length(find(hyp1==0))/epoch;
    stage_precent(i,3)=length(find(hyp1==1))/epoch;
    stage_precent(i,4)=length(find(hyp1==2))/epoch;
    stage_precent(i,5)=length(find(hyp1==3))/epoch;
    tmp=find(W==0);
    diff_ana.SE(i)=length(tmp)/length(hyp);
    diff_ana.TST(i)=length(tmp)/2;
    diff_ana.SOT(i)=tmp(1)/2;
    tmp=find(W(tmp(1):end)==1);
    diff_ana.WASOT(i)=length(tmp)/2;
    
end

% stage_cm=zeros(5,5);
% for i=1:people
%     for j=1:length(hyp)
%         stage_cm(stage2num2(gold_hyp(j)),stage2num2(hyp(j,i)))=stage_cm(stage2num2(gold_hyp(j)),stage2num2(hyp(j,i)))+1;
%     end
%     
% end
% for i=1:5
%     stage_cm_precent(i,1:5) = stage_cm(i,:)./sum(stage_cm(i,:));
% end


acc=[];
for i=1:people
    for j=i+1:people
        acc=[acc CM(i,j)];
    end
end
mean(acc)
min(acc)
epoch_stage=[];
for i=1:epoch
    stage_all{i} = hyp(i,:);
    stage_num{i} = unique(hyp(i,:));
    stage_num_sum(i) = length(unique(hyp(i,:)));
end

diff_idx1=find( stage_num_sum==1);
diff_idx2=find( stage_num_sum==2);
diff_idx3=find( stage_num_sum==3);
diff_idx4=find( stage_num_sum==4);
diff_idx5=find( stage_num_sum==5);
% 
for i=1:length(diff_idx4)
    diff4_each(i,2:8)=hyp(diff_idx4(i),:);
    diff4_each(i,1)=diff_idx4(i);
end
for i=1:length(diff_idx3)
    diff3_each(i,2:8)=hyp(diff_idx3(i),:);
    diff3_each(i,1)=diff_idx3(i);
end
for i=1:length(diff_idx2)
    two_stage(i)=stage_all(diff_idx2(i));
end
% d_two_stage=[];
% A=[];
% p19=0;p28=0;p37=0;p46=0;p55=0;
% for i=1:length(two_stage)
%     A{i}=tabulate(two_stage{1,i}); 
%     A{1,i}(2,2)
%     if A{1,i}(2,2)==1 || A{1,i}(2,2)==9
%         p19=p19+1;
%     elseif A{1,i}(2,2)==2 || A{1,i}(2,2)==8
%         p28=p28+1;
%     elseif A{1,i}(2,2)==3 || A{1,i}(2,2)==7
%         p37=p37+1;
%     elseif A{1,i}(2,2)==4 || A{1,i}(2,2)==6
%         p46=p46+1;   
%     elseif A{1,i}(2,2)==5 
%         p55=p55+1;
%     end
% end

