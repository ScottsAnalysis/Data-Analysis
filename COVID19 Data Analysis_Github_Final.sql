
--COVID-19 WORLD DATA ANALYSIS - (Data downloaded on 21/01/2023)

	--CREATE DATABASE: COVID
	USE COVID;


--VISUALISE LOADED .csv DATA
USE COVID;

SELECT * 
	FROM CDeath 
		ORDER BY 3,4;

SELECT * 
	FROM CVac


	--Select data of interest:
SELECT location, date, population, total_cases, new_cases, total_deaths
	FROM CDeath 
		ORDER BY 1,2;




--1) DO A QUICK CLEAN UP OF DATA

	--A few things look out of place, need to edit and adjust the table and column parameters:
		-- Change column name:
EXECUTE sp_rename N'dbo.CDeath.Total_Death', N'total_deaths', 'COLUMN'

		-- Fix the different table column data types manually (not done during import wizzard):
ALTER TABLE CDeath
	ALTER COLUMN new_deaths FLOAT;

ALTER TABLE CDeath
	ALTER COLUMN total_deaths FLOAT;

ALTER TABLE CDeath
	ALTER COLUMN Population FLOAT;

ALTER TABLE CDeath
	ALTER COLUMN new_cases FLOAT;

ALTER TABLE CDeath
	ALTER COLUMN total_cases FLOAT;

--------------------------------------------------------------------------------------------------------------------------------------
	



--2a) EXPLORE CASES VS DEATHS DATA (MORTALITY)

	--Looking at Total Cases vs Total Deaths (Mortality rate) over time in the United Kingdom
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS MortalityPercRate
	FROM CDeath 
		WHERE location LIKE '%united kingdom%' 
			ORDER BY 1,2;
	

	--Looking at Total Cases in the French Population over time (proportion of population which have had COVID)
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercInfectionRate
	FROM CDeath 
		WHERE location LIKE '%France%' 
			ORDER BY 1,2;


	--Which country has the highest infection rate to date?
SELECT location, population, MAX(total_cases) AS MaxInfections, (MAX(total_cases)/MAX(population))*100 AS MaxInfectionPercRate
	FROM CDeath 
		WHERE continent IS NOT NULL 
			GROUP BY location, population 
				ORDER BY MaxInfectionPercRate DESC;


	--Which COUNTRY had the highest death count relative to their population to date?
SELECT location, population, MAX(total_deaths) AS MaxMortality, MAX(total_deaths/population)*100 AS MortalityRelativeToPop
	FROM CDeath
		WHERE continent IS NOT NULL
			GROUP BY location, population
				ORDER BY MortalityRelativeToPop DESC;


	--Which CONTINENT had the highest death count relative to their population to date?
SELECT location, MAX(total_deaths) AS MaxMortality, MAX(total_deaths/population)*100 AS MortalityRelativeToPop
	FROM CDeath
		WHERE continent IS NULL AND location NOT LIKE '%income'
			GROUP BY location
				ORDER BY MortalityRelativeToPop DESC;

------------------------------------------------------------------------------------------------------------------------------------




--2b) TAKE A LOOK AT GLOBAL NUMBERS:

	--MORTALITY RATE PER REGION:
SELECT  location, SUM(new_cases) AS CumulativeNewCases, SUM(new_deaths) AS CumulativeNewDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
	FROM CDeath 
		WHERE continent IS NULL AND location NOT LIKE '%income' 
			GROUP BY location
				ORDER BY 1,2;

	--MORTALITY RATE OVERALL FOR HUMANITY - CASES & DEATHS:
SELECT  SUM(new_cases) AS CumulativeNewCases, SUM(new_deaths) AS CumulativeNewDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
	FROM CDeath 
		WHERE continent IS NULL AND location NOT LIKE '%income' 
			ORDER BY 1,2;

------------------------------------------------------------------------------------------------------------------------------------




--3) EXPLORE VACCINATION DATA:

	--VACCINATION RATE PER REGION:
SELECT CVac.location, MAX(population) AS TotalPopulation, MAX(total_vaccinations) AS CumulativeNewVaccs, (MAX(total_vaccinations)/MAX(population))*100 AS VaccPercentage
	FROM CVac 
		JOIN CDeath ON CVac.location = CDeath.location
			WHERE CDeath.continent IS NULL AND CVac.location NOT LIKE '%income' 
			GROUP BY CVac.location, population
				ORDER BY 4 DESC;

	--VACCINATION RATE PER COUNTRY:
