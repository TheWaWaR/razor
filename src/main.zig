const ckb_std = @import("ckb_std");
const global_allocator = @import("root").global_allocator;

const syscalls = ckb_std.syscalls;
const util = ckb_std.util;

const loadTxHash = syscalls.loadTxHash;
const loadScriptHash = syscalls.loadScriptHash;
const loadScript = syscalls.loadScript;
const debug = util.debug;
const print = util.print;

pub fn main(c_argc: i32, c_argv: [*][*:0]u8) i8 {
    debug("c_argc: {}, c_argv: {*}", .{ c_argc, c_argv }, global_allocator);

    var tx_hash = loadTxHash() catch unreachable;
    print("loadTxHash, data: {any}", .{tx_hash}, global_allocator);

    const script_hash = loadScriptHash() catch unreachable;
    print("loadScriptHash, data: {any}", .{script_hash}, global_allocator);

    const script_buf = loadScript(global_allocator) catch unreachable;
    defer global_allocator.free(script_buf);
    print("loadScript, data: {any}", .{script_buf}, global_allocator);

    return 0;
}
