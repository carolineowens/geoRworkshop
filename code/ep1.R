# R Geospatial Workshop - UCSB Library Collaboratory
# https://ucsbcarpentry.github.io/2021-05-13-GeospatialR/


# Load Packages -----------------------------------------------------------

library(raster) #load before dplyr to avoid select conflict
library(rgdal)
library(ggplot2)
library(dplyr)

# Load Data ---------------------------------------------------------------

# within Airborne RS, have Harvard Forest and San Joaquin Valley
# for HARV, have Digital Surface Model and Digital T Model files; 

# get file information

GDALinfo("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif")

# gives X,Y origin distance from origin point of CRS
# resolution is 1x1 
# filetype is geotiff
# apparent band summary/stats means it took a sample

# load file info into an object
HARV_dsmCrop_info <- capture.output(GDALinfo("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif"))
HARV_dsmCrop_info

# create raster object
DSM_HARV <- raster("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif")
DSM_HARV #not a lot of difference between the standard output of a raster object vs the standard output of its metadata

#summary stats of raster
summary(DSM_HARV) #brings up warning that this is an estimate
#to check all cells:
summary(DSM_HARV, maxsamp = ncell(DSM_HARV))

#changes values slightly but not much - no NAs in the dataset


# Visualization -----------------------------------------------------------

#ggplot requires a dataframe, not a raster

df_DSM_HARV <- as.data.frame(DSM_HARV, xy = TRUE)
str(df_DSM_HARV) #has 2mil obs of x, y, and HARV_dsmCrop (numeric value - elev in m)

ggplot(data = df_DSM_HARV)+
  geom_raster(aes(x=x, y=y, fill = HARV_dsmCrop))+
  scale_fill_viridis_c()+ #good for colorblind
  coord_quickmap() #helps the map draw faster and maintain projection 
# quickmap is basically a fast cheat to plot a basic map without having to go through the mathematical transformations for a real projection

#check min and max values

minValue(DSM_HARV)
maxValue(DSM_HARV)

#store for faster retrieval
DSM_HARV <- setMinMax(DSM_HARV) #doesn't change the min/max values

#to get the min/max from the dataframe version

min(df_DSM_HARV$HARV_dsmCrop)

summary(df_DSM_HARV)

df_DSM_HARV %>% 
  summarise(min(HARV_dsmCrop), max(HARV_dsmCrop))

#how many bands?
nlayers(DSM_HARV)

#highlight bad data
ggplot(data = df_DSM_HARV)+
  geom_raster(aes(x=x, y=y, fill = HARV_dsmCrop))+
  scale_fill_viridis_c(na.value = 'deeppink')+ #good for colorblind
  coord_quickmap()

#now load SJ data
LandSat_SJER <- raster('data/NEON-DS-Airborne-Remote-Sensing/SJER/DTM/SJER_dtmCrop.tif')
GDALinfo('data/NEON-DS-Airborne-Remote-Sensing/SJER/DTM/SJER_dtmCrop.tif')
df_LandSat_SJER = as.data.frame(LandSat_SJER, xy=T)

#check for bad values here
#user descriptive funcitons
min(df_LandSat_SJER$SJER_dtmCrop)
which(is.na(df_LandSat_SJER$SJER_dtmCrop))

#visual method
ggplot(data = df_LandSat_SJER)+
  geom_raster(aes(x=x, y=y, fill = SJER_dtmCrop))+
  scale_fill_viridis_c(na.value = 'deeppink')+ #good for colorblind
  coord_quickmap()

#histogram of values

ggplot(data = df_LandSat_SJER)+
  geom_histogram(aes(SJER_dtmCrop))


# Challenge ---------------------------------------------------------------

GDALinfo('data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_DSMhill.tif')

#resolution is 1 so res is 1 m, so a 5pixelx5pixel would be 5mx5m
#hillshade has the same CRS as DSM data