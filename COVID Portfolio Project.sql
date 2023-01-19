SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in my country
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location='Jamaica'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of the population got Covid
SELECT location, date, total_cases, population, ROUND((total_cases/population)*100, 5) AS CasesByPopulation
FROM PortfolioProject..CovidDeaths
--WHERE location='Jamaica'
ORDER BY 1,2

-- Looking at countried with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, ROUND(MAX((total_cases/population))*100,2) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location='Jamaica'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths AS int )) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing Continents with Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths AS int )) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers by date
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, ROUND((SUM(cast(new_deaths AS int))/SUM(new_cases))*100, 2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2

-- Global Numbers overall
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, ROUND((SUM(cast(new_deaths AS int))/SUM(new_cases))*100, 2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccionations
-- USE CTE
WITH PopulationvsVaccinations (Continent, Location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(CONVERT(int,vax.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVax vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is NOT NULL 
)
SELECT *, ROUND((RollingPeopleVaccinated/Population)*100,2) AS RollingPercent
FROM PopulationvsVaccinations
--WHERE RollingPeopleVaccinated is NOT NULL

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(CONVERT(int,vax.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVax vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is NOT NULL 

SELECT *, ROUND((RollingPeopleVaccinated/Population)*100,2) AS RollingPercent
FROM #PercentPopulationVaccinated


-- Create

CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(CONVERT(int,vax.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVax vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is NOT NULL 


