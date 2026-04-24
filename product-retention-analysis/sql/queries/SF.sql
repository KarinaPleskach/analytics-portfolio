with maus as (
	select
		count(distinct ue.user_id) as mau
	from userentry ue
	where extract(year from ue.entry_at) >= 2022 and ue.user_id > 93
	group by to_char(ue.entry_at, 'YYYY-WW')
), daus as (
	select
		count(distinct ue.user_id) as dau
	from userentry ue
	where extract(year from ue.entry_at) >= 2022 and ue.user_id > 93
	group by to_char(ue.entry_at, 'YYYY-DDD')
)
select avg(dau) * 100.0 / avg(mau) as sf
from daus, maus