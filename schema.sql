-- Schema for MRO Inventory Health Dashboard

-- Drop objects if they already exist (optional, depends on your RDBMS)
-- Adjust DROP syntax for your specific database engine if needed.

-- DIMENSION TABLES

CREATE TABLE DimBranch (
    Branch_ID        VARCHAR(10)  NOT NULL PRIMARY KEY,
    Branch_Name      VARCHAR(100) NOT NULL,
    Region           VARCHAR(50)  NULL
);

CREATE TABLE DimPart (
    Part_Number      VARCHAR(20)  NOT NULL PRIMARY KEY,
    Part_Description VARCHAR(255) NULL,
    Category         VARCHAR(50)  NULL,
    Unit_Cost        DECIMAL(18, 2) NOT NULL
);

CREATE TABLE DimDate (
    Date_Key   DATE         NOT NULL PRIMARY KEY,
    Calendar_Year INT       NOT NULL,
    Calendar_Month INT      NOT NULL,
    Calendar_Day   INT      NOT NULL,
    Month_Name     VARCHAR(20) NOT NULL,
    Quarter        VARCHAR(6)  NOT NULL
);


-- FACT TABLE
-- Grain: One row per Branch, Part, and Snapshot Date

CREATE TABLE FactInventory (
    Inventory_ID      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Branch_ID         VARCHAR(10)  NOT NULL,
    Part_Number       VARCHAR(20)  NOT NULL,
    Snapshot_Date_Key DATE         NOT NULL,
    Stock_Level       INT          NOT NULL,
    Reorder_Point     INT          NOT NULL,
    Last_Restock_Date DATE         NULL,

    CONSTRAINT FK_FactInventory_Branch
        FOREIGN KEY (Branch_ID) REFERENCES DimBranch (Branch_ID),

    CONSTRAINT FK_FactInventory_Part
        FOREIGN KEY (Part_Number) REFERENCES DimPart (Part_Number),

    CONSTRAINT FK_FactInventory_Date
        FOREIGN KEY (Snapshot_Date_Key) REFERENCES DimDate (Date_Key)
);


-- VIEW: Days of Inventory on Hand
-- Business rule (simplified for demo):
--   Assume Reorder_Point represents the expected 30 days of demand.
--   Days of Inventory on Hand = (Stock_Level / Reorder_Point) * 30

CREATE VIEW vw_DaysInventoryOnHand AS
SELECT
    f.Inventory_ID,
    f.Branch_ID,
    f.Part_Number,
    f.Snapshot_Date_Key,
    f.Stock_Level,
    f.Reorder_Point,
    f.Last_Restock_Date,
    CASE
        WHEN f.Reorder_Point > 0 THEN
            ROUND(
                (CAST(f.Stock_Level AS DECIMAL(18, 4))
                 / CAST(f.Reorder_Point AS DECIMAL(18, 4))) * 30,
                1
            )
        ELSE NULL
    END AS Days_Inventory_On_Hand
FROM FactInventory f;

