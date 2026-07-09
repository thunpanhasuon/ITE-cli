const std = @import("std");

pub fn connect() void {
    std.debug.print("Hello From Zig\n", .{});
}

pub fn readFile(io: std.Io, allocator: std.mem.Allocator) !void {
    const max_file_size = 10 * 1024 * 1024;
    const content = try std.Io.Dir.cwd().readFileAlloc(
        io,
        "src/data.json",
        allocator,
        .limited(max_file_size),
    );
    defer allocator.free(content);

    std.debug.print("File Content: {s}\n", .{content});
}
