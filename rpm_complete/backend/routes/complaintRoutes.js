const express = require('express');
const router = express.Router();
const { registerComplaint, getMyComplaints, updateComplaintStatus, requestCorrection, getSurveyorCorrections, approveCorrection } = require('../controllers/complaintController');
const { requireAuth, requireAdmin } = require('../middleware/auth');

router.post('/', requireAuth, registerComplaint);
router.get('/my', requireAuth, getMyComplaints);
router.put('/status', requireAdmin, updateComplaintStatus);
router.put('/feedback', requireAuth, submitFeedback);
router.post('/corrections', requireAuth, requestCorrection);
router.get('/corrections/surveyor', requireAuth, getSurveyorCorrections);
router.put('/corrections/:id/approve', requireAuth, approveCorrection);

module.exports = router;
