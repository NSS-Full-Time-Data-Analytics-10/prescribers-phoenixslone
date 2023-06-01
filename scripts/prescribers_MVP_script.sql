--1a. Which prescriber had the highest total number of claims (totaled over all drugs)? 
--Report the npi and the total number of claims.  
--good
SELECT prescriber.npi, SUM(total_claim_count) AS highest_claim_count --SUM to find the total # of claims
FROM prescriber
INNER JOIN prescription
ON prescriber.npi = prescription.npi
GROUP BY prescriber.npi 
ORDER BY highest_claim_count DESC;

--better
SELECT npi, SUM(total_claim_count) AS claims
FROM prescription
GROUP BY npi
ORDER BY claims DESC;
-- A: Prescriber with the NPI 1881634483 had 99,707 claims.

--1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,
--specialty_description, and the total number of claims. 
SELECT nppes_provider_first_name AS first_name,
	   nppes_provider_last_org_name AS last_name, 
	   specialty_description,                                                                                                                                 
	   SUM(total_claim_count) AS sum_claim_count 
FROM prescription
LEFT JOIN prescriber
ON prescription.npi = prescriber.npi
GROUP BY first_name, last_name, specialty_description
ORDER BY sum_claim_count DESC;
--LEFT JOIN on prescription because we are only interested in the prescribers who have claims. 
--A: Bruce Pendley with 99,707 claims

--2a. Which specialty had the most total number of claims (totaled over all drugs)? 
SELECT DISTINCT specialty_description, SUM(total_claim_count) AS sum_num_of_claims
FROM prescriber
INNER JOIN prescription
ON prescriber.npi = prescription.npi
GROUP BY specialty_description
ORDER BY sum_num_of_claims DESC;
----A: Family Practice with 9,752,347 claims

--2b. Which specialty had the most total number of claims for opioids?
SELECT specialty_description, drug.opioid_drug_flag, SUM(total_claim_count) AS sum_claims
FROM prescriber
INNER JOIN prescription
ON prescriber.npi = prescription.npi
INNER JOIN drug
USING (drug_name)
WHERE opioid_drug_flag = 'Y' 
GROUP BY prescriber.specialty_description, drug.opioid_drug_flag
ORDER BY sum_claims DESC;
-- A: Nurse Practitioner with 900,845 claims

--2c.**Challenge Question:** Are there any specialties that appear in the prescriber table that have no 
--associated prescriptions in the prescription table? 
SELECT npi, specialty_description, drug_name
FROM prescriber
LEFT JOIN prescription
USING (npi)
WHERE drug_name IS NULL
ORDER BY specialty_description;
--A: 4458 specialties that have no associated prescriptions

SELECT p1.specialty_description, SUM(p2.total_claim_count) AS claims
FROM prescriber as p1
FULL JOIN prescription as p2
ON p1.npi = p2.npi
GROUP BY specialty_description
HAVING SUM(p2.total_claim_count) IS NULL;
--A: 15 specialties that have no associated prescriptions

--2d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* 
--For each specialty, report the percentage of total claims by that specialty which are for opioids. 
--Which specialties have a high percentage of opioids?
SELECT DISTINCT p1.specialty_description, d.opioid_drug_flag, ((COUNT (p2.total_claim_count)/SUM(p2.total_claim_count))*100) AS percent_claims
FROM prescriber AS p1
CROSS JOIN drug AS d
INNER JOIN prescription AS p2
USING (npi)
WHERE d.opioid_drug_flag = 'Y'
GROUP BY p1.specialty_description, d.opioid_drug_flag
ORDER BY percent_claims;

--3a. Which drug (generic_name) had the highest total drug cost?
SELECT d.generic_name, MONEY(SUM(p.total_drug_cost)) AS total_cost
FROM drug AS d
INNER JOIN prescription AS p
USING (drug_name)
GROUP BY d.generic_name
ORDER BY total_cost DESC;
--A: INSULIN GLARGINE,HUM.REC.ANLOG cost = $104,264,066.35

--3b. Which drug (generic_name) has the hightest total cost per day? 
--**Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
SELECT d.generic_name, ROUND(SUM(p.total_drug_cost)/SUM(p.total_day_supply), 2) AS daily_cost
FROM drug AS d
INNER JOIN prescription AS p
USING (drug_name)
GROUP BY d.generic_name
ORDER BY daily_cost DESC;
-- A:C1 Esterase Inhibitor cost per day = $3,495.22

