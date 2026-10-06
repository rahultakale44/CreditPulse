# CreditPulse - Data Profiling Report

**Project:** CreditPulse Business Intelligence Project  
**Analysis Date:** October 7, 2026  
**Analyst:** Kiro AI  
**Purpose:** Comprehensive data profiling before MySQL database design and Power BI development

---

## Executive Summary

This report provides a detailed analysis of four CSV files containing credit card and customer data for 2023. The dataset contains:
- **10,108 existing customers** with 52 weeks of credit card transaction data (Jan-Dec 2023)
- **185 new customers** added on December 31, 2023 (Week 53)
- **Zero missing values** across all datasets
- **Complete 1:1 relationship** between credit card and customer records

### Key Findings:
1. **cc_add.csv and cust_add.csv represent ADDITIONAL records**, not duplicates
2. All 185 clients in the "add" files are NEW customers not present in main files
3. **Critical difference:** `Total_Trans_Vol` in credit_card.csv vs `Total_Trans_Ct` in cc_add.csv (same meaning, different column names)
4. Data quality issues identified: 510 placeholder Credit_Limit values (1438.3) and 44 placeholder Income values (1250)
5. Week_Num field contains string values like "Week-1" instead of numeric 1

---

## 1. Dataset Overview

### 1.1 File Summary

| File Name | Rows | Columns | Size | Purpose |
|-----------|------|---------|------|---------|
| credit_card.csv | 10,108 | 18 | 4.6 MB | Main credit card transaction data (Weeks 1-52) |
| customer.csv | 10,108 | 15 | 5.8 MB | Main customer demographic and profile data |
| cc_add.csv | 185 | 18 | 85.7 KB | Additional credit card records (Week 53 only) |
| cust_add.csv | 185 | 15 | 109.4 KB | Additional customer records (matching cc_add) |

### 1.2 Data Coverage

- **Time Period:** January 1, 2023 - December 31, 2023
- **Weeks Covered:** 
  - Main files: Week-1 through Week-52 (Jan 1 - Dec 24)
  - Additional files: Week-53 only (Dec 31)
- **Quarters:** Q1, Q2, Q3, Q4
- **Total Unique Customers:** 10,293 (10,108 main + 185 new)

---

## 2. File-by-File Profiling

### 2.1 credit_card.csv (Main Transaction Data)

**Rows:** 10,108 | **Columns:** 18 | **No Missing Values**

#### Column Details:

| Column Name | Data Type | Unique Values | Description | Min | Max | Notes |
|-------------|-----------|---------------|-------------|-----|-----|-------|
| Client_Num | Integer | 10,108 | Customer unique identifier | 708,082,083 | 827,890,758 | PRIMARY KEY - No duplicates |
| Card_Category | String | 4 | Card tier | - | - | Blue (91.2%), Silver (6.3%), Gold (1.9%), Platinum (0.7%) |
| Annual_Fees | Integer | 61 | Yearly card fee | $95 | $500 | Mean: $292 |
| Activation_30_Days | Integer | 2 | Activated within 30 days | 0 | 1 | 57% activated, 43% not activated |
| Customer_Acq_Cost | Integer | 133 | Customer acquisition cost | $40 | $172 | Mean: $96 |
| Week_Start_Date | String | 52 | Week start date | 01-01-2023 | 24-12-2023 | Format: DD-MM-YYYY |
| Week_Num | String | 52 | Week identifier | Week-1 | Week-9 | **STRING, not numeric!** |
| Qtr | String | 4 | Quarter | Q1 | Q4 | Evenly distributed |
| current_year | Integer | 1 | Year | 2023 | 2023 | All records from 2023 |
| Credit_Limit | Float | 6,197 | Credit card limit | $1,438.30 | $34,516.00 | **505 records = $1,438.30 (placeholder)** |
| Total_Revolving_Bal | Integer | 1,974 | Revolving balance | $0 | $2,517 | 24.4% have $0 balance |
| Total_Trans_Amt | Integer | 5,031 | Total transaction amount | $510 | $18,484 | Mean: $4,405 |
| **Total_Trans_Vol** | Integer | 126 | **Transaction count** | 10 | 139 | Mean: 65 transactions |
| Avg_Utilization_Ratio | Float | 964 | Credit utilization | 0.0 | 0.999 | Mean: 0.27 (27%) |
| Use Chip | String | 3 | Payment method | - | - | Swipe (70.3%), Chip (23.9%), Online (5.9%) |
| Exp Type | String | 6 | Expense category | - | - | Bills (29.4%), Entertainment (19.7%), Fuel (17.4%), Grocery (14.9%), Food (11.7%), Travel (6.9%) |
| Interest_Earned | Float | 9,132 | Interest earned | $42.14 | $4,785.00 | Mean: $776 |
| Delinquent_Acc | Integer | 2 | Delinquent account flag | 0 | 1 | 6.1% delinquent |

