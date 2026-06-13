require('dotenv').config();
const express = require('express');
const connectDB = require('./config/db');

const app = express();

connectDB();

app.use(express.json());

app.use('/api', require('./routes/categoryRoutes'));
app.use('/api', require('./routes/lawRoutes'));
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api', require('./routes/bookmarkRoutes'));

app.get('/', (req, res) => {
  res.json({ success: true, message: 'Pocket Court API is running' });
});

app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
