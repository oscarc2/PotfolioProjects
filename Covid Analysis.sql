/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select *

-- select data that we're using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..['covid deaths']
order by 1,2


-- Looking at Total cases vs total deaths
-- Shows the likelihood of dying from covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases*100) as DeathPercent
from PortfolioProject..['covid deaths']
where location like '%states%'
order by 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population*100) as PercentofInfected
from PortfolioProject..['covid deaths']
where location like '%states%'
order by 1,2

-- looking at countries with highest infection rates compared to population
select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentofInfected
from PortfolioProject..['covid deaths']
group by location, population
order by percentofinfected desc 

--Shows countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['covid deaths']
where continent is not null -- to remove continent data and only do countries
group by location
order by TotalDeathCount desc 

--look at continents
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['covid deaths']
where continent is null  -- to use only continent data and not countries
and location not like '%income%'
and location not like '%world%'
group by location
--having location not like '%income%' -- removing income data found as well
order by TotalDeathCount desc 

-- world death count
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['covid deaths']
where location like '%World%'
group by location
order by TotalDeathCount 


--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as totalvax
,
from PortfolioProject..['covid deaths'] dea
join PortfolioProject..covidvax vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use CTE

with PopVsVax (continent, location, date, population, new_vaccinations, totalvax) as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as totalvax
from PortfolioProject..['covid deaths'] dea
join PortfolioProject..covidvax vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (totalvax/population)*100 as PercentVaxed
from PopVsVax

-- Temp table
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
totalvax numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as totalvax
from PortfolioProject..['covid deaths'] dea
join PortfolioProject..covidvax vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select*, (totalvax/population)*100 as PercentVaxed
from #PercentPopulationVaccinated


--creating view to store data for visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as totalvax
from PortfolioProject..['covid deaths'] dea
join PortfolioProject..covidvax vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated