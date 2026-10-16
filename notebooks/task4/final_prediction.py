"""
TASK 4 — FINAL CHURN PREDICTIONS
"""

from pathlib import Path

import joblib
import pandas as pd


PROJECT_DIR = Path(__file__).resolve().parents[2]
INPUT_DIR = PROJECT_DIR / "output" / "task4"


THRESHOLD = 0.30


# LOAD MODEL AND TEST DATA

model = joblib.load(
    INPUT_DIR / "logistic_regression_model.pkl"
)

X_test = joblib.load(
    INPUT_DIR / "X_test_processed.pkl"
)

test_ids = pd.read_csv(
    INPUT_DIR / "test_ids.csv"
)


# GENERATE PREDICTIONS

churn_probability = model.predict_proba(
    X_test
)[:, 1]

predicted_churn = (
    churn_probability >= THRESHOLD
).astype(int)



# CREATE FINAL PREDICTION DATASET

final_predictions = test_ids.copy()

final_predictions["churn_probability"] = churn_probability
final_predictions["predicted_churn"] = predicted_churn


# SAVE ALL PREDICTIONS

final_predictions.to_csv(
    INPUT_DIR / "final_churn_predictions.csv",
    index=False
)


# SAVE HIGH-RISK PLAYERS

high_risk_players = final_predictions[
    final_predictions["predicted_churn"] == 1
].copy()

high_risk_players = high_risk_players.sort_values(
    "churn_probability",
    ascending=False
)

high_risk_players.to_csv(
    INPUT_DIR / "high_risk_churn_players.csv",
    index=False
)


# SUMMARY

print("=" * 55)
print("TASK 4 — FINAL CHURN PREDICTIONS")
print("=" * 55)

print("\nFinal threshold:", THRESHOLD)

print(
    "\nTotal test observations:",
    len(final_predictions)
)

print(
    "Predicted churn observations:",
    len(high_risk_players)
)

print(
    "Predicted non-churn observations:",
    int(
        (final_predictions["predicted_churn"] == 0).sum()
    )
)

print(
    "\nPredicted churn percentage:",
    round(
        100 * len(high_risk_players) / len(final_predictions),
        2
    ),
    "%"
)

print("\nSaved:")
print(
    INPUT_DIR / "final_churn_predictions.csv"
)

print(
    INPUT_DIR / "high_risk_churn_players.csv"
)

print("\nFINAL PREDICTIONS COMPLETED")