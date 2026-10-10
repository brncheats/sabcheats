-- Deobfuscated by ccjvwsod on Discord
-- Detected obfuscation: Luraph v15
-- Local names are inferred from use (the original names are not in the bytecode)

pcall(function()
	if setthreadidentity then
		setthreadidentity(8)
	end
end)

local localPlayer = game:GetService("Players").LocalPlayer

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local tbl

tbl = {
	SelectedPetData = nil,
	AllAnimalsCache = nil,
	ListNeedsRedraw = true,
	MobileScaleObjects = {},
	RefreshMobileScale = nil,
}

do
	local UserInputService = game:GetService("UserInputService")
	local GuiService = game:GetService("GuiService")

	local function fn()
		local flag = false
		local flag2 = false
		local flag3 = false
		local flag4 = false

		pcall(function()
			flag = UserInputService.TouchEnabled
			flag2 = UserInputService.KeyboardEnabled
			flag3 = UserInputService.MouseEnabled
			flag4 = UserInputService.GamepadEnabled
		end)

		local flag5 = false

		pcall(function()
			flag5 = GuiService:IsTenFootInterface()
		end)

		if flag5 or flag4 and not flag and not flag2 then
			return "console"
		end

		if flag2 and flag3 then
			return "pc"
		end

		if flag then
			local currentCamera = workspace.CurrentCamera
			local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(390, 760)
			return math.min(viewportSize.X, viewportSize.Y) >= 600 and "tablet" or "phone"
		end

		return "pc"
	end

	local function fn2()
		_G.YesDevice = fn()
		_G.YesIsTouch = _G.YesDevice == "phone" or _G.YesDevice == "tablet"
		_G.YesIsPhone = _G.YesDevice == "phone"
		_G.YesIsTablet = _G.YesDevice == "tablet"
		_G.YesIsConsole = _G.YesDevice == "console"
	end

	fn2()
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			fn2()
		end)
	end
end

do
	local tbl2 = { AUTO_STEAL = false, RADIUS = 12 }

	local tbl3 = {
		{
			min = Vector3.new(-337.4483, -3.898971, -122.39776),
			max = Vector3.new(-328.00458, -3.898971, 242.62563),
		},
		{
			min = Vector3.new(-327.25766, -3.899109, -122.22862),
			max = Vector3.new(-320.6009, -3.899109, 242.61226),
		},
		{
			min = Vector3.new(-319.7834, -3.89897, -122.22709),
			max = Vector3.new(-312.90833, -3.89897, 242.58562),
		},
		{
			min = Vector3.new(-312.44565, -3.899108, -122.38983),
			max = Vector3.new(-305.4899, -3.899108, 242.45682),
		},
		{
			min = Vector3.new(-305.03705, -3.89897, -122.23074),
			max = Vector3.new(-293.9575, -3.89897, 242.60687),
		},
		{
			min = Vector3.new(-491.4486, -3.898972, -122.25326),
			max = Vector3.new(-481.81174, -3.898972, 242.615),
		},
		{
			min = Vector3.new(-498.97107, -3.89897, -122.38277),
			max = Vector3.new(-491.74884, -3.89897, 242.61206),
		},
		{
			min = Vector3.new(-506.43674, -3.898972, -122.411476),
			max = Vector3.new(-499.31854, -3.898972, 242.61598),
		},
		{
			min = Vector3.new(-513.78357, -3.898972, -122.2233),
			max = Vector3.new(-506.80185, -3.898972, 242.62709),
		},
		{
			min = Vector3.new(-525.23694, -3.898972, -122.40981),
			max = Vector3.new(-514.265, -3.898972, 242.60893),
		},
	}

	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local localPlayer2 = Players.LocalPlayer
	local connection = nil

	local function fn()
		localPlayer2.DevEnableMouseLock = true
		localPlayer2.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam

		if connection then
			connection:Disconnect()
		end

		connection = RunService.RenderStepped:Connect(function()
			local currentCamera = workspace.CurrentCamera

			if currentCamera and currentCamera.CameraSubject and currentCamera.CameraType == Enum.CameraType.Custom then
				currentCamera.CFrame = currentCamera.CFrame
			end
		end)
	end

	fn()

	localPlayer2.CharacterAdded:Connect(function()
		task.wait(0.5)
		fn()
	end)

	local tbl4 = {}
	local tbl5 = {}
	local n = 0

	_G.getSafePollRate = function()
		if os.clock() < n then
			return 0.27
		end
		return 0.1
	end

	_G.triggerSafePollBoost = function()
		n = os.clock() + 3
	end

	local tbl6 = {}

	local function fn2()
		local character = localPlayer2.Character
		return character and character:FindFirstChild("HumanoidRootPart")
	end

	local function fn3(arg)
		for i, v in ipairs(tbl3) do
			if arg.X >= math.min(v.min.X, v.max.X) and arg.X <= math.max(v.min.X, v.max.X) and arg.Z >= math.min(v.min.Z, v.max.Z) and arg.Z <= math.max(v.min.Z, v.max.Z) then
				return i
			end
		end
	end

	local function fn4(arg)
		local parent = arg.Parent
		if not parent then
			return
		end

		if parent:IsA("Attachment") and parent.Parent then
			parent = parent.Parent
		end

		if parent:IsA("BasePart") then
			return parent.Position
		end

		if parent:IsA("Model") then
			return parent:GetPivot().Position
		end
	end

	local function fn5(arg)
		if not tbl then
			return false
		end
		local selectedPetData = tbl.SelectedPetData
		if not selectedPetData then
			return false
		end
		local model = arg:FindFirstAncestorOfClass("Model")
		if not model then
			return false
		end

		if selectedPetData.plot then
			if not arg:FindFirstAncestor(selectedPetData.plot) then
				return false
			end
		end

		if selectedPetData.slot then
			if arg:FindFirstAncestor(selectedPetData.slot) then
				return true
			end

			if model.Name == selectedPetData.slot then
				return true
			end

			if model.Parent and model.Parent.Name == selectedPetData.slot then
				return true
			end
		end

		if selectedPetData.name then
			local v = string.lower(selectedPetData.name)

			while model do
				if model.Name and string.lower(model.Name) == v then
					return true
				end
				model = model.Parent
			end
		end

		return false
	end

	local function fn6(arg, arg2)
		if not arg or not arg.Parent then
			return false
		end

		if not arg.Enabled then
			return false
		end
		local v = fn4(arg)
		if not v then
			return false
		end

		if arg:FindFirstAncestorOfClass("Model") then
			local plots = workspace:FindFirstChild("Plots")

			if plots then
				local model = arg:FindFirstAncestorWhichIsA("Model")

				while model and model.Parent ~= plots do
					model = model.Parent
				end

				if model then
					local plotSign = model:FindFirstChild("PlotSign")

					if plotSign then
						local surfaceGui = plotSign:FindFirstChildWhichIsA("SurfaceGui", true)
						surfaceGui = surfaceGui and surfaceGui:FindFirstChildWhichIsA("TextLabel", true)

						if surfaceGui then
							local str = surfaceGui.Text:lower()
							if str:find(game.Players.LocalPlayer.Name:lower(), 1, true) or str:find(game.Players.LocalPlayer.DisplayName:lower(), 1, true) then
								return false
							end
						end
					end
				end
			end
		end

		if _G.NEAREST_INSTANT_MODE == true then
			local v2 = fn3(arg2)
			local v3 = fn3(v)
			if not v2 or v2 ~= v3 then
				return false
			end
		end

		if _G.NEAREST_INSTANT_MODE ~= true then
			if not fn5(arg) then
				return false
			end
		end

		return (v - arg2).Magnitude <= math.min(tbl2.RADIUS, typeof(arg.MaxActivationDistance) == "number" and arg.MaxActivationDistance > 0 and arg.MaxActivationDistance or tbl2.RADIUS)
	end

	local function fn7(arg, arg2)
		local now = os.clock()
		local v = tbl5[arg]
		if v and now - v < arg2 then
			return false
		end
		tbl5[arg] = now
		return true
	end

	local function fn8(arg, arg2, arg3)
		if not arg or not arg.Parent then
			return
		end

		if not arg.Enabled then
			return
		end

		if not fn7(arg, arg3) then
			return
		end

		for i = 1, arg2 do
			pcall(function()
				fireproximityprompt(arg, 0)
			end)
		end
	end

	local function fn9(arg)
		if tbl4[arg] then
			return
		end
		tbl4[arg] = true

		local function fn10()
			local v = fn2()
			if not v then
				return
			end

			if fn6(arg, v.Position) then
				tbl2.AUTO_STEAL = true
				local now = os.clock()
				local v2 = tbl6[arg]

				if not v2 or now - v2 >= 0.08 then
					tbl6[arg] = now
					fn8(arg, 25, 0)
				end
			end
		end

		task.defer(function()
			fn10()
		end)

		pcall(function()
			arg:GetPropertyChangedSignal("Enabled"):Connect(function()
				if arg.Enabled then
					fn10()
				end
			end)
		end)

		arg.AncestryChanged:Connect(function()
			if not arg:IsDescendantOf(workspace) then
				tbl4[arg] = nil
				tbl5[arg] = nil
				tbl6[arg] = nil
			end
		end)
	end

	local function fn10()
		local plots = workspace:FindFirstChild("Plots")
		if not plots then
			return
		end

		for _, child in ipairs(plots:GetChildren()) do
			local animalPodiums = child:FindFirstChild("AnimalPodiums")

			if animalPodiums then
				for _, descendant in ipairs(animalPodiums:GetDescendants()) do
					if descendant:IsA("ProximityPrompt") then
						fn9(descendant)
					end
				end
			end
		end
	end

	fn10()

	workspace.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("ProximityPrompt") and descendant:FindFirstAncestor("AnimalPodiums") then
			fn9(descendant)
		end
	end)

	task.spawn(function()
		while task.wait(_G.getSafePollRate()) do
			local v = fn2()

			if not v then
				tbl2.AUTO_STEAL = false
			else
				local position = v.Position
				local autoSteal = false

				for k in pairs(tbl4) do
					if fn6(k, position) then
						autoSteal = true

						if tbl2.AUTO_STEAL then
							fn8(k, 3, 0.12)
							autoSteal = true
						end
					end
				end

				tbl2.AUTO_STEAL = autoSteal
			end
		end
	end)
end

local players, runService, replicatedStorage, tweenService, workspace_, localPlayer2, playerGui, v, scale, v2
local fn

do
	local tbl2 = {
		Players = game:GetService("Players"),
		RunService = game:GetService("RunService"),
		UserInputService = game:GetService("UserInputService"),
		ReplicatedStorage = game:GetService("ReplicatedStorage"),
		TweenService = game:GetService("TweenService"),
		HttpService = game:GetService("HttpService"),
		Workspace = game:GetService("Workspace"),
		Lighting = game:GetService("Lighting"),
		GuiService = game:GetService("GuiService"),
		TeleportService = game:GetService("TeleportService"),
	}

	players = tbl2.Players
	runService = tbl2.RunService
	local userInputService = tbl2.UserInputService
	replicatedStorage = tbl2.ReplicatedStorage
	tweenService = tbl2.TweenService
	local httpService = tbl2.HttpService
	workspace_ = tbl2.Workspace
	localPlayer2 = players.LocalPlayer
	playerGui = localPlayer2:WaitForChild("PlayerGui")
	local obj = nil

	obj = setmetatable({}, { __index = function(arg, arg2)
		local net = replicatedStorage.Packages.Net

		if arg2:sub(1, 3) == "RE/" then
			arg2:sub(4)
		else
			if arg2:sub(1, 3) ~= "RF/" then
				return nil
			end
			arg2:sub(4)
		end

		local v3 = nil

		for k, v4 in net:GetChildren() do
			if v4.Name == arg2 then
				v3 = net:GetChildren()[k + 1]
				break
			else
				v3 = nil
			end
		end

		if v3 and not rawget(obj, arg2) then
			rawset(obj, arg2, v3)
		end

		return rawget(obj, arg2)
	end })

	local tbl3 = { LarpNet = function(arg, arg2)
		return obj[arg2]
	end }

	localPlayer2:GetMouse()

	local function fn2()
		return userInputService.TouchEnabled and not userInputService.KeyboardEnabled and not userInputService.MouseEnabled
	end

	v = fn2()
	scale = 0.79

	local tbl4 = {
		Positions = {
			AutoSteal = { X = 0, Y = 0, OffsetX = 14, OffsetY = 80 },
			TargetControls = { X = 0, Y = 0, OffsetX = 14 + 320 * scale + 10, OffsetY = 80 },
		},
		MenuKey = "LeftControl",
		MobileGuiScale = 0.5,
		StealNearest = false,
		StealHighest = true,
		StealPriority = false,
		DefaultToNearest = false,
		DefaultToHighest = false,
		DefaultToPriority = false,
		UILocked = false,
		HideAutoSteal = false,
		CompactAutoSteal = false,
		InstantSteal = false,
		nextBaseEnabled = false,
		XRay = false,
		PlayerESP = false,
		podiumESP = false,
		TurretESP = false,
		TrapESP = false,
		BrainrotESP = false,
		BrainrotESPMinGen = 10000000,
		AntiRagdoll = true,
		AntiBeeDisco = true,
		AntiDie = true,
		AutoTurret = false,
		AntiLag = false,
		CarpetSpeed = false,
		CarpetSpeedValue = 140,
		CarpetSpeedKey = "Q",
		InfJump = true,
		AutoKickOnSteal = false,
		FOV = 80,
		ResetCooldown = 2.5,
		ResetFlingTime = 5,
		PriorityList = {
			"Strawberry Elephant",
			"Meowl",
			"Skibidi Toilet",
			"Headless Horseman",
			"Dragon Gingerini",
			"Dragon Cannelloni",
			"Ketupat Bros",
			"Hydra Dragon Cannelloni",
			"La Supreme Combinasion",
			"Love Love Bear",
			"Ginger Gerat",
			"Cerberus",
			"Capitano Moby",
			"La Casa Boo",
			"Burguro and Fryuro",
			"Spooky and Pumpky",
			"Cooki and Milki",
			"Rosey and Teddy",
			"Popcuru and Fizzuru",
			"Reinito Sleighito",
			"Fragrama and Chocrama",
			"Garama and Madundung",
			"Ketchuru and Musturu",
			"La Secret Combinasion",
			"Tralaledon",
			"Tictac Sahur",
			"Ketupat Kepat",
			"Tang Tang Keletang",
			"Orcaledon",
			"La Ginger Sekolah",
			"Los Spaghettis",
			"Lavadorito Spinito",
			"Swaggy Bros",
			"La Taco Combinasion",
			"Los Primos",
			"Chillin Chili",
			"Tuff Toucan",
			"W or L",
			"Chillin Chili",
			"Chipso and Queso",
		},
	}

	DeepCopy = function(arg)
		if type(arg) ~= "table" then
			return arg
		end
		local tbl5 = {}

		for k, v3 in pairs(arg) do
			tbl5[k] = DeepCopy(v3)
		end

		return tbl5
	end

	MergeDefaults = function(arg, arg2)
		for k, v3 in pairs(arg2) do
			if type(v3) == "table" then
				if type(arg[k]) ~= "table" then
					arg[k] = DeepCopy(v3)
				else
					MergeDefaults(arg[k], v3)
				end
			elseif arg[k] == nil then
				arg[k] = v3
			end
		end
	end

	v2 = DeepCopy(tbl4)

	NormalizeKeyName = function(arg, arg2)
		if type(arg) ~= "string" or arg == "" then
			return arg2
		end

		local v3 = ({
			ALT = "LeftAlt",
			LALT = "LeftAlt",
			RALT = "RightAlt",
			CTRL = "LeftControl",
			CONTROL = "LeftControl",
			LCTRL = "LeftControl",
			RCTRL = "RightControl",
			SHIFT = "LeftShift",
			LSHIFT = "LeftShift",
			RSHIFT = "RightShift",
			WIN = "LeftSuper",
			CMD = "LeftSuper",
			META = "LeftSuper",
		})[string.upper(arg)] or arg

		return Enum.KeyCode[v3] and v3 or arg
	end

	PrettyKeyName = function(arg)
		local v3 = ({
			LeftAlt = "ALT",
			RightAlt = "RALT",
			LeftControl = "CTRL",
			RightControl = "RCTRL",
			LeftShift = "SHIFT",
			RightShift = "RSHIFT",
			LeftSuper = "WIN",
			RightSuper = "RWIN",
		})[arg]

		local str

		if v3 then
			str = v3
		else
			str = tostring(arg or "")
		end

		return str
	end

	if isfile and isfile("SlicedzHub.json") then
		pcall(function()
			local json = readfile("SlicedzHub.json")
			if not json or json == "" then
				return
			end
			local data = httpService:JSONDecode(json)
			if type(data) ~= "table" then
				return
			end
			local v3 = nil

			if type(data.PriorityList) == "table" then
				v3 = DeepCopy(data.PriorityList)
			end

			MergeDefaults(data, tbl4)

			if v3 ~= nil then
				data.PriorityList = v3
			end

			v2 = data
		end)
	end

	if v2.Positions then
		v2.Positions.Settings = { X = 0.5, Y = 0.5, OffsetX = 0, OffsetY = 0 }
	end

	if v2.LayoutRev ~= 4 then
		v2.Positions = v2.Positions or {}
		v2.Positions.AutoSteal = DeepCopy(tbl4.Positions.AutoSteal)
		v2.Positions.TargetControls = DeepCopy(tbl4.Positions.TargetControls)
		v2.LayoutRev = 4
		v2.FixedLayout = nil
		_needMigrationSave = true
	end

	EnsureSavedKeybinds = function()
		v2.SavedKeybinds = v2.SavedKeybinds or {}
		v2.SavedKeybinds.MenuKey = NormalizeKeyName(v2.SavedKeybinds.MenuKey or v2.MenuKey, tbl4.MenuKey or "LeftControl")
	end

	ApplySavedKeybindsToConfig = function()
		EnsureSavedKeybinds()
		v2.MenuKey = v2.SavedKeybinds.MenuKey
	end

	NormalizeAllKeybinds = function()
		EnsureSavedKeybinds()
		ApplySavedKeybindsToConfig()
	end

	NormalizeAllKeybinds()

	fn = function()
		if writefile then
			pcall(function()
				NormalizeAllKeybinds()
				local v3 = DeepCopy(v2)
				v3.MenuKey = v2.SavedKeybinds.MenuKey
				writefile("SlicedzHub.json", httpService:JSONEncode(v3))
			end)
		end
	end

	if _needMigrationSave then
		fn()
	end

	_G.StickyCarpetSpeed = v2.CarpetSpeed == true
	_G.StickyCarpetSpeedValue = math.clamp(tonumber(v2.CarpetSpeedValue) or 140, 20, 400)
	_G.StickyCarpetSpeedKeyName = type(v2.CarpetSpeedKey) == "string" and v2.CarpetSpeedKey or "Q"
	_G.StickyInfJump = v2.InfJump ~= false
	_G.StickyAutoKickOnSteal = v2.AutoKickOnSteal == true
	_G.StickyFOV = tonumber(v2.FOV) or 80
	_G.StickyResetCooldown = tonumber(v2.ResetCooldown) or 2.5
	_G.StickyResetFlingTime = tonumber(v2.ResetFlingTime) or 5
	_G.StickyAntiBee = v2.AntiBeeDisco ~= false
	_G.StickyAntiDieDisabled = v2.AntiDie == false

	local function fn3()
		v2.CarpetSpeedValue = math.clamp(tonumber(_G.StickyCarpetSpeedValue) or 140, 20, 400)
		v2.FOV = tonumber(_G.StickyFOV) or v2.FOV
		v2.ResetCooldown = tonumber(_G.StickyResetCooldown) or v2.ResetCooldown
		v2.ResetFlingTime = tonumber(_G.StickyResetFlingTime) or v2.ResetFlingTime
		v2.AntiBeeDisco = _G.StickyAntiBee ~= false
		v2.AntiDie = _G.StickyAntiDieDisabled ~= true

		if type(_G.StickyCarpetSpeedKeyName) == "string" then
			v2.CarpetSpeedKey = _G.StickyCarpetSpeedKeyName
		end

		if _G.StickyInfJump ~= nil then
			v2.InfJump = _G.StickyInfJump == true
		end

		if _G.StickyCarpetSpeed ~= nil then
			v2.CarpetSpeed = _G.StickyCarpetSpeed == true
		end

		if _G.StickyAutoKickOnSteal ~= nil then
			v2.AutoKickOnSteal = _G.StickyAutoKickOnSteal == true
		end
	end

	local v3 = nil

	_G.StickySaveConfigNow = function()
		pcall(function()
			fn3()
			local json = httpService:JSONEncode(v2)

			if json ~= v3 then
				v3 = json
				fn()
			end
		end)
	end
end

task.spawn(function()
	task.wait(5)

	while true do
		_G.StickySaveConfigNow()
		task.wait(5)
	end
end)

do
	local flag = false
	local tbl2 = {}

	_G.StickyOnBoot = function(arg)
		if type(arg) ~= "function" then
			return
		end

		if flag then
			task.spawn(arg)
			return
		end
		tbl2[#tbl2 + 1] = arg
	end

	task.spawn(function()
		local n = os.clock() + 30

		while not workspace:FindFirstChild("Plots") and os.clock() < n do
			task.wait(0.25)
		end

		local n2 = os.clock() + 15

		while os.clock() < n2 do
			local character = localPlayer2.Character
			if not (character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChildOfClass("Humanoid")) then
				task.wait(0.25)
				continue
			end
			break
		end

		task.wait(1.5)
		flag = true

		for _, v3 in ipairs(tbl2) do
			task.spawn(v3)
		end

		tbl2 = {}
	end)
end

game:GetService("Workspace")

do
	local Players = game:GetService("Players")
	local localPlayer3 = Players.LocalPlayer
	local v3 = v2
	local v4 = fn

	local function fn2(arg, arg2)
		local slicedzSyncToggleUI = _G.SlicedzSyncToggleUI

		if type(slicedzSyncToggleUI) == "function" then
			pcall(slicedzSyncToggleUI, arg, arg2)
		end
	end

	if _G.StickyXray == nil then
		_G.StickyXray = true
	end

	if _G.StickyXrayAlpha == nil then
		_G.StickyXrayAlpha = 0.9
	end

	local function fn3()
		local tbl2 = { "Base", "PlotSign", "FriendPanel", "Cash", "Laser", "Decorations", "Skin", "Unlock", "Purchases" }
		local obj = setmetatable({}, { __mode = "k" })
		local tbl3 = {}
		local n = 0

		local function fn4(arg, arg2)
			if not arg:IsA("BasePart") then
				return
			end

			if obj[arg] == nil then
				obj[arg] = arg.Transparency == arg2 and 0 or arg.Transparency
			end

			local v5 = obj[arg]
			if v5 >= 1 then
				return
			end
			local transparency = v5 + (1 - v5) * arg2

			if math.abs(arg.Transparency - transparency) > 0.01 then
				arg.Transparency = transparency
			end
		end

		local function fn5()
			while _G.StickyStealHold do
				task.wait(0.15)
			end
		end

		local function fn6(arg, arg2, arg3)
			if not arg or arg3 ~= n then
				return
			end
			fn4(arg, arg2)
			local n2 = 0

			for _, descendant in ipairs(arg:GetDescendants()) do
				if arg3 ~= n then
					return
				end
				fn4(descendant, arg2)
				n2 += 1

				if n2 % 250 == 0 then
					task.wait()
				end
			end

			tbl3[#tbl3 + 1] = arg.DescendantAdded:Connect(function(descendant)
				if arg3 == n then
					fn4(descendant, arg2)
				end
			end)
		end

		local function fn7(arg, arg2, arg3)
			if not arg or arg3 ~= n then
				return
			end

			for _, v5 in ipairs(tbl2) do
				if arg3 ~= n then
					return
				end
				fn6(arg:FindFirstChild(v5), arg2, arg3)
			end

			if arg3 ~= n then
				return
			end

			tbl3[#tbl3 + 1] = arg.ChildAdded:Connect(function(child)
				if arg3 ~= n then
					return
				end

				for _, v5 in ipairs(tbl2) do
					if child.Name == v5 then
						fn6(child, arg2, arg3)
						break
					end
				end
			end)

			local animalPodiums = arg:FindFirstChild("AnimalPodiums")
			if not animalPodiums then
				return
			end

			local function fn8(arg4)
				for _, child in ipairs(arg4:GetChildren()) do
					if child.Name == "Claim" then
						fn6(child, arg2, arg3)
					elseif child.Name == "Base" then
						fn6(child:FindFirstChild("Decorations"), arg2, arg3)
					end
				end
			end

			for _, child in ipairs(animalPodiums:GetChildren()) do
				fn8(child)
			end

			tbl3[#tbl3 + 1] = animalPodiums.ChildAdded:Connect(function(child)
				if arg3 ~= n then
					return
				end
				task.wait(0.1)

				if arg3 == n then
					fn8(child)
				end
			end)
		end

		local function fn8()
			for _, v5 in ipairs(tbl3) do
				pcall(function()
					v5:Disconnect()
				end)
			end

			local n2 = n + 1
			tbl3 = {}
			n = n2
		end

		_G.StickyEnableXray = function()
			v3.XRay = true
			v4()
			fn2("XRay", true)
			fn2("X-Ray", true)
			fn8()
			local v5 = n
			local n2 = math.clamp(tonumber(_G.StickyXrayAlpha) or 0.9, 0, 1)

			task.spawn(function()
				while v5 == n and not workspace:FindFirstChild("Plots") do
					task.wait(0.5)
				end

				local plots = workspace:FindFirstChild("Plots")
				if v5 ~= n or not plots then
					return
				end
				fn5()

				for _, child in ipairs(plots:GetChildren()) do
					if v5 ~= n then
						return
					end
					pcall(fn7, child, n2, v5)
					task.wait()
					fn5()
				end

				tbl3[#tbl3 + 1] = plots.ChildAdded:Connect(function(child)
					if v5 ~= n then
						return
					end
					task.wait(0.2)
					pcall(fn7, child, n2, v5)
				end)
			end)
		end

		_G.StickyDisableXray = function()
			v3.XRay = false
			v4()
			fn2("XRay", false)
			fn2("X-Ray", false)
			fn8()
			local v5 = obj
			obj = setmetatable({}, { __mode = "k" })

			for k, v6 in pairs(v5) do
				pcall(function()
					if k:IsA("BasePart") then
						k.Transparency = v6
					end
				end)
			end
		end

		setXRay = function(arg)
			if arg then
				_G.StickyEnableXray()
			else
				_G.StickyDisableXray()
			end
		end

		_G.setXRay = setXRay
	end

	fn3()

	if _G.StickyAutoKickOnSteal == nil then
		_G.StickyAutoKickOnSteal = v2.AutoKickOnSteal == true
	end

	if _G.StickyKickToPS == nil then
		_G.StickyKickToPS = false
	end

	local function fn4()
		local function fn5(arg)
			local match = tostring(arg or ""):match("^%s*(.-)%s*$")
			if match == "" then
				return nil
			end

			if not match:find("://", 1, true) then
				return match
			end
			return match:match("[?&]privateServerLinkCode=([^&]+)") or match:match("[?&]linkCode=([^&]+)") or match:match("[?&]code=([^&]+)")
		end

		local function stickyKickOut()
			if _G.StickyKickToPS == true then
				local v5 = fn5(_G.StickyPrivateServerLink)

				if v5 and v5 ~= "" then
					if pcall(function()
						game:GetService("ExperienceService"):LaunchExperience({ placeId = tonumber(_G.StickyPrivateServerPlaceId) or game.PlaceId, linkCode = v5 })
					end) then
						return
					end
				end
			end

			if pcall(function()
				game:Shutdown()
			end) then
				return
			end

			pcall(function()
				localPlayer2:Kick("")
			end)
		end

		_G.StickyKickOut = stickyKickOut

		task.spawn(function()
			local playerGui2 = localPlayer2:FindFirstChildOfClass("PlayerGui") or localPlayer2:WaitForChild("PlayerGui", 10)
			if not playerGui2 then
				return
			end
			local obj = setmetatable({}, { __mode = "k" })

			local function fn6(arg)
				return type(arg) == "string" and arg:lower():find("you stole", 1, true) ~= nil
			end

			local function fn7(arg)
				return arg:IsA("TextLabel") or arg:IsA("TextButton") or arg:IsA("TextBox")
			end

			local function fn8(arg)
				if obj[arg] then
					return
				end
				obj[arg] = true
				if _G.StickyAutoKickOnSteal == true and fn6(arg.Text) then
					stickyKickOut()
					return
				end

				arg:GetPropertyChangedSignal("Text"):Connect(function()
					if _G.StickyAutoKickOnSteal == true and fn6(arg.Text) then
						stickyKickOut()
					end
				end)
			end

			local function fn9(child)
				child.DescendantAdded:Connect(function(descendant)
					if fn7(descendant) then
						fn8(descendant)
					end
				end)

				local n = 0

				for _, descendant in ipairs(child:GetDescendants()) do
					n += 1

					if n % 200 == 0 then
						task.wait()
					end

					if fn7(descendant) then
						fn8(descendant)
					end
				end
			end

			while _G.StickyAutoKickOnSteal ~= true do
				task.wait(1)
			end

			playerGui2.ChildAdded:Connect(fn9)

			for _, child in ipairs(playerGui2:GetChildren()) do
				fn9(child)
			end
		end)
	end

	fn4()

	if _G.StickyInfJump == nil then
		_G.StickyInfJump = v2.InfJump ~= false
	end

	local function fn5()
		local UserInputService = game:GetService("UserInputService")
		local RunService = game:GetService("RunService")
		local flag = false

		local function fn6()
			local character = localPlayer2.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			character = character and character:FindFirstChildOfClass("Humanoid")
			if not humanoidRootPart or not character or character.Health <= 0 then
				return
			end
			humanoidRootPart.Velocity = Vector3.new(humanoidRootPart.Velocity.X, character.JumpPower or 50, humanoidRootPart.Velocity.Z)
		end

		local function fn7()
			return _G.StickyInfJump ~= false
		end

		UserInputService.JumpRequest:Connect(function()
			if fn7() then
				fn6()
			end
		end)

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed and input.KeyCode == Enum.KeyCode.Space then
				flag = true
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.Space then
				flag = false
			end
		end)

		RunService.Heartbeat:Connect(function()
			if flag and fn7() then
				fn6()
			end
		end)
	end

	fn5()

	if _G.StickyCarpetSpeed == nil then
		_G.StickyCarpetSpeed = v2.CarpetSpeed == true
	end

	if _G.StickyCarpetSpeedValue == nil then
		_G.StickyCarpetSpeedValue = tonumber(v2.CarpetSpeedValue) or 140
	end

	if _G.StickyCarpetSpeedKeyName == nil then
		_G.StickyCarpetSpeedKeyName = v2.CarpetSpeedKey or "Q"
	end

	local function fn6()
		local UserInputService = game:GetService("UserInputService")
		local RunService = game:GetService("RunService")
		local connection = nil

		_G.StickySetCarpetSpeed = function(arg)
			_G.StickyCarpetSpeed = arg and true or false
			_G.StickyCarpetSpeedActive = _G.StickyCarpetSpeed

			if connection then
				connection:Disconnect()
				connection = nil
			end

			if not _G.StickyCarpetSpeed then
				return
			end

			if _G.StickyEquipCarpet then
				task.spawn(function()
					pcall(_G.StickyEquipCarpet)
				end)
			end

			connection = RunService.Heartbeat:Connect(function()
				if localPlayer2:GetAttribute("Stealing") == true then
					_G.StickySetCarpetSpeed(false)
					return
				end
				local character = localPlayer2.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local upperTorso = character and (character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart"))
				if not humanoid or not upperTorso then
					return
				end

				if not (_G.StickyCarpetEngaging and _G.StickyCarpetEngaging()) and _G.StickyEquipCarpet then
					pcall(_G.StickyEquipCarpet)
				end

				local n = math.clamp(tonumber(_G.StickyCarpetSpeedValue) or 140, 20, 400)
				local moveDirection = humanoid.MoveDirection
				local y = upperTorso.Velocity.Y

				if moveDirection.Magnitude > 0 then
					upperTorso.Velocity = Vector3.new(moveDirection.X * n, y, moveDirection.Z * n)
				else
					upperTorso.Velocity = Vector3.new(0, y, 0)
				end
			end)
		end

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then
				return
			end

			if input.KeyCode.Name ~= (_G.StickyCarpetSpeedKeyName or "Q") then
				return
			end

			if localPlayer2:GetAttribute("Stealing") == true then
				return
			end
			local flag = not (_G.StickyCarpetSpeed == true)
			_G.StickySetCarpetSpeed(flag)

			if flag and _G.StickyEquipCarpet then
				task.spawn(function()
					pcall(_G.StickyEquipCarpet)
				end)
			end

			if _G.StickySaveConfigNow then
				task.spawn(_G.StickySaveConfigNow)
			end
		end)

		_G.StickyOnBoot(function()
			if v2.CarpetSpeed == true then
				pcall(_G.StickySetCarpetSpeed, true)
			end
		end)
	end

	fn6()
	local playerESP = v3.PlayerESP == true
	local tbl2 = {}

	local tbl3 = {
		["Boogie Bomb"] = true,
		["Medusa's Head"] = true,
		["Body Swap Potion"] = true,
		["Laser Cape"] = true,
		["Rainbowrath Sword"] = true,
		["Gummy Bear"] = true,
	}

	local function fn7(arg)
		local character = arg.Character
		if not character then
			return nil
		end

		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("Tool") then
				return child.Name
			end
		end

		return nil
	end

	local function fn8(arg)
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Name = "PlayerESP_" .. tostring(arg.UserId)
		billboardGui.Size = UDim2.new(0, 170, 0, 34)
		billboardGui.StudsOffsetWorldSpace = Vector3.new(0, 2.8, 0)
		billboardGui.AlwaysOnTop = true
		billboardGui.LightInfluence = 0
		billboardGui.ResetOnSpawn = false
		local textLabel = Instance.new("TextLabel", billboardGui)
		textLabel.Size = UDim2.new(1, 0, 0, 18)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextSize = 14
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.TextStrokeTransparency = 0.4
		textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		textLabel.Text = arg.Name
		local textLabel2 = Instance.new("TextLabel", billboardGui)
		textLabel2.Name = "ToolLabel"
		textLabel2.Size = UDim2.new(1, 0, 0, 13)
		textLabel2.Position = UDim2.new(0, 0, 0, 18)
		textLabel2.BackgroundTransparency = 1
		textLabel2.Font = Enum.Font.GothamMedium
		textLabel2.TextSize = 11
		textLabel2.TextColor3 = Color3.fromRGB(100, 220, 255)
		textLabel2.TextStrokeTransparency = 0.4
		textLabel2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		textLabel2.Text = fn7(arg) or ""
		return billboardGui, textLabel
	end

	local function fn9(arg)
		if arg == localPlayer3 then
			return
		end
		local humanoidRootPart = arg.Character and arg.Character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then
			return
		end
		local humanoid = arg.Character:FindFirstChild("Humanoid")

		if humanoid then
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end

		local userId = arg.UserId
		local v5 = tbl2[userId]

		if not v5 or not v5.bb or not v5.bb.Parent then
			if v5 and v5.bb then
				pcall(function()
					v5.bb:Destroy()
				end)
			end

			local v6, v7 = fn8(arg)
			v6.Adornee = humanoidRootPart
			v6.Parent = humanoidRootPart
			tbl2[userId] = { bb = v6, nameLbl = v7, player = arg }
		elseif v5.bb.Adornee ~= humanoidRootPart then
			v5.bb.Adornee = humanoidRootPart
			v5.bb.Parent = humanoidRootPart
		end
	end

	local function fn10()
		for k, v5 in pairs(tbl2) do
			if v5.bb then
				pcall(v5.bb.Destroy, v5.bb)
			end

			tbl2[k] = nil
		end
	end

	_G.StickyOnBoot(function()
		while true do
			task.wait(0.5)

			if playerESP then
				for _, player in ipairs(Players:GetPlayers()) do
					if player == localPlayer3 then
						continue
					end
					pcall(fn9, player)
				end

				for _, v5 in pairs(tbl2) do
					if v5.bb and v5.bb.Parent then
						pcall(function()
							local toolLabel = v5.bb:FindFirstChild("ToolLabel")

							if toolLabel then
								local v6 = fn7(v5.player)
								toolLabel.Text = v6 or ""

								if v5.nameLbl then
									v5.nameLbl.TextColor3 = v6 and tbl3[v6] and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(255, 255, 255)
								end
							end
						end)
					end
				end
			else
				fn10()
			end
		end
	end)

	_G.setPlayerESP = function(arg)
		playerESP = arg and true or false
		v3.PlayerESP = playerESP
		v4()
		fn2("PlayerESP", playerESP)
		fn2("Player ESP", playerESP)

		if not playerESP then
			pcall(fn10)
		end
	end

	_G.StickyOnBoot(function()
		if v3.XRay == true then
			pcall(setXRay, true)
		end

		fn2("PlayerESP", playerESP)
	end)
