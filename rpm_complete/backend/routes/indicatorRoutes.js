const express = require('express');
const { getIndicators } = require('../controllers/indicatorController');

const router = express.Router();

// GET /api/indicators
router.get('/', getIndicators);

module.exports = router;
