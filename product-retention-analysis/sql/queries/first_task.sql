with attempts as (
	select user_id, created_at, problem_id, is_false
	from codesubmit
	union
	select user_id, created_at, problem_id, 1
	from coderun
), first_year_attempts as (
	select
		*,
		min(extract(year from created_at)) over(partition by user_id) as first_year,
		first_value(problem_id) over(partition by user_id order by created_at) as first_task,
		min(is_false) over(partition by user_id, problem_id) = 0 as is_solved
	from attempts
	where user_id > 93
), first_task_attempts as (
	select distinct user_id, is_solved
	from first_year_attempts
	where first_year >= 2022 and problem_id = first_task
), user_data as (
	select
		f.user_id,
		f.is_solved,
		to_char(u.date_joined, 'YYYY-MM') as cohort,
		ue.entry_at::date - u.date_joined::date as next_entry
	from first_task_attempts f
	join users u
	on u.id = f.user_id
	left join userentry ue
	on u.id = ue.user_id
	where extract(year from u.date_joined) = 2022
)
select
	cohort,
	is_solved,
	round(count(distinct case when next_entry = 0 then user_id end) * 100.0 / count(distinct user_id), 2) as "0",
	round(count(distinct case when next_entry = 1 then user_id end) * 100.0 / count(distinct user_id), 2) as "1",
	round(count(distinct case when next_entry = 3 then user_id end) * 100.0 / count(distinct user_id), 2) as "3",
	round(count(distinct case when next_entry = 7 then user_id end) * 100.0 / count(distinct user_id), 2) as "7",
	round(count(distinct case when next_entry = 14 then user_id end) * 100.0 / count(distinct user_id), 2) as "14",
	round(count(distinct case when next_entry = 30 then user_id end) * 100.0 / count(distinct user_id), 2) as "30",
	round(count(distinct case when next_entry = 60 then user_id end) * 100.0 / count(distinct user_id), 2) as "60",
	round(count(distinct case when next_entry = 90 then user_id end) * 100.0 / count(distinct user_id), 2) as "90"
from user_data
group by cohort, is_solved