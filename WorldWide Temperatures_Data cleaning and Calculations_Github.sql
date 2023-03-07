
-- Worldwide Temperatures - Data cleaning and analysis

		-- Data source: https://www.kaggle.com/datasets/mdazizulkabirlovlu/all-countries-temperature-statistics-1970-2021?resource=download


-- Creating new database:
Create Database Temp
	Use Temp

		-- Col 1 = Country ID
		-- Col 2 = Country
		-- Col 3 = Temp Unit - REMOVE column
		-- Col 4 = Temp change type - REMOVE column
		-- Years: 1970-2021 = 51 years --> Cols 5-56

--Loading .csv file


-- Inspect data:
Select * from Temp1


-- Select data of interest in a new table (Temp2):
		-- Need: country ID, Coutnry Name & Temperatures (columns 5 ->56), i.e. all but column3 & column4 --> 54 columns in total
CREATE TABLE Temp2
(
	CountryID nvarchar(255),
	Country nvarchar(255),
	Y1970 decimal(6,3), Y1971 decimal(6,3), Y1972 decimal(6,3), Y1973 decimal(6,3), Y1974 decimal(6,3), Y1975 decimal(6,3), Y1976 decimal(6,3), Y1977 decimal(6,3), Y1978 decimal(6,3), Y1979 decimal(6,3),
	Y1980 decimal(6,3), Y1981 decimal(6,3), Y1982 decimal(6,3), Y1983 decimal(6,3), Y1984 decimal(6,3),	Y1985 decimal(6,3), Y1986 decimal(6,3), Y1987 decimal(6,3), Y1988 decimal(6,3),	Y1989 decimal(6,3),
	Y1990 decimal(6,3), Y1991 decimal(6,3), Y1992 decimal(6,3), Y1993 decimal(6,3),	Y1994 decimal(6,3),	Y1995 decimal(6,3), Y1996 decimal(6,3), Y1997 decimal(6,3), Y1998 decimal(6,3),	Y1999 decimal(6,3),
	Y2000 decimal(6,3),	Y2001 decimal(6,3),	Y2002 decimal(6,3),	v2003 decimal(6,3),	Y2004 decimal(6,3),	Y2005 decimal(6,3),	Y2006 decimal(6,3),	Y2007 decimal(6,3),	Y2008 decimal(6,3),	Y2009 decimal(6,3),
	Y2010 decimal(6,3),	Y2011 decimal(6,3),	Y2012 decimal(6,3),	v2013 decimal(6,3),	Y2014 decimal(6,3),	Y2015 decimal(6,3),	Y2016 decimal(6,3),	Y2017 decimal(6,3),	Y2018 decimal(6,3),	Y2019 decimal(6,3),
	Y2020 decimal(6,3),	Y2021 decimal(6,3),
)
	INSERT INTO Temp2
		SELECT column1, column2, column5, column6, column7, column8, column9, column10, column11, column12, column13, column14, column15, column16, column17, column18, column19, column20, 
		column21, column22, column23, column24, column25, column26, column27, column28, column29, column30,
		column31, column32, column33, column34, column35, column36, column37, column38, column39, column40,
		column41, column42, column43, column44, column45, column46, column47, column48, column49, column50,
		column51, column52, column53, column54, column55, column56
			FROM Temp1;

SELECT * FROM Temp2

	-- Fix erroneous column name v2003 to Y2003:
EXECUTE sp_rename N'dbo.Temp2.v2003', N'Y2003', 'COLUMN'

	-- Fix erroneous column name v2013 to Y2013:
EXECUTE sp_rename N'dbo.Temp2.v2013', N'Y2013', 'COLUMN'


	-- Fix erroneous country ID for Zimbabwe:
UPDATE Temp2
	SET CountryID = 227 WHERE Country LIKE 'Zimbabwe';

	SELECT * FROM Temp2




-- Unpivot table in order to transform from wide data to tall data format:
SELECT 
	CountryID,
	Country,
	Year,
	TempChange
FROM Temp2
UNPIVOT
(
	[TempChange] FOR [Year] IN 
	(
		Y1970, Y1971, Y1972, Y1973, Y1974, Y1975, Y1976, Y1977, Y1978, Y1979,
		Y1980, Y1981, Y1982, Y1983, Y1984, Y1985, Y1986, Y1987, Y1988, Y1989,
		Y1990, Y1991, Y1992, Y1993, Y1994, Y1995, Y1996, Y1997, Y1998, Y1999,
		Y2000, Y2001, Y2002, Y2003, Y2004, Y2005, Y2006, Y2007, Y2008, Y2009,
		Y2010, Y2011, Y2012, Y2013, Y2014, Y2015, Y2016, Y2017, Y2018, Y2019,
		Y2020, Y2021
	)
) AS Temp2Pivot;

	-- Create new table (Temp3) with the new data format,as above (unpivoted data):
