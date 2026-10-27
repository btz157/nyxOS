const fs = require('fs');
const path = require('path');
const { parse } = require('luau-parser');
const root = process.argv[2];
function walk(d, out) {
  for (const f of fs.readdirSync(d)) {
    const p = path.join(d, f);
    if (fs.statSync(p).isDirectory()) { if (f !== '.git') walk(p, out); }
    else if (f.endsWith('.lua')) out.push(p);
  }
  return out;
}
let bad = 0;
for (const f of walk(root, [])) {
  const src = fs.readFileSync(f, 'utf8');
  try { parse(src); console.log('OK   ', f); }
  catch (e) { bad++; console.log('ERRO ', f, '->', String(e.message || e).split('\n')[0]); }
}
console.log(bad ? `\n${bad} arquivo(s) com erro de sintaxe` : '\nSintaxe OK em todos os arquivos');
