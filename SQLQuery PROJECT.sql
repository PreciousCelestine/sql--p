-- CELESTINE PRECIOUS
-- SQL PROJECT
-- FEBURARY COHORT


-- Question 1
---Retrieve information about the products with colour values except null, red, silver/black, white and list price between
--£75 and £750. Rename the column StandardCost to Price. Also, sort the results in descending order by list price.--


SELECT * FROM Production.Product
WHERE Color NOT IN ('NULL','Red','Silver','Black','White')
AND ListPrice BETWEEN 75 AND 750;


--Question 2
--Find all the male employees born between 1962 to 1970 and with hire date greater than 2001 and female employees
--born between 1972 and 1975 and hire date between 2001 and 2002.


SELECT * FROM HumanResources.Employee
WHERE Gender = 'F' AND BirthDate BETWEEN '1972/1/1' AND '1975/12/31' AND HireDate BETWEEN '2001/1/1' AND '2001/12/31'
AND Gender = 'M' AND BirthDate BETWEEN '1962/1/1' AND '1970/12/31' AND HireDate BETWEEN '2001/1/1' AND '2002/12/31';

--Question 3
--Create a list of 10 most expensive products that have a product number beginning with ‘BK’. Include only the product
--ID, Name and colour.


SELECT TOP(10)* FROM Production.Product
WHERE ProductNumber LIKE 'BK%' AND ProductID  IS NOT NULL 
AND Color IS NOT NULL AND Name IS NOT NULL
ORDER BY ListPrice DESC;

--Question 4
--Create a list of all contact persons, where the first 4 characters of the last name are the same asthe first four characters
--of the email address. Also, for all contacts whose first name and the last name begin with the same characters, create
--a new column called full name combining first name and the last name only. Also provide the length ofthe new column
--full name.

SELECT * FROM Person.EmailAddress
SELECT PP.FirstName,PP.LastName,PE.EmailAddress ,
  CASE
        WHEN LEFT(PP.LastName, 4) = LEFT(PE.EmailAddress, 4) THEN 'Matching'
        ELSE 'Not Matching'
    END AS last_name_match,
    CASE
        WHEN LEFT(PP.FirstName, 4) = LEFT(PP.FirstName, 4) THEN PP.FirstName + ' ' + PP.LastName
        ELSE NULL
    END AS full_name,
    LEN(CASE
        WHEN LEFT(PP.FirstName, 4) = LEFT(PP.LastName, 4) THEN PP.FirstName + ' ' + PP.LastName
        ELSE NULL
    END) AS full_name_length
FROM Person.Person AS PP 
INNER JOIN Person.EmailAddress AS PE
ON PP.BusinessEntityID = PE.BusinessEntityID


--Question 5
--Return all product subcategories that take an average of 3 days or longer to manufacture.

SELECT ProductSubcategoryID FROM Production.Product
WHERE DaysToManufacture >= 3


--Question 6
--Create a list of product segmentation by defining criteria that places each item in a predefined segment as follows. If
--price gets less than £200 then low value. If price is between £201 and £750 then mid value. If between £750 and £1250
--then mid to high value else higher value. Filter the results only for black, silver and red color products.
	
SELECT *,"Price Range" = CASE
        WHEN ListPrice <= 200 THEN 'low value'
        WHEN ListPrice >= 201 AND ListPrice <= 750 THEN 'mid value'
        WHEN ListPrice >= 751 AND ListPrice <= 1250 THEN 'mid to high value'
        ELSE 'higher value'
        END    
FROM Production.Product
 WHERE color IN ('black', 'silver', 'red')
ORDER BY ProductNumber;

--Question 7
--How many Distinct Job title is present in the Employee table?

SELECT DISTINCT COUNT (JobTitle) FROM HumanResources.Employee

--Question 8
--Use employee table and calculate the ages of each employee at the time of hiring.

SELECT *, "AgeHired" = DATEDIFF(year,BirthDate,HireDate)
from HumanResources.Employee


--Question 9
--How many employees will be due a long service award in the next 5 years, if long service is 20 years?

SELECT COUNT(*) AS employees_due_long_service
FROM HumanResources.Employee
WHERE DATEDIFF(YEAR, HireDate, GETDATE()) >= 20
      AND DATEDIFF(YEAR, HireDate, GETDATE()) < 25;

--Question 10
--How many more years does each employee have to work before reaching sentiment, if sentiment age is 65?

SELECT *, 
	CASE
        WHEN MONTH(GETDATE()) * 100 + DAY(GETDATE()) >= MONTH(BirthDate) * 100 + DAY(BirthDate)
            THEN 65 - DATEDIFF(YEAR, BirthDate, GETDATE())
        ELSE 65 - DATEDIFF(YEAR, BirthDate, GETDATE()) - 1
    END AS years_to_sentiment
FROM
   HumanResources.Employee


---Question11
--Implement new price policy on the product table base on the colour of the item
--If white increase price by 8%, If yellow reduce price by 7.5%, If black increase price by 17.2%. If multi, silver,
--silver/black or blue take the square root of the price and double the value. Column should be called Newprice. For
--each item, also calculate commission as 37.5% of newly computed list price.

