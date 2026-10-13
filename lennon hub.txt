-- ============================================
-- leaked by https://discord.gg/R6vnkNQNbP
-- LennonHub 

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
game:GetService("SoundService")
game:GetService("Debris")

local localPlayer = Players.LocalPlayer
local networking = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Networking")

local tbl = {
	AskFieldEggSnapshot = networking:WaitForChild("RF/EggWorld/AskFieldEggSnapshot", 10),
	AskFieldEggCarry = networking:WaitForChild("RF/EggWorld/AskFieldEggCarry", 10),
	AskFieldEggDrop = networking:WaitForChild("RF/EggWorld/AskFieldEggDrop", 10),
	FieldEggCarry = networking:WaitForChild("RE/EggWorld/FieldEggCarry", 10),
}

local tbl2

tbl2 = {
	walk = function(arg, arg2)
		if not arg or not arg2 then
			return nil
		end
		local children = arg:GetChildren()

		while #children > 0 do
			local n = #children
			local v = children[n]
			children[n] = nil
			local children2 = v:GetChildren()

			for i = 1, #children2 do
				children[#children + 1] = children2[i]
			end

			if arg2(v) ~= true then
				continue
			end
			return v
		end

		return nil
	end,
	snapshot = function(arg)
		local tbl3 = {}

		tbl2.walk(arg, function(arg2)
			tbl3[#tbl3 + 1] = arg2
		end)

		return tbl3
	end,
}

tbl2.Integrity = {
	armed = false,
	restoring = false,
	connections = {},
	records = {},
	knownRootChildren = {},
	repairQueued = false,
	hardUntil = 0,
	hardRefreshAt = 0,
	tamperCount = 0,
	tamperWindow = 0,
	guardName = "LHVisualGuard_" .. tostring(math.random(100000, 999999)),
}

tbl2.integrityDisconnect = function()
	local integrity = tbl2.Integrity

	for i = 1, #integrity.connections do
		local v = integrity.connections[i]

		if v then
			pcall(function()
				v:Disconnect()
			end)
		end
	end

	table.clear(integrity.connections)

	pcall(function()
		RunService:UnbindFromRenderStep(integrity.guardName)
	end)
end

tbl2.integrityEscalate = function()
	local integrity = tbl2.Integrity
	local now = os.clock()

	if now - integrity.tamperWindow > 0.45 then
		integrity.tamperWindow = now
		integrity.tamperCount = 0
	end

	integrity.tamperCount = integrity.tamperCount + 1

	if integrity.tamperCount >= 3 then
		integrity.hardUntil = math.max(integrity.hardUntil, now + 2.5)
	end
end

tbl2.integrityRepairRecord = function(arg, arg2)
	local instance = arg and arg.instance
	if not instance then
		return
	end

	if arg.parent and instance.Parent ~= arg.parent then
		pcall(function()
			instance.Parent = arg.parent
		end)
	end

	if arg2 then
		local v = arg.properties[arg2]

		if v ~= nil then
			local ok, result = pcall(function()
				return instance[arg2]
			end)

			if ok and result ~= v then
				pcall(function()
					instance[arg2] = v
				end)
			end
		end

		return
	end

	for k, property in pairs(arg.properties) do
		local ok, result = pcall(function()
			return instance[k]
		end)

		if ok and result ~= property then
			pcall(function()
				instance[k] = property
			end)
		end
	end
end

tbl2.integrityQueueRepair = function()
	local integrity = tbl2.Integrity
	if not integrity.armed or integrity.restoring or integrity.repairQueued then
		return
	end
	integrity.repairQueued = true

	task.defer(function()
		integrity.repairQueued = false
		tbl2.integrityRepairAll()
	end)
end

tbl2.integrityRepairAll = function()
	local integrity = tbl2.Integrity
	if not integrity.armed or integrity.restoring then
		return
	end
	integrity.restoring = true

	for i = 1, #integrity.records do
		tbl2.integrityRepairRecord(integrity.records[i])
	end

	if integrity.refresh then
		pcall(integrity.refresh)
	end

	integrity.restoring = false
end

tbl2.integrityWatch = function(arg, arg2, parent)
	if not arg then
		return
	end
	local integrity = tbl2.Integrity
	local tbl3 = { instance = arg, properties = arg2, parent = parent }
	integrity.records[#integrity.records + 1] = tbl3

	if parent then
		integrity.connections[#integrity.connections + 1] = arg.AncestryChanged:Connect(function()
			if not integrity.armed or integrity.restoring or arg.Parent == parent then
				return
			end
			tbl2.integrityEscalate()
			integrity.restoring = true

			pcall(function()
				arg.Parent = parent
			end)

			integrity.restoring = false

			if arg.Parent ~= parent then
				tbl2.integrityQueueRepair()
			end
		end)
	end

	integrity.connections[#integrity.connections + 1] = arg.Changed:Connect(function(arg3)
		if not integrity.armed or integrity.restoring or arg2[arg3] == nil then
			return
		end

		local ok, result = pcall(function()
			return arg[arg3]
		end)

		if ok and result == arg2[arg3] then
			return
		end
		tbl2.integrityEscalate()
		integrity.restoring = true
		tbl2.integrityRepairRecord(tbl3, arg3)
		integrity.restoring = false
	end)
end

tbl2.integrityWatchComputed = function(arg, arg2, arg3)
	if not arg or not arg3 then
		return
	end
	local integrity = tbl2.Integrity
	local tbl3 = {}

	for i = 1, #arg2 do
		tbl3[arg2[i]] = true
	end

	integrity.connections[#integrity.connections + 1] = arg.Changed:Connect(function(arg4)
		if not integrity.armed or integrity.restoring or not tbl3[arg4] then
			return
		end
		tbl2.integrityEscalate()
		integrity.restoring = true
		pcall(arg3)
		integrity.restoring = false
	end)
end

tbl2.armHubIntegrity = function(arg)
	local integrity = tbl2.Integrity
	tbl2.integrityDisconnect()
	integrity.armed = false
	integrity.restoring = false
	integrity.repairQueued = false
	integrity.records = {}
	integrity.knownRootChildren = {}
	integrity.hardUntil = 0
	integrity.hardRefreshAt = 0
	integrity.tamperCount = 0
	integrity.tamperWindow = os.clock()
	local gui = arg.gui
	if not gui or not gui.Parent then
		return
	end
	local dynamicText = arg.dynamicText or {}
	local dynamicTextColor = arg.dynamicTextColor or {}
	local dynamicTextTransparency = arg.dynamicTextTransparency or {}
	local dynamicBackground = arg.dynamicBackground or {}
	local dynamicBackgroundTransparency = arg.dynamicBackgroundTransparency or {}
	local dynamicSize = arg.dynamicSize or {}
	local dynamicPosition = arg.dynamicPosition or {}
	local dynamicRotation = arg.dynamicRotation or {}
	local dynamicStrokeColor = arg.dynamicStrokeColor or {}
	local dynamicStrokeTransparency = arg.dynamicStrokeTransparency or {}

	local function fn(arg2)
		local tbl3 = { Name = arg2.Name }

		if arg2:IsA("ScreenGui") then
			tbl3.ResetOnSpawn = arg2.ResetOnSpawn
			tbl3.IgnoreGuiInset = arg2.IgnoreGuiInset
			tbl3.DisplayOrder = arg2.DisplayOrder
			tbl3.AutoLocalize = arg2.AutoLocalize
			tbl3.ZIndexBehavior = arg2.ZIndexBehavior
		end

		if arg2:IsA("GuiObject") then
			tbl3.BorderSizePixel = arg2.BorderSizePixel
			tbl3.ZIndex = arg2.ZIndex
			tbl3.AnchorPoint = arg2.AnchorPoint

			if not dynamicSize[arg2] then
				tbl3.Size = arg2.Size
			end

			if not dynamicPosition[arg2] then
				tbl3.Position = arg2.Position
			end

			if not dynamicRotation[arg2] then
				tbl3.Rotation = arg2.Rotation
			end

			if not dynamicBackground[arg2] then
				tbl3.BackgroundColor3 = arg2.BackgroundColor3
			end

			if not dynamicBackgroundTransparency[arg2] then
				tbl3.BackgroundTransparency = arg2.BackgroundTransparency
			end
		end

		if arg2:IsA("TextLabel") or arg2:IsA("TextButton") then
			if not dynamicText[arg2] then
				tbl3.Text = arg2.Text
			end

			if not dynamicTextColor[arg2] then
				tbl3.TextColor3 = arg2.TextColor3
			end

			if not dynamicTextTransparency[arg2] then
				tbl3.TextTransparency = arg2.TextTransparency
			end

			tbl3.TextStrokeColor3 = arg2.TextStrokeColor3
			tbl3.TextStrokeTransparency = arg2.TextStrokeTransparency
			tbl3.TextSize = arg2.TextSize
			tbl3.Font = arg2.Font
			tbl3.TextXAlignment = arg2.TextXAlignment
			tbl3.TextYAlignment = arg2.TextYAlignment
			tbl3.TextWrapped = arg2.TextWrapped
			tbl3.TextScaled = arg2.TextScaled
			tbl3.TextTruncate = arg2.TextTruncate

			if arg2:IsA("TextButton") then
				tbl3.AutoButtonColor = arg2.AutoButtonColor
			end
		end

		if arg2:IsA("ImageLabel") or arg2:IsA("ImageButton") then
			tbl3.Image = arg2.Image
			tbl3.ImageColor3 = arg2.ImageColor3
			tbl3.ImageTransparency = arg2.ImageTransparency
			tbl3.ScaleType = arg2.ScaleType

			if arg2:IsA("ImageButton") then
				tbl3.AutoButtonColor = arg2.AutoButtonColor
			end
		end

		if arg2:IsA("UIStroke") then
			if not dynamicStrokeColor[arg2] then
				tbl3.Color = arg2.Color
			end

			if not dynamicStrokeTransparency[arg2] then
				tbl3.Transparency = arg2.Transparency
			end

			tbl3.Thickness = arg2.Thickness
			tbl3.LineJoinMode = arg2.LineJoinMode
		end

		if arg2:IsA("UICorner") then
			tbl3.CornerRadius = arg2.CornerRadius
		end

		if arg2:IsA("UIScale") then
			tbl3.Scale = arg2.Scale
		end

		if arg2:IsA("UIGradient") then
			tbl3.Color = arg2.Color
			tbl3.Transparency = arg2.Transparency
			tbl3.Rotation = arg2.Rotation
		end

		return tbl3
	end

	local parent = gui.Parent
	tbl2.integrityWatch(gui, fn(gui), parent)
	local children = gui:GetChildren()

	for i = 1, #children do
		integrity.knownRootChildren[children[i]] = true
	end

	tbl2.walk(gui, function(arg2)
		local parent2 = arg2.Parent
		tbl2.integrityWatch(arg2, fn(arg2), parent2)
	end)

	integrity.connections[#integrity.connections + 1] = gui.ChildAdded:Connect(function(child)
		if not integrity.armed or integrity.restoring then
			return
		end

		if not integrity.knownRootChildren[child] then
			tbl2.integrityEscalate()

			pcall(function()
				child:Destroy()
			end)
		end
	end)

	integrity.connections[#integrity.connections + 1] = gui.ChildRemoved:Connect(function(child)
		if not integrity.armed or integrity.restoring or not integrity.knownRootChildren[child] then
			return
		end
		tbl2.integrityEscalate()
		tbl2.integrityQueueRepair()
	end)

	local computed = arg.computed or {}

	for i = 1, #computed do
		local v = arg.computed[i]
		tbl2.integrityWatchComputed(v.instance, v.properties, v.repair)
	end

	integrity.refresh = arg.refresh
	integrity.armed = true
	tbl2.integrityRepairAll()

	pcall(function()
		RunService:UnbindFromRenderStep(integrity.guardName)
	end)

	RunService:BindToRenderStep(integrity.guardName, Enum.RenderPriority.Last.Value + 1000, function()
		local now = os.clock()
		if not integrity.armed or integrity.restoring or now > integrity.hardUntil then
			return
		end
		integrity.restoring = true

		for i = 1, #integrity.records do
			tbl2.integrityRepairRecord(integrity.records[i])
		end

		if integrity.refresh and now >= integrity.hardRefreshAt then
			integrity.hardRefreshAt = now + 0.05
			pcall(integrity.refresh)
		end

		integrity.restoring = false
	end)
end

tbl2.findModule = function(arg)
	local v = nil

	tbl2.walk(ReplicatedStorage, function(arg2)
		if arg2:IsA("ModuleScript") and arg2.Name:lower() == arg:lower() then
			v = arg2
			return true
		end
	end)

	if v then
		local ok, result = pcall(require, v)
		if ok then
			return result
		end
	end

	return nil
end

-- FIX: تم إزالة WaitForChild الخطير على Assets/Trails
local Assets = nil
local data = ReplicatedStorage:FindFirstChild("Data")
local assets = data and data:FindFirstChild("Assets") or ReplicatedStorage:FindFirstChild("Assets")

if assets and assets:IsA("ModuleScript") then
	local ok, result = pcall(require, assets)

	if ok then
		Assets = result
	end
end

Assets = Assets or tbl2.findModule("Assets")
require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("EggState"))
require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("RagdollJoints"))
require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"):WaitForChild("AreaEggSlotIdentity"))
local AreaEggCycle = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"):WaitForChild("AreaEggCycle"))
require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("AreaEggResetCycle"))
local Rarity = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("Rarity"))

tbl2.isDaytime = function()
	local ok, result = pcall(function()
		return AreaEggCycle.IsNightPhase(workspace:GetServerTimeNow())
	end)

	return ok and result ~= true
end

tbl2.isStartWallOpen = function()
	local objects = workspace:FindFirstChild("World")
	objects = objects and objects:FindFirstChild("Areas")
	if not objects then
		return true
	end
	local wallStartVisual = objects:FindFirstChild("WallStartVisual")
	if wallStartVisual and wallStartVisual:IsA("BasePart") and wallStartVisual.Size.Y > 0.25 then
		return false
	end
	local wallStartCollision = objects:FindFirstChild("WallStartCollision")
	if wallStartCollision and wallStartCollision:IsA("BasePart") and wallStartCollision.CanCollide then
		return false
	end
	return true
end

tbl2.canLeaveForSteal = function()
	return tbl2.isDaytime() and tbl2.isStartWallOpen()
end

tbl2.rarityConfigCache = {}
tbl2.rarityColorCache = {}

tbl2.getOfficialRarityConfig = function(arg)
	local str = string.lower(tostring(arg or "")):gsub("%s+", "")
	local v = tbl2.rarityConfigCache[str]
	if v ~= nil then
		return v ~= false and v or nil
	end
	local rarities = Rarity.Rarities or {}

	for k, rarity in pairs(rarities) do
		local str2 = string.lower(tostring(k)):gsub("%s+", "")
		local str3 = string.lower(tostring(type(rarity) == "table" and rarity.DisplayName or "")):gsub("%s+", "")
		if str2 == str or str3 == str then
			tbl2.rarityConfigCache[str] = rarity
			return rarity
		end
	end

	tbl2.rarityConfigCache[str] = false
	return nil
end

-- FIX: كان يمرر v2 (nil) بدلاً من arg
tbl2.getOfficialRarityColor = function(arg)
	local str = string.lower(tostring(arg or "")):gsub("%s+", "")
	local v = tbl2.rarityColorCache[str]
	if v then
		return v
	end
	local color = tbl2.getOfficialRarityConfig(arg)
	color = color and color.Color
	local value

	if typeof(color) == "ColorSequence" then
		value = color.Keypoints[1].Value
	else
		value = color
	end

	if typeof(value) ~= "Color3" then
		value = Color3.fromRGB(170, 190, 178)
	end

	tbl2.rarityColorCache[str] = value
	return value
end

local Mutations = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Mutations"))
local AssetViewport = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("AssetViewport"))

local tbl3 = {
	REFRESH_INTERVAL = 0.5,
	SPAM_INTERVAL = 0.01,
	PROTECT_INTERVAL = 0.05,
	SPAWN_OFFSET = 3,
	BEAM_WIDTH = 0.12,
	GROUND_OFFSET = 3,
	DROPDOWN_ROWS = 4,
	ROW_H = 28,
	ROW_GAP = 3,
	TWEEN_SPEED = 500,
	WAYPOINT = Vector3.new(510.092, 70.767, -364.085),
	USE_GROUND_DETECTION = true,
	GROUND_CLEARANCE = 4,
	RAYCAST_UP = 100,
	RAYCAST_DOWN = 300,
	START_MARKER_DEPTH_PADDING = 0,
	START_MARKER_BACK_PADDING = 16,
	START_MARKER_TEXT_BACK_OFFSET = 9,
	START_MARKER_TEXT_AREA_EXTRA = 11,
	JUMP_ANIMATION_ID = "rbxassetid://125750702",
}

local tbl4 = {
	enabled = false,
	mode = "TELEGUIADO",
	running = true,
	bestEgg = nil,
	selectedEgg = nil,
	selectedUid = nil,
	dropdownOpen = false,
	targetEgg = nil,
	eggs = {},
	rarityEggs = {},
	filteredEggs = {},
	rarityFilter = {},
	waitingForDay = false,
	loopEnabled = false,
	runLoop = false,
	guidedCycleActive = false,
	lastRefresh = 0,
	isMoving = false,
	isStealing = false,
	isProtecting = false,
	carrying = false,
	carryLocked = false,
	isDelivering = false,
	heldEggUid = nil,
	moveTarget = nil,
	onArrive = nil,
	lastSpamTime = 0,
	lastProtectTime = 0,
}

local tbl5 = {}
local tbl6 = { Key = "cosmic", Label = "Cosmic", Color = tbl2.getOfficialRarityColor("Cosmic") }
local tbl7 = { Key = "secret", Label = "Secret", Color = tbl2.getOfficialRarityColor("Secret") }
local tbl8 = { Key = "eternal", Label = "Eternal", Color = tbl2.getOfficialRarityColor("Eternal") }
local tbl9 = { Key = "divine", Label = "Divine", Color = tbl2.getOfficialRarityColor("Divine") }
tbl5[1] = tbl6
tbl5[2] = tbl7
tbl5[3] = tbl8
tbl5[4] = tbl9

tbl2.normalizeRarityKey = function(arg)
	return string.lower(tostring(arg or "")):gsub("%s+", "")
end

tbl2.isRarityFilterActive = function()
	for _, v in ipairs(tbl5) do
		if tbl4.rarityFilter[v.Key] then
			return true
		end
	end

	return false
end

tbl2.eggMatchesRarityFilter = function(arg)
	if not tbl2.isRarityFilterActive() then
		return true
	end
	return tbl4.rarityFilter[tbl2.normalizeRarityKey(arg.RarityName)] == true
end
-- ============================================
-- LennonHub - FIXED VERSION
-- Part 2/6: Character Setup, Movement, Desync
-- ============================================

local v = nil
local humanoid = nil
local humanoidRootPart = nil
workspace:WaitForChild("World"):WaitForChild("Areas"):WaitForChild("StartArea")

local v2 = nil
local v3 = nil
local animate = nil
local health = nil
local v4 = nil
local v5 = nil
local animation = nil
local breakJointsOnDeath = nil
local v6 = nil
local connection = nil
local walkSpeed = nil

tbl2.restoreWalkSpeed = function()
	local character = localPlayer.Character
	local humanoid2 = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid2 and walkSpeed then
		humanoid2.WalkSpeed = walkSpeed
		walkSpeed = nil
	end
end

tbl2.isPlayerInGroundArea = function(arg)
	local ground = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("Areas") and workspace.World.Areas:FindFirstChild("Ground")
	if not ground then
		return false
	end

	if ground:IsA("Model") then
		local boundingBox, v7 = ground:GetBoundingBox()
		local v8 = boundingBox:PointToObjectSpace(arg.Position)
		local n = v7.X / 2
		local flag = math.abs(v8.X) <= n

		if flag then
			local n2 = v7.Y / 2 + 20
			flag = math.abs(v8.Y) <= n2
		end

		if flag then
			local n2 = v7.Z / 2
			flag = math.abs(v8.Z) <= n2
		end

		return flag
	end

	if ground:IsA("BasePart") then
		local v7 = ground.CFrame:PointToObjectSpace(arg.Position)
		local n = ground.Size.X / 2
		local flag = math.abs(v7.X) <= n

		if flag then
			local n2 = ground.Size.Y / 2 + 20
			flag = math.abs(v7.Y) <= n2
		end

		if flag then
			local n2 = ground.Size.Z / 2
			flag = math.abs(v7.Z) <= n2
		end

		return flag
	end

	return false
end

tbl2.unequipTreadmill = function()
	pcall(function()
		local network = ReplicatedStorage:FindFirstChild("Network")
		network = network and network:FindFirstChild("Treadmills: RequestUnequip")

		if network then
			network:InvokeServer()
		end
	end)
end

tbl2.getGroundAdjustedPosition = function(arg)
	if typeof(arg) ~= "Vector3" then
		return arg
	end
	local n = tonumber(tbl3.GROUND_CLEARANCE) or 4
	local character = localPlayer.Character or v
	local humanoidRootPart2 = character and character:FindFirstChild("HumanoidRootPart")
	character = character and character:FindFirstChildOfClass("Humanoid")
	local n2

	if humanoidRootPart2 and character then
		n2 = math.max(n, humanoidRootPart2.Size.Y * 0.5 + math.max(tonumber(character.HipHeight) or 0, 0) + 0.2)
	else
		n2 = n
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	local filterDescendantsInstances = {}

	if v and v.Parent then
		table.insert(filterDescendantsInstances, v)
	end

	local n3 = arg + Vector3.new(0, tbl3.RAYCAST_UP, 0)
	local vector = Vector3.new(0, -(tbl3.RAYCAST_UP + tbl3.RAYCAST_DOWN), 0)

	for i = 1, 8 do
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		local hit = workspace:Raycast(n3, vector, raycastParams)
		if not hit then
			return arg
		end
		local instance = hit.Instance
		if instance:IsA("Terrain") or instance:IsA("BasePart") and instance.CanCollide then
			return Vector3.new(arg.X, hit.Position.Y + n2, arg.Z)
		end
		table.insert(filterDescendantsInstances, instance)
	end

	return arg
end

tbl2.liftCharacterOutOfGround = function()
	local character = localPlayer.Character or v
	local humanoidRootPart2 = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid2 = character and character:FindFirstChildOfClass("Humanoid")
	if not character or not humanoidRootPart2 or not humanoid2 then
		return
	end
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	local filterDescendantsInstances = { character }
	local v7 = nil

	for i = 1, 8 do
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		local hit = workspace:Raycast(humanoidRootPart2.Position + Vector3.new(0, 2, 0), Vector3.new(0, -12, 0), raycastParams)
		v7 = nil

		if hit then
			local instance = hit.Instance

			if instance:IsA("Terrain") or instance:IsA("BasePart") and instance.CanCollide then
				v7 = hit
				break
			else
				table.insert(filterDescendantsInstances, instance)
				v7 = nil
				continue
			end
		end

		break
	end

	if not v7 then
		return
	end

	if humanoidRootPart2.Position.Y + 1.5 < v7.Position.Y then
		return
	end
	local n = v7.Position.Y + humanoidRootPart2.Size.Y * 0.5 + math.max(tonumber(humanoid2.HipHeight) or 0, 0) + 0.2

	if humanoidRootPart2.Position.Y < n - 0.05 then
		humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
		humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
		humanoidRootPart2.CFrame = humanoidRootPart2.CFrame + Vector3.new(0, n - humanoidRootPart2.Position.Y, 0)
	end
end

tbl2.stopCurrentTween = function(arg)
	if connection then
		connection:Disconnect()
		connection = nil
	end

	if v6 then
		v6:Cancel()
		v6 = nil
	end

	local character = localPlayer.Character
	character = character and character:FindFirstChild("HumanoidRootPart")

	if character then
		character.AssemblyLinearVelocity = Vector3.zero
	end

	tbl2.restoreWalkSpeed()

	if arg then
		task.spawn(function()
			task.wait(0.05)

			pcall(function()
				if ReplicatedStorage:FindFirstChild("Network") then
					local askFieldEggDrop = tbl.AskFieldEggDrop

					if askFieldEggDrop then
						askFieldEggDrop:InvokeServer({ Reason = "PlayerRequest" })
					end
				end
			end)
		end)
	end
end

tbl2.completeMove = function()
	tbl2.restoreWalkSpeed()

	if tbl4.isMoving then
		tbl4.isMoving = false
		tbl4.moveTarget = nil
		local onArrive = tbl4.onArrive
		tbl4.onArrive = nil

		if onArrive then
			task.defer(onArrive)
		end
	end
end

tbl2.tweenToTarget = function(arg, arg2)
	local character = localPlayer.Character
	local humanoidRootPart2 = character and character:FindFirstChild("HumanoidRootPart")
	character = character and character:FindFirstChildOfClass("Humanoid")

	if humanoidRootPart2 then
		if tbl2.isPlayerInGroundArea(humanoidRootPart2) then
			tbl2.unequipTreadmill()
		end

		local n = tonumber(tbl3.TWEEN_SPEED) or 500
		tbl2.stopCurrentTween(false)

		if character then
			if character.WalkSpeed > 0 then
				walkSpeed = character.WalkSpeed
			end

			character.WalkSpeed = 0
		end

		local function fn(arg3, arg4)
			local magnitude = (arg3 - humanoidRootPart2.Position).Magnitude

			if magnitude < 2 then
				if arg4 then
					arg4()
				end

				return
			end

			local tweenInfo = TweenInfo.new(magnitude / n, Enum.EasingStyle.Linear)
			local cframe = CFrame.new(arg3)

			if arg2 then
				local vector = Vector3.new(arg3.X - humanoidRootPart2.Position.X, 0, arg3.Z - humanoidRootPart2.Position.Z)

				if vector.Magnitude > 0.01 then
					cframe = CFrame.lookAt(arg3, arg3 + vector.Unit)
				end
			end

			local tween = TweenService:Create(humanoidRootPart2, tweenInfo, { CFrame = cframe })
			v6 = tween

			connection = tween.Completed:Connect(function(playbackState)
				if v6 == tween then
					v6 = nil

					if connection then
						connection:Disconnect()
						connection = nil
					end

					if playbackState == Enum.PlaybackState.Completed then
						humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
						humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
						humanoidRootPart2.CFrame = cframe

						if arg4 then
							arg4()
						end
					end
				end
			end)

			tween:Play()
		end

		local waypoint = tbl3.WAYPOINT
		local flag = (arg - waypoint).Magnitude < 2
		local v7 = tbl2.getGroundAdjustedPosition(waypoint)
		local v8 = arg2 and arg or tbl2.getGroundAdjustedPosition(arg)

		if tbl3.USE_GROUND_DETECTION and not arg2 and tbl2.isPlayerInGroundArea(humanoidRootPart2) and not flag then
			fn(v7, function()
				fn(v8, tbl2.completeMove)
			end)
		else
			fn(v8, tbl2.completeMove)
		end
	end
end

tbl2.startMove = function(moveTarget, onArrive, arg)
	if not moveTarget or not humanoidRootPart then
		return
	end
	tbl4.isMoving = true
	tbl4.moveTarget = moveTarget
	tbl4.onArrive = onArrive
	tbl2.tweenToTarget(moveTarget, arg == true)
end

tbl2.finishMove = function()
	tbl2.stopCurrentTween(false)
	tbl4.isMoving = false
	tbl4.moveTarget = nil
	tbl4.onArrive = nil
end

tbl2.unequipAllTools = function()
	task.spawn(function()
		pcall(function()
			local character = localPlayer.Character or v
			if not character then
				return
			end
			local humanoid2 = character:FindFirstChildOfClass("Humanoid")

			if humanoid2 then
				humanoid2:UnequipTools()
			end
		end)
	end)
end

tbl2.applyAntiRagdoll = function(arg, arg2)
	if not arg or not arg2 then
		return
	end
	arg2:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	arg2:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	arg2:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
	local motorCache = tbl2.motorCache

	if motorCache then
		for i = 1, #motorCache do
			local v7 = motorCache[i]

			if v7 and v7.Parent and v7:IsDescendantOf(arg) then
				v7.Enabled = true
			end
		end
	else
		tbl2.walk(arg, function(arg3)
			if arg3:IsA("Motor6D") then
				arg3.Enabled = true
			end
		end)
	end
end

tbl2.createZombieHumanoidClone = function(arg, arg2)
	if not arg then
		return nil
	end
	local clone = arg:Clone()
	clone.Name = "Humanoid"
	clone.BreakJointsOnDeath = false
	clone:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	clone:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	clone:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	clone:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
	clone.Health = clone.MaxHealth
	clone.HipHeight = arg.HipHeight
	clone.PlatformStand = false
	clone.Sit = false
	clone.AutoRotate = arg2 == true
	return clone
end

tbl2.applyZombieDesync = function(parent)
	if not parent then
		return nil
	end

	if v2 and v2.Parent == parent then
		return v2
	end
	walkSpeed = nil
	local humanoid2 = parent:WaitForChild("Humanoid", 5)
	if not humanoid2 then
		return nil
	end
	local humanoidRootPart2 = parent:FindFirstChild("HumanoidRootPart")
	local cFrame = humanoidRootPart2 and humanoidRootPart2.CFrame or nil
	local hipHeight = humanoid2.HipHeight
	v3 = humanoid2
	breakJointsOnDeath = humanoid2.BreakJointsOnDeath
	v4 = parent
	health = parent:FindFirstChild("Health")
	animate = parent:FindFirstChild("Animate")
	local v7 = tbl2.createZombieHumanoidClone(humanoid2, true)
	if not v7 then
		return nil
	end

	if animate then
		animate.Parent = nil
	end

	local animator = v7:FindFirstChildOfClass("Animator")

	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = v7
	end

	if tbl3.JUMP_ANIMATION_ID and tbl3.JUMP_ANIMATION_ID ~= "" then
		pcall(function()
			animation = Instance.new("Animation")
			animation.AnimationId = tbl3.JUMP_ANIMATION_ID
			v5 = animator:LoadAnimation(animation)

			v7.Jumping:Connect(function(arg)
				if arg and v5 then
					v5:Play()
				end
			end)
		end)
	end

	humanoid2.Parent = nil
	v7.Parent = parent
	v7.HipHeight = hipHeight
	v2 = v7
	humanoid = v7

	if animate then
		if not pcall(function()
			local clone = animate:Clone()
			clone.Name = "Animate"
			clone.Parent = parent
			clone.Disabled = false
		end) then
			animate.Parent = parent
			animate.Disabled = false
		end
	end

	tbl2.applyAntiRagdoll(parent, v7)

	if humanoidRootPart2 and humanoidRootPart2.Parent then
		humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
		humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero

		if cFrame then
			humanoidRootPart2.CFrame = cFrame
		end
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera.CameraType = Enum.CameraType.Custom
		currentCamera.CameraSubject = v7
	end

	return v7
end

tbl2.restoreOriginalHumanoid = function()
	local character = v4 or localPlayer.Character
	if not character then
		return
	end

	if not v3 then
		v2 = nil
		humanoid = character:FindFirstChildOfClass("Humanoid")
		local currentCamera = workspace.CurrentCamera

		if currentCamera and humanoid then
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.CameraSubject = humanoid
		end

		return
	end

	if v5 then
		pcall(function()
			v5:Stop(0)
		end)
	end

	if animation then
		pcall(function()
			animation:Destroy()
		end)
	end

	v5 = nil
	animation = nil
	local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")
	local cFrame = humanoidRootPart2 and humanoidRootPart2.CFrame or nil
	local humanoid2 = character:FindFirstChildOfClass("Humanoid")

	if humanoid2 and humanoid2 ~= v3 then
		humanoid2:Destroy()
	end

	if v3 then
		v3.Parent = character
		v3.PlatformStand = false
		v3.AutoRotate = true
		v3.Sit = false

		pcall(function()
			v3:ChangeState(Enum.HumanoidStateType.GettingUp)
		end)

		humanoid = v3
		v2 = nil
	end

	if humanoidRootPart2 and humanoidRootPart2.Parent then
		humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
		humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero

		if cFrame then
			humanoidRootPart2.CFrame = cFrame
		end
	end

	local animate2 = character:FindFirstChild("Animate")

	if animate2 and animate2 ~= animate then
		animate2:Destroy()
	end

	if animate then
		animate.Parent = character
		animate.Disabled = false
	end

	if health then
		health.Parent = character
	end

	if v3 and breakJointsOnDeath ~= nil then
		v3.BreakJointsOnDeath = breakJointsOnDeath
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera and humanoid then
		currentCamera.CameraSubject = humanoid
	end

	v4 = nil
	v3 = nil
	animate = nil
	health = nil
	breakJointsOnDeath = nil
end

local n = 0

RunService.Heartbeat:Connect(function(deltaTime)
	n += deltaTime
	if n < 0.1 then
		return
	end
	n = 0

	if localPlayer.Character and v2 then
		local motorCache = tbl2.motorCache

		if motorCache then
			for i = 1, #motorCache do
				local v7 = motorCache[i]

				if v7 and v7.Parent and not v7.Enabled then
					v7.Enabled = true
				end
			end
		end

		local state = v2:GetState()

		if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then
			v2:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end
end)

local guardAreas = workspace:WaitForChild("World"):WaitForChild("Areas"):WaitForChild("GuardAreas")
guardAreas:WaitForChild("Forest")

local tbl10 = {
	["Abyss Ocean"] = { X = 0, Y = 9.4, Z = 4 },
	["Cherry Blossom"] = { X = 0, Y = 7.5, Z = -1 },
	Cosmic = { X = 0, Y = 11, Z = 3.000015 },
	Desert = { X = -6.1e-05, Y = 2, Z = 2 },
	Forest = { X = 0, Y = 2, Z = 0.500061 },
	Jungle = { X = 0, Y = 5.000008, Z = -0.500031 },
	Lake = { X = 0, Y = 2, Z = 0 },
	Prehistoric = { X = 0, Y = 22, Z = -12 },
	Snow = { X = 0, Y = 1.5, Z = -0.5 },
	Volcano = { X = -6.1e-05, Y = 8, Z = -2 },
	["Titan Temple"] = { X = 0, Y = 15, Z = 3.5 },
}

local v7 = nil
local v8 = nil
local v9 = nil
local y = nil
local v10 = nil
local parent = nil
local weldConstraint = nil
local v11 = nil
local v12 = nil
local v13 = nil
local tbl11 = {}
local connection2 = nil

tbl2.getAreaCenter = function(arg)
	if not arg then
		return nil
	end

	if arg:IsA("Model") then
		return arg:GetPivot().Position
	end

	if arg:IsA("BasePart") then
		return arg.Position
	end
	local basePart = arg:FindFirstChildWhichIsA("BasePart", true)
	return basePart and basePart.Position or nil
end

tbl2.isPositionInsideArea = function(arg, arg2)
	if not arg2 then
		return false
	end
	local boundingBox, size

	if arg2:IsA("Model") then
		boundingBox, size = arg2:GetBoundingBox()
	else
		if not arg2:IsA("BasePart") then
			return false
		end
		boundingBox = arg2.CFrame
		size = arg2.Size
	end

	local v14 = boundingBox:PointToObjectSpace(arg)
	local n2 = size.X / 2
	local flag = math.abs(v14.X) <= n2

	if flag then
		local n3 = size.Z / 2
		flag = math.abs(v14.Z) <= n3
	end

	local flag2

	if flag then
		local n3 = size.Y / 2 + 100
		flag2 = math.abs(v14.Y) <= n3
	else
		flag2 = flag
	end

	return flag2
end

tbl2.getBossAreaFromEgg = function(arg)
	if not arg then
		return nil
	end
	local areaName = arg.AreaName or arg.Area or arg.World or arg.Biome
	if type(areaName) == "string" and guardAreas:FindFirstChild(areaName) then
		return areaName
	end
	local position = arg.Position
	if typeof(position) ~= "Vector3" then
		return nil
	end
	local v14 = nil
	local name = nil

	for _, child in ipairs(guardAreas:GetChildren()) do
		if tbl2.isPositionInsideArea(position, child) then
			return child.Name
		end
		local v15 = tbl2.getAreaCenter(child)

		if v15 then
			local magnitude = (Vector3.new(v15.X, 0, v15.Z) - Vector3.new(position.X, 0, position.Z)).Magnitude

			if not v14 or magnitude < v14 then
				name = child.Name
				v14 = magnitude
			end
		end
	end

	return name
end

tbl2.stopBossAnimations = function()
	if connection2 then
		connection2:Disconnect()
		connection2 = nil
	end

	if v11 then
		pcall(function()
			v11:Stop(0.15)
		end)
	end

	if v12 then
		pcall(function()
			v12:Stop(0.15)
		end)
	end

	if v13 then
		pcall(function()
			v13:Stop(0.15)
		end)
	end

	for _, v14 in ipairs(tbl11) do
		local sound = v14.Sound

		if sound and sound.Parent then
			pcall(function()
				sound:Stop()
				sound.Looped = v14.Looped
			end)
		end
	end

	tbl11 = {}
	v11 = nil
	v12 = nil
	v13 = nil
end

tbl2.cleanupBossMount = function()
	tbl2.stopBossAnimations()

	if weldConstraint then
		weldConstraint:Destroy()
		weldConstraint = nil
	end

	if v7 then
		v7:Destroy()
		v7 = nil
	end

	if v10 and parent then
		v10.Parent = parent
	end

	v10 = nil
	parent = nil
	v8 = nil
	v9 = nil
	y = nil
	local humanoid2 = v2 or v and v:FindFirstChildOfClass("Humanoid")

	if humanoid2 and humanoid2.Parent then
		humanoid2.PlatformStand = false
		humanoid2.AutoRotate = true
	end
end
-- ============================================
-- LennonHub - FIXED VERSION
-- Part 3/6: Boss Animations, Spawning, GUI Header
-- ============================================

tbl2.loadBossMovementSounds = function(arg)
	tbl11 = {}
	local tbl12 = {}
	local tbl13 = {}

	tbl2.walk(arg, function(arg2)
		if arg2:IsA("Sound") then
			tbl13[#tbl13 + 1] = arg2
			local v14 = string.lower(arg2.Name)

			if v14:find("walk") or v14:find("run") or v14:find("move") or v14:find("step") or arg2.Looped then
				tbl12[#tbl12 + 1] = arg2
			end
		end
	end)

	if #tbl12 == 0 then
		tbl12 = tbl13
	end

	for _, v14 in ipairs(tbl12) do
		table.insert(tbl11, { Sound = v14, Looped = v14.Looped })
		v14.Looped = true
	end
end

tbl2.setBossMovementSounds = function(arg)
	for _, v14 in ipairs(tbl11) do
		local sound = v14.Sound

		if sound and sound.Parent then
			if arg then
				if not sound.IsPlaying then
					pcall(function()
						sound:Play()
					end)
				end
			elseif sound.IsPlaying then
				pcall(function()
					sound:Stop()
				end)
			end
		end
	end
end

tbl2.loadBossAnimations = function(arg, arg2)
	tbl2.loadBossMovementSounds(arg)
	local animationController = arg:FindFirstChildWhichIsA("AnimationController", true)

	if not animationController then
		animationController = Instance.new("AnimationController")
		animationController.Name = "AnimationController"
		animationController.Parent = arg:FindFirstChild("Model") or arg
	end

	local animator = animationController:FindFirstChildWhichIsA("Animator") or Instance.new("Animator")
	animator.Parent = animationController
	local animationId = nil
	local animationId2 = nil

	pcall(function()
		local v14 = ReplicatedStorage.Data.Guards.Configs:FindFirstChild(arg2)

		if v14 then
			local module = require(v14)
			animationId = module.IdleAnimation and module.IdleAnimation.AnimationId
			animationId2 = module.WalkAnimation and module.WalkAnimation.AnimationId
		end
	end)

	local function fn(animationId3, priority)
		if not animationId3 then
			return nil
		end
		local animation2 = Instance.new("Animation")
		animation2.AnimationId = animationId3

		local ok, result = pcall(function()
			return animator:LoadAnimation(animation2)
		end)

		if not ok or not result then
			return nil
		end
		result.Looped = true
		result.Priority = priority
		return result
	end

	v11 = fn(animationId, Enum.AnimationPriority.Idle)
	v12 = fn(animationId2, Enum.AnimationPriority.Movement)

	if v11 then
		v11:Play(0.15)
	end

	local v14 = v2
	local humanoid2

	if v2 then
		humanoid2 = v14
	else
		humanoid2 = v and v:FindFirstChildOfClass("Humanoid")
	end

	if humanoid2 then
		local animator2 = humanoid2:FindFirstChildOfClass("Animator") or Instance.new("Animator")
		animator2.Parent = humanoid2
		local animation2 = Instance.new("Animation")
		animation2.AnimationId = "rbxassetid://2506281703"

		local ok, result = pcall(function()
			return animator2:LoadAnimation(animation2)
		end)

		if ok and result then
			v13 = result
			v13.Looped = true
			v13.Priority = Enum.AnimationPriority.Action4
			v13:Play(0.15)
			v13:AdjustWeight(1, 0.1)
		end
	end

	local n2 = 0

	connection2 = RunService.Heartbeat:Connect(function(deltaTime)
		n2 += deltaTime
		if n2 < 0.08 then
			return
		end
		n2 = 0
		if not v7 or not v7.Parent then
			tbl2.cleanupBossMount()
			return
		end
		local isMoving = tbl4.isMoving

		if isMoving and v12 then
			if v11 and v11.IsPlaying then
				v11:Stop(0.15)
			end

			if not v12.IsPlaying then
				v12:Play(0.15)
			end

			tbl2.setBossMovementSounds(true)
		elseif not isMoving and v11 then
			if v12 and v12.IsPlaying then
				v12:Stop(0.15)
			end

			if not v11.IsPlaying then
				v11:Play(0.15)
			end

			tbl2.setBossMovementSounds(false)
		elseif isMoving then
			tbl2.setBossMovementSounds(true)
		else
			tbl2.setBossMovementSounds(false)
		end

		if v13 and not v13.IsPlaying then
			v13:Play(0.1)
			v13:AdjustWeight(1, 0.1)
		end
	end)
end

tbl2.getGroundDirectionFrom = function(arg)
	local ground = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("Areas") and workspace.World.Areas:FindFirstChild("Ground")
	if not ground then
		return nil
	end
	local position

	if ground:IsA("Model") then
		position = ground:GetPivot().Position
	elseif ground:IsA("BasePart") then
		position = ground.Position
	else
		position = ground:FindFirstChildWhichIsA("BasePart", true)
		position = position and position.Position
	end

	if not position then
		return nil
	end
	local vector = Vector3.new(position.X - arg.X, 0, position.Z - arg.Z)
	return vector.Magnitude > 0.01 and vector.Unit or nil
end

tbl2.spawnBossForEgg = function(arg)
	tbl2.cleanupBossMount()
	if not humanoidRootPart or not humanoidRootPart.Parent then
		return nil
	end
	local v14 = tbl2.getBossAreaFromEgg(arg)
	local v15 = v14 and guardAreas:FindFirstChild(v14)
	local guard = v15 and v15:FindFirstChild("Guard")
	if not guard then
		warn("Guard nao encontrado para a area do ovo:", tostring(v14))
		return nil
	end
	local primaryPart = guard.PrimaryPart or guard:FindFirstChild("HumanoidRootPart", true) or guard:FindFirstChild("Root", true) or guard:FindFirstChildWhichIsA("BasePart", true)
	if not primaryPart then
		return nil
	end
	y = primaryPart.Position.Y
	local clone = guard:Clone()
	clone.Name = "__LennonBoss_" .. tostring(v14)
	v10 = guard
	parent = guard.Parent
	guard.Parent = nil
	local primaryPart2 = clone.PrimaryPart or clone:FindFirstChild("HumanoidRootPart", true) or clone:FindFirstChild("Root", true) or clone:FindFirstChildWhichIsA("BasePart", true)

	if not primaryPart2 then
		clone:Destroy()

		if v10 and parent then
			v10.Parent = parent
		end

		v10 = nil
		parent = nil
		return nil
	end

	clone.PrimaryPart = primaryPart2

	tbl2.walk(clone, function(arg2)
		if arg2:IsA("BasePart") then
			arg2.CanCollide = false
			arg2.CanQuery = false
			arg2.CanTouch = false
			arg2.Massless = true
			arg2.Anchored = false
		end
	end)

	local lookVector = tbl2.getGroundDirectionFrom(humanoidRootPart.Position) or humanoidRootPart.CFrame.LookVector
	local unit = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
	local n2 = humanoidRootPart.Position + unit * 8
	local vector = Vector3.new(n2.X, y, n2.Z)
	clone:PivotTo(CFrame.lookAt(vector, vector + unit))
	local n3 = y - primaryPart2.Position.Y

	if math.abs(n3) > 0.001 then
		clone:PivotTo(clone:GetPivot() + Vector3.new(0, n3, 0))
	end

	clone.Parent = workspace
	primaryPart2.Anchored = true
	local tbl12 = tbl10[v14] or { X = 0, Y = 3, Z = 0 }
	v9 = tbl12
	humanoidRootPart.CFrame = primaryPart2.CFrame * CFrame.new(tbl12.X, tbl12.Y, tbl12.Z)
	primaryPart2.Anchored = false
	weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Name = "LennonBossRiderWeld"
	weldConstraint.Part0 = humanoidRootPart
	weldConstraint.Part1 = primaryPart2
	weldConstraint.Parent = humanoidRootPart
	v7 = clone
	v8 = primaryPart2
	local humanoid2 = v2 or v and v:FindFirstChildOfClass("Humanoid")

	if humanoid2 then
		humanoid2.PlatformStand = false
		humanoid2.AutoRotate = false
	end

	tbl2.loadBossAnimations(clone, v14)
	return clone
end

tbl2.getBossDeliveryPosition = function(arg)
	if typeof(arg) ~= "Vector3" then
		return arg
	end
	local v14 = v9
	if not v14 then
		return arg
	end
	local vector = Vector3.new(arg.X, y or arg.Y, arg.Z)
	return (CFrame.lookAt(vector, vector + (tbl2.getGroundDirectionFrom(vector) or Vector3.new(0, 0, -1))) * CFrame.new(v14.X, v14.Y, v14.Z)).Position
end

local str = "LH_"

local function fn(arg)
	if not arg then
		return
	end
	local children = arg:GetChildren()

	for i = 1, #children do
		local v14 = children[i]

		if v14:IsA("ScreenGui") and (v14.Name == "LennonHub" or v14.Name:sub(1, #str) == str) then
			pcall(function()
				v14:Destroy()
			end)
		end
	end
end

pcall(function()
	fn(game:GetService("CoreGui"))
end)

pcall(function()
	fn(localPlayer.PlayerGui)
end)

local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
local flag = viewportSize.X < 680 or viewportSize.Y < 500
local n2 = 262
local n3 = 185
local scale = flag and 0.88 or 0.94
local n4 = flag and 40 or 42
local n5 = flag and 10 or 14
local udim2 = flag and UDim2.new(1, -math.floor(n2 * scale) - 8, 0, 8) or UDim2.new(0.5, 140, 0.5, -math.floor(n3 * scale / 2) - 22)
local n6 = tbl3.DROPDOWN_ROWS * tbl3.ROW_H + (tbl3.DROPDOWN_ROWS - 1) * tbl3.ROW_GAP + 8
local n7 = n6 + 20
local n8 = 2
local v14 = math.ceil(#tbl5 / n8)
local n9 = flag and 21 or 22
local n10 = 3
local n11 = v14 * n9 + (v14 - 1) * n10
local n12 = 120 + n7 + n11 + 10

local screenGui = Instance.new("ScreenGui")
screenGui.Name = str .. tostring(math.random(1000000, 9999999))
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.DisplayOrder = 100
screenGui.AutoLocalize = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local imageButton = Instance.new("ImageButton")
imageButton.Name = "LennonIcon"
imageButton.Size = UDim2.fromOffset(n4, n4)
imageButton.Position = UDim2.new(0, n5, 0.5, -math.floor(n4 / 2))
imageButton.BackgroundColor3 = Color3.fromRGB(8, 12, 10)
imageButton.BackgroundTransparency = 0.08
imageButton.Image = "rbxassetid://103090301992311"
imageButton.ScaleType = Enum.ScaleType.Crop
imageButton.AutoButtonColor = false
imageButton.ZIndex = 20
imageButton.Parent = screenGui
Instance.new("UICorner", imageButton).CornerRadius = UDim.new(1, 0)
local uiStroke = Instance.new("UIStroke", imageButton)
uiStroke.Color = Color3.fromRGB(50, 255, 110)
uiStroke.Thickness = 1.5
uiStroke.Transparency = 0.15

local frame = Instance.new("Frame")
frame.Name = "LennonPanel"
frame.Size = UDim2.fromOffset(262, 185)
frame.Position = udim2
frame.BackgroundColor3 = Color3.fromRGB(7, 10, 8)
frame.BackgroundTransparency = 0.12
frame.Visible = true
frame.ZIndex = 10
frame.Parent = screenGui
local uiScale = Instance.new("UIScale")
uiScale.Name = "CompactScale"
uiScale.Scale = scale
uiScale.Parent = frame
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local uiStroke2 = Instance.new("UIStroke", frame)
uiStroke2.Color = Color3.fromRGB(35, 145, 70)
uiStroke2.Thickness = 1
uiStroke2.Transparency = 0.2

local frame2 = Instance.new("Frame")
frame2.Size = UDim2.new(1, -20, 0, 42)
frame2.Position = UDim2.fromOffset(10, 10)
frame2.BackgroundTransparency = 1
frame2.ZIndex = 11
frame2.Parent = frame

local imageLabel = Instance.new("ImageLabel")
imageLabel.Size = UDim2.fromOffset(26, 26)
imageLabel.Position = UDim2.new(0, 0, 0.5, -13)
imageLabel.BackgroundTransparency = 1
imageLabel.Image = "rbxassetid://103090301992311"
imageLabel.ScaleType = Enum.ScaleType.Crop
imageLabel.ZIndex = 12
imageLabel.Parent = frame2
Instance.new("UICorner", imageLabel).CornerRadius = UDim.new(1, 0)

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, -70, 0, 18)
textLabel.Position = UDim2.new(0, 34, 0, 4)
textLabel.BackgroundTransparency = 1
textLabel.Text = "LENNON HUB"
textLabel.TextColor3 = Color3.fromRGB(235, 255, 240)
textLabel.TextSize = 13
textLabel.Font = Enum.Font.GothamBold
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.ZIndex = 12
textLabel.Parent = frame2

local textLabel2 = Instance.new("TextLabel")
textLabel2.Size = UDim2.new(1, -70, 0, 13)
textLabel2.Position = UDim2.new(0, 34, 0, 22)
textLabel2.BackgroundTransparency = 1
textLabel2.Text = "BEST EGG SYSTEM"
textLabel2.TextColor3 = Color3.fromRGB(90, 130, 100)
textLabel2.TextSize = 7
textLabel2.Font = Enum.Font.GothamMedium
textLabel2.TextXAlignment = Enum.TextXAlignment.Left
textLabel2.ZIndex = 12
textLabel2.Parent = frame2

local frame3 = Instance.new("Frame")
frame3.Name = "LennonToast"
frame3.Size = UDim2.fromOffset(190, 28)
frame3.Position = UDim2.new(0.5, -95, 0, -35)
frame3.BackgroundColor3 = Color3.fromRGB(12, 22, 16)
frame3.BackgroundTransparency = 1
frame3.ZIndex = 50
frame3.Visible = false
frame3.ClipsDescendants = true
frame3.Parent = frame
Instance.new("UICorner", frame3).CornerRadius = UDim.new(0, 8)
local uiStroke3 = Instance.new("UIStroke", frame3)
uiStroke3.Color = Color3.fromRGB(50, 255, 110)
uiStroke3.Thickness = 1
uiStroke3.Transparency = 1

local textLabel3 = Instance.new("TextLabel")
textLabel3.Size = UDim2.new(1, 0, 1, 0)
textLabel3.BackgroundTransparency = 1
textLabel3.Text = "Discord link copied!"
textLabel3.TextColor3 = Color3.fromRGB(235, 255, 240)
textLabel3.TextTransparency = 1
textLabel3.TextSize = 10
textLabel3.Font = Enum.Font.GothamBold
textLabel3.ZIndex = 51
textLabel3.Parent = frame3

tbl2.showToast = function(text)
	textLabel3.Text = text or "Discord link copied!"
	frame3.Visible = true
	frame3.Position = UDim2.new(0.5, -95, 0, -35)
	frame3.BackgroundTransparency = 1
	textLabel3.TextTransparency = 1
	uiStroke3.Transparency = 1
	TweenService:Create(frame3, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, -95, 0, 7), BackgroundTransparency = 0.1 }):Play()
	TweenService:Create(textLabel3, TweenInfo.new(0.18), { TextTransparency = 0 }):Play()
	TweenService:Create(uiStroke3, TweenInfo.new(0.18), { Transparency = 0.25 }):Play()

	task.delay(1.8, function()
		if not frame3.Visible then
			return
		end
		local tween = TweenService:Create(frame3, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Position = UDim2.new(0.5, -95, 0, -35), BackgroundTransparency = 1 })
		TweenService:Create(textLabel3, TweenInfo.new(0.22), { TextTransparency = 1 }):Play()
		TweenService:Create(uiStroke3, TweenInfo.new(0.22), { Transparency = 1 }):Play()
		tween:Play()

		tween.Completed:Connect(function()
			if frame3.Position.Y.Offset <= -25 then
				frame3.Visible = false
			end
		end)
	end)
end

local imageButton2 = Instance.new("ImageButton")
imageButton2.Size = UDim2.fromOffset(24, 24)
imageButton2.Position = UDim2.new(1, -52, 0.5, -12)
imageButton2.BackgroundColor3 = Color3.fromRGB(25, 32, 27)
imageButton2.BackgroundTransparency = 0.25
imageButton2.Image = "rbxassetid://121807029290075"
imageButton2.ScaleType = Enum.ScaleType.Fit
imageButton2.AutoButtonColor = false
imageButton2.ZIndex = 12
imageButton2.Parent = frame2
Instance.new("UICorner", imageButton2).CornerRadius = UDim.new(1, 0)
local uiStroke4 = Instance.new("UIStroke", imageButton2)
uiStroke4.Color = Color3.fromRGB(88, 101, 242)
uiStroke4.Thickness = 1.2
uiStroke4.Transparency = 0.3

imageButton2.MouseButton1Click:Connect(function()
	pcall(function()
		if setclipboard then
			setclipboard("https://discord.gg/xuPkkjQfRR")
		end
	end)

	tbl2.showToast("Discord link copied!")
	uiStroke4.Color = Color3.fromRGB(50, 255, 110)

	task.delay(0.4, function()
		if uiStroke4 and uiStroke4.Parent then
			uiStroke4.Color = Color3.fromRGB(88, 101, 242)
		end
	end)
end)

local textButton = Instance.new("TextButton")
textButton.Size = UDim2.fromOffset(24, 24)
textButton.Position = UDim2.new(1, -24, 0.5, -12)
textButton.BackgroundColor3 = Color3.fromRGB(25, 32, 27)
textButton.BackgroundTransparency = 0.25
textButton.Text = "X"
textButton.TextColor3 = Color3.fromRGB(160, 180, 165)
textButton.TextSize = 16
textButton.Font = Enum.Font.Gotham
textButton.AutoButtonColor = false
textButton.ZIndex = 12
textButton.Parent = frame2
Instance.new("UICorner", textButton).CornerRadius = UDim.new(1, 0)

local frame4 = Instance.new("Frame")
frame4.Size = UDim2.new(1, -20, 0, 1)
frame4.Position = UDim2.fromOffset(10, 52)
frame4.BackgroundColor3 = Color3.fromRGB(40, 90, 50)
frame4.BackgroundTransparency = 0.5
frame4.BorderSizePixel = 0
frame4.ZIndex = 11
frame4.Parent = frame

local frame5 = Instance.new("Frame")
frame5.Size = UDim2.new(1, -20, 0, 52)
frame5.Position = UDim2.fromOffset(10, 60)
frame5.BackgroundColor3 = Color3.fromRGB(13, 19, 15)
frame5.BackgroundTransparency = 0.1
frame5.ZIndex = 11
frame5.Parent = frame
Instance.new("UICorner", frame5).CornerRadius = UDim.new(0, 9)
local uiStroke5 = Instance.new("UIStroke", frame5)
uiStroke5.Color = Color3.fromRGB(35, 70, 43)
uiStroke5.Thickness = 1
uiStroke5.Transparency = 0.2

local textLabel4 = Instance.new("TextLabel")
textLabel4.Size = UDim2.new(1, -58, 0, 14)
textLabel4.Position = UDim2.fromOffset(52, 5)
textLabel4.BackgroundTransparency = 1
textLabel4.Text = "BEST EGG"
textLabel4.TextColor3 = Color3.fromRGB(90, 130, 100)
textLabel4.TextSize = 7
textLabel4.Font = Enum.Font.GothamBold
textLabel4.TextXAlignment = Enum.TextXAlignment.Left
textLabel4.ZIndex = 12
textLabel4.Parent = frame5

local textLabel5 = Instance.new("TextLabel")
textLabel5.Size = UDim2.new(0, 100, 0, 17)
textLabel5.Position = UDim2.fromOffset(52, 20)
textLabel5.BackgroundTransparency = 1
textLabel5.Text = "SEARCHING..."
textLabel5.TextColor3 = Color3.fromRGB(235, 255, 240)
textLabel5.TextSize = 10
textLabel5.Font = Enum.Font.GothamBold
textLabel5.TextXAlignment = Enum.TextXAlignment.Left
textLabel5.TextTruncate = Enum.TextTruncate.AtEnd
textLabel5.ZIndex = 12
textLabel5.Parent = frame5

local textLabel6 = Instance.new("TextLabel")
textLabel6.Size = UDim2.new(0, 100, 0, 12)
textLabel6.Position = UDim2.fromOffset(52, 35)
textLabel6.BackgroundTransparency = 1
textLabel6.Text = ""
textLabel6.TextColor3 = Color3.fromRGB(170, 190, 178)
textLabel6.TextSize = 8
textLabel6.Font = Enum.Font.GothamBold
textLabel6.TextXAlignment = Enum.TextXAlignment.Left
textLabel6.TextTruncate = Enum.TextTruncate.AtEnd
textLabel6.ZIndex = 12
textLabel6.Parent = frame5

local textLabel7 = Instance.new("TextLabel")
textLabel7.AnchorPoint = Vector2.new(1, 0)
textLabel7.Size = UDim2.fromOffset(60, 17)
textLabel7.Position = UDim2.new(1, -24, 0, 20)
textLabel7.BackgroundTransparency = 1
textLabel7.Text = "--"
textLabel7.TextColor3 = Color3.fromRGB(50, 255, 110)
textLabel7.TextSize = 10
textLabel7.Font = Enum.Font.GothamBold
textLabel7.TextXAlignment = Enum.TextXAlignment.Right
textLabel7.ZIndex = 12
textLabel7.Parent = frame5

local textButton2 = Instance.new("TextButton")
textButton2.Name = "DropdownToggle"
textButton2.Size = UDim2.fromOffset(18, 18)
textButton2.Position = UDim2.new(1, -20, 0, 3)
textButton2.BackgroundColor3 = Color3.fromRGB(25, 32, 27)
textButton2.BackgroundTransparency = 0.35
textButton2.Text = ""
textButton2.AutoButtonColor = false
textButton2.ZIndex = 13
textButton2.Parent = frame5
Instance.new("UICorner", textButton2).CornerRadius = UDim.new(1, 0)

local frame6 = Instance.new("Frame")
frame6.Name = "Arrow"
frame6.AnchorPoint = Vector2.new(0.5, 0.5)
frame6.Position = UDim2.new(0.5, 0, 0.5, 0)
frame6.Size = UDim2.fromOffset(10, 10)
frame6.BackgroundTransparency = 1
frame6.Rotation = 0
frame6.ZIndex = 14
frame6.Parent = textButton2

local frame7 = Instance.new("Frame")
frame7.AnchorPoint = Vector2.new(0.5, 0.5)
frame7.Position = UDim2.new(0.5, -3, 0.5, -1)
frame7.Size = UDim2.fromOffset(7, 2)
frame7.Rotation = 45
frame7.BackgroundColor3 = Color3.fromRGB(160, 220, 175)
frame7.BorderSizePixel = 0
frame7.ZIndex = 14
frame7.Parent = frame6
Instance.new("UICorner", frame7).CornerRadius = UDim.new(1, 0)

local frame8 = Instance.new("Frame")
frame8.AnchorPoint = Vector2.new(0.5, 0.5)
frame8.Position = UDim2.new(0.5, 3, 0.5, -1)
frame8.Size = UDim2.fromOffset(7, 2)
frame8.Rotation = -45
frame8.BackgroundColor3 = Color3.fromRGB(160, 220, 175)
frame8.BorderSizePixel = 0
frame8.ZIndex = 14
frame8.Parent = frame6
Instance.new("UICorner", frame8).CornerRadius = UDim.new(1, 0)

local textButton3 = Instance.new("TextButton")
textButton3.Size = UDim2.new(1, -20, 0, 55)
textButton3.Position = UDim2.fromOffset(10, 120)
textButton3.BackgroundColor3 = Color3.fromRGB(13, 19, 15)
textButton3.BackgroundTransparency = 0.15
textButton3.Text = ""
textButton3.AutoButtonColor = false
textButton3.ZIndex = 11
textButton3.Parent = frame
Instance.new("UICorner", textButton3).CornerRadius = UDim.new(0, 9)
local uiStroke6 = Instance.new("UIStroke", textButton3)
uiStroke6.Color = Color3.fromRGB(35, 70, 43)
uiStroke6.Thickness = 1
uiStroke6.Transparency = 0.3

local textLabel8 = Instance.new("TextLabel")
textLabel8.Size = UDim2.fromOffset(88, 20)
textLabel8.Position = UDim2.fromOffset(12, 8)
textLabel8.BackgroundTransparency = 1
textLabel8.Text = "TELEGUIADO"
textLabel8.TextColor3 = Color3.fromRGB(230, 240, 233)
textLabel8.TextSize = 11
textLabel8.Font = Enum.Font.GothamBold
textLabel8.TextXAlignment = Enum.TextXAlignment.Left
textLabel8.ZIndex = 12
textLabel8.Parent = textButton3

local textLabel9 = Instance.new("TextLabel")
textLabel9.Size = UDim2.fromOffset(88, 14)
textLabel9.Position = UDim2.fromOffset(12, 30)
textLabel9.BackgroundTransparency = 1
textLabel9.Text = "Always targets the highest value"
textLabel9.TextColor3 = Color3.fromRGB(100, 125, 108)
textLabel9.TextSize = 8
textLabel9.Font = Enum.Font.Gotham
textLabel9.TextXAlignment = Enum.TextXAlignment.Left
textLabel9.ZIndex = 12
textLabel9.Parent = textButton3

tbl2.loopButton = Instance.new("TextButton")
tbl2.loopButton.Name = "LoopCheckbox"
tbl2.loopButton.AnchorPoint = Vector2.new(0.5, 0.5)
tbl2.loopButton.Size = UDim2.fromOffset(52, 20)
tbl2.loopButton.Position = UDim2.new(0.56, 0, 0.5, 0)
tbl2.loopButton.BackgroundTransparency = 1
tbl2.loopButton.Text = ""
tbl2.loopButton.AutoButtonColor = false
tbl2.loopButton.ZIndex = 13
tbl2.loopButton.Parent = textButton3

tbl2.loopBox = Instance.new("Frame")
tbl2.loopBox.Size = UDim2.fromOffset(14, 14)
tbl2.loopBox.Position = UDim2.fromOffset(0, 3)
tbl2.loopBox.BackgroundColor3 = Color3.fromRGB(25, 32, 27)
tbl2.loopBox.BorderSizePixel = 0
tbl2.loopBox.ZIndex = 14
tbl2.loopBox.Parent = tbl2.loopButton
Instance.new("UICorner", tbl2.loopBox).CornerRadius = UDim.new(0, 4)
tbl2.loopBoxStroke = Instance.new("UIStroke", tbl2.loopBox)
tbl2.loopBoxStroke.Color = Color3.fromRGB(90, 120, 98)
tbl2.loopBoxStroke.Thickness = 1
tbl2.loopBoxStroke.Transparency = 0.15

tbl2.loopCheck = Instance.new("TextLabel")
tbl2.loopCheck.Size = UDim2.fromScale(1, 1)
tbl2.loopCheck.BackgroundTransparency = 1
tbl2.loopCheck.Text = "X"
tbl2.loopCheck.TextColor3 = Color3.fromRGB(8, 18, 11)
tbl2.loopCheck.TextSize = 11
tbl2.loopCheck.Font = Enum.Font.GothamBold
tbl2.loopCheck.Visible = false
tbl2.loopCheck.ZIndex = 15
tbl2.loopCheck.Parent = tbl2.loopBox

tbl2.loopLabel = Instance.new("TextLabel")
tbl2.loopLabel.Size = UDim2.new(1, -18, 1, 0)
tbl2.loopLabel.Position = UDim2.fromOffset(18, 0)
tbl2.loopLabel.BackgroundTransparency = 1
tbl2.loopLabel.Text = "LOOP"
tbl2.loopLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
tbl2.loopLabel.TextSize = 11
tbl2.loopLabel.Font = Enum.Font.GothamBold
tbl2.loopLabel.TextXAlignment = Enum.TextXAlignment.Left
tbl2.loopLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
tbl2.loopLabel.TextStrokeTransparency = 0
tbl2.loopLabel.ZIndex = 14
tbl2.loopLabel.Parent = tbl2.loopButton

local frame9 = Instance.new("Frame")
frame9.Size = UDim2.fromOffset(38, 20)
frame9.Position = UDim2.new(1, -48, 0.5, -10)
frame9.BackgroundColor3 = Color3.fromRGB(32, 42, 35)
frame9.ZIndex = 12
frame9.Parent = textButton3
Instance.new("UICorner", frame9).CornerRadius = UDim.new(1, 0)

local frame10 = Instance.new("Frame")
frame10.Size = UDim2.fromOffset(14, 14)
frame10.Position = UDim2.new(0, 3, 0.5, -7)
frame10.BackgroundColor3 = Color3.fromRGB(145, 155, 148)
frame10.ZIndex = 13
frame10.Parent = frame9
Instance.new("UICorner", frame10).CornerRadius = UDim.new(1, 0)

local frame11 = Instance.new("Frame")
frame11.Name = "DropdownList"
frame11.Size = UDim2.new(1, -20, 0, n7 + n11)
frame11.Position = UDim2.fromOffset(10, 120)
frame11.BackgroundTransparency = 1
frame11.Visible = false
frame11.ZIndex = 11
frame11.Parent = frame
-- ============================================
-- LennonHub - FIXED VERSION
-- Part 4/6: Dropdown Rows, Rarity Filters, Egg Data
-- ============================================

local tbl12 = {}

tbl2.createDropdownRow = function(arg)
	local textButton4 = Instance.new("TextButton")
	textButton4.Name = "Row" .. arg
	textButton4.Size = UDim2.new(1, 0, 0, tbl3.ROW_H)
	textButton4.Position = UDim2.fromOffset(0, (arg - 1) * (tbl3.ROW_H + tbl3.ROW_GAP))
	textButton4.BackgroundColor3 = Color3.fromRGB(13, 19, 15)
	textButton4.BackgroundTransparency = 0.15
	textButton4.Text = ""
	textButton4.AutoButtonColor = false
	textButton4.ZIndex = 12
	textButton4.Visible = false
	textButton4.Parent = frame11
	Instance.new("UICorner", textButton4).CornerRadius = UDim.new(0, 7)
	local uiStroke7 = Instance.new("UIStroke", textButton4)
	uiStroke7.Color = Color3.fromRGB(35, 70, 43)
	uiStroke7.Thickness = 1
	uiStroke7.Transparency = 0.35
	local textLabel10 = Instance.new("TextLabel")
	textLabel10.Size = UDim2.fromOffset(16, tbl3.ROW_H)
	textLabel10.Position = UDim2.fromOffset(6, 0)
	textLabel10.BackgroundTransparency = 1
	textLabel10.Text = "#" .. arg
	textLabel10.TextColor3 = Color3.fromRGB(90, 130, 100)
	textLabel10.TextSize = 9
	textLabel10.Font = Enum.Font.GothamBold
	textLabel10.ZIndex = 13
	textLabel10.Parent = textButton4
	local frame12 = Instance.new("Frame")
	frame12.Name = "Preview"
	frame12.AnchorPoint = Vector2.new(0, 0.5)
	frame12.Position = UDim2.new(0, 26, 0.5, 0)
	frame12.Size = UDim2.fromOffset(24, 24)
	frame12.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame12.BackgroundTransparency = 0.5
	frame12.BorderSizePixel = 0
	frame12.ClipsDescendants = true
	frame12.ZIndex = 13
	frame12.Parent = textButton4
	Instance.new("UICorner", frame12).CornerRadius = UDim.new(0, 6)
	local textLabel11 = Instance.new("TextLabel")
	textLabel11.Size = UDim2.new(1, -130, 0, 14)
	textLabel11.Position = UDim2.fromOffset(58, 4)
	textLabel11.BackgroundTransparency = 1
	textLabel11.Text = ""
	textLabel11.TextColor3 = Color3.fromRGB(235, 255, 240)
	textLabel11.TextSize = 9
	textLabel11.Font = Enum.Font.GothamBold
	textLabel11.TextXAlignment = Enum.TextXAlignment.Left
	textLabel11.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel11.ZIndex = 13
	textLabel11.Parent = textButton4
	local textLabel12 = Instance.new("TextLabel")
	textLabel12.Size = UDim2.new(1, -130, 0, 11)
	textLabel12.Position = UDim2.fromOffset(58, 17)
	textLabel12.BackgroundTransparency = 1
	textLabel12.Text = ""
	textLabel12.TextColor3 = Color3.fromRGB(170, 190, 178)
	textLabel12.TextSize = 7
	textLabel12.Font = Enum.Font.GothamBold
	textLabel12.TextXAlignment = Enum.TextXAlignment.Left
	textLabel12.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel12.ZIndex = 13
	textLabel12.Parent = textButton4
	local textLabel13 = Instance.new("TextLabel")
	textLabel13.AnchorPoint = Vector2.new(1, 0)
	textLabel13.Size = UDim2.fromOffset(60, 20)
	textLabel13.Position = UDim2.new(1, -8, 0, 5)
	textLabel13.BackgroundTransparency = 1
	textLabel13.Text = ""
	textLabel13.TextColor3 = Color3.fromRGB(50, 255, 110)
	textLabel13.TextSize = 10
	textLabel13.Font = Enum.Font.GothamBold
	textLabel13.TextXAlignment = Enum.TextXAlignment.Right
	textLabel13.ZIndex = 13
	textLabel13.Parent = textButton4

	return {
		Row = textButton4,
		Preview = frame12,
		NameLabel = textLabel11,
		RarityLabel = textLabel12,
		ValueLabel = textLabel13,
		Egg = nil,
		LastUid = nil,
		LastCategory = nil,
	}
end

for i = 1, tbl3.DROPDOWN_ROWS do
	tbl12[i] = tbl2.createDropdownRow(i)
end

local textLabel10 = Instance.new("TextLabel")
textLabel10.Name = "RarityFilterTitle"
textLabel10.Size = UDim2.new(1, 0, 0, 18)
textLabel10.Position = UDim2.fromOffset(0, n6)
textLabel10.BackgroundTransparency = 1
textLabel10.Text = "RARITY FILTER - TP + TELEGUIADO"
textLabel10.TextColor3 = Color3.fromRGB(120, 255, 160)
textLabel10.TextSize = 8
textLabel10.Font = Enum.Font.GothamBold
textLabel10.TextXAlignment = Enum.TextXAlignment.Left
textLabel10.ZIndex = 12
textLabel10.Parent = frame11

local frame12 = Instance.new("Frame")
frame12.Name = "RarityFilterList"
frame12.Size = UDim2.new(1, 0, 0, n11)
frame12.Position = UDim2.fromOffset(0, n7)
frame12.BackgroundTransparency = 1
frame12.Visible = true
frame12.ZIndex = 11
frame12.Parent = frame11

local tbl13 = {}

tbl2.createRarityCheckbox = function(arg, arg2)
	local n13 = (arg - 1) % n8
	local n14 = math.floor((arg - 1) / n8)
	local textButton4 = Instance.new("TextButton")
	textButton4.Name = "RarityCheckbox" .. arg2.Key
	textButton4.Size = UDim2.new(0.5, -3, 0, n9)
	textButton4.Position = UDim2.new(n13 * 0.5, n13 == 0 and 0 or 3, 0, n14 * (n9 + n10))
	textButton4.BackgroundColor3 = Color3.fromRGB(13, 19, 15)
	textButton4.BackgroundTransparency = 0.08
	textButton4.BorderSizePixel = 0
	textButton4.AutoButtonColor = false
	textButton4.Text = ""
	textButton4.ZIndex = 12
	textButton4.Parent = frame12
	Instance.new("UICorner", textButton4).CornerRadius = UDim.new(0, 7)
	local uiStroke7 = Instance.new("UIStroke", textButton4)
	uiStroke7.Color = arg2.Color
	uiStroke7.Thickness = 1
	uiStroke7.Transparency = 0.35
	local textLabel11 = Instance.new("TextLabel")
	textLabel11.Name = "Check"
	textLabel11.Size = UDim2.fromOffset(16, 16)
	textLabel11.Position = UDim2.fromOffset(5, 4)
	textLabel11.BackgroundColor3 = arg2.Color
	textLabel11.BackgroundTransparency = 0.55
	textLabel11.BorderSizePixel = 0
	textLabel11.Text = ""
	textLabel11.TextColor3 = Color3.fromRGB(7, 10, 8)
	textLabel11.TextSize = 12
	textLabel11.Font = Enum.Font.GothamBlack
	textLabel11.ZIndex = 13
	textLabel11.Parent = textButton4
	Instance.new("UICorner", textLabel11).CornerRadius = UDim.new(0, 4)
	local textLabel12 = Instance.new("TextLabel")
	textLabel12.Name = "Label"
	textLabel12.Size = UDim2.new(1, -28, 1, 0)
	textLabel12.Position = UDim2.fromOffset(26, 0)
	textLabel12.BackgroundTransparency = 1
	textLabel12.Text = arg2.Label
	textLabel12.TextColor3 = arg2.Key == "secret" and Color3.fromRGB(255, 255, 255) or arg2.Color
	textLabel12.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel12.TextStrokeTransparency = arg2.Key == "secret" and 0 or 1
	textLabel12.TextSize = 8
	textLabel12.Font = Enum.Font.GothamBold
	textLabel12.TextXAlignment = Enum.TextXAlignment.Left
	textLabel12.ZIndex = 13
	textLabel12.Parent = textButton4
	return { Row = textButton4, Box = textLabel11, Stroke = uiStroke7, Label = textLabel12, Option = arg2 }
end

for i, v15 in ipairs(tbl5) do
	tbl13[v15.Key] = tbl2.createRarityCheckbox(i, v15)
end

tbl2.updateRarityChecks = function()
	for _, v15 in ipairs(tbl5) do
		local v16 = tbl13[v15.Key]
		local flag2 = tbl4.rarityFilter[v15.Key] == true
		local flag3 = v15.Key == "secret"
		v16.Label.TextColor3 = flag3 and Color3.fromRGB(255, 255, 255) or v15.Color
		v16.Label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		v16.Label.TextStrokeTransparency = flag3 and 0 or 1
		v16.Box.Text = flag2 and "X" or ""
		v16.Box.BackgroundColor3 = v15.Color
		v16.Box.BackgroundTransparency = flag2 and 0 or 0.55
		v16.Box.TextColor3 = flag2 and Color3.fromRGB(10, 12, 10) or v15.Color
		v16.Stroke.Color = v15.Color
		v16.Stroke.Transparency = flag2 and 0 or 0.35
		v16.Row.BackgroundColor3 = flag2 and Color3.fromRGB(24, 48, 31) or Color3.fromRGB(13, 19, 15)
	end
end

tbl2.attachViewport = function(arg, arg2)
	if not AssetViewport then
		return
	end

	local ok, result = pcall(function()
		return AssetViewport.Mount(arg)
	end)

	if not ok or not result then
		return
	end
	local v15 = result
	v15.Size = UDim2.fromScale(1, 1)
	v15.Position = UDim2.fromScale(0.5, 0.5)
	v15.AnchorPoint = Vector2.new(0.5, 0.5)
	v15.BackgroundTransparency = 1
	v15.ZIndex = 14

	if not pcall(function()
		return AssetViewport.ShowAsset(arg2, v15, true)
	end) then
		if v15 then
			v15:Destroy()
		end

		return
	end
end

local v15 = nil

tbl2.updatePetPreview = function(arg)
	if not frame.Visible then
		v15 = nil
		return
	end

	if v15 == arg and frame5:FindFirstChild("Preview") then
		return
	end
	v15 = arg
	local preview = frame5:FindFirstChild("Preview")

	if preview then
		preview:Destroy()
	end

	if not arg then
		return
	end
	local frame13 = Instance.new("Frame")
	frame13.Name = "Preview"
	frame13.AnchorPoint = Vector2.new(0, 0.5)
	frame13.Position = UDim2.new(0, 6, 0.5, 0)
	frame13.Size = UDim2.fromOffset(40, 40)
	frame13.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame13.BackgroundTransparency = 0.5
	frame13.BorderSizePixel = 0
	frame13.ClipsDescendants = true
	frame13.ZIndex = 13
	frame13.Parent = frame5
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 7)
	uiCorner.Parent = frame13
	tbl2.attachViewport(frame13, arg)
end

tbl2.formatNumber = function(arg)
	local n13 = tonumber(arg) or 0

	local function fn2(arg2)
		return (string.format("%.2f", arg2):gsub("(%..-)0+$", "%1"):gsub("%.$", ""))
	end

	local n14 = math.abs(n13)

	for _, v16 in ipairs({ { 1e12, "T" }, { 1e9, "B" }, { 1000000, "M" }, { 1000, "K" } }) do
		if n14 >= v16[1] then
			local v17 = v16[2]
			return fn2(n13 / v16[1]) .. v17
		end
	end

	return tostring(math.floor(n13 + 0.5))
end

local tbl14 = {
	common = Color3.fromRGB(185, 185, 185),
	uncommon = Color3.fromRGB(80, 220, 100),
	rare = Color3.fromRGB(70, 150, 255),
	epic = Color3.fromRGB(170, 75, 255),
	legendary = Color3.fromRGB(255, 190, 45),
	mythic = Color3.fromRGB(255, 75, 75),
	cosmic = Color3.fromRGB(215, 90, 255),
	eternal = Color3.fromRGB(255, 220, 80),
}

tbl2.getRarityColor = function(arg)
	if type(arg) == "table" then
		local color = arg.Color or arg.Color3 or arg.RarityColor
		if typeof(color) == "Color3" then
			return color
		end

		if typeof(color) == "ColorSequence" then
			return color.Keypoints[1].Value
		end

		if type(color) == "string" then
			local str2 = color:gsub("#", "")

			if #str2 == 6 then
				local num = tonumber(str2:sub(1, 2), 16)
				local num2 = tonumber(str2:sub(3, 4), 16)
				local num3 = tonumber(str2:sub(5, 6), 16)
				if num and num2 and num3 then
					return Color3.fromRGB(num, num2, num3)
				end
			end
		end
	end

	return tbl14[string.lower(tostring(type(arg) == "table" and (arg.DisplayName or arg.Name) or arg or ""))] or Color3.fromRGB(170, 190, 178)
end

tbl2.getScaleMultiplier = function(arg)
	local n13 = tonumber(arg) or 1
	if n13 <= 5 then
		return n13 ^ 1.85
	end
	return (n13 / 5) ^ 1.2 * 19.637875755794113
end

tbl2.getEggData = function(arg)
	local v16 = Assets.Directory[arg.AssetCategory]
	if not v16 then
		return nil
	end
	local n13 = tonumber(v16.EarningRate) or 0
	local n14 = tonumber(arg.AssetScale) or 1
	local flag2 = arg.Mutations and #arg.Mutations > 0
	local n15 = 1

	if flag2 then
		local v17 = Mutations
		local earningsFor

		if Mutations then
			earningsFor = Mutations.EarningsFor
		else
			earningsFor = v17
		end

		if type(earningsFor) == "function" then
			local ok, result = pcall(function()
				return earningsFor(arg.Mutations)
			end)

			if ok then
				n15 = tonumber(result) or 1
			end
		end
	end

	local n16 = n13 * tbl2.getScaleMultiplier(n14) * n15
	local color = Color3.fromRGB(170, 190, 178)
	local n17 = 0
	local str2 = ""

	if v16.Rarity then
		n17 = v16.Rarity.RarityNumber or 0
		str2 = v16.Rarity.DisplayName or v16.Rarity.Name or ""
		color = tbl2.getOfficialRarityColor(str2)
	end

	return {
		Uid = arg.Uid,
		Category = arg.AssetCategory,
		Name = v16.DisplayName or arg.AssetCategory,
		Generation = math.round(n16),
		Position = arg.BottomCFrame.Position,
		BottomCFrame = arg.BottomCFrame,
		Rarity = n17,
		RarityName = str2,
		RarityColor = color,
		BaseRate = n13,
		Scale = n14,
	}
end

tbl2.getGroundPosition = function()
	local objects = workspace:FindFirstChild("World")
	if not objects then
		return nil
	end
	local areas = objects:FindFirstChild("Areas")
	if not areas then
		return nil
	end
	local ground = areas:FindFirstChild("Ground")
	if not ground then
		return nil
	end

	if ground:IsA("BasePart") then
		return ground.Position + Vector3.new(0, ground.Size.Y * 0.5 + tbl3.GROUND_OFFSET, 0)
	end

	if ground:IsA("Model") then
		local pivot = ground:GetPivot()
		local boundingBox, v16 = ground:GetBoundingBox()
		return pivot.Position + Vector3.new(0, v16.Y * 0.5 + tbl3.GROUND_OFFSET, 0)
	end

	local basePart = ground:FindFirstChildWhichIsA("BasePart", true)
	if basePart then
		return basePart.Position + Vector3.new(0, basePart.Size.Y * 0.5 + tbl3.GROUND_OFFSET, 0)
	end
	return nil
end

tbl2.refreshDropdownRows = function()
	for i = 1, tbl3.DROPDOWN_ROWS do
		local v16 = tbl12[i]
		local v17 = tbl4.filteredEggs[i]
		v16.Egg = v17
		local lastUid = v17 and tostring(v17.Uid) or nil
		local category = v17 and v17.Category or nil

		if v16.LastUid ~= lastUid or v16.LastCategory ~= category then
			for _, child in ipairs(v16.Preview:GetChildren()) do
				child:Destroy()
			end

			v16.LastUid = lastUid
			v16.LastCategory = category

			if v17 then
				tbl2.attachViewport(v16.Preview, category)
			end
		end

		if v17 then
			v16.Row.Visible = true
			local text = tostring(v17.Name or "UNKNOWN")
			local text2 = tostring(v17.RarityName or "")
			local v18 = tbl2.formatNumber(v17.Generation or 0)

			if v16.NameLabel.Text ~= text then
				v16.NameLabel.Text = text
			end

			if v16.RarityLabel.Text ~= text2 then
				v16.RarityLabel.Text = text2
			end

			local rarityColor = v17.RarityColor or Color3.fromRGB(170, 190, 178)

			if v16.RarityLabel.TextColor3 ~= rarityColor then
				v16.RarityLabel.TextColor3 = rarityColor
			end

			if v16.ValueLabel.Text ~= v18 then
				v16.ValueLabel.Text = v18
			end
		else
			v16.Row.Visible = false

			if v16.NameLabel.Text ~= "" then
				v16.NameLabel.Text = ""
			end

			if v16.RarityLabel.Text ~= "" then
				v16.RarityLabel.Text = ""
			end

			if v16.ValueLabel.Text ~= "" then
				v16.ValueLabel.Text = ""
			end
		end
	end
end

tbl2.closeDropdown = function()
	if not tbl4.dropdownOpen then
		return
	end
	tbl4.dropdownOpen = false
	frame11.Visible = false
	textButton3.Visible = true
	TweenService:Create(frame6, TweenInfo.new(0.15), { Rotation = 0 }):Play()
	TweenService:Create(frame, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(262, 185) }):Play()
end

tbl2.openDropdown = function()
	if tbl4.dropdownOpen then
		return
	end
	tbl4.dropdownOpen = true
	tbl2.refreshDropdownRows()
	textButton3.Visible = false
	frame11.Visible = true
	TweenService:Create(frame6, TweenInfo.new(0.15), { Rotation = 180 }):Play()
	TweenService:Create(frame, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(262, n12) }):Play()
end

textButton2.MouseButton1Click:Connect(function()
	if tbl4.dropdownOpen then
		tbl2.closeDropdown()
	else
		tbl2.openDropdown()
	end
end)

for i = 1, tbl3.DROPDOWN_ROWS do
	local v16 = tbl12[i]

	v16.Row.MouseButton1Click:Connect(function()
		local egg = v16.Egg

		if egg then
			tbl4.selectedEgg = egg
			tbl4.selectedUid = egg.Uid
			tbl4.targetEgg = nil

			if tbl4.enabled and not tbl4.carrying and not tbl4.carryLocked and not tbl4.isProtecting and not tbl4.isDelivering then
				tbl2.finishMove()
				tbl4.isStealing = false
			end
		end

		tbl2.closeDropdown()
	end)

	v16.Row.MouseEnter:Connect(function()
		TweenService:Create(v16.Row, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(19, 28, 21) }):Play()
	end)

	v16.Row.MouseLeave:Connect(function()
		TweenService:Create(v16.Row, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(13, 19, 15) }):Play()
	end)
end

tbl2.refreshEggs = function(arg)
	local now = tick()
	if not arg and now - tbl4.lastRefresh < tbl3.REFRESH_INTERVAL then
		return tbl4.eggs
	end

	local ok, result = pcall(function()
		return tbl.AskFieldEggSnapshot:InvokeServer()
	end)

	if not ok then
		return tbl4.eggs
	end
	local eggs = tbl4.eggs
	table.clear(eggs)

	if result and result.Records then
		for _, record in ipairs(result.Records) do
			if record.State == "Slot" or record.State == "Dropped" then
				local v16 = tbl2.getEggData(record)

				if v16 then
					eggs[#eggs + 1] = v16
				end
			end
		end
	end

	table.sort(eggs, function(arg2, arg3)
		return arg2.Generation > arg3.Generation
	end)

	local filteredEggs = tbl4.filteredEggs
	table.clear(filteredEggs)

	for _, egg in ipairs(eggs) do
		if tbl2.eggMatchesRarityFilter(egg) then
			filteredEggs[#filteredEggs + 1] = egg
		end
	end

	tbl4.bestEgg = tbl4.filteredEggs[1]
	tbl4.lastRefresh = now
	return tbl4.eggs
end

tbl2.getActiveTargetEgg = function()
	if tbl4.selectedEgg then
		for _, filteredEgg in ipairs(tbl4.filteredEggs) do
			if filteredEgg.Uid == tbl4.selectedEgg.Uid then
				tbl4.selectedEgg = filteredEgg
				tbl4.selectedUid = filteredEgg.Uid
				return filteredEgg
			end
		end

		tbl4.selectedEgg = nil
		tbl4.selectedUid = nil
	end

	return tbl4.bestEgg
end

for _, v16 in ipairs(tbl5) do
	local v17 = tbl13[v16.Key]

	v17.Row.MouseButton1Click:Connect(function()
		tbl4.rarityFilter[v16.Key] = not tbl4.rarityFilter[v16.Key]
		tbl4.selectedEgg = nil
		tbl4.selectedUid = nil
		tbl4.targetEgg = nil
		tbl4.lastRefresh = 0
		tbl2.updateRarityChecks()
		tbl2.refreshEggs(true)

		if tbl4.enabled and tbl4.mode == "TELEGUIADO" and not tbl4.carrying and not tbl4.carryLocked and not tbl4.isProtecting and not tbl4.isDelivering then
			tbl2.finishMove()
			tbl4.isStealing = false
		end
	end)

	v17.Row.MouseEnter:Connect(function()
		if not tbl4.rarityFilter[v16.Key] then
			TweenService:Create(v17.Row, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(19, 28, 21) }):Play()
		end
	end)

	v17.Row.MouseLeave:Connect(function()
		if not tbl4.rarityFilter[v16.Key] then
			TweenService:Create(v17.Row, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(13, 19, 15) }):Play()
		end
	end)
end

tbl2.updateRarityChecks()

local beam = nil
local attachment = nil
local attachment2 = nil

tbl2.clearBeam = function()
	if beam then
		beam:Destroy()
		beam = nil
	end

	if attachment then
		attachment:Destroy()
		attachment = nil
	end

	if attachment2 then
		if attachment2.Parent then
			attachment2.Parent:Destroy()
		end

		attachment2 = nil
	end
end

tbl2.createBeam = function(arg)
	if not humanoidRootPart or not humanoidRootPart.Parent or not arg then
		return
	end
	tbl2.clearBeam()
	attachment = Instance.new("Attachment")
	attachment.Name = "LennonBeamOrigin"
	attachment.Parent = humanoidRootPart
	local part = Instance.new("Part")
	part.Name = "LennonBeamTarget"
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CFrame = CFrame.new(arg)
	part.Parent = workspace
	attachment2 = Instance.new("Attachment")
	attachment2.Parent = part
	beam = Instance.new("Beam")
	beam.Name = "LennonTargetBeam"
	beam.Attachment0 = attachment
	beam.Attachment1 = attachment2
	beam.Width0 = tbl3.BEAM_WIDTH
	beam.Width1 = tbl3.BEAM_WIDTH
	beam.FaceCamera = true
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.Color = ColorSequence.new(Color3.fromRGB(50, 255, 110))
	beam.Parent = humanoidRootPart
end

tbl2.updateBestDisplay = function()
	tbl2.refreshEggs()
	local v16 = tbl2.getActiveTargetEgg()

	pcall(function()
		if not v16 then
			if textLabel5 and textLabel5.Parent and textLabel5.Text ~= "NO EGG FOUND" then
				textLabel5.Text = "NO EGG FOUND"
			end

			if textLabel6 and textLabel6.Parent and textLabel6.Text ~= "" then
				textLabel6.Text = ""
			end

			if textLabel7 and textLabel7.Parent and textLabel7.Text ~= "--" then
				textLabel7.Text = "--"
			end

			tbl2.updatePetPreview(nil)
		else
			local text = tostring(v16.Name or "UNKNOWN")
			local text2 = tostring(v16.RarityName or "")
			local v17 = tbl2.formatNumber(v16.Generation or 0)

			if textLabel5 and textLabel5.Parent and textLabel5.Text ~= text then
				textLabel5.Text = text
			end

			if textLabel6 and textLabel6.Parent then
				if textLabel6.Text ~= text2 then
					textLabel6.Text = text2
				end

				local rarityColor = v16.RarityColor or Color3.fromRGB(170, 190, 178)

				if textLabel6.TextColor3 ~= rarityColor then
					textLabel6.TextColor3 = rarityColor
				end
			end

			if textLabel7 and textLabel7.Parent and textLabel7.Text ~= v17 then
				textLabel7.Text = v17
			end

			tbl2.updatePetPreview(v16.Category)
		end
	end)

	if tbl4.dropdownOpen then
		tbl2.refreshDropdownRows()
	end

	return v16
end

tbl2.updateLoopUI = function()
	if not tbl2.loopBox or not tbl2.loopBox.Parent then
		return
	end

	if tbl4.loopEnabled then
		tbl2.loopBox.BackgroundColor3 = Color3.fromRGB(50, 255, 110)
		tbl2.loopBoxStroke.Color = Color3.fromRGB(90, 255, 140)
		tbl2.loopCheck.Visible = true
		tbl2.loopLabel.TextColor3 = Color3.fromRGB(180, 255, 198)
	else
		tbl2.loopBox.BackgroundColor3 = Color3.fromRGB(25, 32, 27)
		tbl2.loopBoxStroke.Color = Color3.fromRGB(90, 120, 98)
		tbl2.loopCheck.Visible = false
		tbl2.loopLabel.TextColor3 = Color3.fromRGB(145, 165, 150)
	end
end

tbl2.updateToggle = function()
	if tbl4.enabled then
		TweenService:Create(frame9, TweenInfo.new(0.18, Enum.EasingStyle.Quart), { BackgroundColor3 = Color3.fromRGB(30, 205, 90) }):Play()
		TweenService:Create(frame10, TweenInfo.new(0.18, Enum.EasingStyle.Quart), { Position = UDim2.new(1, -17, 0.5, -7), BackgroundColor3 = Color3.fromRGB(240, 255, 242) }):Play()
		uiStroke6.Color = Color3.fromRGB(40, 190, 80)

		if tbl4.waitingForDay then
			textLabel9.Text = tbl2.isDaytime() and "WAITING FOR GATE" or "WAITING FOR DAY"
		elseif tbl4.runLoop then
			textLabel9.Text = "LOOP ACTIVE"
		else
			textLabel9.Text = "ONE SHOT IN PROGRESS"
		end
	else
		TweenService:Create(frame9, TweenInfo.new(0.18, Enum.EasingStyle.Quart), { BackgroundColor3 = Color3.fromRGB(32, 42, 35) }):Play()
		TweenService:Create(frame10, TweenInfo.new(0.18, Enum.EasingStyle.Quart), { Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Color3.fromRGB(145, 155, 148) }):Play()
		uiStroke6.Color = Color3.fromRGB(35, 70, 43)
		textLabel9.Text = tbl4.loopEnabled and "LOOP READY" or "ONE SHOT"
	end
end
-- ============================================
-- LennonHub - FIXED VERSION
-- Part 5/6: Carry Logic, Delivery, Move Functions
-- ============================================

tbl2.startEggProtection = function(heldEggUid)
	if not heldEggUid then
		return
	end

	if tbl4.isProtecting and tbl4.heldEggUid == heldEggUid then
		return
	end
	tbl4.isProtecting = true
	tbl4.heldEggUid = heldEggUid
	tbl4.lastProtectTime = 0

	task.spawn(function()
		while tbl4.isProtecting and tbl4.heldEggUid == heldEggUid do
			tbl4.lastProtectTime = tick()

			local ok, result = pcall(function()
				return tbl.AskFieldEggCarry:InvokeServer({ Uid = heldEggUid })
			end)

			if ok and result == true then
				tbl4.carrying = true
			end

			task.wait(tbl3.PROTECT_INTERVAL)
		end
	end)
end

tbl2.resetCarryState = function()
	tbl4.carrying = false
	tbl4.carryLocked = false
	tbl4.isProtecting = false
	tbl4.heldEggUid = nil
	tbl4.targetEgg = nil
	tbl2.clearBeam()
	tbl2.unequipAllTools()
end

tbl2.startDelivery = function()
end

tbl2.startSpammingCarry = function(heldEggUid)
	if not heldEggUid or tbl4.isStealing then
		return
	end

	if tbl4.carrying and tbl4.heldEggUid == heldEggUid then
		return
	end
	tbl4.isStealing = true
	tbl4.lastSpamTime = 0

	task.spawn(function()
		while true do
			if tbl4.isStealing and not tbl4.carrying then
				local now = tick()

				if not (tbl3.SPAM_INTERVAL <= now - tbl4.lastSpamTime) then
					RunService.Heartbeat:Wait()
					continue
				else
					tbl4.lastSpamTime = now

					local ok, result = pcall(function()
						return tbl.AskFieldEggCarry:InvokeServer({ Uid = heldEggUid })
					end)

					if ok and result == true then
						tbl4.isStealing = false
						tbl4.carrying = true
						tbl4.heldEggUid = heldEggUid

						tbl4.carryLocked = true
						-- FIX: تم حذف السطر المعطوب ;(nil)(...) الذي كان يسبب خطأ
						tbl2.spawnBossForEgg(tbl4.targetEgg or tbl2.getActiveTargetEgg())

						task.spawn(function()
							tbl2.startEggProtection(heldEggUid)
						end)

						task.spawn(function()
							local v16 = tbl2.getGroundPosition()
							local v17 = tbl2.getBossDeliveryPosition(v16)

							if v16 and v17 then
								tbl4.isDelivering = true
								tbl2.clearBeam()
								tbl2.createBeam(v16)

								tbl2.startMove(v17, function()
									tbl4.isDelivering = false
									tbl2.cleanupBossMount()
									tbl2.resetCarryState()
									tbl2.completeGuidedCycle()
								end, true)
							end
						end)

						break
					else
						RunService.Heartbeat:Wait()
						continue
					end
				end
			end

			break
		end

		tbl4.isStealing = false
	end)
end

tbl2.completeGuidedCycle = function()
	if not tbl4.guidedCycleActive then
		return
	end
	tbl4.guidedCycleActive = false
	tbl4.lastRefresh = 0
	if tbl4.mode ~= "TELEGUIADO" then
		return
	end

	if tbl4.enabled and tbl4.runLoop then
		tbl2.updateToggle()
		return
	end
	tbl4.enabled = false
	tbl4.waitingForDay = false
	tbl4.runLoop = false
	tbl2.updateToggle()
end

tbl2.startDelivery = function()
	if tbl4.isDelivering then
		return
	end
	local v16 = tbl2.getGroundPosition()
	local v17 = tbl2.getBossDeliveryPosition(v16)
	if not v16 or not v17 then
		return
	end
	tbl4.isDelivering = true
	tbl2.clearBeam()
	tbl2.createBeam(v16)

	if humanoidRootPart and humanoidRootPart.Parent then
		local vector = Vector3.new(v17.X - humanoidRootPart.Position.X, 0, v17.Z - humanoidRootPart.Position.Z)

		if vector.Magnitude > 0.01 then
			humanoidRootPart.CFrame = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + vector.Unit)
		end
	end

	tbl2.startMove(v17, function()
		tbl4.isDelivering = false
		tbl2.cleanupBossMount()
		tbl2.resetCarryState()
		tbl2.completeGuidedCycle()
	end, true)
end

tbl2.moveToBestEggTP = function()
	if tbl4.carrying or tbl4.carryLocked or tbl4.isProtecting or tbl4.isDelivering or tbl4.isMoving or tbl4.isStealing then
		return false
	end
	tbl2.refreshEggs(true)
	local v16 = tbl2.getActiveTargetEgg()
	if not v16 or not humanoidRootPart or not humanoidRootPart.Parent then
		return false
	end

	if tbl4.mode == "TELEGUIADO" then
		tbl4.guidedCycleActive = true

		if tbl4.enabled then
			tbl2.updateToggle()
		end
	end

	tbl4.targetEgg = v16
	local position = v16.Position
	tbl2.createBeam(position)
	if (position - humanoidRootPart.Position).Magnitude <= tbl3.SPAWN_OFFSET then
		tbl2.startSpammingCarry(v16.Uid)
		return
	end

	tbl2.startMove(position - (position - humanoidRootPart.Position).Unit * tbl3.SPAWN_OFFSET, function()
		if tbl4.enabled and not tbl4.carrying and not tbl4.carryLocked and not tbl4.isProtecting and not tbl4.isDelivering and tbl4.targetEgg and tbl4.targetEgg.Uid == v16.Uid then
			tbl2.startSpammingCarry(v16.Uid)
		end
	end)

	return true
end

tbl2.cancelEverything = function()
	tbl2.cleanupBossMount()
	tbl2.stopCurrentTween(true)
	tbl2.restoreOriginalHumanoid()
	tbl4.isMoving = false
	tbl4.moveTarget = nil
	tbl4.onArrive = nil
	tbl4.isStealing = false
	tbl4.isProtecting = false
	tbl4.isDelivering = false
	tbl4.targetEgg = nil
	tbl4.heldEggUid = nil
	tbl4.carrying = false
	tbl4.carryLocked = false
	tbl4.guidedCycleActive = false
	tbl2.clearBeam()
end

tbl2.setupCharacter = function(arg)
	if tbl2.motorAddedConn then
		tbl2.motorAddedConn:Disconnect()
		tbl2.motorAddedConn = nil
	end

	if tbl2.motorRemovingConn then
		tbl2.motorRemovingConn:Disconnect()
		tbl2.motorRemovingConn = nil
	end

	v = arg
	humanoidRootPart = arg:WaitForChild("HumanoidRootPart")
	humanoid = arg:FindFirstChildOfClass("Humanoid")
	tbl2.motorCache = {}

	tbl2.walk(arg, function(arg2)
		if arg2:IsA("Motor6D") then
			tbl2.motorCache[#tbl2.motorCache + 1] = arg2
		end
	end)

	tbl2.motorAddedConn = arg.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("Motor6D") then
			table.insert(tbl2.motorCache, descendant)
		end
	end)

	tbl2.motorRemovingConn = arg.DescendantRemoving:Connect(function(descendant)
		if not descendant:IsA("Motor6D") then
			return
		end

		for i = #tbl2.motorCache, 1, -1 do
			if tbl2.motorCache[i] == descendant then
				table.remove(tbl2.motorCache, i)
				break
			end
		end
	end)
end

tbl.FieldEggCarry.OnClientEvent:Connect(function(arg)
	if tbl2.newTGRuntime and tbl2.newTGRuntime.running then
		return
	end

	if not arg or not arg.Uid then
		return
	end
	local uid = arg.Uid

	if arg.CarrierUserId == localPlayer.UserId then
		if uid == tbl4.heldEggUid then
			tbl4.carrying = true
			return
		end

		if tbl4.targetEgg and uid == tbl4.targetEgg.Uid then
			tbl4.carrying = true
			tbl4.heldEggUid = uid
			tbl4.carryLocked = true
			tbl4.isStealing = false
			tbl2.spawnBossForEgg(tbl4.targetEgg or tbl2.getActiveTargetEgg())

			task.spawn(function()
				tbl2.startEggProtection(uid)
			end)

			task.spawn(function()
				tbl2.startDelivery()
			end)
		end

		return
	end

	if uid == tbl4.heldEggUid then
		tbl4.carrying = false
		tbl4.carryLocked = false

		if not tbl4.isProtecting then
			task.spawn(function()
				tbl2.startEggProtection(uid)
			end)
		end

		return
	end

	if tbl4.targetEgg and uid == tbl4.targetEgg.Uid then
		tbl4.carrying = false

		if not tbl4.isStealing then
			task.defer(function()
				task.wait(0.02)

				if tbl4.targetEgg and tbl4.targetEgg.Uid == uid and not tbl4.carrying then
					tbl2.startSpammingCarry(uid)
				end
			end)
		end
	end
end)

tbl2.newTGRuntime = tbl2.newTGRuntime or {
	running = false,
	cleanup = nil,
	cooldownUntil = 0,
	desyncOriginal = nil,
	desyncOriginalState = nil,
	desyncFake = nil,
	desyncCharacter = nil,
	desyncStateConn = nil,
	desyncDescConn = nil,
	restoreDesync = nil,
}

tbl2.stopNewTeleguiado = function()
	local newTGRuntime = tbl2.newTGRuntime
	local cleanup = newTGRuntime.cleanup
	newTGRuntime.cleanup = nil

	if cleanup then
		pcall(cleanup)
	end

	local restoreDesync = newTGRuntime.restoreDesync

	if restoreDesync then
		pcall(restoreDesync)
	end

	newTGRuntime.running = false
end

