/* controllers/indicatorController.js */
const { getIndicators } = require('../services/indicatorService');

async function getIndicatorsHandler(req, res, next) {
  try {
    const filters = {};
    if (req.query.ward)      filters.ward      = req.query.ward;
    if (req.query.collector) filters.collector = req.query.collector;
    const indicators = await getIndicators(filters);
    res.json({ indicators });
  } catch (err) { next(err); }
}

module.exports = { getIndicators: getIndicatorsHandler };