end

local v3
v3 = v2
local v4
v4 = fn
local fn2

fn2 = function(arg, arg2)
	local slicedzSyncToggleUI = _G.SlicedzSyncToggleUI

	if type(slicedzSyncToggleUI) == "function" then
		pcall(slicedzSyncToggleUI, arg, arg2)
	end
end

do
	local function fn3()
		if _G.__NextBaseCleanup then
			pcall(_G.__NextBaseCleanup)
		end

		local CoreGui = game:GetService("CoreGui")
		local plots = workspace:WaitForChild("Plots")

		local tbl2 = {
			Vector3.new(-342.439, 10.399, 113.107),
			Vector3.new(-342.439, 10.465, 6.107),
			Vector3.new(-476.752, 10.465, 114.107),
			Vector3.new(-476.752, 10.465, 7.107),
			Vector3.new(-342.44, 10.464, 220.107),
			Vector3.new(-476.752, 10.465, 221.107),
			Vector3.new(-342.439, 10.465, -100.893),
			Vector3.new(-476.752, 10.465, -99.893),
		}

		local n = 6
		local str = "Empty Base"
		local v5 = utf8.char(11015)

		local function fn4(arg)
			local ok, result = pcall(function()
				return (arg:GetBoundingBox())
			end)

			if not ok then
				return nil
			end
			local position = result.Position
			local v6 = nil
			local v7 = nil

			for i, v8 in ipairs(tbl2) do
				local n2 = position.X - v8.X
				local n3 = position.Z - v8.Z
				local v9 = math.sqrt(n2 * n2 + n3 * n3)

				if not v6 or v9 < v6 then
					v6 = v9
					v7 = i
				end
			end

			return v6 and v6 <= n and v7 or nil
		end

		local tbl3 = {}
		local tbl4 = {}
		local tbl5 = {}
		local part = Instance.new("Part")
		part.Name = "__NextBaseAnchor"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Transparency = 1
		part.Size = Vector3.one
		part.Parent = CoreGui
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Name = "NextBaseBillboard"
		billboardGui.Adornee = part
		billboardGui.Size = UDim2.fromScale(32, 13)
		billboardGui.StudsOffset = Vector3.new(0, 10, 0)
		billboardGui.MaxDistance = math.huge
		billboardGui.AlwaysOnTop = true
		billboardGui.LightInfluence = 0
		billboardGui.Enabled = false
		billboardGui.Parent = part
		local textLabel = Instance.new("TextLabel", billboardGui)
		textLabel.BackgroundTransparency = 1
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.Position = UDim2.fromScale(0.5, 0.3)
		textLabel.Size = UDim2.fromScale(0.95, 0.5)
		textLabel.Font = Enum.Font.GothamBlack
		textLabel.Text = v5 .. "  NEXT  " .. v5
		textLabel.TextScaled = true
		textLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
		textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		textLabel.TextStrokeTransparency = 0
		local textLabel2 = Instance.new("TextLabel", billboardGui)
		textLabel2.BackgroundTransparency = 1
		textLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel2.Position = UDim2.fromScale(0.5, 0.72)
		textLabel2.Size = UDim2.fromScale(0.95, 0.42)
		textLabel2.Font = Enum.Font.GothamBlack
		textLabel2.Text = "EMPTY BASE"
		textLabel2.TextScaled = true
		textLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		textLabel2.TextStrokeTransparency = 0

		local function fn5(arg)
			return arg.Text:gsub("^%s+", ""):gsub("%s+$", "") == str
		end

		local function fn6()
			local v6 = nil

			for i = 1, #tbl2 do
				local v7 = tbl3[i]

				if v7 and v7.label and fn5(v7.label) then
					v6 = i
					break
				else
					v6 = nil
				end
			end

			if v6 then
				part.CFrame = tbl3[v6].cf
				billboardGui.Enabled = true
			else
				billboardGui.Enabled = false
			end
		end

		local function fn7(arg)
			if tbl4[arg] then
				return
			end
			tbl4[arg] = true
			table.insert(tbl5, arg:GetPropertyChangedSignal("Text"):Connect(fn6))
		end

		local function fn8()
			for _, child in ipairs(plots:GetChildren()) do
				local plotSign = child:FindFirstChild("PlotSign")
				local model = plotSign and plotSign:FindFirstChild("Model")
				plotSign = plotSign and plotSign:FindFirstChild("SurfaceGui")
				plotSign = plotSign and plotSign:FindFirstChild("Frame")
				plotSign = plotSign and plotSign:FindFirstChild("TextLabel")

				if model and plotSign then
					local v6 = fn4(model)

					if v6 then
						tbl3[v6] = { label = plotSign, cf = select(1, model:GetBoundingBox()) }
						fn7(plotSign)
					end
				end
			end

			fn6()
		end

		fn8()

		table.insert(tbl5, plots.DescendantAdded:Connect(function(descendant)
			if descendant:IsA("TextLabel") then
				task.defer(fn8)
			end
		end))

		table.insert(tbl5, plots.ChildAdded:Connect(function()
			task.defer(fn8)
		end))

		_G.__NextBaseCleanup = function()
			for _, v6 in ipairs(tbl5) do
				pcall(function()
					v6:Disconnect()
				end)
			end

			if part then
				part:Destroy()
			end

			_G.__NextBaseCleanup = nil
		end
	end

	local function setNextBase(arg)
		local nextBaseEnabled = arg and true or false
		v3.nextBaseEnabled = nextBaseEnabled
		v4()
		fn2("NextBase", nextBaseEnabled)
		fn2("Next Base", nextBaseEnabled)
		fn2("Base Pointer", nextBaseEnabled)

		if nextBaseEnabled then
			task.spawn(function()
				pcall(fn3)
			end)
		elseif _G.__NextBaseCleanup then
			pcall(_G.__NextBaseCleanup)
		end
	end

	_G.setNextBase = setNextBase

	_G.StickyOnBoot(function()
		if v3.nextBaseEnabled then
			pcall(setNextBase, true)
		end
	end)
end

