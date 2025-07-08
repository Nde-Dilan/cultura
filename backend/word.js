require('dotenv').config();
// //initialise key
// const { GoogleGenAI } = require("@google/genai");
const { translateText } = require('./translator');
// // Init Gemini
// const ai = new GoogleGenAI({});
//text to markdown
async function sendword(word) {
    if (!word) {
        console.error('❌ Aucun mot fourni à sendword.');
        return null;
    }

    try {
        const word_translated = await translateText(word);

        if (
            word_translated &&
            Array.isArray(word_translated.translation) &&
            word_translated.translation[0].translation_text
        ) {
            const texteTraduit = word_translated.translation[0].translation_text;
            console.log(`✅ phrase traduite : ${texteTraduit}`);
            return {
                success: true,
                word_translated: texteTraduit,
            };
        } else {
            console.warn(`⚠️ Structure inattendue :`, word_translated);
            return { success: false, word_translated: word }; // Fallback au texte original
        }

    } catch (error) {
        console.error('❌ Erreur lors du formatage :', error.message);
        return { success: false, word_translated: word }; // Fallback au texte original
    }
}
module.exports={
    sendword
};