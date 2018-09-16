use sakila;
-- 1a Display first and last names of all actors from actor table:
SELECT first_name,last_name 
FROM actor;

-- 1b Display first and last names of all actors in single column from actor table:
SELECT upper(concat(first_name,',',last_name)) AS ActorName
FROM actor;

-- 2a Display ID Number,first and last Names WHERE first_name = 'Joe':
SELECT actor_id,first_name,last_name 
FROM actor
WHERE first_name = 'joe';

-- 2b Display actors whose last name contain the letters GEN:
SELECT first_name,last_name
FROM actor
WHERE last_name like '%GEN%';

-- 2c Display actors whose last name contains the letters LI:
SELECT first_name,last_name
FROM actor 
WHERE last_name like '%LI%'
ORDER BY last_name,first_name;

-- 2d Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id,country
FROM country
WHERE country IN ('Afghanistan','Bangladesh','China');

-- 3a create a column in the table actor named description and use the data type BLOB:
ALTER TABLE actor
ADD description BLOB;

-- SELECT * FROM actor;
-- 3b Delete the description column:
ALTER TABLE actor
DROP description;

-- 4a Display last names of actors, as well as how many actors have that last name:
SELECT last_name, count(last_name) as count
FROM actor
GROUP BY last_name;

-- 4b List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors:
SELECT last_name, count(last_name) as count
FROM actor
GROUP BY last_name
HAVING count >=2;

-- 4c Actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS
UPDATE actor
SET first_name = 'HARPO',last_name = 'WILLIAMS'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- 4d if the first name of the actor is currently HARPO, change it to GROUCHO:
UPDATE actor
SET first_name = 'GROUCHO',last_name = 'WILLIAMS'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE sakila.address;

-- 6a JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name,s.last_name,a.address
FROM staff as s
INNER JOIN address as a 
on s.address_id = a.address_id;

-- 6b JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment:
-- select * from payment;
SELECT s.first_name,s.last_name,sum(p.amount)
FROM staff AS s 
INNER JOIN payment AS p
ON s.staff_id = p.staff_id
WHERE MONTH(p.payment_date) = 08 AND YEAR(p.payment_date) = 2005
GROUP BY p.staff_id;

-- 6c  List each film and the number of actors who are listed for that film. Use tables film_actor and film:
SELECT f.title,count(fa.actor_id) AS 'Actors'
FROM film AS f
INNER JOIN film_actor AS fa
ON f.film_id = fa.film_id
GROUP BY title
ORDER BY Actors DESC;


-- 6d How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title,count(inventory_id) as 'Number Of Copies'
FROM film
INNER JOIN inventory
USING (film_id)
WHERE title = 'Hunchback Impossible'
GROUP BY title;


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT first_name,last_name,sum(amount) as 'Total Paid'
FROM  customer
INNER JOIN payment
USING(customer_id)
GROUP BY customer_id
ORDER BY last_name ASC;

-- 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title 
FROM film
WHERE (title like 'k%') OR (title like 'q%') AND language_id IN (
SELECT language_id 
FROM language
WHERE name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name,last_name
FROM actor
WHERE actor_id IN 
(SELECT actor_id FROM film_actor 
WHERE film_id IN 
(SELECT film_id FROM film
 WHERE title = 'Alone Trip'));
                             
-- 7c. names and email addresses of all Canadian customers. Use joins to retrieve this information. 
SELECT cu.first_name,cu.last_name,cu.email,co.country
FROM customer AS cu
JOIN address AS a
USING(address_id)
JOIN city as c
USING(city_id)
JOIN country as co
USING (country_id)
WHERE country = 'canada';


-- 7d. Identify all movies categorized as family films.
-- SELECT * FROM film_list;
-- option 1 using film_list view 
SELECT title,category 
FROM film_list
WHERE category = 'family';

-- option 2 using subquerry 
SELECT f.title
FROM film AS f
WHERE film_id IN(
SELECT film_id
FROM film_category AS fc
WHERE category_id IN(
SELECT category_id 
FROM category AS c
WHERE c.name = 'Family'));

-- option 3 using multiple inner joins
SELECT f.title,c.name
FROM film as f
JOIN film_category
USING(film_id)
JOIN category as c
USING(category_id)
WHERE c.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.

SELECT title, COUNT(title) as 'Rentals'
FROM film
INNER JOIN inventory
ON (film.film_id = inventory.film_id)
INNER JOIN rental
ON (inventory.inventory_id = rental.inventory_id)
GROUP by title
ORDER BY rentals desc;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- option 1 using sales_by_store view
SELECT store,total_sales
FROM sales_by_store;

-- option 2 using multiple joins
SELECT store_id,SUM(p.amount) AS 'Gross amount'
FROM payment AS p
JOIN rental
USING(rental_id)
JOIN inventory AS i
USING(inventory_id)
JOIN store AS s 
USING(store_id)
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id,city,country
FROM store
INNER JOIN address
USING (address_id)
INNER JOIN city
USING (city_id)
INNER JOIN country
USING (country_id);


-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- option 1 using sales_by_film view
select * from sales_by_film_category
LIMIT 5;

-- option 2 using multiple joins 
SELECT c.name as 'Genre', SUM(p.amount) AS 'Gross Rev'
FROM payment AS p
JOIN rental AS r
USING(rental_id)
JOIN inventory as i
USING(inventory_id)
JOIN film as f
USING(film_id)
JOIN film_category as fc
USING(film_id)
JOIN category as c
USING(category_id)
GROUP BY c.name
ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 8a. Create a view with the Top five genres by gross revenue. 
CREATE VIEW top_five_genres AS
SELECT c.name as 'Genre', SUM(p.amount) AS 'Gross Rev'
FROM payment AS p
JOIN rental AS r
USING(rental_id)
JOIN inventory as i
USING(inventory_id)
JOIN film as f
USING(film_id)
JOIN film_category as fc
USING(film_id)
JOIN category as c
USING(category_id)
GROUP BY c.name
ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 8b. Display the view that you created in 8a?
SELECT * 
FROM top_five_genres;

-- 8c. Drop the  top_five_genres view
DROP VIEW top_five_genres;

