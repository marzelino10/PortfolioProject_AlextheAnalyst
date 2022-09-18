-- Showing all columns of CovidDeaths table
Select *
From Portfolio_Project..CovidDeaths


-- Showing all columns of CovidVaccinations table
Select *
From Portfolio_Project..CovidVaccinations


-- Selecting data that we will use
Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Indonesia
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
From Portfolio_Project..CovidDeaths
Where location like '%indonesia%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 AS percent_population_infected
From Portfolio_Project..CovidDeaths
Where location like '%indonesia%'
order by 1,2


-- Looking at countries with highest infection rate compared to population
Select location, population, max(total_cases) as highest_infection_count,  max((total_cases/population))*100 AS max_percent_population_infected
From Portfolio_Project..CovidDeaths
--Where location like '%indonesia%'
group by location, population 
order by max_percent_population_infected desc

-- Showing countries with the highest death count 
Select location, max(cast(total_deaths as int)) as death_count	-- changing total_deaths from nvarchar25 into integer
From Portfolio_Project..CovidDeaths
where continent is not null					-- deleting locations consisting of group of countries, such as Asia or World
group by location
order by death_count desc


-- BREAKING THINGS DOWN BY CONTINENT


-- Showing the continents with the highest death count per poulation
Select continent, max(cast(total_deaths as int)) as death_count	-- changing total_deaths from nvarchar25 into integer
From Portfolio_Project..CovidDeaths
where continent is not null					-- deleting locations consisting of group of countries, such as Asia or World
group by continent
order by death_count desc


-- GLOBAL NUMBERS per day

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
From Portfolio_Project..CovidDeaths
--Where location like '%indonesia%'
where continent is not null					-- deleting locations consisting of group of countries, such as Asia or World
group by date
order by 1,2


-- Looking at Total Population vs Vaccinations
-- Using CTE (Common Table Expression)
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, Rolling_people_vaccinated)
as (
Select	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
			as rolling_people_vaccinated		-- rolling new_vaccinations number based on the country and date
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, (Rolling_people_vaccinated/Population)*100 as Vaccination_percentage
from PopvsVac



-- TEMP TABLE
Drop table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	Rolling_people_vaccinated numeric
)
Insert into PercentPopulationVaccinated
Select	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
			as rolling_people_vaccinated		-- rolling new_vaccinations number based on the country and date
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

select *, (Rolling_people_vaccinated/Population)*100 as Vaccination_percentage
from PercentPopulationVaccinated


-- Creating View (virtual table) to store data for later visualizations

Create view PercentPopulationVaccinated as
Select	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
			as rolling_people_vaccinated		-- rolling new_vaccinations number based on the country and date
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
from PercentPopulationVaccinated
