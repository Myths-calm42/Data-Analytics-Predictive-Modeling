"""
TASK 4 STEP 9 — Train Logistic Regression.
"""

from pathlib import Path
import joblib
import pandas as pd

from sklearn.linear_model import LogisticRegression


PROJECT_DIR = Path(__file__).resolve().parents[2]
INPUT_DIR = PROJECT_DIR / "output" / "task4"
OUTPUT_DIR = PROJECT_DIR / "output" / "task4"

# Load processed features
X_train = joblib.load(
    INPUT_DIR / "X_train_processed.pkl"
)

X_validation = joblib.load(
    INPUT_DIR / "X_validation_processed.pkl"
)

# Load targets
y_train = pd.read_csv(
    INPUT_DIR / "y_train.csv"
)["churn_14d"]

y_validation = pd.read_csv(
    INPUT_DIR / "y_validation.csv"
)["churn_14d"]

print("=" * 50)
print("TASK 4 STEP 9 — LOGISTIC REGRESSION")
print("=" * 50)

print("\nTraining data:")
print("X_train:", X_train.shape)
print("y_train:", y_train.shape)

print("\nValidation data:")
print("X_validation:", X_validation.shape)
print("y_validation:", y_validation.shape)

# Create model
model = LogisticRegression(
    solver="saga",
    max_iter=200,
    random_state=42,
    verbose=1
)

print("\nTraining Logistic Regression...")

# Train
model.fit(X_train, y_train)

print("Training completed.")

# Validation probabilities
validation_probabilities = model.predict_proba(
    X_validation
)[:, 1]

# Save model
joblib.dump(
    model,
    OUTPUT_DIR / "logistic_regression_model.pkl"
)

# Save validation probabilities
pd.DataFrame({
    "churn_probability": validation_probabilities,
    "actual_churn": y_validation.values
}).to_csv(
    OUTPUT_DIR / "validation_predictions.csv",
    index=False
)

print("\nModel saved:")
print(OUTPUT_DIR / "logistic_regression_model.pkl")

print("\nValidation predictions saved:")
print(OUTPUT_DIR / "validation_predictions.csv")

print("\nSTEP 9 COMPLETED")