CREATE TABLE Temp3
(
	CountryID nvarchar(255),
	Country nvarchar(255),
	Year nvarchar(255),
	TempChange decimal(6,3)
)
	INSERT INTO Temp3
		SELECT 
			CountryID,
			Country,
			Year,
			TempChange
FROM Temp2
UNPIVOT
(
	[TempChange] FOR [Year] IN 
	(
		Y1970, Y1971, Y1972, Y1973, Y1974, Y1975, Y1976, Y1977, Y1978, Y1979,
		Y1980, Y1981, Y1982, Y1983, Y1984, Y1985, Y1986, Y1987, Y1988, Y1989,
		Y1990, Y1991, Y1992, Y1993, Y1994, Y1995, Y1996, Y1997, Y1998, Y1999,
		Y2000, Y2001, Y2002, Y2003, Y2004, Y2005, Y2006, Y2007, Y2008, Y2009,
		Y2010, Y2011, Y2012, Y2013, Y2014, Y2015, Y2016, Y2017, Y2018, Y2019,
		Y2020, Y2021
	)
) as Temp2Pivot;

		SELECT * FROM Temp3




--Clean up new data table (year and country names)

	-- Remove 'Y' from input year and convert to date:
SELECT CountryID, Country, Year(CONVERT(date, SUBSTRING(Year, 2, LEN(Year)))) AS 'Year', TempChange
	FROM Temp3


	-- Convert Year column to date format (Temp4):
CREATE TABLE Temp4
(
	CountryID nvarchar(255),
	Country nvarchar(255),
	Year date,
	TempChange decimal(6,3)
)
	INSERT INTO Temp4
		SELECT CountryID, Country, CONVERT(date, SUBSTRING(Year, 2, LEN(Year))) AS 'Year', TempChange
			FROM Temp3

		SELECT * FROM Temp4



	-- Clean up Country names by removing clutter:
SELECT Country, REPLACE(Country, ',', '.')
	From Temp4
				
	-- Add extra full-stop at end of all counrty names:
UPDATE Temp4
    set Country = CONCAT(Country, '.');

	-- Now select varchars in Counrty 'up to while excluding the full stop':
SELECT Country, SUBSTRING(Country, 1, CHARINDEX('.', REPLACE(Country, ',', '.'))-1)
	From Temp4


	-- Create Final cleaned up table, with cleaned up country names and year entries (Temp5):
CREATE TABLE Temp5
(
	CountryID nvarchar(255),
	Country nvarchar(255),
	Year date,
	TempChange decimal(6,3)
)
	INSERT INTO Temp5
		SELECT CountryID, SUBSTRING(Country, 1, CHARINDEX('.', REPLACE(Country, ',', '.'))-1), DATENAME(YEAR, Year), TempChange
			FROM Temp4

			SELECT * FROM Temp5
				-- Export table for graphical visualisation using R.

---------------------------------------------------------------------------------------------------------------






-- Calculation Queries:

	-- Worldwide average temp change across the world 1970-2021:
SELECT AVG(TempChange) from Temp5
			-- On average, +0.606 degrees compared to 50s-80s average
	
	-- Country-specific average temp change across the world 1970-2021:
SELECT CountryID, Country, AVG(Tempchange) AS AverageYearlyDifference
	FROM Temp5
		GROUP BY CountryID, Country
			ORDER BY 3 DESC
				-- Shows countries which have averaged the greatest temperature differences overall, compared to baseline temp from 50's-80's.
					-- Balkan & European countries compose most of the top 10, including Serbia, Montenegro, Estonia, Luxembourg, Belarus, Latvia, Slovenia, Belgium and the Czech Republic


	-- WorldWide average temp change across world in 70s alone
SELECT AVG(TempChange) FROM Temp5 WHERE Year BETWEEN '1970-01-01' AND '1979-01-01'
			-- On average, insignificant yearly increase (+0.011 degrees) in the 70s compared to 50s-80s baseline. 
						-- This is as expected as temperatures from the 70's are included in the baseline temperature calculations (including 50's-80's)

	-- WorldWide average temp change across world in 2010s alone
