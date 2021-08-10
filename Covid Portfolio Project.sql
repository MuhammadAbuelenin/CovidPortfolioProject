-- New Cases and Death data
select *
from PortfolioProject..['owid-covid-data$']
where continent is null

-- select Total Cases vs. total Deaths
select location, date, total_cases, total_deaths , new_cases, (total_deaths/total_cases)*100 As DeathPercetage
from PortfolioProject..['owid-covid-data$']
where location like '%Egypt%'
order by 1,2
	
-- select total Cases vs. population
select location, date, total_cases, population, (total_cases/population)*100 as DeathPopulation
from PortfolioProject..['owid-covid-data$']
where location like '%brazil%'
order by 1,2


select Location, Population, Max(total_cases) as HighestCases, Max((total_cases/population))*100 as PercentPopulation
from PortfolioProject..['owid-covid-data$']
group by Location, Population
order by HighestCases DESC

--  select with the highest deathcount
select  location, Max(total_deaths) as totalDeath
from PortfolioProject..['owid-covid-data$']
group by location
order by totalDeath desc

--  select with the highest deathcount by casting by country
select  location, Max(cast(total_deaths as int)) as totalDeath
from PortfolioProject..['owid-covid-data$']
where continent is not null
group by location
order by totalDeath desc


--  select with the highest deathcount by casting by continent
select continent, Max(cast(total_deaths as int)) as totalDeath
from PortfolioProject..['owid-covid-data$']
where continent is not null
group by continent
order by totalDeath desc

-- Global Numbers
select date, sum(new_cases), SUM(cast(new_deaths as int))
from PortfolioProject..['owid-covid-data$']
where continent is not null
group by date
order by 1


-- Vaccination Data
select *
from PortfolioProject..CovidVacenations$
where location like '%canada%'

-- join 2 tables together (New_cases and Vaccination)
select dea.location, dea.date, dea.continent, dea.population, vac.total_vaccinations
from PortfolioProject..['owid-covid-data$'] dea
join PortfolioProject..CovidVacenations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2

-- Population vs Vaccination
select dea.location, dea.date, dea.continent, dea.population, vac.total_vaccinations, sum(convert(int, vac.new_vaccinations)) over 
( Partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
from PortfolioProject..['owid-covid-data$'] dea
join PortfolioProject..CovidVacenations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2

-- CTE (when you cant use your new column-RollingPeopleVac- in a new equation to make a new column)
with PopvsVac (location, date, continent, population, total_vaccinations, RollingPeopleVac)
as 
(
select dea.location, dea.date, dea.continent, dea.population, vac.total_vaccinations, sum(convert(int, vac.new_vaccinations)) over 
( Partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
from PortfolioProject..['owid-covid-data$'] dea
join PortfolioProject..CovidVacenations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVac/population)*100 as new_eq
from PopvsVac

	
-- Temp table
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
location nvarchar(255),
continent nvarchar(255),
Date datetime,
population numeric,
new_vaccinated numeric,
RollingPeopleVac numeric
)

Insert into #PercentPopulationVaccinated
select dea.location, dea.continent, dea.date,  dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over 
( Partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
from PortfolioProject..['owid-covid-data$'] dea
join PortfolioProject..CovidVacenations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null

select *, (RollingPeopleVac/population)*100 as new_eq
from #PercentPopulationVaccinated


-- creating view to store data for later viz
create view PercentPopulationVaccinated as
select dea.location, dea.continent, dea.date,  dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over 
( Partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
from PortfolioProject..['owid-covid-data$'] dea
join PortfolioProject..CovidVacenations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


--- <==================> ---

--Table 1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..['owid-covid-data$']
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--Table 2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..['owid-covid-data$']
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


--Table 3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..['owid-covid-data$']
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


--Table 4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..['owid-covid-data$']
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc