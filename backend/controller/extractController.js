// extractController.js
const path = require('path');
const fs = require('fs-extra');
const { recognize, formatterMarkdown, translateFile, toEnglish } = require('../extract.js'); // Ton fichier avec la fonction recognize(lang, path)
const { translateText } = require("../translator.js");

//fonction de suppression du fichier importé
const fss = require('fs').promises;

async function supprimerFichier(filename) {
    try {

        // Supprimer le fichier
        await fss.unlink(filename);

        console.log(`✅Fichier ${filename} supprimé avec succès.`);
    } catch (err) {
        console.error('❌Erreur lors de la suppression :', err);
    }
}


//fonction principale
exports.handleExtract = async (req, res) => {
    try {
        if (!req.file || !req.body.source) {
            return res.status(400).json({ error: 'Fichier et source requis' });
        }

        const filePath = req.file.path;
        const lang = req.body.source;
        const target = req.body.target || '';

        // Appel OCR
        await recognize(lang, filePath);


        // Chemin du fichier texte généré dans ./temp
        let outputTxtPath = path.join('./temp', path.basename(filePath) + '.txt');

        //suppression du fichier temporaire importé
        supprimerFichier(filePath);

        //traduire en anglais pour augmenter l'éfficacité du modèle

        await toEnglish(outputTxtPath);

        //traduire en langue(target)
        try {
            await translateFile(outputTxtPath);
        } catch (err) {
            console.error("erreur pendant le traitement du fichier texte", err.message);
            res.status(500).json({ error: 'Erreur interne à translatorfile' });

        }

        outputTxtPath = outputTxtPath.replace('.txt', '.translated.txt')

        // Ajout du champ 'target' à la fin du fichier
        await fs.appendFile(outputTxtPath, `\n--- source: ${lang} ---\n`);
        await fs.appendFile(outputTxtPath, `\n--- Target: fufulde ---\n`);
        await formatterMarkdown(outputTxtPath);

        res.download(outputTxtPath, (err) => {
            if (err) {
                console.error('❌Erreur de téléchargement:', err);
                res.status(500).send('❌Erreur lors de l\'envoi du fichier');
            } else {
                // ✅ Suppression du fichier après téléchargement réussi
                fss.unlink(outputTxtPath, (unlinkErr) => {
                    if (unlinkErr) {
                        console.error('❌Erreur lors de la suppression du fichier :', unlinkErr);
                    } else {
                        console.log('🗑️ Fichier temporaire supprimé :', outputTxtPath);
                    }
                });
            }
        });




    } catch (err) {
        console.error('❌ Erreur dans handleExtract :', err.message);
        res.status(500).json({ error: 'Erreur interne OCR' });
    }
};

