--[[
	Redeemer by brn782k
	- Écoute les notifications, assemble les parties du code (2, 3, 4...) et redeem
	- Remote pré-capturé au démarrage (plus d'attente de 2-3 s au 1er redeem)
	- Envois en parallèle (burst) + renvoi automatique du code en cas d'erreur
	- Mode Remote ou Click (même logique que l'original)
]]

local env = (typeof(getgenv) == "function" and getgenv()) or _G
if type(env.BRN782K_REDEEMER) == "function" then
	pcall(env.BRN782K_REDEEMER)
end



if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- relance du script : on retire l'ancienne interface si elle traîne encore (ex. plantage au chargement précédent)
do
	local function killOld(parent)
		pcall(function()
			local old = parent:FindFirstChild("BRN782K_Redeemer")
			if old then
				old:Destroy()
			end
		end)
	end
	killOld(playerGui)
	killOld(game:GetService("CoreGui"))
	if typeof(gethui) == "function" then
		pcall(function()
			killOld(gethui())
		end)
	end
end

local TEST_CODE = "BESTBRAINROTEVER"
local CACHE_FILE = "BRN782K_RemoteCache.json"

----------------------------------------------------------------------
-- RÉGLAGES (modifiables ici ou depuis le GUI)
----------------------------------------------------------------------
local cfg = {
	mode = "Remote", -- "Remote", "Click" ou "Both" (Remote + Click en parallèle)
	parts = 3, -- nb de parties avant le 1er redeem (2, 3 ou 4)
	burst = 20, -- requêtes envoyées en parallèle
	interval = 0.0001, -- délai entre deux vagues d'envoi
	slowInterval = 0.0001, -- délai après une réponse "invalid code"
	maxSeconds = 60, -- arrêt du renvoi après X secondes
	staleSeconds = 20, -- parties plus vieilles que ça = on repart de zéro
	webhook = "https://discord.com/api/webhooks/1551308750152015953/3UOPgRXpAmC54iLHwOP396adHzgqPrBbMiRw77J82LYfzvNwt5kUKn7QwiNRiGLQhuyF", -- COLLE ICI TON WEBHOOK DISCORD (https://discord.com/api/webhooks/...)
	spam = true, -- Spam Redeem automatique dès qu'un code complet est détecté
	spamSeconds = 5, -- durée du spam en secondes (réglable dans le GUI)
	spamInterval = 0.05, -- délai entre deux envois pendant le spam (réglable dans le GUI : 10 ms à 1 s)
	stopOnInvalid = true, -- le spam s'arrête sur "Invalid code" (désactivable dans le GUI)
	fastListen = true, -- écoute directe du conteneur de notifications (plus rapide que ChildAdded + recherche)
	directHook = false, -- hook __newindex sur TextLabel.Text (avancé, desactivé par défaut)
	clickGap = 0.12, -- délai mini entre deux clics UI en mode Both
}

-- tu peux aussi le mettre avant de lancer le script : getgenv().BRN782K_WEBHOOK = "https://discord.com/api/webhooks/..."
if type(env.BRN782K_WEBHOOK) == "string" and env.BRN782K_WEBHOOK ~= "" then
	cfg.webhook = env.BRN782K_WEBHOOK
end

-- Réglages sauvegardés dans BRN782K_Settings.json (relus au prochain lancement)
local persist = { fps = false, ping = false, lag = false, fx = {}, code = "", jumpsOn = false, speedOn = false, speedVal = 140 }
local profLog = function() end -- sera assignée par la page log
local saveSettings
do
	local FILE = "BRN782K_Settings.json"
	local queued = false

	local function clampNum(v, lo, hi)
		return type(v) == "number" and math.clamp(math.floor(v), lo, hi) or nil
	end

	local function load()
		if typeof(isfile) ~= "function" or typeof(readfile) ~= "function" then
			return
		end
		local ok, exists = pcall(isfile, FILE)
		if not ok or not exists then
			return
		end
		local ok2, raw = pcall(readfile, FILE)
		if not ok2 or type(raw) ~= "string" then
			return
		end
		local ok3, data = pcall(HttpService.JSONDecode, HttpService, raw)
		if not ok3 or type(data) ~= "table" then
			return
		end
		local c = data.cfg
		if type(c) == "table" then
			if c.mode == "Remote" or c.mode == "Click" or c.mode == "Both" then
				cfg.mode = c.mode
			end
			cfg.parts = clampNum(c.parts, 1, 6) or cfg.parts
			cfg.burst = clampNum(c.burst, 1, 20) or cfg.burst
			cfg.spamSeconds = clampNum(c.spamSeconds, 1, 30) or cfg.spamSeconds
			if type(c.fastListen) == "boolean" then
				cfg.fastListen = c.fastListen
			end
			if type(c.directHook) == "boolean" then
				cfg.directHook = c.directHook
			end
			local ms = clampNum(c.spamMs, 10, 1000)
			if ms then
				cfg.spamInterval = ms / 1000
			end
			if type(c.stopOnInvalid) == "boolean" then
				cfg.stopOnInvalid = c.stopOnInvalid
			end
			if type(c.spam) == "boolean" then
				cfg.spam = c.spam
			end
			if type(c.webhook) == "string" and c.webhook ~= "" and cfg.webhook == "" then
				cfg.webhook = c.webhook
			end
		end
		local u = data.ui
		if type(u) == "table" then
			persist.fps = u.fps == true
			persist.ping = u.ping == true
			persist.lag = u.lag == true
			persist.jumpsOn = u.jumpsOn == true
			persist.speedOn = u.speedOn == true
			if type(u.speedVal) == "number" then persist.speedVal = math.clamp(u.speedVal, 10, 300) end
			if type(u.code) == "string" then
				persist.code = u.code
			end
			if type(u.fx) == "table" then
				for k, v in pairs(u.fx) do
					if type(k) == "string" and v == true then
						persist.fx[k] = true
					end
				end
			end
		end
	end

	saveSettings = function()
		if typeof(writefile) ~= "function" or queued then
			return
		end
		queued = true
		task.delay(0.4, function()
			queued = false
			local ok, json = pcall(HttpService.JSONEncode, HttpService, {
				cfg = {
					mode = cfg.mode,
					parts = cfg.parts,
					burst = cfg.burst,
					spam = cfg.spam,
					spamSeconds = cfg.spamSeconds,
					spamMs = math.floor(cfg.spamInterval * 1000 + 0.5),
					stopOnInvalid = cfg.stopOnInvalid,
					fastListen = cfg.fastListen,
					directHook = cfg.directHook,
					webhook = cfg.webhook,
				},
				ui = { fps = persist.fps, ping = persist.ping, lag = persist.lag, fx = persist.fx, code = persist.code, jumpsOn = persist.jumpsOn, speedOn = persist.speedOn, speedVal = persist.speedVal },
			})
			if ok then
				pcall(writefile, FILE, json)
			end
		end)
	end

	load()
end

local C = {
	bg = Color3.fromRGB(22, 22, 28),
	bar = Color3.fromRGB(34, 34, 44),
	btn = Color3.fromRGB(46, 46, 60),
	text = Color3.fromRGB(196, 200, 214),
	dim = Color3.fromRGB(112, 116, 136),
	ok = Color3.fromRGB(78, 168, 120),
	okDark = Color3.fromRGB(30, 84, 58),
	bad = Color3.fromRGB(190, 82, 90),
	badDark = Color3.fromRGB(100, 44, 50),
	warn = Color3.fromRGB(190, 154, 80),
}

local conns = {}
local function track(c)
	conns[#conns + 1] = c
	return c
end

local function trim(s)
	return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function clean(s)
	return trim((tostring(s or ""):gsub("<.->", "")))
end

local setStatus, refreshStart, startListening, stopListening, startSpam, prewarm, setDirectHook, refreshRemoteBadge
local prof = { detect = 0 }

----------------------------------------------------------------------
-- ÉTAT
----------------------------------------------------------------------
local session = { parts = {}, lastPart = 0, token = 0 }
local listening = false
local listenConn = nil
local topNotification = nil
local ignoreUntil = 0
local lastAttemptAt = 0

----------------------------------------------------------------------
-- GUI Codes (mode Click)
----------------------------------------------------------------------
local uiCache = { box = nil, confirm = nil }
local function getCodesUI()
	if uiCache.confirm and uiCache.confirm.Parent and uiCache.box and uiCache.box.Parent then
		return uiCache.box, uiCache.confirm
	end
	local codes = playerGui:FindFirstChild("Codes")
	codes = codes and codes:FindFirstChild("Codes")
	if not codes then
		return nil, nil
	end
	local box = codes:FindFirstChild("CodeRedeem")
	box = box and box:FindFirstChild("TextBox")
	local confirm = codes:FindFirstChild("Confirm")
	if box and confirm then
		uiCache.box, uiCache.confirm = box, confirm
		box.ClearTextOnFocus = false
	end
	return box, confirm
end

local function fireSignal(sig)
	local ok, list = pcall(getconnections, sig)
	if not ok or #list == 0 then
		return false
	end
	if typeof(firesignal) == "function" and pcall(firesignal, sig) then
		return true
	end
	local any = false
	for _, c in ipairs(list) do
		any = pcall(function()
			c:Fire()
		end) or any
	end
	return any
end

local function clickRedeem(code)
	local box, confirm = getCodesUI()
	if box then
		box.ClearTextOnFocus = false
		box.Text = tostring(code or "")
	end
	if not confirm or typeof(getconnections) ~= "function" then
		return false
	end
	return fireSignal(confirm.Activated) or fireSignal(confirm.MouseButton1Click)
end

----------------------------------------------------------------------
-- REMOTE (cache + capture)
----------------------------------------------------------------------
local remote = nil
local capturing = false
local lastResolve = 0
local cache = { found = nil }

local function loadCache()
	if typeof(isfile) ~= "function" or typeof(readfile) ~= "function" then
		return
	end
	local ok, exists = pcall(isfile, CACHE_FILE)
	if not ok or not exists then
		return
	end
	local ok2, raw = pcall(readfile, CACHE_FILE)
	if not ok2 or type(raw) ~= "string" then
		return
	end
	local ok3, data = pcall(HttpService.JSONDecode, HttpService, raw)
	if ok3 and type(data) == "table" and tostring(data.jobId) == tostring(game.JobId) and type(data.found) == "string" then
		cache.found = data.found
	end
end

local function saveCache()
	if typeof(writefile) ~= "function" then
		return
	end
	local ok, json = pcall(HttpService.JSONEncode, HttpService, { jobId = tostring(game.JobId), found = cache.found })
	if ok then
		pcall(writefile, CACHE_FILE, json)
	end
end

local function getNet()
	local pk = ReplicatedStorage:FindFirstChild("Packages")
	return pk and pk:FindFirstChild("Net")
end

local function resolveRemote()
	if remote and remote.Parent then
		return remote
	end
	remote = nil
	if not cache.found or os.clock() - lastResolve < 1 then
		return nil
	end
	lastResolve = os.clock()
	local net = getNet()
	if not net then
		return nil
	end
	for _, d in ipairs(net:GetDescendants()) do
		if d:IsA("RemoteFunction") and d:GetFullName() == cache.found then
			remote = d
			return d
		end
	end
	return nil
end

local function capture()
	if remote and remote.Parent then
		return remote
	end
	if capturing then
		local limit = os.clock() + 9
		while capturing and os.clock() < limit do
			task.wait(0.001)
		end
		return remote, remote and "ok" or "Capture en cours sans résultat"
	end
	if typeof(hookmetamethod) ~= "function" or typeof(getnamecallmethod) ~= "function" or typeof(newcclosure) ~= "function" then
		return nil, "Capture non supportée par l'executor"
	end
	local net = getNet()
	if not net then
		return nil, "Packages.Net introuvable"
	end

	capturing = true
	local got, old = nil, nil
	local unhooked = false

	local function unhook()
		if unhooked then
			return
		end
		unhooked = true
		pcall(function()
			hookmetamethod(game, "__namecall", old)
		end)
	end

	local ok, err = pcall(function()
		old = hookmetamethod(
			game,
			"__namecall",
			newcclosure(function(self, ...)
				local method = getnamecallmethod()
				if not got and method == "InvokeServer" and typeof(self) == "Instance" and self:IsA("RemoteFunction") and self:IsDescendantOf(net) and (...) == TEST_CODE then
					got = self
				end
				if typeof(setnamecallmethod) == "function" then
					setnamecallmethod(method)
				end
				return old(self, ...)
			end)
		)
	end)

	if not ok then
		capturing = false
		return nil, "Hook impossible : " .. tostring(err)
	end

	ignoreUntil = tick() + 10
	if not clickRedeem(TEST_CODE) then
		unhook()
		capturing = false
		return nil, "Bouton Redeem introuvable"
	end

	local limit = os.clock() + 8
	while not got and os.clock() < limit do
		task.wait(0.001)
	end

	unhook()
	capturing = false

	if got then
		remote = got
		cache.found = got:GetFullName()
		task.defer(saveCache)
		return got, "ok"
	end
	return nil, "Aucun appel capturé"
end


----------------------------------------------------------------------
-- REDEEM (1 tentative)
-- retourne : "success" | "click" | "fail" | "error", message, ms
----------------------------------------------------------------------
local rebinding = false
local function rebindRemote()
	if rebinding or not cache.found then
		return
	end
	rebinding = true
	local net = getNet()
	if net then
		for _, d in ipairs(net:GetDescendants()) do
			if d:IsA("RemoteFunction") and d:GetFullName() == cache.found then
				remote = d
				break
			end
		end
	end
	rebinding = false
end

local lastClickAt = 0
local function redeemOnce(code)
	-- Nettoyage strict de la chaîne assemblée
	code = tostring(code or ""):gsub("%s+", "")

	-- Mode Both : le clic UI part en parallèle du Remote (limité par cfg.clickGap pour ne pas saturer l'UI)
	local bothClicked = false
	if cfg.mode == "Both" then
		local now = os.clock()
		if now - lastClickAt >= cfg.clickGap then
			lastClickAt = now
			bothClicked = true
			task.spawn(clickRedeem, code)
		end
	end

	if cfg.mode == "Remote" or cfg.mode == "Both" then
		-- On cherche le remote actif ou on tente de le ré-ancrer
		local r = remote
		if not (r and r.Parent) then
			r = resolveRemote()
		end

		-- chemin normal : aucun scan. Référence perdue = ré-ancrage en arrière-plan (jamais pendant un submit)
		if not (r and r.Parent) then
			task.spawn(rebindRemote)
		end

		if r and r.Parent then
			local t = os.clock()
			local ok, a, b = pcall(r.InvokeServer, r, code)
			local ms = math.floor((os.clock() - t) * 1000 + 0.5)
			
			if not ok then
				return "error", tostring(a), ms
			end
			if a == true or tostring(a):lower():find("success") then
				return "success", b or a, ms
			end
			return "fail", tostring(b or a or "Rejeté"), ms
		end
	end

	-- Both : le clic est déjà parti, le remote est absent : on attend le texte du jeu (watchFeedback)
	if bothClicked then
		return "click", nil, 0
	end
	-- Secours en Mode Click uniquement si le Remote est totalement introuvable
	if clickRedeem(code) then
		return "click", nil, 0
	end
	return "error", "Remote et Click indisponibles", 0
end

local function lowerHas(msg, ...)
	for _, p in ipairs({ ... }) do
		if msg:find(p, 1, true) then
			return true
		end
	end
	return false
end

----------------------------------------------------------------------
-- WEBHOOK DISCORD (ajout) : redeem OK / sold out / déjà utilisé
-- Envoyé dans un thread à part APRÈS la réponse du serveur : ça ne ralentit pas le submit.
----------------------------------------------------------------------
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local function webhookReady()
	local url = trim(cfg.webhook)
	return url:match("^https://discord%.com/api/webhooks/%d+/")
		or url:match("^https://discordapp%.com/api/webhooks/%d+/")
		or url:match("^https://ptb%.discord%.com/api/webhooks/%d+/")
		or url:match("^https://canary%.discord%.com/api/webhooks/%d+/")
end

local WEBHOOK_STYLE = {
	success = { title = "✅ Code redeem !", color = 5763719 },
	soldout = { title = "❌ Sold out", color = 15548997 },
	already = { title = "⚠️ Code déjà utilisé", color = 16705372 },
	invalid = { title = "⚠️ The code is invalid", color = 16705372 },
	refused = { title = "🚫 Code refusé", color = 10038562 },
	test = { title = "🔔 Test webhook", color = 5793266 },
}

local function cutText(str, n)
	str = tostring(str)
	if #str <= n then
		return str
	end
	local ok, pos = pcall(utf8.offset, str, n + 1)
	return str:sub(1, (ok and pos or n + 1) - 1)
end

local function sendWebhook(kind, code, msg, ms)
	local st = WEBHOOK_STYLE[kind]
	if not st or not httpRequest or not webhookReady() then
		return false
	end
	local url = trim(cfg.webhook)
	local text = type(msg) == "string" and clean(msg) or ""
	local low = text:lower()
	local title, result = st.title, nil
	if kind == "success" then
		result = (low:find("spawned", 1, true) and text) or "Brainrot spawned!"
		title = "✅ " .. result
	elseif kind == "soldout" then
		result = (low:find("sold out", 1, true) and text) or "The code is sold out"
		title = "❌ " .. result
	elseif kind == "invalid" then
		result = (low:find("invalid", 1, true) and text) or "The code is invalid"
		title = "⚠️ " .. result
	end
	task.spawn(function()
		local fields = {
			{ name = "Résultat", value = (kind == "success" and "✅ Ça a marché" or kind == "soldout" and "❌ Sold out" or kind == "invalid" and "⚠️ Invalid code" or kind == "refused" and "🚫 Refusé" or kind == "already" and "⚠️ Déjà utilisé" or "🔔 Test"), inline = false },
			{ name = "Code", value = "`" .. tostring(code) .. "`", inline = true },
			{ name = "Temps", value = tostring(ms or 0) .. " ms", inline = true },
			{ name = "Joueur", value = tostring(lp.Name), inline = true },
		}
		if text ~= "" then
			fields[#fields + 1] = { name = "Réponse du jeu", value = cutText(text, 200) }
		end
		local ok, body = pcall(HttpService.JSONEncode, HttpService, {
			username = "Redeemer by brn782k",
			embeds = { {
				title = cutText(title, 250),
				color = st.color,
				fields = fields,
				footer = { text = "by brn782k" },
				timestamp = DateTime.now():ToIsoDate(),
			} },
		})
		if not ok then
			return
		end
		local sent, res = pcall(httpRequest, {
			Url = url,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = body,
		})
		-- on n'écrit dans l'historique que si le webhook a échoué
		local status = type(res) == "table" and (res.StatusCode or res.status_code) or nil
		if not sent or (type(res) == "table" and res.Success == false) or (status and status >= 300) then
			profLog("⚠️ Webhook non envoyé" .. (status and (" (HTTP " .. tostring(status) .. ")") or ""), C.warn)
		end
	end)
	return true
end

-- Historique : affiche le message exact du jeu / du remote
-- "The code is sold out" / "The code was sold out", "The code is invalid", "<Brainrot> spawned!"
local lastLogKey, lastLogAt = "", 0
local function logGame(kind, msg, ms, code)
	-- même résultat pour le même code dans les 3 s (remote + notification) = une seule ligne
	local key = kind .. "|" .. tostring(code)
	if key == lastLogKey and os.clock() - lastLogAt < 3 then
		return
	end
	lastLogKey, lastLogAt = key, os.clock()
	local text = type(msg) == "string" and clean(msg) or ""
	local low = text:lower()
	local line, col
	if kind == "success" then
		line = "✅ " .. ((low:find("spawned", 1, true) and text) or "Brainrot spawned!")
		col = C.ok
	elseif kind == "soldout" then
		line = "❌ " .. ((low:find("sold out", 1, true) and text) or "The code is sold out")
		col = C.bad
	elseif kind == "invalid" then
		line = "⚠️ " .. ((low:find("invalid", 1, true) and text) or "The code is invalid")
		col = C.warn
	elseif kind == "already" then
		line = "⚠️ " .. ((low:find("already", 1, true) and text) or "Code already redeemed")
		col = C.warn
	elseif kind == "refused" then
		line = "🚫 Refusé" .. (text ~= "" and (" : " .. text) or "")
		col = C.bad
	else
		return
	end
	if code and code ~= "" then
		line = line .. "  · " .. tostring(code)
	end
	profLog(line, col)
end

local function onSuccess(code, msg, ms)
	logGame("success", msg, ms, code)
	local name = code
	if type(msg) == "string" then
		local n = msg:gsub("%s*[Ss]pawned!$", "")
		if n ~= "" then
			name = n
		end
	end
	stopListening()
	setStatus(string.format("OK  %s  (%d ms)  %s", code, ms or 0, name), C.ok)
	refreshStart()
end


do
-- Messages du jeu qui terminent le spam : "Spawned!", "Sold out", "Invalid code", "already redeemed"
-- (le "spawned" n'est pris en compte que dans le GUI Codes : une notif globale peut venir d'un autre joueur)
local function classifyFeedback(text, fromCodesGui)
	local low = tostring(text or ""):lower()
	if low == "" then
		return nil
	end
	if fromCodesGui and low:find("spawned", 1, true) then
		return "success"
	end
	if low:find("sold out", 1, true) then
		return "soldout"
	end
	if low:find("already", 1, true) and low:find("redeem", 1, true) then
		return "already"
	end
	if low:find("invalid code", 1, true) or low:find("code is invalid", 1, true) or low:find("does not exist", 1, true) then
		return "invalid"
	end
	return nil
end

-- Écoute ce que le jeu affiche pendant le spam (notifications du haut + textes du GUI Codes).
-- Renvoie une fonction qui coupe l'écoute.
local function watchFeedback(onKind)
	local list, closed = {}, false

	local function add(c)
		if closed then
			c:Disconnect()
		else
			list[#list + 1] = c
		end
	end

	local function check(label, fromGui)
		local text = clean(label.Text)
		local kind = classifyFeedback(text, fromGui)
		if kind then
			onKind(kind, text)
		end
	end

	local function hookLabel(label, fromGui)
		add(label:GetPropertyChangedSignal("Text"):Connect(function()
			check(label, fromGui)
		end))
	end

	local top = playerGui:FindFirstChild("TopNotification")
	local frame = top and top:FindFirstChild("TopNotification")
	if frame then
		add(frame.ChildAdded:Connect(function(child)
			local function hook(label)
				check(label, false)
				hookLabel(label, false)
			end
			local label = child:IsA("TextLabel") and child or child:FindFirstChildWhichIsA("TextLabel", true)
			if label then
				hook(label)
			end
			add(child.DescendantAdded:Connect(function(d)
				if d:IsA("TextLabel") then
					hook(d)
				end
			end))
		end))
	end

	local codes = playerGui:FindFirstChild("Codes")
	if codes then
		for _, d in ipairs(codes:GetDescendants()) do
			if d:IsA("TextLabel") then
				hookLabel(d, true)
			end
		end
		add(codes.DescendantAdded:Connect(function(d)
			if d:IsA("TextLabel") then
				check(d, true)
				hookLabel(d, true)
			end
		end))
	end

	return function()
		closed = true
		for _, c in ipairs(list) do
			pcall(c.Disconnect, c)
		end
		table.clear(list)
	end
end

-- Envoie le code : burst parallèle au départ, puis (si Spam Redeem est ON) un nouvel envoi
-- toutes les cfg.spamInterval secondes, même si les précédents n'ont pas encore répondu.
-- Le spam s'arrête dès que : Spawned! (succès) / Sold out / Invalid code / déjà redeem
-- (réponse du serveur OU texte affiché par le jeu), ou à la fin de la durée choisie.
-- Le statut GUI est mis à jour APRÈS l'envoi pour ne pas retarder le submit.
startSpam = function(code)
	session.token += 1
	local token = session.token
	lastAttemptAt = tick()
	local t0 = os.clock()
	local leadMs = prof.detect > 0 and (t0 - prof.detect) * 1000 or 0
	local rttLogged = false
	local done, pending, sent = false, 0, 0
	local invalidHooked = false
	local soft = nil -- issue "douce" : décidée quand toutes les réponses en vol sont revenues
	local stopFeedback = function() end

	local remoteOk = (cfg.mode == "Remote" or cfg.mode == "Both") and ((remote ~= nil and remote.Parent ~= nil) or resolveRemote() ~= nil)
	local maxBurst = remoteOk and math.max(1, math.min(cfg.burst, 20)) or 1
	local spamming = cfg.spam
	local loopOn = false
	local attempt

	local function conclude()
		done = true
		stopFeedback()
	end

	local function finalizeSoft()
		conclude()
		local r = soft
		-- code invalide / refusé : on CONTINUE d'écouter et on garde les parties déjà reçues,
		-- pour que la partie suivante complète le code (au lieu de tout arrêter)
		local waitNext = r.kind == "invalid" or r.kind == "refused"
		if not waitNext then
			stopListening()
		end
		if r.kind == "soldout" then
			setStatus(string.format("Épuisé (%dms) : Sold Out !", r.ms or 0), C.bad)
			sendWebhook("soldout", code, r.msg, r.ms)
		elseif r.kind == "invalid" then
			setStatus(string.format("Invalide : %s", code), C.bad)
			if not invalidHooked then
				invalidHooked = true
				sendWebhook("invalid", code, r.msg, r.ms)
			end
		elseif r.kind == "already" then
			session.parts = {}
			setStatus("Déjà redeem : " .. code, C.dim)
			logGame("already", r.msg, r.ms, code)
			sendWebhook("already", code, r.msg, r.ms)
		else
			setStatus(string.format("Refusé (%dms) : %s", r.ms or 0, tostring(r.msg):sub(1, 60)), C.bad)
			logGame("refused", tostring(r.msg), r.ms, code)
			sendWebhook("refused", code, tostring(r.msg), r.ms)
		end
		refreshStart()
	end

	-- texte affiché par le jeu (notification / GUI Codes)
	local function onFeedback(kind, text)
		if done or soft or token ~= session.token then
			return
		end
		local ms = math.floor((os.clock() - t0) * 1000 + 0.5)
		if kind == "soldout" or kind == "invalid" then
			logGame(kind, text, ms, code)
		end
		if kind == "success" then
			conclude()
			onSuccess(code, text, ms)
			sendWebhook("success", code, text, ms)
			return
		end
		if kind == "invalid" and not cfg.stopOnInvalid then
			return
		end
		soft = { kind = kind, msg = text, ms = ms }
		task.delay(0.25, function() -- laisse 0,25 s à un éventuel succès encore en vol
			if not done and token == session.token then
				finalizeSoft()
			end
		end)
	end

	-- réponse du serveur (Mode Remote)
	local function onReply(res, msg, ms)
		if done or token ~= session.token then
			return
		end
		if not rttLogged then
			rttLogged = true
		end
		local reply = tostring(msg or ""):lower()

		-- 1. SUCCÈS : le Brainrot a spawned (prioritaire, immédiat)
		if res == "success" or reply:find("spawned", 1, true) then
			conclude()
			stopListening()
			onSuccess(code, msg, ms)
			sendWebhook("success", code, msg, ms)
			return
		end

		-- Mode Click : clic envoyé, pas de réponse du serveur à lire
		if res == "click" then
			if not spamming then
				conclude()
				stopListening()
				setStatus("Click envoyé : " .. code, C.ok)
				refreshStart()
			end
			return
		end

		local retry = false
		if reply:find("sold out", 1, true) then
			logGame("soldout", msg, ms, code)
			soft = { kind = "soldout", msg = msg, ms = ms }
		elseif lowerHas(reply, "already") and lowerHas(reply, "redeem") then
			soft = { kind = "already", msg = msg, ms = ms }
		elseif res == "error" or lowerHas(reply, "please wait", "rate limit", "ratelimit", "too many request", "try again", "cooldown", "too fast") then
			retry = true -- erreur transitoire
		elseif lowerHas(reply, "invalid code", "code is invalid", "does not exist") then
			logGame("invalid", msg, ms, code)
			if not invalidHooked then
				invalidHooked = true
				sendWebhook("invalid", code, msg, ms)
			end
			if cfg.stopOnInvalid or not spamming then
				soft = soft or { kind = "invalid", msg = msg, ms = ms }
			else
				retry = true -- "Stop invalid" désactivé : on continue de spammer
			end
		else
			soft = soft or { kind = "refused", msg = msg, ms = ms }
		end

		if pending > 0 then
			return -- d'autres réponses arrivent : un succès peut encore passer devant
		end
		if soft then
			return finalizeSoft()
		end
		if retry and spamming then
			return -- le spam renvoie déjà tout seul, la fin est gérée par sa boucle
		end

		if retry and os.clock() - t0 < math.min(cfg.maxSeconds, 15) and sent < 40 then
			task.wait(math.max(cfg.interval, 0.001))
			if not done and token == session.token then
				attempt()
			end
			return
		end

		conclude()
		stopListening()
		setStatus(string.format("Échec (%dms) : %s", ms or 0, tostring(msg):sub(1, 35)), C.bad)
		refreshStart()
	end

	attempt = function()
		pending += 1
		sent += 1
		task.spawn(function()
			local res, msg, ms = redeemOnce(code)
			pending -= 1
			onReply(res, msg, ms)
		end)
	end

	for _ = 1, maxBurst do
		attempt()
	end
	if spamming then
		setStatus(string.format("Envoi : %s  (spam %d ms)", code, math.floor(cfg.spamInterval * 1000 + 0.5)), C.warn)
	else
		setStatus("Envoi : " .. code, C.warn)
	end

	if spamming then
		stopFeedback = watchFeedback(onFeedback)
		if done then
			stopFeedback()
		end
		loopOn = true
		task.spawn(function()
			local limit = math.max(1, cfg.spamSeconds)
			local step = math.max(cfg.spamInterval, 0.01)
			local acc = 0
			while not done and not soft and token == session.token and os.clock() - t0 < limit do
				acc += task.wait() -- plusieurs envois par frame si le délai est plus court qu'une frame
				local burstNow = 0
				while acc >= step and burstNow < 4 do
					acc -= step
					if pending < 80 and sent < 3500 then -- plafond de requêtes en vol : ne sature pas le téléphone
						attempt()
						burstNow += 1
					end
				end
				if acc > step * 4 then
					acc = 0
				end
			end
			loopOn = false

			if token ~= session.token or done then
				stopFeedback()
				return
			end
			if soft then
				return -- fin gérée par onReply / onFeedback
			end

			-- durée écoulée sans résultat : on laisse 2 s aux réponses encore en vol
			local graceUntil = os.clock() + 2
			while pending > 0 and os.clock() < graceUntil and not done and not soft and token == session.token do
				task.wait(0.05)
			end
			if done or soft or token ~= session.token then
				return
			end
			conclude()
			stopListening()
			setStatus(string.format("Spam terminé (%ds, %d envois) : aucun spawn", limit, sent), C.warn)
			refreshStart()
		end)
	end
end

end

----------------------------------------------------------------------
-- DÉTECTION DU CODE (notifications)
----------------------------------------------------------------------
do
local function normalizeInline(s)
	return (tostring(s or ""):upper():gsub("%s+[Gg][Oo][Oo][Dd]%s+[Ll][Uu][Cc][Kk].*$", ""):gsub("[^A-Z0-9]", ""):gsub("GARAMA", "GARAM"):gsub("MANDUNDUNG", "MANDUDUNG"))
end

local function parseCue(text)
	local low = text:lower()
	if low == "" then
		return nil
	end
	local p1, e1 = low:find("the%s+code%s+is%s*")
	if not e1 then
		p1, e1 = low:find("code%s+is%s*")
	end
	local p2, e2 = low:find("the%s+riddle%s+is%s*")
	if not e2 then
		p2, e2 = low:find("riddle%s+is%s*")
	end
	if e1 and (not p2 or p1 < p2) then
		local inline = normalizeInline(text:sub(e1 + 1))
		return "sniper", inline ~= "" and inline or nil
	end
	if e2 then
		return "riddle"
	end
	local sammy = low:find("sammy", 1, true) ~= nil
	if sammy and low:find("riddle", 1, true) then
		return "riddle"
	end
	if sammy and (low:find("code", 1, true) or low:find("ok its", 1, true) or low:find("ok it's", 1, true) or low:find("ok i guess", 1, true)) then
		return "sniper"
	end
	return nil
end

-- notifications générées par le redeem lui-même : à ne pas prendre pour des parties de code
local function isUtility(text)
	local low = text:lower()
	if lowerHas(low, "code redeemed", "redeemed successfully", "already been redeemed", "you got", "remote captured", "captured and saved") then
		return true
	end
	local recent = tick() <= ignoreUntil or tick() - lastAttemptAt < 15
	if recent and lowerHas(low, "invalid code", "code is invalid", "does not exist", "please wait", "rate limit", "ratelimit", "too many request", "try again", "cooldown", "too fast") then
		return true
	end
	return false
end

local lastText, lastTextAt = "", 0

local function addPart(text, full)
	local now = tick()
	if text == lastText and now - lastTextAt < 0.5 then
		return
	end
	lastText, lastTextAt = text, now

	if now - session.lastPart > cfg.staleSeconds then
		session.parts = {}
	end
	session.lastPart = now

	if full then
		session.parts = { text }
	else
		table.insert(session.parts, text)
	end

	local n = #session.parts
	if n >= cfg.parts then
		prof.detect = os.clock()
		startSpam(table.concat(session.parts))
	else
		-- pré-armement : remote résolu, UI Click en cache, avant même que la dernière partie arrive
		if n >= cfg.parts - 1 then
			task.spawn(prewarm)
		end
		setStatus(string.format("Partie %d/%d : %s", n, cfg.parts, text), C.warn)
	end
end

----------------------------------------------------------------------
-- FILTRE CORRIGÉ (%a en minuscule pour les lettres)
----------------------------------------------------------------------
local function isValidCode(text)
    text = text:gsub("^%s*(.-)%s*$", "%1")
    
    if text:find("%s") then
        return false
    end

    -- 1. Uniquement des chiffres (ex: 1234)
    if text:match("^%d+$") then
        return true
    end

    -- 2. Uniquement des lettres en majuscules (ex: CODE)
    if text:match("^%a+$") and text == text:upper() then
        return true
    end

    -- 3. Lettres majuscules + chiffres (ex: CODE123)
    if text:match("^[%a%d]+$") and text == text:upper() and text:find("%a") and text:find("%d") then
        return true
    end

    return false
end

----------------------------------------------------------------------
-- APPLICATION DANS ONTEXT
----------------------------------------------------------------------
local function onText(text)
	if not listening or text == "" or isUtility(text) then
		return
	end

	-- 1. indices "The code is XXXX" : ils contiennent des espaces, donc on les traite AVANT le filtre
	local kind, inline = parseCue(text)
	if kind then
		if kind ~= "sniper" then
			return
		end
		if not inline then
			setStatus("Indice reçu, j'attends le code...", C.warn)
			return
		end
		return addPart(inline, cfg.parts == 1)
	end

	-- 2. partie brute : on ne garde que ce qui ressemble à un morceau de code
	if not isValidCode(text) then
		return
	end
	addPart(text, false)
end

local function findLabel(obj)
	if obj:IsA("TextLabel") then
		return obj
	end
	return obj:FindFirstChildWhichIsA("TextLabel", true)
end

local function watch(child)
	local list, done = {}, false

	local function finish()
		if done then
			return
		end
		done = true
		for _, c in ipairs(list) do
			c:Disconnect()
		end
	end

	local function check()
		if done then
			return true
		end
		local label = findLabel(child)
		if not label then
			return false
		end
		local text = clean(label.Text)
		if text == "" then
			return false
		end
		finish()
		onText(text)
		return true
	end

	if check() then
		return
	end

	local label = findLabel(child)
	if label then
		list[#list + 1] = label:GetPropertyChangedSignal("Text"):Connect(check)
	end
	list[#list + 1] = child.DescendantAdded:Connect(function(d)
		if d:IsA("TextLabel") then
			list[#list + 1] = d:GetPropertyChangedSignal("Text"):Connect(check)
		end
		check()
	end)

	task.delay(0.25, function()
		if not done then
			check()
			finish()
		end
	end)
end

-- Pré-armement : tout ce qui coûte du temps au 1er envoi est fait AVANT que le code soit complet
prewarm = function()
	if cfg.mode ~= "Click" then
		pcall(function()
			if not (remote and remote.Parent) then
				resolveRemote()
			end
		end)
	end
	if cfg.mode ~= "Remote" then
		pcall(getCodesUI)
	end
	if refreshRemoteBadge then
		refreshRemoteBadge()
	end
end

-- Écoute rapide : un seul hook sur le conteneur, chaque TextLabel est lu dès sa création
-- et dès que son texte change (pas d'attente de ChildAdded -> recherche -> délai).
local fastConn, fastLabels = nil, setmetatable({}, { __mode = "k" })
local function startFast()
	if fastConn or not cfg.fastListen or not topNotification then
		return
	end
	local function take(label)
		if fastLabels[label] then
			return
		end
		fastLabels[label] = true
		local conn
		local function read()
			local text = clean(label.Text)
			if text ~= "" then
				if conn then
					conn:Disconnect()
					conn = nil
				end
				onText(text) -- une seule lecture par notification (comme watch)
			end
		end
		conn = label:GetPropertyChangedSignal("Text"):Connect(read)
		read()
	end
	fastConn = topNotification.DescendantAdded:Connect(function(d)
		if d:IsA("TextLabel") then
			take(d)
		end
	end)
end
local function stopFast()
	if fastConn then
		fastConn:Disconnect()
		fastConn = nil
	end
end

-- Hook direct (avancé) : lit la valeur AVANT qu'elle soit écrite dans TextLabel.Text.
-- Désactivé par défaut : le hook passe par chaque écriture de propriété du jeu.
local directOld = nil
local hookSeen = setmetatable({}, { __mode = "k" })
setDirectHook = function(on)
	if on then
		if directOld or typeof(hookmetamethod) ~= "function" or typeof(newcclosure) ~= "function" then
			return directOld ~= nil
		end
		local ok = pcall(function()
			local orig
			orig = hookmetamethod(game, "__newindex", newcclosure(function(self, key, value)
				if key == "Text" and listening and type(value) == "string" and typeof(self) == "Instance" then
					local top = topNotification
					if top and not hookSeen[self] and self:IsA("TextLabel") and self:IsDescendantOf(top) then
						local v = clean(value)
						if v ~= "" then
							hookSeen[self] = true
							task.spawn(onText, v)
						end
					end
				end
				return orig(self, key, value)
			end))
			directOld = orig
		end)
		if not ok then
			directOld = nil
		end
		return ok
	end
	if directOld then
		local prev = directOld
		pcall(function()
			-- on rétablit le comportement d'origine : le closure ne fait plus rien
			hookmetamethod(game, "__newindex", prev)
		end)
		directOld = nil
	end
	return true
end

startListening = function()
	if listening then
		return true
	end
	if not topNotification or topNotification:IsA("ScreenGui") then
		local top = playerGui:FindFirstChild("TopNotification") or playerGui:WaitForChild("TopNotification", 5)
		topNotification = top and (top:FindFirstChild("TopNotification") or top:WaitForChild("TopNotification", 5))
	end
	if not topNotification then
		setStatus("TopNotification introuvable", C.bad)
		return false
	end
	listening = true
	session.parts = {}
	session.lastPart = 0
	listenConn = topNotification.ChildAdded:Connect(watch)
	startFast()
	if cfg.directHook then
		setDirectHook(true)
	end
	task.spawn(prewarm)
	setStatus("Écoute... (" .. cfg.parts .. " parties)", C.ok)
	return true
end

stopListening = function()
	listening = false
	session.token += 1
	session.parts = {}
	if listenConn then
		listenConn:Disconnect()
		listenConn = nil
	end
	stopFast()
	setDirectHook(false)
end

end -- fin du bloc détection du code

----------------------------------------------------------------------
-- BOOST FPS / PING
----------------------------------------------------------------------
local pingFlags = {
	{ "DFFlagSampleAndRefreshRakPing", "True" },
	{ "DFFlagRakNetUseSlidingWindow4", "True" },
	{ "DFIntMaxReceiveToDeserializeLatencyMilliseconds", "15" },
	{ "DFIntNetworkInDeserializeLimitGameplayMsClient", "6" },
	{ "DFIntNetworkInProcessLimitGameplayMsClient", "6" },
	{ "DFIntMaxWaitTimeBeforeForcePacketProcessMS", "1" },
	{ "DFIntClientPacketMaxDelayMs", "11" },
	{ "DFIntClientPacketMaxFrameMicroseconds", "200" },
	{ "DFIntClientPacketMinMicroseconds", "1" },
	{ "DFIntRakNetNakResendDelayMs", "10" },
	{ "DFIntRakNetNakResendDelayMsMax", "100" },
	{ "DFIntRakNetResendRttMultiple", "1" },
	{ "DFIntRakNetLoopMs", "1" },
	{ "DFIntRakNetSelectTimeoutMs", "1" },
	{ "DFIntMaxProcessPacketsStepsPerCyclic", "5000" },
	{ "DFIntMaxProcessPacketsJobScaling", "10000" },
	{ "DFIntMegaReplicatorNetworkQualityProcessorUnit", "10" },
	{ "DFFlagCoreScriptTelemetry2", "False" },
	{ "FFlagEnableTelemetryService1", "False" },
	{ "FFlagOpenTelemetryEnabled2", "False" },
	{ "FFlagPerfDataOnTelemetryV2", "False" },
	{ "FIntTelemetryProfilerFrequency", "0" },
	{ "DFIntTelemetryProfilerHundredthsPercentage", "0" },
	{ "FIntPerformanceTelemetryQueueProcessLimit", "0" },
}

local fpsFlags = {
	{ "DFFlagTextureQualityOverrideEnabled", "True" },
	{ "DFIntTextureQualityOverride", "0" },
	{ "FIntDebugTextureManagerSkipMips", "7" },
	{ "DFIntDebugFRMQualityLevelOverride", "1" },
	{ "FIntDebugForceMSAASamples", "1" },
	{ "FIntFRMMaxGrassDistance", "0" },
	{ "FIntFRMMinGrassDistance", "0" },
	{ "FIntRobloxGuiBlurIntensity", "0" },
	{ "FIntRenderLocalLightFadeInMs", "0" },
	{ "DFIntAnimationLodFacsDistanceMin", "0" },
	{ "DFIntAnimationLodFacsDistanceMax", "0" },
	{ "DFIntAnimationLodFacsVisibilityDenominator", "0" },
	{ "FFlagFastGPULightCulling3", "True" },
	{ "FFlagCacheTextBoundsInGuiText", "True" },
}

----------------------------------------------------------------------
-- FFLAGS AVANCÉS (ajout) : fusionnés dans pingFlags / fpsFlags, rien n'est retiré.
-- Les flags que ton executor / Roblox ne connaît pas sont ignorés sans erreur.
----------------------------------------------------------------------
do
local extraPingFlags = {
	-- réseau / RakNet
	{ "DFIntRaknetBandwidthInfluxHundredthsPercentageV2", "10000" },
	{ "DFIntRakNetClockDriftAdjustmentPerPingMillisecond", "100" },
	{ "DFIntRakNetNakResendDelayRttPercent", "50" },
	{ "DFIntRakNetMinAckGrowthPercent", "0" },
	{ "DFIntRaknetBandwidthPingSendEveryXSeconds", "1" },
	{ "DFIntRakNetMtuValue1InBytes", "1280" },
	{ "DFIntRakNetMtuValue2InBytes", "1240" },
	{ "DFIntRakNetMtuValue3InBytes", "1200" },
	{ "DFIntConnectionMTUSize", "1260" },
	{ "FIntRakNetResendBufferArrayLength", "128" },
	{ "DFIntOptimizePingThreshold", "50" },
	{ "DFIntWaitOnRecvFromLoopEndedMS", "100" },
	{ "DFIntWaitOnUpdateNetworkLoopEndedMS", "100" },
	{ "DFIntLargePacketQueueSizeCutoffMB", "1000" },
	{ "DFIntClientPacketHealthyAllocationPercent", "20" },
	{ "DFIntClientPacketExcessMicroseconds", "1000" },
	{ "DFIntMaxProcessPacketsStepsAccumulated", "0" },
	{ "DFIntMaxFrameBufferSize", "4" },
	{ "DFIntCodecMaxIncomingPackets", "100" },
	{ "DFIntCodecMaxOutgoingFrames", "10000" },
	{ "DFIntSignalRCoreRpcQueueSize", "256" },
	{ "DFIntSignalRCoreServerTimeoutMs", "11100" },
	{ "DFIntSignalRCoreKeepAlivePingPeriodMs", "250" },
	{ "DFIntSignalRCoreTimerMs", "750" },
	{ "DFIntSignalRHubConnectionBaseRetryTimeMs", "100" },
	{ "DFIntSignalRHubConnectionHeartbeatTimerRateMs", "1000" },
	{ "FFlagSpecifyNetworkReplicatorScope", "True" },
	{ "FFlagSpecifyNetworkReplicatorScopeForItems", "True" },
	-- télémétrie / logs coupés (moins de trafic + moins de CPU)
	{ "FFlagDebugDisableTelemetryEphemeralCounter", "True" },
	{ "FFlagDebugDisableTelemetryEphemeralStat", "True" },
	{ "FFlagDebugDisableTelemetryEventIngest", "True" },
	{ "FFlagDebugDisableTelemetryPoint", "True" },
	{ "FFlagDebugDisableTelemetryV2Counter", "True" },
	{ "FFlagDebugDisableTelemetryV2Event", "True" },
	{ "FFlagDebugDisableTelemetryV2Stat", "True" },
	{ "DFFlagBrowserTrackerIdTelemetryEnabled", "False" },
	{ "DFFlagVideoCaptureServiceEnabled", "False" },
	{ "FFlagSendRenderFidelityTelemetry2", "False" },
	{ "FIntReportDeviceInfoRollout", "0" },
}

local extraFpsFlags = {
	-- rendu / ombres / lumières
	{ "FFlagDisablePostFx", "True" },
	{ "FIntRenderShadowIntensity", "0" },
	{ "FIntRenderShadowmapBias", "0" },
	{ "FIntRenderMaxShadowAtlasUsageBeforeDownscale", "80" },
	{ "FIntRenderShadowMapDepthCacheMemLimit", "192" },
	{ "FFlagRenderAllocateShadowMapResourcesOnDemand", "True" },
	{ "FIntRenderLocalLightUpdatesMax", "1" },
	{ "FIntRenderLocalLightUpdatesMin", "1" },
	{ "DFFlagDebugPauseVoxelizer", "True" },
	{ "FFlagDebugForceFSMCPULightCulling", "True" },
	{ "FFlagGlobalWindRendering", "False" },
	{ "FFlagGlobalWindActivated", "False" },
	{ "FIntRenderGrassDetailStrands", "0" },
	{ "FIntGrassMovementReducedMotionFactor", "0" },
	-- LOD forcé au plus bas
	{ "DFIntCSGLevelOfDetailSwitchingDistance", "0" },
	{ "DFIntCSGLevelOfDetailSwitchingDistanceL12", "0" },
	{ "DFIntCSGLevelOfDetailSwitchingDistanceL23", "0" },
	{ "DFIntCSGLevelOfDetailSwitchingDistanceL34", "0" },
	-- textures / mémoire
	{ "TextureQualityOverrideEnabled", "True" },
	{ "TextureQualityOverride", "1" },
	{ "FIntUITextureMaxRenderTextureSize", "1024" },
	{ "FIntTerrainOTAMaxTextureSize", "1024" },
	{ "FIntDefaultMeshCacheSizeMB", "256" },
	{ "DFIntDebugRestrictGCDistance", "1" },
	{ "DFFlagOptimizePartsInPart", "True" },
	{ "DFFlagDebugPerfMode", "True" },
	-- CPU / threads / fps
	{ "DFIntTaskSchedulerTargetFps", "240" },
	{ "FFlagTaskSchedulerLimitTargetFpsTo2402", "False" },
	{ "FFlagGameBasicSettingsFramerateCap5", "False" },
	{ "FFlagBaseThreadPoolUseRuntime2", "True" },
	{ "FIntTaskSchedulerAutoThreadLimit", "6" },
	{ "FIntTaskSchedulerAsyncTasksMinimumThreadCount", "2" },
	{ "FIntOcclusionWorkerThreadCount", "5" },
	{ "FFlagRenderGpuTextureCompressor", "True" },
	{ "DFIntRenderingEngineMaxFrameTimeMs", "0" },
}

for _, f in ipairs(extraPingFlags) do
	table.insert(pingFlags, f)
end
for _, f in ipairs(extraFpsFlags) do
	table.insert(fpsFlags, f)
end

local morePingFlags = {
	{ "FFlagLargeReplicatorEnabled6", "True" },
	{ "FFlagLargeReplicatorWrite5", "True" },
	{ "FFlagLargeReplicatorRead5", "True" },
	{ "DFFlagDebugDisableTimeoutDisconnect", "True" },
	{ "DFIntPhysicsReceiveNumParallelTasks", "4" },
	{ "DFIntReplicationDataCacheNumParallelTasks", "4" },
	{ "DFIntInterpolationNumParallelTasks", "4" },
	{ "DFIntS2PhysicsSenderRate", "30" },
	{ "DFIntDataSenderRate", "60" },
	{ "DFIntNetworkStopProducingPacketsToProcessThresholdMs", "1" },
	{ "DFIntRakNetPingFrequencyMillisecond", "250" },
	{ "DFIntRakNetCongestionControlMinCwnd", "64" },
	{ "DFIntRakNetNakResendDelayRttPercent", "30" },
	{ "FIntRakNetPingThrottle", "0" },
	{ "DFIntHttpCurlConnectionCacheSize", "64" },
	{ "DFIntHttpCurlConnectionCacheExpirationSecs", "600" },
	{ "DFIntHttpSendRetries", "0" },
	{ "DFIntHttpBatchLimit", "16" },
	{ "FFlagHttpUseNewDnsResolver", "True" },
	{ "DFFlagAnalyticsEnableLogs", "False" },
	{ "FFlagEnableLogsReporting", "False" },
	{ "FFlagCrashUploaderEnabled", "False" },
	{ "FFlagDisableUploadCrashDumps", "True" },
	{ "FIntCrashUploadToBacktracePercentage", "0" },
	{ "FFlagDisableAnalyticsReporting", "True" },
	{ "DFFlagDisablePlayerReportsForMobile", "True" },
}

local moreFpsFlags = {
	{ "DFFlagSkipHighResolutiontextureMipsOnLowMemoryDevices", "True" },
	{ "DFFlagSkipHighResolutiontextureMipsOnLowMemoryDevices2", "True" },
	{ "DFFlagDebugRenderForceTechnologyVoxel", "True" },
	{ "FFlagDebugSkyGray", "True" },
	{ "FFlagDebugDisableOTAMaterialTexture", "True" },
	{ "FIntRenderShadowmapBias", "0" },
	{ "FFlagDebugRenderingSetDeterministic", "False" },
	{ "FIntRenderLocalLightUpdatesMax", "0" },
	{ "FIntRenderGrassHeightScaler", "0" },
	{ "FIntRenderGrassDetailStrands", "0" },
	{ "FFlagGlobalWindRendering", "False" },
	{ "FIntFRMMinGrassDistance", "0" },
	{ "FIntFRMMaxGrassDistance", "0" },
	{ "FFlagSkyUseTextureCompression", "True" },
	{ "FFlagRenderSkipSkyLightingUpdate", "True" },
	{ "DFIntTextureCompositorActiveJobs", "1" },
	{ "FIntMeshContentProviderForceCacheSize", "268435456" },
	{ "FIntRobloxGuiBlurIntensity", "0" },
	{ "FFlagDisableDynamicHeads", "True" },
	{ "FFlagEnableAvatarDetailReduction", "True" },
	{ "FFlagMaterialManagerSkipLoad", "True" },
	{ "FFlagUseNewPlayerListFrameLimiter", "True" },
	{ "FIntEmotesMenuUpdateRateMs", "1000" },
	{ "DFIntAnimationLodFacsDistanceMin", "0" },
	{ "FIntAnimationClipCacheLifetimeSec", "30" },
	{ "FFlagDisableAnimationsFromOffScreen", "True" },
	{ "DFIntPhysicsDecompForceUpgradeVersion", "0" },
	{ "DFIntSimBroadPhaseCacheSize", "2048" },
	{ "FFlagAdaptiveStreamingOptimization", "True" },
	{ "DFIntGraphicsOptimizationModeMaxFrameTimeTargetMs", "6" },
	{ "DFIntGraphicsOptimizationModeMinFrameTimeTargetMs", "4" },
	{ "FIntGraphicsOptimizationModeFRMFrameRateTarget", "240" },
	{ "FFlagGraphicsOptimizationMode", "True" },
	{ "DFIntPerformanceControlFrameTimeMax", "99999" },
	{ "FIntFramerateTargetFloor", "240" },
}

for _, f in ipairs(morePingFlags) do
	table.insert(pingFlags, f)
end
for _, f in ipairs(moreFpsFlags) do
	table.insert(fpsFlags, f)
end
end -- fin des flags supplémentaires

local PERF = {}
local jumps, speed, setJumps, setSpeed
do
local flagOriginal = {}

local function applyFlags(list, on)
	local setter = (typeof(setfflag) == "function" and setfflag) or (typeof(setfflags) == "function" and setfflags) or nil
	if not setter then
		return false
	end
	local count = 0
	for _, f in ipairs(list) do
		local name, value = f[1], f[2]
		if on then
			if flagOriginal[name] == nil and typeof(getfflag) == "function" then
				local ok, v = pcall(getfflag, name)
				if ok and v ~= nil then
					flagOriginal[name] = tostring(v)
				end
			end
			if pcall(setter, name, value) then
				count += 1
			end
		else
			local o = flagOriginal[name]
			if o ~= nil and pcall(setter, name, o) then
				count += 1
			end
		end
	end
	return count > 0
end

local fps = { on = false, saved = {}, conn = nil }

local function isEffect(d)
	return d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles")
end

local function setFpsBoost(on)
	fps.on = on
	if on then
		pcall(function()
			fps.quality = settings().Rendering.QualityLevel
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		end)
		pcall(function()
			fps.shadows = Lighting.GlobalShadows
			Lighting.GlobalShadows = false
		end)
		pcall(function()
			fps.decoration = workspace.Terrain.Decoration
			workspace.Terrain.Decoration = false
		end)
		if typeof(setfpscap) == "function" then
			if typeof(getfpscap) == "function" then
				pcall(function()
					fps.cap = getfpscap()
				end)
			end
			pcall(setfpscap, 240)
		end
		for _, v in ipairs(Lighting:GetChildren()) do
			if v:IsA("PostEffect") then
				fps.saved[v] = v.Enabled
				v.Enabled = false
			end
		end
		fps.conn = workspace.DescendantAdded:Connect(function(d)
			if fps.on and isEffect(d) then
				d.Enabled = false
			end
		end)
		task.spawn(function()
			local n = 0
			for _, d in ipairs(workspace:GetDescendants()) do
				if not fps.on then
					break
				end
				if isEffect(d) then
					if fps.saved[d] == nil then
						fps.saved[d] = d.Enabled
					end
					d.Enabled = false
				end
				n += 1
				if n % 400 == 0 then
					task.wait(0.001)
				end
			end
		end)
	else
		if fps.conn then
			fps.conn:Disconnect()
			fps.conn = nil
		end
		if fps.cap and typeof(setfpscap) == "function" then
			pcall(setfpscap, fps.cap)
			fps.cap = nil
		end
		pcall(function()
			if fps.quality then
				settings().Rendering.QualityLevel = fps.quality
			end
			if fps.shadows ~= nil then
				Lighting.GlobalShadows = fps.shadows
			end
			if fps.decoration ~= nil then
				workspace.Terrain.Decoration = fps.decoration
			end
		end)
		for inst, was in pairs(fps.saved) do
			pcall(function()
				inst.Enabled = was
			end)
		end
		fps.saved = {}
	end
	return applyFlags(fpsFlags, on)
end

----------------------------------------------------------------------
-- ANTI-LAG EXTRÊME (ajout)
-- Matériaux plats, ombres / décals / lumières / effets coupés, eau + brouillard off,
-- qualité et détail des meshes au minimum, FFlags FPS. Tout est restauré en OFF.
----------------------------------------------------------------------
local lag = { on = false, orig = setmetatable({}, { __mode = "k" }), conn = nil, env = {}, token = 0 }

local function lagSave(inst, props)
	if lag.orig[inst] == nil then
		lag.orig[inst] = props
	end
end

local function lagStrip(d)
	if d:IsA("BasePart") then
		if d:IsA("Terrain") then
			return
		end
		lagSave(d, { Material = d.Material, Reflectance = d.Reflectance, CastShadow = d.CastShadow })
		d.Material = Enum.Material.SmoothPlastic
		d.Reflectance = 0
		d.CastShadow = false
	elseif d:IsA("Decal") or d:IsA("Texture") then
		lagSave(d, { Transparency = d.Transparency })
		d.Transparency = 1
	elseif d:IsA("Light") or isEffect(d) then
		lagSave(d, { Enabled = d.Enabled })
		d.Enabled = false
	end
end

local function lagSweep(token)
	local n = 0
	for _, d in ipairs(workspace:GetDescendants()) do
		if not lag.on or token ~= lag.token then
			return
		end
		pcall(lagStrip, d)
		n += 1
		if n % 300 == 0 then
			task.wait()
		end
	end
end

local function setExtremeAntiLag(on)
	lag.on = on
	lag.token += 1
	if on then
		local token = lag.token
		pcall(function()
			lag.env.quality = settings().Rendering.QualityLevel
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		end)
		pcall(function()
			lag.env.mesh = settings().Rendering.MeshPartDetailLevel
			settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
		end)
		pcall(function()
			lag.env.shadows = Lighting.GlobalShadows
			lag.env.fogEnd = Lighting.FogEnd
			Lighting.GlobalShadows = false
			Lighting.FogEnd = 9e8
		end)
		pcall(function()
			local t = workspace.Terrain
			lag.env.water = { t.WaterWaveSize, t.WaterWaveSpeed, t.WaterReflectance, t.WaterTransparency }
			lag.env.decoration = t.Decoration
			t.WaterWaveSize, t.WaterWaveSpeed, t.WaterReflectance, t.WaterTransparency = 0, 0, 0, 1
			t.Decoration = false
		end)
		for _, v in ipairs(Lighting:GetChildren()) do
			pcall(function()
				if v:IsA("PostEffect") then
					lagSave(v, { Enabled = v.Enabled })
					v.Enabled = false
				elseif v:IsA("Atmosphere") then
					lagSave(v, { Density = v.Density, Haze = v.Haze })
					v.Density, v.Haze = 0, 0
				end
			end)
		end
		if typeof(setfpscap) == "function" then
			pcall(setfpscap, 240)
		end
		lag.conn = workspace.DescendantAdded:Connect(function(d)
			if lag.on then
				pcall(lagStrip, d)
			end
		end)
		task.spawn(lagSweep, token)
	else
		if lag.conn then
			lag.conn:Disconnect()
			lag.conn = nil
		end
		pcall(function()
			if lag.env.quality then
				settings().Rendering.QualityLevel = lag.env.quality
			end
			if lag.env.mesh then
				settings().Rendering.MeshPartDetailLevel = lag.env.mesh
			end
			if lag.env.shadows ~= nil then
				Lighting.GlobalShadows = lag.env.shadows
			end
			if lag.env.fogEnd ~= nil then
				Lighting.FogEnd = lag.env.fogEnd
			end
			local t, w = workspace.Terrain, lag.env.water
			if w then
				t.WaterWaveSize, t.WaterWaveSpeed, t.WaterReflectance, t.WaterTransparency = w[1], w[2], w[3], w[4]
			end
			if lag.env.decoration ~= nil then
				t.Decoration = lag.env.decoration
			end
		end)
		task.spawn(function()
			local n = 0
			for inst, props in pairs(lag.orig) do
				for k, v in pairs(props) do
					pcall(function()
						inst[k] = v
					end)
				end
				lag.orig[inst] = nil
				n += 1
				if n % 300 == 0 then
					task.wait()
				end
			end
		end)
		lag.env = {}
	end
	return applyFlags(fpsFlags, on)
end

-- 3D OFF : coupe totalement le rendu 3D (écran noir, FPS max, GUI intacte). Remets sur OFF pour revoir le jeu.
local function set3dRender(off)
	return (pcall(function()
		RunService:Set3dRenderingEnabled(not off)
	end))
end

-- ANTI-LAG EXTRÊME + : joueurs, UI du jeu, éclairage, matériaux, animations
local StarterGui = game:GetService("StarterGui")
local MaterialService = game:GetService("MaterialService")
local ex = { on = false, hidden = {}, saved = {}, conns = {}, loop = 0, core = {} }

local function isCosmetic(d)
	return d:IsA("Accessory") or d:IsA("Shirt") or d:IsA("Pants") or d:IsA("ShirtGraphic") or d:IsA("CharacterMesh")
end

local function hideCosmetic(d)
	if ex.on and ex.hidden[d] == nil and isCosmetic(d) then
		ex.hidden[d] = d.Parent
		d.Parent = nil
	end
end

local function exWatchChar(char)
	for _, d in ipairs(char:GetDescendants()) do
		pcall(hideCosmetic, d)
	end
	ex.conns[#ex.conns + 1] = char.DescendantAdded:Connect(function(d)
		task.defer(pcall, hideCosmetic, d)
	end)
end

local function exWatchPlayer(pl)
	if pl == lp then
		return
	end
	if pl.Character then
		task.spawn(pcall, exWatchChar, pl.Character)
	end
	ex.conns[#ex.conns + 1] = pl.CharacterAdded:Connect(function(c)
		task.wait(0.5)
		if ex.on then
			pcall(exWatchChar, c)
		end
	end)
end

local function extremePlus(on)
	ex.on = on
	ex.loop += 1
	if on then
		local token = ex.loop
		pcall(function()
			ex.saved.diffuse, ex.saved.specular, ex.saved.soft = Lighting.EnvironmentDiffuseScale, Lighting.EnvironmentSpecularScale, Lighting.ShadowSoftness
			Lighting.EnvironmentDiffuseScale, Lighting.EnvironmentSpecularScale, Lighting.ShadowSoftness = 0, 0, 0
		end)
		pcall(function()
			if typeof(sethiddenproperty) == "function" and typeof(gethiddenproperty) == "function" then
				ex.saved.tech = gethiddenproperty(Lighting, "Technology")
				sethiddenproperty(Lighting, "Technology", Enum.Technology.Compatibility)
			end
		end)
		pcall(function()
			ex.saved.mat2022 = MaterialService.Use2022Materials
			MaterialService.Use2022Materials = false
		end)
		pcall(function()
			local sky = Lighting:FindFirstChildOfClass("Sky")
			if sky then
				ex.saved.sky = { sky, sky.StarCount, sky.CelestialBodiesShown }
				sky.StarCount, sky.CelestialBodiesShown = 0, false
			end
		end)
		pcall(function()
			for _, t in ipairs({ Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.Chat, Enum.CoreGuiType.EmotesMenu, Enum.CoreGuiType.Health }) do
				ex.core[t] = StarterGui:GetCoreGuiEnabled(t)
				StarterGui:SetCoreGuiEnabled(t, false)
			end
		end)
		for _, pl in ipairs(Players:GetPlayers()) do
			exWatchPlayer(pl)
		end
		ex.conns[#ex.conns + 1] = Players.PlayerAdded:Connect(exWatchPlayer)
		task.spawn(function()
			while ex.on and token == ex.loop do
				for _, pl in ipairs(Players:GetPlayers()) do
					local hum = pl ~= lp and pl.Character and pl.Character:FindFirstChildOfClass("Humanoid")
					local animator = hum and hum:FindFirstChildOfClass("Animator")
					if animator then
						for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do
							pcall(tr.Stop, tr, 0)
						end
					end
				end
				task.wait(1.5)
			end
		end)
		pcall(collectgarbage, "collect")
	else
		for _, c in ipairs(ex.conns) do
			pcall(c.Disconnect, c)
		end
		ex.conns = {}
		pcall(function()
			if ex.saved.diffuse ~= nil then
				Lighting.EnvironmentDiffuseScale, Lighting.EnvironmentSpecularScale, Lighting.ShadowSoftness = ex.saved.diffuse, ex.saved.specular, ex.saved.soft
			end
			if ex.saved.tech ~= nil then
				sethiddenproperty(Lighting, "Technology", ex.saved.tech)
			end
			if ex.saved.mat2022 ~= nil then
				MaterialService.Use2022Materials = ex.saved.mat2022
			end
			if ex.saved.sky then
				local k = ex.saved.sky
				k[1].StarCount, k[1].CelestialBodiesShown = k[2], k[3]
			end
		end)
		for t, was in pairs(ex.core) do
			pcall(StarterGui.SetCoreGuiEnabled, StarterGui, t, was)
		end
		for d, parent in pairs(ex.hidden) do
			pcall(function()
				d.Parent = parent
			end)
		end
		ex.hidden, ex.saved, ex.core = {}, {}, {}
	end
end

-- ANTI-LAG DÉTAILLÉ : une catégorie = un interrupteur, restauration complète en OFF
local fx = {}

local function fxMake(match, apply, undo)
	local c = { on = false, saved = {}, conn = nil, token = 0 }
	local function matches(d)
		local ok, m = pcall(match, d)
		return ok and m
	end
	c.set = function(on)
		c.on = on
		c.token += 1
		if on then
			local tk = c.token
			c.conn = workspace.DescendantAdded:Connect(function(d)
				if c.on and matches(d) then
					pcall(apply, c, d)
				end
			end)
			task.spawn(function()
				local n = 0
				for _, d in ipairs(workspace:GetDescendants()) do
					if not c.on or tk ~= c.token then
						return
					end
					if matches(d) then
						pcall(apply, c, d)
					end
					n += 1
					if n % 300 == 0 then
						task.wait()
					end
				end
			end)
		else
			if c.conn then
				c.conn:Disconnect()
				c.conn = nil
			end
			local saved = c.saved
			c.saved = {}
			task.spawn(function()
				local n = 0
				for inst, st in pairs(saved) do
					pcall(undo, inst, st)
					n += 1
					if n % 300 == 0 then
						task.wait()
					end
				end
			end)
		end
	end
	return c
end

local function restoreEnabled(inst, v)
	inst.Enabled = v
end

fx.clothes = fxMake(isCosmetic, function(c, d)
	c.saved[d] = d.Parent
	d.Parent = nil
end, function(inst, parent)
	inst.Parent = parent
end)

fx.colors = fxMake(function(d)
	return d:IsA("BasePart") and not d:IsA("Terrain")
end, function(c, d)
	c.saved[d] = d.Color
	d.Color = Color3.fromRGB(118, 118, 128)
end, function(inst, col)
	inst.Color = col
end)

fx.textures = fxMake(function(d)
	return d:IsA("Decal") or d:IsA("Texture") or d:IsA("SurfaceAppearance") or (d:IsA("MeshPart") and d.TextureID ~= "")
end, function(c, d)
	if d:IsA("SurfaceAppearance") then
		c.saved[d] = { "parent", d.Parent }
		d.Parent = nil
	elseif d:IsA("MeshPart") then
		c.saved[d] = { "tex", d.TextureID }
		d.TextureID = ""
	else
		c.saved[d] = { "tr", d.Transparency }
		d.Transparency = 1
	end
end, function(inst, st)
	if st[1] == "parent" then
		inst.Parent = st[2]
	elseif st[1] == "tex" then
		inst.TextureID = st[2]
	else
		inst.Transparency = st[2]
	end
end)

fx.particles = fxMake(isEffect, function(c, d)
	c.saved[d] = d.Enabled
	d.Enabled = false
end, restoreEnabled)

fx.lights = fxMake(function(d)
	return d:IsA("Light")
end, function(c, d)
	c.saved[d] = d.Enabled
	d.Enabled = false
end, restoreEnabled)

local soundSaved = nil
fx.sound = {
	on = false,
	set = function(on)
		fx.sound.on = on
		pcall(function()
			local ugs = UserSettings():GetService("UserGameSettings")
			if on then
				soundSaved = ugs.MasterVolume
				ugs.MasterVolume = 0
			elseif soundSaved ~= nil then
				ugs.MasterVolume = soundSaved
				soundSaved = nil
			end
		end)
	end,
}

PERF.fps, PERF.lag, PERF.ex, PERF.fx = fps, lag, ex, fx
PERF.applyFlags, PERF.setFpsBoost, PERF.setExtremeAntiLag = applyFlags, setFpsBoost, setExtremeAntiLag
PERF.set3dRender, PERF.extremePlus = set3dRender, extremePlus


-- Unlimited Jumps (méthode Heresy) : tant que tu maintiens Espace (ou le bouton saut sur mobile), tu es repropulsé vers le haut
jumps = { on = false, conn = nil }
function setJumps(on)
	jumps.on = on
	if jumps.conn then jumps.conn:Disconnect() jumps.conn = nil end
	if on then
		local last = 0
		jumps.conn = RunService.Heartbeat:Connect(function()
			local c = lp.Character
			local hrp = c and c:FindFirstChild("HumanoidRootPart")
			local hum = c and c:FindFirstChildOfClass("Humanoid")
			if not hrp or not hum or hum.Health <= 0 then return end
			if not (UserInputService:IsKeyDown(Enum.KeyCode.Space) or hum.Jump) then return end
			local now = tick()
			if now - last < 0.1 then return end
			last = now
			local v = hrp.AssemblyLinearVelocity
			hrp.AssemblyLinearVelocity = Vector3.new(v.X, 55, v.Z)
		end)
	end
end

-- Waverider Speed (méthode Heresy "Carpet Speed") : Waverider équipé = vitesse horizontale forcée dans ta direction de marche
speed = { on = false, conn = nil, value = 140 }
function setSpeed(on)
	speed.on = on
	if speed.conn then speed.conn:Disconnect() speed.conn = nil end
	if on then
		local last = 0
		speed.conn = RunService.Heartbeat:Connect(function()
			local now = tick()
			if now - last < 0.066 then return end
			last = now
			local c = lp.Character
			local hum = c and c:FindFirstChildOfClass("Humanoid")
			local hrp = c and c:FindFirstChild("HumanoidRootPart")
			if not hum or not hrp then return end
			local tool = c:FindFirstChild("Waverider")
			if not tool then
				-- auto-équipe le Waverider depuis le sac
				local bp = lp:FindFirstChildOfClass("Backpack")
				local tb = bp and bp:FindFirstChild("Waverider")
				if tb then pcall(function() hum:EquipTool(tb) end) end
				return
			end
			local md = hum.MoveDirection
			local v = hrp.AssemblyLinearVelocity
			if md.Magnitude > 0 then
				hrp.AssemblyLinearVelocity = Vector3.new(md.X * speed.value, v.Y, md.Z * speed.value)
			else
				hrp.AssemblyLinearVelocity = Vector3.new(0, v.Y, 0)
			end
		end)
	end
end

PERF.shutdown = function()
	if jumps.on then pcall(setJumps, false) end
	if speed.on then pcall(setSpeed, false) end
	if fps.conn then
		pcall(function()
			fps.conn:Disconnect()
		end)
	end
	if lag.on then
		pcall(setExtremeAntiLag, false)
	end
	if ex.on then
		pcall(extremePlus, false)
	end
	for _, cat in pairs(fx) do
		if cat.on then
			pcall(cat.set, false)
		end
	end
end
end -- fin du bloc perf





----------------------------------------------------------------------
-- GUI GALAXIE PORTRAIT : fenêtre verticale 290 x 500, noir / galaxie / violet, onglets en bas
----------------------------------------------------------------------
local TweenService = game:GetService("TweenService")

local T = {
	bg = Color3.fromRGB(6, 4, 15),
	panel = Color3.fromRGB(14, 9, 30),
	panel2 = Color3.fromRGB(26, 17, 56),
	stroke = Color3.fromRGB(56, 38, 112),
	accent = Color3.fromRGB(118, 72, 236),
	accentHi = Color3.fromRGB(160, 120, 255),
	accent2 = Color3.fromRGB(70, 100, 232),
	pink = Color3.fromRGB(176, 62, 190),
}

local function tw(o, t, props)
	TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

local function mk(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do
		o[k] = v
	end
	o.Parent = parent
	return o
end

local function corner(o, r)
	return mk("UICorner", { CornerRadius = UDim.new(0, r) }, o)
end

local function stroke(o, color, thickness)
	return mk("UIStroke", { Color = color, Thickness = thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, o)
end

local function gradient(o, c1, c2, rotation)
	return mk("UIGradient", { Color = ColorSequence.new(c1, c2), Rotation = rotation or 0 }, o)
end

local function gradient3(o, c1, c2, c3, rotation)
	return mk("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, c1),
			ColorSequenceKeypoint.new(0.5, c2),
			ColorSequenceKeypoint.new(1, c3),
		}),
		Rotation = rotation or 0,
	}, o)
end

local function btn(parent, text, x, y, w, h, bg)
	local b = mk("TextButton", {
		Size = UDim2.fromOffset(w, h),
		Position = UDim2.fromOffset(x, y),
		BackgroundColor3 = bg or T.panel2,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = C.text,
		Text = text,
	}, parent)
	corner(b, 8)
	return b
end

local function card(parent, x, y, w, h)
	local f = mk("Frame", {
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(w, h),
		BackgroundColor3 = T.panel,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
	}, parent)
	corner(f, 8)
	stroke(f, T.stroke, 1)
	return f
end

local function hover(b, base, over)
	track(b.MouseEnter:Connect(function()
		tw(b, 0.15, { BackgroundColor3 = over })
	end))
	track(b.MouseLeave:Connect(function()
		tw(b, 0.2, { BackgroundColor3 = base })
	end))
end

local gui = mk("ScreenGui", {
	Name = "BRN782K_Redeemer",
	ResetOnSpawn = false,
	DisplayOrder = 999,
	IgnoreGuiInset = true,
}, (typeof(gethui) == "function" and gethui()) or playerGui)

-- Portrait : 290 de large, hauteur adaptée à l'écran (500 max). Onglets EN HAUT, pages défilantes :
-- plus rien ne sort de l'écran sur téléphone.
local WIDTH, FULL_H, HEAD_H, TAB_H, STATUS_H = 290, 500, 38, 30, 24
local CX, CY = 8, HEAD_H + TAB_H + 8
local CW = WIDTH - 16
local PAGE_SIZE = UDim2.new(0, CW, 1, -(CY + STATUS_H + 12))
local TOP_Y, collapsed = 48, false

local function fitWindow()
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
	TOP_Y = vp.Y < 600 and 6 or 48
	FULL_H = math.clamp(math.floor(vp.Y) - TOP_Y - 6, 250, 500)
end
fitWindow()

local main = mk("Frame", {
	Size = UDim2.fromOffset(WIDTH, FULL_H),
	Position = UDim2.new(0.5, -WIDTH / 2, 0, TOP_Y),
	BackgroundColor3 = T.bg,
	BorderSizePixel = 0,
	ClipsDescendants = true,
}, gui)
corner(main, 14)
do
	local rim = gradient3(stroke(main, C.text, 1.4), T.accent, T.accent2, T.pink, 45)
	TweenService:Create(rim, TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), { Rotation = 405 }):Play()
end
gradient(main, Color3.fromRGB(255, 255, 255), Color3.fromRGB(110, 110, 140), 60)

-- Fond galaxie : nébuleuses violettes / bleues + petites étoiles blanches (derrière tout le reste)
do
local function nebula(px, py, size, color, base)
	for i = 1, 3 do
		local s = size * (1 - (i - 1) * 0.32)
		local f = mk("Frame", {
			Position = UDim2.new(px, -s / 2, py, -s / 2),
			Size = UDim2.fromOffset(s, s),
			BackgroundColor3 = color,
			BackgroundTransparency = base - (i - 1) * 0.012,
			BorderSizePixel = 0,
		}, main)
		corner(f, s / 2)
	end
end
nebula(0.88, 0.08, 290, Color3.fromRGB(112, 50, 224), 0.94)
nebula(0.04, 0.5, 260, Color3.fromRGB(40, 72, 224), 0.955)
nebula(0.96, 0.97, 270, Color3.fromRGB(176, 54, 180), 0.95)

do
	local rng = Random.new(782)
	local twinkle = 0
	for i = 1, 130 do
		local sz = (i % 9 == 0) and 2 or 1
		local st = mk("Frame", {
			Position = UDim2.new(rng:NextNumber(), 0, rng:NextNumber(), 0),
			Size = UDim2.fromOffset(sz, sz),
			BackgroundColor3 = (i % 6 == 0) and Color3.fromRGB(180, 154, 255) or Color3.fromRGB(238, 238, 252),
			BackgroundTransparency = rng:NextNumber(0.3, 0.85),
			BorderSizePixel = 0,
		}, main)
		if sz == 2 then
			corner(st, 1)
		end
		if i % 7 == 0 and twinkle < 16 then -- 16 étoiles qui scintillent max (léger pour le téléphone)
			twinkle += 1
			TweenService:Create(
				st,
				TweenInfo.new(rng:NextNumber(1.4, 3.6), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{ BackgroundTransparency = 0.95 }
			):Play()
		end
	end
end
end

-- Fond animé : aurore douce qui glisse + étoile filante + halo en haut (léger : 2 tweens + 1 boucle lente)
do
	local aurora = mk("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.9,
		BorderSizePixel = 0,
		Active = false,
	}, main)
	corner(aurora, 14)
	local ag = mk("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(84, 40, 190)),
			ColorSequenceKeypoint.new(0.45, Color3.fromRGB(40, 90, 220)),
			ColorSequenceKeypoint.new(0.8, Color3.fromRGB(176, 54, 180)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(84, 40, 190)),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.85),
			NumberSequenceKeypoint.new(0.5, 0.97),
			NumberSequenceKeypoint.new(1, 0.85),
		}),
		Rotation = 28,
		Offset = Vector2.new(-0.6, 0),
	}, aurora)
	TweenService:Create(ag, TweenInfo.new(11, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Offset = Vector2.new(0.6, 0) }):Play()

	local halo = mk("Frame", {
		Size = UDim2.new(1, 0, 0, 120),
		BackgroundColor3 = Color3.fromRGB(118, 72, 236),
		BackgroundTransparency = 0.9,
		BorderSizePixel = 0,
		Active = false,
	}, main)
	corner(halo, 14)
	mk("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 1) }),
	}, halo)

	local vignette = mk("Frame", {
		Position = UDim2.new(0, 0, 1, -140),
		Size = UDim2.new(1, 0, 0, 140),
		BackgroundColor3 = Color3.fromRGB(2, 1, 8),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Active = false,
	}, main)
	corner(vignette, 14)
	mk("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.15) }),
	}, vignette)

	task.spawn(function()
		local rng = Random.new(os.clock() * 1000)
		while main.Parent do
			task.wait(rng:NextNumber(4, 9))
			if not main.Parent or collapsed then
				continue
			end
			local star = mk("Frame", {
				Size = UDim2.fromOffset(34, 1),
				Rotation = 35,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(rng:NextNumber(0.5, 1), 0, 0, rng:NextNumber(40, 160)),
				BackgroundColor3 = Color3.fromRGB(220, 210, 255),
				BackgroundTransparency = 0.2,
				BorderSizePixel = 0,
				Active = false,
			}, main)
			mk("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }) }, star)
			local t = TweenService:Create(star, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.new(star.Position.X.Scale - 0.45, 0, 0, star.Position.Y.Offset + 150),
				BackgroundTransparency = 1,
			})
			t:Play()
			t.Completed:Once(function()
				star:Destroy()
			end)
		end
	end)
end

-- En-tête
local bar = mk("Frame", { Size = UDim2.new(1, 0, 0, HEAD_H), BackgroundColor3 = T.panel, BackgroundTransparency = 0.3, BorderSizePixel = 0 }, main)
do
local title = mk("TextLabel", {
	Position = UDim2.fromOffset(14, 4),
	Size = UDim2.fromOffset(110, 18),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBlack,
	TextSize = 15,
	TextColor3 = C.text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "REDEEMER",
}, bar)
gradient3(title, T.accentHi, T.accent2, T.pink, 0)
mk("TextLabel", {
	Position = UDim2.fromOffset(14, 21),
	Size = UDim2.fromOffset(110, 12),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextColor3 = C.dim,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "by brn782k",
}, bar)
local line = mk("Frame", { Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.text, BorderSizePixel = 0 }, bar)
gradient3(line, T.accent, T.accent2, T.pink, 0)
end

local minBtn = btn(bar, "-", WIDTH - 52, 8, 22, 22)
local closeBtn = btn(bar, "x", WIDTH - 26, 8, 22, 22)
hover(minBtn, T.panel2, T.stroke)
hover(closeBtn, T.panel2, C.badDark)

do
local Stats = game:GetService("Stats")
local statsLabel = mk("TextLabel", {
	Position = UDim2.fromOffset(WIDTH - 52 - 8 - 90, 12),
	Size = UDim2.fromOffset(90, 14),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	TextSize = 11,
	TextColor3 = C.dim,
	TextXAlignment = Enum.TextXAlignment.Right,
	Text = "--ms  --fps",
}, bar)

task.spawn(function()
	local frames = 0
	track(RunService.Heartbeat:Connect(function()
		frames += 1
	end))
	local item
	pcall(function()
		item = Stats.Network.ServerStatsItem["Data Ping"]
	end)
	local last = os.clock()
	while gui.Parent do
		task.wait(0.5)
		local now = os.clock()
		local f = math.floor(frames / (now - last) + 0.5)
		frames, last = 0, now
		local ping = 0
		if item then
			local ok, v = pcall(item.GetValue, item)
			ping = ok and math.floor(v + 0.5) or 0
		end
		statsLabel.Text = string.format("%dms  %dfps", ping, f)
		statsLabel.TextColor3 = (ping <= 90 and C.ok) or (ping <= 160 and C.warn) or C.bad
	end
end)
end

-- Barre d'onglets (en bas)
local side = mk("Frame", { Position = UDim2.fromOffset(0, HEAD_H), Size = UDim2.fromOffset(WIDTH, TAB_H), BackgroundColor3 = T.panel, BackgroundTransparency = 0.25, BorderSizePixel = 0 }, main)
mk("Frame", { Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.stroke, BorderSizePixel = 0 }, side)

local tabs = {}
do
local tabDefs = { { "main", "Redeemer" }, { "fps", "FPS Boost" }, { "func", "FONCTIONNALITY" }, { "log", "Historique" } }
for i, def in ipairs(tabDefs) do
	local b = mk("TextButton", {
		Position = UDim2.new((i - 1) / #tabDefs, 0, 0, 0),
		Size = UDim2.new(1 / #tabDefs, 0, 1, -1),
		BackgroundColor3 = T.panel2,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = C.dim,
		Text = def[2],
	}, side)
	local mark = mk("Frame", { Position = UDim2.new(0.18, 0, 1, -3), Size = UDim2.new(0.64, 0, 0, 2), BackgroundColor3 = T.accentHi, BorderSizePixel = 0, Visible = false }, b)
	corner(mark, 1)
	tabs[def[1]] = { btn = b, mark = mark }
		track(b.Activated:Connect(function()
			switchPage(def[1])
		end))
	end
end

-- Pages
local body, pageFps, pageFunc, pageLog, switchPage
do
	local function newPage(canvasH)
		return mk("ScrollingFrame", {
			Position = UDim2.fromOffset(CX, CY),
			Size = PAGE_SIZE,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = T.accent,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			CanvasSize = UDim2.fromOffset(0, canvasH),
			Visible = false,
		}, main)
	end
	body = newPage(470) -- page Redeemer
	pageFps = newPage(340)
	pageFunc = newPage(290)
	pageLog = newPage(260)
	pages = { main = body, fps = pageFps, func = pageFunc, log = pageLog }

function switchPage(name)
	for pageName, page in pairs(pages) do
		if page then page.Visible = (pageName == name) end
		local t = tabs[pageName]
		if t and t.btn then t.btn.TextColor3 = (pageName == name) and T.accent or C.dim end
		if t and t.mark then t.mark.Visible = (pageName == name) end
	end
end
end

-- Barre de statut (visible sur tous les onglets)
local statusCard = card(main, CX, 0, CW, STATUS_H)
statusCard.Position = UDim2.new(0, CX, 1, -(STATUS_H + 8))
do
local dot = mk("Frame", { Position = UDim2.fromOffset(10, 8), Size = UDim2.fromOffset(8, 8), BackgroundColor3 = C.dim, BorderSizePixel = 0 }, statusCard)
corner(dot, 4)
local statusLabel = mk("TextLabel", {
	Position = UDim2.fromOffset(26, 0),
	Size = UDim2.fromOffset(CW - 34, STATUS_H),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	TextSize = 11,
	TextTruncate = Enum.TextTruncate.AtEnd,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.dim,
	Text = "Initialisation...",
}, statusCard)

local uiLast, uiQueued, uiText, uiColor = 0, false, "", nil
local function applyStatus()
	uiQueued = false
	uiLast = os.clock()
	local col = uiColor or C.text
	statusLabel.Text = uiText
	statusLabel.TextColor3 = col
	dot.BackgroundColor3 = col
end
setStatus = function(text, color)
	uiText, uiColor = text, color
	if os.clock() - uiLast >= 0.12 then
		applyStatus()
	elseif not uiQueued then
		uiQueued = true
		applyStatus()
	end
end
end

-- HISTORIQUE (onglet Historique) : les lignes s'écrivent directement dans la page visible (pageLog)
do
local logFrame = pageLog
logFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
logFrame.CanvasSize = UDim2.new()
mk("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) }, logFrame)
mk("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingTop = UDim.new(0, 2), PaddingRight = UDim.new(0, 6) }, logFrame)

local emptyLabel = mk("TextLabel", {
	Size = UDim2.new(1, -8, 0, 30),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextColor3 = C.dim,
	Text = "Ici : spawned / sold out / invalid / refusé / déjà redeem pour chaque code.",
	LayoutOrder = 1,
}, logFrame)

local logRows, logN = {}, 0
local function pushLog(text, color)
	text = tostring(text)
	if emptyLabel then
		emptyLabel:Destroy()
		emptyLabel = nil
	end
	logN += 1
	logRows[#logRows + 1] = mk("TextLabel", {
		Size = UDim2.new(1, -8, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextColor3 = color or C.text,
		Text = os.date("%H:%M:%S") .. "  " .. text,
		LayoutOrder = -logN, -- le plus récent en haut
	}, logFrame)
	if #logRows > 60 then
		table.remove(logRows, 1):Destroy()
	end
end

profLog = pushLog
local baseSetStatus = setStatus
setStatus = function(text, color)
	baseSetStatus(text, color)
end
end

----------------------------------------------------------------------
-- COMPOSANTS
----------------------------------------------------------------------
local function toggle(label, x, y, parent, w)
	w = w or 134
	local b = mk("TextButton", {
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(w, 28),
		BackgroundColor3 = T.panel,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
	}, parent or body)
	corner(b, 8)
	stroke(b, T.stroke, 1)
	mk("TextLabel", {
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.fromOffset(w - 52, 28),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = label,
	}, b)
	local rail = mk("Frame", { Position = UDim2.fromOffset(w - 36, 7), Size = UDim2.fromOffset(28, 14), BackgroundColor3 = T.stroke, BorderSizePixel = 0 }, b)
	corner(rail, 7)
	local knob = mk("Frame", { Position = UDim2.fromOffset(2, 2), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = C.text, BorderSizePixel = 0 }, rail)
	corner(knob, 5)
	local function set(on)
		tw(rail, 0.18, { BackgroundColor3 = on and T.accent or T.stroke })
		tw(knob, 0.18, { Position = on and UDim2.fromOffset(16, 2) or UDim2.fromOffset(2, 2) })
	end
	return b, set
end

-- Compteur générique : get() = valeur affichée, change(dir) = -1 / +1, fmt(v) = texte, after() = rappel
local function stepper(label, x, y, w, parent, get, change, fmt, after)
	local c = card(parent or body, x, y, w, 28)
	local minus = btn(c, "-", 3, 3, 22, 22)
	local val = mk("TextLabel", {
		Position = UDim2.fromOffset(25, 0),
		Size = UDim2.fromOffset(w - 50, 28),
		BackgroundTransparency = 1,
		RichText = true,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = C.text,
		Text = "",
	}, c)
	local plus = btn(c, "+", w - 25, 3, 22, 22)
	hover(minus, T.panel2, T.stroke)
	hover(plus, T.panel2, T.stroke)
	local function render()
		local v = get()
		val.Text = string.format('<font color="rgb(120,112,150)">%s</font>  %s', label, fmt and fmt(v) or tostring(v))
	end
	render()
	local function press(dir)
		change(dir)
		render()
		if after then
			after()
		end
		saveSettings()
	end
	track(minus.Activated:Connect(function()
		press(-1)
	end))
	track(plus.Activated:Connect(function()
		press(1)
	end))
	return render
end

local function cfgStepper(label, x, y, key, lo, hi, w, parent)
	return stepper(label, x, y, w, parent, function()
		return cfg[key]
	end, function(d)
		cfg[key] = math.clamp(cfg[key] + d, lo, hi)
	end)
end

local function section(parent, text, y)
	mk("TextLabel", {
		Position = UDim2.fromOffset(2, y),
		Size = UDim2.fromOffset(CW - 4, 14),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = T.accentHi,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = text,
	}, parent)
end

local function hint(parent, text, y, h)
	return mk("TextLabel", {
		Position = UDim2.fromOffset(2, y),
		Size = UDim2.fromOffset(CW - 4, h),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 10,
		TextWrapped = true,
		TextColor3 = C.dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = text,
	}, parent)
end

----------------------------------------------------------------------
-- PAGE REDEEMER
----------------------------------------------------------------------
local startBtn = btn(body, "START", 0, 0, 130, 32, T.accent)
startBtn.TextSize = 13
gradient(startBtn, Color3.fromRGB(215, 215, 225), Color3.fromRGB(140, 140, 160), 90)

refreshStart = function()
	startBtn.Text = listening and "STOP" or "START"
	startBtn.BackgroundColor3 = listening and C.bad or T.accent
end
refreshStart()

local refreshMode
do
local modeCard = card(body, 136, 0, 138, 32)
local modeBtns = {
	Remote = btn(modeCard, "Remote", 2, 2, 44, 28, T.panel),
	Click = btn(modeCard, "Click", 48, 2, 44, 28, T.panel),
	Both = btn(modeCard, "Both", 94, 2, 42, 28, T.panel),
}
for _, b in pairs(modeBtns) do
	b.TextSize = 10
end
refreshMode = function()
	for name, b in pairs(modeBtns) do
		b.BackgroundColor3 = cfg.mode == name and T.accent or T.panel
	end
end
for name, b in pairs(modeBtns) do
	track(b.Activated:Connect(function()
		cfg.mode = name
		refreshMode()
		saveSettings()
		task.spawn(prewarm)
		setStatus(name == "Both" and "Mode Both : Remote + Click en parallèle" or ("Mode " .. name), C.ok)
	end))
end
refreshMode()
end

cfgStepper("Parts", 0, 38, "parts", 1, 6, 134)
cfgStepper("Burst", 140, 38, "burst", 1, 20, 134)

-- Code manuel
local codeBox = mk("TextBox", {
	Position = UDim2.fromOffset(0, 74),
	Size = UDim2.fromOffset(200, 30),
	BackgroundColor3 = T.panel,
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	PlaceholderText = "Code manuel",
	PlaceholderColor3 = C.dim,
	Text = tostring(persist.code or ""),
	Font = Enum.Font.GothamMedium,
	TextSize = 12,
	TextColor3 = C.text,
	TextXAlignment = Enum.TextXAlignment.Left,
}, body)
corner(codeBox, 8)
mk("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, codeBox)
do
local codeStroke = stroke(codeBox, T.stroke, 1)
track(codeBox.Focused:Connect(function()
	tw(codeStroke, 0.2, { Color = T.accent })
end))
track(codeBox.FocusLost:Connect(function()
	tw(codeStroke, 0.2, { Color = T.stroke })
	persist.code = trim(codeBox.Text)
	saveSettings()
end))
end
local goBtn = btn(body, "GO", 206, 74, 68, 30, T.accent)
hover(goBtn, T.accent, T.accentHi)

-- Spam Redeem : renvoie le code toutes les X ms jusqu'à Spawned / Sold out / Invalid
do
section(body, "SPAM REDEEM", 112)
local spamBtn, setSpamUI = toggle("Spam Redeem", 0, 128, body, 134)
setSpamUI(cfg.spam)
track(spamBtn.Activated:Connect(function()
	cfg.spam = not cfg.spam
	setSpamUI(cfg.spam)
	setStatus(cfg.spam and string.format("Spam Redeem ON (%d ms, %ds)", math.floor(cfg.spamInterval * 1000 + 0.5), cfg.spamSeconds) or "Spam Redeem OFF", cfg.spam and C.ok or C.dim)
	saveSettings()
end))

local invBtn, setInvUI = toggle("Stop invalid", 140, 128, body, 134)
setInvUI(cfg.stopOnInvalid)
track(invBtn.Activated:Connect(function()
	cfg.stopOnInvalid = not cfg.stopOnInvalid
	setInvUI(cfg.stopOnInvalid)
	setStatus(cfg.stopOnInvalid and "Le spam s'arrête sur Invalid code" or "Le spam continue même sur Invalid code", cfg.stopOnInvalid and C.ok or C.warn)
	saveSettings()
end))

local MS_STEPS = { 10, 20, 30, 40, 50, 60, 80, 100, 150, 200, 300, 500, 1000 }
local function intervalMs()
	return math.floor(cfg.spamInterval * 1000 + 0.5)
end
local function nearestStep(ms)
	local best, bestDiff = 1, math.huge
	for i, v in ipairs(MS_STEPS) do
		local d = math.abs(v - ms)
		if d < bestDiff then
			best, bestDiff = i, d
		end
	end
	return best
end

local chips, refreshChips = {}, nil
local renderInterval = stepper("Délai", 0, 162, 134, body, intervalMs, function(dir)
	local i = math.clamp(nearestStep(intervalMs()) + dir, 1, #MS_STEPS)
	cfg.spamInterval = MS_STEPS[i] / 1000
end, function(v)
	return v .. " ms"
end, function()
	refreshChips()
end)
cfgStepper("Durée", 140, 162, "spamSeconds", 1, 30, 134)

refreshChips = function()
	local cur = intervalMs()
	for _, c in ipairs(chips) do
		local on = c.ms == cur
		c.btn.BackgroundColor3 = on and T.accent or T.panel2
		c.btn.TextColor3 = on and C.text or C.dim
	end
end
for i, ms in ipairs({ 20, 50, 100, 200 }) do
	local b = btn(body, ms .. " ms", (i - 1) * 70, 198, 64, 26, T.panel2)
	b.TextSize = 11
	chips[i] = { btn = b, ms = ms }
	track(b.Activated:Connect(function()
		cfg.spamInterval = ms / 1000
		renderInterval()
		refreshChips()
		saveSettings()
		setStatus(string.format("Spam : un envoi toutes les %d ms", ms), C.ok)
	end))
end
refreshChips()
hint(body, "Renvoie le code toutes les X ms (même sans réponse) jusqu'à Spawned! / Sold out / Invalid code, ou la fin de la durée.", 230, 40)
end

-- Webhook Discord (saisie + test)
section(body, "WEBHOOK DISCORD", 278)
local whBox = mk("TextBox", {
	Position = UDim2.fromOffset(0, 294),
	Size = UDim2.fromOffset(200, 28),
	BackgroundColor3 = T.panel,
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	PlaceholderText = "https://discord.com/api/webhooks/...",
	PlaceholderColor3 = C.dim,
	Text = tostring(cfg.webhook or ""),
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextColor3 = C.text,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
}, body)
corner(whBox, 8)
mk("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, whBox)
do
local whStroke = stroke(whBox, T.stroke, 1)
track(whBox.Focused:Connect(function()
	tw(whStroke, 0.2, { Color = T.accent })
end))
track(whBox.FocusLost:Connect(function()
	tw(whStroke, 0.2, { Color = T.stroke })
	local v = trim(whBox.Text)
	if v ~= "" then
		cfg.webhook = v
		saveSettings()
	end
end))
end
local whBtn = btn(body, "Test", 206, 294, 68, 28, T.panel2)
hover(whBtn, T.panel2, T.stroke)

-- AVANCÉ : écoute rapide, hook direct, arrêt Sold out, état du remote
do
section(body, "AVANCÉ", 332)
local fastBtn, setFastUI = toggle("Écoute rapide", 0, 348, body, 134)
setFastUI(cfg.fastListen)
track(fastBtn.Activated:Connect(function()
	cfg.fastListen = not cfg.fastListen
	setFastUI(cfg.fastListen)
	saveSettings()
	setStatus(cfg.fastListen and "Écoute rapide : ON (au prochain START)" or "Écoute rapide : OFF", cfg.fastListen and C.ok or C.dim)
end))

local hookBtn, setHookUI = toggle("Hook direct", 140, 348, body, 134)
setHookUI(cfg.directHook)
track(hookBtn.Activated:Connect(function()
	local want = not cfg.directHook
	if want and (typeof(hookmetamethod) ~= "function" or typeof(newcclosure) ~= "function") then
		setStatus("Hook direct non supporté par l'executor", C.bad)
		return
	end
	cfg.directHook = want
	setHookUI(want)
	saveSettings()
	if listening then
		setDirectHook(want)
	end
	setStatus(want and "Hook direct : ON (actif pendant l'écoute)" or "Hook direct : OFF", want and C.warn or C.dim)
end))


local badgeCard = card(body, 140, 380, 134, 28)
local badge = mk("TextLabel", {
	Position = UDim2.fromOffset(12, 0),
	Size = UDim2.fromOffset(110, 28),
	BackgroundTransparency = 1,
	RichText = true,
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	TextColor3 = C.text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "",
}, badgeCard)
refreshRemoteBadge = function()
	local ready = remote ~= nil and remote.Parent ~= nil
	local uiReady = uiCache.confirm ~= nil and uiCache.confirm.Parent ~= nil
	local txt, col
	if ready and uiReady then
		txt, col = "Remote + UI", "rgb(78,168,120)"
	elseif ready then
		txt, col = "Remote prêt", "rgb(78,168,120)"
	elseif uiReady then
		txt, col = "UI prête", "rgb(190,154,80)"
	else
		txt, col = "non prêt", "rgb(190,82,90)"
	end
	badge.Text = string.format('<font color="rgb(120,112,150)">État</font>  <font color="%s">%s</font>', col, txt)
end
refreshRemoteBadge()
hint(body, "Both = Remote + clic UI en parallèle. Sold out : arrêt après N réponses d'affilée. Hook direct : lit le texte avant son écriture (peut ne pas marcher selon l'executor).", 414, 52)
end

----------------------------------------------------------------------
-- PAGE FPS BOOST
----------------------------------------------------------------------
local fpsBtn, setFpsUI = toggle("FPS Boost", 0, 0, pageFps)
local pingBtn, setPingUI = toggle("Ping Boost", 140, 0, pageFps)
local lagBtn, setLagUI = toggle("Anti-Lag", 0, 32, pageFps)
local r3Btn, setR3UI = toggle("3D OFF", 140, 32, pageFps)

local fxSet = {}
do
local fxRows = {
	{ "Sons", "sound", 0, 64 },
	{ "Particules", "particles", 140, 64 },
	{ "Lumières", "lights", 0, 96 },
	{ "Textures", "textures", 140, 96 },
	{ "Couleurs", "colors", 0, 128 },
	{ "Vêtements", "clothes", 140, 128 },
}
for _, row in ipairs(fxRows) do
	local b, setUI = toggle(row[1], row[3], row[4], pageFps)
	local cat = PERF.fx[row[2]]
	fxSet[row[2]] = setUI
	track(b.Activated:Connect(function()
		local on = not cat.on
		cat.set(on)
		setUI(on)
		persist.fx[row[2]] = on
		saveSettings()
		setStatus(row[1] .. (on and " : ON" or " : OFF"), on and C.ok or C.dim)
	end))
end
end
hint(pageFps, "Chaque option se restaure en OFF. Compare tes FPS avec le compteur en haut.", 166, 28)




-- PAGE FONCTIONNALITY (placée après les helpers GUI : toggle / section / hint / stepper)
do
local function hasWaverider()
	local bp = lp:FindFirstChildOfClass("Backpack")
	return (bp and bp:FindFirstChild("Waverider") ~= nil) or (lp.Character and lp.Character:FindFirstChild("Waverider") ~= nil) or false
end

section(pageFunc, "JUMPS", 0)
local jumpBtn, setJumpUI = toggle("Unlimited Jumps", 0, 16, pageFunc, 274)
setJumpUI(persist.jumpsOn)
track(jumpBtn.Activated:Connect(function()
	persist.jumpsOn = not persist.jumpsOn
	setJumps(persist.jumpsOn)
	setJumpUI(persist.jumpsOn)
	saveSettings()
	setStatus(persist.jumpsOn and "Jumps : ON" or "Jumps : OFF", persist.jumpsOn and C.ok or C.dim)
end))
hint(pageFunc, "Maintiens Espace (ou saut mobile) pour monter.", 62, 28)

section(pageFunc, "SPEED", 104)
local speedBtn, setSpeedUI = toggle("Waverider Speed", 0, 120, pageFunc, 134)
setSpeedUI(false)
local renderSpeed = stepper("Vitesse", 140, 120, 134, pageFunc, function()
	return persist.speedVal
end, function(d)
	persist.speedVal = math.clamp(persist.speedVal + d * 10, 10, 300)
	speed.value = persist.speedVal
end)
track(speedBtn.Activated:Connect(function()
	if not persist.speedOn and not hasWaverider() then
		setStatus("Speed : Waverider introuvable dans ton sac", C.bad)
		return
	end
	persist.speedOn = not persist.speedOn
	speed.value = persist.speedVal
	setSpeed(persist.speedOn)
	setSpeedUI(persist.speedOn)
	saveSettings()
	setStatus(persist.speedOn and ("Speed : " .. persist.speedVal) or "Speed : OFF", persist.speedOn and C.ok or C.dim)
end))
hint(pageFunc, "Équipe le Waverider tout seul. 10-300 (140 conseillé).", 174, 28)

-- Réapplique les réglages sauvegardés (speed seulement si on a le Waverider)
if persist.speedOn then
	if hasWaverider() then
		speed.value = persist.speedVal
		setSpeed(true)
		setSpeedUI(true)
	else
		persist.speedOn = false
	end
end
if persist.jumpsOn then
	setJumps(true)
	setJumpUI(true)
end
end

----------------------------------------------------------------------
-- ACTIONS
----------------------------------------------------------------------
track(startBtn.Activated:Connect(function()
	if listening then
		stopListening()

	else
		startListening()
	end
	refreshStart()
end))

track(goBtn.Activated:Connect(function()
	local code = trim(codeBox.Text)
	if code == "" then
		setStatus("Entre un code", C.bad)
		return
	end
	persist.code = code
	saveSettings()
	prof.detect = os.clock()
	startSpam(code)
end))

track(fpsBtn.Activated:Connect(function()
	local on = not PERF.fps.on
	local flagsOk = PERF.setFpsBoost(on)
	setFpsUI(on)
	persist.fps = on
	saveSettings()
	if on and not flagsOk then
		setStatus("FPS boost actif (FFlags non supportés)", C.warn)
	end
end))

local pingOn = false
track(pingBtn.Activated:Connect(function()
	pingOn = not pingOn
	local flagsOk = PERF.applyFlags(pingFlags, pingOn)
	setPingUI(pingOn)
	if pingOn and not flagsOk then
		pingOn = false
		setPingUI(false)
		setStatus("Ping boost non supporté (setfflag)", C.bad)
	end
	persist.ping = pingOn
	saveSettings()
end))

local lagOn = false
track(lagBtn.Activated:Connect(function()
	lagOn = not lagOn
	local flagsOk = PERF.setExtremeAntiLag(lagOn)
	pcall(PERF.extremePlus, lagOn)
	setLagUI(lagOn)
	persist.lag = lagOn
	saveSettings()
	if lagOn then
		setStatus(flagsOk and "Anti-Lag extrême actif" or "Anti-Lag actif (FFlags non supportés)", flagsOk and C.ok or C.warn)
	else
		setStatus("Anti-Lag désactivé", C.dim)
	end
end))

local r3Off = false
track(r3Btn.Activated:Connect(function()
	local want = not r3Off
	if PERF.set3dRender(want) then
		r3Off = want
		setR3UI(want)
		setStatus(want and "Rendu 3D coupé (écran noir)" or "Rendu 3D rétabli", want and C.warn or C.ok)
	else
		setStatus("3D OFF non supporté par l'executor", C.bad)
	end
end))

track(whBtn.Activated:Connect(function()
	local v = trim(whBox.Text)
	if v ~= "" then
		cfg.webhook = v
		saveSettings()
	end
	if not webhookReady() then
		setStatus("Webhook vide ou invalide", C.bad)
	elseif not httpRequest then
		setStatus("Executor sans fonction request", C.bad)
	else
		sendWebhook("test", "TEST", "Webhook OK", 0)
		setStatus("Test webhook envoyé", C.ok)
	end
end))

-- Réglages sauvegardés : on réapplique les boosts activés la dernière fois (3D OFF ne sont jamais relancés seuls)
task.defer(function()
	switchPage("main")
	if pages.main then pages.main.Visible = true end
	if persist.fps then
		PERF.setFpsBoost(true)
		setFpsUI(true)
	end
	if persist.ping then
		pingOn = PERF.applyFlags(pingFlags, true)
		setPingUI(pingOn)
	end
	if persist.lag then
		lagOn = true
		PERF.setExtremeAntiLag(true)
		pcall(PERF.extremePlus, true)
		setLagUI(true)
	end
	for name, on in pairs(persist.fx) do
		if on and PERF.fx[name] and fxSet[name] then
			PERF.fx[name].set(true)
			fxSet[name](true)
		end
	end
end)

-- Navigation entre onglets
local page = "main"
local function applyPage()
	local open = not collapsed
	for name, f in pairs(pages) do
		f.Visible = open and page == name
	end
	side.Visible = open
	statusCard.Visible = open
	for name, t in pairs(tabs) do
		local on = name == page
		t.mark.Visible = on
		t.btn.BackgroundTransparency = on and 0.15 or 1
		t.btn.TextColor3 = on and C.text or C.dim
	end
end
for name, t in pairs(tabs) do
	track(t.btn.Activated:Connect(function()
		page = name
		applyPage()
	end))
	track(t.btn.MouseEnter:Connect(function()
		if name ~= page then
			tw(t.btn, 0.15, { BackgroundTransparency = 0.6 })
		end
	end))
	track(t.btn.MouseLeave:Connect(function()
		if name ~= page then
			tw(t.btn, 0.2, { BackgroundTransparency = 1 })
		end
	end))
end
applyPage()

local function applySize()
	main.Size = UDim2.fromOffset(WIDTH, collapsed and HEAD_H or FULL_H)
end

-- garde toujours la fenêtre (et surtout son en-tête) dans l'écran
local function keepOnScreen()
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize
	if not vp then
		return
	end
	local ax, ay = main.AbsolutePosition.X, main.AbsolutePosition.Y
	local nx = math.clamp(ax, 0, math.max(0, vp.X - WIDTH))
	local ny = math.clamp(ay, 0, math.max(0, vp.Y - (collapsed and HEAD_H or FULL_H) - 4))
	if nx ~= ax or ny ~= ay then
		main.Position = UDim2.fromOffset(nx, ny)
	end
end

-- rotation de l'écran / changement de taille : la fenêtre se réadapte toute seule
do
	local camConn = nil
	local function refit()
		fitWindow()
		applySize()
		task.defer(keepOnScreen)
	end
	local function hook()
		if camConn then
			camConn:Disconnect()
			camConn = nil
		end
		local cam = workspace.CurrentCamera
		if cam then
			camConn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(refit)
		end
	end
	hook()
	track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		hook()
		refit()
	end))
	track({
		Disconnect = function()
			if camConn then
				camConn:Disconnect()
				camConn = nil
			end
		end,
	})
end

track(minBtn.Activated:Connect(function()
	collapsed = not collapsed
	applySize()
	applyPage()
	task.defer(keepOnScreen)
end))

local function destroy()
	session.token += 1
	listening = false
	if listenConn then
		pcall(function()
			listenConn:Disconnect()
		end)
	end
	pcall(PERF.shutdown)
	pcall(setDirectHook, false)
	if r3Off then
		pcall(PERF.set3dRender, false)
	end
    for _, c in ipairs(conns) do
    if c then c:Disconnect() end  -- direct
	end
	gui:Destroy()
end
track(closeBtn.Activated:Connect(destroy))
env.BRN782K_REDEEMER = destroy

-- Drag (souris + tactile), limité à l'écran
do
	local dragging, startAbs, dragStart = false, nil, nil
	track(bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = i.Position
			startAbs = main.AbsolutePosition
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end))
	track(UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - dragStart
			local cam = workspace.CurrentCamera
			local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
			local nx = math.clamp(startAbs.X + d.X, 0, math.max(0, vp.X - WIDTH))
			local ny = math.clamp(startAbs.Y + d.Y, 0, math.max(0, vp.Y - HEAD_H))
			main.Position = UDim2.fromOffset(nx, ny)
		end
	end))
end

main.Position = UDim2.new(0.5, -WIDTH / 2, 0, -FULL_H)
tw(main, 0.5, { Position = UDim2.new(0.5, -WIDTH / 2, 0, TOP_Y) })

----------------------------------------------------------------------
-- DÉMARRAGE : le remote est préparé tout de suite (c'est ça qui fait gagner 2-3 s)
----------------------------------------------------------------------
-- Remote toujours frais : si la référence est perdue (téléportation, reload du Net), elle est ré-ancrée en arrière-plan
task.spawn(function()
	local hooked = false
	while gui.Parent do
		task.wait(2)
		if cfg.mode ~= "Click" and not (remote and remote.Parent) and cache.found then
			pcall(rebindRemote)
			if not hooked then
				local net = getNet()
				if net then
					hooked = true
					track(net.DescendantAdded:Connect(function(d)
						if not (remote and remote.Parent) and d:IsA("RemoteFunction") and cache.found and d:GetFullName() == cache.found then
							remote = d
						end
					end))
				end
			end
		end
		if refreshRemoteBadge then
			refreshRemoteBadge()
		end
	end
end)

task.spawn(function()
	loadCache()

	local ok, top = pcall(function()
		return playerGui:FindFirstChild("TopNotification")
	end)
	topNotification = ok and top or nil

	if resolveRemote() then
		setStatus("Remote prêt (cache). Appuie sur START", C.ok)
		return
	end

	if not playerGui:WaitForChild("Codes", 20) then
		setStatus("GUI Codes introuvable", C.bad)
		return
	end

	for i = 1, 3 do
		setStatus(string.format("Capture du remote %d/3...", i), C.warn)
		local r, err = capture()
		if r then
			setStatus("Remote prêt : " .. r.Name .. ". Appuie sur START", C.ok)
			return
		end
		if tostring(err):find("non support", 1, true) then
			cfg.mode = "Click"
			refreshMode()
			setStatus("Capture non supportée : mode Click", C.warn)
			return
		end
		task.wait(0.001)
	end
	setStatus("Remote non capturé : Click en secours", C.warn)
end)
