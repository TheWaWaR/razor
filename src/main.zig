const std = @import("std");
const syscalls = @import("syscalls.zig");

// FIXME: learn ckb-vm memory model, then decide the size even the allocator Type.
var heap_buf: [512 * 1024]u8 = undefined;
var fixed_allocator = std.heap.FixedBufferAllocator.init(&heap_buf);
const allocator = fixed_allocator.allocator();

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

// FIXME: is this symbol required?
export fn eh_personality() void {}
// FIXME: is this symbol required?
export fn abort() noreturn {
    const msg: [:0]const u8 = "abort";
    _ = syscalls.debug(msg);
    syscalls.exit(-1);
}

pub fn panic(message: []const u8, _: ?*std.builtin.StackTrace) noreturn {
    syscalls.debug(message);
    syscalls.exit(-2);
    while (true) {}
}

export fn main() i8 {
    const msg: []const u8 = "hello";
    syscalls.debug(msg);

    var i: usize = 0;
    while (true) {
        i += 1;
        if (i > 400) {
            break;
        }
    }
    var s = std.fmt.allocPrint(allocator, "i = {}", .{i}) catch @panic("oom");
    syscalls.debug(s);
    if (i > 200) {
        @panic("this is panic message");
    }
    return 0;
}
