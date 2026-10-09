-- ============================================================
-- OR's AUTO STEAL HUB - MINI HUB STANDALONE
-- FPSL 
-- ORS AUTO STEAL
-- ============================================================

-- ── RESOLVE fireproximityprompt ──────────────────────────────
if not fireproximityprompt then
    fireproximityprompt = (getgenv and getgenv().fireproximityprompt)
        or (genv and genv().fireproximityprompt)
        or function(prompt)
            pcall(function()
                prompt:InputHoldBegin()
                prompt:InputHoldEnd()
            end)
        end
end

-- ── SERVIÇOS ─────────────────────────────────────────────────
local UIS          = game:GetService("UserInputService")
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui      = game:GetService("CoreGui")
local HttpService  = game:GetService("HttpService")

local lp = Players.LocalPlayer

-- ── ANTI DUPLICATA ───────────────────────────────────────────
pcall(function()
    if CoreGui:FindFirstChild("ORsAutoStealHub") then
        CoreGui:FindFirstChild("ORsAutoStealHub"):Destroy()
    end
    local pg = lp:FindFirstChild("PlayerGui")
    if pg and pg:FindFirstChild("ORsStealBarGui") then
        pg:FindFirstChild("ORsStealBarGui"):Destroy()
    end
end)

-- ── CONFIG PERSISTIDA ────────────────────────────────────────
local CONFIG_FILE = "ORsAutoSteal_Config.json"
local cfg = {}

local function saveConfig()
    if writefile then
        pcall(writefile, CONFIG_FILE, HttpService:JSONEncode(cfg))
    end
end

local function loadConfig()
    if isfile and isfile(CONFIG_FILE) then
        local ok, raw = pcall(readfile, CONFIG_FILE)
        if ok and raw then
            local ok2, d = pcall(HttpService.JSONDecode, HttpService, raw)
            if ok2 and d then cfg = d; return end
        end
    end
    cfg = {
        hubPos   = { px = 60,  py = 120 },
        barPos   = { px = -1,  py = -1  },
        radius   = 9,
        duration = 0,
        active   = true,
    }
    saveConfig()
end

loadConfig()

task.spawn(function()
    while true do task.wait(8); saveConfig() end
end)

-- ── SCREEN GUI (hub) ─────────────────────────────────────────
local Screen = Instance.new("ScreenGui")
Screen.Name           = "ORsAutoStealHub"
Screen.ResetOnSpawn   = false
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Screen.Parent         = CoreGui

-- ── CORES ────────────────────────────────────────────────────
local C = {
    Black     = Color3.fromRGB(0,   0,   0),
    Gray      = Color3.fromRGB(160, 160, 160),
    LightGray = Color3.fromRGB(130, 130, 130),
    White     = Color3.fromRGB(230, 230, 230),
    Dim       = Color3.fromRGB(90,  90,  90),
    TogOff    = Color3.fromRGB(40,  40,  48),
    Green     = Color3.fromRGB(80,  200, 120),
    Red       = Color3.fromRGB(200, 80,  80),
}

local STROKE_ACTIVE = Color3.fromRGB(255, 255, 255)
local STROKE_IDLE   = Color3.fromRGB(100, 100, 100)

-- ── HELPER NEW ───────────────────────────────────────────────
local function New(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props) do if k ~= "Parent" then o[k] = v end end
    o.Parent = props.Parent
    return o
end

-- ── GRADIENTE ANIMADO ────────────────────────────────────────
local function applyHubGradient(frame)
    local g = Instance.new("UIGradient", frame)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
    })
    g.Rotation = 135
    local rotSpeed  = 14  + math.random() * 18
    local shimSpeed = 0.8 + math.random() * 1.4
    local shimAmp   = 0.04 + math.random() * 0.05
    local phase     = math.random() * math.pi * 2
    local rot       = 135 + math.random(-45, 45)
    local dir       = (math.random(2) == 1) and 1 or -1
    local t = 0
    RunService.Heartbeat:Connect(function(dt)
        if not g or not g.Parent then return end
        t   = t + dt
        rot = (rot + rotSpeed * dt * dir) % 360
        g.Rotation = rot
        local wave = math.sin(t * shimSpeed + phase) * shimAmp
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,    math.clamp(0.04 + wave, 0, 1)),
            NumberSequenceKeypoint.new(0.4,  math.clamp(0.12 + wave, 0, 1)),
            NumberSequenceKeypoint.new(0.75, math.clamp(0.48 - wave, 0, 1)),
            NumberSequenceKeypoint.new(1,    math.clamp(0.85 - wave, 0, 1)),
        })
    end)
    return g
end

-- ── GHOST EFFECT (fantasmas dentro do frame) ─────────────────
local ghostReg = {}
local ghostT   = 0

RunService.Heartbeat:Connect(function(dt)
    if #ghostReg == 0 then return end
    ghostT = ghostT + 1
    if ghostT < 2 then return end
    ghostT = 0
    local dt2 = dt * 2
    local i = 1
    while i <= #ghostReg do
        local g = ghostReg[i]
        if not g.f or not g.f.Parent then
            pcall(function() g.l:Destroy() end)
            table.remove(ghostReg, i)
        else
            g.wp = g.wp + g.ws
            g.y  = g.y  + g.sp * 60 * dt2
            g.l.Position = UDim2.new(g.x + math.sin(g.wp) * g.wa, 0, g.y, 0)
            if     g.y < 0.05 then g.l.TextTransparency = 1 - g.op*(g.y+0.15)/0.20
            elseif g.y > 0.75 then g.l.TextTransparency = 1 - g.op*(1-(g.y-0.75)/0.30)
            else                    g.l.TextTransparency = 1 - g.op end
            if g.y > 1.1 then
                g.y=-.15; g.x=math.random(0,90)/100
                g.sp=.0008+math.random()*.0012
                g.wa=.03+math.random()*.04
                g.op=.35+math.random()*.45
                local sz=math.random(10,18)
                g.l.TextSize=sz; g.l.Size=UDim2.new(0,sz+4,0,sz+4)
            end
            i = i + 1
        end
    end
end)

local function Ghost(frame, n)
    frame.ClipsDescendants = true
    for k = 1, (n or 5) do
        task.delay((k-1)*0.3, function()
            if not frame.Parent then return end
            local l = Instance.new("TextLabel", frame)
            l.BackgroundTransparency = 1
            l.Text = "👻"
            l.ZIndex = (frame.ZIndex or 5) + 1
            l.BorderSizePixel = 0
            local sz = math.random(10, 18)
            l.TextSize = sz
            l.Size = UDim2.new(0, sz+4, 0, sz+4)
            l.TextTransparency = 1
            local g = {
                f  = frame, l = l,
                x  = math.random(0,90)/100,
                y  = -.15 - math.random()*.5,
                sp = .0008 + math.random()*.0012,
                wa = .03   + math.random()*.04,
                ws = .04   + math.random()*.03,
                wp = math.random()*math.pi*2,
                op = .35   + math.random()*.45,
            }
            l.Position = UDim2.new(g.x, 0, g.y, 0)
            table.insert(ghostReg, g)
        end)
    end
end

-- ── EFEITO INTRO: 👻 CHOVENDO NA TELA TODA ──────────────────
local function spawnScreenGhosts()
    local overlay = Instance.new("Frame", Screen)
    overlay.Size                 = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel      = 0
    overlay.ZIndex               = 100
    overlay.ClipsDescendants     = false

    for i = 1, 22 do
        task.delay((i-1) * 0.08, function()
            if not overlay.Parent then return end
            local lbl = Instance.new("TextLabel", overlay)
            lbl.BackgroundTransparency = 1
            lbl.Text                   = "👻"
            lbl.ZIndex                 = 101
            lbl.BorderSizePixel        = 0
            local sz = math.random(18, 36)
            lbl.TextSize = sz
            lbl.Size     = UDim2.new(0, sz+4, 0, sz+4)
            lbl.TextTransparency = 1
            local xPos      = math.random(3, 95) / 100
            local speed     = 0.55 + math.random() * 0.45
            local wobble    = math.random() * math.pi * 2
            local wobbleAmp = 0.02 + math.random() * 0.03
            lbl.Position = UDim2.new(xPos, 0, -0.12, 0)
            local startTime = tick()
            local conn
            conn = RunService.Heartbeat:Connect(function()
                if not lbl or not lbl.Parent then conn:Disconnect(); return end
                local elapsed  = tick() - startTime
                local progress = elapsed / speed
                lbl.Position = UDim2.new(
                    xPos + math.sin(wobble + elapsed * 3) * wobbleAmp, 0,
                    -0.12 + progress * 1.25, 0
                )
                if     elapsed < 0.15  then lbl.TextTransparency = 1 - (elapsed / 0.15)
                elseif progress > 0.85 then lbl.TextTransparency = (progress - 0.85) / 0.15
                else                        lbl.TextTransparency = 0 end
                if progress >= 1.0 then
                    conn:Disconnect()
                    pcall(function() lbl:Destroy() end)
                end
            end)
        end)
    end

    task.delay(4.5, function() pcall(function() overlay:Destroy() end) end)
