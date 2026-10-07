# Power BI Dashboard Guide

## 📁 Files

- **CreditPulse.pbix** - Main Power BI report file (to be created)

## 🔌 Database Connection Setup

### Step 1: Open Power BI Desktop

1. Launch Power BI Desktop
2. Click **Get Data** → **Database** → **MySQL database**

### Step 2: Enter Connection Details

```
Server: localhost
Database: creditpulse_db
```

### Step 3: Import Tables

Select these tables:
- ✅ `dim_customer`
- ✅ `fact_credit_card`

Click **Load**

### Step 4: Create Relationship

1. Go to **Model view** (left sidebar)
2. Create relationship:
   - **From:** `dim_customer[Client_Num]`
   - **To:** `fact_credit_card[Client_Num]`
   - **Cardinality:** One-to-One (1:1)
   - **Cross filter direction:** Both
   - **Make this relationship active:** ✓

---

## 📊 Recommended DAX Measures

### Create a Measures Table

1. In Model view, right-click → **New table**
2. Name it: `_Measures`

### Financial Metrics

```dax
// Total Revenue
Total Revenue = SUM(fact_credit_card[Interest_Earned])

// Total Transaction Amount
Total Transaction Amount = SUM(fact_credit_card[Total_Trans_Amt])

// Total Transaction Count
Total Transaction Count = SUM(fact_credit_card[Total_Trans_Count])

// Average Transaction Value
Avg Transaction Value = 
DIVIDE(
    [Total Transaction Amount],
    [Total Transaction Count],
    0
)

// Revenue per Customer
Revenue per Customer = 
DIVIDE(
    [Total Revenue],
    [Total Customers],
    0
)

// Average Credit Limit
Avg Credit Limit = AVERAGE(fact_credit_card[Credit_Limit])

// Average Utilization
Avg Utilization = AVERAGE(fact_credit_card[Avg_Utilization_Ratio])
```

### Customer Metrics

```dax
// Total Customers
Total Customers = COUNTROWS(dim_customer)

// Active Customers (with transactions)
Active Customers = 
CALCULATE(
    DISTINCTCOUNT(fact_credit_card[Client_Num])
)

// Female Customers
Female Customers = 
CALCULATE(
    COUNTROWS(dim_customer),
    dim_customer[Gender] = "F"
)

// Male Customers
Male Customers = 
CALCULATE(
    COUNTROWS(dim_customer),
    dim_customer[Gender] = "M"
)

// Female %
Female Percentage = 
DIVIDE([Female Customers], [Total Customers], 0)

// Average Customer Age
Avg Customer Age = AVERAGE(dim_customer[Customer_Age])

// Average Income
Avg Income = AVERAGE(dim_customer[Income])
```

### Performance Metrics

```dax
// Delinquency Rate
Delinquency Rate = 
DIVIDE(
    CALCULATE(
        COUNTROWS(fact_credit_card),
        fact_credit_card[Delinquent_Acc] = TRUE()
    ),
    COUNTROWS(fact_credit_card),
    0
)

// Delinquent Accounts
Delinquent Accounts = 
CALCULATE(
    COUNTROWS(fact_credit_card),
    fact_credit_card[Delinquent_Acc] = TRUE()
)

// Activation Rate
Activation Rate = 
DIVIDE(
    CALCULATE(
        COUNTROWS(fact_credit_card),
        fact_credit_card[Activation_30_Days] = TRUE()
    ),
    COUNTROWS(fact_credit_card),
    0
)

// Average Acquisition Cost
Avg Acquisition Cost = AVERAGE(fact_credit_card[Customer_Acq_Cost])
```

### Conditional Formatting Measures

```dax
// Revenue Status Color
Revenue Status = 
SWITCH(
    TRUE(),
    [Total Revenue] >= 1000000, "Green",
    [Total Revenue] >= 500000, "Yellow",
    "Red"
)

// Delinquency Status
Delinquency Status = 
IF([Delinquency Rate] > 0.1, "High Risk", 
    IF([Delinquency Rate] > 0.05, "Medium Risk", "Low Risk"))
```

### Time Intelligence (if Date table created)

