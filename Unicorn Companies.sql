 /*View the table*/							  
SELECT *
FROM unicorn_companies_dup;

/*Data Cleaning*/
---Change column name from select_investors to unicorn_investors. 
ALTER TABLE unicorn_companies_dup 
RENAME COLUMN select_investors TO unicorn_investors;

---Change the data type of valuation column from VARCHAR to BIGINT. 
ALTER TABLE unicorn_companies_dup 
ALTER COLUMN valuation TYPE BIGINT
USING valuation::BIGINT;

---Change the text Unknown and Other in funding and industry columns to empty rows
UPDATE unicorn_companies_dup
SET funding = REPLACE (funding, 'Unknown', '');

UPDATE unicorn_companies_dup
SET industry = REPLACE (industry, 'Other', '');

---Change the null values in funding column to zero
UPDATE unicorn_companies_dup
SET funding = 0
WHERE ID IN ('216', '425', '640', '652', '718', '734', '867', '946', '948', '1003', '891');

---Change the data type of funding column from VARCHAR to BIGINT. 
ALTER TABLE unicorn_companies_dup 
ALTER COLUMN funding TYPE BIGINT
USING funding::BIGINT;

---Remove the '$ and 'B' sign from the "valuation" column.
UPDATE unicorn_companies_dup
SET valuation = REPLACE (valuation, '$', '');

UPDATE unicorn_companies_dup
SET valuation = REPLACE (valuation, 'B', '000');

UPDATE unicorn_companies_dup
SET valuation = REPLACE (valuation, '000', '000000000');

---Remove the '$', 'M' and 'B' sign from the "funding" column.
UPDATE unicorn_companies_dup
SET funding = REPLACE (funding, '$', '');

UPDATE unicorn_companies_dup
SET funding = REPLACE (funding, 'M', '000000');

UPDATE unicorn_companies_dup
SET funding = REPLACE (funding, 'B', '000000000');

---trim the whitespaces off column: "company"
SELECT TRIM( BOTH '  ' FROM company) as company
FROM unicorn_companies_dup;

---Splitting the unicorn_investors column
SELECT company, split_part(unicorn_investors, ',' , 1) AS first_investor,
       split_part(unicorn_investors, ',' , 2) AS second_investor,
	   split_part(unicorn_investors, ',' , 3) AS third_investor,
	   split_part(unicorn_investors, ',' , 4) AS fourth_investor
FROM unicorn_companies_dup;

/*Exploratory Data Analysis*/
---What is the total valuation?
SELECT SUM(valuation)
FROM unicorn_companies_dup;

---What is the total funding?
SELECT SUM(funding)
FROM unicorn_companies_dup;

---How many investors do the unicorn companies have?
SELECT COUNT(DISTINCT(unicorn_investors))
FROM Unicorn_companies_dup;

---How many companies are listed as unicorn?
SELECT COUNT(DISTINCT(company))
FROM unicorn_companies_dup;

---How many countries have unicorn companies?
SELECT COUNT(DISTINCT(country))
FROM unicorn_companies_dup;

---How many industries have unicorn companies?
SELECT COUNT(DISTINCT(industry))
FROM unicorn_companies_dup;

---Which companies had the highest valuation? 
SELECT id, company, MAX(valuation) AS value 
FROM unicorn_companies_dup
GROUP BY id, country, company
ORDER BY id, value ASC
LIMIT 10;

---Which industries had the highest funding?
SELECT id, industry, MAX(funding) AS funds
FROM unicorn_companies_dup
GROUP BY id, industry
ORDER BY id,funds ASC
LIMIT 10;

---Which investors have funded the most unicorns?
SELECT id, split_part(unicorn_investors, ',', 1) AS unicorn_invest, MAX(valuation) AS unicorn
FROM unicorn_companies_dup
GROUP BY id, unicorn_investors
ORDER BY id, unicorn_invest, unicorn ASC
LIMIT 10;

---Which unicorn companies have had the biggest return on investment?
SELECT id, company, valuation/Nullif(funding, 0) * 100 AS ROI
FROM unicorn_companies_dup
ORDER BY id, ROI ASC
LIMIT 10;

---Which countries have the most unicorns? 
SELECT country, MAX(company) AS unicorn
FROM unicorn_companies_dup
GROUP BY country
ORDER BY unicorn DESC
LIMIT 10;

---Are there any cities that appear to be industry hubs?
SELECT city, COUNT(industry) AS Hub
FROM unicorn_companies_dup
GROUP BY city
HAVING COUNT(industry) >1
ORDER BY Hub DESC
LIMIT 10;

---Which investors are the most represented in the dataset?
SELECT split_part(unicorn_investors, ',', 1) AS first_investor, split_part(unicorn_investors, ',', 2) AS second_investor, 
       split_part(unicorn_investors, ',', 3) AS third_investor
FROM unicorn_companies_dup
GROUP BY unicorn_investors
HAVING COUNT(unicorn_investors) >1;

---How long does it usually take for a company to become a unicorn?
SELECT company, valuation, year_founded, EXTRACT(YEAR FROM date_joined) AS year_joined
FROM unicorn_companies_dup
GROUP BY company, valuation, year_founded, date_joined
HAVING MAX(Valuation)>1000000000
ORDER BY year_joined DESC;

