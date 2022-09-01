const std = @import("std");
const builtin = @import("builtin");
const syscalls = @import("syscalls.zig");

const mem = std.mem;

pub fn format(allocator: mem.Allocator, comptime fmt: []const u8, args: anytype) []u8 {
    return std.fmt.allocPrint(allocator, fmt, args) catch @panic("allocPrint");
}

fn print(allocator: mem.Allocator, comptime fmt: []const u8, args: anytype) void {
    var content = format(allocator, fmt, args);
    // Optimized version of `std.cstr.addNullByte()`;
    content = allocator.realloc(content, content.len + 1) catch @panic("realloc");
    defer allocator.free(content);
    content[content.len - 1] = 0;
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