--4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says
--'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have 
--antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs
SELECT drug_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither' END AS drug_type
FROM drug;

--4b.Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost)
--on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT MONEY(SUM(total_drug_cost)),
CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
END AS drug_type
FROM drug
LEFT JOIN prescription
ON drug.drug_name = prescription.drug_name
GROUP BY drug_type;
-- A: Opioid = $105,080,626.37  Antibiotic = $38,435,121.26   Neither = $2,972,698,710.23

--5a. How many CBSAs are in Tennessee? **Warning:** 
--The cbsa table contains information for all states, not just Tennessee.
SELECT COUNT(DISTINCT cbsa), cbsaname
FROM cbsa
WHERE cbsaname LIKE '%TN%'
GROUP BY cbsaname;
-- A: 10 cbsa in TN
--DISTINCT is needed because a cbsa can be in multiple counties

--5b. Which cbsa has the largest combined population? Which has the smallest? 
--Report the CBSA name and total population. 
SELECT c.cbsa, c.cbsaname, SUM(p.population) largest_combined_pop
FROM cbsa AS c
INNER JOIN population AS p
ON c.fipscounty = p.fipscounty
GROUP BY c.cbsa, c.cbsaname
ORDER BY largest_combined_pop DESC;
----A: Largest= Nashville-Davidson--Murfreesboro--Franklin,TN 1,830,410
--     Smallest= Morristown,TN 116,352

--5c.What is the largest (in terms of population) county which is not included in a CBSA? 
--Report the county name and population. 
SELECT fp.county, MAX(p.population) AS largest_pop
FROM fips_county AS fp
INNER JOIN population AS p
ON fp.fipscounty = p.fipscounty
WHERE fp.fipscounty NOT IN
	(SELECT fipscounty
	FROM cbsa)
GROUP BY fp.county
ORDER BY largest_pop DESC;
--A: Sevier = 95,523

--6a. Find all rows in the prescription table where total_claims is at least 3000. 
--Report the drug_name and the total_claim_count.
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

--6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT prescription.drug_name, prescription.total_claim_count, drug.opioid_drug_flag
FROM prescription
LEFT JOIN drug
USING (drug_name)
WHERE total_claim_count >= 3000 AND opioid_drug_flag = 'Y';
-- Shows only the drugs (2) that have claim counts higher than 3000 and were flagged with opioids 

SELECT drug_name,total_claim_count,
CASE WHEN opioid_drug_flag='Y' THEN 'opioid'
     ELSE 'Not_opioid' END AS category
FROM prescription
INNER JOIN drug
USING (drug_name)
WHERE total_claim_count>=3000
ORDER BY total_claim_count DESC;
-- Shows the entire chart from 6a that includes 9 drugs and shows whether opiods were flagged or not

--6c. Add another column to you answer from the previous part which gives the prescriber first and 
--last name associated with each row.
SELECT prescription.drug_name,
	   prescription.total_claim_count, 
	   drug.opioid_drug_flag, 
	   prescriber.nppes_provider_first_name,
	   prescriber.nppes_provider_last_org_name
FROM prescription
INNER JOIN drug
ON prescription.drug_name = drug.drug_name
LEFT JOIN prescriber
ON prescription.npi = prescriber.npi
WHERE prescription.total_claim_count >= 3000 AND drug.opioid_drug_flag = 'Y';

--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville
--and the number of claims they had for each opioid. 
--**Hint:** The results from all 3 parts will have 637 rows.
--a. First, create a list of all npi/drug_name combinations for pain management specialists 
--(specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'),
--where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running
--it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
SELECT p.npi,d.drug_name,d.opioid_drug_flag, p.specialty_description 
FROM prescriber AS p
CROSS JOIN drug AS d
WHERE p.specialty_description = 'Pain Management' AND 
	  p.nppes_provider_city = 'NASHVILLE' AND
	  d.opioid_drug_flag = 'Y';

--b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations,
--whether or not the prescriber had any claims. You should report the npi, the drug name, and the number
--of claims (total_claim_count).
SELECT prescriber.npi, drug_name, total_claim_count
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
USING(npi, drug_name)
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
ORDER BY drug_name;

--c.Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
SELECT prescriber.npi, drug_name, COALESCE(total_claim_count,0)
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
USING(npi, drug_name)
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
ORDER BY drug_name;