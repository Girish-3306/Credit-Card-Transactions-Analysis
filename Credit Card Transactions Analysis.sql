use namastesql;

Select * from Credit_card_transactions;

Select min(transaction_date) as min_date, max(transaction_date) as max_date -- 2013-10-04 // 2015-05-26
from Credit_card_transactions

Select DISTINCT(card_type) from Credit_card_transactions; --Silver, Signature ,Gold ,Platinum 

Select DISTINCT(exp_type) from Credit_card_transactions; -- Entertainment, Food, Bills, Fuel, Travel, Grocery

Select DISTINCT(city) from Credit_card_transactions;

--1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 
Select * from Credit_card_transactions;


WITH CTEA as(
Select city,SUM(amount) as total_spend
from Credit_card_transactions
group by city)
, CTEB as(
Select SUM(amount) as total_amount 
from Credit_card_transactions)

Select TOP 5 * , ROUND(100* total_spend/total_amount,2) as percentage_cobtribution 
from CTEA A
inner join CTEB B on 1=1
order by total_spend desc

--2- write a query to print highest spend month and amount spent in that month for each card type

Select * from Credit_card_transactions;

WITH CTEC as(
Select card_type ,DATEPART(year, transaction_date) as yr,DATEPART(month, transaction_date) as mnth, SUM(amount) as total_spend
from Credit_card_transactions
group by card_type ,DATEPART(year, transaction_date),DATEPART(month, transaction_date)
)
, CTED as(
Select *,
RANK() over(partition by card_type order by total_spend desc) as rank_yr_mnth
from CTEC)

Select *
from CTED
where rank_yr_mnth = 1

--3- write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)

Select * from Credit_card_transactions;

WITH CTEE as(
Select *,
SUM(amount) over(partition by card_type order by transaction_date,transaction_id) as total_spend
from Credit_card_transactions
)
,CTEF as (
Select *,
RANK() over(partition by card_type order by total_spend ASC) as rnk
from CTEE where total_spend >= 1000000 
) 

Select *
from CTEF
where rnk =1 

--4- write a query to find city which had lowest percentage spend for gold card type  
Select * from Credit_card_transactions;

WITH CTEgold as(
Select city,card_type, SUM(amount) as gold_amount 
from Credit_card_transactions
where card_type = 'Gold'
group by city,card_type)

, CTEamount as (
 Select city, SUM(amount) as total_amount
 from Credit_card_transactions
 group by city)

Select TOP 1 cg.city,cg.card_type, ROUND((gold_amount/total_amount)*100,2) as percentage_spent_on_gold
from CTEgold cg
inner join CTEamount ca on cg.city = ca.city
order by percentage_spent_on_gold ASC
 
-- Ankit Banasal's Solution
with cte as (
select city,card_type,sum(amount) as amount
,sum(case when card_type='Gold' then amount end) as gold_amount
from Credit_card_transactions
group by city,card_type)

select TOP 1 city,sum(amount) total_amount,sum(gold_amount) as gold_amount,sum(gold_amount)*1.0/sum(amount) as gold_ratio
from cte
group by city
having sum(gold_amount) is not null 
order by gold_ratio;


--5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

Select *from Credit_card_transactions;

with CTEAA AS(
Select city,exp_type, SUM(amount) as total_spend
from Credit_card_transactions
group by city, exp_type)

,CTEBB as (
Select *,
rank() over(partition by city order by total_spend desc) rn_desc,
rank() over(partition by city order by total_spend asc) rn_asc
from CTEAA
)

Select city,
max(CASE WHEN rn_desc = 1 then exp_type end) as highest_expense_type,
min(CASE WHEN rn_asc = 1 then exp_type end) as lowest_expense_type
from CTEBB
group by city

--6- write a query to find percentage contribution of spends by females for each expense type
 Select *from Credit_card_transactions;

 WITH CTEfspend as(
 Select exp_type, gender, SUM(amount) as total_amount,
 SUM(CASE WHEN gender= 'F' then amount else 0 END) as female_spend
 from Credit_card_transactions
 group by exp_type, gender
 )

 Select exp_type,SUM(female_spend) as female_spend ,SUM(total_amount) as Total_spend,ROUND(SUM(female_spend)*100/SUM(total_amount),2) as percentage_contribution
 from CTEfspend
 group by exp_type;

 --7- which card and expense type combination saw highest month over month growth percentage in Jan-2014
 Select *from Credit_card_transactions;

 WITH CTE as(
 Select card_type, exp_type, DATEPART(year,transaction_date) as yr, DATEPART(MONTH,transaction_date) as mnth,sum(amount) as total_spend
 from Credit_card_transactions
 group by card_type, exp_type, DATEPART(year,transaction_date),DATEPART(MONTH,transaction_date)
 )
 , CTE_combination as (
 Select *,
 LAG(total_spend) over (partition by card_type,exp_type order by yr,mnth) as previous_mnth_spend
 from CTE
)

Select TOP 1 *, ROUND((total_spend - previous_mnth_spend)/previous_mnth_spend,2) as highest_mnth_growth
from CTE_combination
where yr = 2014 and mnth = 1
order by highest_mnth_growth desc

--8- during weekends which city has highest total spend to total no of transactions ratio 
 Select *from Credit_card_transactions;

Select TOP 1 city, ROUND((SUM(amount)*100/COUNT(*)),2) as ratio --,DATEPART(WEEKDAY,transaction_date) as weekday_number, DATENAME(WEEKDAY,transaction_date) as weekday_name
from Credit_card_transactions
where DATEPART(WEEKDAY,transaction_date) in (1,7) 
group by city
order by ratio;

--9- which city took least number of days to reach its 500th transaction after the first transaction in that city
 Select *from Credit_card_transactions;

 WITH CTE_transaction as (
Select *,
ROW_NUMBER() over (partition by city order by transaction_date,transaction_id) as rnk
from Credit_card_transactions
)

Select TOP 1 city, DATEDIFF(DAY, min(transaction_date) ,MAX(transaction_date)) as date_diff
from CTE_transaction
where rnk = 1 or rnk=500
group by city
having COUNT(1) = 2
order by date_diff ASC


