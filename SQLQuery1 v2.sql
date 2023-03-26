select *
from PortfolioProject..CovidDeaths
order by 3, 4

select *
from PortfolioProject..CovidVaccinations

alter table PortfolioProject..CovidDeaths
alter column total_deaths_per_million float (3)

--Select Data that we are going to be using
Select location, date, total_cases_per_million, new_cases_per_million, total_deaths_per_million, population_density
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Death Rate
Select location, date, total_cases_per_million, total_deaths_per_million, 
case when total_cases_per_million = 0 or total_deaths_per_million = 0 then NULL
else (total_deaths_per_million/total_cases_per_million)*100 end as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%enya'
order by 1,2

--Looking at Total cases vs Population

Select cd.location, cd.date, cd.total_cases_per_million, cv.population, 
cd.total_cases_per_million/10000 as PercentageAffected
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv on cd.location = cv.location
where cd.location like '%enya'
order by 1,2

--Countries with highest infection rates compared to the population
Select cd.location, cv.population, 
max(cd.total_cases_per_million) as HighestInfectionCount, 
max(cd.total_cases_per_million/10000) as HighestPercentageAffected
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv on cd.location = cv.location
where cd.continent is not null
Group by cd.location, cv.population
order by HighestPercentageAffected desc

--Countries with highest death count per population

Select cd.location,
max(cd.total_deaths) as HighestDeathCount
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv on cd.location = cv.location
--where cd.location like '%enya'
where cd.continent is not null
Group by cd.location
order by HighestDeathCount desc

----BROKEN DOWN BY CONTINENT
Select cd.continent,
max(cd.total_deaths) as HighestDeathCount
from PortfolioProject..CovidDeaths cd
--join PortfolioProject..CovidVaccinations cv on cd.location = cv.location and cd.date = cv.date
--where cd.location like '%enya'
where cd.continent is not null
Group by cd.continent
order by HighestDeathCount desc

---ALTERNATIVE BREAKING DOWN BY CONTINENT
Select cd.location,
max(cd.total_deaths) as HighestDeathCount
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv on cd.location = cv.location and cd.date = cv.date
--where cd.location like '%enya'
where cd.continent is null
Group by cd.location
order by HighestDeathCount desc

--- SHOWING CONTINENTS WITH HIGHEST DEATH COUNTS PER POPULATION
Select cd.continent,
max(cd.total_deaths) as HighestDeathCount
from PortfolioProject..CovidDeaths cd
---join PortfolioProject..CovidVaccinations cv on cd.continent = cv.continent and cd.date = cv.date
--where cd.location like '%enya'
where cd.continent is not null
Group by cd.continent
order by HighestDeathCount desc

---GLOBAL NUMBERS

Select date, sum(new_cases) Total_new_cases, sum(new_deaths) Total_new_deaths,
case when sum(new_cases) = 0 or sum(new_deaths) = 0 then null
else sum(new_deaths)/sum(new_cases) *100 end as Global_Death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

---LOOKING AND TOTAL POPULATION VS VACCINATIONS

Select cd.continent, cd.location, cd.date, cv.population,
cv.new_vaccinations,
sum(convert(bigint, cv.new_vaccinations)) over (Partition by cd.location Order by cd.location, cd.date) Sum_of_New_Vaccinations

from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv on cd.location = cv.location and cd.date = cv.date
--where cd.location like '%enya'
where cd.continent is not null

order by 2,3

--- USING A CTE
with PopvsVac (continent, location, date, population, new_vaccinations, Sum_of_New_Vaccinations)
as
(
Select cd.continent, cd.location, cd.date, cv.population,
cv.new_vaccinations,
sum(convert(bigint, cv.new_vaccinations)) over (Partition by cd.location Order by cd.location, cd.date) Sum_of_New_Vaccinations

from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv on cd.location = cv.location and cd.date = cv.date
--where cd.location like '%enya'
where cd.continent is not null

--order by 2,3
)
select *, (Sum_of_New_Vaccinations/population)*100 as Percentage_Vaccinated
from PopvsVac


---TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations int,
Sum_of_New_Vaccinations bigint
)

Insert into #PercentPopulationVaccinated

Select cd.continent, cd.location, cd.date, cv.population,
cv.new_vaccinations,
sum(convert(bigint, cv.new_vaccinations)) over (Partition by cd.location Order by cd.location, cd.date) Sum_of_New_Vaccinations

from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv on cd.location = cv.location and cd.date = cv.date
--where cd.location like '%enya'
where cd.continent is not null
--order by 2,3

select *, Sum_of_New_Vaccinations/population *100 as Percentage_Populated
from #PercentPopulationVaccinated

----CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

create view PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cv.population,
cv.new_vaccinations,
sum(convert(bigint, cv.new_vaccinations)) over (Partition by cd.location Order by cd.location, cd.date) Sum_of_New_Vaccinations

from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv on cd.location = cv.location and cd.date = cv.date
--where cd.location like '%enya'
where cd.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated


