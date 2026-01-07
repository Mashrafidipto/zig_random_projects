#include <stdio.h>
#include <sys/inotify.h>
#include <unistd.h>
 // Hello 
#define EVENT_SIZE  (sizeof(struct inotify_event))
#define BUF_LEN     (1024 * (EVENT_SIZE + 16))

int main() {
    int fd, wd;
    char buffer[BUF_LEN];

    fd = inotify_init();
    if (fd < 0) {
        perror("inotify_init");
        return 1;
    }

    // Watch the current directory (.)
    // We add IN_CREATE, IN_DELETE, and IN_MOVED_TO to catch editor "swaps"
    wd = inotify_add_watch(fd, ".", IN_MODIFY | IN_CREATE | IN_DELETE | IN_MOVED_TO);
    
    printf("Watching current directory for changes...\n");

    while (1) {
        int length = read(fd, buffer, BUF_LEN);
        if (length < 0) break;

        int i = 0;
        while (i < length) {
            struct inotify_event *event = (struct inotify_event *) &buffer[i];
            
            // Check if the event involves a file (event->len > 0)
            if (event->len) {
                if (event->mask & IN_CREATE) {
                    printf("New file created: %s\n", event->name);
                } else if (event->mask & IN_DELETE) {
                    printf("File deleted: %s\n", event->name);
                } else if (event->mask & IN_MODIFY) {
                    printf("File modified: %s\n", event->name);
                } else if (event->mask & IN_MOVED_TO) {
                    printf("File moved/renamed to: %s\n", event->name);
                }
            }
            // Move to the next event in the buffer
            i += EVENT_SIZE + event->len;
        }
    }

    inotify_rm_watch(fd, wd);
    close(fd);
    return 0;
}
