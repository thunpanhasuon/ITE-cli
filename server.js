const http = require("http");
const crypto = require("crypto");

// token -> user, in-memory only (fine for local testing)
const sessions = new Map();

// fake admin key + fake student data, in-memory only, for local testing
const ADMIN_KEY = "supersecretadminkey";
const students = [
  {
    id: 1,
    studentId: "ITE-000",
    firstName: "Seed",
    lastName: "Student",
    ite: "ITE-101",
    iteEmail: "seed@ite.edu",
    iteUsername: "seed",
    itePassword: "password123",
  },
];

const server = http.createServer((req, res) => {
  if (req.method === "GET" && req.url === "/") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ email: "hello@world.com", password: "world" }));
    return;
  }

  if (req.method === "POST" && req.url === "/api/auth/login") {
    let body = "";
    req.on("data", (chunk) => (body += chunk));
    req.on("end", () => {
      const auth = JSON.parse(body);
      const token = crypto.randomBytes(16).toString("hex");
      sessions.set(token, { email: auth.email, password: auth.password });
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ email: auth.email, password: auth.password, token }));
    });
    return;
  }

  if (req.method === "GET" && req.url === "/api/auth/me") {
    const authHeader = req.headers["authorization"] || "";
    const token = authHeader.startsWith("Bearer ") ? authHeader.slice(7) : null;
    const user = token && sessions.get(token);

    if (!user) {
      res.writeHead(401, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: "Unauthorized" }));
      return;
    }

    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ email: user.email, password: user.password, token }));
    return;
  }

  if (req.method === "GET" && req.url.startsWith("/api/students/class/")) {
    if (req.headers["x-admin-key"] !== ADMIN_KEY) {
      res.writeHead(401, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: "Unauthorized" }));
      return;
    }

    const className = decodeURIComponent(req.url.slice("/api/students/class/".length));
    const matches = students.filter((s) => s.ite === className);
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify(matches));
    return;
  }

  if (req.method === "POST" && req.url === "/api/students") {
    if (req.headers["x-admin-key"] !== ADMIN_KEY) {
      res.writeHead(401, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: "Unauthorized" }));
      return;
    }

    let body = "";
    req.on("data", (chunk) => (body += chunk));
    req.on("end", () => {
      const input = JSON.parse(body);
      const student = { id: students.length + 1, ...input };
      students.push(student);
      res.writeHead(201, { "Content-Type": "application/json" });
      res.end(JSON.stringify(student));
    });
    return;
  }

  res.writeHead(404, { "Content-Type": "text/plain" });
  res.end("Not found");
});

server.listen(3000, "localhost", () => {
  console.log("Server running at http://localhost:3000/");
});
