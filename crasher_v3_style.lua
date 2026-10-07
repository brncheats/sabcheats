local Player = game.Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

local isActive = false
local crashThread = nil
local collapsed = false

-- Thème (identique au Redeemer)
local T = {
	bg = Color3.fromRGB(10, 8, 20),
	panel = Color3.fromRGB(30, 24, 60),
	accent = Color3.fromRGB(118, 72, 236),
	accent2 = Color3.fromRGB(84, 40, 190),
	pink = Color3.fromRGB(176, 54, 180),
	text = Color3.fromRGB(238, 238, 252),
	dim = Color3.fromRGB(160, 140, 200),
}

local function mk(className, props, parent)
	local inst = Instance.new(className)
	for k, v in pairs(props or {}) do inst[k] = v end
	inst.Parent = parent
	return inst
end

local function corner(inst, rad)
	mk("UICorner", { CornerRadius = UDim.new(0, rad) }, inst)
end

local function stroke(inst, color, size)
	return mk("UIStroke", { Color = color, Thickness = size, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, inst)
end

----------------------------------------------------------------------
-- GUI (petit format, draggable, réductible)
----------------------------------------------------------------------
local gui = mk("ScreenGui", {
	Name = "BRN782K_Crasher",
	ResetOnSpawn = false,
	DisplayOrder = 999,
}, (typeof(gethui) == "function" and gethui()) or playerGui)

local WIDTH, HEAD_H, FULL_H = 200, 30, 95

local main = mk("Frame", {
	Size = UDim2.fromOffset(WIDTH, FULL_H),
	Position = UDim2.new(0.5, -WIDTH / 2, 0, 50),
	BackgroundColor3 = T.bg,
	BorderSizePixel = 0,
	ClipsDescendants = true,
}, gui)
corner(main, 10)

-- Gradient border animé (comme le Redeemer)
do
	local rim = stroke(main, T.accent, 1.4)
	local g = mk("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, T.accent),
			ColorSequenceKeypoint.new(0.5, T.pink),
			ColorSequenceKeypoint.new(1, T.accent),
		}),
	}, rim)
	TweenService:Create(g, TweenInfo.new(6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), { Rotation = 360 }):Play()
end

