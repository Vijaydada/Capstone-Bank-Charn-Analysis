create database NEWTON_BANK_CRM;
use NEWTON_BANK_CRM;

create table CreditCard (
	CreditID INT PRIMARY KEY,
	Category varchar (255)
);
create table ExitCustomer (
	ExitID INT PRIMARY KEY,
    ExitCategory varchar(255)
);

create table ActiveCustomer(
ActiveID int PRIMARY KEY,
ActiveCategory varchar(255));

create table Geography (
  GeographyId int primary key,
  GeographyLocation varchar(255)
);
create table Gender(
	GenderID int primary key,
    GenderCategory varchar(10));
    

create table CustomerInfo(
	CustomerId int primary key,
    Surname varchar(255),
    Age int,
    GenderID int,
    EstimatedSalary	double,
    GeographyID	int,
    BankDOJ text,
    foreign key (GenderID) references Gender(GenderID),
    foreign key(GeographyId) references Geography(GeographyId)
    );
    

create table Bank_churn(
	CustomerId int,
    foreign key (CustomerId) references customerinfo(CustomerId),
	CreditScore int,
	Tenure int,
	Balance int,
    NumOfProducts int,
	HasCrCard int,
    foreign key (HasCrCard) references creditcard(CreditID),
    IsActiveMember int,
    foreign key (IsActiveMember) references activecustomer(ActiveID),
	Exited int,
    foreign key (Exited) references exitcustomer(ExitID)
    );
-- Question 2
SELECT 
    CustomerId, 
    YEAR(BankDOJ) AS join_year, 
    QUARTER(BankDOJ) AS join_quarter, 
    MAX(EstimatedSalary) AS max_salary
FROM 
    CustomerInfo
WHERE 
    QUARTER (BankDOJ) = 4
GROUP BY 
    CustomerId, 
    join_year, 
    join_quarter
ORDER BY 
    max_salary DESC
LIMIT 5;
-- Question 3
select CustomerId, avg(NumOfProducts) from Bank_churn 
where HasCrCard = 1
group by customerId;
-- Question 4

select g.GenderCategory,
count(*) as total_customers,
sum(case when bc.Exited =1 then 1 else 0 end) as churned_customers,
sum(case when bc.Exited =1 then 1 else 0 end)/count(*) as churn_rate
from BANK_CHURN bc
join CustomerInfo ci on bc.CustomerId = ci.CustomerId
join Gender g on ci.GenderId = g.GenderId
where year(ci.BankDOJ) = (select max(year(BankDOJ)) from CustomerInfo)
group by g.GenderCategory;
-- Question 5 
SELECT
    CASE WHEN Exited = 1 THEN 'forexited' ELSE 'fornonexited' END AS exit_status,
    AVG(CreditScore) AS avg_credit_score
FROM
    BANK_CHURN
GROUP BY
    CASE WHEN Exited = 1 THEN 'forexited' ELSE 'fornonexited' END;
   -- Question 6
WITH AvgSalary AS (
    SELECT
        GenderId,
        ROUND(AVG(EstimatedSalary), 2) AS avg_salary
    FROM
        CustomerInfo
    GROUP BY
        GenderId
)

SELECT
    g.GenderCategory,
    a.avg_salary,
    SUM(bc.IsActivemember) AS active_accounts
FROM
    Gender g
JOIN
    AvgSalary a ON g.GenderId = a.GenderId
JOIN
    CustomerInfo ci ON g.GenderId = ci.GenderId
JOIN
    BANK_CHURN bc ON ci.CustomerId = bc.CustomerId
GROUP BY
    g.GenderCategory, a.avg_salary;
    -- Qestion 7
WITH creditScoreSegment AS (
    SELECT CASE 
            WHEN CreditScore <= 599 THEN 'Poor'
            WHEN CreditScore > 599 AND CreditScore <= 700 THEN 'Low'
            WHEN CreditScore > 700 AND CreditScore <= 749 THEN 'Low'
            WHEN CreditScore > 749 AND CreditScore <= 799 THEN 'Low'
            ELSE 'Excellent'END AS CreditSegment,Exited
    FROM Bank_Churn)
