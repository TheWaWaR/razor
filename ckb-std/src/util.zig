const std = @import("std");
const builtin = @import("builtin");
const syscalls = @import("syscalls.zig");

const mem = std.mem;

pub fn format(allocator: mem.Allocator, comptime fmt: []const u8, args: anytype) []u8 {
    return std.fmt.allocPrint(allocator, fmt, args) catch @panic("allocPrint error");
}

pub fn print(allocator: mem.Allocator, comptime fmt: []const u8, args: anytype) void {
    const raw_content = format(allocator, fmt, args);
    const content = std.cstr.addNullByte(allocator, raw_content) catch @panic("addNullByte error");
    defer allocator.free(raw_content);
    defer allocator.free(content);
    syscalls.debug(content);
}

pub fn debug(allocator: mem.Allocator, comptime fmt: []const u8, args: anytype) void {
    switch (builtin.mode) {
        .Debug => print(allocator, fmt, args),
        else => {
            _ = fmt;
            _ = args;
        },
    }
}
