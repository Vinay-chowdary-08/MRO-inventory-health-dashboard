import random
from datetime import datetime, timedelta
from typing import List

import pandas as pd


def generate_inventory_data(
    num_branches: int = 5,
    parts_per_branch: int = 100,
    output_path: str = "inventory_data.csv",
) -> None:
    """
    Generate a synthetic MRO inventory dataset and write it to a CSV file.

    Columns:
        - Branch_ID: branch identifier (e.g., B001)
        - Part_Number: part identifier (e.g., P00001)
        - Stock_Level: current on-hand quantity
        - Reorder_Point: threshold at which replenishment is triggered
        - Last_Restock_Date: date of last replenishment
        - Unit_Cost: unit cost of the part (for stock value analysis)
    """

    branches: List[str] = [f"B{str(i).zfill(3)}" for i in range(1, num_branches + 1)]
    parts: List[str] = [f"P{str(i).zfill(5)}" for i in range(1, parts_per_branch + 1)]

    today = datetime.today()
    max_days_back = 180  # last restock within the last 6 months

    records = []
    for branch in branches:
        for part in parts:
            stock_level = random.randint(0, 500)

            # Ensure reorder point is positive but can be above or below current stock
            reorder_point = random.randint(20, 200)

            last_restock_date = today - timedelta(days=random.randint(0, max_days_back))

            # Unit cost to support Total Stock Value measure in Power BI
            unit_cost = round(random.uniform(5.0, 500.0), 2)

            records.append(
                {
                    "Branch_ID": branch,
                    "Part_Number": part,
                    "Stock_Level": stock_level,
                    "Reorder_Point": reorder_point,
                    "Last_Restock_Date": last_restock_date.date().isoformat(),
                    "Unit_Cost": unit_cost,
                }
            )

    df = pd.DataFrame(records)
    df.to_csv(output_path, index=False)


if __name__ == "__main__":
    generate_inventory_data()

