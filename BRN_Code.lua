--[[
	VOIDSNIPE v1.0
	Mode Click uniquement - Accumulation infinie sur invalid
	Design Glassmorphism + Neon
]]

local env = (typeof(getgenv) == "function" and getgenv()) or _G
if type(env.VOIDSNIPE_DESTROY) == "function" then
	pcall(env.VOIDSNIPE_DESTROY)
end

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Players        = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService    = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Lighting       = game:GetService("Lighting")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local StarterGui     = game:GetService("StarterGui")
local MaterialService = game:GetService("MaterialService")

local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- Kill old GUI
do
	local function killOld(parent)
		pcall(function()
			local old = parent:FindFirstChild("VOIDSNIPE_GUI")
			if old then old:Destroy() end
			local old2 = parent:FindFirstChild("BRN782K_Redeemer")
			if old2 then old2:Destroy() end
		end)
	end
	killOld(playerGui)
	killOld(game:GetService("CoreGui"))
	if typeof(gethui) == "function" then
		pcall(function() killOld(gethui()) end)
	end
end

----------------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------------
local cfg = {
	parts        = 1,
	autoRedeem   = true,
	submitDelayMin = 0.001, -- secondes, borne basse du délai aléatoire avant le click
	submitDelayMax = 0.002, -- secondes, borne haute du délai aléatoire avant le click
	growOnInvalid = true,
	fastListen   = true,
	directHook   = false,
	webhook      = "",
	staleSeconds = 60,
}

local persist = {
	fps = false, ping = false, lag = false,
	fx = {}, code = "",
	jumpsOn = false, speedOn = false, speedVal = 140,
	autoStart = false,
}

----------------------------------------------------------------------
-- SETTINGS SAVE/LOAD
----------------------------------------------------------------------
local saveSettings
do
	local FILE = "BRN782K_Settings.json"
	local queued = false

	local function clampNum(v, lo, hi)
		return type(v) == "number" and math.clamp(math.floor(v), lo, hi) or nil
	end

	local function load()
		if typeof(isfile) ~= "function" or typeof(readfile) ~= "function" then return end
		local ok, exists = pcall(isfile, FILE)
		if not ok or not exists then return end
		local ok2, raw = pcall(readfile, FILE)
		if not ok2 or type(raw) ~= "string" then return end
		local ok3, data = pcall(HttpService.JSONDecode, HttpService, raw)
		if not ok3 or type(data) ~= "table" then return end
		local c = data.cfg
		if type(c) == "table" then
			cfg.parts        = clampNum(c.parts, 1, 6) or cfg.parts
			cfg.autoRedeem   = type(c.autoRedeem) == "boolean" and c.autoRedeem or cfg.autoRedeem
			if type(c.webhook) == "string" and c.webhook ~= "" then cfg.webhook = c.webhook end
		end
		local u = data.ui
		if type(u) == "table" then
			persist.fps     = u.fps == true
			persist.ping    = u.ping == true
			persist.lag     = u.lag == true
			persist.jumpsOn = u.jumpsOn == true
			persist.speedOn = u.speedOn == true
			persist.autoStart = u.autoStart == true
			if type(u.speedVal) == "number" then persist.speedVal = math.clamp(u.speedVal, 10, 300) end
			if type(u.code) == "string" then persist.code = u.code end
			if type(u.fx) == "table" then
				for k, v in pairs(u.fx) do
					if type(k) == "string" and v == true then persist.fx[k] = true end
				end
			end
		end
	end

	saveSettings = function()
		if typeof(writefile) ~= "function" or queued then return end
		queued = true
		task.delay(0.4, function()
			queued = false
			local ok, json = pcall(HttpService.JSONEncode, HttpService, {
				cfg = {
					parts        = cfg.parts,
					autoRedeem   = cfg.autoRedeem,
					webhook      = cfg.webhook,
				},
				ui = {
					fps = persist.fps, ping = persist.ping, lag = persist.lag,
					fx = persist.fx, code = persist.code,
					jumpsOn = persist.jumpsOn, speedOn = persist.speedOn, speedVal = persist.speedVal,
					autoStart = persist.autoStart,
				},
			})
			if ok then pcall(writefile, FILE, json) end
		end)
	end

	load()
end

