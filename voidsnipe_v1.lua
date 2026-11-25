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
	parts        = 3,
	spam         = true,
	spamSeconds  = 5,
	spamInterval = 0.05,
	stopOnInvalid = false,  -- sur invalid on accumule toujours
	growOnInvalid = true,
	fastListen   = true,
	directHook   = false,
	webhook      = "",
	staleSeconds = 20,
}

local persist = {
	fps = false, ping = false, lag = false,
	fx = {}, code = "",
	jumpsOn = false, speedOn = false, speedVal = 140,
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
			cfg.spam         = type(c.spam) == "boolean" and c.spam or cfg.spam
			cfg.spamSeconds  = clampNum(c.spamSeconds, 1, 30) or cfg.spamSeconds
			local ms = clampNum(c.spamMs, 10, 1000)
			if ms then cfg.spamInterval = ms / 1000 end
			if type(c.webhook) == "string" and c.webhook ~= "" then cfg.webhook = c.webhook end
		end
		local u = data.ui
		if type(u) == "table" then
			persist.fps     = u.fps == true
			persist.ping    = u.ping == true
			persist.lag     = u.lag == true
			persist.jumpsOn = u.jumpsOn == true
			persist.speedOn = u.speedOn == true
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
					spam         = cfg.spam,
					spamSeconds  = cfg.spamSeconds,
					spamMs       = math.floor(cfg.spamInterval * 1000 + 0.5),
					webhook      = cfg.webhook,
				},
				ui = {
					fps = persist.fps, ping = persist.ping, lag = persist.lag,
					fx = persist.fx, code = persist.code,
					jumpsOn = persist.jumpsOn, speedOn = persist.speedOn, speedVal = persist.speedVal,
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
	bg       = Color3.fromRGB(8, 8, 12),
	glass    = Color3.fromRGB(18, 20, 28),
	glass2   = Color3.fromRGB(26, 28, 40),
	cyan     = Color3.fromRGB(0, 255, 200),
	cyanDim  = Color3.fromRGB(0, 140, 110),
	rose     = Color3.fromRGB(255, 50, 150),
	roseDim  = Color3.fromRGB(140, 20, 80),
	orange   = Color3.fromRGB(255, 160, 40),
	text     = Color3.fromRGB(220, 225, 240),
	dim      = Color3.fromRGB(100, 108, 130),
	border   = Color3.fromRGB(50, 55, 75),
	borderC  = Color3.fromRGB(0, 180, 140),
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

local function set3dRender(off)
	return (pcall(function() RunService:Set3dRenderingEnabled(not off) end))
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
		if on then
			local tk = c.token
			c.conn = workspace.DescendantAdded:Connect(function(d)
				if c.on and matches(d) then pcall(apply, c, d) end
			end)
			task.spawn(function()
				local n = 0
				for _, d in ipairs(workspace:GetDescendants()) do
					if not c.on or tk ~= c.token then return end
					if matches(d) then pcall(apply, c, d) end
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

local function fireSignal(sig)
	local ok, list = pcall(getconnections, sig)
	if not ok or #list == 0 then return false end
	if typeof(firesignal) == "function" and pcall(firesignal, sig) then return true end
	local any = false
	for _, c in ipairs(list) do
		any = pcall(function() c:Fire() end) or any
	end
	return any
end

-- Redeem avec timing humain :
-- 1) attendre 5ms
-- 2) écrire le code dans la TextBox caractère par caractère très vite
-- 3) attendre 5ms
-- 4) cliquer Confirm
local function clickRedeem(code)
	code = tostring(code or "")
	local box, confirm = getCodesUI()
	if not box or not confirm then return false end

	-- 5ms avant de commencer à écrire
	task.wait(0.005)

	box.ClearTextOnFocus = false
	-- écriture progressive ultra rapide (simule humain)
	box.Text = ""
	for i = 1, #code do
		box.Text = code:sub(1, i)
		task.wait(0.001) -- 1ms entre chaque caractère
	end

	-- 5ms avant le clic
	task.wait(0.005)

	if typeof(getconnections) ~= "function" then
		return false
	end
	return fireSignal(confirm.Activated) or fireSignal(confirm.MouseButton1Click)
end

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
local setStatus, refreshStart, startSpam, startListening, stopListening, refreshUIBadge

----------------------------------------------------------------------
-- LOG
----------------------------------------------------------------------
local profLog = function() end

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
-- SPAM / REDEEM
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
			-- Accumulation infinie : on garde les parties et attend la suivante
			conclude()
			session.accumulating = true
			session.lastPart = tick()
			local n = #session.parts
			setStatus(string.format("Invalid → %d partie(s) gardées, j'attends...", n), N.orange)
			profLog("⚠️ Invalid : " .. code .. " (" .. n .. " parties gardées)", N.orange)
			sendWebhook("invalid", code, text, ms)
			-- on remet le code dans la textbox pour montrer visuellement
			task.spawn(function()
				local box = getCodesUI()
				if box then
					box.ClearTextOnFocus = false
					box.Text = code
				end
			end)
			-- on reste en écoute (stopListening pas appelé)
			refreshStart()
		end
	end

	-- Envoie initial + spam si activé
	local spamming = cfg.spam
	local t0 = os.clock()

	if spamming then
		setStatus(string.format("Envoi spam : %s (%dms)", code, math.floor(cfg.spamInterval * 1000 + 0.5)), N.orange)
	else
		setStatus("Envoi : " .. code, N.orange)
	end

	stopFeedback = watchFeedback(onFeedback)

	-- Premier envoi
	task.spawn(function()
		clickRedeem(code)
	end)

	if spamming then
		task.spawn(function()
			local limit = math.max(1, cfg.spamSeconds)
			local step  = math.max(cfg.spamInterval, 0.01)
			local acc   = 0
			while not done and token == session.token and os.clock() - t0 < limit do
				acc += task.wait()
				if acc >= step then
					acc = 0
					if not done and token == session.token then
						task.spawn(function() clickRedeem(code) end)
					end
				end
			end
			if done or token ~= session.token then
				stopFeedback()
				return
			end
			local graceUntil = os.clock() + 2
			while not done and token == session.token and os.clock() < graceUntil do
				task.wait(0.05)
			end
			if done or token ~= session.token then return end
			conclude()
			setStatus(string.format("Spam terminé (%ds) sans résultat", limit), N.orange)
			refreshStart()
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
	local recent = tick() <= ignoreUntil or tick() - lastAttemptAt < 15
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
	if text == lastText and now - lastTextAt < 0.5 then return end
	lastText, lastTextAt = text, now

	if now - session.lastPart > cfg.staleSeconds and not session.accumulating then
		session.parts = {}
	end
	session.lastPart = now

	table.insert(session.parts, text)
	local n = #session.parts

	if session.accumulating then
		-- Mode accumulation : chaque nouvelle partie déclenche immédiatement un envoi
		local assembled = table.concat(session.parts)
		session.accumulating = false -- sera remis à true si invalid
		setStatus(string.format("Partie %d (accum) : %s", n, assembled), N.orange)
		startSpam(assembled)
	elseif n >= cfg.parts then
		-- Code complet atteint
		local assembled = table.concat(session.parts)
		setStatus(string.format("Code complet : %s", assembled), N.orange)
		startSpam(assembled)
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
	task.delay(0.25, function()
		if not done then check(); finish() end
	end)
end

-- Écoute rapide
local fastConn, fastLabels = nil, setmetatable({}, {__mode="k"})
local function startFast()
	if fastConn or not cfg.fastListen or not topNotification then return end
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
local function stopFast()
	if fastConn then fastConn:Disconnect(); fastConn = nil end
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
-- GUI VOIDSNIPE — Glassmorphism + Neon
----------------------------------------------------------------------
local WIDTH  = 320
local HEIGHT = 520
local HEAD_H = 44
local TAB_H  = 40
local STATUS_H = 26

local gui = mk("ScreenGui", {
	Name = "VOIDSNIPE_GUI",
	ResetOnSpawn = false,
	DisplayOrder = 999,
	IgnoreGuiInset = true,
}, (typeof(gethui) == "function" and gethui()) or playerGui)

local main = mk("Frame", {
	Size = UDim2.fromOffset(WIDTH, HEIGHT),
	Position = UDim2.new(0.5, -WIDTH/2, 0, 48),
	BackgroundColor3 = N.bg,
	BorderSizePixel = 0,
	ClipsDescendants = true,
}, gui)
corner(main, 16)

-- Bordure principale cyan animée
local mainStroke = uistroke(main, N.borderC, 1.5)
task.spawn(function()
	while main.Parent do
		tw(mainStroke, 2, {Color = N.rose})
		task.wait(2.1)
		tw(mainStroke, 2, {Color = N.cyan})
		task.wait(2.1)
	end
end)

-- Fond glass subtle
mk("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 14, 20)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 12)),
	}),
	Rotation = 135,
}, main)