-- Fond galaxie (mini version)
do
	local function nebula(px, py, size, color, base)
		local f = mk("Frame", {
			Position = UDim2.new(px, -size / 2, py, -size / 2),
			Size = UDim2.fromOffset(size, size),
			BackgroundColor3 = color,
			BackgroundTransparency = base,
			BorderSizePixel = 0,
		}, main)
		corner(f, size / 2)
	end
	nebula(0.85, 0.1, 110, Color3.fromRGB(112, 50, 224), 0.93)
	nebula(0.1, 0.9, 100, Color3.fromRGB(176, 54, 180), 0.94)

	local rng = Random.new(782)
	for i = 1, 35 do
		local st = mk("Frame", {
			Position = UDim2.new(rng:NextNumber(), 0, rng:NextNumber(), 0),
			Size = UDim2.fromOffset(1, 1),
			BackgroundColor3 = Color3.fromRGB(238, 238, 252),
			BackgroundTransparency = rng:NextNumber(0.3, 0.85),
			BorderSizePixel = 0,
		}, main)
		if i % 6 == 0 then
			TweenService:Create(st, TweenInfo.new(rng:NextNumber(1.4, 3), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { BackgroundTransparency = 0.95 }):Play()
		end
	end
end

-- Header (draggable)
local bar = mk("Frame", {
	Size = UDim2.new(1, 0, 0, HEAD_H),
	BackgroundColor3 = T.panel,
	BackgroundTransparency = 0.25,
	BorderSizePixel = 0,
}, main)
corner(bar, 10)

local title = mk("TextLabel", {
	Position = UDim2.fromOffset(8, 0),
	Size = UDim2.fromOffset(100, HEAD_H),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBlack,
	TextSize = 13,
	TextColor3 = T.text,
	Text = "Crasher by brn782k",
	TextXAlignment = Enum.TextXAlignment.Left,
}, bar)

local minBtn = mk("TextButton", {
	Position = UDim2.new(1, -52, 0, 0),
	Size = UDim2.fromOffset(24, HEAD_H),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	TextColor3 = T.dim,
	Text = "−",
	AutoButtonColor = false,
}, bar)

local closeBtn = mk("TextButton", {
	Position = UDim2.new(1, -28, 0, 0),
	Size = UDim2.fromOffset(28, HEAD_H),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	TextSize = 15,
	TextColor3 = T.dim,
	Text = "✕",
	AutoButtonColor = false,
}, bar)

-- Contenu
local content = mk("Frame", {
	Position = UDim2.fromOffset(0, HEAD_H),
	Size = UDim2.new(1, 0, 1, -HEAD_H),
	BackgroundTransparency = 1,
}, main)

local statusText = mk("TextLabel", {
	Position = UDim2.fromOffset(8, 4),
	Size = UDim2.new(1, -16, 0, 14),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextColor3 = T.dim,
	Text = "OFF",
	TextXAlignment = Enum.TextXAlignment.Left,
}, content)

local toggleBtn = mk("TextButton", {
	Position = UDim2.fromOffset(8, 20),
	Size = UDim2.new(1, -16, 0, 38),
	BackgroundColor3 = T.accent2,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBlack,
	TextSize = 15,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Text = "CRASH",
	AutoButtonColor = false,
}, content)
corner(toggleBtn, 8)
stroke(toggleBtn, T.accent, 1)

----------------------------------------------------------------------
-- TON CODE, COLLÉ TEL QUEL (juste dans un thread pour pouvoir le stop)
----------------------------------------------------------------------
local function runCrash()
	local LightingService = game:GetService("Lighting");
	local LPlayer = game.Players.LocalPlayer;
	local Character = LPlayer.Character;

	local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid");
	local Valid = Character and Character:QueryDescendants("BasePart") or {};

	task.spawn(function()
		while Character and Character.Parent do
			for Index, Current in Valid do
				sethiddenproperty(Current, "PhysicsRepRootPart", Valid[Index + 1] or Valid[1]);
			end;
			task.wait();
		end;
	end);

	task.wait(0.1);

	for Iteration = 1, 5 do
		replicatesignal(Humanoid.ServerBreakJoints);
		replicatesignal(Humanoid.ServerResetCharacter);
	end;

	task.wait(0.1);

	for Iteration = 1, 5e10 do
		if not isActive then break end -- SEUL ajout : permet d'arrêter la boucle
		replicatesignal(Humanoid.ServerBreakJoints);
		replicatesignal(Humanoid.ServerResetCharacter);
		Character.Parent = LightingService;
		task.wait();
		replicatesignal(game.Players.LocalPlayer.Character.Humanoid.ServerResetCharacter);
	end;
end
----------------------------------------------------------------------

local function startCrash()
	if isActive then return end
	isActive = true
	statusText.Text = "CRASHING"
	statusText.TextColor3 = Color3.fromRGB(255, 120, 120)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(190, 82, 90)
	toggleBtn.Text = "STOP"
	crashThread = task.spawn(runCrash)
end

local function stopCrash()
	if not isActive then return end
	isActive = false
	if crashThread then
		task.cancel(crashThread)
		crashThread = nil
	end
	statusText.Text = "OFF"
	statusText.TextColor3 = T.dim
	toggleBtn.BackgroundColor3 = T.accent2
	toggleBtn.Text = "CRASH"
end

local function toggleMinimize()
	collapsed = not collapsed
	if collapsed then
		TweenService:Create(main, TweenInfo.new(0.25), { Size = UDim2.fromOffset(WIDTH, HEAD_H) }):Play()
		content.Visible = false
	else
		TweenService:Create(main, TweenInfo.new(0.25), { Size = UDim2.fromOffset(WIDTH, FULL_H) }):Play()
		content.Visible = true
	end
end

toggleBtn.MouseButton1Click:Connect(function()
	if isActive then stopCrash() else startCrash() end
end)

minBtn.MouseButton1Click:Connect(toggleMinimize)

closeBtn.MouseButton1Click:Connect(function()
	stopCrash()
	gui:Destroy()
end)

Player.CharacterRemoving:Connect(stopCrash)

-- DRAG (par le header)
local dragging, dragStart, startPos = false, nil, nil

bar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

bar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		main.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
	end
end)
