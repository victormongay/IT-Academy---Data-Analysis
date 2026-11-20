# Script 2
# Exercici 2:
# Llistat dels països que estan generant vendes.

USE transacitions;
SELECT DISTINCT c.country
FROM transaction t
JOIN company c ON t.company_id = c.id
WHERE t.declined = 0
ORDER BY c.country ASC;

# Des de quants països es generen les vendes.

SELECT COUNT(DISTINCT c.country) AS total_countries 
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0;

# Identifica la companyia amb la mitjana més gran de vendes.

SELECT c.company_name, AVG(amount) AS amount_mean
FROM transaction t
JOIN company c ON t.company_id = c.id
WHERE t.declined = 0
GROUP BY c.company_name
ORDER BY amount_mean DESC
LIMIT 1;



# Exercici 3
# Mostra totes les transaccions realitzades per empreses d'Alemanya.

SELECT *
FROM transaction
WHERE declined = 0
AND company_id IN ( SELECT company.id
						FROM company
                        WHERE country = "Germany" );

# Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

SELECT company_name
FROM company
WHERE id IN (   SELECT company_id
				FROM transaction
				WHERE declined = 0 
                AND amount > (  SELECT AVG(amount)
								FROM transaction
								WHERE declined = 0 ) )
ORDER BY company_name;

# Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

SELECT company_name
FROM company c
WHERE NOT EXISTS (  SELECT 1 
					FROM transaction t
                    WHERE c.id = t.company_id )
ORDER BY company_name; 

# Exercici 4

CREATE TABLE credit_card (
	id VARCHAR(15),
	iban VARCHAR(34),
    pan VARCHAR(22),
    pin VARCHAR(12),
    cvv VARCHAR(4),
    expiring_date VARCHAR(10), 
    PRIMARY KEY (id)
); 

ALTER TABLE transaction
ADD CONSTRAINT fk_credit_id
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

SET SQL_SAFE_UPDATES = 0;

UPDATE credit_card
SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%y');

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE credit_card MODIFY expiring_date DATE;

# Exercici 5

UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

SELECT *
FROM credit_card
WHERE id = 'CcU-2938';

# Exercici 6

INSERT INTO credit_card (id) VALUES ('CcU-9999');
INSERT INTO company (id) VALUES ('b-9999');

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', '111.11', '0'); 

SELECT *
FROM transaction
WHERE company_id = 'b-9999';

# Exercici 7

ALTER TABLE credit_card DROP COLUMN pan;

SELECT *
FROM credit_card;

# Exercici 8

DROP DATABASE eu_us_transactions;
CREATE DATABASE eu_us_transactions;
USE eu_us_transactions;

CREATE TABLE transactions (
    id                VARCHAR(36) PRIMARY KEY,
    card_id           VARCHAR(15),
    business_id       VARCHAR(15),
    timestamp         DATETIME,
    amount            DECIMAL(10, 2),
    declined          BOOLEAN,
    product_ids       VARCHAR(50),
    user_id           INT,
    lat               DOUBLE,
    longitude         DOUBLE,
    discount_amount   DECIMAL(10, 2),
    tax_amount        DECIMAL(10, 2),
    shipping_amount   DECIMAL(10, 2),
    channel           VARCHAR(20),
    campaign_id       VARCHAR(30),
    device_type       VARCHAR(20),
    is_international  BOOLEAN,
    decline_reason    VARCHAR(30),
    distance_km       DECIMAL(10, 2)
);

LOAD DATA LOCAL INFILE 'C:/Users/Victor/Documents/IT ACADEMY/N1-Ex.8__transactions.csv'
INTO TABLE transactions
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, card_id, business_id, timestamp, amount, declined, product_ids, user_id,
 lat, longitude, discount_amount, tax_amount, shipping_amount, channel,
 campaign_id, device_type, is_international, @decline_reason, distance_km)
SET decline_reason = NULLIF(@decline_reason, '');

CREATE TABLE company (
    company_id               VARCHAR(15) PRIMARY KEY,
    company_name             VARCHAR(100),
    phone                    VARCHAR(20),
    email                    VARCHAR(100),
    country                  VARCHAR(50),
    website                  VARCHAR(100),
    merchant_category        VARCHAR(30),
    merchant_price_position  VARCHAR(20)
);

LOAD DATA LOCAL INFILE 'C:/Users/Victor/Documents/IT ACADEMY/N1-Ex.8__companies.csv'
INTO TABLE company
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

CREATE TABLE credit_card (
    id                 VARCHAR(15) PRIMARY KEY,
    user_id            INT,
    iban               VARCHAR(34),
    pan                VARCHAR(19),
    pin                VARCHAR(4),
    cvv                VARCHAR(4),
    track1             VARCHAR(100),
    track2             VARCHAR(100),
    expiring_date      DATE,
    card_type          VARCHAR(20),
    card_renewal_flag  BOOLEAN
);

LOAD DATA LOCAL INFILE 'C:/Users/Victor/Documents/IT ACADEMY/N1-Ex.8__credit_cards.csv'
INTO TABLE credit_card
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, user_id, iban, pan, pin, cvv, track1, track2, @expiring_date, card_type, card_renewal_flag)
SET expiring_date = STR_TO_DATE(@expiring_date, '%m/%d/%y');

CREATE TABLE users (
	id				INT PRIMARY KEY,
    name			VARCHAR(40),
    surname			VARCHAR(50),
    phone			VARCHAR(20),
    email			VARCHAR(100),
    birth_date		DATE,
    country			VARCHAR(50),
    city			VARCHAR(50),
    postal_code		VARCHAR(15),
    address			VARCHAR(100),
    signup_date		DATE,
    user_segment 	VARCHAR(30),
    income_band		VARCHAR(20)
);

