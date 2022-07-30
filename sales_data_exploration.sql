--1--
--Inspecting Data--
SELECT * 
  FROM sales_data_sample 

--2--
--Checking Unique Values--
SELECT DISTINCT status FROM sales_data_sample ; --nice to plot--
SELECT DISTINCT month_id FROM sales_data_sample ;
SELECT DISTINCT year_id FROM sales_data_sample ;
SELECT DISTINCT  productline FROM sales_data_sample ; --nice to plot--
SELECT DISTINCT CITY FROM sales_data_sample ;
SELECT DISTINCT  state FROM sales_data_sample ; 
SELECT DISTINCT  country FROM sales_data_sample ; --nice to plot--
SELECT DISTINCT  TERRITORY FROM sales_data_sample ; --nice to plot--
SELECT DISTINCT  DEALSIZE FROM sales_data_sample ; --nice to plot--

--3--
--Sales Per product line--
SELECT PRODUCTLINE , ROUND(SUM(sales),2) Revenue
  FROM sales_data_sample 
 GROUP BY productline 
 ORDER BY 2 DESC 

--4--
--Sales Per year--
SELECT year_id , ROUND(SUM(sales),2) Revenue
  FROM sales_data_sample
 GROUP BY year_id 
 ORDER BY 2 DESC 

--Check every year operation months--
SELECT year_id ,COUNT(DISTINCT(month_id)) count_of_operation_months
  FROM sales_data_sample 
 GROUP BY year_id 

--5--
--Sales Per Deal size--
SELECT dealsize , ROUND(SUM(sales),2) Revenue
  FROM sales_data_sample
 GROUP BY dealsize 
 ORDER BY 2 DESC 

--6--
--Sales Per Country--
SELECT country , ROUND(SUM(sales),2) Revenue 
 FROM sales_data_sample
GROUP BY country 
ORDER BY 2 DESC

--7-- 
--What was the best month for sales in a specific year ? how much was earned that month ?--
SELECT year_id , month_id , SUM(sales) Revenue , COUNT(sales) Frequency 
  FROM sales_data_sample
 GROUP BY year_id , month_id 
 ORDER BY SUM(sales) DESC

--November seems to be the best month in sales Revenue , what product do they sell in november--
SELECT year_id , month_id , PRODUCTLINE , SUM(sales) Revenue , COUNT(sales) Frequency
  FROM sales_data_sample 
 WHERE month_id = 11 
 GROUP BY year_id , month_id , PRODUCTLINE
 ORDER BY 4 DESC

--8-- 
--Who is our best customer -- USING RFM Recency - Frequency - Monetary
--Recency (last order date) , frequency (count of total orders ),monetary (total spend)

WITH rfm_cte AS
(
SELECT customername  , DATEDIFF(DAY,MAX(orderdate),(SELECT MAX(orderdate) FROM sales_data_sample)) [recency /day] , 
       COUNT(sales) frequency , ROUND(SUM(sales),2) monetary
  FROM sales_data_sample 
 GROUP BY CUSTOMERNAME
)
,cte_2 AS
(
SELECT * , 
       NTILE(4) OVER (ORDER BY [recency /day] DESC) rfm_recency ,
	   NTILE(4) OVER (ORDER BY frequency ASC) rfm_frequency,
	   NTILE(4) OVER (ORDER BY monetary ASC) rfm_monetary
  FROM rfm_cte 
)
,cte_3 AS
(
SELECT * , CAST(rfm_recency AS VARCHAR) + CAST(rfm_frequency AS VARCHAR) + CAST(rfm_monetary AS VARCHAR) rfm ,
       rfm_recency + rfm_frequency + rfm_monetary AS rfm_score
  FROM cte_2 
)

SELECT customername , [recency /day] , frequency , monetary , rfm , rfm_score , 
       CASE WHEN rfm_score >= 10 THEN 'loyal_customer'
			WHEN rfm_score >= 5 THEN 'good_customer'
			WHEN rfm_score <= 4 THEN 'lost_customer' END AS customer_classification
  FROM cte_3 
 ORDER BY rfm_score DESC ,[recency /day] ASC,frequency DESC ,monetary DESC

 --9--
 --What Product Codes Sold Together?--
 
 SELECT a.productcode product_1, b.productcode product_2 , COUNT(*) count_of_product_1_2 
   FROM sales_data_sample  a
   JOIN sales_data_sample b
     ON a.ORDERNUMBER = b.ORDERNUMBER AND a.PRODUCTCODE != b.PRODUCTCODE
  GROUP BY  a.PRODUCTCODE , b.PRODUCTCODE
  ORDER BY 3 DESC