end

-- ── DRAG HELPER ──────────────────────────────────────────────
local _dragJustHappened = false

local function MakeDrag(frame, onDrop)
    local dragging    = false
    local didMove     = false
    local activeInput = nil
    local startPos    = Vector2.zero
    local frameStart  = Vector2.zero

    local function beginDrag(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if not frame.Visible then return end
        if dragging then return end
        dragging    = true; didMove = false; activeInput = input
        startPos    = Vector2.new(input.Position.X, input.Position.Y)
        frameStart  = Vector2.new(frame.AbsolutePosition.X, frame.AbsolutePosition.Y)
    end

    local function hookObj(obj)
        if obj:IsA("GuiObject") and not obj:IsA("TextBox") then
            obj.InputBegan:Connect(beginDrag)
        end
    end
    hookObj(frame)
    for _, d in ipairs(frame:GetDescendants()) do hookObj(d) end
    frame.DescendantAdded:Connect(hookObj)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = Vector2.new(input.Position.X, input.Position.Y) - startPos
        if not didMove then
            if delta.Magnitude < 6 then return end
            didMove = true; _dragJustHappened = true
        end
        frame.Position = UDim2.new(0, frameStart.X + delta.X, 0, frameStart.Y + delta.Y)
    end)

    UIS.InputEnded:Connect(function(input)
        if not dragging or input ~= activeInput then return end
        dragging = false; activeInput = nil
        if didMove then
            if onDrop then onDrop(frame) end
            task.delay(0.12, function() _dragJustHappened = false end)
        end
        didMove = false
    end)
end

-- ============================================================
-- AUTO STEAL — LÓGICA COMPLETA
-- ============================================================
local isStealing     = false
local stealStartTime = 0
local STEAL_RADIUS   = cfg.radius   or 9
local STEAL_DURATION = cfg.duration or 0.2
local stealConn      = nil
local progressConn   = nil
local stealActive_   = cfg.active == true

local animalCache = {}
local promptCache = {}
local stealCache  = {}

-- Referências da barra separada (preenchidas abaixo)
local grabBarFill    = nil
local grabBarPercent = nil
local gbStroke       = nil

local function resetStealBar()
    if grabBarFill    then grabBarFill.Size = UDim2.fromScale(0, 1) end
    if grabBarPercent then grabBarPercent.Text = "READY" end
    if gbStroke       then gbStroke.Color = STROKE_IDLE end
end

local function isMyPlot(plotName)
    local plot = workspace.Plots and workspace.Plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign"); if not sign then return false end
    local yb = sign:FindFirstChild("YourBase")
    return yb and yb:IsA("BillboardGui") and yb.Enabled == true
end

local function scanPlot(plot)
    if not plot or not plot:IsA("Model") then return end
    if isMyPlot(plot.Name) then return end
    local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return end
    for _, pod in ipairs(podiums:GetChildren()) do
        if pod:IsA("Model") and pod:FindFirstChild("Base") then
            local uid = plot.Name .. "_" .. pod.Name
            for _, ex in ipairs(animalCache) do if ex.uid == uid then return end end
            table.insert(animalCache, {
                name = pod.Name, plot = plot.Name, slot = pod.Name,
                worldPosition = pod:GetPivot().Position, uid = uid,
            })
        end
    end
