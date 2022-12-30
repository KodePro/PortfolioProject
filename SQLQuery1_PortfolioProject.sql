Select *
From PortfolioProject..CovidDeaths

where continent is not null

order by 3, 4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths

order by 1, 2

-- total cases vs total deaths in Afghanistan

select location, date, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths

where location like '%states%'

order by 1, 2

--Looking at total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths

where location = 'United States'

order by 1, 2

-- looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths

-- where location = 'United States'

group by location, population

order by 4 desc


-- showing countries highest death count by population

select location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc

--showing continent with highest death count per population

select continent, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc

--Global numbers

Select sum(new_cases) as GlobalCasesPerDay, sum(cast(new_deaths as int)) as GlobalDeathsPerDay, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathsPerctgDay --total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1, 2 asc

--Total Population vs Vaccination
With PopvsVax (continent, location, date, population, new_vaccinations, RollingPeopleVaxinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaxinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

select *, (RollingPeopleVaxinated/population)*100 as PerctgPeopleVaxinated
from PopvsVax


--Temp Table

create table #PercentPopulationVaxinated
(
continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaxinated numeric
)

insert into #PercentPopulationVaxinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaxinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3


select *, (RollingPeopleVaxinated/population)*100 as PerctgPeopleVaxinated
from #PercentPopulationVaxinated


--creating view to store data for later viz

create view PercentPopulationVaxinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaxinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3