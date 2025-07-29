const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "shadowsocks-zig",
        .root_module = b.addModule("main", .{
            .root_source_file = .{ .cwd_relative = "src/main.zig" },
            .target = target,
            .optimize = mode,
        }),
    });
    exe.root_module.addAnonymousImport("network", .{ .root_source_file = .{ .cwd_relative = "libs/zig-network/network.zig" } });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest(.{
        .root_module = b.addModule("main-test", .{
            .root_source_file = .{ .cwd_relative = "src/main.zig" },
            .target = target,
            .optimize = mode,
        }),
    });
    exe_tests.root_module.addAnonymousImport("network", .{ .root_source_file = .{ .cwd_relative = "libs/zig-network/network.zig" } });

    const shadowsocks_tests = b.addTest(.{
        .name = "shadowsocks-test",
        .root_module = b.addModule("shadowsocks-test", .{
            .root_source_file = .{ .cwd_relative = "src/shadowsocks.zig" },
            .target = target,
            .optimize = mode,
        }),
    });
    shadowsocks_tests.root_module.addAnonymousImport("network", .{ .root_source_file = .{ .cwd_relative = "libs/zig-network/network.zig" } });
    b.installArtifact(shadowsocks_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
    test_step.dependOn(&shadowsocks_tests.step);
}
