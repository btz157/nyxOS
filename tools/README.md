# Verificação estática

Requer Node e o pacote `luau-parser`:

    npm install luau-parser
    node tools/check-syntax.js .
    node tools/check-globals.js .

- check-syntax: confere se todos os .lua têm sintaxe Luau válida.
- check-globals: lista variáveis globais usadas e não declaradas (erros comuns de digitação).
