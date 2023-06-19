function [colony_img,mask] = colonyMask(img,top,bottom,varargin)
%detect fluorescence signal of each slice of colony and form a round-shape
%plate mask.

%usage:
%    [colony_img,mask] = colonyMask(img,top,bottom)
%    [colony_img,mask] = colonyMask(img,top,bottom,threshold)
%    [colony_img,mask] = colonyMask(img,top,bottom,threshold,'sigma',value,'disk_size',value)
%    [colony_img,mask] = colonyMask(img,top,bottom,threshold,'sigma',value,'disk_size',value,'display',value)

% The input img should be a 3-dimensional matrix of microscope images, with
% the three indices representing y, x, and z respectively.

%the input top and bottom is the first and last slice of the colony
%caculated by changes of flourescence intensity.

%the optional input threshold is a foldchange of multithresh function and
%the default value is .85.

%the optional input sigma is the standard deviation for imgaussflit, this
%function helps filtrate noise of img.

%the optional input disk_size is a parameter of function imopen and
%imclose, is the disk size for mathematical morphology caculation.

%the optional input display determains display the mask and colony_img or
%not. the default value is 1 which means display the iPlayer.

%the output colony_img is colony image cutoff by its top and bottom slice.

%the output mask is a double matrix of 0 or 1.

%
% Written by Yihui He
% Version 0.1. Created on Aug, 15, 2022.

argin = inputParser;
addOptional(argin,'threshold',0.85)
addParameter(argin,'sigma',0.5)
addParameter(argin,'disk_size',2)
addParameter(argin,'display',1)
parse(argin,varargin{:})
thresh = argin.Results.threshold;
sigma = argin.Results.sigma;
disk_size = argin.Results.disk_size;
display = argin.Results.display;


colony_img = img(:,:,top:bottom); % remove other slide

% filter noise and calculate gradient for image

smoothImage = zeros(size(colony_img,1),size(colony_img,2),size(colony_img,3));
imgrad = zeros(size(colony_img,1),size(colony_img,2),size(colony_img,3));

for k = 1:size(colony_img,3)
    smoothImage(:,:,k) = imgaussfilt(colony_img(:,:,k),sigma); % filters image A with a 2-D Gaussian smoothing kernel with standard deviation specified by sigma
    imgrad(:,:,k) = imgradient(smoothImage(:,:,k)); %Gradient magnitude and direction of an image
end
% get colony volume and max area
mask = zeros(size(imgrad,1),size(imgrad,2),size(imgrad,3));

for i = 1:size(imgrad,3)
     threshold = thresh * multithresh(imgrad(:,:,i));
     mask_slice = imgrad(:,:,i)>threshold;
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
     mask(:,:,i) = mask_slice_filled;     
end

if display == 1
    iPlayer(colony_img,'Mask',logical(mask))
end