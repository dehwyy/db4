-- 1.
SELECT 
    o.IdOrder, 
    c.CompanyName, 
    o.OrderDate, 
    o.Status
FROM Orders o
JOIN Customers c ON o.IdCustomer = c.IdCustomer
WHERE c.CompanyName = 'Tinkoff' 
ORDER BY o.OrderDate ASC;

-- 2.
SELECT
    p.IdProduct,
    p.PrName,
    p.PrPrice,
    SUM(i.Quantity) AS TotalQuantity
FROM Products p
JOIN Items i ON p.IdProduct = i.IdProduct
GROUP BY
    p.IdProduct,
    p.PrName,
    p.PrPrice
ORDER BY TotalQuantity DESC 
LIMIT 10;
