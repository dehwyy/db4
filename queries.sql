CREATE OR REPLACE PROCEDURE update_product_price(p_id INT, new_price NUMERIC)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Products SET Price = new_price WHERE IdProduct = p_id;
END;
$$;
-- CALL update_product_price(2, 1600.00);

-- 2b.
CREATE OR REPLACE PROCEDURE insert_customer(p_name VARCHAR, p_city VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Customers (FirstName, LastName, City) VALUES (p_name, 'Неизвестно', p_city);
END;
$$;
-- CALL insert_customer('ООО Вектор', 'Москва');

-- 2c. Поиск среднего
CREATE OR REPLACE FUNCTION mean_value(value1 real DEFAULT 0, value2 real DEFAULT 0, value3 real DEFAULT 0)
RETURNS real LANGUAGE sql AS $$
    SELECT (value1 + value2 + value3) / 3::real;
$$;
-- SELECT mean_value(10, 20, 30);

-- 2d.
CREATE OR REPLACE FUNCTION search_customer_by_name(c_name VARCHAR)
RETURNS TABLE(Id INT, Name VARCHAR, City VARCHAR) LANGUAGE sql AS $$
    SELECT IdCustomer, FirstName, City FROM Customers WHERE FirstName ILIKE '%' || c_name || '%';
$$;
-- SELECT * FROM search_customer_by_name('Иван');

-- 2e. Функция поиска товаров по диапазону цен
CREATE OR REPLACE FUNCTION search_products_by_price(min_p NUMERIC, max_p NUMERIC)
RETURNS TABLE(Id INT, Product VARCHAR, Price NUMERIC) LANGUAGE sql AS $$
    SELECT IdProduct, PrName, PrPrice FROM Products WHERE PrPrice BETWEEN min_p AND max_p;
$$;
-- SELECT * FROM search_products_by_price(1000, 15000);

-- 2f. Функция поиска заказов по диапазону дат
CREATE OR REPLACE FUNCTION search_orders_by_date(start_date DATE, end_date DATE)
RETURNS TABLE(OrderId INT, OrderDate DATE, Total NUMERIC) LANGUAGE sql AS $$
    SELECT IdOrder, OrderDate, TotalAmount FROM Orders WHERE OrderDate BETWEEN start_date AND end_date;
$$;
-- SELECT * FROM search_orders_by_date('2023-10-01', '2023-10-15');

-- 2g. ВАРИАНТ 15: Задание 1. Информация о покупателях без заказов
CREATE OR REPLACE FUNCTION get_customers_no_orders()
RETURNS TABLE(IdCustomer INT, FirstName VARCHAR, LastName VARCHAR, City VARCHAR) LANGUAGE sql AS $$
    SELECT c.IdCustomer, c.FirstName, c.LastName, c.City
    FROM Customers c
    LEFT JOIN Orders o ON c.IdCustomer = o.IdCustomer
    WHERE o.IdOrder IS NULL;
$$;
-- SELECT * FROM get_customers_no_orders();

-- 2g. ВАРИАНТ 15: Задание 2. Топ 5 товаров города
CREATE OR REPLACE FUNCTION get_top5_products_by_city(p_city VARCHAR)
RETURNS TABLE(PrName VARCHAR, TotalSold BIGINT) LANGUAGE sql AS $$
    SELECT p.PrName, SUM(i.Quantity) AS TotalSold
    FROM Products p
    JOIN Items i ON p.IdProduct = i.IdProduct
    JOIN Orders o ON i.IdOrder = o.IdOrder
    JOIN Customers c ON o.IdCustomer = c.IdCustomer
    WHERE c.City = p_city
    GROUP BY p.PrName
    ORDER BY TotalSold DESC
    LIMIT 5;
$$;
-- SELECT * FROM get_top5_products_by_city('Москва');

-- Логирование добавления клиента
CREATE OR REPLACE FUNCTION trg_after_insert_customer() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    RAISE NOTICE 'Добавлен новый клиент: %', NEW.FirstName;
    RETURN NEW;
END;
$$;
CREATE OR REPLACE TRIGGER trg_insert AFTER INSERT ON Customers
FOR EACH ROW EXECUTE FUNCTION trg_after_insert_customer();


-- Запрет удаления клиента, если город Москва
CREATE OR REPLACE FUNCTION trg_before_delete_customer() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF OLD.City = 'Москва' THEN
        RAISE EXCEPTION 'Нельзя удалять клиентов из Москвы!';
    END IF;
    RETURN OLD;
END;
$$;
CREATE OR REPLACE TRIGGER trg_delete BEFORE DELETE ON Customers
FOR EACH ROW EXECUTE FUNCTION trg_before_delete_customer();


-- Контроль изменения цены (нельзя уменьшить)
CREATE OR REPLACE FUNCTION trg_before_update_product() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.Price < OLD.Price THEN
        RAISE EXCEPTION 'Цена товара не может быть уменьшена!';
    END IF;
    RETURN NEW;
END;
$$;
CREATE OR REPLACE TRIGGER trg_update BEFORE UPDATE ON Products
FOR EACH ROW EXECUTE FUNCTION trg_before_update_product();


-- Функция и Триггер 6: Каскадное удаление из Items при удалении из Products
CREATE OR REPLACE FUNCTION trg_cascade_delete_product() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Items WHERE IdProduct = OLD.IdProduct;
    RETURN OLD;
END;
$$;
CREATE OR REPLACE TRIGGER trg_cascade_del_prod BEFORE DELETE ON Products
FOR EACH ROW EXECUTE FUNCTION trg_cascade_delete_product();


-- Функция и Триггер 7 (с таблицей NEW): Авто-расчет поля Total при вставке в Items
CREATE OR REPLACE FUNCTION trg_calculate_item_total() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.Total := NEW.Quantity * (SELECT Price FROM Products WHERE IdProduct = NEW.IdProduct);
    RETURN NEW;
END;
$$;
CREATE OR REPLACE TRIGGER trg_new_item BEFORE INSERT ON Items
FOR EACH ROW EXECUTE FUNCTION trg_calculate_item_total();


-- Триггер 8: Предотвращение DROP TABLE / ALTER TABLE
CREATE OR REPLACE FUNCTION prevent_table_modification() RETURNS event_trigger LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'Изменение и удаление таблиц в базе запрещено политикой безопасности!';
END;
$$;

--CREATE EVENT TRIGGER no_drop_table
--ON ddl_command_start
--WHEN TAG IN ('DROP TABLE', 'ALTER TABLE')
--EXECUTE FUNCTION prevent_table_modification();

-- DROP EVENT TRIGGER no_drop_table;
