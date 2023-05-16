


USE LPJ;

-- Data Cleaning & Preparation:
--=============================


-- Data Clean-Up For Analysis (raw data): 
SELECT * FROM Orders


	-- Create new PRODUCTS table (Isolating salient data):
SELECT OrderID, BillingName, BillingCountry, Email, PaidDate, ItemQuantity, ItemName, ItemPrice, ItemSKU, FinancialStatus 
	FROM Orders



-- A) Create new table Adding Item Labels - Ultimately generate new Item codes:
DROP TABLE IF EXISTS LabelledProducts
GO
CREATE TABLE LabelledProducts
(
	OrderID int,
	Name nvarchar(50),
	Country nvarchar(10),
	Email nvarchar(100),
	OrderDate date,
	Fulfilled nvarchar(50),
	Quantity int,
	ItemName nvarchar(100),
	Type nvarchar(15),			-- Item or Shoe
	Collection nvarchar(50),	-- Item Name Family/Collection (ALEX, CINDY, HOYA etc).
	Price decimal(9,2),
	ItemSKU nvarchar(50),
	Status nvarchar(50)
)
	INSERT INTO LabelledProducts
		SELECT OrderID, BillingName, BillingCountry, Email, PaidDate, FulfillmentStatus, ItemQuantity, ItemName, NULL, NULL, ItemPrice, ItemSKU, FinancialStatus 
			FROM Orders
GO
SELECT * FROM LabelledProducts
	ORDER BY 1 DESC

	-- 'TYPE' labelling
		-- Set Shoes label ('S')
UPDATE LabelledProducts
	SET Type = 'S' WHERE ItemName LIKE '%- 3%' OR ItemName LIKE '%- 4%';

		-- Set other Items label ('I')
UPDATE LabelledProducts
	SET Type = 'I' WHERE Type IS NULL;



	-- 'COLLECTION' labelling:

		-- Set Item 'I' Names:
UPDATE LabelledProducts	SET Collection = 'ALE' WHERE ItemName LIKE '%ALEX%';
UPDATE LabelledProducts	SET Collection = 'TRI' WHERE ItemName LIKE '%TRILLY%';
UPDATE LabelledProducts	SET Collection = 'LUL' WHERE ItemName LIKE '%LULU%';
UPDATE LabelledProducts	SET Collection = 'CLO' WHERE ItemName LIKE '%CLOUD%';
UPDATE LabelledProducts	SET Collection = 'IVY' WHERE ItemName LIKE '%IVY%';
UPDATE LabelledProducts	SET Collection = 'BIB' WHERE ItemName LIKE '%BIBI%';
UPDATE LabelledProducts	SET Collection = 'MIC' WHERE ItemName LIKE '%MICK%';
UPDATE LabelledProducts	SET Collection = 'GIN' WHERE ItemName LIKE '%GINNY%';
UPDATE LabelledProducts	SET Collection = 'COS' WHERE ItemName LIKE '%COSMO%';
UPDATE LabelledProducts	SET Collection = 'PIX' WHERE ItemName LIKE '%PIXIE%';
UPDATE LabelledProducts	SET Collection = 'HEA' WHERE ItemName LIKE '%HEART%';
UPDATE LabelledProducts	SET Collection = 'AND' WHERE ItemName LIKE '%ANDY%';
UPDATE LabelledProducts	SET Collection = 'DAL' WHERE ItemName LIKE '%DALIAH%';
UPDATE LabelledProducts	SET Collection = 'JAN' WHERE ItemName LIKE '%JANIS%';
UPDATE LabelledProducts	SET Collection = 'EMM' WHERE ItemName LIKE '%EMMA%';
UPDATE LabelledProducts	SET Collection = 'CRD' WHERE ItemName LIKE '%CARDHOLDER%';
UPDATE LabelledProducts	SET Collection = 'MEG' WHERE ItemName LIKE '%MEGHAN%';
UPDATE LabelledProducts	SET Collection = 'LIN' WHERE ItemName LIKE '%LINDA%';