```dax
// Revenue Month over Month
Revenue MoM = 
VAR CurrentRevenue = [Total Revenue]
VAR PreviousRevenue = 
    CALCULATE(
        [Total Revenue],
        DATEADD('Date'[Date], -1, MONTH)
    )
RETURN
    DIVIDE(CurrentRevenue - PreviousRevenue, PreviousRevenue, 0)

// Revenue Year to Date
Revenue YTD = 
CALCULATE(
    [Total Revenue],
    DATESYTD('Date'[Date])
)
```

---

## 🎨 Dashboard Design Guidelines

### Color Palette

**Primary Colors:**
- 🔵 Blue: `#1F77B4` (Primary brand color)
- 🟢 Green: `#2CA02C` (Positive metrics)
- 🔴 Red: `#D62728` (Negative metrics, alerts)
- 🟡 Yellow: `#FFA500` (Warning, medium priority)

**Secondary Colors:**
- Gray: `#7F7F7F` (Text, labels)
- Light Gray: `#E0E0E0` (Backgrounds)
- White: `#FFFFFF` (Cards, containers)

### Typography

- **Headers:** Segoe UI Bold, 16-20pt
- **KPIs:** Segoe UI Bold, 28-36pt
- **Body Text:** Segoe UI, 10-12pt
- **Labels:** Segoe UI, 9-10pt

---

## 📋 Dashboard Pages

### Page 1: Executive Overview

**Purpose:** High-level business metrics at a glance

**Visuals:**
1. **KPI Cards (Top Row)**
   - Total Revenue
   - Total Customers
   - Total Transaction Amount
   - Delinquency Rate
   - Activation Rate
   - Average Transaction Value

2. **Line Chart:** Revenue Trend by Week
   - X-axis: Week_Start_Date
   - Y-axis: Total Revenue
   - Show data labels: Last point only

3. **Bar Chart:** Revenue by Card Category
   - X-axis: Card_Category
   - Y-axis: Total Revenue
   - Sort: Descending

4. **Donut Chart:** Revenue by Expense Type
   - Legend: Exp_Type
   - Values: Total Revenue
   - Show percentage

5. **Table:** Top 10 States by Revenue
   - Columns: state_cd, Total Customers, Total Revenue
   - Sort: Total Revenue descending

**Filters:**
- Date Range Slicer
- Card Category
- State

---

### Page 2: Customer Demographics

**Purpose:** Understand customer base composition

**Visuals:**
1. **KPI Cards**
   - Total Customers
   - Female %
   - Male %
   - Average Age
   - Average Income

2. **Column Chart:** Age Distribution
   - X-axis: Customer_Age (binned: 20-30, 31-40, 41-50, 51-60, 61+)
   - Y-axis: Count of Customers

3. **Pie Chart:** Gender Distribution
   - Legend: Gender
   - Values: Total Customers

4. **Bar Chart:** Customers by Education Level
   - Y-axis: Education_Level
   - X-axis: Total Customers

5. **Map:** Geographic Distribution
   - Location: state_cd
   - Bubble size: Total Customers
   - Color: Total Revenue

6. **Stacked Bar:** Income Segmentation
   - Y-axis: Income brackets (<30K, 30-60K, 60-100K, 100K+)
   - X-axis: Count
   - Legend: Gender

**Filters:**
- State
- Age Range
- Income Range
- Education Level

---

### Page 3: Transaction Analysis

**Purpose:** Deep dive into transaction patterns

**Visuals:**
1. **KPI Cards**
   - Total Transaction Amount
   - Total Transaction Count
   - Average Transaction Value

2. **Area Chart:** Transaction Amount Trend
   - X-axis: Week_Start_Date
   - Y-axis: Total Transaction Amount

3. **Clustered Column:** Transactions by Payment Method
   - X-axis: Use_Chip
   - Y-axis: Total Transaction Count
   - Color: Exp_Type

4. **Tree Map:** Transaction Amount by Expense Type
   - Group: Exp_Type
   - Values: Total Transaction Amount

5. **Scatter Plot:** Transaction Amount vs Count
   - X-axis: Total Transaction Count
   - Y-axis: Total Transaction Amount
   - Details: Card_Category
   - Size: Credit_Limit

**Filters:**
- Date Range
- Payment Method
- Expense Type
- Card Category

---

### Page 4: Credit Performance

