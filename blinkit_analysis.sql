CREATE TABLE Blinkit_Sales (
		item_fat_content				VARCHAR(20),
		item_identifier					VARCHAR(20),
		item_type						VARCHAR(50),
		outlet_establishment_year		INT,
		outlet_identifier				VARCHAR(20),
		outlet_location_type			VARCHAR(20),
		outlet_size						VARCHAR(20),
		outlet_type						VARCHAR(50),
		item_visibility					FLOAT,
		item_weight						FLOAT,
		sales							FLOAT,
		rating							FLOAT,
		outlet_age						INT
);

-- LOading Data into table

COPY Blinkit_Sales
FROM 'E:\Portfolio Project\Claude Portfolio Project\Blinkit Grocery dataset\BlinkIT-Grocery-Data(under working).csv'
DELIMITER ','
CSV HEADER;

-- TO check whether DATA load successful or not 

SELECT COUNT (*) FROM Blinkit_Sales;

SELECT * FROM Blinkit_Sales LIMIT 5;

-- Cleaning And Processing Data For Analysis

-- Checking NULL in all columns

SELECT 
		COUNT (*) - COUNT(item_fat_content) 			AS Null_item_fat_content,
		COUNT (*) - COUNT(item_identifier) 				AS Null_item_identifier,
		COUNT (*) - COUNT(item_type) 					AS Null_item_type,
		COUNT (*) - COUNT(outlet_establishment_year)	AS Null_outlet_establishment_year,
		COUNT (*) - COUNT(outlet_identifier) 			AS Null_outlet_identifier,
		COUNT (*) - COUNT(outlet_location_type) 		AS Null_outlet_location_type,
		COUNT (*) - COUNT(outlet_size) 					AS Null_outlet_size,
		COUNT (*) - COUNT(item_type) 					AS NUll_item_type,
		COUNT (*) - COUNT(item_visibility) 				AS Null_item_visibility,
		COUNT (*) - COUNT(item_weight) 					AS Null_item_weight,
		COUNT (*) - COUNT(sales) 						AS Null_sales,
		COUNT (*) - COUNT(rating) 						AS Null_rating,
		COUNT (*) - COUNT(outlet_age) 					AS Null_outlet_age
FROM Blinkit_Sales;

-- Checking item_fat_content Distinct values

SELECT item_fat_content,COUNT(*) AS count
FROM Blinkit_Sales
GROUP BY item_fat_content
ORDER BY count DESC;

-- Count of zero visibility

SELECT COUNT(*) AS zero_visibility_count
FROM Blinkit_Sales
WHERE item_visibility = 0;

-- identifying Sales and Rating anomalies

SELECT
		MIN(sales)	AS min_sales,
		MAX(Sales)	AS max_sales,
		AVG(Sales)	AS avg_sales,
		MIN(rating)	AS min_rating,
		MAX(rating)	AS max_rating,
		AVG(rating) AS avg_rating
FROM Blinkit_Sales;

-- replacing null values in item_weight with avg weight of that perticular item category

UPDATE Blinkit_Sales
SET item_weight = subquery.avg_weight
FROM
	(SELECT item_type,ROUND(AVG(item_weight):: NUMERIC,2) AS avg_weight
	FROM Blinkit_sales
	WHERE item_weight IS NOT NULL
	GROUP BY item_type) AS subquery
WHERE Blinkit_Sales.item_type = subquery.item_type
AND Blinkit_Sales.item_weight IS NULL;

-- to chechk whether null values got replace or not

SELECT COUNT(*) FROM Blinkit_Sales
WHERE item_weight IS NULL;

-- fixing zero visibility

UPDATE Blinkit_Sales
SET item_visibility = subquery.avg_visibility
FROM (
		SELECT item_type,ROUND(AVG(item_visibility):: NUMERIC,4) AS avg_visibility
		FROM Blinkit_Sales
		WHERE item_visibility > 0
		GROUP BY item_type) AS subquery