#### Key Observations:
- **No duplicate rows or Client_Num values**
- **24.4% of customers** have zero revolving balance
- **6.1% delinquency rate**
- Most transactions via Swipe (70.3%)
- Bills is the largest expense category (29.4%)

---

### 2.2 customer.csv (Customer Demographics)

**Rows:** 10,108 | **Columns:** 15 | **No Missing Values**

#### Column Details:

| Column Name | Data Type | Unique Values | Description | Min | Max | Notes |
|-------------|-----------|---------------|-------------|-----|-----|-------|
| Client_Num | Integer | 10,108 | Customer unique identifier | 708,082,083 | 827,890,758 | PRIMARY KEY - Matches credit_card.csv 100% |
| Customer_Age | Integer | 50 | Age in years | 21 | 73 | Mean: 46 years |
| Gender | String | 2 | Gender | - | - | Female (58.2%), Male (41.8%) |
| Dependent_Count | Integer | 6 | Number of dependents | 0 | 5 | Mean: 2.35 |
| Education_Level | String | 6 | Education level | - | - | Graduate (40.9%), High School (19.9%), **Unknown (15.0%)**, Uneducated (14.7%), Post-Graduate (5.1%), Doctorate (4.5%) |
| Marital_Status | String | 3 | Marital status | - | - | Married (50.7%), Single (41.9%), **Unknown (7.4%)** |
| state_cd | String | 28 | State code | - | - | Top: CA (24.4%), TX (23.7%), NY (22.5%), FL (16.9%) |
| Zipcode | Integer | 41 | Zip code | 53,010 | 99,504 | Most: 91750 |
| Car_Owner | String | 2 | Car ownership | - | - | No (59.8%), Yes (40.2%) |
| House_Owner | String | 2 | House ownership | - | - | No (53.3%), Yes (46.7%) |
| Personal_loan | String | 2 | Personal loan status | - | - | No (87.3%), Yes (12.7%) |
| contact | String | 3 | Contact method | - | - | Cellular (73.8%), **Unknown (19.3%)**, Telephone (7.0%) |
| Customer_Job | String | 6 | Job category | - | - | Self-employed (25.5%), Businessman (18.8%), Blue-collar (15.6%), White-collar (15.3%), Government (15.1%), Retirees (9.8%) |
| Income | Integer | 8,695 | Annual income | $1,250 | $239,791 | Mean: $56,976; **44 records = $1,250 (placeholder)** |
| Cust_Satisfaction_Score | Integer | 5 | Satisfaction rating | 1 | 5 | Mean: 3.19 |

#### Key Observations:
- **Perfect 1:1 match** with credit_card.csv (all 10,108 Client_Num values match)
- **58.2% Female, 41.8% Male**
- Average age: 46 years
- **Data quality issues:** 1,515 Unknown Education, 744 Unknown Marital Status, 1,947 Unknown contact method
- Geographic concentration: CA, TX, NY, FL represent 87.5% of customers
- Majority are self-employed or business owners (44.3%)

---

### 2.3 cc_add.csv (Additional Credit Card Records)

**Rows:** 185 | **Columns:** 18 | **No Missing Values**

#### Column Details:

| Column Name | Data Type | Unique Values | Description | Min | Max | Notes |
|-------------|-----------|---------------|-------------|-----|-----|-------|
| Client_Num | Integer | 185 | Customer unique identifier | 911,017,231 | 968,936,158 | **ALL NEW - None overlap with main file** |
| Card_Category | String | 3 | Card tier | - | - | Blue (91.9%), Silver (5.4%), Gold (2.7%) |
| Annual_Fees | Integer | 54 | Yearly card fee | $95 | $495 | Mean: $278 |
| Activation_30_Days | Integer | 2 | Activated within 30 days | 0 | 1 | 57% activated |
| Customer_Acq_Cost | Integer | 84 | Customer acquisition cost | $41 | $172 | Mean: $99 |
| Week_Start_Date | String | 1 | Week start date | 31-12-2023 | 31-12-2023 | **ALL records are Week 53 (Dec 31)** |
| Week_Num | String | 1 | Week identifier | Week-53 | Week-53 | **All Week-53** |
| Qtr | String | 1 | Quarter | Q4 | Q4 | All Q4 |
| current_year | Integer | 1 | Year | 2023 | 2023 | All 2023 |
| Credit_Limit | Float | 173 | Credit card limit | $1,438.30 | $34,516.00 | Mean: $9,012; **5 placeholder values** |
| Total_Revolving_Bal | Integer | 133 | Revolving balance | $0 | $2,517 | 20.5% have $0 balance |
| Total_Trans_Amt | Integer | 182 | Total transaction amount | $687 | $79,463 | Mean: $5,465 (higher than main) |
| **Total_Trans_Ct** | Integer | 77 | **Transaction count** | 12 | 125 | **DIFFERENT NAME than main file!** |
| Avg_Utilization_Ratio | Float | 136 | Credit utilization | 0.0 | 0.904 | Mean: 0.26 |
| Use Chip | String | 3 | Payment method | - | - | Swipe (70.8%), Chip (23.2%), Online (6.0%) |
| Exp Type | String | 6 | Expense category | - | - | Bills (23.8%), Entertainment (22.7%), Grocery (16.8%), Fuel (16.2%), Food (12.4%), Travel (8.1%) |
| Interest_Earned | Float | 185 | Interest earned | $82.00 | $4,124.40 | Mean: $752 |
| Delinquent_Acc | Integer | 2 | Delinquent account flag | 0 | 1 | 5.4% delinquent |

