const std = @import("std");

const builtin = std.builtin;
const Target = std.Target;
const RiscvFeature = Target.riscv.Feature;

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    // const target = b.standardTargetOptions(.{});
    var cpu_features_add = Target.Cpu.Feature.Set.empty;
    var cpu_features_sub = Target.Cpu.Feature.Set.empty;
    // support cpu features: [i, m, c, v]
    inline for (.{
        RiscvFeature.@"64bit",
        RiscvFeature.m,
        RiscvFeature.c,
        // TODO add more b extension configs
        RiscvFeature.zbb,
    }) |feature| {
        cpu_features_add.addFeature(@enumToInt(feature));
    }
    inline for (.{
        RiscvFeature.a,
        RiscvFeature.d,
        RiscvFeature.e,
        RiscvFeature.f,
        RiscvFeature.v,
    }) |feature| {
        cpu_features_sub.addFeature(@enumToInt(feature));
    }
    const target = std.zig.CrossTarget{
        .cpu_arch = .riscv64,
        .os_tag = .freestanding,
        .cpu_features_add = cpu_features_add,
        .cpu_features_sub = cpu_features_sub,
        .abi = .none,
    };

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();
    // const mode = builtin.Mode.ReleaseSmall;

    const exe = b.addExecutable("razor", "src/_start.zig");
    // TODO: how to remove this line?
    exe.addAssemblyFile("ckb-std/src/syscall.S");
    exe.addPackagePath("ckb_std", "ckb-std/src/ckb_std.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.single_threaded = true;
    if (mode != .Debug) {
        exe.strip = true;
    }
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/util.zig");
    exe_tests.addAssemblyFile("ckb-std/src/syscall.S");
    exe_tests.addPackagePath("ckb_std", "ckb-std/src/ckb_std.zig");
    exe_tests.setTarget(std.zig.CrossTarget{
        .cpu_arch = .riscv64,
        .os_tag = .linux,
        .abi = .gnu,
    });
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