end

local function findPromptCached(ad)
    if not ad then return nil end
    local cp = promptCache[ad.uid]
    if cp and cp.Parent then return cp end
    local plots = workspace:FindFirstChild("Plots"); if not plots then return nil end
    local plot  = plots:FindFirstChild(ad.plot);    if not plot  then return nil end
    local pods  = plot:FindFirstChild("AnimalPodiums"); if not pods then return nil end
    local pod   = pods:FindFirstChild(ad.slot);     if not pod   then return nil end
    local base  = pod:FindFirstChild("Base");        if not base  then return nil end
    local sp    = base:FindFirstChild("Spawn");      if not sp    then return nil end
    local function searchPrompt(obj)
        for _, ch in ipairs(obj:GetDescendants()) do
            if ch:IsA("ProximityPrompt") then return ch end
        end
    end
    local att = sp:FindFirstChild("PromptAttachment")
    local prompt = nil
    if att then
        for _, p in ipairs(att:GetChildren()) do
            if p:IsA("ProximityPrompt") then prompt = p; break end
        end
    end
    if not prompt then prompt = searchPrompt(sp) end
    if prompt then promptCache[ad.uid] = prompt end
    return prompt
end

local function buildCallbacks(prompt)
    if stealCache[prompt] then return end
    local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
    local ok1, c1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(c1) == "table" then
        for _, conn in ipairs(c1) do
            if type(conn.Function) == "function" then
                table.insert(data.holdCallbacks, conn.Function)
            end
        end
    end
    local ok2, c2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(c2) == "table" then
        for _, conn in ipairs(c2) do
            if type(conn.Function) == "function" then
                table.insert(data.triggerCallbacks, conn.Function)
            end
        end
    end
    if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then
        stealCache[prompt] = data
    end
end

local function nearestAnimal()
    local char = lp.Character; if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
    if not hrp then return nil end
    local best, bestD = nil, math.huge
    for _, ad in ipairs(animalCache) do
        if not isMyPlot(ad.plot) and ad.worldPosition then
            local d = (hrp.Position - ad.worldPosition).Magnitude
            if d < bestD then bestD = d; best = ad end
        end
    end
    return best, bestD
end

local function execSteal(prompt, animalName)
    local data = stealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false; isStealing = true
    stealStartTime = tick()
    if grabBarPercent then grabBarPercent.Text = animalName or "STEAL..." end
    if gbStroke       then gbStroke.Color = STROKE_ACTIVE end
    if progressConn   then progressConn:Disconnect() end
    progressConn = RunService.Heartbeat:Connect(function()
        if not isStealing then progressConn:Disconnect(); return end
        local prog = math.clamp((tick() - stealStartTime) / STEAL_DURATION, 0, 1)
        if grabBarFill    then grabBarFill.Size = UDim2.fromScale(prog, 1) end
        if grabBarPercent then grabBarPercent.Text = math.floor(prog*100).."%" end
    end)
    task.spawn(function()
        for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
        for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
        if progressConn then progressConn:Disconnect(); progressConn = nil end
        resetStealBar()
        data.ready = true; isStealing = false
    end)
    return true
end

local function startAutoSteal()
    if stealConn then return end
    stealConn = RunService.Heartbeat:Connect(function()
        if not stealActive_ or isStealing then return end
        local target, dist = nearestAnimal()
        if not target then return end
        local char = lp.Character
        local hrp  = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"))
        if not hrp then return end
        if dist > STEAL_RADIUS then return end
        local prompt = promptCache[target.uid]
        if not prompt or not prompt.Parent then prompt = findPromptCached(target) end
        if prompt then buildCallbacks(prompt); execSteal(prompt, target.name) end
    end)
end

local function stopAutoSteal()
    if stealConn then stealConn:Disconnect(); stealConn = nil end
    isStealing = false
    resetStealBar()
end

