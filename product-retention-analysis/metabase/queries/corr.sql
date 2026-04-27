with user_data as (
	select c.user_id, c.problem_id, p.complexity
	from coderun c
	join problem p
	on c.problem_id = p.id
	join users
	on users.id =c.user_id
	left join company
	on users.company_id = company.id
	where users.id > 93 
	    and extract(year from users.date_joined) = 2022
	    [[and to_char(users.date_joined, 'YYYY-MM') in ({{cohort}})]]
	    and {{company.name}}
	union
	select c.user_id, c.problem_id, p.complexity
	from codesubmit c
	join problem p
	on c.problem_id = p.id
	join users
	on users.id =c.user_id
	left join company
	on users.company_id = company.id
	where users.id > 93 
	    and extract(year from users.date_joined) = 2022
	    [[and to_char(users.date_joined, 'YYYY-MM') in ({{cohort}})]]
	    and {{company.name}}
)
select
	user_id,
	count(problem_id) as number_of_tried_tasks,
	round(avg(complexity), 2) as average_complexity
from user_data
group by user_id
order by user_id