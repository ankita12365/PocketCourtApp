const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { register, login, updateProfile, getMe } = require('../controllers/authController');

router.post('/register', register);
router.post('/login', login);
router.get('/me', auth, getMe);
router.put('/profile', auth, updateProfile);

module.exports = router;
