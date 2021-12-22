const std = @import("std");
const global_allocator = @import("root").global_allocator;

pub fn format(comptime fmt: []const u8, args: anytype) []u8 {
    // FIXME: ensure the final byte of string is `\0`
    return std.fmt.allocPrint(global_allocator, fmt, args) catch @panic("allocPrint error");
}
