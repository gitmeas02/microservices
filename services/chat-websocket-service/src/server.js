const http = require('http');
const { Server } = require('socket.io');
const { socketAuth } = require('./middleware/socketAuth');
const chatHandler = require('./socketHandlers/chatHandler');

const server = http.createServer();
const io = new Server(server, {
  cors: { origin: '*' }
});

io.use(socketAuth);
io.on('connection', chatHandler);

const PORT = process.env.CHAT_SERVICE_PORT || 8004;
server.listen(PORT, () => {
  console.log(`Chat Websocket Service running on port ${PORT}`);
});
