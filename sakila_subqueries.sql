-- Write SQL queries to perform the following tasks using the Sakila database:
-- 1. Determine the number of copies of the film "Hunchback Impossible" that 
-- exist in the inventory system.
SELECT 
    COUNT(*) AS number_of_copies
FROM
    film
        INNER JOIN
    inventory ON inventory.film_id = film.film_id
WHERE
    film.title = 'Hunchback Impossible';
-- 2. List all films whose length is longer than the average length of all the 
-- films in the Sakila database.
set @average_length = (SELECT ROUND(AVG(length), 2) FROM film);

SELECT 
    *
FROM
    film
WHERE
    length > @average_length
ORDER BY length;
-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".
set @appear_on = (SELECT film_id FROM film WHERE title = 'Alone Trip');

SELECT 
    actor_id, 
    CONCAT(first_name, ' ', last_name) as actors
FROM
    actor
WHERE
    actor_id IN (SELECT actor_id FROM film_actor WHERE film_id = @appear_on);
-- Bonus:
-- 4. Sales have been lagging among young families, and you want to target family 
-- movies for a promotion. Identify all movies categorized as family films.
set @category_fam = (SELECT category_id FROM category WHERE name = 'Family');

SELECT 
    film.title, category.name AS category
FROM
    film
        INNER JOIN
    film_category ON film_category.film_id = film.film_id
        INNER JOIN
    category ON category.category_id = film_category.category_id
WHERE
    category.category_id = @category_fam;
-- 5. Retrieve the name and email of customers from Canada using both subqueries and 
-- joins. To use joins, you will need to identify the relevant tables and their primary 
-- and foreign keys.
set @country_canada = (SELECT country_id FROM country WHERE country = 'Canada');

SELECT 
    CONCAT(first_name, ' ', last_name) as customers, 
    email
FROM
    customer
WHERE
    address_id IN (SELECT address_id FROM address WHERE
		city_id IN (SELECT city_id FROM city WHERE country_id = @country_canada));
-- 6. Determine which films were starred by the most prolific actor in the Sakila database. 
-- A prolific actor is defined as the actor who has acted in the most number of films. First, 
-- you will need to find the most prolific actor and then use that actor_id to find the different 
-- films that he or she starred in.
SELECT 
    actor_id, 
    COUNT(*) AS number_of_films
FROM
    film_actor
GROUP BY actor_id
ORDER BY number_of_films DESC
LIMIT 1;

set @prolific_actor = (SELECT actor_id FROM film_actor GROUP BY actor_id ORDER BY COUNT(*) DESC LIMIT 1);

SELECT 
    film.title
FROM
    film
        INNER JOIN
    film_actor ON film.film_id = film_actor.film_id
WHERE
    film_actor.actor_id = @prolific_actor;
-- 7. Find the films rented by the most profitable customer in the Sakila database. You can use 
-- the customer and payment tables to find the most profitable customer, i.e., the customer who 
-- has made the largest sum of payments.
set @largest_sum = (SELECT customer_id FROM payment GROUP BY customer_id ORDER BY SUM(amount) DESC LIMIT 1);

SELECT 
    film.title, COUNT(*) AS rent_count
FROM
    film
        INNER JOIN
    inventory ON inventory.film_id = film.film_id
        INNER JOIN
    rental ON rental.inventory_id = inventory.inventory_id
        INNER JOIN
    payment ON payment.rental_id = rental.rental_id
WHERE
    payment.customer_id = @largest_sum
GROUP BY film.title
ORDER BY rent_count DESC;

-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the 
-- average of the total_amount spent by each client. You can use subqueries to accomplish this.
SELECT 
    customer.customer_id AS client_id,
    SUM(payment.amount) AS amount_spent
FROM
    customer
        INNER JOIN
    payment ON payment.customer_id = customer.customer_id
GROUP BY customer.customer_id
HAVING SUM(payment.amount) > (SELECT ROUND(AVG(total_amount), 2) AS average_round FROM
    (SELECT SUM(amount) as total_amount FROM payment GROUP BY customer_id) AS average_amount)
ORDER BY amount_spent DESC;