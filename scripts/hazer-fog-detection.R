############ run if hazer not installed ###############
# install.packages('hazer')
# install.packages('jpeg')

#######################################################

library(hazer)
library(jpeg)
library(data.table)

# set up the input image
images_dir <- '../data_raw/NEON.D01.HARV.DP1.00033/2017'

# get a list of all .jpg files in the directory
pointreyes_images <- dir(path = images_dir, 
                         pattern = '*.jpg',
                         recursive = TRUE,
                         ignore.case = TRUE, 
                         full.names = TRUE)



## 1) using a for loop
# number of images
n <- length(pointreyes_images)

# an empty matrix to fill with haze and A0 values
haze_mat <- data.table()

pb <- txtProgressBar(0, n, style = 3)

for(i in 1:n) {
  image_path <- pointreyes_images[i]
  img <- jpeg::readJPEG(image_path)
  haze <- getHazeFactor(img)
  
  haze_mat <- rbind(haze_mat, 
                    data.table(file = image_path, 
                               haze = haze[1], 
                               A0 = haze[2]))
  
  setTxtProgressBar(pb, i)
}


haze_mat[haze>0.4,foggy:=TRUE]
haze_mat[haze<=0.4,foggy:=FALSE]

fwrite(haze_mat[foggy==TRUE], "../data_out/foggy/NEON.D01.HARV.DP1.00033/2021.csv")


