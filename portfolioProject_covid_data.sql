select * from Covid_data.covidvcc order by 3,4
-- viewing data for all the cuntries
select location,date,total_cases,new_cases,total_deaths,population
from
`single-object-345410.Covid_data.covidde`
order by 1,2

-- looking total cases vs total death, death percentage per country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from
`single-object-345410.Covid_data.covidde`
where location like '%India%'
order by 1,2

--- percentage of cases vs population
select location,date,total_cases,population,(total_cases/population)*100 as casespercentage
from
`single-object-345410.Covid_data.covidde`
where location like '%India%'
order by 1,2


---- total death vs country
select Location,Population,max(cast(total_deaths as int)) as TotalDeathCount
from
`single-object-345410.Covid_data.covidde`
where continent is not null
group by Location,population
order by TotalDeathCount desc


--- death per continenet
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from
`single-object-345410.Covid_data.covidde`
where continent is not null
group by continent
order by TotalDeathCount desc

---- global numbers per date

select date , sum(new_cases) as totalcases,sum(new_deaths) as totaldeaths,(sum(new_deaths)/sum(new_cases))*100 as deathpercentage
from 
`single-object-345410.Covid_data.covidde`
where continent is not null 
group by date
order by 1,2

---- total cases vs deaths percentage 

select  sum(new_cases) as totalcases,sum(new_deaths) as totaldeaths,(sum(new_deaths)/sum(new_cases))*100 as deathpercentage
from 
`single-object-345410.Covid_data.covidde`
where continent is not null 
order by 1,2
--- total population vs vaccinations

select  d.continent,d.location,d.date,d.population,v.new_vaccinations

from `single-object-345410.Covid_data.covidde` d
join
`single-object-345410.Covid_data.covidvcc` v

on d.location=v.location and d.date=v.date
where 
d.continent is not null
order by 2,3

--- window function how to add vaccinations per day 

select  d.continent,d.location,d.date,d.population,v.new_vaccinations
,sum(v.new_vaccinations) over (partition  by d.location order by d.location,d.date) as sumperdayvcc
from `single-object-345410.Covid_data.covidde` d
join
`single-object-345410.Covid_data.covidvcc` v

on d.location=v.location and d.date=v.date
where 
d.continent is not null
order by 2,3

--- use CTE

with popvsvcc
as
(
    
select  d.continent,d.location,d.date,d.population,v.new_vaccinations,sum(v.new_vaccinations) over (partition  by d.location order by d.location,d.date) as sumperdayvcc

   from `single-object-345410.Covid_data.covidde` d
 join
 `single-object-345410.Covid_data.covidvcc` v

 on d.location=v.location and d.date=v.date
 where 
 d.continent is not null
 order by 2,3
)

select *,(sumperdayvcc/population)*100 from popvsvcc;



--- temp table but not work in bigquery

create table Covid_data.percentpopvsvcc
(
    continent  nvarchar(255),
    Location   nvarchar(255),
    date       datetime,
    population numeric,
    new_vaccination numeric,
    samperdayvcc numeric
)
insert into Covid_data.percentpopvsvcc 
select  d.continent,d.location,d.date,d.population,v.new_vaccinations,sum(v.new_vaccinations) over (partition  by d.location order by d.location,d.date) as sumperdayvcc
   from `single-object-345410.Covid_data.covidde` d
   join
   `single-object-345410.Covid_data.covidvcc` v
    on d.location=v.location and d.date=v.date
    where 
    d.continent is not null


select * from Covid_data.percentpopvsvcc

--- create view


create view Covid_data.globalnumbers
as
select date , sum(new_cases) as totalcases,sum(new_deaths) as totaldeaths,(sum(new_deaths)/sum(new_cases))*100 as deathpercentage
from 
`single-object-345410.Covid_data.covidde`
where continent is not null 
group by date
order by 1,2
select * from Covid_data.globalnumbers

