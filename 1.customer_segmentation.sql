WITH customer_ltr AS (
    SELECT customerkey,
        cleaned_name,
        SUM(net_revenue) AS total_ltr
    FROM cohort_analysis
    GROUP BY customerkey,
        cleaned_name
),
customer_segment AS (
    SELECT PERCENTILE_CONT(0.25) WITHIN GROUP(
            ORDER BY total_ltr
        ) AS ltr_25th_percentile,
        PERCENTILE_CONT(0.75) WITHIN GROUP(
            ORDER BY total_ltr
        ) AS ltr_75th_percentile
    FROM customer_ltr
),
segment_values AS (
    SELECT customer_ltr.*,
        CASE
            WHEN total_ltr < ltr_25th_percentile THEN '1-LOW-VALUE'
            WHEN total_ltr <= ltr_75th_percentile THEN '2-MID-VALUE'
            ELSE '3-HIGH-VALUE'
        END AS customer_segmentation
    FROM customer_ltr,
        customer_segment
)
SELECT customer_segmentation,
    SUM(total_ltr) AS total_ltr,
    COUNT(customerkey),
    SUM(total_ltr) / COUNT(customerkey) AS avg_ltr
FROM segment_values
GROUP BY customer_segmentation
ORDER BY customer_segmentation DESC