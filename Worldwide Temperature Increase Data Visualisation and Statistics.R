
# Worldwide Temperature DATA VISUALISATION:
# Using SQL data exports

# Original data source: https://www.kaggle.com/datasets/mdazizulkabirlovlu/all-countries-temperature-statistics-1970-2021?resource=download



# LOADING NECESSARY PACKAGES:
library(data.table)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(reshape2)



# Import COVID Mortality Data .csv file (from SQL)
Temper2<-fread("C:\\...\\World Temp Difference 1970_2021_2.csv")


# Inspect Overall data visually & graphically
View(Temper2)

Temper2%>%
  ggplot(aes(x=Year, y=TempChange))+
  geom_point()+
  geom_smooth()



# Graph out selected countries over time
  # Overall trend across countries (with model fit):
Temper2%>%
  filter(Country=='Denmark' | Country=='United States' | Country=='United Kingdom' | 
           Country=='Indonesia' | Country=='Qatar' | Country=='France')%>%
  ggplot(aes(x=Year, y=TempChange))+
  geom_point(aes(col=Country))+
  geom_smooth()+
  theme_bw()

  # Country-specific trends (with model fit):
Temper2%>%
  filter(Country=='Denmark' | Country=='United States' | Country=='United Kingdom' | 
           Country=='Indonesia' | Country=='Qatar' | Country=='France')%>%
  ggplot(aes(x=Year, y=TempChange, col=Country))+
  geom_point()+
  geom_smooth(se=FALSE)+
  theme_bw()


# Graph out Results for each of the above countries separately:
Temper2%>%
  filter(Country=='Denmark' | Country=='United States' | Country=='United Kingdom' | 
           Country=='Indonesia' | Country=='Qatar' | Country=='France')%>%
  ggplot(aes(x=Year, y=TempChange))+
  geom_point(aes(colour=Country))+
  geom_smooth()+
  facet_wrap(~Country)+
  theme_bw()
----------------------------------------------------------------------------------

  
  
  
  
# Statistical Testing of data:

  # Test using linear model fit - First, redraw graphs wih linear model fits:
  Temper2%>%
    filter(Country=='Denmark' | Country=='United States' | Country=='United Kingdom' | 
             Country=='Indonesia' | Country=='Qatar' | Country=='France')%>%
    ggplot(aes(x=Year, y=TempChange))+
    geom_point(aes(colour=Country))+
    geom_smooth(method=lm)+
    facet_wrap(~Country)+
  theme_bw()
  
  # Testing whether temperature changes with respect to year:
lm(Temper2$TempChange ~ Temper2$Year)
summary(lm(Temper2$TempChange ~ Temper2$Year))
      # Temperature rises are dependent on year (P<2e-16; p<0.0001).


  # Test whether the temperature increases in Qatar and the UK are significantly different from each other:
QatvUK <- Temper2 %>%
  select(Country, TempChange) %>%    
  filter(Country=="Qatar" |        
           Country =='United Kingdom')

# Carry out t-test of selected data:
t.test(data=QatvUK, TempChange~Country)  
    # The true means of Qatar's and the UK's temperature increases ARE =0 (P=0.3165; p>0.05)
        # i.e. Temperature rises are very similar between Qatar and the UK.


# Test Qatar vs Indonesia:
QatvInd <- Temper2 %>%
  select(Country, TempChange) %>%    
  filter(Country=="Qatar" |        
           Country =='Indonesia')

t.test(data=QatvInd, TempChange~Country) 
    # The true means of Qatar's and the UK's temperature increases are NOT =0 (P=0.022; p<0.05)
        # i.e. Temperature rises are different enough to be statistically significant between Qatar and Indonesia.



