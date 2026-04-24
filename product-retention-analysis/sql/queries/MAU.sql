select
	to_char(ue.entry_at, 'YYYY-MM') as month,
	count(distinct ue.user_id) as unique_users
from userentry ue
where extract(year from ue.entry_at) >= 2022 and ue.user_id > 93
group by 1
order by 1