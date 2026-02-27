## Power BI Dashboard Design – MRO Inventory Health

### 1. Overview

This document outlines the design of the Power BI report pages, visuals, and key metrics for the MRO Inventory Health Dashboard.

### 2. Data Model Highlights

- **Fact Table**: `FactInventory`
  - Measures: Stock Level, Reorder Point, Last Restock Date.
- **Dimensions**:
  - `DimBranch`: Branch attributes (name, region).
  - `DimPart`: Part attributes (description, category, unit cost).
  - `DimDate`: Calendar attributes.
- **View / Enriched Data**:
  - `vw_DaysInventoryOnHand` – Days of Inventory on Hand.
  - `inventory_with_stockout_risk.csv` – includes `Stockout_Risk_Prob` scores.

### 3. Report Pages

#### 3.1. Page 1 – Executive Overview

- **Purpose**: Provide leadership with a quick view of overall inventory health.
- **Key Visuals**:
  - Cards:
    - Total Stock Value
    - Out of Stock %
    - Average Days of Inventory on Hand
  - Bar / Column Chart:
    - Total Stock Value by Branch
  - Clustered Column + Line Chart:
    - Out of Stock % by Branch, with line for Average DOH.
  - Slicer:
    - Region, Branch, Part Category, Date.

#### 3.2. Page 2 – Branch Inventory Detail

- **Purpose**: Help branch managers identify and resolve local issues.
- **Key Visuals**:
  - Matrix:
    - Rows: Part Number, Part Description
    - Columns: Stock Level, Reorder Point, DOH, Stockout Risk Probability, Last Restock Date.
  - Conditional Formatting:
    - Red font/background for Stock Level = 0.
    - Red for DOH <= 7 (high risk).
    - Amber for DOH between 7 and 30.
    - Green for DOH between 30 and 60.
    - Blue for DOH > 60 (potential overstock).
  - Bar Chart:
    - Count of High-Risk Items by Category.

#### 3.3. Page 3 – Part-Level Analysis

- **Purpose**: Give supply chain analysts a cross-branch view for each part.
- **Key Visuals**:
  - Table:
    - Columns: Part Number, Part Description, Category, Branch Name, Stock Level, DOH, Stockout Risk Probability, Unit Cost, Total Stock Value.
  - Scatter Plot:
    - X-axis: Days of Inventory on Hand
    - Y-axis: Stockout Risk Probability
    - Size: Total Stock Value
    - Color: Category
  - Slicers:
    - Part Category, Branch, Risk Level band.

### 4. Key DAX Measures (Summary)

- `Total Stock Value`
- `Out of Stock Count`
- `Out of Stock %`
- `Average Days of Inventory on Hand`
- **Optional**:
  - `High Risk Count` (DOH <= 7 or Risk_Prob > threshold).
  - `Overstock Count` (DOH > 60).

### 5. Row-Level Security (RLS)

- **Branch_Manager** role:
  - Filter on `DimBranch[Branch_ID]` = USERPRINCIPALNAME() mapping table, or dedicated security table mapping login to branch.
- **Regional_Manager** role:
  - Filter on `DimBranch[Region]` in a security mapping table.
- **Corporate** role:
  - No additional filters (full visibility).

RLS rules are configured in Power BI Desktop under **Modeling → Manage roles** and documented so they align with governance requirements.

