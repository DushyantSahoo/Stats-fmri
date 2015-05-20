# load the library 

library(AnalyzeFMRI)
library(fastICA)
library(oro.nifti)
library(ForeCA)
library(MASS)
library(R.utils)


#convolve by Dushyant from Piazza
convolve2 <- function(x, y, conj=FALSE, type=c("circular", "open", "filter"))
{
  type <- match.arg(type)
  nx <- length(x)
  ny <- length(y)
  if (type == "circular") {
    fft_length <- max(nx, ny)
  } else {
    if (conj) {
      y <- rev(y)
      if (is.complex(y))
        y <- Conj(y)
      conj <- FALSE
    }
    nz <- nx + ny - 1
    fft_length <- 2^ceiling(log2(nz))
  }
  if (fft_length > nx)
    x[(nx+1):fft_length] <- as.integer(0)
  if (fft_length > ny)
    y[(ny+1):fft_length] <- as.integer(0)
  fy <- fft(y)
  if (conj)
    fy <- Conj(fy)
  z <- fft(fft(x) * fy, inverse=TRUE) / length(x)
  if (type == "open") {
    z <- z[1:nz]
  } else {
    if (type == "filter")
      z <- z[1:nx]
  }
  if (is.numeric(x) && is.numeric(y))
    z <- Re(z)
  if (is.integer(x) && is.integer(y))
    z <- as.integer(round(z))
  z
}

sub=c( "sub002" , "sub003"  ,"sub005",  "sub007",  "sub008",  "sub009",  "sub010",  "sub011"  ,"sub014" , "sub015",  "sub017"  ,"sub018"  ,"sub019" , "sub021"  ,"sub022" , "sub025",  "sub026"  ,"sub027",  "sub028",  "sub029",  "sub030",  "sub031"  ,"sub032" , "sub034",  "sub036" , "sub038"  ,"sub039",  "sub040"  ,"sub042",  "sub043"  ,"sub047",  "sub048")

