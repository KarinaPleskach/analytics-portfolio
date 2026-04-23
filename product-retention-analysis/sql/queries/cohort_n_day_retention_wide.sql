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