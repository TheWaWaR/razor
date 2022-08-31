const std = @import("std");
const syscalls = @import("syscalls.zig");
const SysError = @import("error.zig").SysError;
const consts = @import("ckb_constants.zig");
const types = @import("types.zig");

const mem = std.mem;
const assert = std.debug.assert;
const Source = consts.Source;
const CellField = consts.CellField;
const HeaderField = consts.HeaderField;
const InputField = consts.InputField;
const ScriptHashType = types.ScriptHashType;

const BUF_SIZE: usize = 256;

// Load dynamically sized data
fn loadData(
    context: anytype,
    comptime loader: Loader,
    allocator: mem.Allocator,
) SysError![]u8 {
    var result_buf: []u8 = try allocator.alloc(u8, BUF_SIZE);
    const size = try loader.call(context, result_buf, 0);
    if (size > BUF_SIZE) {
        result_buf = try allocator.realloc(result_buf, size);
        const new_size = try loader.call(context, result_buf[BUF_SIZE..size], BUF_SIZE);
        assert(new_size + BUF_SIZE == size);
    }
    return result_buf[0..size];
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
    const size = try field_loader(&buf, offset, index, source, field);
    assert(size == buf.len);
    return mem.bytesAsSlice(u64, &buf)[0];
}

/// Load tx hash
///
/// Return the tx hash or a syscall error
pub fn loadTxHash() SysError![32]u8 {
    var buf: [32]u8 = undefined;
    const size = try syscalls.loadTxHash(&buf, 0);
    assert(size == buf.len);
    return buf;
}

/// Load script hash
///
/// Return the script hash or a syscall error
pub fn loadScriptHash() SysError![32]u8 {
    var buf: [32]u8 = undefined;
    const size = try syscalls.loadScriptHash(&buf, 0);
    assert(size == buf.len);
    return buf;
}

/// Load script
pub fn loadScript(allocator: mem.Allocator) SysError![]u8 {
    return loadData({}, Loader{ .raw = syscalls.loadScript }, allocator);
}

/// Load transaction
///
/// Return the transaction or a syscall error
pub fn loadTransaction(allocator: mem.Allocator) SysError![]u8 {
    return loadData({}, Loader{ .raw = syscalls.loadTransaction }, allocator);
}

/// Load cell
///
/// Return the cell or a syscall error
///
/// # Arguments
///
/// * `index` - index
/// * `source` - source
pub fn loadCell(allocator: mem.Allocator, index: usize, source: Source) SysError![]u8 {
    return loadData(
        .{ .index = index, .source = source },
        Loader{ .by_source = syscalls.loadCell },
        allocator,
    );
}

/// Load input
///
/// Return the input or a syscall error
///
/// # Arguments
///
/// * `index` - index
/// * `source` - source
pub fn loadInput(allocator: mem.Allocator, index: usize, source: Source) SysError![]u8 {
    return loadData(
        .{ .index = index, .source = source },
        Loader{ .by_source = syscalls.loadInput },
        allocator,
    );
}

/// Load header
///
/// Return the header or a syscall error
///
/// # Arguments
///
/// * `index` - index
/// * `source` - source
pub fn loadHeader(allocator: mem.Allocator, index: usize, source: Source) SysError![]u8 {
    return loadData(
        .{ .index = index, .source = source },
        Loader{ .by_source = syscalls.loadHeader },
        allocator,
    );
}

/// Load witness
///
/// Return the witness or a syscall error
///
/// # Arguments
///
/// * `index` - index
/// * `source` - source
pub fn loadWitness(allocator: mem.Allocator, index: usize, source: Source) SysError![]u8 {
    return loadData(
        .{ .index = index, .source = source },
        Loader{ .by_source = syscalls.loadWitness },
        allocator,
    );
}

/// Load cell data
///
/// # Arguments
///
/// * `index` - index
/// * `source` - source
pub fn loadCellData(allocator: mem.Allocator, index: usize, source: Source) SysError![]u8 {
    return loadData(
        .{ .index = index, .source = source },
        Loader{ .by_source = syscalls.loadCellData },
        allocator,
    );
}

/// Load cell capacity
///
/// Return the loaded data length or a syscall error
///
/// # Arguments
///
/// * `index` - index
/// * `source` - source
pub fn loadCellCapacity(index: usize, source: Source) SysError!u64 {
    return loadU64Field(CellField.capacity, syscalls.loadCellByField, 0, index, source);
}

/// Load cell occupied capacity
///
/// # Arguments
///
/// * `index` - index
/// * `source` - source
pub fn loadCellOccupiedCapacity(index: usize, source: Source) SysError!u64 {
    return loadU64Field(CellField.occupied_capacity, syscalls.loadCellByField, 0, index, source);
}

/// Load cell data hash
///
/// # Arguments
///
/// * `index` - index
/// * `source` - source
pub fn loadCellDataHash(index: usize, source: Source) SysError![32]u8 {
    var buf: [32]u8 = undefined;
    const size = try syscalls.loadCellByField(&buf, 0, index, source, CellField.data_hash);
    assert(size == buf.len);
    return buf;
}

