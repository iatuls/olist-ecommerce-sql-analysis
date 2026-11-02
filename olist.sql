-- USE olist


-- 1. How has monthly revenue and order count trended over time?
WITH monthwise_data AS (SELECT t2.payment_value,
					DATE_FORMAT(t1.order_purchase_timestamp, '%M %Y') AS 'month'
					FROM order_dataset t1
					JOIN order_payments_dataset t2
					ON t1.order_id = t2.order_id)
SELECT month,ROUND(SUM(payment_value),2) 'monthwise_revenue',COUNT(*) AS 'monthly_order_count' FROM monthwise_data
GROUP BY month
ORDER BY month ASC, monthwise_revenue DESC, monthwise_revenue DESC;


-- 2. What is the month-over-month growth rate? (LAG window function)
WITH monthwise_data1 AS (SELECT DATE_FORMAT(t1.order_purchase_timestamp, '%M %Y') AS 'month',
			ROUND(SUM(t2.payment_value),2) 'monthwise_revenue'
			FROM order_dataset t1
			JOIN order_payments_dataset t2
			ON t1.order_id = t2.order_id
			GROUP BY DATE_FORMAT(t1.order_purchase_timestamp, '%M %Y')
			ORDER BY DATE_FORMAT(t1.order_purchase_timestamp, '%M %Y'))
SELECT *,
LAG(monthwise_revenue, 1) OVER(),
ROUND(((monthwise_revenue - LAG(monthwise_revenue, 1) OVER())/(LAG(monthwise_revenue, 1) OVER()))*100,2) AS 'percent_change'
FROM monthwise_data1;


-- 3. What is the running (cumulative) revenue?
WITH monthwise_data1 AS (SELECT MONTHNAME(t1.order_purchase_timestamp) AS 'month',
			YEAR(t1.order_purchase_timestamp) AS 'year',
			ROUND(SUM(t2.payment_value),2) 'monthwise_revenue'
			FROM order_dataset t1
			JOIN order_payments_dataset t2
			ON t1.order_id = t2.order_id
			GROUP BY YEAR(t1.order_purchase_timestamp), MONTHNAME(t1.order_purchase_timestamp)
			ORDER BY YEAR(t1.order_purchase_timestamp), MONTHNAME(t1.order_purchase_timestamp))
SELECT *,
ROUND(SUM(monthwise_revenue) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2) AS running_revenue
FROM monthwise_data1;


-- 4. Which months show seasonality, and what happened around Black Friday 2017? (trend analysis)
WITH black_friday AS (SELECT t1.order_id,
					t2.payment_value,
					YEAR(t1.order_purchase_timestamp) AS 'year',
                    WEEK(t1.order_purchase_timestamp) AS 'week'
					FROM order_dataset t1
					JOIN order_payments_dataset t2
					ON t1.order_id = t2.order_id)
SELECT * FROM black_friday
WHERE year = 2017;


-- 5. Which 10 categories bring in the most revenue?
SELECT t1.product_id,t2.product_category_name,SUM(t1.price) FROM order_item_dataset t1
JOIN product_dataset t2
ON t1.product_id = t2.product_id
GROUP BY product_id,product_category_name
ORDER BY ROUND(SUM(t1.price),2) DESC
LIMIT 10;


-- 6. Which categories have high sales volume but low revenue, and vice versa? (comparison, RANK)
SELECT t1.product_id,t2.product_category_name,ROUND(SUM(t1.price),2) AS revenue,COUNT(*) AS volume,
RANK() OVER(ORDER BY ROUND(SUM(t1.price),2) DESC, COUNT(*) ASC) AS 'rank'
FROM order_item_dataset t1
JOIN product_dataset t2
ON t1.product_id = t2.product_id
GROUP BY product_id,product_category_name
ORDER BY ROUND(SUM(t1.price),2) DESC;


