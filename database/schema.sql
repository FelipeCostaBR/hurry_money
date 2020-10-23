CREATE DATABASE hurrymoney;


CREATE TABLE investors (
 id SERIAL PRIMARY KEY,
 firstname VARCHAR(200) NOT NULL,
 lastname VARCHAR(200) NOT NULL,
 email TEXT NOT NULL,
 phone CHAR(20),
 dt_birth DATE,
 address TEXT,
 photo text,
 password_digest TEXT,
 wallet_value DECIMAL
);

alter TABLE investors ADD COLUMN wallet_value DECIMAL;

-- INSERT INTO investors (firstname, lastname, email, phone, dt_birth, address, photo) VALUES ('Felipe', 'Costa', 'felipe@go.co', 404433456, '1992-07-15', 'Rua Abilheira, 7 mitsutani', 'https://avatars2.githubusercontent.com/u/42413625?s=460&u=c9b18cbab7120496cf575fa3ba4556d74455aaae&v=4','123');


CREATE TABLE debtors (
 id SERIAL PRIMARY KEY,
 firstname VARCHAR(200) NOT NULL,
 lastname VARCHAR(200) NOT NULL,
 email TEXT NOT NULL,
 phone CHAR(20),
 dt_birth DATE,
 address TEXT,
 photo text,
 password_digest TEXT,
 wallet_value DECIMAL
);

alter TABLE debtors ADD COLUMN wallet_value DECIMAL;


-- INSERT INTO debtors (firstname, lastname, email, phone, dt_birth, address, photo) VALUES ('Sharlene', 'Piggot', 'sharlene@go.co', 445334334, '1992-02-21', 'Rua Abilheira, 7 mitsutani', 'https://avatars3.githubusercontent.com/u/43175?s=460&u=c7768417f3cf6b1ef9e00301231396f194e65aa2&v=4','123');

CREATE TABLE loans (
    id SERIAL PRIMARY KEY,
    money_asked DECIMAL NOT NULL,
    money_lended DECIMAL,
    fee DECIMAL NOT NULL,
    create_date DATE NOT NULL DEFAULT CURRENT_DATE,
    installments SMALLINT NOT NULL,
    id_debtors INTEGER NOT NULL,
    constraint fk_borrow_debtors
    foreign key (id_debtors) 
    REFERENCES debtors (id),
    id_investors INTEGER,
    constraint fk_borrow_investors
    foreign key (id_investors) 
    REFERENCES investors (id)
);

INSERT INTO loans (money_asked, fee, installments, id_debtors) VALUES (1000, 200, 3, 1);
INSERT INTO loans (money_asked, fee, installments, id_debtors) VALUES (500, 100, 2, 1);

CREATE TABLE installments (
    id SERIAL PRIMARY KEY,
    value DECIMAL,
    due_date DATE,
    paid INTEGER,
    id_loan integer,
    constraint fk_order_loan
    foreign key (id_loan) 
    REFERENCES loans (id)
);
 
CREATE FUNCTION insert_installments()
    RETURNS TRIGGER 
    LANGUAGE PLPGSQL
    AS
$$
    declare 
    counter integer := 0;
    due_date DATE := (SELECT CURRENT_DATE + integer '30');
    BEGIN
        while counter < NEW.installments loop
            INSERT INTO installments(value, due_date, id_loan, paid)VALUES((NEW.money_lended+NEW.fee)/NEW.installments, due_date, NEW.id, 0);
            counter := counter + 1;
            due_date := due_date + integer '30';
        end loop;
        RETURN NEW;
    END;
$$;


CREATE TRIGGER create_all_installments
  BEFORE UPDATE
  ON loans
  FOR EACH ROW
  EXECUTE PROCEDURE insert_installments();


-- DROP TRIGGER create_all_installments ON loans;
-- drop function insert_installments;

-- update when investor decide to leand money 
UPDATE loans SET id_investors = 1, money_lended = 500 WHERE ID = 2;

-- Investors: next payments into the account account
SELECT DISTINCT a.id,CONCAT(c.firstname, ' ',c.lastname) AS debtor_name ,
ROUND((SELECT SUM(value) FROM installments WHERE paid = 0 AND id_loan = a.id),2) AS value_pending, 
(SELECT count(paid) FROM installments WHERE paid = 0 AND id_loan = a.id ) AS not_paid,
(SELECT count(paid) FROM installments WHERE paid = 1 AND id_loan = a.id ) AS paid,
(SELECT min(due_date) FROM installments WHERE paid = 0 AND id_loan = a.id ) AS due_date
    FROM loans a 
        INNER JOIN installments b ON a.id = b.id_loan 
        INNER JOIN debtors c ON c.id = a.id_debtors
        WHERE a.id_investors = 1
        GROUP BY a.id,c.firstname,c.lastname;

