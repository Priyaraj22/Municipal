/* middleware/auth.js */
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'change_me_in_production';

function verifyToken(token) {
  return jwt.verify(token, JWT_SECRET);
}

/* requireAuth — hard authentication guard */
function requireAuth(req, res, next) {
  const header = req.headers.authorization || '';
  // Also support ?token= query param (for Excel download links)
  const token = header.startsWith('Bearer ')
    ? header.slice(7)
    : req.query.token || '';

  if (!token) {
    return res.status(401).json({ error: 'Authentication required.' });
  }
  try {
    req.user = verifyToken(token);
    next();
  } catch {
    return res.status(401).json({ error: 'Invalid or expired token.' });
  }
}

/* optionalAuth — populates req.user if token present, never blocks */
function optionalAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ')
    ? header.slice(7)
    : req.query.token || '';

  if (token) {
    try {
      req.user = verifyToken(token);
    } catch {
      // ignore invalid tokens in optional mode
    }
  }
  next();
}

/* requireAdmin — must be authenticated and role === 'admin' */
function requireAdmin(req, res, next) {
  requireAuth(req, res, () => {
    if (req.user && req.user.role === 'admin') return next();
    return res.status(403).json({ error: 'Admin access required.' });
  });
}

function signToken(payload) {
  return jwt.sign(payload, JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '12h'
  });
}

module.exports = { requireAuth, optionalAuth, requireAdmin, signToken, verifyToken };