tbl2.startNewTeleguiado = function()
	local newTGRuntime = tbl2.newTGRuntime
	if newTGRuntime.running then
		return false
	end

	if tick() < (newTGRuntime.cooldownUntil or 0) then
		return false
	end

	if not tbl4.enabled then
		return false
	end

	if not tbl2.canLeaveForSteal() then
		tbl4.waitingForDay = true
		tbl2.updateToggle()
		return false
	end

	tbl4.mode = "TELEGUIADO"
	tbl4.waitingForDay = false
	tbl4.targetEgg = nil
	tbl4.isMoving = false
	tbl4.isStealing = false
	tbl4.isProtecting = false
	tbl4.isDelivering = false
	tbl4.carrying = false
	tbl4.carryLocked = false
	tbl4.heldEggUid = nil
	newTGRuntime.running = true
	newTGRuntime.cleanup = nil
	tbl2.updateToggle()

	task.spawn(function()
		local ok, result = xpcall(function()
			local Players2 = game:GetService("Players")
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			local TweenService2 = game:GetService("TweenService")
			local RunService2 = game:GetService("RunService")
			local localPlayer2 = Players2.LocalPlayer
			local v16 = tbl4
			local newTGRuntime2 = tbl2.newTGRuntime
			local EggState = require(ReplicatedStorage2.Client.EggState)
			local Remotes = require(ReplicatedStorage2.Shared.Remotes)
			local RagdollJoints = require(ReplicatedStorage2.Shared.Modules.RagdollJoints)
			local Mutations2 = require(ReplicatedStorage2.Shared.Modules.Mutations)
			local Assets2 = require(ReplicatedStorage2.Data.Assets)
			local AreaEggSlotIdentity = require(ReplicatedStorage2.Shared.Util.AreaEggSlotIdentity)
			local areas = workspace.World.Areas
			local guardAreas2 = areas:WaitForChild("GuardAreas")
			local ground = areas:WaitForChild("Ground")
			local n13 = 800
			local character = localPlayer2.Character or localPlayer2.CharacterAdded:Wait()
			local humanoidRootPart2 = character:WaitForChild("HumanoidRootPart")
			local desyncOriginal, desyncOriginalState, desyncFake

			if newTGRuntime2.desyncCharacter == character and newTGRuntime2.desyncOriginal ~= nil and newTGRuntime2.desyncFake ~= nil and newTGRuntime2.desyncFake.Parent == character then
				desyncOriginal = newTGRuntime2.desyncOriginal
				desyncOriginalState = newTGRuntime2.desyncOriginalState
				desyncFake = newTGRuntime2.desyncFake
			else
				local humanoid2 = character:WaitForChild("Humanoid")
				desyncOriginal = humanoid2

				desyncOriginalState = {
					Archivable = humanoid2.Archivable,
					BreakJointsOnDeath = humanoid2.BreakJointsOnDeath,
					PlatformStand = humanoid2.PlatformStand,
					AutoRotate = humanoid2.AutoRotate,
					Sit = humanoid2.Sit,
					WalkSpeed = humanoid2.WalkSpeed,
					JumpPower = humanoid2.JumpPower,
					JumpHeight = humanoid2.JumpHeight,
					UseJumpPower = humanoid2.UseJumpPower,
					HipHeight = humanoid2.HipHeight,
					Health = humanoid2.Health,
					State = humanoid2:GetState(),
				}

				humanoid2.Archivable = true
				desyncFake = humanoid2:Clone()
				desyncFake.Name = "Humanoid"
				desyncFake.BreakJointsOnDeath = false
				desyncFake:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
				desyncFake:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
				desyncFake:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

				pcall(function()
					desyncFake:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
				end)

				desyncFake.Health = desyncFake.MaxHealth

				pcall(function()
					desyncFake.RequiresNeck = false
				end)

				humanoid2.Parent = nil
				desyncFake.Parent = character
				desyncFake.PlatformStand = false
				desyncFake.Sit = false
				newTGRuntime2.desyncOriginal = desyncOriginal
				newTGRuntime2.desyncOriginalState = desyncOriginalState
				newTGRuntime2.desyncFake = desyncFake
				newTGRuntime2.desyncCharacter = character

				if newTGRuntime2.desyncStateConn then
					newTGRuntime2.desyncStateConn:Disconnect()
				end

				newTGRuntime2.desyncStateConn = desyncFake.StateChanged:Connect(function(old, new)
					if newTGRuntime2.desyncFake ~= desyncFake then
						return
					end

					if new == Enum.HumanoidStateType.Ragdoll or new == Enum.HumanoidStateType.FallingDown or new == Enum.HumanoidStateType.Physics then
						desyncFake.PlatformStand = false
						desyncFake.Sit = false

						pcall(function()
							desyncFake:ChangeState(Enum.HumanoidStateType.GettingUp)
						end)
					end
				end)

				local flag2 = false

				if newTGRuntime2.desyncDescConn then
					newTGRuntime2.desyncDescConn:Disconnect()
				end

				newTGRuntime2.desyncDescConn = character.DescendantAdded:Connect(function(descendant)
					if flag2 or newTGRuntime2.desyncFake ~= desyncFake then
						return
					end

					if not descendant:GetAttribute("RagdollConstraint") and not descendant:GetAttribute("RagdollAttachment") then
						return
					end
					flag2 = true

					task.defer(function()
						pcall(RagdollJoints.Release, character)

						if desyncFake and desyncFake.Parent then
							desyncFake.PlatformStand = false
							desyncFake.Sit = false

							pcall(function()
								desyncFake:ChangeState(Enum.HumanoidStateType.GettingUp)
							end)
						end

						if humanoidRootPart2 and humanoidRootPart2.Parent then
							humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
							humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
						end

						flag2 = false
					end)
				end)
			end

			desyncFake.PlatformStand = false
			desyncFake.Sit = false
			desyncFake.AutoRotate = true
			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			workspace.CurrentCamera.CameraSubject = desyncFake
			local v17 = nil
			local v18 = nil

			local function fn2()
				if v17 then
					pcall(function()
						v17:Stop(0.12)
					end)

					v17 = nil
				end

				if v18 then
					pcall(function()
						v18:Destroy()
					end)

					v18 = nil
				end
			end

			local function fn3(arg)
				local animate2 = character and character:FindFirstChild("Animate")

				if animate2 then
					animate2 = animate2:FindFirstChild("idle") or animate2:FindFirstChild("Idle")
				end

				local animationId = nil

				if animate2 then
					local n14 = -math.huge
					animationId = nil

					for _, descendant in ipairs(animate2:GetDescendants()) do
						if descendant:IsA("Animation") and descendant.AnimationId ~= "" then
							local weight = descendant:FindFirstChild("Weight")
							local isNumberValue = weight and weight:IsA("NumberValue")
							local n15 = 1

							if isNumberValue then
								n15 = weight.Value
							end

							if n14 < n15 then
								animationId = descendant.AnimationId
								n14 = n15
							end
						end
					end
				end

				if animationId and animationId ~= "" then
					return animationId
				end

				if arg then
					local ok, result = pcall(function()
						return arg:GetAppliedDescription()
					end)

					if ok and result then
						local num = tonumber(result.IdleAnimation)
						if num and num > 0 then
							return "rbxassetid://" .. tostring(num)
						end
					end
				end

				return nil
			end

			local function fn4()
				local v19 = character
				local humanoid2

				if character then
					humanoid2 = character:FindFirstChildOfClass("Humanoid")
				else
					humanoid2 = v19
				end

				if not humanoid2 then
					return
				end
				humanoid2.Sit = false
				humanoid2.PlatformStand = false

				pcall(function()
					humanoid2:Move(Vector3.zero, false)
				end)

				if v17 and v17.IsPlaying then
					return
				end
				fn2()
				local v20 = fn3(humanoid2)
				if not v20 then
					return
				end
				local animator = humanoid2:FindFirstChildOfClass("Animator")

				if not animator then
					animator = Instance.new("Animator")
					animator.Parent = humanoid2
				end

				for _, v21 in ipairs(animator:GetPlayingAnimationTracks()) do
					if v21.Priority == Enum.AnimationPriority.Movement then
						pcall(function()
							v21:Stop(0.08)
						end)
					end
				end

				local animation2 = Instance.new("Animation")
				animation2.Name = "LennonTweenOwnIdle"
				animation2.AnimationId = v20

				local ok, result = pcall(function()
					return animator:LoadAnimation(animation2)
				end)

				if not ok or not result then
					animation2:Destroy()
					return
				end
				result.Looped = true
				result.Priority = Enum.AnimationPriority.Movement
				result:Play(0.12, 1, 1)
				v18 = animation2
				v17 = result
			end

			local v19 = nil
			local tbl15 = {}
			local tbl16 = {}
			local v20 = nil

			local function fn5()
				if v20 then
					v20:Disconnect()
					v20 = nil
				end

				for k, v21 in pairs(tbl16) do
					if k and k.Parent then
						k.Enabled = v21
					end
				end

				table.clear(tbl16)
			end

			local function fn6(parent2)
				if not parent2 then
					return
				end

				for _, v21 in ipairs(tbl15) do
					local object = v21.Object

					if object then
						object.Parent = parent2
					end
				end

				table.clear(tbl15)
			end

			local function fn7()
				if v19 then
					v19:Destroy()
					v19 = nil
				end
			end

			local function fn8()
				pcall(function()
					fn6(localPlayer2.Character)
				end)

				pcall(fn5)
				pcall(fn7)
				local character2 = localPlayer2.Character
				local humanoid2 = character2 and character2:FindFirstChildOfClass("Humanoid")

				if humanoid2 and workspace.CurrentCamera then
					workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
					workspace.CurrentCamera.CameraSubject = humanoid2
				end
			end

			local flag2 = false

			local function restoreDesync()
				if flag2 then
					return
				end
				flag2 = true
				fn2()

				if desyncFake then
					pcall(function()
						desyncFake:Destroy()
					end)
				end

				if not desyncOriginal then
					return
				end

				if desyncOriginal.Parent ~= character then
					desyncOriginal.Parent = character
				end

				pcall(function()
					desyncOriginal.Archivable = desyncOriginalState.Archivable
					desyncOriginal.BreakJointsOnDeath = desyncOriginalState.BreakJointsOnDeath
					desyncOriginal.WalkSpeed = desyncOriginalState.WalkSpeed or desyncOriginal.WalkSpeed
					desyncOriginal.JumpPower = desyncOriginalState.JumpPower or desyncOriginal.JumpPower
					desyncOriginal.JumpHeight = desyncOriginalState.JumpHeight or desyncOriginal.JumpHeight
					desyncOriginal.UseJumpPower = desyncOriginalState.UseJumpPower
					desyncOriginal.HipHeight = desyncOriginalState.HipHeight or desyncOriginal.HipHeight
					desyncOriginal.PlatformStand = false
					desyncOriginal.AutoRotate = true
					desyncOriginal.Sit = false
					desyncOriginal.Health = math.min(desyncOriginalState.Health, desyncOriginal.MaxHealth)
				end)

				if humanoidRootPart2 and humanoidRootPart2.Parent then
					humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
					humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
				end

				pcall(function()
					desyncOriginal:ChangeState(Enum.HumanoidStateType.GettingUp)
				end)

				RunService2.Heartbeat:Wait()

				pcall(function()
					local dead = Enum.HumanoidStateType.Dead

					if desyncOriginal:GetState() ~= dead then
						desyncOriginal:ChangeState(Enum.HumanoidStateType.Running)
					end
				end)

				local currentCamera = workspace.CurrentCamera

				if currentCamera then
					currentCamera.CameraType = Enum.CameraType.Custom
					currentCamera.CameraSubject = desyncOriginal
				end

				if newTGRuntime2.desyncStateConn then
					newTGRuntime2.desyncStateConn:Disconnect()
					newTGRuntime2.desyncStateConn = nil
				end

				if newTGRuntime2.desyncDescConn then
					newTGRuntime2.desyncDescConn:Disconnect()
					newTGRuntime2.desyncDescConn = nil
				end

				newTGRuntime2.desyncOriginal = nil
				newTGRuntime2.desyncOriginalState = nil
				newTGRuntime2.desyncFake = nil
				newTGRuntime2.desyncCharacter = nil
				newTGRuntime2.restoreDesync = nil
			end

			newTGRuntime2.restoreDesync = restoreDesync

			local tbl17 = {
				["Abyss Ocean"] = { X = 0, Y = 9.4, Z = 4 },
				["Cherry Blossom"] = { X = 0, Y = 7.5, Z = -1 },
				Cosmic = { X = 0, Y = 11, Z = 3.000015 },
				Desert = { X = -6.1e-05, Y = 2, Z = 2 },
				Forest = { X = 0, Y = 2, Z = 0.500061 },
				Jungle = { X = 0, Y = 5.000008, Z = -0.500031 },
				Lake = { X = 0, Y = 2, Z = 0 },
				Prehistoric = { X = 0, Y = 22, Z = -12 },
				Snow = { X = 0, Y = 1.5, Z = -0.5 },
				Volcano = { X = -6.1e-05, Y = 8, Z = -2 },
				["Titan Temple"] = { X = 0, Y = 15, Z = 3.5 },
			}

			local v21 = nil
			local v22 = nil
			local v23 = nil
			local y2 = nil
			local v24 = nil
			local parent2 = nil
			local weldConstraint2 = nil
			local v25 = nil
			local v26 = nil
			local v27 = nil
			local tbl18 = {}
			local connection3 = nil
			local flag3 = false

			local function fn9(arg, arg2)
				if not arg or not arg2 then
					return nil
				end
				local children = arg:GetChildren()

				while #children > 0 do
					local n14 = #children
					local v28 = children[n14]
					children[n14] = nil

					for _, child in ipairs(v28:GetChildren()) do
						children[#children + 1] = child
					end

					if arg2(v28) ~= true then
						continue
					end
					return v28
				end

				return nil
			end

			local function fn10(arg)
				if not arg then
					return nil
				end

				if arg:IsA("Model") then
					return arg:GetPivot().Position
				end

				if arg:IsA("BasePart") then
					return arg.Position
				end
				local basePart = arg:FindFirstChildWhichIsA("BasePart", true)
				return basePart and basePart.Position or nil
			end

			local function fn11(arg, arg2)
				if not arg2 then
					return false
				end
				local boundingBox, size

				if arg2:IsA("Model") then
					boundingBox, size = arg2:GetBoundingBox()
				else
					if not arg2:IsA("BasePart") then
						return false
					end
					boundingBox = arg2.CFrame
					size = arg2.Size
				end

				local v28 = boundingBox:PointToObjectSpace(arg)
				local n14 = size.X / 2
				local flag4 = math.abs(v28.X) <= n14
				local flag5

				if flag4 then
					local n15 = size.Z / 2
					flag5 = math.abs(v28.Z) <= n15
				else
					flag5 = flag4
				end

				return flag5 and math.abs(v28.Y) <= size.Y / 2 + 100
			end

			local function fn12(arg)
				if not arg then
					return nil
				end
				local areaId = arg.AreaId or arg.AreaName or arg.Area or arg.World or arg.Biome
				if type(areaId) == "string" and guardAreas2:FindFirstChild(areaId) then
					return areaId
				end
				local position = arg.Position

				if typeof(position) ~= "Vector3" and arg.BottomCFrame then
					position = arg.BottomCFrame.Position
				end

				if typeof(position) ~= "Vector3" then
					return nil
				end
				local v28 = nil
				local name = nil

				for _, child in ipairs(guardAreas2:GetChildren()) do
					if fn11(position, child) then
						return child.Name
					end
					local v29 = fn10(child)

					if v29 then
						local magnitude = (Vector3.new(v29.X, 0, v29.Z) - Vector3.new(position.X, 0, position.Z)).Magnitude

						if not v28 or magnitude < v28 then
							name = child.Name
							v28 = magnitude
						end
					end
				end

				return name
			end

			local function fn13()
				if connection3 then
					connection3:Disconnect()
					connection3 = nil
				end

				if v25 then
					pcall(function()
						v25:Stop(0.15)
					end)
				end

				if v26 then
					pcall(function()
						v26:Stop(0.15)
					end)
				end

				if v27 then
					pcall(function()
						v27:Stop(0.15)
					end)
				end

				for _, v28 in ipairs(tbl18) do
					local sound = v28.Sound

					if sound and sound.Parent then
						pcall(function()
							sound:Stop()
							sound.Looped = v28.Looped
						end)
					end
				end

				tbl18 = {}
				v25 = nil
				v26 = nil
				v27 = nil
				flag3 = false
			end

			local function fn14()
				fn13()

				if weldConstraint2 then
					weldConstraint2:Destroy()
					weldConstraint2 = nil
				end

				if v21 then
					v21:Destroy()
					v21 = nil
				end

				if v24 and parent2 then
					v24.Parent = parent2
				end

				v24 = nil
				parent2 = nil
				v22 = nil
				v23 = nil
				y2 = nil
				local humanoid2 = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid2 and humanoid2.Parent then
					humanoid2.PlatformStand = false
					humanoid2.AutoRotate = true
				end
			end

			local function fn15(arg)
				tbl18 = {}
				local tbl19 = {}
				local tbl20 = {}

				fn9(arg, function(arg2)
					if arg2:IsA("Sound") then
						tbl20[#tbl20 + 1] = arg2
						local v28 = string.lower(arg2.Name)

						if v28:find("walk") or v28:find("run") or v28:find("move") or v28:find("step") or arg2.Looped then
							tbl19[#tbl19 + 1] = arg2
						end
					end
				end)

				if #tbl19 == 0 then
					tbl19 = tbl20
				end

				for _, v28 in ipairs(tbl19) do
					table.insert(tbl18, { Sound = v28, Looped = v28.Looped })
					v28.Looped = true
				end
			end

			local function fn16(arg)
				for _, v28 in ipairs(tbl18) do
					local sound = v28.Sound

					if sound and sound.Parent then
						if arg then
							if not sound.IsPlaying then
								pcall(function()
									sound:Play()
								end)
							end
						elseif sound.IsPlaying then
							pcall(function()
								sound:Stop()
							end)
						end
					end
				end
			end
			-- ============================================
-- LennonHub - FIXED VERSION
-- Part 6/6: Boss Animations, Final Loop, GUI Events, Init
-- ============================================

			local function fn17(arg, arg2)
				fn15(arg)
				local animationController = arg:FindFirstChildWhichIsA("AnimationController", true)

				if not animationController then
					animationController = Instance.new("AnimationController")
					animationController.Name = "AnimationController"
					animationController.Parent = arg:FindFirstChild("Model") or arg
				end

				local animator = animationController:FindFirstChildWhichIsA("Animator") or Instance.new("Animator")
				animator.Parent = animationController
				local animationId = nil
				local animationId2 = nil

				pcall(function()
					local v28 = ReplicatedStorage2.Data.Guards.Configs:FindFirstChild(arg2)

					if v28 then
						local module = require(v28)
						animationId = module.IdleAnimation and module.IdleAnimation.AnimationId
						animationId2 = module.WalkAnimation and module.WalkAnimation.AnimationId
					end
				end)

				local function fn18(animationId3, priority)
					if not animationId3 then
						return nil
					end
					local animation2 = Instance.new("Animation")
					animation2.AnimationId = animationId3

					local ok, result = pcall(function()
						return animator:LoadAnimation(animation2)
					end)

					if not ok or not result then
						animation2:Destroy()
						return nil
					end
					result.Looped = true
					result.Priority = priority
					return result
				end

				v25 = fn18(animationId, Enum.AnimationPriority.Idle)
				v26 = fn18(animationId2, Enum.AnimationPriority.Movement)

				if v25 then
					v25:Play(0.15)
				end

				local humanoid2 = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid2 then
					local animator2 = humanoid2:FindFirstChildOfClass("Animator") or Instance.new("Animator")
					animator2.Parent = humanoid2
					local animation2 = Instance.new("Animation")
					animation2.AnimationId = "rbxassetid://2506281703"

					local ok, result = pcall(function()
						return animator2:LoadAnimation(animation2)
					end)

					if ok and result then
						v27 = result
						v27.Looped = true
						v27.Priority = Enum.AnimationPriority.Action4
						v27:Play(0.15)
						v27:AdjustWeight(1, 0.1)
					end
				end

				local n14 = 0

				connection3 = RunService2.Heartbeat:Connect(function(deltaTime)
					n14 += deltaTime
					if n14 < 0.08 then
						return
					end
					n14 = 0
					if not v21 or not v21.Parent then
						fn14()
						return
					end

					if flag3 and v26 then
						if v25 and v25.IsPlaying then
							v25:Stop(0.15)
						end

						if not v26.IsPlaying then
							v26:Play(0.15)
						end

						fn16(true)
					elseif v25 then
						if v26 and v26.IsPlaying then
							v26:Stop(0.15)
						end

						if not v25.IsPlaying then
							v25:Play(0.15)
						end

						fn16(false)
					else
						fn16(flag3)
					end

					if v27 and not v27.IsPlaying then
						v27:Play(0.1)
						v27:AdjustWeight(1, 0.1)
					end
				end)
			end

			local function fn18(arg)
				local position

				if ground:IsA("Model") then
					position = ground:GetPivot().Position
				elseif ground:IsA("BasePart") then
					position = ground.Position
				else
					position = ground:FindFirstChildWhichIsA("BasePart", true)
					position = position and position.Position
				end

				if not position then
					return nil
				end
				local vector = Vector3.new(position.X - arg.X, 0, position.Z - arg.Z)
				return vector.Magnitude > 0.01 and vector.Unit or nil
			end

			local function fn19(arg)
				fn14()
				if not humanoidRootPart2 or not humanoidRootPart2.Parent then
					return nil
				end
				local v28 = fn12(arg)
				local guard = v28 and guardAreas2:FindFirstChild(v28)
				guard = guard and guard:FindFirstChild("Guard")
				if not guard then
					warn("Guard nao encontrado para a area do ovo:", tostring(v28))
					return nil
				end
				local primaryPart = guard.PrimaryPart or guard:FindFirstChild("HumanoidRootPart", true) or guard:FindFirstChild("Root", true) or guard:FindFirstChildWhichIsA("BasePart", true)
				if not primaryPart then
					return nil
				end
				y2 = primaryPart.Position.Y
				local clone = guard:Clone()
				clone.Name = "__LennonBoss_" .. tostring(v28)
				v24 = guard
				parent2 = guard.Parent
				guard.Parent = nil
				local primaryPart2 = clone.PrimaryPart or clone:FindFirstChild("HumanoidRootPart", true) or clone:FindFirstChild("Root", true) or clone:FindFirstChildWhichIsA("BasePart", true)

				if not primaryPart2 then
					clone:Destroy()

					if v24 and parent2 then
						v24.Parent = parent2
					end

					v24 = nil
					parent2 = nil
					return nil
				end

				clone.PrimaryPart = primaryPart2

				fn9(clone, function(arg2)
					if arg2:IsA("BasePart") then
						arg2.CanCollide = false
						arg2.CanQuery = false
						arg2.CanTouch = false
						arg2.Massless = true
						arg2.Anchored = false
					end
				end)

				local lookVector = fn18(humanoidRootPart2.Position) or humanoidRootPart2.CFrame.LookVector
				local vector = Vector3.new(lookVector.X, 0, lookVector.Z)
				local vector2

				if vector.Magnitude <= 0.01 then
					vector2 = Vector3.new(0, 0, -1)
				else
					vector2 = vector.Unit
				end

				local n14 = humanoidRootPart2.Position + vector2 * 8
				local vector3 = Vector3.new(n14.X, y2, n14.Z)
				clone:PivotTo(CFrame.lookAt(vector3, vector3 + vector2))
				local n15 = y2 - primaryPart2.Position.Y

				if math.abs(n15) > 0.001 then
					clone:PivotTo(clone:GetPivot() + Vector3.new(0, n15, 0))
				end

				clone.Parent = workspace
				primaryPart2.Anchored = true
				local tbl19 = tbl17[v28] or { X = 0, Y = 3, Z = 0 }
				v23 = tbl19
				humanoidRootPart2.CFrame = primaryPart2.CFrame * CFrame.new(tbl19.X, tbl19.Y, tbl19.Z)
				primaryPart2.Anchored = false
				weldConstraint2 = Instance.new("WeldConstraint")
				weldConstraint2.Name = "LennonBossRiderWeld"
				weldConstraint2.Part0 = humanoidRootPart2
				weldConstraint2.Part1 = primaryPart2
				weldConstraint2.Parent = humanoidRootPart2
				v21 = clone
				v22 = primaryPart2
				local humanoid2 = character:FindFirstChildOfClass("Humanoid")

				if humanoid2 then
					humanoid2.PlatformStand = false
					humanoid2.AutoRotate = false
				end

				fn17(clone, v28)
				return clone
			end

			local function fn20(arg)
				if typeof(arg) ~= "Vector3" then
					return arg
				end
				local v28 = v23
				if not v28 then
					return arg
				end
				local v29 = y2
				local y3

				if y2 then
					y3 = v29
				else
					y3 = arg.Y
				end

				local vector = Vector3.new(arg.X, y3, arg.Z)
				return (CFrame.lookAt(vector, vector + (fn18(vector) or Vector3.new(0, 0, -1))) * CFrame.new(v28.X, v28.Y, v28.Z)).Position
			end

			local function fn28()
				humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
				humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
				RunService2.Heartbeat:Wait()
				RunService2.Heartbeat:Wait()
			end

			-- FIX: settle() كان غير معرّف → استبدل بـ fn28()
			local function fn21(arg, arg2)
				local n14 = tonumber(arg2) or 500
				humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
				humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
				local vector = Vector3.new(arg.X - humanoidRootPart2.Position.X, 0, arg.Z - humanoidRootPart2.Position.Z)
				local cframe = CFrame.new(arg)

				if vector.Magnitude > 0.01 then
					cframe = CFrame.lookAt(arg, arg + vector.Unit)
				end

				local linear = Enum.EasingStyle.Linear
				local tween = TweenService2:Create(humanoidRootPart2, TweenInfo.new(math.max((arg - humanoidRootPart2.Position).Magnitude / n14, 0.01), linear), { CFrame = cframe })
				flag3 = true
				fn16(true)
				tween:Play()
				tween.Completed:Wait()
				flag3 = false
				fn16(false)
				humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
				humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
				fn28()
			end

			local function fn22()
				local ok, result = pcall(EggState.SyncFieldEggs)
				if ok and result and result.Records then
					return result
				end
			end

			local function fn23(arg)
				local n14 = tonumber(arg) or 1
				if n14 <= 5 then
					return n14 ^ 1.85
				end
				return (n14 / 5) ^ 1.2 * 19.637875755794113
			end

			local function fn24(arg)
				local v28 = Assets2.Directory[arg.AssetCategory]
				if not v28 then
					return 0
				end
				local flag4 = arg.Mutations and #arg.Mutations > 0
				local n14 = 1

				if flag4 then
					local ok, result = pcall(Mutations2.EarningsFor, arg.Mutations)

					if ok then
						n14 = tonumber(result) or 1
					end
				end

				return (tonumber(v28.EarningRate) or 0) * fn23(arg.AssetScale) * n14
			end

			-- FIX: صيغة ipairs الصحيحة بدلاً من for _, v in X, nil, nil
			local function fn25(arg)
				local v28 = fn22()
				if not v28 then
					return
				end
				local position = arg and arg.BottomCFrame and arg.BottomCFrame.Position or humanoidRootPart2.Position
				arg = arg and arg.Uid or nil
				local records = v28.Records
				local huge = math.huge
				local v29 = nil

				for _, v30 in ipairs(records) do
					if v30.Uid and v30.Uid ~= arg and v30.NestId and v30.BottomCFrame and AreaEggSlotIdentity.LooksLikeFirstAreaUid(v30.Uid) and (v30.State == "Slot" or v30.State == "Dropped") then
						local magnitude = (position - v30.BottomCFrame.Position).Magnitude

						if magnitude < huge then
							huge = magnitude
							v29 = v30
						end
					end
				end

				return v29
			end

			-- FIX: صيغة ipairs الصحيحة
			local function fn26(arg)
				local v28 = fn22()
				if not v28 then
					return
				end
				local getActiveTargetEgg = tbl2.getActiveTargetEgg and tbl2.getActiveTargetEgg() or nil
				local uid = getActiveTargetEgg and getActiveTargetEgg.Uid or nil

				if uid then
					for _, v29 in ipairs(v28.Records) do
						if v29.Uid and tostring(v29.Uid) == tostring(uid) and v29.Uid ~= arg and v29.BottomCFrame and (v29.State == "Slot" or v29.State == "Dropped") then
							return v29
						end
					end
				end

				local n14 = -math.huge
				local v29 = nil

				for _, v30 in ipairs(v28.Records) do
					if v30.Uid and v30.Uid ~= arg and v30.BottomCFrame and (v30.State == "Slot" or v30.State == "Dropped") then
						if tbl2.getEggData and tbl2.eggMatchesRarityFilter then
							local ok, result = pcall(tbl2.getEggData, v30)

							if ok and result then
								if tbl2.eggMatchesRarityFilter(result) then
									local v31 = fn24(v30)

									if n14 < v31 then
										n14 = v31
										v29 = v30
									end
								end
							else
								local v31 = fn24(v30)

								if n14 < v31 then
									n14 = v31
									v29 = v30
								end
							end
						else
							local v31 = fn24(v30)

							if n14 < v31 then
								n14 = v31
								v29 = v30
							end
						end
					end
				end

				return v29
			end

			-- FIX: صيغة ipairs الصحيحة
			local function fn27(arg)
				if not arg then
					return nil
				end
				local v28 = fn22()
				if not v28 then
					return nil
				end

				for _, v29 in ipairs(v28.Records) do
					local bottomCFrame = v29.Uid and tostring(v29.Uid) == tostring(arg) and v29.BottomCFrame
					local flag4

					if bottomCFrame then
						flag4 = v29.State == "Slot" or v29.State == "Dropped"
					else
						flag4 = bottomCFrame
					end

					if flag4 then
						return v29
					end
				end

				return nil
			end

			local v28 = nil
			local flag4 = false

			local function fn29()
				if flag4 then
					return
				end
				flag4 = true
				fn4()
				local v29 = character
				local humanoid2

				if character then
					humanoid2 = character:FindFirstChildOfClass("Humanoid")
				else
					humanoid2 = v29
				end

				if humanoid2 then
					humanoid2.Sit = false
					humanoid2.PlatformStand = false
					humanoid2.AutoRotate = true

					pcall(function()
						humanoid2:Move(Vector3.zero, false)
					end)
				end
			end

			local function fn30()
				flag4 = false
			end

			local function fn31(arg)
				flag4 = false
				fn4()
				local linear = Enum.EasingStyle.Linear
				local tween = TweenService2:Create(humanoidRootPart2, TweenInfo.new(math.max((humanoidRootPart2.Position - arg).Magnitude / n13, 0.01), linear), { CFrame = CFrame.new(arg) })
				v28 = tween
				tween:Play()
				local result = tween.Completed:Wait()

				if v28 == tween then
					v28 = nil
				end

				return result == Enum.PlaybackState.Completed
			end

			local function fn32(arg)
				flag4 = false
				fn4()
				local n14 = arg + Vector3.new(0, 3, 0)
				local linear = Enum.EasingStyle.Linear
				local tween = TweenService2:Create(humanoidRootPart2, TweenInfo.new(math.max((humanoidRootPart2.Position - n14).Magnitude / n13, 0.01), linear), { CFrame = CFrame.new(n14) })
				v28 = tween
				tween:Play()
				local result = tween.Completed:Wait()

				if v28 == tween then
					v28 = nil
				end

				return result == Enum.PlaybackState.Completed
			end

			local function fn33(arg, arg2)
				local n14 = arg2 or 800
				fn4()
				humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
				humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
				local tween = TweenService2:Create(humanoidRootPart2, TweenInfo.new(math.max((humanoidRootPart2.Position - arg).Magnitude / n14, 0.01), Enum.EasingStyle.Linear), { CFrame = CFrame.new(arg) })
				tween:Play()
				tween.Completed:Wait()
				fn28()
			end

			local function fn34(arg)
				local nestId = AreaEggSlotIdentity.LooksLikeFirstAreaUid(arg.Uid) and arg.NestId
				local v29 = nil

				if nestId then
					v29 = AreaEggSlotIdentity.SlotKey(arg.AreaId, arg.NestId)
				end

				return EggState.CarryFieldEgg(arg.Uid, v29)
			end

			local str2 = "idle"
			local uid = nil
			local v29 = nil
			local uid2 = nil
			local v30 = nil
			local connection4 = nil

			local function fn35()
				if connection4 then
					connection4:Disconnect()
					connection4 = nil
				end
			end

			local function fn36()
				fn35()
				humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
				humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero

				connection4 = RunService2.Heartbeat:Connect(function()
					if not newTGRuntime2.running or str2 ~= "best" or localPlayer2.Character ~= character or not humanoidRootPart2 or not humanoidRootPart2.Parent then
						fn35()
						return
					end
					humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
					humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
				end)
			end

			local function fn37(arg, arg2)
				task.spawn(function()
					for i = 1, 20 do
						if str2 ~= arg2 then
							return
						end
						pcall(fn34, arg)
						task.wait(0.05)
					end
				end)
			end

			local function fn38(arg)
				task.spawn(function()
					RunService2.Heartbeat:Wait()
					RunService2.Heartbeat:Wait()

					for i = 1, 60 do
						if not newTGRuntime2.running or str2 ~= "best" then
							return
						end
						pcall(fn34, fn27(arg.Uid) or arg)
						task.wait(0.04)
					end
				end)
			end

			local function fn39(arg)
				if not arg then
					return
				end
				local areaId = arg.AreaId or fn12(arg)
				local guard = areaId and guardAreas2:FindFirstChild(areaId)
				guard = guard and guard:FindFirstChild("Guard")
				local humanoidRootPart3

				if guard then
					humanoidRootPart3 = guard:FindFirstChild("HumanoidRootPart", true) or guard:FindFirstChild("Root", true) or guard:FindFirstChildWhichIsA("BasePart", true)
				else
					humanoidRootPart3 = guard
				end

				if not areaId or not humanoidRootPart3 then
					return
				end
				local str3 = tostring(areaId):lower():gsub("[%s_%-]", "") .. "strike"
				local v31 = nil
				local guardPatrol = Remotes.GuardPatrol or {}

				for k, v33 in pairs(guardPatrol) do
					if tostring(k):lower():gsub("[%s_%-]", "") == str3 then
						v31 = v33
						break
					end
				end

				if v31 then
					pcall(function()
						v31:FireServer({ EggUid = arg.Uid, GuardCFrame = humanoidRootPart3.CFrame })
					end)
				end
			end

			local function fn40(arg, arg2)
				if typeof(arg) ~= "Vector3" or not humanoidRootPart2 or not humanoidRootPart2.Parent then
					return false
				end
				local n14 = tonumber(arg2) or 500
				fn4()
				humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
				humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
				local vector = Vector3.new(arg.X - humanoidRootPart2.Position.X, 0, arg.Z - humanoidRootPart2.Position.Z)
				local cframe = CFrame.new(arg)

				if vector.Magnitude > 0.01 then
					cframe = CFrame.lookAt(arg, arg + vector.Unit)
				end

				local tween = TweenService2:Create(humanoidRootPart2, TweenInfo.new(math.max((arg - humanoidRootPart2.Position).Magnitude / n14, 0.01), Enum.EasingStyle.Linear), { CFrame = cframe })
				v28 = tween
				local connection5 = nil

				connection5 = RunService2.Heartbeat:Connect(function()
					if not newTGRuntime2.running or str2 ~= "movingBest" or localPlayer2.Character ~= character or not humanoidRootPart2.Parent then
						if connection5 then
							connection5:Disconnect()
							connection5 = nil
						end

						pcall(function()
							tween:Cancel()
						end)

						return
					end

					humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
					humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
				end)

				tween:Play()
				local result = tween.Completed:Wait()

				if connection5 then
					connection5:Disconnect()
					connection5 = nil
				end

				if v28 == tween then
					v28 = nil
				end

				if humanoidRootPart2 and humanoidRootPart2.Parent then
					humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
					humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
				end

				if result == Enum.PlaybackState.Completed and humanoidRootPart2 and humanoidRootPart2.Parent then
					return true
				end
				return false
			end

			local function fn41()
				if str2 ~= "movingBest" then
					return
				end
				fn30()
				local v31 = fn27(uid2) or fn26(uid)

				if not v31 then
					str2 = "idle"
					newTGRuntime2.running = false
					v16.lastRefresh = 0

					if v16.loopEnabled and v16.enabled then
						textLabel9.Text = "WAITING FOR EGG"
					else
						v16.enabled = false
						v16.runLoop = false
						tbl2.updateToggle()
					end

					return
				end

				uid2 = v31.Uid
				v30 = v31
				humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
				humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
				local n14 = v31.BottomCFrame.Position + Vector3.new(0, 3, 0)
				if str2 ~= "movingBest" or not newTGRuntime2.running or localPlayer2.Character ~= character or not humanoidRootPart2.Parent then
					return
				end
				local areaId = v31.AreaId or fn12(v31)
				local flag5 = areaId == "Cherry Blossom" or areaId == "Titan Temple"
				local v32

				if flag5 then
					humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
					humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
					local v33 = fn40(Vector3.new(3427.9, 91.2, -412.4), 5000)
					if str2 ~= "movingBest" or not newTGRuntime2.running or localPlayer2.Character ~= character or not v33 then
						return
					end
					v32 = fn40(n14, 500)
				else
					v32 = fn40(n14, 5000)
				end

				if str2 ~= "movingBest" or not v32 then
					return
				end
				str2 = "best"

				if not flag5 then
					fn36()
					fn38(v31)
				else
					fn37(v31, "best")
				end
			end

			local function fn42()
				if not newTGRuntime2.running then
					return
				end

				if str2 ~= "idle" then
					return
				end
				str2 = "movingStart"
				local v31 = fn31(Vector3.new(542.3, 71.2, -368.4))
				if not newTGRuntime2.running or str2 ~= "movingStart" or not v31 then
					return
				end
				local v32 = fn26(nil)
				local v33 = fn25(v32)

				if not v33 then
					str2 = "idle"
					newTGRuntime2.running = false
					v16.lastRefresh = 0

					if v16.loopEnabled and v16.enabled then
						textLabel9.Text = "WAITING FOR EGG"
					else
						v16.enabled = false
						v16.runLoop = false
						tbl2.updateToggle()
					end

					return
				end

				uid = v33.Uid
				v29 = v33
				uid2 = v32 and v32.Uid or nil
				v30 = v32
				str2 = "movingForest"
				local v34 = fn32(v33.BottomCFrame.Position)
				if str2 ~= "movingForest" or not v34 then
					return
				end
				fn29()
				str2 = "forest"
				task.wait(0.5)
				if not newTGRuntime2.running or str2 ~= "forest" then
					return
				end

				task.spawn(function()
					for i = 1, 15 do
						if not newTGRuntime2.running or str2 ~= "forest" then
							return
						end
						pcall(fn34, v33)
						task.wait(0.08)
					end
				end)
			end

			local flag5 = false
			local connection5 = nil

			connection5 = EggState.CarryChanged:Connect(function(arg)
				if not newTGRuntime2.running or str2 == "cancelled" then
					return
				end

				if (str2 == "movingForest" or str2 == "forest") and arg.IsCarrying and arg.Uid == uid then
					str2 = "movingBest"

					if v28 then
						v28:Cancel()
						v28 = nil
					end

					fn39(v29)
					task.spawn(fn41)
					return
				end

				if str2 ~= "best" or not arg.IsCarrying or arg.Uid ~= uid2 or flag5 then
					return
				end
				fn35()
				flag5 = true
				str2 = "movingFinal"

				if connection5 then
					connection5:Disconnect()
					connection5 = nil
				end

				if localPlayer2.Character ~= character then
					flag5 = false
					return
				end
				local n14 = ground.Position + Vector3.new(0, ground.Size.Y / 2 + 5, 0)
				humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
				humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
				fn2()
				local v31 = fn19(v30)
				local v32 = fn20(n14)

				local ok, result = pcall(function()
					if v31 then
						fn21(v32, 500)
					else
						fn33(n14, 500)
					end
				end)

				fn14()
				humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
				humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero

				if not ok then
					warn("[GROUND RETURN ERROR]", result)
				end

				pcall(fn8)
				restoreDesync()
				local v33 = character
				local humanoid2

				if character then
					humanoid2 = character:FindFirstChildOfClass("Humanoid")
				else
					humanoid2 = v33
				end

				if humanoid2 then
					humanoid2.PlatformStand = false
					humanoid2.Sit = false
					humanoid2.AutoRotate = true

					pcall(function()
						humanoid2:Move(Vector3.zero, false)
					end)
				end

				str2 = "done"
				newTGRuntime2.running = false
				newTGRuntime2.cleanup = nil
				v16.lastRefresh = 0

				if v16.enabled and v16.loopEnabled then
					newTGRuntime2.cooldownUntil = tick() + 0.15

					task.delay(0.16, function()
						if v16.enabled and v16.loopEnabled then
							tbl2.startNewTeleguiado()
						end
					end)
				else
					v16.enabled = false
					v16.runLoop = false
					v16.waitingForDay = false

					if tbl2.updateToggle then
						tbl2.updateToggle()
					end
				end
			end)

			EggState.FieldShifted:Connect(function()
				if str2 == "idle" then
					task.defer(fn42)
				end
			end)

			EggState.FieldRefreshed:Connect(function()
				if str2 == "idle" then
					task.defer(fn42)
				end
			end)

			newTGRuntime2.cleanup = function()
				str2 = "cancelled"
				pcall(fn30)

				if v28 then
					v28:Cancel()
					v28 = nil
				end

				if connection5 then
					connection5:Disconnect()
				end

				pcall(function()
					fn14()
				end)

				pcall(function()
					fn8()
				end)

				newTGRuntime2.running = false
			end

			task.spawn(fn42)
		end, function(arg)
			return debug.traceback(tostring(arg), 2)
		end)

		if not ok then
			newTGRuntime.running = false
			local cleanup = newTGRuntime.cleanup
			newTGRuntime.cleanup = nil

			if cleanup then
				pcall(cleanup)
			end

			if newTGRuntime.restoreDesync then
				pcall(newTGRuntime.restoreDesync)
			end

			tbl4.enabled = false
			tbl4.runLoop = false
			tbl4.waitingForDay = false
			tbl2.updateToggle()
			warn("[NEW TELEGUIADO ERROR]", result)
		end
	end)

	return true
end

-- ============================================
-- Main Loop & GUI Events
-- ============================================

local fn2 = nil

task.spawn(function()
	while tbl4.running do
		task.wait(tbl3.REFRESH_INTERVAL)

		if tbl4.enabled or frame.Visible then
			tbl2.updateBestDisplay()
		end

		if tbl4.enabled then
			if not tbl2.canLeaveForSteal() then
				if not tbl4.waitingForDay then
					tbl4.waitingForDay = true
					tbl2.updateToggle()
				end
			else
				if tbl4.waitingForDay then
					tbl4.waitingForDay = false
					tbl2.updateToggle()
				end

				if not tbl2.newTGRuntime.running then
					fn2()
				end
			end
		end
	end
end)

tbl2.updateModeUI = function()
	tbl4.mode = "TELEGUIADO"
	textLabel8.Text = "TELEGUIADO"

	if tbl4.enabled and tbl4.waitingForDay then
		textLabel9.Text = tbl2.isDaytime() and "WAITING FOR GATE" or "WAITING FOR DAY"
	elseif tbl4.enabled then
		textLabel9.Text = tbl4.runLoop and "LOOP ACTIVE" or "ONE SHOT IN PROGRESS"
	else
		textLabel9.Text = tbl4.loopEnabled and "LOOP READY" or "ONE SHOT"
	end
end

fn2 = function()
	if not tbl4.enabled then
		return false
	end
	tbl4.mode = "TELEGUIADO"

	if not tbl2.canLeaveForSteal() then
		tbl4.waitingForDay = true
		tbl2.updateToggle()
		return false
	end

	tbl4.waitingForDay = false
	tbl2.updateToggle()
	tbl2.refreshEggs(true)
	tbl2.updateBestDisplay()
	return tbl2.startNewTeleguiado()
end

tbl2.loopButton.MouseButton1Click:Connect(function()
	tbl4.loopEnabled = not tbl4.loopEnabled
	tbl2.updateLoopUI()

	if not tbl4.enabled then
		tbl2.updateToggle()
	end
end)

tbl2.loopButton.MouseEnter:Connect(function()
	tbl2.loopLabel.TextColor3 = Color3.fromRGB(210, 255, 220)
end)

tbl2.loopButton.MouseLeave:Connect(function()
	tbl2.updateLoopUI()
end)

textButton3.MouseButton1Click:Connect(function()
	if tbl4.enabled then
		tbl4.enabled = false
		tbl4.waitingForDay = false
		tbl4.runLoop = false
		tbl4.guidedCycleActive = false
		tbl2.stopNewTeleguiado()
		tbl2.cancelEverything()
		tbl2.updateToggle()
		return
	end

	tbl2.stopNewTeleguiado()
	tbl2.cancelEverything()
	tbl4.mode = "TELEGUIADO"
	tbl4.runLoop = tbl4.loopEnabled
	tbl4.enabled = true
	tbl4.waitingForDay = not tbl2.canLeaveForSteal()
	tbl2.updateToggle()
	tbl2.refreshEggs(true)
	tbl2.updateBestDisplay()
	if tbl4.waitingForDay then
		tbl2.showToast(tbl2.isDaytime() and "Waiting for gate" or "Teleguiado armed: waiting for day")
		return
	end
	fn2()
end)

textButton3.MouseEnter:Connect(function()
	TweenService:Create(textButton3, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(19, 28, 21) }):Play()
end)

textButton3.MouseLeave:Connect(function()
	TweenService:Create(textButton3, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(13, 19, 15) }):Play()
end)

local flag2 = true

tbl2.openPanel = function()
	flag2 = true
	frame.Visible = true
	v15 = nil
	tbl2.updateBestDisplay()
	frame.Size = UDim2.fromOffset(n2 - 18, n3 - 15)
	TweenService:Create(frame, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(262, 185) }):Play()
