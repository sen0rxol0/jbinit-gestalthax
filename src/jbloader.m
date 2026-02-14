#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <termios.h>
#include <sys/clonefile.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <mach/mach.h>
#include <spawn.h>
#import <Foundation/Foundation.h>

typedef void *posix_spawnattr_t;
typedef void *posix_spawn_file_actions_t;
int posix_spawnp(pid_t *, const char *,const posix_spawn_file_actions_t *,const posix_spawnattr_t *,char *const __argv[],char *const __envp[]);

int run(const char *cmd, char * const *args)
{
    int pid = 0;
    int retval = 0;
    char printbuf[0x1000] = {};

    for (char * const *a = args; *a; a++) {
        size_t csize = strlen(printbuf);
        if (csize >= sizeof(printbuf)) break;
        snprintf(printbuf+csize,sizeof(printbuf)-csize, "%s ",*a);
    }

    char *envp[] = {"PATH=/jbin:/jbin/bin:/jbin/usr/bin:/jbin/usr/sbin:$PATH","DYLD_LIBRARY_PATH=/usr/lib:/jbin/usr/lib:",NULL};

    retval = posix_spawnp(&pid, cmd, NULL, NULL, args, envp);
    printf("Spawning: %s (posix_spawn returned: %d)\n",printbuf,retval);
    {
        int pidret = 0;
        printf("waiting for '%s' to finish...\n",printbuf);
        retval = waitpid(pid, &pidret, 0);
        printf("waitpid for '%s' returned: %d\n",printbuf,retval);
        return pidret;
    }
    return retval;
}

int main(int argc, char **argv)
{
    unlink(argv[0]);
    setvbuf(stdout, NULL, _IONBF, 0);

    char *patcher_args[] = {"/gestaltpatcher",NULL};
    run(patcher_args[0],patcher_args);

    return 0;
}
