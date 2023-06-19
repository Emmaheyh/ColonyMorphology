function [each_replicate,mean_result,t_value] = colonySize(meta,gene,varargin)
%caculate the volume, height and area information of a set of colony based
%on meta excel table.

%usage:
%    [each_replicate,mean_result,t_value] = colonySize(meta,gene)
%    [each_replicate,mean_result,t_value] = colonySize(meta,gene,dZ)
%    [each_replicate,mean_result,t_value] = colonySize(meta,gene,dZ,'pixelSize',value)

%the input meta is a table that has details of each colony.

%the input gene is a cell containing knock-out genes names.

%the optional input dZ is the step length when taking image by confocal
%microscope. The default value is 15.05.

%the optional pixelSize is the area of each pixel, the default value is 4.32^2.

%the output each_replicate is a table of meta plus height, volume and area
%of each replicate.

%the output mean_result is a table of parameter's mean value of each group.

%the output t_value is a table of t value of 2-samples dual-tails t_test
%between Wild type control and knock_out strains.
%
% Written by Yihui He
% Version 0.3. Created on Aug, 15, 2022. Modified on Dec, 12, 2022.


argin = inputParser;
addOptional(argin,'dZ',15.05)
addParameter(argin,'pixelSize',4.32^2)
parse(argin,varargin{:})
dZ = argin.Results.dZ;
pixelSize = argin.Results.pixelSize;


result = zeros(size(meta,1),4);
for i = 1:size(meta,1)
    img = imRead2(char(meta.mch_path(i)));
    fitc = imRead2(char(meta.fitc_path(i)));
    dZ = meta.dZ(i);
    thresh = meta.threshold(i);
    disk_size = meta.disk_size(i);
    sigma = meta.sigma(i);
    top = meta.top(i);
    bot = meta.bottom(i);
    
    %get colony height with correction
    height = (bot-top) * dZ;
    colony_img = img(:,:,top:bot); % remove other slide
    
    % calculate gradient for image
    smoothImage = zeros(size(colony_img,1),size(colony_img,2),size(colony_img,3));
    imgrad = zeros(size(colony_img,1),size(colony_img,2),size(colony_img,3));
    sigma = meta.sigma(i);
    for k = 1:size(colony_img,3)
        smoothImage(:,:,k) = imgaussfilt(colony_img(:,:,k),sigma); %filter noise point
        imgrad(:,:,k) = imgradient(smoothImage(:,:,k));
    end
    % get colony volume and max area
    mask = zeros(size(imgrad,1),size(imgrad,2),size(imgrad,3));
    volume = 0;
    area = 0;
    for n = 1:size(imgrad,3)
        threshold = thresh * multithresh(imgrad(:,:,n));
        mask_slice = imgrad(:,:,n)>threshold;
        mask_slice = imclose(mask_slice,strel('disk',disk_size));
        mask_slice_filled = imfill(mask_slice, 'holes');
        mask_slice_filled = imopen(mask_slice_filled,strel('disk',disk_size));
     
        CC = bwconncomp(mask_slice_filled);
        MaskV2 = false(size(mask_slice_filled));
        PixelNum = zeros(numel(CC.PixelIdxList),1);
        for p = 1:numel(CC.PixelIdxList)
            PixelNum(p) = numel(CC.PixelIdxList{p});
        end
        [~,iPN] = max(PixelNum);
        MaskV2(CC.PixelIdxList{iPN}) = true;
        mask_slice_filled = MaskV2;
        mask(:,:,n) = mask_slice_filled;
        area(n) = sum(mask_slice_filled(:))*pixelSize/10^6;
        if n >1
           last_slice = sum(mask(:,:,n-1));
           
           volume = volume + (sum(last_slice(:))+sum(mask_slice_filled(:))+ sqrt(sum(last_slice(:))*sqrt(sum(mask_slice_filled(:)))))*dZ/3*pixelSize/10^9;
        end
        
    end
[max_area,~] = max(area);
diameter = (max_area / pi) ^ 0.5*2;
%record data of each replicate
result(i,:) = [height,volume,max_area,diameter];
    
end

condition = {};
for i = 1:size(meta,1)
    condition(i) = {char(meta.file(i))};
end

%export results to meta_data file
each_replicate = addvars(meta,result(:,1),result(:,2),result(:,3),result(:,4),'After','p_boty','NewVariableNames',{'height','volume','max_area','diameter'});
%writetable(each_replicate,filename,'Sheet','each replicate','WriteRowNames',true);


%mean of size parameter
unique_conditions = unique(each_replicate.file,'stable');
mean_result = zeros(numel(unique_conditions),4);

for m = 1:numel(unique_conditions)
    group_id = find(strcmp(unique_conditions(m),each_replicate.file))';
    h = 0;
    a = 0;
    v = 0;
    d = 0;
    for n = 1:numel(group_id)
        h(n) = each_replicate.height(group_id(n));
        a(n) = each_replicate.max_area(group_id(n));
        v(n) = each_replicate.volume(group_id(n));
        d(n) = each_replicate.diameter(group_id(n));
    end
    mean_result(m,:) = [mean(h),mean(v),mean(a),mean(d)];
end
mean_result = array2table(mean_result,'VariableNames',{'height','volume','max_area','diameter'});
mean_result = addvars(mean_result,unique_conditions,'Before','height');
unique_mch_path = unique(meta.mch_path,'stable');
uniqe_fitc_path = unique(meta.fitc_path,'stable');
mean_result = addvars(mean_result,unique_mch_path,'NewVariableNames','mch_path','After','unique_conditions');
mean_result = addvars(mean_result,uniqe_fitc_path,'NewVariableNames','fitc_path','After','mch_path');
mean_result = splitvars(addvars(mean_result,each_replicate(1:size(unique_conditions,1),5:18),'After','fitc_path'));

%caculate t value for multiple comparing
wt_id = find(contains(mean_result.unique_conditions,'WT'))';
for g = 1:numel(wt_id)
    wt.height(g) = mean_result.height(wt_id(g));
    wt.volume(g) = mean_result.volume(wt_id(g));
    wt.max_area(g) = mean_result.max_area(wt_id(g));
    wt.diameter(g) = mean_result.diameter(wt_id(g));
end
% group_id = find(contains(meta.unique_conditions,gene{4}))';
% height = zeros(size(group_id));
% volume = zeros(size(group_id));
% max_area = zeros(size(group_id));
% diameter = zeros(size(group_id));
% for m = 1:numel(group_id)
%     height(m) = meta.height(group_id(m));
%     volume(m) = meta.volume(group_id(m));
%     max_area(m) = meta.max_area(group_id(m));
%     diameter(m) = meta.diameter(group_id(m));
% end        
% [h,p,ci,stats] = ttest2(height,wt.height);        

for k = 1:numel(gene)
    group_id = find(contains(mean_result.unique_conditions,gene{k}))';
    height = zeros(size(group_id));
    volume = zeros(size(group_id));
    max_area = zeros(size(group_id));
    diameter = zeros(size(group_id));
    for l = 1:numel(group_id)
        height(l) = mean_result.height(group_id(l));
        volume(l) = mean_result.volume(group_id(l));
        max_area(l) = mean_result.max_area(group_id(l));
        diameter(l) = mean_result.diameter(group_id(l));
    end
    [h_y,h_p,h_ci,h_stats] = ttest2(height,wt.height);
    [v_y,v_p,v_ci,v_stats] = ttest2(volume,wt.volume);
    [a_y,a_p,a_ci,a_stats] = ttest2(max_area,wt.max_area);
    [d_y,d_p,d_ci,d_stats] = ttest2(diameter,wt.diameter);
    t_value(k,:) = [h_stats.tstat,h_p,v_stats.tstat,v_p,a_stats.tstat,a_p,d_stats.tstat,d_p];
end
t_value = array2table(t_value,'VariableNames',{'height_t_value','h_p','volume_t_value','v_p','max_area_t_value','a_p','diameter_t_value','d_p'});
t_value = addvars(t_value,gene','Before','height_t_value','NewVariableNames',{'Gene'});
t_value = splitvars(addvars(t_value,each_replicate(1:size(gene,2),5:18),'After','Gene'));
%mean_result = addvars(mean_result,t_value,'After','diameter','NewVariableNames',{'t_value'})
%writetable(mean_result,filename,'Sheet','mean of groups','WriteRowNames',true);
