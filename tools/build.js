// Gera dist/nyxOS-beta.lua: um único arquivo com toda a lib.
// Uso: node tools/build.js .
const fs = require('fs');
const path = require('path');

const root = path.resolve(process.argv[2] || '.');
const srcDir = path.join(root, 'src');
const mods = [];
(function walk(d) {
	for (const f of fs.readdirSync(d)) {
		const p = path.join(d, f);
		if (fs.statSync(p).isDirectory()) walk(p);
		else if (f.endsWith('.lua')) mods.push(p);
	}
})(srcDir);
mods.sort();

let out = '--[[ nyxOS 2.6.0-beta | BETA: versão de testes, pode mudar ]]\n';
out += 'local __M, __C = {}, {}\n';
out += 'local function __req(p)\n';
out += '\tif __C[p] == nil then\n';
out += '\t\tlocal f = __M[p]\n';
out += '\t\tassert(f, "nyxOS: módulo não encontrado: " .. tostring(p))\n';
out += '\t\t__C[p] = f(__req)\n';
out += '\tend\n';
out += '\treturn __C[p]\n';
out += 'end\n\n';
for (const p of mods) {
	const key = path.relative(root, p).replace(/\\/g, '/').replace(/\.lua$/, '');
	const body = fs.readFileSync(p, 'utf8');
	out += `__M[${JSON.stringify(key)}] = function(...)\n${body}\nend\n\n`;
}
out += 'return __req("src/init")\n';

fs.mkdirSync(path.join(root, 'dist'), { recursive: true });
fs.writeFileSync(path.join(root, 'dist', 'nyxOS-beta.lua'), out);
console.log('dist/nyxOS-beta.lua gerado com', mods.length, 'módulos');
