##############################################################################################################################

#PAI PROJECT DO-FILE
#2024
#GABRIEL KOIRAN PORTIER

#FILE 4: COUNTERFACTUAL ESTIMATION (counterfactual_estimation)

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
install.packages("haven")
install.packages("fect")
install.packages("gridExtra")
install.packages("synthdid")
install.packages("devtoold")
devtools::install_github("synth-inference/synthdid")

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
library("haven")
library("fect")
library("gridExtra")
library("synthdid")


##############################################################################################################################


## IMPORT PRIMARY DATA AND EXPORT CLEANED TABLE ##

#Import RIC data base (month x vessel cell observations)

ric <- read_dta("ricPAItemptt.dta")

# Delete un-necessary columns and rename

ric <- ric[,-c(7,15,16,18,19,20,22,23,26,27,32:35,37,39,41:50)]

colnames(ric)[18] <- "maingear"
colnames(ric)[19] <- "length"
colnames(ric)[20] <- "tonnage"
colnames(ric)[21] <- "power"

#Save
  
write_csv(ric, "ric.csv")


##############################################################################################################################


## SET-UP FOR COUNTERFACTUAL ESTIMATION ##


#Set unit characteristics as average over time so that unit invariant

ric <- ric %>% 
  group_by(code_bat) %>% 
  mutate(length = mean(length), tonnage = mean(tonnage), power = mean(power))

#Add variables in ric for counter-factual estimates

ric$simulatemt <- ric$c3lnmt
ric$simulateqte <- ric$c3lnqte
ric$simulatetransac <- ric$c3lntransac

#Add variables for adjusted counterfactual estimates: for each outcome, two scenarii, a and b

ric$mt_cf_a <- ric$simulatemt
ric$mt_cf_b <- ric$simulatemt
ric$qte_cf_a <- ric$simulateqte
ric$qte_cf_b <- ric$simulateqte
ric$transac_cf_a <- ric$simulatetransac
ric$transac_cf_b <- ric$simulatetransac

# Define treated individuals (those treated with some observed values)

immat_list <- c(152947, 273986, 294534, 318050, 384579, 425048, 
                462623, 463340, 488858, 513188, 518388, 518497, 528889, 
                544899, 555037, 555180, 555513, 555524, 565125, 572419, 
                579737, 584842, 611916, 615518, 623026, 638739, 638750, 
                639926, 639931, 640316, 642093, 642420, 642585, 642599, 
                644630, 644968, 649729, 655426, 660607, 681131, 683475, 
                685083, 686620, 691417, 711630, 711681, 716706, 721150, 
                722678, 722685, 724521, 730410, 730412, 730703, 730804, 
                732307, 734863, 735990, 749742, 752559, 763882, 764603, 
                769454, 790964, 797377, 804691, 851457, 870580, 898403, 
                898417, 898456, 899833, 905646, 907446, 911294, 912361, 
                916075, 916455, 922468, 922599, 923117, 924832, 925093)


##############################################################################################################################


## COUNTERFACTUAL ESTIMATION FOR VALUE, QUANTITY AND SALES (INCLUDING GRAPHS FOR VALUE) ##


#Set up count variable and empty list for graphs

neighboring_controls_list <- as.list(1:83)
synth_dif_list <- as.list(1:76)
count=0


# Loop through the treated individuals

