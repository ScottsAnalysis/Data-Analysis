


--LPJ Sales Data Analysis - POWERBI Graphs:




									-- Analysis 1: ITEMS


	-- 1) Overall ITEM Sales:

		-- A) OVERALL table of ITEMS total sales numbers & amounts:
SELECT Type, Collection, COUNT(Quantity) AS TotalSales, SUM(Price) AS TotalEURSales
	FROM PaidLabProducts	
		WHERE Type = 'I' AND Collection IS NOT NULL
			GROUP BY Type, Collection
				ORDER BY 3 DESC			--## USE TO MAKE TREE MAP, SUMMARY TABLE, & PIE CHART OF ITEM ORDERS


		-- B) OVERALL time series (CUMULATIVE) of products total sales amount:
SELECT DISTINCT OrderDate, Type, Collection, COUNT(Quantity) OVER (PARTITION BY Collection ORDER BY Collection, OrderDate)
	FROM PaidLabProducts
		WHERE OrderDate IS NOT NULL AND Collection IS NOT NULL AND Type = 'I'
			ORDER BY 3,1			--## USE TO MAKE TIME SERIES OF ITEM ORDERS SALES

				-- Use 'Daily Sales' below to add columns to line graph above:
SELECT DISTINCT OrderDate, Type, Collection, COUNT(Quantity) OVER (PARTITION BY OrderDate, Collection ORDER BY Collection, OrderDate)
	FROM PaidLabProducts
		WHERE OrderDate IS NOT NULL AND Collection IS NOT NULL AND Type = 'I'
			ORDER BY 3,1



		-- C) YEARLY breakdown of ITEMS # of Sales (ALL TIME) --IS THIS USEFULL?? 
SELECT YEAR(OrderDate), Collection, COUNT(Quantity)
	FROM PaidLabProducts	
		WHERE Type = 'I' AND Collection IS NOT NULL
			GROUP BY YEAR(OrderDate), Collection
				ORDER BY 2,1			--## USE TO MAKE TIME SERIES / AREA GRAPH OF ITEM ORDERS SALES

			-- Monthly ITEMS Sales Seasonality (ALL TIME):
SELECT * FROM SeasonSales
	WHERE Type = 'I'
		ORDER BY 1,2,5 DESC			--## USE TO MAKE TIME SERIES / AREA GRAPH OF ITEM ORDERS SALES






	-- 2) Overall SHOE Sales BY YEAR:
		-- A) OVERALL table of SHOES total sales numbers & amounts:
SELECT Type, Collection, COUNT(Quantity) AS TotalSales, SUM(Price) AS TotalEURSales
	FROM PaidLabProducts	
		WHERE Type = 'S' AND Collection IS NOT NULL
			GROUP BY Type, Collection
				ORDER BY 3 DESC			


		-- B) OVERALL time series (CUMULATIVE) of products total sales amount:
SELECT DISTINCT OrderDate, Type, Collection, COUNT(Quantity) OVER (PARTITION BY Collection ORDER BY Collection, OrderDate)
	FROM PaidLabProducts
		WHERE OrderDate IS NOT NULL AND Collection IS NOT NULL AND Type = 'S'
			ORDER BY 3,1			

				-- Use 'Daily Sales' below to add columns to line graph above:
SELECT DISTINCT OrderDate, Type, Collection, COUNT(Quantity) OVER (PARTITION BY OrderDate, Collection ORDER BY Collection, OrderDate)
	FROM PaidLabProducts
		WHERE OrderDate IS NOT NULL AND Collection IS NOT NULL AND Type = 'S'
			ORDER BY 3,1


		-- C) YEARLY breakdown of SHOES # of Sales (ALL TIME) --IS THIS USEFULL?? 
SELECT YEAR(OrderDate), Collection, COUNT(Quantity)
	FROM PaidLabProducts	
		WHERE Type = 'S' AND Collection IS NOT NULL
			GROUP BY YEAR(OrderDate), Collection
				ORDER BY 2,1			

			-- Monthly ITEMS Sales Seasonality (ALL TIME):
