const Law = require('../models/Law');

const getLawByCategoryAndSituation = async (req, res) => {
  try {
    const { category, situation } = req.query;
    if (!category || !situation) {
      return res.status(400).json({ success: false, message: 'category and situation query params are required' });
    }
    const law = await Law.findOne({ category, situation });
    if (!law) {
      return res.status(404).json({ success: false, message: 'Law not found' });
    }
    res.json({ success: true, data: law });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getAllLaws = async (req, res) => {
  try {
    const laws = await Law.find({});
    res.json({ success: true, data: laws });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = { getLawByCategoryAndSituation, getAllLaws };
