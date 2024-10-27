-- SCHEMAS of Netflix

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

SELECT * FROM netflix;

-- 1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1

-- 2. Find the most common rating for movies and TV shows
Select type ,  rating 
from 
(SELECT type,  rating, count(*), 
Rank() over(partition by type order by count(*) desc) as ranking from netflix 
Group by 1,2
ORDER BY 3 desc) as t1
where ranking = 1



--3. List all movies released in a specific year (e.g., 2020)
SELECT * FROM netflix
where release_year = 2020 and type = 'Movie'

--4. Find the top 5 countries with the most content on Netflix
SELECT 
     UNNEST(STRING_TO_ARRAY(country, ','))as new_country, count(show_id) as total_content FROM netflix
GROUP BY  1
ORDER BY total_content DESC
LIMIT 5 


--5. Identify the longest movie
SELECT * FROM netflix
where 
	type = 'Movie' 
	and duration = (SELECT MAX(duration) FROM netflix)	


--6. Find content added in the last 5 years
SELECT *
	FROM netflix
WHERE 
 	TO_DATE(date_added, 'MONTH DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'
	
      
--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
from
(SELECT  UNNEST(STRING_TO_ARRAY(director, ',')) as new_director from netflix)
WHERE  new_director = 'Rajiv Chilaka'

--OR (Another solution) 

SELECT *
from
netflix
WHERE  director like '%Rajiv Chilaka%'


--8. List all TV shows with more than 5 seasons
SELECT * FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ',1):: numeric > 5

--9. Count the number of content items in each genre
SELECT
	  UNNEST(STRING_TO_ARRAY(listed_in,',')) as Genre,
	  COUNT(show_id) AS total_content
	  
FROM netflix
GROUP BY Genre

--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD,YYYY')) as year,
	COUNT(*)
	,ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100 , 2)
		   as average_content_per_year
FROM netflix 
WHERE COUNTRY = 'India'
GROUP BY 1 


--11. List all movies that are documentaries
SELECT * From netflix
WHERE listed_in ILIKE '%Documentaries%'


--12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM netflix
WHERE type = 'Movie' 
	AND casts ILIKE '%Salman Khan%'
	AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10 

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
	SELECT UNNEST(STRING_TO_ARRAY(casts,',')) as Actor,COUNT(*) AS total_content
	FROM netflix
	WHERE country ILIKE '%India'
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 10



--15.
--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
---the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.
WITH new_table 
AS
(SELECT *, 
	CASE 
	WHEN description ILIKE '%Kill%'
	OR
	description ILIKE '%violence%' THEN 'Bad_Content'
	ELSE
	'Good Content'
	End category
FROM netflix
)

SELECT 
	category,
	COUNT(*) AS total_content
FROM new_table
GROUP BY 1

