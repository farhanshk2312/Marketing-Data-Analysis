use PortfolioProject_MarketingAnalytics;

-- SQL statement to join dim_customers with dim_geography to enrich customer data with geographic information

SELECT 
    c.CustomerID,  
    c.CustomerName,  
    c.Email,  
    c.Gender,  
    c.Age,  
    g.Country, 
    g.City  -- 
FROM 
    dbo.customers as c  
LEFT JOIN
-- RIGHT JOIN
-- INNER JOIN
-- FULL OUTER JOIN
    dbo.geography g  
ON 
    c.GeographyID = g.GeographyID;  

----------------------------------------------------------------------------------------------------------
-- SQL Query to categorize products based on their price

SELECT 
    ProductID,  
    ProductName,  
    Price,  
	-- Category, 

    CASE 
        WHEN Price < 50 THEN 'Low'  
        WHEN Price BETWEEN 50 AND 200 THEN 'Medium'  
        ELSE 'High'  
    END AS PriceCategory  

FROM 
    dbo.products;  


---------------------------------------------------------------------------------------------------------
-- Query to clean and normalize the engagement_data table

SELECT 
    EngagementID,  
    ContentID,  
	CampaignID,  
    ProductID,  

    UPPER(REPLACE(ContentType, 'Socialmedia', 'Social Media')) AS ContentType,  
    LEFT(ViewsClicksCombined, CHARINDEX('-', ViewsClicksCombined) - 1) AS Views,  
    RIGHT(ViewsClicksCombined, LEN(ViewsClicksCombined) - CHARINDEX('-', ViewsClicksCombined)) AS Clicks,  
    Likes,  
   
    FORMAT(CONVERT(DATE, EngagementDate), 'dd.MM.yyyy') AS EngagementDate 
FROM 
    dbo.engagement_data  
WHERE 
    ContentType != 'Newsletter';  
---------------------------------------------------------------------------------------------------------

-- Common Table Expression (CTE) to identify and tag duplicate records

WITH DuplicateRecords AS (
    Select 
           JourneyID,
           CustomerID,
           ProductID,
           VisitDate,
           Stage,
           Action,
           Duration,

           ROW_NUMBER() OVER (

           Partition By CustomerID, ProductID, VisitDate, Stage, Action
           Order By JourneyID
           ) As row_num

    From 
      dbo.customer_journey

)

-- Select all records from the CTE where row_num > 1, which indicates duplicate entries

SELECT *
FROM DuplicateRecords
 --where row_num > 1
ORDER BY JourneyID

   SELECT 
    JourneyID, 
    CustomerID,  
    ProductID,  
    Stage,  
    Action, 
    COALESCE(Duration, avg_duration) AS Duration  
FROM 
    (
            SELECT 
            JourneyID,  
            CustomerID,  
            ProductID,  
            VisitDate,  
            UPPER(Stage) AS Stage,  
            Action,  
            Duration,  
            AVG(Duration) OVER (PARTITION BY VisitDate) AS avg_duration,  
            ROW_NUMBER() OVER (
                PARTITION BY CustomerID, ProductID, VisitDate, UPPER(Stage), Action  
                ORDER BY JourneyID  
            ) AS row_num  
        FROM 
            dbo.customer_journey  
    ) AS subquery  
WHERE 
    row_num = 1; 

--------------------------------------------------------------------------------------------------------
-- (STAGE DISTRIBUTION) To count how many records exist per Stage in your CustomerJourney table:

SELECT 
    Stage,
    COUNT(*) AS StageCount
FROM dbo.customer_journey
GROUP BY Stage
ORDER BY StageCount DESC;

----------------------------------------------------------------------------------------------------------
-- (STAGE DISTRIBUTION) See funnel drop-off rates between stages.
-- A funnel drop-off means checking how many customers made it to each stage and then calculating the percentage that progressed further.

WITH StageCounts AS (
    SELECT 
        UPPER(Stage) AS Stage,
        COUNT(CustomerID) AS Customers
    FROM dbo.customer_journey
    GROUP BY UPPER(Stage)
)
SELECT 
    Stage,
    Customers,
    LAG(Customers) OVER (ORDER BY 
        CASE Stage 
            WHEN 'Homepage' THEN 1
            WHEN 'ProductPage' THEN 2
            WHEN 'Checkout' THEN 3
            ELSE 4 END
    ) AS PreviousStageCustomers,
    CASE 
        WHEN LAG(Customers) OVER (ORDER BY 
                CASE Stage 
                    WHEN 'Homepage' THEN 1
                    WHEN 'ProductPage' THEN 2
                    WHEN 'Checkout' THEN 3
                    ELSE 4 END
            ) IS NULL THEN NULL
        ELSE 
            ROUND(
                100.0 * (Customers * 1.0 / 
                LAG(Customers) OVER (ORDER BY 
                    CASE Stage 
                        WHEN 'Homepage' THEN 1
                        WHEN 'ProductPage' THEN 2
                        WHEN 'Checkout' THEN 3
                        ELSE 4 END)
                ), 2
            )
    END AS RetentionPercent
FROM StageCounts
ORDER BY 
    CASE Stage 
        WHEN 'Homepage' THEN 1
        WHEN 'ProductPage' THEN 2
        WHEN 'Checkout' THEN 3
        ELSE 4 END;

-------------------------------------------------------------------------------------------------------

-- (ACTION FREQUENCY) Most common actions (View, Click, Purchase).
-- This calculates the average time customers spend on each action (View, Click, Purchase, etc.).

SELECT 
    Action, 
    COUNT(*) AS ActionCount
FROM dbo.customer_journey
GROUP BY Action
ORDER BY ActionCount DESC;

------------------------------------------------------------------------------------------------------

-- (VISIT TIMELINES) Daily/weekly/monthly number of visits.
-- These queries give daily, weekly, and monthly visit counts.


-- Daily visits
SELECT 
    CAST(VisitDate AS DATE) AS VisitDay,
    COUNT(*) AS TotalVisits
FROM dbo.customer_journey
GROUP BY CAST(VisitDate AS DATE)
ORDER BY VisitDay;

-- Weekly visits
SELECT 
    DATEPART(YEAR, VisitDate) AS YearNum,
    DATEPART(WEEK, VisitDate) AS WeekNum,
    COUNT(*) AS TotalVisits
FROM dbo.customer_journey
GROUP BY DATEPART(YEAR, VisitDate), DATEPART(WEEK, VisitDate)
ORDER BY YearNum, WeekNum;

-- Monthly visits
SELECT 
    DATEPART(YEAR, VisitDate) AS YearNum,
    DATEPART(MONTH, VisitDate) AS MonthNum,
    COUNT(*) AS TotalVisits
FROM dbo.customer_journey
GROUP BY DATEPART(YEAR, VisitDate), DATEPART(MONTH, VisitDate)
ORDER BY YearNum, MonthNum;

------------------------------------------------------------------------------------------------------

-- Calculate days between first visit and purchase per customer/product
-- This query computes the time-to-purchase in days for each customer-product pair by comparing the first visit date and the first purchase date.

WITH FirstVisit AS (
    SELECT 
        CustomerID,
        ProductID,
        MIN(VisitDate) AS FirstVisitDate
    FROM dbo.customer_journey
    GROUP BY CustomerID, ProductID
),
FirstPurchase AS (
    SELECT 
        CustomerID,
        ProductID,
        MIN(VisitDate) AS PurchaseDate
    FROM dbo.customer_journey
    WHERE Action = 'Purchase' 
    GROUP BY CustomerID, ProductID
)
SELECT 
    fv.CustomerID,
    fv.ProductID,
    fv.FirstVisitDate,
    fp.PurchaseDate,
    DATEDIFF(DAY, fv.FirstVisitDate, fp.PurchaseDate) AS DaysToPurchase