SELECT CVac.location, MAX(population) AS TotalPopulation, MAX(total_vaccinations) AS CumulativeNewVaccs, (MAX(total_vaccinations)/MAX(population))*100 AS VaccPercentage
	FROM CVac 
		JOIN CDeath ON CVac.location = CDeath.location
			WHERE CDeath.continent IS NOT NULL 
			GROUP BY CVac.location, population
				ORDER BY 4 DESC;


		--Looking at Total Population vs vaccinations in each country:
SELECT CVac.location, CVac.date, population, new_vaccinations, (new_vaccinations/population)*100 AS PopVaccinationPerc
	FROM CDeath 
		INNER JOIN CVac 
		ON CDeath.location = CVac.location
		AND CDeath.date = CVac.date
			WHERE CVac.continent IS NOT NULL
				ORDER BY 1,2,3;

		--Adding up all the new vaccinations per country - creating a subquery to do a rolling SUM of all the new vaccinations by location (country):
SELECT CDeath.continent, CDeath.location, CDeath.date, population, new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY CDeath.location) AS TotalSummedVaccinations
	FROM CDeath 
		JOIN CVac 
		ON CDeath.location = CVac.location
		AND CDeath.date = CVac.date
			WHERE CVac.continent IS NOT NULL
					ORDER BY 1,2,3;

			--Rolling SUM of all new vaccinations:
SELECT CDeath.continent, CDeath.location, CDeath.date, population, new_vaccinations, SUM(CVac.new_vaccinations) OVER (PARTITION BY CDeath.location ORDER BY CDeath.location, CDeath.date) AS RollingSummedVaccinations
	FROM CDeath 
		INNER JOIN CVac 
		ON CDeath.location = CVac.location
		AND CDeath.date = CVac.date
			WHERE CVac.continent IS NOT NULL 
					ORDER BY 1,2,3;




			--Enabling for further calculations using the results from previous query:
				
				--METHOD 1: Create CTE of above table so we can use calculated values for further queries:
WITH PopVsVaccs (Continent, Location, Date, Population, NewVaccinations, RollingVaccinationNos)
AS
(
SELECT CDeath.continent, CDeath.location, CDeath.date, population, new_vaccinations, SUM(CVac.new_vaccinations) OVER (PARTITION BY CDeath.location ORDER BY CDeath.location, CDeath.date) AS RollingSummedVaccinations
	FROM CDeath 
		INNER JOIN CVac 
		ON CDeath.location = CVac.location
		AND CDeath.date = CVac.date
			WHERE CVac.continent IS NOT NULL 
)
	SELECT * FROM PopVsVaccs
		ORDER BY 2,3;

					--Further calculations/queries:
WITH PopVsVaccs (Continent, Location, Date, Population, NewVaccinations, RollingVaccinationNos)
AS
(
SELECT CDeath.continent, CDeath.location, CDeath.date, population, new_vaccinations, SUM(CVac.new_vaccinations) OVER (PARTITION BY CDeath.location ORDER BY CDeath.location, CDeath.date) AS RollingSummedVaccinations
	FROM CDeath 
		INNER JOIN CVac 
		ON CDeath.location = CVac.location
		AND CDeath.date = CVac.date
			WHERE CVac.continent IS NOT NULL 
)
	SELECT *, (RollingVaccinationNos/population)*100 AS PercentVaccinated
		FROM PopVsVaccs
		ORDER BY 2,3;



				--METHOD 2: Create a View:
CREATE VIEW RollNewVac
AS
(
SELECT CDeath.continent, CDeath.location, CDeath.date, population, new_vaccinations, SUM(CVac.new_vaccinations) OVER (PARTITION BY CDeath.location ORDER BY CDeath.location, CDeath.date) AS RollingSummedVaccinations
	FROM CDeath 
		INNER JOIN CVac 
		ON CDeath.location = CVac.location
		AND CDeath.date = CVac.date
			WHERE CVac.continent IS NOT NULL 
);
			
				--Further calculations:
