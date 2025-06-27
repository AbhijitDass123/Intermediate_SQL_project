SELECT cohort_year,
    COUNT(DISTINCT customerkey) AS total_customer,
    ROUND(SUM(net_revenue)) AS total_revenue,
    ROUND(SUM(net_revenue) / COUNT(DISTINCT customerkey)) AS customer_average_revenue
FROM cohort_analysis
WHERE orderdate = first_purchase
GROUP BY cohort_year