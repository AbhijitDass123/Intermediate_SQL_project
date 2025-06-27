--VIEWS--
/*Think of a view as a saved SQL query that acts like a virtual table. 
 It doesn't store data itself, but shows you data from real tables in a customized way.
 Like saving a search on an e-commerce site to reuse later*/
CREATE VIEW daily_revenue AS
SELECT orderdate,
    SUM(quantity * netprice * exchangerate) AS net_revenue
FROM sales
GROUP BY orderdate
ORDER BY orderdate
SELECT *
FROM daily_net_revenue 

---Cohort_analysis---
/*A cohort is a group of people/items sharing common characteristics during a specific time period. 
 Example: Person A and B made their 1st purchase in the same year*/
CREATE VIEW Cohort_analysis AS WITH customer_revenue AS(
    SELECT s.orderdate,
        c.customerkey,
        SUM(quantity * netprice * exchangerate) AS net_revenue,
        c.countryfull AS country_name,
        c.age,
        c.surname,
        c.givenname
    FROM sales s
        LEFT JOIN customer c ON c.customerkey = s.customerkey
    GROUP BY s.orderdate,
        c.customerkey,
        c.countryfull,
       c.age,
    c.surname,
      c.givenname
)
SELECT *,
    MIN(cr.orderdate) OVER(PARTITION BY cr.customerkey) AS first_purchase,
    EXTRACT(
        year
        FROM MIN(cr.orderdate) OVER(PARTITION BY cr.customerkey)
    ) AS cohort_year,
    CONCAT(TRIM(surname), ' ', TRIM(givenname)) AS cleaned_name
FROM customer_revenue cr 


--Use of Views--
SELECT cohort_year,
    cleaned_name,
    SUM(net_revenue) AS total_revenue
FROM Cohort_analysis
GROUP BY cohort_year,
    cleaned_name
ORDER BY cohort_year
