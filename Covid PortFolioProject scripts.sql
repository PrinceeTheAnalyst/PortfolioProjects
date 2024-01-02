SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER by 3, 4 

SELECT *
FROM CovidVaccinationss
ORDER BY 3,4

-- Select data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeathsS
ORDER BY 1,2 

--Looking at Total Cases vs Total Deaths
--Shows the liklihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population has got Covid

SELECT location, date, total_cases, population, (total_cases/Population) *100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population)) *100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
Group by location,population
ORDER BY PercentPopulationInfected desc  

--Showing Countries with the Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
Group by location
ORDER BY TotalDeathCount desc  

----Let's Break Things Down By Continent

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent IS  NOT NULL
Group by continent
ORDER BY TotalDeathCount desc  

--Global Numbers

SELECT location, date, total_cases, population, (total_cases/Population) *100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

SELECT *
FROM CovidVaccinationss

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinationss vac
ON dea.location = vac.location 
AND dea.date = dea.date
WHERE dea.continent is not null
ORDER BY 1,2,3
   
--Use CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinationss vac 
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
 )
 SELECT *, (RollingPeopleVaccinated/population) * 100
 FROM PopVsVac

 --TEMP TABLE

 CREATE Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinationss vac 
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population) * 100
 FROM #PercentPopulationVaccinated

 --Adding a Drop Table to enable editing

 DROP Table if exists #PercentPopulationVaccinated
 CREATE Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinationss vac 
ON dea.location = vac.location 
AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population) * 100
 FROM #PercentPopulationVaccinated

 --Creating View to store data for later visualization

 CREATE VIEW PercentPopulationVaccinated AS 
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinationss vac 
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated