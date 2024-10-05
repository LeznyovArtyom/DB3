PROG = main

PREF_SRC = ./
PREF_OBJ = ./obj/

SRC = $(wildcard $(PREF_SRC)*.c)
OBJ = $(patsubst $(PREF_SRC)%.c, $(PREF_OBJ)%.o, $(SRC))

#Program compile (C)
$(PROG): $(OBJ)
	@gcc $(OBJ) -o $(PROG)

$(PREF_OBJ)%.o : $(PREF_SRC)%.c
	@gcc -std=c99 -c -O $< -o $@

clean :
	@rm $(PROGNAME) $(PREF_OBJ)*.o