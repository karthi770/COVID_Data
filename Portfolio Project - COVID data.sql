USE portfolio_project_1;
SELECT * FROM covid_data_vaccine
ORDER BY 3,4;
SELECT location, date, total_cases, new_cases, total_deaths, population FROM covid_data_deaths
ORDER BY 1,2;

#Looking at total cases vs total deaths
#This shows the likeliness of dying if we contract with the virus
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage 
FROM covid_data_deaths
WHERE location like 'Canada' 
ORDER BY 1,2;

#Looking at total cases vs Population
#Shows what percentage of Population got COVID
SELECT location, date, total_cases, population, (total_cases /population)*100 as percentage_population_infected 
FROM covid_data_deaths
WHERE location like 'Canada' 
ORDER BY 1,2;

#Looking at countries with highest Infection rate compared to population
SELECT location, MAX(total_cases) AS Highest_infection_count, population, MAX((total_cases /population))*100 as percentage_population_infected 
FROM covid_data_deaths
GROUP BY location, population
ORDER BY percentage_population_infected DESC;

#Countries with highest death count per population
SELECT location, MAX(total_deaths) AS Death_count FROM covid_data_deaths
GROUP BY location
ORDER BY total_deaths DESC;

#Continents with highest death count per population
SELECT continent, MAX(total_deaths) AS Death_count FROM covid_data_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths DESC;

#Global cases
SELECT date, SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/SUM(new_cases) as death_percentage FROM covid_data_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date DESC;

#Global cases total
SELECT SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/SUM(new_cases) as death_percentage FROM covid_data_deaths
WHERE continent IS NOT NULL
ORDER BY date DESC;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations FROM covid_data_deaths dea
JOIN 
covid_data_vaccine vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY dea.continent DESC;

#Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_Vaccinated 
FROM covid_data_deaths dea
JOIN 
covid_data_vaccine vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,1;

#Population vs Vaccination
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccination, Rolling_people_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_Vaccinated
FROM covid_data_deaths dea
JOIN 
covid_data_vaccine vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
)
SELECT *, (Rolling_people_Vaccinated/population)*100
FROM PopvsVac

#Creating a Temp table
DROP TABLE IF EXISTS Percent_population_vaccinated
CREATE TABLE Percent_population_vaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_people_Vaccinated numeric
)
INSERT INTO Percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_Vaccinated
FROM covid_data_deaths dea
JOIN 
covid_data_vaccine vac ON dea.location = vac.location AND dea.date = vac.date
SELECT *, (Rolling_people_Vaccinated/population)*100 AS Percentage
FROM Percent_population_vaccinated


#Creating view for visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_Vaccinated
FROM covid_data_deaths dea
JOIN 
covid_data_vaccine vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
SELECT * FROM PercentPopulationVaccinated;