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


-- ===== MEGA FPS BOOST =====
local function applyMegaBoost()
    if typeof(setfflags) == "function" then
        local flags = {
            {"DFFlagDebugPerfMode", "True"},
            {"DFFlagDisableDPIScale", "True"},
            {"DFIntClientMaxSimulationMs", "0"},
            {"DFIntRaknetBandwidthInfluxHundredthsPercentageV2", "10000"},
            {"DFIntRakNetClockDriftAdjustmentPerPingMillisecond", "200"},
            {"DFFlagCoreScriptTelemetry2", "False"},
            {"DFFlagOptimizePartsInPart", "True"},
            {"DFFlagEnableSoundPreloading", "True"},
            {"FIntRenderThreadSchedulingBudgetCapping", "0"},
            {"DFIntTaskSchedulerTargetFps", "144"},
            {"FFlagBatchRender2", "True"},
            {"FFlagFastGpuTextureCache", "True"},
            {"DFFlagFixLargeSlipVectorVisualization", "True"},
            {"DFIntMaxRenderDistance", "1000"},
            {"FFlagNewMetaLayers", "True"},
        }
        for _, v in ipairs(flags) do
            pcall(setfflags, v[1], v[2])
        end
    end
    
    if typeof(getfflag) == "function" then
        pcall(function()
            local s = game:GetService("StarterPlayer")
            if s then s.StarterCharacterScripts:ClearAllChildren() end
        end)
    end
end

task.spawn(applyMegaBoost)
-- ===== END BOOST =====

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

local TEST_CODE = "BESTBRAINROTEVER"
local CACHE_FILE = "BRN782K_RemoteCache.json"

