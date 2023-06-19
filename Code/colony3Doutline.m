function [Dist, HeightdZ] = colony3Doutline(colony3D, dZ)
%detect the radius of colony from mask of fluorescence image. 

%Usage:[Dist_angleNeg, Dist_anglePos, HeightdZ] = colony3Doutline(colony3D, dZ)

%the input colony3D is masks of the colony, which is a 3-dimentional
%double.dZ is the setp length when taking image by confocal.  

%The output Dist_angleNeg and Dist_anglePos is the radius of the upper and lower half
%of mask, respectively. Dist is the mean of Dist_angleNeg and
%Dist_anglePos.

%The output HeightdZ is the height of the colony.

%---tips---
%do this after checking the mask detection result.

% Written by Shen Ping 
% Version 0.2. Created on Augest 12, 2022. Last modification on Aug 15,
% 2022.

Dist_angleNeg = [];
Dist_anglePos = [];
Dist = [];
HeightdZ = [];
pixelSize = 4.32;
for i = 1:size(colony3D,3)
    CC = bwconncomp(colony3D(:,:,i));
    MaskV2 = false(size(colony3D(:,:,i)));
    PixelNum = zeros(numel(CC.PixelIdxList),1);
    for p = 1:numel(CC.PixelIdxList)
        PixelNum(p) = numel(CC.PixelIdxList{p});
    end
    [~,iPN] = max(PixelNum);
    MaskV2(CC.PixelIdxList{iPN}) = true;
    [y_ids, x_ids] = ind2sub(size(MaskV2),find(MaskV2));
    x_c = mean(x_ids); % centoid of colony bottom region
    y_c = mean(y_ids);
    
    
    EdgeMask = bwdist(~MaskV2)<2.*MaskV2 & MaskV2;
    [outline_y, outline_x] = ind2sub(size(EdgeMask),find(EdgeMask));  % get the colony bottom colony outline
    
    distToCenter = hypot(outline_x - x_c, outline_y - y_c);
    angle = zeros(numel(outline_y),1);
    for n = 1:numel(outline_y)
        if outline_y(n) - y_c > 0
            cosX = (outline_x(n) - x_c)./distToCenter(n);
            angle(n) = round(4*(acosd(cosX)))/4;
        else
            cosX = (outline_x(n) - x_c)./distToCenter(n);
            angle(n) = -1*round(4*(acosd(cosX)))/4;
        end
    end
    
    mask_outline = false(size(MaskV2));
    distToCenter_outline = [];
    angle_outline = [];
    for v = -180:.25:180
        temp = distToCenter;
        temp(angle~=v) = 0;
        [distToCenter_outline(end+1),ind] = max(temp);
        mask_outline(outline_y(ind), outline_x(ind)) = 1;
        angle_outline(end+1) = v;
    end
    
    angleNeg = -180:0.25:0;
    anglePos = 0.25:0.25:180;
    [~,~,icNeg] = intersect(angleNeg, angle_outline, 'stable');
    [~,~,icPos] = intersect(anglePos, angle_outline, 'stable');
    
    Dist_angleNeg(:,i) = distToCenter_outline(icNeg)'* pixelSize;
    Dist_anglePos(:,i) = distToCenter_outline(icPos)'* pixelSize;
    Dist(:,i) = [Dist_angleNeg(:,i);Dist_anglePos(:,i)];
    HeightdZ(i) = (i-1)*dZ;
end
