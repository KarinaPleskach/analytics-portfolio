with num_of_problems as (
	select l.name, count(p.id) as problems
	from problem p
	join languagetoproblem lp
	on lp.pr_id = p.id
	join language l
	on l.id = lp.lang_id
	group by l.name
), num_of_tests as (
	select case when name ilike '%sql%' then 'SQL' else 'Python' end as name, count(*) as tests
	from test
	group by 1
), used_problems as (
	select user_id, problem_id, l.name
	from coderun c
	join languagetoproblem lp
	on lp.pr_id = c.problem_id
	join language l
	on l.id = lp.lang_id
	union
	select user_id, problem_id, l.name
	from codesubmit c
	join languagetoproblem lp
	on lp.pr_id = c.problem_id
	join language l
	on l.id = lp.lang_id
), user_problems as (
	select
		user_id,
		name,
		count(problem_id) as cnt,
		max(count(problem_id)) over(partition by name) as max_problems,
		round(avg(count(problem_id)) over(partition by name)) as avg_problems
	from used_problems
	where user_id > 93
	group by user_id, name
), used_tests as (
	select distinct ts.user_id, ts.test_id, case when t.name ilike '%sql%' then 'SQL' else 'Python' end as name
	from teststart ts
	join test t
	on t.id = ts.test_id
), user_tests as (
	select user_id, name, count(test_id) as cnt,
		max(count(test_id)) over(partition by name) as max_tests,
		round(avg(count(test_id)) over(partition by name)) as avg_tests
	from used_tests
	where user_id > 93
	group by user_id, name
)
select np.name, max(problems) as problems, max(tests) as tests,
	max(up.max_problems) as max_problems, max(up.avg_problems) as avg_problems,
	max(ut.max_tests) as max_tests, max(ut.avg_tests) as avg_tests
from num_of_problems np
join num_of_tests nt
on np.name = nt.name
join user_problems up
on np.name = up.name
join user_tests ut
on np.name = ut.name
group by np.name