-- ============================================================================
-- CreditPulse Data Validation Script
-- ============================================================================
-- Project: CreditPulse Business Intelligence
-- Purpose: Validate data integrity, quality, and completeness
-- Author: Kiro AI
-- Date: 2026-10-07
-- ============================================================================

USE creditpulse_db;

-- ============================================================================
-- SECTION 1: ROW COUNT VALIDATION
-- ============================================================================

SELECT '=== ROW COUNT VALIDATION ===' AS Section;

SELECT 
    'dim_customer' AS Table_Name,
    COUNT(*) AS Row_Count,
    10293 AS Expected_Count,
    CASE 
        WHEN COUNT(*) = 10293 THEN '✓ PASS'
        ELSE '✗ FAIL'
    END AS Status
FROM dim_customer
UNION ALL
SELECT 
    'fact_credit_card' AS Table_Name,
    COUNT(*) AS Row_Count,
    10293 AS Expected_Count,
    CASE 
        WHEN COUNT(*) = 10293 THEN '✓ PASS'
        ELSE '✗ FAIL'
    END AS Status
FROM fact_credit_card;

-- ============================================================================
-- SECTION 2: DISTINCT CUSTOMER COUNT
-- ============================================================================

SELECT '=== DISTINCT CUSTOMER COUNT ===' AS Section;

SELECT 
    COUNT(DISTINCT Client_Num) AS Unique_Customers_dim,
    10293 AS Expected_Count,
    CASE 
        WHEN COUNT(DISTINCT Client_Num) = 10293 THEN '✓ PASS'
        ELSE '✗ FAIL'
    END AS Status
FROM dim_customer;

SELECT 
    COUNT(DISTINCT Client_Num) AS Unique_Customers_fact,
    10293 AS Expected_Count,
    CASE 
        WHEN COUNT(DISTINCT Client_Num) = 10293 THEN '✓ PASS'
        ELSE '✗ FAIL'
    END AS Status
FROM fact_credit_card;

-- ============================================================================
-- SECTION 3: DUPLICATE PRIMARY KEY CHECK
-- ============================================================================

SELECT '=== DUPLICATE PRIMARY KEY CHECK ===' AS Section;

-- Check dim_customer for duplicate Client_Num
SELECT 
    'dim_customer' AS Table_Name,
    Client_Num,
    COUNT(*) AS Duplicate_Count
FROM dim_customer
GROUP BY Client_Num
HAVING COUNT(*) > 1;

-- If no results, display success message
SELECT 
    CASE 
        WHEN NOT EXISTS (
            SELECT 1 FROM dim_customer 
            GROUP BY Client_Num HAVING COUNT(*) > 1
        ) THEN '✓ PASS: No duplicate Client_Num in dim_customer'
        ELSE '✗ FAIL: Duplicates found in dim_customer'
    END AS Status;

-- Check fact_credit_card for duplicate Record_ID
SELECT 
    'fact_credit_card' AS Table_Name,
    Record_ID,
    COUNT(*) AS Duplicate_Count
FROM fact_credit_card
GROUP BY Record_ID
HAVING COUNT(*) > 1;

SELECT 
    CASE 
        WHEN NOT EXISTS (
            SELECT 1 FROM fact_credit_card 
            GROUP BY Record_ID HAVING COUNT(*) > 1
        ) THEN '✓ PASS: No duplicate Record_ID in fact_credit_card'
        ELSE '✗ FAIL: Duplicates found in fact_credit_card'
    END AS Status;

-- ============================================================================
-- SECTION 4: NULL VALUE ANALYSIS
-- ============================================================================

SELECT '=== NULL VALUE ANALYSIS ===' AS Section;

-- Expected: Zero NULLs in NOT NULL columns, some NULLs acceptable in others
SELECT 'dim_customer NULL counts:' AS Analysis;

