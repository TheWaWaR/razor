const std = @import("std");

extern fn syscall(a0: u64, a1: u64, a2: u64, a3: u64, a4: u64, a5: u64, _: u64, a7: u64) u64;

export fn _start() callconv(.Naked) noreturn {
    asm volatile (
        \\ lw a0, 0(sp)
        \\ addi a1, sp, 8
        \\ li a2, 0
        \\ call main
        \\ li a7, 93
        \\ ecall
    );
    while (true) {}
}

export fn eh_personality() void {}
export fn abort() noreturn {
    const msg: [:0]const u8 = "abort";
    _ = debug(msg);
    exit(-1);
}

pub fn panic(message: []const u8, _: ?*std.builtin.StackTrace) noreturn {
    debug(message);
    exit(-1);
    while (true) {}
}


pub fn debug(msg: []const u8) void {
    _ = syscall(@ptrToInt(&msg[0]), 0, 0, 0, 0, 0, 0, 2177);
}
pub fn exit(code: i8) noreturn {
    _ = syscall(@intCast(u64, @bitCast(u8, code)), 0, 0, 0, 0, 0, 0, 93);
    while (true) {}
}

export fn main() i8 {
    const msg1: [:0]const u8 = "hello";
    const msg2: [:0]const u8 = "world";
    debug(msg1);
    debug(msg2);

    var i: usize = 0;
    while (true) {
        i += 1;
        if (i > 400) {
            break;
        }
    }
    if (i > 200) {
        @panic("this is panic message");
    }
    return 0;
}
