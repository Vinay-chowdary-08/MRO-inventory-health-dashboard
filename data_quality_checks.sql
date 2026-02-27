-- Data Quality and Integrity Checks for MRO Inventory

-- 1. Check for negative stock levels (should not occur)
SELECT *
FROM FactInventory
WHERE Stock_Level < 0;

-- 2. Check for negative or zero reorder points
SELECT *
FROM FactInventory
WHERE Reorder_Point <= 0;

-- 3. Check for missing foreign keys (orphaned records)
SELECT f.*
FROM FactInventory f
LEFT JOIN DimBranch b ON f.Branch_ID = b.Branch_ID
WHERE b.Branch_ID IS NULL;

SELECT f.*
FROM FactInventory f
LEFT JOIN DimPart p ON f.Part_Number = p.Part_Number
WHERE p.Part_Number IS NULL;

SELECT f.*
FROM FactInventory f
LEFT JOIN DimDate d ON f.Snapshot_Date_Key = d.Date_Key
WHERE d.Date_Key IS NULL;

-- 4. Check for Last_Restock_Date in the future
SELECT *
FROM FactInventory
WHERE Last_Restock_Date > CURRENT_DATE;

-- 5. Basic volume checks (record counts by branch and part)
SELECT Branch_ID, COUNT(*) AS Inventory_Rows
FROM FactInventory
GROUP BY Branch_ID
ORDER BY Inventory_Rows DESC;

SELECT Part_Number, COUNT(*) AS Inventory_Rows
FROM FactInventory
GROUP BY Part_Number
ORDER BY Inventory_Rows DESC;

