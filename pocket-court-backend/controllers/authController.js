const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const token = (id) => jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: '30d' });

const register = async (req, res) => {
  try {
    const { name, email, password, phone, city } = req.body;
    if (!name || !email || !password)
      return res.status(400).json({ success: false, message: 'Name, email and password are required' });

    if (await User.findOne({ email }))
      return res.status(400).json({ success: false, message: 'Email already registered' });

    const hashed = await bcrypt.hash(password, 10);
    const user = await User.create({ name, email, password: hashed, phone, city });

    res.status(201).json({
      success: true,
      data: { token: token(user._id), user: _safe(user) }
    });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user || !(await bcrypt.compare(password, user.password)))
      return res.status(401).json({ success: false, message: 'Invalid email or password' });

    res.json({ success: true, data: { token: token(user._id), user: _safe(user) } });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

const updateProfile = async (req, res) => {
  try {
    const { name, phone, city } = req.body;
    const user = await User.findByIdAndUpdate(
      req.user.id,
      { name, phone, city },
      { new: true }
    );
    res.json({ success: true, data: _safe(user) });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

const getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    res.json({ success: true, data: _safe(user) });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

const _safe = (u) => ({
  id: u._id, name: u.name, email: u.email,
  phone: u.phone, city: u.city, createdAt: u.createdAt
});

module.exports = { register, login, updateProfile, getMe };