----------------------------------------------------------------------
-- COULEURS NEON GLASS
----------------------------------------------------------------------
local N = {
	bg       = Color3.fromRGB(10, 10, 12),
	glass    = Color3.fromRGB(20, 19, 22),
	glass2   = Color3.fromRGB(28, 26, 28),
	cyan     = Color3.fromRGB(230, 180, 60),   -- accent or (remplace l'ancien cyan)
	cyanDim  = Color3.fromRGB(150, 115, 35),
	rose     = Color3.fromRGB(230, 70, 70),
	roseDim  = Color3.fromRGB(140, 35, 35),
	orange   = Color3.fromRGB(235, 165, 60),
	text     = Color3.fromRGB(225, 222, 215),
	dim      = Color3.fromRGB(120, 116, 110),
	border   = Color3.fromRGB(55, 50, 45),
	borderC  = Color3.fromRGB(180, 140, 50),
	good     = Color3.fromRGB(70, 200, 110),  -- vert pour les switches ON
}

----------------------------------------------------------------------
-- HELPERS GUI
----------------------------------------------------------------------
local conns = {}
local function track(c) conns[#conns+1] = c; return c end

local function mk(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end

local function corner(o, r)
	return mk("UICorner", {CornerRadius = UDim.new(0, r)}, o)
end

local function uistroke(o, color, thick)
	return mk("UIStroke", {Color = color, Thickness = thick or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, o)
end

local function tw(o, t, props)
	TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

local function trim(s)
	return (tostring(s or ""):gsub("^%s+",""):gsub("%s+$",""))
end

local function clean(s)
	return trim((tostring(s or ""):gsub("<.->","")))
end

----------------------------------------------------------------------
-- FLAGS FPS / PING (identiques à l'original)
----------------------------------------------------------------------
local pingFlags = {
	{"DFFlagSampleAndRefreshRakPing","True"},
	{"DFFlagRakNetUseSlidingWindow4","True"},
	{"DFIntMaxReceiveToDeserializeLatencyMilliseconds","15"},
	{"DFIntNetworkInDeserializeLimitGameplayMsClient","6"},
	{"DFIntNetworkInProcessLimitGameplayMsClient","6"},
	{"DFIntMaxWaitTimeBeforeForcePacketProcessMS","1"},
	{"DFIntClientPacketMaxDelayMs","11"},
	{"DFIntClientPacketMaxFrameMicroseconds","200"},
	{"DFIntClientPacketMinMicroseconds","1"},
	{"DFIntRakNetNakResendDelayMs","10"},
	{"DFIntRakNetNakResendDelayMsMax","100"},
	{"DFIntRakNetResendRttMultiple","1"},
	{"DFIntRakNetLoopMs","1"},
	{"DFIntRakNetSelectTimeoutMs","1"},
	{"DFIntMaxProcessPacketsStepsPerCyclic","5000"},
	{"DFIntMaxProcessPacketsJobScaling","10000"},
	{"DFIntMegaReplicatorNetworkQualityProcessorUnit","10"},
	{"DFFlagCoreScriptTelemetry2","False"},
	{"FFlagEnableTelemetryService1","False"},
	{"FFlagOpenTelemetryEnabled2","False"},
	{"FFlagPerfDataOnTelemetryV2","False"},
	{"FIntTelemetryProfilerFrequency","0"},
	{"DFIntTelemetryProfilerHundredthsPercentage","0"},
	{"FIntPerformanceTelemetryQueueProcessLimit","0"},
	{"DFIntRaknetBandwidthInfluxHundredthsPercentageV2","10000"},
	{"DFIntRakNetClockDriftAdjustmentPerPingMillisecond","100"},
	{"DFIntRakNetNakResendDelayRttPercent","50"},
	{"DFIntRakNetMinAckGrowthPercent","0"},
	{"DFIntRaknetBandwidthPingSendEveryXSeconds","1"},
	{"DFIntRakNetMtuValue1InBytes","1280"},
	{"DFIntRakNetMtuValue2InBytes","1240"},
	{"DFIntRakNetMtuValue3InBytes","1200"},
	{"DFIntConnectionMTUSize","1260"},
	{"FIntRakNetResendBufferArrayLength","128"},
	{"DFIntOptimizePingThreshold","50"},
	{"DFIntWaitOnRecvFromLoopEndedMS","100"},
	{"DFIntWaitOnUpdateNetworkLoopEndedMS","100"},
	{"DFIntLargePacketQueueSizeCutoffMB","1000"},
	{"DFIntClientPacketHealthyAllocationPercent","20"},
	{"DFIntClientPacketExcessMicroseconds","1000"},
	{"DFIntMaxProcessPacketsStepsAccumulated","0"},
	{"DFIntMaxFrameBufferSize","4"},
	{"DFIntCodecMaxIncomingPackets","100"},
	{"DFIntCodecMaxOutgoingFrames","10000"},
	{"DFIntSignalRCoreRpcQueueSize","256"},
	{"DFIntSignalRCoreServerTimeoutMs","11100"},
	{"DFIntSignalRCoreKeepAlivePingPeriodMs","250"},
	{"DFIntSignalRCoreTimerMs","750"},
	{"DFIntSignalRHubConnectionBaseRetryTimeMs","100"},
	{"DFIntSignalRHubConnectionHeartbeatTimerRateMs","1000"},
	{"FFlagSpecifyNetworkReplicatorScope","True"},
	{"FFlagSpecifyNetworkReplicatorScopeForItems","True"},
	{"FFlagDebugDisableTelemetryEphemeralCounter","True"},
	{"FFlagDebugDisableTelemetryEphemeralStat","True"},
	{"FFlagDebugDisableTelemetryEventIngest","True"},
	{"FFlagDebugDisableTelemetryPoint","True"},
	{"FFlagDebugDisableTelemetryV2Counter","True"},
	{"FFlagDebugDisableTelemetryV2Event","True"},
	{"FFlagDebugDisableTelemetryV2Stat","True"},
	{"DFFlagBrowserTrackerIdTelemetryEnabled","False"},
	{"DFFlagVideoCaptureServiceEnabled","False"},
	{"FFlagSendRenderFidelityTelemetry2","False"},
	{"FIntReportDeviceInfoRollout","0"},
	{"FFlagLargeReplicatorEnabled6","True"},
	{"FFlagLargeReplicatorWrite5","True"},
	{"FFlagLargeReplicatorRead5","True"},
	{"DFFlagDebugDisableTimeoutDisconnect","True"},
	{"DFIntPhysicsReceiveNumParallelTasks","4"},
	{"DFIntReplicationDataCacheNumParallelTasks","4"},
	{"DFIntInterpolationNumParallelTasks","4"},
	{"DFIntS2PhysicsSenderRate","30"},
	{"DFIntDataSenderRate","60"},
	{"DFIntNetworkStopProducingPacketsToProcessThresholdMs","1"},
	{"DFIntRakNetPingFrequencyMillisecond","250"},
	{"DFIntRakNetCongestionControlMinCwnd","64"},
	{"FIntRakNetPingThrottle","0"},
	{"DFIntHttpCurlConnectionCacheSize","64"},
	{"DFIntHttpCurlConnectionCacheExpirationSecs","600"},
	{"DFIntHttpSendRetries","0"},
	{"DFIntHttpBatchLimit","16"},
	{"FFlagHttpUseNewDnsResolver","True"},
	{"DFFlagAnalyticsEnableLogs","False"},
	{"FFlagEnableLogsReporting","False"},
	{"FFlagCrashUploaderEnabled","False"},
	{"FFlagDisableUploadCrashDumps","True"},
	{"FIntCrashUploadToBacktracePercentage","0"},
	{"FFlagDisableAnalyticsReporting","True"},
	{"DFFlagDisablePlayerReportsForMobile","True"},
}

local fpsFlags = {
	{"DFFlagTextureQualityOverrideEnabled","True"},
	{"DFIntTextureQualityOverride","0"},
	{"FIntDebugTextureManagerSkipMips","7"},
	{"DFIntDebugFRMQualityLevelOverride","1"},
	{"FIntDebugForceMSAASamples","1"},
	{"FIntFRMMaxGrassDistance","0"},
	{"FIntFRMMinGrassDistance","0"},
	{"FIntRobloxGuiBlurIntensity","0"},
	{"FIntRenderLocalLightFadeInMs","0"},
	{"DFIntAnimationLodFacsDistanceMin","0"},
	{"DFIntAnimationLodFacsDistanceMax","0"},
	{"DFIntAnimationLodFacsVisibilityDenominator","0"},
	{"FFlagFastGPULightCulling3","True"},
	{"FFlagCacheTextBoundsInGuiText","True"},
	{"FFlagDisablePostFx","True"},
	{"FIntRenderShadowIntensity","0"},
	{"FIntRenderShadowmapBias","0"},
	{"FIntRenderMaxShadowAtlasUsageBeforeDownscale","80"},
	{"FIntRenderShadowMapDepthCacheMemLimit","192"},
	{"FFlagRenderAllocateShadowMapResourcesOnDemand","True"},
	{"FIntRenderLocalLightUpdatesMax","1"},
	{"FIntRenderLocalLightUpdatesMin","1"},
	{"DFFlagDebugPauseVoxelizer","True"},
	{"FFlagDebugForceFSMCPULightCulling","True"},
	{"FFlagGlobalWindRendering","False"},
	{"FFlagGlobalWindActivated","False"},
	{"FIntRenderGrassDetailStrands","0"},
	{"FIntGrassMovementReducedMotionFactor","0"},
	{"DFIntCSGLevelOfDetailSwitchingDistance","0"},
	{"DFIntCSGLevelOfDetailSwitchingDistanceL12","0"},
	{"DFIntCSGLevelOfDetailSwitchingDistanceL23","0"},
	{"DFIntCSGLevelOfDetailSwitchingDistanceL34","0"},
	{"TextureQualityOverrideEnabled","True"},
	{"TextureQualityOverride","1"},
	{"FIntUITextureMaxRenderTextureSize","1024"},
	{"FIntTerrainOTAMaxTextureSize","1024"},
	{"FIntDefaultMeshCacheSizeMB","256"},
	{"DFIntDebugRestrictGCDistance","1"},
	{"DFFlagOptimizePartsInPart","True"},
	{"DFFlagDebugPerfMode","True"},
	{"DFIntTaskSchedulerTargetFps","240"},
	{"FFlagTaskSchedulerLimitTargetFpsTo2402","False"},
	{"FFlagGameBasicSettingsFramerateCap5","False"},
	{"FFlagBaseThreadPoolUseRuntime2","True"},
	{"FIntTaskSchedulerAutoThreadLimit","6"},
	{"FIntTaskSchedulerAsyncTasksMinimumThreadCount","2"},
	{"FIntOcclusionWorkerThreadCount","5"},
	{"FFlagRenderGpuTextureCompressor","True"},
	{"DFIntRenderingEngineMaxFrameTimeMs","0"},
	{"DFFlagSkipHighResolutiontextureMipsOnLowMemoryDevices","True"},
	{"DFFlagSkipHighResolutiontextureMipsOnLowMemoryDevices2","True"},
	{"DFFlagDebugRenderForceTechnologyVoxel","True"},
	{"FFlagDebugSkyGray","True"},
	{"FFlagDebugDisableOTAMaterialTexture","True"},
	{"FFlagDebugRenderingSetDeterministic","False"},
	{"FIntRenderGrassHeightScaler","0"},
	{"FFlagSkyUseTextureCompression","True"},
	{"FFlagRenderSkipSkyLightingUpdate","True"},
	{"DFIntTextureCompositorActiveJobs","1"},
	{"FIntMeshContentProviderForceCacheSize","268435456"},
	{"FFlagDisableDynamicHeads","True"},
	{"FFlagEnableAvatarDetailReduction","True"},
	{"FFlagMaterialManagerSkipLoad","True"},
	{"FFlagUseNewPlayerListFrameLimiter","True"},
	{"FIntEmotesMenuUpdateRateMs","1000"},
	{"FIntAnimationClipCacheLifetimeSec","30"},
	{"FFlagDisableAnimationsFromOffScreen","True"},
	{"DFIntPhysicsDecompForceUpgradeVersion","0"},
	{"DFIntSimBroadPhaseCacheSize","2048"},
	{"FFlagAdaptiveStreamingOptimization","True"},
	{"DFIntGraphicsOptimizationModeMaxFrameTimeTargetMs","6"},
	{"DFIntGraphicsOptimizationModeMinFrameTimeTargetMs","4"},
	{"FIntGraphicsOptimizationModeFRMFrameRateTarget","240"},
	{"FFlagGraphicsOptimizationMode","True"},
	{"DFIntPerformanceControlFrameTimeMax","99999"},
	{"FIntFramerateTargetFloor","240"},
}

----------------------------------------------------------------------
-- PERFORMANCE FONCTIONS
----------------------------------------------------------------------
local PERF = {}
local jumps, speed, setJumps, setSpeed

do
local flagOriginal = {}
local function applyFlags(list, on)
	local setter = (typeof(setfflag) == "function" and setfflag) or (typeof(setfflags) == "function" and setfflags) or nil
	if not setter then return false end
	local count = 0
	for _, f in ipairs(list) do
		local name, value = f[1], f[2]
		if on then
			if flagOriginal[name] == nil and typeof(getfflag) == "function" then
				local ok, v = pcall(getfflag, name)
				if ok and v ~= nil then flagOriginal[name] = tostring(v) end
			end
			if pcall(setter, name, value) then count += 1 end
		else
			local o = flagOriginal[name]
			if o ~= nil and pcall(setter, name, o) then count += 1 end
		end
	end
	return count > 0
end
PERF.applyFlags = applyFlags

local function isEffect(d)
	return d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles")
end

local fps = {on=false, saved={}, conn=nil}
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
			if typeof(getfpscap) == "function" then pcall(function() fps.cap = getfpscap() end) end
			pcall(setfpscap, 240)
		end
		for _, v in ipairs(Lighting:GetChildren()) do
			if v:IsA("PostEffect") then fps.saved[v] = v.Enabled; v.Enabled = false end
		end
		fps.conn = workspace.DescendantAdded:Connect(function(d)
			if fps.on and isEffect(d) then d.Enabled = false end
		end)
		task.spawn(function()
			local n = 0
			for _, d in ipairs(workspace:GetDescendants()) do
				if not fps.on then break end
				if isEffect(d) then
					if fps.saved[d] == nil then fps.saved[d] = d.Enabled end
					d.Enabled = false
				end
				n += 1
				if n % 400 == 0 then task.wait(0.001) end
			end
		end)
	else
		if fps.conn then fps.conn:Disconnect(); fps.conn = nil end
		if fps.cap and typeof(setfpscap) == "function" then pcall(setfpscap, fps.cap); fps.cap = nil end
		pcall(function()
			if fps.quality then settings().Rendering.QualityLevel = fps.quality end
			if fps.shadows ~= nil then Lighting.GlobalShadows = fps.shadows end
			if fps.decoration ~= nil then workspace.Terrain.Decoration = fps.decoration end
		end)
		for inst, was in pairs(fps.saved) do
			pcall(function() inst.Enabled = was end)
		end
		fps.saved = {}
	end
	return applyFlags(fpsFlags, on)
end
PERF.fps = fps
PERF.setFpsBoost = setFpsBoost

local lag = {on=false, orig=setmetatable({},{__mode="k"}), conn=nil, env={}, token=0}
local function lagStrip(d)
	if d:IsA("BasePart") then
		if d:IsA("Terrain") then return end
		if lag.orig[d] == nil then lag.orig[d] = {Material=d.Material, Reflectance=d.Reflectance, CastShadow=d.CastShadow} end
		d.Material = Enum.Material.SmoothPlastic
		d.Reflectance = 0
		d.CastShadow = false
	elseif d:IsA("Decal") or d:IsA("Texture") then
		if lag.orig[d] == nil then lag.orig[d] = {Transparency=d.Transparency} end
		d.Transparency = 1
	elseif d:IsA("Light") or isEffect(d) then
		if lag.orig[d] == nil then lag.orig[d] = {Enabled=d.Enabled} end
		d.Enabled = false
	end
end
local function lagSweep(token)
	local n = 0
	for _, d in ipairs(workspace:GetDescendants()) do
		if not lag.on or token ~= lag.token then return end
		pcall(lagStrip, d)
		n += 1
		if n % 300 == 0 then task.wait() end
	end
end
local function setExtremeAntiLag(on)
	lag.on = on; lag.token += 1
	if on then
		local token = lag.token
		pcall(function()
			lag.env.quality = settings().Rendering.QualityLevel
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		end)
		pcall(function()
			lag.env.shadows = Lighting.GlobalShadows
			lag.env.fogEnd = Lighting.FogEnd
			Lighting.GlobalShadows = false
			Lighting.FogEnd = 9e8
		end)
		pcall(function()
			local t = workspace.Terrain
			lag.env.water = {t.WaterWaveSize, t.WaterWaveSpeed, t.WaterReflectance, t.WaterTransparency}
			lag.env.decoration = t.Decoration
			t.WaterWaveSize, t.WaterWaveSpeed, t.WaterReflectance, t.WaterTransparency = 0,0,0,1
			t.Decoration = false
		end)
		for _, v in ipairs(Lighting:GetChildren()) do
			pcall(function()
				if v:IsA("PostEffect") then
					if lag.orig[v] == nil then lag.orig[v] = {Enabled=v.Enabled} end
					v.Enabled = false
				elseif v:IsA("Atmosphere") then
					if lag.orig[v] == nil then lag.orig[v] = {Density=v.Density, Haze=v.Haze} end
					v.Density, v.Haze = 0, 0
				end
			end)
		end
		pcall(function()
			if typeof(sethiddenproperty) == "function" and typeof(gethiddenproperty) == "function" then
				lag.env.tech = gethiddenproperty(Lighting, "Technology")
				sethiddenproperty(Lighting, "Technology", Enum.Technology.Compatibility)
			end
		end)
		pcall(function()
			lag.env.meshDetail = settings().Rendering.MeshPartDetailLevel
			settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
		end)
		pcall(function()
			if workspace.StreamingEnabled then
				lag.env.streamRadius = workspace.StreamingTargetRadius
				workspace.StreamingTargetRadius = math.min(workspace.StreamingTargetRadius, 128)
			end
		end)
		pcall(function()
			for _, pl in ipairs(Players:GetPlayers()) do
				if pl ~= lp and pl.Character then
					local hum = pl.Character:FindFirstChildOfClass("Humanoid")
					if hum then hum.NameDisplayDistance = 0; hum.HealthDisplayDistance = 0 end
				end
			end
		end)
		if typeof(setfpscap) == "function" then pcall(setfpscap, 240) end
		lag.conn = workspace.DescendantAdded:Connect(function(d)
			if lag.on then pcall(lagStrip, d) end
		end)
		task.spawn(lagSweep, token)
	else
		if lag.conn then lag.conn:Disconnect(); lag.conn = nil end
		pcall(function()
			if lag.env.quality then settings().Rendering.QualityLevel = lag.env.quality end
			if lag.env.shadows ~= nil then Lighting.GlobalShadows = lag.env.shadows end
			if lag.env.fogEnd ~= nil then Lighting.FogEnd = lag.env.fogEnd end
			local t, w = workspace.Terrain, lag.env.water
			if w then t.WaterWaveSize,t.WaterWaveSpeed,t.WaterReflectance,t.WaterTransparency = w[1],w[2],w[3],w[4] end
			if lag.env.decoration ~= nil then t.Decoration = lag.env.decoration end
		end)
		pcall(function()
			if lag.env.tech ~= nil then sethiddenproperty(Lighting, "Technology", lag.env.tech) end
			if lag.env.meshDetail then settings().Rendering.MeshPartDetailLevel = lag.env.meshDetail end
			if lag.env.streamRadius then workspace.StreamingTargetRadius = lag.env.streamRadius end
		end)
		pcall(function()
			for _, pl in ipairs(Players:GetPlayers()) do
				if pl ~= lp and pl.Character then
					local hum = pl.Character:FindFirstChildOfClass("Humanoid")
					if hum then hum.NameDisplayDistance = 100; hum.HealthDisplayDistance = 100 end
				end
			end
		end)
		task.spawn(function()
			local n = 0
			for inst, props in pairs(lag.orig) do
				for k, v in pairs(props) do pcall(function() inst[k] = v end) end
				lag.orig[inst] = nil
				n += 1
				if n % 300 == 0 then task.wait() end
			end
		end)
		lag.env = {}
	end
	return applyFlags(fpsFlags, on)
end
PERF.lag = lag
PERF.setExtremeAntiLag = setExtremeAntiLag

-- 3D OFF fiable : certains jeux/éléments remettent Set3dRenderingEnabled(true) tout seuls
-- après un court instant (c'est ce qui causait le flash noir 0.5s puis retour du ciel).
-- On force le flag à chaque frame ET on pose un vrai cache GUI noir par-dessus, qui lui
-- ne dépend d'aucun flag moteur et ne peut pas être "remis" par le jeu.
local blackScreen = {on=false, gui=nil, frame=nil, conn=nil}
local function ensureBlackScreenGui()
	if blackScreen.gui and blackScreen.gui.Parent then return blackScreen.gui, blackScreen.frame end
	local parent = game:GetService("CoreGui")
	pcall(function() if typeof(gethui) == "function" then parent = gethui() end end)
	local old = parent:FindFirstChild("BRN782K_BlackScreen")
	if old then pcall(old.Destroy, old) end
	local gui = Instance.new("ScreenGui")
	gui.Name = "BRN782K_BlackScreen"
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 2147483647
	gui.Enabled = false
	local frame = Instance.new("Frame")
	frame.Name = "Black"
	frame.Size = UDim2.fromScale(1, 1)
	frame.Position = UDim2.fromScale(0, 0)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BorderSizePixel = 0
	frame.ZIndex = 10
	frame.Parent = gui
	local tag = Instance.new("TextLabel")
	tag.Name = "Tag"
	tag.BackgroundTransparency = 1
	tag.AnchorPoint = Vector2.new(1, 1)
	tag.Position = UDim2.new(1, -8, 1, -6)
	tag.Size = UDim2.fromOffset(170, 18)
	tag.Font = Enum.Font.GothamBlack
	tag.TextSize = 12
	tag.TextColor3 = Color3.fromRGB(40, 40, 40)
	tag.TextXAlignment = Enum.TextXAlignment.Right
	tag.Text = "BRN Code — 3D OFF"
	tag.ZIndex = 11
	tag.Parent = frame
	pcall(function() gui.Parent = parent end)
	blackScreen.gui, blackScreen.frame = gui, frame
	return gui, frame
end
local function set3dRender(off)
	local ok = pcall(function() RunService:Set3dRenderingEnabled(not off) end)
	if not ok then return false end
	blackScreen.on = off
	if off then
		local gui, frame = ensureBlackScreenGui()
		gui.Enabled = true
		frame.BackgroundTransparency = 0
		if blackScreen.conn then blackScreen.conn:Disconnect() end
		blackScreen.conn = RunService.Heartbeat:Connect(function()
			if not blackScreen.on then return end
			-- reforce le flag + le cache à chaque frame, au cas où le jeu les remette
			pcall(function() RunService:Set3dRenderingEnabled(false) end)
			if blackScreen.gui and not blackScreen.gui.Enabled then blackScreen.gui.Enabled = true end
			if blackScreen.frame and blackScreen.frame.BackgroundTransparency ~= 0 then
				blackScreen.frame.BackgroundTransparency = 0
			end
		end)
	else
		if blackScreen.conn then blackScreen.conn:Disconnect(); blackScreen.conn = nil end
		if blackScreen.gui then blackScreen.gui.Enabled = false end
	end
	return true
end
PERF.set3dRender = set3dRender

local ex = {on=false, hidden={}, saved={}, conns={}, loop=0, core={}}
local function isCosmetic(d)
	return d:IsA("Accessory") or d:IsA("Shirt") or d:IsA("Pants") or d:IsA("ShirtGraphic") or d:IsA("CharacterMesh")
end
local function hideCosmetic(d)
	if ex.on and ex.hidden[d] == nil and isCosmetic(d) then
		ex.hidden[d] = d.Parent; d.Parent = nil
	end
end
local function exWatchChar(char)
	for _, d in ipairs(char:GetDescendants()) do pcall(hideCosmetic, d) end
	ex.conns[#ex.conns+1] = char.DescendantAdded:Connect(function(d)
		task.defer(pcall, hideCosmetic, d)
	end)
end
local function exWatchPlayer(pl)
	if pl == lp then return end
	if pl.Character then task.spawn(pcall, exWatchChar, pl.Character) end
	ex.conns[#ex.conns+1] = pl.CharacterAdded:Connect(function(c)
		task.wait(0.5)
		if ex.on then pcall(exWatchChar, c) end
	end)
end
local function extremePlus(on)
	ex.on = on; ex.loop += 1
	if on then
		local token = ex.loop
		pcall(function()
			ex.saved.diffuse, ex.saved.specular, ex.saved.soft = Lighting.EnvironmentDiffuseScale, Lighting.EnvironmentSpecularScale, Lighting.ShadowSoftness
			Lighting.EnvironmentDiffuseScale, Lighting.EnvironmentSpecularScale, Lighting.ShadowSoftness = 0,0,0
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
			for _, t in ipairs({Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.Chat, Enum.CoreGuiType.EmotesMenu, Enum.CoreGuiType.Health}) do
				ex.core[t] = StarterGui:GetCoreGuiEnabled(t)
				StarterGui:SetCoreGuiEnabled(t, false)
			end
		end)
		for _, pl in ipairs(Players:GetPlayers()) do exWatchPlayer(pl) end
		ex.conns[#ex.conns+1] = Players.PlayerAdded:Connect(exWatchPlayer)
		task.spawn(function()
			while ex.on and token == ex.loop do
				for _, pl in ipairs(Players:GetPlayers()) do
					local hum = pl ~= lp and pl.Character and pl.Character:FindFirstChildOfClass("Humanoid")
					local animator = hum and hum:FindFirstChildOfClass("Animator")
					if animator then
						for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do pcall(tr.Stop, tr, 0) end
					end
				end
				task.wait(1.5)
			end
		end)
		pcall(collectgarbage, "collect")
	else
		for _, c in ipairs(ex.conns) do pcall(c.Disconnect, c) end
		ex.conns = {}
		pcall(function()
			if ex.saved.diffuse ~= nil then
				Lighting.EnvironmentDiffuseScale, Lighting.EnvironmentSpecularScale, Lighting.ShadowSoftness = ex.saved.diffuse, ex.saved.specular, ex.saved.soft
			end
			if ex.saved.tech ~= nil then sethiddenproperty(Lighting, "Technology", ex.saved.tech) end
			if ex.saved.mat2022 ~= nil then MaterialService.Use2022Materials = ex.saved.mat2022 end
		end)
		for t, was in pairs(ex.core) do pcall(StarterGui.SetCoreGuiEnabled, StarterGui, t, was) end
		for d, parent in pairs(ex.hidden) do pcall(function() d.Parent = parent end) end
		ex.hidden, ex.saved, ex.core = {},{},{}
	end
end
PERF.extremePlus = extremePlus
PERF.ex = ex

-- FX détaillé
local fx = {}
local function restoreEnabled(inst, v) inst.Enabled = v end
local function fxMake(match, apply, undo)
	local c = {on=false, saved={}, conn=nil, token=0}
	local function matches(d) local ok, m = pcall(match, d); return ok and m end
	c.set = function(on)
		c.on = on; c.token += 1
		if c.conn then c.conn:Disconnect(); c.conn = nil end
		if on then
			local tk = c.token
			c.conn = workspace.DescendantAdded:Connect(function(d)
				if c.on and c.saved[d] == nil and matches(d) then pcall(apply, c, d) end
			end)
			task.spawn(function()
				local n = 0
				for _, d in ipairs(workspace:GetDescendants()) do
					if not c.on or tk ~= c.token then return end
					if c.saved[d] == nil and matches(d) then pcall(apply, c, d) end
					n += 1
					if n % 300 == 0 then task.wait() end
				end
			end)
		else
			if c.conn then c.conn:Disconnect(); c.conn = nil end
			local saved = c.saved; c.saved = {}
			task.spawn(function()
				local n = 0
				for inst, st in pairs(saved) do
					pcall(undo, inst, st)
					n += 1
					if n % 300 == 0 then task.wait() end
				end
			end)
		end
	end
	return c
end

fx.particles = fxMake(isEffect, function(c, d) c.saved[d] = d.Enabled; d.Enabled = false end, restoreEnabled)
fx.lights    = fxMake(function(d) return d:IsA("Light") end, function(c, d) c.saved[d] = d.Enabled; d.Enabled = false end, restoreEnabled)
fx.textures  = fxMake(function(d)
	return d:IsA("Decal") or d:IsA("Texture") or d:IsA("SurfaceAppearance") or (d:IsA("MeshPart") and d.TextureID ~= "")
end, function(c, d)
	if d:IsA("SurfaceAppearance") then
		c.saved[d] = {"parent", d.Parent}; d.Parent = nil
	elseif d:IsA("MeshPart") then
		c.saved[d] = {"tex", d.TextureID}; d.TextureID = ""
	else
		c.saved[d] = {"tr", d.Transparency}; d.Transparency = 1
	end
end, function(inst, st)
	if st[1] == "parent" then inst.Parent = st[2]
	elseif st[1] == "tex" then inst.TextureID = st[2]
	else inst.Transparency = st[2] end
end)
local soundSaved = nil
fx.sound = {on=false, set=function(on)
	fx.sound.on = on
	pcall(function()
		local ugs = UserSettings():GetService("UserGameSettings")
		if on then soundSaved = ugs.MasterVolume; ugs.MasterVolume = 0
		elseif soundSaved ~= nil then ugs.MasterVolume = soundSaved; soundSaved = nil end
	end)
end}

----------------------------------------------------------------------
-- HIDE EVERYTHING : décors/plots + texte du jeu (snapshot) + ciel plat,
-- tout en gardant les animaux/brainrot visibles et sans faire tomber le joueur.
----------------------------------------------------------------------
local PLOT_KEYWORDS = {"brainrot", "animal", "pet"}
local function matchesKeyword(name)
	name = tostring(name or ""):lower()
	for _, kw in ipairs(PLOT_KEYWORDS) do
		if name:find("%f[%w]" .. kw .. "%f[%W]") then return true end
	end
	return false
end
local function isWhitelisted(d)
	local node = d
	for _ = 1, 6 do -- remonte quelques niveaux d'ancêtres (part -> modèle -> dossier...)
		if not node or node == workspace then break end
		if matchesKeyword(node.Name) then return true end
		node = node.Parent
	end
	return false
end
local function isPlotPart(d)
	if d:IsA("Terrain") then return false end
	if d:IsA("BasePart") then
		-- ne jamais toucher aux joueurs (perso = Model avec Humanoid)
		local model = d:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChildOfClass("Humanoid") then return false end
		return not isWhitelisted(d)
	end
	if d:IsA("Decal") or d:IsA("Texture") or d:IsA("SurfaceAppearance")
	or d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam")
	or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles")
	or d:IsA("Light") or d:IsA("Highlight") then
		return not isWhitelisted(d)
	end
	return false
end
fx.plots = fxMake(isPlotPart, function(c, d)
	-- Jamais de CanCollide touché, sinon le joueur tombe à travers le sol/les plateformes.
	if d:IsA("BasePart") or d:IsA("Decal") or d:IsA("Texture") then
		c.saved[d] = {"tr", d.Transparency}
		d.Transparency = 1
	elseif d:IsA("SurfaceAppearance") then
		c.saved[d] = {"parent", d.Parent}
		d.Parent = nil
	else
		c.saved[d] = {"enabled", d.Enabled}
		d.Enabled = false
	end
end, function(inst, st)
	if st == nil then return end
	if st[1] == "tr" then inst.Transparency = st[2]
	elseif st[1] == "parent" then inst.Parent = st[2]
	elseif st[1] == "enabled" then inst.Enabled = st[2]
	end
end)

-- Texte du jeu : snapshot UNE FOIS à l'activation (pas de hook live), pour ne jamais
-- masquer une annonce du créateur ou un texte qui apparaît après coup (TopNotification
-- vit dans PlayerGui, jamais touché ici : seul workspace est balayé).
local hiddenText = {}
local hideTextToken = 0
local function hideGameTextOnce()
	hideTextToken += 1
	local tk = hideTextToken
	task.spawn(function()
		local n = 0
		for _, d in ipairs(workspace:GetDescendants()) do
			if tk ~= hideTextToken then return end -- coupé entre-temps
			if hiddenText[d] == nil then
				if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
					hiddenText[d] = {"visible", d.Visible}
					d.Visible = false
				elseif d:IsA("SurfaceGui") or d:IsA("BillboardGui") then
					hiddenText[d] = {"enabled", d.Enabled}
					d.Enabled = false
				end
			end
			n += 1
			if n % 300 == 0 then task.wait() end
		end
	end)
end
local function restoreGameText()
	hideTextToken += 1 -- arrête un balayage encore en cours
	for inst, st in pairs(hiddenText) do
		pcall(function()
			if st[1] == "visible" then inst.Visible = st[2]
			else inst.Enabled = st[2] end
		end)
	end
	hiddenText = {}
end

-- Ciel : remplace le skybox texturé par un rendu plat (moins de texture sampling = plus de FPS).
local skyInstance, skyParent = nil, nil
local skySaved = {}
local function flattenSky(on)
	pcall(function()
		if on then
			local sky = Lighting:FindFirstChildOfClass("Sky")
			if sky then
				skyInstance, skyParent = sky, sky.Parent
				sky.Parent = nil
			end
			skySaved.clock = Lighting.ClockTime
			skySaved.amb = Lighting.Ambient
			skySaved.outAmb = Lighting.OutdoorAmbient
			skySaved.fogC = Lighting.FogColor
			skySaved.bright = Lighting.Brightness
			-- Le ciel est retiré juste au-dessus (sky.Parent = nil) : c'est ÇA qui donne
			-- le fond noir, pas besoin de couper l'ambiance en plus. Avant, Ambient/
			-- OutdoorAmbient à 0 + ClockTime à minuit rendaient aussi les Animal/Pet/
			-- Brainrot encore visibles trop sombres. On garde le fond noir mais on
			-- rallume une ambiance neutre pour qu'ils restent bien visibles/colorés.
			Lighting.ClockTime = 14
			Lighting.Ambient = Color3.fromRGB(200, 200, 200)
			Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
			Lighting.FogColor = Color3.fromRGB(0,0,0)
			Lighting.Brightness = math.max(Lighting.Brightness, 2)
		else
			if skyInstance then skyInstance.Parent = skyParent end
			skyInstance, skyParent = nil, nil
			if skySaved.clock then
				Lighting.ClockTime = skySaved.clock
				Lighting.Ambient = skySaved.amb
				Lighting.OutdoorAmbient = skySaved.outAmb
				Lighting.FogColor = skySaved.fogC
				if skySaved.bright then Lighting.Brightness = skySaved.bright end
			end
			skySaved = {}
		end
	end)
end

local hideEverything = {on = false}
function hideEverything.set(on)
	hideEverything.on = on
	pcall(fx.plots.set, on)
	flattenSky(on)
	if on then
		pcall(hideGameTextOnce)
	else
		pcall(restoreGameText)
	end
end
PERF.hideEverything = hideEverything

PERF.fx = fx

jumps = {on=false, conn=nil}
function setJumps(on)
	jumps.on = on
	if jumps.conn then jumps.conn:Disconnect(); jumps.conn = nil end
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

speed = {on=false, conn=nil, value=140}
function setSpeed(on)
	speed.on = on
	if speed.conn then speed.conn:Disconnect(); speed.conn = nil end
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
	if fps.conn then pcall(function() fps.conn:Disconnect() end) end
	if hideEverything.on then pcall(hideEverything.set, false) end
	if lag.on then pcall(setExtremeAntiLag, false) end
	if ex.on then pcall(extremePlus, false) end
	for _, cat in pairs(fx) do if cat.on then pcall(cat.set, false) end end
end
end

----------------------------------------------------------------------
-- WEBHOOK
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
	success = {title="✅ Code redeem !", color=5763719},
	soldout = {title="❌ Sold out",       color=15548997},
	already = {title="⚠️ Déjà utilisé",   color=16705372},
	invalid = {title="⚠️ Invalid code",   color=16705372},
	refused = {title="🚫 Refusé",         color=10038562},
	test    = {title="🔔 Test webhook",   color=5793266},
}

local function cutText(str, n)
	str = tostring(str)
	if #str <= n then return str end
	local ok, pos = pcall(utf8.offset, str, n+1)
	return str:sub(1, (ok and pos or n+1)-1)
end

local function sendWebhook(kind, code, msg, ms)
	local st = WEBHOOK_STYLE[kind]
	if not st or not httpRequest or not webhookReady() then return false end
	local url = trim(cfg.webhook)
	local text = type(msg) == "string" and clean(msg) or ""
	local title = st.title
	task.spawn(function()
		local fields = {
			{name="Code",   value="`"..tostring(code).."`", inline=true},
			{name="Temps",  value=tostring(ms or 0).." ms",  inline=true},
			{name="Joueur", value=tostring(lp.Name),          inline=true},
		}
		if text ~= "" then fields[#fields+1] = {name="Réponse", value=cutText(text,200)} end
		local ok, body = pcall(HttpService.JSONEncode, HttpService, {
			username = "VOIDSNIPE",
			embeds = {{
				title  = cutText(title, 250),
				color  = st.color,
				fields = fields,
				footer = {text = "VOIDSNIPE v1.0"},
				timestamp = DateTime.now():ToIsoDate(),
			}},
		})
		if not ok then return end
		pcall(httpRequest, {
			Url     = url,
			Method  = "POST",
			Headers = {["Content-Type"]="application/json"},
			Body    = body,
		})
	end)
	return true
end

----------------------------------------------------------------------
-- GUI CODES (Click)
----------------------------------------------------------------------
local uiCache = {box=nil, confirm=nil}

local function getCodesUI()
	if uiCache.confirm and uiCache.confirm.Parent and uiCache.box and uiCache.box.Parent then
		return uiCache.box, uiCache.confirm
	end
	local codes = playerGui:FindFirstChild("Codes")
	codes = codes and codes:FindFirstChild("Codes")
	if not codes then return nil, nil end
	local box = codes:FindFirstChild("CodeRedeem")
	box = box and box:FindFirstChild("TextBox")
	local confirm = codes:FindFirstChild("Confirm")
	if box and confirm then
		uiCache.box, uiCache.confirm = box, confirm
		box.ClearTextOnFocus = false
	end
	return box, confirm
end

-- Capacité testée une seule fois au premier usage réel, puis mise en cache :
-- évite de retenter firesignal à chaque redeem si l'exécuteur ne le supporte pas.
local firesignalCap = nil -- nil = pas encore testé, true/false = résultat mis en cache
local function fireSignal(sig)
	local ok, list = pcall(getconnections, sig)
	if not ok or #list == 0 then return false end

	if firesignalCap ~= false and typeof(firesignal) == "function" then
		local fok = pcall(firesignal, sig)
		if fok then
			firesignalCap = true
			return true
		end
		firesignalCap = false -- échec constaté une fois : on ne retente plus, fallback direct
	end

	local any = false
	for _, c in ipairs(list) do
		any = pcall(function() c:Fire() end) or any
	end
	return any
end

-- Click simple et honnête : écrit le code entier dans la TextBox, puis clique Confirm.
-- Pas de faux délai de frappe, pas de triche de timing.
-- On retient quel signal a marché la dernière fois (Activated ou MouseButton1Click)
-- pour le retenter en premier : évite un essai pour rien à chaque code une fois que
-- le bon signal est connu.
local lastGoodSignal = nil -- "activated" | "mouse1" | nil
local function clickRedeem(code)
	code = tostring(code or "")
	local box, confirm = getCodesUI()
	if not box or not confirm then return false end

	box.Text = code

	if typeof(getconnections) ~= "function" then
		return false
	end
	if lastGoodSignal == "mouse1" then
		if fireSignal(confirm.MouseButton1Click) then return true end
		if fireSignal(confirm.Activated) then lastGoodSignal = "activated"; return true end
		return false
	end
	if fireSignal(confirm.Activated) then lastGoodSignal = "activated"; return true end
	if fireSignal(confirm.MouseButton1Click) then lastGoodSignal = "mouse1"; return true end
	return false
end

-- Préchauffe le cache UI (TextBox + bouton Confirm) tout de suite, sans rien cliquer :
-- si on attend le premier code réel pour faire cette recherche, ce premier code (souvent
-- le plus important) paie le coût du FindFirstChild. Là il est déjà payé au chargement.
task.spawn(function()
	pcall(getCodesUI)
end)

----------------------------------------------------------------------
-- ÉTAT
----------------------------------------------------------------------
local session = {
	parts       = {},
	lastPart    = 0,
	accumulating = false,
	currentCode = "", -- code assemblé actuel (pour accumulation invalid)
}
local listening    = false
local listenConn   = nil
local topNotification = nil
local ignoreUntil  = 0
local lastAttemptAt = 0

----------------------------------------------------------------------
-- STATUT GUI (défini plus bas, forward refs)
----------------------------------------------------------------------
local setStatus, refreshStart, startSpam, startListening, stopListening, refreshUIBadge, profLog
profLog = function() end

----------------------------------------------------------------------
-- FEEDBACK WATCHER
----------------------------------------------------------------------
local function lowerHas(msg, ...)
	for _, p in ipairs({...}) do
		if msg:find(p, 1, true) then return true end
	end
	return false
end

local function classifyFeedback(text, fromCodesGui)
	local low = tostring(text or ""):lower()
	if low == "" then return nil end
	if fromCodesGui and low:find("spawned", 1, true) then return "success" end
	if low:find("sold out", 1, true) then return "soldout" end
	if low:find("already", 1, true) and low:find("redeem", 1, true) then return "already" end
	if low:find("invalid code", 1, true) or low:find("code is invalid", 1, true) or low:find("does not exist", 1, true) then return "invalid" end
	return nil
end

local function watchFeedback(onKind)
	local list, closed = {}, false
	local function add(c)
		if closed then c:Disconnect() else list[#list+1] = c end
	end
	local function check(label, fromGui)
		local text = clean(label.Text)
		local kind = classifyFeedback(text, fromGui)
		if kind then onKind(kind, text) end
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
			local function hook(label) check(label, false); hookLabel(label, false) end
			local label = child:IsA("TextLabel") and child or child:FindFirstChildWhichIsA("TextLabel", true)
			if label then hook(label) end
			add(child.DescendantAdded:Connect(function(d)
				if d:IsA("TextLabel") then hook(d) end
			end))
		end))
	end
	local codes = playerGui:FindFirstChild("Codes")
	if codes then
		for _, d in ipairs(codes:GetDescendants()) do
			if d:IsA("TextLabel") then hookLabel(d, true) end
		end
		add(codes.DescendantAdded:Connect(function(d)
			if d:IsA("TextLabel") then check(d, true); hookLabel(d, true) end
		end))
	end
	return function()
		closed = true
		for _, c in ipairs(list) do pcall(c.Disconnect, c) end
		table.clear(list)
	end
end

----------------------------------------------------------------------
-- REDEEM (un seul envoi, après un délai fixe, aucune boucle)
----------------------------------------------------------------------
startSpam = function(code)
	session.currentCode = code
	lastAttemptAt = tick()

	local token = session.token or 0
	session.token = token + 1
	token = session.token

	local done = false
	local stopFeedback = function() end

	local function conclude() done = true; stopFeedback() end

	local function onFeedback(kind, text)
		if done or token ~= session.token then return end
		local ms = 0

		if kind == "success" then
			conclude()
			pcall(function() game:GetService("SoundService") end)
			pcall(function()
				local s = Instance.new("Sound")
				s.SoundId = "rbxassetid://4813454669"
				s.Volume = 1
				s.Parent = workspace
				s:Play()
				game:GetService("Debris"):AddItem(s, 6)
			end)
			session.parts = {}; session.accumulating = false; session.currentCode = ""
			stopListening()
			setStatus("✓ SPAWNED! " .. code, N.cyan)
			profLog("✅ " .. code .. " → spawned!", N.cyan)
			sendWebhook("success", code, text, ms)
			refreshStart()
		elseif kind == "soldout" then
			conclude()
			session.parts = {}; session.accumulating = false; session.currentCode = ""
			stopListening()
			setStatus("⊘ Sold out : " .. code, N.rose)
			profLog("❌ Sold out : " .. code, N.rose)
			sendWebhook("soldout", code, text, ms)
			refreshStart()
		elseif kind == "already" then
			conclude()
			session.parts = {}; session.accumulating = false; session.currentCode = ""
			stopListening()
			setStatus("⚠ Déjà redeem : " .. code, N.dim)
			sendWebhook("already", code, text, ms)
			refreshStart()
		elseif kind == "invalid" then
			-- On garde les parties déjà reçues et on attend la suivante (pas de reboucle automatique)
			conclude()
			session.accumulating = true
			session.lastPart = tick()
			local n = #session.parts
			setStatus(string.format("Invalid → %d partie(s) gardées, j'attends...", n), N.orange)
			profLog("⚠️ Invalid : " .. code .. " (" .. n .. " parties gardées)", N.orange)
			sendWebhook("invalid", code, text, ms)
			task.spawn(function()
				local box = getCodesUI()
				if box then
					box.ClearTextOnFocus = false
					box.Text = code
				end
			end)
			refreshStart()
		end
	end

	stopFeedback = watchFeedback(onFeedback)

	-- Délai obligatoire avant l'envoi (temps normal de lecture/frappe humaine, pas de triche de vitesse)
	local dMin = math.max(0, cfg.submitDelayMin or 0)
	local dMax = math.max(dMin, cfg.submitDelayMax or dMin)
	local delay = cfg.autoInstant and 0 or (dMin + math.random() * (dMax - dMin))
	setStatus(string.format("Code prêt : %s — envoi dans %ds", code, delay), N.orange)
	profLog(string.format("⏳ %s → envoi programmé dans %ds", code, delay), N.orange)

	do
		local waited = 0
		local lastShown = -1
		local hbConn
		hbConn = RunService.Heartbeat:Connect(function(dt)
			if done or token ~= session.token then
				hbConn:Disconnect()
				return
			end
			waited += dt
			if waited < delay then
				local shownSec = math.ceil(delay - waited)
				if shownSec ~= lastShown then
					lastShown = shownSec
					setStatus(string.format("Envoi dans %ds... (%s)", shownSec, code), N.orange)
				end
				return
			end

			hbConn:Disconnect()
			if done or token ~= session.token then return end

			setStatus("Envoi : " .. code, N.orange)
			clickRedeem(code)

			-- fenêtre d'attente de la réponse serveur, un seul essai, pas de reboucle, pilotée au Heartbeat
			local graceWaited = 0
			local graceConn
			graceConn = RunService.Heartbeat:Connect(function(gdt)
				if done or token ~= session.token then
					graceConn:Disconnect()
					return
				end
				graceWaited += gdt
				if graceWaited < 5 then return end
				graceConn:Disconnect()
				if done or token ~= session.token then return end
				conclude()
				setStatus("Pas de réponse pour : " .. code, N.dim)
				refreshStart()
			end)
		end)
	end
end

----------------------------------------------------------------------
-- DÉTECTION CODES (notifications)
----------------------------------------------------------------------
do
local function normalizeCode(s)
	-- Majuscule automatiquement, peu importe la casse
	return (tostring(s or ""):upper():gsub("[^A-Z0-9]", ""))
end

local function parseCue(text)
	local low = text:lower()
	if low == "" then return nil end
	local p1, e1 = low:find("the%s+code%s+is%s*")
	if not e1 then p1, e1 = low:find("code%s+is%s*") end
	local p2, e2 = low:find("the%s+riddle%s+is%s*")
	if not e2 then p2, e2 = low:find("riddle%s+is%s*") end
	if e1 and (not p2 or p1 < p2) then
		local inline = normalizeCode(text:sub(e1 + 1))
		return "sniper", inline ~= "" and inline or nil
	end
	if e2 then return "riddle" end
	local sammy = low:find("sammy", 1, true) ~= nil
	if sammy and low:find("riddle", 1, true) then return "riddle" end
	if sammy and (low:find("code", 1, true) or low:find("ok its", 1, true) or low:find("ok it's", 1, true)) then
		return "sniper"
	end
	return nil
end

local function isUtility(text)
	local low = text:lower()
	if lowerHas(low, "code redeemed", "redeemed successfully", "already been redeemed", "you got") then
		return true
	end
	local recent = tick() <= ignoreUntil or tick() - lastAttemptAt < 5
	if recent and lowerHas(low, "invalid code", "code is invalid", "does not exist", "please wait", "rate limit", "too many request", "try again", "cooldown", "too fast") then
		return true
	end
	return false
end

local lastText, lastTextAt = "", 0

local function addPart(rawText)
	local text = normalizeCode(rawText) -- majuscule automatique
	if text == "" then return end

	local now = tick()
	if text == lastText and now - lastTextAt < 0.05 then return end
	lastText, lastTextAt = text, now

	if now - session.lastPart > cfg.staleSeconds and not session.accumulating then
		session.parts = {}
	end
	session.lastPart = now

	table.insert(session.parts, text)
	local n = #session.parts

	if session.accumulating then
		-- Nouvelle partie reçue après un invalid : on retente avec le code mis à jour
		local assembled = table.concat(session.parts)
		session.accumulating = false -- sera remis à true si invalid
		setStatus(string.format("Partie %d (accum) : %s", n, assembled), N.orange)
		if cfg.autoRedeem then
			startSpam(assembled)
		else
			setStatus("Code prêt (Auto Redeem OFF) : " .. assembled, N.dim)
		end
	elseif n >= cfg.parts then
		-- Code complet atteint
		local assembled = table.concat(session.parts)
		setStatus(string.format("Code complet : %s", assembled), N.orange)
		if cfg.autoRedeem then
			startSpam(assembled)
		else
			setStatus("Code prêt (Auto Redeem OFF) : " .. assembled, N.dim)
		end
	else
		-- En attente de la prochaine partie
		setStatus(string.format("Partie %d/%d : %s", n, cfg.parts, text), N.orange)
	end
end

local function onText(text)
	if not listening or text == "" or isUtility(text) then return end

	-- 1. Indices "The code is XXXX"
	local kind, inline = parseCue(text)
	if kind then
		if kind ~= "sniper" then
			setStatus("Indice reçu, j'attends le code...", N.orange)
			return
		end
		if not inline then
			setStatus("Indice reçu, j'attends le code...", N.orange)
			return
		end
		return addPart(inline)
	end

	-- 2. Partie brute : on prend tout ce qui arrive (majuscule auto)
	local up = normalizeCode(text)
	if up == "" then return end
	addPart(up)
end

local function findLabel(obj)
	if obj:IsA("TextLabel") then return obj end
	return obj:FindFirstChildWhichIsA("TextLabel", true)
end

local function watch(child)
	local list, done = {}, false
	local function finish()
		if done then return end
		done = true
		for _, c in ipairs(list) do c:Disconnect() end
	end
	local function check()
		if done then return true end
		local label = findLabel(child)
		if not label then return false end
		local text = clean(label.Text)
		if text == "" then return false end
		finish()
		onText(text)
		return true
	end
	if check() then return end
	local label = findLabel(child)
	if label then
		list[#list+1] = label:GetPropertyChangedSignal("Text"):Connect(check)
	end
	list[#list+1] = child.DescendantAdded:Connect(function(d)
		if d:IsA("TextLabel") then
			list[#list+1] = d:GetPropertyChangedSignal("Text"):Connect(check)
		end
		check()
	end)
	do
		local waited = 0
		local hbConn
		hbConn = RunService.Heartbeat:Connect(function(dt)
			if done then
				hbConn:Disconnect()
				return
			end
			waited += dt
			if waited < 0.25 then return end
			hbConn:Disconnect()
			if not done then check(); finish() end
		end)
	end
end

-- Écoute rapide
local fastConn, fastLabels = nil, setmetatable({}, {__mode="k"})
local fastRetryConn = nil
local function hookFast()
	if fastConn or not topNotification then return end
	local function take(label)
		if fastLabels[label] then return end
		fastLabels[label] = true
		local conn
		local function read()
			local text = clean(label.Text)
			if text ~= "" then
				if conn then conn:Disconnect(); conn = nil end
				onText(text)
			end
		end
		conn = label:GetPropertyChangedSignal("Text"):Connect(read)
		read()
	end
	fastConn = topNotification.DescendantAdded:Connect(function(d)
		if d:IsA("TextLabel") then take(d) end
	end)
end
local function startFast()
	if fastConn or fastRetryConn or not cfg.fastListen then return end
	if topNotification then
		hookFast()
		return
	end
	-- topNotification pas encore trouvé : on retry en Heartbeat au lieu d'abandonner
	fastRetryConn = RunService.Heartbeat:Connect(function()
		if not cfg.fastListen or not listening then
			if fastRetryConn then fastRetryConn:Disconnect(); fastRetryConn = nil end
			return
		end
		if topNotification then
			fastRetryConn:Disconnect(); fastRetryConn = nil
			hookFast()
		end
	end)
end
local function stopFast()
	if fastConn then fastConn:Disconnect(); fastConn = nil end
	if fastRetryConn then fastRetryConn:Disconnect(); fastRetryConn = nil end
end

startListening = function()
	if listening then return true end
	if not topNotification or topNotification:IsA("ScreenGui") then
		local top = playerGui:FindFirstChild("TopNotification") or playerGui:WaitForChild("TopNotification", 5)
		topNotification = top and (top:FindFirstChild("TopNotification") or top:WaitForChild("TopNotification", 5))
	end
	if not topNotification then
		setStatus("TopNotification introuvable", N.rose)
		return false
	end
	listening = true
	session.parts = {}; session.lastPart = 0; session.accumulating = false; session.currentCode = ""
	if not session.token then session.token = 0 end
	session.token += 1
	listenConn = topNotification.ChildAdded:Connect(watch)
	startFast()
	setStatus("Écoute... (" .. cfg.parts .. " parties)", N.cyan)
	return true
end

stopListening = function()
	listening = false
	if not session.token then session.token = 0 end
	session.token += 1
	if listenConn then listenConn:Disconnect(); listenConn = nil end
	stopFast()
end

end -- fin détection

----------------------------------------------------------------------
-- GUI VOIDSNIPE — compact, tabs en haut, style sombre/or
----------------------------------------------------------------------
local WIDTH    = 260
local HEAD_H   = 34
local TAB_H    = 24
local STATUS_H = 20

local gui = mk("ScreenGui", {
	Name = "VOIDSNIPE_GUI",
	ResetOnSpawn = false,
	DisplayOrder = 999,
	IgnoreGuiInset = true,
}, (typeof(gethui) == "function" and gethui()) or playerGui)

local main = mk("Frame", {
	Size = UDim2.fromOffset(WIDTH, 1), -- hauteur réglée par page, voir plus bas
	Position = UDim2.new(0.5, -WIDTH/2, 0, 48),
	BackgroundColor3 = N.bg,
	BorderSizePixel = 0,
	ClipsDescendants = true,
}, gui)
corner(main, 14)
local mainStroke = uistroke(main, N.borderC, 1.5)

mk("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 14, 12)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 7, 6)),
	}),
	Rotation = 135,
}, main)

----------------------------------------------------------------------
-- HEADER
----------------------------------------------------------------------
local header = mk("Frame", {
	Size = UDim2.new(1, 0, 0, HEAD_H),
	BackgroundColor3 = N.glass,
	BackgroundTransparency = 0.4,
	BorderSizePixel = 0,
}, main)
mk("Frame", {
	Position = UDim2.new(0, 0, 1, -1),
	Size = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = N.borderC,
	BorderSizePixel = 0,
}, header)

local titleLabel = mk("TextLabel", {
	Position = UDim2.fromOffset(12, 4),
	Size = UDim2.fromOffset(150, 16),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBlack,
	TextSize = 14,
	TextColor3 = N.cyan,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "BRN Code",
}, header)

mk("TextLabel", {
	Position = UDim2.fromOffset(12, 18),
	Size = UDim2.fromOffset(150, 12),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	TextSize = 9,
	TextColor3 = N.dim,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "v1.1  •  Click",
}, header)

local closeBtn = mk("TextButton", {
	Position = UDim2.fromOffset(WIDTH - 24, 7),
	Size = UDim2.fromOffset(18, 18),
	BackgroundColor3 = Color3.fromRGB(45, 25, 25),
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	TextColor3 = N.rose,
	Text = "✕",
}, header)
corner(closeBtn, 5)

local minBtn = mk("TextButton", {
	Position = UDim2.fromOffset(WIDTH - 46, 7),
	Size = UDim2.fromOffset(18, 18),
	BackgroundColor3 = N.glass2,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextColor3 = N.dim,
	Text = "−",
}, header)
corner(minBtn, 5)

----------------------------------------------------------------------
-- TABS (en haut, sous le header)
----------------------------------------------------------------------
local TAB_Y = HEAD_H
local tabBar = mk("Frame", {
	Position = UDim2.fromOffset(0, TAB_Y),
	Size = UDim2.fromOffset(WIDTH, TAB_H),
	BackgroundColor3 = N.glass,
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
}, main)
mk("Frame", {
	Position = UDim2.new(0, 0, 1, -1),
	Size = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = N.border,
	BorderSizePixel = 0,
}, tabBar)

local tabDefs = {
	{id="fx",     label="FONCTIONNALITY"},
	{id="redeem", label="REDEEMER"},
	{id="boost",  label="BOOST"},
}
local tabBtns, tabMarks = {}, {}
for i, def in ipairs(tabDefs) do
	local b = mk("TextButton", {
		Position = UDim2.new((i-1)/#tabDefs, 0, 0, 0),
		Size = UDim2.new(1/#tabDefs, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBold,
		TextSize = 9,
		TextColor3 = N.dim,
		Text = def.label,
	}, tabBar)
	local mark = mk("Frame", {
		Position = UDim2.new(0.15, 0, 1, -2),
		Size = UDim2.new(0.7, 0, 0, 2),
		BackgroundColor3 = N.cyan,
		BorderSizePixel = 0,
		Visible = false,
	}, b)
	corner(mark, 1)
	tabBtns[def.id]  = b
	tabMarks[def.id] = mark
end

----------------------------------------------------------------------
-- BARRE STATUT (dot + texte + compteur parties)
----------------------------------------------------------------------
local STATUS_Y = TAB_Y + TAB_H
local statusBar = mk("Frame", {
	Position = UDim2.fromOffset(0, STATUS_Y),
	Size = UDim2.fromOffset(WIDTH, STATUS_H),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, main)

local statusDot = mk("Frame", {
	Position = UDim2.fromOffset(10, 7),
	Size = UDim2.fromOffset(7, 7),
	BackgroundColor3 = N.dim,
	BorderSizePixel = 0,
}, statusBar)
corner(statusDot, 4)

local statusLabel = mk("TextLabel", {
	Position = UDim2.fromOffset(22, 0),
	Size = UDim2.fromOffset(WIDTH - 70, STATUS_H),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	TextSize = 10,
	TextTruncate = Enum.TextTruncate.AtEnd,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = N.dim,
	Text = "IDLE",
}, statusBar)

local countLabel = mk("TextLabel", {
	Position = UDim2.fromOffset(WIDTH - 44, 0),
	Size = UDim2.fromOffset(34, STATUS_H),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Right,
	TextColor3 = N.dim,
	Text = "0/1",
}, statusBar)

local uiLast = 0
setStatus = function(text, color)
	local col = color or N.text
	statusLabel.Text = tostring(text)
	statusLabel.TextColor3 = col
	statusDot.BackgroundColor3 = col
	uiLast = os.clock()
end

local function refreshCount()
	countLabel.Text = string.format("%d/%d", #session.parts, cfg.parts)
end

----------------------------------------------------------------------
-- COMPOSANTS GUI
----------------------------------------------------------------------
local function glassCard(parent, h)
	local f = mk("Frame", {
		Size = UDim2.new(1, -4, 0, h),
		BackgroundColor3 = N.glass,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		LayoutOrder = 0,
	}, parent)
	corner(f, 8)
	uistroke(f, N.border, 1)
	return f
end

-- Toggle façon pilule ON/OFF (vert = ON, comme sur la référence)
local function toggle(parent, labelText, initOn, lo)
	lo = lo or 0
	local ROW_H = 30
	local card = glassCard(parent, ROW_H)
	card.LayoutOrder = lo

	mk("TextLabel", {
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.fromOffset(card.AbsoluteSize.X - 70, ROW_H),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = N.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = labelText,
	}, card)

	local pill = mk("TextButton", {
		Position = UDim2.new(1, -56, 0.5, -11),
		Size = UDim2.fromOffset(44, 22),
		BackgroundColor3 = Color3.fromRGB(45, 20, 20),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBlack,
		TextSize = 10,
		TextColor3 = Color3.fromRGB(255,255,255),
		Text = "OFF",
	}, card)
	corner(pill, 11)

	local on = initOn or false
	local function refresh()
		tw(pill, 0.15, {BackgroundColor3 = on and Color3.fromRGB(25, 150, 70) or Color3.fromRGB(55, 30, 30)})
		pill.Text = on and "ON" or "OFF"
	end
	refresh()

	local changed = Instance.new("BindableEvent")
	track(pill.Activated:Connect(function()
		on = not on
		refresh()
		changed:Fire(on)
	end))

	local function setState(v) on = v; refresh() end
	local function getState() return on end

	return card, changed.Event, setState, getState
end

-- Stepper -/+ compact
local function stepper(parent, labelText, val, lo2, hi, lo_order)
	lo_order = lo_order or 0
	local ROW_H = 30
	local card = glassCard(parent, ROW_H)
	card.LayoutOrder = lo_order

	local minus = mk("TextButton", {
		Position = UDim2.fromOffset(6, 4),
		Size = UDim2.fromOffset(22, 22),
		BackgroundColor3 = N.glass2,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = N.cyan,
		Text = "−",
	}, card)
	corner(minus, 6)

	local valLbl = mk("TextLabel", {
		Position = UDim2.fromOffset(32, 0),
		Size = UDim2.fromOffset(card.AbsoluteSize.X - 96, ROW_H),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = N.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, card)

	local plus = mk("TextButton", {
		Position = UDim2.new(1, -28, 0, 4),
		Size = UDim2.fromOffset(22, 22),
		BackgroundColor3 = N.glass2,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = N.cyan,
		Text = "+",
	}, card)
	corner(plus, 6)

	local current = val
	local function render()
		valLbl.Text = string.format('%s: %s', labelText, tostring(current))
	end
	render()

	local changed = Instance.new("BindableEvent")
	track(minus.Activated:Connect(function()
		current = math.clamp(current - 1, lo2, hi)
		render()
		changed:Fire(current)
		saveSettings()
	end))
	track(plus.Activated:Connect(function()
		current = math.clamp(current + 1, lo2, hi)
		render()
		changed:Fire(current)
		saveSettings()
	end))

	local function set(v) current = math.clamp(v, lo2, hi); render() end
	local function get() return current end

	return card, changed.Event, set, get
end

local sectionOrder = 0
local function section(parent, text)
	sectionOrder += 1
	local f = mk("Frame", {
		Size = UDim2.new(1, -4, 0, 16),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = sectionOrder,
	}, parent)
	mk("TextLabel", {
		Size = UDim2.new(1,0,1,0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBlack,
		TextSize = 9,
		TextColor3 = N.cyanDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "▸ " .. text,
	}, f)
	return f
end

----------------------------------------------------------------------
-- PAGES
----------------------------------------------------------------------
local PAGE_Y = STATUS_Y + STATUS_H
local function newPage()
	local p = mk("Frame", {
		Position = UDim2.fromOffset(6, PAGE_Y + 4),
		Size = UDim2.fromOffset(WIDTH - 12, 0), -- hauteur = AutomaticSize
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
	}, main)
	mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,5)}, p)
	return p
end
local pageFx     = newPage()
local pageRedeem = newPage()
local pageBoost  = newPage()
local pages = {fx = pageFx, redeem = pageRedeem, boost = pageBoost}

----------------------------------------------------------------------
-- PAGE REDEEMER
----------------------------------------------------------------------
sectionOrder = 0

local startCard = glassCard(pageRedeem, 38)
startCard.LayoutOrder = 1
local startBtn = mk("TextButton", {
	Position = UDim2.fromOffset(4, 4),
	Size = UDim2.new(1, -8, 0, 30),
	BackgroundColor3 = N.cyan,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Font = Enum.Font.GothamBlack,
	TextSize = 13,
	TextColor3 = Color3.fromRGB(20, 16, 8),
	Text = "▶  START",
}, startCard)
corner(startBtn, 7)

refreshStart = function()
	if listening then
		startBtn.Text = "■  STOP"
		startBtn.BackgroundColor3 = N.rose
		statusDot.BackgroundColor3 = N.cyan
	else
		startBtn.Text = "▶  START"
		startBtn.BackgroundColor3 = N.cyan
	end
end

local _, autoRedeemEv, autoRedeemSet = toggle(pageRedeem, "Auto Redeem", cfg.autoRedeem, 2)
track(autoRedeemEv:Connect(function(v)
	cfg.autoRedeem = v
	setStatus(v and "Auto Redeem ON" or "Auto Redeem OFF", v and N.cyan or N.dim)
	saveSettings()
end))

local _, autoStartEv, autoStartSet = toggle(pageRedeem, "Auto Start", persist.autoStart, 3)
track(autoStartEv:Connect(function(v)
	persist.autoStart = v
	saveSettings()
end))

local partsCard, partsEv, partsSet, partsGet = stepper(pageRedeem, "Submit After", cfg.parts, 1, 6, 4)
track(partsEv:Connect(function(v)
	cfg.parts = v
	refreshCount()
	setStatus("Submit After : " .. v, N.cyan)
end))

local _, invEv, invSet = toggle(pageRedeem, "Invalid → Accumule", cfg.growOnInvalid, 5)
track(invEv:Connect(function(v)
	cfg.growOnInvalid = v
	setStatus(v and "Accumulation ON" or "Accumulation OFF", v and N.cyan or N.orange)
	saveSettings()
end))

-- LOG (dernières lignes de statut)
section(pageRedeem, "LOG")
local logCard = glassCard(pageRedeem, 70)
logCard.LayoutOrder = 10
local logList = mk("TextLabel", {
	Position = UDim2.fromOffset(8, 4),
	Size = UDim2.new(1, -16, 1, -8),
	BackgroundTransparency = 1,
	Font = Enum.Font.Code,
	TextSize = 9,
	TextColor3 = N.dim,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextWrapped = true,
	Text = "",
}, logCard)

local logLines = {}
profLog = function(text, color)
	table.insert(logLines, tostring(text))
	if #logLines > 6 then table.remove(logLines, 1) end
	logList.Text = table.concat(logLines, "\n")
	if color then logList.TextColor3 = color end
end

----------------------------------------------------------------------
-- PAGE BOOST (FPS)
----------------------------------------------------------------------
section(pageBoost, "FPS & RÉSEAU")
local _, fpsEv, fpsSet, fpsGet = toggle(pageBoost, "FPS Boost",  persist.fps,  1)
local _, pingEv, pingSet, pingGet = toggle(pageBoost, "Ping Boost", persist.ping, 2)
local _, lagEv,  lagSet,  lagGet  = toggle(pageBoost, "Anti-Lag",  persist.lag,  3)
local _, r3Ev,   r3Set,   r3Get   = toggle(pageBoost, "3D OFF",    false,         4)
local _, hideEvEv, hideEvSet, hideEvGet = toggle(pageBoost, "Hide Everything", persist.fx.plots == true, 5)

local pingOn = persist.ping
local lagOn  = persist.lag
local r3Off  = false

track(fpsEv:Connect(function(v)
	persist.fps = v
	local ok = PERF.setFpsBoost(v)
	if v and not ok then setStatus("FPS boost actif (FFlags non sup.)", N.orange) end
	saveSettings()
end))
track(pingEv:Connect(function(v)
	pingOn = v
	local ok = PERF.applyFlags(pingFlags, v)
	if v and not ok then pingSet(false); pingOn = false; setStatus("Ping boost non supporté", N.rose) end
	persist.ping = pingOn
	saveSettings()
end))
track(lagEv:Connect(function(v)
	lagOn = v
	PERF.setExtremeAntiLag(v)
	pcall(PERF.extremePlus, v)
	persist.lag = v
	setStatus(v and "Anti-Lag extrême ON" or "Anti-Lag OFF", v and N.cyan or N.dim)
	saveSettings()
end))
track(r3Ev:Connect(function(v)
	local ok = PERF.set3dRender(v)
	if ok then
		r3Off = v
		setStatus(v and "3D OFF (écran noir)" or "3D rétabli", v and N.orange or N.cyan)
	else
		r3Set(false); setStatus("3D OFF non supporté", N.rose)
	end
end))
track(hideEvEv:Connect(function(v)
	PERF.hideEverything.set(v)
	persist.fx.plots = v or nil
	setStatus(v and "Hide Everything ON" or "Hide Everything OFF", v and N.cyan or N.dim)
	saveSettings()
end))

----------------------------------------------------------------------
-- PAGE FONCTIONNALITY (jump + wave speed)
----------------------------------------------------------------------
section(pageFx, "FONCTIONNALITY")
local _, jumpEv, jumpSet, jumpGet = toggle(pageFx, "Unlimited Jumps", persist.jumpsOn, 1)
track(jumpEv:Connect(function(v)
	persist.jumpsOn = v
	setJumps(v)
	setStatus(v and "Jumps ON" or "Jumps OFF", v and N.cyan or N.dim)
	saveSettings()
end))

section(pageFx, "SPEED")
local _, speedEv, speedSet2 = toggle(pageFx, "Waverider Speed", false, 10)
local _, spvEv, spvSet, spvGet = stepper(pageFx, "Vitesse", persist.speedVal, 10, 300, 11)
track(speedEv:Connect(function(v)
	if v then
		local bp = lp:FindFirstChildOfClass("Backpack")
		local hasWav = (bp and bp:FindFirstChild("Waverider")) or (lp.Character and lp.Character:FindFirstChild("Waverider"))
		if not hasWav then
			speedSet2(false)
			setStatus("Speed : Waverider introuvable", N.rose)
			return
		end
	end
	persist.speedOn = v
	speed.value = persist.speedVal
	setSpeed(v)
	setStatus(v and ("Speed : " .. persist.speedVal) or "Speed OFF", v and N.cyan or N.dim)
	saveSettings()
end))
track(spvEv:Connect(function(v)
	persist.speedVal = v
	speed.value = v
	saveSettings()
end))

----------------------------------------------------------------------
-- NAVIGATION ONGLETS
----------------------------------------------------------------------
local currentPage = "redeem"

local function switchPage(name)
	currentPage = name
	for id, page in pairs(pages) do
		page.Visible = id == name
	end
	for id, btn2 in pairs(tabBtns) do
		local on = id == name
		btn2.TextColor3 = on and N.cyan or N.dim
		tabMarks[id].Visible = on
	end
	task.defer(function()
		local h = PAGE_Y + 8
		for id, page in pairs(pages) do
			if page.Visible then h += page.AbsoluteSize.Y end
		end
		main.Size = UDim2.fromOffset(WIDTH, h)
	end)
end

for _, def in ipairs(tabDefs) do
	track(tabBtns[def.id].Activated:Connect(function()
		switchPage(def.id)
	end))
end

task.defer(function()
	switchPage("redeem")
end)

----------------------------------------------------------------------
-- ACTIONS
----------------------------------------------------------------------
track(startBtn.Activated:Connect(function()
	if listening then
		session.parts = {}; session.accumulating = false; session.currentCode = ""
		stopListening()
		setStatus("Arrêté", N.dim)
	else
		startListening()
	end
	refreshCount()
	refreshStart()
end))

----------------------------------------------------------------------
-- COLLAPSE / FERMER
----------------------------------------------------------------------
local collapsed = false
local function applyCollapse()
	if collapsed then
		tw(main, 0.25, {Size = UDim2.fromOffset(WIDTH, HEAD_H)})
		tabBar.Visible = false
		statusBar.Visible = false
		for _, p in pairs(pages) do p.Visible = false end
	else
		tabBar.Visible = true
		statusBar.Visible = true
		switchPage(currentPage)
	end
end

track(minBtn.Activated:Connect(function()
	collapsed = not collapsed
	applyCollapse()
end))

local function destroy()
	session.token = (session.token or 0) + 1
	listening = false
	if listenConn then pcall(function() listenConn:Disconnect() end) end
	pcall(PERF.shutdown)
	if r3Off then pcall(PERF.set3dRender, false) end
	for _, c in ipairs(conns) do if c then pcall(c.Disconnect, c) end end
	gui:Destroy()
end
track(closeBtn.Activated:Connect(destroy))
env.VOIDSNIPE_DESTROY = destroy

----------------------------------------------------------------------
-- DRAG
----------------------------------------------------------------------
do
	local dragging, dragStart, startAbs = false, nil, nil
	track(header.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = i.Position
			startAbs = main.AbsolutePosition
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
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

----------------------------------------------------------------------
-- DÉMARRAGE
----------------------------------------------------------------------
task.defer(function()
	if persist.fps  then PERF.setFpsBoost(true); fpsSet(true) end
	if persist.ping then
		local ok = PERF.applyFlags(pingFlags, true)
		pingSet(ok); pingOn = ok; persist.ping = ok
	end
	if persist.lag then
		PERF.setExtremeAntiLag(true); pcall(PERF.extremePlus, true); lagSet(true)
	end
	if persist.fx.plots then PERF.hideEverything.set(true); hideEvSet(true) end
	if persist.jumpsOn then setJumps(true); jumpSet(true) end
	if persist.speedOn then
		local bp = lp:FindFirstChildOfClass("Backpack")
		local hasWav = (bp and bp:FindFirstChild("Waverider")) or (lp.Character and lp.Character:FindFirstChild("Waverider"))
		if hasWav then
			speed.value = persist.speedVal; setSpeed(true); speedSet2(true)
		else
			persist.speedOn = false
		end
	end

	local ok, top = pcall(function() return playerGui:FindFirstChild("TopNotification") end)
	topNotification = ok and top or nil
	if not topNotification then
		local top2 = playerGui:WaitForChild("TopNotification", 10)
		if top2 then
			topNotification = top2:FindFirstChild("TopNotification") or top2
		end
	elseif topNotification:IsA("ScreenGui") then
		topNotification = topNotification:FindFirstChild("TopNotification") or topNotification
	end

	refreshCount()
	refreshStart()
	setStatus("Prêt. Appuie sur START", N.dim)
	profLog("Prêt — Submit After : " .. cfg.parts .. ", délai : " .. cfg.submitDelayMin .. "-" .. cfg.submitDelayMax .. "s")

	if persist.autoStart then
		startListening()
		refreshStart()
	end
end)
