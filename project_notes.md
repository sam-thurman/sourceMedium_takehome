**Total number of unique `customer_id`'s:**
(unique customers =) 75120

_Query_:

```
SELECT COUNT(DISTINCT(customer_id))
FROM `source-medium-take-home.SM_test_project_dataset.Maintb`
```

**Total number of unique customers who made more than one purchase**
13298

_Query_:

```
SELECT COUNT(customer_id)
FROM (SELECT customer_id, COUNT(\*) AS ord_count
FROM `source-medium-take-home.SM_test_project_dataset.Maintb`
GROUP BY customer_id
HAVING ord_count>1)
```

**Number of distinct `discount_codes`**
4960