for (immat in immat_list) {

# Keep only current treated vessel and all control vessels  

sub_ric <- ric %>% 
    filter(code_bat == immat | ntraite == 0)

# Store characteristics of the treated vessel
  
length_treated <- mean(sub_ric$length[sub_ric$ntraite == 1])
power_treated <- mean(sub_ric$power[sub_ric$ntraite == 1])
tonnage_trated <- mean(sub_ric$tonnage[sub_ric$ntraite == 1])
gear_trated <- as.character(sub_ric$maingear[sub_ric$ntraite == 1][1])

#Keep as controls only those that are same gear, and +/- 20% of length and tonnage if <25m, and all >24m if >25m

if ( (ric[ric$code_bat == immat,]$length)[1] < 25) {
  
  sub_ric <- sub_ric %>% 
    filter( code_bat == immat | (ntraite == 0
                                 & length>0.8*length_treated & length<1.2*length_treated 
                                 #& power>0.8*power_treated & power<1.2*power_treated KEEP OUT POWER CRITERION FOR NOW
                                 & tonnage>0.8*tonnage_trated & tonnage<1.2*tonnage_trated
                                 & maingear == gear_trated) )
  
}

else {
  
  sub_ric <- sub_ric %>% 
    filter( code_bat == immat | (ntraite == 0
                                 & length>24
                                 & maingear == gear_trated) )
  
}


#Replace all NA's by 0 and keep only time periods where treated vessel is observed
# and controls vessels that have observations during the whole presence of the treated vessel

sub_ric[is.na(sub_ric)] <- 0

for ( time in 1:100 ) {
  
  if ( sub_ric[ (sub_ric$yearmonth==time & sub_ric$ntraite==1) , "c3lnmt"] == 0) {
    
    sub_ric <- sub_ric %>% 
      filter( yearmonth != time )
  }
  
  else break
  
}

for ( codebat in unique(sub_ric$code_bat) ) {
  
  if ( sub_ric[ (sub_ric$code_bat==codebat & sub_ric$yearmonth==min(sub_ric$yearmonth)), "c3lnmt"] == 0) {
    
    sub_ric <- sub_ric %>% 
      filter( code_bat != codebat )
    
  }
  
}

# Go to next vessel in loop if no controls or only one control

if ( (length(unique(sub_ric$code_bat))==1)  | (length(unique(sub_ric$code_bat))==2)  ) {
  
  next
  
}


# Graph for each vessel characteristics of treated and controls (and add to vector of graphs)

plot_dimensions <- ggplot(sub_ric, aes(x = length, y = tonnage, color = ntraite)) + 
  geom_point() + 
  theme_minimal() +
  theme(legend.position = "none") +
  ggtitle(immat)

count=count+1
neighboring_controls_list[[count]] <- plot_dimensions



# FECT ESTIMATOR FOR VALUE

#out.fect <- fect(c3lnmt ~ timetraite + length + tonnage + power, data = sub_ric, index = c("gbat","yearmonth"), method = "fe")


# SYNTHETIC DIF AND DIF ESTIMATOR FOR VALUE (INCLUDING GRAPH)


#Estimate synthetic dif and dif model for vessel
panel_sub_ric <- panel.matrices(panel=as.data.frame(sub_ric), unit= "code_bat", time="yearmonth", outcome="c3lnmt", treatment="timetraite")
syntdid_sub_ric <- synthdid_estimate(panel_sub_ric$Y, panel_sub_ric$Nx0, panel_sub_ric$T0)

#Count number of controls total and used
num_control_used <- length(synthdid_units_plot(syntdid_sub_ric))
num_control <- length(unique(sub_ric$code_bat))-1

#Plot synthetic dif and dif model for vessel and add to vector
did_plot <- synthdid_plot(syntdid_sub_ric, overlay=1, line.width=1, trajectory.alpha=1, effect.alpha=0,
                          diagram.alpha=0, onset.alpha=1) +
  theme(legend.position="none") +
  ggtitle(immat) +
  annotate("text", x=10, y=12, label= paste(num_control, " controls, ", num_control_used, " used."))

synth_dif_list[[count]] <- did_plot

# Generate counterfactual estimates
estimate <- synthdid_estimate(panel_sub_ric$Y, panel_sub_ric$N0, panel_sub_ric$T0)
estimate_curve <- synthdid_effect_curve(estimate)

# Add counterfactual estimates to ric database
ric[ (ric$code_bat == immat & ric$timetraite == 1), "simulatemt"] <-
  ric[ (ric$code_bat == immat & ric$timetraite == 1), "simulatemt"] - estimate_curve



# SYNTHETIC DIF AND DIF ESTIMATOR FOR QUANTITY


#Estimate synthetic dif and dif model for vessel and generate counterfactual estimates
panel_sub_ric <- panel.matrices(panel=as.data.frame(sub_ric), unit= "code_bat", time="yearmonth", outcome="c3lnqte", treatment="timetraite")
estimate <- synthdid_estimate(panel_sub_ric$Y, panel_sub_ric$N0, panel_sub_ric$T0)
estimate_curve <- synthdid_effect_curve(estimate)

# Add counterfactual estimates to ric database
ric[ (ric$code_bat == immat & ric$timetraite == 1), "simulateqte"] <-
  ric[ (ric$code_bat == immat & ric$timetraite == 1), "simulateqte"] - estimate_curve


# SYNTHETIC DIF AND DIF ESTIMATOR FOR SALES


#Estimate synthetic dif and dif model for vessel and generate counterfactual estimates
panel_sub_ric <- panel.matrices(panel=as.data.frame(sub_ric), unit= "code_bat", time="yearmonth", outcome="c3lntransac", treatment="timetraite")
estimate <- synthdid_estimate(panel_sub_ric$Y, panel_sub_ric$N0, panel_sub_ric$T0)
estimate_curve <- synthdid_effect_curve(estimate)

# Add counterfactual estimates to ric database
ric[ (ric$code_bat == immat & ric$timetraite == 1), "simulatetransac"] <-
  ric[ (ric$code_bat == immat & ric$timetraite == 1), "simulatetransac"] - estimate_curve


# ADJUSTMENT FOR LACK OF DATA (CORRECTION DUE TO EARLIER IMPUTATION) - ADJUSTMENT OF COUNTERFACTUAL ESTIMATES


#Imputation rule: Trajectory "a" is adjusted for share of unobserved time points over whole time period.
#Trajectory "b" is adjusted for share of unobserved time points over last 6 time periods.

#Compute total shareand 6 month share of observed time points

pre_treatment_length <- nrow ( sub_ric[ (sub_ric$code_bat==immat & sub_ric$timetraite==0),] )

share <- 
  nrow ( sub_ric[ (sub_ric$code_bat==immat & sub_ric$c1lntransac!=0 & sub_ric$timetraite==0),] ) / pre_treatment_length

share6 <- 
  nrow ( (sub_ric[sub_ric$code_bat==immat,])[(pre_treatment_length-5):pre_treatment_length,] ) / 6


# Adjust trajectory

ric[ric$code_bat==immat,]$mt_cf_a <- ric[ric$code_bat==immat,]$simulatemt*share
ric[ric$code_bat==immat,]$mt_cf_b <- ric[ric$code_bat==immat,]$simulatemt*share6
ric[ric$code_bat==immat,]$qte_cf_a <- ric[ric$code_bat==immat,]$simulateqte*share
ric[ric$code_bat==immat,]$qte_cf_b <- ric[ric$code_bat==immat,]$simulateqte*share6
ric[ric$code_bat==immat,]$transac_cf_a <- ric[ric$code_bat==immat,]$simulatetransac*share
ric[ric$code_bat==immat,]$transac_cf_b <- ric[ric$code_bat==immat,]$simulatetransac*share6


}