LOAD DATA LOCAL INFILE 'C:/Users/Victor/Documents/IT ACADEMY/N1-Ex.8__american_users.csv'
INTO TABLE users
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address, signup_date, user_segment, income_band)
SET birth_date = STR_TO_DATE(@birth_date, '%b %e, %Y');

LOAD DATA LOCAL INFILE 'C:/Users/Victor/Documents/IT ACADEMY/N1-Ex.8__european_users.csv'
INTO TABLE users
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address, signup_date, user_segment, income_band)
SET birth_date = STR_TO_DATE(@birth_date, '%b %e, %Y');

ALTER TABLE transactions
ADD CONSTRAINT fk_card_id
FOREIGN KEY (card_id) REFERENCES credit_card(id);

ALTER TABLE transactions
ADD CONSTRAINT fk_company_id
FOREIGN KEY (business_id) REFERENCES company(company_id);

ALTER TABLE transactions
ADD CONSTRAINT fk_user_id
FOREIGN KEY (user_id) REFERENCES users(id);

# Exercici 9

SELECT name, surname
FROM users
WHERE id IN (   SELECT user_id
				FROM transactions t
                GROUP BY user_id
                HAVING COUNT(*) > 80 );
                
# Exercici 10



SELECT c_c.iban, ROUND(AVG(t.amount), 2) AS amount_mean
FROM company c
JOIN transactions t ON c.company_id = t.business_id
JOIN credit_card c_c ON t.card_id = c_c.id
WHERE c.company_name = "Donec Ltd" AND t.declined = 0
GROUP BY c_c.iban
ORDER BY amount_mean DESC;

# Nivell 2
# Exercici 1

WITH amount_day AS (
	SELECT  DATE(timestamp) AS sale_date, 
			SUM(amount) AS income,
            RANK() OVER (ORDER BY SUM(amount) DESC) AS ranking
	FROM transactions
	WHERE declined = 0
	GROUP BY sale_date 
)
SELECT sale_date, income
FROM amount_day
WHERE ranking <= 5
ORDER BY ranking;

# Exercici 2:

SELECT  c.company_name, c.phone, c.country, 
		DATE(t.timestamp) AS transaction_date,
        t.amount
FROM company c
JOIN transactions t ON c.company_id = t.business_id
WHERE amount BETWEEN 350 AND 400
AND DATE(t.timestamp) IN ('2015-04-29', '2018-07-20', '2024-03-13')
ORDER BY amount DESC;

# Exercici 3:

SELECT  c.company_name, COUNT(*) AS total_transactions,
		CASE 
			WHEN COUNT(*) >= 400 THEN '400 or more'
            ELSE 'Less than 400'
		END AS transaction_category
FROM company c
JOIN transactions t ON c.company_id = t.business_id
GROUP BY c.company_name
ORDER BY total_transactions;

# Exercici 4

DELETE FROM transactions
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

SELECT *
FROM transactions
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

# Exercici 5

CREATE VIEW VistaMarketing AS
SELECT c.company_name, c.phone, c.country,
       ROUND(AVG(t.amount), 2) AS average_purchase
FROM company c
JOIN transactions t ON c.company_id = t.business_id
WHERE t.declined = 0
GROUP BY c.company_id;

SELECT *
FROM VistaMarketing
ORDER BY average_purchase DESC;

# Nivell 3
# Exercici 1

CREATE TABLE credit_card_status (
    card_id  VARCHAR(20) PRIMARY KEY,
    card_status   VARCHAR(10) NOT NULL,
    FOREIGN KEY (card_id) REFERENCES credit_card(id)
);

INSERT INTO credit_card_status (card_id, card_status)
SELECT t.card_id,
       CASE
           WHEN SUM(t.declined) = 3 THEN 'inactive'
           ELSE 'active'
       END AS card_status
FROM transactions t
WHERE 3 > ( SELECT COUNT(*)
			FROM transactions AS t2
			WHERE t2.card_id = t.card_id
			AND t2.timestamp > t.timestamp)
GROUP BY t.card_id;

SELECT COUNT(*) AS active_cards
FROM credit_card_status
WHERE card_status = 'active';

# Exercici 2

CREATE TABLE products (
	id				INT PRIMARY KEY,
    product_name	VARCHAR(30),
    price			DECIMAL(10, 2),
    colour			VARCHAR(20),
    weight			DECIMAL(10, 2),
    warehouse_id	VARCHAR(20),
    category		VARCHAR(20),
    brand			VARCHAR(20),
    cost			DECIMAL(10, 2),
    currency		VARCHAR(3),
    launch_date		DATE
);

LOAD DATA LOCAL INFILE 'C:/Users/Victor/Documents/IT ACADEMY/N1-Ex.8__products.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, product_name, @price, colour, weight, warehouse_id, category, brand, @cost, launch_date)
SET price = REPLACE(@price, '$', ''),
	cost = REPLACE(@cost, '$', ''),
    currency = LEFT(@price, 1);
    
CREATE TABLE product_transaction (
	product_id INT NOT NULL,
    transaction_id VARCHAR(36) NOT NULL,
    PRIMARY KEY (product_id, transaction_id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id)
);

INSERT INTO product_transaction (product_id, transaction_id)
SELECT jlist.product_id, t.id
FROM transactions t,
	JSON_TABLE(
		CONCAT('[', t.product_ids, ']'),
        '$[*]' COLUMNS (product_id INT PATH '$')
	) AS jlist;
    
SELECT p.id, p.product_name, COUNT(pt.transaction_id) AS sales
FROM products p
LEFT JOIN product_transaction pt ON p.id = pt.product_id
GROUP BY p.id
ORDER BY p.product_name;