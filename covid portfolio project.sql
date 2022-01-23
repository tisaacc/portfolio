select *
from PortfolioProject..covid_deaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..covid_vaccinations
--order by 3,4

-- Selecting the relevant data to this project

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covid_deaths
where continent is not null
order by 1, 2

-- Total Cases vs. Total Deaths in the US
-- Shows the death rate according to cases and deaths per day

select location, date, total_cases, total_deaths, cast(total_deaths as float)/(cast(total_cases as float))*100 as DeathPercentage 
from PortfolioProject..covid_deaths
where location like '%states%' 
and continent is not null
order by 1, 2

-- Total Cases vs. Population
-- Shows what percentage of the total population has died from Covid-19

select location, date, total_cases, population, total_cases, (cast(total_cases as float) / cast(population as float))*100 as PerfectPopulationInfected
from PortfolioProject..covid_deaths
where location like '%states%' 
and continent is not null
order by 1, 2

-- Identifying countries with highest infection rates compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((cast(total_cases as float) / cast(population as float)))*100 as PerfectPopulationInfected
from PortfolioProject..covid_deaths
where continent is not null
group by location, population
order by PerfectPopulationInfected desc

-- Continents with the highest number of deaths

select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..covid_deaths
where continent is null
group by location
order by TotalDeathCount desc

-- Global cases, deaths, and death percentage

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(cast(new_deaths as float)) / sum(cast(new_cases as float)))*100 as DeathPercentage
from PortfolioProject..covid_deaths
where continent is not null
group by date
order by 1, 2

-- Total Global cases, total deaths, and overall death percentage

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(cast(new_deaths as float)) / sum(cast(new_cases as float)))*100 as DeathPercentage
from PortfolioProject..covid_deaths
where continent is not null
order by 1, 2

-- Total population vs. total vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
from PortfolioProject..covid_deaths dea 
left join PortfolioProject..covid_vaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Using CTE

with population_vaccinated (continent, location, date, population, new_vaccinations, rolling_vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
from PortfolioProject..covid_deaths dea 
left join PortfolioProject..covid_vaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
)

select *, (cast(rolling_vaccinations as float) / (cast(population as float))*100) 
from population_vaccinated
where continent is not null

-- Using Temp Table

DROP table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population bigint,
new_vaccinations bigint,
rolling_vaccinations float
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
from PortfolioProject..covid_deaths dea 
left join PortfolioProject..covid_vaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date

select *, (cast(rolling_vaccinations as float) / (cast(population as float))*100) 
from #PercentPopulationVaccinated
where continent is not null

-- Creating view to store data for Tableau

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
from PortfolioProject..covid_deaths dea 
left join PortfolioProject..covid_vaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

