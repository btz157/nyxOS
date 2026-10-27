const fs = require('fs');
const path = require('path');
const { parse, analyzeScopes } = require('luau-parser');
const OK = new Set(['load','game','workspace','script','task','Enum','Instance','UDim2','UDim','Vector2','Vector3','Color3','TweenInfo','Players','math','string','table','os','pcall','xpcall','print','warn','error','ipairs','pairs','tostring','tonumber','type','typeof','select','assert','next','rawget','rawset','setmetatable','getmetatable','unpack','utf8','coroutine','require','ColorSequence','ColorSequenceKeypoint','NumberSequence','NumberRange','Rect','getgenv','gethui','loadstring','syn','_G','shared','tick','time','wait','readfile','writefile','isfile','makefolder','isfolder','bit32','buffer','vector','Random','math']);
function walk(d, out) {
  for (const f of fs.readdirSync(d)) {
    const p = path.join(d, f);
    if (fs.statSync(p).isDirectory()) { if (f !== '.git') walk(p, out); }
    else if (f.endsWith('.lua')) out.push(p);
  }
  return out;
}
let total = 0, parsed = 0;
for (const f of walk(process.argv[2], [])) {
  const src = fs.readFileSync(f, 'utf8');
  let ast;
  try { ast = parse(src); parsed++; } catch (e) { console.log('ERRO sintaxe', f); continue; }
  const sc = analyzeScopes(ast);
  const bl = sc.bindings instanceof Map ? [...sc.bindings.values()] : (sc.bindings || []);
  for (const b of bl) {
    if (b.kind !== 'global' || OK.has(b.name)) continue;
    const ref = (b.references || [])[0];
    const line = ref && ref.line ? ref.line.start : '?';
    total++;
    console.log(path.basename(f) + ' linha ' + line + ': global "' + b.name + '" não declarada');
  }
}
console.log(`\narquivos analisados: ${parsed}; possíveis problemas: ${total}`);