SELECT 
    COUNT(*) - COUNT(Client_Num) AS Client_Num_NULLs,
    COUNT(*) - COUNT(Customer_Age) AS Customer_Age_NULLs,
    COUNT(*) - COUNT(Gender) AS Gender_NULLs,
    COUNT(*) - COUNT(Education_Level) AS Education_Level_NULLs,
    COUNT(*) - COUNT(Marital_Status) AS Marital_Status_NULLs,
    COUNT(*) - COUNT(Income) AS Income_NULLs,
    COUNT(*) - COUNT(Cust_Satisfaction_Score) AS Satisfaction_NULLs
FROM dim_customer;

SELECT 'fact_credit_card NULL counts:' AS Analysis;

SELECT 
    COUNT(*) - COUNT(Record_ID) AS Record_ID_NULLs,
    COUNT(*) - COUNT(Client_Num) AS Client_Num_NULLs,
    COUNT(*) - COUNT(Week_Start_Date) AS Week_Start_Date_NULLs,
    COUNT(*) - COUNT(Week_Num) AS Week_Num_NULLs,
    COUNT(*) - COUNT(Total_Trans_Amt) AS Total_Trans_Amt_NULLs,
    COUNT(*) - COUNT(Total_Trans_Count) AS Total_Trans_Count_NULLs,
    COUNT(*) - COUNT(Credit_Limit) AS Credit_Limit_NULLs
FROM fact_credit_card;

-- ============================================================================
-- SECTION 5: FOREIGN KEY INTEGRITY CHECK
-- ============================================================================

SELECT '=== FOREIGN KEY INTEGRITY CHECK ===' AS Section;

-- Check for orphan records (credit card records without customers)
SELECT 
    COUNT(*) AS Orphan_Records,
    CASE 
        WHEN COUNT(*) = 0 THEN '✓ PASS: No orphan records'
        ELSE '✗ FAIL: Orphan records found'
    END AS Status
FROM fact_credit_card f
LEFT JOIN dim_customer c ON f.Client_Num = c.Client_Num
WHERE c.Client_Num IS NULL;

-- ============================================================================
-- SECTION 6: DATE RANGE VALIDATION
-- ============================================================================

SELECT '=== DATE RANGE VALIDATION ===' AS Section;

SELECT 
    MIN(Week_Start_Date) AS Min_Date,
    MAX(Week_Start_Date) AS Max_Date,
    DATE('2023-01-01') AS Expected_Min,
    DATE('2023-12-31') AS Expected_Max,
    CASE 
        WHEN MIN(Week_Start_Date) = '2023-01-01' 
         AND MAX(Week_Start_Date) = '2023-12-31' 
        THEN '✓ PASS'
        ELSE '✗ CHECK: Date range differs from expected'
    END AS Status
FROM fact_credit_card;

-- Week number range
SELECT 
    MIN(Week_Num) AS Min_Week,
    MAX(Week_Num) AS Max_Week,
    1 AS Expected_Min,
    53 AS Expected_Max,
    CASE 
        WHEN MIN(Week_Num) >= 1 AND MAX(Week_Num) <= 53 
        THEN '✓ PASS'
        ELSE '✗ FAIL'
    END AS Status
FROM fact_credit_card;

-- ============================================================================
-- SECTION 7: WEEK 53 RECORDS VALIDATION
-- ============================================================================

SELECT '=== WEEK 53 RECORDS VALIDATION ===' AS Section;

-- Count Week 53 records
SELECT 
    COUNT(*) AS Week_53_Count,
    185 AS Expected_Count,
    CASE 
        WHEN COUNT(*) = 185 THEN '✓ PASS'
        ELSE '✗ FAIL'
    END AS Status
FROM fact_credit_card
WHERE Week_Num = 53;

-- Verify Week 53 date
SELECT DISTINCT
    Week_Num,
    Week_Start_Date,
    COUNT(*) AS Record_Count
FROM fact_credit_card
WHERE Week_Num = 53
GROUP BY Week_Num, Week_Start_Date;

-- ============================================================================
-- SECTION 8: TRANSACTION METRICS VALIDATION
-- ============================================================================

SELECT '=== TRANSACTION METRICS VALIDATION ===' AS Section;

