# UK CO2 levels 2005-2019:
  # Data from https://www.ons.gov.uk/economy/environmentalaccounts/articles/carbondioxideemissionsandwoodlandcoveragewhereyoulive/2021-10-21


# LOADING NECESSARY PACKAGES:
library(data.table)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(reshape2)


# Import data from SQL:
CO2lvl<-fread("C:\\...\\UK CO2 data_SQL Cleaned.csv")


#Inspect data visually:
View(CO2lvl)

CO2lvl %>%
  ggplot(aes(Sample_Year, CO2_Lvls))+
  geom_point(aes(color=Area), alpha=0.4)+
  geom_smooth()+
  theme_bw()


# Log of Co2 Lvls to spread graph out:
CO2lvl %>%
  ggplot(aes(Sample_Year, log(CO2_Lvls)))+
  geom_point(aes(color=Area), alpha=0.4)+
  geom_smooth()+
  theme_bw()

# CO2 levels in London over time:
CO2lvl %>%
  filter(Area=='London')%>%
  ggplot(aes(Sample_Year, log(CO2_Lvls)))+
  geom_point(aes(color=Region), alpha=0.4)+
  geom_smooth()+
  theme_bw()

#CO2 levels in selected London boroughs:
CO2lvl %>%
  filter(Locality=='City of London'| Locality=='Camden'| Locality=='Tower Hamlets'| Locality=='Westminster'| Locality=='Islington')%>%
  select(Region, CO2_Lvls)

CO2lvl %>%
  filter(Locality=='City of London'| Locality=='Camden'| Locality=='Tower Hamlets'| Locality=='Westminster'| Locality=='Islington')%>%
  ggplot(aes(Sample_Year, log(CO2_Lvls), color=Locality))+
  geom_point(alpha=0.4)+
  geom_smooth()+
  theme_bw()



#Linear versions of the log data above:

  #London boroughs linear data models:
CO2lvl %>%
  filter(Locality=='City of London' | Locality=='Camden' | Locality=='Tower Hamlets' | Locality=='Westminster' | Locality=='Islington')%>%
  ggplot(aes(Sample_Year, CO2_Lvls, color=Locality))+
  geom_point(alpha=0.4)+
  geom_smooth()+
  theme_bw()






# Linear Representation of CO2 levels over time in Scotland:
CO2lvl %>%
  filter(Area=='Scotland')%>%
  ggplot(aes(Sample_Year, CO2_Lvls, col=Locality))+
  geom_point(alpha=0.3)+
  geom_smooth()+
  theme_bw()


#Adding Midlothian & City of Edinburgh historical CO2 levels to selected records graph above:
CO2lvl %>%
  filter(Locality=='Midlothian' | Locality=='City of Edinburgh' | Locality=='City of London' | Locality=='Camden'| Locality=='Tower Hamlets' | Locality=='Westminster' | Locality=='Islington')%>%
  select(Region, Locality, CO2_Lvls)


CO2lvl %>%
  filter(Locality=='Midlothian' | Locality=='City of Edinburgh' | Locality=='City of London' | Locality=='Camden'| Locality=='Tower Hamlets' | Locality=='Westminster' | Locality=='Islington')%>%
  ggplot(aes(Sample_Year, CO2_Lvls, col=Locality))+
  geom_point(alpha=0.3)+
  geom_smooth()+
  theme_bw()


  


#Overall UK data model:

  #Overall log fit:
CO2lvl %>%
  filter(Locality=='Midlothian' | Locality=='City of Edinburgh' | Locality=='City of London' | Locality=='Camden'| Locality=='Tower Hamlets' | Locality=='Westminster' | Locality=='Islington')%>%
  ggplot(aes(Sample_Year, log(CO2_Lvls)))+
  geom_point(aes(color=Locality), alpha=0.4)+
  geom_smooth()+
  theme_bw()


  #Overall linear fit:
CO2lvl %>%
  filter(Locality=='Midlothian' | Locality=='City of Edinburgh' | Locality=='City of London' | Locality=='Camden'| Locality=='Tower Hamlets' | Locality=='Westminster' | Locality=='Islington')%>%
  ggplot(aes(Sample_Year, CO2_Lvls))+
  geom_point(aes(color=Locality), alpha=0.4)+
  geom_smooth()+
  theme_bw()
