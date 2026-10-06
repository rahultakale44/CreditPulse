-- ============================================================================
-- CreditPulse Table Creation Script
-- ============================================================================
-- Project: CreditPulse Business Intelligence
-- Purpose: Create star schema tables (dim_customer, fact_credit_card)
-- Author: Kiro AI
-- Date: 2026-10-07
-- Schema: Star Schema optimized for Power BI and analytics
-- ============================================================================

USE creditpulse_db;

-- ============================================================================
-- DIMENSION TABLE: dim_customer
-- ============================================================================
-- Purpose: Store customer demographic and profile information
-- Grain: One row per unique customer
-- Expected rows: 10,293 (10,108 main + 185 additional)
-- ============================================================================

CREATE TABLE IF NOT EXISTS dim_customer (
    -- Primary Key
    Client_Num BIGINT NOT NULL COMMENT 'Unique customer identifier',
    
    -- Demographic Information
    Customer_Age INT NOT NULL COMMENT 'Customer age in years (21-73)',
    Gender VARCHAR(1) NOT NULL COMMENT 'Gender: F or M',
    Dependent_Count INT NOT NULL COMMENT 'Number of dependents (0-5)',
    Education_Level VARCHAR(20) DEFAULT NULL COMMENT 'Education level: Graduate, High School, Unknown, Uneducated, Post-Graduate, Doctorate',
    Marital_Status VARCHAR(10) DEFAULT NULL COMMENT 'Marital status: Married, Single, Unknown',
    
    -- Geographic Information
    state_cd VARCHAR(2) DEFAULT NULL COMMENT 'State code (e.g., CA, TX, NY, FL)',
    Zipcode INT DEFAULT NULL COMMENT 'Zip code',
    
    -- Asset Ownership
    Car_Owner VARCHAR(3) DEFAULT NULL COMMENT 'Car ownership: yes or no',
    House_Owner VARCHAR(3) DEFAULT NULL COMMENT 'House ownership: yes or no',
    Personal_loan VARCHAR(3) DEFAULT NULL COMMENT 'Personal loan status: yes or no',
    
    -- Contact Information
    contact VARCHAR(10) DEFAULT NULL COMMENT 'Contact method: cellular, unknown, telephone',
    
    -- Employment & Financial
    Customer_Job VARCHAR(20) DEFAULT NULL COMMENT 'Job category: Selfemployeed, Businessman, Blue-collar, White-collar, Govt, Retirees',
    Income INT DEFAULT NULL COMMENT 'Annual income in dollars (Note: 1250 may be placeholder)',
    
    -- Satisfaction
    Cust_Satisfaction_Score INT DEFAULT NULL COMMENT 'Satisfaction score 1-5',
    
    -- Constraints
    PRIMARY KEY (Client_Num),
    
    -- Indexes for common queries
    INDEX idx_state (state_cd),
    INDEX idx_education (Education_Level),
    INDEX idx_job (Customer_Job),
    INDEX idx_marital (Marital_Status),
    INDEX idx_gender (Gender)
    
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Dimension table containing customer demographics and profiles';

-- ============================================================================
-- FACT TABLE: fact_credit_card
-- ============================================================================
-- Purpose: Store weekly credit card transaction snapshots
-- Grain: One row per customer per week
-- Expected rows: 10,293 (one record per customer - mostly Week 53 snapshot)
-- Note: Main file has weeks 1-52, additional file has week 53
-- ============================================================================

CREATE TABLE IF NOT EXISTS fact_credit_card (
    -- Surrogate Key
    Record_ID BIGINT NOT NULL AUTO_INCREMENT COMMENT 'Auto-generated surrogate key',
    
    -- Foreign Key
    Client_Num BIGINT NOT NULL COMMENT 'Customer identifier (FK to dim_customer)',
    
    -- Time Dimensions
    Week_Start_Date DATE NOT NULL COMMENT 'Week start date (2023-01-01 to 2023-12-31)',
    Week_Num INT NOT NULL COMMENT 'Week number (1-53)',
    Qtr VARCHAR(2) NOT NULL COMMENT 'Quarter: Q1, Q2, Q3, Q4',
    Year INT NOT NULL COMMENT 'Year (2023)',
    
    -- Card Information
    Card_Category VARCHAR(10) DEFAULT NULL COMMENT 'Card category: Blue, Silver, Gold, Platinum',
    Annual_Fees INT DEFAULT NULL COMMENT 'Annual card fees in dollars (95-500)',
    Activation_30_Days BOOLEAN DEFAULT NULL COMMENT 'Card activated within 30 days: 0=No, 1=Yes',
    Customer_Acq_Cost INT DEFAULT NULL COMMENT 'Customer acquisition cost in dollars (40-172)',
    
    -- Credit Information
    Credit_Limit DECIMAL(10,2) DEFAULT NULL COMMENT 'Credit card limit (Note: 1438.3 may be placeholder)',
    Total_Revolving_Bal INT DEFAULT NULL COMMENT 'Revolving balance in dollars (0-2517)',
    Avg_Utilization_Ratio DECIMAL(5,3) DEFAULT NULL COMMENT 'Credit utilization ratio (0.0-0.999)',
    
    -- Transaction Information
    Total_Trans_Amt INT DEFAULT NULL COMMENT 'Total transaction amount in dollars',
    Total_Trans_Count INT DEFAULT NULL COMMENT 'Total transaction count (standardized from Trans_Vol/Trans_Ct)',
    
    -- Transaction Method & Category
    Use_Chip VARCHAR(10) DEFAULT NULL COMMENT 'Payment method: Swipe, Chip, Online',
    Exp_Type VARCHAR(20) DEFAULT NULL COMMENT 'Expense category: Bills, Entertainment, Fuel, Grocery, Food, Travel',
    
    -- Financial Metrics
    Interest_Earned DECIMAL(10,2) DEFAULT NULL COMMENT 'Interest earned in dollars',
    Delinquent_Acc BOOLEAN DEFAULT NULL COMMENT 'Delinquent account flag: 0=No, 1=Yes',
    
    -- Constraints
    PRIMARY KEY (Record_ID),
    
    -- Foreign Key Constraint
    CONSTRAINT fk_customer 
        FOREIGN KEY (Client_Num) 
        REFERENCES dim_customer(Client_Num)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Indexes for common queries
    INDEX idx_client (Client_Num),
    INDEX idx_week_date (Week_Start_Date),
    INDEX idx_week_num (Week_Num),
    INDEX idx_category (Card_Category),
    INDEX idx_quarter (Qtr, Year),
    INDEX idx_delinquent (Delinquent_Acc),
    INDEX idx_expense (Exp_Type)
    
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Fact table containing weekly credit card transaction snapshots';

-- ============================================================================
-- Verification Queries
-- ============================================================================

-- Show created tables
SHOW TABLES;

-- Display table structures
DESCRIBE dim_customer;
DESCRIBE fact_credit_card;

-- Display table information
SELECT 
    'dim_customer' AS Table_Name,
    COUNT(*) AS Column_Count
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'creditpulse_db' 
  AND TABLE_NAME = 'dim_customer'
UNION ALL
SELECT 
    'fact_credit_card' AS Table_Name,
    COUNT(*) AS Column_Count
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'creditpulse_db' 
  AND TABLE_NAME = 'fact_credit_card';

SELECT 'Tables created successfully' AS Status;

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================
