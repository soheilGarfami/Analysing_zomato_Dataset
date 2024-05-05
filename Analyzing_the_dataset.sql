USE zomato;


--let's see how many restaurants we have in USA 
SELECT count(RestaurantID) Num_of_restaurants_in_us FROM Zomato_Dataset
WHERE Country_name = 'United States' ;

--now let's get specific into citys 
SELECT  City ,SUM(COUNT(Locality)) OVER(PARTITION BY City) AS Restaurants_in_City ,
Locality , COUNT(*) Restaurants_in_Locality
FROM Zomato_Dataset
WHERE Country_name = 'United States'
GROUP BY Country_name , City , Locality
ORDER BY City ;









CREATE OR ALTER VIEW Total_resturant_country AS (
SELECT Country_name , COUNT(RestaurantID) Rest_count	 
FROM Zomato_Dataset
GROUP BY Country_name
);
SELECT * FROM Total_resturant_country;



--Let's see each country contains what percentage of Zomato's restaurants.
 WITH CT1 AS (
SELECT DISTINCT Country_name  ,  COUNT(RestaurantID) OVER()   total_rest
FROM Zomato_Dataset 
)
--Now let's use these two view 
SELECT A.Country_name ,
ROUND(CAST(B.Rest_count AS float)/CAST(A.total_rest AS float)*100 , 2) AS Persentage 
FROM CT1 A JOIN Total_resturant_country B
ON A.Country_name = B.Country_name
ORDER BY 2 DESC ; 






--Let's see which countries have Online Service and what percentage of their resturants have Online service 

WITH CT2 AS(
SELECT Country_name  , count(*) AS ResturantWhithOnlineS FROM Zomato_Dataset
WHERE Has_Online_delivery = 'yes'
GROUP BY Country_name
)--total restaurants in a country
--Now let's use these views
SELECT A.Country_name ,
ROUND(CAST(B.ResturantWhithOnlineS AS float)/ CAST(A.Rest_count AS float) , 2 ) AS country_OnlineService_percentage
FROM Total_resturant_country AS a join CT2 AS b 
ON A.Country_name = B.Country_name ;
 




--Lest see in which locality of each city , the avrage price of restaurants are low (restuarants in which part of the city have better price)

-- avrage price in localities
with avrage_cost_local AS (
SELECT  City , Locality , AVG(Average_Cost_for_two) Av_cost
FROM  Zomato_Dataset
WHERE Currency = 'Dollar($)'
GROUP BY Locality , city 
),
--lowest avrage price in each city
min_avcost_city  AS (
SELECT city , MIN(Av_cost) AS  minn FROM avrage_cost_local
GROUP BY city  )
--the locality with lowest avrage price for eache city
SELECT a.city , a.locality AS lowPrice_locality , a.Av_cost
FROM avrage_cost_local AS a join min_avcost_city AS b ON a.city = b.city
WHERE a.Av_cost = b.minn;






SELECT Cuisines FROM Zomato_Dataset;

--Let's see which cuisines are the most popular(offered in most restuarants)

WITH soloCuisines AS ( --splitting Cuisisnes to different rows 
SELECT RestaurantID , value AS S_Cuisines  FROM Zomato_Dataset  CROSS APPLY   string_split(cuisines , '|') 
)
SELECT S_Cuisines , COUNT(RestaurantID) AS Num_of_Restuarants ,
ROUND(CAST(COUNT(RestaurantID) AS float)  / CAST((SELECT COUNT(*) FROM Zomato_Dataset) AS float)*100 , 2) AS Popularity  --percentage   
FROM soloCuisines
GROUP BY S_Cuisines
ORDER BY Popularity DESC ; 




--Lets find out how many and what persentage of restuarants in each category have onlie booking 
with T1 as(
SELECT COUNT(*) Restruarants  ,Rating_category
FROM Zomato_Dataset
GROUP BY Rating_category
),
T2 as (
SELECT COUNT(*) Restuarats_with_booking  ,Rating_category
FROM Zomato_Dataset
WHERE Has_Table_booking = 'yes'
GROUP BY Rating_category
)
SELECT T1.Rating_category , T1.Restruarants ,T2.Restuarats_with_booking,
ROUND(CAST(T2.Restuarats_with_booking AS float) / CAST(T1.Restruarants AS float) * 100 , 2 ) AS percentages
FROM T1 join T2 on T1.Rating_category = T2.Rating_category
ORDER BY percentages DESC










