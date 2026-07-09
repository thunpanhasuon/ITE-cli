const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zig_obj = b.addObject(.{
        .name = "utils_zig",
        .root_module = b.createModule(.{
            .root_source_file = b.path("./src/utils.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const exe = b.addExecutable(.{
        .name = "utils",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libcpp = true,
        }),
    });

    exe.root_module.addCSourceFile(.{
        .file = b.path("main.cpp"),
        .flags = &[_][]const u8{"-std=c++17"},
    });
    exe.root_module.addObject(zig_obj);

    b.installArtifact(exe);
}
