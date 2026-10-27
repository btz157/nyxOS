-- nyxOS: modelo inicial
-- Copie este arquivo, troque os textos e comece a criar.
-- Referência completa: docs/API.md

local NyxOS = loadstring(game:HttpGet("https://raw.githubusercontent.com/btz157/nyxOS/main/dist/nyxOS-beta.lua"))()

-- 1) Janela
local nyx = NyxOS.new({
	Title = "Meu script",
	Size = Vector2.new(720, 440),
	Keybind = Enum.KeyCode.RightShift, -- minimiza e restaura
	Home = {
		Game = { Name = "Meu jogo", Version = "1.0.0", Desc = "Descrição curta do jogo." },
		Character = { Name = "Meu personagem", Class = "Classe", Level = 1, Power = 100 },
		Skins = {
			{ Real = true, Name = "Meu avatar", Desc = "Seu avatar real do Roblox." },
		},
	},
})

-- 2) Uma aba com um botão e um toggle salvo
local principal = nyx:Tab("Principal", "ações do script", "⚡")
principal:Section("Ações")

principal:Button("Olá", function()
	nyx:Notify("olá! o script está funcionando.", 3, "success")
end)

principal:Toggle("Modo ativo", nyx:Get("modoAtivo", false), function(on)
	nyx:Set("modoAtivo", on) -- salvo automaticamente
	nyx:Notify("modo " .. (on and "ligado" or "desligado"), 2, "info")
end)

-- 3) Uma aba de configurações pronta
nyx:SettingsTab()
