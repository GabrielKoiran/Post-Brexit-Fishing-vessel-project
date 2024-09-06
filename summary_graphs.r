##############################################################################################################################

#PAI PROJECT DO-FILE
#2024
#GABRIEL KOIRAN PORTIER

#FILE 3: SUMMARY GRAPHS (summary_graphs)

##############################################################################################################################


## PACKAGES ##


install.packages("tidyr")
install.packages("dplyr")
install.packages("stringr")
install.packages("table1") 
install.packages("tidyverse") 
install.packages("ggplot2") 
install.packages("flextable")
install.packages("readxl")
install.packages("magrittr")
install.packages("stargazer")
install.packages("lmtest")
install.packages("sandwich")
install.packages("ivreg")
install.packages("lubridate")
install.packages("lessR")
install.packages("stats")
install.packages("jtools")
install.packages("writexl")
install.packages("hrbrthemes")
install.packages("gridExtra")
install.packages("ggpubr")
install.packages("listr")
install.packages("RColorBrewer")
install.packages("magick")


library("tidyr")
library("dplyr")
library("stringr")
library("table1") 
library("tidyverse") 
library("ggplot2") 
library("flextable")
library("readxl")
library("magrittr")
library("stargazer")
library("lmtest")
library("sandwich")
library("ivreg")
library("lubridate")
library("lessR")
library("stats")
library("jtools")
library("writexl")
library("hrbrthemes")
library("gridExtra")
library("ggpubr")
library("listr")
library("RColorBrewer")
library("magick")


#Packages for maps

install.packages("sf")
install.packages("terra")
install.packages("spData")
install.packages("spDataLarge", repos='https://nowosad.github.io/drat/', type='source')
install.packages("tmap")
install.packages("leaflet")
install.packages("sp")
install.packages("tidygeocoder")
install.packages("rgeos")

library("sf")
library("terra")
library("spData")
library("spDataLarge")
library("tmap")
library("leaflet")
library("sp")
library("tidygeocoder")
library("rgeos")



##############################################################################################################################


## IMPORT DATA FROM PREVIOUS STEP ##

sum_quartier <- read_csv("sum_quartier.csv")

treatment_progress <- read_csv("treatment_progress.csv")

zone <- read_csv("zone.csv")

ric <- read_csv("ric.csv")

treated_list <- read_csv("treated_list.csv")

#Correct Nantes
zone[30,1] <- 'NA'

##############################################################################################################################


## GRAPH OF PROGRESSIVE TREATMENT ##

# Transform treatment_progress table into stacked

treatment_progress_graph <- bind_rows(treatment_progress, treatment_progress, treatment_progress, treatment_progress)

treatment_progress_graph[366:730,2] <- treatment_progress_graph[366:730,3] 
treatment_progress_graph[731:1095,2] <- treatment_progress_graph[731:1095,4]
treatment_progress_graph[1096:1460,2] <- treatment_progress_graph[1096:1460,5]

treatment_progress_graph <- treatment_progress_graph[,1:2]

treatment_progress_graph$Metric <- NA

treatment_progress_graph[1:365,3] <- 'Number of vessels'
treatment_progress_graph[366:730,3]  <- 'Volume'
treatment_progress_graph[731:1095,3] <- 'Power'
treatment_progress_graph[1096:1460,3] <- 'Length'

names(treatment_progress_graph) <- c("Date", "Capacity", "Metric")

#Create graph

treatment_plot <- ggplot(data=treatment_progress_graph, aes(x=Date, y=Capacity, group=Metric, color=Metric))+ 
  geom_line()

ggsave(treatment_plot, height = 5, width = 7, filename = "treatment_plot.png")


##############################################################################################################################


## MAP OF FRANCE WITH SIZE/INTENSITY OF TREATMENT PER ZONE ##


#See for other guidelines
# https://r.geocompx.org/spatial-class
# https://www.geeksforgeeks.org/making-maps-with-r/


# Add complete quartier name using zone corrrespondance to sum_quartier

sum_quartier$zone <- NA

for (i in 1:nrow(sum_quartier)){
  sum_quartier$zone[i] <- zone$Quartier[zone$Code == sum_quartier$quartier[i]]
}

# Add coordinates to sum_quartier automatically and make map table summarized graph
# https://lrouviere.github.io/TUTO_VISU_R/08-carto.html