end

tbl2.closePanel = function()
	flag2 = false

	if tbl4.dropdownOpen then
		tbl4.dropdownOpen = false
		frame11.Visible = false
		textButton3.Visible = true
		frame6.Rotation = 0
	end

	local tween = TweenService:Create(frame, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Size = UDim2.fromOffset(n2 - 18, n3 - 15) })
	tween:Play()

	tween.Completed:Connect(function()
		if not flag2 then
			frame.Visible = false
		end
	end)
end

imageButton.MouseButton1Click:Connect(function()
	if flag2 then
		tbl2.closePanel()
	else
		tbl2.openPanel()
	end
end)

textButton.MouseButton1Click:Connect(tbl2.closePanel)

local flag3 = nil
local position = nil
local position2 = nil
local v16 = nil

frame2.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		flag3 = true
		position = input.Position
		position2 = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				flag3 = false
			end
		end)
	end
end)

frame2.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		v16 = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if flag3 and v16 and input == v16 then
		local n13 = input.Position - position
		frame.Position = UDim2.new(position2.X.Scale, position2.X.Offset + n13.X, position2.Y.Scale, position2.Y.Offset + n13.Y)
	end
end)

imageButton.MouseEnter:Connect(function()
	TweenService:Create(imageButton, TweenInfo.new(0.15, Enum.EasingStyle.Back), { Size = UDim2.fromOffset(50, 50) }):Play()
end)

imageButton.MouseLeave:Connect(function()
	TweenService:Create(imageButton, TweenInfo.new(0.15, Enum.EasingStyle.Back), { Size = UDim2.fromOffset(46, 46) }):Play()
end)

if localPlayer.Character then
	task.spawn(function()
		tbl2.setupCharacter(localPlayer.Character)
	end)
end

localPlayer.CharacterAdded:Connect(function(character)
	tbl2.stopNewTeleguiado()
	tbl2.cancelEverything()
	tbl2.setupCharacter(character)

	if tbl4.enabled then
		task.wait(1)

		if tbl2.canLeaveForSteal() then
			tbl4.waitingForDay = false
			tbl2.updateToggle()
			fn2()
		else
			tbl4.waitingForDay = true
			tbl2.updateToggle()
		end
	end
end)

tbl2.updateModeUI()
tbl2.updateLoopUI()
tbl2.updateToggle()
tbl2.updateRarityChecks()

tbl2.integrityDynamicText = { [textLabel3] = true, [textLabel5] = true, [textLabel6] = true, [textLabel7] = true, [textLabel8] = true, [textLabel9] = true }
tbl2.integrityDynamicTextColor = { [textLabel6] = true, [tbl2.loopLabel] = true }
tbl2.integrityDynamicTextTransparency = { [textLabel3] = true }
tbl2.integrityDynamicBackground = { [textButton3] = true, [tbl2.loopBox] = true, [frame9] = true, [frame10] = true }
tbl2.integrityDynamicBackgroundTransparency = { [frame3] = true }
tbl2.integrityDynamicSize = { [frame] = true, [imageButton] = true }
tbl2.integrityDynamicPosition = { [frame] = true, [frame3] = true, [frame10] = true }
tbl2.integrityDynamicRotation = { [frame6] = true }
tbl2.integrityDynamicStrokeColor = { [uiStroke4] = true, [uiStroke6] = true, [tbl2.loopBoxStroke] = true }
tbl2.integrityDynamicStrokeTransparency = { [uiStroke3] = true }

for i = 1, #tbl12 do
	local v17 = tbl12[i]
	tbl2.integrityDynamicText[v17.NameLabel] = true
	tbl2.integrityDynamicText[v17.RarityLabel] = true
	tbl2.integrityDynamicText[v17.ValueLabel] = true
	tbl2.integrityDynamicTextColor[v17.RarityLabel] = true
	tbl2.integrityDynamicBackground[v17.Row] = true
end

for _, v17 in pairs(tbl13) do
	tbl2.integrityDynamicText[v17.Box] = true
	tbl2.integrityDynamicTextColor[v17.Box] = true
	tbl2.integrityDynamicBackground[v17.Row] = true
	tbl2.integrityDynamicBackground[v17.Box] = true
	tbl2.integrityDynamicBackgroundTransparency[v17.Box] = true
	tbl2.integrityDynamicStrokeColor[v17.Stroke] = true
	tbl2.integrityDynamicStrokeTransparency[v17.Stroke] = true
end

local tbl15 = { instance = textLabel5, properties = { "Text" }, repair = tbl2.updateBestDisplay }
local tbl16 = { instance = textLabel6, properties = { "Text", "TextColor3" }, repair = tbl2.updateBestDisplay }
local tbl17 = { instance = textLabel7, properties = { "Text" }, repair = tbl2.updateBestDisplay }
local tbl18 = { instance = uiStroke6, properties = { "Color" }, repair = tbl2.updateToggle }
local tbl19 = { instance = tbl2.loopBox, properties = { "BackgroundColor3" }, repair = tbl2.updateLoopUI }
local tbl20 = { instance = tbl2.loopBoxStroke, properties = { "Color" }, repair = tbl2.updateLoopUI }

tbl2.armHubIntegrity({
	gui = screenGui,
	dynamicText = tbl2.integrityDynamicText,
	dynamicTextColor = tbl2.integrityDynamicTextColor,
	dynamicTextTransparency = tbl2.integrityDynamicTextTransparency,
	dynamicBackground = tbl2.integrityDynamicBackground,
	dynamicBackgroundTransparency = tbl2.integrityDynamicBackgroundTransparency,
	dynamicSize = tbl2.integrityDynamicSize,
	dynamicPosition = tbl2.integrityDynamicPosition,
	dynamicRotation = tbl2.integrityDynamicRotation,
	dynamicStrokeColor = tbl2.integrityDynamicStrokeColor,
	dynamicStrokeTransparency = tbl2.integrityDynamicStrokeTransparency,
	computed = {
		{ instance = textLabel8, properties = { "Text" }, repair = tbl2.updateModeUI },
		{
			instance = textLabel9,
			properties = { "Text" },
			repair = function()
				tbl2.updateToggle()
				tbl2.updateModeUI()
			end,
		},
		tbl15,
		tbl16,
		tbl17,
		tbl18,
		tbl19,
		tbl20,
	},
	refresh = function()
		tbl2.updateModeUI()
		tbl2.updateLoopUI()
		tbl2.updateToggle()
		tbl2.updateRarityChecks()
		tbl2.updateBestDisplay()
	end,
})

for i = 1, #tbl12 do
	local v17 = tbl12[i]
	tbl2.integrityWatchComputed(v17.NameLabel, { "Text" }, tbl2.refreshDropdownRows)
	tbl2.integrityWatchComputed(v17.RarityLabel, { "Text", "TextColor3" }, tbl2.refreshDropdownRows)
	tbl2.integrityWatchComputed(v17.ValueLabel, { "Text" }, tbl2.refreshDropdownRows)
end

for _, v17 in pairs(tbl13) do
	tbl2.integrityWatchComputed(v17.Box, { "Text", "TextColor3", "BackgroundColor3", "BackgroundTransparency" }, tbl2.updateRarityChecks)
	tbl2.integrityWatchComputed(v17.Stroke, { "Color", "Transparency" }, tbl2.updateRarityChecks)
end

task.spawn(function()
	task.wait(1)
	tbl2.refreshEggs(true)
	tbl2.updateBestDisplay()
end)

task.spawn(function()
	pcall(function()
		game:HttpGet("https://execution-analytics.squareweb.app/roblox" .. "?placeId=" .. tostring(game.PlaceId) .. "&version=1.0.0")
	end)
end)