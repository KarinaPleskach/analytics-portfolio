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