-- Total transaction amount and count
SELECT 
    COUNT(*) AS Total_Records,
    SUM(Total_Trans_Amt) AS Total_Transaction_Amount,
    SUM(Total_Trans_Count) AS Total_Transaction_Count,
    AVG(Total_Trans_Amt) AS Avg_Transaction_Amount,
    AVG(Total_Trans_Count) AS Avg_Transaction_Count,
    MIN(Total_Trans_Amt) AS Min_Transaction_Amount,
    MAX(Total_Trans_Amt) AS Max_Transaction_Amount
FROM fact_credit_card;

-- ============================================================================
-- SECTION 9: CREDIT LIMIT ANALYSIS
-- ============================================================================

SELECT '=== CREDIT LIMIT ANALYSIS ===' AS Section;

-- Check placeholder Credit_Limit = 1438.3
SELECT 
    COUNT(*) AS Placeholder_Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_credit_card), 2) AS Percentage,
    510 AS Expected_Approx,
    CASE 
        WHEN COUNT(*) BETWEEN 500 AND 520 THEN '✓ PASS: Within expected range'
        ELSE '⚠ CHECK: Count differs from profiling'
    END AS Status
FROM fact_credit_card
WHERE Credit_Limit = 1438.3;

-- Credit limit range
SELECT 
    MIN(Credit_Limit) AS Min_Credit_Limit,
    MAX(Credit_Limit) AS Max_Credit_Limit,
    AVG(Credit_Limit) AS Avg_Credit_Limit,
    1438.3 AS Expected_Min,
    34516.0 AS Expected_Max
FROM fact_credit_card;

-- ============================================================================
-- SECTION 10: INCOME PLACEHOLDER CHECK
-- ============================================================================

SELECT '=== INCOME PLACEHOLDER CHECK ===' AS Section;

-- Check placeholder Income = 1250
SELECT 
    COUNT(*) AS Income_Placeholder_Count,
    44 AS Expected_Count,
    CASE 
        WHEN COUNT(*) <= 50 THEN '✓ PASS: Within expected range'
        ELSE '⚠ CHECK: Count differs from profiling'
    END AS Status
FROM dim_customer
WHERE Income = 1250;

-- Income range
SELECT 
    MIN(Income) AS Min_Income,
    MAX(Income) AS Max_Income,
    AVG(Income) AS Avg_Income,
    1250 AS Expected_Min_Approx
FROM dim_customer;

-- ============================================================================
-- SECTION 11: DELINQUENCY RATE
-- ============================================================================

SELECT '=== DELINQUENCY ANALYSIS ===' AS Section;

SELECT 
    SUM(CASE WHEN Delinquent_Acc = 1 THEN 1 ELSE 0 END) AS Delinquent_Count,
    COUNT(*) AS Total_Records,
    ROUND(SUM(CASE WHEN Delinquent_Acc = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Delinquency_Rate_Percent,
    CASE 
        WHEN ROUND(SUM(CASE WHEN Delinquent_Acc = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) BETWEEN 5.0 AND 7.0 
        THEN '✓ PASS: ~6% as expected'
        ELSE '⚠ CHECK: Rate differs from profiling'
    END AS Status
FROM fact_credit_card;

-- ============================================================================
-- SECTION 12: ACTIVATION RATE
-- ============================================================================

SELECT '=== ACTIVATION ANALYSIS ===' AS Section;

SELECT 
    SUM(CASE WHEN Activation_30_Days = 1 THEN 1 ELSE 0 END) AS Activated_Count,
    COUNT(*) AS Total_Records,
    ROUND(SUM(CASE WHEN Activation_30_Days = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Activation_Rate_Percent,
    CASE 
        WHEN ROUND(SUM(CASE WHEN Activation_30_Days = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) BETWEEN 55.0 AND 60.0 
        THEN '✓ PASS: ~57% as expected'
        ELSE '⚠ CHECK: Rate differs from profiling'
    END AS Status
FROM fact_credit_card;

-- ============================================================================
-- SECTION 13: INTEREST EARNED
-- ============================================================================

SELECT '=== INTEREST EARNED ANALYSIS ===' AS Section;

SELECT 
    SUM(Interest_Earned) AS Total_Interest_Earned,
    AVG(Interest_Earned) AS Avg_Interest_Earned,
    MIN(Interest_Earned) AS Min_Interest_Earned,
    MAX(Interest_Earned) AS Max_Interest_Earned,
    COUNT(*) AS Record_Count
FROM fact_credit_card;

-- ============================================================================
-- SECTION 14: CARD CATEGORY DISTRIBUTION
-- ============================================================================

SELECT '=== CARD CATEGORY DISTRIBUTION ===' AS Section;

SELECT 
    Card_Category,
    COUNT(*) AS Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_credit_card), 2) AS Percentage
FROM fact_credit_card
GROUP BY Card_Category
ORDER BY Count DESC;

-- Expected: Blue ~91%, Silver ~6%, Gold ~2%, Platinum ~1%

-- ============================================================================
-- SECTION 15: EXPENSE TYPE DISTRIBUTION
-- ============================================================================

SELECT '=== EXPENSE TYPE DISTRIBUTION ===' AS Section;

SELECT 
    Exp_Type,
    COUNT(*) AS Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_credit_card), 2) AS Percentage
FROM fact_credit_card
GROUP BY Exp_Type
ORDER BY Count DESC;

-- Expected: Bills ~29%, Entertainment ~20%, Fuel ~17%, etc.

-- ============================================================================
-- SECTION 16: PAYMENT METHOD DISTRIBUTION
-- ============================================================================

SELECT '=== PAYMENT METHOD DISTRIBUTION ===' AS Section;

SELECT 
    Use_Chip,
    COUNT(*) AS Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_credit_card), 2) AS Percentage
