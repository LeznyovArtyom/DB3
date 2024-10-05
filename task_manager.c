#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <termios.h>
#include <sys/wait.h>

#define MAX_PASSWORD_LENGTH 20

size_t len = 0;

void GetPassword(char *password, size_t maxlen) 
{
    struct termios oldt, newt;
    int ch;

    // Получаем текущие настройки терминала
    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    // Отключаем отображение вводимых символов
    newt.c_lflag &= ~(ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newt); 

    printf("Enter password: ");

    // Читаем символы до Enter или до максимальной длины
    while ((ch = getchar()) != '\n' && len < maxlen - 1) {
        password[len++] = ch;
    }
    // Заканчиваем строку
    password[len] = '\0';

    // Возвращаем настройки терминала
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);

    printf("\n");
}

int main()
{
    char password[MAX_PASSWORD_LENGTH];
    char taskNumber;
    int status;
    GetPassword(password, sizeof(password));

    printf("'x' выйти из программы");
    printf("\nВыберите задание (1-5): ");

    while (scanf("%c", &taskNumber))
    {
        while ((getchar()) != '\n');  // Очистка буфера ввода

        switch (taskNumber)
        {
        case '1':

            printf("\nЗапуск программы 1\n");

            if (fork() == 0)
            {
                execl("./compiled_tasks/task1","task1", password, NULL);
                exit(EXIT_FAILURE);
            }

            wait(&status);

            break;
        case '2':

            printf("\nЗапуск программы 2\n");
            
            if (fork() == 0)
            {
                execl("./compiled_tasks/task2","task2", password, NULL);
                exit(EXIT_FAILURE);
            }
            
            wait(&status);

            break;
        case '3':

            printf("\nЗапуск программы 3\n");            
            
            if (fork() == 0)
            {
                execl("./compiled_tasks/task3","task3", password, NULL);
                exit(EXIT_FAILURE);
            }
            
            wait(&status);

            break;
        case '4':

            printf("\nЗапуск программы 4\n");
            
            if (fork() == 0)
            {
                execl("./compiled_tasks/task4","task4", password, NULL);
                exit(EXIT_FAILURE);
            }
            
            wait(&status);

            break;
        case '5':
            printf("\nЗапуск программы 5\n");
                        
            if (fork() == 0)
            {
                execl("./compiled_tasks/task5","task5", password, NULL);
                exit(EXIT_FAILURE);
            }
            
            wait(&status);

            break;
        case 'x':
            return EXIT_SUCCESS;
        default:
            printf("Вы ввели неверное число\n");
            break;
        }
            printf("\n'x' выйти из программы");
            printf("\nВыберите задание (1-5): ");
    }

    return EXIT_SUCCESS;
}