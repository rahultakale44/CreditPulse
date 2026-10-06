-- ============================================================================
-- CreditPulse Data Loading Script
-- ============================================================================
-- Project: CreditPulse Business Intelligence
-- Purpose: Load data from CSV files into MySQL tables
-- Author: Kiro AI
-- Date: 2026-10-07
-- Data Sources:
--   - data/customer.csv (10,108 records)
--   - data/cust_add.csv (185 records)
--   - data/credit_card.csv (10,108 records)
--   - data/cc_add.csv (185 records)
-- ============================================================================

USE creditpulse_db;

-- ============================================================================
-- STEP 1: Load Customer Data (dim_customer)
-- ============================================================================
-- Load from customer.csv (main file)
-- Expected: 10,108 rows
-- ============================================================================

LOAD DATA LOCAL INFILE 'D:/CreditPulse/data/customer.csv'
INTO TABLE dim_customer
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Client_Num, Customer_Age, Gender, Dependent_Count, Education_Level, 
 Marital_Status, state_cd, Zipcode, Car_Owner, House_Owner, Personal_loan, 
 contact, Customer_Job, Income, Cust_Satisfaction_Score);

SELECT CONCAT('Loaded ', ROW_COUNT(), ' rows from customer.csv') AS Status;

-- ============================================================================
-- STEP 2: Load Additional Customer Data
-- ============================================================================
-- Load from cust_add.csv (additional file - Week 53 customers)
-- Expected: 185 rows
-- ============================================================================

LOAD DATA LOCAL INFILE 'D:/CreditPulse/data/cust_add.csv'
INTO TABLE dim_customer
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Client_Num, Customer_Age, Gender, Dependent_Count, Education_Level, 
 Marital_Status, state_cd, Zipcode, Car_Owner, House_Owner, Personal_loan, 
 contact, Customer_Job, Income, Cust_Satisfaction_Score);

SELECT CONCAT('Loaded ', ROW_COUNT(), ' rows from cust_add.csv') AS Status;

-- Verify customer load
SELECT COUNT(*) AS Total_Customers FROM dim_customer;

-- ============================================================================
-- STEP 3: Load Credit Card Data (fact_credit_card)
-- ============================================================================
-- Load from credit_card.csv (main file - Weeks 1-52)
-- Expected: 10,108 rows
-- IMPORTANT: Standardize Total_Trans_Vol → Total_Trans_Count
-- ============================================================================

LOAD DATA LOCAL INFILE 'D:/CreditPulse/data/credit_card.csv'
INTO TABLE fact_credit_card
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Client_Num, Card_Category, Annual_Fees, Activation_30_Days, Customer_Acq_Cost,
 @Week_Start_Date, @Week_Num, Qtr, Year,
 Credit_Limit, Total_Revolving_Bal, Total_Trans_Amt, Total_Trans_Count,
 Avg_Utilization_Ratio, @Use_Chip, @Exp_Type, Interest_Earned, Delinquent_Acc)
SET
    Week_Start_Date = STR_TO_DATE(@Week_Start_Date, '%d-%m-%Y'),
    Week_Num = CAST(REPLACE(@Week_Num, 'Week-', '') AS UNSIGNED),
    Use_Chip = TRIM(@Use_Chip),
    Exp_Type = TRIM(@Exp_Type);

SELECT CONCAT('Loaded ', ROW_COUNT(), ' rows from credit_card.csv') AS Status;

-- ============================================================================
-- STEP 4: Load Additional Credit Card Data
-- ============================================================================
-- Load from cc_add.csv (additional file - Week 53)
-- Expected: 185 rows
-- IMPORTANT: Standardize Total_Trans_Ct → Total_Trans_Count
-- ============================================================================

LOAD DATA LOCAL INFILE 'D:/CreditPulse/data/cc_add.csv'
INTO TABLE fact_credit_card
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Client_Num, Card_Category, Annual_Fees, Activation_30_Days, Customer_Acq_Cost,
 @Week_Start_Date, @Week_Num, Qtr, Year,
 Credit_Limit, Total_Revolving_Bal, Total_Trans_Amt, Total_Trans_Count,
 Avg_Utilization_Ratio, @Use_Chip, @Exp_Type, Interest_Earned, Delinquent_Acc)
SET
    Week_Start_Date = STR_TO_DATE(@Week_Start_Date, '%d-%m-%Y'),
    Week_Num = CAST(REPLACE(@Week_Num, 'Week-', '') AS UNSIGNED),
    Use_Chip = TRIM(@Use_Chip),
    Exp_Type = TRIM(@Exp_Type);

SELECT CONCAT('Loaded ', ROW_COUNT(), ' rows from cc_add.csv') AS Status;

-- Verify credit card load
SELECT COUNT(*) AS Total_Credit_Card_Records FROM fact_credit_card;

-- ============================================================================
-- Final Summary
-- ============================================================================

SELECT 
    'dim_customer' AS Table_Name,
    COUNT(*) AS Row_Count,
    COUNT(DISTINCT Client_Num) AS Unique_Customers
FROM dim_customer
UNION ALL
SELECT 
    'fact_credit_card' AS Table_Name,
    COUNT(*) AS Row_Count,
    COUNT(DISTINCT Client_Num) AS Unique_Customers
FROM fact_credit_card;

SELECT 'Data loading completed successfully' AS Status;

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================