SELECT AVG(TempChange) FROM Temp5 WHERE Year BETWEEN '2010-01-01' AND '2019-01-01'
			-- On average, over 1 degree (+1.15 degrees) in the 2010's above 50s-80s average temp.

			

	-- Country-specific decade average temp difference 1970-2021 compared to 50's-80's baseline:
		-- Calculate average difference per decade:
				-- 70's:
SELECT DISTINCT Country, AVG(TempChange) OVER (PARTITION BY Country) AS AVGOverallTempChange
	FROM Temp5 
		WHERE Year BETWEEN '1970-01-01' AND '1979-01-01'
					-- Store in temporary tables:
CREATE TABLE #70s
(
	Country nvarchar(255),
	AVGTempChange70s decimal(6,3)
)
	INSERT INTO #70s
		SELECT DISTINCT Country, AVG(TempChange) OVER (PARTITION BY Country) AS AVGOverallTempChange
			FROM Temp5 
				WHERE Year BETWEEN '1970-01-01' AND '1979-01-01'


				-- 80's:
SELECT DISTINCT Country, AVG(TempChange) OVER (PARTITION BY Country) AS AVGOverallTempChange
	FROM Temp5 
		WHERE Year BETWEEN '1980-01-01' AND '1989-01-01'


CREATE TABLE #80s
(
	Country nvarchar(255),
	AVGTempChange70s decimal(6,3)
)
	INSERT INTO #80s
		SELECT DISTINCT Country, AVG(TempChange) OVER (PARTITION BY Country) AS AVGOverallTempChange
			FROM Temp5 
				WHERE Year BETWEEN '1980-01-01' AND '1989-01-01'


				-- 90's:
SELECT DISTINCT Country, AVG(TempChange) OVER (PARTITION BY Country) AS AVGOverallTempChange
	FROM Temp5 
		WHERE Year BETWEEN '1990-01-01' AND '1999-01-01'

CREATE TABLE #90s
(
	Country nvarchar(255),
	AVGTempChange70s decimal(6,3)
)
	INSERT INTO #90s
		SELECT DISTINCT Country, AVG(TempChange) OVER (PARTITION BY Country) AS AVGOverallTempChange
			FROM Temp5 
				WHERE Year BETWEEN '1990-01-01' AND '1999-01-01'


				-- 2000's:
SELECT DISTINCT Country, AVG(TempChange) OVER (PARTITION BY Country) AS AVGOverallTempChange
	FROM Temp5 
		WHERE Year BETWEEN '2000-01-01' AND '2009-01-01'

CREATE TABLE #00s
(
	Country nvarchar(255),
	AVGTempChange70s decimal(6,3)
)
	INSERT INTO #00s
		SELECT DISTINCT Country, AVG(TempChange) OVER (PARTITION BY Country) AS AVGOverallTempChange
			FROM Temp5 
				WHERE Year BETWEEN '2000-01-01' AND '2009-01-01'


				-- 2010's's:
SELECT DISTINCT Country, AVG(TempChange) OVER (PARTITION BY Country) AS AVGOverallTempChange
	FROM Temp5 
		WHERE Year BETWEEN '2009-01-01' AND '2019-01-01'

CREATE TABLE #10s
(
	Country nvarchar(255),
	AVGTempChange70s decimal(6,3)
)
	INSERT INTO #10s
		SELECT DISTINCT Country, AVG(TempChange) OVER (PARTITION BY Country) AS AVGOverallTempChange
			FROM Temp5 
				WHERE Year BETWEEN '2009-01-01' AND '2019-01-01'

				-- 2020's's:
SELECT DISTINCT Country, AVG(TempChange) OVER (PARTITION BY Country) AS AVGOverallTempChange
	FROM Temp5 
		WHERE Year BETWEEN '2020-01-01' AND '2021-01-01'

CREATE TABLE #20s
(
	Country nvarchar(255),
	AVGTempChange70s decimal(6,3)
)
	INSERT INTO #20s
		SELECT DISTINCT Country, AVG(TempChange) OVER (PARTITION BY Country) AS AVGOverallTempChange
			FROM Temp5 
				WHERE Year BETWEEN '2020-01-01' AND '2021-01-01'

				SELECT * FROM #70s
				SELECT * FROM #80s
				SELECT * FROM #90s
				SELECT * FROM #00s
				SELECT * FROM #10s
				SELECT * FROM #20s


		-- Join tables for summary results:
