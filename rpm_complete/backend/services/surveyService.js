/* services/surveyService.js */
const {
  getAllSurveys, getSurveyById, createSurvey, updateSurvey,
  deleteSurveyById, deleteAllSurveys
} = require('../models/surveyModel');

function validateSurveyPayload(data) {
  const errors = [];
  if (!data.ward)   errors.push('ward is required');
  if (!data.door)   errors.push('door is required');
  if (!data.street) errors.push('street is required');
  if (!data.head)   errors.push('head (family head name) is required');

  if (!data.members || !data.members.length) {
    errors.push('At least one family member is required');
  }
  return errors;
}

async function listSurveys(filters) {
  return getAllSurveys(filters);
}

async function fetchSurvey(id) {
  const survey = await getSurveyById(id);
  if (!survey) throw Object.assign(new Error('Survey not found'), { status: 404 });
  return survey;
}

async function submitSurvey(data) {
  const errors = validateSurveyPayload(data);
  if (errors.length) {
    throw Object.assign(new Error(errors.join('; ')), { status: 400 });
  }
  return createSurvey(data);
}

async function modifySurvey(id, data) {
    const errors = validateSurveyPayload(data);
    if (errors.length) throw Object.assign(new Error(errors.join('; ')), { status: 400 });
    return updateSurvey(id, data);
}

async function removeSurvey(id) {
  const deleted = await deleteSurveyById(id);
  if (!deleted) throw Object.assign(new Error('Survey not found'), { status: 404 });
}

async function clearAllSurveys(user) {
  if (!user || user.role !== 'admin') {
    throw Object.assign(new Error('Admin access required'), { status: 403 });
  }
  return deleteAllSurveys();
}

module.exports = { listSurveys, fetchSurvey, submitSurvey, modifySurvey, removeSurvey, clearAllSurveys };
