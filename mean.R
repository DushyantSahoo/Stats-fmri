# mean for sound vs no sound

library(AnalyzeFMRI)
library(fastICA)

sub=c( "sub002" , "sub003"  ,"sub005",  "sub007",  "sub008",  "sub009",  "sub010",  "sub011"  ,"sub014" , "sub015",  "sub017"  ,"sub018"  ,"sub019" , "sub021"  ,"sub022" , "sub025",  "sub026"  ,"sub027",  "sub028",  "sub029",  "sub030",  "sub031"  ,"sub032" , "sub034",  "sub036" , "sub038"  ,"sub039",  "sub040"  ,"sub042",  "sub043"  ,"sub047",  "sub048")
sum_images<-array(0,dim=c(91,109,91))
thres_images<-array(0,dim=c(91,109,91))
for (sublength in 1:32){
  print(sub[sublength])
  intial_location=paste("/media/dushyant/Entertainment/fmri_assignment/",sub[sublength],sep="")
  intial_location1=paste(intial_location,"/BOLD/task001_run001/",sep="") 
  intial_location2=paste(intial_location,"/BOLD/task001_run002/",sep="")  
  AA<-readNIfTI(paste(intial_location1,"output_sound/t_stat.nii.gz",sep=""), reorient = FALSE)
  BB<-readNIfTI(paste(intial_location2,"output_sound/t_stat.nii.gz",sep=""), reorient = FALSE)
  A<-AA@.Data
  B<-BB@.Data
  value <- dim(A)
  a<-value[1]
  b<-value[2]
  c<-value[3]
  sum_images<-array(0,dim=c(a,b,c))
  sum_images<-sum_images+A+B
  M1<- A
  M2<- B
  M1[A<1.964]<-0
  M2[B<1.964]<-0
  thres_images<-thres_images+M1+M2
}
sum_images<-sum_images/64
thres_images<-thres_images/64
f.write.analyze(mat = sum_images,file = "/media/dushyant/Entertainment/fmri_assignment/stats_analysis_output/sum_images",size = "float",pixdim=c(2,2,2))
f.write.analyze(mat = thres_images,file = "/media/dushyant/Entertainment/fmri_assignment/stats_analysis_output/thres_images",size = "float",pixdim=c(2,2,2))