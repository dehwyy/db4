-- Cписок всех заказов по порядку для каждого клиента в зависимости от даты заказа.
SELECT
    IdCustomer,
    IdOrder,
    OrderDate,
    TotalAmount,
    ROW_NUMBER() OVER(PARTITION BY IdCustomer ORDER BY OrderDate) AS order_seq_num
FROM Orders
ORDER BY IdCustomer, OrderDate;

-- Сколько потратил каждый клиент во всех заказах по порядку.
SELECT
    IdCustomer,
    IdOrder,
    OrderDate,
    TotalAmount,
    SUM(TotalAmount) OVER(PARTITION BY IdCustomer ORDER BY OrderDate) AS total_spent_so_far
FROM Orders
ORDER BY IdCustomer, OrderDate;

-- Сравнение конкретного заказа со средним чеком клиента
SELECT
    IdCustomer,
    IdOrder,
    TotalAmount,
    ROUND(AVG(TotalAmount) OVER(PARTITION BY IdCustomer), 2) AS customer_avg_check,
    TotalAmount - ROUND(AVG(TotalAmount) OVER(PARTITION BY IdCustomer), 2) AS diff_from_avg
FROM Orders
ORDER BY IdCustomer;

-- Сколько дней прошло с момента предыдущего заказа
SELECT
    IdCustomer,
    IdOrder,
    OrderDate,
    LAG(OrderDate) OVER(PARTITION BY IdCustomer ORDER BY OrderDate) AS prev_order_date,
    OrderDate - LAG(OrderDate) OVER(PARTITION BY IdCustomer ORDER BY OrderDate) AS days_since_last_order
FROM Orders
ORDER BY IdCustomer, OrderDate;
