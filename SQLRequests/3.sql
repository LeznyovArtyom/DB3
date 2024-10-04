select spj.n_izd, spj.kol*p.ves pves, b.mves
from spj
join p on p.n_det = spj.n_det
join (select spj.n_izd, min(spj.kol*p.ves) mves
      from spj
      join p on p.n_det = spj.n_det
      group by spj.n_izd
     ) b on spj.n_izd = b.n_izd
where spj.kol*p.ves > b.mves * 4
order by 1, 2