SELECT 
    CreditSegment,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS Exited_Customer,
    COUNT(*) AS TotalCustomer,
    ROUND(SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / COUNT(*), 4) AS ExitRate
FROM creditScoreSegment
GROUP BY CreditSegment
ORDER BY ExitRate DESC
LIMIT 1;

    -- Question 8
select geo.GeographyLocation, sum(bank.IsActivemember) from Geography geo
join CustomerInfo cust on
geo.GeographyID = cust.GeographyID
join BANK_CHURN bank on
cust.CustomerId = bank.CustomerId
where bank.IsActivemember = 1
and bank.Tenure > 5
group by geo.GeographyLocation
order by 2 desc 
limit 1;
-- Question 9
SELECT 
    CASE 
        WHEN bank.HasCrCard = 0 THEN 'No_Credit' 
        ELSE 'Credit_Card' 
    END AS Creditcard_Status,
    COUNT(bank.exited) AS ChurnedCustomers
FROM bank_churn bank
WHERE bank.exited = 1
GROUP BY bank.HasCrCard;
-- Question 10
select NumOfProducts as MostCommonProduct, count(*) as CountProducts
from BANK_CHURN where Exited=1
group by NumOfProducts
order by count(*) desc limit 1;
-- Question 11
-- Question 12
select year(BankDOJ) as YearWise
, count(CustomerId) from CustomerId
group by year(BankDOJ) order by count(CustomerId) asc;
-- Question 14
show tables;
-- Question 15
select distinct case when GenderID = 1 then "Male" else "Female" end as "Gender",
	avg(case when GeographyID=1 then EstimatedSalary else  0 end) as "France",
    avg(case when GeographyID=2 then EstimatedSalary else  0 end) as "Spain",
    avg(case when GeographyID=3 then EstimatedSalary else  0 end) as "Germany",
    rank() over ( order by avg(EstimatedSalary) )as "Rank_Gender"
from CustomerInfo
group by GenderID;
-- Question 16
select case
		when age between 18 and 30 then "18-30" 
        when age between 31 and 50 then "31-50"
        else "50+" end as AgeGroup,
        avg(EstimatedSalary) as avg_salary
from CustomerInfo
join Bank_Churn on CustomerInfo.CustomerId=Bank_Churn.CustomerId
where Exited=1
group by case
		when age between 18 and 30 then "18-30" 
        when age between 31 and 50 then "31-50"
        else "50+" end;

-- Question 17
SELECT 
    (COUNT(*) * SUM(EstimatedSalary * Balance) - SUM(EstimatedSalary) * SUM(Balance)) /
    (SQRT((COUNT(*) * SUM(EstimatedSalary * EstimatedSalary) - POW(SUM(EstimatedSalary), 2)) * 
    (COUNT(*) * SUM(Balance * Balance) - POW(SUM(Balance), 2))))
    AS correlation_all
FROM 
    Bank_Churn
JOIN 
    CustomerInfo ON Bank_Churn.CustomerId = CustomerInfo.CustomerId
    where Exited=1;
-- non exited 

    -- Question 18
SELECT 
    (COUNT(*) * SUM(EstimatedSalary * CreditScore) - SUM(EstimatedSalary) * SUM(CreditScore)) /
    (SQRT((COUNT(*) * SUM(EstimatedSalary * EstimatedSalary) - POW(SUM(EstimatedSalary), 2)) * 
    (COUNT(*) * SUM(CreditScore * CreditScore) - POW(SUM(CreditScore), 2))))
    AS correlation_all
FROM 
    Bank_Churn
JOIN 
    CustomerInfo ON Bank_Churn.CustomerId = CustomerInfo.CustomerId;


