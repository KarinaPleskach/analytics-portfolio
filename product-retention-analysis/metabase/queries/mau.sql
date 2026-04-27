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