FROM FirstVisit fv
JOIN FirstPurchase fp
    ON fv.CustomerID = fp.CustomerID
   AND fv.ProductID = fp.ProductID
ORDER BY DaysToPurchase;

------------------------------------------------------------------------------------------------------

-- (Customer engagement)  Find average duration spent by each customer name

SELECT 
    j.CustomerID,
    c.CustomerName,
    ROUND(AVG(j.Duration), 2) AS AvgDuration
FROM dbo.customer_journey as j
JOIN dbo.customers c
    ON j.CustomerID = c.CustomerID
WHERE j.Duration IS NOT NULL
GROUP BY j.CustomerID, c.CustomerName
ORDER BY AvgDuration DESC;

---------------------------------------------------------------------------------------------------------

-- (Customer engagement) Find repeat visits per customer

SELECT 
    CustomerID,
    COUNT(*) AS TotalVisits
FROM dbo.customer_journey
GROUP BY CustomerID
HAVING COUNT(*) > 1
ORDER BY TotalVisits DESC;


-- Join with the Customer table if you want customer names:

SELECT 
    j.CustomerID,
    c.CustomerName,
    COUNT(*) AS TotalVisits
FROM dbo.customer_journey as j
JOIN dbo.customers as c
    ON j.CustomerID = c.CustomerID
GROUP BY j.CustomerID, c.CustomerName
HAVING COUNT(*) > 1
ORDER BY TotalVisits DESC;

----------------------------------------------------------------------------------------------------
-- (Rating Distribution) To create a histogram of ratings (count of each rating from 1 to 5) from Customer Reviews table:

EXEC sp_help 'dbo.customer_reviews';

SELECT 
    Rating,
    COUNT(*) AS RatingCount,
    CONCAT(FORMAT(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 'N2'), '%') AS RatingPercent
FROM dbo.customer_reviews
GROUP BY Rating
ORDER BY Rating;

-------------------------------------------------------------------------------------------------------

-- Trends in rating over time (improving or declining).

SELECT 
    FORMAT(ReviewDate, 'MMMM yyyy') AS MonthYear,
    ROUND(AVG(CAST(Rating AS FLOAT)), 2) AS AvgRating,
    COUNT(*) AS ReviewCount
FROM dbo.customer_reviews
GROUP BY FORMAT(ReviewDate, 'MMMM yyyy')
ORDER BY MIN(ReviewDate);

--------------------------------------------------------------------------------------------------------

-- Compare time spent in journey (duration) vs final rating.

SELECT 
    j.CustomerID,
    c.CustomerName,
    j.ProductID,
    SUM(j.Duration) AS TotalDuration,
    r.Rating AS FinalRating
FROM dbo.customer_journey j
JOIN dbo.customers c
    ON j.CustomerID = c.CustomerID
JOIN dbo.customer_reviews r
    ON j.CustomerID = r.CustomerID
   AND j.ProductID = r.ProductID
WHERE j.Duration IS NOT NULL
GROUP BY 
    j.CustomerID,
    c.CustomerName,
    j.ProductID,
    r.Rating
ORDER BY TotalDuration DESC;


--------------------------------------------------------------------------------------------------------
-- (Product Level Insights) - Funnel conversion rate (how many reached purchase).

WITH TotalCustomers AS (
    SELECT COUNT(CustomerID) AS Total
    FROM dbo.customer_journey
),
PurchasedCustomers AS (
    SELECT COUNT(CustomerID) AS Purchased
    FROM dbo.customer_journey
    WHERE UPPER(Stage) = 'Checkout'
)
SELECT 
    p.Purchased,
    t.Total,
    CONCAT(FORMAT(100.0 * p.Purchased / t.Total, 'N2'), '%') AS ConversionRatePercent
FROM PurchasedCustomers p
CROSS JOIN TotalCustomers t;

------------------------------------------------------------------------------------------------------