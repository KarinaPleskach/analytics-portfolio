# Retention improvement plan for "IT Resume"

## Project Description

*IT Resume* is a platform for technical interview preparation where users solve coding tasks and tests in Python and SQL. The platform is transitioning to a subscription model, making user retention a key business metric directly impacting revenue.

## Project Objective

Identify growth opportunities for the retention metric and propose product changes that could improve it.

## Data Description

The dataset  is stored in a PostgreSQL DBMS and includes information about users, login activity, tasks, tests, and users’ attempts to solve them. A [link to the full table descriptions](https://github.com/KarinaPleskach/analytics-portfolio/blob/master/product-retention-analysis/dataset-info/data_description.md) is provided.
<br>
*Note: users with ID < 94 and records before 2022 are excluded as test data.*

## Analysis Overview

- [Cohort-based N-day retention by registration month](#Cohort-based-N-day-retention-by-registration-month)

## Cohort-based N-day retention by registration month

First, we need to understand what we are dealing with.

**Hypothesis:**  
Some  cohorts perform better than others. This may be due to the advertising campaigns or platform they came from (active during their registration), which could have attracted a more engaged and relevant target audience.

*Note:*   
> This analysis includes both a long-format table query and a wide-format (pivot) table query.  
> While the long format is more flexible for analysis, the wide format will be used in the following sections because it is easier to read.

<details>
<summary>Queries:</summary>

*Long table:*
```sql
with user_data as (
    select
        u.id as user_id,
        to_char(u.date_joined, 'YYYY-MM') as cohort,
        ue.entry_at::date - u.date_joined::date as next_entry
    from users u
    left join userentry ue
        on u.id = ue.user_id
    where extract(year from u.date_joined) = 2022 and u.id > 93
), cohort_size as (
    select
        cohort,
        count(distinct user_id) as total_users
    from user_data
    group by cohort
)
select
    ud.cohort,
    ud.next_entry,
    round(
        count(distinct ud.user_id) * 100.0 / cs.total_users,
        1
    ) as retention
from user_data ud
join cohort_size cs
    on ud.cohort = cs.cohort
where ud.next_entry in (0,1,3,7,14,30,60,90)
group by ud.cohort, ud.next_entry, cs.total_users
order by ud.cohort, ud.next_entry;
```
*Wide table:*
```sql
with user_data as (
	select
		u.id as user_id,
		to_char(u.date_joined, 'YYYY-MM') as cohort,
		ue.entry_at::date - u.date_joined::date as next_entry
	from users u
	left join userentry ue
	on u.id = ue.user_id
	where extract(year from u.date_joined) = 2022 and u.id > 93
)
select
	cohort,
	round(count(distinct case when next_entry = 0 then user_id end) * 100.0 / count(distinct user_id), 1) as "0",
	round(count(distinct case when next_entry = 1 then user_id end) * 100.0 / count(distinct user_id), 1) as "1",
	round(count(distinct case when next_entry = 3 then user_id end) * 100.0 / count(distinct user_id), 1) as "3",
	round(count(distinct case when next_entry = 7 then user_id end) * 100.0 / count(distinct user_id), 1) as "7",
	round(count(distinct case when next_entry = 14 then user_id end) * 100.0 / count(distinct user_id), 1) as "14",
	round(count(distinct case when next_entry = 30 then user_id end) * 100.0 / count(distinct user_id), 1) as "30",
	round(count(distinct case when next_entry = 60 then user_id end) * 100.0 / count(distinct user_id), 1) as "60",
	round(count(distinct case when next_entry = 90 then user_id end) * 100.0 / count(distinct user_id), 1) as "90"
from user_data
group by cohort
```

</details>

<details>
<summary>Result table:</summary>

![Table picture](https://github.com/KarinaPleskach/analytics-portfolio/tree/master/product-retention-analysis/sql/results/cohort_n_day_retention.jpg)

</details>

**Conclusion:**  
- We see that most users only logged in on their registration day, and even then, not all of them. One possible explanation is that registration can be completed through a remote service without actually visiting the website. Ideally, the percentage of logins on the registration day should be closer to 100%.  
One potential improvement could be to immediately send a simple and engaging question via email after registration. This could encourage users to go to the platform to achieve a “completed” status (a green checkmark), increasing early engagement.

- The percentage of logins drops significantly starting from the second day, which may indicate poor advertising or targeting the wrong audience.  
However, it is also important to evaluate **rolling retention**, since the service does not require daily usage. It would already be a positive outcome if users return a few times per month.

- There are no visible spikes in user activity any particular day, suggesting there is no effective app reminder mechanism, or that it is not working properly. It might be worth experimenting with other formats of reminders.


