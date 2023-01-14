USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/


-- Segment 1:

-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

SELECT COUNT(*) FROM genre;
-- Total number of rows in 'genre' table equals 14662

SELECT COUNT(*) FROM ratings;
-- Total number of rows in 'ratings' table equals 7997

SELECT COUNT(*) FROM role_mapping;
-- Total number of rows in 'role_mapping' table equals 15615

SELECT COUNT(*) FROM director_mapping;
-- Total number of rows in 'director_mapping' table equals 3867

SELECT COUNT(*) FROM names;
-- Total number of rows in 'names' table equals 25735

SELECT COUNT(*) FROM movie;
-- Total number of rows in 'movie' table equals 7997


-- Q2. Which columns in the movie table have null values?
-- Type your code below:
	SELECT 
		SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS id_count_null, 
		SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_count_null, 
		SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_count_null,
		SUM(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS date_count_null,
		SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_count_null,
		SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_count_null,
		SUM(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS worlwide_gross_income_count_null,
		SUM(CASE WHEN languages IS NULL THEN 1 ELSE 0 END) AS languages_count_null,
		SUM(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END) AS production_company_count_null
	FROM movie;

-- Null Counts
	-- country_null_count equals 20
    -- worldwide_gross_income_null_count equals 3274
    -- languages_null_count equals 194
    -- production_company_null_count equals 528


-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
	-- Number of movies released each year
    SELECT year, COUNT(id) as number_of_movies
	FROM movie
	GROUP BY year
	ORDER BY year;

	-- month wise trend
    SELECT MONTH(date_published) AS month_num, COUNT(id) AS number_of_movies 
	FROM movie
	GROUP BY month_num
	ORDER BY month_num;

-- Highest movies released in Month of March.

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:
	SELECT year, Count(id) AS number_of_movies
	FROM   movie
	WHERE  (country LIKE '%INDIA%' OR country LIKE '%USA%') AND year = 2019;
    
    -- using LIKE instead of = because there are entries where 2 countries have combinedly produced a movie (first country being India or USA)
    


/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
	SELECT DISTINCT genre as unique_list_of_genre
	FROM genre;


/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:
	SELECT genre, Count(mv.id) AS num_of_movies
	FROM movie AS mv
	INNER JOIN genre AS ge
	ON ge.movie_id = mv.id
	GROUP BY genre
	ORDER BY num_of_movies DESC 
    LIMIT 1;

-- 4285 that is highest number of movies produces in Drama genre.

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:
	WITH count_genre AS
	(
	SELECT movie_id, 
			COUNT(genre) AS num_of_movies
	FROM genre
	GROUP BY movie_id
	HAVING num_of_movies=1
	)
	SELECT COUNT(movie_id) AS num_of_movies
	FROM count_genre;

-- there are 3289 Movies having just one genre

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
	SELECT genre, ROUND(AVG(duration),2) AS avg_duration
	FROM genre AS ge
	INNER JOIN movie AS mo
	ON ge.movie_id = mo.id
	GROUP BY genre
	ORDER BY avg_duration DESC;

-- Action Movies is having longer avg duration as compared to other genre.

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
	WITH genre_rank AS
	(
	SELECT genre, COUNT(movie_id) AS movie_count,
			RANK() OVER(ORDER BY COUNT(movie_id) DESC) AS genre_rank
	FROM genre
	GROUP BY genre
	)
	SELECT *
	FROM genre_rank
	WHERE genre='Thriller';

-- Rank of thriller movies is 3.

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:
	SELECT 
		MIN(avg_rating) AS min_avg_rating, 
		MAX(avg_rating) AS max_avg_rating,
		MIN(total_votes) AS min_total_votes, 
        MAX(total_votes) AS max_total_votes,
		MIN(median_rating) AS min_median_rating, 
        MAX(median_rating) AS max_median_rating
	FROM ratings;


/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too
	SELECT title, avg_rating,
		DENSE_RANK() OVER(ORDER BY avg_rating DESC) AS movie_rank
	FROM movie AS mo
	INNER JOIN ratings AS ra
	ON ra.movie_id = mo.id
	LIMIT 10;

-- Top 3 movies having avg_rating is 9.7 or more.

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have
	SELECT median_rating, COUNT(movie_id) AS movie_count
	FROM ratings
	GROUP BY median_rating
	ORDER BY median_rating;


/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:
	WITH prod_house_rating AS 
    (
		SELECT production_company, COUNT(id) as movie_count,
			RANK() OVER(ORDER BY COUNT(id) DESC) AS prod_company_rank
		FROM movie as mo
        INNER JOIN ratings as ra
        ON mo.id = ra.movie_id
        WHERE avg_rating > 8
        AND production_company IS NOT NULL
        GROUP BY production_company
	 )	
	SELECT * from prod_house_rating
	WHERE prod_company_rank = 1;

-- Production company (Dream Warrior Pictures and National Theater live have produce most number movies having avg ratings>8

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
	SELECT ge.genre, COUNT(ge.movie_id) AS movie_count
	FROM genre AS ge
	INNER JOIN ratings AS ra
	ON ge.movie_id = ra.movie_id
	INNER JOIN movie AS mo
	ON mo.id = ge.movie_id
	WHERE country LIKE '%USA%' AND ra.total_votes>1000 
		  AND MONTH(date_published)=3 AND year=2017
	GROUP BY ge.genre
	ORDER BY movie_count DESC;

-- Drama genre has most number of movies release in March 2017 in USA having more than 1000 votes.

-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
	SELECT title, avg_rating, genre
	FROM genre AS ge
	INNER JOIN ratings AS ra
	ON ge.movie_id = ra.movie_id
	INNER JOIN movie AS mo
	ON mo.id = ge.movie_id
	WHERE title LIKE 'The%' 
		  AND avg_rating > 8
	GROUP BY title
	ORDER BY avg_rating DESC;

-- Title 'The Brighton Mirale has highest avg rating of 9.5
-- 8 movies having title is starts with 'The'

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
	SELECT median_rating, COUNT(movie_id) AS movie_count
	FROM movie AS mo
	INNER JOIN ratings AS ra
	ON mo.id = ra.movie_id
	WHERE median_rating = 8 AND 
		  date_published BETWEEN '2018-04-01' AND '2019-04-01'
	GROUP BY median_rating;

-- 361 movies released between 1 April 2018 and 1 April 2019 which is having median_avg ratings of 8.

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:
	
	SELECT languages, SUM(total_votes) as total_num_votes
	FROM movie AS mo
	INNER JOIN ratings AS ra
	ON ra.movie_id= mo.id
	WHERE languages like '%Italian%'
	UNION
	SELECT languages, SUM(total_votes) as total_num_votes
	FROM movie AS mo
	INNER JOIN ratings AS ra
	ON ra.movie_id= mo.id
	WHERE languages like '%GERMAN%'
	ORDER BY total_num_votes DESC;

-- Yes German movies are getting more votes as compared to Italian

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
	SELECT 
		SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls, 
		SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls,
		SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth_nulls,
		SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls
	FROM names;


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
	WITH top_3_genres AS
	(
		SELECT genre, Count(mo.id) AS movie_count ,
			Rank() OVER(ORDER BY Count(mo.id) DESC) AS genre_rank
		FROM movie AS mo
		INNER JOIN genre AS ge
		ON ge.movie_id = mo.id
		INNER JOIN ratings AS ra
		ON ra.movie_id = mo.id
		WHERE avg_rating > 8
		GROUP BY genre 
        LIMIT 3 
	)
	SELECT nm.NAME AS director_name, Count(di.movie_id) AS movie_count
	FROM director_mapping  AS di
	INNER JOIN genre AS ge
	using (movie_id)
	INNER JOIN names AS nm
	ON nm.id = di.name_id
	INNER JOIN top_3_genres
	using (genre)
	INNER JOIN ratings
	using (movie_id)
	WHERE avg_rating > 8
	GROUP BY name
	ORDER BY movie_count DESC 
    LIMIT 3;

-- James Mangold, Anthony Russo, Soubin Shahir are top 3 directors.

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
	SELECT DISTINCT name AS actor_name, COUNT(ra.movie_id) AS movie_count
	FROM ratings AS ra
	INNER JOIN role_mapping AS rm
	ON rm.movie_id = ra.movie_id
	INNER JOIN names AS nm
	ON rm.name_id = nm.id
	WHERE median_rating >= 8 
		  AND category = 'actor'
	GROUP BY actor_name
	ORDER BY movie_count DESC
	LIMIT 2;

-- Top 2 actors are Manmooty and Mohanlal

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
	SELECT production_company, SUM(total_votes) AS vote_count,
			RANK() OVER(ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
	FROM movie AS mo
	INNER JOIN ratings AS ra
	ON mo.id = ra.movie_id
	GROUP BY production_company
	LIMIT 3;

-- Top 3 production companies are Marvel Studios. Twentieth Century Fox and Warner Bros.

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
	WITH actor_ranking_details AS 
    (
    SELECT nm.NAME AS actor_name, SUM(total_votes) AS total_votes, 
		   Count(ra.movie_id) AS movie_count,
		   Round(Sum(avg_rating * total_votes) / Sum(total_votes), 2) AS actor_avg_rating
	FROM movie AS mo
	INNER JOIN ratings AS ra
    ON mo.id = ra.movie_id
	INNER JOIN role_mapping AS rm
	ON mo.id = rm.movie_id
	INNER JOIN names AS nm
	ON rm.name_id = nm.id
	WHERE category = 'ACTOR' AND country = "india"
	GROUP BY actor_name 
			 HAVING movie_count >= 5
    )
	SELECT *, 
		Rank() OVER(ORDER BY actor_avg_rating DESC) AS actor_rank
	FROM actor_ranking_details; 

-- TOP actor is Vijay Sethupathi , after that Fahadh Faasil and Yogi Babu

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
	WITH actress_ranking_details AS
	(
	SELECT nm.NAME AS actress_name, SUM(total_votes) AS total_votes, 
           Count(ra.movie_id) AS movie_count,
		Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating
	FROM movie AS mo
	INNER JOIN ratings AS ra
	ON mo.id=ra.movie_id
	INNER JOIN role_mapping AS rm
	ON mo.id = rm.movie_id
	INNER JOIN names AS nm
	ON rm.name_id = nm.id
	WHERE category = 'ACTRESS' AND 
		  country = "INDIA" AND languages LIKE '%HINDI%'
	GROUP BY actress_name 
			 HAVING movie_count>=3 
    )
	SELECT *,
		Rank() OVER(ORDER BY actress_avg_rating DESC) AS actress_rank
	FROM actress_ranking_details 
    LIMIT 5;


/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:
	SELECT DISTINCT title, avg_rating,
		CASE 
			WHEN avg_rating > 8 THEN 'Superhit movies'
			WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
			WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
			WHEN avg_rating < 5 THEN 'Flop movies'
		END AS avg_rating_category
	FROM movie AS mo
	INNER JOIN genre AS ge
	ON mo.id=ge.movie_id
	INNER JOIN ratings as ra
	ON mo.id=ra.movie_id
	WHERE genre='Thriller';


/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
	SELECT genre, 
		   ROUND(AVG(duration),2) AS avg_duration,
		   SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
		   AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) AS moving_avg_duration
	FROM movie AS mo
	INNER JOIN genre AS ge
	ON mo.id= ge.movie_id
	GROUP BY genre
	ORDER BY genre;


-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
	WITH top_genres AS
	(
	SELECT genre, Count(mo.id) AS movie_count,
		Rank() OVER(ORDER BY Count(mo.id) DESC) AS genre_rank
	FROM movie AS mo
	INNER JOIN genre AS ge
	ON ge.movie_id = mo.id
	INNER JOIN ratings AS ra
	ON ra.movie_id = mo.id
	WHERE avg_rating > 8
	GROUP BY genre 
    LIMIT 3
    ), 
    movie_details AS
	(
	SELECT genre, year, title AS movie_name,
		CAST(replace(replace(ifnull(worlwide_gross_income,0),'INR',''),'$','') AS decimal(10)) AS worlwide_gross_income ,
		DENSE_RANK() OVER(partition BY year ORDER BY CAST(replace(replace(ifnull(worlwide_gross_income,0),'INR',''),'$','') AS decimal(10)) DESC) AS movie_rank
	FROM movie AS mo
	INNER JOIN genre AS ge
	ON mo.id = ge.movie_id
	WHERE genre IN (SELECT genre FROM top_genres)
	GROUP BY movie_name
	)
	SELECT *
	FROM movie_details
	WHERE movie_rank<=5
	ORDER BY YEAR;


-- Top 3 Genres based on most number of movies


-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
	SELECT production_company, COUNT(mo.id) AS movie_count,
		ROW_NUMBER() OVER(ORDER BY count(id) DESC) AS prod_comp_rank
	FROM movie AS mo
	INNER JOIN ratings AS ra
	ON mo.id=ra.movie_id
	WHERE median_rating>=8 
		  AND production_company IS NOT NULL 
          AND POSITION(',' IN languages)>0
	GROUP BY production_company
	LIMIT 2;


-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
	
	WITH actress_ranking_details AS 
	(
		SELECT name AS actress_name, 
			   SUM(total_votes) AS total_votes, 
			   COUNT(rm.movie_id) as movie_count, 
			   Round(SUM(avg_rating * total_votes) / SUM(total_votes), 2) as actress_avg_rating
	FROM names as nm
	INNER JOIN role_mapping AS rm
	ON nm.id= rm.name_id
	INNER JOIN movie as mo
	ON rm.movie_id = mo.id
	INNER JOIN ratings AS ra
	ON mo.id = ra.movie_id
	INNER JOIN GENRE AS ge
	ON ge.movie_id = mo.id
	WHERE category = 'actress' 
		  AND avg_rating> 8
		  AND genre = "Drama"
	GROUP BY actress_name
	)
	SELECT *, 
		RANK() OVER(ORDER BY movie_count DESC) AS actress_rank
	FROM actress_ranking_details
	LIMIT 3;

-- Top 3 actress are Paravathy Thiruvothu , Susan Brown and Amanda Lawrence

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:
	WITH movie_date_details AS
	(
	SELECT di.name_id, name, di.movie_id, mo.date_published, 
		LEAD(date_published, 1) OVER(PARTITION BY di.name_id ORDER BY date_published, di.movie_id) AS next_movie_date
	FROM director_mapping di
	INNER JOIN names AS nm
	ON di.name_id=nm.id 
	INNER JOIN movie AS mo
	ON di.movie_id=mo.id
	),
	date_difference AS
	(
	SELECT *, DATEDIFF(next_movie_date, date_published) AS diff
	FROM movie_date_details
	),
	avg_inter_days AS
	(
	SELECT name_id, AVG(diff) AS avg_inter_movie_days
	FROM date_difference
	GROUP BY name_id
	),
	final_result AS
	(
	SELECT di.name_id AS director_id, name AS director_name,
	COUNT(di.movie_id) AS number_of_movies,
	ROUND(avg_inter_movie_days) AS inter_movie_days,
	ROUND(AVG(avg_rating),2) AS avg_rating,
	SUM(total_votes) AS total_votes,
	MIN(avg_rating) AS min_rating,
	MAX(avg_rating) AS max_rating,
	SUM(duration) AS total_duration,
	ROW_NUMBER() OVER(ORDER BY COUNT(di.movie_id) DESC) AS director_row_rank
	FROM names AS nm
	INNER JOIN director_mapping AS di
	ON nm.id=di.name_id
	INNER JOIN ratings AS ra
	ON di.movie_id=ra.movie_id
	INNER JOIN movie AS mo
	ON mo.id=ra.movie_id
	INNER JOIN avg_inter_days AS av
	ON av.name_id=di.name_id
	GROUP BY director_id
	)
	SELECT * FROM final_result
	LIMIT 9;