-- Check if every order has a matching customer
SELECT
    COUNT(*) AS missing_customers
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Check if every order item belongs to a valid order
SELECT 
	COUNT(*) AS missing_orders
FROM order_items oi
LEFT JOIN orders o
	ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Check if every order item has a matching product
SELECT
	COUNT(*) AS missing_products
FROM order_items oi
LEFT JOIN products p
	ON oi.product_id=p.product_id
WHERE p.product_id IS NULL;

-- Check if every payment corresponds to a valid order
SELECT 
	COUNT(*) AS payments_with_missing_order_id
FROM payments p
LEFT JOIN orders o
	ON p.order_id = o.order_id
WHERE o.order_id IS NULL;
