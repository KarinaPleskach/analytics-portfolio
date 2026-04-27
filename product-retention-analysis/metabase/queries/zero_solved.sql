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