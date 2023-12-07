# Data Analyst Portfolio Project

## Overview

This project is a comprehensive analysis of global COVID-19 data, showcasing data analyst skills through SQL queries and a Tableau dashboard. The primary objectives include exploring worldwide COVID-19 statistics, analyzing death counts across continents, evaluating the impact on individual countries based on population, tracking vaccination progress, and employing advanced SQL techniques such as Common Table Expressions (CTE) and Temp Tables.

## Tableau Dashboard

Explore the interactive Tableau dashboard created for this project by clicking [here](https://public.tableau.com/app/profile/harnish.patel8865/viz/PortfolioProject-Covid_17005436060580/Dashboard1).

## Table of Contents

- [Queries](#queries)
  - [Total Cases and Deaths](#total-cases-and-deaths)
  - [Total Death Count Across Continents](#total-death-count-across-continents)
  - [Population vs Total Cases](#population-vs-total-cases)
  - [Highest Percentage of Population Infected](#highest-percentage-of-population-infected)
  - [Rolling Count of People Vaccinated](#rolling-count-of-people-vaccinated)
- [Not Used in Tableau Project](#not-used-in-tableau-project)
  - [Rolling Percentage of Population Vaccinated (CTE Usage)](#rolling-percentage-of-population-vaccinated-cte-usage)
  - [Compare Rolling Population Percentage Vaccinated vs New Cases and Deaths (TEMP TABLE USAGE)](#compare-rolling-population-percentage-vaccinated-vs-new-cases-and-deaths-temp-table-usage)
- [Conclusion](#conclusion)

## Queries

### Total Cases and Deaths

The following query provides insights into the global impact of COVID-19, calculating total cases, total deaths, and the percentage likelihood of death if contracting the virus.

```sql
-- Total cases in the world vs total deaths in the world
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM covidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;
```
## Total Death Count Across Continents

This query focuses on the total death count across continents, excluding specific locations such as 'high income' and 'world.'

```sql
-- Total death count across continents
SELECT location, SUM(new_deaths) AS TotalDeathCount
FROM covidDeaths
WHERE continent IS NULL AND location NOT IN ('high income', 'upper middle income', 'lower middle income', 'european union', 'low income', 'world')
GROUP BY location 
ORDER BY TotalDeathCount DESC;
```

## Population vs Total Cases

Analyzing the impact on individual countries, this query compares population size with total COVID-19 cases, highlighting countries with the highest percentage of population infected.

```sql
-- Population of country vs total cases
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population) * 100 AS PercentPopulationInfected
FROM covidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;
```

## Highest Percentage of Population infected

Extending the previous query, this one tracks the country with the highest percentage of population infected based on date.

```sql
-- Track which country has the highest percentage of population infected based on date
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases / population) * 100 AS PercentPopulationInfected
FROM covidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC;
```

## Rolling Count of People Vaccinated

This query focuses on the rolling count of people vaccinated per country based on date, leveraging the data from both the covidDeaths and covidVaccinations tables.

```sql
-- Rolling count of people vaccinated per country based on date
SELECT dea.continent, dea.location, dea.date, dea.population, MAX(vac.total_vaccinations) AS RollingPeopleVaccinated
FROM covidDeaths dea
JOIN covidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, dea.location, dea.date, dea.population
ORDER BY 1, 2, 3;
```

## Not Used in Tableau Project

### Rolling Percentage of Population Vaccinated (CTE USAGE)

Although not incorporated into the Tableau project, this query calculates the rolling percentage of the population per country that has been vaccinated using CTE.

### Compare Rolling Population Percentage Vaccinated vs New Cases and Deaths (TEMP TABLE USAGE)

This part of the project involves creating a temporary table (#VacvsDea) for comparing rolling population percentage vaccinated vs new cases and deaths, focusing on Canada.

## Conclusion

This portfolio project showcases a range of data analyst skills, including data exploration, aggregation, and visualization. The SQL queries provide valuable insights into global and country-specific COVID-19 data, while the Tableau dashboard, enhances the presentation and interpretation of the findings. The use of advanced SQL techniques such as CTEs and Temp Tables demonstrates proficiency in handling and transforming data for analysis.
