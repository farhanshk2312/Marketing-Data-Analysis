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


-- To count how many records exist per Stage in your CustomerJourney table:

--SELECT 
--    Stage,
--    COUNT(*) AS StageCount
--FROM dbo.customer_journey
--GROUP BY Stage
--ORDER BY StageCount DESC;




