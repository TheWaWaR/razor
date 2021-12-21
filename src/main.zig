
const syscalls = @import("syscalls.zig");
const debug = syscalls.debug;
const format = @import("util.zig").format;

pub fn main(c_argc: i32, c_argv: [*][*:0]u8) i8 {
    debug(format("c_argc: {}, c_argv: {*}", .{c_argc, c_argv}));
    var i: usize = 0;
    while (true) {
        i += 1;
        if (i > 400) {
            break;
        }
    }
    debug(format("i = {}", .{i}));
    if (i > 200) {
        @panic("this is panic message");
    }
    return 0;
}
