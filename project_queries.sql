CREATE DATABASE emp_project;
 
USE emp_project;

DESCRIBE hr;

SELECT * FROM hr;
-- Start cleaning the data.

-- Change the first field from 'ï»¿id' to 'emp_id'
ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(30);

SET sql_safe_updates = 0;

-- Updating the birthdate field from text to date format
UPDATE hr
SET birthdate = CASE 
 WHEN birthdate LIKE '%/%' THEN str_to_date(birthdate, '%m/%d/%Y')
 WHEN birthdate LIKE '%-%' THEN str_to_date(birthdate, '%m-%d-%Y')
ELSE NULL
END;

-- Updating the hire_date field from text to date format
UPDATE hr
SET hire_date = CASE 
 WHEN hire_date LIKE '%/%' THEN str_to_date(hire_date, '%m/%d/%Y')
 WHEN hire_date LIKE '%-%' THEN str_to_date(hire_date, '%m-%d-%Y')
ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN  birthdate DATE;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

-- Updating the termdate field from text to date format
UPDATE hr
SET termdate = CASE
 WHEN termdate LIKE '%-%' THEN STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC')
 ELSE NULL 
END;

UPDATE hr
SET termdate = DATE(STR_TO_DATE(termdate,'%Y-%m-%d %H:%i:%s'))
WHERE termdate IS NOT NULL;

DESCRIBE hr;

-- Adding a new column to calculate the empoyee's age from the birthdate.
ALTER TABLE hr
ADD COLUMN age INT;

UPDATE hr
 SET age = TIMESTAMPDIFF(Year, birthdate, CURDATE())
 WHERE age IS NULL;
 
SELECT birthdate, age FROM hr ORDER BY age DESC;

-- Fetching the Outliers values as the max_age was 58 & min_age was -45.
SELECT
 MAX(age) AS max_age,
 MIN(age) AS min_age
FROM hr;

-- Fetching the count of employees who are less than 18
SELECT 
 COUNT(*) AS number_of_emp_below_18
FROM hr
WHERE age < 19;

/* 1. What is the breakdown of active employees in the company? */
SELECT
 gender,
 COUNT(*) AS number_of_emp
FROM hr
WHERE age > 18 AND termdate IS NULL
GROUP BY gender;

/* 2. What is the race/ethnicity breakdown of the active employees in the company? */
SELECT
 race,
 COUNT(race) AS count_of_race
FROM hr
WHERE age > 18 AND termdate IS NULL
GROUP BY race
ORDER BY count_of_race DESC;

/* 3. What is the age distribution of employees in the company? */
SELECT
 MAX(age),
 MIN(age)
FROM hr
WHERE age >= 18 AND termdate IS NULL;

SELECT
 CASE 
  WHEN age >= 18 AND age <= 24 THEN '18-24'
  WHEN age >= 25 AND age <= 34 THEN '25-34'
  WHEN age >= 35 AND age <= 44 THEN '35-44'
  WHEN age >= 45 AND age <= 54 THEN '45-54'
  WHEN age >= 55 AND age <= 64 THEN '55-64'
  ELSE '65+'
 END AS age_distribution, gender,
 COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate IS NULL
GROUP BY age_distribution, gender
ORDER BY age_distribution, gender;


/* 4. How many employees work at headquarters versus remote locations? */
SELECT 
 location,
 COUNT(location) count_of_emp
FROM hr
WHERE age >= 18 AND termdate IS NULL
GROUP BY location;

/* 5. What is the average length of employment for employees who have been terminated? */
SELECT
 first_name,
 hire_date,
 termdate
FROM hr
WHERE termdate IS NOT NULL;

ALTER TABLE hr
ADD COLUMN len_of_employment INT ;

UPDATE hr
SET len_of_employment = TIMESTAMPDIFF(Year, hire_date, termdate )
WHERE len_of_employment IS NULL AND age >= 18;

SELECT ROUND(AVG(len_of_employment),0) AS avg_len_of_employment
FROM hr;

/* 6. How does the gender distribution vary across departments and job titles? */

SELECT
 department,
 gender,
 COUNT(*) 
FROM hr
WHERE age >= 18 AND termdate IS NULL
GROUP BY gender, department
ORDER BY department ASC;

-- 7. What is the distribution of job titles across the company?
SELECT
 jobtitle,
 COUNT(jobtitle) AS count_of_jobtitles
FROM hr
WHERE age >= 18 AND termdate IS NULL
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. Which department has the highest turnover rate?
SELECT 
 department, 
 COUNT(*) AS total_count, 
 SUM(CASE WHEN termdate <= CURDATE() AND termdate IS NOT NULL THEN 1 ELSE 0 END) AS terminated_count, 
 SUM(CASE WHEN termdate IS NULL THEN 1 ELSE 0 END) AS active_count,
 (SUM(CASE WHEN termdate <= CURDATE() THEN 1 ELSE 0 END) / COUNT(*)) AS termination_rate
FROM hr
WHERE age >= 18
GROUP BY department
ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees across location state by state?
SELECT
 location_state,
 COUNT(location_state) AS count
FROM hr
WHERE age >= 18 AND termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT 
 YEAR(hire_date) AS year,
 COUNT(*) AS hires,
 SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations, 
 COUNT(*) - SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS net_change,
 ROUND(((COUNT(*) - SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END)) / COUNT(*) * 100),2) AS net_change_percent
FROM hr
WHERE age >= 18
GROUP BY YEAR(hire_date)
ORDER BY YEAR(hire_date) ASC;


-- 11. What is the tenure distribution for each department?
SELECT 
 department, 
 ROUND(AVG(DATEDIFF(CURDATE(),termdate)/365),0) AS avg_tenure
FROM hr
WHERE termdate <= CURDATE() AND termdate IS NOT NULL AND age >= 18
GROUP BY department;



