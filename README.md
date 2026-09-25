# Olist E-Commerce Sales & Customer Analytics Dashboard

An end-to-end data analytics project using the **Olist Brazilian E-Commerce dataset**, covering data quality analysis, SQL business analysis, Python-based data cleaning, and an interactive Power BI dashboard.

The project analyzes approximately **99K orders** placed between **September 2016 and October 2018** to understand sales performance, customer behavior, product and seller performance, delivery logistics, and customer satisfaction.

---

## 📌 Project Overview

The goal of this project is to transform raw e-commerce data into actionable business insights using **SQL, Python, and Power BI**.

The analysis focuses on questions such as:

* How is revenue changing over time?
* Which product categories generate the most revenue?
* Which sellers contribute the most to revenue?
* How many customers are repeat vs. one-time buyers?
* Which states generate the most revenue?
* How do payment methods vary?
* How long does order fulfillment take?
* Does delivery timeliness affect customer satisfaction?
* What factors contribute to customer value and retention?

---

## 🛠️ Tools & Technologies

| Tool                 | Purpose                                                 |
| -------------------- | ------------------------------------------------------- |
| **PostgreSQL / SQL** | Data quality checks and business analysis               |
| **Python**           | Data cleaning, transformation, and exploratory analysis |
| **Pandas**           | Data manipulation and preprocessing                     |
| **Google Colab**     | Python development environment                          |
| **Power BI**         | Interactive dashboard and visualization                 |
| **DAX**              | Measures and analytical calculations                    |

---

## 📂 Repository Structure

```text
Olist-Ecommerce-Analysis/
│
├── README.md
│
├── olist_sql_analysis.sql
│
├── olist_cleaning.ipynb
│
├── olist_ecommerce_dashboard.pbix
│
└── images/
    ├── overview.png
    ├── sales.png
    ├── customer.png
    ├── product_seller.png
    └── delivery_review.png
```

### Files

**`olist_sql_analysis.sql`**

Contains:

* Schema setup
* Data quality checks
* Data validation
* Sales analysis
* Customer analysis
* Product and seller analysis
* Delivery analysis
* Review analysis
* Business-question queries

**`olist_cleaning.ipynb`**

Python notebook containing:

* Loading raw CSV files
* Data understanding
* Data quality investigation
* Data cleaning
* Data transformation
* Feature preparation
* Export of cleaned datasets for Power BI

**`olist_ecommerce_dashboard.pbix`**

The complete interactive Power BI dashboard containing five analytical pages.

---

# 📊 Power BI Dashboard

The dashboard consists of **5 analytical pages**.

## 1. Overview

Provides a high-level view of business performance.

### Key metrics

* Total Revenue
* Total Orders
* Total Customers
* Average Review Score

### Analysis

* Monthly revenue trend
* Revenue by product category
* Revenue by Brazilian state

---

## 2. Sales & Financial Performance

Focuses on revenue and order performance over time.

### Analysis

* Monthly order volume
* Revenue trends
* Month-over-month growth
* Average Order Value (AOV)
* Revenue by payment method

---

## 3. Customer Analytics & Retention

Analyzes customer acquisition, purchasing behavior, and customer value.

### Analysis

* New customer acquisition
* Repeat vs. one-time customers
* Customer revenue contribution
* Customer spending tiers
* Customer value vs. customer volume by state

---

## 4. Product & Seller Performance

Identifies product categories and sellers contributing to marketplace revenue.

### Analysis

* Category revenue concentration
* Pareto analysis
* Top sellers by revenue
* Seller revenue vs. average review score

---

## 5. Delivery Logistics & Customer Satisfaction

Examines order fulfillment and the relationship between delivery performance and customer satisfaction.

### Analysis

* Order fulfillment time
* Processing time
* Shipping time
* Delivery time
* Review score distribution
* Delivery timeliness vs. review score

---

# 🔍 Key Data Quality Findings

An important part of this project was identifying and addressing data quality issues before performing business analysis.

### 1. Customer ID vs. Customer Unique ID

The Olist dataset contains both `customer_id` and `customer_unique_id`.

`customer_id` is associated with an order/address record and is **not suitable as the primary identifier for customer-level analysis**.

Therefore, customer-level aggregations use:

```text
customer_unique_id
```

