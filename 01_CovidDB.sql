/*
=================================================================
DATABASE CREATION IN SYSTEM
=================================================================
*/ 

IF NOT EXISTS (
      SELECT name
      FROM sys.databases
      WHERE name = N'Covid_DB'
      )
   CREATE DATABASE [Covid_DB];
GO

IF SERVERPROPERTY('ProductVersion') > '12'
   ALTER DATABASE [Covid_DB] SET QUERY_STORE = ON;
GO

/*
=================================================================
USE CovidDB DATABASE
=================================================================
*/ 

USE Covid_DB;

/*
=================================================================
DATA UNDERSTANDING QUERIES 
=================================================================
*/ 

/*
This query looks into the CovidDeaths table to better understand the data we are working with.
Columns: All columns in CovidDeaths table
*/
SELECT*FROM CovidDeaths 
WHERE continent IS NOT NULL
ORDER BY location, date;

/*
This query looks into CovidVaccinations table to better understand the data we are working with. 
Columns: All columns in CovidVaccinations table
*/
SELECT*FROM CovidVaccinations 
WHERE continent IS NOT NULL
ORDER BY location, date;

/*
This query get the timeline of the data we are working with where MIN(date) is the start date and the MAX(date) is the last date found in the data. 
Column: date
*/
SELECT MIN(date) AS data_start_date, MAX(date) AS data_last_updated
FROM CovidDeaths; 

/*
This query compares the number of countries we are working with in both tables. 
Column: location
Tables: CovidDeath and CovidVaccinations
*/
-- CovidDeaths table
SELECT COUNT(DISTINCT location) AS "Number of Countries in CovidDeaths Table"
FROM CovidDeaths
WHERE location IS NOT NULL AND continent IS NOT NULL;
-- CovidVaccinations table
SELECT COUNT(DISTINCT location) AS "Number of Countries in CovidVaccinations Table"
FROM CovidVaccinations
WHERE location IS NOT NULL AND continent IS NOT NULL;

/*
There are NULL values in continents. This query checks the locations which has NULL continents. 
Column: location 
Tables: CovidDeath and CovidVaccinations
*/
-- CovidDeaths table
SELECT DISTINCT (location)
FROM CovidDeaths
WHERE continent IS NULL; 
-- CovidVaccinations table
SELECT DISTINCT (location)
FROM CovidVaccinations
WHERE continent IS NULL; 

/*
This query aims to have a view of when COVID-19 was first discovered out of China. We will look at the top 10 countries first. 
Columns: date, location, population, total_cases, new_cases, total_deaths 
*/
SELECT TOP 10
    date, location, population, total_cases, new_cases, total_deaths 
FROM CovidDeaths
WHERE 
    continent IS NOT NULL 
    AND total_cases >= 1 
    AND location <> 'China'
ORDER BY 1,2;

/*
This query finds out the daily death percentage when contracted with COVID-19 in respective countries. 
Columns: date, location, continent, total_cases, total_deaths 
*/
SELECT 
    date, 
    location, 
    continent, 
    total_cases, 
    total_deaths, 
    ROUND((CAST(total_deaths AS FLOAT)/total_cases)*100, 2) AS "Death Percentage"
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 2,1;

/*
This query finds out the country with the highest death percentage for the month when contracted COVID-19 in 2020 and sort them by month using Common Table Expression (CTE). 
Columns: date, location, total_cases, total_deaths
*/
WITH DeathPercentageData AS (
    SELECT
        DATEPART(YEAR, date) AS 'Year',
        DATEPART(MONTH, date) AS 'Month',
        location,
        SUM(total_cases) AS total_cases,
        SUM(total_deaths) AS total_deaths,
        ROUND(SUM(CAST(total_deaths AS FLOAT)) / SUM(total_cases) * 100, 2) AS 'Death Percentage'
    FROM CovidDeaths
    WHERE
        continent IS NOT NULL
        AND DATEPART(YEAR, date) = 2020
    GROUP BY
        DATEPART(YEAR, date),
        DATEPART(MONTH, date),
        location
)

