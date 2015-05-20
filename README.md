# Stats-fmri
Complete Statistical Analysis of fMRI
1) First do the analysis for in FEAT 
2) We would be using the preprocessed images for the analysis using R and for registration also
3) First run the run_folder_ass.sh bash file which will generate all the relevant folders for storing the output images
4) Please Make relevant changes in the bash file and R file for folder configuration
4) Now run the R file complete_GLM1.R , it will do all the analysis for all the cases and store the output images in results folder
5) Now run the run_firt_assign.sh bash file which will output the registered images in output folder
6) Now make run001 to run002 in all the above scripts so that similar analysis takes place for second run also
7) Run Mean1.R to find the mean of all the images and t-stat threshold 
