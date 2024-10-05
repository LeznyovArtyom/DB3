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

    // Объявление главной переменной
    EXEC SQL BEGIN DECLARE SECTION;
        char password[MAX_PASSWORD_LENGTH];
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
        exit(1)
    }

    // Начинает работу с базой данных
    EXEC SQL BEGIN WORK;

    printf("Задание 2: \nПоменять местами фамилии первого и последнего по алфавиту поставщика, т. е. первому по алфавиту поставщику установить фамилию последнего по алфавиту поставщика и наоборот.\n");

    EXEC SQL update s
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
                       limit 1);

    if (sqlca.sqlcode < 0) {
        printf("\nОшибка при изменении данных (UPDATE).\nКод: %d\nОписание: %s\n", desc, sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);
        // откат транзакции
        EXEC SQL ROLLBACK WORK;
        // rollback сбрасывает search_path
        EXEC SQL SET SEARCH_PATH TO pmib1812;

        return EXIT_FAILURE
    }

    if (sqlca.sqlcode < 0) {
        print("Количество обработанных записей: %d\n", sqlca.sqlerrd[2]);
    }

    // Фиксирование всех изменений в базе данных
    EXEC SQL COMMIT WORK;

    // Отключение приложения от базы данных
    EXEC SQL DISCONNECT students;

    if (sqlca.sqlcode == 0) {
        printf("Отключение от программы 2");
    }

    return EXIT_SUCCESS;
}