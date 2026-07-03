/* services/authService.js */
const bcrypt = require('bcryptjs');
const { pool } = require('../config/db');
const { signToken } = require('../middleware/auth');

async function loginCollector(name, ward) {
  const cleanName = (name || '').trim();
  const cleanWard = Array.isArray(ward) ? ward[0] : (ward || '').trim();

  if (!cleanName) throw Object.assign(new Error('Name is required'), { status: 400 });
  if (!cleanWard) throw Object.assign(new Error('Ward is required'), { status: 400 });

  const { rows: existing } = await pool.query(
    'SELECT id, name, ward FROM collectors WHERE name = $1 AND ward = $2',
    [cleanName, cleanWard]
  );

  let collector;
  if (existing.length) {
    collector = existing[0];
    await pool.query('UPDATE collectors SET last_login = NOW() WHERE id = $1', [collector.id]);
  } else {
    const { rows } = await pool.query(
      `INSERT INTO collectors (name, ward, last_login)
       VALUES ($1, $2, NOW())
       RETURNING id, name, ward`,
      [cleanName, cleanWard]
    );
    collector = rows[0];
  }

  const token = signToken({
    role: 'surveyor',
    id: collector.id,
    name: collector.name,
    ward: collector.ward,
  });

  return {
    token,
    user: { role: 'surveyor', id: collector.id, name: collector.name, ward: collector.ward },
  };
}

async function loginAdmin(password) {
  if (!password) throw Object.assign(new Error('Password is required'), { status: 400 });

  const { rows } = await pool.query(
    "SELECT id, username, password_hash FROM admins WHERE username = 'admin' LIMIT 1"
  );
  if (!rows.length) {
    throw Object.assign(new Error('Admin account not configured'), { status: 500 });
  }

  const admin = rows[0];
  const match = await bcrypt.compare(password, admin.password_hash);
  if (!match) {
    throw Object.assign(new Error('Invalid admin password'), { status: 401 });
  }

  const token = signToken({ role: 'admin', id: admin.id, name: 'Admin' });

  return {
    token,
    user: { role: 'admin', id: admin.id, name: 'Admin', ward: 'All Wards' },
  };
}

async function loginCitizen(phone) {
    if (!phone) throw Object.assign(new Error('Phone number is required'), { status: 400 });

    const { rows } = await pool.query(
        'SELECT survey_id FROM family_members WHERE mobile = $1 LIMIT 1',
        [phone]
    );

    if (rows.length === 0) {
        throw Object.assign(new Error('Mobile number not found in any survey record.'), { status: 404 });
    }

    const surveyId = rows[0].survey_id;

    const token = signToken({
        role: 'citizen',
        phone: phone,
        surveyId: surveyId
    });

    return {
        token,
        surveyId,
        user: { role: 'citizen', phone }
    };
}

module.exports = { loginCollector, loginAdmin, loginCitizen };
