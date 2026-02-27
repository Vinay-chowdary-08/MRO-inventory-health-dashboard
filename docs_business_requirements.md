## Business Requirements – MRO Inventory Health Dashboard

### 1. Background and Stakeholders

- **Business Context**: The company operates multiple branches that stock MRO (Maintenance, Repair, and Operations) parts. Lack of visibility into inventory health leads to stockouts, overstock, and excess working capital tied up in slow-moving items.
- **Primary Stakeholders**:
  - **Supply Chain Manager** – wants to minimize stockouts and reduce excess inventory across branches.
  - **Branch Operations Managers** – want clear visibility on which parts are at risk of stockout and which are overstocked.
  - **Finance/FP&A** – wants accurate valuation of on-hand MRO inventory and visibility into trends.

### 2. Business Problems

1. **Stockouts** on critical parts cause production delays and emergency purchases.
2. **Overstock** ties up working capital and increases carrying costs.
3. **Manual reporting** via spreadsheets is time-consuming, inconsistent, and error-prone.
4. Limited ability to **prioritize actions** across branches and parts (which items to address first).

### 3. High-Level Objectives

- Provide a **centralized dashboard** that:
  - Highlights **stockouts** and **high stockout risk**.
  - Identifies **overstocked** items in terms of Days of Inventory on Hand.
  - Shows **Total Stock Value** by branch, part category, and over time.
- Reduce manual reporting by **automating data extraction and refresh**.
- Enable branch and supply chain leaders to **take corrective actions** based on data-driven insights.

### 4. Key Questions to Answer

- Which branch–part combinations are **currently out of stock**?
- Which items have **less than 7 days of inventory on hand** (high stockout risk)?
- Which items have **more than 60 or 90 days of inventory on hand** (overstock)?
- What is the **total stock value** by:
  - Branch
  - Part Category
  - Region
- How has **inventory health** (stockouts, DOH) changed over time?

### 5. Functional Requirements

- **FR1 – Inventory Health Overview**:
  - A Power BI dashboard page that shows:
    - Total Stock Value
    - Out of Stock %
    - Average Days of Inventory on Hand
    - Top N branches by stock value and by stockout risk.

- **FR2 – Branch Detail**:
  - Ability to drill down into a single branch to view:
    - List of parts with stockouts or high stockout risk.
    - List of parts with overstock (e.g., DOH > 60).

- **FR3 – Part Detail**:
  - Table of parts showing:
    - Current Stock Level, Reorder Point, DOH, Stockout Risk Probability.
    - Last Restock Date and Unit Cost.

- **FR4 – Data Refresh**:
  - Data is refreshed from the source tables or CSV on a **daily** basis.

- **FR5 – Role-Level Security**:
  - Branch managers can only see **their own branch**.
  - Regional and corporate users can see multiple branches as per their access level.

### 6. Non-Functional Requirements

- Dashboard should load in **< 10 seconds** for typical filters.
- Data model should be **documented** with definitions for each metric and field.
- Follow corporate standards for **data security and governance**.

