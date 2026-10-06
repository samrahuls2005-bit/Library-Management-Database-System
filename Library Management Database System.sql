CREATE DATABASE librarydata_db;
USE librarydata_db;
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL
);

CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100) NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0)
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    issue_date DATE NOT NULL,
    return_date DATE,
    status VARCHAR(20) DEFAULT 'Issued',

    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

INSERT INTO users (name, email, phone)
VALUES
('Sam', 'sam@gmail.com', '9876543210'),
('Rahul', 'rahul@gmail.com', '9876543211'),
('David', 'david@gmail.com', '9876543212');

INSERT INTO books (title, author, quantity)
VALUES
('Java Programming', 'James Gosling', 5),
('Python Basics', 'Guido van Rossum', 4),
('Database Management System', 'Korth', 3),
('Web Development', 'Jon Duckett', 6);

SELECT * FROM users;

SELECT * FROM books;

SELECT title, quantity
FROM books
WHERE book_id = 2;

UPDATE books
SET quantity = quantity - 1
WHERE book_id = 2
AND quantity > 0;

INSERT INTO transactions
(user_id, book_id, issue_date, status)
SELECT
1,
2,
CURDATE(),
'Issued'
FROM books
WHERE book_id = 2
AND quantity >= 0;

SELECT * FROM transactions;

UPDATE books
SET quantity = quantity + 1
WHERE book_id = 2
AND EXISTS (
    SELECT 1
    FROM transactions
    WHERE transaction_id = 1
    AND status = 'Issued'
);

UPDATE transactions
SET
    return_date = CURDATE(),
    status = 'Returned'
WHERE transaction_id = 1
AND status = 'Issued';

UPDATE users
SET phone = '9999999999'
WHERE user_id = 1;

SELECT *
FROM books
WHERE title = 'Database Management System';

SELECT
    book_id,
    title,
    author,
    quantity AS available_quantity
FROM books;

SELECT
    transactions.transaction_id,
    users.name,
    books.title,
    transactions.issue_date,
    transactions.return_date,
    transactions.status
FROM transactions
JOIN users
ON transactions.user_id = users.user_id
JOIN books
ON transactions.book_id = books.book_id;

SELECT
    users.name,
    books.title,
    transactions.issue_date,
    transactions.status
FROM transactions
JOIN users
ON transactions.user_id = users.user_id
JOIN books
ON transactions.book_id = books.book_id
WHERE transactions.status = 'Issued';

SELECT * FROM users;
SELECT * FROM books;
SELECT * FROM transactions;