-- Lueur en haut (glow)
local glow = mk("Frame", {
	Size = UDim2.new(1, 0, 0, 80),
	BackgroundColor3 = N.cyan,
	BackgroundTransparency = 0.92,
	BorderSizePixel = 0,
}, main)
corner(glow, 16)
mk("UIGradient", {
	Rotation = 90,
	Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)}),
}, glow)

----------------------------------------------------------------------
-- HEADER
----------------------------------------------------------------------
local header = mk("Frame", {
	Size = UDim2.new(1, 0, 0, HEAD_H),
	BackgroundColor3 = N.glass,
	BackgroundTransparency = 0.5,
	BorderSizePixel = 0,
}, main)
mk("Frame", {
	Position = UDim2.new(0, 0, 1, -1),
	Size = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = N.borderC,
	BorderSizePixel = 0,
}, header)

local titleLabel = mk("TextLabel", {
	Position = UDim2.fromOffset(16, 4),
	Size = UDim2.fromOffset(140, 22),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBlack,
	TextSize = 18,
	TextColor3 = N.cyan,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "VOIDSNIPE",
}, header)
mk("UIGradient", {
	Color = ColorSequence.new(N.cyan, N.rose),
	Rotation = 0,
}, titleLabel)

mk("TextLabel", {
	Position = UDim2.fromOffset(16, 26),
	Size = UDim2.fromOffset(60, 14),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	TextSize = 10,
	TextColor3 = N.dim,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "v1.0  •  Click",
}, header)

-- Stats ping/fps
local statsLabel = mk("TextLabel", {
	Position = UDim2.fromOffset(WIDTH - 130, 14),
	Size = UDim2.fromOffset(100, 16),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	TextSize = 11,
	TextColor3 = N.dim,
	TextXAlignment = Enum.TextXAlignment.Right,
	Text = "--ms  --fps",
}, header)

local closeBtn = mk("TextButton", {
	Position = UDim2.fromOffset(WIDTH - 26, 10),
	Size = UDim2.fromOffset(20, 20),
	BackgroundColor3 = Color3.fromRGB(50, 20, 35),
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	TextColor3 = N.rose,
	Text = "✕",
}, header)
corner(closeBtn, 6)

local minBtn = mk("TextButton", {
	Position = UDim2.fromOffset(WIDTH - 50, 10),
	Size = UDim2.fromOffset(20, 20),
	BackgroundColor3 = N.glass2,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	TextColor3 = N.dim,
	Text = "−",
}, header)
corner(minBtn, 6)

-- Stats update
task.spawn(function()
	local Stats = game:GetService("Stats")
	local frames = 0
	track(RunService.Heartbeat:Connect(function() frames += 1 end))
	local item
	pcall(function() item = Stats.Network.ServerStatsItem["Data Ping"] end)
	local last = os.clock()
	while gui.Parent do
		task.wait(0.5)
		local now = os.clock()
		local f = math.floor(frames / (now - last) + 0.5)
		frames, last = 0, now
		local ping = 0
		if item then local ok, v = pcall(item.GetValue, item); ping = ok and math.floor(v+0.5) or 0 end
		statsLabel.Text = string.format("%dms  %dfps", ping, f)
		statsLabel.TextColor3 = ping <= 90 and N.cyan or ping <= 160 and N.orange or N.rose
	end
end)

