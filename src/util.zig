const std = @import("std");
const builtin = @import("builtin");

const global_allocator = @import("root").global_allocator;
const syscalls = @import("ckb_std").syscalls;

pub fn format(comptime fmt: []const u8, args: anytype) []u8 {
    // FIXME: ensure the final byte of string is `\0`
    return std.fmt.allocPrint(global_allocator, fmt, args) catch @panic("allocPrint error");
}

pub fn print(comptime fmt: []const u8, args: anytype) void {
    syscalls.debug(format(fmt, args));
}

pub fn debug(comptime fmt: []const u8, args: anytype) void {
    switch (builtin.mode) {
        .Debug => print(fmt, args),
        else => {
            _ = fmt;
            _ = args;
        },
    }
}

test "check all decls: util" {
    std.testing.refAllDecls(@This());
}
