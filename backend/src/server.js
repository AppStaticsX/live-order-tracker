const http = require('http');
const app = require('./app');
const { Server } = require("socket.io");
const socketHandler = require('./sockets/socketHandler');

const port = process.env.PORT || 3000;

const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*", // Allow all origins for simplicity in this demo
    methods: ["GET", "POST"]
  }
});

socketHandler(io);

server.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
