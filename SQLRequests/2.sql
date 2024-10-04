update s
set name=(case when s.name=(select s.name 
                            from s 
                            order by s.name asc 
                            limit 1)
               then (select s.name 
                     from s 
                     order by s.name desc 
                     limit 1)
               else (select s.name 
                     from s 
                     order by s.name asc 
                     limit 1)
          end)
where s.n_post=(select s.n_post 
                from s 
                order by s.name asc 
                limit 1)
      or
      s.n_post=(select s.n_post 
                from s 
                order by s.name desc 
                limit 1)
