-- show the complete walmart table data
select * from walmart order by city;

-- Q1. different payment method used and count of transaction by each payment method
select
payment_method,
count(*) as transaction_count
from walmart
group by payment_method;

-- Q2. Highest Average rating in each branch
with branch_rating as
(
select
branch,
category,
avg(rating) as avg_rating
from walmart
group by branch,category 
), ranked_rating as
(
select 
branch,
category,
avg_rating,
rank() over(partition by branch order by avg_rating desc) as rank_rating
from branch_rating
)
select
branch,
category
from ranked_rating
where rank_rating=1;

-- Q3. busiest day of the week for each branch based on the transaction volume.
select
branch,
day_name
from
(
select
branch,
dayname(str_to_date(date,'%d/%m/%y')) as day_name,
count(*) as transactions,
rank() over(partition by branch order by count(*) desc) as ranked
from walmart
group by branch,day_name
) A
where ranked=1;

-- Q4. Total Quantity sold through each payment method.
select
payment_method,
sum(quantity) as total_quantity_sold
from walmart
group by payment_method
order by total_quantity_sold desc;

-- Q5. Average, minimum and maximum ratings for each category in each city
select
city,
category,
avg(rating) as avg_rating,
min(rating) as min_rating,
max(rating) as max_rating
from walmart
group by city,category
order by city;

-- Q6. total profit for each category ranked highest to lowest
select
category,
cast(sum(profit_margin) as decimal(20,2)) as total_profit
from walmart
group by category
order by total_profit desc;

-- Q7. Most frequently used payment method in each branch
select
branch,
payment_method
from (
select 
branch,
payment_method,
count(*) as frequency,
rank() over(partition by branch order by count(*) desc) as ranking
from walmart
group by branch,payment_method
) A
where ranking=1;

-- Q8. Transactions occur in each shift(Morning, Afternoon, Evening) 
with time_table as
(
select
branch,
time,
case
when hour(time)<10 then 'Morning Shift'
when hour(time)<18 then 'Afternoon Shift'
else 'Evening Shift'
end as Shift
from walmart 
)
select
branch,
shift,
count(*) as transactions
from time_table
group by branch,shift
order by branch;

-- Q9. Branches experienced the largest decrease in revenue compared to last year
with revenue_year_wise as
(
select 
branch,
year(date) as year_,
sum(Total) as revenue
from walmart
group by branch,year_
order by branch,year_
), revenue_last_year as
(
select 
branch,
year_,
revenue,
lag(revenue,1) over(partition by branch order by year_) as revenue_last_year
from revenue_year_wise
), max_decline as 
(
select
branch,
year_,
revenue,
revenue_last_year,
rank() over(partition by branch order by (revenue_last_year-revenue) desc) as ranking
from revenue_last_year
)
select
branch,
year_,
revenue,
revenue_last_year
from max_decline
where ranking=1;

-- Q10. City wise poorest average rating of category
select 
city,
category
from
(
select
city,
category,
avg(rating),
rank() over(partition by city order by avg(rating)) as ranking
from walmart
group by city,category
) A
where ranking=1;







