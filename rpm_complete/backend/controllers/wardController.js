/* controllers/wardController.js */
const { getWardProgress, getWardsList } = require('../services/wardService');

async function getWardProgressHandler(req, res, next) {
  try {
    const progress = await getWardProgress();
    // Flutter expects a JSON array directly
    res.json(progress);
  } catch (err) { next(err); }
}

async function getWards(req, res, next) {
  try {
    const wards = await getWardsList();
    // Flutter Ward.fromJson expects: id, ward_no, ward_name, lgd_code
    res.json(wards);
  } catch (err) { next(err); }
}

module.exports = { getWardProgress: getWardProgressHandler, getWards };