task.spawn(function()
    task.wait(2)
    local plots = workspace:WaitForChild("Plots", 10); if not plots then return end
    local function setupPlot(plot)
        if not plot:IsA("Model") then return end
        scanPlot(plot)
        plot.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "AnimalPodiums" or descendant:IsA("Model") then
                task.wait(0.1)
                scanPlot(plot)
            end
        end)
    end
    for _, plot in ipairs(plots:GetChildren()) do setupPlot(plot) end
    plots.ChildAdded:Connect(setupPlot)
    task.spawn(function()
        while task.wait(1) do
            animalCache = {}; promptCache = {}
            for _, plot in ipairs(plots:GetChildren()) do
                if plot:IsA("Model") then scanPlot(plot) end
            end
        end
    end)
end)

-- ============================================================
-- BARRA DE PROGRESSO — FRAME SEPARADO, ARRASTÁVEL
-- ============================================================
local BAR_W = 220
local BAR_H = 28

local barDados = cfg.barPos or { px = -1, py = -1 }

local BarGui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
BarGui.Name           = "ORsStealBarGui"
BarGui.ResetOnSpawn   = false
BarGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local botFrame = Instance.new("Frame", BarGui)
botFrame.Name             = "GrabBarFrame"
botFrame.Size             = UDim2.new(0, BAR_W, 0, BAR_H)
botFrame.AnchorPoint      = Vector2.new(0, 0)
botFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
botFrame.BorderSizePixel  = 0
botFrame.Active           = true
Instance.new("UICorner", botFrame).CornerRadius = UDim.new(0, 10)
applyHubGradient(botFrame)

local botStroke = Instance.new("UIStroke", botFrame)
botStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
botStroke.Thickness       = 2
botStroke.Color           = STROKE_IDLE
gbStroke = botStroke

-- Posição inicial da barra separada
task.defer(function()
    local vp = workspace.CurrentCamera.ViewportSize
    if barDados.px and barDados.px >= 0
    and barDados.px < vp.X - 50 and barDados.py < vp.Y - 10 then
        botFrame.Position = UDim2.new(0, barDados.px, 0, barDados.py)
    else
        -- Default: centro inferior da tela
        botFrame.Position = UDim2.new(0, math.floor(vp.X/2 - BAR_W/2), 0, math.floor(vp.Y - 80))
        barDados.px = botFrame.Position.X.Offset
        barDados.py = botFrame.Position.Y.Offset
        cfg.barPos  = barDados
        saveConfig()
    end
end)

-- Label de status (READY / %)
local readyLbl = New("TextLabel", {
    Size = UDim2.new(0, 100, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "READY",
    TextColor3 = C.White,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 2,
    Parent = botFrame,
})
grabBarPercent = readyLbl

-- Ícone 👻 à direita
New("TextLabel", {
    Size = UDim2.new(0, 22, 0, 22),
    Position = UDim2.new(1, -26, 0.5, -11),
    BackgroundTransparency = 1,
    Text = "👻",
    TextSize = 14,
    ZIndex = 2,
    Parent = botFrame,
})

-- Barra de progresso na base
local barBg = New("Frame", {
    Size = UDim2.new(1, -6, 0, 5),
    Position = UDim2.new(0, 3, 1, -7),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = botFrame,
})
Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

local barFill = New("Frame", {
    Size = UDim2.fromScale(0, 1),
    BackgroundColor3 = C.White,
    BorderSizePixel  = 0,
    ZIndex = 3,
    Parent = barBg,
})
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
grabBarFill = barFill

-- Shimmer na barra enquanto roubando
RunService.Heartbeat:Connect(function()
    if isStealing then
        local t = tick() % 1
        barFill.BackgroundColor3 = Color3.fromRGB(
            230 + math.floor(math.sin(t * math.pi * 6) * 25), 230, 255
        )
    else
        barFill.BackgroundColor3 = C.White
    end
end)

-- Drag independente da barra separada
do
    local dragging, dragInput, dragStart, startAbsPos, activeBotInput
    botFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging       = true
            dragStart      = input.Position
            startAbsPos    = botFrame.AbsolutePosition
            activeBotInput = input
        end
    end)
    botFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if not dragging or input ~= activeBotInput then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = false; activeBotInput = nil
        barDados.px = botFrame.AbsolutePosition.X
        barDados.py = botFrame.AbsolutePosition.Y
        cfg.barPos  = barDados; saveConfig()
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            botFrame.Position = UDim2.new(0, startAbsPos.X + delta.X, 0, startAbsPos.Y + delta.Y)
        end
    end)
