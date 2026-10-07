"""
CreditPulse Data Loading Script
Purpose: Load CSV data into MySQL database with proper transformations
Author: Rahul Takale
Date: 2026-10-07
"""

import pandas as pd
import mysql.connector
from mysql.connector import Error
from datetime import datetime

# Database connection parameters
DB_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': 'your_password',  # Change this to your MySQL password
    'database': 'creditpulse_db'
}

def connect_to_db():
    """Establish connection to MySQL database"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        if connection.is_connected():
            print("✓ Connected to MySQL database successfully")
            return connection
    except Error as e:
        print(f"✗ Error connecting to MySQL: {e}")
        return None

def load_customer_data(connection):
    """Load customer.csv and cust_add.csv into dim_customer table"""
    print("\n" + "="*80)
    print("LOADING CUSTOMER DATA")
    print("="*80)
    
    cursor = connection.cursor()
    
    # Load main customer file
    print("\n1. Loading customer.csv...")
    df_customer = pd.read_csv('../data/customer.csv')
    print(f"   - Rows read: {len(df_customer)}")
    
    # Load additional customer file
    print("2. Loading cust_add.csv...")
    df_cust_add = pd.read_csv('../data/cust_add.csv')
    print(f"   - Rows read: {len(df_cust_add)}")
    
    # Combine both dataframes
    df_all_customers = pd.concat([df_customer, df_cust_add], ignore_index=True)
    print(f"3. Total customer records: {len(df_all_customers)}")
    
    # Insert data
    insert_query = """
    INSERT INTO dim_customer 
    (Client_Num, Customer_Age, Gender, Dependent_Count, Education_Level,
     Marital_Status, state_cd, Zipcode, Car_Owner, House_Owner, Personal_loan,
     contact, Customer_Job, Income, Cust_Satisfaction_Score)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    
    inserted_count = 0
    for index, row in df_all_customers.iterrows():
        try:
            cursor.execute(insert_query, tuple(row))
            inserted_count += 1
            if (inserted_count % 1000 == 0):
                print(f"   - Inserted {inserted_count} rows...")
        except Error as e:
            print(f"   ✗ Error inserting row {index}: {e}")
    
    connection.commit()
    print(f"✓ Successfully loaded {inserted_count} customer records")
    
    return inserted_count