for (sublength in 1:32){

# intialise the directory
  print(sub[sublength])
  intial_location1=paste("/media/dushyant/Entertainment/fmri_assignment/",sub[sublength],sep="")
  intial_location1=paste(intial_location1,"/model/model001/onsets/task001_run002/",sep="")
  intial_location=paste("/media/dushyant/Entertainment/fmri_assignment/",sub[sublength],sep="")
  intial_location=paste(intial_location,"/BOLD/task001_run002/",sep="")  
  AA<-readNIfTI(paste(intial_location,"bold.feat/filtered_func_data.nii.gz",sep=""), reorient = FALSE)
  A<-AA@.Data
value <- dim(A)
print("start")
a<-value[1]
b<-value[2]
c<-value[3]

# make 3D data linear
number <- array(0 , dim=c(value[1]*value[2]*value[3],value[4]))
for (ii in 1:a)
{
  for (jj in 1:b)
  {
    for (kk in 1:c)
    {
      
      number[(ii-1)*b*c+(jj-1)*c+kk,]<- A[ii,jj,kk,]
      
    }
  }
}

start.time <- Sys.time()
# define the model files
model1=paste(intial_location1,"cond001.txt",sep="")
model2=paste(intial_location1,"cond002.txt",sep="")
model3=paste(intial_location1,"cond003.txt",sep="")
model4=paste(intial_location1,"cond004.txt",sep="")

# intialise the parameters 
TR=2
volumes=179

# load the model files
Model1 = read.table(model1)
Model2 = read.table(model2)
Model3 = read.table(model3)
Model4 = read.table(model4)

#HRF function
x=array(0,dim=c(20))
i<-0
for (i in 1:20)
{
  x[i]=i
}

temp<- dgamma(x, shape=6,scale=1)-0.5*dgamma(x, shape=10,scale=1)
HRF<- array(0,dim=c(20))
for (i in 1:20)
{
  HRF[i]<-temp[i]
}
diffHRF <- diff(HRF)

# initialise the signal
Signal1<-array(0,dim=c(volumes))
Signal2<-array(0,dim=c(volumes))
Signal3<-array(0,dim=c(volumes))
Signal4<-array(0,dim=c(volumes))

# Model parameters
Model1init<-Model1$V1
Model1len<-Model1$V2
Model2init<-Model2$V1
Model2len<-Model2$V2
Model3init<-Model3$V1
Model3len<-Model3$V2
Model4init<-Model4$V1
Model4len<-Model4$V2

# put the model into the signal defined
for (i in 1:length(Model1init))
{
  for (j in 1:(length(Model1len)/TR))
  {
    Signal1[(Model1init[i]/TR)+j-1]<-1
  }
}
for (i in 1:length(Model2init))
{
  for (j in 1:(length(Model2len)/TR))
  {
    Signal2[(Model2init[i]/TR)+j-1]<-1
  }
}
for (i in 1:length(Model3init))
{
  for (j in 1:(length(Model3len)/TR))
  {
    Signal3[(Model3init[i]/TR)+j-1]<-1
  }
}
for (i in 1:length(Model4init))
{
  for (j in 1:(length(Model4len)/TR))
  {
    Signal4[(Model4init[i]/TR)+j-1]<-1
  }
}

# convolve HRF with the signal
bold1 <- convolve2(Signal1,HRF,type="open")
bold2 <- convolve2(Signal2,HRF,type="open")
bold3 <- convolve2(Signal3,HRF,type="open")
bold4 <- convolve2(Signal4,HRF,type="open")
bold01 <- convolve2(Signal1,diffHRF,type="open")
bold02 <- convolve2(Signal2,diffHRF,type="open")
bold03 <- convolve2(Signal3,diffHRF,type="open")
bold04 <- convolve2(Signal4,diffHRF,type="open")
bold0 <- array(1,dim=c(179))
X <- cbind(bold0,bold1[1:179],bold2[1:179],bold3[1:179],bold4[1:179],bold01[1:179],bold02[1:179],bold03[1:179],bold04[1:179])
stats <- array(0 , dim=c(value[1]*value[2]*value[3],1))

for (i in 1:(dim(number)[1]))
{
  Y <- number[i,]
  if (mean(Y)>0 ){
    #Y <- Y-mean(Y)
    
    
    Y <- whiten(Y)$U
    
    tempX <- X[1:179,]
    # OLS 
    
    # R_x
    R_x <- (solve(t(tempX)%*%(tempX)))%*%(t(tempX))
    
    # X is desing matrix and Y is input data
    beta = R_x%*%Y
    
    # estimated Y_hat
    Y_hat = tempX%*%beta
    
    #residuals
    residuals = Y-Y_hat
    
    # residual variance
    sigma_res = (t(residuals)%*%residuals)/171
    
    # contrast for sound vs no sound 
    
    con=array(1,dim=c(9))
    con[1]<-0
    
    # contrast for 2 nd assignment
    
    #con[3]<- 0
    #con[4]<- -1
    #con[5]<- 0
    #con[7]<- 0
    #con[8]<- -1
    #con[9]<- 0
    
    # variance total
    total <- sigma_res*(t(con)%*%(solve(t(tempX)%*%(tempX)))%*%con)
    
    
    stats[i,1] <- (t(con)%*%beta)/sqrt(total)
  }
  
}


# Convert single array data in to 3D data

t_stat <- array(0 , dim=c(a,b,c))
for (ii in 1:a)
{
  for (jj in 1:b)
  {
    for (kk in 1:c)
    {
      t_stat[ii,jj,kk] <- stats[(ii-1)*b*c+(jj-1)*c+kk,1]
    }
  }
}
f.write.analyze(mat = t_stat,file = paste(intial_location,"results_sound/t_stat",sep=""),size = "float",pixdim=c(3,3,3.54))
end.time <- Sys.time()
time.taken <- end.time - start.time
print(time.taken)
}
