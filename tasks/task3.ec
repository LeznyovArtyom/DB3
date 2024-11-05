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
        char n_izd[7];
        int pves;
        int mves;
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

    printf("Задание 3: \nНайти изделия, для которых выполнены поставки, вес которых более чем в 4 раза превышает минимальный вес поставки для изделия. Вывести номер изделия, вес поставки, минимальный вес поставки для изделия.\n");

    // Подготовка запроса и привязка его к курсору cursor3
    EXEC SQL Declare cursor3 cursor for
             select spj.n_izd, spj.kol*p.ves pves, b.mves
             into :n_izd, :pves, :mves
             from spj
             join p on p.n_det = spj.n_det
             join (select spj.n_izd, min(spj.kol*p.ves) mves
                   from spj
                   join p on p.n_det = spj.n_det
                   group by spj.n_izd
                  ) b on spj.n_izd = b.n_izd
             where spj.kol*p.ves > b.mves * 4
             order by 1, 2;

    // Открытие курсора к началу выполнения
    EXEC SQL OPEN cursor3;

    if (sqlca.sqlcode < 0) {
        error_msg("Ошибка при открытии курсора (OPEN)");
    }

    // Извлечение строки из набора данных, возвращенного курсором
    EXEC SQL FETCH cursor3;

    if (sqlca.sqlcode < 0)
    {
        error_msg("Ошибка при чтении курсора (FETCH)");
    }

    if (sqlca.sqlcode == 100) {
        printf("\nДанных не найдено\n");
    }
    else {
        printf("\nНомер изделия\tВес поставки\t\tМинимальный вес поставки для изделия\n%s\t\t%d\t\t%d\n", n_izd, pves, mves);
    }

    while (sqlca.sqlcode == 0) {
        // Извлечение строки из набора данных, возвращенного курсором
        EXEC SQL FETCH cursor3;
        if (sqlca.sqlcode < 0) {
            error_msg("Ошибка при чтении курсора (FETCH)");
            break;
        }

        if (sqlca.sqlcode == 0) {
            printf("%s\t\t%d\t\t%d\n", n_izd, pves, mves);
        }
    }

    // Закрытие курсора и завершение обработки результатов запроса
    EXEC SQL CLOSE cursor3;

    // Фиксирование всех изменений в базе данных
    EXEC SQL COMMIT WORK;

    // Отключение приложения от базы данных
    EXEC SQL DISCONNECT students;

    if (sqlca.sqlcode == 0) {
        printf("Отключение от программы 3\n");
    }

    return EXIT_SUCCESS;
}