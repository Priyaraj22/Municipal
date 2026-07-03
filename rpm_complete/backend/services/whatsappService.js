/* services/whatsappService.js */
const axios = require('axios');

async function sendWhatsApp(phone, message) {
    // ── MOCK WHATSAPP GATEWAY ──────────────────────────────────────────────
    // In production, use Meta Business API or Twilio.
    console.log('\n------------------------------------------');
    console.log(`🟢 [WHATSAPP API] To: ${phone}`);
    console.log(`💬 Message: ${message}`);
    console.log('------------------------------------------\n');
}

module.exports = { sendWhatsApp };