**Purpose:** Monitor credit risk and utilization

**Visuals:**
1. **Gauge Charts**
   - Delinquency Rate (0-20% scale, target <5%)
   - Activation Rate (0-100% scale, target >70%)
   - Average Utilization (0-100% scale, target <30%)

2. **Column Chart:** Delinquency by State
   - X-axis: state_cd
   - Y-axis: Delinquency Rate
   - Color gradient: Red (high) to Green (low)

3. **Histogram:** Credit Utilization Distribution
   - X-axis: Avg_Utilization_Ratio (binned)
   - Y-axis: Count of Customers

4. **Scatter Plot:** Credit Limit vs Revolving Balance
   - X-axis: Credit_Limit
   - Y-axis: Total_Revolving_Bal
   - Color: Delinquent_Acc
   - Size: Interest_Earned

5. **Funnel Chart:** Activation Journey
   - Stages: Total Customers → Activated → Non-Delinquent → High Revenue

6. **Matrix:** Risk Segmentation
   - Rows: Utilization brackets
   - Columns: Income brackets
   - Values: Delinquency Rate

**Filters:**
- Card Category
- State
- Utilization Range
- Delinquency Status

---

### Page 5: Geographic Analysis

**Purpose:** Regional performance insights

**Visuals:**
1. **Filled Map:** Revenue by State
   - Location: state_cd
   - Color saturation: Total Revenue

2. **Bar Chart:** Top 10 States by Customers
   - Y-axis: state_cd
   - X-axis: Total Customers
   - Sort: Descending

3. **Table:** State-wise Metrics
   - Columns: State, Customers, Revenue, Avg Income, Delinquency Rate

4. **Column Chart:** Card Category by State (Top 5)
   - X-axis: state_cd
   - Y-axis: Count
   - Legend: Card_Category

5. **KPI Cards**
   - Top State by Revenue
   - Top State by Customers
   - Highest Delinquency State

**Filters:**
- State (multi-select)
- Card Category

---

## 🎯 Formatting Best Practices

### Visual Formatting

1. **Remove Gridlines:** Clean, minimal look
2. **Data Labels:** Show only for key metrics
3. **Tooltips:** Customize with multiple metrics
4. **Borders:** Use subtle borders (1-2px, light gray)
5. **Background:** White or light gray for cards

### Interaction Settings

1. **Cross-filtering:** Enable for all visuals
2. **Drill-through:** Create drill-through pages for details
3. **Bookmarks:** Create bookmarks for key views
4. **Buttons:** Add navigation buttons between pages

### Mobile Layout

1. Enable mobile layout for each page
2. Prioritize KPIs at top
3. Stack visuals vertically
4. Use touch-friendly filters

---

## 📤 Publishing

### Publish to Power BI Service

1. Click **Publish** in Power BI Desktop
2. Select workspace
3. Configure scheduled refresh:
   - Frequency: Daily at 6 AM
   - On-premises data gateway: Configure if needed

### Share Dashboard

1. Create a dashboard from reports
2. Pin key visuals
3. Share with stakeholders
4. Set up email subscriptions

---

## 🔒 Security

### Row-Level Security (RLS)

Create role for state-based access:

```dax
[state_cd] = USERPRINCIPALNAME()
```

Apply role in Power BI Service

---

## 📝 Tips & Tricks

1. **Performance:** Use aggregation tables for large datasets
2. **Refresh:** Set up incremental refresh for historical data
3. **Documentation:** Add text boxes explaining complex metrics
4. **Version Control:** Save versions before major changes
5. **Testing:** Test with sample filters before full load

---

## 🐛 Troubleshooting

### Common Issues

**Issue:** Can't connect to MySQL
- **Solution:** Install MySQL ODBC driver, enable TCP/IP

**Issue:** Relationship not working
- **Solution:** Check data types match (both BIGINT)

**Issue:** Measures showing blank
- **Solution:** Check filter context, use CALCULATE

**Issue:** Slow performance
- **Solution:** Reduce visual count, use aggregations

---

## 📞 Support

For issues or questions:
- 📧 Email: rahultakale44@gmail.com
- 🐙 GitHub: [Create an issue](https://github.com/rahultakale44/CreditPulse/issues)

---

**Happy Dashboarding! 📊**
