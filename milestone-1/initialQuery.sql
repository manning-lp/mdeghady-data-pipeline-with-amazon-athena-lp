CREATE TABLE IF NOT EXISTS
  myschema.users AS
SELECT
  1 AS id,
  CURRENT_DATE() AS registration_date
UNION ALL
SELECT
  2 AS id,
  DATE_SUB(CURRENT_DATE(), INTERVAL 1 day) AS registration_date;
CREATE TABLE IF NOT EXISTS
  myschema.transactions AS
SELECT
  1 AS transaction_id,
  1 AS user_id,
  10.99 AS total_cost,
  CURRENT_DATE() AS dt
UNION ALL
SELECT
  2 AS transaction_id,
  2 AS user_id,
  4.99 AS total_cost,
  CURRENT_DATE() AS dt
UNION ALL
SELECT
  3 AS transaction_id,
  2 AS user_id,
  4.99 AS total_cost,
  DATE_SUB(CURRENT_DATE(), INTERVAL 3 day) AS dt
UNION ALL
SELECT
  4 AS transaction_id,
  1 AS user_id,
  4.99 AS total_cost,
  DATE_SUB(CURRENT_DATE(), INTERVAL 3 day) AS dt
UNION ALL
SELECT
  5 AS transaction_id,
  1 AS user_id,
  5.99 AS total_cost,
  DATE_SUB(CURRENT_DATE(), INTERVAL 2 day) AS dt
UNION ALL
SELECT
  6 AS transaction_id,
  1 AS user_id,
  15.99 AS total_cost,
  DATE_SUB(CURRENT_DATE(), INTERVAL 1 day) AS dt
UNION ALL
SELECT
  7 AS transaction_id,
  1 AS user_id,
  55.99 AS total_cost,
  DATE_SUB(CURRENT_DATE(), INTERVAL 4 day) AS dt
;