CREATE DATABASE librarydata_db;
USE librarydata_db;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100) NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0)
) ENGINE = InnoDB;

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    issue_date DATE NOT NULL,
    return_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'Issued',

    CONSTRAINT chk_transaction_status
        CHECK (status IN ('Issued', 'Returned')),

    CONSTRAINT chk_return_date
        CHECK (
            (status = 'Issued' AND return_date IS NULL)
            OR
            (status = 'Returned' AND return_date IS NOT NULL)
        ),

    FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    FOREIGN KEY (book_id)
        REFERENCES books(book_id)
) ENGINE = InnoDB;

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

DELIMITER //

CREATE PROCEDURE issue_book(
    IN p_user_id INT,
    IN p_book_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    UPDATE books
    SET quantity = quantity - 1
    WHERE book_id = p_book_id
      AND quantity > 0;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Book not found or no copies available';
    END IF;

    INSERT INTO transactions
        (user_id, book_id, issue_date, status)
    VALUES
        (p_user_id, p_book_id, CURDATE(), 'Issued');

    COMMIT;
END //

CREATE PROCEDURE return_book(
    IN p_transaction_id INT
)
BEGIN
    DECLARE v_book_id INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_book_id = NULL;

    START TRANSACTION;

    SELECT book_id
    INTO v_book_id
    FROM transactions
    WHERE transaction_id = p_transaction_id
      AND status = 'Issued'
    FOR UPDATE;

    IF v_book_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Invalid transaction or book already returned';
    END IF;

    UPDATE transactions
    SET return_date = CURDATE(),
        status = 'Returned'
    WHERE transaction_id = p_transaction_id
      AND status = 'Issued';

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Return could not be completed';
    END IF;

    UPDATE books
    SET quantity = quantity + 1
    WHERE book_id = v_book_id;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Book not found';
    END IF;

    COMMIT;
END //

DELIMITER ;

SELECT * FROM users;

SELECT * FROM books;

SELECT title, quantity
FROM books
WHERE book_id = 2;

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
    t.transaction_id,
    u.name,
    b.title,
    t.issue_date,
    t.return_date,
    t.status
FROM transactions t
JOIN users u
    ON t.user_id = u.user_id
JOIN books b
    ON t.book_id = b.book_id;

SELECT
    u.name,
    b.title,
    t.issue_date,
    t.status
FROM transactions t
JOIN users u
    ON t.user_id = u.user_id
JOIN books b
    ON t.book_id = b.book_id
WHERE t.status = 'Issued';

UPDATE users
SET phone = '9999999999'
WHERE user_id = 1;

SELECT * FROM users;
SELECT * FROM books;
SELECT * FROM transactions;
