SELECT * FROM bank_analysis;

/*========================================
Project: bank_marketing_campaign_analysis
Author: Akash Roy
Objective: To analyze the bank marketing campaign data
and find which type of customers are more likely to 
subscribe to the bank’s term deposit.
Date: 05-07-2026
==========================================*/

-- Step 1. Data cleaning

	-- Standerize Data --
    
-- 1 RENAME COLUMN. 
    
ALTER TABLE bank_analysis
RENAME COLUMN age TO Age;

ALTER TABLE bank_analysis
RENAME COLUMN job TO Job;

ALTER TABLE bank_analysis
RENAME COLUMN marital TO Marital;

ALTER TABLE bank_analysis
RENAME COLUMN education TO Education;

ALTER TABLE bank_analysis
RENAME COLUMN `default` TO `Defaults`;

ALTER TABLE bank_analysis
RENAME COLUMN balance TO Bank_Balance;

ALTER TABLE bank_analysis
RENAME COLUMN housing TO Customer_Housing;

ALTER TABLE bank_analysis
RENAME COLUMN loan TO Personal_lone;

ALTER TABLE bank_analysis
RENAME COLUMN contact TO Contact;

ALTER TABLE bank_analysis
RENAME COLUMN `day` TO Days;

ALTER TABLE bank_analysis
RENAME COLUMN `month` TO `Month`;

ALTER TABLE bank_analysis
RENAME COLUMN duration TO Duration;

ALTER TABLE bank_analysis
RENAME COLUMN campaign to Campaign;

ALTER TABLE bank_analysis
RENAME COLUMN pdays to P_days;

ALTER TABLE bank_analysis
RENAME COLUMN previous to Previous;

ALTER TABLE bank_analysis
RENAME COLUMN poutcome to Previous_outcome;

ALTER TABLE bank_analysis
RENAME COLUMN y to People_subscribed;

UPDATE bank_analysis
SET PEOPLE_SUBSCRIBED = CASE WHEN PEOPLE_SUBSCRIBED = 'yes' THEN 1 ELSE 0 END;

-- 2 FORMATE DATA ( TRIM ROWS )

UPDATE bank_analysis
SET AGE = TRIM(AGE);

UPDATE bank_analysis
SET job = TRIM(JOB);

UPDATE bank_analysis
SET MARITAL = TRIM(MARITAL);

UPDATE bank_analysis
SET EDUCATION = TRIM(EDUCATION);

UPDATE bank_analysis
SET DEFAULTS = TRIM(DefaultS);

UPDATE bank_analysis
SET CONTACT = TRIM(CONTACT);

	-- 3 REMOVING DUPLICATES/NULL VALUE --

-- IF A AGE, JOB PROFESION, BANK BALANCE AND SUBSCRIBTION RESULT MATCH IT WILL MAY CONSIDER AS DUPLICATE 

SELECT AGE,JOB, bank_BALANCE, PEOPLE_SUBSCRIBED, COUNT(*) AS 'DUPLICATE'
FROM bank_analysis
GROUP BY AGE, JOB, bank_BALANCE, PEOPLE_SUBSCRIBED
HAVING COUNT(*) > 1;

SELECT AGE,JOB, bank_BALANCE, PEOPLE_SUBSCRIBED FROM bank_analysis
WHERE JOB = 'MANAGEMENT'
AND Bank_Balance = '2143'
AND People_subscribed = 'NO';

-- USING RANK METHOD FOR WIDER VIEW.

SELECT *, 
ROW_NUMBER() OVER(PARTITION BY AGE, JOB,MARITAL, EDUCATION, Defaults, bank_BALANCE, CUSTOMER_HOUSING, PERSONAL_LONE, Contact, Days, `Month`, Duration, Campaign, P_DAYS, PREVIOUS, PREVIOUS_OUTCOME, PEOPLE_SUBSCRIBED) AS DUPLICATES
FROM bank_analysis
ORDER BY DUPLICATES DESC;

	-- NO DUPLICATES --

SELECT * FROM bank_analysis
WHERE AGE = ''
OR JOB = ''
OR MARITAL = ''
OR EDUCATION = ''
OR Defaults = ''
OR bank_BALANCE = ''
OR CUSTOMER_HOUSING = '' 
OR PERSONAL_LONE = ''
OR Contact = '';

-- NO BLANK/NULL --

	-- Step 2. Exploratory Data Analysis (EDA)

-- AVARAGE AGE GROUP --

SELECT AVG(AGE), MAX(AGE), MIN(AGE) FROM bank_analysis;

SELECT AGE , COUNT(*) AS AGE_GROUP
FROM bank_analysis
GROUP BY AGE 
ORDER BY AGE_GROUP DESC;

-- ( MAXIMUM AGE GROUP IS 32 )

-- GROUP BY JOB WITH HIGHEST JOB PROFESION

SELECT JOB, COUNT(*) AS JOB_CATEGORY, ROUND(COUNT(*)*100/ (SELECT COUNT(*) FROM BANK_ANALYSIS ),2) AS PERSENTAGE
FROM bank_analysis
GROUP BY JOB
ORDER BY JOB_CATEGORY DESC;

-- 288 CUSTOMER HAS UNKNOWN JOB PROFESION

-- GROUP BY MARITAL STATUS

SELECT MARITAL, COUNT(*) AS MARITAL_COUNT , ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM BANK_ANALYSIS),2) AS PERSENTAGE
FROM bank_analysis
GROUP BY MARITAL 
ORDER BY MARITAL_COUNT DESC;

-- GROUP BY EDUCATION 

SELECT EDUCATION, COUNT(*) AS EDUCATION_LEVEL , ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM BANK_ANALYSIS),2) AS PERSENTAGE
FROM bank_analysis
GROUP BY EDUCATION
ORDER BY EDUCATION_LEVEL DESC; 

-- GROUP BY PRODUCT_DEFAULTS

SELECT Defaults , COUNT(*) AS `COUNT` FROM bank_analysis
GROUP BY defaults
ORDER BY `COUNT` DESC;

-- RANKING BANK BALENCE 

WITH BALANCE_RANK AS
( SELECT Bank_Balance, 
CASE 
WHEN BANK_BALANCE > ( SELECT AVG(BANK_BALANCE) FROM bank_analysis ) THEN 'HIGHEST'
ELSE 'LOW'
END AS RANK_BALANCE
FROM bank_analysis )
SELECT RANK_BALANCE, COUNT(*) FROM BALANCE_RANK
GROUP BY RANK_BALANCE;

SELECT AVG(Bank_Balance), MAX(Bank_Balance), MIN(Bank_Balance) FROM bank_analysis;

-- 11748 customers has more then average bank balance

-- HOW MUCH CUSTOMER HAS A HOUSE

SELECT CUSTOMER_HOUSING, COUNT(*) AS RNK , ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM BANK_ANALYSIS),2) AS PERSENTAGE
FROM bank_analysis
GROUP BY Customer_Housing
ORDER BY RNK DESC;

-- 55.58% OF CUSTOMER HAS HOUSE.

-- HOW MUCH CUSTOMER HAS A PERSONAL LONE

SELECT Personal_lone, COUNT(*) AS RNK , ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM BANK_ANALYSIS),2) AS PERSENTAGE
FROM bank_analysis
GROUP BY Personal_lone
ORDER BY RNK DESC;

-- 83.98% OF CUSTOMER DOSE'NOT HAS ANY PERSONAL_

-- CONTACT TYPE

SELECT CONTACT, COUNT(*) AS CONTACT_COUNT FROM bank_analysis
GROUP BY CONTACT 
ORDER BY CONTACT_COUNT DESC;

-- unknown contacts type is 13020 

-- Step 3. Data Analysis 

-- 1. Which job type has the highest subscription rate?

