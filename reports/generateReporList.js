// generateReportList.js
const fs = require('fs');
const path = require('path');

const baseDir = __dirname;
const outputFile = path.join(baseDir, 'index.html');

// Read only folders
const folders = fs.readdirSync(baseDir, { withFileTypes: true })
  .filter(dirent => dirent.isDirectory())
  .map(dirent => dirent.name);

// Generate HTML
const html = `
<html>
  <body>
    <h1>Reports</h1>
    <ul>
      ${folders.map(folder => `<li><a href="${folder}/">${folder}</a></li>`).join('\n      ')}
    </ul>
  </body>
</html>
`;

// Write to file
fs.writeFileSync(outputFile, html, 'utf8');
console.log('index.html generated with report folders.');
