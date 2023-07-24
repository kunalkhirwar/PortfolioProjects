select * from [Portfolio Project].dbo.CovidDeaths
order by 3,4;

select * from [Portfolio Project].dbo.CovidVaccinations
order by 3,4;

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project].dbo.CovidDeaths
order by 1,2;

-- Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you get covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From [Portfolio Project].dbo.CovidDeaths
where location = 'India' and continent is not null
order by 1,2;

--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercent 
From [Portfolio Project].dbo.CovidDeaths
--where location = 'India'
order by 1,2;

--Looking at countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases), max((total_cases/population))*100 as InfectedPopulationPercent 
From [Portfolio Project].dbo.CovidDeaths
--where location = 'India'
group by location, population
order by InfectedPopulationPercent desc;

--Showing countries with Highest Death count per Population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount 
From [Portfolio Project].dbo.CovidDeaths
--where location = 'India'
where continent is not null
group by location
order by TotalDeathCount desc;

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the continent with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount 
From [Portfolio Project].dbo.CovidDeaths
--where location = 'India'
where continent is not null
group by continent
order by TotalDeathCount desc;


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
where continent is not null
--group by date
order by 1,2;


Select *
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date


-- Looking at Total Populations vs Vaccinations

-- Use CTE

With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3;
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Creating view to store data for later visualizations

Create View PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPeopleVaccinated;