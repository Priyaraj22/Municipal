/* controllers/surveyController.js */
const {
  listSurveys, fetchSurvey, submitSurvey, modifySurvey,
  removeSurvey, clearAllSurveys
} = require('../services/surveyService');

async function getSurveys(req, res, next) {
  try {
    const filters = {};
    if (req.user && req.user.role === 'citizen') {
      filters.id = req.user.surveyId;
    } else if (req.user && req.user.role === 'surveyor' && !req.query.collector && !req.query.ward) {
        filters.wards = req.user.wards;
        filters.collector = req.user.name;
    } else {
      if (req.query.ward)      filters.ward      = req.query.ward;
      if (req.query.collector) filters.collector = req.query.collector;
    }
    const surveys = await listSurveys(filters);
    res.json(surveys);
  } catch (err) { next(err); }
}

async function getSurveyById(req, res, next) {
  try {
    const survey = await fetchSurvey(parseInt(req.params.id));
    res.json(survey);
  } catch (err) { next(err); }
}

async function createSurvey(req, res, next) {
  try {
    const payload = { ...req.body };

    // Robustly ensure collector and ward are never null
    if (req.user) {
      payload.collector = payload.collector || req.user.name || 'Unknown';
      // Support both snake_case from app and camelCase for logic
      payload.collectorWard = payload.collector_ward || payload.collectorWard || req.user.ward || 'All Wards';
    } else {
      payload.collector = payload.collector || 'Anonymous';
      payload.collectorWard = payload.collector_ward || payload.collectorWard || 'All Wards';
    }

    const survey = await submitSurvey(payload);

    const { sendWhatsApp } = require('../services/whatsappService');
    if (payload.members && payload.members.length > 0 && payload.status !== 'Hold') {
        const head = payload.members[0];
        if (head.mobile) {
            const msg = `Rajapalayam Municipality\n\nYour family details have been successfully registered.\n\nYou can now log in using your mobile number ${head.mobile} to view details or register complaints.`;
            await sendWhatsApp(head.mobile, msg);
        }
    }
    res.status(201).json(survey);
  } catch (err) { next(err); }
}

async function updateSurvey(req, res, next) {
  try {
    const payload = { ...req.body };
    // Ensure ward info is preserved on update too
    payload.collectorWard = payload.collector_ward || payload.collectorWard;

    const survey = await modifySurvey(parseInt(req.params.id), payload);
    res.json(survey);
  } catch (err) { next(err); }
}

async function deleteSurvey(req, res, next) {
  try {
    if (req.params.id) {
      await removeSurvey(parseInt(req.params.id));
      return res.json({ message: 'Survey deleted.' });
    }
    const count = await clearAllSurveys(req.user);
    res.json({ message: `${count} survey(s) deleted.` });
  } catch (err) { next(err); }
}

module.exports = { getSurveys, getSurveyById, createSurvey, updateSurvey, deleteSurvey };
