WITH customer_latest_purchase AS (
    SELECT customerkey,
        orderdate,
        cleaned_name,
        cohort_year,
        ROW_NUMBER() OVER (
            PARTITION BY customerkey
            ORDER BY orderdate DESC
        ) AS rn,
        first_purchase
    FROM cohort_analysis
),
status_by_year AS (
    SELECT customerkey,
        cleaned_name,
        cohort_year,
        orderdate AS latest_purchase,
        CASE
            WHEN orderdate < '2024-4-20'::date - INTERVAL '6 months' THEN 'churned'
            ELSE 'Active'
        END AS customer_status
    FROM customer_latest_purchase
    WHERE rn = 1
        AND first_purchase < '2024-4-20'::date - INTERVAL '6 months'
)
SELECT cohort_year,
    customer_status,
    COUNT(customerkey) AS num_customer,
    SUM(COUNT(customerkey)) OVER(
        ORDER BY cohort_year
    ),
    ROUND(
        COUNT(customerkey) / SUM(COUNT(customerkey)) 
        OVER(ORDER BY cohort_year),2) AS status_percentage
FROM status_by_year
GROUP BY cohort_year,
    customer_status
    