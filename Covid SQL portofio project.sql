-- Select the data we are going to use 

SELECT location, date,total_cases,new_cases,total_deaths,population 
from CovidPortfolioProject..CovidDeaths
order by 1,2

-- Looking for the total cases vs total deaths 

-- Show likelihood of dying if you contract covid in your country
SELECT location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidPortfolioProject..CovidDeaths
order by 1,2

-- Finding the total cases vs population 
--Show what percentages of population got covid 
SELECT location, date, population,total_cases, (total_cases/population)*100 as InfectedPercentage
from CovidPortfolioProject..CovidDeaths
order by 1,2

-- Looking at countries with highest infection rate compared to population
SELECT location, population,Max(total_cases) as Highestinfectioncount, Max((total_cases/population))*100 as InfectedPercentage
from CovidPortfolioProject..CovidDeaths
Group by location, population
order by InfectedPercentage desc

--Showing countries / continent with highest death count
-- Find the total death cases in each countries 
SELECT location,Max(cast(total_deaths as int)) as TotalDeathCount
from CovidPortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- Find the total death cases in each continent
SELECT continent,Max(cast(total_deaths as int)) as TotalDeathCount
from CovidPortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers 
-- Find the total new cases and total deaths in each day around the world

SELECT date, sum(new_cases) as totol_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Find the total new cases and total deaths in around the world

SELECT sum(new_cases) as totol_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidPortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Join two table together

Select *
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidDeaths vac
  On dea.location = vac.location
  and dea.date = vac.date

-- Looking at the total population vs vaccinations 

Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidDeaths vac
  On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3

  -- Creating a CTE for further calculation

  With PopvsVac (Continet, location, data, population, new_vaccination ,RollingPeopleVaccinated)
  as
  (
  Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidDeaths vac
  On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/population)*100 as countryvaccrate
From PopvsVac

-- TEMP Table 

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continet nvarchar(225),
location nvarchar(225),
data datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidDeaths vac
  On dea.location = vac.location
  and dea.date = vac.date
 where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 as countryvaccrate
From #PercentPopulationVaccinated




-- Creating table for later visualization

Create view PercentPopulationVaccinated as
Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidDeaths vac
  On dea.location = vac.location
  and dea.date = vac.date
 where dea.continent is not null

 select * from PercentPopulationVaccinated

