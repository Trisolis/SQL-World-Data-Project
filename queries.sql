-- SQL queries for answering data-related questions == 

-- 1. What are the largest countries in South America by area?
SELECT name, area 
FROM countries
WHERE region = 'South America'
ORDER BY area DESC;

-- 2. What countries have a high inflation rate (>5%) and low unemployment (<5%)?
SELECT name, inflation, unemployment
FROM economy
WHERE inflation > 5
  AND unemployment < 5
ORDER BY inflation DESC;

-- 3. What countries start with S and have 5 letters? What countries have 'land' in their names?
SELECT name
FROM countries
WHERE name LIKE 'S____' 
   OR name LIKE '%land%';

-- 4. What countries are above average in population and area?
SELECT c.name, population, area
FROM countries c
INNER JOIN indicators i ON c.iso_code=i.iso_code
WHERE area > (SELECT AVG(area) FROM countries)
AND population > (SELECT AVG(population) FROM indicators)
ORDER BY population DESC;

-- 5. Which country has the highest GDP in each region? (ALL not supported)
SELECT region, c.name, gdp
FROM countries c
INNER JOIN economy e ON c.iso_code=e.iso_code
WHERE gdp = (
    SELECT MAX(e2.gdp)
    FROM countries c2 
    INNER JOIN economy e2 ON c2.iso_code=e2.iso_code
    WHERE c2.region = c.region
)
ORDER BY gdp DESC;

-- 6. What are the 10 most densely populated countries?
SELECT name, density
FROM indicators
WHERE density IS NOT NULL
ORDER BY density DESC
LIMIT 10;

-- 7. What is the average population density for each region?
SELECT region, ROUND(AVG(density),2) AS avg_pop_density
FROM countries c
INNER JOIN indicators i ON c.iso_code=i.iso_code
GROUP BY region;

-- 8. What is the total and average GDP for each region, organized by total?
SELECT region, SUM(gdp) AS sum_of_gdp, AVG(gdp) AS avg_gdp
FROM countries c
INNER JOIN economy e ON c.iso_code=e.iso_code
GROUP BY region
ORDER BY SUM(gdp) DESC;

-- 9. What are the first and last three characters of every country name? (LEFT not supported)
SELECT SUBSTRING(name,1,3), SUBSTRING(name,-3)
FROM countries;

-- 10. How many countries in each region have an HDI above 0.7?
SELECT region, COUNT(c.name) AS country_count
FROM countries c
INNER JOIN indicators i ON c.iso_code=i.iso_code
WHERE hdi > 0.7
GROUP BY region
ORDER BY COUNT(c.name) DESC;

-- 11. Which countries have a higher life expectancy than the global average?
SELECT c.name, life_expectancy
FROM countries c
INNER JOIN indicators i ON c.iso_code=i.iso_code
WHERE life_expectancy > (SELECT AVG(life_expectancy) FROM indicators)
ORDER BY life_expectancy DESC;

-- 12. Which countries have missing data for both HDI and GDP?
SELECT c.name
FROM countries c
INNER JOIN economy e ON c.iso_code=e.iso_code
INNER JOIN indicators i ON i.iso_code=e.iso_code
WHERE hdi IS NULL AND gdp IS NULL;

-- 13. What is the average, highest, and lowest life expectancy for each region?
SELECT region, AVG(life_expectancy) AS avg_life_expectancy, MAX(life_expectancy) AS max_life_expectancy, MIN(life_expectancy) AS min_life_expectancy
FROM countries c
INNER JOIN indicators i ON c.iso_code=i.iso_code
GROUP BY region
ORDER BY AVG(life_expectancy) DESC;

-- 14. Classify countries by GDP per capita with null handling
SELECT c.name, gdp_per_capita,
CASE 
    WHEN gdp_per_capita IS NULL THEN 'No data'
    WHEN gdp_per_capita < 4000 THEN  'Low Income'
    WHEN gdp_per_capita < 12000 THEN  'Low Middle Income'
    WHEN gdp_per_capita < 40000 THEN  'High Middle Income'
    ELSE 'High Income'
END AS income_group
FROM countries c 
INNER JOIN economy e ON c.iso_code=e.iso_code;

-- 15. How many major cities does each region have, and what is their combined population?
SELECT region, COUNT(name) AS num_cities, SUM(population) AS sum_of_pop
FROM cities
GROUP BY region
ORDER BY COUNT(name) DESC;

-- 16. Which countries have an HDI above the global average?
SELECT c.name, hdi
FROM countries c
INNER JOIN indicators i ON c.iso_code=i.iso_code
WHERE hdi > (SELECT AVG(hdi) FROM indicators)
ORDER BY hdi DESC;

-- 17. Which development tier does each country fall into based on their HDI?
SELECT c.name, hdi,
CASE 
    WHEN hdi IS NULL THEN 'No data'
    WHEN hdi < 0.550 THEN  'Low Human Development'
    WHEN hdi < 0.700 THEN  'Medium Human Development'
    WHEN hdi < 0.800 THEN  'High Human Development'
    ELSE 'Very High Human Development'