SELECT #70s.Country, 
		#70s.AVGTempChange70s AS AvgTempRise70, 
		#80s.AVGTempChange70s AS AvgTempRise80, 
		#90s.AVGTempChange70s AS AvgTempRise90, 
		#00s.AVGTempChange70s AS AvgTempRise00, 
		#10s.AVGTempChange70s AS AvgTempRise10,
		#20s.AVGTempChange70s AS AvgTempRise20
	FROM #70s
		INNER JOIN #80s 
		ON #70s.Country = #80s.Country
			INNER JOIN #90s
			ON #70s.Country = #90s.Country
				INNER JOIN #00s
				ON #70s.Country = #00s.Country
					INNER JOIN #10s
					ON #70s.Country = #10s.Country
						INNER JOIN #20s
						ON #70s.Country = #20s.Country

			-- Create final Results table:
CREATE TABLE FinalDecadeAVGTempCountries
(
	Country nvarchar(255),
	AvgTemp70 decimal(6,2),
	AvgTemp80 decimal(6,2),
	AvgTemp90 decimal(6,2),
	AvgTemp00 decimal(6,2),
	AvgTemp10 decimal(6,2),
	AvgTemp20 decimal(6,2)
)
		INSERT INTO FinalDecadeAVGTempCountries
			SELECT #70s.Country, 
		#70s.AVGTempChange70s AS AvgTempRise70, 
		#80s.AVGTempChange70s AS AvgTempRise80, 
		#90s.AVGTempChange70s AS AvgTempRise90, 
		#00s.AVGTempChange70s AS AvgTempRise00, 
		#10s.AVGTempChange70s AS AvgTempRise10,
		#20s.AVGTempChange70s AS AvgTempRise20
	FROM #70s
		INNER JOIN #80s 
		ON #70s.Country = #80s.Country
			INNER JOIN #90s
			ON #70s.Country = #90s.Country
				INNER JOIN #00s
				ON #70s.Country = #00s.Country
					INNER JOIN #10s
					ON #70s.Country = #10s.Country
						INNER JOIN #20s
						ON #70s.Country = #20s.Country;

		SELECT * FROM FinalDecadeAVGTempCountries

		-- Produce list ordered by countries with the most temperature difference in the 2020's compared to baseline:
SELECT * FROM FinalDecadeAVGTempCountries
	ORDER BY AvgTemp20 Desc

			-- 80's:
				-- African Countries mostly make up top 20 countries with greatest temperature difference in the 80's, including:
					-- Cabo Verde & Mauritania, Senegal, Gambia, Morrocco, Mali, Burkina Faso, Uganda, Ghana, Algeria, Western Sahara & Namibia.
			-- 90's:
				-- Still mostly African Countries, though now also sharing top 20 with some European countries (Sweden, Switzerland, France, Austria, Netherlands, Germany & Denmark)
			-- 2000's-2020's:
				-- European countries (Austria, Hungary, Switzerland, Romania, Poland, Germany - all in top 15)
				-- Scandinavia (Finland, Sweden, Denmark, Norway all in top 15) 
				-- Middle East (Tunisia, Saudi Arabia, Bahrain, Iraq, Iran, Syria, Algeria, Kuwait, Jordan, Qatar all up in the top 25)


	-- Calculate Overall Worldwide average temperature difference compared to 50's-80's baseline temperature.
SELECT AVG(AvgTemp70) AS '70s', AVG(AvgTemp80)  AS '80s', AVG(AvgTemp90)  AS '90s', AVG(AvgTemp00)  AS '00s', AVG(AvgTemp10)  AS '10s', AVG(AvgTemp20)  AS '20s' 
	FROM FinalDecadeAVGTempCountries
			-- Results shows an average increase of 0.2-0.3 degrees per decade compared to 50's - 80's average temperatures.

---------------------------------------------------------------------------------------------------------------




-- Pivot table back to original state:

	-- Using Temp5 data table (convert data format back to Temp1 table):
		-- Selecting exact data of interest:
SELECT CountryID, Country, DATENAME(YEAR, Year) AS Year, Tempchange 
	FROM Temp5

		-- PIVOT table:
SELECT CountryID,
		[Country],
		[1970], [1971], [1972], [1973], [1974], [1975], [1976], [1977], [1978],[1979],
		[1980], [1981], [1982], [1983], [1984], [1985], [1986], [1987], [1988],[1989],
		[1990], [1991], [1992], [1993], [1994], [1995], [1996], [1997], [1998],[1999],
		[2000], [2001], [2002], [2003], [2004], [2005], [2006], [2007], [2008],[2009],
		[2010], [2011], [2012], [2013], [2014], [2015], [2016], [2017], [2018],[2019],
		[2020], [2021]
	FROM
(
	SELECT CountryID, Country, DATENAME(YEAR, Year) AS Year, Tempchange 
	FROM Temp5
) AS Src
PIVOT
(
	AVG(TempChange)
		FOR [Year] IN ([1970], [1971], [1972], [1973], [1974], [1975], [1976], [1977], [1978],[1979],
						[1980], [1981], [1982], [1983], [1984], [1985], [1986], [1987], [1988],[1989],
						[1990], [1991], [1992], [1993], [1994], [1995], [1996], [1997], [1998],[1999],
						[2000], [2001], [2002], [2003], [2004], [2005], [2006], [2007], [2008],[2009],
						[2010], [2011], [2012], [2013], [2014], [2015], [2016], [2017], [2018],[2019],
						[2020], [2021])
) AS Pvt;


	-- Create final reverted table back to original form (Temp6 = Temp1):
CREATE TABLE Temp6
(
	CountryID nvarchar(255),
	Country nvarchar(255),
	[1970] decimal(6,5), [1971] decimal(6,5), [1972] decimal(6,5), [1973] decimal(6,5), [1974] decimal(6,5), [1975] decimal(6,5), [1976] decimal(6,5), [1977] decimal(6,5), [1978] decimal(6,5), [1979] decimal(6,5),
	[1980] decimal(6,5), [1981] decimal(6,5), [1982] decimal(6,5), [1983] decimal(6,5), [1984] decimal(6,5), [1985] decimal(6,5), [1986] decimal(6,5), [1987] decimal(6,5), [1988] decimal(6,5), [1989] decimal(6,5),
	[1990] decimal(6,5), [1991] decimal(6,5), [1992] decimal(6,5), [1993] decimal(6,5), [1994] decimal(6,5), [1995] decimal(6,5), [1996] decimal(6,5), [1997] decimal(6,5), [1998] decimal(6,5), [1999] decimal(6,5),
	[2000] decimal(6,5), [2001] decimal(6,5), [2002] decimal(6,5), [2003] decimal(6,5), [2004] decimal(6,5), [2005] decimal(6,5), [2006] decimal(6,5), [2007] decimal(6,5), [2008] decimal(6,5), [2009] decimal(6,5),
	[2010] decimal(6,5), [2011] decimal(6,5), [2012] decimal(6,5), [2013] decimal(6,5), [2014] decimal(6,5), [2015] decimal(6,5), [2016] decimal(6,5), [2017] decimal(6,5), [2018] decimal(6,5), [2019] decimal(6,5),
	[2020] decimal(6,5), [2021] decimal(6,5),

)
	INSERT INTO Temp6
		SELECT CountryID,
				[Country],
				[1970], [1971], [1972], [1973], [1974], [1975], [1976], [1977], [1978],[1979],
				[1980], [1981], [1982], [1983], [1984], [1985], [1986], [1987], [1988],[1989],
				[1990], [1991], [1992], [1993], [1994], [1995], [1996], [1997], [1998],[1999],
				[2000], [2001], [2002], [2003], [2004], [2005], [2006], [2007], [2008],[2009],
				[2010], [2011], [2012], [2013], [2014], [2015], [2016], [2017], [2018],[2019],
				[2020], [2021]
			FROM
(
			SELECT CountryID, Country, DATENAME(YEAR, Year) AS Year, Tempchange 
				FROM Temp5
) AS Src
PIVOT
(
	AVG(TempChange)
		FOR [Year] IN ([1970], [1971], [1972], [1973], [1974], [1975], [1976], [1977], [1978],[1979],
						[1980], [1981], [1982], [1983], [1984], [1985], [1986], [1987], [1988],[1989],
						[1990], [1991], [1992], [1993], [1994], [1995], [1996], [1997], [1998],[1999],
						[2000], [2001], [2002], [2003], [2004], [2005], [2006], [2007], [2008],[2009],
						[2010], [2011], [2012], [2013], [2014], [2015], [2016], [2017], [2018],[2019],
						[2020], [2021])
) AS Pvt;


--Confirm result visually:
SELECT * FROM Temp6
SELECT * FROM Temp1
		-- Identical except for original columns 3 and 4 (in Temp1); i.e.: Temp6 is now identical to Temp2 table. 
SELECT * FROM Temp2

---------------------------------------------------------------------------------------------------------------
