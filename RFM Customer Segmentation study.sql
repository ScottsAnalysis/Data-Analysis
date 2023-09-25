-- Customer Recency/Ferquency/Monetary (RFM) Segmentation study:


WITH refund_amount_per_transaction_id as
  (SELECT transaction_id, 
  SUM(item_price*return_quantity) as refund_total
FROM TransactionItems as ti
LEFT JOIN ProductReturns as pr
USING (transaction_id, item_id)
WHERE return_status = 'Refund'
/*AND return_date BETWEEN
   (SELECT DATE_SUB(MAX(return_date), INTERVAL 6 MONTH) AS max_return_date_minus_6_month FROM ProductReturns)
    AND
   (SELECT MAX(return_date) as max_recent_return_date FROM ProductReturns)*/
GROUP BY transaction_id
ORDER BY refund_total asc),

 anti_returns as (SELECT *
FROM Transactions as t
WHERE transaction_total>0),

Frequency as (SELECT user_crm_id, COUNT(transaction_id) as purchase_count,
  CASE WHEN COUNT(transaction_id) > 1 THEN 'Frequent'
  ELSE 'Infrequent' END AS frequency_category
FROM anti_returns
GROUP BY user_crm_id
ORDER BY purchase_count desc),

Recency as (SELECT user_crm_id, latest_purchase_date,
 CASE WHEN latest_purchase_date BETWEEN
    (SELECT DATE_SUB(MAX(latest_purchase_date), INTERVAL 6 MONTH) AS max_latestpurchased_minus_6_month FROM Users)
     AND
    (SELECT MAX(latest_purchase_date) as most_recent_date FROM Users) THEN 'Recent'
    ELSE 'Old' END AS recency_category
FROM Users 
  WHERE latest_purchase_date IS NOT NULL
  ORDER BY recency_category asc)

/*-- TOTALS FOR TRANSACTION ID
SELECT date, transaction_id, user_crm_id, transaction_total, refund_total,
FROM refund_amount_per_transaction_id 
LEFT JOIN Transactions
USING(transaction_id)*/

--Revenue after Refund
--Mean 17.012254992755611
--Median 3.99
--Mode 2.99 not including 0.00
SELECT user_crm_id,
ROUND(SUM(transaction_total), 0) as transaction_total,
ROUND(SUM(COALESCE(refund_total,0)), 0) as refund_total,
ROUND(SUM(transaction_total)-SUM(COALESCE(refund_total,0)), 0) as revenue_after_refund,
    CASE WHEN  SUM(transaction_total)-SUM(COALESCE(refund_total,0))< 20 THEN 'Low Revenue Customer'
  ELSE 'High Revenue Customer' END AS revenue_category,
recency_category,
frequency_category
FROM Transactions
  LEFT JOIN refund_amount_per_transaction_id
  USING(transaction_id)
    INNER JOIN Recency 
    USING(user_crm_id)
      INNER JOIN Frequency
      USING(user_crm_id)
WHERE user_crm_id IS NOT NULL
GROUP BY user_crm_id, recency_category, frequency_category
ORDER BY revenue_after_refund asc


--Median row 114818,114819
/*SELECT *
 FROM (SELECT ROW_NUMBER() OVER (ORDER BY rev_after_ref.revenue_after_refund desc) as row_numbering,
  user_crm_id,
  transaction_total, 
  refund_total, 
  revenue_after_refund
FROM rev_after_ref) as a
WHERE row_numbering = 114818
ORDER BY refund_total asc*/

/*--Mode
SELECT COUNT(*) as count_of_instances, rev_after_ref.revenue_after_refund
FROM rev_after_ref  
GROUP BY rev_after_ref.revenue_after_refund
ORDER BY Count(*) desc*/

/*--Mean 
SELECT AVG( rev_after_ref.revenue_after_refund)
FROM rev_after_ref*/