SELECT JOB, PEOPLE_SUBSCRIBED,COUNT(*) AS TOTAL_PEOPLE_SUBSCRIBED
FROM bank_analysis
WHERE PEOPLE_SUBSCRIBED = 1
GROUP BY JOB, PEOPLE_SUBSCRIBED
ORDER BY TOTAL_PEOPLE_SUBSCRIBED DESC;

-- MANAGEMENT HAS HIGHER PEOPLE SUBSCRIPTION RATE 

-- 2. Which age group has the highest subscription rate?

SELECT CASE 
	WHEN AGE BETWEEN 18 AND 35 THEN '18-35'
    WHEN AGE BETWEEN 35 AND 55 THEN '36-55'
    ELSE '56-95' 
		END AS AGE_GROUP 
        , PEOPLE_SUBSCRIBED, COUNT(*) AS RNK,
        ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM BANK_ANALYSIS
        WHERE PEOPLE_SUBSCRIBED = '1' ),2) AS PERSENTAGE
        FROM bank_analysis
        WHERE PEOPLE_SUBSCRIBED = '1'
        GROUP BY AGE_GROUP, People_subscribed
				ORDER BY RNK DESC;

-- AGE GROUP 36-55 HAS HIGHEST SUBSCRIPTION WITH 41.48%

-- 3. Does education level affect subscription?

SELECT EDUCATION , COUNT(*) AS TOTAL , ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM BANK_ANALYSIS
WHERE PEOPLE_SUBSCRIBED = '1' ),2) AS PERSENTAGE , PEOPLE_SUBSCRIBED
FROM BANK_ANALYSIS
WHERE PEOPLE_SUBSCRIBED = '1'
GROUP BY EDUCATION, PEOPLE_SUBSCRIBED
ORDER BY PEOPLE_SUBSCRIBED DESC ;

-- SECONDARY EDUCATION LEVEL HAS 46.32% 

-- 4. Does marital status affect subscription?

SELECT MARITAL , COUNT(*) AS TOTAL , ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM BANK_ANALYSIS
WHERE PEOPLE_SUBSCRIBED = '1'),2) AS PERSENTAGE , PEOPLE_SUBSCRIBED
FROM BANK_ANALYSIS
WHERE PEOPLE_SUBSCRIBED = '1'
GROUP BY MARITAL, PEOPLE_SUBSCRIBED
ORDER BY PEOPLE_SUBSCRIBED DESC ;

-- 52.09% OF MARRIED CUSTOMER HAS HIGHEST SUBSCRIPTION RATE

-- 5. Do customers with housing loans subscribe less?

SELECT CUSTOMER_HOUSING, COUNT(*) AS TOTAL , ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM BANK_ANALYSIS ),2) AS RNK, People_subscribed FROM bank_analysis
GROUP BY Customer_Housing, People_subscribed
ORDER BY RNK DESC;

-- CUSTOMER WITH HOUSING LONE HAS HIGHER CHANCE OF NO SUBSCRIBTION

-- 6. Do customers with personal loans subscribe less?

SELECT Personal_lone, COUNT(*) AS TOTAL , ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM BANK_ANALYSIS ),2) AS RNK, People_subscribed FROM bank_analysis
GROUP BY Personal_lone, People_subscribed
ORDER BY RNK DESC;

-- CUSTOMER WITH ANY PERSONAL LONE HAS LOWEST CHANCE OF SUBSCRIPTION

-- 7. Which contact method performs best?

SELECT CONTACT , PEOPLE_SUBSCRIBED , COUNT(*) AS RNK , ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM bank_analysis),2)
AS PERSENTAGE_RNK
FROM bank_analysis
GROUP BY CONTACT , PEOPLE_SUBSCRIBED
ORDER BY RNK DESC;

-- CELLULAR CONTACT METHOD HAS HIGHEST CHANCE OF SUBSCRIBTION

-- 8. Which month has the highest subscription rate?

SELECT MONTH , PEOPLE_SUBSCRIBED , COUNT(*) AS RNK , ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM bank_analysis
WHERE PEOPLE_SUBSCRIBED = '1' ),2)
AS PERSENTAGE_RNK
FROM bank_analysis
WHERE People_subscribed ='1'
GROUP BY MONTH , PEOPLE_SUBSCRIBED
ORDER BY RNK DESC;