do
	local function fn3()
		if _G.__PodiumESPCleanup then
			pcall(_G.__PodiumESPCleanup)
		end

		local RunService = game:GetService("RunService")
		local hui = gethui and gethui() or game:GetService("CoreGui")
		local plots = workspace:FindFirstChild("Plots")
		if not plots then
			return
		end

		local function fn4()
			return workspace.CurrentCamera
		end

		if not fn4() then
			return
		end
		local color = Color3.fromRGB(255, 60, 60)
		local color2 = Color3.fromRGB(255, 255, 255)
		local flag = true
		local flag2 = true
		local n = 0.05
		local n2 = 2
		local n3 = 0.12

		local tbl2 = {
			{ 18.5, 1.531, -14.476, 90 },
			{ 18.5, 1.531, -6.976, 90 },
			{ 18.5, 1.531, 0.524, 90 },
			{ 18.5, 1.531, 8.024, 90 },
			{ 18.5, 1.531, 15.524, 90 },
			{ -18.536, 1.531, 15.524, -90 },
			{ -18.536, 1.531, 8.024, -90 },
			{ -18.536, 1.531, 0.524, -90 },
			{ -18.536, 1.531, -6.976, -90 },
			{ -18.536, 1.531, -14.476, -90 },
			{ 18.5, 19.531, -14.476, 90 },
			{ 18.5, 19.531, -6.976, 90 },
			{ 18.5, 19.531, 0.524, 90 },
			{ 18.5, 19.531, 8.024, 90 },
			{ 18.5, 19.531, 15.524, 90 },
			{ -18.38, 19.531, -14.452, -90 },
			{ -18.38, 19.531, -6.952, -90 },
			{ -18.38, 19.531, 0.548, -90 },
			{ 18.5, 36.531, -12.476, 90 },
			{ 18.5, 36.531, -4.976, 90 },
			{ 18.5, 36.531, 2.524, 90 },
			{ 18.5, 36.531, 10.024, 90 },
			{ 18.5, 36.531, 17.524, 90 },
			{ -18.472, 36.531, -12.501, -90 },
			{ -18.471, 36.531, -5.001, -90 },
			{ -18.471, 36.531, 2.499, -90 },
			{ -18.471, 36.531, 9.999, -90 },
			{ -18.471, 36.531, 17.499, -90 },
		}

		local v5 = Random.new(os.clock() * 1000000)

		local tbl3 = {
			"Part",
			"Mesh",
			"MeshPart",
			"Union",
			"Wedge",
			"Cylinder",
			"Model",
			"Frame",
			"Handle",
			"Body",
			"Root",
		}

		local function fn5()
			return tbl3[v5:NextInteger(1, #tbl3)]
		end

		local tbl4 = {}
		local tbl5 = {}
		local tbl6 = {}
		local tbl7 = {}
		local tbl8 = {}
		local tbl9 = {}
		local v6 = nil
		local flag3 = true
		local flag4 = false

		local function fn6(arg)
			tbl4[#tbl4 + 1] = arg
			arg.Parent = hui
			return arg
		end

		local function fn7()
			for _, v7 in ipairs(tbl4) do
				pcall(function()
					v7:Destroy()
				end)
			end

			table.clear(tbl4)
			table.clear(tbl5)

			for _, v7 in ipairs(tbl7) do
				pcall(function()
					v7:Destroy()
				end)
			end

			table.clear(tbl7)

			for _, v7 in ipairs(tbl8) do
				pcall(function()
					v7:Destroy()
				end)
			end

			table.clear(tbl8)
			table.clear(tbl9)
			v6 = nil
		end

		local function createBoxHandleAdornment(adornee, cFrame, size, color3, transparency, arg)
			local boxHandleAdornment = Instance.new("BoxHandleAdornment")
			boxHandleAdornment.Adornee = adornee
			boxHandleAdornment.Size = size
			boxHandleAdornment.CFrame = cFrame
			boxHandleAdornment.Color3 = color3
			boxHandleAdornment.Transparency = transparency
			boxHandleAdornment.AlwaysOnTop = true
			boxHandleAdornment.ZIndex = 0
			fn6(boxHandleAdornment)

			if arg then
				tbl5[#tbl5 + 1] = { a = boxHandleAdornment, base = transparency }
			end

			return boxHandleAdornment
		end

		local function fn8(arg, arg2, arg3, arg4)
			local n4 = n * 1.6
			local n5 = arg3.X * 0.5
			local n6 = arg3.Z * 0.5
			local n7 = arg3.Y * 0.5
			createBoxHandleAdornment(arg, arg2 * CFrame.new(0, n7, n6), Vector3.new(arg3.X, n4, n4), arg4, 0)
			createBoxHandleAdornment(arg, arg2 * CFrame.new(0, n7, -n6), Vector3.new(arg3.X, n4, n4), arg4, 0)
			createBoxHandleAdornment(arg, arg2 * CFrame.new(n5, n7, 0), Vector3.new(n4, n4, arg3.Z), arg4, 0)
			createBoxHandleAdornment(arg, arg2 * CFrame.new(-n5, n7, 0), Vector3.new(n4, n4, arg3.Z), arg4, 0)
		end

		local function createPart(cFrame, arg)
			local v7 = fn4()
			if not v7 then
				return nil
			end
			local part = Instance.new("Part")
			part.Name = fn5()
			part.Anchored = true
			part.CanCollide = arg and true or false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			part.Massless = true
			part.Transparency = 1
			part.Size = arg and Vector3.new(6, 0.25, 6) or Vector3.new(0.1, 0.1, 0.1)
			part.CFrame = cFrame
			part.Parent = v7

			if arg then
				tbl7[#tbl7 + 1] = part
			else
				tbl8[#tbl8 + 1] = part
			end

			return part
		end

		local function fn9(arg, adornee, arg2, color3)
			if not flag then
				return
			end
			local billboardGui = Instance.new("BillboardGui")
			billboardGui.Adornee = adornee
			billboardGui.Size = UDim2.new(2.2, 20, 1.35, 12)
			billboardGui.StudsOffset = Vector3.new(0, 3.2, 0)
			billboardGui.AlwaysOnTop = true
			billboardGui.LightInfluence = 0
			billboardGui.MaxDistance = 400
			billboardGui.Enabled = false
			local frame = Instance.new("Frame", billboardGui)
			frame.Size = UDim2.fromScale(1, 1)
			frame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
			frame.BackgroundTransparency = 0.55
			frame.BorderSizePixel = 0
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0.3, 0)
			local uiStroke = Instance.new("UIStroke", frame)
			uiStroke.Color = color3
			uiStroke.Thickness = 4
			uiStroke.Transparency = 0.7
			uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			local textLabel = Instance.new("TextLabel", frame)
			textLabel.Size = UDim2.fromScale(1, 1)
			textLabel.BackgroundTransparency = 1
			textLabel.Text = tostring(arg2)
			textLabel.Font = Enum.Font.GothamBlack
			textLabel.TextScaled = true
			textLabel.TextColor3 = color2
			local uiPadding = Instance.new("UIPadding", textLabel)
			uiPadding.PaddingLeft = UDim.new(0.1, 0)
			uiPadding.PaddingRight = UDim.new(0.1, 0)
			uiPadding.PaddingTop = UDim.new(0.08, 0)
			uiPadding.PaddingBottom = UDim.new(0.08, 0)
			local uiTextSizeConstraint = Instance.new("UITextSizeConstraint", textLabel)
			uiTextSizeConstraint.MaxTextSize = 500
			uiTextSizeConstraint.MinTextSize = 6
			local uiStroke2 = Instance.new("UIStroke", textLabel)
			uiStroke2.Color = color3
			uiStroke2.Thickness = 2
			uiStroke2.LineJoinMode = Enum.LineJoinMode.Round
			fn6(billboardGui)
			tbl9[arg] = tbl9[arg] or {}
			table.insert(tbl9[arg], billboardGui)
		end

		local function fn10()
			if not flag3 then
				return
			end
			fn7()

			for _, child in ipairs(plots:GetChildren()) do
				local mainRoot = child:FindFirstChild("MainRoot")

				if mainRoot then
					for i = 1, #tbl2 do
						local v7 = tbl2[i]
						local cframe = CFrame.Angles
						local n4 = mainRoot.CFrame * CFrame.new(v7[1], v7[2], v7[3]) * cframe(0, math.rad(v7[4]), 0)
						local v8 = createPart(n4, false)

						if v8 then
							createBoxHandleAdornment(v8, CFrame.new(), Vector3.new(6, 0.25, 6), color, 0.55, true)
							createBoxHandleAdornment(v8, CFrame.new(0, 0.25, 0), Vector3.new(4, 0.25, 4), color, 0.42, true)
							fn8(v8, CFrame.new(), Vector3.new(6, 0.25, 6), color)

							if flag2 then
								createPart(n4, true)
							end

							fn9(child, v8, i, color)
						end
					end
				end
			end
		end

		local function fn11()
			local character = localPlayer2.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then
				return nil
			end
			local position = humanoidRootPart.Position
			local huge = math.huge
			local v7 = nil

			for _, child in ipairs(plots:GetChildren()) do
				local mainRoot = child:FindFirstChild("MainRoot")

				if mainRoot then
					local magnitude = (mainRoot.Position - position).Magnitude

					if magnitude < huge then
						huge = magnitude
						v7 = child
					end
				end
			end

			if huge > 100 then
				return nil
			end
			return v7
		end

		local function fn12()
			local v7 = fn11()
			if v7 == v6 then
				return
			end
			v6 = v7

			for k, v8 in pairs(tbl9) do
				local enabled = k == v6

				for _, v9 in ipairs(v8) do
					if v9 and v9.Parent then
						v9.Enabled = enabled
					end
				end
			end
		end

		local function fn13()
			local v7 = flag4
			local flag5

			if flag4 then
				flag5 = v7
			else
				flag5 = not flag3
			end

			if flag5 then
				return
			end
			flag4 = true

			task.delay(0.4, function()
				flag4 = false
				if not flag3 then
					return
				end
				pcall(fn10)
				pcall(fn12)
			end)
		end

		fn10()
		fn12()

		local function fn14(arg)
			if not arg:FindFirstChild("MainRoot") then
				if arg:WaitForChild("MainRoot", 30) and flag3 then
					fn13()
				end
			end
		end

		for _, child in ipairs(plots:GetChildren()) do
			task.spawn(fn14, child)
		end

		table.insert(tbl6, plots.ChildAdded:Connect(function(child)
			task.spawn(fn14, child)
			fn13()
		end))

		table.insert(tbl6, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			if flag3 then
				fn13()
			end
		end))

		local n4 = 0
		local n5 = 0

		table.insert(tbl6, RunService.Heartbeat:Connect(function(deltaTime)
			local n6 = n5 + deltaTime
			n4 += deltaTime
			n5 = n6

			if n4 >= 0.05 then
				n4 = 0
				local n7 = math.sin(os.clock() * n2) * n3

				for _, v7 in ipairs(tbl5) do
					if v7.a.Parent then
						v7.a.Transparency = math.clamp(v7.base + n7, 0, 1)
					end
				end
			end

			if n5 >= 0.5 then
				n5 = 0
				fn12()
			end
		end))

		_G.__PodiumESPCleanup = function()
			flag3 = false

			for _, v7 in ipairs(tbl6) do
				pcall(function()
					v7:Disconnect()
				end)
			end

			table.clear(tbl6)
			fn7()
			_G.__PodiumESPCleanup = nil
		end
	end

	local function setPodiumESP(arg)
		local podiumESP = arg and true or false
		v3.podiumESP = podiumESP
		v4()
		fn2("PodiumESP", podiumESP)
		fn2("Podium ESP", podiumESP)

		if podiumESP then
			task.spawn(function()
				pcall(fn3)
			end)
		elseif _G.__PodiumESPCleanup then
			pcall(_G.__PodiumESPCleanup)
		end
	end

	_G.setPodiumESP = setPodiumESP

	_G.StickyOnBoot(function()
		if v3.podiumESP then
			pcall(setPodiumESP, true)
		end
	end)
end

local Players
Players = game:GetService("Players")
local RunService
RunService = game:GetService("RunService")
local ReplicatedStorage
ReplicatedStorage = game:GetService("ReplicatedStorage")
local v5

do
	local Workspace = game:GetService("Workspace")
	v5 = localPlayer2

	local function fn3(arg, ...)
		local v6 = table.pack(...)

		for i = 1, select("#", ...), 2 do
			arg[select(i, table.unpack(v6, 1, v6.n))] = select(i + 1, table.unpack(v6, 1, v6.n))
		end

		return arg
	end

	local tbl2 = {
		new = function(arg, parent, ...)
			local instance = Instance.new(arg)
			fn3(instance, ...)

			if parent then
				instance.Parent = parent
			end

			return instance
		end,
		corner = function(arg, arg2)
			Instance.new("UICorner", arg).CornerRadius = UDim.new(0, arg2 or 4)
			return arg
		end,
		stroke = function(arg, color, thickness, transparency)
			local uiStroke = Instance.new("UIStroke", arg)
			uiStroke.Color = color
			uiStroke.Thickness = thickness or 1
			uiStroke.Transparency = transparency or 0
			return uiStroke
		end,
	}

	local tbl3 = {}
	local flag = false
	local find = string.find
	local tbl4 = { "trap", "mine", "hive" }

	local tbl5 = {
		turret = { color = Color3.fromRGB(255, 40, 40), text = "TURRET" },
		trap = { color = Color3.fromRGB(255, 150, 20), text = "TRAP" },
		mine = { color = Color3.fromRGB(167, 142, 255), text = "SUBSPACE MINE" },
	}

	local function fn4(arg)
		local str = arg:lower()
		if find(str, "sentrybullet", 1, true) then
			return nil
		end

		if find(str, "tripmine", 1, true) then
			return "mine"
		end

		if find(str, "sentry", 1, true) then
			return "turret"
		end

		for _, v6 in ipairs(tbl4) do
			if find(str, v6, 1, true) then
				return "trap"
			end
		end

		return nil
	end

	local function fn5(parent, arg)
		local v6 = tbl5[arg]
		local str = "! " .. v6.text .. " !"

		if arg == "mine" then
			local match = parent.Name:match("SubspaceTripmine(.+)")

			if match then
				local v7 = Players:FindFirstChild(match)
				str = "! " .. (v7 and v7.DisplayName or match) .. "'s MINE !"
			end
		end

		local highlight

		if parent:IsA("Model") then
			highlight = Instance.new("Highlight")
			fn3(highlight, "Name", "Sticky_HazardESP_HL", "Adornee", parent, "FillColor", v6.color, "FillTransparency", 0.25, "OutlineColor", Color3.fromRGB(255, 255, 255), "OutlineTransparency", 0)
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Parent = parent
		else
			highlight = Instance.new("SelectionBox")
			fn3(highlight, "Name", "Sticky_HazardESP_HL", "Adornee", parent, "Color3", v6.color, "LineThickness", 0.12, "SurfaceColor3", v6.color, "SurfaceTransparency", 0.6, "Parent", parent)
		end

		local isBasePart = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart", true) or parent
		local billboardGui = Instance.new("BillboardGui")
		fn3(billboardGui, "Name", "Sticky_HazardESP_Label", "Adornee", isBasePart, "Size", UDim2.new(0, 200, 0, 44), "StudsOffset", Vector3.new(0, 6, 0), "AlwaysOnTop", true, "Parent", parent)
		local color = v6.color
		local gothamBold = Enum.Font.GothamBold
		tbl2.new("TextLabel", billboardGui, "Size", UDim2.new(1, 0, 1, 0), "BackgroundTransparency", 1, "Text", str, "TextColor3", color, "TextStrokeColor3", Color3.fromRGB(0, 0, 0), "TextStrokeTransparency", 0, "Font", gothamBold, "TextScaled", true)
		return { hl = highlight, bb = billboardGui, kind = arg }
	end

	local function fn6(arg, arg2)
		if arg2.hl and arg2.hl.Parent then
			pcall(function()
				arg2.hl:Destroy()
			end)
		end

		if arg2.bb and arg2.bb.Parent then
			pcall(function()
				arg2.bb:Destroy()
			end)
		end

		tbl3[arg] = nil
	end

	local function fn7()
		local tbl6 = { turret = v3.TurretESP == true, trap = v3.TrapESP == true, mine = v3.TrapESP == true }
		local tbl7 = {}

		if tbl6.turret or tbl6.trap or tbl6.mine then
			local descendants = workspace:GetDescendants()

			for i = 1, #descendants do
				local v6 = descendants[i]

				if v6.ClassName == "Model" or v6:IsA("BasePart") then
					local v7 = fn4(v6.Name)

					if v7 and tbl6[v7] then
						local flag2 = false
						local parent

						if v6:FindFirstChildWhichIsA("Humanoid", true) then
							flag2 = true
							parent = v6
						else
							parent = v6
						end

						while true do
							if not flag2 and parent and parent ~= workspace then
								if Players:GetPlayerFromCharacter(parent) or parent.ClassName == "Model" and parent:FindFirstChildOfClass("Humanoid") then
									flag2 = true
									break
								elseif parent ~= v6 and fn4(parent.Name) then
									flag2 = true
									break
								else
									parent = parent.Parent
									continue
								end
							end

							break
						end

						if not flag2 then
							tbl7[v6] = true
							local v8 = tbl3[v6]
							local v9

							if v8 and v8.kind ~= v7 then
								fn6(v6, v8)
								v9 = nil
							else
								v9 = v8
							end

							if not v9 then
								local ok, result = pcall(fn5, v6, v7)

								if ok then
									tbl3[v6] = result
								end
							end
						end
					end
				end
			end
		end

		for k, v6 in pairs(tbl3) do
			if not tbl7[k] or not k.Parent then
				fn6(k, v6)
			end
		end
	end

	local function fn8()
		if flag then
			return
		end
		flag = true

		task.spawn(function()
			while true do
				task.wait(tonumber(_G.StickyHazardESPEvery) or 1.5)
				if v3.TurretESP == true or v3.TrapESP == true then
					pcall(fn7)
					continue
				end

				if next(tbl3) == nil then
					continue
				end
				pcall(fn7)
			end
		end)
	end

	local function setTurretESP(arg)
		local turretESP = arg and true or false
		v3.TurretESP = turretESP
		v4()
		fn2("TurretESP", turretESP)
		fn2("Turret ESP", turretESP)

		if turretESP then
			fn8()
		end

		task.spawn(function()
			pcall(fn7)
		end)
	end

	local function setTrapESP(arg)
		local trapESP = arg and true or false
		v3.TrapESP = trapESP
		v4()
		fn2("TrapESP", trapESP)
		fn2("Trap ESP", trapESP)

		if trapESP then
			fn8()
		end

		task.spawn(function()
			pcall(fn7)
		end)
	end

	_G.setTurretESP = setTurretESP
	_G.setTrapESP = setTrapESP

	_G.StickyOnBoot(function()
		if v3.TurretESP == true or v3.TrapESP == true then
			fn8()
		end
	end)

	local tbl6 = {}
	local flag2 = false
	local color = Color3.fromRGB(0, 0, 0)
	local color2 = Color3.fromRGB(255, 255, 255)
	local tbl7 = {}
	local color3 = Color3.fromRGB(255, 215, 0)
	local color4 = Color3.fromRGB(0, 200, 255)
	local color5 = Color3.fromRGB
	tbl7[1] = color3
	tbl7[2] = color4

	do
		local values = table.pack(color5(170, 90, 255))
		table.move(values, 1, values.n, 3, tbl7)
	end

	local color6 = Color3.fromRGB(175, 175, 175)

	local function fn9(arg, arg2)
		local BillboardGui = tbl2.new("BillboardGui", nil, "Name", "BrainrotESP_" .. tostring(arg.uid), "Size", UDim2.new(0, 160, 0, 38), "StudsOffset", Vector3.new(0, 1.8, 0), "AlwaysOnTop", true, "LightInfluence", 0, "MaxDistance", 3000)
		local flag3 = arg.mutation and arg.mutation ~= "None" and arg.mutation ~= "N/A"
		local v6 = arg2 or color2
		local Frame = tbl2.new("Frame", BillboardGui, "Name", "Box", "Size", UDim2.new(1, 0, 1, 0), "BackgroundColor3", color, "BackgroundTransparency", 0.5, "BorderSizePixel", 0)
		tbl2.corner(Frame, 4)
		tbl2.stroke(Frame, v6, 1.5, 0.2)
		tbl2.new("TextLabel", Frame, "Name", "Nm", "Size", UDim2.new(1, -6, 0, 18), "Position", UDim2.new(0, 3, 0, 2), "BackgroundTransparency", 1, "Font", Enum.Font.GothamBlack, "TextSize", 13, "TextColor3", v6, "TextStrokeTransparency", 0, "TextStrokeColor3", color, "Text", arg.name or arg.petName or "???", "TextXAlignment", Enum.TextXAlignment.Center)
		tbl2.new("TextLabel", Frame, "Size", UDim2.new(1, -6, 0, 14), "Position", UDim2.new(0, 3, 0, 20), "BackgroundTransparency", 1, "Font", Enum.Font.GothamBold, "TextSize", 11, "TextColor3", color2, "TextStrokeTransparency", 0, "TextStrokeColor3", color, "Text", arg.genText or "", "TextXAlignment", Enum.TextXAlignment.Center)

		if flag3 then
			tbl2.corner(tbl2.new("TextLabel", BillboardGui, "Name", "Badge", "Size", UDim2.new(0, 60, 0, 14), "Position", UDim2.new(0.5, -30, 0, -16), "BackgroundColor3", v6, "BackgroundTransparency", 0.3, "Font", Enum.Font.GothamBlack, "TextSize", 9, "TextColor3", color2, "TextStrokeTransparency", 0, "TextStrokeColor3", color, "Text", tostring(arg.mutation):upper()), 3)
		end

		return BillboardGui
	end

	local function fn10(arg)
		local bb = arg.bb
		if not bb then
			return
		end
		local box = bb:FindFirstChild("Box")

		if box then
			arg.st = box:FindFirstChildOfClass("UIStroke")
			arg.nm = box:FindFirstChild("Nm")
		end

		arg.badge = bb:FindFirstChild("Badge")
	end

	local function fn11(arg, color7)
		if arg.color == color7 then
			return
		end
		arg.color = color7

		if arg.st then
			arg.st.Color = color7
		end

		if arg.nm then
			arg.nm.TextColor3 = color7
		end

		if arg.badge then
			arg.badge.BackgroundColor3 = color7
		end
	end

	local function fn12()
		for k, v6 in pairs(tbl6) do
			if v6.bb then
				pcall(function()
					v6.bb:Destroy()
				end)
			end

			tbl6[k] = nil
		end
	end

	local function fn13()
		if v3.BrainrotESP ~= true then
			return
		end
		local allAnimalsCache = tbl.AllAnimalsCache
		if not allAnimalsCache or #allAnimalsCache == 0 then
			return
		end
		local n = tonumber(v3.BrainrotESPMinGen) or 10000000
		local tbl8 = {}
		local v6, v7, v8 = ipairs(allAnimalsCache)
		local n2 = 0

		for _, v9 in v6, v7, v8 do
			if v9 and v9.uid and v9.genValue and not v9.isWalking and v9.genValue >= n then
				n2 += 1
				tbl8[v9.uid] = n2
				if not (n2 >= 3) then
					continue
				end
			else
				continue
			end

			break
		end

		local character = v5.Character
		character = character and character:FindFirstChild("HumanoidRootPart")
		character = character and character.Position
		local tbl9 = {}
		local stickyFindAdornee = _G.StickyFindAdornee

		for _, v9 in ipairs(allAnimalsCache) do
			if v9.genValue ~= nil and not v9.isWalking and v9.genValue >= n then
				tbl9[v9.uid] = true
				local v10 = tbl7[tbl8[v9.uid]] or color6
				local v11 = tbl6[v9.uid]

				if v11 then
					if v11.bb then
						fn11(v11, v10)
					end
				else
					local v12 = stickyFindAdornee and stickyFindAdornee(v9)

					if v12 and v12:IsA("BasePart") and (not character or (v12.Position - character).Magnitude <= 3000) then
						local tbl10 = {
							bb = fn3(fn9(v9, v10), "Adornee", v12, "StudsOffset", Vector3.new(0, 1.8, 0), "Parent", v12),
							color = v10,
						}

						fn10(tbl10)
						tbl6[v9.uid] = tbl10
					end
				end
			end
		end

		for k, v9 in pairs(tbl6) do
			if not tbl9[k] then
				if v9.bb then
					pcall(function()
						v9.bb:Destroy()
					end)
				end

				tbl6[k] = nil
			end
		end
	end

	local function fn14()
		if flag2 then
			return
		end
		flag2 = true

		task.spawn(function()
			while true do
				task.wait(0.3)

				if v3.BrainrotESP == true then
					local allAnimalsCache = tbl.AllAnimalsCache

					if allAnimalsCache and #allAnimalsCache > 0 then
						pcall(fn13)
					end
				end
			end
		end)
	end

	_G.setBrainrotESP = function(arg)
		local brainrotESP = arg and true or false
		v3.BrainrotESP = brainrotESP
		v4()
		fn2("BrainrotESP", brainrotESP)
		fn2("Brainrot ESP", brainrotESP)

		if brainrotESP then
			fn14()

			task.spawn(function()
				pcall(fn13)
			end)
		else
			pcall(fn12)
		end
	end

	_G.StickyOnBoot(function()
		if v3.BrainrotESP == true then
			fn14()
		end
	end)

	local tbl8 = { conns = {}, charConn = nil, beat = nil, acs = nil, acsChar = nil, rootAC = nil }
	local flag3 = false

	local function fn15(acsChar)
		if tbl8.acsChar ~= acsChar or not tbl8.acs then
			tbl8.acsChar = acsChar
			tbl8.acs = {}
			tbl8.rootAC = nil

			for _, descendant in ipairs(acsChar:GetDescendants()) do
				if descendant:IsA("AnimationConstraint") then
					table.insert(tbl8.acs, descendant)

					if descendant.Name == "Root" then
						tbl8.rootAC = descendant
					end
				end
			end
		end

		for _, v6 in ipairs(tbl8.acs) do
			if not v6.Enabled and v6.Parent then
				return true
			end
		end

		return false
	end

	local tbl9 = {
		BodyVelocity = true,
		BodyForce = true,
		BodyThrust = true,
		BodyGyro = true,
		BodyAngularVelocity = true,
		VectorForce = true,
		AngularVelocity = true,
		RocketPropulsion = true,
	}

	local tbl10 = {
		SpeedForce = true,
		InvisSpeedForce = true,
		JumpForce = true,
		FlightPower = true,
		FlightSpin = true,
		FlightHold = true,
	}

	local function fn16(arg)
		if _G.StickyCarpetFlightAware == false then
			return false
		end
		arg = arg and arg:FindFirstChild("HumanoidRootPart")
		if not arg then
			return false
		end
		return arg:FindFirstChild("FlightPower") ~= nil or arg:FindFirstChild("FlightSpin") ~= nil or arg:FindFirstChild("FlightHold") ~= nil
	end

	local function fn17(arg)
		if tbl10[arg.Name] then
			return false
		end
		local className = arg.ClassName
		local flag4 = tbl9[className]

		if not flag4 and className == "LinearVelocity" then
			flag4 = true
		end

		local flag5 = not flag4

		if flag5 then
			flag5 = className:find("Force") or className:find("Velocity") or className:find("Body") or className:find("Propulsion")
		end

		if flag5 then
			flag5 = arg.Name:find("Impulse") or arg.Name:find("Knockback") or arg.Name:find("Launch")
		end

		if flag5 then
			flag4 = true
		end

		if flag4 then
			pcall(function()
				arg:Destroy()
			end)

			return true
		end

		return false
	end

	local function fn18(arg)
		local humanoidRootPart = arg:FindFirstChild("HumanoidRootPart")
		local flag4 = false

		if humanoidRootPart then
			for _, child in ipairs(humanoidRootPart:GetChildren()) do
				flag4 = fn17(child) or flag4
			end
		end

		for _, child in ipairs(arg:GetChildren()) do
			flag4 = fn17(child) or flag4
		end

		return flag4
	end

	local flag4 = true

	local function fn19(arg)
		if flag4 == arg then
			return
		end
		flag4 = arg

		pcall(function()
			local playerScripts = v5:FindFirstChild("PlayerScripts")
			playerScripts = playerScripts and playerScripts:FindFirstChild("PlayerModule")

			if playerScripts then
				local controls = require(playerScripts):GetControls()

				if arg then
					controls:Enable()
				else
					controls:Disable()
				end
			end
		end)
	end

	local function stickyUnRagdoll(arg)
		local character = arg or v5.Character
		if not character then
			return
		end

		pcall(function()
			local attribute = v5:GetAttribute("RagdollEndTime")

			if attribute and attribute - Workspace:GetServerTimeNow() > 0 then
				_G.StickyRagdollUntil = attribute
			end

			v5:SetAttribute("RagdollEndTime", 0)
		end)

		local v6 = nil

		for _, descendant in ipairs(character:GetDescendants()) do
			if descendant:IsA("BallSocketConstraint") or descendant:IsA("HingeConstraint") or descendant:IsA("NoCollisionConstraint") then
				pcall(function()
					descendant:Destroy()
				end)
			elseif descendant:IsA("Motor6D") and not descendant.Enabled then
				pcall(function()
					descendant.Enabled = true
				end)
			elseif descendant:IsA("AnimationConstraint") then
				if not descendant.Enabled then
					pcall(function()
						descendant.Enabled = true
					end)
				end

				if v6 == nil and descendant.Name == "Root" then
					v6 = descendant
				end
			end
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local rootRigAttachment = humanoidRootPart and humanoidRootPart:FindFirstChild("RootRigAttachment")

		if rootRigAttachment and v6 then
			if v6.Attachment0 == nil or v6.Attachment0.Parent == nil then
				pcall(function()
					v6.Attachment0 = rootRigAttachment
				end)
			end
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			pcall(function()
				if humanoid.PlatformStand then
					humanoid.PlatformStand = false
				end
			end)

			local state = humanoid:GetState()

			if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.PlatformStanding then
				pcall(function()
					humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				end)
			end

			pcall(function()
				Workspace.CurrentCamera.CameraSubject = humanoid
			end)
		end

		fn19(true)
	end

	_G.StickyUnRagdoll = stickyUnRagdoll

	local function fn20()
		if typeof(getconnections) ~= "function" then
			return
		end

		pcall(function()
			local packages = ReplicatedStorage:FindFirstChild("Packages")
			local net = packages and packages:FindFirstChild("Net")
			local reRagdoll = nil

			if net then
				reRagdoll = net:FindFirstChild("RE/Ragdoll")
			end

			if not reRagdoll then
				reRagdoll = packages and packages:FindFirstChild("Ragdoll")
				reRagdoll = reRagdoll and reRagdoll:FindFirstChild("Ragdoll")
			end

			if reRagdoll and reRagdoll:IsA("RemoteEvent") then
				for _, v6 in ipairs(getconnections(reRagdoll.OnClientEvent)) do
					if not pcall(function()
						v6:Disable()
					end) then
						pcall(function()
							v6:Disconnect()
						end)
					end
				end
			end
		end)
	end

	local function fn21()
		for _, conn in ipairs(tbl8.conns) do
			pcall(function()
				conn:Disconnect()
			end)
		end

		tbl8.conns = {}
	end

	local function fn22(arg)
		if not flag3 or not arg then
			return
		end
		fn21()
		fn20()
		stickyUnRagdoll(arg)

		local connection = v5:GetAttributeChangedSignal("RagdollEndTime"):Connect(function()
			if not flag3 then
				return
			end
			local attribute = v5:GetAttribute("RagdollEndTime")

			if attribute and attribute - Workspace:GetServerTimeNow() > 0 then
				stickyUnRagdoll(v5.Character)
			end
		end)

		table.insert(tbl8.conns, connection)
		local humanoid = arg:FindFirstChildOfClass("Humanoid")

		if humanoid then
			local connection2 = humanoid.StateChanged:Connect(function(old, new)
				if not flag3 then
					return
				end

				if new == Enum.HumanoidStateType.Physics or new == Enum.HumanoidStateType.Ragdoll or new == Enum.HumanoidStateType.PlatformStanding then
					stickyUnRagdoll(v5.Character)
				end
			end)

			table.insert(tbl8.conns, connection2)
		end

		local flag5 = false

		local connection2 = arg.DescendantAdded:Connect(function(descendant)
			if not flag3 then
				return
			end

			if descendant:IsA("BallSocketConstraint") or descendant:IsA("HingeConstraint") or descendant:IsA("NoCollisionConstraint") then
				if flag5 then
					return
				end
				flag5 = true

				task.defer(function()
					flag5 = false
					stickyUnRagdoll(v5.Character)
				end)
			end
		end)

		table.insert(tbl8.conns, connection2)
	end

	local function fn23()
		flag3 = false
		fn21()

		if tbl8.charConn then
			pcall(function()
				tbl8.charConn:Disconnect()
			end)

			tbl8.charConn = nil
		end

		if tbl8.beat then
			pcall(function()
				tbl8.beat:Disconnect()
			end)

			tbl8.beat = nil
		end
	end

	local function fn24(arg)
		fn23()
		flag3 = arg and true or false
		if not flag3 then
			return
		end

		if v5.Character then
			task.spawn(function()
				fn22(v5.Character)
			end)
		end

		tbl8.charConn = v5.CharacterAdded:Connect(function(character)
			if not flag3 then
				return
			end

			pcall(function()
				character:WaitForChild("Humanoid", 10)
			end)

			fn22(character)

			task.spawn(function()
				for i = 1, 12 do
					task.wait(0.25)
					if flag3 then
						fn20()
						continue
					end
					break
				end
			end)
		end)

		local n = 0
		local vector = Vector3.zero

		tbl8.beat = RunService.Heartbeat:Connect(function()
			if not flag3 then
				return
			end
			local character = v5.Character
			if not character then
				return
			end
			local attribute = v5:GetAttribute("RagdollEndTime")
			local flag5 = attribute ~= nil and attribute - Workspace:GetServerTimeNow() > 0
			local v6 = fn16(character)

			if not flag5 and not v6 then
				local humanoid = character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					local state = humanoid:GetState()
					flag5 = state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.PlatformStanding or humanoid.PlatformStand == true
				end
			end

			flag5 = flag5 or fn15(character)

			if not _G.invisibleStealEnabled then
				local rootAC = tbl8.rootAC

				if rootAC and rootAC.Parent and (rootAC.Attachment0 == nil or rootAC.Attachment0.Parent == nil) then
					local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
					local rootRigAttachment = humanoidRootPart and humanoidRootPart:FindFirstChild("RootRigAttachment")

					if rootRigAttachment then
						pcall(function()
							rootAC.Attachment0 = rootRigAttachment
						end)
					end
				end
			end

			local flag6

			if not flag5 then
				local now = tick()
				local n2 = now - n

				if not ((tonumber(_G.StickyRagScanInterval) or 0.2) < n2) then
					flag6 = flag5
				else
					n = now
					flag6 = character:FindFirstChildWhichIsA("BallSocketConstraint", true) ~= nil or character:FindFirstChildWhichIsA("HingeConstraint", true) ~= nil
				end
			else
				flag6 = flag5
			end

			if flag6 then
				_G.StickyRagdollPhysLastT = tick()
			end

			local stickyTpActive = _G.StickyAntiLaunch ~= false and (flag6 or _G.StickyTpActive)
			local flag7 = false

			if stickyTpActive then
				flag7 = fn18(character)
			end

			if flag6 then
				stickyUnRagdoll(character)
			end

			if flag6 or flag7 then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					humanoidRootPart.AssemblyAngularVelocity = Vector3.zero

					if _G.StickyRagdollStayPut ~= false and not _G.StickyTpActive and not _G.StickyDropFlingActive then
						humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					end
				end
			end

			if v3.AntiRagdoll ~= false and not _G.StickyTpActive and not _G.StickyCarpetSpeedActive and not v6 and not _G.StickyCarpetBuyFlying and not _G.StickyDropFlingActive then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
					local magnitude = (assemblyLinearVelocity - vector).Magnitude

					if (tonumber(_G.StickyLaunchSpikeThreshold) or 110) < magnitude then
						humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
						humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
						assemblyLinearVelocity = Vector3.zero
					end

					vector = assemblyLinearVelocity
				end
			else
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				vector = humanoidRootPart and humanoidRootPart.AssemblyLinearVelocity or Vector3.zero
			end
		end)
	end

	_G.setAntiRagdoll = function(arg)
		local antiRagdoll = arg and true or false
		v3.AntiRagdoll = antiRagdoll
		v4()
		fn2("AntiRagdoll", antiRagdoll)
		fn2("Anti Ragdoll", antiRagdoll)
		fn24(antiRagdoll)
	end

	_G.StickyOnBoot(function()
		if v3.AntiRagdoll ~= false then
			pcall(fn24, true)
		end
	end)
end

do
	local Lighting = game:GetService("Lighting")
	local v6 = v5
	local v7 = ReplicatedStorage

	if _G.StickyAntiBee == nil then
		_G.StickyAntiBee = v3.AntiBeeDisco ~= false
	end

	local function fn3()
		local tbl2 = { Blue = true, DiscoEffect = true, BeeBlur = true, Flashbang = true, ColorCorrection = true }

		local function fn4()
			return _G.StickyAntiBee ~= false
		end

		local function fn5(descendant)
			if fn4() and descendant and descendant.Parent and tbl2[descendant.Name] then
				pcall(function()
					descendant:Destroy()
				end)
			end
		end

		local v8 = nil

		local function fn6()
			if not fn4() then
				return
			end

			pcall(function()
				if not (v8 and v8.Parent) then
					local controllers = v7:FindFirstChild("Controllers")
					local itemController = controllers and controllers:FindFirstChild("ItemController")
					itemController = itemController and itemController:FindFirstChild("BeeLauncherController")
					local buzzing = itemController and itemController:FindFirstChild("Buzzing")

					if buzzing and buzzing:IsA("Sound") then
						v8 = buzzing
					end
				end

				if v8 then
					v8.Volume = 0

					if v8.IsPlaying then
						v8:Stop()
					end
				end
			end)
		end

		local tbl3 = {}

		local function fn7(arg, arg2)
			if not arg or tbl3[arg] then
				return
			end
			local moveFunction = arg2 or arg.moveFunction
			if not moveFunction then
				return
			end

			local function moveFunction2(arg3, arg4, arg5)
				return moveFunction(arg3, arg4, arg5)
			end

			tbl3[arg] = moveFunction2
			arg.moveFunction = moveFunction2

			RunService.Heartbeat:Connect(function()
				if not fn4() then
					return
				end

				if arg.moveFunction ~= moveFunction2 then
					arg.moveFunction = moveFunction2
				end
			end)
		end

		local function fn8()
			pcall(function()
				local controllers = v7:FindFirstChild("Controllers")
				controllers = controllers and controllers:FindFirstChild("CharacterController")
				local module = controllers and require(controllers)

				if type(module) == "table" then
					fn7(module.Controls, module.originalMoveFunction)
				end
			end)

			pcall(function()
				local playerScripts = v6:WaitForChild("PlayerScripts", 5)
				playerScripts = playerScripts and playerScripts:FindFirstChild("PlayerModule")

				if playerScripts then
					fn7(require(playerScripts):GetControls())
				end
			end)
		end

		_G.StickyOnBoot(function()
			v6:WaitForChild("PlayerScripts", 8)
			Lighting.DescendantAdded:Connect(fn5)
			local n = 0

			for _, descendant in ipairs(Lighting:GetDescendants()) do
				n += 1

				if n % 150 == 0 then
					task.wait()
				end

				fn5(descendant)
			end

			fn8()
			local n2 = 1

			RunService.Heartbeat:Connect(function(deltaTime)
				if not fn4() then
					return
				end
				local currentCamera = workspace.CurrentCamera

				if currentCamera and math.abs(currentCamera.FieldOfView - 20) < 0.01 then
					currentCamera.FieldOfView = tonumber(_G.StickyFOV) or 70
				end

				n2 += deltaTime
				if n2 < 0.5 then
					return
				end
				n2 = 0
				fn6()
			end)
		end)

		v6.CharacterAdded:Connect(function()
			task.delay(1, fn8)
		end)
	end

	fn3()

	_G.setAntiBeeDisco = function(arg)
		local antiBeeDisco = arg and true or false
		v3.AntiBeeDisco = antiBeeDisco
		_G.StickyAntiBee = antiBeeDisco
		v4()
		fn2("AntiBeeDisco", antiBeeDisco)
		fn2("Anti Bee/Disco", antiBeeDisco)
	end

	if _G.StickyAntiDieDisabled == nil then
		_G.StickyAntiDieDisabled = v3.AntiDie == false
	end

	task.spawn(function()
		while not Players.LocalPlayer do
			task.wait()
		end

		pcall(function()
			local connection = nil
			local connection2 = nil
			local connection3 = nil

			local function fn4(arg)
				pcall(function()
					arg.BreakJointsOnDeath = false
				end)

				pcall(function()
					arg.RequiresNeck = false
				end)

				pcall(function()
					arg:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
				end)

				pcall(function()
					arg:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
				end)

				pcall(function()
					arg:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
				end)

				pcall(function()
					arg:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
				end)
			end

			local function fn5(arg)
				pcall(function()
					arg.Health = arg.MaxHealth
				end)

				pcall(function()
					arg:ChangeState(Enum.HumanoidStateType.Running)
				end)
			end

			local function fn6()
				local character = v6.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not humanoid then
					return
				end
				fn4(humanoid)

				if connection then
					pcall(function()
						connection:Disconnect()
					end)
				end

				if connection2 then
					pcall(function()
						connection2:Disconnect()
					end)
				end

				if connection3 then
					pcall(function()
						connection3:Disconnect()
					end)
				end

				connection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
					if _G.StickyAntiDieDisabled then
						return
					end

					if humanoid.Health <= 0 then
						fn5(humanoid)
					end
				end)

				connection2 = humanoid.Died:Connect(function()
					if _G.StickyAntiDieDisabled then
						return
					end
					fn5(humanoid)
				end)

				local n = 0

				connection3 = RunService.Heartbeat:Connect(function()
					if _G.StickyAntiDieDisabled or not humanoid or not humanoid.Parent then
						return
					end
					local now = os.clock()

					if now - n >= 0.5 then
						n = now
						fn4(humanoid)
					end

					if humanoid.Health <= 0 then
						fn5(humanoid)
					end

					if _G.StickyStealHold and humanoid.Health < humanoid.MaxHealth then
						pcall(function()
							humanoid.Health = humanoid.MaxHealth
						end)
					end

					local parent = humanoid.Parent
					local humanoidRootPart = parent and parent:FindFirstChild("HumanoidRootPart")

					if parent and humanoidRootPart then
						local state = humanoid:GetState()
						local flag = state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown

						if not flag then
							local num = tonumber(v6:GetAttribute("RagdollEndTime"))

							if num and num - workspace:GetServerTimeNow() > 0 then
								flag = true
							end
						end

						if flag then
							pcall(function()
								v6:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow())
							end)

							pcall(function()
								humanoid:ChangeState(Enum.HumanoidStateType.Running)
							end)

							if not _G.__stickyResetBusy and v6:GetAttribute("Stealing") ~= true then
								pcall(function()
									humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
								end)
							end

							local currentCamera = workspace.CurrentCamera

							if currentCamera and currentCamera.CameraSubject ~= humanoid then
								pcall(function()
									currentCamera.CameraSubject = humanoid
								end)
							end

							for _, descendant in ipairs(parent:GetDescendants()) do
								if descendant:IsA("BallSocketConstraint") or descendant.Name and descendant.Name:find("RagdollAttachment") then
									pcall(function()
										descendant:Destroy()
									end)
								end
							end
						end
					end

					local dead = Enum.HumanoidStateType.Dead

					if humanoid:GetState() == dead then
						pcall(function()
							humanoid:ChangeState(Enum.HumanoidStateType.Running)
						end)
					end
				end)
			end

			fn6()

			v6.CharacterAdded:Connect(function(character)
				local humanoid = character:WaitForChild("Humanoid", 5)

				if humanoid then
					fn4(humanoid)
				end

				task.wait(0.1)
				fn6()
			end)
		end)
	end)

	_G.setAntiDie = function(arg)
		local antiDie = arg and true or false
		v3.AntiDie = antiDie
		_G.StickyAntiDieDisabled = not antiDie
		v4()
		fn2("AntiDie", antiDie)
		fn2("Anti Die", antiDie)
	end

	local tbl2 = { "Flying Carpet", "Waverider", "Santa's Sleigh", "Witch's Broom", "Cupid's Wings" }
	local v8 = nil

	local function fn4(arg)
		local character = v6.Character
		local backpack = v6:FindFirstChild("Backpack")
		return character and character:FindFirstChild(arg) or backpack and backpack:FindFirstChild(arg)
	end

	_G.StickyEquipCarpet = function()
		local character = v6.Character
		if not character then
			return nil
		end

		if v8 then
			local v9 = character:FindFirstChild(v8)
			if v9 and v9.Parent == character then
				return v8
			end
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return nil
		end

		for _, v9 in ipairs(tbl2) do
			local v10 = fn4(v9)

			if v10 and v10:IsA("Tool") then
				if v10.Parent ~= character then
					pcall(function()
						humanoid:EquipTool(v10)
					end)
				end

				v8 = v9
				return v9
			end
		end

		return nil
	end

	_G.StickyCarpetEngaging = function()
		local character = v6.Character
		if not character then
			return false
		end

		for _, v9 in ipairs(tbl2) do
			local v10 = character:FindFirstChild(v9)
			if v10 and v10:IsA("Tool") then
				return true
			end
		end

		return false
	end

	local tbl3 = {}
	local flag = false

	local function stickyStopWalkFling()
		flag = false

		for _, v9 in ipairs(tbl3) do
			if typeof(v9) == "RBXScriptConnection" then
				pcall(function()
					v9:Disconnect()
				end)
			end
		end

		tbl3 = {}
	end

	local function fn5()
		flag = true
		local character = v6.Character
		if not character then
			return
		end
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			for _, child in pairs(currentCamera:GetChildren()) do
				if child.Name == "HumanoidRootPart" then
					humanoidRootPart = child
					break
				end
			end
		end

		if not humanoidRootPart then
			return
		end

		table.insert(tbl3, RunService.Stepped:Connect(function()
			if not flag then
				return
			end

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= v6 and player.Character then
					for _, child in ipairs(player.Character:GetChildren()) do
						if child:IsA("BasePart") then
							child.CanCollide = false
						end
					end
				end
			end
		end))

		task.spawn(function()
			if _G.invisibleStealEnabled then
				humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 3, 0)
			end

			while flag do
				RunService.Heartbeat:Wait()

				if not (not humanoidRootPart or not humanoidRootPart.Parent) then
					local velocity = humanoidRootPart.Velocity
					humanoidRootPart.Velocity = velocity * 10000 + Vector3.new(0, 10000, 0)
					RunService.RenderStepped:Wait()

					if humanoidRootPart and humanoidRootPart.Parent then
						humanoidRootPart.Velocity = velocity
					end

					RunService.Stepped:Wait()

					if humanoidRootPart and humanoidRootPart.Parent then
						humanoidRootPart.Velocity = velocity + Vector3.new(0, 0.1, 0)
					end

					continue
				end

				break
			end
		end)
	end

	_G.StickyDropBrainrot = function()
		if flag then
			return
		end
		fn5()
		task.delay(0.4, stickyStopWalkFling)
	end

	_G.StickyStopWalkFling = stickyStopWalkFling
	local v9 = nil
	local v10 = nil
	local flag2 = false
	local flag3 = false

	local function fn6()
		if v9 or flag3 then
			return
		end

		if not hookfunction or _G.StickyResetCapture == false then
			return
		end
		flag3 = true

		pcall(function()
			local fn7 = newcclosure or function(arg)
				return arg
			end

			local now = os.clock()
			local flag4 = false

			local function fn8(stickyResetCaptureWhy)
				if flag4 then
					return
				end
				flag4 = true

				pcall(function()
					hookfunction(Instance.new("RemoteEvent").FireServer, v10)
				end)

				_G.StickyResetCaptureMs = (os.clock() - now) * 1000
				_G.StickyResetCaptureWhy = stickyResetCaptureWhy
				flag3 = false
			end

			local str = tostring(_G.StickyResetCaller or "ToolActivationController")
			local v11 = getcallingscript
			if not v11 then
				fn8("no-getcallingscript")
				return
			end
			local tbl4 = {}

			local function fn9(stickyResetRemote)
				local name = stickyResetRemote.Name
				if name:sub(1, 3) ~= "RE/" then
					return
				end

				if not name:match("^RE/%x%x%x%x%x%x%x%x") then
					return
				end
				local v12 = v11()
				if not v12 or v12.Name ~= str then
					return
				end
				local n = (tbl4[stickyResetRemote] or 0) + 1
				tbl4[stickyResetRemote] = n

				if (tonumber(_G.StickyResetMinFires) or 2) <= n then
					v9 = stickyResetRemote
					_G.StickyResetRemote = stickyResetRemote
					_G.StickyResetRemoteName = name
					task.defer(fn8, "captured")
				end
			end

			v10 = hookfunction(Instance.new("RemoteEvent").FireServer, fn7(function(arg, ...)
				local v12 = table.pack(...)

				if not v9 then
					local v13 = ...

					if type(v13) == "string" then
						pcall(fn9, arg)
					end

					return v10(arg, table.unpack(v12, 1, v12.n))
				end

				return v10(arg, ...)
			end))

			task.delay(tonumber(_G.StickyResetCaptureMax) or 8, function()
				fn8("timeout")
			end)
		end)
	end

	_G.StickyResetArm = function()
		fn6()
	end

	task.spawn(function()
		local function fn7(character)
			if not character then
				return
			end

			for _, child in ipairs(character:GetChildren()) do
				if child:IsA("Tool") and not v9 then
					fn6()
					break
				end
			end

			character.ChildAdded:Connect(function(child)
				if not v9 and child:IsA("Tool") then
					fn6()
				end
			end)
		end

		if v6.Character then
			fn7(v6.Character)
		end

		v6.CharacterAdded:Connect(fn7)
	end)

	local function fn7()
		local flag4 = false

		pcall(function()
			local character = v6.Character
			if not character then
				return
			end

			for _, child in ipairs(character:GetChildren()) do
				if child:IsA("Tool") then
					flag4 = true
					break
				end
			end

			if not flag4 then
				return
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				pcall(function()
					humanoid:UnequipTools()
				end)
			end

			for _, child in ipairs(character:GetChildren()) do
				if child:IsA("Tool") then
					pcall(function()
						child.Parent = v6:FindFirstChild("Backpack")
					end)
				end
			end
		end)

		return flag4
	end

	_G.StickyInstantReset = function(arg)
		if _G.StickyResetJunkFire == true then
			if flag2 then
				return true
			end
			flag2 = true

			task.spawn(function()
				if _G.StickyResetStowTools ~= false then
					_G.StickyResetStowActive = true
					fn7()
					RunService.Heartbeat:Wait()
				end

				local stickyAntiDieDisabled = _G.StickyAntiDieDisabled
				_G.StickyAntiDieDisabled = true
				local flag4 = false

				local function fn8()
					if flag4 then
						return
					end
					flag4 = true
					_G.StickyAntiDieDisabled = stickyAntiDieDisabled
					_G.StickyResetStowActive = false
					flag2 = false
				end

				local connection = nil

				connection = v6.CharacterAdded:Connect(function()
					if connection then
						connection:Disconnect()
						connection = nil
					end

					fn8()
				end)

				task.delay(tonumber(_G.StickyResetRestoreMax) or 8, function()
					if connection then
						connection:Disconnect()
						connection = nil
					end

					fn8()
				end)

				pcall(function()
					local character = v6.Character
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")

					if humanoid then
						pcall(function()
							humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
						end)

						pcall(function()
							humanoid.BreakJointsOnDeath = true
						end)

						humanoid:ChangeState(Enum.HumanoidStateType.Dead)
					end
				end)
			end)

			return true
		end

		local v11 = v9
		local stickyResetRemote

		if v9 then
			stickyResetRemote = v11
		else
			stickyResetRemote = _G.StickyResetRemote
		end

		if not stickyResetRemote then
			fn6()
			local n = tonumber(_G.StickyResetArmWait) or 0

			if n > 0 then
				local now = os.clock()

				while not v9 and os.clock() - now < n do
					task.wait(0.1)
				end
			end

			local v12 = v9

			if v9 then
				stickyResetRemote = v12
			else
				stickyResetRemote = _G.StickyResetRemote
			end
		end

		if not stickyResetRemote then
			return false
		end

		if not stickyResetRemote.Parent then
			_G.StickyResetRemoteDead = true
			return false
		end
		_G.StickyResetRemoteDead = false
		if flag2 then
			return true
		end
		flag2 = true
		local flag4 = false

		if _G.StickyResetStowTools ~= false then
			_G.StickyResetStowActive = true
			flag4 = fn7()
		end

		local fn8 = _G.StickyResetUseRawFS == true and v10 or function(arg2, arg3)
			return arg2:FireServer(arg3)
		end

		local n = math.clamp(tonumber(arg) or tonumber(_G.StickyResetBurst) or 50, 1, 50)

		task.spawn(function()
			local stickyResetLastOk = false
			local connection = nil

			pcall(function()
				connection = v6.CharacterRemoving:Connect(function()
					stickyResetLastOk = true
				end)
			end)

			if _G.StickyResetStowTools ~= false then
				local n2 = math.clamp(tonumber(_G.StickyResetStowWait) or 0.1, 0, 1)
				local n3 = math.clamp(tonumber(_G.StickyResetStowCap) or 0.5, n2, 3)
				local now = os.clock()
				local n4 = flag4 and now or now - n2

				while true do
					if not stickyResetLastOk and os.clock() - now < n3 then
						if fn7() then
							n4 = os.clock()
						end

						if not (os.clock() - n4 >= n2) then
							RunService.Heartbeat:Wait()
							continue
						end
					end

					break
				end
			end

			local character = v6.Character
			local now = os.clock()
			local n2 = tonumber(_G.StickyResetMaxTime) or 3
			local stickyResetLastFires = 0

			for i = 1, n do
				if not (stickyResetLastOk or v6.Character ~= character) then
					if not (n2 <= os.clock() - now) then
						pcall(fn8, stickyResetRemote, "randomstring")
						stickyResetLastFires += 1
						RunService.Heartbeat:Wait()
						continue
					end
				end

				break
			end

			_G.StickyResetLastFires = stickyResetLastFires
			_G.StickyResetLastMs = (os.clock() - now) * 1000
			_G.StickyResetLastOk = stickyResetLastOk or v6.Character ~= character

			if connection then
				pcall(function()
					connection:Disconnect()
				end)
			end

			_G.StickyResetStowActive = false
			flag2 = false
		end)

		return true
	end

	local function fn8(arg)
		if not arg then
			return
		end
		local backpack = v6:FindFirstChild("Backpack")
		if not backpack then
			return
		end

		for _, child in ipairs(arg:GetChildren()) do
			if child:IsA("Tool") then
				pcall(function()
					child.Parent = backpack
				end)
			end
		end
	end

	_G.StickyExecuteReset = function()
		if _G.StickyInstantReset and _G.StickyInstantReset(50) then
			return
		end

		pcall(function()
			Players.RespawnTime = 0
		end)

		local stickyAntiDieDisabled = _G.StickyAntiDieDisabled
		_G.StickyAntiDieDisabled = true
		_G.__stickyResetBusy = true
		local connection = nil

		local function fn9()
			_G.StickyAntiDieDisabled = stickyAntiDieDisabled
			_G.__stickyResetBusy = false
		end

		connection = v6.CharacterAdded:Connect(function(character)
			if connection then
				connection:Disconnect()
				connection = nil
			end

			task.defer(function()
				pcall(function()
					character:WaitForChild("Humanoid", 12)
				end)

				RunService.Heartbeat:Wait()
				fn9()
			end)
		end)

		task.delay(10, function()
			if connection then
				connection:Disconnect()
				connection = nil
			end

			fn9()
		end)

		local character = v6.Character

		if not character then
			pcall(function()
				v6:LoadCharacter()
			end)

			return
		end

		pcall(function()
			local function fn10()
				local findFirstChild = character.FindFirstChild
				return character:FindFirstChildOfClass("Humanoid"), findFirstChild(character, "HumanoidRootPart")
			end

			local v11, v12 = fn10()
			if not (v12 and v11) then
				return
			end

			pcall(function()
				v11:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
				v11:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
				v11:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
				v11.BreakJointsOnDeath = true
			end)

			fn8(character)
			v12.CFrame = CFrame.new(0, 15000, 0)
			RunService.Heartbeat:Wait()
			fn8(character)
			RunService.Heartbeat:Wait()
			local v13
			v11, v13 = fn10()
			if not (v11 and v13) then
				return
			end

			pcall(function()
				v11.Health = 0
			end)

			pcall(function()
				v11:ChangeState(Enum.HumanoidStateType.Dead)
			end)

			if v11.Health > 0 then
				pcall(function()
					v11:TakeDamage(v11.MaxHealth * 99)
				end)
			end

			if v11.Health > 0 then
				pcall(function()
					character:BreakJoints()
				end)
			end

			local v14
			v11, v14 = fn10()

			if v11 and v14 and v11.Health > 0 then
				pcall(function()
					v14.AssemblyLinearVelocity = Vector3.zero
					v14.CFrame = CFrame.new(v14.Position.X, workspace.FallenPartsDestroyHeight - 500, v14.Position.Z)
				end)
			end
		end)

		task.spawn(function()
			local character2 = v6.Character

			for i = 1, 8 do
				pcall(function()
					v6:LoadCharacter()
				end)

				task.wait(0.05)
				if not (v6.Character and v6.Character ~= character2) then
					continue
				end
				break
			end
		end)
	end

	_G.StickyInstaReset = _G.StickyExecuteReset

	if _G.StickyResetCaptureAtLoad ~= false then
		_G.StickyOnBoot(function()
			fn6()
		end)
	end
end

do
	local flag = false

	local function fn3()
		local character = v5.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		return character ~= nil and humanoid ~= nil and humanoid.Health > 0
	end

	local function fn4()
		local character = v5.Character
		return character, character and character:FindFirstChild("HumanoidRootPart"), character and character:FindFirstChildOfClass("Humanoid")
	end

	local obj = setmetatable({}, { __mode = "k" })

	local function fn5(arg)
		local flag2 = _G.StickyTurretDeployStrict ~= false
		local tbl2 = {}
		local flag3 = false
		local static = nil

		for _, descendant in ipairs(arg:GetDescendants()) do
			if descendant:IsA("TextLabel") then
				local text = descendant.Text

				if text ~= "" then
					local flag4

					if text:lower():find("ready", 1, true) then
						flag4 = true

						if not flag3 then
							flag3 = true
							static = "ready-label"
						end
					elseif not flag2 then
						local pos = text:find("!", 1, true) or text:match("^%s*%d+%.?%d*%s*[sS]?%s*$")
						flag4 = false

						if pos then
							flag4 = true

							if not flag3 then
								flag3 = true
								static = "loose"
							end
						end
					else
						local match = text:match("^%s*(%d+%.?%d*)%s*[sS]?%s*!*%s*$")
						local flag5

						if match then
							flag5 = (tonumber(match) or 99) <= 10
						else
							flag5 = match
						end

						flag4 = false

						if flag5 then
							flag4 = true

							if not flag3 then
								static = "countdown=" .. match
								flag3 = true
							end
						end
					end

					if flag4 then
						tbl2[#tbl2 + 1] = text
					end
				end
			end
		end

		if not flag3 then
			obj[arg] = nil
			return false, nil
		end
		local str = table.concat(tbl2, "\1")
		local now = tick()
		local v6 = obj[arg]
		if not v6 or v6.key ~= str then
			obj[arg] = { key = str, at = now, why = static }
			return true, static
		end
		v6.why = static
		local flag4 = _G.StickyTurretStaticRelease ~= false

		if flag4 then
			flag4 = now - v6.at >= (tonumber(_G.StickyTurretStaticPin) or 1.2)
		end

		if flag4 then
			return false, "static:" .. static
		end
		return true, static
	end

	local obj2 = setmetatable({}, { __mode = "k" })
	local obj3 = setmetatable({}, { __mode = "k" })
	local obj4 = setmetatable({}, { __mode = "k" })
	local obj5 = setmetatable({}, { __mode = "k" })
	local tbl2 = { tp = 0, speed = 0, buykick = 0, steal = 0, join = 0, noweapon = 0 }

	local function fn6()
		local tbl3 = {}

		for _, v6 in ipairs({ "tp", "speed", "buykick", "steal", "join", "noweapon" }) do
			if tbl2[v6] > 0.05 then
				tbl3[#tbl3 + 1] = string.format("%s %.2fs", v6, tbl2[v6])
			end
		end

		return #tbl3 > 0 and table.concat(tbl3, ", ") or "none"
	end

	local function fn7(arg)
		if _G.StickyTurretSkipPlayers == false then
			return false
		end

		while arg and arg ~= workspace do
			if Players:GetPlayerFromCharacter(arg) or arg.ClassName == "Model" and arg:FindFirstChildOfClass("Humanoid") then
				return true
			end
			arg = arg.Parent
		end

		return false
	end

	local function fn8(arg)
		if fn7(arg) then
			return false
		end

		if _G.StickyTurretWaitReady == false then
			return true
		end

		if obj3[arg] then
			return true
		end
		local now = tick()
		local v6 = obj2[arg]

		if not v6 then
			obj2[arg] = now
			v6 = now
		end

		local tbl3 = obj4[arg]

		if not tbl3 then
			tbl3 = { seen = now }
			obj4[arg] = tbl3
		end

		local n = now - v6

		if (tonumber(_G.StickyTurretDeploySpan) or 12) <= n then
			obj3[arg] = true

			if tbl3.pinwhy and not tbl3.pinrel then
				tbl3.pinrel = "age-cap"
			end

			return true
		end

		local v7, v8 = fn5(arg)

		if v8 and v7 then
			tbl3.pinwhy = v8
		end

		if v7 then
			return false
		end

		if tbl3.pinwhy and not tbl3.pinrel then
			tbl3.pinrel = v8 and "static" or "deploy-done"
		end

		if _G.StickyTurretArmLatch ~= false then
			obj3[arg] = true
		end

		return true
	end

	local function fn9(arg)
		for _, descendant in ipairs(arg:GetDescendants()) do
			if descendant:IsA("BasePart") and descendant ~= arg then
				descendant.Transparency = 0.5
				descendant.CanCollide = false
				descendant.CanTouch = false
				descendant.CanQuery = false
			elseif descendant:IsA("BillboardGui") and descendant.Name == "SentryLabel" then
				pcall(function()
					descendant:Destroy()
				end)
			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				descendant.Transparency = 0.5
			end
		end

		if arg:IsA("BasePart") and arg.Name == "ProxyVisual" then
			arg.Transparency = 1
			arg.CanCollide = false
		end
	end

	local function fn10()
		local character = v5.Character
		if not character then
			return nil
		end
		local backpack = v5:FindFirstChild("Backpack")
		return backpack and backpack:FindFirstChild("Bat") or character:FindFirstChild("Bat") or backpack and backpack:FindFirstChild("Gummy Bear") or character:FindFirstChild("Gummy Bear")
	end

	local function fn11()
		if _G.StickyResetStowActive then
			return
		end
		local v6, v7, v8 = fn4()
		if not v6 or not v8 then
			return
		end
		local v9 = fn10()

		if v9 and v9.Parent ~= v6 then
			v8:EquipTool(v9)
		end
	end

	local n = 0

	local function fn12(arg)
		local v6
		v6, v6 = fn4()
		if not v6 then
			return nil
		end
		local v7 = nil
		local huge = math.huge
		local find = string.find
		local now = tick()
		local position = v6.Position

		local function fn13(arg2)
			for i = 1, #arg2 do
				local v8 = arg2[i]
				local name = v8.Name
				local isBasePart = find(name, "Sentry", 1, true) and name ~= "SentryBullet" and (v8.ClassName == "Model" or v8:IsA("BasePart"))

				if isBasePart then
					isBasePart = arg

					if not arg then
						isBasePart = not (obj5[v8] and now < obj5[v8])
					end
				end

				if isBasePart and fn8(v8) then
					local isBasePart2 = v8:IsA("BasePart") and v8 or v8:FindFirstChildWhichIsA("BasePart", true)

					if isBasePart2 then
						local magnitude = (position - isBasePart2.Position).Magnitude

						if magnitude < huge then
							huge = magnitude
							v7 = v8
						end
					end
				end
			end
		end

		fn13(workspace:GetChildren())
		local flag2 = not v7
		local flag3

		if flag2 then
			flag3 = now - n > (tonumber(_G.StickyTurretDeepEvery) or 3)
		else
			flag3 = flag2
		end

		if flag3 then
			n = now
			fn13(workspace:GetDescendants())
		end

		return v7
	end

	_G.StickyAutoTurretActive = function()
		return flag == true
	end

	_G.StickyToggleAutoTurret = function()
		flag = not flag

		if flag then
			n = 0
		end

		return flag
	end

	local flag2 = false

	local function fn13(arg)
		if flag2 then
			return
		end
		flag2 = true
		local v6 = obj4[arg]

		if v6 and not v6.engage then
			v6.engage = tick()
		end

		local flag3 = _G.invisibleStealEnabled == true

		if flag3 then
			_G.StickyInvisSurface = true
		end

		local now = tick()

		while true do
			local flag4 = arg and arg.Parent and v5:GetAttribute("Stealing") ~= true

			if flag4 then
				flag4 = tick() - now < (tonumber(_G.StickyTurretCycleCap) or 6)
			end

			if flag4 then
				local v7, v8, v9 = fn4()

				if not (not v7 or not v8 or not v9) then
					if fn3() then
						if not _G.StickyTpActive then
							if not (_G.StickyTurretYieldToSpeed ~= false and _G.StickyCarpetSpeedActive) then
								local v10, cframe

								if _G.StickyTurretYieldToBuyKick == false then
									v10 = fn10()
									fn9(arg)
									cframe = CFrame.new(v8.Position + v8.CFrame.LookVector * 4, v8.Position)

									if arg:IsA("Model") then
										arg:PivotTo(cframe)
									elseif arg:IsA("BasePart") then
										arg.CFrame = cframe
									end

									if v10 then
										if v10.Parent ~= v7 then
											v9:EquipTool(v10)
										end

										v10:Activate()
										task.wait(0.1)
										continue
									end
								elseif not (_G.StickyAutoBuyActive and _G.StickyAutoBuyActive()) then
									v10 = fn10()
									fn9(arg)
									cframe = CFrame.new(v8.Position + v8.CFrame.LookVector * 4, v8.Position)

									if arg:IsA("Model") then
										arg:PivotTo(cframe)
									elseif arg:IsA("BasePart") then
										arg.CFrame = cframe
									end

									if v10 then
										if v10.Parent ~= v7 then
											v9:EquipTool(v10)
										end

										v10:Activate()
										task.wait(0.1)
										continue
									end
								end
							end
						end
					end
				end
			end

			break
		end

		local parent = arg and arg.Parent

		if parent then
			parent = tick() - now >= (tonumber(_G.StickyTurretCycleCap) or 6)
		end

		if parent then
			obj5[arg] = tick() + (tonumber(_G.StickyTurretCooldown) or 2.5)
		end

		if flag3 then
			_G.StickyInvisSurface = false
		end

		if v6 then
			local now2 = tick()
			local seen = v6.seen or now2
			local armed = v6.armed or seen
			local engage = v6.engage or now2
			local flag4 = not (arg and arg.Parent)
			local pinwhy = v6.pinwhy
			local str

			if pinwhy then
				str = string.format(": %s -> %s", v6.pinwhy, v6.pinrel or "?")
			else
				str = pinwhy
			end

			_G.StickyTurretLastReport = string.format("[Turret] %s | total %.2fs | seen->armed %.2fs (ready-wait%s) | armed->engage %.2fs (ours) | swinging %.2fs | blocked by: %s", flag4 and "DESTROYED" or "SURVIVED", now2 - seen, armed - seen, str or "", engage - armed, now2 - engage, fn6())
		end

		for k in pairs(tbl2) do
			tbl2[k] = 0
		end

		flag2 = false
	end

	_G.StickyDestroyTurretIfThreat = function()
		if not (flag and fn3()) then
			return false
		end

		if _G.StickyTurretYieldToBuyKick ~= false then
			if _G.StickyAutoBuyActive and _G.StickyAutoBuyActive() then
				return false
			end
		end

		local v6, v7 = fn4()
		if not v7 then
			return false
		end
		local v8 = fn12(true)
		if not v8 then
			return false
		end
		local isBasePart = v8:IsA("BasePart") and v8 or v8:FindFirstChildWhichIsA("BasePart", true)
		if not isBasePart then
			return false
		end
		local magnitude = (v7.Position - isBasePart.Position).Magnitude
		if (tonumber(_G.StickyTurretHitRange) or 45) < magnitude then
			return false
		end

		if not fn10() then
			return false
		end
		fn11()
		fn13(v8)
		return true
	end

	_G.StickyTurretThreatNearby = function()
		if not (flag and fn3()) then
			return false
		end
		local v6, v7 = fn4()
		if not v7 then
			return false
		end
		local v8 = fn12(true)
		if not v8 then
			return false
		end
		local isBasePart = v8:IsA("BasePart") and v8 or v8:FindFirstChildWhichIsA("BasePart", true)
		if not isBasePart then
			return false
		end
		return (v7.Position - isBasePart.Position).Magnitude <= (tonumber(_G.StickyTurretHitRange) or 45)
	end

	local now = tick()
	local n2 = 0
	local n3 = 0
	local n4 = 0
	local flag3 = false
	local flag4 = false
	local n5 = 0
	local tbl3 = {}

	local function fn14(stickyTurretWhy)
		if _G.StickyTurretWhy ~= stickyTurretWhy then
			_G.StickyTurretWhy = stickyTurretWhy
			tbl3[#tbl3 + 1] = string.format("%.1f %s", tick() - now, stickyTurretWhy)

			if #tbl3 > 24 then
				table.remove(tbl3, 1)
			end

			_G.StickyTurretWhyLog = table.concat(tbl3, " | ")
		end
	end

	task.spawn(function()
		local now2 = tick()
		local n6 = 0

		local function fn15(arg)
			if n5 > 0 then
				tbl2[arg] = (tbl2[arg] or 0) + n6
			end
		end

		while true do
			task.wait(0.1)
			local now3 = tick()
			n6 = now3 - now2

			if not fn3() then
				fn14("not-in-game")
				now2 = now3
			else
				if _G.StickyTurretObserve ~= false then
					local children = workspace:GetChildren()
					local n7 = 0

					for i = 1, #children do
						local v6 = children[i]
						local name = v6.Name

						if string.find(name, "Sentry", 1, true) and name ~= "SentryBullet" and (v6.ClassName == "Model" or v6:IsA("BasePart")) and not fn7(v6) then
							n7 += 1
							local tbl4 = obj4[v6]

							if not tbl4 then
								tbl4 = { seen = now3 }
								obj4[v6] = tbl4
							end

							if flag and fn8(v6) and not tbl4.armed then
								tbl4.armed = now3
							end
						end
					end

					n5 = n7
				else
					n5 = 0
				end

				if not flag then
					fn14("off")
					now2 = now3
					continue
				end

				if now3 - now < (tonumber(_G.StickyTurretJoinGrace) or 8) then
					fn14("join-grace")
					fn15("join")
					now2 = now3
					continue
				end

				if _G.StickyTpActive then
					fn14("gate:tp")
					fn15("tp")
					now2 = now3
					continue
				end

				if _G.StickyTurretYieldToSpeed ~= false and _G.StickyCarpetSpeedActive then
					fn14("gate:speed")
					fn15("speed")
					now2 = now3
					continue
				end

				if _G.StickyTurretYieldToBuyKick ~= false then
					if _G.StickyAutoBuyActive and _G.StickyAutoBuyActive() then
						fn14("gate:buykick")
						fn15("buykick")
						now2 = now3
						continue
					end
				end

				if v5:GetAttribute("Stealing") == true then
					fn14("gate:steal")
					fn15("steal")
					now2 = now3
					continue
				end

				local flag5 = n5 == 0 and not flag3

				if flag5 then
					flag5 = now3 - n4 < (tonumber(_G.StickyTurretIdleScanDt) or 0.3)
				end

				if flag5 then
					fn14("idle:no-sentry")
					now2 = now3
					continue
				end

				n4 = now3
				local v6 = fn12()
				flag3 = v6 ~= nil

				if not v6 then
					fn14(n5 > 0 and "sentry-known-not-ready" or "idle:no-sentry")
					local flag6 = _G.StickyTurretStreamSweep ~= false and not flag4

					if flag6 then
						flag6 = now3 - n3 > (tonumber(_G.StickyTurretSweepEvery) or 1)
					end

					if flag6 then
						n3 = now3
						local plots = workspace:FindFirstChild("Plots")

						if plots then
							local children = plots:GetChildren()
							if not (#children > 0) then
								now2 = now3
								continue
							end
							n2 = n2 % #children + 1
							local mainRoot = children[n2]:FindFirstChild("MainRoot")

							if mainRoot and workspace.StreamingEnabled then
								flag4 = true
								local position = mainRoot.Position

								task.spawn(function()
									pcall(function()
										workspace:RequestStreamAroundAsync(position, 1)
									end)

									flag4 = false
								end)

								now2 = now3
								continue
							end

							now2 = now3
							continue
						end

						now2 = now3
						continue
					end

					now2 = now3
					continue
				end

				if not fn10() then
					fn14("no-weapon")
					fn15("noweapon")
					now2 = now3
					continue
				end

				fn14("engaging")
				fn11()
				fn13(v6)
				now2 = now3
			end
		end
	end)

	_G.setAutoTurret = function(arg)
		local autoTurret = arg and true or false
		v3.AutoTurret = autoTurret
		v4()
		fn2("AutoTurret", autoTurret)
		fn2("Auto Turret", autoTurret)
		flag = autoTurret

		if autoTurret then
			n = 0
		end
	end

	_G.StickyOnBoot(function()
		if v3.AutoTurret == true then
			flag = true
		end
	end)
end

do
	local Lighting = game:GetService("Lighting")
	local flag = false
	local flag2 = false
	local connection = nil
	local tbl2 = nil

	local function fn3(arg)
		pcall(function()
			if arg:IsA("Accessory") or arg:IsA("Hat") then
				arg:Destroy()
				return
			end

			if arg:IsA("BasePart") then
				arg.Material = Enum.Material.Plastic
				arg.Reflectance = 0
				arg.CastShadow = false
				return
			end

			if arg:IsA("Decal") or arg:IsA("Texture") then
				arg.Transparency = 1
				return
			end

			if arg:IsA("ParticleEmitter") or arg:IsA("Trail") or arg:IsA("Beam") or arg:IsA("Fire") or arg:IsA("Smoke") or arg:IsA("Sparkles") then
				arg.Enabled = false
			end
		end)
	end

	local function fn4()
		flag2 = true
		flag = true

		if tbl2 == nil then
			tbl2 = {
				Brightness = Lighting.Brightness,
				ClockTime = Lighting.ClockTime,
				OutdoorAmbient = Lighting.OutdoorAmbient,
				GlobalShadows = Lighting.GlobalShadows,
				FogEnd = Lighting.FogEnd,
				EnvDiffuse = Lighting.EnvironmentDiffuseScale,
				EnvSpecular = Lighting.EnvironmentSpecularScale,
				effects = {},
			}

			for _, child in ipairs(Lighting:GetChildren()) do
				if child:IsA("PostEffect") then
					tbl2.effects[child] = child.Enabled
				end
			end
		end

		Lighting.GlobalShadows = false
		Lighting.FogEnd = 1e10
		Lighting.Brightness = 1
		Lighting.EnvironmentDiffuseScale = 0
		Lighting.EnvironmentSpecularScale = 0

		for _, child in ipairs(Lighting:GetChildren()) do
			pcall(function()
				if child:IsA("BlurEffect") or child:IsA("SunRaysEffect") or child:IsA("ColorCorrectionEffect") or child:IsA("BloomEffect") or child:IsA("DepthOfFieldEffect") then
					child.Enabled = false
				end
			end)
		end

		for _, descendant in ipairs(workspace:GetDescendants()) do
			fn3(descendant)
		end

		if connection then
			connection:Disconnect()
		end

		connection = workspace.DescendantAdded:Connect(function(descendant)
			if flag2 then
				fn3(descendant)
			end
		end)
	end

	local function fn5()
		flag2 = false
		flag = false

		if connection then
			connection:Disconnect()
			connection = nil
		end

		pcall(function()
			if tbl2 then
				Lighting.Brightness = tbl2.Brightness
				Lighting.ClockTime = tbl2.ClockTime
				Lighting.OutdoorAmbient = tbl2.OutdoorAmbient
				Lighting.GlobalShadows = tbl2.GlobalShadows
				Lighting.FogEnd = tbl2.FogEnd
				Lighting.EnvironmentDiffuseScale = tbl2.EnvDiffuse
				Lighting.EnvironmentSpecularScale = tbl2.EnvSpecular

				for k, effect in pairs(tbl2.effects) do
					if k and k.Parent then
						pcall(function()
							k.Enabled = effect
						end)
					end
				end
			end

			Lighting.ExposureCompensation = 0
		end)
	end

	_G.StickyToggleAntiLag = function(arg)
		if arg == nil then
			arg = not flag
		end

		if arg then
			fn4()
		else
			fn5()
		end
	end
end

local function setAntiLag(arg)
	local antiLag = arg and true or false
	v3.AntiLag = antiLag
	v4()
	fn2("AntiLag", antiLag)
	fn2("Anti Lag", antiLag)

	task.spawn(function()
		pcall(_G.StickyToggleAntiLag, antiLag)
	end)
end

_G.setAntiLag = setAntiLag

_G.StickyOnBoot(function()
	if v3.AntiLag == true then
		pcall(setAntiLag, true)
	end
end)

do
	local tbl2 = { 80, 120, 180 }
	local connection = nil

	local function fn3()
		if connection then
			connection:Disconnect()
			connection = nil
		end

		local fieldOfView = tonumber(_G.StickyFOV)
		if not fieldOfView then
			return
		end

		connection = RunService.RenderStepped:Connect(function()
			local currentCamera = workspace.CurrentCamera

			if currentCamera and currentCamera.FieldOfView ~= fieldOfView then
				currentCamera.FieldOfView = fieldOfView
			end
		end)
	end

	local function stickySetFOV(arg)
		_G.StickyFOV = tonumber(arg) or 80
		v3.FOV = _G.StickyFOV
		v4()
		fn3()
		return _G.StickyFOV
	end

	_G.StickySetFOV = stickySetFOV

	_G.StickyCycleFOV = function()
		local num = tonumber(_G.StickyFOV) or tbl2[1]
		local n = 1

		for i, v6 in ipairs(tbl2) do
			if v6 == num then
				n = i
				break
			end
		end

		return stickySetFOV(tbl2[n % #tbl2 + 1])
	end

	_G.StickyOnBoot(function()
		_G.StickyFOV = tonumber(v3.FOV) or 80
		fn3()
	end)
end

local function fn3()
	return require(localPlayer2:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
end

fn3()

do
	local tbl2 = {
		Background = Color3.fromRGB(18, 8, 8),
		Surface = Color3.fromRGB(28, 10, 10),
		SurfaceHighlight = Color3.fromRGB(48, 16, 16),
		Accent1 = Color3.fromRGB(220, 60, 60),
		Accent2 = Color3.fromRGB(170, 30, 30),
		TextPrimary = Color3.fromRGB(240, 240, 240),
		TextSecondary = Color3.fromRGB(140, 140, 150),
		Success = Color3.fromRGB(30, 150, 90),
		Error = Color3.fromRGB(255, 60, 80),
	}

	local tbl3 = {}

	local function fn4()
		for i = #tbl3, 1, -1 do
			tbl3[i] = nil
		end

		local v6 = ipairs
		local priorityList = v2.PriorityList or {}

		for k, v7 in v6(priorityList) do
			tbl3[k] = v7
		end
	end

	local function fn5()
		v2.PriorityList = {}

		for i, v6 in ipairs(tbl3) do
			v2.PriorityList[i] = v6
		end
	end

	fn4()

	local function stickyFindAdornee(arg)
		if not arg then
			return nil
		end
		local plots = workspace_:FindFirstChild("Plots") and workspace_.Plots:FindFirstChild(arg.plot)

		if plots then
			local animalPodiums = plots:FindFirstChild("AnimalPodiums")

			if animalPodiums then
				local v6 = animalPodiums:FindFirstChild(arg.slot)

				if v6 then
					local base = v6:FindFirstChild("Base")

					if base then
						local spawn = base:FindFirstChild("Spawn")
						if spawn then
							return spawn
						end
						return base:FindFirstChildWhichIsA("BasePart") or base
					end
				end
			end
		end

		return nil
	end

	_G.StickyFindAdornee = stickyFindAdornee

	local function fn6(parent)
		if not parent then
			return
		end
		local uiScale = parent:FindFirstChildOfClass("UIScale")

		if uiScale then
			uiScale:Destroy()
		end

		local uiScale2 = Instance.new("UIScale")
		uiScale2.Parent = parent
		tbl.MobileScaleObjects[parent] = uiScale2

		if tbl.RefreshMobileScale then
			tbl.RefreshMobileScale()
		else
			uiScale2.Scale = scale
		end
	end

	tbl.RefreshMobileScale = function()
		local v6 = scale

		for k, mobileScaleObject in pairs(tbl.MobileScaleObjects) do
			if k and k.Parent and mobileScaleObject and mobileScaleObject.Parent == k then
				mobileScaleObject.Scale = v6
			else
				tbl.MobileScaleObjects[k] = nil
			end
		end
	end

	local UserInputService = game:GetService("UserInputService")

	local function fn7(arg, arg2, arg3)
		local flag = nil
		local v6 = nil
		local position = nil
		local position2 = nil

		arg.InputBegan:Connect(function(input)
			if v2.UILocked then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				flag = true
				position = input.Position
				position2 = arg2.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						flag = false

						if arg3 then
							v2.Positions[arg3] = {
								X = arg2.Position.X.Scale,
								Y = arg2.Position.Y.Scale,
								OffsetX = arg2.Position.X.Offset,
								OffsetY = arg2.Position.Y.Offset,
							}

							fn()
						end
					end
				end)
			end
		end)

		arg.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				v6 = input
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input == v6 and flag then
				local n = input.Position - position
				arg2.Position = UDim2.new(position2.X.Scale, position2.X.Offset + n.X, position2.Y.Scale, position2.Y.Offset + n.Y)
			end
		end)
	end

	local function createTextButton(arg, arg2, arg3, arg4, arg5)
		local textButton = Instance.new("TextButton", arg)
		textButton.Name = "ResizeGrip"
		textButton.AnchorPoint = Vector2.new(1, 1)
		textButton.Position = UDim2.new(1, -2, 1, -2)
		textButton.Size = UDim2.fromOffset(22, 22)
		textButton.BackgroundTransparency = 1
		textButton.Text = "◢"
		textButton.TextColor3 = Color3.fromRGB(220, 90, 90)
		textButton.TextSize = 15
		textButton.Font = Enum.Font.GothamBold
		textButton.TextTransparency = 0.45
		textButton.TextXAlignment = Enum.TextXAlignment.Right
		textButton.TextYAlignment = Enum.TextYAlignment.Bottom
		textButton.AutoButtonColor = false
		textButton.Active = true
		textButton.ZIndex = 400
		local flag = false
		local position = nil
		local n = 0
		local n2 = 0

		local function fn8()
			local scale2 = tbl.MobileScaleObjects[arg]
			scale2 = scale2 and scale2.Scale or 1

			if scale2 <= 0 then
				scale2 = 1
			end

			return scale2
		end

		local function fn9()
			local v6, v7 = arg4()
			v2.PanelSize = v2.PanelSize or {}
			v2.PanelSize[arg2] = v2.PanelSize[arg2] or {}
			v2.PanelSize[arg2].W = v6
			v2.PanelSize[arg2].H = v7

			if _G.StickySaveConfigNow then
				task.spawn(_G.StickySaveConfigNow)
			else
				fn()
			end
		end

		textButton.MouseEnter:Connect(function()
			if not flag then
				textButton.TextTransparency = 0.1
			end
		end)

		textButton.MouseLeave:Connect(function()
			if not flag then
				textButton.TextTransparency = 0.45
			end
		end)

		textButton.InputBegan:Connect(function(input)
			if v2.UILocked then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				flag = true
				position = input.Position
				local v6, v7 = arg4()
				n = v6
				n2 = v7
				textButton.TextTransparency = 0

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End and flag then
						flag = false
						textButton.TextTransparency = 0.45
						fn9()
					end
				end)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if not flag then
				return
			end

			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			local v6 = fn8()
			local n3 = (input.Position.X - position.X) / v6
			local n4 = (input.Position.Y - position.Y) / v6
			local n5 = math.clamp(n + n3, arg3.minW, arg3.maxW)
			local n6 = math.clamp(n2 + n4, arg3.minH, arg3.maxH)
			local floor = math.floor
			arg5(math.floor(n5 + 0.5), floor(n6 + 0.5))
		end)

		textButton.Visible = false
		textButton.Active = false
		textButton.Selectable = false
		return textButton
	end

	task.spawn(function()
		local fn8, fn9, Animals, fn10, fn11

		do
			local packages = replicatedStorage:WaitForChild("Packages")
			local datas = replicatedStorage:WaitForChild("Datas")
			replicatedStorage:WaitForChild("Shared")
			replicatedStorage:WaitForChild("Utils")
			local Synchronizer = require(packages:WaitForChild("Synchronizer"))

			fn8 = function(arg)
				if not arg then
					return false
				end

				if typeof(arg) == "Instance" then
					return arg == localPlayer2
				end

				if type(arg) == "string" then
					return arg == localPlayer2.Name
				end
				return false
			end

			fn9 = function(arg)
				local ok, result = pcall(function()
					local v6 = getthreadidentity and getthreadidentity() or nil

					if setthreadidentity then
						setthreadidentity(8)
					end

					local tableFromChannel = Synchronizer:GetTableFromChannel(arg)

					if v6 and setthreadidentity then
						pcall(setthreadidentity, v6)
					end

					return tableFromChannel
				end)

				if ok and type(result) == "table" then
					return result
				end
				return nil
			end

			Animals = require(datas:WaitForChild("Animals"))
			local Mutations = require(datas:WaitForChild("Mutations"))
			local Traits = require(datas:WaitForChild("Traits"))

			local tbl4 = {
				"",
				"K",
				"M",
				"B",
				"T",
				"Qa",
				"Qi",
				"Sx",
				"Sp",
				"Oc",
				"No",
				"Dc",
				"Ud",
				"Dd",
				"Td",
				"Qad",
				"Qid",
				"Sxd",
				"Spd",
				"Ocd",
				"Nod",
				"Vg",
				"Uvg",
				"Dvg",
				"Tvg",
			}

			fn10 = function(arg, arg2)
				local n = arg2 or 1
				local n2 = math.abs(arg)
				local n3 = math.floor(math.log(math.max(1, n2), 1000))
				local str = tbl4[n3 + 1] or "e+" .. n3
				return ("%." .. n .. "f"):format(math.floor(arg * 10 ^ n / 1000 ^ n3) / 10 ^ n):gsub("%.?0+$", "") .. str
			end

			fn11 = function(arg, arg2, arg3)
				local v6 = Animals[arg]
				if not v6 then
					return 0
				end
				local generation = v6.Generation or v6.Price * 0.1
				local flag = arg2 and arg2 ~= "None"
				local n = 1

				if flag then
					local v7 = Mutations[arg2]

					if v7 and v7.Modifier then
						n = 1 + v7.Modifier
					end
				end

				local flag2 = false

				if type(arg3) == "table" then
					for _, v7 in ipairs(arg3) do
						if v7 == "Sleepy" then
							flag2 = true
						else
							local v8 = Traits[v7]

							if v8 and v8.MultiplierModifier then
								n += v8.MultiplierModifier
							end
						end
					end
				end

				local v7 = math.round(generation * n)

				if flag2 then
					v7 = math.round(v7 * 0.5)
				end

				return v7
			end
		end

		local flag
		flag = true

		if v2.DefaultToPriority and v2.DefaultToHighest then
			v2.DefaultToHighest = false
		end

		if v2.DefaultToPriority and v2.DefaultToNearest then
			v2.DefaultToNearest = false
		end

		if v2.DefaultToHighest and v2.DefaultToNearest then
			v2.DefaultToNearest = false
		end

		if not v2.DefaultToPriority and not v2.DefaultToHighest and not v2.DefaultToNearest then
			v2.DefaultToHighest = true
		end

		local stealNearest
		stealNearest = false
		local stealHighest
		stealHighest = false
		local stealPriority
		stealPriority = false

		if v2.DefaultToNearest then
			stealNearest = true
			v2.StealNearest = true
			v2.StealHighest = false
			v2.StealPriority = false
		elseif v2.DefaultToHighest then
			stealHighest = true
			v2.StealHighest = true
			v2.StealNearest = false
			v2.StealPriority = false
		elseif v2.DefaultToPriority then
			stealPriority = true
			v2.StealPriority = true
			v2.StealNearest = false
			v2.StealHighest = false
		else
			stealNearest = v2.StealNearest
			stealHighest = v2.StealHighest
			stealPriority = v2.StealPriority

			if v2.InstantSteal == nil then
				v2.InstantSteal = false
			end
		end

		local instantSteal
		instantSteal = v2.InstantSteal == true
		_G.NEAREST_INSTANT_MODE = v2.StealNearest == true and v2.InstantSteal == true
		local flag2
		flag2 = false
		local flag3
		flag3 = false
		local n
		n = 1
		local uid
		uid = nil
		local uid2
		uid2 = nil
		local allAnimalsCache
		allAnimalsCache = {}
		local fn12

		fn12 = function()
			flag = stealNearest == true or stealHighest == true or stealPriority == true
		end

		fn12()
		local tbl4
		tbl4 = {}
		local tbl5
		tbl5 = {}
		local tween
		tween = nil
		local v6
		v6 = nil
		local tbl6
		tbl6 = {}
		local fn13

		fn13 = function(arg)
			if not arg or not arg.plot then
				return false
			end
			local plots = workspace_:FindFirstChild("Plots")
			if not plots then
				return false
			end
			local v7 = plots:FindFirstChild(arg.plot)
			if not v7 then
				return false
			end
			local v8 = fn9(v7.Name)
			if v8 then
				return fn8(v8.Owner)
			end
			return false
		end

		local fn14, fn15, fn16

		local function fn17(arg)
			if not arg or arg == "None" then
				return ""
			end
			local str

			if arg == "Cursed" then
				str = "<font color='rgb(200,0,0)'>Cur</font><font color='rgb(0,0,0)'>sed</font>"
			elseif arg == "Gold" then
				str = "<font color='rgb(255,215,0)'>Gold</font>"
			elseif arg == "Diamond" then
				str = "<font color='rgb(0,255,255)'>Diamond</font>"
			elseif arg == "YinYang" then
				str = "<font color='rgb(255,255,255)'>Yin</font><font color='rgb(0,0,0)'>Yang</font>"
			elseif arg == "Candy" then
				str = "<font color='rgb(255,105,180)'>Candy</font>"
			elseif arg == "Divine" then
				str = "<font color='rgb(255,255,255)'>Divine</font>"
			elseif arg == "Rainbow" then
				local tbl7 = {
					"rgb(255,0,0)",
					"rgb(255,127,0)",
					"rgb(255,255,0)",
					"rgb(0,255,0)",
					"rgb(0,0,255)",
					"rgb(75,0,130)",
					"rgb(148,0,211)",
				}

				str = ""

				for i = 1, #arg do
					str ..= "<font color='" .. tbl7[(i - 1) % #tbl7 + 1] .. "'>" .. arg:sub(i, i) .. "</font>"
				end
			elseif arg == "Radioactive" then
				str = "<font color='rgb(132,255,0)'>Radioactive</font>"
			elseif arg ~= "Galaxy" then
				str = arg
			else
				str = "<font color='rgb(170,85,255)'>Galaxy</font>"
			end

			return "<font weight='800'>" .. str .. " </font>"
		end

		fn14 = function(arg)
			if arg == "Gold" then
				return Color3.fromRGB(255, 215, 0)
			end

			if arg == "Diamond" then
				return Color3.fromRGB(0, 255, 255)
			end

			if arg == "Cursed" then
				return Color3.fromRGB(200, 0, 0)
			end

			if arg == "YinYang" then
				return Color3.fromRGB(255, 255, 255)
			end

			if arg == "Candy" then
				return Color3.fromRGB(255, 105, 180)
			end

			if arg == "Divine" then
				return Color3.fromRGB(255, 255, 255)
			end

			if arg == "Rainbow" then
				return Color3.fromRGB(148, 0, 211)
			end

			if arg == "Radioactive" then
				return Color3.fromRGB(132, 255, 0)
			end

			if arg == "Galaxy" then
				return Color3.fromRGB(170, 85, 255)
			end
			return Color3.fromRGB(255, 70, 120)
		end

		fn15 = function(arg)
			return arg and arg.petName or "Unknown"
		end

		fn16 = function(arg)
			arg = arg and arg.mutation
			if arg and arg ~= "None" and arg ~= "" then
				return fn17(arg), true
			end
			return "", false
		end

		local fn18

		fn18 = function()
			local tbl7 = {}

			for _, v7 in ipairs(allAnimalsCache) do
				if v7.genValue >= 1 and not fn13(v7) then
					table.insert(tbl7, {
						petName = v7.name,
						mpsText = v7.genText,
						mpsValue = v7.genValue,
						owner = v7.owner,
						plot = v7.plot,
						slot = v7.slot,
						uid = v7.uid,
						mutation = v7.mutation,
						animalData = v7,
					})
				end
			end

			return tbl7
		end

		local hui
		hui = gethui and gethui() or game:GetService("CoreGui")
		local n2, tbl7, scrollingFrame

		do
			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = "cJPcVLFpwxgI"
			screenGui.ResetOnSpawn = false
			screenGui.Parent = hui
			local frame = Instance.new("Frame")
			n2 = v and 0.6 or 1

			tbl7 = {
				BG = Color3.fromRGB(8, 20, 34),
				SURF = Color3.fromRGB(14, 34, 58),
				SURF2 = Color3.fromRGB(22, 52, 84),
				TEXT = Color3.fromRGB(235, 250, 255),
				DIM = Color3.fromRGB(120, 180, 230),
				AQUA = Color3.fromRGB(90, 200, 255),
				AQUA2 = Color3.fromRGB(40, 130, 210),
				AQUA_STROKE = Color3.fromRGB(120, 210, 255),
			}

			local autoSteal = v2.PanelSize and v2.PanelSize.AutoSteal
			frame.Size = UDim2.fromOffset(tonumber(autoSteal and autoSteal.W) or 320, tonumber(autoSteal and autoSteal.H) or 580)

			if autoSteal and autoSteal.W and autoSteal.H then
				tbl.AutoStealCustomSize = true
			end

			frame.Position = UDim2.new(v2.Positions.AutoSteal.X, v2.Positions.AutoSteal.OffsetX or 0, v2.Positions.AutoSteal.Y, v2.Positions.AutoSteal.OffsetY or 0)
			tbl.AutoStealFrame = frame
			frame.BackgroundColor3 = tbl7.BG
			frame.BackgroundTransparency = 0
			frame.BorderSizePixel = 0
			frame.ClipsDescendants = true
			frame.Parent = screenGui
			fn6(frame)
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
			local uiStroke = Instance.new("UIStroke", frame)
			uiStroke.Color = tbl7.AQUA_STROKE
			uiStroke.Thickness = 1.3
			uiStroke.Transparency = 0.25
			local frame2 = Instance.new("Frame", frame)
			frame2.Size = UDim2.new(1, 0, 0, 60)
			frame2.BackgroundTransparency = 1
			fn7(frame2, frame, "AutoSteal")

			createTextButton(frame, "AutoSteal", { minW = 220, minH = 200, maxW = 640, maxH = 900 }, function()
				return frame.Size.X.Offset, frame.Size.Y.Offset
			end, function(arg, arg2)
				tbl.AutoStealCustomSize = true
				frame.Size = UDim2.fromOffset(arg, arg2)
			end)

			local textLabel = Instance.new("TextLabel", frame2)
			textLabel.Size = UDim2.new(1, -32, 0, 35)
			textLabel.Position = UDim2.new(0, 16, 0, 12)
			textLabel.BackgroundTransparency = 1
			textLabel.Text = "STEAL TARGET"
			textLabel.Font = Enum.Font.GothamBlack
			textLabel.TextSize = 28
			textLabel.TextColor3 = tbl7.TEXT
			textLabel.TextXAlignment = Enum.TextXAlignment.Center
			local frame3 = Instance.new("Frame", frame)
			frame3.AnchorPoint = Vector2.new(0.5, 0)
			frame3.Position = UDim2.new(0.5, 0, 0, 54)
			frame3.Size = UDim2.new(0, 120, 0, 2)
			frame3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			frame3.BackgroundTransparency = 0.15
			frame3.BorderSizePixel = 0
			scrollingFrame = Instance.new("ScrollingFrame", frame)
		end

		scrollingFrame.Size = UDim2.new(1, -20, 1, -92)
		scrollingFrame.Position = UDim2.new(0, 10, 0, 80)
		scrollingFrame.BackgroundTransparency = 1
		scrollingFrame.BorderSizePixel = 0
		scrollingFrame.ClipsDescendants = true
		scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
		scrollingFrame.ScrollingEnabled = true
		scrollingFrame.Active = true
		scrollingFrame.Selectable = false
		scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
		scrollingFrame.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
		scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
		scrollingFrame.ScrollBarImageColor3 = tbl7.AQUA_STROKE
		scrollingFrame.ScrollBarImageTransparency = 0.15
		scrollingFrame.ScrollBarThickness = 6
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		local frame
		frame = Instance.new("Frame", scrollingFrame)
		frame.Name = "Holder"
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Position = UDim2.new(0, 0, 0, 0)
		frame.Size = UDim2.new(1, 0, 0, 0)
		frame.ClipsDescendants = false
		local uiListLayout
		uiListLayout = Instance.new("UIListLayout", frame)
		uiListLayout.Padding = UDim.new(0, 4)
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

		for _, v7 in ipairs({ playerGui, hui }) do
			local brXgmsaEVfze = v7 and v7:FindFirstChild("bRXgmsaEVfze")

			if brXgmsaEVfze then
				pcall(function()
					brXgmsaEVfze:Destroy()
				end)
			end
		end

		local textLabel, frame2, textLabel2

		do
			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = "bRXgmsaEVfze"
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = true
			screenGui.DisplayOrder = 2147483646
			screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			screenGui.Parent = hui

			local tbl8 = {
				PANEL = Color3.fromRGB(14, 34, 58),
				PANEL2 = Color3.fromRGB(22, 52, 84),
				TEXT = Color3.fromRGB(235, 250, 255),
				STROKE = Color3.fromRGB(120, 210, 255),
				GLOW = Color3.fromRGB(90, 200, 255),
				TRACK = Color3.fromRGB(20, 44, 72),
				TRACK2 = Color3.fromRGB(30, 60, 92),
				FILL1 = Color3.fromRGB(90, 200, 255),
				FILL2 = Color3.fromRGB(200, 240, 255),
			}

			local frame3 = Instance.new("Frame", screenGui)
			frame3.Name = "CurrentTargetHUD"
			frame3.AnchorPoint = Vector2.new(0.5, 1)
			frame3.Size = UDim2.new(0, 180 * n2, 0, 48 * n2)
			frame3.Position = UDim2.new(0.5, 0, 1, _G.YesIsPhone and -116 or -145)
			frame3.BackgroundColor3 = tbl8.PANEL
			frame3.BackgroundTransparency = 0.02
			frame3.BorderSizePixel = 0
			frame3.ZIndex = 70

			if not _G.YesIsPhone then
				Instance.new("UIScale", frame3).Scale = 1.25
			end

			Instance.new("UICorner", frame3).CornerRadius = UDim.new(0, math.floor(10 * n2))
			local uiStroke = Instance.new("UIStroke", frame3)
			uiStroke.Color = tbl8.STROKE
			uiStroke.Thickness = 1
			uiStroke.Transparency = 0.35
			local uiStroke2 = Instance.new("UIStroke", frame3)
			uiStroke2.Color = tbl8.GLOW
			uiStroke2.Thickness = 3
			uiStroke2.Transparency = 0.84
			uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			textLabel = Instance.new("TextLabel", frame3)
			textLabel.Name = "TargetName"
			textLabel.Size = UDim2.new(1, -10, 0, 16 * n2)
			textLabel.Position = UDim2.fromOffset(5 * n2, 4 * n2)
			textLabel.BackgroundTransparency = 1
			textLabel.Font = Enum.Font.GothamBold
			textLabel.TextSize = 10 * n2
			textLabel.TextColor3 = tbl8.TEXT
			textLabel.TextXAlignment = Enum.TextXAlignment.Center
			textLabel.TextTruncate = Enum.TextTruncate.AtEnd
			textLabel.ZIndex = 72
			textLabel.Text = "No target"
			local frame4 = Instance.new("Frame", frame3)
			frame4.Name = "ProgressBg"
			frame4.Size = UDim2.new(1, -8 * n2, 0, 16 * n2)
			frame4.Position = UDim2.fromOffset(4 * n2, 22 * n2)
			frame4.BackgroundColor3 = tbl8.TRACK
			frame4.BorderSizePixel = 0
			frame4.ZIndex = 72
			Instance.new("UICorner", frame4).CornerRadius = UDim.new(0, math.floor(6 * n2))
			local uiStroke3 = Instance.new("UIStroke", frame4)
			uiStroke3.Color = tbl8.STROKE
			uiStroke3.Thickness = 1
			uiStroke3.Transparency = 0.55
			local frame5 = Instance.new("Frame", frame4)
			frame5.Name = "InnerTrack"
			frame5.Size = UDim2.new(1, -2, 1, -2)
			frame5.Position = UDim2.fromOffset(1, 1)
			frame5.BackgroundColor3 = tbl8.TRACK2
			frame5.BackgroundTransparency = 0.15
			frame5.BorderSizePixel = 0
			frame5.ZIndex = 72
			Instance.new("UICorner", frame5).CornerRadius = UDim.new(0, math.floor(5 * n2))
			frame2 = Instance.new("Frame", frame4)
			frame2.Name = "ProgressFill"
			frame2.Size = UDim2.new(0, 0, 1, 0)
			frame2.BackgroundColor3 = tbl8.FILL1
			frame2.BorderSizePixel = 0
			frame2.ZIndex = 73
			Instance.new("UICorner", frame2).CornerRadius = UDim.new(0, math.floor(6 * n2))
			local colorSequence = ColorSequence.new
			local new = ColorSequenceKeypoint.new
			local fILL2 = tbl8.FILL2
			Instance.new("UIGradient", frame2).Color = colorSequence({ ColorSequenceKeypoint.new(0, tbl8.FILL1), new(1, fILL2) })
			local uiStroke4 = Instance.new("UIStroke", frame2)
			uiStroke4.Color = Color3.fromRGB(200, 240, 255)
			uiStroke4.Thickness = 1
			uiStroke4.Transparency = 0.45
			textLabel2 = Instance.new("TextLabel", frame4)
			textLabel2.Name = "Percent"
			textLabel2.Size = UDim2.new(1, 0, 1, 0)
			textLabel2.BackgroundTransparency = 1
			textLabel2.Font = Enum.Font.GothamBold
			textLabel2.TextSize = 10 * n2
			textLabel2.TextColor3 = tbl8.TEXT
		end

		textLabel2.TextStrokeTransparency = 0.7
		textLabel2.TextXAlignment = Enum.TextXAlignment.Center
		textLabel2.ZIndex = 74
		textLabel2.Text = "0%"
		local v7
		v7 = frame2

		for _, v8 in ipairs({ playerGui, hui }) do
			local sxTopLayer = v8 and v8:FindFirstChild("SxTopLayer")

			if sxTopLayer then
				pcall(function()
					sxTopLayer:Destroy()
				end)
			end
		end

		do
			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = "SxTopLayer"
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = true
			screenGui.DisplayOrder = 2147483647
			screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			screenGui.Parent = hui
			local frame3 = Instance.new("Frame", screenGui)
			frame3.Name = "StickyBar"
			frame3.AnchorPoint = Vector2.new(0.5, 1)
			frame3.AutomaticSize = Enum.AutomaticSize.None
			frame3.Size = UDim2.new(0, 500 * n2, 0, 42 * n2)
			frame3.Position = UDim2.new(0.5, 0, 1, _G.YesIsPhone and -68 or -70)
			frame3.BackgroundColor3 = Color3.fromRGB(8, 20, 34)
			frame3.BackgroundTransparency = 0.02
			frame3.BorderSizePixel = 0
			frame3.ClipsDescendants = false
			frame3.ZIndex = 70
			Instance.new("UICorner", frame3).CornerRadius = UDim.new(0, math.floor(8 * n2))
			local uiStroke = Instance.new("UIStroke", frame3)
			uiStroke.Color = Color3.fromRGB(120, 210, 255)
			uiStroke.Thickness = 1
			uiStroke.Transparency = 0.35
			local uiPadding = Instance.new("UIPadding", frame3)
			uiPadding.PaddingLeft = UDim.new(0, math.floor(10 * n2))
			uiPadding.PaddingRight = UDim.new(0, math.floor(10 * n2))
			local uiListLayout2 = Instance.new("UIListLayout", frame3)
			uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
			uiListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
			uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
			uiListLayout2.Padding = UDim.new(0, math.floor(14 * n2))
			local frame4 = Instance.new("Frame", frame3)
			frame4.LayoutOrder = 1
			local floor = math.floor
			frame4.Size = UDim2.fromOffset(math.floor(7 * n2), floor(7 * n2))
			frame4.BackgroundColor3 = Color3.fromRGB(90, 200, 255)
			frame4.BorderSizePixel = 0
			frame4.ZIndex = 72
			Instance.new("UICorner", frame4).CornerRadius = UDim.new(1, 0)
			local textLabel3 = Instance.new("TextLabel", frame3)
			textLabel3.LayoutOrder = 2
			textLabel3.AutomaticSize = Enum.AutomaticSize.X
			textLabel3.Size = UDim2.new(0, 0, 1, 0)
			textLabel3.BackgroundTransparency = 1
			textLabel3.Font = Enum.Font.GothamBlack
			textLabel3.TextSize = math.floor(14 * n2)
			textLabel3.TextColor3 = Color3.new(1, 1, 1)
			local uiGradient = Instance.new("UIGradient", textLabel3)
			local colorSequence = ColorSequence.new
			local tbl8 = {}
			local v8 = ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 80, 255))
			local v9 = ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 200, 255))
			local new = ColorSequenceKeypoint.new
			local color = Color3.fromRGB
			tbl8[1] = v8
			tbl8[2] = v9

			do
				local values = table.pack(new(1, color(255, 255, 255)))
				table.move(values, 1, values.n, 3, tbl8)
			end

			uiGradient.Color = colorSequence(tbl8)
			textLabel3.TextXAlignment = Enum.TextXAlignment.Left
			textLabel3.TextTruncate = Enum.TextTruncate.None
			textLabel3.TextWrapped = false
			textLabel3.ClipsDescendants = false
			textLabel3.ZIndex = 72
			textLabel3.Text = "CHOCOLA PUBLIC TP"
			local frame5 = Instance.new("Frame", frame3)
			frame5.LayoutOrder = 3
			frame5.Size = UDim2.new(0, 1, 0.6, 0)
			frame5.BackgroundColor3 = Color3.fromRGB(120, 210, 255)
			frame5.BackgroundTransparency = 0.35
			frame5.BorderSizePixel = 0
			frame5.ZIndex = 72
			local textLabel4 = Instance.new("TextLabel", frame3)
			textLabel4.LayoutOrder = 4
			textLabel4.AutomaticSize = Enum.AutomaticSize.X
			textLabel4.Size = UDim2.new(0, 0, 1, 0)
			textLabel4.BackgroundTransparency = 1
			textLabel4.Font = Enum.Font.GothamBlack
			textLabel4.TextSize = math.floor(14 * n2)
			textLabel4.TextColor3 = Color3.new(1, 1, 1)
			local uiGradient2 = Instance.new("UIGradient", textLabel4)
			local colorSequence2 = ColorSequence.new
			local tbl9 = {}
			local v10 = ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 180, 255))
			local v11 = ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 200, 255))
			local new2 = ColorSequenceKeypoint.new
			local color2 = Color3.fromRGB
			tbl9[1] = v10
			tbl9[2] = v11

			do
				local values = table.pack(new2(1, color2(200, 220, 255)))
				table.move(values, 1, values.n, 3, tbl9)
			end

			uiGradient2.Color = colorSequence2(tbl9)
			textLabel4.TextXAlignment = Enum.TextXAlignment.Left
			textLabel4.TextTruncate = Enum.TextTruncate.None
			textLabel4.TextWrapped = false
			textLabel4.ClipsDescendants = false
			textLabel4.ZIndex = 72
			textLabel4.Text = "discord.gg/4cyvmyHdt4"
			local frame6 = Instance.new("Frame", frame3)
			frame6.LayoutOrder = 5
			frame6.Size = UDim2.new(0, 1, 0.65, 0)
			frame6.BackgroundColor3 = Color3.fromRGB(120, 210, 255)
			frame6.BackgroundTransparency = 0.4
			frame6.BorderSizePixel = 0
			frame6.ZIndex = 72
			local frame7 = Instance.new("Frame", frame3)
			frame7.LayoutOrder = 6
			frame7.Size = UDim2.new(0, math.floor(38 * n2), 1, 0)
			frame7.BackgroundTransparency = 1
			frame7.ZIndex = 72
			local textLabel5 = Instance.new("TextLabel", frame7)
			textLabel5.Size = UDim2.new(1, 0, 0.42, 0)
			textLabel5.Position = UDim2.new(0, 0, 0, 0)
			textLabel5.BackgroundTransparency = 1
			textLabel5.Font = Enum.Font.GothamBlack
			textLabel5.TextSize = math.floor(8 * n2)
			textLabel5.TextColor3 = Color3.fromRGB(180, 220, 255)
			textLabel5.TextXAlignment = Enum.TextXAlignment.Center
			textLabel5.TextYAlignment = Enum.TextYAlignment.Bottom
			textLabel5.Text = "FPS"
			textLabel5.ZIndex = 72
			local textLabel6 = Instance.new("TextLabel", frame7)
			textLabel6.Size = UDim2.new(1, 0, 0.58, 0)
			textLabel6.Position = UDim2.new(0, 0, 0.42, 0)
			textLabel6.BackgroundTransparency = 1
			textLabel6.Font = Enum.Font.GothamBlack
			textLabel6.TextSize = math.floor(13 * n2)
			textLabel6.TextColor3 = Color3.fromRGB(120, 230, 140)
			textLabel6.TextXAlignment = Enum.TextXAlignment.Center
			textLabel6.TextYAlignment = Enum.TextYAlignment.Top
			textLabel6.Text = "0"
			textLabel6.ZIndex = 72
			local frame8 = Instance.new("Frame", frame3)
			frame8.LayoutOrder = 7
			frame8.Size = UDim2.new(0, 1, 0.65, 0)
			frame8.BackgroundColor3 = Color3.fromRGB(120, 210, 255)
			frame8.BackgroundTransparency = 0.4
			frame8.BorderSizePixel = 0
			frame8.ZIndex = 72
			local frame9 = Instance.new("Frame", frame3)
			frame9.LayoutOrder = 8
			frame9.Size = UDim2.new(0, math.floor(44 * n2), 1, 0)
			frame9.BackgroundTransparency = 1
			frame9.ZIndex = 72
			local textLabel7 = Instance.new("TextLabel", frame9)
			textLabel7.Size = UDim2.new(1, 0, 0.42, 0)
			textLabel7.Position = UDim2.new(0, 0, 0, 0)
			textLabel7.BackgroundTransparency = 1
			textLabel7.Font = Enum.Font.GothamBlack
			textLabel7.TextSize = math.floor(8 * n2)
			textLabel7.TextColor3 = Color3.fromRGB(180, 220, 255)
			textLabel7.TextXAlignment = Enum.TextXAlignment.Center
			textLabel7.TextYAlignment = Enum.TextYAlignment.Bottom
			textLabel7.Text = "PING"
			textLabel7.ZIndex = 72
			local textLabel8 = Instance.new("TextLabel", frame9)
			textLabel8.Size = UDim2.new(1, 0, 0.58, 0)
			textLabel8.Position = UDim2.new(0, 0, 0.42, 0)
			textLabel8.BackgroundTransparency = 1
			textLabel8.Font = Enum.Font.GothamBlack
			textLabel8.TextSize = math.floor(13 * n2)
			textLabel8.TextColor3 = Color3.fromRGB(120, 230, 140)
			textLabel8.TextXAlignment = Enum.TextXAlignment.Center
			textLabel8.TextYAlignment = Enum.TextYAlignment.Top
			textLabel8.Text = "0ms"
			textLabel8.ZIndex = 72

			task.spawn(function()
				local RunService2 = game:GetService("RunService")
				local Stats = game:GetService("Stats")
				local n3 = 0
				local n4 = 0

				RunService2.RenderStepped:Connect(function(deltaTime)
					n3 += deltaTime
					n4 += 1

					if n3 >= 0.5 then
						textLabel6.Text = tostring(math.floor(n4 / n3 + 0.5))
						n3 = 0
						n4 = 0
					end
				end)

				while task.wait(1) do
					local ok, result = pcall(function()
						return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
					end)

					if ok and result then
						textLabel8.Text = tostring(result) .. "ms"
					end
				end
			end)
		end

		local kzBUJxAKwhtf = playerGui:FindFirstChild("kzBUJxAKwhtf")

		if kzBUJxAKwhtf then
			kzBUJxAKwhtf:Destroy()
		end

		local tbl8, createUICorner, createUIStroke, fn19, textButton, textButton2, fn20, nearest, highest, priority
		local instantSteal2

		do
			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = "kzBUJxAKwhtf"
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = true
			screenGui.DisplayOrder = 999
			screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			screenGui.Parent = hui
			local frame3 = Instance.new("Frame", screenGui)
			frame3.Name = "TargetControlsFrame"
			tbl.TargetControlsFrame = frame3
			frame3.AutomaticSize = Enum.AutomaticSize.Y
			frame3.Size = UDim2.new(0, 320, 0, 0)
			local x = v2.Positions.TargetControls and v2.Positions.TargetControls.X
			local y = v2.Positions.TargetControls and v2.Positions.TargetControls.Y
			local offsetX = v2.Positions.TargetControls and v2.Positions.TargetControls.OffsetX
			local offsetY = v2.Positions.TargetControls and v2.Positions.TargetControls.OffsetY

			if x == nil or y == nil then
				x = v2.Positions.AutoSteal.X + 0.28
				y = v2.Positions.AutoSteal.Y

				if x > 0.78 then
					x = math.max(0.02, v2.Positions.AutoSteal.X - 0.28)
				end

				if y > 0.72 then
					y = 0.72
				end

				v2.Positions.TargetControls = { X = x, Y = y }
			end

			frame3.Position = UDim2.new(x or 0.26, offsetX or 10, y or 0.35, offsetY or 0)
			frame3.BackgroundColor3 = Color3.fromRGB(8, 20, 34)
			frame3.BackgroundTransparency = 0
			frame3.BorderSizePixel = 0
			frame3.ClipsDescendants = false
			frame3.ZIndex = 100
			fn6(frame3)

			tbl8 = {
				BG = Color3.fromRGB(8, 20, 34),
				SURF = Color3.fromRGB(14, 34, 58),
				SURF2 = Color3.fromRGB(22, 52, 84),
				TEXT = Color3.fromRGB(235, 250, 255),
				DIM = Color3.fromRGB(120, 180, 230),
				AQUA = Color3.fromRGB(90, 200, 255),
				AQUA2 = Color3.fromRGB(40, 130, 210),
				AQUA_STROKE = Color3.fromRGB(120, 210, 255),
				GREEN1 = Color3.fromRGB(40, 130, 210),
				GREEN2 = Color3.fromRGB(90, 200, 255),
				GREEN_STROKE = Color3.fromRGB(120, 210, 255),
				OFF_BG = Color3.fromRGB(24, 56, 92),
				OFF_TEXT = Color3.fromRGB(150, 190, 230),
			}

			createUICorner = function(parent, arg)
				local uiCorner = Instance.new("UICorner")
				uiCorner.CornerRadius = UDim.new(0, arg)
				uiCorner.Parent = parent
				return uiCorner
			end

			createUIStroke = function(parent, color, thickness, transparency)
				local uiStroke = Instance.new("UIStroke")
				uiStroke.Color = color
				uiStroke.Thickness = thickness or 1
				uiStroke.Transparency = transparency or 0
				uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				uiStroke.Parent = parent
				return uiStroke
			end

			fn19 = function(arg, arg2, arg3, arg4, arg5)
				tweenService:Create(arg, TweenInfo.new(arg2 or 0.2, arg4 or Enum.EasingStyle.Quint, arg5 or Enum.EasingDirection.Out), arg3):Play()
			end

			local function createUIGradient(parent, arg, arg2, rotation)
				local uiGradient = Instance.new("UIGradient")
				uiGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, arg), ColorSequenceKeypoint.new(1, arg2) })
				uiGradient.Rotation = rotation or 0
				uiGradient.Parent = parent
				return uiGradient
			end

			createUICorner(frame3, 16)
			createUIStroke(frame3, tbl8.AQUA_STROKE, 1.2, 0.4)
			local frame4 = Instance.new("Frame", frame3)
			frame4.Size = UDim2.new(1, 0, 0, 50)
			frame4.BackgroundTransparency = 1
			frame4.ZIndex = 101
			fn7(frame4, frame3, "TargetControls")
			local textLabel3 = Instance.new("TextLabel", frame4)
			textLabel3.Size = UDim2.new(1, -24, 0, 30)
			textLabel3.Position = UDim2.new(0, 12, 0, 10)
			textLabel3.ZIndex = 102
			textLabel3.BackgroundTransparency = 1
			textLabel3.Text = "TARGET CONTROLS"
			textLabel3.Font = Enum.Font.GothamBlack
			textLabel3.TextSize = 22
			textLabel3.TextColor3 = tbl8.TEXT
			textLabel3.TextXAlignment = Enum.TextXAlignment.Center
			local frame5 = Instance.new("Frame", frame3)
			frame5.AnchorPoint = Vector2.new(0.5, 0)
			frame5.Position = UDim2.new(0.5, 0, 0, 44)
			frame5.Size = UDim2.new(0, 120, 0, 2)
			frame5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			frame5.BackgroundTransparency = 0.15
			frame5.BorderSizePixel = 0
			frame5.ZIndex = 101
			local frame6 = Instance.new("Frame", frame3)
			frame6.Size = UDim2.new(1, -16, 0, 30)
			frame6.Position = UDim2.fromOffset(8, 50)
			frame6.BackgroundTransparency = 1
			frame6.BorderSizePixel = 0
			frame6.ZIndex = 110
			textButton = Instance.new("TextButton", frame6)
			textButton.Size = UDim2.new(0.5, -3, 1, 0)
			textButton.Position = UDim2.new(0, 0, 0, 0)
			textButton.BackgroundColor3 = tbl8.GREEN1
			textButton.TextColor3 = Color3.fromRGB(232, 255, 240)
			textButton.Text = "Main"
			textButton.Font = Enum.Font.GothamBold
			textButton.TextSize = 12
			textButton.BorderSizePixel = 0
			textButton.AutoButtonColor = false
			textButton.ZIndex = 110
			createUICorner(textButton, 6)
			textButton2 = Instance.new("TextButton", frame6)
			textButton2.Size = UDim2.new(0.5, -3, 1, 0)
			textButton2.Position = UDim2.new(0.5, 3, 0, 0)
			textButton2.BackgroundColor3 = tbl8.OFF_BG
			textButton2.TextColor3 = tbl8.OFF_TEXT
			textButton2.Text = "Settings"
			textButton2.Font = Enum.Font.GothamBold
			textButton2.TextSize = 12
			textButton2.BorderSizePixel = 0
			textButton2.AutoButtonColor = false
			textButton2.ZIndex = 110
			createUICorner(textButton2, 6)
			local frame7 = Instance.new("Frame", frame3)
			frame7.Name = "TabContent"
			frame7.Size = UDim2.new(1, -16, 0, 280)
			frame7.Position = UDim2.fromOffset(8, 86)
			frame7.BackgroundTransparency = 1
			frame7.ClipsDescendants = true
			frame7.ZIndex = 101
			local scrollingFrame2 = Instance.new("ScrollingFrame", frame7)
			scrollingFrame2.Name = "MainPage"
			scrollingFrame2.Size = UDim2.fromScale(1, 1)
			scrollingFrame2.BackgroundColor3 = tbl8.SURF
			scrollingFrame2.BorderSizePixel = 0
			scrollingFrame2.ZIndex = 101
			scrollingFrame2.ClipsDescendants = true
			scrollingFrame2.ScrollBarThickness = 4
			scrollingFrame2.ScrollBarImageColor3 = tbl8.AQUA2
			scrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, 0)
			scrollingFrame2.AutomaticCanvasSize = Enum.AutomaticSize.Y
			createUICorner(scrollingFrame2, 14)
			createUIStroke(scrollingFrame2, tbl8.AQUA_STROKE, 1, 0.48)
			local frame8 = Instance.new("Frame", scrollingFrame2)
			frame8.AutomaticSize = Enum.AutomaticSize.Y
			frame8.Size = UDim2.new(1, -8, 0, 0)
			frame8.Position = UDim2.fromOffset(4, 4)
			frame8.BackgroundTransparency = 1
			frame8.ZIndex = 102
			local uiListLayout2 = Instance.new("UIListLayout")
			uiListLayout2.Padding = UDim.new(0, 5)
			uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
			uiListLayout2.Parent = frame8
			local n3 = 1
			Instance.new("UIPadding", frame8).PaddingBottom = UDim.new(0, 12)

			fn20 = function(arg, text, arg2)
				local frame9 = Instance.new("Frame", arg)
				frame9.Name = text:gsub("%s+", "") .. "Row"
				frame9.Size = UDim2.new(1, 0, 0, math.floor(38 * n3))
				frame9.BackgroundColor3 = tbl8.SURF2
				frame9.BackgroundTransparency = 0.02
				frame9.BorderSizePixel = 0
				frame9.LayoutOrder = math.floor((arg2 or 0) / math.max(1, 42 * n3)) + 1
				frame9.ZIndex = 103
				createUICorner(frame9, 10)
				local v8 = createUIStroke(frame9, tbl8.AQUA_STROKE, 1, 0.52)
				local textLabel4 = Instance.new("TextLabel", frame9)
				textLabel4.BackgroundTransparency = 1
				textLabel4.Position = UDim2.fromOffset(10, 0)
				textLabel4.Size = UDim2.new(1, -90, 1, 0)
				textLabel4.Font = Enum.Font.GothamBold
				textLabel4.Text = text
				textLabel4.TextColor3 = tbl8.TEXT
				textLabel4.TextSize = 13 * n3
				textLabel4.TextXAlignment = Enum.TextXAlignment.Left
				textLabel4.ZIndex = 104
				local textButton3 = Instance.new("TextButton", frame9)
				textButton3.Name = text:gsub("%s+", "") .. "Toggle"
				textButton3.AutoButtonColor = false
				local floor = math.floor
				local n4 = 26 * n3
				textButton3.Size = UDim2.fromOffset(math.floor(72 * n3), floor(n4))
				textButton3.Position = UDim2.new(1, -math.floor(80 * n3), 0.5, -math.floor(13 * n3))
				textButton3.BackgroundColor3 = tbl8.OFF_BG
				textButton3.BorderSizePixel = 0
				textButton3.Text = ""
				textButton3.ZIndex = 104
				createUICorner(textButton3, 6)
				local v9 = createUIStroke(textButton3, tbl8.AQUA_STROKE, 1, 0.55)
				local frame10 = Instance.new("Frame", textButton3)
				frame10.Size = UDim2.new(1, 0, 1, 0)
				frame10.BackgroundTransparency = 1
				frame10.BorderSizePixel = 0
				frame10.ZIndex = 104
				createUICorner(frame10, 6)
				createUIGradient(frame10, tbl8.GREEN1, tbl8.GREEN2, 0)
				local textLabel5 = Instance.new("TextLabel", textButton3)
				textLabel5.BackgroundTransparency = 1
				textLabel5.Size = UDim2.fromScale(1, 1)
				textLabel5.Font = Enum.Font.GothamBold
				textLabel5.TextSize = 11 * n3
				textLabel5.Text = "OFF"
				textLabel5.TextColor3 = tbl8.OFF_TEXT
				textLabel5.ZIndex = 105

				frame9.MouseEnter:Connect(function()
					fn19(frame9, 0.14, { BackgroundColor3 = Color3.fromRGB(22, 52, 84) })
					fn19(v8, 0.14, { Transparency = 0.38 })
				end)

				frame9.MouseLeave:Connect(function()
					fn19(frame9, 0.14, { BackgroundColor3 = tbl8.SURF2 })
					fn19(v8, 0.14, { Transparency = 0.52 })
				end)

				return {
					row = frame9,
					label = textLabel4,
					button = textButton3,
					knob = frame10,
					stateLabel = textLabel5,
					stroke = v9,
					rowStroke = v8,
				}
			end

			nearest = fn20(frame8, "Nearest", 0)
			highest = fn20(frame8, "Highest", 42 * n3)
			priority = fn20(frame8, "Priority", 84 * n3)
			local frame9 = Instance.new("Frame", frame8)
			frame9.Name = "PriorityListRow"
			frame9.Size = UDim2.new(1, 0, 0, math.floor(38 * n3))
			frame9.BackgroundColor3 = tbl8.SURF2
			frame9.BackgroundTransparency = 0.02
			frame9.BorderSizePixel = 0
			frame9.LayoutOrder = math.floor(126 * n3 / math.max(1, 42 * n3)) + 1
			frame9.ZIndex = 103
			createUICorner(frame9, 10)
			local v8 = createUIStroke(frame9, tbl8.AQUA_STROKE, 1, 0.52)
			local textLabel4 = Instance.new("TextLabel", frame9)
			textLabel4.BackgroundTransparency = 1
			textLabel4.Position = UDim2.fromOffset(10, 0)
			textLabel4.Size = UDim2.new(1, -90, 1, 0)
			textLabel4.Font = Enum.Font.GothamBold
			textLabel4.Text = "Priority List"
			textLabel4.TextColor3 = tbl8.TEXT
			textLabel4.TextSize = 13 * n3
			textLabel4.TextXAlignment = Enum.TextXAlignment.Left
			textLabel4.ZIndex = 104
			local textButton3 = Instance.new("TextButton", frame9)
			textButton3.Name = "PriorityListButton"
			textButton3.AutoButtonColor = false
			local floor = math.floor
			textButton3.Size = UDim2.fromOffset(math.floor(72 * n3), floor(26 * n3))
			textButton3.Position = UDim2.new(1, -math.floor(80 * n3), 0.5, -math.floor(13 * n3))
			textButton3.BackgroundColor3 = tbl8.AQUA2
			textButton3.BorderSizePixel = 0
			textButton3.Text = "OPEN"
			textButton3.TextColor3 = tbl8.TEXT
			textButton3.TextSize = 11 * n3
			textButton3.Font = Enum.Font.GothamBold
			textButton3.ZIndex = 104
			createUICorner(textButton3, 6)
			createUIStroke(textButton3, tbl8.AQUA_STROKE, 1, 0.55)

			frame9.MouseEnter:Connect(function()
				fn19(frame9, 0.14, { BackgroundColor3 = Color3.fromRGB(22, 52, 84) })
				fn19(v8, 0.14, { Transparency = 0.38 })
			end)

			frame9.MouseLeave:Connect(function()
				fn19(frame9, 0.14, { BackgroundColor3 = tbl8.SURF2 })
				fn19(v8, 0.14, { Transparency = 0.52 })
			end)

			local flag4 = false
			local v9 = nil

			textButton3.MouseButton1Click:Connect(function()
				if v9 then
					v9:Destroy()
					v9 = nil
					flag4 = false
					textButton3.Text = "OPEN"
					return
				end

				local screenGui2 = Instance.new("ScreenGui")
				screenGui2.Name = "PriorityEditor"
				screenGui2.ResetOnSpawn = false
				screenGui2.Parent = gethui and gethui() or game:GetService("CoreGui")
				local frame10 = Instance.new("Frame")
				frame10.Size = UDim2.new(0, 340, 0, 500)
				frame10.AnchorPoint = Vector2.new(0.5, 0.5)
				frame10.Position = UDim2.new(0.5, 0, 0.5, 0)
				frame10.BackgroundColor3 = Color3.fromRGB(8, 20, 34)
				frame10.BorderSizePixel = 0
				frame10.Parent = screenGui2
				Instance.new("UICorner", frame10).CornerRadius = UDim.new(0, 12)
				local uiStroke = Instance.new("UIStroke", frame10)
				uiStroke.Color = tbl8.AQUA_STROKE
				uiStroke.Thickness = 1.2
				uiStroke.Transparency = 0.3
				local textLabel5 = Instance.new("TextLabel", frame10)
				textLabel5.Size = UDim2.new(1, 0, 0, 50)
				textLabel5.BackgroundTransparency = 1
				textLabel5.Text = "PRIORITY LIST"
				textLabel5.Font = Enum.Font.GothamBlack
				textLabel5.TextSize = 22
				textLabel5.TextColor3 = tbl8.TEXT
				textLabel5.TextXAlignment = Enum.TextXAlignment.Center
				local textButton4 = Instance.new("TextButton", frame10)
				textButton4.Size = UDim2.new(0, 36, 0, 36)
				textButton4.Position = UDim2.new(1, -44, 0, 7)
				textButton4.BackgroundColor3 = tbl8.SURF2
				textButton4.Text = "X"
				textButton4.Font = Enum.Font.GothamBold
				textButton4.TextSize = 16
				textButton4.TextColor3 = tbl8.TEXT
				textButton4.AutoButtonColor = false
				Instance.new("UICorner", textButton4).CornerRadius = UDim.new(0, 8)

				textButton4.MouseButton1Click:Connect(function()
					screenGui2:Destroy()
					v9 = nil
					flag4 = false
					textButton3.Text = "OPEN"
				end)

				local scrollingFrame3 = Instance.new("ScrollingFrame", frame10)
				scrollingFrame3.Size = UDim2.new(1, -16, 1, -80)
				scrollingFrame3.Position = UDim2.new(0, 8, 0, 60)
				scrollingFrame3.BackgroundTransparency = 1
				scrollingFrame3.BorderSizePixel = 0
				scrollingFrame3.ScrollBarThickness = 3
				scrollingFrame3.ScrollBarImageColor3 = tbl8.AQUA_STROKE
				scrollingFrame3.CanvasSize = UDim2.new(0, 0, 0, 0)
				local uiListLayout3 = Instance.new("UIListLayout", scrollingFrame3)
				uiListLayout3.Padding = UDim.new(0, 4)
				uiListLayout3.SortOrder = Enum.SortOrder.LayoutOrder

				uiListLayout3:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					scrollingFrame3.CanvasSize = UDim2.new(0, 0, 0, uiListLayout3.AbsoluteContentSize.Y + 10)
				end)

				local fn21 = nil

				fn21 = function()
					for _, child in ipairs(scrollingFrame3:GetChildren()) do
						if child:IsA("Frame") and child.Name == "Item" then
							child:Destroy()
						end
					end

					for i, v10 in ipairs(tbl3) do
						local frame11 = Instance.new("Frame", scrollingFrame3)
						frame11.Name = "Item"
						frame11.Size = UDim2.new(1, 0, 0, 40)
						frame11.BackgroundColor3 = tbl8.SURF2
						frame11.BackgroundTransparency = 0.05
						frame11.BorderSizePixel = 0
						Instance.new("UICorner", frame11).CornerRadius = UDim.new(0, 6)
						local textLabel6 = Instance.new("TextLabel", frame11)
						textLabel6.Size = UDim2.new(1, -90, 1, 0)
						textLabel6.Position = UDim2.new(0, 10, 0, 0)
						textLabel6.BackgroundTransparency = 1
						textLabel6.Text = tostring(i) .. ". " .. v10
						textLabel6.Font = Enum.Font.GothamBold
						textLabel6.TextSize = 13
						textLabel6.TextColor3 = tbl8.TEXT
						textLabel6.TextXAlignment = Enum.TextXAlignment.Left
						local textButton5 = Instance.new("TextButton", frame11)
						textButton5.Size = UDim2.new(0, 30, 0, 30)
						textButton5.Position = UDim2.new(1, -70, 0.5, -15)
						textButton5.BackgroundColor3 = tbl8.AQUA2
						textButton5.Text = "▲"
						textButton5.Font = Enum.Font.GothamBold
						textButton5.TextSize = 14
						textButton5.TextColor3 = tbl8.TEXT
						textButton5.AutoButtonColor = false
						Instance.new("UICorner", textButton5).CornerRadius = UDim.new(0, 5)

						textButton5.MouseButton1Click:Connect(function()
							if i > 1 then
								local v11 = tbl3
								local n4 = i - 1
								local v12 = tbl3[i]
								tbl3[i] = tbl3[i - 1]
								v11[n4] = v12
								fn5()
								fn()
								fn21()
								tbl.ListNeedsRedraw = true

								if tbl.UpdateAutoStealUI then
									tbl.UpdateAutoStealUI()
								end
							end
						end)

						local textButton6 = Instance.new("TextButton", frame11)
						textButton6.Size = UDim2.new(0, 30, 0, 30)
						textButton6.Position = UDim2.new(1, -36, 0.5, -15)
						textButton6.BackgroundColor3 = tbl8.AQUA2
						textButton6.Text = "▼"
						textButton6.Font = Enum.Font.GothamBold
						textButton6.TextSize = 14
						textButton6.TextColor3 = tbl8.TEXT
						textButton6.AutoButtonColor = false
						Instance.new("UICorner", textButton6).CornerRadius = UDim.new(0, 5)

						textButton6.MouseButton1Click:Connect(function()
							if i < #tbl3 then
								local v11 = tbl3
								local n4 = i + 1
								local v12 = tbl3[i]
								tbl3[i] = tbl3[i + 1]
								v11[n4] = v12
								fn5()
								fn()
								fn21()
								tbl.ListNeedsRedraw = true

								if tbl.UpdateAutoStealUI then
									tbl.UpdateAutoStealUI()
								end
							end
						end)
					end
				end

				fn21()
				v9 = screenGui2
				flag4 = true
				textButton3.Text = "CLOSE"
				fn7(frame10, frame10)
			end)

			instantSteal2 = fn20(frame8, "Instant Steal", 168 * n3)

			local function fn21(text, text2, arg, arg2)
				local frame10 = Instance.new("Frame", frame8)
				frame10.Name = text:gsub("%s+", "") .. "Row"
				frame10.Size = UDim2.new(1, 0, 0, math.floor(38 * n3))
				frame10.BackgroundColor3 = tbl8.SURF2
				frame10.BackgroundTransparency = 0.02
				frame10.BorderSizePixel = 0
				frame10.LayoutOrder = math.floor(arg * n3 / math.max(1, 42 * n3)) + 1
				frame10.ZIndex = 103
				createUICorner(frame10, 10)
				local v10 = createUIStroke(frame10, tbl8.AQUA_STROKE, 1, 0.52)
				local textLabel5 = Instance.new("TextLabel", frame10)
				textLabel5.BackgroundTransparency = 1
				textLabel5.Position = UDim2.fromOffset(10, 0)
				textLabel5.Size = UDim2.new(1, -90, 1, 0)
				textLabel5.Font = Enum.Font.GothamBold
				textLabel5.Text = text
				textLabel5.TextColor3 = tbl8.TEXT
				textLabel5.TextSize = 13 * n3
				textLabel5.TextXAlignment = Enum.TextXAlignment.Left
				textLabel5.ZIndex = 104
				local textButton4 = Instance.new("TextButton", frame10)
				textButton4.Name = text:gsub("%s+", "") .. "Button"
				textButton4.AutoButtonColor = false
				local floor2 = math.floor
				local n4 = 26 * n3
				textButton4.Size = UDim2.fromOffset(math.floor(72 * n3), floor2(n4))
				textButton4.Position = UDim2.new(1, -math.floor(80 * n3), 0.5, -math.floor(13 * n3))
				textButton4.BackgroundColor3 = tbl8.AQUA2
				textButton4.BorderSizePixel = 0
				textButton4.Text = text2
				textButton4.TextColor3 = tbl8.TEXT
				textButton4.TextSize = 11 * n3
				textButton4.Font = Enum.Font.GothamBold
				textButton4.ZIndex = 104
				createUICorner(textButton4, 6)
				createUIStroke(textButton4, tbl8.AQUA_STROKE, 1, 0.55)

				frame10.MouseEnter:Connect(function()
					fn19(frame10, 0.14, { BackgroundColor3 = Color3.fromRGB(22, 52, 84) })
					fn19(v10, 0.14, { Transparency = 0.38 })
				end)

				frame10.MouseLeave:Connect(function()
					fn19(frame10, 0.14, { BackgroundColor3 = tbl8.SURF2 })
					fn19(v10, 0.14, { Transparency = 0.52 })
				end)

				textButton4.MouseButton1Click:Connect(function()
					textButton4.Text = "..."

					task.spawn(function()
						pcall(arg2)
						task.wait(0.35)
						textButton4.Text = text2
					end)
				end)

				return frame10, textButton4
			end

			fn21("Drop Brainrot", "DROP", 210, function()
				if type(_G.StickyDropBrainrot) == "function" then
					_G.StickyDropBrainrot()
				end
			end)

			fn21("Instant Reset", "RESET", 252, function()
				if type(_G.StickyInstaReset) == "function" then
					_G.StickyInstaReset()
				end
			end)

			local carpetSpd = fn20(frame8, "Carpet Spd", 294 * n3)

			local function fn22(arg)
				if arg then
					carpetSpd.button.BackgroundColor3 = tbl8.GREEN1
					carpetSpd.knob.BackgroundTransparency = 0
					carpetSpd.stateLabel.Text = "ON"
					carpetSpd.stateLabel.TextColor3 = Color3.fromRGB(232, 255, 240)
					carpetSpd.stroke.Color = tbl8.GREEN_STROKE
					carpetSpd.stroke.Transparency = 0.22
				else
					carpetSpd.button.BackgroundColor3 = tbl8.OFF_BG
					carpetSpd.knob.BackgroundTransparency = 1
					carpetSpd.stateLabel.Text = "OFF"
					carpetSpd.stateLabel.TextColor3 = tbl8.OFF_TEXT
					carpetSpd.stroke.Color = tbl8.AQUA_STROKE
					carpetSpd.stroke.Transparency = 0.55
				end

				if carpetSpd.rowStroke then
					carpetSpd.rowStroke.Transparency = arg and 0.38 or 0.52
				end
			end

			fn22(_G.StickyCarpetSpeed == true)

			carpetSpd.button.MouseButton1Click:Connect(function()
				local flag5 = not (_G.StickyCarpetSpeed == true)

				if _G.StickySetCarpetSpeed then
					_G.StickySetCarpetSpeed(flag5)
				end

				fn22(flag5)

				if _G.StickySaveConfigNow then
					task.spawn(_G.StickySaveConfigNow)
				end
			end)

			_G.StickyOnBoot(function()
				fn22(_G.StickyCarpetSpeed == true)
			end)
		end

		do
			local plots = workspace:WaitForChild("Plots")
			local folder = Instance.new("Folder")
			folder.Name = "ChocolaPodiumESP"
			folder.Parent = workspace
			local flag4 = false
			local tbl9 = {}

			local function fn21(arg)
				local tbl10 = {}

				for _, child in ipairs(arg:GetChildren()) do
					local base = child:FindFirstChild("Base", true) or child
					local result

					if base:IsA("Model") then
						local ok

						ok, result = pcall(function()
							return base:GetBoundingBox()
						end)

						ok = ok and result
						local v8 = nil

						if not ok then
							result = v8
						end
					else
						result = nil

						if base:IsA("BasePart") then
							result = base.CFrame
						end
					end

					if result then
						local flag5 = false

						for _, v8 in ipairs(tbl10) do
							if math.abs(v8.y - result.Position.Y) <= 8 then
								v8.y = v8.y + (result.Position.Y - v8.y) / (v8.count + 1)
								v8.count = v8.count + 1
								flag5 = true
								break
							end
						end

						if not flag5 then
							table.insert(tbl10, { y = result.Position.Y, count = 1 })
						end
					end
				end

				table.sort(tbl10, function(arg2, arg3)
					return arg2.y < arg3.y
				end)

				return tbl10
			end

			local function fn22(arg)
				if #arg >= 2 then
					local n3 = arg[2].y - arg[1].y
					if n3 > 8 then
						return n3
					end
				end

				return 18
			end

			local tbl10 = {}

			local function fn23(arg)
				for _, v8 in ipairs(tbl10) do
					if (arg - v8).Magnitude <= 1.5 and math.abs(arg.Y - v8.Y) <= 2 then
						return true
					end
				end

				return false
			end

			local function fn24(arg, arg2, arg3)
				local n3 = arg3 * (arg2 - 1)

				if arg2 == 3 then
					n3 -= 0.85
				end

				return arg.Position + Vector3.new(0, n3, 0)
			end

			local color = Color3.fromRGB(90, 200, 255)
			local surfaceTransparency = 0.82

			local function fn25(arg)
				local animalPodiums = arg:FindFirstChild("AnimalPodiums")
				if not animalPodiums then
					return
				end
				local v8 = fn21(animalPodiums)
				if #v8 == 0 then
					return
				end
				local v9 = fn22(v8)
				local y = v8[1].y
				tbl10 = {}

				for _, child in ipairs(animalPodiums:GetChildren()) do
					local base = child:FindFirstChild("Base", true) or child
					local cFrame, size

					if base:IsA("Model") then
						local ok

						ok, cFrame, size = pcall(function()
							return base:GetBoundingBox()
						end)

						local v10 = nil
						local v11 = nil

						if not ok then
							cFrame = v10
							size = v11
						end
					else
						cFrame = nil
						size = nil

						if base:IsA("BasePart") then
							cFrame = base.CFrame
							size = base.Size
						end
					end

					if cFrame and size then
						local position = cFrame.Position
						table.insert(tbl10, position)
						local part = Instance.new("Part")
						part.Name = "ChocolaPodium"
						part.Anchored = true
						part.CanCollide = false
						part.CanQuery = false
						part.CanTouch = false
						part.CastShadow = false
						part.Transparency = 1
						part.Size = size
						part.CFrame = cFrame
						part.Parent = folder
						local selectionBox = Instance.new("SelectionBox")
						selectionBox.Name = "ChocolaPodium"
						selectionBox.Adornee = part
						selectionBox.Color3 = color
						selectionBox.SurfaceColor3 = color
						selectionBox.LineThickness = 0.06
						selectionBox.Transparency = 0
						selectionBox.SurfaceTransparency = surfaceTransparency
						selectionBox.Parent = part

						if math.abs(position.Y - y) <= 8 then
							for i = 2, 3 do
								local v10 = fn24(cFrame, i, v9)

								if not fn23(v10) then
									local part2 = Instance.new("Part")
									part2.Name = "ChocolaPodium"
									part2.Anchored = true
									part2.CanCollide = false
									part2.CanQuery = false
									part2.CanTouch = false
									part2.CastShadow = false
									part2.Transparency = 1
									part2.Size = Vector3.new(size.X, 0.5, size.Z)
									part2.CFrame = CFrame.new(v10) * CFrame.new(0, -(size.Y - 0.5) / 2, 0)
									part2.Parent = folder
									local selectionBox2 = Instance.new("SelectionBox")
									selectionBox2.Name = "ChocolaPodium"
									selectionBox2.Adornee = part2
									selectionBox2.Color3 = color
									selectionBox2.SurfaceColor3 = color
									selectionBox2.LineThickness = 0.06
									selectionBox2.Transparency = 0
									selectionBox2.SurfaceTransparency = surfaceTransparency
									selectionBox2.Parent = part2
									table.insert(tbl10, v10)
								end
							end
						end
					end
				end
			end

			local function fn26()
				folder:ClearAllChildren()
				if not flag4 then
					return
				end

				for _, child in ipairs(plots:GetChildren()) do
					fn25(child)
				end
			end

			local function fn27()
				for _, v8 in ipairs(tbl9) do
					v8:Disconnect()
				end

				tbl9 = {}
				table.insert(tbl9, plots.ChildAdded:Connect(fn26))
				table.insert(tbl9, plots.ChildRemoved:Connect(fn26))

				for _, child in ipairs(plots:GetChildren()) do
					local animalPodiums = child:FindFirstChild("AnimalPodiums")

					if animalPodiums then
						table.insert(tbl9, animalPodiums.ChildAdded:Connect(fn26))
						table.insert(tbl9, animalPodiums.ChildRemoved:Connect(fn26))
						table.insert(tbl9, animalPodiums.DescendantAdded:Connect(fn26))
						table.insert(tbl9, animalPodiums.DescendantRemoving:Connect(fn26))
					end
				end
			end

			_G.setChocolaPodiumESP = function(arg)
				flag4 = arg and true or false

				if flag4 then
					fn27()
					fn26()
				else
					for _, v8 in ipairs(tbl9) do
						v8:Disconnect()
					end

					tbl9 = {}
					folder:ClearAllChildren()
				end
			end

			_G.getChocolaPodiumESP = function()
				return flag4
			end
		end

		do
			local targetControlsFrame = tbl.TargetControlsFrame
			local tabContent = targetControlsFrame:FindFirstChild("TabContent")
			local mainPage = tabContent and tabContent:FindFirstChild("MainPage")
			local scrollingFrame2 = Instance.new("ScrollingFrame", tabContent)
			scrollingFrame2.Name = "SettingsPage"
			scrollingFrame2.Size = UDim2.fromScale(1, 1)
			scrollingFrame2.BackgroundColor3 = tbl8.SURF
			scrollingFrame2.BorderSizePixel = 0
			scrollingFrame2.ZIndex = 101
			scrollingFrame2.Visible = false
			scrollingFrame2.ClipsDescendants = true
			scrollingFrame2.ScrollBarThickness = 4
			scrollingFrame2.ScrollBarImageColor3 = tbl8.AQUA2
			scrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, 0)
			scrollingFrame2.AutomaticCanvasSize = Enum.AutomaticSize.Y
			createUICorner(scrollingFrame2, 14)
			createUIStroke(scrollingFrame2, tbl8.AQUA_STROKE, 1, 0.48)
			local frame3 = Instance.new("Frame", scrollingFrame2)
			frame3.AutomaticSize = Enum.AutomaticSize.Y
			frame3.Size = UDim2.new(1, -8, 0, 0)
			frame3.Position = UDim2.fromOffset(4, 4)
			frame3.BackgroundTransparency = 1
			frame3.ZIndex = 102
			local uiListLayout2 = Instance.new("UIListLayout", frame3)
			uiListLayout2.Padding = UDim.new(0, 5)
			uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder

			local function fn21(arg, arg2)
				if not arg then
					return
				end

				if arg2 then
					arg.button.BackgroundColor3 = tbl8.GREEN1
					arg.knob.BackgroundTransparency = 0
					arg.stateLabel.Text = "ON"
					arg.stateLabel.TextColor3 = Color3.fromRGB(232, 255, 240)
					arg.stroke.Color = tbl8.GREEN_STROKE
					arg.stroke.Transparency = 0.22
				else
					arg.button.BackgroundColor3 = tbl8.OFF_BG
					arg.knob.BackgroundTransparency = 1
					arg.stateLabel.Text = "OFF"
					arg.stateLabel.TextColor3 = tbl8.OFF_TEXT
					arg.stroke.Color = tbl8.AQUA_STROKE
					arg.stroke.Transparency = 0.55
				end

				if arg.rowStroke then
					arg.rowStroke.Transparency = arg2 and 0.38 or 0.52
				end
			end

			_G.SlicedzSyncToggleUI = function()
			end

			local v8 = fn20(frame3, "X-Ray", 0)
			local playerEsp = fn20(frame3, "Player ESP", 42)
			local nextBase = fn20(frame3, "Next Base", 84)
			local autoKick = fn20(frame3, "Auto Kick", 126)
			local infJump = fn20(frame3, "Inf Jump", 168)
			local podiumEsp = fn20(frame3, "Podium ESP", 252)
			local turretEsp = fn20(frame3, "Turret ESP", 294)
			local trapEsp = fn20(frame3, "Trap ESP", 336)
			local antiRagdoll = fn20(frame3, "Anti Ragdoll", 378)
			local v9 = fn20(frame3, "Anti Bee/Disco", 420)
			local antiDie = fn20(frame3, "Anti Die", 462)
			local autoTurret = fn20(frame3, "Auto Turret", 504)
			local antiLag = fn20(frame3, "Anti Lag", 546)
			local brainrotEsp = fn20(frame3, "Brainrot ESP", 630)
			local podium = fn20(frame3, "Podium", 672)
			fn21(v8, v2.XRay == true)
			fn21(playerEsp, v2.PlayerESP == true)
			fn21(nextBase, v2.nextBaseEnabled == true)
			fn21(autoKick, _G.StickyAutoKickOnSteal == true)
			fn21(infJump, _G.StickyInfJump == true)
			fn21(podiumEsp, v2.podiumESP == true)
			fn21(turretEsp, v2.TurretESP == true)
			fn21(trapEsp, v2.TrapESP == true)
			fn21(brainrotEsp, v2.BrainrotESP == true)
			fn21(antiRagdoll, v2.AntiRagdoll ~= false)
			fn21(v9, v2.AntiBeeDisco ~= false)
			fn21(antiDie, v2.AntiDie ~= false)
			fn21(autoTurret, v2.AutoTurret == true)
			fn21(antiLag, v2.AntiLag == true)

			v8.button.MouseButton1Click:Connect(function()
				local xRay = not (v2.XRay == true)
				fn21(v8, xRay)

				if type(_G.setXRay) == "function" then
					task.spawn(_G.setXRay, xRay)
				else
					v2.XRay = xRay
					fn()
				end
			end)

			playerEsp.button.MouseButton1Click:Connect(function()
				local playerESP = not (v2.PlayerESP == true)
				fn21(playerEsp, playerESP)

				if type(_G.setPlayerESP) == "function" then
					task.spawn(_G.setPlayerESP, playerESP)
				else
					v2.PlayerESP = playerESP
					fn()
				end
			end)

			nextBase.button.MouseButton1Click:Connect(function()
				local nextBaseEnabled = not (v2.nextBaseEnabled == true)
				fn21(nextBase, nextBaseEnabled)

				if type(_G.setNextBase) == "function" then
					task.spawn(_G.setNextBase, nextBaseEnabled)
				else
					v2.nextBaseEnabled = nextBaseEnabled
					fn()
				end
			end)

			autoKick.button.MouseButton1Click:Connect(function()
				local stickyAutoKickOnSteal = not (_G.StickyAutoKickOnSteal == true)
				_G.StickyAutoKickOnSteal = stickyAutoKickOnSteal
				fn21(autoKick, stickyAutoKickOnSteal)

				if _G.StickySaveConfigNow then
					task.spawn(_G.StickySaveConfigNow)
				end
			end)

			infJump.button.MouseButton1Click:Connect(function()
				local stickyInfJump = not (_G.StickyInfJump == true)
				_G.StickyInfJump = stickyInfJump
				fn21(infJump, stickyInfJump)

				if _G.StickySaveConfigNow then
					task.spawn(_G.StickySaveConfigNow)
				end
			end)

			podiumEsp.button.MouseButton1Click:Connect(function()
				local podiumESP = not (v2.podiumESP == true)
				fn21(podiumEsp, podiumESP)

				if type(_G.setPodiumESP) == "function" then
					task.spawn(_G.setPodiumESP, podiumESP)
				else
					v2.podiumESP = podiumESP
					fn()
				end
			end)

			turretEsp.button.MouseButton1Click:Connect(function()
				local turretESP = not (v2.TurretESP == true)
				fn21(turretEsp, turretESP)

				if type(_G.setTurretESP) == "function" then
					task.spawn(_G.setTurretESP, turretESP)
				else
					v2.TurretESP = turretESP
					fn()
				end
			end)

			trapEsp.button.MouseButton1Click:Connect(function()
				local trapESP = not (v2.TrapESP == true)
				fn21(trapEsp, trapESP)

				if type(_G.setTrapESP) == "function" then
					task.spawn(_G.setTrapESP, trapESP)
				else
					v2.TrapESP = trapESP
					fn()
				end
			end)

			brainrotEsp.button.MouseButton1Click:Connect(function()
				local brainrotESP = not (v2.BrainrotESP == true)
				fn21(brainrotEsp, brainrotESP)

				if type(_G.setBrainrotESP) == "function" then
					task.spawn(_G.setBrainrotESP, brainrotESP)
				else
					v2.BrainrotESP = brainrotESP
					fn()
				end
			end)

			antiRagdoll.button.MouseButton1Click:Connect(function()
				local antiRagdoll2 = not (v2.AntiRagdoll ~= false)
				fn21(antiRagdoll, antiRagdoll2)

				if type(_G.setAntiRagdoll) == "function" then
					task.spawn(_G.setAntiRagdoll, antiRagdoll2)
				else
					v2.AntiRagdoll = antiRagdoll2
					fn()
				end
			end)

			v9.button.MouseButton1Click:Connect(function()
				local antiBeeDisco = not (v2.AntiBeeDisco ~= false)
				fn21(v9, antiBeeDisco)

				if type(_G.setAntiBeeDisco) == "function" then
					task.spawn(_G.setAntiBeeDisco, antiBeeDisco)
				else
					v2.AntiBeeDisco = antiBeeDisco
					fn()
				end
			end)

			antiDie.button.MouseButton1Click:Connect(function()
				local antiDie2 = not (v2.AntiDie ~= false)
				fn21(antiDie, antiDie2)

				if type(_G.setAntiDie) == "function" then
					task.spawn(_G.setAntiDie, antiDie2)
				else
					v2.AntiDie = antiDie2
					fn()
				end
			end)

			autoTurret.button.MouseButton1Click:Connect(function()
				local autoTurret2 = not (v2.AutoTurret == true)
				fn21(autoTurret, autoTurret2)

				if type(_G.setAutoTurret) == "function" then
					task.spawn(_G.setAutoTurret, autoTurret2)
				else
					v2.AutoTurret = autoTurret2
					fn()
				end
			end)

			antiLag.button.MouseButton1Click:Connect(function()
				local antiLag2 = not (v2.AntiLag == true)
				fn21(antiLag, antiLag2)

				if type(_G.setAntiLag) == "function" then
					task.spawn(_G.setAntiLag, antiLag2)
				else
					v2.AntiLag = antiLag2
					fn()
				end
			end)

			podium.button.MouseButton1Click:Connect(function()
				local flag4 = not _G.getChocolaPodiumESP()
				fn21(podium, flag4)

				if type(_G.setChocolaPodiumESP) == "function" then
					task.spawn(_G.setChocolaPodiumESP, flag4)
				end
			end)

			local function fn22(arg, text, arg2, arg3, arg4)
				local frame4 = Instance.new("Frame", arg)
				frame4.Size = UDim2.new(1, 0, 0, 38)
				frame4.BackgroundColor3 = tbl8.SURF2
				frame4.BackgroundTransparency = 0.02
				frame4.BorderSizePixel = 0
				frame4.LayoutOrder = math.floor(arg2 / 42) + 1
				frame4.ZIndex = 103
				createUICorner(frame4, 10)
				createUIStroke(frame4, tbl8.AQUA_STROKE, 1, 0.52)
				local textLabel3 = Instance.new("TextLabel", frame4)
				textLabel3.BackgroundTransparency = 1
				textLabel3.Position = UDim2.fromOffset(10, 0)
				textLabel3.Size = UDim2.new(0, 120, 1, 0)
				textLabel3.Font = Enum.Font.GothamBold
				textLabel3.Text = text
				textLabel3.TextColor3 = tbl8.TEXT
				textLabel3.TextSize = 11
				textLabel3.TextXAlignment = Enum.TextXAlignment.Left
				textLabel3.ZIndex = 104
				local textBox = Instance.new("TextBox", frame4)
				textBox.Size = UDim2.new(0, 60, 0, 24)
				textBox.Position = UDim2.new(1, -74, 0.5, -12)
				textBox.BackgroundColor3 = tbl8.BG
				textBox.BorderSizePixel = 0
				textBox.Text = tostring(arg3)
				textBox.Font = Enum.Font.Gotham
				textBox.TextSize = 11
				textBox.TextColor3 = tbl8.TEXT
				textBox.PlaceholderColor3 = tbl8.DIM
				textBox.ZIndex = 104
				createUICorner(textBox, 6)

				textBox.FocusLost:Connect(function()
					arg4(textBox)
				end)

				return frame4, textBox
			end

			fn22(frame3, "Carpet Spd Val", 210, _G.StickyCarpetSpeedValue or 140, function(arg)
				local num = tonumber(arg.Text)

				if num then
					_G.StickyCarpetSpeedValue = math.clamp(num, 20, 400)
					arg.Text = tostring(_G.StickyCarpetSpeedValue)
				else
					arg.Text = tostring(_G.StickyCarpetSpeedValue or 140)
				end

				if _G.StickySaveConfigNow then
					task.spawn(_G.StickySaveConfigNow)
				end
			end)

			local function fn23(arg, text, arg2, arg3, arg4)
				local frame4 = Instance.new("Frame", arg)
				frame4.Size = UDim2.new(1, 0, 0, 38)
				frame4.BackgroundColor3 = tbl8.SURF2
				frame4.BackgroundTransparency = 0.02
				frame4.BorderSizePixel = 0
				frame4.LayoutOrder = math.floor(arg2 / 42) + 1
				frame4.ZIndex = 103
				createUICorner(frame4, 10)
				createUIStroke(frame4, tbl8.AQUA_STROKE, 1, 0.52)
				local textLabel3 = Instance.new("TextLabel", frame4)
				textLabel3.BackgroundTransparency = 1
				textLabel3.Position = UDim2.fromOffset(10, 0)
				textLabel3.Size = UDim2.new(0, 120, 1, 0)
				textLabel3.Font = Enum.Font.GothamBold
				textLabel3.Text = text
				textLabel3.TextColor3 = tbl8.TEXT
				textLabel3.TextSize = 11
				textLabel3.TextXAlignment = Enum.TextXAlignment.Left
				textLabel3.ZIndex = 104
				local textButton3 = Instance.new("TextButton", frame4)
				textButton3.Size = UDim2.new(0, 60, 0, 24)
				textButton3.Position = UDim2.new(1, -74, 0.5, -12)
				textButton3.BackgroundColor3 = tbl8.AQUA2
				textButton3.BorderSizePixel = 0
				textButton3.AutoButtonColor = false
				textButton3.Text = tostring(arg3)
				textButton3.Font = Enum.Font.GothamBold
				textButton3.TextSize = 11
				textButton3.TextColor3 = tbl8.TEXT
				textButton3.ZIndex = 104
				createUICorner(textButton3, 6)
				createUIStroke(textButton3, tbl8.AQUA_STROKE, 1, 0.55)

				textButton3.MouseButton1Click:Connect(function()
					local ok, result = pcall(arg4)

					if ok and result ~= nil then
						textButton3.Text = tostring(result)
					end
				end)

				return frame4, textButton3
			end

			fn23(frame3, "FOV", 588, math.floor(tonumber(v2.FOV) or 80), function()
				if type(_G.StickyCycleFOV) == "function" then
					return math.floor(_G.StickyCycleFOV())
				end
				return math.floor(tonumber(v2.FOV) or 80)
			end)

			fn22(frame3, "Brainrot Min M/s", 672, math.floor((tonumber(v2.BrainrotESPMinGen) or 10000000) / 1000000), function(arg)
				local num = tonumber(arg.Text)

				if num then
					v2.BrainrotESPMinGen = math.clamp(num, 0, 100000) * 1000000
					fn()
				end

				arg.Text = tostring(math.floor((tonumber(v2.BrainrotESPMinGen) or 10000000) / 1000000))
			end)

			local tbl9 = {}

			if mainPage then
				tbl9.main = mainPage
			end

			tbl9.settings = scrollingFrame2
			local targetControls = v2.PanelSize and v2.PanelSize.TargetControls
			local mainH = tonumber(targetControls and targetControls.MainH) or 338
			local settingsH = tonumber(targetControls and targetControls.SettingsH) or 380
			local str = "main"

			local function fn24()
				return str == "settings" and settingsH or mainH
			end

			if targetControls and tonumber(targetControls.W) then
				targetControlsFrame.Size = UDim2.new(0, math.floor(tonumber(targetControls.W)), 0, 0)
			end

			local function fn25(arg)
				str = arg

				for k, v10 in pairs(tbl9) do
					v10.Visible = k == arg
				end

				if tabContent then
					tabContent.Size = UDim2.new(1, -16, 0, fn24())
				end

				if arg == "main" then
					textButton.BackgroundColor3 = tbl8.GREEN1
					textButton.TextColor3 = Color3.fromRGB(232, 255, 240)
					textButton2.BackgroundColor3 = tbl8.OFF_BG
					textButton2.TextColor3 = tbl8.OFF_TEXT
				else
					textButton.BackgroundColor3 = tbl8.OFF_BG
					textButton.TextColor3 = tbl8.OFF_TEXT
					textButton2.BackgroundColor3 = tbl8.GREEN1
					textButton2.TextColor3 = Color3.fromRGB(232, 255, 240)
				end
			end

			textButton.MouseButton1Click:Connect(function()
				fn25("main")
			end)

			textButton2.MouseButton1Click:Connect(function()
				fn25("settings")
			end)

			task.defer(function()
				task.wait()
				fn25("main")
			end)

			local targetControlsFrame2 = tbl.TargetControlsFrame
			local autoStealFrame = tbl.AutoStealFrame

			if targetControlsFrame2 and autoStealFrame then
				local function fn26()
					if not (targetControlsFrame2.Parent and autoStealFrame.Parent) then
						return
					end

					if tbl.AutoStealCustomSize then
						return
					end
					local n3 = _G.YesIsPhone and 296 or 86 + mainH
					local n4 = _G.YesIsPhone and 240 or 260

					if not (n3 < n4) then
						n4 = n3
					end

					autoStealFrame.Size = UDim2.new(0, targetControlsFrame2.Size.X.Offset, 0, math.floor(n4 + 0.5))
				end

				createTextButton(targetControlsFrame2, "TargetControls", { minW = 240, minH = 200, maxW = 640, maxH = 900 }, function()
					return targetControlsFrame2.Size.X.Offset, 86 + fn24()
				end, function(arg, arg2)
					local n3 = math.max(110, arg2 - 86)

					if str == "settings" then
						settingsH = n3
					else
						mainH = n3
					end

					targetControlsFrame2.Size = UDim2.new(0, arg, 0, 0)

					if tabContent then
						tabContent.Size = UDim2.new(1, -16, 0, n3)
					end

					v2.PanelSize = v2.PanelSize or {}
					v2.PanelSize.TargetControls = v2.PanelSize.TargetControls or {}
					v2.PanelSize.TargetControls.MainH = mainH
					v2.PanelSize.TargetControls.SettingsH = settingsH
				end)

				local function fn27()
					local currentCamera = workspace.CurrentCamera
					currentCamera = currentCamera and currentCamera.ViewportSize
					if not currentCamera or currentCamera.X < 1 or currentCamera.Y < 1 then
						return
					end
					local tbl10 = { [autoStealFrame] = "AutoSteal", [targetControlsFrame2] = "TargetControls" }
					local flag4 = false

					for _, v10 in ipairs({ autoStealFrame, targetControlsFrame2 }) do
						if v10.Parent then
							local absoluteSize = v10.AbsoluteSize

							if absoluteSize.X > 1 and absoluteSize.Y > 1 then
								local position = v10.Position
								local n3 = position.X.Scale * currentCamera.X + position.X.Offset
								local n4 = position.Y.Scale * currentCamera.Y + position.Y.Offset
								local n5 = math.clamp(n3, 6, math.max(6, currentCamera.X - absoluteSize.X - 6))
								local n6 = math.clamp(n4, 6, math.max(6, currentCamera.Y - absoluteSize.Y - 6))

								if math.abs(n5 - n3) > 1 or math.abs(n6 - n4) > 1 then
									local floor = math.floor
									v10.Position = UDim2.fromOffset(math.floor(n5), floor(n6))
									local v11 = tbl10[v10]

									if v11 and v2.Positions then
										v2.Positions[v11] = { X = 0, Y = 0, OffsetX = math.floor(n5), OffsetY = math.floor(n6) }
										flag4 = true
									end
								end
							end
						end
					end

					if flag4 and _G.StickySaveConfigNow then
						task.spawn(_G.StickySaveConfigNow)
					end
				end

				targetControlsFrame2:GetPropertyChangedSignal("AbsoluteSize"):Connect(fn26)
				task.defer(fn26)

				if _G.StickyOnBoot then
					_G.StickyOnBoot(function()
						fn26()
						fn27()
					end)
				else
					task.delay(1, fn27)
				end
			end
		end

		do
			local fn21 = nil

			fn21 = function(arg, selectedPetData)
				fn12()

				local function fn22(arg2, arg3, arg4)
					if not arg4 then
					end

					if arg3 then
						arg2.button.BackgroundColor3 = tbl8.GREEN1
						arg2.knob.BackgroundTransparency = 0
						arg2.stateLabel.Text = "ON"
						arg2.stateLabel.TextColor3 = Color3.fromRGB(232, 255, 240)
						arg2.stroke.Color = tbl8.GREEN_STROKE
						arg2.stroke.Transparency = 0.22
					else
						arg2.button.BackgroundColor3 = tbl8.OFF_BG
						arg2.knob.BackgroundTransparency = 1
						arg2.stateLabel.Text = "OFF"
						arg2.stateLabel.TextColor3 = tbl8.OFF_TEXT
						arg2.stroke.Color = tbl8.AQUA_STROKE
						arg2.stroke.Transparency = 0.55
					end

					if arg2.rowStroke then
						arg2.rowStroke.Transparency = arg3 and 0.38 or 0.52
					end

					if arg2.label then
						arg2.label.TextColor3 = arg3 and tbl8.TEXT or tbl8.TEXT
					end
				end

				fn22(nearest, stealNearest, tbl2.Accent1)
				fn22(highest, stealHighest, tbl2.Accent1)
				fn22(priority, stealPriority, tbl2.Accent2)

				if instantSteal2 then
					if instantSteal then
						instantSteal2.stateLabel.Text = "ON"
						instantSteal2.stateLabel.TextColor3 = Color3.fromRGB(232, 255, 240)
						instantSteal2.button.BackgroundColor3 = tbl8.GREEN1
						instantSteal2.knob.BackgroundTransparency = 0
						instantSteal2.stroke.Color = tbl8.GREEN_STROKE
						instantSteal2.stroke.Transparency = 0.22
					else
						instantSteal2.stateLabel.Text = "OFF"
						instantSteal2.stateLabel.TextColor3 = tbl8.OFF_TEXT
						instantSteal2.button.BackgroundColor3 = tbl8.OFF_BG
						instantSteal2.knob.BackgroundTransparency = 1
						instantSteal2.stroke.Color = tbl8.AQUA_STROKE
						instantSteal2.stroke.Transparency = 0.55
					end

					if instantSteal2.rowStroke then
						instantSteal2.rowStroke.Transparency = instantSteal and 0.38 or 0.52
					end
				end

				if uid and selectedPetData then
					for i, v8 in ipairs(selectedPetData) do
						if v8.uid == uid then
							n = i
							break
						end
					end
				end

				if tbl.ListNeedsRedraw then
					for _, child in ipairs(frame:GetChildren()) do
						if child:IsA("TextButton") then
							child:Destroy()
						end
					end

					tbl6 = {}

					if selectedPetData and #selectedPetData > 0 then
						for i = 1, #selectedPetData do
							local v8 = selectedPetData[i]
							local textButton3 = Instance.new("TextButton")
							textButton3.Size = UDim2.new(1, 0, 0, 38)
							textButton3.BackgroundColor3 = tbl7.SURF2
							textButton3.BorderSizePixel = 0
							textButton3.Text = ""
							textButton3.AutoButtonColor = false
							textButton3.Parent = frame
							textButton3.Position = UDim2.new(0, 0, 0, 0)
							textButton3.ClipsDescendants = true
							textButton3.ZIndex = 1
							Instance.new("UICorner", textButton3).CornerRadius = UDim.new(0, 8)
							local frame3 = Instance.new("Frame", textButton3)
							frame3.Name = "SelectedOverlay"
							frame3.Size = UDim2.new(1, 0, 1, 0)
							frame3.Position = UDim2.new(0, 0, 0, 0)
							frame3.BackgroundColor3 = Color3.fromRGB(8, 10, 12)
							frame3.BackgroundTransparency = 0.82
							frame3.BorderSizePixel = 0
							frame3.Visible = false
							frame3.ZIndex = 2
							Instance.new("UICorner", frame3).CornerRadius = UDim.new(0, 8)
							local uiGradient = Instance.new("UIGradient", frame3)
							uiGradient.Rotation = 90
							local colorSequence = ColorSequence.new
							local tbl9 = {}
							local v9 = ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0))
							local v10 = ColorSequenceKeypoint.new(0.45, Color3.fromRGB(18, 22, 18))
							local new = ColorSequenceKeypoint.new
							local color = Color3.fromRGB
							tbl9[1] = v9
							tbl9[2] = v10

							do
								local values = table.pack(new(1, color(0, 0, 0)))
								table.move(values, 1, values.n, 3, tbl9)
							end

							uiGradient.Color = colorSequence(tbl9)
							local numberSequence = NumberSequence.new
							local tbl10 = {}
							local v11 = NumberSequenceKeypoint.new(0, 0.12)
							local v12 = NumberSequenceKeypoint.new(0.18, 0.3)
							local v13 = NumberSequenceKeypoint.new(0.55, 0.52)
							local new2 = NumberSequenceKeypoint.new
							tbl10[1] = v11
							tbl10[2] = v12
							tbl10[3] = v13

							do
								local values = table.pack(new2(1, 0.18))
								table.move(values, 1, values.n, 4, tbl10)
							end

							uiGradient.Transparency = numberSequence(tbl10)
							local frame4 = Instance.new("Frame", textButton3)
							frame4.Size = UDim2.fromOffset(24, 24)
							frame4.Position = UDim2.fromOffset(8, 7)
							frame4.BackgroundColor3 = tbl7.SURF
							frame4.ZIndex = 3
							frame4.BorderSizePixel = 0
							Instance.new("UICorner", frame4).CornerRadius = UDim.new(0, 4)
							local uiStroke = Instance.new("UIStroke", frame4)
							uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
							uiStroke.Color = tbl7.AQUA_STROKE
							uiStroke.Thickness = 1
							uiStroke.Transparency = 0.45
							local textLabel3 = Instance.new("TextLabel", frame4)
							textLabel3.Size = UDim2.new(1, 0, 1, 0)
							textLabel3.BackgroundTransparency = 1
							textLabel3.Text = "#" .. i
							textLabel3.Font = Enum.Font.GothamBold
							textLabel3.TextSize = 11
							textLabel3.TextColor3 = tbl7.TEXT
							textLabel3.TextXAlignment = Enum.TextXAlignment.Center
							textLabel3.ZIndex = 4
							local petName = v8 and v8.petName or "Unknown"
							local mpsText = v8 and v8.mpsText or "$0/s"
							local textLabel4 = Instance.new("TextLabel", textButton3)
							textLabel4.Size = UDim2.new(1, -140, 0, 16)
							textLabel4.Position = UDim2.fromOffset(40, 2)
							textLabel4.BackgroundTransparency = 1
							textLabel4.RichText = false
							textLabel4.Text = petName
							textLabel4.Font = Enum.Font.GothamBold
							textLabel4.TextSize = 12
							textLabel4.TextColor3 = tbl7.TEXT
							textLabel4.TextXAlignment = Enum.TextXAlignment.Left
							textLabel4.TextTruncate = Enum.TextTruncate.None
							textLabel4.ClipsDescendants = false
							textLabel4.ZIndex = 4
							local uiTextSizeConstraint = Instance.new("UITextSizeConstraint", textLabel4)
							uiTextSizeConstraint.MinTextSize = 8
							uiTextSizeConstraint.MaxTextSize = 12
							local textLabel5 = Instance.new("TextLabel", textButton3)
							textLabel5.Size = UDim2.new(0, 90, 0, 16)
							textLabel5.Position = UDim2.new(1, -98, 0, 2)
							textLabel5.BackgroundTransparency = 1
							textLabel5.RichText = false
							textLabel5.Text = mpsText
							textLabel5.Font = Enum.Font.GothamBold
							textLabel5.TextSize = 12
							textLabel5.TextColor3 = Color3.fromRGB(120, 230, 255)
							textLabel5.TextXAlignment = Enum.TextXAlignment.Right
							textLabel5.TextTruncate = Enum.TextTruncate.AtEnd
							textLabel5.ZIndex = 4
							local textLabel6 = Instance.new("TextLabel", textButton3)
							textLabel6.Size = UDim2.new(1, -140, 0, 16)
							textLabel6.Position = UDim2.fromOffset(40, 20)
							textLabel6.BackgroundTransparency = 1
							local v14, v15 = fn16(v8)
							textLabel6.RichText = v15
							textLabel6.Text = v14
							textLabel6.Font = Enum.Font.GothamBold
							textLabel6.TextSize = 12
							textLabel6.TextColor3 = fn14(v8.mutation)
							textLabel6.TextXAlignment = Enum.TextXAlignment.Left
							textLabel6.TextTruncate = Enum.TextTruncate.None
							textLabel6.ClipsDescendants = false
							textLabel6.ZIndex = 4
							local uiTextSizeConstraint2 = Instance.new("UITextSizeConstraint", textLabel6)
							uiTextSizeConstraint2.MinTextSize = 8
							uiTextSizeConstraint2.MaxTextSize = 12
							textLabel6.Visible = v14 ~= ""

							tbl6[i] = {
								button = textButton3,
								selectedOverlay = frame3,
								rankBox = frame4,
								rankBoxStroke = uiStroke,
								rank = textLabel3,
								info = textLabel4,
								rate = textLabel5,
								mutation = textLabel6,
								petData = v8,
							}

							textButton3.MouseButton1Click:Connect(function()
								if uid2 == v8.uid then
									uid2 = nil
									uid = nil
									_G.NEAREST_INSTANT_MODE = stealNearest and instantSteal
								else
									n = i
									uid = v8.uid
									uid2 = v8.uid
									flag = true
									_G.NEAREST_INSTANT_MODE = false
								end

								tbl.ListNeedsRedraw = true
								fn21(flag, fn18())
							end)
						end
					end

					tbl.ListNeedsRedraw = false
					local n3 = #tbl6
					local n4 = 0

					if n3 > 0 then
						n4 = n3 * 38 + (n3 - 1) * 4
					end

					frame.Size = UDim2.new(1, 0, 0, n4)
					scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, n4 + 8)
				end

				for _, v8 in ipairs(tbl6) do
					local visible = v8.petData and uid2 and v8.petData.uid == uid2
					v8.button.ZIndex = 1
					v8.button.BackgroundTransparency = 0
					v8.button.BackgroundColor3 = visible and Color3.fromRGB(40, 130, 210) or tbl7.SURF2

					if v8.selectedOverlay then
						v8.selectedOverlay.Visible = visible
						v8.selectedOverlay.ZIndex = 2
						v8.selectedOverlay.BackgroundColor3 = Color3.fromRGB(8, 10, 12)
						v8.selectedOverlay.BackgroundTransparency = visible and 0.9 or 1
					end

					if v8.rankBox then
						v8.rankBox.BackgroundColor3 = visible and Color3.fromRGB(30, 90, 150) or tbl7.SURF
						v8.rankBox.ZIndex = 3
					end

					if v8.rankBoxStroke then
						v8.rankBoxStroke.Color = visible and Color3.fromRGB(30, 90, 150) or tbl7.AQUA_STROKE
						v8.rankBoxStroke.Thickness = 1
						v8.rankBoxStroke.Transparency = visible and 1 or 0.45
					end

					if v8.rank then
						v8.rank.ZIndex = 4
						v8.rank.TextColor3 = visible and Color3.fromRGB(240, 255, 240) or tbl7.TEXT
					end

					if v8.info then
						v8.info.ZIndex = 4
						v8.info.RichText = false

						if v8.petData then
							v8.info.Text = fn15(v8.petData)
						end

						v8.info.TextColor3 = visible and Color3.fromRGB(0, 0, 0) or tbl7.TEXT
					end

					if v8.mutation then
						v8.mutation.ZIndex = 4

						if v8.petData then
							local v9, v10 = fn16(v8.petData)
							v8.mutation.RichText = v10
							v8.mutation.Text = v9
							v8.mutation.Visible = v9 ~= ""
						end

						local mutation = v8.mutation
						local color = visible and Color3.fromRGB(0, 0, 0)

						if not color then
							color = fn14(v8.petData and v8.petData.mutation)
						end

						mutation.TextColor3 = color
					end

					if v8.rate then
						v8.rate.ZIndex = 4

						if v8.petData and v8.petData.mpsText then
							v8.rate.Text = v8.petData.mpsText
						end

						v8.rate.TextColor3 = visible and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(120, 230, 255)
					end
				end

				selectedPetData = selectedPetData and selectedPetData[n]
				tbl.SelectedPetData = selectedPetData

				if arg then
					if not stealNearest then
						if selectedPetData then
							textLabel.Text = string.format("%s - %s", selectedPetData.petName or "Unknown", selectedPetData.mpsText or "")
						else
							textLabel.Text = "Searching..."
						end
					end
				else
					textLabel.Text = "Disabled"

					if tween then
						tween:Cancel()
						tween = nil
					end

					v7.Size = UDim2.new(0, 0, 1, 0)
				end

				textLabel2.Text = string.format("%d%%", math.clamp(math.floor(v7.Size.X.Scale * 100 + 0.5), 0, 100))
				frame.Size = UDim2.new(1, 0, 0, math.max(0, uiListLayout.AbsoluteContentSize.Y))
				scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(0, uiListLayout.AbsoluteContentSize.Y) + 8)
			end

			uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				frame.Size = UDim2.new(1, 0, 0, math.max(0, uiListLayout.AbsoluteContentSize.Y))
				scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(0, uiListLayout.AbsoluteContentSize.Y) + 8)
			end)

			tbl.UpdateAutoStealUI = function()
				fn21(flag, fn18())
			end

			task.spawn(function()
				while frame2 and frame2.Parent do
					local n3 = math.clamp(math.floor(v7.Size.X.Scale * 100 + 0.5), 0, 100)
					textLabel2.Text = tostring(n3) .. "%"
					task.wait(0.05)
				end
			end)

			nearest.button.MouseButton1Click:Connect(function()
				stealNearest = not stealNearest

				if stealNearest then
					stealHighest = false
					stealPriority = false
					uid2 = nil
				end

				v2.StealNearest = stealNearest
				v2.StealHighest = stealHighest
				v2.StealPriority = stealPriority
				fn12()
				_G.NEAREST_INSTANT_MODE = stealNearest and instantSteal
				fn()
				tbl.ListNeedsRedraw = false
				fn21(flag, fn18())
			end)

			highest.button.MouseButton1Click:Connect(function()
				stealHighest = not stealHighest

				if stealHighest then
					stealNearest = false
					stealPriority = false
					uid2 = nil
				end

				v2.StealNearest = stealNearest
				v2.StealHighest = stealHighest
				v2.StealPriority = stealPriority
				fn12()
				_G.NEAREST_INSTANT_MODE = stealNearest and instantSteal
				fn()
				tbl.ListNeedsRedraw = false
				fn21(flag, fn18())
			end)

			priority.button.MouseButton1Click:Connect(function()
				stealPriority = not stealPriority

				if stealPriority then
					stealNearest = false
					stealHighest = false
					uid2 = nil
				end

				v2.StealNearest = stealNearest
				v2.StealHighest = stealHighest
				v2.StealPriority = stealPriority
				fn12()
				_G.NEAREST_INSTANT_MODE = stealNearest and instantSteal
				fn()
				tbl.ListNeedsRedraw = false
				fn21(flag, fn18())
			end)

			instantSteal2.button.MouseButton1Click:Connect(function()
				instantSteal = not instantSteal

				if instantSteal then
					flag2 = false
					flag3 = false
				else
					flag2 = false
					flag3 = false
				end

				v2.InstantSteal = instantSteal
				_G.NEAREST_INSTANT_MODE = stealNearest and instantSteal
				fn()
				tbl.ListNeedsRedraw = false
				fn21(flag, fn18())
			end)

			task.spawn(function()
				while true do
					task.wait(1.5)

					if instantSteal then
						instantSteal = false
						flag2 = false
						flag3 = false
						v2.InstantSteal = false
						_G.NEAREST_INSTANT_MODE = false
						task.wait(0.05)
						instantSteal = true
						v2.InstantSteal = true
						_G.NEAREST_INSTANT_MODE = stealNearest and true
					end
				end
			end)

			local function fn22(arg)
				if not arg then
					return nil
				end
				local v8 = tbl5[arg.uid]
				if v8 and v8.Parent then
					return v8
				end
				local v9 = workspace_.Plots:FindFirstChild(arg.plot)
				if not v9 then
					return nil
				end
				local animalPodiums = v9:FindFirstChild("AnimalPodiums")
				if not animalPodiums then
					return nil
				end
				local animalList = fn9(v9.Name)
				animalList = animalList and animalList.AnimalList

				if not animalList then
					local v10 = animalPodiums:FindFirstChild(arg.slot)

					if v10 then
						local base = v10:FindFirstChild("Base")
						local spawn = base and base:FindFirstChild("Spawn")

						if spawn then
							local promptAttachment = spawn:FindFirstChild("PromptAttachment")

							if promptAttachment then
								for _, child in ipairs(promptAttachment:GetChildren()) do
									if child:IsA("ProximityPrompt") then
										tbl5[arg.uid] = child
										return child
									end
								end
							end
						end
					end

					return nil
				end

				local str = arg.name and arg.name:lower() or ""
				local slot = arg.slot
				local v10 = nil

				for k, v11 in pairs(animalList) do
					if type(v11) == "table" and tostring(k) == slot then
						local index = v11.Index
						local flag4 = Animals[v11.Index]

						if flag4 then
							flag4 = (flag4.DisplayName or index):lower() == str
						end

						if flag4 then
							v10 = animalPodiums:FindFirstChild(tostring(k))
							break
						else
							v10 = nil
						end
					else
						v10 = nil
					end
				end

				v10 = v10 or animalPodiums:FindFirstChild(arg.slot)

				if v10 then
					local base = v10:FindFirstChild("Base")
					base = base and base:FindFirstChild("Spawn")

					if base then
						local promptAttachment = base:FindFirstChild("PromptAttachment")

						if promptAttachment then
							for _, child in ipairs(promptAttachment:GetChildren()) do
								if child:IsA("ProximityPrompt") and child.Enabled and child.ActionText == "Steal" then
									tbl5[arg.uid] = child
									return child
								end
							end
						end

						local position = base.Position
						local x = position.X
						local z = position.Z
						local huge = math.huge
						local v11 = nil

						for _, descendant in pairs(v9:GetDescendants()) do
							if descendant:IsA("ProximityPrompt") and descendant.Enabled and descendant.ActionText == "Steal" then
								local parent = descendant.Parent
								local position2

								if parent and parent:IsA("BasePart") then
									position2 = parent.Position
								else
									local isBasePart = parent and parent:IsA("Attachment") and parent.Parent and parent.Parent:IsA("BasePart")
									position2 = nil

									if isBasePart then
										position2 = parent.Parent.Position
									end
								end

								if position2 then
									local y = position.Y

									if str:find("la secret combinasion") then
										y = position.Y - 5
									end

									if math.sqrt((position2.X - x) ^ 2 + (position2.Z - z) ^ 2) < 5 and position2.Y > y then
										local n3 = position2.Y - y

										if n3 < huge then
											huge = n3
											v11 = descendant
										end
									end
								end
							end
						end

						if v11 then
							tbl5[arg.uid] = v11
							return v11
						end
					end
				end

				return nil
			end

			local function fn23(arg)
				if tbl4[arg] then
					return
				end
				local tbl9 = { holdCallbacks = {}, triggerCallbacks = {}, holdEndCallbacks = {}, ready = true }
				local ok, result = pcall(getconnections, arg.PromptButtonHoldBegan)

				if ok and type(result) == "table" then
					for _, v8 in ipairs(result) do
						if type(v8.Function) == "function" then
							table.insert(tbl9.holdCallbacks, v8.Function)
						end
					end
				end

				local ok2, result2 = pcall(getconnections, arg.Triggered)

				if ok2 and type(result2) == "table" then
					for _, v8 in ipairs(result2) do
						if type(v8.Function) == "function" then
							table.insert(tbl9.triggerCallbacks, v8.Function)
						end
					end
				end

				local ok3, result3 = pcall(getconnections, arg.PromptButtonHoldEnded)

				if ok3 and type(result3) == "table" then
					for _, v8 in ipairs(result3) do
						if type(v8.Function) == "function" then
							table.insert(tbl9.holdEndCallbacks, v8.Function)
						end
					end
				end

				if #tbl9.holdCallbacks > 0 or #tbl9.triggerCallbacks > 0 or #tbl9.holdEndCallbacks > 0 then
					tbl4[arg] = tbl9
				end
			end

			local function fn24(arg)
				for _, v8 in ipairs(arg) do
					task.spawn(v8)
				end
			end

			local function fn25(arg)
				local v8 = fn9(arg)
				if v8 then
					return fn8(v8.Owner)
				end
				return false
			end

			local function fn26()
				local humanoidRootPart = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")
				if not humanoidRootPart then
					return nil, math.huge, nil
				end
				local plots = workspace:FindFirstChild("Plots")
				if not plots then
					return nil, math.huge, nil
				end
				local huge = math.huge
				local v8 = nil
				local name = nil

				for _, child in ipairs(plots:GetChildren()) do
					if not fn25(child.Name) then
						local huge2 = math.huge

						pcall(function()
							local position = humanoidRootPart.Position
							huge2 = (child:GetPivot().Position - position).Magnitude
						end)

						if huge2 > 100 then
						else
							local animalPodiums = child:FindFirstChild("AnimalPodiums")

							if not animalPodiums then
							else
								for _, child2 in ipairs(animalPodiums:GetChildren()) do
									local base = child2:FindFirstChild("Base")
									base = base and base:FindFirstChild("Spawn")

									if base then
										local magnitude = (base.Position - humanoidRootPart.Position).Magnitude

										if not (magnitude > 60 or magnitude >= huge) then
											local promptAttachment = base:FindFirstChild("PromptAttachment")

											if promptAttachment then
												local proximityPrompt = promptAttachment:FindFirstChildOfClass("ProximityPrompt")

												if proximityPrompt and proximityPrompt.Parent and proximityPrompt.Enabled then
													name = child2.Name
													huge = magnitude
													v8 = proximityPrompt
												end
											end
										end
									end
								end
							end
						end
					end
				end

				return v8, huge, name
			end

			local function fn27(arg, arg2)
				local v8 = tbl4[arg]
				if not v8 or not v8.ready then
					return false
				end
				v8.ready = false

				task.spawn(function()
					if v6 ~= arg2 then
						if tween then
							tween:Cancel()
						end

						v7.Size = UDim2.new(0, 0, 1, 0)
						v6 = arg2
					end

					if #v8.holdCallbacks > 0 then
						fn24(v8.holdCallbacks)
					end

					v7.Size = UDim2.new(0, 0, 1, 0)
					v7.BackgroundTransparency = 0
					tween = tweenService:Create(v7, TweenInfo.new(1.2, Enum.EasingStyle.Linear), { Size = UDim2.new(1, 0, 1, 0) })
					tween:Play()
					tween.Completed:Wait()

					if v6 == arg2 and #v8.triggerCallbacks > 0 then
						fn24(v8.triggerCallbacks)
					end

					v8.ready = true
				end)

				return true
			end

			local function fn28(arg, arg2)
				if not arg or not arg.Parent then
					return false
				end
				fn23(arg)
				if not tbl4[arg] then
					return false
				end

				if v6 ~= arg2 then
					if tween then
						tween:Cancel()
						tween = nil
					end

					v7.Size = UDim2.new(0, 0, 1, 0)
				end

				return fn27(arg, arg2)
			end

			local function fn29()
				for _, v8 in pairs(tbl5) do
					if v8 and v8.Parent then
						fn23(v8)
					end
				end
			end

			task.spawn(function()
				while task.wait(2) do
					if flag then
						fn29()
					end
				end
			end)

			local tbl9 = {}

			local function fn30(arg)
				if not arg then
					return ""
				end
				local str = ""

				for k, v8 in pairs(arg) do
					if type(v8) == "table" then
						str ..= tostring(k) .. tostring(v8.Index) .. tostring(v8.Mutation)
					end
				end

				return str
			end

			local function fn31(arg)
				local flag4 = false

				pcall(function()
					local v8 = fn9(arg.Name)
					if not v8 then
						return
					end
					local animalList = v8.AnimalList
					local owner = v8.Owner

					if not owner or fn8(owner) or typeof(owner) == "Instance" and not players:FindFirstChild(owner.Name) or type(owner) == "string" and not players:FindFirstChild(owner) then
						tbl9[arg.Name] = nil

						for i = #allAnimalsCache, 1, -1 do
							if allAnimalsCache[i].plot == arg.Name then
								table.remove(allAnimalsCache, i)
								flag4 = true
							end
						end

						return
					end

					if not animalList then
						tbl9[arg.Name] = nil

						for i = #allAnimalsCache, 1, -1 do
							if allAnimalsCache[i].plot == arg.Name then
								table.remove(allAnimalsCache, i)
								flag4 = true
							end
						end

						return
					end

					local name = typeof(owner) == "Instance" and owner.Name or tostring(owner)
					local v9 = fn30(animalList, name)
					if tbl9[arg.Name] == v9 then
						return
					end

					for i = #allAnimalsCache, 1, -1 do
						if allAnimalsCache[i].plot == arg.Name then
							table.remove(allAnimalsCache, i)
						end
					end

					for k, v10 in pairs(animalList) do
						if type(v10) == "table" then
							local index = v10.Index
							local v11 = Animals[v10.Index]

							if v11 then
								local mutation = v10.Mutation or "None"

								if mutation == "Yin Yang" then
									mutation = "YinYang"
								end

								local str = v10.Traits and #v10.Traits > 0 and table.concat(v10.Traits, ", ") or "None"
								local v12 = fn11(index, v10.Mutation, v10.Traits)

								table.insert(allAnimalsCache, {
									name = v11.DisplayName or index,
									genText = "$" .. fn10(v12) .. "/s",
									genValue = v12,
									mutation = mutation,
									traits = str,
									owner = name,
									plot = arg.Name,
									slot = tostring(k),
									uid = arg.Name .. "_" .. tostring(k),
								})
							end
						end
					end

					tbl9[arg.Name] = v9
					flag4 = true
				end)

				if flag4 then
					table.sort(allAnimalsCache, function(arg2, arg3)
						return arg2.genValue > arg3.genValue
					end)

					tbl.AllAnimalsCache = allAnimalsCache
					tbl.ListNeedsRedraw = true

					if tbl.UpdateAutoStealUI then
						tbl.UpdateAutoStealUI()
					end
				end
			end

			local function fn32(arg)
				local v8 = nil
				local n3 = 0

				while not v8 and n3 < 40 do
					v8 = fn9(arg.Name)

					if not v8 then
						n3 += 1
						task.wait(0.07)
					end
				end

				if not v8 then
					return
				end
				fn31(arg)

				local function fn33(arg2)
					if not arg2 then
						return
					end

					arg2.ChildAdded:Connect(function()
						task.wait(0.15)
						fn31(arg)
					end)

					arg2.ChildRemoved:Connect(function()
						for i = #allAnimalsCache, 1, -1 do
							if allAnimalsCache[i].plot == arg.Name then
								table.remove(allAnimalsCache, i)
							end
						end

						tbl9[arg.Name] = nil
						_getPetsCache = nil

						for k in pairs(tbl5) do
							local name = arg.Name

							if k:sub(1, #arg.Name) == name then
								tbl5[k] = nil
							end
						end

						tbl.ListNeedsRedraw = true

						if tbl.UpdateAutoStealUI then
							tbl.UpdateAutoStealUI()
						end

						task.wait(0.15)
						fn31(arg)
					end)
				end

				local animalPodiums = arg:FindFirstChild("AnimalPodiums")
				fn33(animalPodiums)

				arg.ChildAdded:Connect(function(child)
					if child.Name == "AnimalPodiums" then
						fn33(child)
						fn31(arg)
					end
				end)

				arg.ChildRemoved:Connect(function(child)
					if child.Name == "AnimalPodiums" then
						for i = #allAnimalsCache, 1, -1 do
							if allAnimalsCache[i].plot == arg.Name then
								table.remove(allAnimalsCache, i)
							end
						end

						tbl9[arg.Name] = nil
						_getPetsCache = nil
						tbl.ListNeedsRedraw = true

						if tbl.UpdateAutoStealUI then
							tbl.UpdateAutoStealUI()
						end
					end
				end)

				task.spawn(function()
					while arg.Parent do
						task.wait(10)
						fn31(arg)
					end
				end)
			end

			local plots = workspace_:WaitForChild("Plots", 8)

			if plots then
				for _, child in ipairs(plots:GetChildren()) do
					fn32(child)
				end

				plots.ChildAdded:Connect(function(child)
					task.wait(0.5)
					fn32(child)
				end)

				plots.ChildRemoved:Connect(function(child)
					tbl9[child.Name] = nil
					_getPetsCache = nil

					for i = #allAnimalsCache, 1, -1 do
						if allAnimalsCache[i].plot == child.Name then
							table.remove(allAnimalsCache, i)
						end
					end

					for k in pairs(tbl5) do
						local name = child.Name

						if k:sub(1, #child.Name) == name then
							tbl5[k] = nil
						end
					end

					tbl.ListNeedsRedraw = true

					if tbl.UpdateAutoStealUI then
						tbl.UpdateAutoStealUI()
					end
				end)
			end

			local function fn33(arg)
				if #arg == 0 then
					return
				end

				if uid2 then
					for i, v8 in ipairs(arg) do
						if v8.uid == uid2 then
							if n ~= i then
								n = i
								uid = v8.uid
							end

							textLabel.Text = string.format("%s - %s", v8.petName or "Unknown", v8.mpsText or "")
							return
						end
					end

					uid2 = nil
				end

				if stealPriority then
					for _, v8 in ipairs(tbl3) do
						local str = v8:lower()

						for i, v9 in ipairs(arg) do
							if v9.petName and v9.petName:lower() == str then
								if n ~= i then
									n = i
									uid = v9.uid
								end

								return
							end
						end
					end

					if n ~= 1 then
						n = 1
						uid = arg[1] and arg[1].uid
					end
				elseif stealNearest then
					local character = localPlayer2.Character
					character = character and character:FindFirstChild("HumanoidRootPart")

					if character then
						local v8, v9, v10 = ipairs(arg)
						local huge = math.huge
						local n3 = 1

						for k, v11 in v8, v9, v10 do
							local animalData = v11.animalData and stickyFindAdornee(v11.animalData)

							if animalData and animalData:IsA("BasePart") then
								local magnitude = (character.Position - animalData.Position).Magnitude

								if magnitude < huge then
									huge = magnitude
									n3 = k
								end
							end
						end

						if arg[n3] then
							local v11 = arg[n3]
							textLabel.Text = string.format("%s - %s", v11.petName or "Unknown", v11.mpsText or "")
						end

						if not instantSteal and n ~= n3 then
							n = n3
							uid = arg[n3] and arg[n3].uid
						end
					end
				elseif stealHighest then
					if n ~= 1 then
						n = 1
						uid = arg[1] and arg[1].uid
					end
				end
			end

			runService.Heartbeat:Connect(function()
				if not flag then
					return
				end
				fn33(fn18())
			end)

			task.spawn(function()
				while true do
					task.wait(0.5)

					if flag then
						local v8 = fn18()
						if not (#v8 > 0) then
							continue
						end
						tbl.ListNeedsRedraw = false
						fn21(flag, v8)
					end
				end
			end)

			runService.Heartbeat:Connect(function()
				if not flag then
					return
				end

				if instantSteal then
					if tween then
						tween:Cancel()
						tween = nil
					end

					v7.Size = UDim2.new(1, 0, 1, 0)
					v7.BackgroundTransparency = 0

					if not flag3 then
						flag3 = true

						task.spawn(function()
							if not game:IsLoaded() then
								game.Loaded:Wait()
							end

							task.wait(0.5)
							flag2 = true
						end)
					end

					if flag2 then
						if stealNearest and not uid2 then
							local v8, v9 = fn26()

							if v8 then
							end
						else
							local v8 = fn18()

							if #v8 > 0 then
								if #v8 < n then
									n = #v8
								end

								if n < 1 then
									n = 1
								end

								local v9 = v8[n]

								if v9 and not fn13(v9.animalData) then
									local v10 = tbl5[v9.uid]

									if not v10 or not v10.Parent then
										fn22(v9.animalData)
									end
								end
							end
						end
					end

					return
				end

				local v8 = fn18()
				if #v8 == 0 then
					return
				end

				if n > #v8 then
					n = #v8
				end

				if n < 1 then
					n = 1
				end

				local v9 = v8[n]
				if not v9 or fn13(v9.animalData) then
					return
				end
				local v10 = tbl5[v9.uid]

				if not v10 or not v10.Parent then
					v10 = fn22(v9.animalData)
				end

				if v10 then
					fn28(v10, v9.uid)
				end
			end)

			task.spawn(function()
				while task.wait(0.5) do
					fn21(flag, fn18())
				end
			end)

			task.spawn(function()
				task.wait(1)
				tbl.ListNeedsRedraw = true
				fn21(flag, fn18())
			end)
		end

		task.spawn(function()
			while true do
				tbl.AllAnimalsCache = allAnimalsCache
				task.wait(0.5)
			end
		end)
	end)
end

local UserInputService, color, color2, color3, color4, color5, color6, color7, color8, color9
local color10, color11, color12, str, fn4, fn5, v6, visible, visible2, revealed
local fn6, frame, textLabel, textLabel2, textButton, textButton2

do
	local Players2 = game:GetService("Players")
	UserInputService = game:GetService("UserInputService")
	local HttpService = game:GetService("HttpService")
	local localPlayer3 = Players2.LocalPlayer
	local jobIdGui = localPlayer3:FindFirstChild("JobIdGui")

	if jobIdGui then
		jobIdGui:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "JobIdGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = localPlayer3:WaitForChild("PlayerGui")
	color = Color3.fromRGB(46, 204, 113)
	color2 = Color3.fromRGB(245, 255, 250)
	local color13 = Color3.fromRGB(10, 22, 46)
	local color14 = Color3.fromRGB(70, 140, 220)
	local color15 = Color3.fromRGB(55, 105, 175)
	color3 = Color3.fromRGB(15, 32, 62)
	color4 = Color3.fromRGB(150, 210, 255)
	color5 = Color3.fromRGB(30, 90, 180)
	color6 = Color3.fromRGB(220, 240, 255)
	color7 = Color3.fromRGB(46, 204, 113)
	color8 = Color3.fromRGB(245, 255, 250)
	color9 = Color3.fromRGB(255, 255, 255)
	color10 = Color3.fromRGB(35, 60, 100)
	color11 = Color3.fromRGB(200, 220, 245)
	color12 = Color3.fromRGB(255, 255, 255)
	local color16 = Color3.fromRGB(245, 250, 255)
	str = string.rep(". ", 30)

	fn4 = function(arg)
		arg.AutoButtonColor = false
		arg.Selectable = false
		arg.SelectionImageObject = nil
		arg.TextStrokeTransparency = 1
		arg.Active = false
	end

	local flag = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"

	if flag and type(makefolder) == "function" and type(isfolder) == "function" then
		if not isfolder("JobIdGui") then
			pcall(makefolder, "JobIdGui")
		end
	end

	local function fn7()
		if not flag then
			return {}
		end

		if not isfile("JobIdGui/config.json") then
			return {}
		end

		local ok, result = pcall(function()
			return HttpService:JSONDecode(readfile("JobIdGui/config.json"))
		end)

		if ok and type(result) == "table" then
			return result
		end
		return {}
	end

	fn5 = function(arg)
		if not flag then
			return
		end

		pcall(function()
			writefile("JobIdGui/config.json", HttpService:JSONEncode(arg))
		end)
	end

	v6 = fn7()
	visible = v6.namesVisible ~= false
	visible2 = v6.numbersVisible == true
	revealed = v6.revealed ~= false
	local tbl2 = {}

	local function fn8(arg, arg2)
		local character = arg.Character
		if not character then
			return
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.DisplayDistanceType = arg2 and Enum.HumanoidDisplayDistanceType.Viewer or Enum.HumanoidDisplayDistanceType.None
		end
	end

	local function fn9(arg)
		if tbl2[arg] then
			tbl2[arg]:Destroy()
			tbl2[arg] = nil
		end

		local character = arg.Character
		if not character then
			return
		end
		local head = character:FindFirstChild("Head")
		if not head then
			return
		end
		fn8(arg, visible)
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Name = "JobIdTag"
		billboardGui.Size = UDim2.new(0, 140, 0, 44)
		billboardGui.StudsOffset = Vector3.new(0, 2.4, 0)
		billboardGui.AlwaysOnTop = true
		billboardGui.Adornee = head
		billboardGui.Parent = head
		local textLabel3 = Instance.new("TextLabel")
		textLabel3.Name = "NameLabel"
		textLabel3.Size = UDim2.new(1, 0, 0, 20)
		textLabel3.BackgroundTransparency = 1
		textLabel3.Text = arg.DisplayName
		textLabel3.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel3.TextStrokeTransparency = 0.3
		textLabel3.TextScaled = true
		textLabel3.Font = Enum.Font.GothamBold
		textLabel3.Visible = visible
		textLabel3.Parent = billboardGui
		local textLabel4 = Instance.new("TextLabel")
		textLabel4.Name = "NumLabel"
		textLabel4.Size = UDim2.new(1, 0, 0, 18)
		textLabel4.Position = UDim2.new(0, 0, 0, 21)
		textLabel4.BackgroundTransparency = 1
		textLabel4.Text = "#" .. tostring(arg.UserId)
		textLabel4.TextColor3 = color
		textLabel4.TextStrokeTransparency = 0.3
		textLabel4.TextScaled = true
		textLabel4.Font = Enum.Font.GothamBlack
		textLabel4.Visible = visible2
		textLabel4.Parent = billboardGui
		tbl2[arg] = billboardGui
	end

	fn6 = function()
		for k, v7 in pairs(tbl2) do
			if v7 and v7.Parent then
				local nameLabel = v7:FindFirstChild("NameLabel")
				local numLabel = v7:FindFirstChild("NumLabel")

				if nameLabel then
					nameLabel.Visible = visible
				end

				if numLabel then
					numLabel.Visible = visible2
				end
			end

			fn8(k, visible)
		end

		fn8(localPlayer3, visible)
	end

	local function fn10(player)
		if player == localPlayer3 then
			return
		end

		player.CharacterAdded:Connect(function()
			task.wait(0.5)
			fn9(player)
		end)

		if player.Character then
			fn9(player)
		end
	end

	for _, player in ipairs(Players2:GetPlayers()) do
		fn10(player)
	end

	Players2.PlayerAdded:Connect(fn10)

	Players2.PlayerRemoving:Connect(function(player)
		if tbl2[player] then
			tbl2[player]:Destroy()
			tbl2[player] = nil
		end
	end)

	frame = Instance.new("Frame")
	frame.Name = "MainPanel"
	frame.Size = UDim2.new(0, 240, 0, 104)
	frame.Position = UDim2.new(0, 650, 0, 10)
	frame.BackgroundColor3 = color13
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.ZIndex = 10
	frame.Parent = screenGui
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 10)
	uiCorner.Parent = frame
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color14
	uiStroke.Thickness = 1.3
	uiStroke.Transparency = 0.1
	uiStroke.Parent = frame
	textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 0, 14)
	textLabel.Position = UDim2.new(0, 0, 0, 4)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "SERVER JOB ID"
	textLabel.TextColor3 = color16
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.TextStrokeTransparency = 1
	textLabel.ZIndex = 11
	textLabel.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.Size = UDim2.new(0.42, 0, 0, 1)
	frame2.Position = UDim2.new(0.29, 0, 0, 20)
	frame2.BackgroundColor3 = Color3.fromRGB(160, 210, 250)
	frame2.BorderSizePixel = 0
	frame2.ZIndex = 11
	frame2.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.Size = UDim2.new(0.92, 0, 0, 44)
	frame3.Position = UDim2.new(0.04, 0, 0, 26)
	frame3.BackgroundColor3 = Color3.fromRGB(12, 26, 52)
	frame3.BackgroundTransparency = 0.35
	frame3.BorderSizePixel = 0
	frame3.ZIndex = 11
	frame3.Parent = frame
	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(0, 8)
	uiCorner2.Parent = frame3
	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.Color = color15
	uiStroke2.Thickness = 1
	uiStroke2.Transparency = 0.15
	uiStroke2.Parent = frame3
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 4)
	uiPadding.PaddingBottom = UDim.new(0, 4)
	uiPadding.PaddingLeft = UDim.new(0, 4)
	uiPadding.PaddingRight = UDim.new(0, 4)
	uiPadding.Parent = frame3
	textLabel2 = Instance.new("TextLabel")
	textLabel2.Size = UDim2.new(1, 0, 0, 15)
	textLabel2.Position = UDim2.new(0, 0, 0, 0)
	textLabel2.BackgroundColor3 = color3
	textLabel2.TextColor3 = color4
	textLabel2.Text = game.JobId ~= "" and game.JobId or str
	textLabel2.TextScaled = true
	textLabel2.Font = Enum.Font.Code
	textLabel2.TextStrokeTransparency = 1
	textLabel2.ZIndex = 12
	textLabel2.Parent = frame3
	local uiCorner3 = Instance.new("UICorner")
	uiCorner3.CornerRadius = UDim.new(0, 4)
	uiCorner3.Parent = textLabel2
	textButton = Instance.new("TextButton")
	textButton.Size = UDim2.new(0.48, 0, 0, 17)
	textButton.Position = UDim2.new(0, 0, 0, 19)
	textButton.BackgroundColor3 = color5
	textButton.TextColor3 = color6
	textButton.Text = "COPY"
	textButton.TextSize = 10
	textButton.TextScaled = false
	textButton.Font = Enum.Font.GothamBlack
	textButton.ZIndex = 12
	textButton.Parent = frame3
	fn4(textButton)
	local uiCorner4 = Instance.new("UICorner")
	uiCorner4.CornerRadius = UDim.new(0, 4)
	uiCorner4.Parent = textButton
	textButton2 = Instance.new("TextButton")
	textButton2.Size = UDim2.new(0.48, 0, 0, 17)
	textButton2.Position = UDim2.new(0.52, 0, 0, 19)
	textButton2.BackgroundColor3 = color
	textButton2.TextColor3 = color2
	textButton2.Text = "SHOW"
	textButton2.TextSize = 10
	textButton2.TextScaled = false
	textButton2.Font = Enum.Font.GothamBlack
	textButton2.ZIndex = 12
	textButton2.Parent = frame3