----------------------------------------------------------------------
-- ONGLETS (en bas)
----------------------------------------------------------------------
local TAB_Y = HEIGHT - TAB_H
local tabBar = mk("Frame", {
	Position = UDim2.fromOffset(0, TAB_Y),
	Size = UDim2.fromOffset(WIDTH, TAB_H),
	BackgroundColor3 = N.glass,
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
}, main)
mk("Frame", {
	Position = UDim2.new(0,0,0,0),
	Size = UDim2.new(1,0,0,1),
	BackgroundColor3 = N.borderC,
	BorderSizePixel = 0,
}, tabBar)

local tabDefs = {
	{id="redeem", label="⚡ REDEEM"},
	{id="boost",  label="🚀 BOOST"},
	{id="fx",     label="✨ FX"},
}
local tabBtns = {}
local tabMarks = {}
for i, def in ipairs(tabDefs) do
	local b = mk("TextButton", {
		Position = UDim2.new((i-1)/#tabDefs, 0, 0, 0),
		Size = UDim2.new(1/#tabDefs, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = N.dim,
		Text = def.label,
	}, tabBar)
	local mark = mk("Frame", {
		Position = UDim2.new(0.1, 0, 1, -2),
		Size = UDim2.new(0.8, 0, 0, 2),
		BackgroundColor3 = N.cyan,
		BorderSizePixel = 0,
		Visible = false,
	}, b)
	corner(mark, 1)
	tabBtns[def.id]  = b
	tabMarks[def.id] = mark
end

----------------------------------------------------------------------
-- PAGES (ScrollingFrame)
----------------------------------------------------------------------
local PAGE_Y = HEAD_H
local PAGE_H = TAB_Y - HEAD_H - STATUS_H - 8

local pages = {}
local function newPage()
	local p = mk("ScrollingFrame", {
		Position = UDim2.fromOffset(8, PAGE_Y + 4),
		Size = UDim2.fromOffset(WIDTH - 16, PAGE_H),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = N.cyanDim,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Visible = false,
	}, main)
	mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,6)}, p)
	mk("UIPadding", {PaddingTop=UDim.new(0,4), PaddingLeft=UDim.new(0,2), PaddingRight=UDim.new(0,4)}, p)
	return p
end
local pageRedeem = newPage()
local pageBoost  = newPage()
local pageFx     = newPage()
pages.redeem = pageRedeem
pages.boost  = pageBoost
pages.fx     = pageFx

----------------------------------------------------------------------
-- BARRE STATUT
----------------------------------------------------------------------
local statusBar = mk("Frame", {
	Position = UDim2.fromOffset(8, TAB_Y - STATUS_H - 4),
	Size = UDim2.fromOffset(WIDTH - 16, STATUS_H),
	BackgroundColor3 = N.glass2,
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
}, main)
corner(statusBar, 8)
local statusDot = mk("Frame", {
	Position = UDim2.fromOffset(10, 9),
	Size = UDim2.fromOffset(8, 8),
	BackgroundColor3 = N.dim,
	BorderSizePixel = 0,
}, statusBar)
corner(statusDot, 4)
local statusLabel = mk("TextLabel", {
	Position = UDim2.fromOffset(26, 0),
	Size = UDim2.fromOffset(WIDTH - 42, STATUS_H),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	TextSize = 11,
	TextTruncate = Enum.TextTruncate.AtEnd,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = N.dim,
	Text = "Init...",
}, statusBar)

local uiLast = 0
setStatus = function(text, color)
	local col = color or N.text
	statusLabel.Text = tostring(text)
	statusLabel.TextColor3 = col
	statusDot.BackgroundColor3 = col
	uiLast = os.clock()
end

