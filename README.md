# Marketing Analytics with SQL

This project demonstrates SQL-based data cleaning, enrichment, and analysis for marketing and customer journey data. It uses the PortfolioProject_MarketingAnalytics database and explores customer demographics, engagement, funnel analysis, time-to-purchase, and review trends.

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


# Suggested Dashboard (Power BI / Tableau)

      Funnel Analysis: Stage counts & retention %.

      Time-to-Purchase: Distribution of days to convert.

      Engagement Trends: Session duration, repeat visits.

      Ratings Over Time: Monthly trend in satisfaction.

      Geographic Segmentation: Conversion heatmap by city/country.

# Upcoming Exercises

      Build retention cohorts (7/30/90 day).

      Develop CLTV & churn prediction models using SQL + Python.

      Automate dashboard refresh with Power BI.

      Experiment with A/B testing for funnel optimization.
