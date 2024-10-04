select distinct spj.n_post
from spj
join p on spj.n_det = p.n_det
join j on spj.n_izd = j.n_izd
where p.n_det in (select p.n_det
                  from p
                  where p.cvet='Красный')
            and
            j.n_izd in (select j.n_izd
                        from j
                        where length(j.name) >= 7)
except
select spj.n_post
from spj
join p on spj.n_det = p.n_det
join j on spj.n_izd = j.n_izd
where p.n_det not in (select p.n_det
                      from p
                      where p.cvet='Красный')
      or
      j.n_izd not in (select j.n_izd
                      from j
                      where length(j.name) >= 7)