UPDATE LabelledProducts	SET Collection = 'TRA' WHERE ItemName LIKE '%TRAPEZIO%';
UPDATE LabelledProducts	SET Collection = 'STA' WHERE ItemName LIKE '%STAR%';
UPDATE LabelledProducts	SET Collection = 'STR' WHERE ItemName LIKE '%STRAP%';
UPDATE LabelledProducts	SET Collection = 'WAL' WHERE ItemName LIKE '%WALLET%';
UPDATE LabelledProducts	SET Collection = 'ROY' WHERE ItemName LIKE '%ROY%';
UPDATE LabelledProducts	SET Collection = 'MIA' WHERE ItemName LIKE '%MIA%';
UPDATE LabelledProducts	SET Collection = 'LIV' WHERE ItemName LIKE '%LIV%';
UPDATE LabelledProducts	SET Collection = 'LEX' WHERE ItemName LIKE '%LEXIE%';
UPDATE LabelledProducts	SET Collection = 'LEA' WHERE ItemName LIKE '%LEA%';
UPDATE LabelledProducts	SET Collection = 'KEL' WHERE ItemName LIKE '%KELLY%';
UPDATE LabelledProducts	SET Collection = 'HAI' WHERE ItemName LIKE '%HAILEY%';
UPDATE LabelledProducts	SET Collection = 'GRA' WHERE ItemName LIKE '%GRACE%';
UPDATE LabelledProducts	SET Collection = 'ELE' WHERE ItemName LIKE '%ELEPHANTS%';
UPDATE LabelledProducts	SET Collection = 'FRI' WHERE ItemName LIKE '%FRINGY%';
UPDATE LabelledProducts	SET Collection = 'ENV' WHERE ItemName LIKE '%ENVELOPE%';
UPDATE LabelledProducts	SET Collection = 'CIN' WHERE ItemName LIKE '%CINDY%';
UPDATE LabelledProducts	SET Collection = 'BOB' WHERE ItemName LIKE '%BON BON%';
UPDATE LabelledProducts	SET Collection = 'OLI' WHERE ItemName LIKE '%OLIVIA%';
UPDATE LabelledProducts	SET Collection = 'AMO' WHERE ItemName LIKE '%AMOUR%';
UPDATE LabelledProducts	SET Collection = 'JAC' WHERE ItemName LIKE '%JACK%';
UPDATE LabelledProducts	SET Collection = 'KAI' WHERE ItemName LIKE '%KAIA%';		
UPDATE LabelledProducts	SET Collection = 'BUT' WHERE ItemName LIKE '%BUTTERFLY%';
UPDATE LabelledProducts	SET Collection = 'CAS' WHERE ItemName LIKE '%CASSIA%';
UPDATE LabelledProducts	SET Collection = 'PHO' WHERE ItemName LIKE '%PHONE%';
UPDATE LabelledProducts	SET Collection = 'BRE' WHERE ItemName LIKE '%BRENDA%';


		-- Set Item Code (weird item names like C-06, F-06, N-06, B-06, PCX-V10, TAG-V63, CHO-V64 etc etc) Collection codes:
SELECT * FROM PaidLabProducts WHERE OrderDate BETWEEN '01-01-2018' AND '01-01-2019'


UPDATE LabelledProducts	SET Collection = 'C-06' WHERE ItemName LIKE '%-06%';
	SELECT * FROM LabelledProducts WHERE Collection LIKE '%06%'

UPDATE LabelledProducts	SET Collection = 'C-V10' WHERE ItemName LIKE '%-V10%';
	SELECT * FROM LabelledProducts WHERE Collection LIKE '%V10%'

UPDATE LabelledProducts	SET Collection = 'C-V6x' WHERE ItemName LIKE '%-V6%';
	SELECT * FROM LabelledProducts WHERE Collection LIKE '%V6x%'



	-- Ensure no other '%01' or '%02' records:
		SELECT * FROM LabelledProducts WHERE ItemName LIKE '%FLASH 01'
		SELECT * FROM LabelledProducts WHERE ItemName LIKE '%FLASH 02'


UPDATE LabelledProducts	SET Collection = 'C-0x' WHERE ItemName LIKE '%01%' OR ItemName LIKE '%02';
	SELECT * FROM LabelledProducts WHERE ItemName LIKE '%02'
UPDATE LabelledProducts	SET Collection = 'PET' WHERE ItemName LIKE '%Peter Flash 02';
	SELECT * FROM LabelledProducts WHERE ItemName LIKE '%02'