WHERE Blinkit_Sales.item_type = subquery.item_type
AND Blinkit_Sales.item_visibility = 0;

-- checking count of zero visibility

SELECT COUNT(*) FROM Blinkit_Sales
WHERE item_visibility = 0;

-- Now Data Analysis

-- (1) total Sales by item type

SELECT
		item_type,
		ROUND(SUM(sales) :: NUMERIC,2) AS total_sales,
		ROUND(AVG(sales) :: NUMERIC,2) AS avg_sales,
		COUNT(*) AS total_items
FROM Blinkit_Sales
GROUP BY item_type
ORDER BY total_sales DESC;

--(2) Sales By Outlet Location

SELECT
		outlet_location_type,
		ROUND(SUM(sales):: NUMERIC,2) AS total_sales,
		ROUND(AVG(sales):: NUMERIC,2) AS avg_sales,
		COUNT(DISTINCT outlet_identifier) AS total_outlets
FROM Blinkit_Sales
GROUP BY outlet_location_type
ORDER BY total_sales DESC;

--(3) Sales By Outlet type

SELECT
		outlet_type,
		ROUND(SUM(sales):: NUMERIC,2) AS total_sales,
		ROUND(AVG(sales):: NUMERIC,2) AS avg_sales,
		COUNT(DISTINCT outlet_identifier) AS total_outlets,
		ROUND(AVG(rating):: NUMERIC,2) AS avg_rating
FROM Blinkit_Sales
GROUP BY outlet_type
ORDER BY total_sales DESC;


-- (4) Impact of Outlet Age on Sales

SELECT
		outlet_age,
		ROUND(SUM(sales):: NUMERIC,2) AS total_sales,
		ROUND(AVG(sales):: NUMERIC,2) AS avg_sales,
		COUNT(DISTINCT outlet_identifier) AS total_outlets,
		ROUND(AVG(rating):: NUMERIC,2) AS avg_rating
FROM Blinkit_Sales
GROUP BY outlet_age
ORDER BY outlet_age DESC;

-- (5) Fat Content Preference By tier

SELECT
		outlet_location_type,
		item_fat_content,
		COUNT(*) AS total_items,
		ROUND(SUM(sales):: NUMERIC,2) AS total_sales,
		ROUND(AVG(sales):: NUMERIC,2) AS avg_sales
FROM Blinkit_Sales
GROUP BY outlet_location_type,item_fat_content
ORDER BY outlet_location_type,total_sales DESC;

-- (6) Item visibility Vs Sales Correlation

SELECT
		CASE
			WHEN item_visibility < 0.05 THEN 'Low Visibility'
			WHEN item_visibility BETWEEN 0.05 AND 0.15 THEN 'Medium Visibility'
			ELSE 'High Visibility'
		END AS visibility_bucket,
		COUNT(*) AS total_items,
		ROUND(AVG(sales):: NUMERIC,2) AS avg_sales,
		ROUND(AVG(rating):: NUMERIC,2) AS avg_rating
FROM Blinkit_Sales
GROUP BY visibility_bucket
ORDER BY avg_sales DESC;

-- (7) Top Performing Outlets Overall

SELECT
		outlet_identifier,
		outlet_type,
		outlet_location_type,
		outlet_size,
		outlet_age,
		ROUND(SUM(sales):: NUMERIC,2) AS total_sales,
		ROUND(AVG(sales):: NUMERIC,2) AS avg_sales,
		ROUND(AVG(rating):: NUMERIC,2) AS avg_rating,
		COUNT(*) AS total_items
FROM Blinkit_Sales
GROUP BY outlet_identifier,outlet_type,outlet_location_type,outlet_size,outlet_age
ORDER BY total_sales DESC;


COPY Blinkit_sales
TO 'E:\Portfolio Project\Claude Portfolio Project\Blinkit Grocery dataset\BlinkIT-Grocery-Data(under working).csv'
DELIMITER ','
CSV HEADER;