-- 7. What is the top product category(by revenue) in each state?
WITH state_wise_top_product AS (SELECT t1.customer_state,t6.product_category_name_english,ROUND(SUM(t3.payment_value),2) AS 'revenue',
				ROW_NUMBER() OVER(PARTITION BY t1.customer_state ORDER BY ROUND(SUM(t3.payment_value),2) DESC) AS 'rank'
				FROM customers_dataset t1
				JOIN  order_dataset t2
					ON t1.customer_id = t2.customer_id
				JOIN order_payments_dataset t3
					ON t2.order_id = t3.order_id
				JOIN order_item_dataset t4
					ON t2.order_id = t4.order_id
				JOIN product_dataset t5
					ON t5.product_id = t4.product_id
				JOIN product_category_name_translation t6
					ON t5.product_category_name = t6.product_category_name
				GROUP BY t1.customer_state, t6.product_category_name_english)
SELECT customer_state,product_category_name_english,revenue FROM state_wise_top_product
WHERE `rank` = 1
ORDER BY revenue DESC;


-- 8. Do shipping costs (freight) eat a large share of the price in certain categories?
WITH freight AS (SELECT ROUND(SUM(t1.price)) AS 'price',ROUND(SUM(t1.freight_value)) AS 'freight_value',t3.product_category_name_english
		FROM order_item_dataset t1
		JOIN product_dataset t2
		ON t1.product_id = t2.product_id
		JOIN product_category_name_translation t3
		ON t3.product_category_name = t2.product_category_name
		GROUP BY t3.product_category_name_english)
SELECT product_category_name_english,
ROUND((freight_value / (price + freight_value)) * 100,2) AS freight_share
FROM freight
ORDER BY ROUND((freight_value / (price + freight_value)) * 100,2) DESC;

-- So, yes freight has a significant share of price in many categories


-- 9. Which sellers generate the most revenue, and do they also have good reviews?
WITH sellers_rev AS (SELECT t1.seller_id, 
			ROUND(SUM(t1.price),2) AS 'total_price',
			ROUND(SUM(t1.freight_value),2) AS 'total_freight',
            SUM(t2.review_score) AS 'total_review'
			FROM order_item_dataset t1
            JOIN order_reviews_dataset t2
			ON t1.order_id = t2.order_id
			GROUP BY seller_id)
SELECT seller_id,total_review,
ROUND((total_price + total_freight),2) AS 'total_revenue',
DENSE_RANK() OVER(ORDER BY ROUND((total_price + total_freight),2) DESC) AS 'revenue_rank',
DENSE_RANK() OVER(ORDER BY total_review DESC) AS 'review_rank'
FROM sellers_rev
ORDER BY ROUND((total_price + total_freight),2) DESC;

-- Therefore, we can see that seller which has generated most revenue have got approx half the review score
-- as one which has most review score


-- 10. How concentrated is revenue? Do the top 10% of sellers make up 50%+ of revenue?
WITH sellers_rev AS (SELECT seller_id, 
			ROUND(SUM(price),2) AS 'total_price',
			ROUND(SUM(freight_value),2) AS 'total_freight'
			FROM order_item_dataset
			GROUP BY seller_id)
