--creating de database
CREATE DATABASE books;

--accessing the database created
\c books

--Creating the temporary tables where we are copying the data
CREATE TABLE Temp_isbn_precios(
  ISBN varchar(20),
  precios varchar(15)
);

CREATE TABLE Temp_libros_final(
  author varchar(100),
  title varchar(300),
  format varchar(100),
  n_pages varchar(50),
  publishing_house varchar(100),
  publishing_date varchar(50),
  lang varchar(50),
  ISBN varchar(20)
);

CREATE TABLE Temp_usuarios(
  uid varchar(20),
  scrname varchar(50),
  full_name varchar(100),
  join_date varchar(100),
  credit_card varchar(50),
  expiration varchar(50)
);

CREATE TABLE Temp_ventas(
  sale_id varchar(20),
  user_id varchar(50),
  ISBN varchar(20),
  purchase_date varchar(50)
);
----------------------------------------------------------------

--Copying the data into temporary tables(It is important to have the file "datos_libreria" in your User file (ex. Users/Alejandro Santorum))
\copy Temp_isbn_precios from 'Desktop/datos_libreria/isbns_precios.txt'; --in windows just datos_libreria/isbns_precios.txt without simple quotes

\copy Temp_libros_final from 'Desktop/datos_libreria/LIBROS_FINAL.txt'; --in windows just datos_libreria/LIBROS_FINAL.txt without simple quotes

\copy Temp_usuarios from 'Desktop/datos_libreria/usuarios.txt'; --in windows just datos_libreria/usuarios.txt without simple quotes

\copy Temp_ventas from 'Desktop/datos_libreria/ventas.txt'; --in windows just datos_libreria/ventas.txt without simple quotes
---------------------------------------------------------

--We create a auxiliary temporary table, just to help us to cast the price from varchar into float
CREATE TABLE Temp_books(
  ISBN varchar(20),
  Title varchar(200),
  Author varchar(200),
  Format varchar(64),
  N_pages varchar(100),
  Publishing_house varchar(100),
  Lang varchar(50),
  Price float
);

INSERT INTO Temp_books(
  SELECT Temp_libros_final.ISBN, Title, Author, Format, n_pages, Publishing_house, Lang, cast(replace(Temp_isbn_precios.Precios, ',','.') as Float)
  FROM Temp_libros_final, Temp_isbn_precios
  WHERE Temp_isbn_precios.ISBN = Temp_libros_final.ISBN AND left(Temp_isbn_precios.Precios, 1) <> ' '
  UNION
  SELECT Temp_libros_final.ISBN, Title, Author, Format, n_pages, Publishing_house, Lang, 10.0
  FROM Temp_libros_final, Temp_isbn_precios
  WHERE Temp_isbn_precios.ISBN = Temp_libros_final.ISBN AND left(Temp_isbn_precios.Precios, 1) = ' '
);
------------------------------------------------------------------

--Creating the final tables where the data will be stored
CREATE TABLE Books(
  ISBN varchar(20) PRIMARY KEY,
  Title varchar(200),
  Author varchar(200),
  Format varchar(64),
  N_pages varchar(100),
  Publishing_house varchar(100),
  Lang varchar(50),
  Price float,
  Book_id serial
);

CREATE TABLE Users(
  User_id int PRIMARY KEY,
  Scrname varchar(50),
  Full_name varchar(200),
  Join_date date,
  Credit_card bigint,
  Expiration date
);

CREATE TABLE Sales(
  Sale_id int,
  User_id int,
  ISBN varchar(20),
  Purchase_date date,
  Super_sale_id serial PRIMARY KEY,
  FOREIGN KEY(ISBN) REFERENCES BOOKS(ISBN),
  FOREIGN KEY(User_id) REFERENCES USERS(user_id)
);

CREATE TABLE Discounts(
  Discount_id serial PRIMARY KEY,
  ISBN varchar(20),
  Initial_date date,
  Final_date date,
  Coef int,
  FOREIGN KEY(ISBN) REFERENCES BOOKS(ISBN)
);
------------------------------------------------------------------------

--This view filter the repeated ISBNS, Titles, Authors, etc
--because of the fact the data we recieve is poor, talking about quality
CREATE VIEW IntoBooks AS
  SELECT ISBN, min(Title) AS Title, min(Author) AS Author, min(Format) AS Format, min(n_pages) AS n_pages, min(Publishing_house) AS Publishing_house, min(Lang) AS Lang
  FROM temp_books
  GROUP BY ISBN;

--We insert all the data into the final tables
INSERT INTO Books(
  SELECT DISTINCT IntoBooks.ISBN, IntoBooks.Title, IntoBooks.Author, IntoBooks.Format, IntoBooks.n_pages, IntoBooks.Publishing_house, IntoBooks.Lang, Temp_books.price
  FROM IntoBooks, temp_books
  WHERE IntoBooks.ISBN = temp_books.ISBN
);

INSERT INTO Users --Introducing the Non Registered User into Users table
VALUES(0, 'NRU', 'Non_Registered_User', '1000-01-01', 0000000000000000, '1000-01-01');

INSERT INTO Users
  SELECT cast(uid AS int), min(scrname), min(full_name), min(cast(join_date AS date)), min(cast(credit_card AS bigint)), min(cast(expiration AS date))
  FROM temp_usuarios
  GROUP BY uid;

INSERT INTO Sales
  SELECT cast(Temp_ventas.sale_id AS int), cast(Temp_ventas.User_id AS INT), Books.ISBN, cast(Temp_ventas.Purchase_date AS date)
  FROM Temp_ventas, Books
  WHERE Books.ISBN = Temp_ventas.ISBN;

INSERT INTO Discounts (ISBN, Initial_date, Final_date, Coef)
VALUES('0753820870', '2010-01-15', '2014-10-10', 50), ('019871517X', '2012-01-01', '2014-12-30', 90);

DROP VIEW intobooks; --Once the database is already filled, we don´t need this auxiliary view.
-------------------------------------------------------------------------------
