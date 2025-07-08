// wordRoute.js : Définit la route POST /word
const express = require('express');
const wordrouter = express.Router();
const path = require('path');
const fs = require('fs-extra');
const { handleword } = require('../controller/wordController.js');
const multer = require('multer');


const upload = multer();

wordrouter.post('/word', upload.none(), handleword);

module.exports = wordrouter;