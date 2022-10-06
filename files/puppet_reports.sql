CREATE TABLE reports ( ID SERIAL PRIMARY KEY, certname varchar(80) NOT NULL, environment varchar(40), status varchar(10) NOT NULL, time varchar(30), transaction_uuid character varying(50) NOT NULL );
CREATE TABLE users ( username varchar(20) NOT NULL, password varchar(20) NOT NULL );
INSERT INTO users (username, password) VALUES ('admin', 'ch@ngem3');