#### Critical Findings:
1. **ALL 185 Client_Num values are NEW** - Zero overlap with credit_card.csv
2. **Week 53 only** - All records dated December 31, 2023
3. **Column name discrepancy:** `Total_Trans_Ct` (count) vs `Total_Trans_Vol` (volume) in main file
4. **These are additional records, not duplicates or updates**
5. Higher average transaction amount ($5,465 vs $4,405)

---

### 2.4 cust_add.csv (Additional Customer Records)

**Rows:** 185 | **Columns:** 15 | **No Missing Values**

#### Column Details:

| Column Name | Data Type | Unique Values | Description | Min | Max | Notes |
|-------------|-----------|---------------|-------------|-----|-----|-------|
| Client_Num | Integer | 185 | Customer unique identifier | 911,017,231 | 968,936,158 | **Matches cc_add.csv 100%** |
| Customer_Age | Integer | 38 | Age in years | 27 | 65 | Mean: 46 years |
| Gender | String | 2 | Gender | - | - | Female (57.8%), Male (42.2%) |
| Dependent_Count | Integer | 6 | Number of dependents | 0 | 5 | Mean: 2.43 |
| Education_Level | String | 6 | Education level | - | - | Graduate (40.0%), High School (20.5%), Unknown (17.3%), Uneducated (12.4%) |
| Marital_Status | String | 3 | Marital status | - | - | Married (48.7%), Single (40.0%), Unknown (11.4%) |
| state_cd | String | 13 | State code | - | - | CA (26.0%), TX (24.3%), NY (18.9%), FL (15.7%) |
| Zipcode | Integer | 3 | Zip code | 53,010 | 91,750 | Mostly 91750 |
| Car_Owner | String | 2 | Car ownership | - | - | No (60.0%), Yes (40.0%) |
| House_Owner | String | 2 | House ownership | - | - | No (56.2%), Yes (43.8%) |
| Personal_loan | String | 2 | Personal loan status | - | - | No (87.0%), Yes (13.0%) |
| contact | String | 3 | Contact method | - | - | Cellular (74.1%), Unknown (17.3%), Telephone (8.7%) |
| Customer_Job | String | 6 | Job category | - | - | Self-employed (28.7%), Businessman (18.4%), Government (15.7%) |
| Income | Integer | 171 | Annual income | $2,565 | $515,324 | Mean: $63,164 (higher than main); **No placeholder values** |
| Cust_Satisfaction_Score | Integer | 5 | Satisfaction rating | 1 | 5 | Mean: 3.49 (higher than main) |

#### Critical Findings:
1. **Perfect 1:1 match with cc_add.csv** - All 185 Client_Num values match
2. **ALL 185 Client_Num values are NEW** - Zero overlap with customer.csv
3. **Identical column structure** to customer.csv
4. **Higher average income** ($63,164 vs $56,976)
5. **Higher satisfaction scores** (3.49 vs 3.19)
6. **No Income placeholder values** (unlike main customer file)

---

## 3. Relationship Analysis

### 3.1 Primary Key: Client_Num

**Client_Num** is the unique identifier across all files:
- **credit_card.csv:** 10,108 unique Client_Num values
- **customer.csv:** 10,108 unique Client_Num values (100% match)
- **cc_add.csv:** 185 unique Client_Num values (100% NEW)
- **cust_add.csv:** 185 unique Client_Num values (100% match with cc_add.csv)

### 3.2 Relationship Diagram

