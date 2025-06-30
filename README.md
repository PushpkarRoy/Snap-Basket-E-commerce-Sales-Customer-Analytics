<h1 align="center">🛒 Snap Basket – E-Commerce SQL Analytics Project</h1>
<p align="center">
  <b>Data Analyst | SQL Expert | Business Problem Solver</b><br>
  <img src="https://img.shields.io/badge/Tool-PostgreSQL-informational?style=flat&logo=postgresql&color=336791" />
  <img src="https://img.shields.io/badge/Project-Level-Advanced-success" />
  <img src="https://img.shields.io/badge/Queries-50+-brightgreen" />
  <img src="https://img.shields.io/badge/Domain-E--Commerce-blueviolet" />
</p>

---

## 📌 Project Overview

**Snap Basket** is a simulated e-commerce SQL project that mirrors a real-world online store environment. This project includes **5 relational tables**, over **1,000+ rows**, and delivers **50+ business-focused SQL queries** that uncover insights across sales, customer behavior, product performance, returns, reviews, and more.

Built from scratch, this project is not just a collection of SQL questions — it's a fully structured data analysis workflow reflecting the role of a **Data Analyst in an actual company**.

---

## 🧠 What You'll Learn

- Advanced **SQL Querying Techniques** (Window Functions, Subqueries, JOINS, Aggregates)
- Building **customer segmentation** and **order funnel analysis**
- Calculating custom **Product Performance Score**
- Uncovering **returns, delivery failures**, and **customer churn**
- Revenue forecasting, category trends, discount impact, and more

---

## 📊 Schema Diagram

customers ─┬─ orders ─┬─ order_items ─┬─ products
│ │ └─ reviews
│ └─────────────────┘
└────────────────────────────┘


---

## 📁 Project Structure

| File/Folder       | Description |
|-------------------|-------------|
| `snap_basket.sql` | All 50+ SQL queries, organized by business use case |
| `snap_basket_schema.png` | Visual ERD of database relationships |
| `snap_basket_summary.pdf` | Executive summary of insights |
| `snap_basket_ppt.pptx` | Presentation-ready slides |
| `README.md` | You're reading it! |

---

## 🔍 Key Business Insights

- 💰 **Total Revenue Generated:** ₹69.13M  
- 📦 **Top 3 Products:** Accounted for over **21%** of sales  
- 🔁 **Return Rate vs. Delivered:** 24.87% vs. 25.47%  
- 📊 **Revenue Leaderboard:** Electronics tops with ₹13.3M  
- ⭐ **Customer Favorites:** Products with avg. ratings > 4.5 & below average sales = *hidden gems*  
- 🧠 **Custom KPI:** `Performance Score = Avg Rating × Quantity Sold × Revenue`

---

## 🚀 Features Covered

| Topic | Covered? |
|-------|----------|
| `SELECT`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, `LIMIT` | ✅ |
| `JOINS` (INNER, LEFT, FULL) | ✅ |
| Aggregate Functions (`SUM`, `COUNT`, `AVG`, `MAX`, `MIN`) | ✅ |
| Window Functions (`RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`, `CUME_DIST()`) | ✅ |
| Subqueries & CTEs | ✅ |
| Business KPIs (Revenue, LTV, Returns) | ✅ |
| Customer & Product Segmentation | ✅ |
| Monthly/Hourly Trends & Forecasting | ✅ |

---

---

## 👨‍💻 About Me

Hi, I'm **Pushpkar Roy** — a highly motivated and detail-oriented **Data Analyst** passionate about turning raw data into actionable business decisions. With hands-on experience in **SQL**, **Power BI**, **Excel**, and **Python**, I specialize in solving real-world business problems through structured thinking and clean analytics.

- 💡 Always curious to uncover patterns hidden in data  
- 📈 Focused on delivering measurable impact through insights  
- 🛠️ Skilled in writing complex queries, visualizing dashboards, and data storytelling  
- 🌱 Currently deep-diving into BI tools and advanced SQL optimization  
- 🎯 Career Goal: Use data to drive smarter decisions and scalable business solutions

📬 **Let’s Connect!**  
🔗 [LinkedIn](https://www.linkedin.com/in/pushpkar-roy)  
💻 [GitHub](https://github.com/PushpkarRoy)  
📧 **Email:** Pushpkarroy880@gmail.com

---


## 📈 Visual Sample: Monthly Revenue Trend

```sql
SELECT 
  TO_CHAR(order_date, 'Month') AS month_name,
  ROUND(SUM(ot.item_total)::NUMERIC, 2) AS monthly_revenue,
  RANK() OVER(ORDER BY SUM(ot.item_total) DESC) AS rank
FROM orders o
JOIN order_items ot ON o.order_id = ot.order_id
GROUP BY month_name;




---



