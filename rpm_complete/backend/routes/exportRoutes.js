const express = require('express');
const { exportExcel } = require('../controllers/exportController');

const router = express.Router();

// GET /api/export/excel
router.get('/excel', exportExcel);

module.exports = router;
