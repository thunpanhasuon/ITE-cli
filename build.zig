const std = @import("std"); 

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create the main executable compile step
    const exe = b.addExecutable(.{
        .name = "cpp_zig_app",
        .root_source_file = b.path("hello.zig"), // Compiles your Zig source
        .target = target,
        .optimize = optimize,
    });

    // Add your C++ files into the compilation graph
    exe.addCSourceFile(.{
        .file = b.path("main.cpp"),
        .flags = &[_][]const u8{ "-std=c++17" },
    });

    // Mandatory: Link the C++ standard library runtime
    exe.linkLibCpp();

    // Expose the program binary inside 'zig-out/bin/'
    b.installArtifact(exe);
}
