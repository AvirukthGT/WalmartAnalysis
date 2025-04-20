select * from walmart;

drop table walmart;

select distinct 
	payment_method,
	count(*)
from walmart
	group by payment_method;


select count(distinct branch) from walmart;

select min(quantity) from walmart;

--Q1: find different payment method and its number of transactions,number of qty sold

select 
	payment_method,
	count(*) as No_of_Transactions,
	SUM(quantity) as Total_Quantity 
from walmart
group by payment_method;

--Q3 IDENTIFYING HIGHEST-RATED CATEGORY IN EACH BRANCH
select * from (
		select branch,category,avg(rating),rank() over(partition by branch order by avg(rating) desc) as rank
		from walmart
		group by 1,2
		order by 1,3 desc
) where rank=1;


--Q3: IDENTIFY THE BUSIEST DAY FOR EACH BRANCH BASED ON NUMBER OF TRANSACTIONS
select * from
	(select 
		branch,
		to_char(to_date(date,'DD/MM/YY'),'day') as day, 
		count(*) as number_of_transactions,
		rank() over(partition by branch order by count(*) desc) as rank
	from walmart
	group by 1,2)
where rank=1;

--Q4 :CALCULATE THE TOTAL QUANTITY OF ITEMS SOLD PER PAYMENT METHOD, LIST PAYMENT METHOD AND TOTAL_QUANTITY

select 
	payment_method,
	SUM(quantity) as Total_Quantity 
from walmart
group by payment_method;

--Q5: DETERMINE THE AVERAGE,MINIMUM,AND MAXIMUM RATING OF EACH FOR EACH CATEGORY PER CITY
-- LIST THE CITY,AVERAGE_RATING,MIN_RATING AND MAX RATING

select 
	city,
	category,
	avg(rating) as average,
	min(rating) as minimum,
	max(rating) as maximum
from walmart
group by city,category
order by 1,2;

--Q6:CALCULATE THE TOTAL PROFIT FOR EACH CATEGORY
--TOTAL PROFIT = (UNIT_PRICE * QUANTIY * PROFIT MARGIN)

SELECT 
	category,
	sum(amount*profit_margin) as total_profit
FROM walmart
group by category;


--Q7 DETERMIINE THE MOST COMMON PAYMENT METHOD FOR EACH BRANCH
--DISPLAY BRANCH AND PREFERRED PAYMENT METHOD
with cte
as
	(
	select 
		branch,
		payment_method,
		count(*) as total_trans,
		rank() over(partition by branch order by count(*) desc) as rank
	from walmart
	group by 1,2
	)
select * from cte where rank=1;

--Q8 CATEGORIZE SALES INTO 3 GROUPS MORNING,EVENING AND AFTERNOON
--FIND NUMBER OF INVOICES PER GROUP

select
		branch,
		case 
			when extract (hour from (time::time))<12 then 'Morning'
			when  extract (hour from (time::time)) between 12 and 17 then 'Afternoon'
			else 'Evening'
		END day_time,
		count(*)
from walmart
group by 1,2
order by 1,3 desc;

--Q9 IDENTIFY 5 BRANCHES WITH HIGHEST PERCENTAGE DECREASE  IN REVENUE COMPARED TO LAST YEAR
select *,
	Extract(year from to_date(date,'DD/MM/YY')) as formatted_date	         
from walmart

with revenue_2022 as 
(
SELECT 
	branch,
	SUM(amount) as revenue
from walmart
where Extract(year from to_date(date,'DD/MM/YY'))=2022
group by 1
),
revenue_2023 as 
(
SELECT 
	branch,
	SUM(amount) as revenue
from walmart
where Extract(year from to_date(date,'DD/MM/YY'))=2023
group by 1

) select 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as current_year_revenue,
	round(((ls.revenue-cs.revenue)::numeric/ls.revenue::numeric)*100,2) as percentage_decrease
from revenue_2022 ls
join 
revenue_2023 as cs
on ls.branch=cs.branch
where ls.revenue>cs.revenue
order by 4 desc limit 5



