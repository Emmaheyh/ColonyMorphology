%you need mcherry and fitc tif image and meta info.

% Written by Yihui He
% Version 0.2. Created on Aug, 15, 2022. Last modification on Aug, 17,
% 2022.

%see also colonyBoundary, colonyMask, colonySize, colony3Doutline.
%% load path
clearvars 
wd = 'E:\myConfocal\CF\D20230101\analysis'; % the path of all file
cd(wd)
filename = '20230101_meta.xlsx'; % meta excel filename
dZ = 15.05;
%% WT1
img = imRead2('Test-mCherry.tif','roi','p');
fitc = imRead2('Test-FITC.tif','roi','p'); % set ROI

%%
dis = 1:8; %meta row numbers
meta = readtable(filename,'Sheet',1);
result = colonyBoundary(img,fitc,meta,dis);
hmean = mean(result(dis,3))
%%
%check the patameters of mask detection
[colony_img,mask] = colonyMask(img,6,17);

%% WT2
img = imRead2('mcherry-2.tif');
fitc = imRead2('FITC-2.tif');
iViewer(img, 'roi','p') %choose multiple ROIs to determine intensity change, set the eight upper-left point of the ROI and set the rectangle lenght additionally.
iViewer(fitc,'roi','p') %choose multiple ROIs to determine intensity change, set the eight upper-left point of the ROI and set the rectangle lenght additionally.

%%
dis = 9:16; %meta row numbers
meta = readtable(filename,'Sheet',1);
result = colonyBoundary(img,fitc,meta,dis);
hmean = mean(result(dis,3))
%%
%check the patameters of mask detection
[colony_img,mask] = colonyMask(img,5,16);
%% WT3
img = imRead2('mcherry-3.tif');
fitc = imRead2('FITC-3.tif');
iViewer(img, 'roi','p') %choose multiple ROIs to determine intensity change
iViewer(fitc, 'roi','p') %choose multiple ROIs to determine intensity change

%%
dis = 17:24; %meta row numbers
meta = readtable(filename,'Sheet',1);
result = colonyBoundary(img,fitc,meta,dis);
hmean = mean(result(dis,3))
%%
%check the patameters of mask detection
[colony_img,mask] = colonyMask(img,5,16,0.7);

%% caculate colony size parameters based on meta data
%reread the meta info to get the top, bottom, sigma, threshold, disk_size
%information to caculate a set of colonies' parameters.
filename = '20230101_meta.xlsx';
meta = readtable(filename,'Sheet',1);
gene = {'glmZ_full','glmZ_purR-35','glmZ_purR','glmZ_sRNA','glmZ_TSS','drutG'}; % gene-knock strains that involved in this experiment
[each_replicate,mean_result,t_value] = colonySize(meta,gene);

%% export to meta file
writetable(each_replicate,filename,'Sheet','each replicate','WriteRowNames',true); %output the results table to the meta excel form
writetable(mean_result,filename,'Sheet','mean of groups','WriteRowNames',true); %output the results table to the meta excel form
writetable(t_value,filename,'Sheet','t_values','WriteRowNames',true) %output the 2-sample dual_tails ttest t_values to the meta excel form

%% load data
wd = 'E:\myConfocal\CF\D20230101\analysis';
cd(wd)
dZ = 15.05;
edge = readtable(filename,'Sheet','edge plot');
edge_gene = {'glmZ_full','glmZ_purR-35','glmZ_purR','glmZ_sRNA','glmZ_TSS','rutG'}; % gene-knock strains that involved in this experiment

%% plot each significant ko strain with WT
edge = readtable(filename,'Sheet','edge plot');

mkdir('colonyElevation_eachStrain') %make a new folder
close all
cmp = cbrewer2('seq','Reds',9); %set color

% WT colony info
WT_img = imRead2('mcherry-1.tif'); 
WT_top = 6;
WT_bottom = 16;

%plot
for i = 1:numel(edge_gene)
    %con = ['d' edge_gene{i} '_img'];
    con = imRead2(edge.unique_mch_path{i});
    figure
    set(gcf,'position',[300 300 1000 500])
    [line1,~,~,~] = PlotColony(con,edge.top(i),edge.bottom(i),cmp(i+2,:))
    [WT,~,~,~] = PlotColony(WT_img,WT_top,WT_bottom,'k')
    set(gca,'FontSize',14)
    ylabel('Height(\mum)')
    xlabel('Length(\mum)')
    xline(0,':k')
    % axis equal
    ylim([-10 200])
    leg = ['\it\Delta' replace(edge_gene{i},'_',' ')];
    legend([line1, WT],{leg,'WT'},'FontSize',20)
    print(['colonyElevation_eachStrain\' edge_gene{i}],'-dpng','-r600')
    close
end