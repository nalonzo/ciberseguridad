ALTER USER postgres WITH PASSWORD 'postgres';
CREATE DATABASE vulnerable_db;
\c vulnerable_db
CREATE TABLE users (id INT, username VARCHAR(255), password VARCHAR(255));
INSERT INTO users VALUES (1, 'admin', 'admin123');
