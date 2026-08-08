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
SELECT c.name, i.population, c.area
FROM countries c
JOIN indicators i ON c.iso_code=i.iso_code
WHERE c.area > (SELECT AVG(area) FROM countries)
AND i.population > (SELECT AVG(population) FROM indicators)
ORDER BY i.population DESC;

-- 5. Which country has the highest GDP in each region?
SELECT c.region, c.name, e.gdp
FROM countries c
JOIN economy e ON c.iso_code=e.iso_code
WHERE e.gdp = (
    SELECT MAX(e2.gdp)
    FROM countries c2 
    JOIN economy e2 ON c2.iso_code=e2.iso_code
    WHERE c2.region = c.region
);

-- 6. What are the 10 most densely populated countries?

-- 7. What is the average population density for each region?

-- 8. What is the total and average GDP for each region, organized by total?

-- 9. What are the first and last three characters of every country name?

-- 10. How many countries in each region have an HDI above 0.7?

-- 11. Which countries have a higher life expectancy than the global average?

-- 12. Which countries are missing economic data, and what data do they have?

-- 13. What is the average, highest, and lowest life expectancy for each region?

-- 14. Classify countries by GDP per capita with null handling

-- 15. How many major cities does each region have, and what is their combined population?

-- 16. Which countries have an HDI above the global average?

-- 17. Which development tier does each country fall into based on their HDI?

-- 18. Which countries have missing data for both HDI and GDP?

-- 19. Which countries have a birth rate higher than their region's average?

-- 20. What are the 5 most populated cities in each region?

-- 21. What are the smallest countries by area that still have a major city? (bottom 5)

-- 22. Which country in each region has the lowest life expectancy?

-- 23. Which countries rank highly in HDI or GDP per capita, but not both?

-- 24. What development tier is each capital city's country in?

-- 25. Which countries have a higher GDP than every country in South Asia?

-- BONUS. For each region, find countries that rank in the top 25% for GDP per capita, but in the bottom 25% for HDI within their region
-- Display each country with its region, GDP per capita, HDI, an income classification label, and the average GDP per capita of its region for comparison
-- Only include regions where at least 3 countries meet this criteria.