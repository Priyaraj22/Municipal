const express = require('express');
const { getWardProgress, getWards } = require('../controllers/wardController');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

router.get('/progress', requireAuth, getWardProgress);
router.get('/',         requireAuth, getWards);

module.exports = router;
