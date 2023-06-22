-- London CO2 Levels Analysis (2005-2019)
	-- Data downloaded on 14/03/2023 from https://www.ons.gov.uk/economy/environmentalaccounts/articles/carbondioxideemissionsandwoodlandcoveragewhereyoulive/2021-10-21


-- Create Dataset:
CREATE DATABASE CO2
USE CO2;

-- Load .csv data, and inspect imported table:
SELECT * FROM CO2



-- Clean up DATA: change decimal(10,18) to decimal(4,1), present as 'tall' data format and sort column names:

	-- Sort decimal places:
CREATE TABLE CO2_1
(
	Area nvarchar(50),
	Region nvarchar(50),
	Locality nvarchar(50),
	Code nvarchar(50),
	Y2005 decimal(4,1), Y2006 decimal(4,1), Y2007 decimal(4,1), Y2008 decimal(4,1), Y2009 decimal(4,1), Y2010 decimal(4,1), 
	Y2011 decimal(4,1), Y2012 decimal(4,1), Y2013 decimal(4,1), Y2014 decimal(4,1), Y2015 decimal(4,1), Y2016 decimal(4,1), 
	Y2017 decimal(4,1), Y2018 decimal(4,1), Y2019 decimal(4,1)
)
	INSERT INTO CO2_1
		SELECT Area, Region, City, Code, _2005, _2006, _2007, _2008, _2009, _2010, _2011, _2012, _2013, _2014, _2015, _2016, _2017, _2018, _2019	
			FROM CO2

			SELECT * FROM CO2_1;

	-- UnPivot table from 'wide' to 'tall' data format:
SELECT 
	Area,
	Region,
	Locality,
	Code,
	SampleYear,
	CO2_Lvls
FROM CO2_1
UNPIVOT
(
	[CO2_Lvls] FOR [SampleYear] IN 
	(
		Y2005, Y2006, Y2007, Y2008, Y2009, Y2010, Y2011, Y2012, Y2013, Y2014,
		Y2015, Y2016, Y2017, Y2018, Y2019
	)
) AS CO2Pivot;

CREATE TABLE CO2_2
(
	Area nvarchar(50),
	Region nvarchar(50),
	Locality nvarchar(50),
	Code nvarchar(50),
	Sample_Year nvarchar(50),
	CO2_Lvls decimal(4,1)
)
	INSERT INTO CO2_2
		SELECT 
			Area,
			Region,
			Locality,
			Code,
			SampleYear,
			CO2_Lvls
		FROM CO2_1
		UNPIVOT
		(
			[CO2_Lvls] FOR [SampleYear] IN 
			(
				Y2005, Y2006, Y2007, Y2008, Y2009, Y2010, Y2011, Y2012, Y2013, Y2014,
				Y2015, Y2016, Y2017, Y2018, Y2019
			)
		) AS CO2Pivot
GO
	SELECT * FROM CO2_2;



-- Set 'Sample_Year' column to date format, only showing the year:

	-- Remove the 'Y' from Sample_Year column:
SELECT Sample_Year, SUBSTRING(Sample_Year, 2, LEN(Sample_Year))
	FROM CO2_2

UPDATE CO2_2
	SET Sample_Year = SUBSTRING(Sample_Year, 2, LEN(Sample_Year))
GO
	SELECT * FROM CO2_2;

	-- Change data type from 'Sample_Year' column from nvarchar to date:
UPDATE CO2_2
	SET Sample_Year = DATENAME(Year, CAST(Sample_Year AS Date))
GO
	SELECT * FROM CO2_2;



-- Remove mension of ', City of' or ', County of' from both Region and City columns:
	-- Region column:
UPDATE CO2_2
    SET Region = REPLACE(Region, ',', '.')
GO
UPDATE CO2_2
    SET Region = CONCAT(Region, '.');


UPDATE CO2_2
    SET Region = SUBSTRING(Region, 1, CHARINDEX('.', Region)-1);


	-- City column:
UPDATE CO2_2
    SET Locality = REPLACE(Locality, ',', '.')
GO
UPDATE CO2_2
    SET Locality = CONCAT(Locality, '.');


UPDATE CO2_2
    SET Locality = SUBSTRING(Locality, 1, CHARINDEX('.', Locality)-1);

	-- Final table output:
		SELECT * FROM CO2_2;

-- Export table as .csv for visualisation in R.

