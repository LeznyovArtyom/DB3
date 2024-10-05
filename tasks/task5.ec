#include <stdio.h>
#include <stdlib.h>
#include <sqlca.h>
#include <unistd.h>

#define MAX_PASSWORD_LENGTH 20


// Вывод кода и описания ошибки
void error_msg(char *desc)
{
    printf("\n%s\nКод: %d\nОписание: %s\n", desc, sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);
    // откат транзакции
    EXEC SQL ROLLBACK WORK;
    // rollback сбрасывает search_path
    EXEC SQL SET SEARCH_PATH TO pmib1812;
}

int main(int numberOfArguments, char *arguments[]) 
{
    if (numberOfArguments < 2) {
        fprintf(stderr, "Arguments too few (The directory name is missing)\n");
        return EXIT_FAILURE;
    }

    // Объявление главных переменных
    EXEC SQL BEGIN DECLARE SECTION;
        char password[MAX_PASSWORD_LENGTH];
        char n_post[7];
        char name[7];
        int reiting;
        char town[7];
    EXEC SQL END DECLARE SECTION;

    // Предотвращаем переполнение буфера
    strncpy(password, arguments[1], MAX_PASSWORD_LENGTH - 1);
    password[MAX_PASSWORD_LENGTH - 1] = '\0';

    // Подключение к базе данных
    EXEC SQL CONNECT TO students@students.ami.nstu.ru USER "pmi-b1812" USING :password;

    // Перезаписываем массив, чтобы уменьшить время нахождения пароля в памяти
    memset(password, 0, strlen(password));

    if (sqlca.sqlcode < 0) {
        printf("Ошибка при подключении: %s\n", sqlca.sqlerrm.sqlerrmc);
        exit(1);
    }

    // Установка схемы базы данных
    EXEC SQL SET SEARCH_PATH TO pmib1812;

    if (sqlca.sqlcode < 0) {
        printf("Ошибка при установке схемы: %s\n", sqlca.sqlerrm.sqlerrmc);
        EXEC SQL DISCONNECT students;
        exit(1);
    }

    // Начинает работу с базой данных
    EXEC SQL BEGIN WORK;

    printf("Задание 5: \nВыдать полную информацию о поставщиках, поставляющих ТОЛЬКО красные детали и только для изделия с длиной названия не меньше 7.\n");
    
    // Подготовка запроса и привязка его к курсору cursor5
    EXEC SQL Declare cursor5 cursor for
             select distinct s.*
             into :n_post, :name, :reiting, :town
             from spj
             join p on spj.n_det = p.n_det
             join j on spj.n_izd = j.n_izd
             join s on spj.n_post = s.n_post
             where p.n_det in (select p.n_det
                               from p
                               where p.cvet='Красный')
                   and
                   j.n_izd in (select j.n_izd
                               from j
                               where length(j.name) >= 7)
             except
             select s.*
             from spj
             join p on spj.n_det = p.n_det
             join j on spj.n_izd = j.n_izd
             join s on spj.n_post = s.n_post
             where p.n_det not in (select p.n_det
                                   from p
                                   where p.cvet='Красный')
                   or
                   j.n_izd not in (select j.n_izd
                                   from j
                                   where length(j.name) >= 7);



    // Открытие курсора к началу выполнения
    EXEC SQL OPEN cursor5;

    if (sqlca.sqlcode < 0) {
        error_msg("Ошибка при открытии курсора (OPEN)");
    }

    // Извлечение строки из набора данных, возвращенного курсором
    EXEC SQL FETCH cursor5;

    if (sqlca.sqlcode < 0)
    {
        error_msg("Ошибка при чтении курсора (FETCH)");
    }

    if (sqlca.sqlcode == 100) {
        printf("\nДанных не найдено\n");
    }
    else {
        printf("\nНомер поставщика\tФамилия\tРейтинг\tГород\n%s\t%s\t\t%d\t%s\n", n_post, name, reiting, town);
    }

    while (sqlca.sqlcode == 0) {
        // Извлечение строки из набора данных, возвращенного курсором
        EXEC SQL FETCH cursor5;
        if (sqlca.sqlcode < 0) {
            error_msg("Ошибка при чтении курсора (FETCH)");
            break;
        }

        if (sqlca.sqlcode == 0) {
            printf("%s\t%s\t\t%d\t%s\n", n_post, name, reiting, town);
        }
    }

    // Закрытие курсора и завершение обработки результатов запроса
    EXEC SQL CLOSE cursor5;

    // Фиксирование всех изменений в базе данных
    EXEC SQL COMMIT WORK;

    // Отключение приложения от базы данных
    EXEC SQL DISCONNECT students;

    if (sqlca.sqlcode == 0) {
        printf("Отключение от программы 5\n");
    }

    return EXIT_SUCCESS;
}