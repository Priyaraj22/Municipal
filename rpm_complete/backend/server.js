/* server.js — Rajapalayam Municipality Family Survey System */
require('dotenv').config();
const express    = require('express');
const helmet     = require('helmet');
const cors       = require('cors');
const morgan     = require('morgan');
const path       = require('path');

const { testConnection } = require('./config/db');
const errorHandler       = require('./middleware/errorHandler');

const authRoutes      = require('./routes/authRoutes');
const surveyRoutes    = require('./routes/surveyRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');
const indicatorRoutes = require('./routes/indicatorRoutes');
const wardRoutes      = require('./routes/wardRoutes');
const exportRoutes    = require('./routes/exportRoutes');

const app  = express();
const PORT = process.env.PORT || 3000;

/* ── Security ── */
app.use(helmet({
  contentSecurityPolicy: false,  // relaxed for mobile app clients
}));

app.use(cors({
  origin:      process.env.CORS_ORIGIN || '*',
  credentials: true,
}));

/* ── Logging & body parsing ── */
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

/* ── API Routes ── */
app.use('/api/auth',       authRoutes);
app.use('/api/surveys',    surveyRoutes);
app.use('/api/dashboard',  dashboardRoutes);
app.use('/api/indicators', indicatorRoutes);
app.use('/api/wards',      wardRoutes);
app.use('/api/export',     exportRoutes);
app.use('/api/complaints', require('./routes/complaintRoutes'));

/* ── Health check ── */
app.get('/api/health', (_req, res) =>
  res.json({ status: 'ok', timestamp: new Date() })
);

/* ── Serve frontend static files ── */
const frontendPath = path.join(__dirname, '..', 'frontend');
app.use(express.static(frontendPath));
app.get('*', (_req, res) => {
  const indexPath = path.join(frontendPath, 'index.html');
  const fs = require('fs');
  if (fs.existsSync(indexPath)) {
    res.sendFile(indexPath);
  } else {
    res.json({ message: 'Rajapalayam Survey API is running.' });
  }
});

/* ── Error handler (must be last) ── */
app.use(errorHandler);

/* ── Boot ── */
async function start() {
  await testConnection();
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Rajapalayam Survey System running on http://0.0.0.0:${PORT}`);
    console.log(`   Environment : ${process.env.NODE_ENV || 'development'}`);
    console.log(`   Access from phone: http://<YOUR_IP>:${PORT}`);
  });
}

start().catch(err => {
  console.error('Fatal startup error:', err);
  process.exit(1);
});
