CREATE DATABASE IF NOT EXISTS vulnerable_db;

USE vulnerable_db;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50),
    password VARCHAR(50),
    email VARCHAR(100),
    credit_card VARCHAR(20),
    is_admin TINYINT(1)
);

INSERT INTO users VALUES
(1, 'admin', 'supersecret', 'admin@example.com', '4111111111111111', 1),
(2, 'alice', 'alice123', 'alice@example.com', '5555555555554444', 0),
(3, 'bob', 'password', 'bob@example.com', '378282246310005', 0);

DELIMITER //
CREATE PROCEDURE vulnerable_proc(IN userid INT)
BEGIN
    SET @sql = CONCAT('SELECT * FROM users WHERE id = ', userid);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

GRANT ALL PRIVILEGES ON *.* TO 'victim_user'@'%' IDENTIFIED BY 'weakpassword';
FLUSH PRIVILEGES;