```
Main Dataset (Weeks 1-52, 2023):
┌─────────────────────┐         ┌─────────────────────┐
│  credit_card.csv    │  1:1    │   customer.csv      │
│  10,108 records     │◄───────►│  10,108 records     │
│  Client_Num (PK)    │         │  Client_Num (PK)    │
└─────────────────────┘         └─────────────────────┘
         ↑                               ↑
         │                               │
         │ UNION ALL (append)            │ UNION ALL (append)
         ↓                               ↓
┌─────────────────────┐         ┌─────────────────────┐
│   cc_add.csv        │  1:1    │  cust_add.csv       │
│   185 records       │◄───────►│  185 records        │
│   Client_Num (PK)   │         │  Client_Num (PK)    │
│   Week 53 ONLY      │         │  Week 53 customers  │
└─────────────────────┘         └─────────────────────┘

Total Unique Customers: 10,293
```

### 3.3 Overlap Analysis

| Comparison | Result | Interpretation |
|------------|--------|----------------|
| credit_card ∩ customer | 10,108 (100%) | Perfect match - every credit card has a customer |
| cc_add ∩ credit_card | 0 (0%) | No overlap - all new customers |
| cust_add ∩ customer | 0 (0%) | No overlap - all new customers |
| cc_add ∩ cust_add | 185 (100%) | Perfect match - every new credit card has a customer |

### 3.4 Purpose of "_add" Files

**CONFIRMED: cc_add.csv and cust_add.csv contain ADDITIONAL RECORDS**

These are NOT:
- ❌ Duplicates of existing records
- ❌ Updates to existing records
- ❌ Corrections to main files

These ARE:
- ✅ **New customers acquired in Week 53 (December 31, 2023)**
- ✅ **Complete records** that should be appended to main datasets
- ✅ **185 new customer relationships** added at year-end

### 3.5 Foreign Key Relationships

**For MySQL Database:**

1. **customer table → credit_card table**
   - FK: `Client_Num` in credit_card references `Client_Num` in customer
   - Relationship: ONE customer to MANY credit card records (weekly snapshots)

2. **Data Loading Strategy:**
   - Load customer + cust_add → `dim_customer` table (10,293 records)
   - Load credit_card + cc_add → `fact_credit_card` table (10,293 records)
   - Both maintain Client_Num as linking key

---

## 4. Data Quality Findings

### 4.1 Completeness ✅

| Aspect | Status | Details |
|--------|--------|---------|
| Missing values | ✅ PASS | Zero NULL/missing values in all 4 files |
| Duplicate rows | ✅ PASS | No duplicate rows in any file |
| Duplicate keys | ✅ PASS | No duplicate Client_Num within each file |
| Orphan records | ✅ PASS | All credit cards have matching customers |

### 4.2 Data Quality Issues ⚠️

#### Issue 1: Placeholder Credit_Limit Values
- **Credit_Limit = 1438.3** appears as placeholder
  - credit_card.csv: 505 occurrences (5.0%)
  - cc_add.csv: 5 occurrences (2.7%)
- **Action Required:** Determine actual credit limits or business rule for these accounts

#### Issue 2: Placeholder Income Values
- **Income = 1250** appears as placeholder minimum
  - customer.csv: 44 occurrences (0.4%)
  - cust_add.csv: 0 occurrences
- **Action Required:** Verify if this is actual income or placeholder

#### Issue 3: "Unknown" Categorical Values
- **Education_Level = "Unknown":** 1,515 (15.0%) in main, 32 (17.3%) in add
- **Marital_Status = "Unknown":** 744 (7.4%) in main, 21 (11.4%) in add
- **contact = "unknown":** 1,947 (19.3%) in main, 32 (17.3%) in add
- **Action:** Consider as valid category or attempt to gather additional data

#### Issue 4: Column Name Inconsistency ⚠️ **CRITICAL**
- **credit_card.csv:** `Total_Trans_Vol` (transaction volume/count)
- **cc_add.csv:** `Total_Trans_Ct` (transaction count)
- **SAME MEANING, DIFFERENT NAME**
- **Action Required:** Standardize column name before MySQL import

#### Issue 5: Week_Num Data Type
- Stored as STRING ("Week-1", "Week-2") instead of numeric (1, 2)
- **Action:** Strip "Week-" prefix during ETL to create numeric week field

#### Issue 6: Trailing Spaces in Column Names
- `"Use Chip "` has trailing space
- `"Swipe "` has trailing space
- **Action:** Trim column names and values during data load

### 4.3 Data Ranges & Validity

