DROP DATABASE IF EXISTS `bookstore_db`;
CREATE SCHEMA `bookstore_db` DEFAULT CHARACTER SET utf8;
USE `bookstore_db`;

-- 1. Таблица "genres"
CREATE TABLE `genres` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC)
);

-- 2. Таблица "authors"
CREATE TABLE `authors` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `full_name` VARCHAR(150) NOT NULL,
  `bio` TEXT NULL,
  PRIMARY KEY (`id`)
);

-- 3. Таблица "books"
CREATE TABLE `books` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(255) NOT NULL,
  `isbn` VARCHAR(20) NULL,
  `year` INT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `genre_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `isbn_UNIQUE` (`isbn` ASC),
  INDEX `fk_books_genres_idx` (`genre_id` ASC),
  CONSTRAINT `fk_books_genres`
    FOREIGN KEY (`genre_id`)
    REFERENCES `genres` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

-- 4. Таблица "book_author"
CREATE TABLE `book_author` (
  `book_id` INT NOT NULL,
  `author_id` INT NOT NULL,
  PRIMARY KEY (`book_id`, `author_id`),
  INDEX `fk_book_author_authors_idx` (`author_id` ASC),
  CONSTRAINT `fk_book_author_books`
    FOREIGN KEY (`book_id`)
    REFERENCES `books` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_book_author_authors`
    FOREIGN KEY (`author_id`)
    REFERENCES `authors` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- 5. Таблица "suppliers"
CREATE TABLE `suppliers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `phone` VARCHAR(20) NULL,
  `address` TEXT NULL,
  PRIMARY KEY (`id`)
);

-- 6. Таблица "supplies"
CREATE TABLE `supplies` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `supplier_id` INT NOT NULL,
  `supply_date` DATE NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_supplies_suppliers_idx` (`supplier_id` ASC),
  CONSTRAINT `fk_supplies_suppliers`
    FOREIGN KEY (`supplier_id`)
    REFERENCES `suppliers` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

-- 7. Таблица "supply_items"
CREATE TABLE `supply_items` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `supply_id` INT NOT NULL,
  `book_id` INT NOT NULL,
  `quantity` INT NOT NULL,
  `purchase_price` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_supply_items_supplies_idx` (`supply_id` ASC),
  INDEX `fk_supply_items_books_idx` (`book_id` ASC),
  CONSTRAINT `fk_supply_items_supplies`
    FOREIGN KEY (`supply_id`)
    REFERENCES `supplies` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_supply_items_books`
    FOREIGN KEY (`book_id`)
    REFERENCES `books` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

-- 8. Таблица "stock"
CREATE TABLE `stock` (
  `book_id` INT NOT NULL,
  `quantity` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`book_id`),
  CONSTRAINT `fk_stock_books`
    FOREIGN KEY (`book_id`)
    REFERENCES `books` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- 9. Таблица "customers"
CREATE TABLE `customers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `full_name` VARCHAR(150) NOT NULL,
  `phone` VARCHAR(20) NULL,
  `email` VARCHAR(100) NULL,
  `reg_date` DATE DEFAULT (CURRENT_DATE),
  PRIMARY KEY (`id`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC)
);

-- 10. Таблица "orders"
CREATE TABLE `orders` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `customer_id` INT NOT NULL,
  `order_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `total_amount` DECIMAL(10,2) NOT NULL,
  `status` VARCHAR(20) DEFAULT 'new',
  PRIMARY KEY (`id`),
  INDEX `fk_orders_customers_idx` (`customer_id` ASC),
  CONSTRAINT `fk_orders_customers`
    FOREIGN KEY (`customer_id`)
    REFERENCES `customers` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

-- 11. Таблица "order_items"
CREATE TABLE `order_items` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `order_id` INT NOT NULL,
  `book_id` INT NOT NULL,
  `quantity` INT NOT NULL,
  `price_at_sale` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_order_items_orders_idx` (`order_id` ASC),
  INDEX `fk_order_items_books_idx` (`book_id` ASC),
  CONSTRAINT `fk_order_items_orders`
    FOREIGN KEY (`order_id`)
    REFERENCES `orders` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_order_items_books`
    FOREIGN KEY (`book_id`)
    REFERENCES `books` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

CREATE TABLE `tmp` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(255) NOT NULL,
  `author` VARCHAR(150) NOT NULL,
  `genre` VARCHAR(100) NOT NULL,
  `year` INT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id`)
);
INSERT INTO tmp (title, author, genre, year, price) VALUES
('1984', 'Джордж Оруэлл', 'Фантастика', 1949, 350.00),
('Убийство в Восточном экспрессе', 'Агата Кристи', 'Детектив', 1934, 420.00),
('Преступление и наказание', 'Ф. Достоевский', 'Роман', 1866, 500.00),
('Мастер и Маргарита', 'М. Булгаков', 'Роман', 1967, 450.00),
('Гарри Поттер и философский камень', 'Дж. Роулинг', 'Фэнтези', 1997, 600.00);
INSERT INTO genres (name)
SELECT DISTINCT genre FROM tmp;

INSERT INTO authors (full_name)
SELECT DISTINCT author FROM tmp;
INSERT INTO books (title, year, price, genre_id)
SELECT t.title, t.year, t.price, g.id
FROM tmp t
JOIN genres g ON t.genre = g.name;

-- Шаг 6. Перенос связей книга-автор
INSERT INTO book_author (book_id, author_id)
SELECT b.id, a.id
FROM tmp t
JOIN books b ON t.title = b.title
JOIN authors a ON t.author = a.full_name;
INSERT INTO suppliers (name, phone, address) VALUES
('АСТ', '8-800-555-35-35', 'г. Москва, ул. Правды, д. 24');

INSERT INTO supplies (supplier_id, supply_date) VALUES (1, '2025-02-01');

INSERT INTO supply_items (supply_id, book_id, quantity, purchase_price) VALUES
(1, 1, 50, 250.00),
(1, 2, 30, 300.00);

INSERT INTO customers (full_name, phone, email) VALUES
('Иван Петров', '+71234567890', 'ivan@mail.ru');

INSERT INTO orders (customer_id, total_amount, status) VALUES (1, 770.00, 'paid');

INSERT INTO order_items (order_id, book_id, quantity, price_at_sale) VALUES
(1, 1, 1, 350.00),
(1, 2, 1, 420.00);