SELECT
    dpd.[Year],
    dpd.[Month],
    dpd.location,
    MAX(total_cases) AS 'Total COVID-19 Cases',
    MAX(total_deaths) AS 'Total Death Cases',
    MAX([Death Percentage]) AS 'Death Percentage'
FROM
    DeathPercentageData dpd
GROUP BY
    dpd.[Year],
    dpd.[Month],
    dpd.location
ORDER BY 2 ASC, 5 DESC;

/*
This query finds out the monthly death percentage when contracted COVID-19 in respective countries in 2021 and sort them by month. 
Columns: date, location, total_cases, total_deaths
*/
-- Using CTE to calculate the death percentage 
WITH DeathPercentageData AS (
    SELECT
        DATEPART(YEAR, date) AS 'Year',
        DATEPART(MONTH, date) AS 'Month',
        location,
        SUM(total_cases) AS total_cases,
        SUM(total_deaths) AS total_deaths,
        ROUND(SUM(CAST(total_deaths AS FLOAT)) / SUM(total_cases) * 100, 2) AS 'Death Percentage'
    FROM
        CovidDeaths
    WHERE
        continent IS NOT NULL
        AND DATEPART(YEAR, date) = 2020
    GROUP BY
        DATEPART(YEAR, date),
        DATEPART(MONTH, date),
        location
)

-- Main Query
SELECT
    dpd.[Year],
    dpd.[Month],
    dpd.location,
    MAX(total_cases) AS 'Total COVID-19 Cases',
    MAX(total_deaths) AS 'Total Death Cases',
    MAX([Death Percentage]) AS 'Death Percentage'
FROM
    DeathPercentageData dpd
GROUP BY
    dpd.[Year],
    dpd.[Month],
    dpd.location
ORDER BY 2 ASC, 5 DESC;

/*
This query looks into the percentage of COVID-19 positive cases to the population in the respective countries DAILY in 2020
Columns: date, location, total_cases, population
*/
SELECT
    date, 
    continent, 
    location, 
    total_cases, 
    population,
    (CAST(total_cases AS FLOAT)/population)*100 AS 'Percentage of COVID-19 Positive'
FROM CovidDeaths 
WHERE 
    continent IS NOT NULL
    AND DATEPART(YEAR, date) = 2020
GROUP BY date, continent, location, total_cases, population
ORDER BY 1 ASC, 4 DESC; 

/*
This query looks into the percentage of COVID-19 positive cases to the population in the respective countries MONTHLY in 2020
Columns: date, continent, location, total_cases, population
*/
SELECT
    DATEPART(YEAR, date) AS 'Year', 
    DATEPART(MONTH, date) AS 'Month', 
    continent, 
    location, 
    SUM(total_cases) AS 'Total Cases', 
    population, 
    SUM(CAST(total_cases AS FLOAT))/population*100 AS 'Percentage of COVID-19 Positive'
FROM CovidDeaths
WHERE
    continent IS NOT NULL 
    AND DATEPART(YEAR, date) = 2020
GROUP BY DATEPART(YEAR, date), DATEPART(MONTH, date), continent, location, population
ORDER BY DATEPART(MONTH, date) ASC, SUM(total_cases) DESC;

/*
This query looks into the percentage of COVID-19 positive cases to the population in the respective countries DAILY in 2021
Columns: date, location, total_cases, population
*/
SELECT
    date, 
    continent, 
    location, 
    total_cases, 
    population,
    (CAST(total_cases AS FLOAT)/population)*100 AS 'Percentage of COVID-19 Positive'
FROM CovidDeaths 
WHERE 
    continent IS NOT NULL
    AND DATEPART(YEAR, date) = 2021
GROUP BY date, continent, location, total_cases, population
ORDER BY 1 ASC, 4 DESC; 

/*
This query looks into the percentage of COVID-19 positive cases to the population in the respective countries MONTHLY in 2021
Columns: date, continent, location, total_cases, population
*/
SELECT
    DATEPART(YEAR, date) AS 'Year', 
    DATEPART(MONTH, date) AS 'Month', 
    continent, 
    location, 
    SUM(total_cases) AS 'Total Cases', 
    population, 
    ROUND(SUM(CAST(total_cases AS FLOAT))/population*100,2) AS 'Percentage of COVID-19 Positive'
