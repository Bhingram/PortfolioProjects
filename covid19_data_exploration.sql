/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

--- Selects Data that we are going to be starting with

SELECT location,
				 date,
				 total_cases,
				 new_cases,
				 total_deaths,
				 population
FROM covid_deaths
ORDER BY 1, 2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location,
				 date,
				 total_cases,
				 total_deaths,
				 (CAST (total_deaths AS REAL) / CAST (total_cases AS REAL))*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
	   --AND location = 'United States'
ORDER BY 1, 2

-- Total Cases vs Population
-- Shows the percentage of population that contracted covid

SELECT location,
				 date,
				 total_cases, population,
				 (CAST (total_cases AS REAL) / CAST (population AS REAL))*100 AS case_percentage
FROM covid_deaths
--WHERE location = 'United States'
ORDER BY 1, 2

-- Highest Infection Rate vs Population

SELECT location,
				 MAX(total_cases) AS highest_infection_count, population,
				 MAX((CAST (total_cases AS REAL) / CAST (population AS REAL)))*100 AS highest_infection_percentage
FROM covid_deaths
--WHERE location = 'United States'
GROUP BY location, population
ORDER BY highest_infection_percentage DESC

--Countries with the highest death count per population

SELECT location,
				  MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
       --AND location = 'United Statees'
GROUP BY location
ORDER BY total_death_count DESC

--Continents with the highest death count per population

SELECT continent,
				 MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM covid_deaths
WHERE continent IS  NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

--Global Numbers

SELECT date,
				 SUM(new_cases) AS total_global_cases,
				 SUM(CAST(new_deaths AS INT)) AS total_global_deaths,
				 (CAST(SUM(CAST(new_deaths AS INT)) AS REAL) / CAST(SUM(new_cases) AS REAL)) * 100 AS global_death_percentage
FROM covid_deaths
WHERE continent IS  NOT NULL
GROUP BY date
ORDER BY 1, 2

-- Total Population vs Total Vaccinations
-- Shows percentage of population that has recieved at least one covid vaccine

SELECT dea.continent,
			   dea.location,
				 dea.date,
				 dea.population,
				 vac.new_vaccinations,
				 SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS  NOT NULL

-- Using CTE to perform Calculation on PARTITION BY in previous query

WITH PopvsVac  AS (
		SELECT dea.continent,
						 dea.location,
						 dea.date,
						 dea.population,
						 vac.new_vaccinations,
						 SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
		FROM covid_deaths AS dea
		JOIN covid_vaccinations AS vac
				ON dea.location = vac.location
				AND dea.date = vac.date
		WHERE dea.continent IS  NOT NULL
		)

SELECT *,
				 (CAST(rolling_people_vaccinated  AS REAL) / CAST(population AS REAL)) * 100 AS rolling_people_vaccinated_percentage
FROM PopvsVac

-- Using Temp Table to perform Calculation on PARTITION BY in previous query

DROP TABLE IF EXISTS percent_population_vaccinated

CREATE TABLE percent_population_vaccinated
(
		continent TEXT,
		location TEXT,
		date DATETIME,
		population NUMERIC,
		new vaccinations NUMERIC,
		rolling_people_vaccinated NUMERIC
)

INSERT INTO percent_population_vaccinated
SELECT dea.continent,
				  dea.location,
				  dea.date,
				  dea.population,
				  vac.new_vaccinations,
				  SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
		FROM covid_deaths AS dea
		JOIN covid_vaccinations AS vac
				ON dea.location = vac.location
				AND dea.date = vac.date
		WHERE dea.continent IS  NOT NULL

SELECT *, (CAST(rolling_people_vaccinated  AS REAL) / CAST(population AS REAL)) * 100 AS rolling_people_vaccinated_percentage
FROM percent_population_vaccinated

-- Creating view to store for later visualizations

CREATE VIEW percent_population_vaccinated AS
SELECT dea.continent,
				  dea.location,
				  dea.date,
				  dea.population,
				  vac.new_vaccinations,
				  SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
		FROM covid_deaths AS dea
		JOIN covid_vaccinations AS vac
				ON dea.location = vac.location
				AND dea.date = vac.date
		WHERE dea.continent IS  NOT NULL
