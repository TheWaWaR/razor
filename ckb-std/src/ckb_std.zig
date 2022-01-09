const std = @import("std");

pub const ckb_constants = @import("ckb_constants.zig");
pub const SysError = @import("error.zig").SysError;
pub const syscalls = @import("syscalls.zig");
pub const syscalls_wrap = @import("syscalls_wrap.zig");
pub const util = @import("util.zig");

// FIXME: learn ckb-vm memory model, then decide the size even the allocator Type.
var heap_buf: [512 * 1024]u8 = undefined;
var fixed_allocator = std.heap.FixedBufferAllocator.init(&heap_buf);
pub fn initFixedAllocator() std.mem.Allocator {
    return fixed_allocator.allocator();
}

test "check all decls" {
    std.testing.refAllDecls(@This());
}
