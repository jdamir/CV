-- Common script to create source table
CREATE DATABASE parts;


CREATE TABLE parts_extended (
item_no INT,
length NUMERIC,
width NUMERIC,
height NUMERIC,
operator CHAR(5)
);