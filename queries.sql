-- a
SELECT * FROM Items;

-- b, c, d Specified fields && ORDER && LIMIT
SELECT LastName, FirstName, City FROM Customers ORDER BY LastName DESC LIMIT 5;

-- f, h. Between && Like
SELECT * FROM Customers WHERE IdCustomer BETWEEN 1 AND 10 AND Email LIKE '%.ru';

-- g. SubQuery
SELECT * FROM Customers WHERE IdCustomer IN (SELECT IdCustomer FROM Customers WHERE Bonuscard is True)

-- i. IS NULL
SELECT * FROM Orders WHERE ShipDate IS NULL;

-- j, k. Агрегация и HAVING
SELECT City, COUNT(*) as client_count 
FROM Customers 
GROUP BY City 
HAVING COUNT(*) > 2;

-- l. JOIN
SELECT c.LastName, o.OrderDate, o.Status 
FROM Customers as c
JOIN Orders as o ON c.IdCustomer = o.IdCustomer;

-- o. CASE
SELECT IdOrder, 
       CASE WHEN Status = 'P' THEN 'Processed'
            WHEN Status = 'A' THEN 'Active'
            WHEN Status = 'C' THEN 'Cancelled'
            ELSE 'Unknown' END as Status_Text
FROM Orders;
