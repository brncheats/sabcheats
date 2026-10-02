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
	burst = 6, -- requêtes envoyées en parallèle
	interval = 0.04, -- délai entre deux vagues d'envoi
	slowInterval = 0.04, -- délai après une réponse "invalid code"
	maxSeconds = 10, -- arrêt du renvoi après X secondes
	staleSeconds = 20, -- parties plus vieilles que ça = on repart de zéro
}

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
			task.wait(0.05)
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
		task.wait()
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
		local r = remote
		if not (r and r.Parent) then
			r = resolveRemote()
		end

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
			
			-- On envoie 2 requêtes en parallèle propre pour maximiser la vitesse sans flood excessif
			local lastOk, lastA, lastB, lastMs
			for i = 1, 2 do
				task.spawn(function()
					local ok, a, b = pcall(r.InvokeServer, r, code)
					local ms = math.floor((os.clock() - t) * 1000 + 0.5)
					lastOk, lastA, lastB, lastMs = ok, a, b, ms
				end)
			end
			
			-- Petite pause imperceptible pour laisser le temps aux threads de s'exécuter
			task.wait(0.01)
			
			if lastOk == false then
				return "error", tostring(lastA), lastMs or 0
			end
			if lastA == true or (lastA and tostring(lastA):lower():find("success")) then
				return "success", lastB or lastA, lastMs or 0
			end
			return "fail", tostring(lastB or lastA or "Rejeté"), lastMs or 0
		end
	end

	-- Secours en Mode Click
	if clickRedeem(code) then
		return "click", nil, 0
	end
	return "error", "Remote et Click indisponibles", 0
end

-- Envoie le code en boucle (burst parallèle) jusqu'à succès, nouvelle partie ou timeout.
-- En cas d'erreur, le code est automatiquement renvoyé.

startSpam = function(code)
	session.token += 1
	local token = session.token
	lastAttemptAt = tick()
	setStatus("Envoi : " .. code, C.warn)

	task.spawn(function()
		local res, msg, ms = redeemOnce(code)

		if token ~= session.token then
			return
		end

		local reply = tostring(msg or ""):lower()

		-- 1. SUCCÈS : Le Brainrot a spawned
		if res == "success" or reply:find("spawned") then
			stopListening()
			onSuccess(code, msg, ms)
			return
		end

		-- 2. SOLD OUT : Stock épuisé
		if reply:find("sold out") then
			stopListening()
			setStatus(string.format("Épuisé (%dms) : Sold Out !", ms or 0), C.bad)
			refreshStart()
			return
		end

		-- 3. DÉJÀ REDEEM
		if lowerHas(reply, "already") and lowerHas(reply, "redeem") then
			stopListening()
			session.parts = {}
			setStatus("Déjà redeem : " .. code, C.dim)
			refreshStart()
			return
		end

		-- Tout autre échec : stoppe proprement sans spammer
		stopListening()
		setStatus(string.format("Refusé (%dms) : %s", ms or 0, tostring(msg):sub(1, 35)), C.bad)
		refreshStart()
	end)
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

	task.delay(0.25, function()
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
	if not topNotification then
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

local flagOriginal = {}

local function applyFlags(list, on)
	if typeof(setfflag) ~= "function" then
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
			if pcall(setfflag, name, value) then
				count += 1
			end
		else
			local o = flagOriginal[name]
			if o ~= nil and pcall(setfflag, name, o) then
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
					task.wait()
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
		tw(b, 0.12, { BackgroundColor3 = over })
	end))
	track(b.MouseLeave:Connect(function()
		tw(b, 0.12, { BackgroundColor3 = base })
	end))
end

local gui = mk("ScreenGui", {
	Name = "BRN782K_Redeemer",
	ResetOnSpawn = false,
	DisplayOrder = 999,
	IgnoreGuiInset = true,
}, (typeof(gethui) == "function" and gethui()) or playerGui)

local WIDTH, HEAD_H, BODY_H = 280, 38, 244
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
tw(main, 0.4, { Position = UDim2.new(0.5, -WIDTH / 2, 0, 36) })

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
	tw(dot, 0.15, { BackgroundColor3 = col })
end
setStatus = function(text, color)
	uiText, uiColor = text, color
	if os.clock() - uiLast >= 0.12 then
		applyStatus()
	elseif not uiQueued then
		uiQueued = true
		task.delay(0.12, applyStatus)
	end
end

-- START / STOP
local startBtn = btn(body, "START", 8, 56, 264, 34, T.accent)
startBtn.TextSize = 13
gradient(startBtn, Color3.fromRGB(255, 255, 255), Color3.fromRGB(190, 190, 205), 90)

refreshStart = function()
	startBtn.Text = listening and "STOP" or "START"
	tw(startBtn, 0.2, { BackgroundColor3 = listening and C.bad or T.accent })
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
		tw(b, 0.15, { BackgroundColor3 = on and T.accent or T.panel, TextColor3 = on and C.text or C.dim })
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
		tw(rail, 0.15, { BackgroundColor3 = on and C.ok or T.stroke })
		tw(knob, 0.15, { Position = UDim2.fromOffset(on and 16 or 2, 2) })
	end
	return b, set
end
local fpsBtn, setFpsUI = toggle("FPS Boost", 8, 170)
local pingBtn, setPingUI = toggle("Ping Boost", 142, 170)

-- Code manuel
local codeBox = mk("TextBox", {
	Position = UDim2.fromOffset(8, 206),
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
	tw(codeStroke, 0.15, { Color = T.accent })
end))
track(codeBox.FocusLost:Connect(function()
	tw(codeStroke, 0.15, { Color = T.stroke })
end))
local goBtn = btn(body, "GO", 212, 206, 60, 30, T.accent)
hover(goBtn, T.accent, T.accentHi)

-- Actions
track(startBtn.Activated:Connect(function()
	if listening then
		stopListening()
		setStatus("Arrêté", C.dim)
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

local collapsed = false
track(minBtn.Activated:Connect(function()
	collapsed = not collapsed
	if collapsed then
		body.Visible = false
		tw(main, 0.2, { Size = UDim2.fromOffset(WIDTH, HEAD_H) })
	else
		body.Visible = true
		tw(main, 0.2, { Size = UDim2.fromOffset(WIDTH, FULL_H) })
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
		return playerGui:WaitForChild("TopNotification", 20):WaitForChild("TopNotification", 20)
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
		task.wait(1.5)
	end
	setStatus("Remote non capturé : Click en secours", C.warn)
end)
