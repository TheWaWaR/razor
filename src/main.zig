const ckb_std = @import("ckb_std");
const allocator = @import("root").global_allocator;

const syscalls = ckb_std.syscalls_wrap;
const util = ckb_std.util;
const consts = ckb_std.ckb_constants;

const loadTxHash = syscalls.loadTxHash;
const loadScriptHash = syscalls.loadScriptHash;
const loadScript = syscalls.loadScript;
const loadCell = syscalls.loadCell;
const debug = util.debug;
const print = util.print;
const Source = consts.Source;

pub fn main(c_argc: i32, c_argv: [*][*:0]u8) i8 {
    debug("c_argc: {}, c_argv: {*}", .{ c_argc, c_argv }, allocator);

    var tx_hash = loadTxHash() catch unreachable;
    print("loadTxHash, data: {any}", .{tx_hash}, allocator);

    const script_hash = loadScriptHash() catch unreachable;
    print("loadScriptHash, data: {any}", .{script_hash}, allocator);

    const script_buf = loadScript(allocator) catch unreachable;
    defer allocator.free(script_buf);
    print("loadScript, data: {any}", .{script_buf}, allocator);

    const cell_buf = loadCell(allocator, 0, Source.input) catch unreachable;
    defer allocator.free(cell_buf);
    print("loadCell, data: {any}", .{cell_buf}, allocator);

    return 0;
}