----------------------------------------------------------------------
-- COMPOSANTS GUI
----------------------------------------------------------------------
local function glassCard(parent, h)
	local f = mk("Frame", {
		Size = UDim2.new(1, -4, 0, h),
		BackgroundColor3 = N.glass,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		LayoutOrder = 0,
	}, parent)
	corner(f, 10)
	uistroke(f, N.border, 1)
	return f
end

local function label(parent, text, x, y, w, h, fs, col, font, xa)
	return mk("TextLabel", {
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(w, h),
		BackgroundTransparency = 1,
		Font = font or Enum.Font.GothamMedium,
		TextSize = fs or 11,
		TextColor3 = col or N.text,
		TextXAlignment = xa or Enum.TextXAlignment.Left,
		Text = text,
	}, parent)
end

local function neonBtn(parent, text, x, y, w, h, col)
	col = col or N.glass2
	local b = mk("TextButton", {
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(w, h),
		BackgroundColor3 = col,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = N.text,
		Text = text,
	}, parent)
	corner(b, 8)
	local s = uistroke(b, N.border, 1)
	track(b.MouseEnter:Connect(function()
		tw(b, 0.15, {BackgroundTransparency = 0})
		tw(s, 0.15, {Color = N.cyan})
	end))
	track(b.MouseLeave:Connect(function()
		tw(b, 0.2, {BackgroundTransparency = 0.1})
		tw(s, 0.2, {Color = N.border})
	end))
	return b, s
end

-- Toggle glassmorphism
local function toggle(parent, labelText, initOn, lo)
	lo = lo or 0
	local ROW_H = 36
	local card = glassCard(parent, ROW_H)
	card.LayoutOrder = lo

	mk("TextLabel", {
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.fromOffset(170, ROW_H),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = N.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = labelText,
	}, card)

	local rail = mk("Frame", {
		Position = UDim2.fromOffset(card.Size.X.Offset - 46, 11),
		Size = UDim2.fromOffset(32, 14),
		BackgroundColor3 = N.glass2,
		BorderSizePixel = 0,
	}, card)
	corner(rail, 7)
	uistroke(rail, N.border, 1)

	local knob = mk("Frame", {
		Position = UDim2.fromOffset(2, 2),
		Size = UDim2.fromOffset(10, 10),
		BackgroundColor3 = N.dim,
		BorderSizePixel = 0,
	}, rail)
	corner(knob, 5)

	local on = initOn or false
	local function refresh()
		tw(rail, 0.2, {BackgroundColor3 = on and Color3.fromRGB(0, 60, 50) or N.glass2})
		tw(knob, 0.2, {
			Position = on and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2),
			BackgroundColor3 = on and N.cyan or N.dim,
		})
	end
	refresh()

	local btn2 = mk("TextButton", {
		Size = UDim2.new(1,0,1,0),
		BackgroundTransparency = 1,
		Text = "",
		BorderSizePixel = 0,
	}, card)

	local changed = Instance.new("BindableEvent")
	track(btn2.Activated:Connect(function()
		on = not on
		refresh()
		changed:Fire(on)
	end))

	local function setState(v)
		on = v; refresh()
	end
	local function getState() return on end

	return card, changed.Event, setState, getState
end

