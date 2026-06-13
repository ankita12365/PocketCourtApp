const mongoose = require('mongoose');

const lawSchema = new mongoose.Schema({
  category: { type: String, required: true },
  situation: { type: String, required: true },
  act: { type: String, required: true },
  section: { type: String, required: true },
  fine: { type: String, default: 'N/A' },
  article: { type: String, default: 'N/A' }
});

module.exports = mongoose.model('Law', lawSchema);
