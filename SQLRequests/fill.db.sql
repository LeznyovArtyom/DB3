CREATE TABLE s (
    n_post character(6) NOT NULL UNIQUE,
    name character(20),
    reiting integer,
    town character(20)
) WITH OIDS;

CREATE TABLE p (
    n_det character(6) NOT NULL UNIQUE,
    name character(20), 
    cvet character(20),
    ves integer,
    town character(20)
) WITH OIDS;

CREATE TABLE j (
    n_izd character(6) NOT NULL UNIQUE,
    name character(20),
    town character(20)
) WITH OIDS;

CREATE TABLE spj (
    n_post character(6),
    n_det character(6),
    n_izd character(6),
    kol integer
) WITH OIDS;

insert into s 
values ('S1', 'Смит', 20, 'Лондон'),
       ('S2', 'Джонс', 10, 'Париж'),
       ('S3', 'Блейк', 30, 'Париж'),
       ('S4', 'Кларк', 20, 'Лондон'),
       ('S5', 'Адамс', 30, 'Афины');

insert into p 
values ('P1', 'Гайка', 'Красный', 12, 'Лондон'),
       ('P2', 'Болт', 'Зеленый', 17, 'Париж'),
       ('P3', 'Винт', 'Голубой', 17, 'Рим'),
       ('P4', 'Винт', 'Красный', 14, 'Лондон'),
       ('P5', 'Кулачок', 'Голубой', 12, 'Париж'),
       ('P6', 'Блюм', 'Красный', 19, 'Лондон');

insert into j
values ('J1', 'Жесткий диск', 'Париж'),
       ('J2', 'Перфоратор', 'Рим'),
       ('J3', 'Считыватель', 'Афины'),
       ('J4', 'Принтер', 'Афины'),
       ('J5', 'Флоппи-диск', 'Лондон'),
       ('J6', 'Терминал', 'Осло'),
       ('J7', 'Лента', 'Лондон');

insert into spj
values ('S1', 'P1', 'J1', 200),
       ('S1', 'P1', 'J4', 700),
       ('S2', 'P3', 'J1', 400),
       ('S2', 'P3', 'J2', 200),
       ('S2', 'P3', 'J3', 200),
       ('S2', 'P3', 'J4', 500),
       ('S2', 'P3', 'J5', 600),
       ('S2', 'P3', 'J6', 400),
       ('S2', 'P3', 'J7', 800),
       ('S2', 'P5', 'J2', 100),
       ('S3', 'P3', 'J1', 200),
       ('S3', 'P4', 'J2', 500),
       ('S4', 'P6', 'J3', 300),
       ('S4', 'P6', 'J7', 300),
       ('S5', 'P2', 'J2', 200),
       ('S5', 'P2', 'J4', 100),
       ('S5', 'P5', 'J5', 500),
       ('S5', 'P5', 'J7', 100),
       ('S5', 'P6', 'J2', 200),
       ('S5', 'P1', 'J4', 100),
       ('S5', 'P3', 'J4', 200),
       ('S5', 'P4', 'J4', 800),
       ('S5', 'P5', 'J4', 400),
       ('S5', 'P6', 'J4', 500);

alter table spj
add date date;

update spj set date='2024-10-01'
where n_post='S1';

update spj set date='2024-10-04'
where n_post='S2';

update spj set date='2024-10-08'
where n_post='S3';

update spj set date='2024-10-12'
where n_post='S4';

update spj set date='2024-10-16'
where n_post='S5';