end

-- ============================================================
-- HUB PRINCIPAL — "OR's Auto Steal"
-- ============================================================
local HUB_W      = 230
local HUB_H_FULL = 140   -- sem a barra (que agora é separada)
local HUB_H_MINI = 34    -- só o header
local isMinimized = false

local hubPos = cfg.hubPos or { px = 60, py = 120 }

local HubFrame = Instance.new("Frame", Screen)
HubFrame.Name                  = "AutoStealHub"
HubFrame.Size                  = UDim2.new(0, HUB_W, 0, HUB_H_FULL)
HubFrame.Position               = UDim2.new(0, hubPos.px, 0, hubPos.py)
HubFrame.BackgroundColor3       = C.Black
HubFrame.BackgroundTransparency = 0
HubFrame.Visible                = true
HubFrame.ZIndex                 = 10
HubFrame.Active                 = true
HubFrame.ClipsDescendants       = true
Instance.new("UICorner", HubFrame).CornerRadius = UDim.new(0, 14)
local hubStroke = Instance.new("UIStroke", HubFrame)
hubStroke.Thickness = 2; hubStroke.Color = C.Gray
applyHubGradient(HubFrame)
Ghost(HubFrame, 5)

MakeDrag(HubFrame, function(frame)
    local ap = frame.AbsolutePosition
    cfg.hubPos = { px = ap.X, py = ap.Y }; saveConfig()
end)

-- ── HEADER ───────────────────────────────────────────────────
local Header = New("Frame", {
    Size = UDim2.new(1, 0, 0, HUB_H_MINI),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    ZIndex = 11, Parent = HubFrame,
})

