"""
TASK 4 — FINAL TEST-SET EVALUATION
"""

from pathlib import Path
import sys

import joblib
import pandas as pd
import matplotlib.pyplot as plt

from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    roc_auc_score,
    average_precision_score,
    confusion_matrix,
    classification_report,
    roc_curve,
    precision_recall_curve,
    ConfusionMatrixDisplay
)


PROJECT_DIR = Path(__file__).resolve().parents[2]
INPUT_DIR = PROJECT_DIR / "output" / "task4"
PLOT_DIR = INPUT_DIR / "final_test_plots"

PLOT_DIR.mkdir(parents=True, exist_ok=True)

RESULT_FILE = INPUT_DIR / "final_test_evaluation.txt"

THRESHOLD = 0.30


# SAVE TERMINAL OUTPUT


result_file = open(
    RESULT_FILE,
    "w",
    encoding="utf-8"
)


class Tee:
    def __init__(self, *files):
        self.files = files

    def write(self, text):
        for file in self.files:
            file.write(text)
            file.flush()

    def flush(self):
        for file in self.files:
            file.flush()


original_stdout = sys.stdout

sys.stdout = Tee(
    original_stdout,
    result_file
)


# LOAD MODEL AND TEST DATA

model = joblib.load(
    INPUT_DIR / "logistic_regression_model.pkl"
)

X_test = joblib.load(
    INPUT_DIR / "X_test_processed.pkl"
)

y_test = pd.read_csv(
    INPUT_DIR / "y_test.csv"
)["churn_14d"]


# TEST PREDICTIONS

test_probability = model.predict_proba(
    X_test
)[:, 1]

test_prediction = (
    test_probability >= THRESHOLD
).astype(int)

# METRICS

accuracy = accuracy_score(
    y_test,
    test_prediction
)

precision = precision_score(
    y_test,
    test_prediction,
    zero_division=0
)

recall = recall_score(
    y_test,
    test_prediction,
    zero_division=0
)

f1 = f1_score(
    y_test,
    test_prediction,
    zero_division=0
)

roc_auc = roc_auc_score(
    y_test,
    test_probability
)

pr_auc = average_precision_score(
    y_test,
    test_probability
)

cm = confusion_matrix(
    y_test,
    test_prediction
)


# PRINT RESULTS

print("=" * 55)
print("TASK 4 — FINAL TEST-SET EVALUATION")
print("=" * 55)

print("\nTest samples:", len(y_test))
print("Actual churn cases:", int(y_test.sum()))
print(
    "Actual non-churn cases:",
    int((y_test == 0).sum())
)

print("\nFinal threshold:", THRESHOLD)

print("\nMetrics")
print("-" * 30)

print("Accuracy :", round(accuracy, 4))
print("Precision:", round(precision, 4))
print("Recall   :", round(recall, 4))
print("F1-score :", round(f1, 4))
print("ROC-AUC  :", round(roc_auc, 4))
print("PR-AUC   :", round(pr_auc, 4))

print("\nConfusion Matrix")
print("-" * 30)
print(cm)

print("\nClassification Report")
print("-" * 30)

print(
    classification_report(
        y_test,
        test_prediction,
        target_names=[
            "Not Churn",
            "Churn"
        ],
        zero_division=0
    )
)


# CONFUSION MATRIX

fig, ax = plt.subplots(figsize=(6, 5))

ConfusionMatrixDisplay(
    confusion_matrix=cm,
    display_labels=[
        "Not Churn",
        "Churn"
    ]
).plot(
    ax=ax,
    values_format="d"
)

ax.set_title(
    "Confusion Matrix — Final Test Set"
)

plt.tight_layout()

plt.savefig(
    PLOT_DIR / "confusion_matrix.png",
    dpi=300,
    bbox_inches="tight"
)

plt.close()


# ROC CURVE

fpr, tpr, _ = roc_curve(
    y_test,
    test_probability
)

plt.figure(figsize=(7, 6))

plt.plot(
    fpr,
    tpr,
    label=f"Logistic Regression (AUC = {roc_auc:.3f})"
)

plt.plot(
    [0, 1],
    [0, 1],
    linestyle="--",
    label="Random classifier"
)

plt.xlabel("False Positive Rate")
plt.ylabel("True Positive Rate")
plt.title("ROC Curve — Final Test Set")
plt.legend()

plt.tight_layout()

plt.savefig(
    PLOT_DIR / "roc_curve.png",
    dpi=300,
    bbox_inches="tight"
)

plt.close()

# PRECISION-RECALL CURVE

precision_values, recall_values, _ = precision_recall_curve(
    y_test,
    test_probability
)

plt.figure(figsize=(7, 6))

plt.plot(
    recall_values,
    precision_values,
    label=f"PR-AUC = {pr_auc:.3f}"
)

plt.xlabel("Recall")
plt.ylabel("Precision")
plt.title("Precision-Recall Curve — Final Test Set")
plt.legend()

plt.tight_layout()

plt.savefig(
    PLOT_DIR / "precision_recall_curve.png",
    dpi=300,
    bbox_inches="tight"
)

plt.close()


# SAVE FINAL TEST PREDICTIONS

test_predictions = pd.DataFrame({
    "churn_probability": test_probability,
    "predicted_churn": test_prediction,
    "actual_churn": y_test.values
})

test_predictions.to_csv(
    INPUT_DIR / "final_test_predictions.csv",
    index=False
)

# SAVE FINAL TEST METRICS

metrics = pd.DataFrame({
    "metric": [
        "accuracy",
        "precision",
        "recall",
        "f1_score",
        "roc_auc",
        "pr_auc",
        "threshold"
    ],
    "value": [
        accuracy,
        precision,
        recall,
        f1,
        roc_auc,
        pr_auc,
        THRESHOLD
    ]
})

metrics.to_csv(
    INPUT_DIR / "final_test_metrics.csv",
    index=False
)


# FINAL OUTPUT

print("\nSaved plots:")
print(PLOT_DIR / "confusion_matrix.png")
print(PLOT_DIR / "roc_curve.png")
print(PLOT_DIR / "precision_recall_curve.png")

print("\nSaved:")
print(INPUT_DIR / "final_test_predictions.csv")
print(INPUT_DIR / "final_test_metrics.csv")
print(INPUT_DIR / "final_test_evaluation.txt")

print("\nFINAL TEST EVALUATION COMPLETED")

# RESTORE OUTPUT


sys.stdout = original_stdout
result_file.close()