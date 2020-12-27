-- Corrected retention (pg 1) query 12/26
WITH by_month AS
(SELECT 
    customer_id,
    EXTRACT(MONTH FROM order_Date) AS month
FROM `source-medium-take-home.SM_test_project_dataset.Maintb`
GROUP BY customer_id, month),
with_first_month AS
(SELECT 
    customer_id,
    month,
    FIRST_VALUE(month) OVER (PARTITION BY customer_id ORDER BY month) AS first_month,
    NTH_VALUE(month, 2) OVER (PARTITION BY customer_id ORDER BY month) AS second_month,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY month) AS row_part
FROM by_month),
with_consecutive_months AS
(SELECT 
    customer_id,
    month,
    first_month,
    second_month,
    (month-first_month) AS months_since_cohort_start,
    row_part
FROM with_first_month
WHERE month=first_month OR second_month=first_month+1)
SELECT
    first_month,
    SUM(CASE WHEN months_since_cohort_start = 0 THEN 1 ELSE 0 END) AS new_customers,
    SUM(CASE WHEN months_since_cohort_start = 1 THEN 1 ELSE 0 END)/SUM(CASE WHEN months_since_cohort_start = 0 THEN 1 ELSE 0 END) AS month_1,
    SUM(CASE WHEN months_since_cohort_start = 2 THEN 1 ELSE 0 END)/SUM(CASE WHEN months_since_cohort_start = 0 THEN 1 ELSE 0 END) AS month_2,
    SUM(CASE WHEN months_since_cohort_start = 3 THEN 1 ELSE 0 END)/SUM(CASE WHEN months_since_cohort_start = 0 THEN 1 ELSE 0 END) AS month_3,
    SUM(CASE WHEN months_since_cohort_start = 4 THEN 1 ELSE 0 END)/SUM(CASE WHEN months_since_cohort_start = 0 THEN 1 ELSE 0 END) AS month_4,
    SUM(CASE WHEN months_since_cohort_start = 5 THEN 1 ELSE 0 END)/SUM(CASE WHEN months_since_cohort_start = 0 THEN 1 ELSE 0 END) AS month_5,
    SUM(CASE WHEN months_since_cohort_start = 6 THEN 1 ELSE 0 END)/SUM(CASE WHEN months_since_cohort_start = 0 THEN 1 ELSE 0 END) AS month_6
FROM with_consecutive_months
GROUP BY first_month
ORDER BY first_month




WITH with_month AS
(SELECT 
  order_date,
  EXTRACT(MONTH FROM order_date) as month,
  order_id,
  customer_id,
  source_medium,
  net_revenue,
  discount_codes,
  payment_gateway,
  order_type
FROM `source-medium-take-home.SM_test_project_dataset.Maintb`),
with_first_month AS
(SELECT 
  order_date,
  month,
  FIRST_VALUE(month) OVER (PARTITION BY customer_id ORDER BY month) AS first_month,
  NTH_VALUE(month, 2) OVER (PARTITION BY customer_id ORDER BY month) AS second_month,
  order_id,
  customer_id,
  source_medium,
  net_revenue,
  discount_codes,
  payment_gateway,
  order_type
FROM with_month),
with_retained AS 
(SELECT
  order_date,
  FIRST_VALUE(order_date) OVER(PARTITION BY customer_id ORDER BY order_date) as first_order_date,
  NTH_VALUE(order_date, 2) OVER(PARTITION BY customer_id ORDER BY order_date) as second_order_date,
  month,
  first_month,
  second_month,
  order_id,
  customer_id,
  source_medium,
  net_revenue,
  discount_codes,
  payment_gateway,
  order_type
  FROM with_first_month
)
SELECT * 
FROM with_retained
WHERE order_date=first_order_date OR (second_month=first_month+1)