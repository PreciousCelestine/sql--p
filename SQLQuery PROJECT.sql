-- CELESTINE PRECIOUS
-- SQL PROJECT
-- FEBURARY COHORT


-- Question 1
---Retrieve information about the products with colour values except null, red, silver/black, white and list price between
--£75 and £750. Rename the column StandardCost to Price. Also, sort the results in descending order by list price.--


SELECT
    ProductID,
    Name,
    ProductNumber,
    Color,
    StandardCost AS Price,
    ListPrice
FROM Production.Product
WHERE Color IS NOT NULL
  AND Color NOT IN ('Red', 'Silver/Black', 'White')
  AND ListPrice BETWEEN 75 AND 750
ORDER BY ListPrice DESC;


--Question 2
--Find all the male employees born between 1962 to 1970 and with hire date greater than 2001 and female employees
--born between 1972 and 1975 and hire date between 2001 and 2002.


SELECT
    BusinessEntityID,
    JobTitle,
    Gender,
    BirthDate,
    HireDate
FROM HumanResources.Employee
WHERE
    (
        Gender = 'M'
        AND BirthDate >= '19620101'
        AND BirthDate < '19710101'
        AND HireDate >= '20020101'
    )
    OR
    (
        Gender = 'F'
        AND BirthDate >= '19720101'
        AND BirthDate < '19760101'
        AND HireDate >= '20010101'
        AND HireDate < '20030101'
    )
ORDER BY Gender, BirthDate, BusinessEntityID;

--Question 3
--Create a list of 10 most expensive products that have a product number beginning with ‘BK’. Include only the product
--ID, Name and colour.


SELECT TOP (10)
    ProductID,
    Name,
    Color
FROM Production.Product
WHERE ProductNumber LIKE 'BK%'
ORDER BY ListPrice DESC, ProductID;

--Question 4
--Create a list of all contact persons, where the first 4 characters of the last name are the same asthe first four characters
--of the email address. Also, for all contacts whose first name and the last name begin with the same characters, create
--a new column called full name combining first name and the last name only. Also provide the length ofthe new column
--full name.

-- A. Contacts whose last name and email address
-- have the same first four characters.
SELECT
    p.BusinessEntityID,
    p.FirstName,
    p.LastName,
    e.EmailAddress
FROM Person.Person AS p
INNER JOIN Person.EmailAddress AS e
    ON p.BusinessEntityID = e.BusinessEntityID
WHERE LEFT(p.LastName, 4) = LEFT(e.EmailAddress, 4)
ORDER BY p.BusinessEntityID, e.EmailAddress;


-- B. Contacts whose first and last names
-- begin with the same initial.
SELECT
    p.BusinessEntityID,
    p.FirstName,
    p.LastName,
    CONCAT(p.FirstName, ' ', p.LastName) AS FullName,
    LEN(CONCAT(p.FirstName, ' ', p.LastName)) AS FullNameLength
FROM Person.Person AS p
WHERE LEFT(p.FirstName, 1) = LEFT(p.LastName, 1)
ORDER BY p.BusinessEntityID;


--Question 5
--Return all product subcategories that take an average of 3 days or longer to manufacture.

SELECT
    p.ProductSubcategoryID,
    ps.Name AS SubcategoryName,
    AVG(CAST(p.DaysToManufacture AS DECIMAL(10, 2)))
        AS AverageManufacturingDays
FROM Production.Product AS p
INNER JOIN Production.ProductSubcategory AS ps
    ON p.ProductSubcategoryID = ps.ProductSubcategoryID
GROUP BY
    p.ProductSubcategoryID,
    ps.Name
HAVING
    AVG(CAST(p.DaysToManufacture AS DECIMAL(10, 2))) >= 3
ORDER BY
    AverageManufacturingDays DESC,
    p.ProductSubcategoryID;


--Question 6
--Create a list of product segmentation by defining criteria that places each item in a predefined segment as follows. If
--price gets less than £200 then low value. If price is between £201 and £750 then mid value. If between £750 and £1250
--then mid to high value else higher value. Filter the results only for black, silver and red color products.
	
