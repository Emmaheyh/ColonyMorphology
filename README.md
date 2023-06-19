# ColonyMorphology
## Biref introduction
These MATLAB scripts are for 3D colony morphology detection and caculation. the workfolw include loading the image (.tif) and meta file (.xlsx), detecting the outline of colony by thresholding the image gradient, caculating the height and area and analyzing them statistically.
## Dependency
1. MATLAB 2019a
2. The scripts in Code directory （note: add these scripts to the PATH of your MATLAB)
## Input files
load image files(two fluorescence channels): [mCherry image](/example/Test-mCherry.tif) and [FITC image](/example/Test-FITC.tif)
meta file: [meta](/example/meta.xlsx).
load meta.xlsx file for recording the information of experiments and message during data processing.
## Usage
Here is an example.
