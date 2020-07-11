/* Query 1: Who are the top 5 customers and the revenue they brought in (Incl. late fees)? */

SELECT 	c.first_name || ' ' || c.last_name AS full_name,
				SUM(p.amount) AS total_amt_paid,
				COUNT(p.rental_id) AS num_movies_rented
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


/* Query 2:  What are the most popular movie genres in terms of revenue? */

SELECT 	c.name AS genre,
				SUM(f.rental_rate) AS revenue
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f
ON fc.film_id = f.film_id
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


/* Query 3: What are our top 5 customers favourite genre of movies? */

WITH table1 AS (
	SELECT 	c.customer_id,
					c.first_name || ' ' || c.last_name AS full_name,
					SUM(p.amount) AS total_amt_paid,
					COUNT(*) AS num_movies_rented
	FROM customer c
	JOIN payment p
	ON c.customer_id = p.customer_id
	GROUP BY 1, 2
	ORDER BY 3 DESC
	LIMIT 5)

SELECT 	full_name,
				c.name AS genre,
				DENSE_RANK() OVER (PARTITION BY full_name ORDER BY COUNT(p.rental_id) DESC) AS genre_rank
FROM table1
JOIN payment p
ON table1.customer_id = p.customer_id
JOIN rental r
ON p.customer_id = r.customer_id
JOIN inventory i
ON r.inventory_id = i.inventory_id
JOIN film f
ON i.film_id = f.film_id
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON fc.category_id = c.category_id
GROUP BY 1, 2
ORDER BY 1, 3;


/* Query 4: What is the average amount of dollars has each customer spent? */

WITH t1 AS (
	SELECT 	c.first_name || ' ' || c.last_name AS full_name,
					COUNT(*) AS num_dvds_rented,
					SUM(p.amount) AS all_payments
	FROM customer c
	JOIN payment p
	ON c.customer_id = p.customer_id
	GROUP BY 1
	ORDER BY 3 DESC)

SELECT 	full_name,
				ROUND((all_payments/num_dvds_rented), 2) AS average_payment
FROM t1
GROUP BY 1, 2
ORDER BY 2 DESC;