end

fn4(textButton2)
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 4)
uiCorner.Parent = textButton2

do
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = UDim2.new(0, 10, 0, 10)
	imageLabel.Position = UDim2.new(0, 4, 0.5, -5)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://3926305904"
	imageLabel.ImageRectOffset = Vector2.new(724, 364)
	imageLabel.ImageRectSize = Vector2.new(36, 36)
	imageLabel.ImageColor3 = color2
	imageLabel.ZIndex = 13
	imageLabel.Parent = textButton2
	local textButton3 = Instance.new("TextButton")
	textButton3.Size = UDim2.new(0.45, 0, 0, 13)
	textButton3.Position = UDim2.new(0.04, 0, 0, 78)
	textButton3.TextSize = 9
	textButton3.TextScaled = false
	textButton3.Font = Enum.Font.GothamBlack
	textButton3.TextXAlignment = Enum.TextXAlignment.Center
	textButton3.ZIndex = 12
	textButton3.Parent = frame
	fn4(textButton3)
	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(1, 0)
	uiCorner2.Parent = textButton3
	local frame2 = Instance.new("Frame")
	frame2.Size = UDim2.new(0, 4, 0, 4)
	frame2.Position = UDim2.new(0, 5, 0.5, -2)
	frame2.BorderSizePixel = 0
	frame2.ZIndex = 13
	frame2.Parent = textButton3
	local uiCorner3 = Instance.new("UICorner")
	uiCorner3.CornerRadius = UDim.new(1, 0)
	uiCorner3.Parent = frame2
	local textButton4 = Instance.new("TextButton")
	textButton4.Size = UDim2.new(0.45, 0, 0, 13)
	textButton4.Position = UDim2.new(0.51, 0, 0, 78)
	textButton4.TextSize = 9
	textButton4.TextScaled = false
	textButton4.Font = Enum.Font.GothamBlack
	textButton4.TextXAlignment = Enum.TextXAlignment.Center
	textButton4.ZIndex = 12
	textButton4.Parent = frame
	fn4(textButton4)
	local uiCorner4 = Instance.new("UICorner")
	uiCorner4.CornerRadius = UDim.new(1, 0)
	uiCorner4.Parent = textButton4
	local frame3 = Instance.new("Frame")
	frame3.Size = UDim2.new(0, 4, 0, 4)
	frame3.Position = UDim2.new(0, 5, 0.5, -2)
	frame3.BorderSizePixel = 0
	frame3.ZIndex = 13
	frame3.Parent = textButton4
	local uiCorner5 = Instance.new("UICorner")
	uiCorner5.CornerRadius = UDim.new(1, 0)
	uiCorner5.Parent = frame3

	local function fn7()
		if visible then
			textButton3.Text = "HIDE NAMES ON"
			textButton3.BackgroundColor3 = color7
			textButton3.TextColor3 = color8
			frame2.BackgroundColor3 = color9
		else
			textButton3.Text = "HIDE NAMES OFF"
			textButton3.BackgroundColor3 = color10
			textButton3.TextColor3 = color11
			frame2.BackgroundColor3 = color12
		end
	end

	local function fn8()
		if visible2 then
			textButton4.Text = "SHOW # ON"
			textButton4.BackgroundColor3 = color7
			textButton4.TextColor3 = color8
			frame3.BackgroundColor3 = color9
		else
			textButton4.Text = "SHOW # OFF"
			textButton4.BackgroundColor3 = color10
			textButton4.TextColor3 = color11
			frame3.BackgroundColor3 = color12
		end
	end

	local function fn9()
		textLabel2.Text = revealed and (game.JobId ~= "" and game.JobId or str) or str
		textButton2.Text = revealed and "SHOW" or "HIDE"
		imageLabel.ImageRectOffset = revealed and Vector2.new(724, 364) or Vector2.new(760, 364)
	end

	fn7()
	fn8()
	fn9()
	fn6()
	local flag = nil
	local position = nil
	local position2 = nil

	local function fn10(arg)
		flag = true
		position = arg.Position
		position2 = frame.Position

		arg.Changed:Connect(function()
			if arg.UserInputState == Enum.UserInputState.End then
				flag = false
			end
		end)
	end

	for _, v7 in ipairs({ textLabel, frame }) do
		v7.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				fn10(input)
			end
		end)
	end

	UserInputService.InputChanged:Connect(function(input)
		if flag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local n = input.Position - position
			frame.Position = UDim2.new(position2.X.Scale, position2.X.Offset + n.X, position2.Y.Scale, position2.Y.Offset + n.Y)
		end
	end)

	textButton.MouseButton1Click:Connect(function()
		local jobId = game.JobId

		if setclipboard then
			setclipboard(jobId)
		elseif toclipboard then
			toclipboard(jobId)
		end

		print("Job ID: " .. jobId)
		textButton.Text = "COPIED"
		task.wait(1.1)
		textButton.Text = "COPY"
	end)

	textButton2.MouseButton1Click:Connect(function()
		revealed = not revealed
		fn9()
		v6.revealed = revealed
		fn5(v6)
	end)

	textButton3.MouseButton1Click:Connect(function()
		visible = not visible
		fn7()
		fn6()
		v6.namesVisible = visible
		fn5(v6)
	end)

	textButton4.MouseButton1Click:Connect(function()
		visible2 = not visible2
		fn8()
		fn6()
		v6.numbersVisible = visible2
		fn5(v6)
	end)
end
