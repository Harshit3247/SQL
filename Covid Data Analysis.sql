select location,date,total_cases,total_deaths,population
from CovidDeaths$
order by 1,2;

--Total Cases vs Total Deaths and DeathPercentage
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where location='india'
order by 1,2;

--Total Cases vs Population
select location,date,population,total_cases,(total_cases/population)*100 as CovidPopPercentage
from CovidDeaths$
where location='india'
order by 1,2;

--Highest Infection Rate compared to Population
select location,population,max(total_cases) as HighestInfectionCount,Max((total_cases/population)*100) as CovidPopPercentage
from CovidDeaths$
group by location,population
order by CovidPopPercentage desc;

--Highest Death Count compared to Population
select location,population,max(cast(total_deaths as int)) as HighestDeathCount,Max((total_deaths/population)*100) as CovidPopPercentage
from CovidDeaths$
where continent is not null
group by location,population
order by HighestDeathCount desc;

--Continent-Wise with highest death count
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc;

--Global Numbers
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths$
where continent is not null
--group by date
order by 1,2;

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations from CovidDeaths$ dea
join CovidVaccinations$ vac 
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3;

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac 
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3;

--cte
with PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac 
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/Population)*100 from PopvsVac;


--temp table
drop table if exists #PerPopVac;
create table #PerPopVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PerPopVac
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac 
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
;

select *,(RollingPeopleVaccinated/Population)*100 from #PerPopVac;

--view 
create view ContinentDeaths as
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by continent
--order by TotalDeathCount desc;

select * from ContinentDeaths;