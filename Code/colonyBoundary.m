function result = colonyBoundary(img,fitc,meta,varargin)
%caculate the first and last slice of the colony based on the change of
%fluorscence intensity.

%usage:
%    result = colonyBoundary(img,fitc,meta)
%    result = colonyBoundary(img,fitc,meta,dZ)
%    result = colonyBoundary(img,fitc,meta,dZ,'dis',value)

% The input img should be a 3-dimensional matrix of mcherry channel 
%microscope images, with the three indices representing y, x, and z respectively.

% The input fitc should be a 3-dimensional matrix of fitc channel background 
%microscope images, with the three indices representing y, x, and z respectively.

%the input meta should be a table recording the position for determain
%top and bottom slice.

%the optional input dZ is the step length when taking image by confocal
%microscope. The default value is 15.05.

%the optinal input dis is the line numbers of the present colony in the
%meta excel matrix. The default is from the first to last slice.

%the output result is the top and bottom slice numbers of each pair of ROI
%and the height caculated from them.

%
% Written by Yihui He
% Version 0.2. Created on Aug, 15, 2022. last modification is on Aug, 17,
% 2022.
argin = inputParser;
addOptional(argin,'dis',1:size(meta,1))
addOptional(argin,'dZ',15.05)
parse(argin,varargin{:})
dis = argin.Results.dis;
dZ = argin.Results.dZ;

result = zeros(size(meta,1),3);

for i = dis
    fitc_pos = [meta.p_botx(i),meta.p_boty(i), meta.rectangle(i),meta.rectangle(i)];
    fitc_img2 = imCrop2(fitc, fitc_pos);
    fitc_mean_img2 = squeeze(mean(mean(fitc_img2,1),2));
    for n = 1:size(fitc_mean_img2)-1
        fitc_change(n) = fitc_mean_img2(n)-fitc_mean_img2(n+1);
    end
    [~,bot] = min(fitc_change); 
    bot = bot+1;
    mch_pos = [meta.p_topx(i),meta.p_topy(i), meta.rectangle(i),meta.rectangle(i)];
    mch_img2 = imCrop2(img, mch_pos);
    mch_mean_img2 = squeeze(mean(mean(mch_img2,1),2));
    for n = 1:size(mch_mean_img2)-1
        mch_change(n) = mch_mean_img2(n)-mch_mean_img2(n+1);
    end
    [~,top] = min(mch_change); 
    top = top + 1;
    height = dZ * (bot-top);
    result(i,:) = [top,bot,height];
end