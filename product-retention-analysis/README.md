# Retention improvement plan for "IT Resume"

## Project Description

*IT Resume* is a platform for technical interview preparation where users solve coding tasks and tests in Python and SQL. The platform is transitioning to a subscription model, making user retention a key business metric directly impacting revenue.

## Project Objective

Identify growth opportunities for the retention metric and propose product changes that could improve it.

## Data Description

The dataset  is stored in a PostgreSQL DBMS and includes information about users, login activity, tasks, tests, and users’ attempts to solve them. A [link to the full table descriptions](https://github.com/KarinaPleskach/analytics-portfolio/blob/master/product-retention-analysis/dataset-info/data_description.md) is provided.
<br>
> *Note: users with ID < 94 and records before 2022 are excluded as test data.*

## Dashboard

As a result of the analysis, a dashboard was developed to monitor changes in user retention metrics. [Dashboard link](https://metabase.simulative.ru/public/dashboard/83e03191-6702-44a5-af91-353e479a2750?cohort=&company_name=&day_of_entry=&month_of_entry=0&month_of_entry=1&month_of_entry=2)

![Dashboard picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/metabase/visualizations/dashboard.png)

## Analysis Overview

- [Cohort-based N-day retention](#Cohort-based-N-day-retention)
- [Cohort-based N-month retention](#Cohort-based-N-month-retention)
- [Cohort-based Rolling retention](#Cohort-based-Rolling-retention)
- [Retention of non-company students](#Retention-of-non-company-students)
- [MAU for each month](#MAU_for_each_month)
- [Stickiness factor](#Stickiness-factor)
- [Referral users](#Referral-users)
- [Day 1 return users](#Day-1-return-users)
- [Zero solved](#Zero-solved)
- [Completing first task](#Completing-first-task)
- [Too hard last tasks](#Too-hard-last-tasks)
- [Number of tasks](#Number-of-tasks)
- [Complexity vs engagement](#Complexity-vs-engagement)

## 🟦 Cohort-based N-day retention

First, we need to understand what we are dealing with.

**Hypothesis:**  
Some  cohorts perform better than others. This may be due to the advertising campaigns or platform they came from (active during their registration), which could have attracted a more engaged and relevant target audience.

<details>
<summary>Queries:</summary>

> *Note:*  
This analysis includes both a long-format table query and a wide-format (pivot) table query.  
> While the long format is more flexible for analysis, the wide format will be used in the following sections because it is easier to read.

> Also, Metabase queries differ slightly, so they are included in this section for each metric with a visualization.

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

*Query for Visualization:*
```sql
with user_data as (
	select
		users.id as user_id,
		to_char(users.date_joined, 'YYYY-MM') as cohort,
		ue.entry_at::date - users.date_joined::date as next_entry
	from users
	left join userentry ue
	on users.id = ue.user_id
	where users.id > 93 
	    and extract(year from users.date_joined) = 2022
	    [[and to_char(users.date_joined, 'YYYY-MM') in ({{cohort}})]]
), registrations as (
	select cohort, count(distinct user_id) as cnt
	from user_data
	group by cohort
)
select u.cohort, u.next_entry, count(distinct u.user_id) * 100.0 / max(cnt) as percent
from user_data u
join registrations r
on u.cohort = r.cohort
where u.next_entry is not null 
    [[and u.next_entry in ({{day_of_entry}})]] 
    [[and ceil(u.next_entry/30.0) in ({{month_of_entry}})]]
group by u.cohort, u.next_entry
```

</details>

<details>
<summary>Result table:</summary>

![Table picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/sql/results/cohort_n_day_retention.jpg)

</details>

Visualization:

![Visualization picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/metabase/visualizations/cohort_n_day_retention.jpg)

**Conclusion:**  
- We see that most users only logged in on their registration day, and even then, not all of them. One possible explanation is that registration can be completed through a remote service without actually visiting the website. Ideally, the percentage of logins on the registration day should be closer to 100%.  
One potential improvement could be to immediately **send a simple question via email after registration**. This could encourage users to go to the platform to achieve a “completed” status (a green checkmark), increasing early engagement.

- The percentage of logins drops significantly starting from the second day, which may indicate poor advertising or targeting the wrong audience.  
However, it is also important to evaluate **rolling retention**, since the service does not require daily usage. It would already be a positive outcome if users return a few times per month.

- There are no visible spikes in user activity any particular day, suggesting there is no effective **app reminder mechanism**, or that it is not working properly. It might be worth experimenting with other formats of reminders.


## 🟦 Cohort-based N-month retention

**Hypothesis:**  
Since we have a monthly subscription model, it is most important for us that users see the value in visiting the platform at least once a month.

<details>
<summary>Queries:</summary>

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
	round(count(distinct case when next_entry = 0 then user_id end) * 100.0
		/ count(distinct user_id), 2) as "0 day",
	round(count(distinct case when next_entry between 1 and 30 then user_id end) * 100.0
		/ count(distinct user_id), 2) as "1 month",
	round(count(distinct case when next_entry between 31 and 60 then user_id end) * 100.0
		/ count(distinct user_id), 2) as "2 month",
	round(count(distinct case when next_entry between 61 and 90 then user_id end) * 100.0
		/ count(distinct user_id), 2) as "3 month"
from user_data
group by cohort
```

*Query for Visualization:*
```sql
with user_data as (
	select
		users.id as user_id,
		to_char(users.date_joined, 'YYYY-MM') as cohort,
		ue.entry_at::date - users.date_joined::date as next_entry,
		ceil((ue.entry_at::date - users.date_joined::date)/30.0) as month
	from users
	left join userentry ue
	on users.id = ue.user_id
	where users.id > 93
	    and extract(year from users.date_joined) = 2022
	    [[and to_char(users.date_joined, 'YYYY-MM') in ({{cohort}})]]
), registrations as (
	select cohort, count(distinct user_id) as cnt
	from user_data
	group by cohort
)
select 
	u.cohort,
	u.month,
	count(distinct u.user_id) * 100.0 / max(cnt) as percent
from user_data u
join registrations r
on u.cohort = r.cohort
where u.next_entry is not null 
    [[and u.month in ({{month_of_entry}})]] 
    [[and u.next_entry in ({{day_of_entry}})]] 
group by 1, 2
```

</details>

<details>
<summary>Result table:</summary>

![Table picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/sql/results/cohort_n_month_retention.jpg)

</details>

Visualization:

![Visualization picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/metabase/visualizations/cohort_n_month_retention.jpg)

**Conclusion:**  
- The numbers have increased slightly, but not significantly. However, it is more noticeable here that **cohort 4 performed best**, while cohort 2 showed the weakest results. It would be useful to **review the advertising campaigns** or service updates corresponding to these periods.
- **Less than 8%** of registered users see the value in using the service for at least two months.

## 🟦 Cohort-based Rolling retention

**Hypothesis:**  
Most users log in only once.

<details>
<summary>Queries:</summary>

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
	round(count(distinct case when next_entry >= 0 then user_id end) * 100.0 / count(distinct user_id), 2) as "0",
	round(count(distinct case when next_entry >= 1 then user_id end) * 100.0 / count(distinct user_id), 2) as "1",
	round(count(distinct case when next_entry >= 3 then user_id end) * 100.0 / count(distinct user_id), 2) as "3",
	round(count(distinct case when next_entry >= 7 then user_id end) * 100.0 / count(distinct user_id), 2) as "7",
	round(count(distinct case when next_entry >= 14 then user_id end) * 100.0 / count(distinct user_id), 2) as "14",
	round(count(distinct case when next_entry >= 30 then user_id end) * 100.0 / count(distinct user_id), 2) as "30",
	round(count(distinct case when next_entry >= 60 then user_id end) * 100.0 / count(distinct user_id), 2) as "60",
	round(count(distinct case when next_entry >= 90 then user_id end) * 100.0 / count(distinct user_id), 2) as "90"
from user_data
group by cohort
```

*Query for Visualization:*
```sql
with user_data as (
	select
		users.id as user_id,
		to_char(users.date_joined, 'YYYY-MM') as cohort,
		ue.entry_at::date - users.date_joined::date as next_entry
	from users
	left join userentry ue on users.id = ue.user_id
	where users.id > 93
	    and extract(year from users.date_joined) = 2022
	    [[and to_char(users.date_joined, 'YYYY-MM') in ({{cohort}})]]
), registrations as (
	select cohort, count(distinct user_id) as cnt
	from user_data
	group by cohort
), last_entries as (
	select 
		user_id, 
		cohort,
		max(next_entry) as last_day
	from user_data
	where next_entry is not null
	group by 1, 2
), generation_days as (
	select generate_series(0, 135) as day
), active_users as (
	select 
		user_id,
		cohort,
		last_day,
		day
	from last_entries
	join generation_days
	on last_day >= day
)
select 
	a.cohort,
	a.day,
	count(*) * 100.0 / max(r.cnt) as percentage
from active_users a
join registrations r
on a.cohort = r.cohort
where true 
    [[and a.day in ({{day_of_entry}})]] 
    [[and ceil(a.day/30.0) in ({{month_of_entry}})]]
group by a.cohort, a.day
order by 1, 2
```

</details>

<details>
<summary>Result table:</summary>

![Table picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/sql/results/cohort_rolling_retention.jpg)

</details>

Visualization:

![Visualization picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/metabase/visualizations/cohort_rolling_retention.jpg)

**Conclusion:**  
- **More than half** of the users **drop off** immediately. It would be helpful to compare these figures with similar platforms. Additionally, analyzing user actions and identifying the exact points where they leave could provide valuable insights.
- Again, a higher percentage of users churned in the second cohort, which might be **related to an unpopular update**.
- However, we observe that rolling retention after one and two weeks shows a significant number of users still **remain active** compared to n-day retention. This indicates that **there is a segment of users genuinely interested** in our product.

## 🟦 Retention of non-company students

**Hypothesis:**  
It is possible that users who are not company students (who are presumably required to use the product) engage with the app even less.

<details>
<summary>Queries:</summary>

*(Let's immediately review all three previous metrics; they will be similar to the previous ones, with only an added predicate in the subquery.)*
```sql
with user_data as (
	select
		u.id as user_id,
		to_char(u.date_joined, 'YYYY-MM') as cohort,
		ue.entry_at::date - u.date_joined::date as next_entry
	from users u
	left join userentry ue
	on u.id = ue.user_id
	where extract(year from u.date_joined) = 2022 and u.id > 93 and u.company_id is null
)
```

</details>

<details>
<summary>Result table:</summary>

*n-day:*  
![Table picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/sql/results/non_student_cohort_n_day_retention.jpg)

*n-month:*  
![Table picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/sql/results/non_student_cohort_n_month_retention.jpg)

*rolling:*  
![Table picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/sql/results/non_student_cohort_rolling_retention.jpg)

</details>

Visualization:

![Visualization picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/metabase/visualizations/non_student_cohort_n_day_retention.jpg)

**Conclusion:**  
**No** significant **difference** was found between non-students and the overall data.

## 🟦 MAU for each month

**Hypothesis:**  
There might be seasonality. Perhaps users who registered during certain seasons use the platform more frequently?

<details>
<summary>Queries:</summary>

```sql
select
	to_char(ue.entry_at, 'YYYY-MM') as month,
	count(distinct ue.user_id) as unique_users
from userentry ue
where extract(year from ue.entry_at) >= 2022 and ue.user_id > 93
group by 1
order by 1
```

*Query for Visualization:*
```sql
with user_data as (
	select
		users.id as user_id,
		to_char(users.date_joined, 'YYYY-MM') as cohort,
		entry_at
	from users
	join userentry ue
	on users.id = ue.user_id
	left join company
	on users.company_id = company.id
	where users.id > 93 
	    and extract(year from ue.entry_at) >= 2022
	    [[and to_char(users.date_joined, 'YYYY-MM') in ({{cohort}})]]
	    and {{company.name}}
)
select
	to_char(entry_at, 'YYYY-MM') as month,
	count(distinct user_id) as unique_users
from user_data
group by 1
order by 1
```

</details>

<details>
<summary>Result table:</summary>

![Table picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/sql/results/MAU.jpg)

</details>

Visualization:

![Visualization picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/metabase/visualizations/mau.jpg)

![Visualization picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/metabase/visualizations/mau_trend.jpg)

**Conclusion:**  
The **peak** of activity occurs in **February**. Possibly, after the New Year holidays, people gradually get back into their routines. Interestingly, users who registered in February **performed the worst**. This may indicate that their initial motivation was fleeting.

## 🟦 Stickiness factor

**Hypothesis:**  
Since there is about a fourfold difference between 7-day retention and 7-day rolling retention, it would be interesting to examine the stickiness factor (SF). It’s possible that while the number of returning users is small, those who do return visit the platform every day. Additionally, this could be a useful metric to monitor regularly on the dashboard.

<details>
<summary>Queries:</summary>

```sql
with maus as (
	select
		count(distinct ue.user_id) as mau
	from userentry ue
	where extract(year from ue.entry_at) >= 2022 and ue.user_id > 93
	group by to_char(ue.entry_at, 'YYYY-WW')
), daus as (
	select
		count(distinct ue.user_id) as dau
	from userentry ue
	where extract(year from ue.entry_at) >= 2022 and ue.user_id > 93
	group by to_char(ue.entry_at, 'YYYY-DDD')
)
select avg(dau) * 100.0 / avg(mau) as sf
from daus, maus
```

*Query for Visualization:*
```sql
with maus as (
	select
		count(distinct userentry.user_id) as mau
	from userentry
	join users
	on users.id = userentry.user_id
	left join company
	on users.company_id = company.id
	where userentry.user_id > 93
	    and extract(year from userentry.entry_at) >= 2022
	    [[and to_char(users.date_joined, 'YYYY-MM') in ({{cohort}})]]
	    and {{company.name}}
	group by to_char(userentry.entry_at, 'YYYY-WW')
), daus as (
	select
		count(distinct userentry.user_id) as dau
	from userentry
	join users
	on users.id = userentry.user_id
	left join company
	on users.company_id = company.id
	where userentry.user_id > 93
	    and extract(year from userentry.entry_at) >= 2022
	    [[and to_char(users.date_joined, 'YYYY-MM') in ({{cohort}})]]
	    and {{company.name}}
	group by to_char(userentry.entry_at, 'YYYY-DDD')
)
select avg(dau) / avg(mau) as sf
from daus, maus
```

</details>

<details>
<summary>Result table:</summary>

![Table picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/sql/results/SF.jpg)

</details>

Visualization:

![Visualization picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/metabase/visualizations/sf.jpg)

**Conclusion:**  
- Although the n-day retention was **low**, it is possible that the users who did log in were **highly active**. Therefore, **23% is a very good** figure, considering that more than half of the users drop off immediately.
- We can estimate the average **number of times** each **user logs into** the app **per month** as follows: `0.234 * 30 = 7`.

## 🟦 Referral users

**Hypothesis:**  
Maybe users invited by friends stay engaged with the product longer because they feel motivated to compete with their friends. In that case, creating a cool referral incentive could be a great way to attract more users.

<details>
<summary>Queries:</summary>

*(Only the subquery changes)*
```sql
with user_data as (
	select
		u.id as user_id,
		to_char(u.date_joined, 'YYYY-MM') as cohort,
		ue.entry_at::date - u.date_joined::date as next_entry
	from users u
	left join userentry ue
	on u.id = ue.user_id
	where extract(year from u.date_joined) = 2022 and u.id > 93 and u.referal_user is not null
)
```

</details>

<details>
<summary>Result table:</summary>

![Table picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/sql/results/referral_users.jpg)

</details>

Visualization:

![Visualization picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/metabase/visualizations/referral_users.jpg)

**Conclusion:**  
The hypothesis turned out to be the **opposite**. Referred users stopped logging in by the 10th day. Therefore, there is **no reason to invest** in incentives for users who bring in friends.

## 🟦 Day 1 return users

**Hypothesis:**  
Users who log in for the first time on the day after registration tend to use the app more actively.

<details>
<summary>Queries:</summary>

```sql
with user_data as (
	select
		u.id as user_id,
		count(case when ue.entry_at::date - u.date_joined::date = 1 then 1 end) 
over(partition by u.id) as is_entered_at_first_day,
		to_char(u.date_joined, 'YYYY-MM') as cohort,
		ue.entry_at::date - u.date_joined::date as next_entry
	from users u
	left join userentry ue
	on u.id = ue.user_id
	where extract(year from u.date_joined) = 2022 and u.id > 93
)
select
	cohort,
	is_entered_at_first_day,
	round(count(distinct case when next_entry = 0 then user_id end) * 100.0 / count(distinct user_id), 2) as "0",
	round(count(distinct case when next_entry = 1 then user_id end) * 100.0 / count(distinct user_id), 2) as "1",
	round(count(distinct case when next_entry = 3 then user_id end) * 100.0 / count(distinct user_id), 2) as "3",
	round(count(distinct case when next_entry = 7 then user_id end) * 100.0 / count(distinct user_id), 2) as "7",
	round(count(distinct case when next_entry = 14 then user_id end) * 100.0 / count(distinct user_id), 2) as "14",
	round(count(distinct case when next_entry = 30 then user_id end) * 100.0 / count(distinct user_id), 2) as "30",
	round(count(distinct case when next_entry = 60 then user_id end) * 100.0 / count(distinct user_id), 2) as "60",
	round(count(distinct case when next_entry = 90 then user_id end) * 100.0 / count(distinct user_id), 2) as "90"
from user_data
group by cohort, is_entered_at_first_day
```

</details>

<details>
<summary>Result table:</summary>

![Table picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/sql/results/first_day_entrance.jpg)

</details>

**Conclusion:**  
- The hypothesis was **confirmed**. It is crucial to engage users on their very first day by all possible means. The same applies to engaging users on the registration day, as data shows that most of these users logged in on that day.
- However, the number of users who remain active for more than a month is still very **low for a subscription-based model**.

## 🟦 Zero solved

**Hypothesis:**  
What percentage of users have never attempted to solve a single problem or test? A high number could indicate a lack of understanding of how the platform works. Since they registered, they presumably had the initial intention to solve tasks. If this is the case, improving the onboarding process is necessary.

<details>
<summary>Queries:</summary>

```sql
with tries as (
	select user_id
	from codesubmit
	union
	select user_id
	from coderun
	union
	select user_id
	from testresult
	where answer_id is not null
)
select
	round(count(t.user_id) * 100.0 / count(u.id), 2) as tried_percentage
from users u
left join tries t
on u.id = t.user_id
where extract(year from u.date_joined) = 2022 and u.id > 93
```

*Query for Visualization:*
```sql
with tries as (
	select user_id
	from codesubmit
	union
	select user_id
	from coderun
	union
	select user_id
	from testresult
	where answer_id is not null
)
select
	round(count(t.user_id) * 100.0 / count(users.id), 2) as tried_percentage
from users
left join tries t
on users.id = t.user_id
left join company
on users.company_id = company.id
where extract(year from users.date_joined) = 2022 
    and users.id > 93
    [[and to_char(users.date_joined, 'YYYY-MM') in ({{cohort}})]]
	and {{company.name}}
```

</details>

<details>
<summary>Result table:</summary>

![Table picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/sql/results/zero_solved.jpg)

</details>

Visualization:

![Visualization picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/metabase/visualizations/zero_solved.jpg)

**Conclusion:**  
Almost half of the users (around **46%**) have **never attempted to solve** anything. *(For tests, we looked specifically at users who answered at least one question, regardless of whether the answer was correct.)* If this is the platform’s main functionality, it is quite surprising that so many users initially showed interest by registering but never tried it. This could be due to **unclear UI**, the absence of immediate **prompts to solve** something, or the initial tasks seeming **too difficult**, causing users to abandon the platform.

## 🟦 Completing first task

**Hypothesis:**  
If a user manages to solve their first task, they tend to stay on the platform longer. Conversely, if the first task attempted is too difficult or unsolvable for the user, they often stop logging in.

<details>
<summary>Queries:</summary>

```sql
with attempts as (
	select user_id, created_at, problem_id, is_false
	from codesubmit
	union
	select user_id, created_at, problem_id, 0
	from coderun
), first_year_attempts as (
	select
		*,
		min(extract(year from created_at)) over(partition by user_id) as first_year,
		first_value(problem_id) over(partition by user_id order by created_at) as first_task,
		max(is_false) over(partition by user_id, problem_id) as is_solved
	from attempts
	where user_id > 93
), first_task_attempts as (
	select distinct user_id, is_solved
	from first_year_attempts
	where first_year >= 2022 and problem_id = first_task
), user_data as (
	select
		f.user_id,
		f.is_solved,
		to_char(u.date_joined, 'YYYY-MM') as cohort,
		ue.entry_at::date - u.date_joined::date as next_entry
	from first_task_attempts f
	join users u
	on u.id = f.user_id
	left join userentry ue
	on u.id = ue.user_id
	where extract(year from u.date_joined) = 2022
)
select
	cohort,
	is_solved,
	round(count(distinct case when next_entry = 0 then user_id end) * 100.0 / count(distinct user_id), 2) as "0",
	round(count(distinct case when next_entry = 1 then user_id end) * 100.0 / count(distinct user_id), 2) as "1",
	round(count(distinct case when next_entry = 3 then user_id end) * 100.0 / count(distinct user_id), 2) as "3",
	round(count(distinct case when next_entry = 7 then user_id end) * 100.0 / count(distinct user_id), 2) as "7",
	round(count(distinct case when next_entry = 14 then user_id end) * 100.0 / count(distinct user_id), 2) as "14",
	round(count(distinct case when next_entry = 30 then user_id end) * 100.0 / count(distinct user_id), 2) as "30",
	round(count(distinct case when next_entry = 60 then user_id end) * 100.0 / count(distinct user_id), 2) as "60",
	round(count(distinct case when next_entry = 90 then user_id end) * 100.0 / count(distinct user_id), 2) as "90"
from user_data
group by cohort, is_solved
```

</details>

<details>
<summary>Result table:</summary>

![Table picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/sql/results/first_task.jpg)

</details>

**Conclusion:**  
Users who successfully complete their first task show **higher retention** across all cohorts. This suggests that the first successful interaction with the product plays a critical role in user engagement. However, this relationship **is not causal** and may be driven by the fact that more skilled or motivated users are both more likely to solve the task and to return.

## 🟦 Too hard last tasks

**Hypothesis:**  
The user’s most recent attempts at solving tasks were unsuccessful. Let’s analyze the number of consecutive unsolved recent tasks and tests *(considering tests where zero questions were answered correctly)*.

<details>
<summary>Queries:</summary>

```sql
with attempts as (
	select user_id, created_at, 'p' || problem_id as task_id, is_false
	from codesubmit
	where extract(year from created_at) >= 2022 and user_id > 93
	union
	select user_id, created_at, 'p' || problem_id, 0
	from coderun
	where extract(year from created_at) >= 2022 and user_id > 93
	union
	select r.user_id, max(r.created_at), 't' || r.test_id, case when bool_or(a.is_correct) then 1 else 0 end
	from testresult r
	left join testanswer a
	on r.answer_id = a.id
	where extract(year from created_at) >= 2022 and user_id > 93
	group by to_char(r.created_at, 'YYYY-MM-DD'), r.test_id, r.user_id
), tasks_data as (
	select
		user_id,
		max(created_at) as created_at,
		task_id,
		max(is_false) as is_solved,
		sum(max(is_false)) over(partition by user_id order by max(created_at) desc)
	from attempts
	group by user_id, to_char(created_at, 'YYYY-MM-DD'), task_id
	order by 1, 2 desc
), counts as (
	select user_id, count(case when sum = 0 then 1 end) as unsolved_tasks
	from tasks_data
	group by user_id
	order by 1
)
select unsolved_tasks, count(user_id)
from counts
group by unsolved_tasks
```

</details>

<details>
<summary>Result table:</summary>

![Table picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/sql/results/hard_tasks.jpg)

</details>

Visualization:

![Visualization picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/metabase/visualizations/hard_tasks.jpg)

**Conclusion:**  
The hypothesis was **not confirmed**. The majority of users had their **last task solved** correctly.

## 🟦 Number of tasks

**Hypothesis:**  
We might have too few tasks available to solve, especially considering that not all tasks are equally appealing—some users prefer to skip certain problems right away. Additionally, some users want to focus exclusively on SQL or Python tasks, or only on tests.

<details>
<summary>Queries:</summary>

```sql
with num_of_problems as (
	select l.name, count(p.id) as problems
	from problem p
	join languagetoproblem lp
	on lp.pr_id = p.id
	join language l
	on l.id = lp.lang_id
	group by l.name
), num_of_tests as (
	select case when name ilike '%sql%' then 'SQL' else 'Python' end as name, count(*) as tests
	from test
	group by 1
), used_problems as (
	select user_id, problem_id, l.name
	from coderun c
	join languagetoproblem lp
	on lp.pr_id = c.problem_id
	join language l
	on l.id = lp.lang_id
	union
	select user_id, problem_id, l.name
	from codesubmit c
	join languagetoproblem lp
	on lp.pr_id = c.problem_id
	join language l
	on l.id = lp.lang_id
), user_problems as (
	select
		user_id,
		name,
		count(problem_id) as cnt,
		max(count(problem_id)) over(partition by name) as max_problems,
		round(avg(count(problem_id)) over(partition by name)) as avg_problems
	from used_problems
	where user_id > 93
	group by user_id, name
), used_tests as (
	select distinct ts.user_id, ts.test_id, case when t.name ilike '%sql%' then 'SQL' else 'Python' end as name
	from teststart ts
	join test t
	on t.id = ts.test_id
), user_tests as (
	select user_id, name, count(test_id) as cnt,
		max(count(test_id)) over(partition by name) as max_tests,
		round(avg(count(test_id)) over(partition by name)) as avg_tests
	from used_tests
	where user_id > 93
	group by user_id, name
)
select np.name, max(problems) as problems, max(tests) as tests,
	max(up.max_problems) as max_problems, max(up.avg_problems) as avg_problems,
	max(ut.max_tests) as max_tests, max(ut.avg_tests) as avg_tests
from num_of_problems np
join num_of_tests nt
on np.name = nt.name
join user_problems up
on np.name = up.name
join user_tests ut
on np.name = ut.name
group by np.name
```

</details>

<details>
<summary>Result table:</summary>

![Table picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/sql/results/number_of_tasks.jpg)

</details>

Visualization:

![Visualization picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/metabase/visualizations/number_of_tasks.jpg)

**Conclusion:**  
Although some users have come close to completing nearly all the platform’s content, the average metrics remain low, so the hypothesis was **not confirmed**.

## 🟦 Complexity vs engagement

**Hypothesis:**  
The target audience should be focused on less experienced specialists. Let’s compare the relationship between the number of tasks solved and their average difficulty. *(Solutions can be either correct or incorrect)*

<details>
<summary>Queries:</summary>

```sql
with user_data as (
	select c.user_id, c.problem_id, p.complexity
	from coderun c
	join problem p
	on c.problem_id = p.id
	where c.user_id > 93 and extract(year from c.created_at) >= 2022
	union
	select c.user_id, c.problem_id, p.complexity
	from codesubmit c
	join problem p
	on c.problem_id = p.id
	where c.user_id > 93 and extract(year from c.created_at) >= 2022
), aggr_user_data as (
	select
		user_id,
		count(problem_id) as number_of_tried_tasks,
		round(avg(complexity), 2) as average_complexity
	from user_data
	group by user_id
	order by user_id
)
select corr(number_of_tried_tasks, average_complexity)
from aggr_user_data
```

</details>

<details>
<summary>Result table:</summary>

![Table picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/sql/results/complexity.jpg)

</details>

Visualization:

![Visualization picture](https://github.com/KarinaPleskach/analytics-portfolio/raw/master/product-retention-analysis/metabase/visualizations/corr.jpg)

**Conclusion:**  
The hypothesis was not confirmed; there is no correlation between the number of attempted tasks and their average difficulty. However, the chart shows that the **higher the complexity** of the tasks users solve, the fewer tasks they complete, and consequently, the **lower their engagement**.

## Conclusion

The biggest problem of the platform is the high churn rate on the very first day. Moreover, half of the users do not solve a single task. It is necessary to improve the onboarding process on the website and immediately offer a popular test or task upon registration.