| Field | Main File | Add File | Validity Check |
|-------|-----------|----------|----------------|
| Customer_Age | 21-73 years | 27-65 years | ✅ Reasonable |
| Dependent_Count | 0-5 | 0-5 | ✅ Reasonable |
| Credit_Limit | $1,438-$34,516 | $1,438-$34,516 | ⚠️ Low end suspicious |
| Income | $1,250-$239,791 | $2,565-$515,324 | ⚠️ Wide range, one outlier |
| Annual_Fees | $95-$500 | $95-$495 | ✅ Reasonable |
| Total_Trans_Amt | $510-$18,484 | $687-$79,463 | ⚠️ One outlier in add ($79k) |
| Avg_Utilization_Ratio | 0.0-0.999 | 0.0-0.904 | ✅ Valid percentage |

---

## 5. Column Name Differences: Total_Trans_Vol vs Total_Trans_Ct

### 5.1 The Issue

**CRITICAL DISCOVERY:**
- `credit_card.csv` has column named **`Total_Trans_Vol`**
- `cc_add.csv` has column named **`Total_Trans_Ct`**

### 5.2 Analysis

Looking at the actual values:

**Total_Trans_Vol (main file):**
- Range: 10 to 139
- Mean: 65
- Data type: Integer
- Meaning: **Count of transactions** (discrete whole numbers)

**Total_Trans_Ct (add file):**
- Range: 12 to 125
- Mean: 63
- Data type: Integer
- Meaning: **Count of transactions** (discrete whole numbers)

### 5.3 Conclusion

**These are the SAME metric with different names:**
- **Vol** = Volume (misnomer, should be Count)
- **Ct** = Count (correct naming)
- Both represent the **number of transactions**

**NOT to be confused with:**
- `Total_Trans_Amt` = Total transaction **amount** in dollars (different field)

### 5.4 Recommended Action

**For MySQL Database:**
- Standardize to `Total_Trans_Count` in both tables
- During ETL: Rename `Total_Trans_Vol` → `Total_Trans_Count`
- During ETL: Rename `Total_Trans_Ct` → `Total_Trans_Count`

---

## 6. Recommended MySQL Table Structure

### 6.1 Database Schema

#### Option A: Normalized Star Schema (RECOMMENDED)

```sql
-- Dimension Table: Customers
CREATE TABLE dim_customer (
    Client_Num BIGINT PRIMARY KEY,
    Customer_Age INT NOT NULL,
    Gender VARCHAR(1) NOT NULL,
    Dependent_Count INT NOT NULL,
    Education_Level VARCHAR(20),
    Marital_Status VARCHAR(10),
    state_cd VARCHAR(2),
    Zipcode INT,
    Car_Owner VARCHAR(3),
    House_Owner VARCHAR(3),
    Personal_loan VARCHAR(3),
    contact VARCHAR(10),
    Customer_Job VARCHAR(20),
    Income INT,
    Cust_Satisfaction_Score INT,
    INDEX idx_state (state_cd),
    INDEX idx_education (Education_Level),
    INDEX idx_job (Customer_Job)
);

-- Fact Table: Credit Card Transactions (Weekly Snapshots)
CREATE TABLE fact_credit_card (
    Record_ID BIGINT AUTO_INCREMENT PRIMARY KEY,
    Client_Num BIGINT NOT NULL,
    Week_Start_Date DATE NOT NULL,
    Week_Num INT NOT NULL,
    Qtr VARCHAR(2) NOT NULL,
    Year INT NOT NULL,
    Card_Category VARCHAR(10),
    Annual_Fees INT,
    Activation_30_Days BOOLEAN,
    Customer_Acq_Cost INT,
    Credit_Limit DECIMAL(10,2),
    Total_Revolving_Bal INT,
    Total_Trans_Amt INT,
    Total_Trans_Count INT,  -- Standardized name
    Avg_Utilization_Ratio DECIMAL(5,3),
    Use_Chip VARCHAR(10),
    Exp_Type VARCHAR(20),
    Interest_Earned DECIMAL(10,2),
    Delinquent_Acc BOOLEAN,
    FOREIGN KEY (Client_Num) REFERENCES dim_customer(Client_Num),
    INDEX idx_week (Week_Start_Date),
    INDEX idx_category (Card_Category),
    INDEX idx_quarter (Qtr, Year)
);

-- Dimension Table: Date (for time intelligence)
CREATE TABLE dim_date (
    Date_Key DATE PRIMARY KEY,
    Week_Num INT,
    Week_Start_Date DATE,
    Month INT,
    Month_Name VARCHAR(20),
    Quarter VARCHAR(2),
    Year INT,
    Is_Weekend BOOLEAN
);
```

#### Option B: Denormalized Single Table (Simpler)

```sql
CREATE TABLE credit_card_transactions (
    Record_ID BIGINT AUTO_INCREMENT PRIMARY KEY,
    Client_Num BIGINT NOT NULL,
    
    -- Credit Card Info (Weekly)
    Week_Start_Date DATE NOT NULL,
    Week_Num INT NOT NULL,
    Qtr VARCHAR(2) NOT NULL,
    Year INT NOT NULL,
    Card_Category VARCHAR(10),
    Annual_Fees INT,
    Activation_30_Days BOOLEAN,
    Customer_Acq_Cost INT,
    Credit_Limit DECIMAL(10,2),
    Total_Revolving_Bal INT,
    Total_Trans_Amt INT,
    Total_Trans_Count INT,
    Avg_Utilization_Ratio DECIMAL(5,3),
    Use_Chip VARCHAR(10),
    Exp_Type VARCHAR(20),
    Interest_Earned DECIMAL(10,2),
    Delinquent_Acc BOOLEAN,
    
    -- Customer Info (Repeated)
    Customer_Age INT,
    Gender VARCHAR(1),
    Dependent_Count INT,
    Education_Level VARCHAR(20),
    Marital_Status VARCHAR(10),
    state_cd VARCHAR(2),
    Zipcode INT,
    Car_Owner VARCHAR(3),
    House_Owner VARCHAR(3),
    Personal_loan VARCHAR(3),
    contact VARCHAR(10),
    Customer_Job VARCHAR(20),
    Income INT,
    Cust_Satisfaction_Score INT,
    
    INDEX idx_client (Client_Num),
    INDEX idx_week (Week_Start_Date),
    INDEX idx_state (state_cd)
);
```

### 6.2 Recommended Approach: **Option A (Star Schema)**

**Rationale:**
1. **Eliminates redundancy:** Customer data stored once (not repeated 52 times)
2. **Better performance:** Smaller fact table, faster aggregations
3. **Easier updates:** Customer changes only update one row
4. **Power BI optimized:** Star schema is ideal for BI tools
5. **Data integrity:** Foreign key constraints prevent orphans
6. **Storage efficient:** ~85% size reduction vs denormalized

### 6.3 Data Loading Sequence

```sql
-- Step 1: Load dimension table
INSERT INTO dim_customer
SELECT * FROM customer
UNION ALL
SELECT * FROM cust_add;
-- Result: 10,293 customer records

-- Step 2: Load fact table (rename columns during insert)
INSERT INTO fact_credit_card
SELECT 
    NULL as Record_ID,  -- Auto-increment
    Client_Num,
    STR_TO_DATE(Week_Start_Date, '%d-%m-%Y') as Week_Start_Date,
    CAST(REPLACE(Week_Num, 'Week-', '') AS UNSIGNED) as Week_Num,
    Qtr,
    current_year as Year,
    Card_Category,
    Annual_Fees,
    Activation_30_Days,
    Customer_Acq_Cost,
    Credit_Limit,
    Total_Revolving_Bal,
    Total_Trans_Amt,
    Total_Trans_Vol as Total_Trans_Count,  -- Rename here
    Avg_Utilization_Ratio,
    TRIM(Use_Chip) as Use_Chip,  -- Remove trailing space
    TRIM(Exp_Type) as Exp_Type,
    Interest_Earned,
    Delinquent_Acc
FROM credit_card
UNION ALL
SELECT 
    NULL as Record_ID,
    Client_Num,
    STR_TO_DATE(Week_Start_Date, '%d-%m-%Y') as Week_Start_Date,
    CAST(REPLACE(Week_Num, 'Week-', '') AS UNSIGNED) as Week_Num,
    Qtr,
    current_year as Year,
    Card_Category,
    Annual_Fees,
    Activation_30_Days,
    Customer_Acq_Cost,
    Credit_Limit,
    Total_Revolving_Bal,
    Total_Trans_Amt,
    Total_Trans_Ct as Total_Trans_Count,  -- Rename here
    Avg_Utilization_Ratio,
    TRIM(Use_Chip) as Use_Chip,
    TRIM(Exp_Type) as Exp_Type,
    Interest_Earned,
    Delinquent_Acc
FROM cc_add;
-- Result: 10,293 credit card records
```

---

## 7. Power BI Considerations

### 7.1 Data Model Relationships

```
dim_customer (1) ────── (*) fact_credit_card
   Client_Num                  Client_Num

dim_date (1) ────── (*) fact_credit_card
   Date_Key                Week_Start_Date
```

### 7.2 Recommended Measures (DAX)

#### Basic Metrics:
- Total Customers
- Total Transaction Amount
- Total Transaction Count
- Average Credit Limit
- Average Utilization Ratio
- Delinquency Rate
- Customer Acquisition Cost

#### Advanced Analytics:
- Customer Lifetime Value
- Utilization Trend
- Delinquency Risk Score
- Revenue by Card Category
- Geographic Distribution
- Demographic Segmentation

### 7.3 Date Handling

