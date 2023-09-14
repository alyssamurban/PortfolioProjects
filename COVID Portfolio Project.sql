select *
from CovidDeaths
where continent is not null
order by 3,4

--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your country.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states'
order by 1, 2

--Total Cases vs Population
--Shows percentage of poplulation who contracted Covid
select location, date, total_cases, population, (total_cases/population)*100 as Percentage
from CovidDeaths
where location like '%states'
order by 1, 2

--Countries with Highest Infection Rate compared to population
select location, MAX(total_cases) as HighestInfectionCount, population, (MAX(total_cases)/population)*100 as PercentageofPopulationInfected
from CovidDeaths
group by Location, Population
order by PercentageofPopulationInfected desc

--Countries with highest death count 
select location, MAX(total_deaths) AS TotalDeathCount, population
from CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc

--Total Death Count by Continent
select continent, MAX(total_deaths) AS TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Showing continents with the highest death count per population
select continent, MAX(total_deaths) AS TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers - Cases and Deaths to date
select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths 
from CovidDeaths
where continent is not null

--Total Population vs Vaccination using CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON vac.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON vac.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON vac.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *
from PercentPopulationVaccinated


