## Initial Questions

#### Report- overall percentage-based table

- Can I assume that if a `customer_id` has orders in consecutive months following their first purchase, they can be considered "retained" for those month? (repeat customer rate)
- follow up: How should I treat customers with orders in non-consecutive months(ex: orders in months 2,4 and 5)? Retained or not retained? (currently assuming they are considered not retained)

#### Report - filterable table

- Are `net_revenue`, `num_customers`, `order_count` calculated regardless of retention? Or should I only calculate cohort totals based on retained customers?

#### Report - LTV

- is `cumulative revenue for a cohort` calculated by month

## Working Questions

#### Report - filterable table

- Should filtering be done for every possible value? For example, `discount_codes` has 4960 unique values. Some orders did not use a code. Do I need to include all of these codes as filterable options in a dropdown? Or just an option for "used discount code"? Same goes for `source_medium` (61 unique values, some orders don't have a `source_medium` value)