def load_credit_card_data(connection):
    """Load credit_card.csv and cc_add.csv into fact_credit_card table"""
    print("\n" + "="*80)
    print("LOADING CREDIT CARD DATA")
    print("="*80)
    
    cursor = connection.cursor()
    
    # Load main credit card file
    print("\n1. Loading credit_card.csv...")
    df_cc = pd.read_csv('../data/credit_card.csv')
    print(f"   - Rows read: {len(df_cc)}")
    
    # Transformations for main file
    print("   - Transforming data...")
    # Convert date format DD-MM-YYYY to YYYY-MM-DD
    df_cc['Week_Start_Date'] = pd.to_datetime(df_cc['Week_Start_Date'], format='%d-%m-%Y')
    
    # Extract numeric week number from "Week-X" format
    df_cc['Week_Num'] = df_cc['Week_Num'].str.replace('Week-', '').astype(int)
    
    # Trim spaces from Use Chip and Exp Type
    df_cc['Use Chip'] = df_cc['Use Chip'].str.strip()
    df_cc['Exp Type'] = df_cc['Exp Type'].str.strip()
    
    # Rename Total_Trans_Vol to Total_Trans_Count
    df_cc = df_cc.rename(columns={'Total_Trans_Vol': 'Total_Trans_Count'})
    
    # Load additional credit card file
    print("\n2. Loading cc_add.csv...")
    df_cc_add = pd.read_csv('../data/cc_add.csv')
    print(f"   - Rows read: {len(df_cc_add)}")
    
    # Transformations for additional file
    print("   - Transforming data...")
    df_cc_add['Week_Start_Date'] = pd.to_datetime(df_cc_add['Week_Start_Date'], format='%d-%m-%Y')
    df_cc_add['Week_Num'] = df_cc_add['Week_Num'].str.replace('Week-', '').astype(int)
    df_cc_add['Use Chip'] = df_cc_add['Use Chip'].str.strip()
    df_cc_add['Exp Type'] = df_cc_add['Exp Type'].str.strip()
    
    # Rename Total_Trans_Ct to Total_Trans_Count (CRITICAL: different column name!)
    df_cc_add = df_cc_add.rename(columns={'Total_Trans_Ct': 'Total_Trans_Count'})
    
    # Combine both dataframes
    df_all_cc = pd.concat([df_cc, df_cc_add], ignore_index=True)
    print(f"3. Total credit card records: {len(df_all_cc)}")
    
    # Prepare column order for insert
    columns_order = [
        'Client_Num', 'Week_Start_Date', 'Week_Num', 'Qtr', 'current_year',
        'Card_Category', 'Annual_Fees', 'Activation_30_Days', 'Customer_Acq_Cost',
        'Credit_Limit', 'Total_Revolving_Bal', 'Total_Trans_Amt', 'Total_Trans_Count',
        'Avg_Utilization_Ratio', 'Use Chip', 'Exp Type', 'Interest_Earned', 'Delinquent_Acc'
    ]
    
    df_all_cc = df_all_cc[columns_order]
    
    # Insert data
    insert_query = """
    INSERT INTO fact_credit_card 
    (Client_Num, Week_Start_Date, Week_Num, Qtr, Year,
     Card_Category, Annual_Fees, Activation_30_Days, Customer_Acq_Cost,
     Credit_Limit, Total_Revolving_Bal, Total_Trans_Amt, Total_Trans_Count,
     Avg_Utilization_Ratio, Use_Chip, Exp_Type, Interest_Earned, Delinquent_Acc)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    
    inserted_count = 0
    for index, row in df_all_cc.iterrows():
        try:
            cursor.execute(insert_query, tuple(row))
            inserted_count += 1
            if (inserted_count % 1000 == 0):
                print(f"   - Inserted {inserted_count} rows...")
        except Error as e:
            print(f"   ✗ Error inserting row {index}: {e}")
    
    connection.commit()
    print(f"✓ Successfully loaded {inserted_count} credit card records")
    
    return inserted_count

def verify_data(connection):
    """Verify data load with basic checks"""
    print("\n" + "="*80)
    print("DATA VERIFICATION")
    print("="*80)
    
    cursor = connection.cursor()
    
    # Check row counts
    cursor.execute("SELECT COUNT(*) FROM dim_customer")
    customer_count = cursor.fetchone()[0]
    print(f"\n✓ dim_customer rows: {customer_count} (Expected: 10,293)")
    
    cursor.execute("SELECT COUNT(*) FROM fact_credit_card")
    cc_count = cursor.fetchone()[0]
    print(f"✓ fact_credit_card rows: {cc_count} (Expected: 10,293)")
    
    # Check distinct customers
    cursor.execute("SELECT COUNT(DISTINCT Client_Num) FROM dim_customer")
    unique_customers = cursor.fetchone()[0]
    print(f"✓ Unique customers: {unique_customers}")
    
    # Check date range
    cursor.execute("SELECT MIN(Week_Start_Date), MAX(Week_Start_Date) FROM fact_credit_card")
    min_date, max_date = cursor.fetchone()
    print(f"✓ Date range: {min_date} to {max_date}")
    
    # Check Week 53 records
    cursor.execute("SELECT COUNT(*) FROM fact_credit_card WHERE Week_Num = 53")
    week_53_count = cursor.fetchone()[0]
    print(f"✓ Week 53 records: {week_53_count} (Expected: 185)")
    
    # Check foreign key integrity
    cursor.execute("""
        SELECT COUNT(*) FROM fact_credit_card f
        LEFT JOIN dim_customer c ON f.Client_Num = c.Client_Num
        WHERE c.Client_Num IS NULL
    """)
    orphan_count = cursor.fetchone()[0]
    print(f"✓ Orphan records: {orphan_count} (Expected: 0)")
    
    cursor.close()

def main():
    """Main execution function"""
    print("="*80)
    print("CREDITPULSE DATA LOADING SCRIPT")
    print("="*80)
    print(f"Start time: {datetime.now()}")
    
    # Connect to database
    connection = connect_to_db()
    if not connection:
        print("✗ Failed to connect to database. Exiting.")
        return
    
    try:
        # Load customer data
        customer_count = load_customer_data(connection)
        
        # Load credit card data
        cc_count = load_credit_card_data(connection)
        
        # Verify data
        verify_data(connection)
        
        # Summary
        print("\n" + "="*80)
        print("LOADING COMPLETE")
        print("="*80)
        print(f"✓ Total customers loaded: {customer_count}")
        print(f"✓ Total credit card records loaded: {cc_count}")
        print(f"✓ End time: {datetime.now()}")
        print("\n✓ Data loading completed successfully!")
        
    except Error as e:
        print(f"\n✗ An error occurred: {e}")
        connection.rollback()
    finally:
        if connection.is_connected():
            connection.close()
            print("\n✓ MySQL connection closed")

if __name__ == "__main__":
    main()
