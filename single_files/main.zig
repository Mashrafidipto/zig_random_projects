const std = @import("std");
const log = std.math;

const DEBUG: bool = false;

pub fn n_th_fibonacci(n: usize) u128 {
    const first = 1;
    const second = 2;

    var first_part: u128 = first;
    var second_part: u128 = second;
    if (n == 0) {
        return 0;
    } else if (n == 1) {
        return first;
    } else if (n == 2) {
        return second;
    }

    var i: usize = 3;
    while (i <= n) : (i += 1) {
        first_part = first_part + second_part;
        if (DEBUG) std.log.info("{d}", .{first_part});

        i += 1;
        second_part = first_part + second_part;
        if (DEBUG) std.log.info("{d}", .{second_part});
    }
    return if (n == i) first_part else second_part;
}

pub fn main() !void {
    const val = n_th_fibonacci(81);

    std.log.info("{d}", .{val});
}
