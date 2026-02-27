import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report
from sklearn.model_selection import train_test_split


def prepare_features(df: pd.DataFrame) -> pd.DataFrame:
    """
    Create simple engineered features for stockout risk modeling.

    We approximate daily demand as Reorder_Point / 30 and compute
    an implied Days of Inventory on Hand (DOH). We then define a
    binary label for "at risk of stockout in <= 7 days".
    """
    df = df.copy()

    # Avoid division by zero
    df["Daily_Demand_Est"] = df["Reorder_Point"] / 30.0
    df["Daily_Demand_Est"] = df["Daily_Demand_Est"].replace(0, 1e-6)

    df["Days_Inventory_On_Hand"] = df["Stock_Level"] / df["Daily_Demand_Est"]

    # Binary target: 1 if DOH <= 7 days, else 0
    df["Stockout_Risk_7d"] = (df["Days_Inventory_On_Hand"] <= 7).astype(int)

    # Simple numeric features only (you could add more in a real project)
    feature_cols = ["Stock_Level", "Reorder_Point", "Unit_Cost", "Days_Inventory_On_Hand"]
    X = df[feature_cols]
    y = df["Stockout_Risk_7d"]

    return X, y


def train_and_evaluate_model(csv_path: str = "inventory_data.csv") -> None:
    """
    Train a basic logistic regression model to classify
    whether a Branch–Part combination is at risk of stockout
    within the next 7 days, based on current inventory levels.
    """
    df = pd.read_csv(csv_path)

    X, y = prepare_features(df)

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    model = LogisticRegression(max_iter=1000)
    model.fit(X_train, y_train)

    y_pred = model.predict(X_test)

    report = classification_report(y_test, y_pred, digits=3)
    print("Classification report for Stockout Risk (<= 7 days):")
    print(report)

    # Attach predicted probabilities back to the original data for use in BI tools
    df_probs = df.copy()
    df_probs["Stockout_Risk_Prob"] = model.predict_proba(X)[:, 1]
    df_probs.to_csv("inventory_with_stockout_risk.csv", index=False)
    print("Saved enriched data with stockout risk scores to 'inventory_with_stockout_risk.csv'.")


if __name__ == "__main__":
    train_and_evaluate_model()

