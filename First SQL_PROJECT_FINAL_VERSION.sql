/* =====================================================
   SQL DATA CLEANING PROJECT – LAYOFFS DATASET
   Steps:
   1. Create staging table
   2. Remove duplicates
   3. Standardize data
   4. Handle NULL / blank values
   5. Remove unnecessary rows / columns
===================================================== */


-- =====================================================
-- QUICK VIEW OF RAW DATA
-- =====================================================

SELECT *
FROM layoffs;


-- =====================================================
-- CREATE STAGING TABLE (SAFE COPY)
-- =====================================================

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;


-- Insert raw data into staging

INSERT layoffs_staging
SELECT *
FROM layoffs;



-- =====================================================
-- 1. REMOVE DUPLICATES
-- =====================================================

-- Check duplicates using ROW_NUMBER

SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company,industry,total_laid_off,
percentage_laid_off, `date`
) AS row_id
FROM layoffs_staging;



-- Use CTE to identify duplicates

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company,location,industry,
total_laid_off,percentage_laid_off,
`date`,stage,country,funds_raised_millions
) AS row_id
FROM layoffs_staging
)

SELECT *
FROM duplicate_cte
WHERE row_id > 1;



-- Validate sample

SELECT *
FROM layoffs_staging
WHERE company = 'E Inc.';



-- MySQL limitation → create new table with row_id

CREATE TABLE layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT,
  percentage_laid_off BIGINT,
  `date` TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT,
  row_id INT
);


-- Insert with row number

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company,location,industry,
total_laid_off,percentage_laid_off,
`date`,stage,country,funds_raised_millions
) AS row_id
FROM layoffs_staging;



-- Delete duplicates

DELETE
FROM layoffs_staging2
WHERE row_id > 1;



-- Check again

SELECT *
FROM layoffs_staging2
WHERE row_id > 1;



-- =====================================================
-- 2. STANDARDIZE DATA
-- =====================================================

SELECT *
FROM layoffs_staging2;



-- ---------- INDUSTRY ----------

SELECT industry, TRIM(industry)
FROM layoffs_staging2
ORDER BY industry;

UPDATE layoffs_staging2
SET industry = TRIM(industry);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;



-- Fix Crypto / Crypto Currency

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';



-- ---------- LOCATION ----------

SELECT location, TRIM(location)
FROM layoffs_staging2
ORDER BY location;

UPDATE layoffs_staging2
SET location = TRIM(location);

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY location;



-- ---------- COUNTRY ----------

UPDATE layoffs_staging2
SET country = TRIM(country);

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;



-- Fix United States typo

SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';



-- ---------- DATE ----------

SELECT `date`
FROM layoffs_staging2
ORDER BY `date`;

UPDATE layoffs_staging2
SET `date` = TRIM(`date`);

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;



-- =====================================================
-- 3. HANDLE NULL / BLANK VALUES
-- =====================================================

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';



-- Convert blank to NULL

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';



-- Populate NULL using self join

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;



UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;



-- =====================================================
-- 4. REMOVE UNNECESSARY ROWS / COLUMNS
-- =====================================================

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off IS NULL
AND total_laid_off IS NULL;



DELETE
FROM layoffs_staging2
WHERE percentage_laid_off IS NULL
AND total_laid_off IS NULL;



-- Drop helper column

ALTER TABLE layoffs_staging2
DROP COLUMN row_id;



-- =====================================================
-- FINAL CHECK
-- =====================================================

SELECT *
FROM layoffs_staging2;