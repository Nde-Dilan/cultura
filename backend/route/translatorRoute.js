const express = require('express');
const router = express.Router();
const MyClassificationPipeline = require('../controller/translatorController');

router.post('/classify', async (req, res) => {
  const { text } = req.body;

  if (!text) {
    return res.status(400).json({ error: 'Champ `text` requis dans le corps' });
  }

  try {
    const classifier = await MyClassificationPipeline.getInstance();
    const result = await classifier(text);
    res.json(result);
  } catch (err) {
    console.error('❌ Erreur classification :', err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

module.exports = router;
