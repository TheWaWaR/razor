const syscalls = @import("syscalls.zig");
const util = @import("util.zig");

const loadTxHash = syscalls.loadTxHash;
const loadScriptHash = syscalls.loadScriptHash;
const loadScript = syscalls.loadScript;
const debug = util.debug;
const print = util.print;

pub fn main(c_argc: i32, c_argv: [*][*:0]u8) i8 {
    debug("c_argc: {}, c_argv: {*}", .{ c_argc, c_argv });

    var hash_buf: [32]u8 = undefined;
    const size_tx_hash = loadTxHash(&hash_buf, 0) catch unreachable;
    print("loadTxHash.length: {}, data: {any}", .{ size_tx_hash, hash_buf });

    const size_script_hash = loadScriptHash(&hash_buf, 0) catch unreachable;
    print("loadScriptHash.length: {}, data: {any}", .{ size_script_hash, hash_buf });

    var script_buf: [1024]u8 = undefined;
    const size_script = loadScript(&script_buf, 0) catch unreachable;
    print("loadScript.length: {}, data: {any}", .{ size_script, script_buf[0..size_script] });

    return 0;
}
