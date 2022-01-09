const std = @import("std");
const builtin = @import("builtin");
const syscalls = @import("syscalls.zig");

const mem = std.mem;

pub fn format(comptime fmt: []const u8, args: anytype, allocator: mem.Allocator) []u8 {
    // FIXME: ensure the final byte of string is `\0`
    return std.fmt.allocPrint(allocator, fmt, args) catch @panic("allocPrint error");
}

pub fn print(comptime fmt: []const u8, args: anytype, allocator: mem.Allocator) void {
    const content = format(fmt, args, allocator);
    defer allocator.free(content);
    syscalls.debug(content);
}

pub fn debug(comptime fmt: []const u8, args: anytype, allocator: mem.Allocator) void {
    switch (builtin.mode) {
        .Debug => print(fmt, args, allocator),
        else => {
            _ = fmt;
            _ = args;
        },
    }
}