SELECT * FROM SeasonSales
	WHERE Type = 'I'
		ORDER BY 1,2,5 DESC			

			-- Monthly SHOES Sales Seasonality (ALL TIME):
SELECT * FROM SeasonSales
	WHERE Type = 'S'
		ORDER BY 1,2,5 DESC			







	-- 3) 2016-2017 ITEM Sales BY YEAR:

		-- A) 2016 ITEM Sales:
DROP TABLE IF EXISTS #Sales2016
CREATE TABLE #Sales2016
(
	ItemType nvarchar(5),
	ItemCode nvarchar(10), 
	NumOfSales16 int, 
	SalesEURTotal16 decimal(7,2),
	EURPercOfTotal16 decimal(4,2)
)
	INSERT INTO #Sales2016
		SELECT Type, Collection, COUNT(Quantity), SUM(Price), (SUM(Price)/(SELECT SUM(Price) FROM PaidLabProducts WHERE OrderDate <'01-01-2017'))*100
			FROM PaidLabProducts
				WHERE OrderDate < '01-01-2017'
					GROUP BY Type, Collection

SELECT * FROM #Sales2016
	WHERE ItemType = 'I'
		ORDER BY 4 DESC		
																	


		-- B) 2017 ITEM Sales:
DROP TABLE IF EXISTS #Sales2017
CREATE TABLE #Sales2017
(
	ItemType nvarchar(5),
	ItemCode nvarchar(10), 
	NumOfSales17 int, 
	SalesEURTotal17 decimal(7,2),
	EURPercOfTotal17 decimal(4,2)
)
	INSERT INTO #Sales2017
		SELECT Type, Collection, COUNT(Quantity), SUM(Price), (SUM(Price)/(SELECT SUM(Price) FROM PaidLabProducts WHERE OrderDate BETWEEN '01-01-2017' AND '01-01-2018' AND Collection IS NOT NULL))*100
			FROM PaidLabProducts
				WHERE OrderDate BETWEEN '01-01-2017' AND '01-01-2018' AND Collection IS NOT NULL
					GROUP BY Type, Collection

SELECT * FROM #Sales2017
	WHERE ItemType = 'I'
		ORDER BY 4 DESC              
																



		-- C) 2016-2017 Seasonal purchases Time series
SELECT * FROM SeasonISales1617
	WHERE Type = 'I'
		ORDER BY 3, 1 DESC						







	-- 4) 2018-2019 ITEM Sales BY YEAR:


		-- A) 2018 ITEM Sales:
DROP TABLE IF EXISTS #Sales2018
CREATE TABLE #Sales2018
(
	ItemType nvarchar(5),
	ItemCode nvarchar(10), 
	NumOfSales18 int, 
	SalesEURTotal18 decimal(7,2),
	EURPercOfTotal18 decimal(4,2)
)
	INSERT INTO #Sales2018
		SELECT Type, Collection, COUNT(Quantity), SUM(Price), (SUM(Price)/(SELECT SUM(Price) FROM PaidLabProducts WHERE OrderDate BETWEEN '01-01-2018' AND '01-01-2019' AND Collection IS NOT NULL))*100
			FROM PaidLabProducts
				WHERE OrderDate BETWEEN '01-01-2018' AND '01-01-2019' AND Collection IS NOT NULL
					GROUP BY Type, Collection

SELECT * FROM #Sales2018
	WHERE ItemType = 'I'
		ORDER BY 4 DESC
			
																		


		-- B) 2019 ITEM Sales:
DROP TABLE IF EXISTS #Sales2019
CREATE TABLE #Sales2019
(
	ItemType nvarchar(5),
	ItemCode nvarchar(10), 
	NumOfSales19 int, 
	SalesEURTotal19 decimal(7,2),
	EURPercOfTotal19 decimal(4,2)
)
	INSERT INTO #Sales2019
		SELECT Type, Collection, COUNT(Quantity), SUM(Price), (SUM(Price)/(SELECT SUM(Price) FROM PaidLabProducts WHERE OrderDate BETWEEN '01-01-2019' AND '01-01-2020' AND Type = 'I'))*100
			FROM PaidLabProducts
				WHERE OrderDate BETWEEN '01-01-2019' AND '01-01-2020' AND Collection IS NOT NULL
					GROUP BY Type, Collection

SELECT * FROM #Sales2019
	WHERE ItemType = 'I'
		ORDER BY 4 DESC
			
																	

						SELECT SUM(EURPercOfTotal19) FROM #Sales2019

		-- C) 2018-2019 Seasonal purchases Time series
SELECT * FROM SeasonISales1819
	WHERE Type = 'I'
		ORDER BY 3,1						








	-- 5) 2020-2021 ITEM Sales BY YEAR:


		-- A) 2020 ITEM Sales:
DROP TABLE IF EXISTS #Sales2020
CREATE TABLE #Sales2020
(
	ItemType nvarchar(5),
	ItemCode nvarchar(10), 
	NumOfSales20 int, 
	SalesEURTotal20 decimal(7,2),
	EURPercOfTotal20 decimal(4,2)
)
	INSERT INTO #Sales2020
		SELECT Type, Collection, COUNT(Quantity), SUM(Price), (SUM(Price)/(SELECT SUM(Price) FROM PaidLabProducts WHERE OrderDate BETWEEN '01-01-2020' AND '01-01-2021' AND Type = 'I'))*100
			FROM PaidLabProducts
				WHERE OrderDate BETWEEN '01-01-2020' AND '01-01-2021' AND Collection IS NOT NULL
					GROUP BY Type, Collection

SELECT * FROM #Sales2020
	WHERE ItemType = 'I'
		ORDER BY 4 DESC
			
																		


		-- B) 2021 ITEM Sales:
DROP TABLE IF EXISTS #Sales2021
CREATE TABLE #Sales2021
(
	ItemType nvarchar(5),
	ItemCode nvarchar(10), 
	NumOfSales21 int, 
	SalesEURTotal21 decimal(7,2),
	EURPercOfTotal21 decimal(7,2)
)
	INSERT INTO #Sales2021
		SELECT Type, Collection, COUNT(Quantity), SUM(Price), (SUM(Price)/(SELECT SUM(Price) FROM PaidLabProducts WHERE OrderDate BETWEEN '01-01-2021' AND '01-01-2022' AND Type = 'I'))*100
			FROM PaidLabProducts
				WHERE OrderDate BETWEEN '01-01-2021' AND '01-01-2022' AND Collection IS NOT NULL
					GROUP BY Type, Collection

SELECT * FROM #Sales2021
	WHERE ItemType = 'I'
		ORDER BY 4 DESC


		-- C) 2020-2021 Seasonal purchases Time series
SELECT * FROM SeasonISales2021
	WHERE Type = 'I'
		ORDER BY 3,1						








		-- 6) 2022-2023 ITEM Sales BY YEAR:


		-- A) 2022 ITEM Sales:
DROP TABLE IF EXISTS #Sales2022
CREATE TABLE #Sales2022
(
	ItemType nvarchar(5),
	ItemCode nvarchar(10), 
	NumOfSales22 int, 
	SalesEURTotal22 decimal(7,2),
	EURPercOfTotal22 decimal(4,2)
)
	INSERT INTO #Sales2022
		SELECT Type, Collection, COUNT(Quantity), SUM(Price), (SUM(Price)/(SELECT SUM(Price) FROM PaidLabProducts WHERE OrderDate BETWEEN '01-01-2022' AND '01-01-2023' AND Type = 'I'))*100
			FROM PaidLabProducts
				WHERE OrderDate BETWEEN '01-01-2022' AND '01-01-2023' AND Collection IS NOT NULL
					GROUP BY Type, Collection

SELECT * FROM #Sales2022
	WHERE ItemType = 'I'
		ORDER BY 4 DESC
		


		-- B) 2023 ITEM Sales:
DROP TABLE IF EXISTS #Sales2023
CREATE TABLE #Sales2023
(
	ItemType nvarchar(5),
	ItemCode nvarchar(10), 
	NumOfSales23 int, 
	SalesEURTotal23 decimal(7,2),
	EURPercOfTotal23 decimal(7,2)
)
	INSERT INTO #Sales2023
		SELECT Type, Collection, COUNT(Quantity), SUM(Price), (SUM(Price)/(SELECT SUM(Price) FROM PaidLabProducts WHERE OrderDate > '01-01-2023' AND Type = 'I'))*100
			FROM PaidLabProducts
				WHERE OrderDate > '01-01-2023' AND Collection IS NOT NULL
					GROUP BY Type, Collection

SELECT * FROM #Sales2023
	WHERE ItemType = 'I'
		ORDER BY 4 DESC
			



		-- C) 2022-2023 Seasonal purchases Time series
SELECT * FROM SeasonISales2223
	WHERE Type = 'I'
		ORDER BY 3,1		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------





									-- Analysis 2: SHOES



	-- 7) Overall SHOES Sales:

		-- A) OVERALL table of SHOES total sales numbers & amounts:
SELECT Type, Collection, COUNT(Quantity) AS TotalSales, SUM(Price) AS TotalEURSales
	FROM PaidLabProducts	
		WHERE Type = 'S' AND Collection IS NOT NULL
			GROUP BY Type, Collection
				ORDER BY 3 DESC			


		-- B) OVERALL time series (CUMULATIVE) of products total sales amount:
SELECT DISTINCT OrderDate, Type, Collection, COUNT(Quantity) OVER (PARTITION BY Collection ORDER BY Collection, OrderDate)
	FROM PaidLabProducts
		WHERE OrderDate IS NOT NULL AND Collection IS NOT NULL AND Type = 'S'
			ORDER BY 3,1			

				-- Use 'Daily Sales' below to add columns to line graph above:
SELECT DISTINCT OrderDate, Type, Collection, COUNT(Quantity) OVER (PARTITION BY OrderDate, Collection ORDER BY Collection, OrderDate)
	FROM PaidLabProducts
		WHERE OrderDate IS NOT NULL AND Collection IS NOT NULL AND Type = 'S'
			ORDER BY 3,1


		-- C) IS THIS USEFULL??  -- YEARLY breakdown of ITEMS # of Sales
SELECT YEAR(OrderDate), Collection, COUNT(Quantity)
	FROM PaidLabProducts	
		WHERE Type = 'S' AND Collection IS NOT NULL
			GROUP BY YEAR(OrderDate), Collection
				ORDER BY 2,1






	-- 8) 2018-2019 SHOE Sales BY YEAR:
		-- A) 2018 SHOE Sales:
DROP TABLE IF EXISTS #Sales2018
CREATE TABLE #Sales2018
(
	ItemType nvarchar(5),
	ItemCode nvarchar(10), 
	NumOfSales18 int, 
	SalesEURTotal18 decimal(7,2),
	EURPercOfTotal18 decimal(4,2)
)
	INSERT INTO #Sales2018
		SELECT Type, Collection, COUNT(Quantity), SUM(Price), (SUM(Price)/(SELECT SUM(Price) FROM PaidLabProducts WHERE OrderDate BETWEEN '01-01-2018' AND '01-01-2019' AND Type = 'S'))*100
			FROM PaidLabProducts
				WHERE OrderDate BETWEEN '01-01-2018' AND '01-01-2019' AND Collection IS NOT NULL
					GROUP BY Type, Collection

SELECT * FROM #Sales2018
	WHERE ItemType = 'S'
		ORDER BY 4 DESC
		
																	

		-- B) 2019 SHOE Sales:
DROP TABLE IF EXISTS #Sales2019
CREATE TABLE #Sales2019
(
	ItemType nvarchar(5),
	ItemCode nvarchar(10), 
	NumOfSales19 int, 
	SalesEURTotal19 decimal(7,2),
	EURPercOfTotal19 decimal(4,2)
)
	INSERT INTO #Sales2019
		SELECT Type, Collection, COUNT(Quantity), SUM(Price), (SUM(Price)/(SELECT SUM(Price) FROM PaidLabProducts WHERE OrderDate BETWEEN '01-01-2019' AND '01-01-2020' AND Type = 'S'))*100
			FROM PaidLabProducts
				WHERE OrderDate BETWEEN '01-01-2019' AND '01-01-2020' AND Collection IS NOT NULL
					GROUP BY Type, Collection