FROM CovidDeaths
WHERE
    continent IS NOT NULL 
    AND DATEPART(YEAR, date) = 2021
GROUP BY DATEPART(YEAR, date), DATEPART(MONTH, date), continent, location, population
ORDER BY DATEPART(MONTH, date) ASC, SUM(total_cases) DESC;

/*
This query looks at the countries with the highest infection rate per population from 1 Jan 2020 to 30 Apr 2021
Columns: continent, location, population, total_cases 
*/
SELECT 
    continent,
    location, 
    population, 
    MAX(total_cases) AS "Highest Infection Cases", 
    MAX((CAST(total_cases AS FLOAT)/population)*100) AS "Percentage of Population Infected"
FROM CovidDeaths 
WHERE continent IS NOT NULL 
GROUP BY continent, location, population
ORDER BY "Percentage of Population Infected" DESC;

/*
This query looks at the countries with the highest infection rate per population in 2020
Columns: continent, location, population, total_cases 
*/
SELECT 
    DATEPART(YEAR, date) AS 'Year',
    continent,
    location, 
    population, 
    MAX(total_cases) AS "Highest Infection Cases", 
    MAX((CAST(total_cases AS FLOAT)/population)*100) AS "Percentage of Population Infected"
FROM CovidDeaths 
WHERE 
    continent IS NOT NULL 
    AND DATEPART(YEAR, date) = 2020
GROUP BY DATEPART(YEAR, date), continent, location, population
ORDER BY "Percentage of Population Infected" DESC;

/*
This query looks at the countries with the highest infection rate per population in 2021
Columns: continent, location, population, total_cases 
*/
SELECT 
    DATEPART(YEAR, date) AS 'Year',
    continent,
    location, 
    population, 
    MAX(total_cases) AS "Highest Infection Cases", 
    MAX((CAST(total_cases AS FLOAT)/population)*100) AS "Percentage of Population Infected"
FROM CovidDeaths 
WHERE 
    continent IS NOT NULL 
    AND DATEPART(YEAR, date) = 2021
GROUP BY DATEPART(YEAR, date), continent, location, population
ORDER BY "Percentage of Population Infected" DESC;

/*
This query gives an overview of the continents with the highest infection rate per population in 2020
Columns: date, continent, population, total_cases
*/ 
SELECT
    DATEPART(YEAR, date) AS 'Year', 
    continent, 
    SUM(population) AS 'Population', 
    SUM(total_cases) AS 'Total Cases',
    ROUND(SUM(CAST(total_cases AS FLOAT))/ SUM(Population)*100,2) AS 'Percentage of Population Infected'
FROM CovidDeaths 
WHERE 
    continent IS NOT NULL
    AND DATEPART(YEAR, date) = 2020
GROUP BY DATEPART(YEAR, date), continent 
ORDER BY [Percentage of Population Infected] DESC; 

/*
This query gives an overview of the continents with the highest infection rate per population in 2021
Columns: date, continent, population, total_cases, population
*/ 
SELECT
    DATEPART(YEAR, date), 
    continent, 
    SUM(population) AS 'Population', 
    SUM(total_cases) AS 'Total Cases',
    ROUND(SUM(CAST(total_cases AS FLOAT))/ SUM(Population)*100,2) AS 'Percentage of Population Infected'
FROM CovidDeaths 
WHERE 
    continent IS NOT NULL
    AND DATEPART(YEAR, date) = 2021
GROUP BY DATEPART(YEAR, date), continent 
ORDER BY [Percentage of Population Infected] DESC; 

/*
This query looks at the countries with the highest death count per population from 1 Jan 2020 to 30 Apr 2021
Columns: date, location, total_cases, population
*/
SELECT 
    location, 
    MAX(total_deaths) AS total_deaths_count,
    MAX((CAST(total_deaths AS FLOAT)/population)*100) AS 'Percentage of Death Caused'
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY [Percentage of Death Caused] DESC;

