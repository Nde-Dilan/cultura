const Tesseract = require('tesseract.js');
const fs = require('fs-extra');
const { fileTypeFromBuffer } = require('file-type');
const path = require('path');
const sharp = require('sharp');
const { exec } = require('child_process');
const { promisify } = require('util');

const execPromise = promisify(exec);

// Configuration OCR optimisée
const OCR_CONFIG = {
    logger: m => console.log(m),
    config: {
        tessedit_char_whitelist: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ0123456789 .,;:!?()[]{}«»""\'-–—',
        tessedit_pageseg_mode: '6',
        preserve_interword_spaces: '1',
        tessedit_create_hocr: '0',
        tessedit_create_pdf: '0',
        tessedit_do_invert: '0',
        textord_really_old_xheight: '1',
        textord_min_xheight: '10',
        edges_use_new_outline_complexity: '1',
        tosp_old_to_method: '0',
        load_system_dawg: '1',
        load_freq_dawg: '1',
        load_unambig_dawg: '1',
        load_punc_dawg: '1',
        load_number_dawg: '1',
        load_bigram_dawg: '1'
    }
};


// Prétraitement d'image avancé avec plusieurs techniques
async function preprocessImage(inputPath, outputPath) {
    try {
        const image = sharp(inputPath);
        const metadata = await image.metadata();

        // Détection automatique du type de contenu
        const stats = await image.stats();
        const isLowContrast = stats.channels[0].mean > 200 || stats.channels[0].mean < 50;

        let pipeline = image.clone();

        // Redimensionnement si l'image est trop petite (améliore l'OCR)
        if (metadata.width < 1000 || metadata.height < 1000) {
            pipeline = pipeline.resize(
                Math.max(metadata.width * 2, 1500),
                Math.max(metadata.height * 2, 1500),
                { kernel: sharp.kernel.lanczos3 }
            );
        }

        // Conversion en niveaux de gris
        pipeline = pipeline.grayscale();

        // Amélioration du contraste adaptatif
        if (isLowContrast) {
            pipeline = pipeline.normalise();
        }

        // Réduction du bruit avec un filtre médian
        pipeline = pipeline.median(1);

        // Amélioration de la netteté
        pipeline = pipeline.sharpen(1.0, 1.0, 2.0);

        // Binarisation adaptative (seuil dynamique)
        const threshold = await calculateOptimalThreshold(image);
        pipeline = pipeline.threshold(threshold);

        // Morphologie pour nettoyer le texte
        pipeline = pipeline.convolve({
            width: 3,
            height: 3,
            kernel: [0, -1, 0, -1, 5, -1, 0, -1, 0]
        });

        await pipeline.toFile(outputPath);
        console.log(`✅ Prétraitement terminé : ${outputPath}`);

    } catch (error) {
        console.error('❌ Erreur prétraitement :', error.message);
        // Fallback vers traitement basique
        await sharp(inputPath)
            .grayscale()
            .threshold(180)
            .toFile(outputPath);
    }
}

// Calcul du seuil optimal pour la binarisation
async function calculateOptimalThreshold(image) {
    try {
        const { data, info } = await image.grayscale().raw().toBuffer({ resolveWithObject: true });

        // Histogramme des niveaux de gris
        const histogram = new Array(256).fill(0);
        for (let i = 0; i < data.length; i++) {
            histogram[data[i]]++;
        }

        // Méthode d'Otsu pour trouver le seuil optimal
        const total = info.width * info.height;
        let sum = 0;
        for (let i = 0; i < 256; i++) {
            sum += i * histogram[i];
        }

        let sumB = 0;
        let wB = 0;
        let maximum = 0;
        let threshold = 0;

        for (let i = 0; i < 256; i++) {
            wB += histogram[i];
            if (wB === 0) continue;

            const wF = total - wB;
            if (wF === 0) break;

            sumB += i * histogram[i];
            const mB = sumB / wB;
            const mF = (sum - sumB) / wF;

            const variance = wB * wF * (mB - mF) * (mB - mF);

            if (variance > maximum) {
                maximum = variance;
                threshold = i;
            }
        }

        return Math.max(120, Math.min(200, threshold));
    } catch {
        return 150; // Valeur par défaut
    }
}

// OCR amélioré avec post-traitement
async function ocrImage(imagePath, lang, writeStream, pageNum = null) {
    const label = pageNum ? `--- Début page ${pageNum} ---\n` : '--- Début image ---\n';
    writeStream.write(label);

    try {
        // OCR avec configuration optimisée
        const { data: { text, confidence } } = await Tesseract.recognize(imagePath, lang, {
            ...OCR_CONFIG,
            logger: (m) => {
                if (m.status === 'recognizing text') {
                    console.log(`📖 Reconnaissance en cours... ${Math.round(m.progress * 100)}%`);
                }
            }
        });

        console.log(`📊 Confiance OCR : ${confidence.toFixed(1)}%`);

        // Post-traitement du texte
        const cleanedText = postProcessText(text);

        writeStream.write(cleanedText + '\n');

    } catch (error) {
        console.error('❌ Erreur OCR :', error.message);
        writeStream.write('[ERREUR LORS DE LA RECONNAISSANCE]\n');
    }

    writeStream.write(pageNum ? `--- Fin page ${pageNum} ---\n\n` : '--- Fin image ---\n\n');
}

// Post-traitement intelligent du texte
function postProcessText(text) {
    let cleaned = text;

    // Corrections typographiques communes
    const corrections = {
        '|': 'l',
        '1': 'l',
        '0': 'o',
        '5': 's',
        '€': 'e',
        '£': 'f',
        '¢': 'c',
        '®': 'r',
        '©': 'o',
        '™': 'm',
        '„': '"',
        '"': '"',
        '‘': "'",
        '’': "'",
        '…': '...',
        '—': '-',
        '–': '-',
        [/\s{2,}/g]: ' ',       // 🔁 espaces multiples → un seul espace
        [/\n{3,}/g]: '\n\n'     // 🔁 lignes vides multiples → 2 max
    };


    // Application des corrections
    for (const [pattern, replacement] of Object.entries(corrections)) {
        if (pattern instanceof RegExp) {
            cleaned = cleaned.replace(pattern, replacement);
        } else {
            cleaned = cleaned.split(pattern).join(replacement);
        }
    }

    // Nettoyage des caractères indésirables (mais garde les accents français)
    cleaned = cleaned.replace(/[^\w\sÀ-ÿ'\-«»""".?!,:;()\[\]{}]/g, '');

    // Correction des espaces autour de la ponctuation
    cleaned = cleaned.replace(/\s+([,.;:!?])/g, '$1');
    cleaned = cleaned.replace(/([«"])\s+/g, '$1');
    cleaned = cleaned.replace(/\s+([»"])/g, '$1');

    // Capitalisation des débuts de phrases
    cleaned = cleaned.replace(/(^|\.\s+)([a-zà-ÿ])/g, (match, p1, p2) => p1 + p2.toUpperCase());

    // Nettoyage final
    cleaned = cleaned.trim();

    return cleaned;
}

// Fonction principale 
async function recognize(lang, filepath, options = {}) {
    const startTime = Date.now();

    try {
        if (!fs.existsSync(filepath)) {
            throw new Error(`Fichier introuvable : ${filepath}`);
        }

        console.log(`🚀 Démarrage OCR pour : ${filepath}`);

        const ext = path.extname(filepath).toLowerCase();
        const fileBuffer = await fs.readFile(filepath);
        const type = await fileTypeFromBuffer(fileBuffer);
        const outputTextPath = options.outputPath || path.join('temp', path.basename(filepath) + '.txt');
        await fs.ensureDir(path.dirname(outputTextPath));

        await fs.ensureDir(path.dirname(outputTextPath));
        const writeStream = fs.createWriteStream(outputTextPath);

        // CAS 1 : Image
        if (type && type.mime.startsWith('image/')) {
            console.log('📸 Traitement d\'image détecté...');
            const filename = path.basename(filepath);
            const cleanedPath = path.join(path.dirname(filepath), filename.replace(ext, `1${ext}`));

            await preprocessImage(filepath, cleanedPath);
            await ocrImage(cleanedPath, lang, writeStream);

            // Nettoyage des fichiers temporaires
            await fs.remove(cleanedPath);
        }

        // CAS 2 : PDF
        else if (ext === '.pdf') {
            console.log('📄 Traitement PDF détecté...');
            const tempDir = path.join('./temp_ocr_' + Date.now());
            await fs.ensureDir(tempDir);

            try {
                // Tentative d'extraction du texte directement
                const { stdout } = await execPromise(`pdftotext "${filepath}" -`);
                if (stdout.trim().length > 50) { // Seuil plus élevé
                    writeStream.write('--- Début texte PDF (non scanné) ---\n');
                    writeStream.write(postProcessText(stdout));
                    writeStream.write('\n--- Fin texte PDF ---\n');
                    console.log('✅ PDF texte extrait directement');
                } else {
                    throw new Error('PDF probablement scanné');
                }
            } catch {
                console.log('🔄 PDF scanné détecté, extraction page par page...');

                // Extraction haute résolution
                const prefix = path.join(tempDir, 'page');
                await execPromise(`pdftoppm -png -r 300 "${filepath}" "${prefix}"`);

                const images = (await fs.readdir(tempDir))
                    .filter(f => f.endsWith('.png'))
                    .sort((a, b) => {
                        const numA = parseInt(a.match(/\d+/)?.[0] || '0');
                        const numB = parseInt(b.match(/\d+/)?.[0] || '0');
                        return numA - numB;
                    });

                if (images.length === 0) {
                    throw new Error('Aucune image générée depuis le PDF');
                }

                console.log(`📖 Traitement de ${images.length} page(s)...`);

                for (let i = 0; i < images.length; i++) {
                    const imgPath = path.join(tempDir, images[i]);
                    const cleanedPath = imgPath.replace('.png', '_clean.png');

                    console.log(`📄 Page ${i + 1}/${images.length}`);
                    await preprocessImage(imgPath, cleanedPath);
                    await ocrImage(cleanedPath, lang, writeStream, i + 1);

                    await fs.remove(cleanedPath);
                }
            }

            await fs.remove(tempDir);
        }

        else {
            throw new Error('Format de fichier non supporté (image ou PDF requis)');
        }


        writeStream.end();

        console.log(`✅ Extraction réussie  → ${outputTextPath}`);

        return {
            success: true,
            outputPath: outputTextPath,
        };

    } catch (err) {
        console.error('❌ Erreur OCR :', err.message);
        return {
            success: false,
            error: err.message
        };
    }
}

// Fonction utilitaire pour traiter plusieurs fichiers
async function recognizeBatch(lang, filepaths, options = {}) {
    const results = [];

    for (const filepath of filepaths) {
        console.log(`\n🔄 Traitement ${filepath}...`);
        const result = await recognize(lang, filepath, options);
        results.push({ filepath, ...result });
    }

    return results;
}



//fonction de traduction du txt en langue
const { sendword } = require('./word.js');

/**
 * Traduit un fichier texte ligne par ligne en ignorant les marqueurs
 */
async function translateFile(inputPath) {
    try {
        const contenu = fs.readFileSync(inputPath, 'utf-8');
        const lignes = contenu.split(/\r?\n/);


        const outputPath = inputPath.replace('.txt', '.translated.txt');
        // Vider le fichier de sortie s’il existe déjà
        if (fs.existsSync(outputPath)) {
            fs.unlinkSync(outputPath);
        }
        // let isMarqueur = "--- Début ";
        // let isMarqueur2 = "--- Fin";

        const MAX_LEN = 200; // seuil de découpage

        for (let i = 0; i < lignes.length; i++) {
            let ligne = lignes[i];
            let ligneFinale = '';

            if (ligne.startsWith("---") || ligne.trim() === '') {
                ligneFinale = ligne;
            } else {
                try {
                    // Si la ligne est courte, traduis directement
                    if (ligne.length <= MAX_LEN) {
                        const res = await sendword(ligne.trim());
                        ligneFinale = res.word_translated || '';
                    } else {
                        // Découpe la ligne trop longue par mots
                        const mots = ligne.trim().split(/\s+/);
                        let buffer = '';
                        let morceaux = [];

                        for (let mot of mots) {
                            if ((buffer + ' ' + mot).length > MAX_LEN) {
                                morceaux.push(buffer.trim());
                                buffer = mot;
                            } else {
                                buffer += ' ' + mot;
                            }
                        }
                        if (buffer.trim()) morceaux.push(buffer.trim());

                        // Traduit chaque morceau séparément
                        for (let part of morceaux) {
                            const res = await sendword(part);
                            ligneFinale += (res.word_translated || '') + ' ';
                        }

                        ligneFinale = ligneFinale.trim(); // nettoyage final
                    }
                } catch (err) {
                    console.error('❌ Erreur de traduction ligne dans translateFile :', err.message);
                    ligneFinale = ligne; // on garde la ligne originale en cas d’erreur
                }
            }

            console.log(`la ligne finale est :`, ligneFinale);
            await fs.promises.appendFile(outputPath, ligneFinale + '\n', 'utf-8');
        }


        fs.unlinkSync(inputPath);
        console.log(`✅ Fichier traduit : ${outputPath}`);
        console.log(`🗑️ Fichier original supprimé : ${inputPath}`);
    } catch (err) {
        console.error('❌ Erreur translatefile function:', err.message);
    }
}







const fss = require('fs');
require('dotenv').config();
//initialise key
const { GoogleGenAI } = require("@google/genai");
// Init Gemini
const ai = new GoogleGenAI({});
//text to markdown
async function formatterMarkdown(filepathArg) {
    if (!filepathArg) {
        console.error('❌ Donne le chemin du fichier texte à formater.');
        console.log('Ex : node formatMarkdown.js ../temp/montexte.txt');
        return;
    }

    const filepath = path.resolve(filepathArg);

    // Vérifie que le fichier existe
    if (!fss.existsSync(filepath)) {
        console.error(`❌ Fichier introuvable : ${filepath}`);
        return;
    }

    try {

        const texte = fss.readFileSync(filepath, 'utf8');

        const prompt = `
ajoute des jolis styles markdown à ce texte(police , titres , listes , soulignements...) sans aucune modification sémantique .
tu tacheras de supprimer toutes les lignes ayant "--- " sauf celles ayant source et target(qui seront mis en petits caractères)
Voici le texte(je ne veux pas d'indicatifs de ta part , je n'ai pas besoin que tu m'indiques que c'est la réponse)  :
""" 
${texte}
"""
`;

        let response = await ai.models.generateContent({
            model: "gemini-2.5-flash",
            contents: prompt,
            config: {
                thinkingConfig: {
                    thinkingBudget: 0, // Disables thinking
                },
            }
        });





        // response en markdown
        const markdownFormate = response.text;

        // Écrase le fichier d'origine
        fss.writeFileSync(filepath, markdownFormate, 'utf8');
        console.log(`✅ Fichier formaté avec succès : ${filepath}`);
    } catch (error) {
        console.error('❌ Erreur lors du formatage :', error.message);
    }
}


async function toEnglish(filepathArg) {
    if (!filepathArg) {
        console.error('❌ Donne le chemin du fichier texte à formater.');
        console.log('Ex : node formatMarkdown.js ../temp/montexte.txt');
        return;
    }

    const filepath = path.resolve(filepathArg);

    // Vérifie que le fichier existe
    if (!fss.existsSync(filepath)) {
        console.error(`❌ Fichier introuvable : ${filepath}`);
        return;
    }

    try {

        const texte = fss.readFileSync(filepath, 'utf8');

        const prompt = `
traduis fidèlement le texte suivant en anglais simple (sans modifier le sens du texte). Structure les titres, listes, paragraphes, etc.
tu ignoreras les '---' du text , et tu traduiras ligne par ligne
je ne veux que la réponse , tu ne mettras donc aucun indicatif qui montre que c'est une réponse
Voici le texte à traduire en anglais courant :
""" 
${texte}
"""
`;

        let response = await ai.models.generateContent({
            model: "gemini-2.5-flash",
            contents: prompt,
            config: {
                thinkingConfig: {
                    thinkingBudget: 0, // Disables thinking
                },
            }
        });





        // response en markdown
        const englishText = response.text;

        // Écrase le fichier d'origine
        fss.writeFileSync(filepath, englishText, 'utf8');
        console.log(`✅ le Fichier ${filepath} traduis en englais avec succès`);
    } catch (error) {
        console.error('❌ Erreur lors du la traduction en anglais :', error.message);
    }
}



// Export des fonctions pour utilisation en module
module.exports = {
    recognize,
    recognizeBatch,
    formatterMarkdown,
    translateFile,
    toEnglish
};