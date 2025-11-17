USE sakila;


-- Step 1: Creating view

CREATE VIEW customer_rental_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
JOIN rental r USING (customer_id)
GROUP BY c.customer_id, customer_name, c.email;

-- Step 2: Creating rental summary per customer

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    crs.customer_id,
    SUM(p.amount) AS total_paid
FROM customer_rental_summary crs
JOIN payment p USING (customer_id)
GROUP BY crs.customer_id;


-- Step 3: Creating CTE and final report

WITH customer_summary AS (
    SELECT 
        crs.customer_name,
        crs.email,
        crs.rental_count,
        cps.total_paid
    FROM customer_rental_summary crs
    JOIN customer_payment_summary cps USING (customer_id)
)

SELECT
    customer_name,
    email,
    rental_count,
    total_paid,
    (total_paid / rental_count) AS average_payment_per_rental
FROM customer_summary
ORDER BY customer_name;

-- BONUS; Dropping the view and temp table cleanup

DROP VIEW customer_rental_summary;

DROP TEMPORARY TABLE IF EXISTS customer_payment_summary;
