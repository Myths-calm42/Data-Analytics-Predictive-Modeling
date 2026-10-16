"""
TASK 4 STEP 6 & 7
Time-based split and model data preparation.
"""

from pathlib import Path
import pandas as pd

PROJECT_DIR = Path(__file__).resolve().parents[2]
INPUT_FILE = PROJECT_DIR / "output" / "task4" / "task4_final_ml_dataset.csv"
OUTPUT_DIR = PROJECT_DIR / "output" / "task4"

df = pd.read_csv(INPUT_FILE)

df["prediction_date"] = pd.to_datetime(df["prediction_date"])


# STEP 6 — TIME-BASED SPLIT

train = df[
    (df["prediction_date"] >= "2026-02-01") &
    (df["prediction_date"] <= "2026-03-15")
].copy()

validation = df[
    (df["prediction_date"] >= "2026-03-16") &
    (df["prediction_date"] <= "2026-03-31")
].copy()

test = df[
    (df["prediction_date"] >= "2026-04-01") &
    (df["prediction_date"] <= "2026-04-16")
].copy()

train.to_csv(OUTPUT_DIR / "task4_train.csv", index=False)
validation.to_csv(OUTPUT_DIR / "task4_validation.csv", index=False)
test.to_csv(OUTPUT_DIR / "task4_test.csv", index=False)


# STEP 7 — SEPARATE IDs, FEATURES AND TARGET

TARGET = "churn_14d"

ID_COLUMNS = [
    "device_id",
    "prediction_date"
]

NON_FEATURE_COLUMNS = [
    "device_id",
    "prediction_date",
    "install_date",
    "last_activity_date",
    "last_purchase_date"
]

# Keep identifiers separately
train_ids = train[ID_COLUMNS].copy()
validation_ids = validation[ID_COLUMNS].copy()
test_ids = test[ID_COLUMNS].copy()

# Separate target
y_train = train[TARGET].copy()
y_validation = validation[TARGET].copy()
y_test = test[TARGET].copy()

# Create model features
X_train = train.drop(
    columns=NON_FEATURE_COLUMNS + [TARGET]
)

X_validation = validation.drop(
    columns=NON_FEATURE_COLUMNS + [TARGET]
)

X_test = test.drop(
    columns=NON_FEATURE_COLUMNS + [TARGET]
)

# Save IDs
train_ids.to_csv(
    OUTPUT_DIR / "train_ids.csv",
    index=False
)

validation_ids.to_csv(
    OUTPUT_DIR / "validation_ids.csv",
    index=False
)

test_ids.to_csv(
    OUTPUT_DIR / "test_ids.csv",
    index=False
)

# Save X and y
X_train.to_csv(
    OUTPUT_DIR / "X_train.csv",
    index=False
)

y_train.to_csv(
    OUTPUT_DIR / "y_train.csv",
    index=False
)

X_validation.to_csv(
    OUTPUT_DIR / "X_validation.csv",
    index=False
)

y_validation.to_csv(
    OUTPUT_DIR / "y_validation.csv",
    index=False
)

X_test.to_csv(
    OUTPUT_DIR / "X_test.csv",
    index=False
)

y_test.to_csv(
    OUTPUT_DIR / "y_test.csv",
    index=False
)

# OUTPUT

print("=" * 50)
print("TASK 4 STEP 6 & 7 COMPLETED")
print("=" * 50)

print("\nTIME-BASED SPLIT")

print("\nTrain:")
print("Rows:", len(train))
print("Dates:", train["prediction_date"].min().date(),
      "to", train["prediction_date"].max().date())
print("Churn rate:", round(train[TARGET].mean() * 100, 2), "%")

print("\nValidation:")
print("Rows:", len(validation))
print("Dates:", validation["prediction_date"].min().date(),
      "to", validation["prediction_date"].max().date())
print("Churn rate:", round(validation[TARGET].mean() * 100, 2), "%")

print("\nTest:")
print("Rows:", len(test))
print("Dates:", test["prediction_date"].min().date(),
      "to", test["prediction_date"].max().date())
print("Churn rate:", round(test[TARGET].mean() * 100, 2), "%")

print("\nMODEL DATA")

print("X_train:", X_train.shape)
print("y_train:", y_train.shape)

print("X_validation:", X_validation.shape)
print("y_validation:", y_validation.shape)

print("X_test:", X_test.shape)
print("y_test:", y_test.shape)

print("\nIDENTIFIERS KEPT SEPARATELY")

print("train_ids:", train_ids.shape)
print("validation_ids:", validation_ids.shape)
print("test_ids:", test_ids.shape)

print("\nModel features:")
print(X_train.columns.tolist())

print("\nOutput folder:")
print(OUTPUT_DIR)