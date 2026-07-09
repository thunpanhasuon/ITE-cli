const std = @import("std");
const utils = @import("utils.zig");

extern fn cpp_hello() void;

pub fn main(init: std.process.Init) !void {
    std.debug.print("Hello, World! from Zig\n", .{});

    utils.connect();
    cpp_hello();
    
    const io = init.io;
    const allocator = init.arena.allocator();
    
    utils.readFile(io, allocator) catch |err| {
        std.debug.print("Failed to read file: {}\n", .{err});
        return;
    };
}
