const std = @import("std");
const Target = std.Target;

pub fn build(b: *std.build.Builder) void {
    var sub_set = Target.Cpu.Feature.Set.empty;
    const rv64_m: Target.riscv.Feature = .m;
    const rv64_a: Target.riscv.Feature = .a;
    const rv64_c: Target.riscv.Feature = .c;
    sub_set.addFeature(@enumToInt(rv64_m));
    sub_set.addFeature(@enumToInt(rv64_a));
    sub_set.addFeature(@enumToInt(rv64_c));

    const target = std.zig.CrossTarget{
        .cpu_arch = Target.Cpu.Arch.riscv64,
        .os_tag = Target.Os.Tag.freestanding,
        .abi = Target.Abi.none,
        .cpu_features_sub = sub_set,
    };

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("zig-riscv64", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
