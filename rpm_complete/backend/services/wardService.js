/* services/wardService.js */
const { pool } = require('../config/db');

async function getWardProgress() {
  const { rows } = await pool.query(`
    SELECT
      w.id,
      w.ward_name,
      w.ward_no,
      w.lgd_code,
      COUNT(s.id)::int AS families_surveyed,
      STRING_AGG(DISTINCT s.collector, ', ') AS collectors
    FROM wards w
    LEFT JOIN surveys s ON s.ward = w.ward_name
    GROUP BY w.id, w.ward_name, w.ward_no, w.lgd_code
    ORDER BY w.ward_no
  `);

  return rows.map(r => ({
    ward_name:         r.ward_name,
    ward_no:           r.ward_no,
    lgd_code:          r.lgd_code,
    families_surveyed: r.families_surveyed,
    collectors:        r.collectors || '',
  }));
}

async function getWardsList() {
  const { rows } = await pool.query(
    'SELECT id, ward_no, ward_name, lgd_code FROM wards ORDER BY ward_no'
  );
  return rows;
}

module.exports = { getWardProgress, getWardsList };