UPDATE LabelledProducts	SET Collection = 'PHO' WHERE ItemName LIKE '%Phone Flash 02';
	SELECT * FROM LabelledProducts WHERE ItemName LIKE '%02'



		-- Check for specific entries:
SELECT * FROM LabelledProducts WHERE ItemName LIKE '%KAIA%'


	-- Set Shoe 'S' Names:
UPDATE LabelledProducts	SET Collection = 'ALI' WHERE ItemName LIKE '%ALISSO%' AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'ARD' WHERE ItemName LIKE '%ARDISIA%'AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'AST' WHERE ItemName LIKE '%ASTER%' AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'CAM' WHERE ItemName LIKE '%CAMELIA%'AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'FLO' WHERE ItemName LIKE '%FLOR%' AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'FRE' WHERE ItemName LIKE '%FRESIA%'AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'HOY' WHERE ItemName LIKE '%HOYA%' AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'IRI' WHERE ItemName LIKE '%IRIS%'AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'MAU' WHERE ItemName LIKE '%MAUVE%' AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'MAY' WHERE ItemName LIKE '%MAYLEA%'AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'NAR' WHERE ItemName LIKE '%NARCISO%' AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'PEO' WHERE ItemName LIKE '%PEONIA%'AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'AMA' WHERE ItemName LIKE '%AMANDA%' AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'GEM' WHERE ItemName LIKE '%GEMMA%'AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'JAN' WHERE ItemName LIKE '%JANE%' AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'JER' WHERE ItemName LIKE '%JERRY%'AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'KAL' WHERE ItemName LIKE '%KALIKA%' AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'KIR' WHERE ItemName LIKE '%KIRI%'AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'KAS' WHERE ItemName LIKE '%KASIA%' AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'LUC' WHERE ItemName LIKE '%LUCAS%'AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'LUN' WHERE ItemName LIKE '%LUNA%' AND Type = 'S';			-- Product exists as both Items AND Shoes.
UPDATE LabelledProducts	SET Collection = 'LOL' WHERE ItemName LIKE '%LOLA%'AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'NIK' WHERE ItemName LIKE '%NIKKI%' AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'TAY' WHERE ItemName LIKE '%TAYA%'AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'VIR' WHERE ItemName LIKE '%VIRGO%'AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'VEN' WHERE ItemName LIKE '%VENUS%' AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'ZAH' WHERE ItemName LIKE '%ZAHIR%'AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'ARH' WHERE ItemName LIKE '%ARDITH%'AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'FAR' WHERE ItemName LIKE '%FARLEY%' AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'THA' WHERE ItemName LIKE '%THALIA%'AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'TWI' WHERE ItemName LIKE '%TWIG%' AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'FAN' WHERE ItemName LIKE '%FANNY%' AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'KAI' WHERE ItemName LIKE '%KAIA%'AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'ISL' WHERE ItemName LIKE '%ISLA%' AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'HOL' WHERE ItemName LIKE '%HOLLIS%' AND Type = 'S';
UPDATE LabelledProducts	SET Collection = 'TAL' WHERE ItemName LIKE '%TALIA%' AND Type = 'S';

	-- Fix Collection labels for Item containing both GINNY and LUNA:
UPDATE LabelledProducts
	SET Collection = 'GIN'  WHERE ItemName = 'GINNY SOL E LUNA';

	-- REMOVE I-AST record (additional aster payment)
DELETE FROM LabelledProducts WHERE TYPE = 'I' AND Collection= 'AST'

	-- REMOVE Chargeback Reverse order record 
DELETE FROM LabelledProducts WHERE ItemName = 'Order 2285 - Chargeback Reverse'


	-- Possibly add a category for colour??


-- Check FINAL LabelledProducts table version:
SELECT * FROM LabelledProducts
	ORDER BY 1 DESC

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------







-- B) Now use LabelledProducts to create a sub-table of PAID orders only (including their NULL rows) - 'PaidLabProducts':

	-- New query selecting for PAID Products only:
SELECT OrderID, Name, Country, Email, OrderDate, Fulfilled, Quantity, ItemName, Type, Collection, Price, ItemSKU, Status 
	FROM LabelledProducts 
		WHERE Status LIKE '%paid%'