FROM fact_credit_card
GROUP BY Use_Chip
ORDER BY Count DESC;

-- Expected: Swipe ~70%, Chip ~24%, Online ~6%

-- ============================================================================
-- SECTION 17: DEMOGRAPHIC ANALYSIS
-- ============================================================================

SELECT '=== DEMOGRAPHIC ANALYSIS ===' AS Section;

-- Gender distribution
SELECT 
    Gender,
    COUNT(*) AS Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM dim_customer), 2) AS Percentage
FROM dim_customer
GROUP BY Gender;

-- Expected: F ~58%, M ~42%

-- Age statistics
SELECT 
    MIN(Customer_Age) AS Min_Age,
    MAX(Customer_Age) AS Max_Age,
    AVG(Customer_Age) AS Avg_Age,
    21 AS Expected_Min,
    73 AS Expected_Max,
    46 AS Expected_Avg_Approx
FROM dim_customer;

-- ============================================================================
-- SECTION 18: GEOGRAPHIC DISTRIBUTION
-- ============================================================================

SELECT '=== GEOGRAPHIC DISTRIBUTION (TOP 5) ===' AS Section;

SELECT 
    state_cd,
    COUNT(*) AS Customer_Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM dim_customer), 2) AS Percentage
FROM dim_customer
GROUP BY state_cd
ORDER BY Customer_Count DESC
LIMIT 5;

-- Expected: CA ~24%, TX ~24%, NY ~22%, FL ~17%

-- ============================================================================
-- SECTION 19: UNKNOWN VALUE ANALYSIS
-- ============================================================================

SELECT '=== UNKNOWN VALUE ANALYSIS ===' AS Section;

SELECT 
    'Education_Level' AS Field,
    COUNT(*) AS Unknown_Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM dim_customer), 2) AS Percentage
FROM dim_customer
WHERE Education_Level = 'Unknown'
UNION ALL
SELECT 
    'Marital_Status' AS Field,
    COUNT(*) AS Unknown_Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM dim_customer), 2) AS Percentage
FROM dim_customer
WHERE Marital_Status = 'Unknown'
UNION ALL
SELECT 
    'contact' AS Field,
    COUNT(*) AS Unknown_Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM dim_customer), 2) AS Percentage
FROM dim_customer
WHERE contact = 'unknown';

-- Expected: Education ~15%, Marital ~7%, contact ~19%

-- ============================================================================
-- VALIDATION SUMMARY
-- ============================================================================

SELECT '=== VALIDATION SUMMARY ===' AS Section;

SELECT 
    'Data validation completed' AS Status,
    NOW() AS Completion_Time;

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================
