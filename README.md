# itecli

A CLI client, written in Zig, for talking to a class/student management API.
`server.js` in this repo is a minimal Node HTTP server used as a local example
backend to develop and test the client against — it is not production code.

## Stack

- **Client:** Zig 0.16 (`std.http.Client`, `std.json`, `std.process.Init`)
- **Example server:** Node.js (`node:http`, no dependencies)
- **Auth:** bearer token for users, `x-admin-key` header for admin routes
- **Data model:** `Student` struct mirrors a Drizzle `students` table schema

## Project layout

- `main.zig` — CLI entry point and subcommand dispatch
- `login.zig` — user auth: login, session token persistence, `/me`
- `admin.zig` — admin auth: admin key persistence, list/add students
- `tui.zig` — pretty-prints a `Student` as a bordered card in the terminal
- `server.js` — example Node server with fake in-memory data, for local testing only
- `build.zig` / `build.zig.zon` — Zig build configuration

## Setup

Requires Zig 0.16 and Node.js.

```bash
zig build
```

The `itecli` binary is produced at `zig-out/bin/itecli`.

Start the example server in a separate terminal (defaults to `localhost:3000`):

```bash
node server.js
```

## Commands

### User

```bash
# Log in; saves a session token to .classmgr_token
itecli login <email> <password>

# Fetch the current user using the saved token
itecli me
```

### Admin

```bash
# Save the admin key to .classmgr_admin_key
itecli admin-key <key>

# List students in a class (raw JSON output)
itecli students <class>

# Add a student from a JSON file (default: student.json)
itecli add-student [path]
```

`student.json` should match the server's expected shape, e.g.:

```json
{
  "studentId": "ITE-001",
  "firstName": "Alice",
  "lastName": "Nguyen",
  "ite": "ITE-101",
  "iteEmail": "alice@ite.edu",
  "iteUsername": "alice",
  "itePassword": "password123"
}
```

## Notes

- `.classmgr_token` and `.classmgr_admin_key` are written to the working
  directory by `login` and `admin-key`; both are git-ignored.
- `server.js` stores everything in memory and resets on restart — it exists
  purely to exercise the client, not as a real backend.
