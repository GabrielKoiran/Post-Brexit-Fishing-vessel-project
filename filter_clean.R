##############################################################################################################################

#PAI PROJECT DO-FILE
#2024
#GABRIEL KOIRAN PORTIER

#FILE 1: DATA IMPORTATION AND CLEANING (filter_clean)

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


## IMPORT PRIMARY DATA ##


#Import data downloaded from EU fleet registry, requesting the universe of all events over all ships ever registered in France
#https://webgate.ec.europa.eu/fleet-europa/search_en

all_records <- read_delim("all_records.csv", delim = ";", escape_double = FALSE, trim_ws = TRUE,
                          col_types = c("c", "c", "c", "c", "D", "D", "n",
                                        "c", "c", "c", "c", "c", "c", "c",
                                        "c", "c", "c", "c", "c", "c", "c",
                                        "c", "c", "c", "c", "c", "n", "n",
                                        "n", "n", "n", "n", "n",
                                        "n", "D", "c", "c", "c", "c", "D"))


#Official list of 86 ships treated with PAI
#https://www.mer.gouv.fr/FAQ_brexit_peche
#https://www.mer.gouv.fr/sites/default/files/2023-12/Liste%20des%20b%C3%A9n%C3%A9ficiaires%20finaux%20PAI%20-%2086%20navires-3.pdf
#Downloaded as pdf and converted to excel file

liste86 <- read_excel("liste_86.xlsx", 
                      range = "A1:N87", col_types = c("text", 
                                                      "text", "text", "text", "numeric", 
                                                      "text", "text", "date", "date", "numeric", 
                                                      "numeric", "numeric", "text", "text"))


##############################################################################################################################


## CORRECT TYPOS IN LIST AND DELETE USELESS INFO (AND COLUMN/ROW NAMES)


#Typos in liste_86 (based on concordance of CFR but not immat or conversely)

liste86[2,5] <- 273986
liste86[3,5] <- 294354
liste86[14,4] <- "FRA000528889"
liste86[23,4] <- "FRA000584842"
liste86[24,4] <- "FRA000611916"
liste86[29,4] <- "FRA000639926"
liste86[44,4] <- "FRA000686620"
liste86[45,4] <- "FRA000690511"
liste86[47,4] <- "FRA000711630"
liste86[70,4] <- "FRA000870580"
liste86[74,4] <- "FRA000899833"
liste86[76,4] <- "FRA000907446"
liste86[78,4] <- "FRA000912361"
liste86[83,5] <- 922635
liste86[82,4] <- "FRA000922599"

# Delete columns

liste86 <- liste86 %>% select(c(4,5,13))

#Rename columns and rows

colnames(liste86) <- c("cfr", "immat", "cpostal")
rownames(liste86) <- liste86$immat


##############################################################################################################################


## MATCH VESSELS FROM EU DATABASE TO SHORT LIST TO GET ADDITIONAL INFO: DATE AND TYPE OF SHIP ##

#Order all_records by event start D

all_records <- all_records[order(all_records$`Event Start Date`),]

#Create variables of interest

liste86$date <- NA
liste86$name <- NA
liste86$place <- NA
liste86$type <- NA
liste86$length <- NA
liste86$tonnage <- NA
liste86$power <- NA

#Loop to match vessels to EU database by using a temporary "history" df with relevant criteria

for (i in 1:nrow(liste86)){
  history <- all_records
  history <- history[history$CFR == as.character(liste86[i,1]),]
  history <- history[(history$`Event` == 'DES' | history$`Event` == 'RET'),]
  history <- tail(history, 1)
#And copy relevant information
  liste86[i,4] <- as.Date(as.numeric(history[1,5]), origin = "1970-01-01")
  liste86[i,5] <- as.character(history[1,9])
  liste86[i,6] <- as.character(history[1,11])
  liste86[i,7] <- as.character(history[1,21])
  liste86[i,8] <- as.numeric(history[1,27])
  liste86[i,9] <- as.numeric(history[1,29])
  liste86[i,10] <- as.numeric(history[1,32])
}

#Replace one illegible

liste86[6,6] <- "Île d'Yeu"


##############################################################################################################################


## MATCH VESSELS FROM SHORT LIST TO EU DATABASE ##

# Delete irrelevant info in EU database and add match column (treated)

universe <- all_records %>% select(c(2,4,5,7,8,9,10,21,27,29,32))
universe$treated <- NA

# Loop to match to short list

for (i in 1:nrow(liste86)){
  universe[universe$CFR == as.character(liste86[i,1]),]$treated <- 1
}


##############################################################################################################################


## OUTPUT DATA

#Make NA into 1 in universe

universe$treated[is.na(universe$treated)] <- 0

#Save data

write_csv(liste86, "treated_list.csv")

write_csv(universe, "universe.csv")


##############################################################################################################################


