const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "utils",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libcpp = true,
        }),
    });

    exe.root_module.addCSourceFile(.{
        .file = b.path("src/hello.cpp"),
        .flags = &[_][]const u8{"-std=c++17"},
    });

    b.installArtifact(exe);
}
