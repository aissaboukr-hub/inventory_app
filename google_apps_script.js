/*
  Google Apps Script pour l'intégration de l'application d'inventaire Flutter.
  À publier en tant qu'application Web (Accès : Tout le monde, même anonyme).
*/

const SPREADSHEET_ID = 'VOTRE_ID_DE_FEUILLE_ICI';

function doGet(e) {
  const action = e.parameter.action;
  
  if (action === 'importProducts') {
    const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
    const sheet = ss.getSheetByName('Produits');
    if (!sheet) return ContentService.createTextOutput(JSON.stringify([])).setMimeType(ContentService.MimeType.JSON);
    
    const data = sheet.getDataRange().getValues();
    const headers = data[0];
    const results = [];
    
    // Détection des colonnes
    let codeIdx = 0, desIdx = 1, barIdx = 2;
    for (let i = 0; i < headers.length; i++) {
      let h = headers[i].toString().toLowerCase();
      if (h.includes('code')) codeIdx = i;
      if (h.includes('designation')) desIdx = i;
      if (h.includes('barcode') || h.includes('barre')) barIdx = i;
    }
    
    for (let i = 1; i < data.length; i++) {
      if (data[i][codeIdx]) {
        results.push({
          code: data[i][codeIdx].toString(),
          designation: data[i][desIdx].toString(),
          barcode: data[i][barIdx].toString()
        });
      }
    }
    return ContentService.createTextOutput(JSON.stringify(results)).setMimeType(ContentService.MimeType.JSON);
  }
}

function doPost(e) {
  const data = JSON.parse(e.postData.contents);
  const action = data.action;
  
  if (action === 'exportInventory') {
    const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
    const inventoryName = data.inventoryName;
    
    // Créer une nouvelle feuille pour cet inventaire
    const sheetName = inventoryName + "_" + new Date().getTime();
    const sheet = ss.insertSheet(sheetName);
    
    // Feuille 1 : Historique
    sheet.appendRow(['Code', 'Designation', 'Barcode', 'Quantite', 'Date']);
    data.history.forEach(item => {
      sheet.appendRow([item.product_code, item.designation, item.barcode, item.quantity, item.date]);
    });
    
    // Totaux (vous pouvez aussi créer une deuxième feuille séparée)
    sheet.appendRow([]);
    sheet.appendRow(['TOTAUX PAR PRODUIT']);
    sheet.appendRow(['Code', 'Designation', 'Barcode', 'Quantite Totale']);
    data.totals.forEach(row => {
      sheet.appendRow([row.product_code, row.designation, row.barcode, row.total_quantity]);
    });
    
    return ContentService.createTextOutput(JSON.stringify({status: 'success', sheetName: sheetName}))
      .setMimeType(ContentService.MimeType.JSON);
  }
}
