from pathlib import Path
import pandas as pd
import joblib

from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.impute import SimpleImputer


PROJECT_DIR = Path(__file__).resolve().parents[2]
INPUT_DIR = PROJECT_DIR / "output" / "task4"
OUTPUT_DIR = PROJECT_DIR / "output" / "task4"


# Load data
X_train = pd.read_csv(INPUT_DIR / "X_train.csv")
X_validation = pd.read_csv(INPUT_DIR / "X_validation.csv")
X_test = pd.read_csv(INPUT_DIR / "X_test.csv")

y_train = pd.read_csv(INPUT_DIR / "y_train.csv")
y_validation = pd.read_csv(INPUT_DIR / "y_validation.csv")
y_test = pd.read_csv(INPUT_DIR / "y_test.csv")


# Feature types
categorical_features = [
    "platform",
    "country",
    "country_tier",
    "acquisition_channel",
    "last_app_version"
]

numerical_features = [
    col for col in X_train.columns
    if col not in categorical_features
]


print("=" * 50)
print("TASK 4 STEP 8 — FEATURE PREPROCESSING")
print("=" * 50)

print("\nCategorical features:")
print(categorical_features)

print("\nNumber of numerical features:", len(numerical_features))


# Numerical preprocessing
numeric_pipeline = Pipeline([
    (
        "imputer",
        SimpleImputer(strategy="median")
    ),
    (
        "scaler",
        StandardScaler()
    )
])


# Categorical preprocessing
categorical_pipeline = Pipeline([
    (
        "imputer",
        SimpleImputer(strategy="most_frequent")
    ),
    (
        "encoder",
        OneHotEncoder(
            handle_unknown="ignore",
            sparse_output=True
        )
    )
])


# Combined preprocessing
preprocessor = ColumnTransformer(
    transformers=[
        (
            "numeric",
            numeric_pipeline,
            numerical_features
        ),
        (
            "categorical",
            categorical_pipeline,
            categorical_features
        )
    ]
)


# Fit ONLY on training data
X_train_processed = preprocessor.fit_transform(X_train)

# Transform validation and test
X_validation_processed = preprocessor.transform(X_validation)
X_test_processed = preprocessor.transform(X_test)


# Save processed data
joblib.dump(
    X_train_processed,
    OUTPUT_DIR / "X_train_processed.pkl"
)

joblib.dump(
    X_validation_processed,
    OUTPUT_DIR / "X_validation_processed.pkl"
)

joblib.dump(
    X_test_processed,
    OUTPUT_DIR / "X_test_processed.pkl"
)

# Save preprocessing object
joblib.dump(
    preprocessor,
    OUTPUT_DIR / "preprocessor.pkl"
)


# Save target variables
y_train.to_csv(
    OUTPUT_DIR / "y_train.csv",
    index=False
)

y_validation.to_csv(
    OUTPUT_DIR / "y_validation.csv",
    index=False
)

y_test.to_csv(
    OUTPUT_DIR / "y_test.csv",
    index=False
)


# Output
print("\nOriginal feature count:",
      X_train.shape[1])

print("Processed feature count:",
      X_train_processed.shape[1])

print("\nProcessed shapes:")
print("X_train:", X_train_processed.shape)
print("X_validation:", X_validation_processed.shape)
print("X_test:", X_test_processed.shape)

print("\nMissing values handled:")
print("Numerical → median")
print("Categorical → most frequent")

print("\nSTEP 8 COMPLETED")