SELECT * FROM hr_analysis_table;

/*=
Project: HR Attrition Analysis
Author: Akash Roy
Objective:
Analyze employee attrition and identify the main factors
contributing to employees leaving the company.
=*/

-- STEP 1: Data Cleaning

-- *1 FINDING DUPLICATES

SELECT EMPLOYEENUMBER, COUNT(*) AS EMPLOYEES
	FROM hr_analysis_table
    GROUP BY EmployeeNumber
    HAVING COUNT(*) >'1';

-- DATA SHOWS NO DUPLICATES--

-- *2 STANDARDIZING DATA
	-- REMANE AGE --
    
ALTER TABLE hr_analysis_table
RENAME COLUMN ï»¿Age TO Age;


-- STEP 2: Exploratory Data Analysis (EDA)

	-- TOTAL EMPLOYEES --
    
    SELECT EMPLOYEENUMBER, COUNT(*) FROM hr_analysis_table
    GROUP BY EMPLOYEENUMBER;

	-- *SALARY ANALYSIS* --

	SELECT MAX(MONTHLYINCOME) AS HIGH_SALARY , AVG(MONTHLYINCOME) AS AVG_SALARY, MIN(MONTHLYINCOME) AS MINIMUM_SALARY
    FROM hr_analysis_table;

	-- SALARY BY DEPARTMENT --
    
    SELECT DEPARTMENT , ROUND(AVG(MonthlyIncome),2) AS AVG_SALARY
    FROM hr_analysis_table
		GROUP BY Department
		ORDER BY AVG_SALARY DESC;
        
	-- SALARY BY EDUCATION FIELD --
    
    SELECT EducationField , ROUND(AVG(MonthlyIncome),2) AS AVG_SALARY
    FROM hr_analysis_table
		GROUP BY EducationField
		ORDER BY AVG_SALARY DESC;
        
    -- SALARY BY EDUCATION --
    
    SELECT Education, ROUND(AVG(MonthlyIncome),2) AS AVG_SALARY
    FROM hr_analysis_table
		GROUP BY Education
		ORDER BY AVG_SALARY DESC;
        
    -- SALARY BY GENDER --
    
      
    SELECT GENDER ,COUNT(*) AS TOTAL_EMPLOYEED,
    ROUND(AVG(MonthlyIncome),2) AS AVG_SALARY
    FROM hr_analysis_table
		GROUP BY GENDER
		ORDER BY AVG_SALARY DESC;
        
    
    -- *ATTRITION RATE ANALYSIS* --
    
    SELECT Attrition ,COUNT(*) FROM hr_analysis_table
GROUP BY Attrition;

SELECT DEPARTMENT , COUNT(*) AS DEPARTMENT_COUNT
	FROM hr_analysis_table
    GROUP BY Department;

	SELECT Attrition,
    ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM hr_analysis_table),2) AS ATTRITION_RATE
    FROM hr_analysis_table
    GROUP BY Attrition;
    
    -- ATTRITION BY DEPARTMENT --    

    SELECT DEPARTMENT , COUNT(*) AS EMPLOYEES ,
    SUM(CASE WHEN ATTRITION = 'YES' THEN 1 ELSE 0 END ) AS ATTRITION_NUM,
    ROUND(SUM(CASE WHEN ATTRITION = 'YES' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS ATTRITION_RATE
    FROM hr_analysis_table
		GROUP BY Department
        ORDER BY ATTRITION_RATE DESC;
        
-- STEP 3: Business Analysis
	-- Business Problem: Identify the main causes of employee attrition. --
    
    /*=
    Possible factors to investigate:
1. Age
2. Gender
3. Monthly Salary
4. Distance From Home
5. Job Satisfaction
6. Environment Satisfaction
7. Work-Life Balance
8. Job Level
9. Job Role
10. Overtime
11. Percent Salary Hike
12. Relationship Satisfaction
13. Business Travel
	=*/

-- Q.1 ATTRITION BY AGE

WITH AGE_ATTRITION AS
( SELECT AGE , COUNT(*) AS EMPLOYEES ,
    SUM(CASE WHEN ATTRITION = 'YES' THEN 1 ELSE 0 END ) AS ATTRITION_NUM,
   ROUND(SUM(CASE WHEN ATTRITION = 'YES' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS ATTRITION_RATE
    FROM hr_analysis_table
		GROUP BY AGE
        ORDER BY ATTRITION_RATE DESC)
        SELECT * FROM AGE_ATTRITION;

-- Q.2 ATTRITION BY GENDER
WITH GENDER_ATTRITION AS
(SELECT GENDER , COUNT(*) AS EMPLOYEES ,
    SUM(CASE WHEN ATTRITION = 'YES' THEN 1 ELSE 0 END ) AS ATTRITION_NUM,
    ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM hr_analysis_table),2) AS ATTRITION_RATE
    FROM hr_analysis_table
		GROUP BY GENDER
        ORDER BY ATTRITION_RATE DESC)
        SELECT * FROM GENDER_ATTRITION
	;

-- Q.3 ATTRITION Monthly Salary
WITH SALARY_GROUP AS
(SELECT
CASE 
WHEN MONTHLYINCOME > ( SELECT AVG(MONTHLYINCOME) FROM hr_analysis_table) THEN 'HIGH'
WHEN MONTHLYINCOME < ( SELECT AVG(MONTHLYINCOME) FROM hr_analysis_table) THEN 'LOW'
WHEN  MonthlyIncome = ( SELECT AVG(MONTHLYINCOME) FROM hr_analysis_table) THEN 'MID'
END AS SALARY_GROUP ,  COUNT(*) EMPLOYEE_COUNT ,
SUM(CASE WHEN ATTRITION = 'YES' THEN 1 ELSE 0 END ) AS ATTRITION_SALARY
FROM hr_analysis_table
GROUP BY SALARY_GROUP
ORDER BY Employee_Count)
SELECT * FROM SALARY_GROUP;

-- Q4. Distance From Home

SELECT DistanceFromHome , COUNT(*) AS EMPLOYEES ,
    SUM(CASE WHEN ATTRITION = 'YES' THEN 1 ELSE 0 END ) AS ATTRITION_NUM,
    ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM hr_analysis_table),2) AS ATTRITION_RATE
    FROM hr_analysis_table
		GROUP BY DistanceFromHome
        ORDER BY ATTRITION_RATE DESC;

