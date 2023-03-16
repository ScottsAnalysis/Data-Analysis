--NASHVILLE HOUSING DATA CLEANING - (Data downloaded on 02/02/2023)

--CREATE DATABASE: Nash	
	USE Nash;


--VISUALISE LOADED .csv DATA
SELECT * FROM NashvilleHousing;


--1) Standardise data format:

	-- Remove time, keep date only
SELECT SaleDate, CONVERT(date, SaleDate)
	FROM NashvilleHousing;

UPDATE NashvilleHousing
	SET SaleDate = CONVERT(date, SaleDate);

	SELECT * FROM NashvilleHousing;

	-- Can also do it this way:
ALTER TABLE NashvilleHousing
	ADD SaleDateConverted date;

	UPDATE NashvilleHousing
		SET SaleDateConverted = CONVERT(date, SaleDate);

		SELECT * FROM NashvilleHousing;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------




--2) Populate all 'PropertyAddress' fields:

	--Self-JOIN the table to itself:
SELECT * 
	FROM NashvilleHousing AS a			
		JOIN NashvilleHousing AS b		
		ON a.ParcelID = b.ParcelID
			AND a.[UniqueID] <> b.[UniqueID];		

	--Check the JOIN between ParcelID and PropertyAddress columns visualy:
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress 
	FROM NashvilleHousing a
		JOIN NashvilleHousing b	
		ON a.ParcelID = b.ParcelID
			AND a.[UniqueID] <> b.[UniqueID];

	--Filter for NULLS:
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress 
	FROM NashvilleHousing a			
		JOIN NashvilleHousing b		
		ON a.ParcelID = b.ParcelID
			AND a.[UniqueID] <> b.[UniqueID]
				WHERE a.PropertyAddress IS NULL;

	--Screen PropertyAddress for NULLS (in table a) and replace them with corresponding PropertyAddress (from table b):
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM NashvilleHousing a			
		JOIN NashvilleHousing b		
		ON a.ParcelID = b.ParcelID
			AND a.[UniqueID] <> b.[UniqueID]
				WHERE a.PropertyAddress IS NULL;
	
	--Finalise Manipulation using same JOIN command as above:
UPDATE a
	SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)		
		FROM NashvilleHousing a												
			JOIN NashvilleHousing b		
			ON a.ParcelID = b.ParcelID
				AND a.[UniqueID] <> b.[UniqueID]
					WHERE a.PropertyAddress IS NULL;

	--Check final output:
SELECT * 
	FROM NashvilleHousing;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------



--3) Breaking data out into iundividual columns
	--A) For 'PropertyAddress' - seperate Address from City:
SELECT PropertyAddress
	FROM NashvilleHousing;

		-- Use SUBSTRING and CHARINDEX to separate Address from City
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address
	FROM NashvilleHousing;

		-- Remove comma:
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
	FROM NashvilleHousing

		-- Isolate Address data from City data:
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
			SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress)) AS City
	FROM NashvilleHousing


		-- Create new Address column in database table and insert data:
ALTER TABLE NashvilleHousing
	ADD PropSplitAddress nvarchar(50);

		UPDATE NashvilleHousing
			SET PropSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

		-- Same for the new City column:
ALTER TABLE NashvilleHousing
	ADD PropSplitCity nvarchar(50);

		UPDATE NashvilleHousing
			SET PropSplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress));

	-- Inspect the new columns:
		SELECT * FROM NashvilleHousing;



	--B) For 'OwnerAddress' --> Generate 3 new columns: 'Address', 'City', 'State' (slightly different way):
SELECT OwnerAddress
	FROM NashvilleHousing;

		-- Use PARSENAME, to split entries:
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
	FROM NashvilleHousing;							

		-- Isolate City:
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
	FROM NashvilleHousing;

		-- Address:
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
	FROM NashvilleHousing;

		-- Altogether:
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
		 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
	FROM NashvilleHousing;


		-- Create new Owner Address column in database table and insert data:
ALTER TABLE NashvilleHousing
	ADD OwnerSplitAddress nvarchar(50);

		UPDATE NashvilleHousing
			SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

		-- Create new Owner City column
ALTER TABLE NashvilleHousing
	ADD OwnerSplitCity nvarchar(50);

		UPDATE NashvilleHousing
			SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

		-- Create new Owner City column
ALTER TABLE NashvilleHousing
	ADD OwnerSplitState nvarchar(50);

		UPDATE NashvilleHousing
			SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

	-- Inspect the new columns:
SELECT * FROM NashvilleHousing;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------




--4) Remove duplicate data:
	-- Screen and count for duplicate rows:
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
	FROM NashvilleHousing
		ORDER BY ParcelID


	-- Filter any data row that contain a value other than 1 in 'row_num' using a CTE (or a View):
WITH RowNumCTE AS(
	SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
		FROM NashvilleHousing
)
	SELECT * FROM RowNumCTE
		WHERE row_num <> 1

	-- Remove duplicates:
WITH RowNumCTE AS(
	SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
		FROM NashvilleHousing
)
	DELETE FROM RowNumCTE
		WHERE row_num <> 1



-- Delete unused columns:

	--Remove the concatenated OwnerAddress, TaxDistrict and PropertyAddress columns
ALTER TABLE NashvilleHousing
	DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

	-- Visualise final data:
SELECT * FROM NashvilleHousing;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------


--6) Calculations:

	-- What was the minimum, mean and max property sale prices?
SELECT MIN(SalePrice), AVG(SalePrice), MAX(SalePrice) 
	FROM NashvilleHousing


    -- Calculate yearly, quarterly and monthly total property sale value:
		-- Yearly total sales:
SELECT YEAR(SaleDate), SUM(SalePrice)
	FROM NashvilleHousing
		GROUP BY YEAR(SaleDate)
			ORDER BY 1


		-- Monthly total sale value:
SELECT YEAR(SaleDate) AS SaleYear, MONTH(SaleDate) AS SaleMonth, SUM(SalePrice) AS TotalSpent
	FROM NashvilleHousing
		GROUP BY YEAR(SaleDate), MONTH(SaleDate)
			ORDER BY 1, 2


		-- Monthly & Yearly sales on same table:
SELECT YEAR(SaleDate), MONTH(SaleDate), 
						CASE WHEN MONTH(SaleDate) IS NULL THEN 'YEARLY' ELSE 'MONTHLY' END AS Totals ,
							SUM(SalePrice) AS TotalSales
	FROM NashvilleHousing
		GROUP BY GROUPING SETS ((YEAR(SaleDate)), (YEAR(SaleDate), MONTH(SaleDate)))
		

		-- Quarterly total sale value:
SELECT YEAR(SaleDate) AS SaleYear, DATEPART(QUARTER, SaleDate) AS QuarterName,
				MONTH(SaleDate) AS MonthSale, 
						CASE WHEN MONTH(SaleDate) IS NULL AND DATEPART(QUARTER, SaleDate) IS NULL THEN 'YEARLY' WHEN MONTH(SaleDate) IS NULL THEN 'QUARTERLY' ELSE 'MONTHLY' END AS Totals ,
							SUM(SalePrice) AS TotalSales
	FROM NashvilleHousing
		GROUP BY GROUPING SETS ((YEAR(SaleDate)), (YEAR(SaleDate), DATEPART(QUARTER, SaleDate)), (YEAR(SaleDate), MONTH(SaleDate)))
			ORDER BY YEAR(SaleDate), DATEPART(QUARTER, SaleDate), MONTH(SaleDate)





