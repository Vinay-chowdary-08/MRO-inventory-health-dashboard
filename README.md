## Supply Chain Inventory Health Dashboard (MRO)

This project simulates an MRO (Maintenance, Repair, and Operations) inventory environment and provides:

- **Synthetic inventory data** via a Python script.
- **Relational schema and view** (SQL) for a star-schema warehouse.
- **Guidance for Power BI** data model and DAX measures for monitoring stock levels, stock value, and inventory health.

---

## 1. Repository Contents

- **`generate_inventory_data.py`**: Python script that generates `inventory_data.csv`.
- **`stockout_risk_model.py`**: Python script that trains a simple predictive model for 7‑day stockout risk and outputs `inventory_with_stockout_risk.csv`.
- **`schema.sql`**: SQL script that creates the star-schema tables and a view for Days of Inventory on Hand.
- **`data_quality_checks.sql`**: SQL script with examples of data integrity and validation queries.
- **`docs_business_requirements.md`**: Business requirements document simulating stakeholder collaboration and problem definition.
- **`docs_scope_of_work.md`**: Scope of Work describing in‑scope deliverables and phases.
- **`docs_powerbi_dashboard_design.md`**: Design document for Power BI pages, visuals, and RLS.
- **`requirements.txt`**: Python dependencies for data generation and modeling.

---

## 2. Generating Synthetic Inventory Data

### 2.1. Environment Setup

- **Python version**: 3.9+ recommended.
- Install dependencies:

```bash
pip install -r requirements.txt
```

### 2.2. Running the Generator

From the project root, run:

```bash
python generate_inventory_data.py
```

This creates an **`inventory_data.csv`** file with the following columns:

- **`Branch_ID`**: Branch identifier (e.g., `B001`).
- **`Part_Number`**: Part identifier (e.g., `P00001`).
- **`Stock_Level`**: Current on-hand quantity.
- **`Reorder_Point`**: Threshold at which replenishment is triggered.
- **`Last_Restock_Date`**: Date of last replenishment (within the last ~6 months).
- **`Unit_Cost`**: Unit cost of the part to support stock value calculations.

You can customize the size of the dataset by editing the default arguments in `generate_inventory_data.py` (e.g., `num_branches`, `parts_per_branch`, `output_path`).

---

## 3. Data Model – Star Schema

The analytical model is designed as a **star schema**, centered around a single fact table (`FactInventory`) with supporting dimensions.

### 3.1. Dimension Tables

- **`DimBranch`**
  - **Grain**: One row per physical branch.
  - **Key**: `Branch_ID`.
  - **Attributes**:
    - `Branch_ID`: Unique ID, matches `Branch_ID` in the CSV.
    - `Branch_Name`: Human-readable branch name (e.g., "Hyderabad Branch 1").
    - `Region`: Optional region/zone (e.g., "South", "West").

- **`DimPart`**
  - **Grain**: One row per MRO part.
  - **Key**: `Part_Number`.
  - **Attributes**:
    - `Part_Number`: Unique ID, matches `Part_Number` in the CSV.
    - `Part_Description`: Description (e.g., "Bearing 6203-2RS").
    - `Category`: Category or family (e.g., "Bearings", "Electrical").
    - `Unit_Cost`: Base unit cost for valuation.

- **`DimDate`**
  - **Grain**: One row per calendar date.
  - **Key**: `Date_Key` (DATE).
  - **Attributes**:
    - `Calendar_Year`, `Calendar_Month`, `Calendar_Day`
    - `Month_Name`, `Quarter`
  - **Usage**: Connected to snapshot dates in the fact table for time-based analysis (trend of stock levels, DOH over time, etc.).

### 3.2. Fact Table – `FactInventory`

- **Grain**: One row per **Branch–Part–Snapshot Date**.
- **Keys**:
  - `Branch_ID` → `DimBranch[Branch_ID]`
  - `Part_Number` → `DimPart[Part_Number]`
  - `Snapshot_Date_Key` → `DimDate[Date_Key]`
- **Measures/Columns**:
  - `Stock_Level`: Current on-hand quantity.
  - `Reorder_Point`: Target reorder level.
  - `Last_Restock_Date`: Date when the item was last replenished.

The sample CSV (`inventory_data.csv`) maps naturally into this model:

- Load **`Branch_ID`** into `DimBranch` (unique list of branches).
- Load **`Part_Number`** and **`Unit_Cost`** into `DimPart`.
- Choose a **snapshot date** (e.g., "as-of" date of the file) and load each row as a record in `FactInventory` with:
  - `Snapshot_Date_Key`: chosen snapshot date.
  - `Stock_Level`, `Reorder_Point`, `Last_Restock_Date`.

---

## 4. SQL Objects

### 4.1. Creating the Schema

Run the contents of **`schema.sql`** in your database (PostgreSQL/SQL Server/other relational engine, adjusting syntax if needed).

It creates:

- **Dimension tables**: `DimBranch`, `DimPart`, `DimDate`
- **Fact table**: `FactInventory`
- **View**: `vw_DaysInventoryOnHand`

### 4.2. Days of Inventory on Hand View

`vw_DaysInventoryOnHand` implements a simplified rule:

- **Assumption**: `Reorder_Point` approximates the expected demand over **30 days**.
- **Formula**:
  - \[
    \text{Days of Inventory on Hand} =
    \left(\frac{\text{Stock\_Level}}{\text{Reorder\_Point}}\right) \times 30
    \]

The view exposes:

- `Branch_ID`, `Part_Number`, `Snapshot_Date_Key`
- `Stock_Level`, `Reorder_Point`, `Last_Restock_Date`
- `Days_Inventory_On_Hand`

You can import this view directly into Power BI as a table named, for example, **`Inventory DOH`**.

---

## 5. Power BI Data Model

### 5.1. Tables to Import

From your database:

- **`DimBranch`**
- **`DimPart`**
- **`DimDate`**
- **`FactInventory`**
- **`vw_DaysInventoryOnHand`** (optional but recommended for DOH visuals)

From the CSV (if staging directly in Power BI instead of the DB):

- Import `inventory_data.csv` into a table, then:
  - Create dimension tables using **Reference** queries (for `DimBranch`, `DimPart`).
  - Add a **Calendar** table (for `DimDate`) using DAX or Power Query.
  - Treat the original CSV table as the **fact** equivalent of `FactInventory`.

### 5.2. Relationships

In Power BI Model view, create these relationships:

- `DimBranch[Branch_ID]` 1 — * `FactInventory[Branch_ID]`
- `DimPart[Part_Number]` 1 — * `FactInventory[Part_Number]`
- `DimDate[Date_Key]` 1 — * `FactInventory[Snapshot_Date_Key]`

If you import `vw_DaysInventoryOnHand`:

- Link `vw_DaysInventoryOnHand[Inventory_ID]` to `FactInventory[Inventory_ID]` **or**
- Link `vw_DaysInventoryOnHand[Branch_ID]`, `[Part_Number]`, and `[Snapshot_Date_Key]` to the respective dimensions/fact columns (depending on how you model it).

---

## 6. Key DAX Measures

Below are example DAX measures that you can define in Power BI (typically in the `FactInventory` table or a dedicated Measures table).

### 6.1. Total Stock Value

Assuming `FactInventory` holds `Stock_Level` and `DimPart` holds `Unit_Cost`:

```DAX
Total Stock Value :=
SUMX (
    FactInventory,
    FactInventory[Stock_Level] * RELATED ( DimPart[Unit_Cost] )
)
```

This computes the aggregated **monetary value** of inventory for any filter context (branch, part category, date, etc.).

### 6.2. Out of Stock Count

```DAX
Out of Stock Count :=
COUNTROWS (
    FILTER (
        FactInventory,
        FactInventory[Stock_Level] = 0
    )
)
```

### 6.3. Out of Stock %

```DAX
Out of Stock % :=
DIVIDE (
    [Out of Stock Count],
    COUNTROWS ( FactInventory )
)
```

This returns the **percentage of Branch–Part combinations** that are currently out of stock in the selected context.

### 6.4. Average Days of Inventory on Hand

If you import `vw_DaysInventoryOnHand` as a table named `Inventory DOH`:

```DAX
Average Days of Inventory on Hand :=
AVERAGE ( 'Inventory DOH'[Days_Inventory_On_Hand] )
```

Alternatively, if you add `Days_Inventory_On_Hand` as a calculated column in `FactInventory`, the measure can reference that column directly.

---

## 7. Example Use Cases in Power BI

- **Branch Inventory Health Overview**
  - Visuals:
    - Card: **Total Stock Value**
    - Card: **Out of Stock %**
    - Bar chart: Total Stock Value by `Branch_Name`
    - Matrix: `Branch_Name` × `Category` with `Stock_Level` and `Days_Inventory_On_Hand`.

- **Part-Level Analysis**
  - Table visual with:
    - `Part_Number`, `Part_Description`, `Stock_Level`, `Reorder_Point`,
      `Days_Inventory_On_Hand`, and `Total Stock Value`.
  - Conditional formatting to highlight:
    - **Stockouts** (`Stock_Level = 0`).
    - **Overstock** (`Days_Inventory_On_Hand` greater than a threshold, e.g., 60 days).

This structure gives you a solid base for monitoring **stockouts**, **overstock**, and overall **inventory health** across branches using **Power BI + SQL + Python**.