-- Q.5 BUSINESS TRAVEL 

SELECT BusinessTravel , COUNT(*) AS EMPLOYEES ,
    SUM(CASE WHEN ATTRITION = 'YES' THEN 1 ELSE 0 END ) AS ATTRITION_NUM,
    ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM hr_analysis_table),2) AS ATTRITION_RATE
    FROM hr_analysis_table
		GROUP BY BusinessTravel
        ORDER BY ATTRITION_RATE DESC;

-- Q.6 JOB SATESFACTION

SELECT JobSatisfaction , COUNT(*) AS EMPLOYEES ,
    SUM(CASE WHEN ATTRITION = 'YES' THEN 1 ELSE 0 END ) AS ATTRITION_NUM,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS ATTRITION_RATE
    FROM hr_analysis_table
		GROUP BY JobSatisfaction
        ORDER BY ATTRITION_RATE DESC;

-- Q.7 Environment Satisfaction
        
        SELECT
    EnvironmentSatisfaction,
    COUNT(*) AS Employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Attrition_Num,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS Attrition_Rate
FROM hr_analysis_table
GROUP BY EnvironmentSatisfaction
ORDER BY Attrition_Rate DESC;

-- Q.8 JOB ROLE AND JOB LEVEL

SELECT JobLevel, JobRole , COUNT(*) AS EMPLOYEES ,
    SUM(CASE WHEN ATTRITION = 'YES' THEN 1 ELSE 0 END ) AS ATTRITION_NUM,
    ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM hr_analysis_table),2) AS ATTRITION_RATE,
    ROUND(SUM(CASE WHEN ATTRITION = 'YES' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS EMP_LOSS
    FROM hr_analysis_table
		GROUP BY JobLevel , JobRole
        ORDER BY AttritioN_RATE DESC;

-- Q.9 ATTRITION BY OVER TIME

SELECT  OverTime, COUNT(*) AS EMPLOYEES ,
    SUM(CASE WHEN ATTRITION = 'YES' THEN 1 ELSE 0 END ) AS ATTRITION_NUM,
    ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM hr_analysis_table),2) AS ATTRITION_RATE,
    ROUND(SUM(CASE WHEN ATTRITION = 'YES' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS EMP_LOSS
    FROM hr_analysis_table
		GROUP BY OverTime
        ORDER BY ATTRITION_RATE DESC;

-- Q.10  Percent Salary Hike


SELECT  PercentSalaryHike , COUNT(*) AS EMPLOYEES ,
    SUM(CASE WHEN ATTRITION = 'YES' THEN 1 ELSE 0 END ) AS ATTRITION_NUM,
    ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM hr_analysis_table),2) AS ATTRITION_RATE
    FROM hr_analysis_table
		GROUP BY PercentSalaryHike
        ORDER BY ATTRITION_RATE DESC;
        
-- Q.11 Relationship Satisfaction

SELECT  RelationshipSatisfaction , COUNT(*) AS EMPLOYEES ,
    SUM(CASE WHEN ATTRITION = 'YES' THEN 1 ELSE 0 END ) AS ATTRITION_NUM,
    ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM hr_analysis_table),2) AS ATTRITION_RATE
    FROM hr_analysis_table
		GROUP BY RelationshipSatisfaction
        ORDER BY ATTRITION_RATE DESC;

/*==============================================
CONCLUSION 
factors that affect attrition
-- 1 over time has highest effect on attrition 
-- 2 Low job satisfaction
-- 3 Poor work environment
-- 4 Poor work life balence
-- 5 Frequent business trave 
==============================================*/
-- FINAL QUERY 

WITH FACTOR_AFFECTS_MOST AS
( SELECT OVERTIME , BUSINESSTRAVEL, COUNT(*) AS EMPLOYEES,
SUM(CASE WHEN ATTRITION = 'YES' THEN 1 ELSE 0 END ) AS ATTRITION_COUNT,
ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM hr_analysis_table),2) AS ANALYSIS_OVERALL,
ROUND(SUM(CASE WHEN ATTRITION = 'YES' THEN 1 ELSE 0 END )*100/ COUNT(*),2) AS ATTRITION_RATE
FROM hr_analysis_table
GROUP BY OverTime, BusinessTravel
ORDER BY ATTRITION_RATE DESC)
SELECT * FROM FACTOR_AFFECTS_MOST ;

		-- IT SHOWS THAT OVERTIME AND FREQUENT TRAVEL AFFECT THE ATTRITION --
        










