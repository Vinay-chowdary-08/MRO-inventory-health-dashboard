## Scope of Work – MRO Inventory Health BI Solution

### 1. Project Overview

Design, build, and deploy a Power BI–based Inventory Health Dashboard for MRO parts across branches, supported by a SQL data model and Python-based data generation/modeling for demonstration.

### 2. In-Scope Work

- **Requirements & Design**
  - Conduct stakeholder workshops to refine business questions and KPIs.
  - Produce Business Requirements Document (BRD) and this Scope of Work (SoW).
  - Define data model (star schema) and data dictionary.

- **Data Engineering**
  - Create synthetic inventory data (`inventory_data.csv`) via Python.
  - Design and implement SQL schema (`schema.sql`) for:
    - `DimBranch`, `DimPart`, `DimDate`, `FactInventory`.
    - View `vw_DaysInventoryOnHand` for Days of Inventory on Hand.
  - Implement basic data quality checks (`data_quality_checks.sql`).

- **Analytics & Modeling**
  - Build descriptive and diagnostic metrics (e.g., Total Stock Value, Out of Stock %, DOH).
  - Develop a simple predictive model (`stockout_risk_model.py`) to estimate stockout risk (≤ 7 days).
  - Output enriched dataset (`inventory_with_stockout_risk.csv`) for use in Power BI.

- **BI Development**
  - Design Power BI data model (relationships, DAX measures).
  - Build at least three report pages:
    - Executive Overview
    - Branch Inventory Detail
    - Part-Level Analysis
  - Configure row-level security roles (branch-level and regional).

- **Deployment & Handover**
  - Document refresh process and data sources.
  - Provide user guide and training walkthrough (documentation).

### 3. Out of Scope

- Integration with live ERP systems (project uses synthetic data).
- Real-time or streaming data ingestion.
- Complex machine learning pipelines or MLOps (only a simple demo model is included).

### 4. Deliverables

- Python scripts:
  - `generate_inventory_data.py`
  - `stockout_risk_model.py`
- SQL scripts:
  - `schema.sql`
  - `data_quality_checks.sql`
- Documentation:
  - `docs_business_requirements.md`
  - `docs_scope_of_work.md`
  - README with Power BI data model and DAX.
- Power BI report (.pbix) built from the above (created in Power BI Desktop by the analyst).

