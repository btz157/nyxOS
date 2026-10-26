# NyxOS

**Biblioteca de interface Luau para Roblox**, com distribuição em arquivo único para ambientes que suportem execução de Luau e carregamento HTTP. A edição single-file foi preparada para testes fora do fluxo tradicional do Studio, mas compatibilidade com executores específicos **não é garantida nem foi validada em execução real**.

> **Versão atual: 0.2.0-dev — build experimental.** Use primeiro o script de teste e reporte erros. Ainda não é uma release estável.

## Comece aqui — sem Rojo

Para apenas testar a interface, use o bundle de arquivo único. **Não precisa instalar Rojo nem abrir Roblox Studio para seguir este caminho.**

### Script de teste pronto

Abra [examples/executor-test.lua](examples/executor-test.lua) para ver/copiar o teste completo com abas, botões, toggle, slider, dropdown, textbox, barra de progresso e notificações.

### Carregar pelo URL
~~~lua
local NyxOS = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/btz157/nyxOS/main/dist/NyxOS.lua"
))()

local window = NyxOS:CreateWindow({
    Title = "NYXOS // TEST",
    Theme = "Matrix",
    Size = UDim2.fromOffset(680, 440),
    ToggleKey = Enum.KeyCode.RightControl
})

local tab = window:CreateTab({Name = "Principal", Icon = "◆"})
tab:AddButton({
    Name = "Testar notificação",
    Callback = function()
        window:Notify({
            Title = "NyxOS",
            Description = "Callback executado!"
        })
    end
})
~~~

### Arquivos principais

- [Bundle single-file](dist/NyxOS.lua)
- [Loader](loader.lua)
- [Teste standalone](examples/executor-test.lua)
- [Guia da API](docs/API.md)

**Aviso:** loadstring e game:HttpGet podem estar indisponíveis em determinados ambientes. Não tente contornar proteções da plataforma; se não forem suportados, use a instalação de desenvolvimento abaixo.

## Instalação de desenvolvimento no Roblox Studio (opcional)

Esta opção é somente para quem deseja trabalhar na versão modular dentro do Studio. Rojo sincroniza arquivos com o Roblox Studio; **não é requisito para usar o bundle single-file**. Consulte a [documentação oficial do Rojo](https://rojo.space/) apenas se quiser esse fluxo.

1. Baixe ou clone este repositório.
2. Configure o Rojo em um computador de desenvolvimento.
3. Execute o comando de build do Rojo e revise a hierarquia gerada.
4. Importe o modelo no Studio e teste em uma experiência própria/autorizada.

## Recursos

- Temas Matrix, Neon, Dark e Light.
- Janela com animação de entrada e barra superior arrastável.
- Abas e páginas com rolagem.
- Minimizar e restaurar pela bolinha flutuante.
- Notificações.
- Button, Toggle, Slider, Dropdown, Textbox, Label, Section, Divider e ProgressBar.
- Tratamento de erros em callbacks.

## Estrutura

- src/: implementação modular para desenvolvimento.
- dist/NyxOS.lua: runtime single-file para teste.
- loader.lua: carregador remoto do runtime.
- examples/: exemplos de teste e Studio.
- docs/API.md: referência da API.

## Limitações conhecidas

- Build experimental; ainda não testado ao vivo no Delta ou em outros executores.
- A API modular e o bundle podem divergir; reporte problemas com o componente e o erro do console.
- Nem todos os ambientes oferecem as mesmas APIs ou permitem carregar código remoto.
- O projeto destina-se a interfaces e experiências Roblox próprias ou autorizadas; não inclui lógica de exploração de jogos.

## Licença

MIT. Consulte [LICENSE](LICENSE).
