# E-Commerce Sales & Customer Analytics Dashboard

<!-- This is a comment -->
**Tools:** MySQL | Python | Pandas | <!--Streamlit --> | Data Visualization

## Project Overview

This project focuses on analyzing Brazilian e-commerce data to understand sales performance, customer purchasing behavior, revenue trends, and customer retention.

Using the Olist E-Commerce Dataset, the project combines SQL-based data analysis with Python to extract meaningful business insights and support data-driven decision-making.

## Dataset

The project uses the Brazilian E-Commerce Public Dataset by Olist.

The dataset contains multiple interconnected tables, including:

- Customers
- Orders
- Order Items
- Order Payments
- Order Reviews
- Products
- Sellers
- Geolocation
- Product Category Translation

## Key Analysis Performed

### 1. Sales Performance Analysis
- Monthly and yearly revenue trends.
- Total orders and sales performance.
- Month-over-month revenue growth.
- Analysis of sales performance during Black Friday 2017.

### 2. Seller Performance Analysis
- Seller-wise revenue contribution.
- Seller ranking based on revenue.
- Cumulative revenue contribution.
- Analysis of seller performance and customer reviews.

### 3. Customer Analytics
- Customer purchasing frequency.
- Identification of repeat and one-time customers.
- RFM (Recency, Frequency, Monetary) analysis.
- Customer segmentation based on purchasing behavior.

### 4. Cohort Retention Analysis
- Identification of customers based on their first purchase month.
- Tracking subsequent purchases across different months.
- Calculation of monthly customer retention rates.
- Analysis of customer purchasing and retention patterns.

## Technical Skills Demonstrated

**SQL / MySQL**
- Multi-table joins
- Aggregate functions
- Common Table Expressions (CTEs)
- Window functions
- Ranking functions
- Date and time functions
- Conditional aggregation
- Customer segmentation
- Cohort analysis

<!--
**Python**
- Data manipulation using Pandas
- Data processing and analysis
- Database connectivity using SQLAlchemy

**Visualization**
- Interactive dashboard development using Streamlit
- Business KPI visualization
- Sales and customer analytics

## Project Structure

```text
olist/
│
├── dataset/
│
├── sql/
│   ├── sales_analysis.sql
│   ├── seller_analysis.sql
│   ├── rfm_analysis.sql
│   └── cohort_retention.sql
│
├── app.py
├── requirements.txt
├── README.md
└── .gitignore
```

*Modify the folder structure above to match your actual repository.*
-->
## Business Objectives

The project aims to answer important business questions:

1. How does revenue change over time?
2. Which sellers contribute the most to overall revenue?
3. Who are the most valuable customers?
4. How frequently do customers make repeat purchases?
5. What percentage of customers return after their first purchase?
6. Which customer segments require better retention strategies?

## Future Enhancements

- Develop an interactive Streamlit dashboard.
- Visualize customer segments using RFM scores.
- Create cohort retention heatmaps.
- Integrate SQL queries with Python for automated reporting.
- Develop actionable recommendations for improving customer retention.

## Author

**Atul Singh**

M.Tech  
MNIT Jaipur

- GitHub: https://github.com/iatuls
- LinkedIn: https://www.linkedin.com/in/atul-singh2

---