/*
This query looks at the countries with the highest death count per population in 2020
Columns: date, location, total_cases, population
*/
SELECT 
    DATEPART(YEAR, date) AS 'Year', 
    location, 
    MAX(total_deaths) AS total_deaths_count,
    MAX((CAST(total_deaths AS FLOAT)/population)*100) AS 'Percentage of Death Caused'
FROM CovidDeaths
WHERE 
    continent IS NOT NULL
    AND DATEPART(YEAR, date) = 2020
GROUP BY DATEPART(YEAR, date), location
ORDER BY [Percentage of Death Caused] DESC;

/*
This query looks at the countries with the highest death count per population in 2021
Columns: date, location, total_cases, population
*/
SELECT 
    DATEPART(YEAR, date) AS 'Year', 
    location, 
    MAX(total_deaths) AS total_deaths_count,
    MAX((CAST(total_deaths AS FLOAT)/population)*100) AS 'Percentage of Death Caused'
FROM CovidDeaths
WHERE 
    continent IS NOT NULL
    AND DATEPART(YEAR, date) = 2021
GROUP BY DATEPART(YEAR, date), location
ORDER BY [Percentage of Death Caused] DESC;

/*
This query looks at continents with the highest death count
Columns: continent, total_deaths
*/
SELECT 
    continent, 
    MAX(total_deaths) AS 'Total Deaths Count'
FROM CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY [Total Deaths Count] DESC; 

/*
This query looks at the Death percentage on a global level
Columns: new_deaths, new_cases
*/ 
SELECT
    SUM(new_deaths) AS 'Total Deaths', 
    SUM(new_cases) AS 'Total Cases', 
    ROUND(SUM(CAST(new_deaths AS FLOAT))/SUM(total_cases)*100,2) AS 'Global Death Percentage'
FROM CovidDeaths 
WHERE continent IS NOT NULL 
ORDER BY [Total Cases]; 
 
/*
This query gives an overview of the people vaccinated (at least had 1 vaccination completed) out of the entire population in the respective countries. 
Using Common Table Expression (CTE) and JOIN 
Columns: continent, location, population, new_vaccinations, date
*/ 
-- Creation of CTE table
WITH PopulationVaccinated(continent, location, population, [People Vaccinated])
AS (
SELECT
    dea.continent, 
    dea.location, 
    MAX(dea.population) AS 'Population', -- One row one location
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location) AS 'People Vaccinated'
FROM CovidDeaths dea 
JOIN CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, dea.location, vac.new_vaccinations
)

-- Main query for CTE table
SELECT 
    location, 
    MAX(continent) AS continent, -- One row one location
    MAX(population) AS population, -- One row one location
    MAX([People Vaccinated]) AS 'People Vaccinated', -- One row one location
    CAST(MAX([People Vaccinated]) AS FLOAT) / MAX(population) * 100 AS 'Percentage of People Vaccinated'
FROM PopulationVaccinated
GROUP BY location
ORDER BY population DESC;

/*
Create temporary table named #PercentPopulationVaccinated instead of creating an actual table that will exist in Database. 
It will show an overview of the percentage of the population that gets vaccinated daily. 
*/
-- Create table
DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated (
    continent NVARCHAR(255), 
    location NVARCHAR(255), 
    date DATETIME, 
    population NUMERIC, 
    new_vaccinations NUMERIC,  
    RollingPeopleVaccinated NUMERIC
); 

-- Insert values from CovidDeaths table into temporary table named #PercentPopulationVaccinated 
INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea 
JOIN CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL; 

-- Show the result of the population vaccinated from temporary table named #PercentPopulationVaccinated DAILY
SELECT *, ROUND((CAST(RollingPeopleVaccinated AS FLOAT)/population)*100,2) AS 'Percentage of Population Vaccinated'
FROM #PercentPopulationVaccinated; 

/*
=================================================================
CREATE VIEWS
=================================================================
*/

