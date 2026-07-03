/* controllers/authController.js */
const { loginCollector, loginAdmin, loginCitizen } = require('../services/authService');

async function login(req, res, next) {
  try {
    const { role, name, wards, ward, password, phone } = req.body;

    if (role === 'surveyor' || role === 'collector') {
      const result = await loginCollector(name, wards || ward);
      return res.json(result);
    }

    if (role === 'admin') {
      const result = await loginAdmin(password);
      return res.json(result);
    }

    if (role === 'citizen') {
        const result = await loginCitizen(phone);
        return res.json(result);
    }

    return res.status(400).json({ error: 'Invalid role.' });
  } catch (err) {
    next(err);
  }
}

async function requestOtp(req, res, next) {
  try {
    const { phone } = req.body;
    const otp = Math.floor(1000 + Math.random() * 9000);

    console.log('\n------------------------------------------');
    console.log(`📲 [OTP GATEWAY] To: ${phone}`);
    console.log(`👉 CODE: ${otp}`);
    console.log('------------------------------------------\n');

    res.json({ message: 'OTP sent successfully', otp: otp });
  } catch (err) { next(err); }
}

module.exports = { login, requestOtp };
