
const std = @import("std");
const global_allocator = @import("kernel.zig").global_allocator;

pub fn format(comptime fmt: []const u8, args: anytype) []u8 {
    return std.fmt.allocPrint(global_allocator, fmt, args) catch @panic("allocPrint error");
}