**Important:** Convert date strings to proper DATE type:
- Source: "01-01-2023" (DD-MM-YYYY string)
- MySQL: DATE type
- Power BI: Will recognize as date automatically

---

## 8. Data Quality Recommendations

### 8.1 Before Loading to MySQL

1. **✅ Standardize Column Names**
   - Rename `Total_Trans_Vol` → `Total_Trans_Count`
   - Rename `Total_Trans_Ct` → `Total_Trans_Count`
   - Remove trailing spaces: `Use Chip ` → `Use_Chip`

2. **✅ Convert Data Types**
   - `Week_Num`: "Week-1" → 1 (string to int)
   - `Week_Start_Date`: "01-01-2023" → DATE '2023-01-01'
   - `Activation_30_Days`: 0/1 → BOOLEAN
   - `Delinquent_Acc`: 0/1 → BOOLEAN

3. **⚠️ Handle Placeholder Values**
   - Decision needed: Keep Credit_Limit = 1438.3 or set to NULL?
   - Decision needed: Keep Income = 1250 or set to NULL?

4. **✅ Trim String Values**
   - Remove leading/trailing spaces from all VARCHAR fields
   - Especially: `Use Chip`, `Swipe`, payment methods

5. **✅ Validate Referential Integrity**
   - Confirm all Client_Num in fact table exist in dim_customer
   - Already verified: 100% match ✓

### 8.2 Data Validation Queries

```sql
-- Check for orphan credit card records
SELECT COUNT(*) 
FROM fact_credit_card f
LEFT JOIN dim_customer c ON f.Client_Num = c.Client_Num
WHERE c.Client_Num IS NULL;
-- Expected: 0

-- Check for duplicate customers
SELECT Client_Num, COUNT(*) 
FROM dim_customer 
GROUP BY Client_Num 
HAVING COUNT(*) > 1;
-- Expected: 0 rows

-- Check date range
SELECT MIN(Week_Start_Date), MAX(Week_Start_Date)
FROM fact_credit_card;
-- Expected: 2023-01-01 to 2023-12-31

-- Check week count per customer
SELECT Client_Num, COUNT(*) as week_count
FROM fact_credit_card
GROUP BY Client_Num
ORDER BY week_count DESC;
-- Expected: 1 week for new customers, ~52 for existing
```

---

## 9. Summary Statistics

### 9.1 Customer Demographics (Combined: customer + cust_add)

| Metric | Value |
|--------|-------|
| Total Customers | 10,293 |
| Female | 58.1% |
| Male | 41.9% |
| Average Age | 46.3 years |
| Age Range | 21-73 years |
| Average Dependents | 2.36 |
| Married | 50.6% |
| Single | 41.8% |
| Average Income | $57,310 |
| Average Satisfaction Score | 3.21 / 5 |

### 9.2 Geographic Distribution

| State | Customer Count | Percentage |
|-------|----------------|------------|
| California (CA) | 2,516 | 24.4% |
| Texas (TX) | 2,439 | 23.7% |
| New York (NY) | 2,305 | 22.4% |
| Florida (FL) | 1,740 | 16.9% |
| New Jersey (NJ) | 732 | 7.1% |
| Others | 561 | 5.5% |

### 9.3 Credit Card Metrics (Combined: credit_card + cc_add)

| Metric | Value |
|--------|-------|
| Total Records | 10,293 |
| Blue Cards | 91.2% |
| Silver Cards | 6.3% |
| Gold Cards | 1.9% |
| Platinum Cards | 0.7% |
| Average Credit Limit | $8,648 |
| Average Transaction Amount | $4,425 |
| Average Transaction Count | 65 |
| Average Utilization | 27.1% |
| Delinquency Rate | 6.0% |
| Average Interest Earned | $774 |

### 9.4 Transaction Patterns

| Expense Type | Percentage |
|--------------|------------|
| Bills | 29.2% |
| Entertainment | 19.8% |
| Fuel | 17.3% |
| Grocery | 15.0% |
| Food | 11.7% |
| Travel | 7.0% |

| Payment Method | Percentage |
|----------------|------------|
| Swipe | 70.3% |
| Chip | 23.9% |
| Online | 5.8% |

---

## 10. Recommended Next Steps

### Phase 1: Data Preparation ✅
- [x] Complete data profiling
- [ ] Create ETL script to standardize column names
- [ ] Decide on handling of placeholder values (1438.3, 1250)
- [ ] Create data cleaning scripts

### Phase 2: MySQL Database Setup 🔄
- [ ] Create MySQL database `creditpulse_db`
- [ ] Execute table creation scripts (star schema)
- [ ] Create ETL pipeline to load data
- [ ] Run data validation queries
- [ ] Create database indexes for performance
- [ ] Set up foreign key constraints

