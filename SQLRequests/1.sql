select count(distinct spj.n_izd)
from spj
join p on spj.n_det = p.n_det
where p.ves > 12 and spj.n_post in (select s.n_post
                                    from s
                                    order by s.name asc
                                    limit 1
                                   )
