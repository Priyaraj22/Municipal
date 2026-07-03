const express = require('express');
const {
  getSurveys, getSurveyById, createSurvey, updateSurvey, deleteSurvey
} = require('../controllers/surveyController');
const { requireAuth, requireAdmin } = require('../middleware/auth');

const router = express.Router();

router.get('/',     requireAuth, getSurveys);
router.get('/:id',  requireAuth, getSurveyById);
router.post('/',    requireAuth, createSurvey);
router.put('/:id',  requireAuth, updateSurvey);
router.delete('/:id', requireAuth, deleteSurvey);
router.delete('/',    requireAdmin, deleteSurvey);   // clear all — admin only

module.exports = router;
