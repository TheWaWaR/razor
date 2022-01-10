const ckb_std = @import("ckb_std");
const allocator = @import("root").global_allocator;

const syscalls = ckb_std.syscalls_wrap;
const util = ckb_std.util;
const types = ckb_std.types;
const consts = ckb_std.ckb_constants;

const debug = util.debug;
const print = util.print;
const Source = consts.Source;
const ScriptHashType = types.ScriptHashType;

pub fn main(c_argc: i32, c_argv: [*][*:0]u8) i8 {
    debug(allocator, "c_argc: {}, c_argv: {*}", .{ c_argc, c_argv });

    var tx_hash = syscalls.loadTxHash() catch unreachable;
    print(allocator, "loadTxHash() => data: {any}", .{tx_hash});

    const script_hash = syscalls.loadScriptHash() catch unreachable;
    print(allocator, "loadScriptHash() => data: {any}", .{script_hash});

    const script_buf = syscalls.loadScript(allocator) catch unreachable;
    defer allocator.free(script_buf);
    print(allocator, "loadScript() => length: {}, data: {any}", .{ script_buf.len, script_buf });

    const cell_buf = syscalls.loadCell(allocator, 0, Source.input) catch unreachable;
    defer allocator.free(cell_buf);
    print(allocator, "loadCell(0, input) => length: {}, data: {any}", .{ cell_buf.len, cell_buf });

    const input_buf = syscalls.loadInput(allocator, 0, Source.input) catch unreachable;
    defer allocator.free(input_buf);
    print(allocator, "loadInput(0, input) => length: {}, data: {any}", .{ input_buf.len, input_buf });

    const header_buf = syscalls.loadHeader(allocator, 0, Source.header_dep) catch unreachable;
    defer allocator.free(header_buf);
    print(allocator, "loadHeader(0, header_dep) => length: {}, data: {any}", .{ header_buf.len, header_buf });

    const witness_buf = syscalls.loadWitness(allocator, 0, Source.input) catch unreachable;
    defer allocator.free(witness_buf);
    print(allocator, "loadWitness(0, input) => length: {}, data: {any}", .{ witness_buf.len, witness_buf });

    const cell_data_buf = syscalls.loadCellData(allocator, 0, Source.input) catch unreachable;
    defer allocator.free(cell_data_buf);
    print(allocator, "loadCellData(0, input) => length: {}, data: {any}", .{ cell_data_buf.len, cell_data_buf });

    const cell_capacity = syscalls.loadCellCapacity(0, Source.input) catch unreachable;
    print(allocator, "loadCellCapacity(0, input) => capacity: {}", .{cell_capacity});
    const cell_occupied_capacity = syscalls.loadCellOccupiedCapacity(0, Source.input) catch unreachable;
    print(allocator, "loadCellOccupiedCapacity(0, input) => occupied capacity: {}", .{cell_occupied_capacity});

    const data_hash = syscalls.loadCellDataHash(0, Source.input) catch unreachable;
    print(allocator, "loadCellDataHash(0, input) => data: {any}", .{data_hash});
    const lock_hash = syscalls.loadCellLockHash(0, Source.input) catch unreachable;
    print(allocator, "loadCellLockHash(0, input) => lock: {any}", .{lock_hash});
    const type_hash = syscalls.loadCellTypeHash(0, Source.input) catch unreachable;
    print(allocator, "loadCellTypeHash(0, input) => type: {any}", .{type_hash});

    const lock_buf = syscalls.loadCellLock(allocator, 0, Source.input) catch unreachable;
    defer allocator.free(lock_buf);
    print(allocator, "loadCellLock(0, input) => length: {}, data: {any}", .{ lock_buf.len, lock_buf });
    const type_buf = syscalls.loadCellType(allocator, 0, Source.input) catch unreachable;
    if (type_buf) |buf| {
        defer allocator.free(buf);
        print(allocator, "loadCellType(0, input) => length: {}, data: {any}", .{ buf.len, buf });
    } else {
        print(allocator, "loadCellType(0, input) => null", .{});
    }

    const epoch_number = syscalls.loadHeaderEpochNumber(0, Source.input) catch unreachable;
    print(allocator, "loadHeaderEpochNumber(0, input) => epoch number: {}", .{epoch_number});
    const epoch_start_block_number = syscalls.loadHeaderEpochStartBlockNumber(0, Source.input) catch unreachable;
    print(allocator, "loadHeaderEpochStartBlockNumber(0, input) => epoch start block number: {}", .{epoch_start_block_number});
    const epoch_length = syscalls.loadHeaderEpochLength(0, Source.input) catch unreachable;
    print(allocator, "loadHeaderEpochLength(0, input) => epoch length: {}", .{epoch_length});

    const since = syscalls.loadInputSince(0, Source.input) catch unreachable;
    print(allocator, "loadInputSince(0, input) => since: {}", .{since});
    const out_point_buf = syscalls.loadInputOutPoint(0, Source.input) catch unreachable;
    print(allocator, "loadInputOutPoint(0, input) => data: {any}", .{out_point_buf});

    const index_opt = syscalls.findCellByDataHash(data_hash[0..], Source.input) catch unreachable;
    print(allocator, "findCellByDataHash(data_hash, input) => index: {any}", .{index_opt});

    const index_opt2 = syscalls.lookForDepWithDataHash(data_hash[0..]);
    print(allocator, "lookForDepWithDataHash(data_hash) => index: {any}", .{index_opt2});

    const argv = &[_][:0]const u8{ "a", "bcd" };
    const exec_result = syscalls.exec_cell(data_hash[0..], ScriptHashType.data, 0, 0, argv[0..]);
    print(allocator, "exec_cell(data_hash, data, 0, 0, argv) => result: {any}", .{exec_result});
    return 0;
}
