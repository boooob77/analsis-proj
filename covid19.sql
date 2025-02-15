/*Summary of What We Have Done:
1-Percentage of people infected in Egypt.
2-Percentage of death cases in Egypt.
3-Top country with the highest infection rate.
4-Highest death count per population.
5-Total population vs. total vaccinations.
6-Percentage of the population that has received at least one COVID-19 vaccine.
7-Creating a view to store data for later use. */

--select * from PortfolioProject..CovidDeaths
--order by 3 , 4;

--select * from PortfolioProject..CovidDeaths
--order by 3 , 4;

--select data that we are going to use 

select location , date , total_cases , new_cases , total_deaths , population 
from PortfolioProject..CovidDeaths
order by 1 , 2 ;

--looking at total cases vs population 
select location , date , total_cases , population , (total_cases/population) * 100 as percentPopulationInfected 
from PortfolioProject..CovidDeaths
where location like '%egypt%'
order by 1 ,2 ;

--looking at total cases vs total deaths 
select location , date , total_cases , total_deaths , (total_deaths/total_cases)* 100 as deathPercentage 
from PortfolioProject..CovidDeaths
where location like '%egypt%'
order by 1 , 2;



--looking a countries with highest infection rate compared to population 
select location , population , MAX(total_cases) as totalCases , MAX((total_cases/population))*100 as percentPopulationInfected 
from PortfolioProject..CovidDeaths
group by location , population 
order by percentPopulationInfected desc;


--showing countries with highest death count per population 
select location , MAX(cast(total_deaths as int)) as totalDeaths 
from PortfolioProject..CovidDeaths
where continent is not null 
group by location
order by totalDeaths desc;

--looking at the total vacination vs total population 
select 
    vac.location, 
    vac.date, 
    dea.population, 
    MAX(cast(vac.total_vaccinations as int)) as max_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.location like '%egypt%'
group by vac.location, vac.date, dea.population
order by 1, 2;



-- looking at total population vs total vacination 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3 ;

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3;

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
