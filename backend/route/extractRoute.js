// extractRoute.js : Définit la route POST /extract
const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs-extra');
const { handleExtract } = require('../controller/extractController');

// Créer le dossier s'il n'existe pas
const uploadDir = path.join(__dirname, '../temp/uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Configuration avec diskStorage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname); // .txt, .png, etc.
    console.log("l'extension du fichier importé est: ",ext);
    const baseName = path.basename(file.originalname, ext); // nom sans extension
    const uniqueSuffix = Date.now();
    cb(null, `${baseName}-${uniqueSuffix}${ext}`);
  }
});

const upload = multer({ storage });

// Route POST /extract avec champs source, target et un fichier
router.post('/extract', upload.single('file'), handleExtract);

module.exports = router;
