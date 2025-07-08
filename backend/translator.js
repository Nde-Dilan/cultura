async function translateText(textToTranslate) {
    console.log("le texte est ",textToTranslate);
    const apiUrl = 'https://mph61rz4ae.execute-api.us-east-1.amazonaws.com/conia_hack_prod_env';
    
    try {
        if (!textToTranslate || typeof textToTranslate !== 'string') {
         throw new Error('Texte invalide pour traduction');
        }

        const response = await fetch(apiUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                text: textToTranslate
            })
        });
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        return data;
        
    } catch (error) {
        console.error('Translation error dans le fichier translator:', error);
        throw error;
    }
}
module.exports={
    translateText
}