SELECT
    ProductID,
    Name,
    ProductNumber,
    Color,
    ListPrice,
    CASE
        WHEN ListPrice <= 200 THEN 'Low value'
        WHEN ListPrice <= 750 THEN 'Mid value'
        WHEN ListPrice <= 1250 THEN 'Mid to high value'
        ELSE 'Higher value'
    END AS PriceSegment
FROM Production.Product
WHERE Color IN ('Black', 'Silver', 'Red')
ORDER BY ProductNumber;

--Question 7
--How many Distinct Job title is present in the Employee table?

SELECT
    COUNT(DISTINCT JobTitle) AS UniqueJobTitles
FROM HumanResources.Employee;

--Question 8
--Use employee table and calculate the ages of each employee at the time of hiring.

SELECT
    BusinessEntityID,
    JobTitle,
    BirthDate,
    HireDate,
    DATEDIFF(YEAR, BirthDate, HireDate)
    - CASE
        WHEN DATEADD(
            YEAR,
            DATEDIFF(YEAR, BirthDate, HireDate),
            BirthDate
        ) > HireDate
        THEN 1
        ELSE 0
      END AS AgeAtHire
FROM HumanResources.Employee
ORDER BY BusinessEntityID;


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

SELECT
    p.ProductID,
    p.ProductNumber,
    p.Name,
    p.Color,
    p.ListPrice,
    pricing.NewPrice,
    pricing.NewPrice * 0.375 AS Commission
FROM Production.Product AS p
CROSS APPLY (
    SELECT
        CASE
            WHEN p.Color = 'White'
                THEN p.ListPrice * 1.08
            WHEN p.Color = 'Yellow'
                THEN p.ListPrice * 0.925
            WHEN p.Color = 'Black'
                THEN p.ListPrice * 1.172
            WHEN p.Color IN (
                'Multi', 'Silver', 'Silver/Black', 'Blue'
            )
                THEN SQRT(p.ListPrice) * 2
            ELSE p.ListPrice
        END AS NewPrice
) AS pricing
ORDER BY p.ProductID;


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
    soh.CustomerID,
    COALESCE(
        store.Name,
        NULLIF(
            LTRIM(RTRIM(CONCAT(
                customer.FirstName, ' ', customer.LastName
            ))),
            ''
        ),
        'Unknown customer'
    ) AS CustomerName,
    soh.SubTotal,
    soh.TaxAmt,
    soh.Freight,
    soh.TotalDue AS OrderAmount,
    soh.SalesPersonID,
    CASE
        WHEN soh.SalesPersonID IS NULL THEN 'Unassigned'
        ELSE CONCAT(salesperson.FirstName, ' ', salesperson.LastName)
    END AS SalesPerson,
    sp.CommissionPct,
    soh.SubTotal * sp.CommissionPct AS EstimatedCommission
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.Customer AS c
    ON soh.CustomerID = c.CustomerID
LEFT JOIN Person.Person AS customer
    ON c.PersonID = customer.BusinessEntityID
LEFT JOIN Sales.Store AS store
    ON c.StoreID = store.BusinessEntityID
LEFT JOIN Sales.SalesPerson AS sp
    ON soh.SalesPersonID = sp.BusinessEntityID
LEFT JOIN Person.Person AS salesperson
    ON sp.BusinessEntityID = salesperson.BusinessEntityID
ORDER BY soh.OrderDate, soh.SalesOrderID;


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

CREATE VIEW dbo.MostExpensiveProductsByColor
AS
WITH RankedProducts AS (
    SELECT
        ProductID,
        Name AS ProductName,
        Color,
        ListPrice,
        ROW_NUMBER() OVER (
            PARTITION BY Color
            ORDER BY ListPrice DESC, ProductID
        ) AS PriceRank
    FROM Production.Product
    WHERE Color IS NOT NULL
)
SELECT
    ProductID,
    ProductName,
    Color,
    ListPrice,
    PriceRank
FROM RankedProducts
WHERE PriceRank <= 5;

GO

SELECT *
FROM dbo.MostExpensiveProductsByColor
ORDER BY Color, PriceRank;
