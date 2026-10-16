# Data Analytics & Predictive Modeling

A multi-stage data analytics project focused on data quality assessment, exploratory analysis, metric decomposition, behavioral analysis, and predictive modeling. The project combines SQL-based data processing with Python notebooks, structured outputs, and presentation-ready reporting.

## Project Overview

This repository organizes the analysis into four tasks. Each task has its own SQL queries and generated outputs, making the workflow easier to inspect and maintain.

- **Task 1 — Data exploration and quality:** Review source data quality, examine activity and performance metrics, and prepare detailed analytical summaries.
- **Task 2 — Metric analysis and decomposition:** Investigate changes in an aggregate performance metric, compare segment-level trends, and separate composition effects from within-segment changes.
- **Task 3 — Comparative analysis:** Compare groups using appropriate descriptive and statistical methods.
- **Task 4 — Predictive modeling:** Develop and evaluate a predictive model, with attention to evaluation metrics and practical interpretation.

The repository contains analysis code and selected reporting materials. Local input data and large generated outputs are not included.

## Repository Structure

```text
.
├── notebooks/
│   ├── task1_analysis.ipynb
│   ├── task2_analysis.ipynb
│   ├── task3_analysis.ipynb
│   └── task4/
├── sql/
│   ├── task-1/
│   ├── task-2/
│   ├── task-3/
│   └── task-4/
├── presentation/
├── output/                 # Local generated outputs; excluded from Git
├── data/                   # Local input data; excluded from Git
├── .gitignore
├── requirements.txt
└── README.md
```

The exact contents of each task folder may evolve as the project is maintained.

## Tools & Technologies

- **SQL** for data extraction, transformations, validation, and metric calculations
- **Python** for analysis and predictive modeling
- **Jupyter Notebook** for reproducible, step-by-step exploration
- **DuckDB** for local analytical queries and data processing
- **Pandas and NumPy** for data manipulation and numerical analysis
- **Matplotlib / Seaborn** for visual exploration and reporting

*The tools listed above should be adjusted to match the libraries and methods actually used in the final notebooks.*

## Analytical Workflow

1. **Validate the data** — inspect data quality, missing values, duplicates, date consistency, and other potential anomalies.
2. **Explore and summarize** — calculate descriptive metrics and examine trends across time and relevant segments.
3. **Investigate drivers** — compare segment-level results and decompose aggregate changes where appropriate.
4. **Test comparisons** — use suitable statistical approaches when comparing groups, while distinguishing association from causation.
5. **Build and evaluate a model** — assess predictive performance with appropriate metrics and interpret the results in context.
6. **Communicate findings** — prepare concise visualizations, tables, and presentation materials to support decisions.

## Selected Finding

One analysis decomposed a decline in an aggregate performance metric into segment-mix and within-segment effects:

- The aggregate metric decreased from **0.351 to 0.293** between the first and last 30-day periods (**16.5% decline**).
- The segment-mix effect was estimated at **−0.0758**, while the within-segment effect was **+0.0179**.
- This descriptive decomposition indicates that the change in segment composition more than accounted for the observed decline, while within-segment changes partially offset it.

These findings are descriptive, not causal. They should be interpreted alongside the data definitions, observation window, and limitations documented in the relevant analysis.

## Data & Reproducibility

Input files and generated outputs are intentionally excluded from the public repository. This keeps the repository lightweight and avoids publishing data that may not be suitable for redistribution.

To reproduce the analysis:

1. Use an authorized copy of the required input data.
2. Place the files in the expected local data directory.
3. Install the dependencies listed in `requirements.txt`.
4. Run the relevant SQL scripts and notebooks in task order.
5. Review the notebook paths and configuration before running in a different environment.

Because local data files are not included, the notebooks may require the input files to be supplied separately before they can run end to end.

## Setup

Create and activate a virtual environment, then install the project dependencies.

```bash
python -m venv .venv
```

Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

macOS / Linux:

```bash
source .venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Open the notebooks with Jupyter:

```bash
jupyter notebook
```

Ensure that `requirements.txt` reflects the dependencies used by the notebooks before publishing the repository.

## Repository Hygiene

The repository is configured to keep local-only and potentially sensitive files out of version control, including:

- Virtual environments and cache files
- Local input data
- Large generated output folders
- Local DuckDB/database files
- Environment files and secrets

Check `.gitignore` and review staged files with `git status` before each push. Do not publish credentials, private information, or data without permission.

## Limitations

- Results depend on the quality and definitions of the available data.
- Some analyses may be descriptive and cannot establish causality.
- Reproducing the results requires access to the relevant input files.
- Model performance should be interpreted using the evaluation procedure and metrics documented in the corresponding notebook.

## Author

**Vikrant Kumar**

- GitHub: [Myths-calm42](https://github.com/Myths-calm42)
- Portfolio: [Personal Portfolio](https://vikrant-portfolio-chi.vercel.app/)
- LinkedIn: [LinkedIn Profile](https://www.linkedin.com/in/vikrant-kumar11022003/)

---

*This repository presents an applied analytics workflow, from data validation and SQL analysis to statistical investigation, predictive modeling, and communication of findings.*
