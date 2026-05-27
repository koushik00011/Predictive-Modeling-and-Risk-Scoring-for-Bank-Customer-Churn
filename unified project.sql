create database unified_da
use unified_da
select top 10 * from cleaned_data

--overall churn percentage--
SELECT exited,
ROUND(count(*)*100.0/sum(count(*)) over(),2) As churn_percent
FROM cleaned_data
GROUP BY exited

--churn % for different customer groups.--
SELECT geography,
ROUND(100.0*sum(exited)/count(*),2)As churn_percent
FROM cleaned_data
GROUP BY geography ORDER BY ROUND(100.0*sum(exited)/count(*),2) DESC

--creating view for churn_percent--
CREATE VIEW churn_percent as
SELECT
ROUND(100.0*sum(exited)/count(*),2) AS churn_rate FROM cleaned_data;

--activity churn %--
SELECT is_active_member,ROUND(100.0*sum(exited)/count(*),2)As churn_percent
FROM cleaned_data GROUP BY is_active_member

--number of products vs churn--
SELECT num_of_products,
ROUND(100.0*sum(exited)/count(*),2) AS churn_rate
from cleaned_data group by num_of_products order by churn_rate desc

--churn rate for age group--
with cte as(select 
CASE WHEN age<=30 then 'Young'
	 when age>30 and age<=50 then 'Middle'
	 else 'Senior' end as age_group,exited from cleaned_data)

select age_group,
ROUND(100.0*sum(exited)/count(*),2) AS churn_rate
from cte group by age_group;

--identify whether high-value customers are leaving.--
WITH cte as(
SELECT
CASE WHEN balance<=50000 then 'Low_balance'
	 when balance>50000 and balance<=150000 then 'Medium_balance'
	 else 'High_balance' end as balance_group,
exited
FROM cleaned_data)


SELECT balance_group,
ROUND(100.0*sum(exited)/count(*),2) as churn_rate
FROM cte group by balance_group order by churn_rate desc;
--(Higher-balance customers churn noticeably more than low-balance customers.)

--age + active status - churn rate
with cte as(select 
CASE WHEN age<=30 then 'Young'
	 when age>30 and age<=50 then 'Middle'
	 else 'Senior' end as age_group,exited,is_active_member from cleaned_data)

select  age_group,is_active_member,
ROUND(100.0*sum(exited)/count(*),2) as churn_rate
from cte group by age_group,is_active_member order by churn_rate desc;

--Geography + Activity Status - churn rate
select  geography,is_active_member,
ROUND(100.0*sum(exited)/count(*),2) as churn_rate
from cleaned_data group by geography,is_active_member order by churn_rate desc;

--Balance Group + Activity Status - churn rate
WITH cte as(
SELECT
CASE WHEN balance<=50000 then 'Low_balance'
	 when balance>50000 and balance<=150000 then 'Medium_balance'
	 else 'High_balance' end as balance_group,
exited,is_active_member
FROM cleaned_data)
select balance_group, is_active_member,
ROUND(100.0*sum(exited)/count(*),2) as churn_rate
from cte group by balance_group,is_active_member order by churn_rate desc;

--Age Group + Number of Products - churn rate
with cte as(select 
CASE WHEN age<=30 then 'Young'
	 when age>30 and age<=50 then 'Middle'
	 else 'Senior' end as age_group,exited,num_of_products from cleaned_data)
select age_group,num_of_products, COUNT(*) AS total_customers,
ROUND(100.0*sum(exited)/count(*),2) as churn_rate
from cte group by age_group,num_of_products order by churn_rate desc
--/(Customers holding four products demonstrated exceptionally high churn behavior across all age groups. This may indicate customer 
--dissatisfaction despite deeper product adoption or potential data-specific behavioral anomalies requiring further investigation.)/--