-- Stepper
local function stepper(parent, labelText, val, lo2, hi, lo_order)
	lo_order = lo_order or 0
	local ROW_H = 36
	local card = glassCard(parent, ROW_H)
	card.LayoutOrder = lo_order

	local minus = mk("TextButton", {
		Position = UDim2.fromOffset(6, 6),
		Size = UDim2.fromOffset(24, 24),
		BackgroundColor3 = N.glass2,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = N.cyan,
		Text = "−",
	}, card)
	corner(minus, 6)

	local valLbl = mk("TextLabel", {
		Position = UDim2.fromOffset(36, 0),
		Size = UDim2.fromOffset(140, ROW_H),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = N.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, card)

	local plus = mk("TextButton", {
		Position = UDim2.fromOffset(card.Size.X.Offset - 30, 6),
		Size = UDim2.fromOffset(24, 24),
		BackgroundColor3 = N.glass2,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = N.cyan,
		Text = "+",
	}, card)
	corner(plus, 6)

	local current = val
	local function render()
		valLbl.Text = string.format('[%s]  %s', labelText, tostring(current))
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

-- Section titre
local sectionOrder = 0
local function section(parent, text)
	sectionOrder += 1
	local f = mk("Frame", {
		Size = UDim2.new(1, -4, 0, 18),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = sectionOrder,
	}, parent)
	mk("TextLabel", {
		Size = UDim2.new(1,0,1,0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBlack,
		TextSize = 10,
		TextColor3 = N.cyanDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "▸ " .. text,
	}, f)
	return f
end

----------------------------------------------------------------------
-- PAGE REDEEM
----------------------------------------------------------------------
sectionOrder = 0

-- START/STOP
local startCard = glassCard(pageRedeem, 46)
startCard.LayoutOrder = 1
local startBtn = mk("TextButton", {
	Position = UDim2.fromOffset(6, 6),
	Size = UDim2.fromOffset(290, 34),
	BackgroundColor3 = Color3.fromRGB(0, 50, 40),
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Font = Enum.Font.GothamBlack,
	TextSize = 15,
	TextColor3 = N.cyan,
	Text = "▶  START LISTEN",
}, startCard)
corner(startBtn, 8)
uistroke(startBtn, N.cyanDim, 1.5)

refreshStart = function()
	if listening then
		startBtn.Text = "■  STOP"
		startBtn.BackgroundColor3 = Color3.fromRGB(50, 10, 25)
		startBtn.TextColor3 = N.rose
	else
		startBtn.Text = "▶  START LISTEN"
		startBtn.BackgroundColor3 = Color3.fromRGB(0, 50, 40)
		startBtn.TextColor3 = N.cyan
	end
end

-- Badge UI
local badgeCard = glassCard(pageRedeem, 28)
badgeCard.LayoutOrder = 2
local badgeLabel = mk("TextLabel", {
	Position = UDim2.fromOffset(10, 0),
	Size = UDim2.fromOffset(280, 28),
	BackgroundTransparency = 1,
	RichText = true,
	Font = Enum.Font.GothamMedium,
	TextSize = 11,
	TextColor3 = N.text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "État UI : ...",
}, badgeCard)

refreshUIBadge = function()
	local box, confirm = getCodesUI()
	local ready = box ~= nil and confirm ~= nil
	if ready then
		badgeLabel.Text = string.format('<font color="rgb(100,120,130)">UI</font>  <font color="rgb(0,220,170)">✓ Prête</font>')
	else
		badgeLabel.Text = string.format('<font color="rgb(100,120,130)">UI</font>  <font color="rgb(220,60,120)">✗ Non prête</font>')
	end
end
task.defer(refreshUIBadge)

-- Parts stepper
section(pageRedeem, "ASSEMBLAGE")
local partsCard, partsEv, partsSet, partsGet = stepper(pageRedeem, "Parts", cfg.parts, 1, 6, 10)
track(partsEv:Connect(function(v) cfg.parts = v; setStatus("Parts : " .. v, N.cyan) end))

-- Code manuel
section(pageRedeem, "CODE MANUEL")
local manualCard = glassCard(pageRedeem, 36)
manualCard.LayoutOrder = 20
local codeBox = mk("TextBox", {
	Position = UDim2.fromOffset(8, 6),
	Size = UDim2.fromOffset(216, 24),
	BackgroundColor3 = Color3.fromRGB(14, 16, 24),
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	PlaceholderText = "Code manuel...",
	PlaceholderColor3 = N.dim,
	Text = tostring(persist.code or ""),
	Font = Enum.Font.GothamMedium,
	TextSize = 12,
	TextColor3 = N.text,
	TextXAlignment = Enum.TextXAlignment.Left,
}, manualCard)
corner(codeBox, 6)
mk("UIPadding", {PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8)}, codeBox)
local codeStroke = uistroke(codeBox, N.border, 1)
track(codeBox.Focused:Connect(function() tw(codeStroke, 0.2, {Color=N.cyan}) end))
track(codeBox.FocusLost:Connect(function()
	tw(codeStroke, 0.2, {Color=N.border})
	persist.code = trim(codeBox.Text); saveSettings()
end))

local goBtn = mk("TextButton", {
	Position = UDim2.fromOffset(230, 6),
	Size = UDim2.fromOffset(60, 24),
	BackgroundColor3 = Color3.fromRGB(0, 50, 40),
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	TextColor3 = N.cyan,
	Text = "GO",
}, manualCard)
corner(goBtn, 6)

-- Spam
section(pageRedeem, "SPAM")
local _, spamEv, spamSet, spamGet = toggle(pageRedeem, "Spam Redeem", cfg.spam, 30)
track(spamEv:Connect(function(v)
	cfg.spam = v
	setStatus(v and "Spam ON" or "Spam OFF", v and N.cyan or N.dim)
	saveSettings()
end))

local MS_STEPS = {10,20,30,40,50,60,80,100,150,200,300,500,1000}
local function nearestStep(ms)
	local best, bestDiff = 1, math.huge
	for i, v in ipairs(MS_STEPS) do
		local d = math.abs(v - ms)
		if d < bestDiff then best, bestDiff = i, d end
	end
	return best
end
local curMs = math.floor(cfg.spamInterval * 1000 + 0.5)
local _, delayEv, delaySet, delayGet = stepper(pageRedeem, "Délai ms", curMs, 10, 1000, 31)
track(delayEv:Connect(function(v)
	local idx = nearestStep(v)
	local ms = MS_STEPS[math.clamp(idx, 1, #MS_STEPS)]
	cfg.spamInterval = ms / 1000
	delaySet(ms)
	saveSettings()
end))

local _, durEv, durSet = stepper(pageRedeem, "Durée s", cfg.spamSeconds, 1, 30, 32)
track(durEv:Connect(function(v) cfg.spamSeconds = v; saveSettings() end))

-- Invalid accumulate
section(pageRedeem, "INVALID")
do
	local _, invEv, invSet = toggle(pageRedeem, "Invalid → Accumule", cfg.growOnInvalid, 40)
	track(invEv:Connect(function(v)
		cfg.growOnInvalid = v
		setStatus(v and "Accumulation ON (garde les parties sur invalid)" or "Accumulation OFF", v and N.cyan or N.orange)
		saveSettings()
	end))
end

-- Webhook
section(pageRedeem, "WEBHOOK DISCORD")
local whCard = glassCard(pageRedeem, 36)
whCard.LayoutOrder = 50
local whBox = mk("TextBox", {
	Position = UDim2.fromOffset(8, 6),
	Size = UDim2.fromOffset(216, 24),
	BackgroundColor3 = Color3.fromRGB(14, 16, 24),
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	PlaceholderText = "discord.com/api/webhooks/...",
	PlaceholderColor3 = N.dim,
	Text = tostring(cfg.webhook or ""),
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextColor3 = N.text,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
}, whCard)
corner(whBox, 6)
mk("UIPadding", {PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8)}, whBox)
local whStroke = uistroke(whBox, N.border, 1)
track(whBox.Focused:Connect(function() tw(whStroke, 0.2, {Color=N.cyan}) end))
track(whBox.FocusLost:Connect(function()
	tw(whStroke, 0.2, {Color=N.border})
	local v = trim(whBox.Text)
	if v ~= "" then cfg.webhook = v; saveSettings() end
end))
local whTestBtn = mk("TextButton", {
	Position = UDim2.fromOffset(230, 6),
	Size = UDim2.fromOffset(60, 24),
	BackgroundColor3 = N.glass2,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	TextColor3 = N.dim,
	Text = "Test",
}, whCard)
corner(whTestBtn, 6)

----------------------------------------------------------------------
-- PAGE BOOST
----------------------------------------------------------------------
section(pageBoost, "FPS & RÉSEAU")
local _, fpsEv, fpsSet, fpsGet = toggle(pageBoost, "FPS Boost",  persist.fps,  1)
local _, pingEv, pingSet, pingGet = toggle(pageBoost, "Ping Boost", persist.ping, 2)
local _, lagEv,  lagSet,  lagGet  = toggle(pageBoost, "Anti-Lag",  persist.lag,  3)
local _, r3Ev,   r3Set,   r3Get   = toggle(pageBoost, "3D OFF",    false,         4)

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

----------------------------------------------------------------------
-- PAGE FX
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

section(pageFx, "EFFETS")
local fxRows = {
	{"Sons",       "sound",     20},
	{"Particules", "particles", 21},
	{"Lumières",   "lights",    22},
	{"Textures",   "textures",  23},
}
local fxSetters = {}
for _, row in ipairs(fxRows) do
	local initOn = persist.fx[row[2]] or false
	local _, ev, setter = toggle(pageFx, row[1], initOn, row[3])
	fxSetters[row[2]] = setter
	local cat = PERF.fx[row[2]]
	track(ev:Connect(function(v)
		cat.set(v)
		persist.fx[row[2]] = v
		setStatus(row[1] .. (v and " : ON" or " : OFF"), v and N.cyan or N.dim)
		saveSettings()
	end))
end

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
	refreshStart()
end))