SELECT * FROM RollNewVac
	ORDER BY 1,2,3;


					--Want to know the percentage of vaccinated people per region (using the View created above):
SELECT *, (RollingSummedVaccinations/population)*100 AS PercentVaccinated
	FROM RollNewVac
		ORDER BY 2,3;

	DROP VIEW RollNewVac





				--METHOD 3: CREATING TEMP TABLE for further queries:
DROP TABLE IF EXISTS S#PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
	INSERT INTO #PercentPopulationVaccinated
		SELECT CDeath.continent, CDeath.location, CDeath.date, population, new_vaccinations, SUM(CVac.new_vaccinations) OVER (PARTITION BY CDeath.location ORDER BY CDeath.location, CDeath.date) AS RollingSummedVaccinations
		FROM CDeath 
			INNER JOIN CVac 
			ON CDeath.location = CVac.location
			AND CDeath.date = CVac.date
				WHERE CVac.continent IS NOT NULL 
					ORDER BY 2,3;

		SELECT* FROM #PercentPopulationVaccinated
			ORDER BY 2,3;

			SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
				FROM #PercentPopulationVaccinated
					ORDER BY 2,3;

------------------------------------------------------------------------------------------------------------------------------------




	--4) Further Data Queries:

		--I. Max vaccinations per country:
CREATE VIEW VaxPerCountry
AS
(
SELECT DISTINCT location, population, SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location) AS TotalVaccinations
	FROM RollNewVac
		WHERE continent IS NOT NULL
			GROUP BY continent, location, population, new_vaccinations
);

		SELECT * FROM VaxPerCountry
			ORDER BY 3 DESC


SELECT *, (TotalVaccinations/population)*100 AS VaccPercentage
	FROM VaxPerCountry
			ORDER BY 4 DESC;

-------------------------------------------------------------------------------------------------------------------------------------
			


	--II. Show Impact of Vaccination roll-outs (in 2021) on Mortality rate across the world

				--First vaccine doses (in the UK, Europe & the US) innoculation: early-to-mid 2021
				--Second vaccine doses (in the UK, Europe & the US) innoculation: late 2021
				--Third ('Booster') vaccine doses (in the UK, Europe & the US) innoculation: early-to-mid 2022


		--STEPS 1 - 4:
		  -------------

	--1a) Select data between July and October 2020 for Mortality Rate analysis
SELECT continent, location, date, total_cases, total_deaths, SUM(new_cases) OVER (PARTITION BY location ORDER BY location, date) AS TotalNewCases2020, SUM(new_deaths) OVER (PARTITION BY location ORDER BY location, date) AS TotalNewDeaths2020, (total_deaths/total_cases)*100 AS MortalityRate
	FROM CDeath
		WHERE continent IS NOT NULL AND date BETWEEN '07/01/2020' and '10/15/2020'
			Order By 2,3;

CREATE TABLE #MortalityRate2020
(
Continent nvarchar(255),
Location nvarchar(255),
TotalCases numeric,
TotalDeaths numeric,
TotalNewCases2020 numeric,
TotalNewDeaths2020 numeric,
MortalityRate2020 Decimal(18,5)
)
	INSERT INTO #MortalityRate2020
		SELECT continent, location, total_cases, total_deaths, SUM(new_cases) OVER (PARTITION BY location ORDER BY location, date), SUM(new_deaths) OVER (PARTITION BY location ORDER BY location, date), (total_deaths/total_cases)*100 
			FROM CDeath
				WHERE continent IS NOT NULL AND date BETWEEN '07/01/2020' and '10/15/2020';

		SELECT * FROM #MortalityRate2020
			ORDER BY 2;


	--1b) Looking at Mortality Rate in 2020:
CREATE TABLE #Mortality2020
(
Continent nvarchar(255),
Location nvarchar(255),
AVGPercMortality2020 decimal (18,5)
)
	INSERT INTO #Mortality2020
		SELECT DISTINCT continent, location, AVG(MortalityRate2020) OVER (PARTITION BY location ORDER BY location)
			FROM #MortalityRate2020
				ORDER BY 2 DESC;

		SELECT * FROM #Mortality2020;



		--2a) Select comparative data from May until September 2022 (post-vaccinations) for Mortality Rate analysis
