
# COVID DATA VISUALISATION:


        # Using SQL COVID Data exports
             # PowerBI Data Visualisation Dashboard: https://app.powerbi.com/view?r=eyJrIjoiNWY4NmJkZWYtMWYwOC00YTliLWEwZjItNDhkZTRkYzY0MWMyIiwidCI6ImE3YTczN2VmLTA5YjgtNGFjZi1hNjI5LThmNjhhNWQzM2MwMiJ9


   # R Data Visualisation Code:

    # LOADING NECESSARY PACKAGES:
library(data.table)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(reshape2)



# PERCENT CHANGE IN MORTALITY RATE - 2020 (PRE-VACCINATIONS) VS 2022 (POST-VACCINATIONS):

    # Import COVID Mortality Data .csv file (from SQL)
Mortality<-fread("C:\\...\\COVID_MortalityData_2020v2022.csv")

        # EXAMINE DATA
str(Mortality)
View(Mortality)

            # Inspect Data Visually
Mortality %>%
    ggplot(aes(Location, MortalityPercentChange2020to2022))+
    geom_bar(stat="identity")+
    labs(title="COVID Mortality Rate Change 2020 vs 2022", x="Country", y="Percent Mortality Rate Change")


        # CREATE WORLDWIDE GRAPH:
Mortality %>%
    ggplot(aes(reorder(Location,-MortalityPercentChange2020to2022), MortalityPercentChange2020to2022))+
    geom_bar(stat="identity", aes(fill=Continent))+
    coord_flip()+                                                               
    theme_bw()+
    theme(panel.grid.minor=element_blank())+
    labs(title="COVID Mortality Rate Change 2020 vs 2022", x="Country", y="Percent Mortality Rate Change")

        # Remove every other label from graph (for clarity):
m=2             #Setting every '2' labels to be removed
n=182/m            # n = <total number of data rows> / m

Mortality %>%
    ggplot(aes(reorder(Location,-MortalityPercentChange2020to2022), MortalityPercentChange2020to2022))+
    geom_bar(stat="identity", aes(fill=Continent))+
    coord_flip()+
    theme_bw()+                                                                                        
    theme(panel.grid.minor=element_blank(), axis.text.y=element_text(colour=rep(c("black", rep("transparent", each=m-1)),n)))+         
    labs(title="COVID Mortality Rate Change 2020 vs 2022", x="Country", y="Percent Mortality Rate Change")



        # CREATE CONTINENT-SPECIFIC GRAPH:
                #Remove all Data Labels (for greater clarity)
Mortality %>%
    ggplot(aes(reorder(Location,-MortalityPercentChange2020to2022), MortalityPercentChange2020to2022))+
    geom_bar(stat="identity", aes(fill=Continent))+
    coord_flip()+
    facet_wrap(~Continent)+
    theme_bw()+
    theme(panel.grid.minor=element_blank(), axis.text.y=element_text(colour="transparent"))+
    labs(title="COVID Mortality Rate Change 2020 vs 2022", x="Country", y="Percent Mortality Rate Change")

#Analysis - Data shows:
    # 1 - The West (North America & Europe) saw a reduction in their Mortality Rate of more than 65% on average
        # - Corroborates the protective impact of vaccines
    
    # 2 - African and South American countries (with little Vaccine exposure) span a wide range of outcomes, from large decreases (30-50%) to large increases (30 - 100%) in mortality.
    
    # 3 - Asia was the continent with the widest spread: a few countries saw great reductions while a few others saw great increases in mortality, while most did 'average.
        # - Asian countries with access to Western vaccines (South Korea, Japan & Turkey among others) showed >50% reduction in Mortality
        # - More economically distant Asian countries (Tajikistan, Turkmenistan, Azerbaijan, Qatar, Syria, Russia, Lebanon, Myanmar, Singapore etc..) saw the worst outcomes (20% decrease, up to 300% increase) in Mortality



# DRAWING GRAPH OF 1) CUMULATIVE & 2) NORMALISED CASES, DEATHS AND VACCINATIONS, BY CONTINENT:

    # 1) Import 'Absolute' COVID Continent Data .csv file (from SQL)
ContinentData<-fread("C:\\...\\COVID_ContinentData.csv")

        # EXAMINE DATA
str(ContinentData)
View(ContinentData)

        # New Cases
ContinentData %>%
    drop_na(CumNewCases) %>% 
    ggplot(aes(Date, CumNewCases, colour=Continent))+     
    geom_point(size=0.1, alpha=0.5)+
    geom_line(size=1)+
    labs(title="Cumulative New COVID Cases Worldwide", y="Total Cumulative Cases (all COVID waves)")+     
    theme_bw()

        # New Deaths
ContinentData %>%
    drop_na(CumNewDeaths) %>% 
    ggplot(aes(Date, CumNewDeaths, colour=Continent))+     
    geom_point(size=0.1, alpha=0.5)+
    geom_line()+
    labs(title="Cumulative New COVID Deaths Worldwide", y="Total Cumulative Deaths (all COVID waves)")+     
    theme_bw()

        # New Vaccinations
ContinentData %>%
    ggplot(aes(Date, as.numeric(CumNewVax), colour=Continent))+                         
    geom_point()+
    labs(title="Cumulative New COVID Vaccinations Worldwide", y="Total Cumulative Vaccinations (Dose 1, Dose 2 & Boosters)")+     
    theme_bw()



    # 2) Import 'Normalised' COVID Continent Data2 .csv file (from SQL)
ContinentData2<-fread("C:\\...\\COVID_ContinentData2.csv")

        # EXAMINE DATA
str(ContinentData2)
View(ContinentData2)

        # New Cases
ContinentData2 %>%
    drop_na(PercPopCases) %>% 
    ggplot(aes(Date, PercPopCases, colour=Continent))+     
    geom_point(size=0.1, alpha=0.5)+
    geom_line(size=1)+
    labs(title="New COVID Cases (as % of Population)", y="% Cases (all COVID waves)")+     
    theme_bw()

        # New Deaths
ContinentData2 %>%
    drop_na(PercPopDeaths) %>% 
    ggplot(aes(Date, PercPopDeaths, colour=Continent))+     
    geom_point(size=0.1, alpha=0.5)+
    geom_line(size=1)+
    labs(title="New COVID Deaths (as % of Population)", y="% Deaths (all COVID waves)")+     
    theme_bw()

        # New Vaccinations
ContinentData2 %>%
    drop_na(PercPopVax) %>% 
    ggplot(aes(Date, PercPopVax, colour=Continent))+     
    geom_point(size=0.1, alpha=0.5)+
    geom_line()+
    labs(title="New Vaccinations (as % of Population)", y="% Vaccinations (Dose 1, Dose 2 & Boosters)")+     
    theme_bw()
    



