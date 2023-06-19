function [BottomLine,EdgeLine,TopLine,fillout] = PlotColony(img,top,bottom,color,varargin)
%plot the colony elevation based on confocal image.

% The input img should be a 3-dimensional matrix of mcherry channel 
%microscope images, with the three indices representing y, x, and z respectively.

% the input top and bottom is the top and bottom frame number of the img
% respectively. 

% the input color is rgb of colors.

% the optional input LineAlpha and StdAlpha is the transparency of the
% ploted line and std shadow. Default is 0.5 and 0.3, respectively.

% the optional input LineWidth is the width of ploted line. Default is 3.

%
% Written by Yihui He
% Version 0. Created on Dec, 21, 2022.


argin = inputParser;
addOptional(argin,'dZ',15.05)
addParameter(argin,'LineAlpha',0.8)
addParameter(argin,'StdAlpha',0.3)
addParameter(argin,'LineWidth',3)
parse(argin,varargin{:})
dZ = argin.Results.dZ;

%top = argin.Results.top;
%bottom = argin.Results.bottom;
%color = argin.Results.Color;
LineAlpha = argin.Results.LineAlpha;
StdAlpha = argin.Results.StdAlpha;
LineWidth = argin.Results.LineWidth;

hold on;
[~,mask] = colonyMask(img,top,bottom,'display',0);
mask = flip(mask,3);
[Dist, HeightdZ] = colony3Doutline(mask, dZ);
i = numel(HeightdZ);
BottomLine = plot([0 mean(Dist(:,1))],[HeightdZ(1) HeightdZ(1)],'LineWidth',LineWidth,'Color',color); % the bottom line
BottomLine.Color(4) = LineAlpha;
EdgeLine = plot(mean(Dist),0:dZ:HeightdZ(i), '-','LineWidth',LineWidth,'Color',color); % the elevation line
EdgeLine.Color(4) = LineAlpha;
TopLine = plot([0 mean(Dist(:,i))],[HeightdZ(i) HeightdZ(i)],'LineWidth',LineWidth,'Color',color); % the top line
TopLine.Color(4) = LineAlpha;
mean_Dist = mean(Dist,1);
std_Dist = std(Dist,1);
fillout = fill([mean_Dist+std_Dist, fliplr(mean_Dist-std_Dist)],[HeightdZ fliplr(HeightdZ)],color,'FaceAlpha',StdAlpha,'linestyle','none'); % fill the std area
hold off