SELECT continent, location, total_cases, total_deaths, SUM(new_cases) OVER (PARTITION BY location ORDER BY location, date) AS TotalNewCases2022, SUM(new_deaths) OVER (PARTITION BY location ORDER BY location, date) AS TotalNewDeaths2022, (total_deaths/total_cases)*100 AS MortalityRate
	FROM CDeath
		WHERE continent IS NOT NULL AND date BETWEEN '05/01/2022' and '09/15/2022'
			Order By 2,3;

CREATE TABLE #MortalityRate2022
(
Continent nvarchar(255),
Location nvarchar(255),
TotalCases numeric,
TotalDeaths numeric,
TotalNewCases2022 numeric,
TotalNewDeaths2022 numeric,
MortalityRate2022 Decimal(18,5)
)
	INSERT INTO #MortalityRate2022
		SELECT continent, location, total_cases, total_deaths, SUM(new_cases) OVER (PARTITION BY location ORDER BY location, date), SUM(new_deaths) OVER (PARTITION BY location ORDER BY location, date), (total_deaths/total_cases)*100
			FROM CDeath
				WHERE continent IS NOT NULL AND date BETWEEN '05/01/2022' and '09/15/2022';

		SELECT * FROM #MortalityRate2022
			ORDER BY 2;
	

		--2b) Looking at Mortality Rate in 2022:
CREATE TABLE #Mortality2022
(
Continent nvarchar(255),
Location nvarchar(255),
AVGPercMortality2022 decimal (18,5)
)
	INSERT INTO #Mortality2022
		SELECT DISTINCT continent, location, AVG(MortalityRate2022) OVER (PARTITION BY location ORDER BY location)
			FROM #MortalityRate2022;
					
		SELECT * FROM #Mortality2022;



			--3a) Comparing 2020 Mortality with that of 2022 directly:
SELECT #Mortality2020.Continent, #Mortality2020.location, #Mortality2020.AVGPercMortality2020, #Mortality2022.AVGPercMortality2022, ((#Mortality2022.AVGPercMortality2022/#Mortality2020.AVGPercMortality2020)-1)*100 AS PercentChange2020To2022
	FROM #Mortality2020
		JOIN #Mortality2022
		ON #Mortality2020.location = #Mortality2022.location
			WHERE #Mortality2020.AVGPercMortality2020 IS NOT NULL AND #Mortality2020.Location NOT LIKE '%lanka'
				ORDER BY 4;

	
			--3b) CREATE FINAL COMPARATIVE RESULTS TABLE:
CREATE TABLE MortalityPercChange2020to2022
(
Continent nvarchar(255),
Location nvarchar(255),
AVGMortality2020 decimal (18,5),
AVGMortality2022 decimal (18,5),
MortalityPercentChange2020to2022 decimal (7,4)
)
INSERT INTO MortalityPercChange2020to2022
	SELECT #Mortality2020.Continent, #Mortality2020.location, #Mortality2020.AVGPercMortality2020, #Mortality2022.AVGPercMortality2022, ((#Mortality2022.AVGPercMortality2022/#Mortality2020.AVGPercMortality2020)-1)*100
		FROM #Mortality2020
			JOIN #Mortality2022
			ON #Mortality2020.location = #Mortality2022.location
				WHERE #Mortality2020.AVGPercMortality2020 IS NOT NULL AND #Mortality2020.Location NOT LIKE '%lanka';


				--4) FINAL RESULT TABLE:
SELECT * FROM MortalityPercChange2020to2022
		ORDER BY 5;
			-- Exported as COVID_MortalityData_2020v2022.csv

-------------------------------------------------------------------------------------------------------------------------------------



		--III. Create single data table for a) number of infections, b) number of deaths, c) number of vaccinations and d) population per continent:
		
		--1) Select data
			--1a) Select Cumulative DEATHS data
CREATE TABLE #ContinentDeaths
(
Continent nvarchar(255),
Date date,
SummedDeaths numeric
)
INSERT INTO #ContinentDeaths
SELECT DISTINCT continent, date, SUM(new_deaths) OVER (PARTITION BY continent ORDER BY continent, date)
	FROM CDeath
		WHERE continent IS NOT NULL;

			SELECT * FROM #ContinentDeaths
				ORDER BY 1,2;


			--1b) Select Cumulative INFECTIONS data
