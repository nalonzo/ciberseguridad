UPDATE mysql.user SET authentication_string=PASSWORD('password') WHERE User='root';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;
DROP DATABASE IF EXISTS test;
CREATE DATABASE vulnerable_db;
USE vulnerable_db;
CREATE TABLE users (id INT, username VARCHAR(255), password VARCHAR(255));
INSERT INTO users VALUES (1, 'admin', 'admin123');
FLUSH PRIVILEGES;
