
extern fn syscall(a0: u64, a1: u64, a2: u64, a3: u64, a4: u64, a5: u64, _: u64, a7: u64) u64;

pub fn debug(msg: []const u8) void {
    _ = syscall(@ptrToInt(&msg[0]), 0, 0, 0, 0, 0, 0, 2177);
}
pub fn exit(code: i8) noreturn {
    _ = syscall(@intCast(u64, @bitCast(u8, code)), 0, 0, 0, 0, 0, 0, 93);
    while (true) {}
}
