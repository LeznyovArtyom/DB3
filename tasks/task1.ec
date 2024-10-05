#include <stdio.h>
#include <stdlib.h>
#include <sqlca.h>
#include <unistd.h>

#define MAX_PASSWORD_LENGTH 20


int main(int numberOfArguments, char *arguments[]) 
{
    if (numberOfArguments < 2) {
        fprintf(stderr, "Arguments too few (The directory name is missing)\n");
        return EXIT_FAILURE;
    }

    // Объявление главных переменных
    EXEC SQL BEGIN DECLARE SECTION;
        char password[MAX_PASSWORD_LENGTH];
        int countProducts;
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

    printf("Задание 1: \nВыдать число изделий, для которых детали с весом больше 12 поставлял первый по алфавиту поставщик.\n");

    EXEC SQL select count(distinct spj.n_izd)
             into :countProducts
             from spj
             join p on spj.n_det = p.n_det
             where p.ves > 12 and spj.n_post in (select s.n_post
                                                 from s
                                                 order by s.name asc
                                                 limit 1
                                                );

    if (sqlca.sqlcode < 0) {
        printf("Ошибка при выборке из базы данных: %s\n", sqlca.sqlerrm.sqlerrmc);
        EXEC SQL DISCONNECT students;
        exit(1);
    }

    printf("Число изделий: %d\n", countProducts);

    // Фиксирование всех изменений в базе данных
    EXEC SQL COMMIT WORK;

    // Отключение приложения от базы данных
    EXEC SQL DISCONNECT students;

    if (sqlca.sqlcode == 0) {
        printf("Отключение от программы 1\n");
    }

    return EXIT_SUCCESS;
}