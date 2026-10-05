
CREATE DATABASE librarydata_db;

USE librarydata_db;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    email VARCHAR(100),
    phone INT
);

CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100),
    author VARCHAR(100),
    quantity INT
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    book_id INT,
    issue_date DATE,
    return_date DATE,

    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

INSERT INTO users (name, email, phone)
VALUES
('sam', 'sam@gmail.com', '9876543210'),
('rahul', 'rahul@gmail.com', '9876543211'),
('David', 'david@gmail.com', '9876543212');

INSERT INTO books (title, author, quantity)
VALUES
('Java Programming', 'James Gosling', 5),
('Python Basics', 'Guido van Rossum', 4),
('Database Management System', 'Korth', 3),
('Web Development', 'Jon Duckett', 6);

SELECT * FROM users;

SELECT * FROM books;

INSERT INTO transactions (user_id, book_id, issue_date)
VALUES (1, 2, CURDATE());

SELECT * FROM transactions;

UPDATE transactions
SET return_date = CURDATE()
WHERE transaction_id = 1;

UPDATE books
SET quantity = 5
WHERE book_id = 2;

UPDATE users
SET phone = '9999999999'
WHERE user_id = 1;

SELECT * FROM books
WHERE title = 'Database Management System';

SELECT title, author, quantity
FROM books;

SELECT
    transactions.transaction_id,
    users.name,
    books.title,
    transactions.issue_date,
    transactions.return_date
FROM transactions
JOIN users
ON transactions.user_id = users.user_id
JOIN books
ON transactions.book_id = books.book_id;

SELECT * FROM users;
SELECT * FROM books;
SELECT * FROM transactions;