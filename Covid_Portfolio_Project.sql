select * from PortfolioProject..CovidDeaths
order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4

--Selecting data that im going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at total cases vs total-deaths

select location, date,total_cases, total_deaths, (convert(float,total_deaths)/convert(float,total_cases)) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- i wanted to see what type are both columns 'total_deaths' & 'total_cases' 

SELECT
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH AS MAX_LENGTH, 
    CHARACTER_OCTET_LENGTH AS OCTET_LENGTH 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'CovidDeaths' 
AND COLUMN_NAME = 'total_deaths'

--we found out that the column type is nvarchar.. In this case, we have two options: 
--change the column’s type, or convert its type on the fly when getting its sum.

--what i did here: "-- Looking at total cases vs total-deaths": is converting the columns when doing the calculation divide.
--result:
--shows likelihood of dying if you contract covid in your country 

select location, date,total_cases, total_deaths, (convert(float,total_deaths)/convert(float,total_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%morocco%'
and continent is not null
order by 1,2


--Looking at total cases vs population
--shows what percentage of population got covid

select location, date, population, total_cases, (convert(float,total_cases) / convert(float,population) )* 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%morocco%'
and continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, (convert(float,MAX(total_cases)) / convert(float,population) )* 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%morocco%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population

select location, MAX(total_deaths) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%morocco%'
where continent is not null
group by location
order by TotalDeathCount desc

--if we look at total_deaths data type, its a varchar, we need to change that into a numeric type or cast it into an integer

select location, MAX(cast(total_deaths as float)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%morocco%'
where continent is not null
group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT


--Showing continents with highest death count per population

select location, MAX(total_deaths) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%morocco%'
where continent is not null
group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS IN THE WHOLE WORLD

select /*date,*/ SUM(cast(new_cases as float)) as TotalCases,
SUM(cast(new_deaths as float)) as TotalDeaths,
(SUM(cast(new_deaths as float)) / SUM(cast(new_cases as float)) )* 100 as GlobalDeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2
 
--Let's join the two tables 
--Looking at total population vs Vaccinations

select dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location , dea.date ) as RollingPeopleVaccinated
--(RollingPeopleVaccinated) / dea.population) *100 
from PortfolioProject..CovidDeaths as dea 
Join PortfolioProject..CovidVaccinations as vac
On dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null --and dea.location = 'Albania'
order by 2,3 

--USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location , dea.date ) as RollingPeopleVaccinated
--(RollingPeopleVaccinated) / dea.population) *100 
from PortfolioProject..CovidDeaths as dea 
Join PortfolioProject..CovidVaccinations as vac
On dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null and dea.location = 'albania'
--order by 2,3 
)
select *, (RollingPeopleVaccinated /population)*100 as PercentageOfPeopleVaccinated
from PopvsVac

--USE TEMP TABLE didn't personally work for me i get the error msg 257

drop table if exists #PercentPolulationVaccinated
create table #PercentPolulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255) ,
Date datetime,
Population numeric, 
New_vaccinations bigint, 
RollingPeopleVaccinated numeric
)
Insert into #PercentPolulationVaccinated
select dea.Continent, dea.Location, dea.Population, convert(datetime,dea.Date), vac.New_vaccinations,
SUM(cast(vac.New_vaccinations as float)) OVER (Partition by dea.Location order by dea.Location , convert(datetime,dea.Date) ) as RollingPeopleVaccinated
--(RollingPeopleVaccinated) / dea.population) *100 
from PortfolioProject..CovidDeaths as dea 
Join PortfolioProject..CovidVaccinations as vac
On dea.Location = vac.Location 
and convert(datetime,dea.Date) = convert(datetime,vac.Date)
where dea.Continent is not null --and dea.Location = 'albania'
--order by 2,3 

select *, (RollingPeopleVaccinated /Population)*100 as PercentageOfPeopleVaccinated
from #PercentPolulationVaccinated

--Creating view to store data for later visualizations

Create View PercentPolulationVaccinated as

select dea.Continent, dea.Location, dea.Population, dea.Date, vac.New_vaccinations,
SUM(cast(vac.New_vaccinations as float)) OVER (Partition by dea.Location order by dea.Location , dea.Date ) as RollingPeopleVaccinated
--(RollingPeopleVaccinated) / dea.population) *100 
from PortfolioProject..CovidDeaths as dea 
Join PortfolioProject..CovidVaccinations as vac
On dea.Location = vac.Location 
and dea.Date = vac.Date
where dea.Continent is not null --and dea.Location = 'albania'
--order by 2,3 


select *
from PercentPolulationVaccinated

