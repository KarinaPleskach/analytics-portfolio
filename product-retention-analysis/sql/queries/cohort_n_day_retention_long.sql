with user_data as (
    select
        u.id as user_id,
        to_char(u.date_joined, 'YYYY-MM') as cohort,
        ue.entry_at::date - u.date_joined::date as next_entry
    from users u
    left join userentry ue
        on u.id = ue.user_id
    where extract(year from u.date_joined) = 2022 and u.id > 93
), cohort_size as (
    select
        cohort,
        count(distinct user_id) as total_users
    from user_data
    group by cohort
)
select
    ud.cohort,
    ud.next_entry,
    round(
        count(distinct ud.user_id) * 100.0 / cs.total_users,
        1
    ) as retention
from user_data ud
join cohort_size cs
    on ud.cohort = cs.cohort
where ud.next_entry in (0,1,3,7,14,30,60,90)
group by ud.cohort, ud.next_entry, cs.total_users
order by ud.cohort, ud.next_entry;