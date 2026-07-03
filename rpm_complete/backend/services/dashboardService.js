/* services/dashboardService.js */
const { pool } = require('../config/db');

async function getDashboardStats() {
  const today = new Date().toLocaleDateString('en-IN');

  const [familiesRes, membersRes, wardsRes, todayRes,
         bplRes, casteRes, genderRes, insuranceRes] = await Promise.all([
    pool.query('SELECT COUNT(*) FROM surveys'),
    pool.query('SELECT COUNT(*) FROM family_members'),
    pool.query('SELECT COUNT(DISTINCT ward) FROM surveys'),
    pool.query('SELECT COUNT(*) FROM surveys WHERE survey_date = $1', [today]),
    pool.query(`SELECT COALESCE(bpl,'Unknown') AS label, COUNT(*) AS cnt FROM surveys GROUP BY bpl`),
    pool.query(`SELECT COALESCE(caste,'Unknown') AS label, COUNT(*) AS cnt FROM surveys GROUP BY caste ORDER BY cnt DESC`),
    pool.query(`SELECT COALESCE(gender,'Unknown') AS label, COUNT(*) AS cnt FROM family_members GROUP BY gender`),
    pool.query(`SELECT COALESCE(insurance,'Unknown') AS label, COUNT(*) AS cnt FROM surveys GROUP BY insurance`),
  ]);

  const toMap = rows => {
    const m = {};
    rows.forEach(r => { m[r.label] = parseInt(r.cnt, 10); });
    return m;
  };

  return {
    // Flutter DashboardData.fromJson expects these exact keys
    families:    parseInt(familiesRes.rows[0].count, 10),
    members:     parseInt(membersRes.rows[0].count, 10),
    activeWards: parseInt(wardsRes.rows[0].count, 10),
    today:       parseInt(todayRes.rows[0].count, 10),
    bplCounts:       toMap(bplRes.rows),
    casteCounts:     toMap(casteRes.rows),
    genderCounts:    toMap(genderRes.rows),
    insuranceCounts: toMap(insuranceRes.rows),
  };
}

module.exports = { getDashboardStats };