SELECT * FROM #Sales2019
	WHERE ItemType = 'S'
		ORDER BY 4 DESC
																		

		-- C) 2018-2019 Seasonal purchases Time series
SELECT * FROM SeasonSSales1819
	WHERE Type = 'S'
		ORDER BY 3,1					





	-- 8) 2020-2021 SHOE Sales BY YEAR:

		-- A) 2020 SHOE Sales:
DROP TABLE IF EXISTS #Sales2020
CREATE TABLE #Sales2020
(
	ItemType nvarchar(5),
	ItemCode nvarchar(10), 
	NumOfSales20 int, 
	SalesEURTotal20 decimal(7,2),
	EURPercOfTotal20 decimal(4,2)
)
	INSERT INTO #Sales2020
		SELECT Type, Collection, COUNT(Quantity), SUM(Price), (SUM(Price)/(SELECT SUM(Price) FROM PaidLabProducts WHERE OrderDate BETWEEN '01-01-2020' AND '01-01-2021' AND Type = 'S'))*100
			FROM PaidLabProducts
				WHERE OrderDate BETWEEN '01-01-2020' AND '01-01-2021' AND Collection IS NOT NULL
					GROUP BY Type, Collection

SELECT * FROM #Sales2020
	WHERE ItemType = 'S'
		ORDER BY 4 DESC
																		

		-- B) 2021 SHOE Sales:
DROP TABLE IF EXISTS #Sales2021
CREATE TABLE #Sales2021
(
	ItemType nvarchar(5),
	ItemCode nvarchar(10), 
	NumOfSales21 int, 
	SalesEURTotal21 decimal(7,2),
	EURPercOfTotal21 decimal(4,2)
)
	INSERT INTO #Sales2021
		SELECT Type, Collection, COUNT(Quantity), SUM(Price), (SUM(Price)/(SELECT SUM(Price) FROM PaidLabProducts WHERE OrderDate BETWEEN '01-01-2021' AND '01-01-2022' AND Type = 'S'))*100
			FROM PaidLabProducts
				WHERE OrderDate BETWEEN '01-01-2021' AND '01-01-2022' AND Collection IS NOT NULL
					GROUP BY Type, Collection

SELECT * FROM #Sales2021
	WHERE ItemType = 'S'
		ORDER BY 4 DESC


		-- C) 2020-2021 Seasonal purchases Time series
SELECT * FROM SeasonSSales2021
	WHERE Type = 'S'
		ORDER BY 3,1						







	-- 9) 2022-2023 SHOE Sales BY YEAR:

		-- A) 2022 SHOE Sales:
DROP TABLE IF EXISTS #Sales2022
CREATE TABLE #Sales2022
(
	ItemType nvarchar(5),
	ItemCode nvarchar(10), 
	NumOfSales22 int, 
	SalesEURTotal22 decimal(7,2),
	EURPercOfTotal22 decimal(4,2)
)
	INSERT INTO #Sales2022
		SELECT Type, Collection, COUNT(Quantity), SUM(Price), (SUM(Price)/(SELECT SUM(Price) FROM PaidLabProducts WHERE OrderDate BETWEEN '01-01-2022' AND '01-01-2023'AND Type = 'S'))*100
			FROM PaidLabProducts
				WHERE OrderDate BETWEEN '01-01-2022' AND '01-01-2023' AND Collection IS NOT NULL
					GROUP BY Type, Collection

SELECT * FROM #Sales2022
	WHERE ItemType = 'S'
		ORDER BY 4 DESC
																	

		-- B) 2023 SHOE Sales:
DROP TABLE IF EXISTS #Sales2023
CREATE TABLE #Sales2023
(
	ItemType nvarchar(5),
	ItemCode nvarchar(10), 
	NumOfSales23 int, 
	SalesEURTotal23 decimal(7,2),
	EURPercOfTotal23 decimal(4,2)
)
	INSERT INTO #Sales2023
		SELECT Type, Collection, COUNT(Quantity), SUM(Price), (SUM(Price)/(SELECT SUM(Price) FROM PaidLabProducts WHERE OrderDate > '01-01-2023'AND Type = 'S'))*100
			FROM PaidLabProducts
				WHERE OrderDate > '01-01-2023' AND Collection IS NOT NULL
					GROUP BY Type, Collection

SELECT * FROM #Sales2023
	WHERE ItemType = 'S'
		ORDER BY 4 DESC
																




		-- C) 2022-2023 Seasonal purchases Time series
SELECT * FROM SeasonSSales2223
	WHERE Type = 'S'
		ORDER BY 3,1					
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------





									-- Analysis 3: COUNTRIES


-- 10) Number of Sales (Items & Shoes) by country (copied from Country Analysis):
SELECT Country, COUNT(Quantity) 
	FROM PaidLabProducts 
		WHERE OrderDate IS NOT NULL AND Collection IS NOT NULL
			GROUP BY Country
				ORDER BY 2 DESC						


-- Number of ITEMS bought across years:
SELECT Country, OrderDate, Collection, COUNT(Quantity) OVER (PARTITION BY Collection, Country ORDER BY Country, Collection, OrderDate) AS NumberOfITEMSSold
	FROM PaidLabProducts 
		WHERE OrderDate IS NOT NULL AND Type = 'I' AND Collection IS NOT NULL
			--GROUP BY Country, OrderDate, Collection
				ORDER BY 1,2 DESC						


-- Number of SHOES bought across years:
SELECT Country, OrderDate, Collection, SUM(Quantity) OVER (PARTITION BY Collection, Country ORDER BY Country, Collection, OrderDate) AS NumberOfSHOESSold
	FROM PaidLabProducts 
		WHERE OrderDate IS NOT NULL AND Type = 'S' AND Collection IS NOT NULL
			--GROUP BY Country, OrderDate, Collection
				ORDER BY 1,2 DESC						





-- ANALYSIS OF SEMESTER SALES (H1 sales vs H2 sales):

	-- Item sales in H1:
DROP VIEW IF EXISTS H1ISales
GO
CREATE VIEW H1ISales
AS
	SELECT DISTINCT Country, Collection, SUM(Quantity) AS NumberOfSales
		FROM PaidLabProducts 
			WHERE DATEPART(MONTH, OrderDate) <= 7 AND Collection IS NOT NULL AND Type = 'I'
				GROUP BY Country, Collection
GO
SELECT * FROM H1ISales ORDER BY 1,3 DESC



	-- Item sales in H2:
DROP VIEW IF EXISTS H2ISales
GO
CREATE VIEW H2ISales
AS
	SELECT DISTINCT Country, Collection, SUM(Quantity) AS NumberOfSales
		FROM PaidLabProducts 
			WHERE DATEPART(MONTH, OrderDate) >= 7 AND Collection IS NOT NULL AND Type = 'I'
				GROUP BY Country, Collection
GO
SELECT * FROM H2ISales ORDER BY 1,3 DESC



	-- Shoe sales in H1:
DROP VIEW IF EXISTS H1SSales
GO
CREATE VIEW H1SSales
AS
	SELECT DISTINCT Country, Collection, SUM(Quantity) AS NumberOfSales
		FROM PaidLabProducts 
			WHERE DATEPART(MONTH, OrderDate) <= 7 AND Collection IS NOT NULL AND Type = 'S'
				GROUP BY Country, Collection
GO
SELECT * FROM H1SSales ORDER BY 1,3 DESC



	-- Shoe sales in H2:
DROP VIEW IF EXISTS H2SSales
GO
CREATE VIEW H2SSales
AS
	SELECT DISTINCT Country, Collection, SUM(Quantity) AS NumberOfSales
		FROM PaidLabProducts 
			WHERE DATEPART(MONTH, OrderDate) >= 7 AND Collection IS NOT NULL AND Type = 'S'
				GROUP BY Country, Collection
GO
SELECT * FROM H2SSales ORDER BY 1,3
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