CREATE TABLE #ContinentCases
(
Continent nvarchar(255),
Date date,
SummedNewCases numeric
)
INSERT INTO #ContinentCases
SELECT DISTINCT continent, date, SUM(new_cases) OVER (PARTITION BY continent ORDER BY continent, date)
	FROM CDeath
		WHERE continent IS NOT NULL;


			SELECT * FROM #ContinentCases
			ORDER BY 1,2;


			--1c) Select Cumulative VACCINATIONS data
CREATE TABLE #ContinentVax
(
Continent nvarchar(255),
Date date,
SummedNewVax numeric
)
INSERT INTO #ContinentVax
SELECT DISTINCT continent, date, SUM(new_vaccinations) OVER (PARTITION BY continent ORDER BY continent, date)
	FROM CVac
		WHERE continent IS NOT NULL;


			SELECT DISTINCT * FROM #ContinentVax
				ORDER BY 1,2;


			--1d) Select POPULATION data
CREATE TABLE #ContinentPop
(
Continent nvarchar(255),
Date date,
Population numeric
)
INSERT INTO #ContinentPop
SELECT DISTINCT continent, date, MAX(population) OVER (PARTITION BY continent ORDER BY continent)
	FROM CDeath
		WHERE continent IS NOT NULL;
				
			SELECT DISTINCT * FROM #ContinentPop				
				ORDER BY 1,2;



			--2) Generate CASES, DEATHS & VAX table
CREATE TABLE #ContData
(
Continent nvarchar(255),
Date date,
CumNewCases numeric,
CumNewDeaths numeric,
CumNewVax numeric
)
INSERT INTO #ContData
SELECT #ContinentCases.continent, #ContinentCases.date, #ContinentCases.SummedNewCases, #ContinentDeaths.SummedDeaths, #ContinentVax.SummedNewVax
	FROM #ContinentCases 
		INNER JOIN #ContinentDeaths 
		ON #ContinentCases.continent = #ContinentDeaths.continent
		AND #ContinentCases.date = #ContinentDeaths.date
		INNER JOIN #ContinentVax
		ON #ContinentCases.continent = #ContinentVax.continent
		AND #ContinentCases.date = #ContinentVax.date
			WHERE #ContinentCases.continent IS NOT NULL;
			
				SELECT * FROM #ContData
					ORDER BY 1,2;


			--3) 'Absolute' data table, including population, new cases, deaths and vax:
CREATE TABLE ContinentData
(
Continent nvarchar(255),
Date date,
Population numeric,
CumNewCases numeric,
CumNewDeaths numeric,
CumNewVax numeric
)
INSERT INTO ContinentData
SELECT DISTINCT #ContData.Continent, #ContData.Date, #ContinentPop.Population, #ContData.CumNewCases, #ContData.CumNewDeaths, #ContData.CumNewVax
	FROM #ContData
		INNER JOIN #ContinentPop
		ON #ContData.Continent = #ContinentPop.Continent
		AND #ContData.Date = #ContinentPop.Date
			WHERE #ContData.continent IS NOT NULL
				ORDER BY 1,2;

				SELECT * FROM ContinentData;
			-- Exported as COVID_ContinentData.csv


			--4) Show 'Absolute' data above as Percentage of their respective continent population:
CREATE TABLE ContinentData2
(
Continent nvarchar(255),
Date date,
PercPopCases decimal(18,4),
PercPopDeaths decimal(18,4),
PercPopVax decimal(18,4),
)
INSERT INTO ContinentData2
SELECT Continent, Date, (CumNewCases/population)*100, (CumNewDeaths/population)*100, (CumNewVax/population)*100
	FROM ContinentData;

				SELECT * FROM ContinentData2;
			-- Exported as COVID_ContinentData2.csv

-- PowerBI Data Visualisation Dashboard: 
		-- https://app.powerbi.com/view?r=eyJrIjoiNWY4NmJkZWYtMWYwOC00YTliLWEwZjItNDhkZTRkYzY0MWMyIiwidCI6ImE3YTczN2VmLTA5YjgtNGFjZi1hNjI5LThmNjhhNWQzM2MwMiJ9
		
-------------------------------------------------------------------------------------------------------------------------------------
