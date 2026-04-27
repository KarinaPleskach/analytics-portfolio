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