-- Homework 8 SQL scripts

USE sakila ;

-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name FROM actor ;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(UPPER(first_name), ' ', UPPER(last_name)) as 'Actor Name'
	FROM actor ;
    
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe". 

SELECT actor_id, first_name, last_name
	FROM actor
    WHERE first_name = 'Joe' ;

-- 2b. Find all actors whose last name contain the letters `GEN`:

SELECT *
	FROM actor
    WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

SELECT last_name, first_name
	FROM actor
    WHERE last_name LIKE '%LI%';
    
    
-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country
	FROM country
    WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Create a column in the table `actor` named `description`and use the data type `BLOB` 

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE actor
	ADD COLUMN description blob ;

SET SQL_SAFE_UPDATES = 1;

SELECT * FROM actor ;

-- 3b. Delete the `description` column.

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE actor
	DROP COLUMN description;

SET SQL_SAFE_UPDATES = 1;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(actor_id) as 'count'
	FROM actor  
    GROUP BY last_name ;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, COUNT(actor_id) AS 'count'
	FROM actor 
	GROUP BY last_name
	HAVING COUNT(actor_id) > 1 ;
  
-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

UPDATE actor
	SET first_name = 'HARPO'
    WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS' ;

-- 4d.`GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

SET SQL_SAFE_UPDATES = 0;

UPDATE actor
	SET first_name = 'GROUCHO'
    WHERE first_name = 'HARPO' ;

SET SQL_SAFE_UPDATES = 1;

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
-- incremented table and constraint names to avoid unique constraints errors/loss of data from dropping address table 

CREATE TABLE address2 (
  address_id smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  address varchar(50) NOT NULL,
  address2 varchar(50) DEFAULT NULL,
  district varchar(20) NOT NULL,
  city_id smallint(5) unsigned NOT NULL,
  postal_code varchar(10) DEFAULT NULL,
  phone varchar(20) NOT NULL,
  location geometry NOT NULL,
  last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (address_id),
  KEY `idx_fk_city_id` (city_id),
  SPATIAL KEY `idx_location` (location),
  CONSTRAINT `fk_address_city2` FOREIGN KEY (city_id) REFERENCES `city` (city_id) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8 ;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
-- Use the tables `staff` and `address`.

SELECT a.first_name, a.last_name, b.*
	FROM staff AS a
	LEFT OUTER JOIN address AS b ON a.address_id = b.address_id ;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
-- Use tables `staff` and `payment`.

SELECT a.first_name, a.last_name, SUM(b.amount) as 'sum rung up'
	FROM staff AS a
    LEFT OUTER JOIN payment as b ON a.staff_id = b.staff_id
    WHERE b.payment_date BETWEEN '2005-08-01' AND '2005-08-31' 
    GROUP BY a.first_name, a.last_name;  

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables `film_actor` and `film`. Use inner join.

SELECT a.title, COUNT(b.actor_id) as 'actor count'
	FROM film AS a
    INNER JOIN film_actor as b ON a.film_id = b.film_id
    GROUP BY a.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT a.title, COUNT(b.inventory_id) as 'inventory count'
	FROM film AS a
    INNER JOIN inventory as b ON a.film_id = b.film_id
    WHERE a.title = 'Hunchback Impossible'
    GROUP BY title;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, 
-- list the total paid by each customer. List the customers alphabetically by last name:

SELECT a.first_name, a.last_name, SUM(b.amount) as 'Total Amount Paid'
	FROM customer AS a
    LEFT OUTER JOIN payment as b ON a.customer_id = b.customer_id
    GROUP BY a.last_name, a.first_name; 

-- 7a. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT a.title
	FROM film AS a
    WHERE a.title IN (SELECT b.title
							FROM film AS b
                            INNER JOIN language as c ON b.language_id = c.language_id
							WHERE a.film_id = b.film_id
                            AND c.name = 'English'
							AND b.title LIKE 'K%') 
	OR a.title IN (SELECT b.title
							FROM film AS b
							INNER JOIN language as c ON b.language_id = c.language_id
							WHERE a.film_id = b.film_id
                            AND c.name = 'English'
                            AND b.title LIKE 'Q%') ;    

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT a.first_name, a.last_name
	FROM actor AS a
    WHERE a.actor_id IN (SELECT b.actor_id
							FROM film_actor AS b
							WHERE a.actor_id = b.actor_id
                            AND b.film_id IN (SELECT c.film_id
											FROM film AS c
											WHERE b.film_id = c.film_id
                                            AND c.title = 'Alone Trip'));

-- 7c. You will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT a.first_name, a.last_name, a.email, b.*
FROM customer AS a
	INNER JOIN address AS b ON a.address_id = b.address_id
    INNER JOIN city AS c ON b.city_id = c.city_id
	INNER JOIN country AS d on c.country_id = d.country_id
    WHERE d.country = 'Canada';
    
-- 7d. Identify all movies categorized as family films.

Select a.title AS 'family films'
	FROM film AS a
	INNER JOIN film_category AS b ON a.film_id = b.film_id
	INNER JOIN category AS c ON b.category_id = c.category_id 
	WHERE c.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.

Select c.title, COUNT(a.rental_id) as 'Rental Count'
	FROM rental AS a
	LEFT OUTER JOIN inventory AS b ON a.inventory_id = b.inventory_id
	LEFT OUTER JOIN film AS c ON b.film_id = c.film_id 
	GROUP BY c.title 
	ORDER BY COUNT(a.rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT c.store_id, SUM(a.amount) 
	FROM payment AS a
	LEFT OUTER JOIN rental AS b ON a.rental_id = b.rental_id
	LEFT OUTER JOIN inventory AS c ON b.inventory_id = c.inventory_id
	GROUP BY c.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT a.store_id, c.city, d.country
	FROM store AS a
	LEFT OUTER JOIN address AS b ON a.address_id = b.address_id
	LEFT OUTER JOIN city AS c ON b.city_id = c.city_id
    LEFT OUTER JOIN country AS d on c.country_id = d.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 

SELECT e.name, SUM(a.amount) AS 'gross revenue'
	FROM payment AS a
	LEFT OUTER JOIN rental AS b ON a.rental_id = b.rental_id
	LEFT OUTER JOIN inventory AS c ON b.inventory_id = c.inventory_id
    LEFT OUTER JOIN film_category AS d on c.film_id = d.film_id
    LEFT OUTER JOIN category AS e on d.category_id = e.category_id
    GROUP BY e.name
    ORDER BY SUM(a.amount) DESC
    LIMIT 5; 
    
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 

CREATE VIEW `top_5_genres` 
	AS SELECT e.name, SUM(a.amount) AS 'gross revenue'
	FROM payment AS a
	LEFT OUTER JOIN rental AS b ON a.rental_id = b.rental_id
	LEFT OUTER JOIN inventory AS c ON b.inventory_id = c.inventory_id
    LEFT OUTER JOIN film_category AS d on c.film_id = d.film_id
    LEFT OUTER JOIN category AS e on d.category_id = e.category_id
    GROUP BY e.name
    ORDER BY SUM(a.amount) DESC
    LIMIT 5; 
    
-- 8b. How would you display the view that you created in 8a?

SELECT * FROM top_5_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW top_5_genres;