----------------------------------------------------------------------
-- RÉGLAGES (modifiables ici ou depuis le GUI)
----------------------------------------------------------------------
local cfg = {
	mode = "Remote", -- "Remote" ou "Click"
	parts = 3, -- nb de parties avant le 1er redeem (2, 3 ou 4)
	burst = 20, -- requêtes envoyées en parallèle
	interval = 0.0001, -- délai entre deux vagues d'envoi
	slowInterval = 0.0001, -- délai après une réponse "invalid code"
	maxSeconds = 60, -- arrêt du renvoi après X secondes
	staleSeconds = 20, -- parties plus vieilles que ça = on repart de zéro
	webhook = "https://discord.com/api/webhooks/1551308750152015953/3UOPgRXpAmC54iLHwOP396adHzgqPrBbMiRw77J82LYfzvNwt5kUKn7QwiNRiGLQhuyF", -- COLLE ICI TON WEBHOOK DISCORD (https://discord.com/api/webhooks/...)
}

-- tu peux aussi le mettre avant de lancer le script : getgenv().BRN782K_WEBHOOK = "https://discord.com/api/webhooks/..."
if type(env.BRN782K_WEBHOOK) == "string" and env.BRN782K_WEBHOOK ~= "" then
	cfg.webhook = env.BRN782K_WEBHOOK
end

local C = {
	bg = Color3.fromRGB(22, 22, 28),
	bar = Color3.fromRGB(34, 34, 44),
	btn = Color3.fromRGB(46, 46, 60),
	text = Color3.fromRGB(240, 240, 245),
	dim = Color3.fromRGB(150, 150, 165),
	ok = Color3.fromRGB(90, 210, 130),
	okDark = Color3.fromRGB(40, 110, 70),
	bad = Color3.fromRGB(230, 90, 90),
	badDark = Color3.fromRGB(130, 50, 50),
	warn = Color3.fromRGB(240, 190, 80),
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

local setStatus, refreshStart, startListening, stopListening, startSpam

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
local function getCodesUI()
	local codes = playerGui:FindFirstChild("Codes")
	codes = codes and codes:FindFirstChild("Codes")
	if not codes then
		return nil, nil
	end
	local box = codes:FindFirstChild("CodeRedeem")
	box = box and box:FindFirstChild("TextBox")
	return box, codes:FindFirstChild("Confirm")
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
local function redeemOnce(code)
	-- Nettoyage strict de la chaîne assemblée
	code = tostring(code or ""):gsub("%s+", "")

	if cfg.mode == "Remote" then
		-- On cherche le remote actif ou on tente de le ré-ancrer
		local r = remote
		if not (r and r.Parent) then
			r = resolveRemote()
		end

		-- Si la référence est perdue, on essaie de la retrouver via le cache complet
		if not (r and r.Parent) and cache.found then
			local net = getNet()
			if net then
				for _, d in ipairs(net:GetDescendants()) do
					if d:IsA("RemoteFunction") and d:GetFullName() == cache.found then
						remote = d
						r = d
						break
					end
				end
			end
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
	local url = tostring(cfg.webhook or "")
	return url:match("^https://discord%.com/api/webhooks/%d+/")
		or url:match("^https://discordapp%.com/api/webhooks/%d+/")
		or url:match("^https://ptb%.discord%.com/api/webhooks/%d+/")
		or url:match("^https://canary%.discord%.com/api/webhooks/%d+/")
end

local WEBHOOK_STYLE = {
	success = { title = "✅ Code redeem !", color = 5763719 },
	soldout = { title = "❌ Sold out", color = 15548997 },
	already = { title = "⚠️ Code déjà utilisé", color = 16705372 },
	test = { title = "🔔 Test webhook", color = 5793266 },
}

local function sendWebhook(kind, code, msg, ms)
	local st = WEBHOOK_STYLE[kind]
	if not st or not httpRequest or not webhookReady() then
		return false
	end
	local url = cfg.webhook
	task.spawn(function()
		local fields = {
			{ name = "Code", value = "`" .. tostring(code) .. "`", inline = true },
			{ name = "Temps", value = tostring(ms or 0) .. " ms", inline = true },
			{ name = "Joueur", value = tostring(lp.Name), inline = true },
		}
		if type(msg) == "string" and msg ~= "" then
			fields[#fields + 1] = { name = "Réponse", value = msg:sub(1, 200) }
		end
		local ok, body = pcall(HttpService.JSONEncode, HttpService, {
			username = "Redeemer by brn782k",
			embeds = { {
				title = st.title,
				color = st.color,
				fields = fields,
				footer = { text = "by brn782k" },
				timestamp = DateTime.now():ToIsoDate(),
			} },
		})
		if not ok then
			return
		end
		pcall(httpRequest, {
			Url = url,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = body,
		})
	end)
	return true
end

local function onSuccess(code, msg, ms)
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


-- Envoie le code : les requêtes partent TOUTES dans la même frame (burst parallèle),
-- le statut GUI est mis à jour APRÈS l'envoi (pas avant) pour ne pas retarder le submit.
-- 1er succès = on s'arrête. Erreur réseau / "please wait" = le code est remis automatiquement.
-- Sold out / déjà redeem / refus = terminal (comme avant) + webhook Discord.
-- (burst plafonné à 5 : au-delà le serveur répond "please wait" et ça ne va pas plus vite)

startSpam = function(code)
	session.token += 1
	local token = session.token
	lastAttemptAt = tick()
	local t0 = os.clock()
	local done, pending, sent = false, 0, 0
	local soft = nil -- issue "douce" : décidée quand toutes les réponses en vol sont revenues

	local maxBurst = math.max(1, math.min(cfg.burst, 5))
	if cfg.mode ~= "Remote" or not (remote and remote.Parent) then
		maxBurst = 1 -- Click : un seul clic
	end

	local attempt

	local function finalizeSoft()
		done = true
		local r = soft
		stopListening()
		if r.kind == "soldout" then
			setStatus(string.format("Épuisé (%dms) : Sold Out !", r.ms or 0), C.bad)
			sendWebhook("soldout", code, r.msg, r.ms)
		elseif r.kind == "already" then
			session.parts = {}
			setStatus("Déjà redeem : " .. code, C.dim)
			sendWebhook("already", code, r.msg, r.ms)
		else
			setStatus(string.format("Refusé (%dms) : %s", r.ms or 0, tostring(r.msg):sub(1, 35)), C.bad)
		end
		refreshStart()
	end

	local function onReply(res, msg, ms)
		if done or token ~= session.token then
			return
		end
		local reply = tostring(msg or ""):lower()

		-- 1. SUCCÈS : le Brainrot a spawned (prioritaire, immédiat)
		if res == "success" or reply:find("spawned") then
			done = true
			stopListening()
			onSuccess(code, msg, ms)
			sendWebhook("success", code, msg, ms)
			return
		end

		-- Mode Click : clic envoyé, pas de réponse du serveur à lire
		if res == "click" then
			done = true
			stopListening()
			setStatus("Click envoyé : " .. code, C.ok)
			refreshStart()
			return
		end

		local retry = false
		if reply:find("sold out") then
			soft = { kind = "soldout", msg = msg, ms = ms } -- 2. SOLD OUT
		elseif lowerHas(reply, "already") and lowerHas(reply, "redeem") then
			soft = { kind = "already", msg = msg, ms = ms } -- 3. DÉJÀ REDEEM
		elseif res == "error" or lowerHas(reply, "please wait", "rate limit", "ratelimit", "too many request", "try again", "cooldown", "too fast") then
			retry = true -- erreur transitoire : on remet le code
		else
			soft = soft or { kind = "refused", msg = msg, ms = ms } -- autre refus
		end

		if pending > 0 then
			return -- d'autres réponses arrivent : un succès peut encore passer devant
		end
		if soft then
			return finalizeSoft()
		end

		if retry and os.clock() - t0 < math.min(cfg.maxSeconds, 15) and sent < 40 then
			task.wait(math.max(cfg.interval, 0.03))
			if not done and token == session.token then
				attempt()
			end
			return
		end

		done = true
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
	setStatus("Envoi : " .. code, C.warn)
end

----------------------------------------------------------------------
-- DÉTECTION DU CODE (notifications)
----------------------------------------------------------------------
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
	if recent and lowerHas(low, "invalid code", "does not exist", "please wait", "rate limit", "ratelimit", "too many request", "try again", "cooldown", "too fast") then
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
		startSpam(table.concat(session.parts))
	else
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

	if not isValidCode(text) then
		return
	end

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

	task.delay(0.001, function()
		if not done then
			check()
			finish()
		end
	end)
end

startListening = function()
	if listening then
		return true
	end
	if not topNotification or topNotification:IsA("ScreenGui") then
		local top = playerGui:FindFirstChild("TopNotification")
		topNotification = top and top:FindFirstChild("TopNotification")
	end
	if not topNotification then
		setStatus("TopNotification introuvable", C.bad)
		return false
	end
	listening = true
	session.parts = {}
	session.lastPart = 0
	listenConn = topNotification.ChildAdded:Connect(watch)
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
end

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
local RunService = game:GetService("RunService")
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

----------------------------------------------------------------------
-- GUI
----------------------------------------------------------------------
local TweenService = game:GetService("TweenService")

local T = {
	bg = Color3.fromRGB(14, 14, 20),
	panel = Color3.fromRGB(23, 23, 32),
	panel2 = Color3.fromRGB(33, 33, 46),
	stroke = Color3.fromRGB(50, 50, 70),
	accent = Color3.fromRGB(139, 92, 246),
	accentHi = Color3.fromRGB(167, 126, 250),
	accent2 = Color3.fromRGB(56, 189, 248),
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

local function hover(b, base, over)
	track(b.MouseEnter:Connect(function()
		
	end))
	track(b.MouseLeave:Connect(function()
		
	end))
end

local gui = mk("ScreenGui", {
	Name = "BRN782K_Redeemer",
	ResetOnSpawn = false,
	DisplayOrder = 999,
	IgnoreGuiInset = true,
}, (typeof(gethui) == "function" and gethui()) or playerGui)

local WIDTH, HEAD_H, BODY_H = 280, 38, 280
local FULL_H = HEAD_H + BODY_H

local main = mk("Frame", {
	Size = UDim2.fromOffset(WIDTH, FULL_H),
	Position = UDim2.new(0.5, -WIDTH / 2, 0, 16),
	BackgroundColor3 = T.bg,
	BorderSizePixel = 0,
	ClipsDescendants = true,
}, gui)
corner(main, 12)
gradient(stroke(main, C.text, 1.5), T.accent, T.accent2, 45)


-- En-tête
local bar = mk("Frame", { Size = UDim2.new(1, 0, 0, HEAD_H), BackgroundColor3 = T.panel, BorderSizePixel = 0 }, main)
local title = mk("TextLabel", {
	Position = UDim2.fromOffset(14, 5),
	Size = UDim2.fromOffset(150, 18),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBlack,
	TextSize = 15,
	TextColor3 = C.text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "REDEEMER",
}, bar)
gradient(title, T.accent, T.accent2, 0)
mk("TextLabel", {
	Position = UDim2.fromOffset(14, 22),
	Size = UDim2.fromOffset(150, 12),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextColor3 = C.dim,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "by brn782k",
}, bar)
local line = mk("Frame", { Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.text, BorderSizePixel = 0 }, bar)
gradient(line, T.accent, T.accent2, 0)

local minBtn = btn(bar, "-", 226, 8, 22, 22)
local closeBtn = btn(bar, "x", 252, 8, 22, 22)
local whBtn = btn(bar, "W", 200, 8, 22, 22) -- test du webhook Discord
hover(minBtn, T.panel2, T.stroke)
hover(closeBtn, T.panel2, C.badDark)

local body = mk("Frame", { Position = UDim2.fromOffset(0, HEAD_H), Size = UDim2.new(1, 0, 0, BODY_H), BackgroundTransparency = 1 }, main)

-- Statut
local statusCard = mk("Frame", { Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(264, 40), BackgroundColor3 = T.panel, BorderSizePixel = 0 }, body)
corner(statusCard, 8)
stroke(statusCard, T.stroke, 1)
local dot = mk("Frame", { Position = UDim2.fromOffset(11, 16), Size = UDim2.fromOffset(8, 8), BackgroundColor3 = C.dim, BorderSizePixel = 0 }, statusCard)
corner(dot, 4)
local statusLabel = mk("TextLabel", {
	Position = UDim2.fromOffset(26, 3),
	Size = UDim2.fromOffset(232, 34),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	TextSize = 11,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Center,
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

-- START / STOP
local startBtn = btn(body, "START", 8, 56, 264, 34, T.accent)
startBtn.TextSize = 13
gradient(startBtn, Color3.fromRGB(255, 255, 255), Color3.fromRGB(190, 190, 205), 90)

refreshStart = function()
	startBtn.Text = listening and "STOP" or "START"
	startBtn.BackgroundColor3 = listening and C.bad or T.accent
end
refreshStart()

-- Mode (Remote / Click)
local modeCard = mk("Frame", { Position = UDim2.fromOffset(8, 98), Size = UDim2.fromOffset(264, 28), BackgroundColor3 = T.panel, BorderSizePixel = 0 }, body)
corner(modeCard, 8)
stroke(modeCard, T.stroke, 1)
local modeBtns = {
	Remote = btn(modeCard, "Remote", 2, 2, 129, 24, T.panel),
	Click = btn(modeCard, "Click", 133, 2, 129, 24, T.panel),
}
local function refreshMode()
	for name, b in pairs(modeBtns) do
		local on = cfg.mode == name
		b.BackgroundColor3 = on and T.accent or T.panel
	end
end
for name, b in pairs(modeBtns) do
	track(b.Activated:Connect(function()
		cfg.mode = name
		refreshMode()
	end))
end
refreshMode()

-- Réglages numériques
local function stepper(label, x, y, key, lo, hi)
	local card = mk("Frame", { Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(130, 28), BackgroundColor3 = T.panel, BorderSizePixel = 0 }, body)
	corner(card, 8)
	stroke(card, T.stroke, 1)
	local minus = btn(card, "-", 2, 2, 24, 24)
	local val = mk("TextLabel", {
		Position = UDim2.fromOffset(26, 0),
		Size = UDim2.fromOffset(78, 28),
		BackgroundTransparency = 1,
		RichText = true,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = C.text,
		Text = "",
	}, card)
	local plus = btn(card, "+", 104, 2, 24, 24)
	hover(minus, T.panel2, T.stroke)
	hover(plus, T.panel2, T.stroke)
	local function render()
		val.Text = string.format('<font color="rgb(150,150,165)">%s</font>  %d', label, cfg[key])
	end
	render()
	track(minus.Activated:Connect(function()
		cfg[key] = math.max(lo, cfg[key] - 1)
		render()
	end))
	track(plus.Activated:Connect(function()
		cfg[key] = math.min(hi, cfg[key] + 1)
		render()
	end))
end
stepper("Parts", 8, 134, "parts", 1, 6)
stepper("Burst", 142, 134, "burst", 1, 6)

-- Interrupteurs FPS / PING
local function toggle(label, x, y)
	local b = mk("TextButton", {
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(130, 28),
		BackgroundColor3 = T.panel,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
	}, body)
	corner(b, 8)
	stroke(b, T.stroke, 1)
	mk("TextLabel", {
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.fromOffset(70, 28),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = label,
	}, b)
	local rail = mk("Frame", { Position = UDim2.fromOffset(92, 7), Size = UDim2.fromOffset(28, 14), BackgroundColor3 = T.stroke, BorderSizePixel = 0 }, b)
	corner(rail, 7)
	local knob = mk("Frame", { Position = UDim2.fromOffset(2, 2), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = C.text, BorderSizePixel = 0 }, rail)
	corner(knob, 5)
	local function set(on)
		rail.BackgroundColor3 = on and T.accent or T.stroke
		knob.Position = on and UDim2.fromOffset(16, 2) or UDim2.fromOffset(2, 2)
	end
	return b, set
end
local fpsBtn, setFpsUI = toggle("FPS Boost", 8, 170)
local pingBtn, setPingUI = toggle("Ping Boost", 142, 170)
local lagBtn, setLagUI = toggle("Anti-Lag", 8, 206)
local r3Btn, setR3UI = toggle("3D OFF", 142, 206)

-- Code manuel
local codeBox = mk("TextBox", {
	Position = UDim2.fromOffset(8, 242),
	Size = UDim2.fromOffset(196, 30),
	BackgroundColor3 = T.panel,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	PlaceholderText = "Code manuel",
	PlaceholderColor3 = C.dim,
	Text = "",
	Font = Enum.Font.GothamMedium,
	TextSize = 12,
	TextColor3 = C.text,
	TextXAlignment = Enum.TextXAlignment.Left,
}, body)
corner(codeBox, 8)
mk("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, codeBox)
local codeStroke = stroke(codeBox, T.stroke, 1)
track(codeBox.Focused:Connect(function()
	
end))
track(codeBox.FocusLost:Connect(function()
	
end))
local goBtn = btn(body, "GO", 212, 242, 60, 30, T.accent)
hover(goBtn, T.accent, T.accentHi)

-- Actions
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
	startSpam(code)
end))

track(fpsBtn.Activated:Connect(function()
	local on = not fps.on
	local flagsOk = setFpsBoost(on)
	setFpsUI(on)
	if on and not flagsOk then
		setStatus("FPS boost actif (FFlags non supportés)", C.warn)
	end
end))

local pingOn = false
track(pingBtn.Activated:Connect(function()
	pingOn = not pingOn
	local flagsOk = applyFlags(pingFlags, pingOn)
	setPingUI(pingOn)
	if pingOn and not flagsOk then
		pingOn = false
		setPingUI(false)
		setStatus("Ping boost non supporté (setfflag)", C.bad)
	end
end))

local lagOn = false
track(lagBtn.Activated:Connect(function()
	lagOn = not lagOn
	local flagsOk = setExtremeAntiLag(lagOn)
	setLagUI(lagOn)
	if lagOn then
		setStatus(flagsOk and "Anti-Lag extrême actif" or "Anti-Lag actif (FFlags non supportés)", flagsOk and C.ok or C.warn)
	else
		setStatus("Anti-Lag désactivé", C.dim)
	end
end))

local r3Off = false
track(r3Btn.Activated:Connect(function()
	local want = not r3Off
	if set3dRender(want) then
		r3Off = want
		setR3UI(want)
		setStatus(want and "Rendu 3D coupé (écran noir)" or "Rendu 3D rétabli", want and C.warn or C.ok)
	else
		setStatus("3D OFF non supporté par l'executor", C.bad)
	end
end))

track(whBtn.Activated:Connect(function()
	if not webhookReady() then
		setStatus("Webhook vide ou invalide (cfg.webhook)", C.bad)
	elseif not httpRequest then
		setStatus("Executor sans fonction request", C.bad)
	else
		sendWebhook("test", "TEST", "Webhook OK", 0)
		setStatus("Test webhook envoyé", C.ok)
	end
end))

local collapsed = false
track(minBtn.Activated:Connect(function()
	collapsed = not collapsed
	if collapsed then
		body.Visible = false
		main.Size = UDim2.fromOffset(WIDTH, HEAD_H)
	else
		body.Visible = true
		main.Size = UDim2.fromOffset(WIDTH, FULL_H)
	end
end))

local function destroy()
	session.token += 1
	listening = false
	if listenConn then
		pcall(function()
			listenConn:Disconnect()
		end)
	end
	if fps.conn then
		pcall(function()
			fps.conn:Disconnect()
		end)
	end
	if lag.on then
		pcall(setExtremeAntiLag, false)
	end
	if r3Off then
		pcall(set3dRender, false)
	end
	for _, c in ipairs(conns) do
		pcall(function()
			c:Disconnect()
		end)
	end
	gui:Destroy()
end
track(closeBtn.Activated:Connect(destroy))
env.BRN782K_REDEEMER = destroy

-- Drag (souris + tactile)
do
	local dragging, startPos, dragStart = false, nil, nil
	track(bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = i.Position
			startPos = main.Position
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
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end))
end

----------------------------------------------------------------------
-- DÉMARRAGE : le remote est préparé tout de suite (c'est ça qui fait gagner 2-3 s)
----------------------------------------------------------------------
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
