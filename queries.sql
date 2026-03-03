-- 2. Создать любое простое представление и запросить с помощью него данные.
CREATE VIEW v_customers AS 
SELECT FirstName, LastName, City FROM Customers;

SELECT * FROM v_customers;

-- 3. Проверить соответствие данных прямым запросом
SELECT FirstName, LastName, City FROM Customers;

-- 4. Изменить представление с помощью ALTER VIEW, добавив псевдонимы (меняем имя колонки)
ALTER VIEW v_customers RENAME COLUMN FirstName TO "Имя Клиента";

-- 5. Изменить запрос с помощью CREATE OR REPLACE VIEW, добавив условие
CREATE OR REPLACE VIEW v_customers AS 
SELECT 
    FirstName AS "Имя Клиента", 
    LastName, 
    City 
FROM Customers 
WHERE City = 'Москва';

-- 6.-1
DROP VIEW v_customers;
CREATE VIEW v_customers AS
SELECT
    FirstName AS "Имя",
    LastName AS "Фамилия",
    City AS "Город"
FROM Customers
WHERE City = 'Москва';

-- 6. Вставить данные с помощью представления
INSERT INTO v_customers ("Имя", "Фамилия", "Город") 
VALUES ('Виктор', 'Цой', 'Москва');

-- 7. Создать представление с опцией WITH CHECK OPTION
CREATE VIEW v_customers_kazan AS 
SELECT FirstName, LastName, City FROM Customers 
WHERE City = 'Казань' WITH CHECK OPTION;

-- OK
INSERT INTO v_customers_kazan (FirstName, LastName, City) VALUES ('Тимур', 'Гареев', 'Казань');
-- ERR
-- INSERT INTO v_customers_kazan (FirstName, LastName, City) VALUES ('Олег', 'Тиньков', 'Москва'); 

-- 8. Удалить представление
DROP VIEW v_customers_kazan;

-- 9. Создать представление на выборку из двух таблиц
CREATE VIEW v_customer_orders AS
SELECT c.FirstName, c.LastName, o.OrderDate, o.TotalAmount
FROM Customers c
JOIN Orders o ON c.IdCustomer = o.IdCustomer;

-- 10. Роль Test_creator без права входа, но с правом создания БД и ролей
CREATE ROLE "Test_creator" NOLOGIN CREATEDB CREATEROLE;

-- 11. 
CREATE USER user1 LOGIN NOCREATEDB PASSWORD 'password123';

-- 12. 
GRANT "Test_creator" TO user1;

-- 13. Создать БД под пользователем user1 
-- CREATE DATABASE db_for_user1;

-- 14. Создать роли без права создания таблицы и с правом создания таблицы
CREATE ROLE role_no_create_tab NOLOGIN;
CREATE ROLE role_can_create_tab NOLOGIN;
-- Выдаем право создания таблиц в стандартной схеме public:
GRANT CREATE ON SCHEMA public TO role_can_create_tab;

-- 15. 
GRANT ALL PRIVILEGES ON TABLE Customers TO role_can_create_tab;

-- 16.
REVOKE INSERT ON TABLE Customers FROM role_can_create_tab;