UNION
SELECT OrderID, Name, Country, Email, OrderDate, Fulfilled, Quantity, ItemName, Type, Collection, Price, ItemSKU, Status 
	FROM LabelledProducts 
		WHERE Status IS NULL AND OrderID NOT IN (SELECT OrderID FROM Orders 
															WHERE FinancialStatus NOT LIKE '%paid%')
			ORDER BY OrderID DESC


	-- Create new PAID Products table:
DROP TABLE IF EXISTS PaidLabProducts
GO
CREATE TABLE PaidLabProducts
(
	OrderID int,
	Name nvarchar(50),
	Country nvarchar(10),
	Email nvarchar(100),
	OrderDate date,
	Fulfilled nvarchar(50),
	Quantity int,
	ItemName nvarchar(100),
	Type nvarchar(5),
	Collection nvarchar(10),
	Price decimal(7,2),
	ItemSKU nvarchar(50),
	Status nvarchar(50)
)
	INSERT INTO PaidLabProducts
		SELECT OrderID, Name, Country, Email, OrderDate, Fulfilled, Quantity, ItemName, Type, Collection, Price, ItemSKU, Status 
			FROM LabelledProducts 
				WHERE Status LIKE '%paid%'
		UNION
		SELECT OrderID, Name, Country, Email, OrderDate, Fulfilled, Quantity, ItemName, Type, Collection, Price, ItemSKU, Status 
			FROM LabelledProducts 
				WHERE Status IS NULL AND OrderID NOT IN (SELECT OrderID FROM Orders 
																	WHERE FinancialStatus NOT LIKE '%paid%')

GO
SELECT * FROM PaidLabProducts 
	ORDER BY 1 DESC
					-- 1912 total rows in this table of PAID orders only.
						-- 275 rows removed - includes refunded, partially refunded & voided orders + their corresponding NULL rows.



	-- POPULATE date field of NULL rows with their order date.
SELECT * 
	FROM PaidLabProducts AS a
		JOIN PaidLabProducts AS b
		ON a.OrderID = b.OrderID
			AND a.[ItemName] <> b.[ItemName]


		-- Check JOIN visually:
SELECT a.OrderID, a.OrderDate, b.OrderID, b.OrderDate
	FROM PaidLabProducts a
		JOIN PaidLabProducts b	
		ON a.OrderID = b.OrderID
			AND a.[ItemName] <> b.[ItemName]
				WHERE a.OrderDate IS NULL AND b.OrderDate IS NOT NULL;


		-- Replace NULLs in a.OrderDate with with their dates from b.OrderDate:
SELECT a.OrderID, a.OrderDate, b.OrderID, b.OrderDate, ISNULL(a.OrderDate, b.OrderDate)
	FROM PaidLabProducts a
		JOIN PaidLabProducts b	
		ON a.OrderID = b.OrderID
			AND a.[ItemName] <> b.[ItemName]
				WHERE a.OrderDate IS NULL AND b.OrderDate IS NOT NULL;


		-- UPDATE PaidProducts table with order date in corresponding NULL rows:
UPDATE a
	SET OrderDate = ISNULL(a.OrderDate, b.OrderDate)
		FROM PaidLabProducts a
			JOIN PaidLabProducts b	
			ON a.OrderID = b.OrderID
				AND a.[ItemName] <> b.[ItemName]
					WHERE a.OrderDate IS NULL AND b.OrderDate IS NOT NULL;

					
		-- POPULATE Name field of NULL rows with customer Name.
			-- Repeating process above for updating PaidProducts table with customer names in corresponding NULL rows:
UPDATE a
	SET Name = ISNULL(a.Name, b.Name)		
		FROM PaidLabProducts a														
			JOIN PaidLabProducts b		
			ON a.OrderID = b.OrderID
				AND a.[ItemName] <> b.[ItemName]
					WHERE a.Name IS NULL AND b.Name IS NOT NULL;



		-- POPULATE Country field of NULL rows with customer Country.
			-- Repeating process above for updating PaidProducts table with customer countries in corresponding NULL rows:
UPDATE a
	SET Country = ISNULL(a.Country, b.Country)		
		FROM PaidLabProducts a														
			JOIN PaidLabProducts b		
			ON a.OrderID = b.OrderID
				AND a.[ItemName] <> b.[ItemName]
					WHERE a.Country IS NULL AND b.Country IS NOT NULL;

		-- Check FINAL Results table for analysis:
SELECT * FROM PaidLabProducts 
	ORDER BY 1 DESC
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
