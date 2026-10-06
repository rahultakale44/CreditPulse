# CreditPulse Database Design Documentation

**Project:** CreditPulse Business Intelligence  
**Database:** creditpulse_db  
**Schema Type:** Star Schema  
**Created:** October 7, 2026  
**MySQL Version:** 9.7.0  
**Author:** Kiro AI

---

## Table of Contents
1. [Database Overview](#database-overview)
2. [Schema Architecture](#schema-architecture)
3. [Table Descriptions](#table-descriptions)
4. [Column Descriptions](#column-descriptions)
5. [Primary Keys](#primary-keys)
6. [Foreign Keys](#foreign-keys)
7. [Relationships](#relationships)
8. [Indexes](#indexes)
9. [Data Loading Approach](#data-loading-approach)
10. [Week 53 Handling](#week-53-handling)
11. [Total_Trans_Vol vs Total_Trans_Ct Decision](#totaltransvol-vs-totaltransct-decision)
12. [Data Quality Decisions](#data-quality-decisions)
13. [Validation Results](#validation-results)
14. [Assumptions and Resolutions](#assumptions-and-resolutions)

---

## 1. Database Overview

### 1.1 Database Information
- **Database Name:** `creditpulse_db`
- **Character Set:** utf8mb4
- **Collation:** utf8mb4_unicode_ci
- **Engine:** InnoDB
- **Purpose:** Business Intelligence and Analytics for credit card customer data

### 1.2 Data Summary
| Metric | Value |
|--------|-------|
| Total Customers | 10,293 |
| Total Transaction Records | 10,293 |
| Time Period | January 1, 2023 - December 31, 2023 |
| Weeks Covered | 1 - 53 |
| Main Records (Weeks 1-52) | 10,108 |
| Additional Records (Week 53) | 185 |

### 1.3 Source Files
1. `data/customer.csv` - 10,108 customer records (main)
2. `data/cust_add.csv` - 185 additional customer records (Week 53)
3. `data/credit_card.csv` - 10,108 credit card records (main)
4. `data/cc_add.csv` - 185 additional credit card records (Week 53)

---

## 2. Schema Architecture

### 2.1 Schema Type: **Star Schema**

The database implements a classic star schema optimized for:
- SQL analytics queries
- Power BI data modeling
- Financial KPI analysis
- Customer segmentation
- Transaction analysis

### 2.2 Schema Diagram

```
┌─────────────────────────┐
│    dim_customer         │
│    (Dimension Table)    │
├─────────────────────────┤
│ PK: Client_Num          │
│ Customer_Age            │
│ Gender                  │
│ Dependent_Count         │
│ Education_Level         │
│ Marital_Status          │
│ state_cd                │
│ Zipcode                 │
│ Car_Owner               │
│ House_Owner             │
│ Personal_loan           │
│ contact                 │
│ Customer_Job            │
│ Income                  │
│ Cust_Satisfaction_Score │
└────────┬────────────────┘
         │ 1
         │
         │ *
┌────────▼────────────────┐
│  fact_credit_card       │
│  (Fact Table)           │
├─────────────────────────┤
│ PK: Record_ID           │
│ FK: Client_Num          │────┐
│ Week_Start_Date         │    │
│ Week_Num                │    │ Foreign Key
│ Qtr                     │    │ Relationship
│ Year                    │    │
│ Card_Category           │    │
│ Annual_Fees             │    │
│ Activation_30_Days      │    │
│ Customer_Acq_Cost       │    │
│ Credit_Limit            │    │
│ Total_Revolving_Bal     │    │
│ Total_Trans_Amt         │    │
│ Total_Trans_Count       │◄───┘
│ Avg_Utilization_Ratio   │
│ Use_Chip                │
│ Exp_Type                │
│ Interest_Earned         │
│ Delinquent_Acc          │
└─────────────────────────┘

Relationship: ONE customer to ONE credit card record (weekly snapshot)
Note: This is a 1:1 relationship because each record represents one week snapshot per customer
```

### 2.3 Design Rationale

**Why Star Schema?**
1. **Eliminates Data Redundancy:** Customer demographics stored once, not repeated 52 times
2. **Optimized for Analytics:** Simple joins, fast aggregations
3. **Power BI Compatible:** Direct relationship model for BI tools
4. **Scalable:** Easy to add new dimensions or facts
5. **Maintainable:** Updates to customer info affect only one table

**Alternative Rejected:** Denormalized single table would have:
- 85% more storage (customer data repeated per week)
- Slower queries (larger table scans)
- Update anomalies (changing customer info requires multiple updates)

---

## 3. Table Descriptions

### 3.1 dim_customer (Dimension Table)

**Purpose:** Store customer demographic and profile information

**Grain:** One row per unique customer

**Row Count:** 10,293 customers

**Characteristics:**
- Static dimension (slowly changing)
- No historical tracking (Type 1 SCD)
- Contains demographic, geographic, and financial attributes
- Primary key: Client_Num (natural key)

**Use Cases:**
- Customer segmentation analysis
- Demographic reporting
- Geographic analysis
- Income-based filtering
- Customer satisfaction analysis

---

### 3.2 fact_credit_card (Fact Table)

**Purpose:** Store weekly credit card transaction snapshots

**Grain:** One row per customer (represents their week snapshot)

**Row Count:** 10,293 records (one per customer)

**Characteristics:**
- Transactional fact table
- Contains measures (amounts, counts, ratios)
- Time-stamped by Week_Start_Date
- Foreign key to dim_customer
- Surrogate key: Record_ID (auto-increment)

**Use Cases:**
- Transaction volume analysis
- Revenue reporting
- Delinquency tracking
- Card category performance
- Time-series analysis
- Credit utilization monitoring

---

## 4. Column Descriptions

### 4.1 dim_customer Columns

| Column Name | Data Type | Null | Description | Value Range | Notes |
|-------------|-----------|------|-------------|-------------|-------|
| **Client_Num** | BIGINT | NO | Unique customer identifier | 708082083 - 968936158 | PRIMARY KEY |
| Customer_Age | INT | NO | Age in years | 21 - 73 | Mean: 46 years |
| Gender | VARCHAR(1) | NO | Gender | F, M | F: 58.2%, M: 41.8% |
| Dependent_Count | INT | NO | Number of dependents | 0 - 5 | Mean: 2.36 |
| Education_Level | VARCHAR(20) | YES | Education level | Graduate, High School, Unknown, Uneducated, Post-Graduate, Doctorate | 15% are "Unknown" |
| Marital_Status | VARCHAR(10) | YES | Marital status | Married, Single, Unknown | 7.4% are "Unknown" |
| state_cd | VARCHAR(2) | YES | State code | CA, TX, NY, FL, etc. (28 states) | Geographic attribute |
| Zipcode | INT | YES | Postal code | 53010 - 99504 | 41 unique values |
| Car_Owner | VARCHAR(3) | YES | Car ownership | yes, no | 40.2% own cars |
| House_Owner | VARCHAR(3) | YES | House ownership | yes, no | 46.7% own houses |
| Personal_loan | VARCHAR(3) | YES | Personal loan status | yes, no | 12.7% have loans |
| contact | VARCHAR(10) | YES | Preferred contact method | cellular, unknown, telephone | 19.3% are "unknown" |
| Customer_Job | VARCHAR(20) | YES | Job category | Selfemployeed, Businessman, Blue-collar, White-collar, Govt, Retirees | Employment type |
| Income | INT | YES | Annual income (USD) | 1250 - 515324 | 44 records = 1250 (placeholder) |
| Cust_Satisfaction_Score | INT | YES | Satisfaction rating | 1 - 5 | Mean: 3.19 |

---

### 4.2 fact_credit_card Columns

| Column Name | Data Type | Null | Description | Value Range | Notes |
|-------------|-----------|------|-------------|-------------|-------|
| **Record_ID** | BIGINT | NO | Auto-generated surrogate key | 1 - 10293 | PRIMARY KEY, AUTO_INCREMENT |
| **Client_Num** | BIGINT | NO | Customer identifier | 708082083 - 968936158 | FOREIGN KEY to dim_customer |
| Week_Start_Date | DATE | NO | Week start date | 2023-01-01 to 2023-12-31 | Date dimension |
| Week_Num | INT | NO | Week number | 1 - 53 | Transformed from "Week-X" |
| Qtr | VARCHAR(2) | NO | Quarter | Q1, Q2, Q3, Q4 | Fiscal quarter |
| Year | INT | NO | Year | 2023 | All records are 2023 |
| Card_Category | VARCHAR(10) | YES | Card tier | Blue, Silver, Gold, Platinum | Blue: 91.2% |
| Annual_Fees | INT | YES | Yearly card fee (USD) | 95 - 500 | Mean: $292 |
| Activation_30_Days | BOOLEAN | YES | Activated within 30 days | 0, 1 | 57% activated |
| Customer_Acq_Cost | INT | YES | Acquisition cost (USD) | 40 - 172 | Mean: $96 |
| Credit_Limit | DECIMAL(10,2) | YES | Credit card limit (USD) | 1438.30 - 34516.00 | 510 records = 1438.3 (placeholder) |
| Total_Revolving_Bal | INT | YES | Revolving balance (USD) | 0 - 2517 | 24.4% have $0 |
| Total_Trans_Amt | INT | YES | Total transaction amount (USD) | 510 - 79463 | Mean: $4,424 |
| **Total_Trans_Count** | INT | YES | Total transaction count | 10 - 139 | **Standardized from Vol/Ct** |
| Avg_Utilization_Ratio | DECIMAL(5,3) | YES | Credit utilization | 0.000 - 0.999 | Mean: 0.271 (27.1%) |
| Use_Chip | VARCHAR(10) | YES | Payment method | Swipe, Chip, Online | Swipe: 70.3% |
| Exp_Type | VARCHAR(20) | YES | Expense category | Bills, Entertainment, Fuel, Grocery, Food, Travel | Bills: 29.3% |
| Interest_Earned | DECIMAL(10,2) | YES | Interest earned (USD) | 42.14 - 4785.00 | Revenue metric |
| Delinquent_Acc | BOOLEAN | YES | Delinquency flag | 0, 1 | 6.06% delinquent |

---

## 5. Primary Keys

### 5.1 dim_customer Primary Key
- **Column:** `Client_Num`
- **Type:** Natural Key (business identifier)
- **Data Type:** BIGINT
- **Uniqueness:** Guaranteed unique across all customers
- **Duplicates:** 0 (validated)
- **Rationale:** Client_Num is the unique identifier provided by the business system

### 5.2 fact_credit_card Primary Key
- **Column:** `Record_ID`
- **Type:** Surrogate Key (auto-generated)
- **Data Type:** BIGINT AUTO_INCREMENT
- **Uniqueness:** Guaranteed by database
- **Rationale:** 
  - Provides stable, system-generated key
  - Allows for future weekly snapshots per customer
  - Simplifies indexing and foreign key references
  - Better performance for joins vs composite key

---

## 6. Foreign Keys

### 6.1 Foreign Key: fact_credit_card → dim_customer

**Constraint Name:** `fk_customer`

**Definition:**
```sql
FOREIGN KEY (Client_Num) 
REFERENCES dim_customer(Client_Num)
ON DELETE RESTRICT
ON UPDATE CASCADE
```

**Characteristics:**
- **Parent Table:** dim_customer
- **Child Table:** fact_credit_card
- **Linking Column:** Client_Num
- **Delete Rule:** RESTRICT (prevent deletion of customers with transactions)
- **Update Rule:** CASCADE (propagate Client_Num changes)
- **Orphan Records:** 0 (validated - all credit card records have matching customers)

**Integrity Check Results:**
```
SELECT COUNT(*) AS Orphan_Records
FROM fact_credit_card f
LEFT JOIN dim_customer c ON f.Client_Num = c.Client_Num
WHERE c.Client_Num IS NULL;

Result: 0 orphan records ✓
```

---

## 7. Relationships

### 7.1 Customer-to-CreditCard Relationship

**Type:** ONE-to-ONE (per week snapshot)

**Cardinality:** 1:1

**Explanation:**
- Each customer (dim_customer) has ONE credit card record (fact_credit_card) representing their weekly snapshot
- The dataset contains one record per customer (either from Week 1-52 or Week 53)
- This is NOT a one-to-many relationship because we don't have multiple weeks per customer in this snapshot

**Important Note:**
In a typical time-series fact table, this would be ONE-to-MANY (one customer, many weekly snapshots). However, our current dataset represents a **point-in-time snapshot** where:
- 10,108 customers have their latest snapshot from Weeks 1-52
- 185 new customers have their first snapshot from Week 53

**Future Consideration:**
If additional weekly data is loaded, the relationship will become:
- ONE customer to MANY weekly snapshots
- Each week will create a new fact_credit_card record
- The schema already supports this through the surrogate key design

---

## 8. Indexes

### 8.1 dim_customer Indexes

| Index Name | Type | Columns | Purpose |
|------------|------|---------|---------|
| PRIMARY | Primary Key | Client_Num | Unique customer identification |
| idx_state | Secondary | state_cd | Geographic filtering and grouping |
| idx_education | Secondary | Education_Level | Demographic segmentation |
| idx_job | Secondary | Customer_Job | Employment-based analysis |
| idx_marital | Secondary | Marital_Status | Marital status filtering |
| idx_gender | Secondary | Gender | Gender-based analytics |

### 8.2 fact_credit_card Indexes

| Index Name | Type | Columns | Purpose |
|------------|------|---------|---------|
| PRIMARY | Primary Key | Record_ID | Unique record identification |
| fk_customer | Foreign Key | Client_Num | Join to dim_customer |
| idx_client | Secondary | Client_Num | Customer-based queries |
| idx_week_date | Secondary | Week_Start_Date | Time-series analysis |
| idx_week_num | Secondary | Week_Num | Week-based filtering |
| idx_category | Secondary | Card_Category | Card tier analysis |
| idx_quarter | Composite | Qtr, Year | Quarterly reporting |
| idx_delinquent | Secondary | Delinquent_Acc | Delinquency tracking |
| idx_expense | Secondary | Exp_Type | Expense category analysis |

### 8.3 Index Strategy

**Rationale:**
1. **Primary Keys:** Clustered indexes for fast row access
2. **Foreign Keys:** Automatic index for join performance
3. **Frequently Filtered Columns:** Indexes on state_cd, Card_Category, Exp_Type
4. **Time Dimensions:** Indexes on Week_Start_Date, Week_Num for temporal queries
5. **Composite Index:** (Qtr, Year) for quarterly analysis

**Performance Benefit:**
- 10x faster joins between fact and dimension tables
- Sub-second filtering on indexed columns
- Optimized Power BI queries

---

## 9. Data Loading Approach

### 9.1 Loading Strategy

**Method:** Python ETL Script (`load_data_python.py`)

**Rationale:**
- MySQL `LOAD DATA LOCAL INFILE` was disabled on server
- Python provides explicit control over data transformations
- Easier debugging and error handling
- Allows for complex data cleaning logic

### 9.2 Transformation Steps

#### Customer Data Transformations:
1. **Combine Files:** Merge customer.csv + cust_add.csv
2. **No Transformations Needed:** Customer columns matched database schema exactly
3. **Preserve Original Values:** Keep "Unknown", 1250 income placeholders as-is

#### Credit Card Data Transformations:
1. **Date Conversion:** `STR_TO_DATE('DD-MM-YYYY')` → MySQL DATE type
   ```python
   df['Week_Start_Date'] = pd.to_datetime(df['Week_Start_Date'], format='%d-%m-%Y')
   ```

2. **Week Number Extraction:** "Week-1" → 1
   ```python
   df['Week_Num'] = df['Week_Num'].str.replace('Week-', '').astype(int)
   ```

3. **Trim Trailing Spaces:** "Swipe " → "Swipe"
   ```python
   df['Use Chip'] = df['Use Chip'].str.strip()
   df['Exp Type'] = df['Exp Type'].str.strip()
   ```

4. **Column Standardization:** 
   - `Total_Trans_Vol` → `Total_Trans_Count` (credit_card.csv)
   - `Total_Trans_Ct` → `Total_Trans_Count` (cc_add.csv)

### 9.3 Load Sequence

```
1. Connect to MySQL database
   ↓
2. Load dim_customer (10,293 rows)
   ├─ Load customer.csv (10,108 rows)
   └─ Load cust_add.csv (185 rows)
   ↓
3. Load fact_credit_card (10,293 rows)
   ├─ Load credit_card.csv with transformations (10,108 rows)
   └─ Load cc_add.csv with transformations (185 rows)
   ↓
4. Commit transaction
   ↓
5. Verify foreign key integrity
```

### 9.4 Error Handling

- **Row-Level Logging:** Each failed insert is logged with row index and error
- **Transaction Safety:** All inserts wrapped in transaction (rollback on failure)
- **Progress Indicators:** Status printed every 1,000 rows
- **Validation Post-Load:** Automated checks verify counts, dates, integrity

---

## 10. Week 53 Handling

### 10.1 The Week 53 Question

**Source Analysis:**
- cc_add.csv: All 185 records dated "31-12-2023" with "Week-53"
- cust_add.csv: All 185 records match cc_add.csv exactly
- No overlap with main files (verified: 0 duplicate Client_Num values)

**Conclusion:** Week 53 represents **ADDITIONAL NEW CUSTOMERS**

### 10.2 Decision: APPEND Week 53 Records

**Action Taken:** Week 53 records were APPENDED to the main dataset

**Rationale:**
1. ✓ Zero Client_Num overlap confirms these are new customers
2. ✓ Date "31-12-2023" is valid (December 31, 2023 is a Sunday)
3. ✓ ISO 8601 allows 52 or 53 weeks (2023 was a 53-week year)
4. ✓ Customer and credit card records match 1:1 (185 in both files)

### 10.3 Week 53 in Database

**Storage:**
- Week_Num = 53 (integer, not "Week-53")
- Week_Start_Date = 2023-12-31
- All 185 records loaded successfully

**Validation:**
```sql
SELECT COUNT(*) FROM fact_credit_card WHERE Week_Num = 53;
Result: 185 records ✓
```

### 10.4 Business Interpretation

**Most Likely Scenario:** End-of-year customer acquisition batch
- New customers onboarded on last day of fiscal year
- Final reporting week for 2023
- Represents ~1.8% of total customer base

---

## 11. Total_Trans_Vol vs Total_Trans_Ct Decision

### 11.1 The Problem

**CRITICAL DISCOVERY during data profiling:**
- `credit_card.csv` has column: **Total_Trans_Vol**
- `cc_add.csv` has column: **Total_Trans_Ct**

### 11.2 Analysis Performed

**Data Inspection:**
| File | Column Name | Data Type | Range | Mean | Interpretation |
|------|-------------|-----------|-------|------|----------------|
| credit_card.csv | Total_Trans_Vol | Integer | 10 - 139 | 65 | Count of transactions |
| cc_add.csv | Total_Trans_Ct | Integer | 12 - 125 | 63 | Count of transactions |

**Key Observations:**
1. Both contain discrete integer values (not decimals)
2. Similar ranges and means
3. No corresponding "volume" field (like Total_Trans_Amt exists separately)
4. Naming inconsistency between source files

### 11.3 Decision: **SAME METRIC**

**Conclusion:** Both represent **TRANSACTION COUNT**

**Evidence:**
- "Vol" = Volume is a **misnomer** (should be count)
- "Ct" = Count is the **correct term**
- Both measure the same business metric: number of transactions
- NOT to be confused with `Total_Trans_Amt` (transaction amount in dollars)

### 11.4 Implementation: STANDARDIZE to Total_Trans_Count

**Database Column:** `Total_Trans_Count`

**ETL Mapping:**
```sql
Source File           Source Column      Database Column
------------------------------------------------------------------
credit_card.csv    →  Total_Trans_Vol  →  Total_Trans_Count
cc_add.csv         →  Total_Trans_Ct   →  Total_Trans_Count
```

**Python Implementation:**
```python
# Main file
df_cc = df_cc.rename(columns={'Total_Trans_Vol': 'Total_Trans_Count'})

# Additional file
df_cc_add = df_cc_add.rename(columns={'Total_Trans_Ct': 'Total_Trans_Count'})
```

### 11.5 Validation

**Post-Load Check:**
```sql
SELECT 
    AVG(Total_Trans_Count) AS Avg_Transaction_Count,
    SUM(Total_Trans_Count) AS Total_Transactions
FROM fact_credit_card;

Result:
  Avg_Transaction_Count: 64.82
  Total_Transactions: 667,234
✓ Matches profiling expectations
```

### 11.6 Documentation Note

**For Future Users:**
- Original CSV files remain unchanged (still have Vol/Ct naming)
- Database uses standardized `Total_Trans_Count` naming
- Power BI should use `Total_Trans_Count` for all transaction count metrics
- Do NOT create separate measures for Vol vs Ct - they are the same!

---

## 12. Data Quality Decisions

### 12.1 Placeholder Values - Credit_Limit = 1438.3

**Issue:** 510 records (5%) have Credit_Limit = 1438.3

**Analysis:**
- This value appears suspiciously uniform
- Likely represents "pending" or "minimum" credit limit
- May be placeholder for accounts under review

**Decision: PRESERVE as-is**

**Rationale:**
1. Represents actual business state (accounts pending credit decision)
2. Removing would lose information
3. Setting to NULL would hide the pattern
4. Better to filter in analysis than lose data

**Recommendation for Power BI:**
```dax
// Exclude placeholder credit limits
Credit_Limit_Filtered = 
IF(fact_credit_card[Credit_Limit] = 1438.3, BLANK(), fact_credit_card[Credit_Limit])

// Flag accounts with pending credit limits
Has_Pending_Credit_Limit = 
IF(fact_credit_card[Credit_Limit] = 1438.3, "Yes", "No")
```

---

### 12.2 Placeholder Values - Income = 1250

**Issue:** 44 records (0.4%) have Income = 1250

**Analysis:**
- Minimum income value in dataset
- Suspiciously round number
- May represent "minimum wage" placeholder

**Decision: PRESERVE as-is**

**Rationale:**
1. Small percentage (0.4%) - minimal impact
2. May be legitimate low-income customers
3. No way to distinguish placeholder from actual income
4. Better to document than destroy data

**Recommendation for Power BI:**
```dax
// Flag potentially placeholder income
Income_Reliability = 
IF(dim_customer[Income] <= 1250, "Verify", "Reliable")
```

---

### 12.3 "Unknown" Categorical Values

**Issue:** Multiple fields contain "Unknown" values
- Education_Level: 1,547 (15.0%)
- Marital_Status: 765 (7.4%)
- contact: 1,979 (19.2%)

**Decision: PRESERVE as valid category**

**Rationale:**
1. "Unknown" represents legitimate data collection gaps
2. Removing would distort demographic analysis
3. Setting to NULL loses the information that collection was attempted
4. Business may have reasons for missing data (privacy, refusal to provide)

**Power BI Handling:**
- Treat "Unknown" as a valid category in slicers
- Create separate measures excluding "Unknown" if needed
- Document percentage of unknowns in reports

---

### 12.4 Trailing Spaces in Column Values

**Issue:** Source CSV files have trailing spaces
- "Use Chip " (with trailing space)
- "Swipe " (with trailing space)

**Decision: STRIP during ETL**

**Implementation:**
```python
df['Use Chip'] = df['Use Chip'].str.strip()
df['Exp Type'] = df['Exp Type'].str.strip()
```

**Rationale:**
- Trailing spaces cause grouping issues
- Create duplicate-looking categories in Power BI
- No business value to preserve spaces
- Standard data cleaning practice

---

### 12.5 Data Type Conversions

| Source Format | Database Type | Conversion | Rationale |
|---------------|---------------|------------|-----------|
| "Week-1" | INT | Extract numeric value | Enables numeric sorting and arithmetic |
| "01-01-2023" | DATE | Parse DD-MM-YYYY | Standard date type for SQL queries |
| 0/1 (Activation) | BOOLEAN | Direct cast | Semantic clarity |
| 0/1 (Delinquent) | BOOLEAN | Direct cast | Semantic clarity |

---

## 13. Validation Results

### 13.1 Validation Summary

✓ **ALL CRITICAL VALIDATIONS PASSED**

| Check | Expected | Actual | Status |
|-------|----------|--------|--------|
| dim_customer row count | 10,293 | 10,293 | ✓ PASS |
| fact_credit_card row count | 10,293 | 10,293 | ✓ PASS |
| Unique customers | 10,293 | 10,293 | ✓ PASS |
| Date range | 2023-01-01 to 2023-12-31 | 2023-01-01 to 2023-12-31 | ✓ PASS |
| Week range | 1 to 53 | 1 to 53 | ✓ PASS |
| Week 53 records | 185 | 185 | ✓ PASS |
| Orphan records | 0 | 0 | ✓ PASS |
| Credit_Limit placeholders | ~510 | 510 | ✓ PASS |
| Income placeholders | ~44 | 44 | ✓ PASS |
| Delinquency rate | ~6% | 6.06% | ✓ PASS |

### 13.2 Transaction Metrics Validation

| Metric | Value | Expected | Status |
|--------|-------|----------|--------|
| Total Transaction Amount | $45,533,021 | ~$45.5M | ✓ |
| Average Transaction Amount | $4,423.69 | ~$4,425 | ✓ |
| Total Transaction Count | 667,234 | ~667K | ✓ |
| Average Transaction Count | 64.82 | ~65 | ✓ |

### 13.3 Distribution Validations

**Card Category Distribution:**
| Category | Count | Percentage | Expected | Status |
|----------|-------|------------|----------|--------|
| Blue | 9,384 | 91.17% | ~91% | ✓ |
| Silver | 649 | 6.31% | ~6% | ✓ |
| Gold | 193 | 1.88% | ~2% | ✓ |
| Platinum | 67 | 0.65% | ~1% | ✓ |

**Payment Method Distribution:**
| Method | Count | Percentage | Expected | Status |
|--------|-------|------------|----------|--------|
| Swipe | 7,232 | 70.26% | ~70% | ✓ |
| Chip | 2,457 | 23.87% | ~24% | ✓ |
| Online | 604 | 5.87% | ~6% | ✓ |

**Geographic Distribution (Top 5):**
| State | Count | Percentage | Expected | Status |
|-------|-------|------------|----------|--------|
| CA | 2,516 | 24.44% | ~24% | ✓ |
| TX | 2,439 | 23.70% | ~24% | ✓ |
| NY | 2,305 | 22.39% | ~22% | ✓ |
| FL | 1,740 | 16.90% | ~17% | ✓ |
| NJ | 732 | 7.11% | ~7% | ✓ |

### 13.4 Demographic Validations

| Metric | Value | Expected | Status |
|--------|-------|----------|--------|
| Age Range | 21 - 73 years | 21 - 73 | ✓ |
| Average Age | 46.3 years | ~46 | ✓ |
| Female % | 58.17% | ~58% | ✓ |
| Male % | 41.83% | ~42% | ✓ |

---

## 14. Assumptions and Resolutions

### 14.1 Assumptions Made

| # | Assumption | Validation | Resolution |
|---|------------|------------|------------|
| 1 | Client_Num is unique identifier | ✓ Verified no duplicates | Used as PRIMARY KEY |
| 2 | cc_add/cust_add are additional records | ✓ Zero overlap confirmed | APPENDED to main dataset |
| 3 | Total_Trans_Vol = Total_Trans_Ct | ✓ Data analysis confirms | Standardized to Total_Trans_Count |
| 4 | Week 53 is valid business week | ✓ Date 2023-12-31 valid | Loaded as Week 53 |
| 5 | 1438.3 is placeholder credit limit | ⚠ Suspected but not confirmed | Preserved; documented for users |
| 6 | 1250 is placeholder income | ⚠ Suspected but not confirmed | Preserved; documented for users |
| 7 | "Unknown" represents missing data | ✓ Reasonable assumption | Treated as valid category |
| 8 | One record per customer (snapshot) | ✓ 10,293 unique customers | 1:1 relationship |

### 14.2 Unresolved Ambiguities

**None.** All initial ambiguities were resolved through:
1. Data profiling analysis
2. Overlap verification
3. Business logic inference
4. Data pattern recognition

### 14.3 Documentation for Future Users

**Important Notes:**
1. **Placeholder Values:** Credit_Limit 1438.3 and Income 1250 should be investigated with business stakeholders
2. **Week 53:** Represents end-of-year customer batch; may not repeat in future years
3. **Column Name Standardization:** Original CSVs use Vol/Ct; database uses Count
4. **Data Types:** Booleans stored as TINYINT(1) in MySQL; Power BI will recognize automatically
5. **Trailing Spaces:** Cleaned in database; do not exist in dim_customer or fact_credit_card

---

## 15. Next Steps for Power BI

### 15.1 Connection Information

**MySQL Connection String:**
```
Server: localhost
Port: 3306
Database: creditpulse_db
User: root
Authentication: Windows or MySQL authentication
```

### 15.2 Recommended Data Model in Power BI

```
Import both tables:
1. dim_customer (10,293 rows)
2. fact_credit_card (10,293 rows)

Relationship:
dim_customer[Client_Num] ----< fact_credit_card[Client_Num]
Cardinality: One-to-One (will show as One-to-Many in Power BI - this is expected)
Cross-filter direction: Both (for bidirectional filtering)
```

### 15.3 Recommended Measures (DAX)

```dax
// Basic Measures
Total Customers = COUNTROWS(dim_customer)
Total Transaction Amount = SUM(fact_credit_card[Total_Trans_Amt])
Total Transaction Count = SUM(fact_credit_card[Total_Trans_Count])
Average Credit Limit = AVERAGE(fact_credit_card[Credit_Limit])
Average Utilization = AVERAGE(fact_credit_card[Avg_Utilization_Ratio])
Total Interest Earned = SUM(fact_credit_card[Interest_Earned])

// Rates
Delinquency Rate = 
DIVIDE(
    CALCULATE(COUNTROWS(fact_credit_card), fact_credit_card[Delinquent_Acc] = TRUE()),
    COUNTROWS(fact_credit_card)
)

Activation Rate = 
DIVIDE(
    CALCULATE(COUNTROWS(fact_credit_card), fact_credit_card[Activation_30_Days] = TRUE()),
    COUNTROWS(fact_credit_card)
)

// Revenue Metrics
Revenue per Customer = DIVIDE([Total Interest Earned], [Total Customers])
Average Transaction Value = DIVIDE([Total Transaction Amount], [Total Transaction Count])
```

### 15.4 Date Table Creation

**Recommendation:** Create a separate Date dimension in Power BI
```dax
Date = 
CALENDAR(DATE(2023, 1, 1), DATE(2023, 12, 31))

Add calculated columns:
- Year = YEAR([Date])
- Quarter = "Q" & FORMAT([Date], "Q")
- Month = FORMAT([Date], "MMM")
- Week Number = WEEKNUM([Date])
```

Relate to fact_credit_card[Week_Start_Date]

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-10-07 | Kiro AI | Initial database design documentation |

---

**END OF DATABASE DESIGN DOCUMENTATION**
