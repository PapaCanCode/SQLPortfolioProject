

Select *
From PortfolioProject..CovidVaccinations$
Where continent is not null
Order By 3,4

--Selecting the data to be used

Select location, date, total_cases, new_cases, total_deaths,population_density
From PortfolioProject..CovidDeaths$
Order by 1,2


--Looking at Total cases vs total deaths

Select location, date, total_cases, total_deaths,  (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location Like '%kenya%'
Order by 1,2

--Looking at the total cases vs population

Select location, date, total_cases, population_density,  (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population_density), 0))*100 as PopPerc
From PortfolioProject..CovidDeaths$
Where location Like '%kenya%'
Order by 1,2


--Countries with highest infection rate

Select location, population_density, Max(Total_cases) as HighestInfectionCount, Max((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population_density), 0)))*100 as HighestInfected
From PortfolioProject..CovidDeaths$
--Where location Like '%kenya%'
Group by population_density, location
Order by HighestInfected desc


--Countries with the highest Death count

Select location, Max(Cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths$
--Where location Like '%kenya%'
Where continent is not null
Group by location
Order by HighestDeathCount desc


--BREAKING THINGS DOWN BY CONTINENT

--Showing continents with the highest death counts

Select continent, Max(Cast(total_deaths as int)) as HighestDeathCountPerCont
From PortfolioProject..CovidDeaths$
--Where location Like '%kenya%'
Where continent is not null
Group by continent
Order by HighestDeathCountPerCont desc


--Global numbers

Select date, Sum(new_cases) as NewCases, Sum(Cast(new_deaths as int))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location Like '%kenya%'
Where continent is not null
Group by date
Order by 1,2


--Vacinations

--Total Population vs Vaccination

Select Dea.continent, Dea.location, Dea.date, Dea.population_density, Vac.new_people_vaccinated_smoothed,
SUM(Convert(int,Vac.new_people_vaccinated_smoothed)) OVER (Partition by dea.location Order by Dea.location, Dea.date) as VacSum
From PortfolioProject..CovidDeaths$ as Dea
Join PortfolioProject..CovidVaccinations$ as Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
Where Dea.continent is not null
Order by 1,2,3

--Using CTE to perform the above

With PopvsVac(continent, location, date, population,population_density, VacSum) 
as
(
Select Dea.continent, Dea.location, Dea.date, Dea.population_density, Vac.new_people_vaccinated_smoothed,
SUM(Convert(int,Vac.new_people_vaccinated_smoothed)) OVER (Partition by dea.location Order by Dea.location, Dea.date) as VacSum
From PortfolioProject..CovidDeaths$ as Dea
Join PortfolioProject..CovidVaccinations$ as Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
Where Dea.continent is not null
--Order by 1,2,3
)
Select *, (VacSum/population)*100
From PopvsVac


--TEMP Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_people_vaccinated_smoothed numeric,
VacSum numeric,
)

Insert Into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population_density, Vac.new_people_vaccinated_smoothed,
SUM(Convert(int,Vac.new_people_vaccinated_smoothed)) OVER (Partition by dea.location Order by Dea.location, Dea.date) as VacSum
From PortfolioProject..CovidDeaths$ as Dea
Join PortfolioProject..CovidVaccinations$ as Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
Where Dea.continent is not null
--Order by 1,2,3

Select *, (VacSum / NULLIF(CONVERT(float, population), 0))*100
From #PercentPopulationVaccinated


--Creating Views to store later for visualisation

Create View PercentPopulationVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population_density, Vac.new_people_vaccinated_smoothed,
SUM(Convert(int,Vac.new_people_vaccinated_smoothed)) OVER (Partition by dea.location Order by Dea.location, Dea.date) as VacSum
From PortfolioProject..CovidDeaths$ as Dea
Join PortfolioProject..CovidVaccinations$ as Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
Where Dea.continent is not null
--Order by 1,2,3

Select *
From PercentPopulationVaccinated


--Other views



