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