##############################################################################################################################


## OUTPUT GRAPHS AND DATA ##


# Create combined graph (of neighboring controls characteristcs) and print on one big image

combined_plots <- do.call(grid.arrange, neighboring_controls_list)
ggsave(combined_plots, height = 50, width = 50, filename = "neighboring_controls.png", limitsize=FALSE)

# Create combined graph (of dif in dif synth for value) and print on one big image

combined_dif_graphs <- do.call(grid.arrange, synth_dif_list)
ggsave(combined_dif_graphs, height = 50, width = 50, filename = "synth_dif.png", limitsize=FALSE)

# Output RIC data with counterfactual estimates after computing high and low scenario


ric$transac_cf_high <- pmax(ric$transac_cf_a, ric$transac_cf_b)
ric$transac_cf_low <- pmin(ric$transac_cf_a, ric$transac_cf_b)

ric$mt_cf_high <- pmax(ric$mt_cf_a, ric$mt_cf_b)
ric$mt_cf_low <- pmin(ric$mt_cf_a, ric$mt_cf_b)

ric$qte_cf_high <- pmax(ric$qte_cf_a, ric$qte_cf_b)
ric$qte_cf_low <- pmin(ric$qte_cf_a, ric$qte_cf_b)

write_csv(ric,"ric_cf.csv")

# Graph of cumulative effect and reagregate by criée


##############################################################################################################################


