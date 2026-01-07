const std = @import("std");
const linux = std.os.linux;

var stdout_buffer = [_]u8{0} ** 1024;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
var stdout = &stdout_writer.interface;

const EVENT_SIZE = @sizeOf(linux.inotify_event);
const BUF_LEN = (1024 * (EVENT_SIZE + 16));

pub fn main() !void {
    const fd_usize = linux.inotify_init1(0);
    const fd: i32 = @intCast(fd_usize);
    defer std.posix.close(fd);

    var buf: [4096]u8 align(@alignOf(linux.inotify_event)) = undefined;

    if (fd < 0) {
        std.debug.print("inotify init", .{});
        std.process.exit(1);
    }
    _ = linux.inotify_add_watch(fd, ".", linux.IN.MODIFY | linux.IN.DELETE | linux.IN.CREATE | linux.IN.MOVED_TO);
    std.log.info("Watching current dir for changes", .{});

    while (true) {
        const length = try std.posix.read(fd, &buf);

        var i: usize = 0;
        while (i < length) {
            const event = @as(*linux.inotify_event, @ptrCast(@alignCast(&buf[i])));

            // Check if the event has a filename associated with it
            if (event.len > 0) {
                const name = event.getName() orelse "genaric";

                if (event.mask & linux.IN.CREATE != 0) {
                    std.debug.print("File Created: {s}\n", .{name});
                } else if (event.mask & linux.IN.MODIFY != 0) {
                    std.debug.print("File Modified: {s}\n", .{name});
                } else if (event.mask & linux.IN.DELETE != 0) {
                    std.debug.print("File Deleted: {s}\n", .{name});
                }
            }
            // Move to the next event in the buffer
            i = i + @sizeOf(linux.inotify_event) + event.len;
        }
    }
}
