const std = @import("std");
const syscalls = @import("syscalls.zig");
const SysError = @import("error.zig").SysError;
const consts = @import("ckb_constants.zig");

const Source = consts.Source;
const CellField = consts.CellField;
const HeaderField = consts.HeaderField;
const InputField = consts.InputField;
const mem = std.mem;
const assert = std.debug.assert;

const BUF_SIZE: usize = 1024;

/// Load dynamically sized data
fn loadData(
    context: anytype,
    comptime loader: Loader,
    allocator: mem.Allocator,
) SysError![]u8 {
    var script_buf: [BUF_SIZE]u8 = undefined;
    const size = try loader.call(context, &script_buf, 0);
    var result_buf: []u8 = try allocator.alloc(u8, size);
    mem.copy(u8, result_buf, script_buf[0..@minimum(BUF_SIZE, size)]);
    if (size > BUF_SIZE) {
        const new_size = try loader.call(context, result_buf[BUF_SIZE..size], BUF_SIZE);
        assert(new_size + BUF_SIZE == size);
    }
    return result_buf;
}

const Loader = union(enum) {
    raw: fn (buf: []u8, offset: usize) SysError!usize,
    by_source: fn (buf: []u8, offset: usize, index: usize, source: Source) SysError!usize,
    by_cell_field: struct {
        field: CellField,
        func: fn (buf: []u8, offset: usize, index: usize, source: Source, field: CellField) SysError!usize,
    },

    fn call(comptime self: Loader, context: anytype, buf: []u8, offset: usize) SysError!usize {
        return switch (self) {
            Loader.raw => |func| blk: {
                break :blk try func(buf, offset);
            },
            Loader.by_source => |func| blk: {
                break :blk try func(buf, offset, context.index, context.source);
            },
            Loader.by_cell_field => |cfg| blk: {
                break :blk try cfg.func(buf, offset, context.index, context.source, cfg.field);
            },
        };
    }
};

fn loadU64Field(
    comptime field: anytype,
    comptime field_loader: fn ([]u8, usize, usize, Source, @TypeOf(field)) SysError!usize,
    offset: usize,
    index: usize,
    source: Source,
) SysError!u64 {
    var buf: [8]u8 align(@alignOf(u64)) = undefined;
    const size = try loader(&buf, offset, index, source, field);
    assert(size == 8);
    return mem.bytesAsSlice(u64, &buf)[0];
}

pub fn loadTxHash() SysError![32]u8 {
    var buf: [32]u8 = undefined;
    const size = try syscalls.loadTxHash(&buf, 0);
    assert(size == buf.len);
    return buf;
}
pub fn loadScriptHash() SysError![32]u8 {
    var buf: [32]u8 = undefined;
    const size = try syscalls.loadScriptHash(&buf, 0);
    assert(size == buf.len);
    return buf;
}

pub fn loadScript(allocator: mem.Allocator) SysError![]u8 {
    return loadData({}, Loader{ .raw = syscalls.loadScript }, allocator);
}
pub fn loadTransaction(allocator: mem.Allocator) SysError![]u8 {
    return loadData({}, Loader{ .raw = syscalls.loadTransaction }, allocator);
}

pub fn loadCell(allocator: mem.Allocator, index: usize, source: Source) SysError![]u8 {
    return loadData(
        .{ .index = index, .source = source },
        Loader{ .by_source = syscalls.loadCell },
        allocator,
    );
}
pub fn loadInput(allocator: mem.Allocator, index: usize, source: Source) SysError![]u8 {
    return loadData(
        .{ .index = index, .source = source },
        Loader{ .by_source = syscalls.loadInput },
        allocator,
    );
}
pub fn loadHeader(allocator: mem.Allocator, index: usize, source: Source) SysError![]u8 {
    return loadData(
        .{ .index = index, .source = source },
        Loader{ .by_source = syscalls.loadHeader },
        allocator,
    );
}
pub fn loadWitness(allocator: mem.Allocator, index: usize, source: Source) SysError![]u8 {
    return loadData(
        .{ .index = index, .source = source },
        Loader{ .by_source = syscalls.loadWitness },
        allocator,
    );
}

pub fn loadCellCapacity(index: usize, source: Source) SysError!u64 {
    return loadU64Field(CellField.capacity, syscalls.loadCellByField, 0, index, source);
}
pub fn loadCellOccupiedCapacity(index: usize, source: Source) SysError!u64 {
    return loadU64Field(CellField.occupied_capacity, syscalls.loadCellByField, 0, index, source);
}

pub fn loadCellDataHash(index: usize, source: Source) SysError![32]u8 {
    var buf: [32]u8 = undefined;
    const size = try syscalls.loadCellByField(&buf, 0, index, source, CellField.data_hash);
    assert(size == buf.len);
    return buf;
}

pub fn loadCellLockHash(index: usize, source: Source) SysError![32]u8 {
    var buf: [32]u8 = undefined;
    const size = try syscalls.loadCellByField(&buf, 0, index, source, CellField.lock_hash);
    assert(size == buf.len);
    return buf;
}

pub fn loadCellTypeHash(index: usize, source: Source) SysError!?[32]u8 {
    var buf: [32]u8 = undefined;
    const size = syscalls.loadCellByField(&buf, 0, index, source, CellField.lock_hash) catch |err| {
        switch (err) {
            error.ItemMissing => return null,
            else => return err,
        }
    };
    assert(size == buf.len);
    return buf;
}

pub fn loadCellLock(allocator: mem.Allocator, index: usize, source: Source) SysError![]u8 {
    return loadData(
        .{ .index = index, .source = source },
        Loader{ .by_cell_field = .{
            .field = CellField.lock,
            .func = syscalls.loadCellByField,
        } },
        allocator,
    );
}

pub fn loadCellType(allocator: mem.Allocator, index: usize, source: Source) SysError!?[]u8 {
    return loadData(
        .{ .index = index, .source = source },
        Loader{ .by_cell_field = .{
            .field = CellField.@"type",
            .func = syscalls.loadCellByField,
        } },
        allocator,
    ) catch |err| {
        switch (err) {
            error.ItemMissing => return null,
            else => return err,
        }
    };
}

pub fn loadHeaderEpochNumber(index: usize, source: Source) SysError!u64 {
    return loadU64Field(HeaderField.epoch_number, syscalls.loadHeaderByField, 0, index, source);
}