/// Load cell lock hash
///
/// # Arguments
///
/// * `index` - index
/// * `source` - source
pub fn loadCellLockHash(index: usize, source: Source) SysError![32]u8 {
    var buf: [32]u8 = undefined;
    const size = try syscalls.loadCellByField(&buf, 0, index, source, CellField.lock_hash);
    assert(size == buf.len);
    return buf;
}

/// Load cell type hash
///
/// return None if the cell has no type
///
/// # Arguments
///
/// * `index` - index
/// * `source` - source
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

/// Load cell lock
///
/// Return the lock script or a syscall error
///
/// # Arguments
///
/// * `index` - index
/// * `source` - source
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

/// Load cell type
///
/// Return the type script or a syscall error, return None if the cell has no type
///
/// # Arguments
///
/// * `index` - index
/// * `source` - source
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

/// Load header epoch number
///
/// # Arguments
///
/// * `index` - index
/// * `source` - source
pub fn loadHeaderEpochNumber(index: usize, source: Source) SysError!u64 {
    return loadU64Field(HeaderField.epoch_number, syscalls.loadHeaderByField, 0, index, source);
}

/// Load header epoch start block number
///
/// # Arguments
///
/// * `index` - index
/// * `source` - source
pub fn loadHeaderEpochStartBlockNumber(index: usize, source: Source) SysError!u64 {
    return loadU64Field(HeaderField.epoch_start_block_number, syscalls.loadHeaderByField, 0, index, source);
}

/// Load header epoch length
///
/// # Arguments
///
/// * `index` - index
/// * `source` - source
pub fn loadHeaderEpochLength(index: usize, source: Source) SysError!u64 {
    return loadU64Field(HeaderField.epoch_length, syscalls.loadHeaderByField, 0, index, source);
}

/// Load input since
///
/// # Arguments
///
/// * `index` - index
/// * `source` - source
pub fn loadInputSince(index: usize, source: Source) SysError!u64 {
    return loadU64Field(InputField.since, syscalls.loadInputByField, 0, index, source);
}

/// Load input out point
///
/// # Arguments
///
/// * `index` - index
/// * `source` - source
pub fn loadInputOutPoint(index: usize, source: Source) SysError![36]u8 {
    var buf: [36]u8 = undefined;
    const size = try syscalls.loadInputByField(&buf, 0, index, source, InputField.out_point);
    assert(size == buf.len);
    return buf;
}

/// Find cell by data_hash
///
/// Iterate and find the cell which data hash equals `data_hash`,
/// return the index of the first cell we found, otherwise return None.
pub fn findCellByDataHash(data_hash: []const u8, source: Source) SysError!?usize {
    var buf: [32]u8 = undefined;
    var index: usize = 0;
    while (true) {
        const size = syscalls.loadCellByField(&buf, 0, index, source, CellField.data_hash) catch |err| {
            switch (err) {
                error.IndexOutOfBound => break,
                else => return err,
            }
        };
        assert(size == buf.len);
        if (mem.eql(u8, &buf, data_hash)) {
            return index;
        }
        index += 1;
    }
    return null;
}

/// Look for a dep cell with specific code hash, code_hash should be a buffer
/// with 32 bytes.
pub fn lookForDepWithHash2(code_hash: []const u8, hash_type: ScriptHashType) SysError!usize {
    const field = switch (hash_type) {
        ScriptHashType.@"type" => CellField.type_hash,
        ScriptHashType.data, ScriptHashType.data1 => CellField.data_hash,
    };
    var index: usize = 0;
    var buf: [32]u8 = undefined;
    while (true) {
        if (syscalls.loadCellByField(&buf, 0, index, Source.cell_dep, field)) |size| {
            assert(size == buf.len);
            if (mem.eql(u8, &buf, code_hash)) {
                return index;
            }
        } else |err| {
            switch (err) {
                error.ItemMissing => {},
                else => return err,
            }
        }
        index += 1;
    }
}
pub fn lookForDepWithDataHash(data_hash: []const u8) SysError!usize {
    return lookForDepWithHash2(data_hash, ScriptHashType.data);
}

/// Exec a cell in cell dep.
///
/// # Arguments
///
/// * `code_hash` - the code hash to search cell in cell deps.
/// * `hash_type` - the hash type to search cell in cell deps.
/// * `argv`      - argv is a two-dimensional array of null terminated strings.
pub fn exec_cell(
    code_hash: []const u8,
    hash_type: ScriptHashType,
    offset: u32,
    length: u32,
    argv: []const [:0]const u8,
) SysError!u64 {
    const index = try lookForDepWithHash2(code_hash, hash_type);
    const bounds: u64 = (@intCast(u64, offset) << 32) | @intCast(u64, length);
    return syscalls.exec(index, Source.cell_dep, 0, bounds, argv);
}

test "check all decls syscalls_wrap" {
    std.testing.refAllDecls(@This());
}
