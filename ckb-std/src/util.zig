const std = @import("std");
const builtin = @import("builtin");
const syscalls = @import("syscalls.zig");

const mem = std.mem;

pub fn format(allocator: mem.Allocator, comptime fmt: []const u8, args: anytype) []u8 {
    return std.fmt.allocPrint(allocator, fmt, args) catch @panic("allocPrint error");
}

pub fn print(allocator: mem.Allocator, comptime fmt: []const u8, args: anytype) void {
    const raw_content = format(allocator, fmt, args);
    // Optimized version of `std.cstr.addNullByte()`;
    const new_content = if (allocator.resize(raw_content, raw_content.len + 1)) |new_content| blk: {
        break :blk new_content;
    } else blk: {
        var new_content = allocator.alloc(u8, raw_content.len + 1) catch @panic("alloc error");
        mem.copy(u8, new_content, raw_content);
        allocator.free(raw_content);
        break :blk new_content;
    };
    defer allocator.free(new_content);
    new_content[raw_content.len] = 0;
    syscalls.debug(new_content);
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
