const std = @import("std");

/// Credentials sent to the server for authentication.
pub const UserAuth = struct {
    email: []const u8,
    password: []const u8,
};

/// User record returned by the server after a successful login.
pub const User = struct {
    email: []const u8,
    password: []const u8,
    token: []const u8,
};

const token_file_name = ".classmgr_token";

/// Writes the session token to a local file so later commands can reuse it.
fn saveToken(io: std.Io, token: []const u8) !void {
    const dir = std.Io.Dir.cwd();
    var file = try dir.createFile(io, token_file_name, .{});
    defer file.close(io);
    try file.writeStreamingAll(io, token);
}

/// Reads the session token previously saved by `loginUser`.
pub fn readToken(gpa: std.mem.Allocator, io: std.Io) ![]u8 {
    const dir = std.Io.Dir.cwd();
    var file = try dir.openFile(io, token_file_name, .{});
    defer file.close(io);

    const stat = try file.stat(io);
    const buf = try gpa.alloc(u8, @intCast(stat.size));
    errdefer gpa.free(buf);

    var read_buf: [256]u8 = undefined;
    var reader = file.reader(io, &read_buf);
    try reader.interface.readSliceAll(buf);

    return buf;
}

/// Calls the server's `/api/auth/me` endpoint using the saved token as a
/// bearer token, to confirm the client can round-trip an authenticated
/// request. Caller owns the returned `std.json.Parsed(User)`.
pub fn me(gpa: std.mem.Allocator, io: std.Io) !std.json.Parsed(User) {
    const token = try readToken(gpa, io);
    defer gpa.free(token);

    const auth_header = try std.fmt.allocPrint(gpa, "Bearer {s}", .{token});
    defer gpa.free(auth_header);

    var client: std.http.Client = .{ .allocator = gpa, .io = io };
    defer client.deinit();

    var response_body: std.Io.Writer.Allocating = .init(gpa);
    defer response_body.deinit();

    const result = try client.fetch(.{
        .method = .GET,
        .location = .{ .url = "http://localhost:3000/api/auth/me" },
        .extra_headers = &.{.{ .name = "Authorization", .value = auth_header }},
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

/// Connects to the server and authenticates a regular user by posting
/// `UserAuth` as JSON to `/users/login`. Caller owns the returned
/// `std.json.Parsed(User)` and must call `.deinit()` on it.
///
/// Admin login will get its own function later; this only handles users.
pub fn loginUser(
    gpa: std.mem.Allocator,
    io: std.Io,
    email: []const u8,
    password: []const u8,
) !std.json.Parsed(User) {
    var client: std.http.Client = .{ .allocator = gpa, .io = io };
    defer client.deinit();

    const auth: UserAuth = .{ .email = email, .password = password };

    var payload: std.Io.Writer.Allocating = .init(gpa);
    defer payload.deinit();
    try std.json.Stringify.value(auth, .{}, &payload.writer);

    var response_body: std.Io.Writer.Allocating = .init(gpa);
    defer response_body.deinit();

    const result = try client.fetch(.{
        .method = .POST,
        .location = .{ .url = "http://localhost:3000/api/auth/login" },
        .payload = payload.written(),
        .headers = .{ .content_type = .{ .override = "application/json" } },
        .response_writer = &response_body.writer,
    });

    if (result.status != .ok) {
        std.debug.print("HTTP Error: {}\n", .{result.status});
        return error.HttpRequestFailed;
    }

    const parsed = try std.json.parseFromSlice(
        User,
        gpa,
        response_body.written(),
        .{
            .ignore_unknown_fields = true,
            .allocate = .alloc_always,
        },
    );

    try saveToken(io, parsed.value.token);

    return parsed;
}