SELECT ProductNumber,ProductID, Name, Color, ListPrice,
    CASE
        WHEN color = 'white' THEN ListPrice * 1.08
        WHEN color = 'yellow' THEN ListPrice * 1.925
        WHEN color = 'black' THEN ListPrice * 1.172
        WHEN color IN ('multi', 'silver', 'silver/black', 'blue') THEN SQRT(ListPrice) * 2
        ELSE ListPrice
    END AS Newprice,
    CASE
        WHEN color = 'multi' THEN 0.375 * SQRT(ListPrice) * 2
        ELSE 0.375 * CASE
            WHEN color = 'white' THEN ListPrice * 1.08
            WHEN color = 'yellow' THEN ListPrice * 0.925
            WHEN color = 'black' THEN ListPrice * 1.172
            WHEN color IN ('silver', 'silver/black', 'blue') THEN SQRT(ListPrice) * 2
            ELSE ListPrice
        END
    END AS commission
FROM
    Production.Product;


--Question 12
--Print the information about all the Sales.Person and their sales quota. For every Sales person you should provide their
--FirstName, LastName, HireDate, SickLeaveHours and Region where they work.
 
SELECT P.BusinessEntityID,P.FirstName,P.LastName,H.SickLeaveHours,H.HireDate,S.SalesQuota,T.Name,T.CountryRegionCode FROM Person.Person AS P
INNER JOIN HumanResources.Employee AS H
ON P.BusinessEntityID = H.BusinessEntityID
INNER JOIN Sales.SalesPerson AS S
ON P.BusinessEntityID = S.BusinessEntityID
INNER JOIN Sales.SalesTerritory AS T
ON S.TerritoryID = T.TerritoryID
WHERE H.JobTitle = 'Sales Representative'


--Question 13
--Using adventure works, write a query to extract the following information.
--Product name,Product category name,Product subcategory name,Sales person,Revenue,Month of transaction,Quarter of transaction,Region

SELECT
    p.Name AS ProductName,
    pc.Name AS ProductCategory,
    ps.Name AS ProductSubcategory,
    CONCAT(e.FirstName, ' ', e.LastName) AS SalesPerson,
    sod.LineTotal AS Revenue,
    DATEPART(MONTH, soh.OrderDate) AS TransactionMonth,
    DATEPART(QUARTER, soh.OrderDate) AS TransactionQuarter,
    st.Name AS Region
FROM
    Sales.SalesOrderHeader AS soh
JOIN
    Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN
    Production.Product AS p ON sod.ProductID = p.ProductID
JOIN
    Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN
    Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
JOIN
    Sales.SalesPerson AS sp ON soh.SalesPersonID = sp.BusinessEntityID
JOIN
    Person.Person AS e ON sp.BusinessEntityID = e.BusinessEntityID
JOIN
    Sales.SalesTerritory AS st ON sp.TerritoryID = st.TerritoryID
ORDER BY
    soh.OrderDate;


---Question 14
--Display the information about the details of an order i.e. order number, order date, amount of order, which customer
--gives the order and which salesman works for that customer and how much commission he gets for an order.

SELECT
    soh.SalesOrderNumber AS OrderNumber,
    soh.OrderDate,
    soh.TotalDue AS OrderAmount,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    CONCAT(e.FirstName, ' ', e.LastName) AS SalesPerson,
    sp.CommissionPct * soh.TotalDue AS Commission
FROM
    Sales.SalesOrderHeader AS soh
JOIN
 Sales.Customer AS v ON soh.CustomerID = v.CustomerID
JOIN
    Sales.vIndividualCustomer AS c ON v.AccountNumber = c.
JOIN
    Sales.SalesPerson AS sp ON soh.SalesPersonID = sp.BusinessEntityID
JOIN
    Person.Person AS e ON sp.BusinessEntityID = e.BusinessEntityID;

SELECT * FROM Sales.SalesTerritory


--Question 15
--For all the products calculate
--Commission as 14.790% of standard cost,
-- Margin, if standard cost is increased or decreased as follows:
--Black: +22%,
--Red: -12%
--Silver: +15%
--Multi: +5%
--White: Two times original cost divided by the square root of cost
--For other colours, standard cost remains the same

SELECT
    p.ProductID,
    p.Name AS ProductName,
    p.Color,
    p.StandardCost,
    CAST(p.StandardCost * 0.1479 AS MONEY) AS Commission,
    CASE
        WHEN p.Color = 'Black' THEN p.StandardCost * 0.22
        WHEN p.Color = 'Red' THEN p.StandardCost * -0.12
        WHEN p.Color = 'Silver' THEN p.StandardCost * 0.15
        WHEN p.Color = 'Multi' THEN p.StandardCost * 0.05
        WHEN p.Color = 'White' THEN (2 * p.StandardCost) / SQRT(p.StandardCost)
        ELSE p.StandardCost
    END AS Margin
FROM
    Production.Product AS p;
--Question 16
--Create a view to find out the top 5 most expensive products for each colour.

CREATE VIEW MostExpensiveProductsByColor AS
WITH RankedProducts AS (
    SELECT
        p.ProductID,
        p.Name AS ProductName,2Z
        p.Color,
        p.StandardCost,
        ROW_NUMBER() OVER(PARTITION BY p.Color ORDER BY p.StandardCost DESC) AS Rank
    FROM
        Production.Product AS p
)
SELECT
    ProductID,
    ProductName,
    Color,
    StandardCost
FROM
    RankedProducts
WHERE
    Rank <= 5;

	SELECT * FROM MostExpensiveProductsByColor