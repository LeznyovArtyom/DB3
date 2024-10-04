select s.n_post
from s
except
select spj.n_post
from spj
join p on spj.n_det = p.n_det
where p.ves=(select min(p.ves)
             from p)
