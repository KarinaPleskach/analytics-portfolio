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