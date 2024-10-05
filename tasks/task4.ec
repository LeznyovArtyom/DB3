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

    printf("Задание 4: \nВыбрать поставщиков, не поставивших ни одной из деталей, имеющих наименьший вес.\n");

    // Подготовка запроса и привязка его к курсору cursor4
    EXEC SQL Declare cursor4 cursor for
             select s.n_post
             into :n_post
             from s
             except
             select spj.n_post
             from spj
             join p on spj.n_det = p.n_det
             where p.ves=(select min(p.ves)
                          from p);


    // Открытие курсора к началу выполнения
    EXEC SQL OPEN cursor4;

    if (sqlca.sqlcode < 0) {
        error_msg("Ошибка при открытии курсора (OPEN)");
    }

    // Извлечение строки из набора данных, возвращенного курсором
    EXEC SQL FETCH cursor4;

    if (sqlca.sqlcode < 0)
    {
        error_msg("Ошибка при чтении курсора (FETCH)");
    }

    if (sqlca.sqlcode == 100) {
        printf("\nДанных не найдено\n");
    }
    else {
        printf("\nСписок поставщиков\n%s\n", n_post);
    }

    while (sqlca.sqlcode == 0) {
        // Извлечение строки из набора данных, возвращенного курсором
        EXEC SQL FETCH cursor4;
        if (sqlca.sqlcode < 0) {
            error_msg("Ошибка при чтении курсора (FETCH)");
            break;
        }

        if (sqlca.sqlcode == 0) {
            printf("%s\n", n_post);
        }
    }

    // Закрытие курсора и завершение обработки результатов запроса
    EXEC SQL CLOSE cursor4;

    // Фиксирование всех изменений в базе данных
    EXEC SQL COMMIT WORK;

    // Отключение приложения от базы данных
    EXEC SQL DISCONNECT students;

    if (sqlca.sqlcode == 0) {
        printf("Отключение от программы 4\n");
    }

    return EXIT_SUCCESS;
}