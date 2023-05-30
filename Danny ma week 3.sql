/*understanding the data gives a better approach to getting great insights
  performing aggregate of another aggregate ussing window functionss
  */


delete from dbo.subscriptions

Select *
from dbo.subscriptions

select *
from plans


 /*1.   How many customers has Foodie-Fi ever had?*/

 select COUNT(distinct customer_id)
 from subscriptions;

 /*2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value*/

 with [distribution] as (select plan_name, DATETRUNC(MONTH,[start_date]) monthly
 from subscriptions s
 left join plans p
 ON p.plan_id = s.plan_id
 where plan_name = 'trial') 

 select plan_name,count(monthly) distri, monthly
 from [distribution]
 group by plan_name,monthly
 order by monthly

 /*3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name*/

 select COUNT(plan_name) count_of_plan_name, plan_name
 from subscriptions s
 join plans p
 on p.plan_id = s.plan_id
 where [start_date] > '2020-12-31'
 group by plan_name;



 /*4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?*/

WITH pt as (select plan_name, sum( count(plan_name)) over(partition by plan_name order by (select null)) [Individual Total],
      sum(count(plan_name)) over(partition by plan_name)*100.0/ 1000 [Customer percentage]
      from subscriptions s
      join plans p
      on p.plan_id = s.plan_id
      group by plan_name
 ) 

select *
from  pt
 where  pt.plan_name = 'churn';
 

 /*5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?*/
 
WITH table_5 as ( select customer_id ,plan_name, LEAD(plan_name) over(order by (select null)) leadin_values,
    case
	when plan_name = 'trial' AND LEAD(plan_name) over(order by (select null)) = 'churn' then 1 end churned
 from subscriptions s
 join plans p
 on p.plan_id = s.plan_id
)

select count(table_5.churned)[No of Churned Customers], count(table_5.churned)*100.0  /SUM(count(distinct table_5.customer_id)) over() total_percentage,
SUM(count(distinct table_5.customer_id)) over() [Total Customers]
from table_5;



/* 6  What is the number and percentage of customer plans after their initial free trial?*/

WITH t6 as (select customer_id ,plan_name, LEAD(plan_name) over(order by (select null)) leadin_values,
    case
	when plan_name = 'trial' AND LEAD(plan_name) over(order by (select null)) <> 'churn' then 1 end customer_plans
 from subscriptions s
 join plans p
 on p.plan_id = s.plan_id)

select count(t6.customer_plans)[No of Customer plans], count(t6.customer_plans)*100.0  /SUM(count(distinct t6.customer_id)) over() total_percentage,
SUM(count(distinct t6.customer_id)) over() [Total Customers]
from t6;


 /*7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?*/

select plan_name, sum( count(plan_name)) over(partition by plan_name order by (select null)) [Individual Total],
      sum(count(plan_name)) over(partition by plan_name)*100.0/ 1000 [Customer percentage]
      from subscriptions s
      join plans p
      on p.plan_id = s.plan_id
	  where s.[start_date] <=  '2020-12-31'
      group by plan_name


/*8.  How many customers have upgraded to an annual plan in 2020?*/
select count(customer_id)
      from subscriptions s
      join plans p
      on p.plan_id = s.plan_id
	  where plan_name = 'pro annual' and [start_date] like '2020%'
	  


/*9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi? */ 

WITH t91 as (select t9.customer_id,
datediff(day,t9.trial_start_date,LEAD(t9.trial_start_date) over(partition by t9.customer_id order by (select null))) [Upgrade Date]
from(select [start_date] as trial_start_date, plan_name,customer_id
from subscriptions s
join plans p
on p.plan_id = s.plan_id
where plan_name in ('trial','pro annual')
) t9)

select AVG(T91.[Upgrade Date]) [Average Updated Date To Annual]
from t91;

/*10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)*/

select AVG(t11.[Upgrade Date]) average_groupings,t11.groupings, SUM(t11.[upgrade Date])
from(select case when t101.[Upgrade Date] between 0 and 30 then '[0-30]'
        when t101.[Upgrade Date] between 31 and 60 then '[31-60]'
		when t101.[Upgrade Date] between 61 and 90 then '[61-90]'
     	when t101.[Upgrade Date] between 91 and 120 then '[91-120]'
		when t101.[Upgrade Date] between 121 and 150 then '[121-150]'
		 when t101.[Upgrade Date] > 150 then '[above 150]' end as groupings,
		 t101.[Upgrade Date]
from(
select t10.customer_id,t10.trial_start_date,t10.plan_name,
datediff(day,t10.trial_start_date,LEAD(t10.trial_start_date) over(partition by t10.customer_id order by (select null))) [Upgrade Date]
from(
select [start_date] as trial_start_date, plan_name,customer_id
from subscriptions s
join plans p
on p.plan_id = s.plan_id
where plan_name in ('trial','pro annual')
)t10)t101
where t101.[Upgrade Date] is not null
group by t101.[Upgrade Date]) t11
group by t11.groupings;



select AVG(t101.[Upgrade Date]) average_groupings,t101.groupings, SUM(t101.[upgrade Date])
from(select
   case when datediff(day,t10.trial_start_date,LEAD(t10.trial_start_date) over(partition by t10.customer_id order by (select null))) between 0 and 30 then '[0-30]'
        when datediff(day,t10.trial_start_date,LEAD(t10.trial_start_date) over(partition by t10.customer_id order by (select null))) between 31 and 60 then '[31-60]'
		when datediff(day,t10.trial_start_date,LEAD(t10.trial_start_date) over(partition by t10.customer_id order by (select null))) between 61 and 90 then '[61-90]'
     	when datediff(day,t10.trial_start_date,LEAD(t10.trial_start_date) over(partition by t10.customer_id order by (select null))) between 91 and 120 then '[91-120]'
		when datediff(day,t10.trial_start_date,LEAD(t10.trial_start_date) over(partition by t10.customer_id order by (select null))) between 121 and 150 then '[121-150]'
		 when datediff(day,t10.trial_start_date,LEAD(t10.trial_start_date) over(partition by t10.customer_id order by (select null))) > 150 then '[above 150]' end as groupings,
		 datediff(day,t10.trial_start_date,LEAD(t10.trial_start_date) over(partition by t10.customer_id order by (select null)))[Upgrade Date]
		
from(
select [start_date] as trial_start_date, plan_name,customer_id
from subscriptions s
join plans p
on p.plan_id = s.plan_id
where plan_name in ('trial','pro annual')
)t10)t101
where t101.[Upgrade Date] is not null
group by t101.groupings;


/*11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?*/ /*No customer downgraded in 2020*/

select *
from
(select customer_id ,plan_name, LEAD(plan_name) over(order by (select null)) leadin_values, [start_date],
    case
	when plan_name = 'pro monthly' AND LEAD(plan_name) over(order by (select null)) = 'basic monthly' then 1 end customer_plans
 from subscriptions s
 join plans p
 on p.plan_id = s.plan_id)t11
 where  plan_name = 'pro monthly' AND leadin_values ='basic monthly' AND t11.[start_date] like '2020%';

