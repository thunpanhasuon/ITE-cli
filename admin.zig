const std = @import("std");

const admin_key_file_name = ".classmgr_admin_key";

/// Saves the admin key to a local file so later admin commands can reuse it.
pub fn saveAdminKey(io: std.Io, key: []const u8) !void {
    const dir = std.Io.Dir.cwd();
    var file = try dir.createFile(io, admin_key_file_name, .{});
    defer file.close(io);
    try file.writeStreamingAll(io, key);
}

/// Reads the admin key previously saved by `saveAdminKey`. Caller owns the
/// returned slice.
fn readAdminKey(gpa: std.mem.Allocator, io: std.Io) ![]u8 {
    return readFile(gpa, io, admin_key_file_name);
}

/// Reads an entire file's contents into an allocated buffer. Caller owns
/// the returned slice.
fn readFile(gpa: std.mem.Allocator, io: std.Io, path: []const u8) ![]u8 {
    const dir = std.Io.Dir.cwd();
    var file = try dir.openFile(io, path, .{});
    defer file.close(io);

    const stat = try file.stat(io);
    const buf = try gpa.alloc(u8, @intCast(stat.size));
    errdefer gpa.free(buf);

    var read_buf: [4096]u8 = undefined;
    var reader = file.reader(io, &read_buf);
    try reader.interface.readSliceAll(buf);

    return buf;
}

/// Fetches all students in a class and prints the raw JSON response.
/// Admins just want the JSON, no pretty printing.
pub fn getStudentsByClass(gpa: std.mem.Allocator, io: std.Io, class_name: []const u8) !void {
    const admin_key = try readAdminKey(gpa, io);
    defer gpa.free(admin_key);

    const url = try std.fmt.allocPrint(gpa, "http://localhost:3000/api/students/class/{s}", .{class_name});
    defer gpa.free(url);

    var client: std.http.Client = .{ .allocator = gpa, .io = io };
    defer client.deinit();

    var response_body: std.Io.Writer.Allocating = .init(gpa);
    defer response_body.deinit();

    const result = try client.fetch(.{
        .method = .GET,
        .location = .{ .url = url },
        .extra_headers = &.{.{ .name = "x-admin-key", .value = admin_key }},
        .response_writer = &response_body.writer,
    });

    if (result.status != .ok and result.status != .created) {
        std.debug.print("HTTP Error: {}\n", .{result.status});
        return error.HttpRequestFailed;
    }

    std.debug.print("{s}\n", .{response_body.written()});
}

/// Reads a student JSON file (default "student.json") and POSTs it as-is
/// to `/api/students`, then prints the raw JSON response.
pub fn addStudent(gpa: std.mem.Allocator, io: std.Io, path: []const u8) !void {
    const admin_key = try readAdminKey(gpa, io);
    defer gpa.free(admin_key);

    const payload = try readFile(gpa, io, path);
    defer gpa.free(payload);

    var client: std.http.Client = .{ .allocator = gpa, .io = io };
    defer client.deinit();

    var response_body: std.Io.Writer.Allocating = .init(gpa);
    defer response_body.deinit();

    const result = try client.fetch(.{
        .method = .POST,
        .location = .{ .url = "http://localhost:3000/api/students" },
        .payload = payload,
        .headers = .{ .content_type = .{ .override = "application/json" } },
        .extra_headers = &.{.{ .name = "x-admin-key", .value = admin_key }},
        .response_writer = &response_body.writer,
    });

    if (result.status != .ok and result.status != .created) {
        std.debug.print("HTTP Error: {}\n", .{result.status});
        return error.HttpRequestFailed;
    }

    std.debug.print("{s}\n", .{response_body.written()});
}
