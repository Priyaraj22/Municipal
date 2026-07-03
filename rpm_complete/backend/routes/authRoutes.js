const express = require('express');
const { login, requestOtp } = require('../controllers/authController');

const router = express.Router();

// POST /api/auth/login
router.post('/login', login);
router.post('/request-otp', requestOtp);

module.exports = router;
