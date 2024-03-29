-- Calculating results of A/B test (including profits, total txns, etc):


-- Selecting Original A/B test customers (Prism+ and Control customers from 2022-01-01)
WITH transactions AS 
(
  SELECT a.*, opt_in_status, b.prism_plus_status, b.prism_plus_tier
  FROM Transactions AS a
    LEFT JOIN Users AS b
    USING(user_crm_id)
  WHERE user_crm_id IS NOT NULL 
),

  -- List of crm users elligeable for Loyalty Prog or Control division on 2022-01-01:
elligeable_crms AS
(
  SELECT user_crm_id
  FROM transactions 
  WHERE date < '2022-01-01' AND opt_in_status IS TRUE
),

-- Gross Profit per Product (item_id) Ignoring shipping costs
-- Revenue = [Item_price * Item Quantity] - Tiziano
revenue_per_item_id AS 
(
  SELECT
  ti.date,
  ti.transaction_id,
  ti.item_id,
  ti.item_price,
  ti.item_quantity,
  CASE WHEN rev_after_disc IS NOT NULL THEN rev_after_disc
  ELSE ti.item_price * ti.item_quantity
  END AS Item_Revenue
FROM TransactionsItems AS ti
LEFT JOIN Revenue_After_Discount as rev_dis
USING(item_id, transaction_id)
ORDER BY ti.date DESC
),

-- Refunds = [Item_price * Refund_Quantity] - Meghaa
refund_per_item_id AS 
(
  SELECT 
  date,
  t.item_id,
  t.transaction_id,
  t.item_price * r.return_quantity AS Refunds,
  return_quantity
FROM TransactionsItems t 
LEFT JOIN Returns r
USING (item_id, transaction_id)
WHERE return_status = 'Refund' 
ORDER BY date DESC
),

-- Cost of Goods = [Item_Cost * Item Quantity] - Ben
cogs_per_item_id AS 
(
  SELECT
  ti.date,
  ti.transaction_id,
  ti.item_id,
  ti.item_quantity,
  pr.return_quantity,
  pc.cost_of_item,
  (cost_of_item * (ti.Item_Quantity - COALESCE(pr.return_quantity, 0)) + Distribution_per_item_id) AS Cost_of_Goods
FROM TransactionsItems AS ti
LEFT JOIN ProductCosts AS pc
ON pc.item_id = ti.item_id
LEFT JOIN ProductReturns as pr
ON pr.item_id = ti.item_id and pr.transaction_id = ti.transaction_id
LEFT JOIN Distrib_Shipping_Costs AS dist_per_id
ON ti.transaction_id = dist_per_id.transaction_id AND ti.item_id = dist_per_id.item_id
),

-- Gross Profit = Revenue - Refunds - Cost of Goods
profit_table AS 
(
SELECT
  revenue_per_item_id.date,
  revenue_per_item_id.transaction_id, 
  revenue_per_item_id.item_id,
  revenue_per_item_id.item_price,
  revenue_per_item_id.item_quantity,
  revenue_per_item_id.Item_Revenue,
  refund_per_item_id.Refunds,
  refund_per_item_id.return_quantity,
  cogs_per_item_id.Cost_of_Goods,
  revenue_per_item_id.Item_Revenue - COALESCE(refund_per_item_id.Refunds, 0) - COALESCE(cogs_per_item_id.Cost_of_Goods, 0) AS Gross_Profit,
  ((revenue_per_item_id.Item_Revenue - COALESCE(refund_per_item_id.Refunds, 0) - COALESCE(cogs_per_item_id.Cost_of_Goods, 0)) / Item_Revenue) AS product_profit_margin
FROM revenue_per_item_id
LEFT JOIN refund_per_item_id
USING(item_id, transaction_id, date)
LEFT JOIN cogs_per_item_id
USING(item_id, transaction_id, date)
ORDER BY date DESC
),

all_txns_prism_profits AS 
(
  SELECT a.*, Gross_Profit, product_profit_margin
  FROM transactions AS a
    LEFT JOIN profit_table AS b
    USING(transaction_id)
  WHERE user_crm_id IS NOT NULL
  ORDER BY 1
),
 
-- Calculate total txns and profit generated by Loyalty Prog. tiers and Control group:
test_result AS
(
  SELECT DATE_TRUNC(date, MONTH) AS date_month, 
          CASE WHEN prism_plus_status IS TRUE THEN 'Prism Plus' WHEN prism_plus_status IS FALSE THEN 'Control crm' END as prism_plus_status, 
          CASE WHEN prism_plus_tier IS NULL THEN 'Control crm' ELSE prism_plus_tier END AS prism_plus_tier, 
          COUNT(DISTINCT transaction_id) AS total_txns, ROUND(SUM(Gross_Profit), 2) AS total_gross_profit, 
          ROUND(SUM(Gross_Profit) / COUNT(DISTINCT transaction_id), 2) AS total_gross_profit_per_txn
  FROM all_txns_prism_profits
  WHERE user_crm_id IN (SELECT * FROM elligeable_crms)
  GROUP BY date_month, prism_plus_status, prism_plus_tier
  ORDER BY 1
)

SELECT EXTRACT(YEAR FROM date_month) AS date_year, prism_plus_status, prism_plus_tier, SUM(total_txns) AS total_yearly_txns, ROUND(SUM(total_gross_profit), 2) AS total_yearly_profit, ROUND(AVG(total_gross_profit_per_txn), 2) AS avg_profit_per_txn, ROUND(SUM(total_gross_profit)/SUM(total_txns), 2) AS tot_calculated_profit_per_txn
FROM test_result
GROUP BY date_year, prism_plus_status, prism_plus_tier