track(goBtn.Activated:Connect(function()
	local code = trim(codeBox.Text):upper()
	if code == "" then setStatus("Entre un code", N.rose); return end
	persist.code = code; saveSettings()
	startSpam(code)
end))

track(whTestBtn.Activated:Connect(function()
	local v = trim(whBox.Text)
	if v ~= "" then cfg.webhook = v; saveSettings() end
	if not webhookReady() then
		setStatus("Webhook invalide", N.rose)
	elseif not httpRequest then
		setStatus("Executor sans request()", N.rose)
	else
		sendWebhook("test", "TEST", "Webhook OK", 0)
		setStatus("Test webhook envoyé ✓", N.cyan)
	end
end))

----------------------------------------------------------------------
-- COLLAPSE / FERMER
----------------------------------------------------------------------
local collapsed = false
local FULL_H = HEIGHT
local function applyCollapse()
	local h = collapsed and HEAD_H or FULL_H
	tw(main, 0.3, {Size = UDim2.fromOffset(WIDTH, h)})
	for _, p in pairs(pages) do p.Visible = not collapsed and p.Visible end
	tabBar.Visible = not collapsed
	statusBar.Visible = not collapsed
end

track(minBtn.Activated:Connect(function()
	collapsed = not collapsed
	applyCollapse()
	if not collapsed then switchPage(currentPage) end
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
-- ANIMATION D'ENTRÉE
----------------------------------------------------------------------
main.Position = UDim2.new(0.5, -WIDTH/2, 0, -HEIGHT)
tw(main, 0.5, {Position = UDim2.new(0.5, -WIDTH/2, 0, 48)})

----------------------------------------------------------------------
-- DÉMARRAGE : réapplication des réglages + init UI
----------------------------------------------------------------------
task.defer(function()
	-- réapplique les boosts sauvegardés
	if persist.fps  then PERF.setFpsBoost(true); fpsSet(true) end
	if persist.ping then
		local ok = PERF.applyFlags(pingFlags, true)
		pingSet(ok); pingOn = ok; persist.ping = ok
	end
	if persist.lag then
		PERF.setExtremeAntiLag(true); pcall(PERF.extremePlus, true); lagSet(true)
	end
	for name, on in pairs(persist.fx) do
		if on and PERF.fx[name] and fxSetters[name] then
			PERF.fx[name].set(true); fxSetters[name](true)
		end
	end
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

	-- Init TopNotification
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

	-- Wait for Codes GUI
	task.spawn(function()
		playerGui:WaitForChild("Codes", 20)
		refreshUIBadge()
	end)

	setStatus("Prêt. Appuie sur START", N.cyan)
end)
