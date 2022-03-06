-- write your code in SQLite 3.11.0
 
    select  
    t.team_id
    , t.team_name
    , COALESCE(m.num_points, 0)
    from 
        teams t --This puts teams table on left side and then adds result of score calculation on rightside. Some teams that dont have matches can has null value on num_points column so I added 'coalesce' for it.
    left outer join 
        (select 
                team 
              , sum(num_points) as num_points --This part calculates and sums total scores of each team. There are only 2 columns which are score and team and those teams  are the ones that joined in match. And this has group by at the end.
        from
            ( --this parantesis is for UNION ALL and it includes firts select statement and second select statement
            --This part is first select statement of union all function to add host team and host team's score
            select host_team as team, host_num_points as num_points
            from 
                (select distinct_matches.* --This creates score column for host team
                ,case
                when  (host_goals - guest_goals) > 0 then 3
                when (host_goals - guest_goals) = 0 then 1
                when (host_goals - guest_goals) < 0 then 0
                end as host_num_points
                ,case
                when  (host_goals - guest_goals) < 0 then 3
                when (host_goals - guest_goals) = 0 then 1
                when (host_goals - guest_goals) > 0 then 0
                end as guest_num_points  
                from (select distinct * from matches) distinct_matches)
            UNION ALL
            --This part is second select statement of union all function to add guest team and guest team's score
            select guest_team as team, guest_num_points as num_points
            from 
                (--This creates score column  for guest team
                select distinct_matches.* 
                ,case
                when  (host_goals - guest_goals) > 0 then 3
                when (host_goals - guest_goals) = 0 then 1
                when (host_goals - guest_goals) < 0 then 0
                end as host_num_points
                ,case
                when  (host_goals - guest_goals) < 0 then 3
                when (host_goals - guest_goals) = 0 then 1
                when (host_goals - guest_goals) > 0 then 0
                end as guest_num_points  
                from (select distinct * from matches) distinct_matches)
            ) 
        group by team) m 
    on t.team_id = m.team -- this line is for left outer join. score calculation statement has m as alias and teams tablehas t as alias.
    order by  num_points desc 
            , team_id asc
; 

