# Marketing Analytics with SQL

This project transforms raw marketing, customer, product and journey data into actionable insights for improving acquisition, engagement and conversion. 

Using SQL-based ETL, cleaning, window functions and aggregations we: 

      (1) Enrich customer records with geography, 
      (2) Categorize products by price tier, 
      (3) Normalize engagement records, 
      (4) Detect & dedupe customer journey events, and 
      (5) Produce conversion, retention, engagement and rating trend measures. 

            
# Business objectives

      (1) Understand user behavior across the funnel (Homepage → ProductPage → Checkout) and quantify drop-off.
         
      (2) Measure time-to-purchase and identify slow points in the customer journey.
            
      (3) Profile customers geographically and by demographics for targeted marketing.
            
      (4) Produce product price tiers and engagement metrics to prioritize promotions.
            
      (5) Assess product/service satisfaction via review ratings and its relationship with session duration.

# Project Overview

The goal of this project is to transform raw marketing data into actionable insights using SQL queries. The exercises cover:

      Data enrichment: Joining customer and geography data.

      Product insights: Categorizing products into price tiers.

      Engagement cleaning: Standardizing content types, parsing views/clicks, formatting dates.

      Deduplication: Identifying and resolving duplicate records with ROW_NUMBER().

      Customer journey analytics: Funnel retention, action frequency, visit timelines, and time-to-purchase.

      Engagement metrics: Average session duration and repeat visits.

      Review insights: Rating distribution, trends over time, and relationship between engagement and satisfaction.

      Conversion rate analysis: Funnel-wide conversion rate to purchase/checkout.

# SQL Techniques Used

      Joins (LEFT, INNER, FULL OUTER) for enrichment.

      CASE expressions for conditional categorization.

      String manipulation (REPLACE, UPPER, LEFT, RIGHT, CHARINDEX).

      Date functions (FORMAT, DATEPART, CONVERT).

      Window functions (ROW_NUMBER(), LAG(), AVG() OVER, PARTITION BY).

      Common Table Expressions (CTEs) for deduplication and funnel analysis.

      Aggregations (COUNT, AVG, SUM, GROUP BY).

#Project Structure

📁 Marketing-Analytics-SQL

├── etl_cleaning.sql        # Queries for cleaning & normalization

├── analysis_queries.sql     # Queries for funnel, journey, and review analysis

├── README.md                # Project documentation


# Analytical queries & methods (what we measured)

Below are the key analyses performed, with the SQL techniques employed and the analytical purpose.

      Funnel distribution & drop-off
            
            Method: Aggregate customers per Stage, then use LAG() to compute retention between ordered funnel stages (Homepage → ProductPage → Checkout).
            
            Purpose: quantify retention% between steps and identify major drop points.


      Action frequency
            
            Method: GROUP BY Action + COUNT(*) to find most common actions (View, Click, Purchase).
            
            Purpose: optimize UX & marketing to amplify high-value actions.


      Visit timelines (daily/weekly/monthly)
            
            Method: GROUP BY on CAST(VisitDate AS DATE), DATEPART(WEEK), and DATEPART(MONTH) to produce time series counts.
            
            Purpose: detect seasonality, campaign impact, and anomalies.


      Time-to-purchase (conversion velocity)
            
            Method: CTEs FirstVisit and FirstPurchase, then DATEDIFF(DAY, FirstVisitDate, PurchaseDate) per CustomerID, ProductID.
            
            Purpose: measure days required to convert after first exposure; useful for targeting (e.g., retarget after typical drop window).


      Customer engagement metrics
            
            Avg session Duration per customer (AVG(Duration)), repeat visits (COUNT(*) per CustomerID), and join with customers to get names for reporting.
            
            Purpose: identify high-engagement customers and potential ambassadors.


      Ratings & reviews analysis
            
            Distribution of Rating (histogram), AvgRating over time (month-year trend), and correlation of TotalDuration with FinalRating.
            
            Purpose: check whether longer sessions relate to higher/lower satisfaction; detect product issues or UX friction.


     Product conversion rate
            
            Method: compute total customers vs customers who reached Checkout to estimate overall conversion percentage.
            
            Purpose: baseline KPI for product and site performance.
            

# Suggested Dashboard (Power BI / Tableau)

      Funnel Analysis: Stage counts & retention %.

      Time-to-Purchase: Distribution of days to convert.

      Engagement Trends: Session duration, repeat visits.

      Ratings Over Time: Monthly trend in satisfaction.

      Geographic Segmentation: Conversion heatmap by city/country.

# Upcoming Exercises

      Build retention cohorts (7/30/90 day).

      Develop CLTV & churn prediction models using SQL + Python.
      
      Train a churn/propensity model to target customers likely to convert with personalized offers.

      Automate dashboard refresh with Power BI.

      Experiment with A/B testing for funnel optimization.
