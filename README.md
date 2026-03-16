# Data-Cleaning-Procedures-SQL-Project

## SQL Data Cleaning Project – Layoffs Dataset

### Overview
This project demonstrates a structured SQL data cleaning workflow using a real-world layoffs dataset from Alex The Analyst GitHub repository. The goal is to prepare raw data for analysis by removing duplicates, standardizing values, fixing data types, and handling missing data using MySQL Workbench. This reflects a real-world workflow where raw data must be cleaned before analysis, reporting, or dashboards.

### Final Data Structure
| Column Name            | Data Type |
|-------------------------|----------|
| company                 | TEXT     |
| location                | TEXT     |
| industry                | TEXT     |
| total_laid_off          | INT      |
| percentage_laid_off     | BIGINT   |
| date                    | DATE     |
| stage                   | TEXT     |
| country                 | TEXT     |
| funds_raised_millions   | INT      |

✅ Lay-offs dataset available: [layoffs.csv](https://github.com/entoma-fritzian/Data-Cleaning-Procedures-SQL-Project/blob/b9fee6d8c34b13cbb859aa2a8b2e456d98a4f66e/layoffs.csv)

### Data Cleaning Steps (with example SQL)

### 1. Create staging table and duplicate data
-- Purpose: Preserve raw data for safe cleaning
```sql
CREATE TABLE layoffs_staging LIKE layoffs;
INSERT INTO layoffs_staging SELECT * FROM layoffs;
```
### 2. Remove duplicates using ROW_NUMBER()
-- Purpose: Identify duplicates and delete extra rows
```sql
WITH duplicate_cte AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
         ) AS row_id
  FROM layoffs_staging
)
DELETE FROM duplicate_cte
WHERE row_id > 1;
```
### 3. Standardize text values
-- Purpose: Remove extra spaces and unify naming
```sql
UPDATE layoffs_staging
SET industry = TRIM(industry);
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
```
### 4. Convert date from text to DATE type
-- Purpose: Ensure proper date formatting for analysis
```sql
UPDATE layoffs_staging 
SET date = STR_TO_DATE(date, '%m/%d/%Y');
ALTER TABLE layoffs_staging
MODIFY COLUMN date DATE;
```
### 5. Handle NULLs in industry column
-- Purpose: Populate missing industry values using available company data
```sql
UPDATE layoffs_staging t1
JOIN layoffs_staging t2
  ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;
```
### 6. Remove rows with missing layoff data
-- Purpose: Drop rows that provide no useful information
```sql
DELETE FROM layoffs_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
```
✅ Full SQL script available: [SQL Data Cleaning Layoffs Project Script](https://github.com/entoma-fritzian/Data-Cleaning-Procedures-SQL-Project/blob/b9c09f7222c034764d4d92d340e37d26402ea3ba/First%20SQL_PROJECT_FINAL_VERSION.sql)

### Results Preview
*Example of cleaned dataset (first 5 rows)*
| company       | location       | industry | total_laid_off | percentage_laid_off | date       | stage  | country       | funds_raised_millions |
|---------------|---------------|---------|----------------|-------------------|-----------|--------|---------------|----------------------|
| E Inc.        | New York      | Tech    | 50             | 10                | 2023-01-15| Series A | United States | 5                    |
| F Corp        | San Francisco | Crypto  | 30             | 5                 | 2023-02-20| Series B | United States | 12                   |
| G Ltd.        | London        | Finance | 20             | 15                | 2023-03-10| Seed    | UK            | 3                    |
> This is a small preview; full cleaned dataset available after running `data_cleaning.sql`.

### Assumptions & Caveats
- Dataset assumed accurate aside from formatting issues
- Missing industry values populated only when matching company data existed
- Rows with no layoff information were removed
- No external datasets were used
- Project focuses solely on data cleaning, not analysis

### Dataset Source
Dataset obtained from the public repository by Alex The Analyst:  
[Alex The Analyst – MySQL YouTube Series](https://github.com/AlexTheAnalyst/MySQL-YouTube-Series)  
This project is for learning and portfolio purposes only.

### Tools Used
- MySQL Workbench
- SQL (Window Functions, Joins, Data Cleaning)
- GitHub

### Author
Fritz Ian Entoma  
Junior Business Intelligence Analyst / Virtual Assistant  
GitHub Profile: https://github.com/YOUR-USERNAME
