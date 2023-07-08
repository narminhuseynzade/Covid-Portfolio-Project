
-- Looking at Total Cases vs Total Death, Death Percentage
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Order By 1,2

-- Shows what percentage of Azerbaijan population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
WHERE location = 'Azerbaijan'
Order By 1,2

-- Looking at Countries with Highest Infection Rate compared to population
Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group By location, population
Order By PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select location, max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not Null
Group By location
order by HighestDeathCount desc

-- LET`S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is Not Null
Group By continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select SUM(new_cases) as new_cases,SUM(cast(new_deaths as int)) as new_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentPerDay
From PortfolioProject..CovidDeaths
Where continent is not null


-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.date, dea.location) 
RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
     ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null AND vac.new_vaccinations is not null
ORDER BY 2,3


-- USE CTE 
WITH PopvsVac ( Continent, Location, Date , Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.date, dea.location) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
     ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null AND vac.new_vaccinations is not null
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- USE TEMP TABLE 

DROP TABLE if exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations bigint,
RollingPeopleVaccinated numeric)

Insert Into #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.date, dea.location) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
     ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null AND vac.new_vaccinations is not null

SELECT *, (RollingPeopleVaccinated/Population)*100 AS Percentage
FROM #PercentagePopulationVaccinated


-- CREATING VIEW FOR DATA VISUALIZATION IN TABLEU

Create View PercentPopulationVaccinate as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.date, dea.location) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
     ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null AND vac.new_vaccinations is not null


Select * From PercentPopulationVaccinate

