"""
TASK 4 STEP 5 — Build the final ML dataset.
"""

from pathlib import Path
import duckdb
import pandas as pd

# Paths
PROJECT_DIR = Path(__file__).resolve().parents[2]
SQL_DIR = PROJECT_DIR / "sql" / "task-4"
TABLE_DIR = PROJECT_DIR / "output" / "task4"
DB_PATH = PROJECT_DIR / "analysis.duckdb"

TABLE_DIR.mkdir(parents=True, exist_ok=True)

con = duckdb.connect(str(DB_PATH))

# Prediction dates
prediction_dates = con.execute(
    (SQL_DIR / "01_prediction_dates.sql").read_text()
).df()

# Churn labels
labels = con.execute(
    (SQL_DIR / "02_churn_label.sql").read_text()
).df()

# Features
features = con.execute(
    (SQL_DIR / "03_features.sql").read_text()
).df()

# Combine
con.register("task4_labels_df", labels)
con.register("task4_features_df", features)

final_ml = con.execute("""
    SELECT
        f.*,
        l.churn_14d
    FROM task4_features_df AS f
    JOIN task4_labels_df AS l
        ON l.device_id = f.device_id
       AND l.prediction_date = f.prediction_date
    ORDER BY f.prediction_date, f.device_id
""").df()

# Save
prediction_dates.to_csv(
    TABLE_DIR / "task4_prediction_dates.csv",
    index=False
)

labels.to_csv(
    TABLE_DIR / "task4_churn_labels.csv",
    index=False
)

features.to_csv(
    TABLE_DIR / "task4_features.csv",
    index=False
)

final_ml.to_csv(
    TABLE_DIR / "task4_final_ml_dataset.csv",
    index=False
)

print("=" * 50)
print("TASK 4 STEP 5 COMPLETED")
print("=" * 50)

print("Prediction dates:", len(prediction_dates))
print("Label rows:", len(labels))
print("Feature rows:", len(features))
print("Final ML rows:", len(final_ml))
print("Churn rate:", round(final_ml["churn_14d"].mean() * 100, 2), "%")

print("\nFinal columns:")
print(final_ml.columns.tolist())

print("\nOutput folder:")
print(TABLE_DIR)