This prevents the same customer from being treated as multiple customers when they place orders from different addresses.

---

### 2. Missing Delivery Dates

A small number of orders marked as `delivered` do not contain a delivery date.

These records were investigated individually by tracing the relevant order across items, payments, and reviews.

They were excluded from delivery-time calculations where the required date information was unavailable.

---

### 3. Revenue Calculation

Revenue calculations are restricted to **delivered orders**.

Payments associated with cancelled or in-progress orders are excluded from revenue analysis to maintain consistency between the SQL analysis and Power BI dashboard.

---

### 4. Customer Retention

The dataset is heavily dominated by one-time buyers.

Approximately **97% of customers do not place a second order** within the available dataset period.

Therefore, customer retention metrics should be interpreted within the limitations of the dataset's observation period.

---

### 5. Currency

All monetary values in the dataset are represented in:

**Brazilian Real (R$ / BRL)**

They are not converted to USD.

---

# 🔄 Data Preparation & Analysis Workflow

The project follows this workflow:

```text
Raw Olist Dataset
        ↓
Data Quality Investigation
        ↓
SQL Analysis
        ↓
Python Data Cleaning
        ↓
Cleaned CSV Tables
        ↓
Power BI Data Model
        ↓
DAX Measures
        ↓
Interactive Dashboard
        ↓
Business Insights
```

---

# 🚀 How to Reproduce the Project

## Step 1 — Download the Dataset

Download the **Brazilian E-Commerce Public Dataset by Olist** from Kaggle.

The dataset contains approximately 99K orders along with information about customers, products, sellers, payments, reviews, and order status.

---

## Step 2 — Run the Python Cleaning Notebook

Open:

```text
olist_cleaning.ipynb
```

The notebook can be executed in **Google Colab** or locally using Jupyter Notebook.

The notebook:

1. Loads the raw CSV files
2. Inspects the dataset structure
3. Checks missing values and duplicates
4. Investigates data quality issues
5. Cleans and transforms the data
6. Creates analytical fields
7. Exports cleaned tables for Power BI

---

## Step 3 — Run the SQL Analysis

Open:

```text
olist_sql_analysis.sql
```

Run the SQL script in a PostgreSQL-compatible environment.

The SQL analysis includes:

* Data quality checks
* Customer analysis
* Sales analysis
* Product analysis
* Seller analysis
* Delivery analysis
* Review analysis
* Business questions

---

## Step 4 — Open the Power BI Dashboard

Open:

```text
olist_ecommerce_dashboard.pbix
```

in **Power BI Desktop**.

Update the data source paths to point to the cleaned CSV files generated by the Python notebook.

---

## Step 5 — Refresh the Data Model

After connecting the cleaned CSV files:

1. Open **Power Query**
2. Verify the file paths
3. Confirm the required tables are loaded
4. Apply any pending transformations
5. Close & Apply
6. Refresh the Power BI model

The dashboard should then populate with the cleaned data.

---

# 📈 Key Business Insights

The analysis highlights several important characteristics of the Olist marketplace:

* Revenue is concentrated across a relatively small number of product categories.
* A small proportion of sellers contribute a significant share of marketplace revenue.
* The customer base is dominated by one-time purchasers.
* Customer value varies considerably across Brazilian states.
* Delivery performance provides useful context when analyzing customer reviews.
* Payment behavior varies across customers and orders.
* Revenue trends show changes in marketplace activity across the observed period.

> **Note:** These insights are based on the available Olist dataset and its observation period and should not automatically be interpreted as representative of Olist's current business performance.

---

# 📁 Dataset

**Dataset:** Brazilian E-Commerce Public Dataset by Olist

**Source:** Kaggle

The raw dataset is not included in this repository. Users should download the dataset separately and follow the data preparation steps above.

---

# 👩‍💻 Project Author

**Nithiyasree**

Data Analytics Project

**Skills demonstrated:**

`SQL` · `Python` · `Pandas` · `Power BI` · `DAX` · `Data Cleaning` · `Data Analysis` · `Data Visualization`

---

## ⭐ Project Highlights

This project demonstrates an end-to-end analytics workflow:

**Raw Data → Data Quality → SQL → Python → Data Modeling → DAX → Power BI → Business Insights**
