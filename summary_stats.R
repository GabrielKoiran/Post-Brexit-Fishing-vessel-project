##############################################################################################################################

#PAI PROJECT DO-FILE
#2024
#GABRIEL KOIRAN PORTIER

#FILE 2: SUMMARY STATS (summary_stats)

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

##############################################################################################################################


## IMPORT DATA FROM PREVIOUS STEP ##

treated_list <- read_csv("treated_list.csv")

universe <- read_csv("universe.csv")

##############################################################################################################################


## CREATE PRESENT LIST TABLE WITH PRESENCE OF SHIPS AT DIFFERENT DATES ##


#Create unique list of identifiers from universe and add columns of interest (presence in March
#and September 2023, and length >= 14 days)

present_list <- universe
present_list <- present_list[,1]
present_list <- unique(present_list)

present_list$treated <- NA
present_list$length <- NA
present_list$tonnage <- NA
present_list$power <- NA
present_list$quartier <- as.character("")

#Create function that takes date (in %d/%m/%Y format) as argument, as well as name of indicator column,
#s a loop going through each observation of present_list: create a temporary history df,
#and see if present on 1/3/23 (and length >or= 14) by progressively deleting lines

presence_date <- function(enter_date, date_column) {
#Create column to indicate presence at date using function argument ()
  present_list$newcol <- NA
  colnames(present_list)[ncol(present_list)] <- date_column
  #Start loop
  for (i in 1:nrow(present_list)){
#Keep only observations corresponding to given line of unique identifier list
  history <- universe
  history <- history[history$CFR == as.character(present_list[i,1]),]
#Check whether any events before date, and if so whether last event before date is destruction or removal
# and corresponds to length criterion
  history <- history[history$'Event Start Date' < as.Date(enter_date, format = "%d/%m/%Y"),]
if (nrow(history) > 0
     & !(as.character(tail(history[,2],1)) == "DES" | as.character(tail(history[,2],1)) == "RET")
     & as.numeric(tail(history[,9],1)) >= 14 ) {
#If this is the case, then report treatment status and technical characteristics and quartier (last recorded before period)
  present_list[i,2] <- as.numeric(tail(history[,12],1))
  present_list[i,3] <- as.numeric(tail(history[,9],1))
  present_list[i,4] <- as.numeric(tail(history[,10],1))
  present_list[i,5] <- as.numeric(tail(history[,11],1))
  present_list[i,6] <- as.character(substr(tail(history[,5],1), 1, 2))
#And indicate presence at that date
  present_list[i,ncol(present_list)] <- 1 
}
  }
  #Superassign local df to global environment (https://stackoverflow.com/questions/71620732/how-to-get-an-r-function-to-have-a-global-effect-on-a-dataframe)
  present_list <<- present_list
}


presence_date("01/03/2023", "march")
presence_date("01/09/2023", "september")


# Delete observations not in database at relevant time

present_list <- present_list[(!is.na(present_list$march) | !is.na(present_list$september)),]

#Replace NAs by 0s

present_list$march[is.na(present_list$march)] <- 0
present_list$september[is.na(present_list$september)] <- 0

##############################################################################################################################


## CREATE QUARTIER LIST WITH VARIOUS SUMMARY STATISTICS ##

# For each treatment status, subset the table of ships present in March

quartier_0 <- present_list[present_list$treated == 0 & present_list$march == 1,]
quartier_1 <- present_list[present_list$treated == 1 & present_list$march == 1,]

# Create summary statistics for each

sum_quartier_0 <-
  quartier_0 %>%
  group_by(quartier) %>%
  summarise(n = n(), sum_length = sum(length), sum_tonnage = sum(tonnage), sum_power = sum(power))

sum_quartier_1 <-
  quartier_1 %>%
  group_by(quartier) %>%
  summarise(n = n(), sum_length = sum(length), sum_tonnage = sum(tonnage), sum_power = sum(power))

#Bind horizontally by quartier and delete for quartier where no vessel was treated
#and rename columns

sum_quartier <- full_join(sum_quartier_0, sum_quartier_1, by = "quartier")
colnames(sum_quartier) <- c("quartier", "n_untreated", "length_untreated", "tonnage_untreated", "power_untreated", "n_treated", "length_treated", "tonnage_treated", "power_treated")
sum_quartier <- sum_quartier[!is.na(sum_quartier$n_treated),]

#Compute percentages

sum_quartier$part_volume <-
  round(sum_quartier$tonnage_treated/(sum_quartier$tonnage_treated+sum_quartier$tonnage_untreated)*100)
sum_quartier$part_puissance <-
  round(sum_quartier$power_treated/(sum_quartier$power_treated+sum_quartier$power_untreated)*100)
sum_quartier$part_longueur <- 
  round(sum_quartier$length_treated/(sum_quartier$length_treated+sum_quartier$length_untreated)*100)


##############################################################################################################################


## SUMMARY STATS BY DATE ##

# Create table with 365 days and total value treated as columbs

treatment_progress <- data.frame(matrix(NA, nrow = 365, ncol = 5))
names(treatment_progress) <- c("Date", "number_removed", "volume_removed", "power_removed", "length_removed")

treatment_progress$Date <- seq(as.Date("2023-01-01"), by = "days", length.out = 365)

# Count number of ships and capacity at each date and write in table

for (i in 1:365){
  treatment_progress[i,2] <- count(liste86[liste86$date < treatment_progress[i,1],])
  treatment_progress[i,3] <- sum(liste86[liste86$date < treatment_progress[i,1],8])
  treatment_progress[i,4] <- sum(liste86[liste86$date < treatment_progress[i,1],9])
  treatment_progress[i,5] <- sum(liste86[liste86$date < treatment_progress[i,1],10])
}

# Express as percentage

treatment_progress$number_removed <- treatment_progress$number_removed/as.numeric(treatment_progress[365,2])*100
treatment_progress$volume_removed <- treatment_progress$volume_removed/as.numeric(treatment_progress[365,3])*100
treatment_progress$power_removed <- treatment_progress$power_removed/as.numeric(treatment_progress[365,4])*100
treatment_progress$length_removed <- treatment_progress$length_removed/as.numeric(treatment_progress[365,5])*100


##############################################################################################################################


## OUTPUT DATA


write_csv(sum_quartier, "sum_quartier.csv")
write_csv(treatment_progress, "treatment_progress.csv")


##############################################################################################################################
