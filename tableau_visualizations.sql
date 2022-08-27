SELECT SUM(new_cases) AS total_global_cases, 
				 SUM(CAST(new_deaths AS INT)) AS total_global_deaths, 
				 (CAST(SUM(CAST(new_deaths AS INT)) AS REAL) / CAST(SUM(new_cases) AS REAL)) * 100 AS global_death_percentage
FROM covid_deaths
WHERE continent IS  NOT NULL
--GROUP BY date
ORDER BY 1, 2


SELECT continent, 
				 SUM(CAST(new_deaths AS INT)) AS total_death_count  
FROM covid_deaths
WHERE continent IS  NOT NULL
		AND location NOT IN ('World', 'European Union', 'International')
GROUP BY continent
ORDER BY total_death_count DESC


SELECT location, 
				 population, 
				 MAX(total_cases) AS highest_infection_count, 
				 MAX((CAST (total_cases AS REAL) / CAST (population AS REAL)))*100 AS highest_infection_percentage
FROM covid_deaths
--WHERE location = 'United States'
GROUP BY location, population
ORDER BY highest_infection_percentage DESC

SELECT location, 
				 population, 
				 date,
				 MAX(total_cases) AS highest_infection_count, 
				 MAX((CAST (total_cases AS REAL) / CAST (population AS REAL)))*100 AS highest_infection_percentage
FROM covid_deaths
--WHERE location = 'United States'
GROUP BY location, 
					  population,
					  date
ORDER BY highest_infection_percentage DESC