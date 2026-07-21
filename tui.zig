const std = @import("std");

/// Mirrors the `students` Drizzle table schema.
pub const Student = struct {
    id: i64,

    student_id: []const u8,
    first_name: []const u8,
    last_name: []const u8,
    full_name_khmer: ?[]const u8 = null,
    date_of_birth: ?[]const u8 = null,
    place_of_birth: ?[]const u8 = null,
    gender: ?[]const u8 = null,
    nationality: ?[]const u8 = null,
    ethnicity: ?[]const u8 = null,
    civil_status: ?[]const u8 = null,

    ite: []const u8,
    grade_level: ?[]const u8 = null,

    address: ?[]const u8 = null,
    phone_number: ?[]const u8 = null,
    passport_number: ?[]const u8 = null,

    ite_email: []const u8,
    ite_username: []const u8,
    ite_password: []const u8,

    enrollment_date: ?[]const u8 = null,

    create_at: []const u8,
    updated_at: []const u8,
};

const box_width = 60;
const label_width = 18;
const value_width = box_width - 2 - 2 - label_width - 2;

fn printRule(left: []const u8, mid: []const u8, right: []const u8) void {
    std.debug.print("{s}", .{left});
    for (0..box_width - 2) |_| std.debug.print("{s}", .{mid});
    std.debug.print("{s}\n", .{right});
}

fn printTitle(title: []const u8) void {
    const pad = if (title.len < box_width - 3) box_width - 3 - title.len else 0;
    std.debug.print("│ {s}", .{title});
    for (0..pad) |_| std.debug.print(" ", .{});
    std.debug.print("│\n", .{});
}

fn printField(label: []const u8, value: ?[]const u8) void {
    const shown = value orelse "-";
    const label_pad = if (label.len < label_width) label_width - label.len else 0;

    std.debug.print("│ {s}", .{label});
    for (0..label_pad) |_| std.debug.print(" ", .{});
    std.debug.print(": ", .{});

    if (shown.len <= value_width) {
        std.debug.print("{s}", .{shown});
        for (0..value_width - shown.len) |_| std.debug.print(" ", .{});
    } else {
        std.debug.print("{s}", .{shown[0..value_width]});
    }
    std.debug.print(" │\n", .{});
}

fn printSection(name: []const u8) void {
    printRule("├", "─", "┤");
    printTitle(name);
    printRule("├", "─", "┤");
}

/// Pretty-prints a `Student` as a bordered, aligned card.
pub fn printStudent(student: Student) void {
    printRule("┌", "─", "┐");

    var name_buf: [128]u8 = undefined;
    const full_name = std.fmt.bufPrint(&name_buf, "{s} {s}", .{ student.first_name, student.last_name }) catch student.first_name;
    printTitle(full_name);
    if (student.full_name_khmer) |khmer| printTitle(khmer);

    printSection("Identity");
    var id_buf: [32]u8 = undefined;
    const id_str = std.fmt.bufPrint(&id_buf, "{d}", .{student.id}) catch "?";
    printField("ID", id_str);
    printField("Student ID", student.student_id);
    printField("Date of Birth", student.date_of_birth);
    printField("Place of Birth", student.place_of_birth);
    printField("Gender", student.gender);
    printField("Nationality", student.nationality);
    printField("Ethnicity", student.ethnicity);
    printField("Civil Status", student.civil_status);

    printSection("Academic");
    printField("ITE", student.ite);
    printField("Grade Level", student.grade_level);
    printField("Enrollment Date", student.enrollment_date);

    printSection("Contact");
    printField("Address", student.address);
    printField("Phone Number", student.phone_number);
    printField("Passport Number", student.passport_number);

    printSection("Account");
    printField("ITE Email", student.ite_email);
    printField("ITE Username", student.ite_username);
    printField("ITE Password", student.ite_password);

    printSection("Timestamps");
    printField("Created At", student.create_at);
    printField("Updated At", student.updated_at);

    printRule("└", "─", "┘");
}

pub fn main() void {
    const sample: Student = .{
        .id = 1,
        .student_id = "STU-2026-001",
        .first_name = "Alice",
        .last_name = "Nguyen",
        .full_name_khmer = "អាលីស",
        .date_of_birth = "2004-03-12",
        .place_of_birth = "Phnom Penh",
        .gender = "Female",
        .nationality = "Cambodian",
        .ethnicity = "Khmer",
        .civil_status = "Single",
        .ite = "ITE-CS-101",
        .grade_level = "Year 2",
        .address = "Street 210, Phnom Penh",
        .phone_number = "012 345 678",
        .passport_number = "N1234567",
        .ite_email = "alice@ite.edu",
        .ite_username = "alice.nguyen",
        .ite_password = "********",
        .enrollment_date = "2024-09-01",
        .create_at = "2024-09-01T08:00:00Z",
        .updated_at = "2026-07-21T10:00:00Z",
    };

    printStudent(sample);
}