### Phase 3: Power BI Development 📊
- [ ] Connect Power BI to MySQL database
- [ ] Create data model (star schema)
- [ ] Define relationships and cardinality
- [ ] Create calculated columns and measures (DAX)
- [ ] Build customer demographic dashboard
- [ ] Build transaction analysis dashboard
- [ ] Build geographic analysis dashboard
- [ ] Build delinquency risk dashboard

### Phase 4: Testing & Validation 🧪
- [ ] Verify data accuracy (spot checks)
- [ ] Validate calculations and aggregations
- [ ] Test Power BI filters and slicers
- [ ] Performance testing
- [ ] User acceptance testing

### Phase 5: Deployment & Documentation 🚀
- [ ] Deploy to production environment
- [ ] Create user documentation
- [ ] Create data dictionary
- [ ] Schedule data refreshes
- [ ] Set up monitoring and alerts

---

## 11. Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Column name mismatch (Trans_Vol vs Trans_Ct) | High | Rename during ETL; standardize to Total_Trans_Count |
| Placeholder values may skew analytics | Medium | Document placeholders; consider NULL or exclude from aggregations |
| Unknown categorical values (15-20%) | Medium | Treat as valid category; attempt to gather more data |
| Week 53 only has new customers | Low | Expected behavior; document in data dictionary |
| Date format DD-MM-YYYY not standard | Low | Convert to MySQL DATE type during load |
| Large Income outlier ($515k) | Low | Validate during load; may be accurate |

---

## Appendix A: Column-by-Column Mapping

### Credit Card Tables (credit_card.csv + cc_add.csv)

| Source Column | MySQL Column | Data Type | Transformation |
|---------------|--------------|-----------|----------------|
| Client_Num | Client_Num | BIGINT | None |
| Card_Category | Card_Category | VARCHAR(10) | Trim spaces |
| Annual_Fees | Annual_Fees | INT | None |
| Activation_30_Days | Activation_30_Days | BOOLEAN | 0/1 → TRUE/FALSE |
| Customer_Acq_Cost | Customer_Acq_Cost | INT | None |
| Week_Start_Date | Week_Start_Date | DATE | STR_TO_DATE('%d-%m-%Y') |
| Week_Num | Week_Num | INT | Remove 'Week-' prefix |
| Qtr | Qtr | VARCHAR(2) | None |
| current_year | Year | INT | Rename column |
| Credit_Limit | Credit_Limit | DECIMAL(10,2) | None |
| Total_Revolving_Bal | Total_Revolving_Bal | INT | None |
| Total_Trans_Amt | Total_Trans_Amt | INT | None |
| Total_Trans_Vol / Total_Trans_Ct | Total_Trans_Count | INT | **Standardize name** |
| Avg_Utilization_Ratio | Avg_Utilization_Ratio | DECIMAL(5,3) | None |
| Use Chip (with space) | Use_Chip | VARCHAR(10) | Trim trailing space |
| Exp Type (with space) | Exp_Type | VARCHAR(20) | Trim trailing space |
| Interest_Earned | Interest_Earned | DECIMAL(10,2) | None |
| Delinquent_Acc | Delinquent_Acc | BOOLEAN | 0/1 → TRUE/FALSE |

### Customer Tables (customer.csv + cust_add.csv)

| Source Column | MySQL Column | Data Type | Transformation |
|---------------|--------------|-----------|----------------|
| Client_Num | Client_Num | BIGINT | None (PRIMARY KEY) |
| Customer_Age | Customer_Age | INT | None |
| Gender | Gender | VARCHAR(1) | None |
| Dependent_Count | Dependent_Count | INT | None |
| Education_Level | Education_Level | VARCHAR(20) | None |
| Marital_Status | Marital_Status | VARCHAR(10) | None |
| state_cd | state_cd | VARCHAR(2) | None |
| Zipcode | Zipcode | INT | None |
| Car_Owner | Car_Owner | VARCHAR(3) | None |
| House_Owner | House_Owner | VARCHAR(3) | None |
| Personal_loan | Personal_loan | VARCHAR(3) | None |
| contact | contact | VARCHAR(10) | None |
| Customer_Job | Customer_Job | VARCHAR(20) | None |
| Income | Income | INT | None |
| Cust_Satisfaction_Score | Cust_Satisfaction_Score | INT | None |

---

## Appendix B: Data Dictionary

Will be created after MySQL tables are finalized, including:
- Table names and descriptions
- Column definitions
- Data types and constraints
- Business rules
- Valid value ranges
- Relationships

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-10-07 | Kiro AI | Initial data profiling report |

---

**END OF DATA PROFILING REPORT**
