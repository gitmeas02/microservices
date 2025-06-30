const express = require('express');
const cors = require('cors');
const { authMiddleware } = require('./middleware/auth');
const authRoutes = require('./routes/auth');
const notificationRoutes = require('./routes/notification');
const paymentRoutes = require('./routes/payment');
const chatRoutes = require('./routes/chat');

const app = express();

app.use(cors());
app.use(express.json());
app.use(authMiddleware);

app.use('/auth', authRoutes);
app.use('/notification', notificationRoutes);
app.use('/payment', paymentRoutes);
app.use('/chat', chatRoutes);

const PORT = process.env.API_GATEWAY_PORT || 8080;
app.listen(PORT, () => {
  console.log(`API Gateway running on port ${PORT}`);
});