-- MAY HAS THE HIGHEST CHANCE OF SUBSCRIPTION

-- 9. Does call duration affect subscription?

SELECT PEOPLE_SUBSCRIBED ,
CASE 
WHEN DURATION BETWEEN 0 AND 1000 THEN '0-1000'
WHEN DURATION BETWEEN 1001 AND 2500 THEN '1001-2500'
ELSE '2501-4918' END AS DURATION_RNK , COUNT(*) AS RNK , ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM bank_analysis
WHERE People_subscribed = '1' ),2)
AS PERSENTAGE_RNK
FROM bank_analysis
WHERE People_subscribed = '1'
GROUP BY DURATION_RNK , PEOPLE_SUBSCRIBED
ORDER BY RNK DESC;

-- CALL DURATION BETWEEN 0-1000 HAS HIGHEST CHANCES OF SUBSCRIPTION WITH 88.05%

-- 10. Does previous campaign result affect current subscription?

SELECT Campaign , PEOPLE_SUBSCRIBED , COUNT(*) AS RNK , ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM bank_analysis 
WHERE People_subscribed = '1'),2)
AS PERSENTAGE_RNK
FROM bank_analysis
WHERE People_subscribed = '1'
GROUP BY Campaign , PEOPLE_SUBSCRIBED
ORDER BY RNK DESC;

-- CAMPAGIN 1 HAS HIGHEST CHANCE OF SUBSCRIPTION

/*==========================================================
Conclusion

Customers from management jobs, the 36–55 age group,
secondary education, and married customers showed higher
subscription numbers. Customers with housing or personal loans
were less likely to subscribe. The cellular contact method and
the month of May performed best for subscriptions.
=============================================================*/

/*==========================================================
Business Advice

Overall, the bank should target middle-aged customers,
management professionals, and customers without loans,
while using cellular contact to improve subscription results.
==========================================================*/

-- Step 4. BUSINESS ANALYSIS

-- 1. Which customer segment should the bank target first?
-- answer ( age group )
-- 2. Which customers are less useful to target?
-- answer (older, primary education , unknown job profetion and has housing lone )

-- 3. Should the bank retarget customers from previous successful campaigns?

SELECT PREVIOUS_OUTCOME, Campaign , PEOPLE_SUBSCRIBED, COUNT(*) RNK FROM bank_analysis
WHERE People_subscribed ='1'
GROUP BY Previous_outcome,Campaign, People_subscribed
ORDER BY RNK DESC;

-- UNKNOWN PREVIUS OUTCOME WITH 1 CAMPAIGN Should the bank retarget customers

-- 4. Which month is best for running the campaign?
-- ANSWER (MAY MONTH)

-- 5. Are customers without loans better targets?
-- ANSWER (customers without loans are the better targets )

-- 6. Are high-balance customers more likely to subscribe?

SELECT 
CASE 
WHEN BANK_BALANCE BETWEEN -8019 AND 0 THEN '-8019-0'
WHEN bank_BALANCE BETWEEN 1 AND 50000 THEN '1-50000'
ELSE '50001-102127'
END AS BANK_BALANCE_GROUP
, COUNT(*) RNK , PEOPLE_SUBSCRIBED FROM bank_analysis
WHERE People_subscribed ='1'
GROUP BY BANK_BALANCE_GROUP, People_subscribed
ORDER BY RNK DESC;

-- ANSWER ( CUSTOMER WITH BANK BALANCE FROM 1 TO 50000 HAS HIGHEST RATE OF SUBSCRIPTION)

/*======================================================
BUSINESS ANALYSIS CONCLUTION 

The bank should target customers with no loans,
good bank balance, and the best-performing age group 36-55.
May is the best campaign month. The bank should avoid older
customers, primary-educated customers, unknown job customers,
and customers with housing loans.

=========================================================*/
