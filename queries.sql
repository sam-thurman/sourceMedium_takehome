      ---- * FOR CHARTS/GRAPHS * ----
---- PAGE 1

-- Monthly Revenue bar-chart
SELECT 
    EXTRACT(MONTH FROM order_date) as month,
    SUM(net_revenue) AS running_netrev_total
FROM `source-medium-take-home.SM_test_project_dataset.Maintb`
GROUP BY month;

-- YTD running revenue line-plot 
WITH src AS 
(SELECT 
    order_date,
    SUM(net_revenue) AS running_netrev_total
FROM `source-medium-take-home.SM_test_project_dataset.Maintb`
GROUP BY order_date)
SELECT 
    order_date, 
    SUM(running_netrev_total) OVER (ORDER BY order_date) as running_total
FROM src;

---- PAGE 2

-- Percentage-based table
WITH with_month AS
(SELECT 
    order_date,
    EXTRACT(MONTH FROM order_date) as month,
    customer_id
FROM `source-medium-take-home.SM_test_project_dataset.Maintb`),
with_first_month AS
(SELECT 
    order_date,
    month,
    FIRST_VALUE(month) OVER (PARTITION BY customer_id ORDER BY month) AS first_month,
    NTH_VALUE(month, 2) OVER (PARTITION BY customer_id ORDER BY month) AS second_month,
    customer_id
FROM with_month),
with_retained AS 
(SELECT
    order_date,
    FIRST_VALUE(order_date) OVER(PARTITION BY customer_id ORDER BY order_date) as first_order_date,
    first_month,
    (month-first_month) AS months_since_cohort_start,
    second_month,
    customer_id
FROM with_first_month
), src AS
(SELECT 
    first_month, 
    months_since_cohort_start, 
    customer_id 
FROM with_retained
WHERE 
    ((order_date=first_order_date) 
      OR (second_month=first_month+1) 
      OR (second_month=first_month)) 
    AND customer_id IS NOT NULL)
SELECT
   	first_month,
    COUNT(DISTINCT(CASE WHEN months_since_cohort_start = 0 THEN customer_id ELSE NULL END)) AS new_customers,
    COUNT(DISTINCT(CASE WHEN months_since_cohort_start = 1 THEN customer_id ELSE NULL END))
      /COUNT(DISTINCT(CASE WHEN months_since_cohort_start = 0 THEN customer_id ELSE NULL END)) AS month_1,
    COUNT(DISTINCT(CASE WHEN months_since_cohort_start = 2 THEN customer_id ELSE NULL END))
      /COUNT(DISTINCT(CASE WHEN months_since_cohort_start = 0 THEN customer_id ELSE NULL END)) AS month_2,
    COUNT(DISTINCT(CASE WHEN months_since_cohort_start = 3 THEN customer_id ELSE NULL END))
      /COUNT(DISTINCT(CASE WHEN months_since_cohort_start = 0 THEN customer_id ELSE NULL END)) AS month_3,
    COUNT(DISTINCT(CASE WHEN months_since_cohort_start = 4 THEN customer_id ELSE NULL END))
      /COUNT(DISTINCT(CASE WHEN months_since_cohort_start = 0 THEN customer_id ELSE NULL END)) AS month_4,
    COUNT(DISTINCT(CASE WHEN months_since_cohort_start = 5 THEN customer_id ELSE NULL END))
      /COUNT(DISTINCT(CASE WHEN months_since_cohort_start = 0 THEN customer_id ELSE NULL END)) AS month_5,
    COUNT(DISTINCT(CASE WHEN months_since_cohort_start = 6 THEN customer_id ELSE NULL END))
      /COUNT(DISTINCT(CASE WHEN months_since_cohort_start = 0 THEN customer_id ELSE NULL END)) AS month_6
FROM src
GROUP BY first_month
ORDER BY first_month ASC;

---- PAGE 3

-- Filterable table
WITH with_month AS
(SELECT 
    order_date,
    EXTRACT(MONTH FROM order_date) as month,
    FIRST_VALUE(order_date) OVER(PARTITION BY customer_id ORDER BY order_date) as first_order_date,
    NTH_VALUE(order_date, 2) OVER(PARTITION BY customer_id ORDER BY order_date) as second_order_date,
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
    first_order_date,
    second_order_date,
    FIRST_VALUE(month) OVER (PARTITION BY customer_id ORDER BY month) AS first_month,
    NTH_VALUE(month, 2) OVER (PARTITION BY customer_id ORDER BY month) AS second_month,
    order_id,
    customer_id,
    source_medium,
    net_revenue,
    discount_codes,
    payment_gateway,
    order_type
FROM with_month)
SELECT
    order_date,
    first_order_date,
    second_order_date,
    month,
    first_month,
    (month-first_month) AS months_since_cohort_start,
    second_month,
    order_id,
    customer_id,
    source_medium,
    net_revenue,
    discount_codes,
    payment_gateway,
    order_type
FROM with_first_month
WHERE 
    ((order_date=first_order_date) 
      OR (second_month=first_month+1) 
      OR (second_month=first_month)) 
    AND customer_id IS NOT NULL;

---- PAGE 4

-- Lifetime value table
  --(6 seperate tables of 1 row each (1 per cohort start month) for styling purposes)
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
FROM with_month)
SELECT
    order_date,
    FIRST_VALUE(order_date) OVER(PARTITION BY customer_id ORDER BY order_date) as first_order_date,
    month,
    first_month,
    (month-first_month) AS months_since_cohort_start,
    second_month,
    order_id,
    customer_id,
    source_medium,
    net_revenue,
    discount_codes,
    payment_gateway,
    order_type
FROM with_first_month
WHERE 
    ((order_date=first_order_date) 
      OR (second_month=first_month+1) 
      OR (second_month=first_month)) 
    AND customer_id IS NOT NULL 
    AND first_month=1; --this line changes for each graph component to reflect cohort start

-- Average order value (retained customers) table
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
    month,
    first_month,
    (month-first_month) AS months_since_cohort_start,
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
WHERE 
    ((order_date=first_order_date) 
      OR (second_month=first_month+1) 
      OR (second_month=first_month)) 
    AND customer_id IS NOT NULL;


      ---- * FOR METRICS * ----

---- PAGE 2

-- Total new customers 
```Aggregate of percentage-based table query```

-- Customers who made a second purchase
WITH T1 AS
(SELECT 
    order_date,
    customer_id
FROM `source-medium-take-home.SM_test_project_dataset.Maintb`),
T2 AS
(SELECT
    Order_date,
    NTH_VALUE(order_date, 2) 
OVER(PARTITION BY customer_id ORDER BY order_date) as second_order_date,
    customer_id
FROM T1
)
SELECT COUNT(DISTINCT(customer_id)) as customers_who_made_second_purchase
FROM T2
WHERE 
    second_order_date=order_date 
    AND customer_id IS NOT NULL;

-- Customers retained 1 month or longer
WITH T1 AS
(SELECT 
    order_date,
    EXTRACT(MONTH FROM order_date) as month,
    customer_id
FROM `source-medium-take-home.SM_test_project_dataset.Maintb`),
T2 AS
(SELECT
    month,
    FIRST_VALUE(month) OVER (PARTITION BY customer_id ORDER BY month) AS first_month,
    customer_id
FROM T1),
T3 AS 
(SELECT
    (month-first_month) AS months_since_cohort_start,
    customer_id
FROM T2
)
SELECT COUNT(DISTINCT(customer_id)) as customers_for_1mo_or_longer
FROM T3
WHERE 
    months_since_cohort_start>=1 
    AND customer_id IS NOT NULL;

---- PAGE 3

-- Median orders per customer
WITH T1 AS
(SELECT
    order_date,
    customer_id,
    order_id,
    RANK() OVER(PARTITION BY customer_id ORDER BY order_date) as order_rank
FROM `source-medium-take-home.SM_test_project_dataset.Maintb`)
SELECT 
    order_rank, 
    COUNT(*) AS ord_count 
FROM T1 
GROUP BY order_rank 
ORDER BY ord_count DESC 
LIMIT 1;

-- Avg orders per retained customers
WITH T1 AS
(SELECT
    EXTRACT(MONTH FROM order_date) as month,
    order_id,
    customer_id
FROM `source-medium-take-home.SM_test_project_dataset.Maintb`),
T2 AS
(SELECT 
    FIRST_VALUE(month) OVER (PARTITION BY customer_id ORDER BY month) AS first_month,
    NTH_VALUE(month, 2) OVER (PARTITION BY customer_id ORDER BY month) AS second_month,
    order_id,
    customer_id
FROM T1)
SELECT 
  --add 1 order for each customer bc first orders aren't included in table
    (COUNT(DISTINCT(order_id))+COUNT(DISTINCT(customer_id)))/COUNT(DISTINCT(customer_id)) AS avg_orders_per_retd_customer
FROM T2
WHERE 
    ((second_month=first_month+1) 
      OR (second_month=first_month)) 
    AND customer_id IS NOT NULL;

---- PAGE 4

-- One-time customer AOV
SELECT SUM(net_revenue)/COUNT(DISTINCT order_id) as one_timer_aov
FROM `source-medium-take-home.SM_test_project_dataset.Maintb`
WHERE customer_id IN
    (     SELECT customer_id
          FROM `source-medium-take-home.SM_test_project_dataset.Maintb`
          GROUP BY customer_id
          HAVING COUNT(*) = 1
    );