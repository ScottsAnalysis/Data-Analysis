
-- iO Sphere Data Analysis Exercises:
   ---------------------------------


CREATE DATABASE iOsphere

USE iOsphere

-- Import first table (Client logins)

-- Inspect Data visually:
SELECT * FROM ClientSales

-- Rename 'Date column'
EXECUTE sp_rename N'dbo.ClientSales.Date', N'AccessDate', 'COLUMN';


-- Import second table (geo data)

-- Inspect Data visually:
SELECT * FROM geodata

-- Remove extra letters in client ID:
SELECT CLID, SUBSTRING(CLID, CHARINDEX('-', CLID)+1, LEN(CLID)) FROM geodata

UPDATE geodata
	SET CLID = SUBSTRING(CLID, CHARINDEX('-', CLID)+1, LEN(CLID))



-- JOIN tables to include geo data on sales table:
SELECT ClientSales.CLID, ClientSales.AccessDate, ClientSales.Vol, geodata.GEOID
	FROM ClientSales
		JOIN geodata
		ON ClientSales.CLID = geodata.CLID


	-- Create New Table unifying the JOINed tables above:
CREATE TABLE ClientSalesGeo
(
	CLID		nvarchar(20),
	AccessDate	date,
	Vol			numeric,
	GEOID		nvarchar(20)
)
		INSERT INTO ClientSalesGeo
			SELECT ClientSales.CLID, ClientSales.AccessDate, ClientSales.Vol, geodata.GEOID
				FROM ClientSales
					JOIN geodata
					ON ClientSales.CLID = geodata.CLID


SELECT * FROM ClientSalesGeo




-- Stakeholder request: Provide a table of SALES VOLUME BY REGION during Q2 2022:
SELECT GEOID, CASE
		WHEN GEOID = 'GEO1001' THEN 'North America'
		WHEN GEOID = 'GEO1002' THEN 'Asia Pacific'
		WHEN GEOID = 'GEO1003' THEN 'Europe, Middle-East & Africa'
		ELSE 'Latin America'
			END AS Region,
				SUM(Vol) AS TotalSalesVolumeQ2_2022
	FROM ClientSalesGeo
		WHERE AccessDate BETWEEN '2022/04/01' AND '2022/07/01'
			GROUP BY GEOID
				ORDER BY 3 DESC

