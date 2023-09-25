
-- Gross Profit & Profit Margin Calculations


WITH revenue_per_item_id AS (
  SELECT
    ti.date,
    ti.transaction_id,
    ti.item_id,
    ti.item_price,
    ti.item_quantity
  FROM Transactions AS ti
),
refund_per_item_id AS (
  SELECT
    date,
    t.item_id,
    t.transaction_id,
    t.item_price,
    r.return_quantity
  FROM TransactionsItems t
  LEFT JOIN ProductReturns r
  USING (item_id, transaction_id)
  WHERE return_status = 'Refund'
),
cogs_per_item_id AS (
  SELECT
    ti.date,
    ti.transaction_id,
    ti.item_id,
    ti.item_quantity,
    pr.return_quantity,
    pc.cost_of_item
  FROM TransactionsItems AS ti
  LEFT JOIN ProductCost AS pc
  ON pc.item_id = ti.item_id
  LEFT JOIN ProductReturn AS pr
  ON pr.item_id = ti.item_id AND pr.transaction_id = ti.transaction_id
),

net_items_sold_cte AS (
  SELECT
    revenue_per_item_id.date AS date,
    revenue_per_item_id.transaction_id AS transaction_id,
    revenue_per_item_id.item_id AS item_id,
    revenue_per_item_id.item_price AS item_price,
    cogs_per_item_id.cost_of_item AS item_cost,
    revenue_per_item_id.item_quantity AS item_qty,
    refund_per_item_id.return_quantity AS rtn_qty,
    CASE
      WHEN refund_per_item_id.return_quantity IS NOT NULL
      THEN revenue_per_item_id.item_quantity - refund_per_item_id.return_quantity
      ELSE revenue_per_item_id.item_quantity
    END AS net_items_sold
  FROM revenue_per_item_id
  LEFT JOIN refund_per_item_id
  USING (item_id, transaction_id, date)
  LEFT JOIN cogs_per_item_id
  USING (item_id, transaction_id, date)
),

basket_item_count AS (
  SELECT
    transaction_id,
    SUM(item_quantity) AS item_quantity_in_basket
  FROM TransactionsItems
  GROUP BY transaction_id
),

return_basket_item_count AS (
  SELECT
    return_date,
    transaction_id,
    SUM(return_quantity) AS refund_quantity_basket
  FROM ProductReturns
  WHERE return_status = 'Refund'
  GROUP BY transaction_id, return_date
),

refund_cte2 AS (
  SELECT *
  FROM ProductReturns
  WHERE return_status = 'Refund'
),

prof_margin as(
  SELECT
    net.date AS purchase_date,
    pr.return_date,
    DATE_DIFF(pr.return_date, net.date, DAY) AS return_window,
    net.transaction_id,
    net.item_id,
    pa.item_brand,
    pa.item_name,
    pa.item_main_category,
    pa.item_sub_category,
    pa.item_gender,
    net.item_price,
    net.item_cost,
    net.item_qty,
    net.rtn_qty,
    net.net_items_sold,
    net.item_price * net.net_items_sold AS net_item_rev,
    net.item_cost * net.net_items_sold AS net_item_cost,
    (transaction_shipping / item_quantity_in_basket) * net.item_qty AS customer_shipping,
    (((1 - COALESCE(cd.perc_discount, 0)) * net.item_price) * net.net_items_sold)+((transaction_shipping / item_quantity_in_basket) * net.item_qty) AS revenue,
    
    ((net.item_price * net.net_items_sold) - (net.item_cost * net.net_items_sold)) AS gross_profit_pre_coupon,
    
    (((1 - COALESCE(cd.perc_discount, 0)) * net.item_price) * net.net_items_sold - (net.item_cost * net.net_items_sold)) AS profit_without_shipping,
    bc.item_quantity_in_basket,
    
    5.35 / bc.item_quantity_in_basket AS shipping_average_per_item,
    
    (5.35 / bc.item_quantity_in_basket) * net.item_qty AS purchase_shipping_per_item,
   
     COALESCE((5.35 / ref.refund_quantity_basket) * net.item_qty, 0) AS refund_shipping_per_item,
   
    (((1 - COALESCE(cd.perc_discount, 0)) * net.item_price) * net.net_items_sold - (net.item_cost * net.net_items_sold)) - ((5.35 / bc.item_quantity_in_basket) * net.item_qty) - 
    (COALESCE((5.35 / ref.refund_quantity_basket) * net.item_qty, 0)) + ((transaction_shipping / item_quantity_in_basket) * net.item_qty) AS 
    profit_after_coupon_shipping_refund,
    
    tr.transaction_coupon,
    --tr.user_crm_id,
    tr.user_cookie_id,
    cd.perc_discount
FROM net_items_sold_cte AS net
  LEFT JOIN Transactions AS tr
  USING (transaction_id)
  --LEFT JOIN Users AS users
  --USING (user_crm_id)
  LEFT JOIN CouponDiscountPercent AS cd
  USING (transaction_coupon)
  LEFT JOIN basket_item_count AS bc
  USING (transaction_id)
  LEFT JOIN refund_cte2 AS pr
  USING (transaction_id, item_id)
  LEFT JOIN return_basket_item_count AS ref
  USING (transaction_id)
  LEFT JOIN ProductAttributes as pa
  USING(item_id))


SELECT /*purchase_date,
return_date,
*/
item_id,
item_brand,
item_name,
item_main_category,
item_sub_category,
item_gender,
ROUND(COALESCE(AVG(return_window),0),2) as average_return_window,
SUM(net_items_sold) as item_sold,
ROUND(SUM(net_item_rev),2) as item_rev,
ROUND(SUM(net_item_cost),2) as item_cost,
ROUND(AVG(customer_shipping),2) as customer_shipping,
ROUND(SUM(gross_profit_pre_coupon),2) as revenue_pre_coupon,
ROUND(SUM(profit_without_shipping),2) as profit_without_shipping,
ROUND(SUM(revenue),2) as revenue,
ROUND(SUM(profit_after_coupon_shipping_refund),2) as final_profit,
ROUND(SUM(profit_after_coupon_shipping_refund)/SUM(revenue),2) as profit_margin
FROM prof_margin
GROUP BY item_id,
item_brand,
item_name,
item_main_category,
item_sub_category,
item_gender
HAVING revenue<>0

