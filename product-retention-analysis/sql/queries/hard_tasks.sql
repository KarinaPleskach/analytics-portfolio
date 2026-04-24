with attempts as (
	select user_id, created_at, 'p' || problem_id as task_id, case when is_false = 0 then 1 else 0 end as is_true
	from codesubmit
	where extract(year from created_at) >= 2022 and user_id > 93
	union
	select user_id, created_at, 'p' || problem_id, 0
	from coderun
	where extract(year from created_at) >= 2022 and user_id > 93
	union
	select r.user_id, max(r.created_at), 't' || r.test_id, case when bool_or(a.is_correct) then 1 else 0 end
	from testresult r
	left join testanswer a
	on r.answer_id = a.id
	where extract(year from created_at) >= 2022 and user_id > 93
	group by to_char(r.created_at, 'YYYY-MM-DD'), r.test_id, r.user_id
), tasks_data as (
	select
		user_id,
		max(created_at) as created_at,
		task_id,
		max(is_true) as is_solved,
		sum(max(is_true)) over(partition by user_id order by max(created_at) desc)
	from attempts
	group by user_id, to_char(created_at, 'YYYY-MM-DD'), task_id
	order by 1, 2 desc
), counts as (
	select user_id, count(case when sum = 0 then 1 end) as unsolved_tasks
	from tasks_data
	group by user_id
	order by 1
)
select unsolved_tasks, count(user_id)
from counts
group by unsolved_tasks