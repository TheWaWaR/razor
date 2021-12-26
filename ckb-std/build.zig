const std = @import("std");

const builtin = std.builtin;
const Target = std.Target;
const RiscvFeature = Target.riscv.Feature;

pub fn build(b: *std.build.Builder) void {
    var cpu_features_add = Target.Cpu.Feature.Set.empty;
    var cpu_features_sub = Target.Cpu.Feature.Set.empty;
    inline for (.{
        RiscvFeature.@"64bit",
        RiscvFeature.c,
        RiscvFeature.m,
    }) |feature| {
        cpu_features_add.addFeature(@enumToInt(feature));
    }
    inline for (.{
        RiscvFeature.a,
        RiscvFeature.d,
        RiscvFeature.e,
        RiscvFeature.f,
        // TODO: will be supported in future update of zig
        RiscvFeature.experimental_b,
        RiscvFeature.experimental_v,
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

    const lib = b.addStaticLibrary("ckb-std", "src/ckb_std.zig");
    lib.addAssemblyFile("src/syscall.S");
    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib.install();

    const lib_tests = b.addTest("src/ckb_std.zig");
    lib_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&lib_tests.step);
}
