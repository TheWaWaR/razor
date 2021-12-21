const std = @import("std");
const syscalls = @import("syscalls.zig");
const main = @import("main.zig");

// FIXME: learn ckb-vm memory model, then decide the size even the allocator Type.
var heap_buf: [512 * 1024]u8 = undefined;
var fixed_allocator = std.heap.FixedBufferAllocator.init(&heap_buf);
pub const global_allocator = fixed_allocator.allocator();

export fn _start() callconv(.Naked) noreturn {
    asm volatile (
        \\ lw a0, 0(sp)
        \\ addi a1, sp, 8
        \\ li a2, 0
        \\ call kmain
        \\ li a7, 93
        \\ ecall
    );
    while (true) {}
}

export fn kmain(c_argc: i32, c_argv: [*][*:0]u8) i8 {
    return @call(.{ .modifier = .always_inline }, main.main, .{c_argc, c_argv});
}

pub fn panic(message: []const u8, _: ?*std.builtin.StackTrace) noreturn {
    syscalls.debug(message);
    syscalls.exit(-1);
    while (true) {}
}

// FIXME: is this symbol required?
export fn eh_personality() void {}
// FIXME: is this symbol required?
export fn abort() noreturn {
    syscalls.debug("abort");
    syscalls.exit(-2);
}

