// server.js : Point d'entrée principal de ton application Express
const express = require('express');
const path = require('path');
const fs = require('fs-extra');
const app = express();
const PORT = process.env.PORT || 3000;
// Pour pouvoir lire les champs texte dans les requêtes POST
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// S'assurer que les dossiers temporaires existent
fs.ensureDirSync(path.join(__dirname, 'temp'));
fs.ensureDirSync(path.join(__dirname, 'temp', 'uploads'));

// Route d'extraction OCR
const extractRoute = require('./route/extractRoute');
app.use('/', extractRoute);

// Pour pouvoir lire les champs texte dans les requêtes POST
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
// Route de traduction de texte
const wordRoute = require('./route/wordRoute');
app.use('/', wordRoute );





// Route POST (avec body JSON : { "text": "some text" })
app.post('/classify', async (req, res) => {
  const { text } = req.body;

  if (!text) {
    return res.status(400).json({ error: 'Champ `text` requis dans le corps' });
  }

  try {
    const classifier = await MyClassificationPipeline.getInstance();
    const result = await classifier(text);
    res.json(result);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erreur interne du serveur' });
  }
});

// Route simple pour tester si le serveur tourne
app.get('/', (req, res) => {
  res.send('🚀 Serveur OCR en ligne');
});

// Lancement du serveur
app.listen(PORT, () => {
  console.log(`🟢 Serveur en cours d'exécution sur http://localhost:${PORT}`);
});
