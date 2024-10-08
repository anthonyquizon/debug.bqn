#include <stdio.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>
#include "replxx.h"

Replxx* replxx;

void init() {
	replxx = replxx_init();
	replxx_install_window_change_handler(replxx);
}

const int input(char *out) {
    const char* result=replxx_input(replxx, "   ");
    if (result==NULL) { return 0; }
    strcpy(out, result);
    return 1;
}

