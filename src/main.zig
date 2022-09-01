const ckb_std = @import("ckb_std");
const allocator = @import("root").global_allocator;

const syscalls = ckb_std.syscalls_wrap;
const util = ckb_std.util;
const types = ckb_std.types;
const consts = ckb_std.ckb_constants;

const debug = util.debug;
const Source = consts.Source;
const ScriptHashType = types.ScriptHashType;

pub fn main(c_argc: i32, c_argv: [*][*:0]u8) i8 {
    debug(allocator, "c_argc: {}, c_argv: {*}", .{ c_argc, c_argv });

    var tx_hash = syscalls.loadTxHash() catch @panic("load tx hash");
    debug(allocator, "loadTxHash() => data: {any}", .{tx_hash});

    const script_hash = syscalls.loadScriptHash() catch @panic("load script hash");
    debug(allocator, "loadScriptHash() => data: {any}", .{script_hash});

    const script_buf = syscalls.loadScript(allocator) catch @panic("load script");
    defer allocator.free(script_buf);
    debug(allocator, "loadScript() => length: {}, data: {any}", .{ script_buf.len, script_buf });

    const cell_buf = syscalls.loadCell(allocator, 0, Source.input) catch @panic("load cell");
    defer allocator.free(cell_buf);
    debug(allocator, "loadCell(0, input) => length: {}, data: {any}", .{ cell_buf.len, cell_buf });

    const input_buf = syscalls.loadInput(allocator, 0, Source.input) catch @panic("load input");
    defer allocator.free(input_buf);
    debug(allocator, "loadInput(0, input) => length: {}, data: {any}", .{ input_buf.len, input_buf });

    if (syscalls.loadHeader(allocator, 0, Source.header_dep)) |header_buf| {
        defer allocator.free(header_buf);
        debug(allocator, "loadHeader(0, header_dep) => length: {}, data: {any}", .{ header_buf.len, header_buf });
    } else |err| {
        debug(allocator, "loadHeader(0, header_buf) => error: {any}", .{err});
    }

    const witness_buf = syscalls.loadWitness(allocator, 0, Source.input) catch @panic("load witness");
    defer allocator.free(witness_buf);
    debug(allocator, "loadWitness(0, input) => length: {}, data: {any}", .{ witness_buf.len, witness_buf });

    const cell_data_buf = syscalls.loadCellData(allocator, 0, Source.input) catch @panic("load cell data");
    defer allocator.free(cell_data_buf);
    debug(allocator, "loadCellData(0, input) => length: {}, data: {any}", .{ cell_data_buf.len, cell_data_buf });

    const cell_capacity = syscalls.loadCellCapacity(0, Source.input) catch @panic("load cell capacity");
    debug(allocator, "loadCellCapacity(0, input) => capacity: {}", .{cell_capacity});
    const cell_occupied_capacity = syscalls.loadCellOccupiedCapacity(0, Source.input) catch @panic("load cell occupied capacity");
    debug(allocator, "loadCellOccupiedCapacity(0, input) => occupied capacity: {}", .{cell_occupied_capacity});

    const data_hash = syscalls.loadCellDataHash(0, Source.input) catch @panic("load cell data hash");
    debug(allocator, "loadCellDataHash(0, input) => data: {any}", .{data_hash});
    const lock_hash = syscalls.loadCellLockHash(0, Source.input) catch @panic("load cell lock hash");
    debug(allocator, "loadCellLockHash(0, input) => lock: {any}", .{lock_hash});
    const type_hash = syscalls.loadCellTypeHash(0, Source.input) catch @panic("load cell type hash");
    debug(allocator, "loadCellTypeHash(0, input) => type: {any}", .{type_hash});

    const lock_buf = syscalls.loadCellLock(allocator, 0, Source.input) catch @panic("load cell lock");
    defer allocator.free(lock_buf);
    debug(allocator, "loadCellLock(0, input) => length: {}, data: {any}", .{ lock_buf.len, lock_buf });
    if (syscalls.loadCellType(allocator, 0, Source.input)) |type_buf_opt| {
        if (type_buf_opt) |buf| {
            defer allocator.free(buf);
            debug(allocator, "loadCellType(0, input) => length: {}, data: {any}", .{ buf.len, buf });
        } else {
            debug(allocator, "loadCellType(0, input) => null", .{});
        }
    } else |err| {
        debug(allocator, "loadCellType(0, input) => error: {}", .{err});
    }

    if (syscalls.loadHeaderEpochNumber(0, Source.input)) |epoch_number| {
        debug(allocator, "loadHeaderEpochNumber(0, input) => epoch number: {}", .{epoch_number});
    } else |err| {
        debug(allocator, "loadHeaderEpochNumber(0, input) => error: {}", .{err});
    }
    if (syscalls.loadHeaderEpochStartBlockNumber(0, Source.input)) |epoch_start_block_number| {
        debug(allocator, "loadHeaderEpochStartBlockNumber(0, input) => epoch start block number: {}", .{epoch_start_block_number});
    } else |err| {
        debug(allocator, "loadHeaderEpochStartBlockNumber(0, input) => error: {}", .{err});
    }
    if (syscalls.loadHeaderEpochLength(0, Source.input)) |epoch_length| {
        debug(allocator, "loadHeaderEpochLength(0, input) => epoch length: {}", .{epoch_length});
    } else |err| {
        debug(allocator, "loadHeaderEpochLength(0, input) => error: {}", .{err});
    }

    if (syscalls.loadInputSince(0, Source.input)) |since| {
        debug(allocator, "loadInputSince(0, input) => since: {}", .{since});
    } else |err| {
        debug(allocator, "loadInputSince(0, input) => error: {}", .{err});
    }
    if (syscalls.loadInputOutPoint(0, Source.input)) |out_point_buf| {
        debug(allocator, "loadInputOutPoint(0, input) => data: {any}", .{out_point_buf});
    } else |err| {
        debug(allocator, "loadInputOutPoint(0, input) => erorr: {}", .{err});
    }

    if (syscalls.findCellByDataHash(data_hash[0..], Source.input)) |index_opt| {
        debug(allocator, "findCellByDataHash(data_hash, input) => index: {any}", .{index_opt});
    } else |err| {
        debug(allocator, "findCellByDataHash(data_hash, input) => error: {}", .{err});
    }

    const index_opt2 = syscalls.lookForDepWithDataHash(data_hash[0..]);
    debug(allocator, "lookForDepWithDataHash(data_hash) => index: {any}", .{index_opt2});

    const argv = &[_][:0]const u8{ "a", "bcd" };
    const exec_result = syscalls.exec_cell(data_hash[0..], ScriptHashType.data, 0, 0, argv[0..]);
    debug(allocator, "exec_cell(data_hash, data, 0, 0, argv) => result: {any}", .{exec_result});
    return 0;
}
