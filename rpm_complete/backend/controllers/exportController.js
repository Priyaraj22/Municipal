/* controllers/exportController.js */
const { generateExcel } = require('../services/exportService');

async function exportExcel(req, res, next) {
  try {
    const filters = {};
    if (req.query.ward)      filters.ward      = req.query.ward;
    if (req.query.collector) filters.collector = req.query.collector;

    const buffer = await generateExcel(filters);

    const dateStr = new Date().toISOString().split('T')[0];
    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename="Rajapalayam_Survey_${dateStr}.xlsx"`);
    res.send(buffer);
  } catch (err) { next(err); }
}

module.exports = { exportExcel };
