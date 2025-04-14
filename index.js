const express = require("express");
const fs = require("fs");
const path = require("path");
const net = require("net");

const app = express();
const port = 8080;
const mappingPath = path.join(__dirname, "proxies.json");
require("dotenv").config();

// Enable CORS for all routes
app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept"
  );
  next();
});

// Serve proxies.json
app.get("/proxies.json", (req, res) => {
  try {
    const data = fs.readFileSync(mappingPath, "utf8");
    res.type("application/json");
    res.send(data);
  } catch (err) {
    res.status(404).json({ error: "Proxies configuration not found" });
  }
});

// Endpoint to request new Tor identity
app.post("/newnym/:country", async (req, res) => {
  const country = req.params.country.toLowerCase();

  let mapping;
  try {
    mapping = JSON.parse(fs.readFileSync(mappingPath, "utf8"));
  } catch (err) {
    return res.status(500).json({ error: "Failed to read proxies.json" });
  }

  const proxy = mapping[country];
  if (!proxy) {
    return res
      .status(404)
      .json({ error: `No proxy found for country '${country}'` });
  }

  try {
    await sendSignalNewnym(proxy.control_port);
    res.json({
      success: true,
      message: `New identity requested for ${country}`,
    });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// Function to send SIGNAL NEWNYM
function sendSignalNewnym(controlPort) {
  return new Promise((resolve, reject) => {
    const socket = net.connect(controlPort, "127.0.0.1");
    const passwd = "tor_proxy";

    let response = "";
    let state = "auth"; // Keep track of what we’re doing

    socket.setTimeout(3000);

    socket.on("connect", () => {
      socket.write(`AUTHENTICATE "${passwd}"\r\n`);
    });

    socket.on("data", (chunk) => {
      response += chunk.toString();

      if (state === "auth" && response.includes("250 OK")) {
        // Auth succeeded, now request new identity
        response = "";
        state = "newnym";
        socket.write("SIGNAL NEWNYM\r\nQUIT\r\n");
      }
    });

    socket.on("end", () => {
      if (state === "newnym" && response.includes("250 OK")) {
        resolve();
      } else {
        reject(new Error("Tor did not respond with 250 OK:\n" + response));
      }
    });

    socket.on("timeout", () => {
      socket.end();
      reject(new Error("Tor ControlPort request timed out"));
    });

    socket.on("error", (err) => {
      reject(new Error("Socket error: " + err.message));
    });
  });
}

app.listen(port, "0.0.0.0", () => {
  console.log(`Server running at http://0.0.0.0:${port}`);
});
