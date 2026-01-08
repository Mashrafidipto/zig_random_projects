const std = @import("std");
const cwd = std.fs.cwd();
const kind = std.fs.File.Kind;

var stdout_buffer = [_]u8{0} ** 1024;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
var stdout = &stdout_writer.interface;

pub fn list_files(allocator: std.mem.Allocator, name: []const u8) !void {
    var dir_current = try cwd.openDir(name, .{ .iterate = true });
    var it = dir_current.iterate();

    while (try it.next()) |entry| {
        const file_type = blk: switch (entry.kind) {
            kind.directory => {
                const full_name = try std.mem.concat(allocator, u8, &[_][]const u8{ name, "/", entry.name });
                try list_files(allocator, full_name);

                allocator.free(full_name);
                break :blk "Dir";
            },
            kind.file => "File",
            else => "Other",
        };
        try stdout.print("Name: {s:>10} type : {s:>5} \n", .{ entry.name, file_type });
    }
    try stdout.flush();
}

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    try list_files(allocator, "hello1");
}