cord <- geocode(tibble(address=sum_quartier$zone), address)

sum_quartier <- cbind(sum_quartier, cord)

map_table <- sum_quartier[,c(6,10:13,15,16)]

#Create geometry coordinates object
# https://tmieno2.github.io/R-as-GIS-for-Economists/turning-a-data-frame-of-points-into-an-sf.html

criees <- st_as_sf(map_table, coords = c("long","lat"))
criees <- st_set_crs(criees, 4326)

# Load shape of France
# downloaded https://simplemaps.com/gis/country/fr

fr <- st_read("fr_shp/fr.shp")

#Disolve borders between regions
#https://mgimond.github.io/Spatial/vector-operations-in-r.html

fr <- st_union(fr, by_feature = FALSE)

# Create map
# https://r-graph-gallery.com/330-bubble-map-with-ggplot2.html

# For how to delete axis
# https://ggplot2.tidyverse.org/reference/theme.html
# https://www.geeksforgeeks.org/remove-axis-labels-and-ticks-in-ggplot2-plot-in-r/

#For how to delete part of legend
# https://stackoverflow.com/questions/14604435/turning-off-some-legends-in-a-ggplot

#How to rename legend sections
# https://www.datanovia.com/en/blog/how-to-change-ggplot-labels/#:~:text=You%20can%20use%20labs(),(aes(fill%20%3D%20dose))

#Color scale
#https://sjspielman.github.io/introverse/articles/color_fill_scales.html

#Random links
#https://ggplot2-book.org/scales-colour
#https://r-spatial.org/r/2018/10/25/ggplot2-sf.html
#https://r-graph-gallery.com/map.html
#https://rdrr.io/cran/spData/man/world.html
#https://www.geeksforgeeks.org/making-maps-with-r/
#https://lrouviere.github.io/TUTO_VISU/faire-des-cartes-avec-r.html
#https://r-tmap.github.io/tmap-book/visual-variables.html
#https://jamescheshire.github.io/learningR/mapping-crime-in-camden.html
#https://lrouviere.github.io/TUTO_VISU_R/08-carto.html
#https://tmieno2.github.io/R-as-GIS-for-Economists/turning-a-data-frame-of-points-into-an-sf.html
#https://r-graph-gallery.com/330-bubble-map-with-ggplot2.html

carte_france_nombre_retires <- ggplot(fr) +
  geom_sf() +
  geom_sf(data = criees, aes (color=criees$part_volume, size=criees$n_treated, alpha=0.8), linewidth = 0) +
  scale_color_gradient(low = "blue", high = "red") +
  theme_classic() +
  theme(axis.text.x=element_blank(), 
        axis.ticks.x=element_blank(), 
        axis.text.y=element_blank(), 
        axis.ticks.y=element_blank(),
        axis.line=element_blank()) +
  guides(alpha = "none") +
  labs(size = "Number of vessels treated") +
  labs(colour = "Share of initial volume treated")

ggsave(carte_france_nombre_retires, height = 5, width = 7, filename = "carte.png")


##############################################################################################################################


## GRAPH EXTRAPOLATED TRAJECTORY FOR EACH BOAT that was treated - number of sales (ln) ##

#Create empty list to store graphs in

plot_list <- vector(mode = "list", length = 86)

#Loop: create graph for each treated identifier and add to big graph

for (i in 1:nrow(treated_list)) {

#identify immat in list of treated vessels
immat <- treated_list[i,2]

#create separate df with observations for that vessel
plot_df <- ric[ric$code_bat==as.numeric(immat),]

#Identify imputed or observed status for each observation
plot_df$status <- NA
plot_df[is.na(plot_df$c1lntransac),34] <- "Imputed"
plot_df[is.na(plot_df$status),34] <- "Observed"

#Create plot with no axis titles or legend but graph title = vessel identifier. 
#Inside if statement to have version with 2 colors (some imputed) and version with 1 (all observed)

if ("Imputed" %in% plot_df$status) {

#Create a custom color scale
  color0 <- c("red", "blue")
  names(color0) <- levels(plot_df$status)
  color1 <- scale_colour_manual(name = "status",values = color0)
  
  #do plot
plot_vessel <- ggplot(plot_df, aes(x=yearmonth, y=c3lntransac, color=status)) +
    geom_line(color="black") +
    theme_ipsum() +
    geom_point(size=2) +
    theme(axis.title.x = element_blank()) +
    theme(axis.title.y = element_blank()) +
    theme(legend.position = "none") +
    ggtitle(immat) +
    color1
  
} else {
  
  
#Create a custom color scale
  color0 <- c("blue")
  names(color0) <- levels(plot_df$status)
  color1 <- scale_colour_manual(name = "status",values = color0)

  #do plot
plot_vessel <- ggplot(plot_df, aes(x=yearmonth, y=c3lntransac, color=status)) +
    scale_fill_manual(values = c("blue")) +
    geom_line(color="black") +
    theme_ipsum() +
    geom_point(size=2) +
    theme(axis.title.x = element_blank()) +
    theme(axis.title.y = element_blank()) +
    theme(legend.position = "none") +
    ggtitle(immat) +
    color1
  
}

#Assign plot to spot on plot list and delete plot
plot_list[[i]] <- plot_vessel

}

