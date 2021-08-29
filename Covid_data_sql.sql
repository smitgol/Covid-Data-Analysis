select *
From master.dbo.['covid-vaccination-data']
order by 3,4



--select data that we are using

Select location, date, total_cases, new_cases, total_deaths, population
From master.dbo.['covid-death-data']
order by 1,2

-- Looking at Total case vs Total deaths
-- showing likehood of dying if you contract covid in your country
Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_ratio
From master.dbo.['covid-death-data']
where location = 'India'
order by 1,2

-- Looking at Total case vs Population
-- show what percentage of population got Covid


Select location, date, population, total_cases, (total_cases/population)*100 as death_ratio
From master.dbo.['covid-death-data']
--where location = 'India'
order by 1,2

-- looking at countries with Highest Infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population))*100 as PercentPopulationInfected
From master.dbo.['covid-death-data']
--where location = 'India'
Group By location, population
order by PercentPopulationInfected DESC

-- looking at countries with Highest Death rate compared to population

Select location, MAX(cast(total_deaths AS int)) as HighestDeathRate
From master.dbo.['covid-death-data']
--where location = 'India'
where continent is not null
Group By location, population
order by HighestDeathRate DESC

-- Lets Break down by continent

Select continent, MAX(cast(total_deaths AS int)) as HighestDeathRate
From master.dbo.['covid-death-data']
--where location = 'India'
where continent is not null
Group By continent
order by HighestDeathRate DESC

-- Showing continent with highest death count per population

Select continent, MAX(cast(total_deaths AS int)) as HighestDeathRate, MAX(cast(total_deaths AS int)/population) as Death_ratio 
From master.dbo.['covid-death-data']
--where location = 'India'
where continent is not null
Group By continent
order by HighestDeathRate DESC

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from master.dbo.['covid-death-data']
order by 1,2

-- Looking at Total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION by dea.location order by dea.location, dea.date) as Rolling_prople_vaccinated
from master.dbo.['covid-death-data'] as dea
join master.dbo.['covid-vaccination-data'] as vac
 on dea.date = vac.date
 and dea.location =vac.location
where dea.continent is not null
order by 1,2,3




-- Using CTE

with popvsvac (Continent, Location, date, Population, new_vaccinations, Rolling_prople_vaccinated)
as 
(
select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION by dea.location order by dea.location, dea.date) as Rolling_prople_vaccinated
from master.dbo.['covid-death-data'] as dea
join master.dbo.['covid-vaccination-data'] as vac
 on dea.date = vac.date
 and dea.location =vac.location
where dea.continent is not null
)
select *, (Rolling_prople_vaccinated/Population)*100
from 
popvsvac


-- Using temp table

DROP TABLE IF exists #percentagepopulationvaccinated 
CREATE Table #percentagepopulationvaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccination numeric,
Rolling_prople_vaccinated numeric
)

INSERT INTO #percentagepopulationvaccinated 
select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION by dea.location order by dea.location, dea.date) as Rolling_prople_vaccinated
from master.dbo.['covid-death-data'] as dea
join master.dbo.['covid-vaccination-data'] as vac
 on dea.date = vac.date
 and dea.location =vac.location
where dea.continent is not null

select *, (Rolling_prople_vaccinated/population)*100
from 
#percentagepopulationvaccinated

-- Creating view to store data for later visualization 

create view Percentagepopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION by dea.location order by dea.location, dea.date) as Rolling_prople_vaccinated
from master.dbo.['covid-death-data'] as dea
join master.dbo.['covid-vaccination-data'] as vac
 on dea.date = vac.date
 and dea.location =vac.location
where dea.continent is not null
--order by 1,2,3
