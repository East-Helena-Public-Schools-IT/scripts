const sheetID = "{enter sheet ID here}"

function doPost(req) {
  if (req.postData.type === "application/json") {
    // I don't think this is needed - but it's easier to leave this here than debug it later...
    SpreadsheetApp.setActiveSpreadsheet(SpreadsheetApp.openById(sheetID))

    console.log("Accpeting JSON")
    let data = JSON.parse(req.postData.contents)
    
    if(!isValidApiKey(data.APIKEY.trim())) { throw Error("Invalid API key!") }
  
    // Arrays display as tho they are in excel (y,x)
    let range = [
      [data.lname, data.fname, data.email, data.password,]
    ];
    grady = data.gradyear

    // getRange uses 1-based ranges for whatever reason...?
    let sheet = getSheet(grady)
    if (sheet == null) { createSheet(grady) }
    sheet.getRange(sheet.getLastRow()+1,1,range.length, range[0].length).setValues(range)
    
    console.log(data)
  } else { throw Error("Didn't send json.") }
}

function getSheet(name) {
  return SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name);
}

function createSheet(name) {
    SpreadsheetApp.getActiveSpreadsheet().insertSheet(name, 1);
    let range = [
      ["Last Name", "First Name", "Email", "Password",]
    ];
    let sheet = getSheet(name)
    sheet.getRange(1,1,1, range[0].length).setValues(range)
    sheet.setFrozenRows(1)
}

function isValidApiKey(checkKey) {
  checkKey = checkKey.trim()

  // UUID length
  if (checkKey.length != 36) {return false}

  const sheet = getSheet("master").getDataRange().getDisplayValues()
  // Look for the api key section of the master sheet
  const titleRow = 0
  for (const collumIndex in sheet[titleRow]) {
    const cell = sheet[titleRow][collumIndex];
    if (cell.trim() == "API Keys") {
      for (const k in sheet) {
        const key = sheet[k][collumIndex]
        if (key.trim() == checkKey) {
          return true
        }
      }
    }
  }
  console.log("Invalid key tried: "+checkKey)
  return false
}
