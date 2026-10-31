create database Zomato_Project;
use Zomato_Project;

select * from `zomato_cleaned dataset`;

/* ===================================
	  Build a country Map Table
====================================== */ 
CREATE TABLE Country_Table(
    Country_ID INT,
    Country CHAR(100) NOT NULL );

INSERT INTO Country_table (Country_ID, Country)
VALUES (1, "India"),
	   (14, "Australia"),
       (30, "Brazil"),
       (37, "Canada"),
       (94, "Indonesia"),
       (148, "New Zealand"),
       (162, "Phillipines"),
       (166, "Qatar"),
       (184, "Singapore"),
       (189, "South Africa"),
       (191, "Sri Lanka"),
       (208, "Turkey"),
       (214, "UAE"),
       (215, "United Kingdom"),
       (216, "United States");
       
Select * from country_table;       

/* ===================================
# Create the Calendar Dimension Table
====================================== */ 
CREATE TABLE Calender AS
SELECT DISTINCT
    FullDate,
    YEAR(FullDate) AS `Year`,
    MONTH(FullDate) AS MonthNo,
    MONTHNAME(FullDate) AS MonthName,
    CONCAT('Q', QUARTER(FullDate)) AS `Quarter`,
    DATE_FORMAT(FullDate, '%Y-%b') AS YearMonth,
    DAYOFWEEK(FullDate) AS Weekday_Number,
    DAYNAME(FullDate) AS Weekday_Name,
    CONCAT(
        'FM',
        CASE
            WHEN MONTH(FullDate) >= 4
                THEN MONTH(FullDate) - 3
            ELSE MONTH(FullDate) + 9
        END
    ) AS Financial_Month,

    CASE
        WHEN MONTH(FullDate) BETWEEN 4 AND 6 THEN 'FQ-1'
        WHEN MONTH(FullDate) BETWEEN 7 AND 9 THEN 'FQ-2'
        WHEN MONTH(FullDate) BETWEEN 10 AND 12 THEN 'FQ-3'
        ELSE 'FQ-4'
    END AS Financial_Quarter
FROM (
    SELECT STR_TO_DATE(Datekey_Opening, '%d-%m-%Y') AS FullDate
    FROM `zomato_cleaned dataset`
) AS Dates
WHERE FullDate IS NOT NULL;

select  * from calender;

/* ===================================
	  Build a Currency table
====================================== */ 
CREATE TABLE Currency AS
SELECT DISTINCT
    z.CountryCode,
    c.Country AS CountryName,
    z.Currency
FROM `zomato_cleaned dataset` AS z
LEFT JOIN country_table AS c
    ON z.CountryCode = c.Country_ID
ORDER BY z.CountryCode ASC;

select * from currency;

/* ===================================
	  Find the Numbers of Resturants 
      based on City and Country.
====================================== */    
SELECT 
    c.Country,
    z.City,
    COUNT(DISTINCT z.ï»¿RestaurantID) AS No_of_Restaurants
FROM `zomato_cleaned dataset` z
LEFT JOIN country_table c 
    ON z.CountryCode = c.Country_ID
GROUP BY 
    c.Country, 
    z.City
ORDER BY 
    No_of_Restaurants DESC
LIMIT 0, 1000;

/* ===================================
	  Numbers of Resturants opening 
	 based on Year , Quarter , Month.
====================================== */
SELECT
    Year,
    Quarter,
    MonthName,
    COUNT(*) AS NumberOfRestaurants
FROM Calender
GROUP BY Year, Quarter, MonthNo, MonthName
ORDER BY Year, Quarter, MonthNo;

/* ===================================
	  Count of Resturants based on 
			Average Ratings.
====================================== */ 
SELECT
	Rating,
    COUNT(DISTINCT ï»¿RestaurantID) AS No_of_Restuarants
FROM `zomato_cleaned dataset`
GROUP BY Rating
ORDER BY Rating ASC;

/* ===============================================================
	  Create buckets based on Average Price of reasonable size 
      and find out how many resturants falls in each buckets.
================================================================ */ 
SELECT 
    CASE 
        WHEN Average_Cost_for_two <= 500 THEN '0 - 500'
        WHEN Average_Cost_for_two <= 1000 THEN '501 - 1000'
        WHEN Average_Cost_for_two <= 2000 THEN '1001 - 2000'
        WHEN Average_Cost_for_two <= 3000 THEN '2001 - 3000'
        ELSE 'Above 3000'
    END AS Price_Bucket,
    COUNT(DISTINCT ï»¿RestaurantID) AS No_of_Restaurants
FROM `zomato_cleaned dataset`
GROUP BY 
    CASE 
        WHEN Average_Cost_for_two <= 500 THEN '0 - 500'
        WHEN Average_Cost_for_two <= 1000 THEN '501 - 1000'
        WHEN Average_Cost_for_two <= 2000 THEN '1001 - 2000'
        WHEN Average_Cost_for_two <= 3000 THEN '2001 - 3000'
        ELSE 'Above 3000'
    END
ORDER BY MIN(Average_Cost_for_two);

/* ===============================================================
	  Percentage of Resturants based on "Has_Table_booking".
================================================================ */ 
SELECT
    Has_Table_booking,
    COUNT(*) AS NumberOfRestaurants,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM `zomato_cleaned dataset`), 2) AS Percentage
FROM `zomato_cleaned dataset`
GROUP BY Has_Table_booking;

/* ===============================================================
	  Percentage of Resturants based on "Has_Online_delivery".
================================================================ */ 
SELECT
    Has_Online_delivery,
    COUNT(*) AS NumberOfRestaurants,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM `zomato_cleaned dataset`), 2) AS Percentage
FROM `zomato_cleaned dataset`
GROUP BY Has_Online_delivery;