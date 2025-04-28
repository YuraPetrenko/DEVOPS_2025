#!/bin/bash
sudo apt update
sudo apt install -y mysql-server

echo "mysql-server встановлено"

# Змінні для налаштування
DB_NAME="SchoolDB"
DB_USER="bald2003"
user_host="192.168.%.%"
DB_PASSWORD="rwzL7515Z"

# Створення бази даних
sudo mysql <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
EOF
echo "Створено базу даних $DB_NAME"
# Створення користувача та надання йому прав
sudo mysql <<EOF
CREATE USER '$DB_USER'@'$user_host' IDENTIFIED BY '$DB_PASSWORD';
GRANT SELECT, INSERT, UPDATE, CREATE TEMPORARY TABLES ON $DB_NAME.* TO '$DB_USER'@'$user_host';
FLUSH PRIVILEGES;
EOF
echo "Створено користувача $DB_USER"
# Підключення до бази даних
sudo mysql $DB_NAME <<EOF

# Створення таблиці "Institutions"
CREATE TABLE IF NOT EXISTS Institutions (
    institution_id INT AUTO_INCREMENT PRIMARY KEY,
    institution_name VARCHAR(255),
    institution_type VARCHAR(255),
    address VARCHAR(255)

);

# Внесення даних до таблиці "Institutions"
  INSERT INTO Institutions (institution_name, institution_type, address) VALUES
    ('Школа №175', 'School', 'Harkiv'),
    ('Садочок №37', 'Kindergarten', 'Kiev'),
    ('Школа №102', 'School', 'Lviv');


# Створення таблиці "Classes"
CREATE TABLE IF NOT EXISTS Classes (
    class_id INT AUTO_INCREMENT PRIMARY KEY,
    class_name VARCHAR(255),
    institution_id INT,
    FOREIGN KEY (institution_id) REFERENCES Institutions(institution_id),
    Institutions_direction VARCHAR(255)

);

# Внесення даних до таблиці "Classes"
  INSERT INTO Classes (class_name,institution_id,Institutions_direction) VALUES
    ('Середній',1,'Biology and Chemistry'),
    ('Початковий',2,'Biology and Chemistry'),
    ('Магістратура',3,'Mathematics');

# Створення таблиці "Children"
CREATE TABLE IF NOT EXISTS Children (
    child_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    birth_date DATE,
    year_of_entry INT,
    age INT,
    institution_id INT,
    FOREIGN KEY (institution_id) REFERENCES Institutions(institution_id),
    class_id INT,
    FOREIGN KEY (class_id) REFERENCES Classes(class_id)
);

# Внесення даних до таблиці "Children"
  INSERT INTO Children (first_name, last_name, birth_date, year_of_entry, age, institution_id, class_id) VALUES
    ('Іван','Усенко','2005-11-13',2020,19,1,1),
    ('Сева','Руденко','2009-10-12',2019,15,2,2),
    ('Василь','Потапенко','2005-08-22',2020,19,3,3);

# Створення таблиці "Parents"
CREATE TABLE IF NOT EXISTS Parents (
    parent_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    child_id INT,
    FOREIGN KEY (child_id) REFERENCES Children(child_id),
    tuition_fee INT
);

# Внесення даних до таблиці "Parents"
  INSERT INTO Parents (first_name, last_name, child_id, tuition_fee) VALUES
    ('Ірина', 'Усенко', '1', '1000'),
    ('Федір', 'Руденко', '2', '500'),
    ('Анна', 'Потапенко', '3', '1500');

EOF