, cummulative_rev AS (SELECT seller_id,
			ROUND((total_price + total_freight),2) AS 'total_revenue',
			SUM((total_price + total_freight)) OVER(ORDER BY ROUND((total_price + total_freight),2) DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 'cummulative_revenue'
			FROM sellers_rev)
, percent AS (SELECT *,
		ROUND((cummulative_revenue/(SUM(total_revenue) OVER()) * 100),2) AS 'percent_of_total_revenue',
        ROW_NUMBER() OVER() AS 'simple_row_number'
		FROM cummulative_rev)
, total_seller AS (SELECT *,
		MAX(simple_row_number) OVER() AS 'total_sellers'
		FROM percent)
SELECT seller_id,total_revenue,cummulative_revenue,percent_of_total_revenue,simple_row_number FROM total_seller
WHERE simple_row_number < 0.1*(total_sellers);

-- This clearifies that 10% of sellers make more than 50% of revenue


-- 11. Which payment methods are most used?
SELECT payment_type,COUNT(*) FROM order_payments_dataset
GROUP BY payment_type;
-- Therefore, credit card is used at most followed by boleto,voucher and debit card


-- 12. Which categories get the lowest ratings
SELECT t4.product_category_name_english,COUNT(*) AS 'number_of_orders_placed',SUM(t1.review_score) AS 'total_rating' FROM order_reviews_dataset t1
JOIN order_item_dataset t2
	ON t1.order_id = t2.order_id
JOIN product_dataset t3
	ON t2.product_id = t3.product_id
JOIN product_category_name_translation t4
	ON t3.product_category_name = t4.product_category_name
GROUP BY product_category_name_english
ORDER BY SUM(t1.review_score) ASC;
-- I have also encountered number of order placed for each category since one category will get less review if it has lesser order


-- 13. RFM analysis
WITH retention AS (SELECT t1.order_id,
		t1.customer_id,
		t1.order_purchase_timestamp,
		t2.customer_unique_id,
		DAY(order_purchase_timestamp) AS 'date',
		MONTH(order_purchase_timestamp) AS 'month',
        YEAR(order_purchase_timestamp) AS 'year',
		t3.payment_value AS last_order_value,
		COUNT(*) OVER(PARTITION BY t2.customer_unique_id) AS 'total_orders'
		FROM order_dataset t1
		JOIN customers_dataset t2
			ON t1.customer_id = t2.customer_id
		JOIN order_payments_dataset AS t3
        ON t1.order_id = t3.order_id)
, ranked AS (SELECT *,
		ROW_NUMBER() OVER(PARTITION BY customer_unique_id ORDER BY `year` DESC,`month` DESC,`date` DESC) AS 'rank'
		FROM retention
		WHERE total_orders>1
		ORDER BY `year` DESC,`month` DESC,`date` DESC)
, max_ranked AS (SELECT *,
		MAX(`rank`) OVER(PARTITION BY customer_unique_id ORDER BY `year` DESC,`month` DESC,`date` DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_rank
        FROM ranked)
SELECT customer_unique_id,
CONCAT(DATEDIFF(CURRENT_DATE, DATE(order_purchase_timestamp)),' days ago') AS last_purchase,
total_orders,
order_id,
last_order_value
FROM max_ranked
WHERE `rank` = last_rank
ORDER BY total_orders DESC;
-- here last purchase is from current date


-- Now doing cohort retention
with first_purchase AS (SELECT t2.customer_unique_id,
		MIN(order_purchase_timestamp) AS first_purchase_date
		FROM order_dataset t1
		JOIN customers_dataset t2
			ON t1.customer_id = t2.customer_id
		GROUP BY customer_unique_id)
, month_diff AS (SELECT t1.customer_unique_id,
		t1.first_purchase_date,
		DATE_FORMAT(first_purchase_date,'%M %Y') AS 'cohort',
		t3.order_purchase_timestamp,
		DATE_FORMAT(t3.order_purchase_timestamp,'%M %Y') AS purchase_month,
		TIMESTAMPDIFF(MONTH,first_purchase_date,order_purchase_timestamp) AS month_difference
		FROM first_purchase t1
		JOIN customers_dataset t2
			ON t1.customer_unique_id = t2.customer_unique_id
		JOIN order_dataset t3
			ON t2.customer_id = t3.customer_id)
, active_cust AS (SELECT cohort,
		month_difference,
		COUNT(DISTINCT customer_unique_id) AS active_customers
		FROM month_diff 
		GROUP BY cohort,month_difference)
, cohort_size AS (SELECT cohort,
        MAX(CASE 
            WHEN month_difference = 0 
            THEN active_customers 
        END) AS total_customers
    FROM active_cust
    GROUP BY cohort)
SELECT 
    a.cohort,
    a.month_difference,
    a.active_customers,
    c.total_customers,
    ROUND((a.active_customers / c.total_customers) * 100, 2) AS retention_rate
FROM active_cust a
JOIN cohort_size c
    ON a.cohort = c.cohort
ORDER BY a.cohort, a.month_difference;