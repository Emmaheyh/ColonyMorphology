# ColonyMorphology
## Biref introduction
These MATLAB scripts are for 3D colony morphology detection and caculation. The height and max area of one colony are derived after processed by this scripts. The workfolw include loading the image (.tif) and meta file (.xlsx), detecting the outline of colony by thresholding the image gradient, caculating the height and area and analyzing them statistically.
## Dependency
1. MATLAB 2019a
2. The scripts in Code directory （note: add these scripts to the PATH of your MATLAB)
## Input files
Load meta.xlsx ([meta](/example/meta.xlsx)) file. This file record the path of each image and basic parameters customized for each image.
Configure of meta.xlsx:/example/meta.xlsx ![meta](/example/meta_example1.png)   
![meta](/example/meta_example2.png)   
file: the name of strain  
mch_path: the path of mCherry photo  
fitc_path: the path of FITC photo  
Date: the date of this experiment 
Medium: the culture medium of this experiment  
Supplement: the supplement to culture medium  
Temp: culture temprature of this experiment  
OD600_Device: the device used for detect OD600 when normalizing cell density  
droplet_volume: the volume of bacteria slurry  
cultureTime: the cultivation time of colony  
culture_device: the container filled with cultivation agar  
photo_device: the device for capture the colony photoes  
dZ: the step length of z-stack when imaging by confocal microscope  
threshold: the threshold during image segmentation  
rectangle: the size of ROI during top and bottom slice identification  
sigma: the standard deviation used for filtrating image with a 2-D Gaussian smoothing kernel  
disk_size: the disk size when using close operation for image identification  
top/bottom: the top and bottom slice of this colony  
p_topx/p_topy: the x and y coordinates of ROI top left corner when identificate top slice using mCherry image  
p_botx/p_boty: the x and y coordinates of ROI top left corner when identificate bottom slice using FITC image  
## Usage
Here is an example. Open the ColonyInfo.m by matlab and run the pannels step by step for customizing some parameters. 
1. Load image files(two fluorescence channels): [mCherry image](/example/Test-mCherry.rar) (Test-mCherry.tif in example) and [FITC image](/example/Test-FITC.rar) (Test-FITC.tif in example).
2. Identify the top and bottom of each colony. Set 8 paris of region of interest (ROI) of mCherry image and FITC image. Each pair is along the center of each colony. The average flurescence of each ROI along the z stack could be derived. We determine the slice with the biggest mCherry or FITC fluorescence change is the top or bottom slice. After identifying the top and bottom slice of the colony, the height was next calculated by multiplication the number of colony images with the z-step size. These are accomplished by colonyBondary.m.  
![ROI](/example/ROI_mCherry.png) ![ROI](/example/ROI_FITC.png)

3. Identify the outline of each colony. We identified the edge of colony biofilm by denoising and thresholding the image gradient (MATLAB function, “imgaussfilt” and “imgrad”). This step also gave rise to an averaged mCherry signal from the edge of the colony at this plane. by applying this to each plane along the z-step, we will get the outline of them. Then, the area was calculated by converting the pixel number to the value of area. Additionally, in our experimental setting, we have 3 replicates of each kncokout strain, so we also caculate the average height and average max area of each strain and compare them with wildtype by student t test. These are accomplished by colonySize.m.  
![1](/example/algorithm.png)
4. Finally, the side view of each strain are presented by PlotColony.m.  
![glmZ_full](https://github.com/Emmaheyh/ColonyMorphology/assets/126593269/9c4a4e55-c4a0-4d59-b9d7-9b9ffadb1656)
## Output
The height, max area of each replicate and the average of them of each strain, the student t test results of knockout strains comparism with wildtype.  
Path of file: /example/meta_results.xlsx
