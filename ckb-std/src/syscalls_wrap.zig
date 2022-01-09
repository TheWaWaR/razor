const std = @import("std");
const syscalls = @import("syscalls.zig");
const SysError = @import("error.zig").SysError;
const Source = @import("ckb_constants.zig").Source;

const mem = std.mem;
const assert = std.debug.assert;

const BUF_SIZE: usize = 1024;

fn loadData(
    context: anytype,
    comptime loader: fn (context: @TypeOf(context), buf: []u8, offset: usize) SysError!usize,
    allocator: mem.Allocator,
) SysError![]u8 {
    var script_buf: [BUF_SIZE]u8 = undefined;
    const size = try loader(context, &script_buf, 0);
    var result_buf: []u8 = try allocator.alloc(u8, size);
    mem.copy(u8, result_buf, script_buf[0..@minimum(BUF_SIZE, size)]);
    if (size > BUF_SIZE) {
        const new_size = try loader(context, result_buf[BUF_SIZE..size], BUF_SIZE);
        assert(new_size + BUF_SIZE == size);
    }
    return result_buf;
}
fn raw_loader(_: void, buf: []u8, offset: usize) SysError!usize {
    return syscalls.loadScript(buf, offset);
}
const SourceLoader = struct {
    index: usize,
    source: Source,
    inner: fn (buf: []u8, offset: usize, index: usize, source: Source) SysError!usize,
};
fn source_loader(context: *const SourceLoader, buf: []u8, offset: usize) SysError!usize {
    return context.inner(buf, offset, context.index, context.source);
}

pub fn loadTxHash() SysError![32]u8 {
    var hash_buf: [32]u8 = undefined;
    const size = try syscalls.loadTxHash(&hash_buf, 0);
    assert(size == 32);
    return hash_buf;
}

pub fn loadScriptHash() SysError![32]u8 {
    var hash_buf: [32]u8 = undefined;
    const size = try syscalls.loadScriptHash(&hash_buf, 0);
    assert(size == 32);
    return hash_buf;
}

pub fn loadCell(allocator: mem.Allocator, index: usize, source: Source) SysError![]u8 {
    const loader = SourceLoader{
        .index = index,
        .source = source,
        .inner = syscalls.loadCell,
    };
    return loadData(&loader, source_loader, allocator);
}

pub fn loadScript(allocator: mem.Allocator) SysError![]u8 {
    return loadData({}, raw_loader, allocator);
}