END AS hdi_tier
FROM countries c 
INNER JOIN indicators i ON c.iso_code=i.iso_code;

-- 18. What cities are both their country's capital, and largest city?
SELECT country, name, population
FROM cities c1
WHERE feature_code = 'PPLC' AND population >= (SELECT MAX(population) FROM cities c2 WHERE c1.country=c2.country);

-- 19. Which countries have a birth rate higher than their region's average?
SELECT region, c.name, birth_rate
FROM countries c
INNER JOIN indicators i ON c.iso_code=i.iso_code
WHERE birth_rate > (
    SELECT AVG(i2.birth_rate)
    FROM countries c2 
    INNER JOIN indicators i2 ON c2.iso_code=i2.iso_code
    WHERE c2.region = c.region
)
ORDER BY region, birth_rate DESC;

-- 20. What are the 5 most populated cities in each region?
SELECT co.region, co.name AS country, ci.name AS city, population
FROM countries co
INNER JOIN cities ci ON co.iso_code=ci.iso2
WHERE (
    SELECT COUNT(*)
    FROM countries co2 
    INNER JOIN cities ci2 ON co2.iso_code=ci2.iso2
    WHERE co2.region = co.region
      AND ci2.population > ci.population
) < 5
ORDER BY co.region, population DESC;

-- 21. What are the smallest countries by area that still have a major city? (bottom 5)
SELECT co.name, ci.name, ci.population, area
FROM countries co
INNER JOIN cities ci ON co.iso_code=ci.iso2
WHERE area IS NOT NULL
GROUP BY co.name
ORDER BY area
LIMIT 10;

-- 22. Which country in each region has the lowest life expectancy?
SELECT region, c.name, life_expectancy
FROM countries c
INNER JOIN indicators i ON c.iso_code=i.iso_code
WHERE life_expectancy <= (
    SELECT MIN(i2.life_expectancy)
    FROM countries c2 
    INNER JOIN indicators i2 ON c2.iso_code=i2.iso_code
    WHERE c2.region = c.region
)
ORDER BY life_expectancy;

-- 23. Which countries are above average in HDI or GDP per capita, but not both?
SELECT c.name, hdi, gdp_per_capita
FROM countries c
INNER JOIN indicators i ON c.iso_code=i.iso_code
INNER JOIN economy e ON c.iso_code=e.iso_code
WHERE (
  hdi > (SELECT AVG(hdi) FROM indicators) AND
  NOT gdp_per_capita > (SELECT AVG(gdp_per_capita) FROM economy)
) OR (
  NOT hdi > (SELECT AVG(hdi) FROM indicators) AND
  gdp_per_capita > (SELECT AVG(gdp_per_capita) FROM economy)
)

-- 24. What development tier is each capital city's country in?
SELECT c.name, c.country, hdi,
CASE 
    WHEN hdi IS NULL THEN 'No data'
    WHEN hdi < 0.550 THEN  'Low Human Development'
    WHEN hdi < 0.700 THEN  'Medium Human Development'
    WHEN hdi < 0.800 THEN  'High Human Development'
    ELSE 'Very High Human Development'
END AS hdi_tier
FROM cities c 
INNER JOIN indicators i ON c.iso2=i.iso_code
WHERE feature_code = 'PPLC'
ORDER BY hdi DESC;

-- 25. Which countries have a higher GDP than every country in Africa combined?
SELECT c.name, gdp
FROM countries c
INNER JOIN economy e ON c.iso_code=e.iso_code
WHERE gdp > (SELECT SUM(gdp) FROM countries c2 INNER JOIN economy e2 ON c2.iso_code=e2.iso_code WHERE region = 'Africa')
ORDER BY gdp DESC;

-- BONUS. For each region, find countries that rank in the top 50% for GDP per capita, but in the bottom 50% for HDI within their region
-- Display each country with its region, GDP per capita, HDI, an income classification label, and the average GDP per capita of its region for comparison
-- Only include regions where at least 3 countries meet this criteria.
SELECT c.name, region, gdp_per_capita, hdi, 
(SELECT AVG(gdp_per_capita) FROM countries c2 JOIN economy e2 ON c2.iso_code=e2.iso_code WHERE c2.region=c.region) AS avg_gdp_per_capita_in_region,
CASE 
    WHEN gdp_per_capita IS NULL THEN 'No data'
    WHEN gdp_per_capita < 4000 THEN  'Low Income'
    WHEN gdp_per_capita < 12000 THEN  'Low Middle Income'
    WHEN gdp_per_capita < 40000 THEN  'High Middle Income'
    ELSE 'High Income'
END AS income_group
FROM countries c
JOIN indicators i ON c.iso_code=i.iso_code
JOIN economy e ON c.iso_code=e.iso_code
WHERE (
  hdi > (SELECT AVG(hdi) FROM indicators) AND
  NOT gdp_per_capita > (SELECT AVG(gdp_per_capita) FROM economy)
) OR (
  NOT hdi > (SELECT AVG(hdi) FROM indicators) AND
  gdp_per_capita > (SELECT AVG(gdp_per_capita) FROM economy)
);