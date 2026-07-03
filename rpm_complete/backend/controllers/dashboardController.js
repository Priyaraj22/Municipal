/* controllers/dashboardController.js */
const { getDashboardStats } = require('../services/dashboardService');

async function getDashboard(req, res, next) {
  try {
    const stats = await getDashboardStats();
    res.json(stats);   // Flutter reads the root object directly
  } catch (err) { next(err); }
}

module.exports = { getDashboard };
