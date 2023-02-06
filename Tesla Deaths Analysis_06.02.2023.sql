-- TESLA Autopilot Deaths 2013 - 2023 (Downloaded February 2023)
	-- DATA SOURCE (Downloaded: 06.02.2023): https://www.kaggle.com/datasets/ibriiee/tesla-autonomous-deaths-data-updated-2023?resource=download


		-- Data includes all road-related deaths involving Teslas since February 2013
			-- Importantly: Tesla introduced their Autopilot feature on the 14th October 2015



-- Create Database:
CREATE DATABASE TESLA;
	USE TESLA;

-- Loading Data 'Tesla Deaths_Clean2.csv' as table 'TDeaths':
SELECT * FROM TDeaths
	ORDER BY 3;



-- Clean up Column Names and invalid data:
EXECUTE sp_rename N'dbo.TDeaths.Case', N'CaseNo', 'COLUMN';

EXECUTE sp_rename N'dbo.TDeaths.Verified_Tesla_Autopilot_Deaths', N'Confirmed_AutoP_Death', 'COLUMN';

UPDATE TDeaths
	SET Year = '2020'
		WHERE Date = '2020-09-17'
---------------------------------------------------


-- 1) Investigate claims of involvement of Tesla's autopilot:
SELECT COUNT(Deaths) AS MultiDeathEvetns
	FROM TDeaths
		-- total number of accidents = 294 accidents


	--A) Number of accidents where autopilot was claimed to be involved:
SELECT COUNT(CaseNo) AS NoAccidentsClaimed
	FROM TDeaths
		WHERE AutopilotClaimed = 1
			-- 32 accidents were claimed to involve Tesla's autopilot (10.9% of total reported)


	--B) Number of accidents where autopilot was confirmed to be involved:
SELECT COUNT(CaseNo) FROM TDeaths
	WHERE Confirmed_AutoP_Death = 1
			-- 13 accidents were confirmed to have involved Tesla's autopilot (4.4% of total accident cases, and 40.6% of cases where it was claimed to be invovled)
	

	--C) Number of accidents leading to death of a pedestrian/cyclist where autopilot claimed to be invovled, PER YEAR:
SELECT Year, Country, Deaths
	FROM TDeaths
		WHERE CyclistsPeds <> 0 AND AutopilotClaimed = 1
				ORDER BY 1 DESC
---------------------------------------------------



--2) Total Number of Deaths since 2013:
	-- Per country overall:
SELECT Country, SUM(Deaths) AS TotalDeathsSince2013
	FROM TDeaths
		GROUP BY Country
			ORDER BY 2 DESC;

	-- Per country and per year:
SELECT Year, Country, COUNT(Deaths) AS TotalDeathsSince2013
	FROM TDeaths
		GROUP BY Year, Country
			ORDER BY 2 DESC;
---------------------------------------------------



--3) Total Number of Deaths in 2013 & 2014 (pre-autopilot) versus 2015-2023 (post-autopilot) in the US:
	--Pre-autopilot:
SELECT Year, Country, COUNT(Deaths) AS TotalDeathsSince2013
	FROM TDeaths
		WHERE Country LIKE '%USA%' AND Year <= 2014
			GROUP BY Year, Country
				ORDER BY 2 DESC;
					--Just 6 deaths in the US in 2013 & 2014

	-- Post-autopilot:
SELECT Year, Country, COUNT(Deaths) AS TotalDeathsSince2013
	FROM TDeaths
		WHERE Country LIKE '%USA%' AND Year > 2014
			GROUP BY Year, Country
				ORDER BY 2 DESC;
---------------------------------------------------


--4) Total Number of Deaths per Model:
SELECT Model, COUNT(Deaths) AS TotalDeathsSince2013
	FROM TDeaths
			GROUP BY Model
				ORDER BY 2 DESC;

	--Which MODEL was most invovled in CONFIRMED Autopilot involvement cases:
SELECT Model, SUM(Deaths)
	FROM TDeaths
		WHERE Confirmed_AutoP_Death = 1
			GROUP BY Model, Deaths
				ORDER BY 2 DESC
---------------------------------------------------



-- 5) Investigate Events leading to deaths in more detail (294 total events/accidents):

	--A) How many accidents caused the death of multiple people, by country:
SELECT Country, COUNT(Deaths) AS MultiDeathEvetns
	FROM TDeaths
		WHERE Deaths > 1
			GROUP BY Country
				ORDER BY 2 DESC


	--B) How many accidents caused death in other vehicles, per country:
SELECT Country, COUNT(OtherVehicle) AS MultiVehicleAccident
	FROM TDeaths
		WHERE OtherVehicle > 1
			GROUP BY Country
				ORDER BY 2 DESC


 --DASHBOARD VISUALISATIONS IN TABLEAU:
		--1) https://prod-uk-a.online.tableau.com/t/badzalisys/views/TESLAAccidentsDataAnalysis/Dashboard1
		--2) https://prod-uk-a.online.tableau.com/t/badzalisys/views/TESLAAccidentsDataAnalysis/Dashboard2
		--3) https://prod-uk-a.online.tableau.com/t/badzalisys/views/TESLAAccidentsDataAnalysis/Dashboard3