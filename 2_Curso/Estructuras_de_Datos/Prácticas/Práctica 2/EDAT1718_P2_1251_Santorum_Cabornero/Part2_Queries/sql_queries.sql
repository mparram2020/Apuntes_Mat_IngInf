------------------------------------------------------------------------------
                          --Q U E R I E S--
--Now we are showing the queries required


--1.1 Given a title, how many editions does it have?(ex. Don Quixote)
SELECT COUNT(Books.ISBN) AS n_Editions
FROM Books WHERE Books.ISBN IN
(SELECT Books.ISBN
FROM Books
WHERE Title = 'Don Quixote');


--1.2 Given a title, in how many languages is the book written?(ex. Don Quixote)
SELECT COUNT(DISTINCT Lang) AS n_Languages
FROM Books
WHERE Books.ISBN IN
(SELECT Books.ISBN
FROM Books
WHERE Title = 'Don Quixote');


--2. How many books of author X were sold? (ex. Arturo Perez-Reverte)
SELECT COUNT(*) AS n_BooksSold
FROM Books, Sales
WHERE Books.author = 'Arturo Perez-Reverte' AND Books.ISBN = Sales.ISBN;


--3. How many books of author X were sold at a discount? (ex. Arturo Perez-Reverte)
SELECT COUNT(*) AS n_BooksAtDiscount
FROM Books, Sales, Discounts
WHERE Books.Author = 'Arturo Perez-Reverte' AND Books.ISBN = Sales.ISBN AND Sales.ISBN = Discounts.ISBN AND (Purchase_date BETWEEN Discounts.Initial_date AND Discounts.Final_date);


--4. How much money was earned by selling books of author X?(ex. Arturo Perez-Reverte)
CREATE VIEW Money_earned AS( --First, we get into a view the prices with a discount and the prices without it.
SELECT sum(Books.price) AS s1
FROM Books, Sales, Discounts
WHERE Sales.ISBN = Books.ISBN AND Sales.ISBN = Discounts.ISBN AND Books.author = 'Arturo Perez-Reverte' AND NOT(Purchase_date BETWEEN Discounts.Initial_date AND Discounts.Final_date)
UNION
SELECT sum(Books.price * (100.0 - Discounts.coef)/100)
FROM Books, Sales, Discounts
WHERE Sales.ISBN = Books.ISBN AND Sales.ISBN = Discounts.ISBN AND Books.author = 'Arturo Perez-Reverte' AND(Purchase_date BETWEEN Discounts.Initial_date AND Discounts.Final_date));

SELECT sum(s1) AS Money_Earned_For_X_Author FROM Money_earned; --We sum the prices with discount and the other ones.

DROP VIEW Money_earned; --We delete the auxiliary view.


--5. How many books were sold to registered users?
SELECT COUNT(*) AS n_BooksSold_ToRegistered
FROM Sales, Users
WHERE Users.user_id = Sales.user_id AND Users.user_id <> 0;


--6. How many registered users have bought English books?
SELECT COUNT(DISTINCT Users.user_id) AS n_registeredUsers
FROM Sales, Users, Books
WHERE Users.user_id <> 0 AND Users.user_id = Sales.user_id AND Sales.ISBN = Books.ISBN AND (Books.Lang = 'English' OR Books.Lang = 'Inglés');


--7. How much money was earned by selling books in French?
CREATE VIEW Money_earned AS( --First, we get into a view the prices with a discount and the prices without it.
SELECT sum(Books.price) AS s1
FROM Books, Sales, Discounts
WHERE Sales.ISBN = Books.ISBN AND Books.lang = 'Francés' AND NOT(Purchase_date BETWEEN Discounts.Initial_date AND Discounts.Final_date)
UNION
SELECT sum(Books.price * (100.0 - Discounts.coef)/100)
FROM Books, Sales, Discounts
WHERE Sales.ISBN = Books.ISBN AND Books.lang = 'Francés' AND(Purchase_date BETWEEN Discounts.Initial_date AND Discounts.Final_date));

SELECT sum(s1) AS Money_Earned_BooksFrench FROM Money_earned; --We sum the prices with discount and the other ones.

DROP VIEW Money_earned; --We delete the auxiliary view.


--8.1 In which days were books of the publisher Adelpi on sale?
SELECT Discounts.Initial_date, Discounts.Final_date --This example returns 0 because Adelpi doesn´t exist.
FROM Books, Discounts
WHERE Publishing_house = 'Adelpi';
--8.2 In which days were books of the publisher Oxford University Press, U.S.A. on sale?
SELECT Discounts.Initial_date, Discounts.Final_date --This gives us a non-null result.
FROM Books, Discounts
WHERE Publishing_house = 'Oxford University Press, U.S.A. ';


--9. Which registered users have never bought paperback books?
SELECT DISTINCT Users.full_name
FROM Users
WHERE User_id <> 0
EXCEPT
SELECT DISTINCT Users.full_name
FROM Users, Sales, Books
WHERE Users.user_id = Sales.user_id AND Sales.ISBN = Books.ISBN AND Users.user_id <> 0 AND Books.format LIKE '%Libro de bolsillo%';
