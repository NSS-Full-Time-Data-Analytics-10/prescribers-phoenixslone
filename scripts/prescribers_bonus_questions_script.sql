--Read Me BONUS Questions
--1. How many npi numbers appear in the prescriber table but not in the prescription table?
(SELECT DISTINCT npi
FROM prescriber)
EXCEPT
(SELECT DISTINCT npi
FROM prescription);
-- A: 4458 rows/npi numbers that are in the prescribers table do not appear in the prescription table.

--2a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.
SELECT DISTINCT npi, generic_name
FROM drug
FULL JOIN prescription
USING (drug_name)
FULL JOIN prescriber
USING (npi)
WHERE specialty_description = 'Family Practice'
GROUP BY generic_name,npi;

--3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
-- a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. 
--Report the npi, the total number of claims, and include a column showing the city.
SELECT DISTINCT npi, total_claim_count,nppes_provider_city
FROM prescription
LEFT JOIN prescriber
USING (npi)
WHERE nppes_provider_city = 'NASHVILLE'
ORDER BY total_claim_count DESC;

-- b. Now, report the same for Memphis.
SELECT DISTINCT npi, total_claim_count,nppes_provider_city
FROM prescription
LEFT JOIN prescriber
USING (npi)
WHERE nppes_provider_city = 'MEMPHIS'
ORDER BY total_claim_count DESC;

-- c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.
SELECT DISTINCT npi, total_claim_count,nppes_provider_city
FROM prescription
LEFT JOIN prescriber
USING (npi)
WHERE nppes_provider_city = 'NASHVILLE' OR 
	  nppes_provider_city = 'NASHVILLE' OR
	  nppes_provider_city = 'KNOXVILLE' OR
	  nppes_provider_city = 'CHATTANOOGA'
ORDER BY total_claim_count DESC;

--4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.
SELECT DISTINCT county, COUNT(overdose_deaths) AS num_overdose
FROM overdose_deaths
CROSS JOIN fips_county
WHERE overdose_deaths > (SELECT AVG(overdose_deaths) AS avg_deaths
						FROM overdose_deaths)
GROUP BY county
ORDER BY num_overdose DESC;
-- A: County = Washington with 2,542 overdoses.

