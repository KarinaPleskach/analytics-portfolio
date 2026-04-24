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