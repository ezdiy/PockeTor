#define _GNU_SOURCE
#include <stdlib.h>
#include <dlfcn.h>
char *get_proxy() {
	return getenv("GET_PROXY");
}

typedef int (*RealSetTaskParameters)(int task, char *appname, char *name, void *icon, unsigned int flags);

int SetTaskParameters(int task, char *appname, char *name, void *icon, unsigned int flags) {
	char *nn = getenv("SET_APPNAME");
	if (nn == NULL)
		nn = name;
	((RealSetTaskParameters)dlsym(RTLD_NEXT, "SetTaskParameters"))(task, appname, nn, icon, flags);
}