New("TextLabel", {
    Size = UDim2.new(1, -50, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "👻 OR's Auto Steal",
    TextColor3 = C.White,
    Font = Enum.Font.Bangers,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 12, Parent = Header,
})

local MinBtn = New("TextButton", {
    Size = UDim2.new(0, 26, 0, 20),
    Position = UDim2.new(1, -32, 0.5, -10),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    BorderSizePixel = 0,
    Text = "─",
    TextColor3 = C.White,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    AutoButtonColor = false,
    ZIndex = 13, Parent = Header,
})
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local Divider = New("Frame", {
    Size = UDim2.new(1, -20, 0, 1),
    Position = UDim2.new(0, 10, 0, HUB_H_MINI - 1),
    BackgroundColor3 = C.Dim,
    BorderSizePixel = 0,
    BackgroundTransparency = 0.3,
    ZIndex = 11, Parent = HubFrame,
})

-- ── CORPO ────────────────────────────────────────────────────
local Body = New("Frame", {
    Size = UDim2.new(1, 0, 0, HUB_H_FULL - HUB_H_MINI),
    Position = UDim2.new(0, 0, 0, HUB_H_MINI),
    BackgroundTransparency = 1,
    ZIndex = 11, Parent = HubFrame,
})

-- ── TOGGLE AUTO STEAL ────────────────────────────────────────
local stealOn = stealActive_

local ToggleContainer = New("Frame", {
    Size = UDim2.new(1, -24, 0, 44),
    Position = UDim2.new(0, 12, 0, 8),
    BackgroundColor3 = Color3.fromRGB(12, 12, 12),
    BackgroundTransparency = 0.2,
    ZIndex = 12, Parent = Body,
})
Instance.new("UICorner", ToggleContainer).CornerRadius = UDim.new(0, 12)
New("UIStroke", {Color=C.Dim, Thickness=1, Transparency=0.5, Parent=ToggleContainer})

New("TextLabel", {
    Size = UDim2.new(0.6, 0, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "Auto Steal",
    TextColor3 = C.White,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 13, Parent = ToggleContainer,
})

local TogglePill = New("Frame", {
    Size = UDim2.new(0, 46, 0, 22),
    Position = UDim2.new(1, -56, 0.5, -11),
    BackgroundColor3 = stealOn and C.Green or C.TogOff,
    ZIndex = 13, Parent = ToggleContainer,
})
Instance.new("UICorner", TogglePill).CornerRadius = UDim.new(1, 0)

local ToggleDot = New("Frame", {
    Size = UDim2.new(0, 16, 0, 16),
    Position = stealOn and UDim2.new(0.55,0,0.1,0) or UDim2.new(0.08,0,0.1,0),
    BackgroundColor3 = C.White,
    ZIndex = 14, Parent = TogglePill,
})
Instance.new("UICorner", ToggleDot).CornerRadius = UDim.new(1, 0)

local StatusLbl = New("TextLabel", {
    Size = UDim2.new(0, 40, 0, 16),
    Position = UDim2.new(1, -104, 0.5, -8),
    BackgroundTransparency = 1,
    Text = stealOn and "ON" or "OFF",
    TextColor3 = stealOn and C.Green or C.Red,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex = 13, Parent = ToggleContainer,
})

local function setToggle(newOn, instant)
    stealOn      = newOn
    stealActive_ = newOn
    cfg.active   = newOn
    saveConfig()
    local tw = TweenInfo.new(instant and 0 or 0.18)
    TweenService:Create(TogglePill, tw, {BackgroundColor3 = newOn and C.Green or C.TogOff}):Play()
    TweenService:Create(ToggleDot,  tw, {Position = newOn and UDim2.new(0.55,0,0.1,0) or UDim2.new(0.08,0,0.1,0)}):Play()
    StatusLbl.Text       = newOn and "ON"  or "OFF"
    StatusLbl.TextColor3 = newOn and C.Green or C.Red
    TweenService:Create(hubStroke, TweenInfo.new(0.2), {
        Color = newOn and STROKE_ACTIVE or C.Gray
    }):Play()
    if newOn then startAutoSteal() else stopAutoSteal() end
end

-- Botão com animação bounce ao clicar
local _tcOrigSize = nil
local _tcOrigPos  = nil

local ToggleBtn = New("TextButton", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "",
    ZIndex = 15,
    AutoButtonColor = false,
    Parent = ToggleContainer,
})

ToggleBtn.MouseButton1Click:Connect(function()
    if _dragJustHappened then return end
    if _tcOrigSize == nil then
        _tcOrigSize = ToggleContainer.Size
        _tcOrigPos  = ToggleContainer.Position
    end
    TweenService:Create(ToggleContainer,
        TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(_tcOrigSize.X.Scale, _tcOrigSize.X.Offset - 6,
                             _tcOrigSize.Y.Scale, _tcOrigSize.Y.Offset - 4),
            Position = UDim2.new(_tcOrigPos.X.Scale, _tcOrigPos.X.Offset + 3,
                                 _tcOrigPos.Y.Scale, _tcOrigPos.Y.Offset + 2),
        }):Play()
    task.delay(0.1, function()
        TweenService:Create(ToggleContainer,
            TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = _tcOrigSize, Position = _tcOrigPos,
            }):Play()
    end)
    setToggle(not stealOn)
end)

-- ── LINHA: RADIUS + DURATION (dentro do hub) ─────────────────
local SettingsRow = New("Frame", {
    Size = UDim2.new(1, -24, 0, 32),
    Position = UDim2.new(0, 12, 0, 60),
    BackgroundColor3 = Color3.fromRGB(12, 12, 12),
    BackgroundTransparency = 0.2,
    ZIndex = 12, Parent = Body,
})
Instance.new("UICorner", SettingsRow).CornerRadius = UDim.new(0, 10)
New("UIStroke", {Color=C.Dim, Thickness=1, Transparency=0.5, Parent=SettingsRow})

-- Separador vertical central
New("Frame", {
    Size = UDim2.new(0, 1, 0.6, 0),
    Position = UDim2.new(0.5, 0, 0.2, 0),
    BackgroundColor3 = C.Dim,
    BorderSizePixel = 0,
    BackgroundTransparency = 0.4,
    ZIndex = 13, Parent = SettingsRow,
})

