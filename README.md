# ColonyMorphology
## Biref introduction
These MATLAB scripts are for 3D colony morphology detection and caculation. The height and max area of one colony are derived after processed by this scripts. The workfolw include loading the image (.tif) and meta file (.xlsx), detecting the outline of colony by thresholding the image gradient, caculating the height and area and analyzing them statistically.
## Dependency
1. MATLAB 2019a
2. ImageJ 
3. The scripts in Code directory （note: add these scripts to the PATH of your MATLAB)
## Input files
Load meta.xlsx ([meta](/example/meta.xlsx)) file. This file record the path of each image and basic parameters customized for each image.
## Usage
Here is an example. Open the main.m by matlab and run the pannels step by step for customizing some parameters. 
1. load image files(two fluorescence channels): [mCherry image](/example/Test-mCherry.tif) and [FITC image](/example/Test-FITC.tif)
2. set 8 paris of region of interest (ROI) of mCherry image and FITC image. Each pair is along the center of each colony. The average flurescence of each ROI along the z direction could be derived. This step is for determine the top and bottom slice of colony. We determine the slice with the biggest mCherry or FITC fluorescence change is the top or bottom slice. 
4. 
