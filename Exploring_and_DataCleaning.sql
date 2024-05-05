USE zomato;

SELECT * FROM dbo.Zomato_Dataset;

SELECT DISTINCT(TABLE_CATALOG), TABLE_NAME FROM INFORMATION_SCHEMA.COLUMNS;



SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Zomato_Dataset';






SELECT RestaurantID, COUNT(RestaurantID) AS counting FROM Zomato_Dataset 
GROUP BY RestaurantID
HAVING COUNT(RestaurantID) != 1;


SELECT CountryCode, City FROM Zomato_Dataset
GROUP BY CountryCode, City
ORDER BY CountryCode ASC;


SELECT * FROM [Country-Code];


SELECT A.RestaurantID, A.City, B.Country  
FROM Zomato_Dataset AS A JOIN [Country-Code] AS B ON A.CountryCode = B.Country_Code;


ALTER TABLE dbo.Zomato_Dataset ADD Country_name VARCHAR(50);


UPDATE Zomato_Dataset SET Country_name = B.Country
FROM Zomato_Dataset AS A JOIN [Country-Code] AS B 
ON A.CountryCode = B.Country_Code;


ALTER TABLE Zomato_dataset DROP COLUMN CountryCode


SELECT DISTINCT City FROM Zomato_Dataset WHERE City LIKE '%?%';


SELECT REPLACE(City, '?', 'i')
FROM Zomato_Dataset WHERE City LIKE '%?%';


UPDATE Zomato_Dataset SET City = REPLACE(City, '?', 'i');


UPDATE Zomato_Dataset SET City = REPLACE(City, 'istanbul', 'Istanbul');


SELECT Country_name, COUNT(DISTINCT City) AS numOfCitys FROM Zomato_Dataset
GROUP BY Country_name
ORDER BY numOfCitys DESC;


SELECT City, COUNT(RestaurantID) AS numOfResturants FROM Zomato_Dataset
GROUP BY City
ORDER BY numOfResturants DESC;


SELECT  Country_name,
COUNT(City) OVER(PARTITION BY Country_name) AS NomOfCity,
City, COUNT(RestaurantID) AS numOfResturantInCity,
SUM(COUNT(RestaurantID)) OVER(PARTITION BY Country_name) AS resturuntInCountry
FROM Zomato_Dataset 
GROUP BY Country_name, city;


SELECT city, locality, COUNT(locality) AS ResturantInLocality,
SUM(COUNT(locality)) OVER (PARTITION BY City) AS ResturantInCity FROM Zomato_Dataset
WHERE Country_name = 'India'
GROUP BY locality, city 
ORDER BY ResturantInCity DESC, ResturantInLocality DESC;


ALTER TABLE Zomato_Dataset DROP COLUMN [Address];
ALTER TABLE Zomato_Dataset DROP COLUMN [LocalityVerbose];


SELECT Cuisines FROM Zomato_Dataset WHERE Cuisines IS NULL OR Cuisines = ' ';


SELECT Cuisines, COUNT(Cuisines) FROM Zomato_Dataset 
GROUP BY Cuisines
ORDER BY COUNT(Cuisines) DESC;


SELECT DISTINCT Currency FROM Zomato_Dataset;


SELECT DISTINCT Has_Online_delivery FROM Zomato_Dataset;
SELECT DISTINCT Has_Table_booking FROM Zomato_Dataset;
SELECT DISTINCT Is_delivering_now FROM Zomato_Dataset;
SELECT DISTINCT Switch_to_order_menu FROM Zomato_Dataset;


ALTER TABLE Zomato_Dataset DROP COLUMN Switch_to_order_menu;


SELECT DISTINCT Votes FROM Zomato_Dataset;


ALTER TABLE Zomato_Dataset ALTER COLUMN Votes INT;


SELECT DATA_TYPE FROM INFORMATION_SCHEMA.columns WHERE COLUMN_NAME = 'Rating';


ALTER TABLE Zomato_Dataset ALTER COLUMN Average_Cost_for_two FLOAT;


SELECT Currency, MIN(Average_Cost_for_two) AS minCost, AVG(CAST(Average_Cost_for_two AS INT)) AS avrageCost, MAX(Average_Cost_for_two) AS maxCost
FROM Zomato_Dataset
GROUP BY Currency;


ALTER TABLE Zomato_Dataset ADD Rating_category VARCHAR(30);


UPDATE Zomato_Dataset SET Rating_category = (CASE 
    WHEN Rating < 2.5 THEN 'not_good'
    WHEN Rating >= 2.5 AND Rating < 3.5 THEN 'mediocre'
    WHEN Rating >= 3.5 AND Rating < 4.5 THEN 'good'
    WHEN Rating >= 4.5 THEN 'great'
END);



SELECT Rating_category, COUNT(*) 
FROM Zomato_Dataset 
GROUP BY Rating_category;



SELECT MIN(Average_Cost_for_two) FROM Zomato_Dataset;
--as you can see some where in dataset the avrage price for two is 0 and it's not logical

--let's see what is the minimum price except zero for each ccurency 

create or alter view Minimum_price  as 
SELECT MIN(Average_Cost_for_two) minimum_price , Currency  
FROM Zomato_Dataset
WHERE Average_Cost_for_two > 0 
GROUP BY Currency
--now let's update the Price 
UPDATE Zomato_Dataset
SET Average_Cost_for_two = (
    SELECT Minimum_price
    FROM Minimum_price 
    WHERE  Zomato_Dataset.Currency = Minimum_price.Currency
)
WHERE Average_Cost_for_two = 0;


