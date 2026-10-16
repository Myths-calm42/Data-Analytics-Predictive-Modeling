"""
TASK 4 STEP 10 — Evaluate Logistic Regression model.
"""

from pathlib import Path
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
PLOT_DIR = INPUT_DIR / "plots"

PLOT_DIR.mkdir(parents=True, exist_ok=True)



# OUTPUT TEXT FILE


RESULT_FILE = INPUT_DIR / "evaluation_results.txt"


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


result_file = open(
    RESULT_FILE,
    "w",
    encoding="utf-8"
)

import sys

original_stdout = sys.stdout
sys.stdout = Tee(
    original_stdout,
    result_file
)



# LOAD VALIDATION PREDICTIONS


predictions = pd.read_csv(
    INPUT_DIR / "validation_predictions.csv"
)

y_true = predictions["actual_churn"]
y_probability = predictions["churn_probability"]



# CLASSIFICATION THRESHOLD


threshold = 0.30

y_pred = (
    y_probability >= threshold
).astype(int)



# METRICS


accuracy = accuracy_score(
    y_true,
    y_pred
)

precision = precision_score(
    y_true,
    y_pred,
    zero_division=0
)

recall = recall_score(
    y_true,
    y_pred,
    zero_division=0
)

f1 = f1_score(
    y_true,
    y_pred,
    zero_division=0
)

roc_auc = roc_auc_score(
    y_true,
    y_probability
)

pr_auc = average_precision_score(
    y_true,
    y_probability
)

cm = confusion_matrix(
    y_true,
    y_pred
)



# PRINT RESULTS


print("=" * 50)
print("TASK 4 STEP 10 — MODEL EVALUATION")
print("=" * 50)

print("\nValidation samples:", len(y_true))
print("Actual churn cases:", int(y_true.sum()))
print("Actual non-churn cases:", int((y_true == 0).sum()))

print("\nThreshold:", threshold)

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
        y_true,
        y_pred,
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
    "Confusion Matrix — Validation Set"
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
    y_true,
    y_probability
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
plt.title("ROC Curve — Validation Set")
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
    y_true,
    y_probability
)

plt.figure(figsize=(7, 6))

plt.plot(
    recall_values,
    precision_values,
    label=f"PR-AUC = {pr_auc:.3f}"
)

plt.xlabel("Recall")
plt.ylabel("Precision")
plt.title("Precision-Recall Curve — Validation Set")
plt.legend()

plt.tight_layout()

plt.savefig(
    PLOT_DIR / "precision_recall_curve.png",
    dpi=300,
    bbox_inches="tight"
)

plt.close()



# SAVE METRICS CSV

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
        threshold
    ]
})

metrics.to_csv(
    INPUT_DIR / "validation_metrics.csv",
    index=False
)


# FINAL OUTPUT

print("\nSaved plots:")
print(PLOT_DIR / "confusion_matrix.png")
print(PLOT_DIR / "roc_curve.png")
print(PLOT_DIR / "precision_recall_curve.png")

print("\nMetrics saved:")
print(INPUT_DIR / "validation_metrics.csv")

print("\nEvaluation text saved:")
print(RESULT_FILE)

print("\nSTEP 10 COMPLETED")



# RESTORE TERMINAL OUTPUT

sys.stdout = original_stdout
result_file.close()