-- Radius
New("TextLabel", {
    Size = UDim2.new(0, 44, 1, 0),
    Position = UDim2.new(0, 8, 0, 0),
    BackgroundTransparency = 1,
    Text = "Radius",
    TextColor3 = C.Gray,
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 13, Parent = SettingsRow,
})
local RadBox = New("TextBox", {
    Size = UDim2.new(0, 32, 0, 20),
    Position = UDim2.new(0, 54, 0.5, -10),
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    BorderSizePixel = 0,
    Text = tostring(STEAL_RADIUS),
    TextColor3 = C.White,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    ClearTextOnFocus = false,
    ZIndex = 14, Parent = SettingsRow,
})
Instance.new("UICorner", RadBox).CornerRadius = UDim.new(0, 6)
RadBox.FocusLost:Connect(function()
    local val = tonumber(RadBox.Text:match("[%d%.]+"))
    if val then STEAL_RADIUS = math.clamp(math.floor(val), 1, 200) end
    RadBox.Text = tostring(STEAL_RADIUS)
    cfg.radius  = STEAL_RADIUS; saveConfig()
end)

-- Duration
New("TextLabel", {
    Size = UDim2.new(0, 40, 1, 0),
    Position = UDim2.new(0.5, 8, 0, 0),
    BackgroundTransparency = 1,
    Text = "Dur(s)",
    TextColor3 = C.Gray,
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 13, Parent = SettingsRow,
})
local DurBox = New("TextBox", {
    Size = UDim2.new(0, 38, 0, 20),
    Position = UDim2.new(1, -46, 0.5, -10),
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    BorderSizePixel = 0,
    Text = tostring(STEAL_DURATION),
    TextColor3 = C.White,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    ClearTextOnFocus = false,
    ZIndex = 14, Parent = SettingsRow,
})
Instance.new("UICorner", DurBox).CornerRadius = UDim.new(0, 6)
DurBox.FocusLost:Connect(function()
    local val = tonumber(DurBox.Text:match("[%d%.]+"))
    if val then STEAL_DURATION = math.clamp(val, 0, 5) end
    DurBox.Text  = tostring(STEAL_DURATION)
    cfg.duration = STEAL_DURATION; saveConfig()
end)

-- ── BOTÃO MINIMIZAR ──────────────────────────────────────────
MinBtn.MouseButton1Click:Connect(function()
    if _dragJustHappened then return end
    isMinimized = not isMinimized
    -- Bounce no próprio botão
    TweenService:Create(MinBtn,
        TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 20, 0, 16)}):Play()
    task.delay(0.1, function()
        TweenService:Create(MinBtn,
            TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 26, 0, 20)}):Play()
    end)
    if isMinimized then
        MinBtn.Text = "□"
        TweenService:Create(HubFrame,
            TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, HUB_W, 0, HUB_H_MINI)}):Play()
        task.delay(0.23, function()
            Body.Visible    = false
            Divider.Visible = false
        end)
    else
        MinBtn.Text     = "─"
        Body.Visible    = true
        Divider.Visible = true
        TweenService:Create(HubFrame,
            TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, HUB_W, 0, HUB_H_FULL)}):Play()
    end
end)

-- ── ESTADO INICIAL ───────────────────────────────────────────
setToggle(stealActive_, true)

-- ── EFEITO INTRO ─────────────────────────────────────────────
task.delay(0.1, function() spawnScreenGhosts() end)

-- ── POP-IN SUAVE DO HUB ──────────────────────────────────────
do
    HubFrame.BackgroundTransparency = 1
    HubFrame.Size     = UDim2.new(0, HUB_W * 0.75, 0, HUB_H_FULL * 0.75)
    local ap          = HubFrame.AbsolutePosition
    HubFrame.Position = UDim2.new(0, ap.X + HUB_W*0.125, 0, ap.Y + HUB_H_FULL*0.125)
    TweenService:Create(HubFrame,
        TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size                  = UDim2.new(0, HUB_W, 0, HUB_H_FULL),
            Position              = UDim2.new(0, hubPos.px, 0, hubPos.py),
            BackgroundTransparency = 0,
        }):Play()
end

print("👻 OR's Auto Steal Hub carregado!")