-- Question 19
with ChurnCustomers as (select case
	when CreditScore<=599 then 'Poor'
    when CreditScore>599 and CreditScore<=700 then 'Low'
    when CreditScore>700 and CreditScore<=749 then 'Fair'
    when CreditScore>749 and CreditScore<=799 then 'Low'
    else 'Excellent'end as Credit_Category, count(*) as churned_count
    from Bank_Churn where Exited= 1
    group by case
	when CreditScore<=599 then 'Poor'
    when CreditScore>599 and CreditScore<=700 then 'Low'
    when CreditScore>700 and CreditScore<=749 then 'Fair'
    when CreditScore>749 and CreditScore<=799 then 'Low'
    else 'Excellent'end),
    RankBucket as (select Credit_Category,Churned_count, rank() over (order by churned_count desc)as Rank_Bucket
    from ChurnCustomers)
    select Credit_Category, Churned_count,Rank_Bucket from RankBucket;
    -- Question 20
WITH CreditCardCounts AS (
    SELECT 
        CASE WHEN cust.Age BETWEEN 18 AND 30 THEN '18-30'
             WHEN cust.Age BETWEEN 31 AND 50 THEN '31-50' ELSE '50+' END AS ageBucket, 
        COUNT(bank.HasCrCard) AS CreditCardCount
    FROM Bank_Churn bank
    JOIN CustomerInfo cust ON bank.customerid = cust.customerid
    WHERE HasCrCard = 1
    GROUP BY ageBucket
),
AvgCreditCards AS (
    SELECT AVG(CreditCardCount) AS avgCreditCard
    FROM CreditCardCounts
)
SELECT ageBucket,CreditCardCount, avgCreditCard
FROM CreditCardCounts
CROSS JOIN AvgCreditCards
WHERE CreditCardCount < avgCreditCard;

--  Question 21 Rank the Locations as per the number of people who have churned the bank and average balance of the customers.
select case when GeographyID=1 then "France" 
			when GeographyID=2 then "Spain" 
            else "Germany" end as Locations, 
            count(bank.CustomerId) as NumberOfCustomerChurned, avg(Balance) as AvgBalance, 
            rank() over (order by count(bank.CustomerId) desc) as "rank"
            from Bank_Churn as bank
join CustomerInfo as cust on bank.CustomerId = cust.CustomerId
where Exited=1
group by GeographyID;
-- Question 22
select 
    cust.*,
    concat(cust.CustomerId, ' ', cust.SurName) as Customerid_Surname
from
    CustomerInfo cust
join 
    Bank_Churn bank on cust.CustomerId = bank.customerId;
    -- Question 23
    select 
		bank.*,
		(select exi.ExitCategory 
	from ExitCustomer exi
     where exi.ExitId = bank.Exited) as ExitCategory
	from Bank_Churn bank;
    -- Question 24
SELECT 
    COUNT(*) AS AllRows,
    COUNT(customerid) - COUNT(*) AS customeridHas_null,
    COUNT(creditscore) - COUNT(*) AS creditscoreHas_null,
    COUNT(tenure) - COUNT(*) AS tenureHas_null,
    COUNT(balance) - COUNT(*) AS balanceHas_null,
    COUNT(numofproducts) - COUNT(*) AS numofproductsHas_null,
    COUNT(hascrcard) - COUNT(*) AS hascrcardHas_null,
    COUNT(isactivemember) - COUNT(*) AS isactivememberHas_null,
    COUNT(exited) - COUNT(*) AS exitedHas_null
FROM 
    Bank_Churn;

SELECT 
    COUNT(*) AS totatRows,
    COUNT(customerid) - COUNT(*) AS nulls_inCustomerid,
    COUNT(surname) - COUNT(*) AS nulls_inSurname,
    COUNT(age) - COUNT(*) AS nulls_inSge,
    COUNT(genderid) - COUNT(*) AS nulls_inGenderid,
    COUNT(estimatedsalary) - COUNT(*) AS nulls_inEstimatedsalary,
    COUNT(geographyid) - COUNT(*) AS nulls_inGeographyid,
    COUNT(BankDOJ) - COUNT(*) AS nulls_inBankDOJ
FROM 
    CustomerInfo;
    -- Question 25
select bank.customerid,cust.SurName, bank.isactivemember
from Bank_Churn bank
join CustomerInfo cust on bank.customerid = cust.customerid
where cust.surname like '%on';