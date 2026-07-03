/* config/db.js — PostgreSQL connection pool */
const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host:     process.env.DB_HOST     || 'localhost',
  port:     parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME     || 'rajapalayam_survey',
  user:     process.env.DB_USER     || 'postgres',
  password: process.env.DB_PASSWORD || '',
  max: 20,
  idleTimeoutMillis: 10000,
  connectionTimeoutMillis: 10000, // Increased timeout
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle PostgreSQL client', err);
  process.exit(-1);
});

// Test connection on startup
async function testConnection() {
  try {
    const client = await pool.connect();
    const res = await client.query('SELECT NOW() as now');
    client.release();
    console.log(`✅ PostgreSQL connected at ${res.rows[0].now}`);
  } catch (err) {
    console.error('❌ PostgreSQL connection failed:', err.message);
    console.error('   Check your .env DB_* variables and that PostgreSQL is running.');
    process.exit(1);
  }
}

module.exports = { pool, testConnection };