# Create combined graph and print on one big image

combined_plots <- do.call(grid.arrange, plot_list)

ggsave(combined_plots, height = 50, width = 50, filename = "plots_treated_sales.png", limitsize=FALSE)


##############################################################################################################################


## GRAPH EXTRAPOLATED TRAJECTORY FOR EACH BOAT (random sample of 250 boats) (output as several images) - number of sales (ln) ##

#Vector of unique vessel identifiers and subset first 250

unique_vessels <- unique(ric$code_bat)
unique_vessels <- unique_vessels[c(1:250)]

#Same procedure as before to create graphs

plot_list <- vector(mode = "list", length = 250)

for (i in 1:length(unique_vessels)) {
  
  immat <- unique_vessels[i]
  
  plot_df <- ric[ric$code_bat==as.numeric(immat),]
  
  plot_df$status <- NA
  plot_df[is.na(plot_df$c1lntransac),34] <- "Imputed"
  plot_df[is.na(plot_df$status),34] <- "Observed"

  if ("Imputed" %in% plot_df$status) {
    
    color0 <- c("red", "blue")
    names(color0) <- levels(plot_df$status)
    color1 <- scale_colour_manual(name = "status",values = color0)
    
    plot_vessel <- ggplot(plot_df, aes(x=yearmonth, y=c3lntransac, color=status)) +
      geom_line(color="black") +
      theme_ipsum() +
      geom_point(size=2) +
      theme(axis.title.x = element_blank()) +
      theme(axis.title.y = element_blank()) +
      theme(legend.position = "none") +
      ggtitle(immat) +
      color1
    
  } else {
    
    
    color0 <- c("blue")
    names(color0) <- levels(plot_df$status)
    color1 <- scale_colour_manual(name = "status",values = color0)
    
    plot_vessel <- ggplot(plot_df, aes(x=yearmonth, y=c3lntransac, color=status)) +
      scale_fill_manual(values = c("blue")) +
      geom_line(color="black") +
      theme_ipsum() +
      geom_point(size=2) +
      theme(axis.title.x = element_blank()) +
      theme(axis.title.y = element_blank()) +
      theme(legend.position = "none") +
      ggtitle(immat) +
      color1
    
  }
  
  plot_list[[i]] <- plot_vessel
  
}

#By 10 groups of 25, print plots onto separate files

for (i in 1:10) {
  short_list <- plot_list[(i*25-24):(i*25)]
  combined_plots <- do.call(grid.arrange, short_list)
  ggsave(combined_plots, height = 20, width = 20, filename = paste(i,"plots_random_sales.png",sep="_"))
}

#Merge images into one big pdf:

for (i in 1:10) {
  merged_plot_image <- image_read(paste(i,"plots_random_sales.png",sep="_"))
  assign(paste("img",i,sep="_"), merged_plot_image)
}

image_write(c(img_1, img_2, img_3, img_4, img_5, img_6, img_7, img_8, img_9, img_10)
            , format = "pdf", "plots_random_sales.pdf")


##############################################################################################################################


## MAP VESSELS ONTO SPACE OF CHARACTERISTICS (LENGTH, TONNAGE) ##

char_space <- ggplot(ric, aes(x = length, y = tonnage, color = ntraite)) + 
  geom_point() + 
  theme_minimal() +
  theme(legend.position = "none") +
  ggtitle("All vessels")

ggsave(char_space, height = 50, width = 50, filename = "char_space.png", limitsize=FALSE)


##############################################################################################################################



