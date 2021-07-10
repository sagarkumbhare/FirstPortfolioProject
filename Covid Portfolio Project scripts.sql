select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

----Looking at Total Cases vs Total Deaths
--Shows Likelihood of dying if you contract covid in your country 

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


----Looking at Total Cases vs population
--Shows what percentage of population got Covid

select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2


--Looking at countries with highest infection rate compared to population

select location,population,MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%India%'
Group by location,population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per population

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
Group by location
order by TotalDeathCount desc

---Lets break things down by Continent

--Showing continents with the highest death count per population

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers

select SUM(new_cases)as total_cases, SUM(CAST(new_deaths as int)) as total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
--group by date
order by 1,2



--Looking at Total Population vs Vaccinations

With PopvsVac(Continent, Location,Date,population, new_vaccinations,RollingPeopleVaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100 
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
on dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
--and dea.location like '%Albania%'
--order by 2,3
)
Select * ,(RollingPeopleVaccinated/population)*100
from PopvsVac



--Temp Table
DROP TABLE  if Exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100 
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
on dea.location=vac.location
and dea.date=vac.date
--Where dea.continent is not null
--and dea.location like '%Albania%'
--order by 2,3

Select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

----Creating view to store data for later visualization
Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100 
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
on dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
--order by 2,3


Select * from PercentPopulationVaccinated