-- Total cases in the world vs total deaths in the world 
-- Compute how likely you are to die if you contract covid based on world data
select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths) / sum(new_cases) * 100 as DeathPercentage
from covidDeaths
where continent is not null
order by 1, 2

-- Total death count across continents
select location, sum(new_deaths) as TotalDeathCount
from covidDeaths
where continent is null and location not in ('high income', 'upper middle income', 'lower middle income', 'european union', 'Low income', 'world')
group by location 
order by TotalDeathCount desc

-- Population of country vs total cases
-- Track which countries had the highest percentage of population infected
select location, population, max(total_cases) as HighestInfectionCount, Max(total_cases/population) * 100 as PercentPopulationInfected
from covidDeaths
-- where location = 'canada'
group by location, population
order by PercentPopulationInfected desc

-- Track which country has the highest percentage of population infected based on date
select location, population, date, max(total_cases) as HighestInfectionCount, Max(total_cases / population) * 100 as PercentPopulationInfected
from covidDeaths
-- where location = 'canada'
group by location, population, date
order by PercentPopulationInfected desc

-- Rolling count of people vaccinated per country based on date
select dea.continent, dea.location, dea.date, dea.population
, max(vac.total_vaccinations) as RollingPeopleVaccinated
from covidDeaths dea
join covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
group by dea.continent, dea.location, dea.date, dea.population
order by 1, 2, 3


-- NOT USED IN TABLEAU PROJECT (Just practicing CTE & Temp Tables
-- Track rolling percentage of population per country that have been vaccinated. 
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covidDeaths dea
join covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated / population) * 100 as PercentPeopleVaccinated
from PopvsVac
order by 2,3

-- Temp table created to compare rolling population percentage vaccinated vs new cases and deaths
-- This query is focusing on Canada
-- Data is cleaned to change nulls to 0, and outlier/incorrect data removed
drop table if exists #VacvsDea
create table #VacvsDea
(
location nvarchar(255),
date datetime,
population numeric,
people_vaccinated numeric,
new_cases numeric,
new_deaths numeric
)
insert into #VacvsDea
select vac.location, vac.date, dea.population, vac.people_vaccinated, dea.new_cases, dea.new_deaths
from covidVaccinations vac
join covidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null and vac.location = 'canada'

-- Change people_vaccinated from null to 0 and change total_deaths from null to 0
update #VacvsDea
set people_vaccinated = isnull(people_vaccinated, 0)

--Remove outliers where people_vaccinated is 0 after the first date where a vaccine is provided
delete from #VacvsDea
where date >= Convert(date, '2020-12-14') and people_vaccinated = 0

-- Remove outliers after 2022-06-12 when tracking new_Cases and new_deaths stopped being done daily
delete from #VacvsDea
where date >= Convert(date, '2022-06-10')


-- Remove outliers where new_cases is null and new_deaths is null
delete from #VacvsDea
where new_cases is null

delete from #VacvsDea
where new_deaths is null

-- View cleaned temp table with rolling new cases, deaths and percentage of population vaccinated
select *, (people_vaccinated / population) * 100 as PercentageOfPopulationVaccinated
from #VacvsDea
order by date
