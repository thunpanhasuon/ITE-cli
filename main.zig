const std = @import("std");
const login = @import("login.zig");
const admin = @import("admin.zig");

const User = struct {
    email: []const u8,
    password: []const u8,
};

/// Connects to the local server, fetches the response body, and parses it
/// into a `User`. Caller owns the returned `std.json.Parsed(User)` and must
/// call `.deinit()` on it.
fn server_connection(gpa: std.mem.Allocator, io: std.Io) !std.json.Parsed(User) {
    var client: std.http.Client = .{ .allocator = gpa, .io = io };
    defer client.deinit();

    var response_body: std.Io.Writer.Allocating = .init(gpa);
    defer response_body.deinit();

    const result = try client.fetch(.{
        .method = .GET,
        .location = .{ .url = "http://localhost:3000/" },
        .response_writer = &response_body.writer,
    });

    if (result.status != .ok) {
        std.debug.print("HTTP Error: {}\n", .{result.status});
        return error.HttpRequestFailed;
    }

    return std.json.parseFromSlice(
        User,
        gpa,
        response_body.written(),
        .{
            .ignore_unknown_fields = true,
            .allocate = .alloc_always,
        },
    );
}

pub fn main(init: std.process.Init) !void {
    // setting up commandline argument
    //
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);

    const gpa = init.gpa;

    if (args.len < 2) {
        std.debug.print("Usage: {s} <login> <email> <password>\n", .{args[0]});
        return;
    }

    if (std.mem.eql(u8, args[1], "login")) {
        if (args.len < 4) {
            std.debug.print("Usage: {s} login <email> <password>\n", .{args[0]});
            return;
        }

        const parsed = try login.loginUser(gpa, init.io, args[2], args[3]);
        defer parsed.deinit();

        const user = parsed.value;
        std.debug.print("User Email: {s}\n", .{user.email});
        std.debug.print("User Password: {s}\n", .{user.password});
        std.debug.print("Token saved: {s}\n", .{user.token});
        return;
    }

    if (std.mem.eql(u8, args[1], "me")) {
        const parsed = try login.me(gpa, init.io);
        defer parsed.deinit();

        const user = parsed.value;
        std.debug.print("User Email: {s}\n", .{user.email});
        std.debug.print("User Password: {s}\n", .{user.password});
        return;
    }

    if (std.mem.eql(u8, args[1], "admin-key")) {
        if (args.len < 3) {
            std.debug.print("Usage: {s} admin-key <key>\n", .{args[0]});
            return;
        }
        try admin.saveAdminKey(init.io, args[2]);
        std.debug.print("Admin key saved.\n", .{});
        return;
    }

    if (std.mem.eql(u8, args[1], "students")) {
        if (args.len < 3) {
            std.debug.print("Usage: {s} students <class>\n", .{args[0]});
            return;
        }
        try admin.getStudentsByClass(gpa, init.io, args[2]);
        return;
    }

    if (std.mem.eql(u8, args[1], "add-student")) {
        const path = if (args.len >= 3) args[2] else "student.json";
        try admin.addStudent(gpa, init.io, path);
        return;
    }

    const parsed = try server_connection(gpa, init.io);
    defer parsed.deinit();

    const user = parsed.value;
    std.debug.print("User Email: {s}\n", .{user.email});
    std.debug.print("User Password: {s}\n", .{user.password});
}
