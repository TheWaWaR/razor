
const std = @import("std");

export fn _start() callconv(.Naked) noreturn {
// pub fn main() void {
    var i: usize = 1;
    var acc: usize = 0;
    while (true) {
        acc +%= i;
        if (i > 6_0000_0000) {
            break;
        }
        i += 1;
    }
    unreachable;
}
