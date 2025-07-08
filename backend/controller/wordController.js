// extractController.js
const path = require('path');
const fs = require('fs-extra');
const { sendword } = require('../word.js'); // Ton fichier avec la fonction recognize(lang, path)

//fonction principale
exports.handleword = async (req, res) => {
    try {
        console.log("l'erreur est ici on arrive pas à lire ! ", req.body);

        if (!req.body.word || !req.body.source || !req.body.target) {
            return res.status(400).json({ error: 'text ,source et target requis' });
        }

        const word = req.body.word;
        const source = req.body.source;
        const target = req.body.target;
        // Appel le translator
        const response = await sendword(word , source , target);

        res.send(response.word_translated, (err) => {
            if (err) {
                console.error('❌Erreur de l\'envoie de la traduction:', err);
                res.status(500).send('❌Erreur lors de l\'envoi du fichier');
            }
        });
        } catch (err) {
        console.error('❌ Erreur dans handleword :', err.message);
        res.status(500).json({ error: 'Erreur interne à "translator"' });
    }
};