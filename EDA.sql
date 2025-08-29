use PortfolioProject_MarketingAnalytics;

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

--SELECT 
--    Stage,
--    COUNT(*) AS StageCount
--FROM dbo.customer_journey
--GROUP BY Stage
--ORDER BY StageCount DESC;


----------------------------------------------------------------------------------------------------------
-- (STAGE DISTRIBUTION) See funnel drop-off rates between stages.
-- A funnel drop-off means checking how many customers made it to each stage and then calculating the percentage that progressed further.

--WITH StageCounts AS (
--    SELECT 
--        UPPER(Stage) AS Stage,
--        COUNT(CustomerID) AS Customers
--    FROM dbo.customer_journey
--    GROUP BY UPPER(Stage)
--)
--SELECT 
--    Stage,
--    Customers,
--    LAG(Customers) OVER (ORDER BY 
--        CASE Stage 
--            WHEN 'Homepage' THEN 1
--            WHEN 'ProductPage' THEN 2
--            WHEN 'Checkout' THEN 3
--            ELSE 4 END
--    ) AS PreviousStageCustomers,
--    CASE 
--        WHEN LAG(Customers) OVER (ORDER BY 
--                CASE Stage 
--                    WHEN 'Homepage' THEN 1
--                    WHEN 'ProductPage' THEN 2
--                    WHEN 'Checkout' THEN 3
--                    ELSE 4 END
--            ) IS NULL THEN NULL
--        ELSE 
--            ROUND(
--                100.0 * (Customers * 1.0 / 
--                LAG(Customers) OVER (ORDER BY 
--                    CASE Stage 
--                        WHEN 'Homepage' THEN 1
--                        WHEN 'ProductPage' THEN 2
--                        WHEN 'Checkout' THEN 3
--                        ELSE 4 END)
--                ), 2
--            )
--    END AS RetentionPercent
--FROM StageCounts
--ORDER BY 
--    CASE Stage 
--        WHEN 'Homepage' THEN 1
--        WHEN 'ProductPage' THEN 2
--        WHEN 'Checkout' THEN 3
--        ELSE 4 END;

-------------------------------------------------------------------------------------------------------

-- (ACTION FREQUENCY) Most common actions (View, Click, Purchase).

SELECT 
    Action, 
    COUNT(*) AS ActionCount
FROM dbo.customer_journey
GROUP BY Action
ORDER BY ActionCount DESC;

------------------------------------------------------------------------------------------------------

-- (VISIT TIMELINES) Daily/weekly/monthly number of visits.


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