/*
Create a view that shows the percentage of the population that gets vaccinated daily
Table Type: View
*/
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea 
JOIN CovidVaccinations vac ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL; 

-- SELECT*FROM PercentPopulationVaccinated;

/*
Create a view that reflects the percentage of COVID-19 positive cases to the population in the respective countries MONTHLY in 2020
Table Type: View
*/
CREATE VIEW MonthlyPositiveStats2020 AS 
SELECT
    DATEPART(YEAR, date) AS 'Year', 
    DATEPART(MONTH, date) AS 'Month', 
    continent, 
    location, 
    SUM(total_cases) AS 'Total Cases', 
    population, 
    SUM(CAST(total_cases AS FLOAT))/population*100 AS 'Percentage of COVID-19 Positive'
FROM CovidDeaths
WHERE
    continent IS NOT NULL 
    AND DATEPART(YEAR, date) = 2020
GROUP BY DATEPART(YEAR, date), DATEPART(MONTH, date), continent, location, population;
--ORDER BY DATEPART(MONTH, date) ASC, SUM(total_cases) DESC;

-- SELECT*FROM MonthlyPositiveStats2020;

/*
Create a view that reflects the percentage of COVID-19 positive cases to the population in the respective countries MONTHLY in 2021
Table Type: View
*/
CREATE VIEW MonthlyPositiveStats2021 AS 
SELECT
    DATEPART(YEAR, date) AS 'Year', 
    DATEPART(MONTH, date) AS 'Month', 
    continent, 
    location, 
    SUM(total_cases) AS 'Total Cases', 
    population, 
    ROUND(SUM(CAST(total_cases AS FLOAT))/population*100,2) AS 'Percentage of COVID-19 Positive'
FROM CovidDeaths
WHERE
    continent IS NOT NULL 
    AND DATEPART(YEAR, date) = 2021
GROUP BY DATEPART(YEAR, date), DATEPART(MONTH, date), continent, location, population;
-- ORDER BY DATEPART(MONTH, date) ASC, SUM(total_cases) DESC;

-- SELECT*FROM MonthlyPositiveStats2021;

/*
Create a view to reflect the highest infection rate per population in 2020
Table Type: View
*/
CREATE VIEW HighestInfectionRate2020 AS 
SELECT 
    DATEPART(YEAR, date) AS 'Year',
    continent,
    location, 
    population, 
    MAX(total_cases) AS "Highest Infection Cases", 
    MAX((CAST(total_cases AS FLOAT)/population)*100) AS "Percentage of Population Infected"
FROM CovidDeaths 
WHERE 
    continent IS NOT NULL 
    AND DATEPART(YEAR, date) = 2020
GROUP BY DATEPART(YEAR, date), continent, location, population;
-- ORDER BY "Percentage of Population Infected" DESC;

-- SELECT*FROM HighestInfectionRate2020;

/*
Create a view to reflect the highest infection rate per population in 2021
Table Type: View
*/
CREATE VIEW HighestInfectionRate2021 AS 
SELECT 
    DATEPART(YEAR, date) AS 'Year',
    continent,
    location, 
    population, 
    MAX(total_cases) AS "Highest Infection Cases", 
    MAX((CAST(total_cases AS FLOAT)/population)*100) AS "Percentage of Population Infected"
FROM CovidDeaths 
WHERE 
    continent IS NOT NULL 
    AND DATEPART(YEAR, date) = 2021
GROUP BY DATEPART(YEAR, date), continent, location, population; 
-- ORDER BY "Percentage of Population Infected" DESC;

/*
Create a view that looks at the Death percentage on a global level from 1 Jan 2020 to 30 Apr 2021
Table type: View
*/ 
CREATE VIEW GlobalDeathPercentage AS
SELECT
    SUM(new_deaths) AS 'Total Deaths', 
    SUM(new_cases) AS 'Total Cases', 
    ROUND(SUM(CAST(new_deaths AS FLOAT))/SUM(total_cases)*100,2) AS 'Global Death Percentage'
FROM CovidDeaths 
WHERE continent IS NOT NULL;
-- ORDER BY [Total Cases]; 