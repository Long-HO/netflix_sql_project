drop table if exists netflix;
create table netflix(
	show_id varchar(6),
    type varchar(10),
    title varchar(150),
    director varchar(150),
    casts varchar(1000),
    country varchar(100),
    date_added varchar(50),
    release_year int,
    rating varchar(15),
    duration varchar(15),
    listed_in varchar(100),
    description varchar(300)
);

/* data source: "https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download" */


-- Find all the movies/TV shows by director 'Toshiya Shinohara' --
select * from content
where director like "%Toshiya Shinohara%";

-- Find how many movies actor 'Denzel Washington' appeared in last 20 years! --
select * from content
where cast like '%Denzel Washington%' and
	release_year > extract(year from current_date) - 20;

-- Find all content without a director --
select * from content
where director is null or director='';

-- List all movies that are documentaries --
select * from content 
where type ="movie" and listed_in like '%documentaries%';

-- Count the number of Movies vs TV Shows--
select type, count(type) as total_contents 
from content
group by 1;

-- List all TV shows with more than 5 seasons --
select * from content
where type ="TV Show" 
	and substring_index(duration, ' ', 1) > 5;

-- List all movies released in a specific year (e.g., 2020) --
select * from content
where type="movie" and release_year=2020;

-- Find the top 5 countries with the most content on Netflix --
select country, count(*) as most_content
from content
where country is not null and country <> '' 
group by 1
order by 2 desc
limit 5;

-- Identify the longest movie --
select * from content
where type="movie" and duration=(
	select max(duration) from content
);

-- Find content added in the last 5 years --
select* from content
where to_date(date_added, 'Month DD, YYYY') >= current_date - interval '5 years';

-- Find the most common rating for movies and TV shows--
select type, rating 
from
(
	select  type, 
			rating, 
            count(*),
            rank() over(partition by type order by count(*) desc) as ranking
	from content
    group by 1,2
) as t1
where ranking=1;

/* Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category. */
with new_table as
(
	select *, 
	case 
	when description like '%kill%' or
		description like '%violence%' then 'Bad_content'
		else 'Good_content'
	end category
from content
)
select category, count(*) as total_content
from new_table
group by 1;