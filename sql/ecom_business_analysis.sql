-- =========================================================
-- E-Commerce SQL Business Analysis
-- Note:
-- Item sales value, shipping charges, and payment value are treated
-- as separate financial metrics because they do not reconcile exactly.
-- =========================================================


-- 1. Financial metric summary:
-- Compare total payment value, total item sales value, and total shipping charges.
-- These metrics are kept separate because they do not reconcile exactly.

SELECT
    'total_payment_value' AS metric_name,
    ROUND(SUM(payment_value), 2) AS metric_value
FROM payments

UNION ALL

SELECT
    'total_item_sales_value' AS metric_name,
    ROUND(SUM(price), 2) AS metric_value
FROM order_items

UNION ALL

SELECT
    'total_shipping_charges' AS metric_name,
    ROUND(SUM(shipping_charges), 2) AS metric_value
FROM order_items;


-- 2. Product category performance:
-- Identify which product categories generate the highest item sales value.

SELECT
    pr.product_category_name,
    COUNT(DISTINCT oi.order_id) AS order_count,
    COUNT(*) AS item_count,
    ROUND(SUM(oi.price), 2) AS total_item_sales_value,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM order_items oi
LEFT JOIN products pr
    ON oi.product_id = pr.product_id
GROUP BY pr.product_category_name
ORDER BY total_item_sales_value DESC;


-- 3. Customer state performance:
-- Identify which customer states generate the most orders and item sales value.

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(*) AS item_count,
    ROUND(SUM(oi.price), 2) AS total_item_sales_value,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_item_sales_value DESC;


-- 4. Top customer cities:
-- Identify the cities generating the highest item sales value.

SELECT
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(*) AS item_count,
    ROUND(SUM(oi.price), 2) AS total_item_sales_value,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_city, c.customer_state
ORDER BY total_item_sales_value DESC
LIMIT 20;


-- 5. Payment method performance:
-- Identify which payment methods are most used and which contribute the highest total payment value.
-- payment_record_count counts rows in the payments table.
-- order_count counts unique orders.
-- These are included separately because one order may have multiple payment records.

SELECT 
    p.payment_type,
    COUNT(*) AS payment_record_count,
    COUNT(DISTINCT p.order_id) AS order_count,
    ROUND(SUM(p.payment_value), 2) AS total_payment_value,
    ROUND(AVG(p.payment_value), 2) AS average_payment_value
FROM payments p
GROUP BY p.payment_type
ORDER BY total_payment_value DESC;


-- 6. Payment installment behavior:
-- Identify the most commonly used installment counts and their payment value contribution.

SELECT 
    p.payment_installments,
    COUNT(*) AS payment_record_count,
    COUNT(DISTINCT p.order_id) AS order_count,
    ROUND(SUM(p.payment_value), 2) AS total_payment_value,
    ROUND(AVG(p.payment_value), 2) AS average_payment_value
FROM payments p
GROUP BY p.payment_installments
ORDER BY payment_record_count DESC;


-- 7. Suspicious payment installment records:
-- Flag records where payment_installments = 0 because installment count normally starts from 1.

SELECT
    p.order_id,
    p.payment_sequential,
    p.payment_type,
    p.payment_installments,
    p.payment_value,
    CASE
        WHEN p.payment_installments = 0 THEN 1
        ELSE 0
    END AS zero_installment_flag
FROM payments p
WHERE p.payment_installments = 0
ORDER BY p.payment_value DESC;


-- 8. Shipping charges by product category:
-- Identify which product categories contribute the highest total shipping charges.

SELECT 
    pr.product_category_name,
    COUNT(*) AS item_count,
    ROUND(SUM(oi.shipping_charges), 2) AS total_shipping_charges,
    ROUND(AVG(oi.shipping_charges), 2) AS average_shipping_charge
FROM order_items oi
LEFT JOIN products pr
    ON oi.product_id = pr.product_id
GROUP BY pr.product_category_name
ORDER BY total_shipping_charges DESC;


-- 9. Shipping weight by product category:
-- Estimate which product categories contribute the highest total shipped weight.

SELECT 
    pr.product_category_name,
    COUNT(*) AS item_count,
    ROUND(SUM(pr.product_weight_g), 2) AS total_weight_shipped_g,
    ROUND(AVG(pr.product_weight_g), 2) AS average_product_weight_g,
    ROUND(SUM(oi.shipping_charges), 2) AS total_shipping_charges
FROM order_items oi
LEFT JOIN products pr
    ON oi.product_id = pr.product_id
WHERE pr.product_weight_g IS NOT NULL
GROUP BY pr.product_category_name
ORDER BY total_weight_shipped_g DESC;


-- 10. Shipping volume by product category:
-- Estimate which product categories contribute the highest total shipped volume.

SELECT 
    pr.product_category_name,
    COUNT(*) AS item_count,
    ROUND(SUM(pr.product_length_cm * pr.product_height_cm * pr.product_width_cm), 2) AS total_shipment_volume_cm3,
    ROUND(AVG(pr.product_length_cm * pr.product_height_cm * pr.product_width_cm), 2) AS average_product_volume_cm3,
    ROUND(SUM(oi.shipping_charges), 2) AS total_shipping_charges
FROM order_items oi
LEFT JOIN products pr
    ON oi.product_id = pr.product_id
WHERE pr.product_length_cm IS NOT NULL
  AND pr.product_height_cm IS NOT NULL
  AND pr.product_width_cm IS NOT NULL
GROUP BY pr.product_category_name
ORDER BY total_shipment_volume_cm3 DESC;


-- 11. Monthly item sales trend:
-- Track monthly order count, item sales value, and shipping charges over time.

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(*) AS item_count,
    ROUND(SUM(oi.price), 2) AS total_item_sales_value,
    ROUND(SUM(oi.shipping_charges), 2) AS total_shipping_charges
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY order_month
ORDER BY order_month;

-- 12. Order status summary:
-- Review overall order fulfillment status distribution.

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 3) AS percentage_of_orders
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

