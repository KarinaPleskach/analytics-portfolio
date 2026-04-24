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
