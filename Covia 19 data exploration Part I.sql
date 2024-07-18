-- Check tables:

SELECT * FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

SELECT * FROM PortfolioProject.dobo.CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3, 4

-- Select Data that will be used:

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Looking at total_cases vs total_deaths:
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
AND continent IS NOT NULL
ORDER BY 1, 2

-- Looking at total_cases vs population

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%state%'
AND continent IS NOT NULL
ORDER BY 1, 2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC
	
-- Showing countries with highest death count per population

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent Is Not Null
GROUP BY location
ORDER BY TotalDeathCount DESC
	
-- Let's break things down by continent

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent Is Null
GROUP BY location
ORDER BY TotalDeathCount DESC
	
-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC
	
-- Global numbers
-- Check daily cases & death by date
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(CAST(new_cases AS int))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent Is Not Null
GROUP BY date
ORDER BY 1, 2
	
-- Check total cases & death by date
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(CAST(new_cases AS int))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent Is Not Null
GROUP BY date
ORDER BY 1, 2
	
-- Join tables
-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100 
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent Is Not Null
ORDER BY 2, 3
	
-- Use CTE
-- Looking at total population vs vaccinations

With PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100 
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/population)*100 
	
-- Temp Table

Drop Table If Exists #PercentPopulationVaccinated
	
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vacciantion AS int)) OVER (PARTITION BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolioproject.ado.CovidDeaths dea
JOIN Portfolioproject.ado.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated
	
-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
	
SELECT * FROM PercentPopulationVaccinated
