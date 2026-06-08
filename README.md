<p align="center">
  <img src="netflix.webp" alt="Global Streaming Catalog Analysis Logo" width="600px">
</p>

# Global Streaming Catalog Optimization & Business Intelligence (SQL Project)

## 📌 Project Overview
This project focuses on executing end-to-end data cleaning, advanced exploratory data analysis (EDA), and strategic financial reporting on an expanded dataset of 16,000 streaming titles (`netflix_titles`). 

Using production-grade **PostgreSQL**, this portfolio demonstrates how messy, unstructured operational data is systematically transformed into scalable business assets. The analysis spans three core areas:
1. **Data Cleaning & Preprocessing:** Formatting anomalies, structural deduplication, safe type casting, and anomaly resolution.
2. **Exploratory Data Analysis (EDA):** Quantifying content demographic shifts, temporal growth curves, distribution profiles, and outlier analysis.
3. **Business & Monetization Analysis:** Developing financial leaderboards, marketing segmentation matrices, ROI calculations, and risk assessments for content acquisition pipelines.

---

## 🛠️ Tech Stack & Tools
* **Database Engine:** PostgreSQL (v15+)
* **Query Tools:** pgAdmin / DBeaver / Terminal interface
* **Concepts Demonstrated:** Advanced Window Functions (`LAG`, `NTILE`, `RANK`), Percentile Groupings (`PERCENTILE_CONT`), String Manipulation, CTEs (`WITH` clauses), Defensive Mathematical Programming, and Type Casting.

---

## 🗺️ Schema Blueprint & Column Registry

The dataset is compiled into a single unified table named `netflix_titles`. Below is the explicit data dictionary and constraints configuration:

| Column Name | Data Type | Key Type / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `show_id` | `INT` | PRIMARY KEY | Unique identifier for each video title. |
| `type` | `VARCHAR(10)` | NOT NULL | Category classification (`Movie` or `TV Show`). |
| `title` | `VARCHAR(255)` | NOT NULL | The structural presentation name of the content item. |
| `director` | `VARCHAR(255)` | Nullable | Name of the primary creative director. |
| ` cast_members` | `TEXT` | Nullable | Leading cast string (Note: Contains a leading whitespace in raw ingest). |
| `country` | `VARCHAR(255)` | Nullable | Geographic production market origin (supports comma-delimited strings). |
| `date_added` | `VARCHAR(50)` | Nullable | Timestamp string indicating platform ingestion date. |
| `release_year` | `INT` | NOT NULL | The original public theatrical or broadcast release year. |
| `rating` | `NUMERIC(4,2)` | Nullable | Internal structural content classification metric. |
| `duration` | `NUMERIC` | Completely Empty | Legacy runtime database column to be audited and handled. |
| `genres` | `VARCHAR(255)` | Nullable | Categorical classification paths mapping content style. |
| `language` | `VARCHAR(10)` | NOT NULL | ISO two-letter language code of original master tape asset. |
| `description` | `TEXT` | Nullable | Logline synopsis copy detailing the core narrative hook. |
| `popularity` | `DOUBLE PRECISION`| NOT NULL | Audience dynamic engagement and exposure index score. |
| `vote_count` | `INT` | NOT NULL | Absolute total volume of historical consumer ratings. |
| `vote_average` | `DOUBLE PRECISION`| NOT NULL | Mean score compiled from critical audience feedback. |
| `budget` | `BIGINT` | NOT NULL | Recorded master file financial production costs (USD). |
| `revenue` | `BIGINT` | NOT NULL | Aggregated global distribution and box-office returns (USD). |

---

## 📋 Analytical Problems Solved

### 🛠️ Data Cleaning & Preprocessing
1. **Text Standardization:** Formatted data by trimming trailing/leading whitespaces from key descriptive text strings.
2. **Structural Deduplication:** Dropped duplicated title logs using row window rankings partitions based on peak popularity markers.
3. **Imputation Pipelines:** Applied database fallbacks (`COALESCE`) to clear unresolved missing record parameters.
4. **Dimension Slicing:** Isolated primary producing nations by tokenizing dynamic string values.
5. **Temporal Normalization:** Converted text fields into explicit SQL `DATE` representations to extract day, month, and year vectors.
6. **Data Integrity Audit:** Verified empty structural metrics across the catalog and handled data gaps using contextual estimations based on genre.
7. **Financial Tracking Audit:** Quantified the exact percentage of titles missing budget and revenue profiles across video formats.
8. **Text Corruption Filter:** Filtered unreadable non-ASCII artifacts using regular expressions (`REGEXP`).

### 📊 Exploratory Data Analysis (EDA)
9. **Longitudinal Shift Analysis:** Tracked movie-to-series ratios across a 15-year platform expansion cycle.
10. **Geographical Distribution:** Ranked peak content contribution sources globally by filtering out unknown metadata noise.
11. **Cumulative Library Growth:** Built running window sums tracking structural expansion historical paths over a daily timeline.
12. **Satisfaction Distribution Profiles:** Created graphical text frequency histograms to analyze distribution profiles of consumer satisfaction.
13. **Popularity Exposure Slicing:** Divided historical files into precise popularity quartiles (`NTILE`) to verify consumer response shifts.
14. **International Content Matrix:** Identified performance baselines for top non-English asset languages.
15. **Statistical Outlier Detection:** Isolated mega-budget assets sitting 3 standard deviations above the systemic global dataset average.

### 📈 Business & Monetization Analysis
16. **High-Value ROI Leaderboards:** Calculated absolute Return on Investment (ROI) efficiency ratios for assets with budgets over $10M.
17. **Director Asset Valuation:** Generated gross revenue valuation aggregates for creators boasting multi-project tracks ($3+$ assets).
18. **Capital Yield Indexing:** Assessed marketing clout efficiency by dividing popularity indicators against standardized production budget costs.
19. **Algorithmic Hidden Gems:** Isolated critically acclaimed, heavily voted content ($R > 7.5, V > 1000$) sitting below platform median popularity.
20. **Geographic Localization Yields:** Evaluated high-level revenue splits between native English assets and international catalogs.
21. **Temporal Release Optimization:** Ranked individual calendar months based on volume capacity and engagement indices using multiple tracking rows.
22. **Matrix Marketing Quadrants:** Mapped the inventory into distinct strategic quadrants (Blockbuster, Cult Classic, Flop, Indie).
23. **Acquisition Risk Assessments:** Evaluated commercial failure frequencies across genre chains by flagging items failing to hit financial breakeven points.
24. **Platform Trajectory Modeling:** Tracked product quality indices by measuring Year-over-Year (YoY) percentage performance shifts (`LAG`).


