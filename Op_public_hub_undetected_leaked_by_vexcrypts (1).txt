if not game:IsLoaded() then game.Loaded:Wait() end

local privateBuild = false
local SharedState = {
    SelectedPetData = nil,
    AllAnimalsCache = nil,
    DisableStealSpeed = nil,
    ListNeedsRedraw = true,
    AdminButtonCache = {},
    StealSpeedToggleFunc = nil,
    _ssUpdateBtn = nil,
    AdminProxBtn = nil,
    BalloonedPlayers = {},
    MobileScaleObjects = {},
    RefreshMobileScale = nil,
    InitialScanComplete = false,
}
_G.firePromptDirect = function(prompt)
    if not prompt or not prompt.Parent then return end
    if not prompt.Enabled then return end
    pcall(function() fireproximityprompt(prompt) end)
end
_G.triggerSafePollBoost = function() end
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService"),
    Workspace = game:GetService("Workspace"),
    Lighting = game:GetService("Lighting"),
    VirtualInputManager = Instance.new("VirtualInputManager"),
    GuiService = game:GetService("GuiService"),
    TeleportService = game:GetService("TeleportService"),
}
local Players = Services.Players
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local ReplicatedStorage = Services.ReplicatedStorage
local TweenService = Services.TweenService
local HttpService = Services.HttpService
local Workspace = Services.Workspace
local Lighting = Services.Lighting
local OriginalLighting = {
    Brightness               = Lighting.Brightness,
    Ambient                  = Lighting.Ambient,
    OutdoorAmbient           = Lighting.OutdoorAmbient,
    ClockTime                = Lighting.ClockTime,
    FogEnd                   = Lighting.FogEnd,
    FogStart                 = Lighting.FogStart,
    GlobalShadows            = Lighting.GlobalShadows,
    EnvironmentDiffuseScale  = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
}
local VirtualInputManager = Services.VirtualInputManager
local GuiService = Services.GuiService
local TeleportService = Services.TeleportService
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ZawaRawSync
do
    local ok, built = pcall(function()
        local Packages      = ReplicatedStorage:WaitForChild("Packages")
        local folder        = Packages:WaitForChild("Synchronizer")
        local channelFolder = folder:WaitForChild("Channel")
        local routeRemote   = folder:WaitForChild("CommunicationRoute")
        local requestData   = folder:FindFirstChild("RequestData")
        local plots         = Workspace:WaitForChild("Plots")
        local plotAnimalSync = {
            caches      = {},
            connections = {},
        }
        local function splitSyncPath(path)
            if typeof(path) == "table" then
                return path
            end
            local out = {}
            for part in string.gmatch(tostring(path), "[^%.]+") do
                table.insert(out, tonumber(part) or part)
            end
            return out
        end
        local function resolveSyncPath(path, root)
            local current = root
            local parent = nil
            local key = nil
            for _, part in ipairs(splitSyncPath(path)) do
                parent = current
                key = part
                current = current and current[part] or nil
            end
            return current, parent, key
        end
        local function applyPlotSyncDiff(channelName, packet)
            local cache = plotAnimalSync.caches[channelName]
            if typeof(cache) ~= "table" then
                return
            end
            local path, action, a, b = packet[1], packet[2], packet[3], packet[4]
            local current, parent, key = resolveSyncPath(path, cache)
            if action == "Changed" then
                if parent ~= nil then
                    parent[key] = a
                end
            elseif action == "ArrayInsert" then
                if current ~= nil then
                    table.insert(current, b, a)
                end
            elseif action == "ArrayRemoved" then
                if current ~= nil then
                    table.remove(current, b)
                end
            elseif action == "DictionaryInsert" then
                if current ~= nil then
                    current[b] = a
                end
            elseif action == "DictionaryRemoved" then
                if current ~= nil then
                    current[b] = nil
                end
            end
        end
        local function attachPlotChannel(remote)
            if plotAnimalSync.connections[remote] then
                return
            end
            local channelName = tostring(remote.Name)
            if not plots:FindFirstChild(channelName) then
                return
            end
            if requestData and plotAnimalSync.caches[channelName] == nil then
                local ok, data = pcall(function()
                    return requestData:InvokeServer(channelName)
                end)
                if ok and typeof(data) == "table" then
                    plotAnimalSync.caches[channelName] = data
                else
                    plotAnimalSync.caches[channelName] = {}
                end
            elseif plotAnimalSync.caches[channelName] == nil then
                plotAnimalSync.caches[channelName] = {}
            end
            plotAnimalSync.connections[remote] = remote.OnClientEvent:Connect(function(queue)
                for _, packet in ipairs(queue) do
                    applyPlotSyncDiff(channelName, packet)
                end
            end)
        end
        local function detachPlotChannel(channelName)
            for remote, conn in pairs(plotAnimalSync.connections) do
                if tostring(remote.Name) == tostring(channelName) then
                    conn:Disconnect()
                    plotAnimalSync.connections[remote] = nil
                    plotAnimalSync.caches[tostring(channelName)] = nil
                    break
                end
            end
        end
        for _, child in ipairs(channelFolder:GetChildren()) do
            if child:IsA("RemoteEvent") then
                attachPlotChannel(child)
            end
        end
        channelFolder.ChildAdded:Connect(function(child)
            if child:IsA("RemoteEvent") then
                attachPlotChannel(child)
            end
        end)
        routeRemote.OnClientEvent:Connect(function(actions)
            for _, action in ipairs(actions) do
                local kind, channelName = action[1], tostring(action[2])
                if not plots:FindFirstChild(channelName) then
                    continue
                end
                if kind == "ListenerAdded" then
                    local remote = channelFolder:FindFirstChild(channelName)
                    if remote and remote:IsA("RemoteEvent") then
                        attachPlotChannel(remote)
                    end
                elseif kind == "ListenerRemoved" then
                    detachPlotChannel(channelName)
                end
            end
        end)
        return { caches = plotAnimalSync.caches }
    end)
    if ok and built then
        ZawaRawSync = built
    else
        warn("[ZawaHub] raw synchronizer init failed:", built)
        ZawaRawSync = { caches = {} }
    end
end
_G.ZawaRawSync = ZawaRawSync
local Decrypted
Decrypted = setmetatable({}, {
    __index = function(S, ez)
        local Netty = ReplicatedStorage.Packages.Net
        local prefix, path
        if     ez:sub(1,3) == "RE/" then prefix = "RE/";  path = ez:sub(4)
        elseif ez:sub(1,3) == "RF/" then prefix = "RF/";  path = ez:sub(4)
        else return nil end
        local Remote
        for i, v in Netty:GetChildren() do
            if v.Name == ez then
                Remote = Netty:GetChildren()[i + 1]
                break
            end
        end
        if Remote and not rawget(Decrypted, ez) then rawset(Decrypted, ez, Remote) end
        return rawget(Decrypted, ez)
    end
})
local Utility = {}
function Utility:LarpNet(F) return Decrypted[F] end
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local function parseMinGen(str)
    if not str or type(str) ~= "string" then return 0 end
    str = str:gsub("%s", ""):lower()
    if str == "" then return 0 end
    local num, suffix = str:match("^([%d%.]+)([kmb]?)$")
    if not num then return 0 end
    num = tonumber(num)
    if not num or num < 0 then return 0 end
    if suffix == "k" then return num * 1e3
    elseif suffix == "m" then return num * 1e6
    elseif suffix == "b" then return num * 1e9
    end
    return num
end
local DANGER_TOOLS = {
    ["Boogie Bomb"]       = true,
    ["Medusa's Head"]     = true,
    ["Body Swap Potion"]  = true,
    ["Laser Cape"]        = true,
    ["Rainbowrath Sword"] = true,
    ["Gummy Bear"]        = true,
}
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
end
local IS_MOBILE = isMobile()
local FileName = "ZawasPublic_v1.json" 
local PriorityFileName = "ZawasPublic_priority.json"
local DefaultConfig = {
    Positions = {
        AdminPanel = {X = 0.1859375, Y = 0.5767123526556385}, 
        StealSpeed = {X = 0.02, Y = 0.18}, 
        Settings = {X = 0.834375, Y = 0.43590998043052839}, 
        InvisPanel = {X = 0.8578125, Y = 0.17260276361454258}, 
        AutoSteal = {X = 0.02, Y = 0.35}, 
        MobileControls = {X = 0.9, Y = 0.4},
        MobileBtn_TP = {X = 0.5, Y = 0.4},
        MobileBtn_CL = {X = 0.5, Y = 0.4},
        MobileBtn_SP = {X = 0.5, Y = 0.4},
        MobileBtn_IV = {X = 0.5, Y = 0.4},
        MobileBtn_UI = {X = 0.5, Y = 0.4},
        JobJoiner = {X = 0.5, Y = 0.85},
        AutoBuy = {X = 0.02, Y = 0.55},
        TargetControls = {X = 0.5, Y = 0.3},
    }, 
    TpSettings = {
        Tool             = "Flying Carpet",
        Speed            = 2, 
        TpKey            = "T",
        CloneKey         = "V",
        TpOnLoad         = false,
        MinGenForTp      = "",
        MinGenForNearest = "",
        CarpetSpeedKey   = "Q",
        InfiniteJump     = false,
    },
    StealSpeed   = 20,
    AntiBodySwap = false,
    ShowStealSpeedPanel = true,
    MenuKey      = "LeftControl",
    MobileGuiScale = 0.5,
    AntiRagdoll  = 0,
    AntiRagdollV2 = false,
    PlayerESP    = true,
    TracerEnabled = true,
    BrainrotESP = true,
    LineToBase = false,
    StealNearest = false,
    StealHighest = true,
    StealPriority = false,
    DefaultToNearest = false,
    DefaultToHighest = false,
    DefaultToPriority = false,
    UILocked     = false,
    HideAdminPanel = false,
    HideAutoSteal = false,
    CompactAutoSteal = false,
    AutoKickOnSteal = false,
    InvisStealAngle = 233,
    SinkSliderValue = 5,
    AutoRecoverLagback = true,
    AutoInvisDuringSteal = false,
    InvisToggleKey = "I",
    ClickToAP = false,
    ClickToAPKeybind = "L",
    DisableClickToAPOnMoby = false,
    ProximityAP = false,
    ProximityAPKeybind = "P",
    ProximityRange = 15,
    StealSpeedKey = "C",
    ShowInvisPanel = true,
    ShowRemoteSell = false,
    AutoSell = false,
    AutoSellPodium = 0, 
    ShowAutoSellZone = false,
    AutoStealEnabled = true,
    StealBarEnabled = false,
    FPSBoost     = true,
    FPSBoostDarkMode = false,
    DarkModeBrightness = 0.3,
    ResetKey = "X",
    AutoResetOnBalloon = false,
    AntiBeeDisco = false,
    AutoDestroyTurrets = false,
    FOV = 70,
    SubspaceMineESP = false,
    AutoUnlockOnSteal = false,
    ShowUnlockButtonsHUD = false,
    AutoTPOnFailedSteal = false,
    AutoKickOnSteal = false,
    AutoTPPriority = true,
    KickKey = "",
    AutoTurretKey = "",
    BaseTimerESP = false,
    MobyESPInAdminPanel = true,
    CleanErrorGUIs = false,
    ClickToAPSingleCommand = false,
    RagdollSelfKey = "",
    DuelBaseESP = true,
    UseTpV2 = false,
    UseTweenTp = false,
    TweenTpSideMode = false,
    TweenTpV3Mode = false,
    ShowTpPath = false,
    AutoTPFloor2FromFloor1 = false,   
    AutoGrab = false,
    AutoTPStartDelay         = 0.50,
    Floor1Velocity           = 800,
    Floor1Height             = 50,
    Floor1SpeedVelocity      = 50,
    Floor1CloneDelay         = 0,
    Floor1InstantCloneSpeed  = 0.05,
    Floor1InstantCloneSpeedHP= 0.1,
    Floor1BrainrotSpeed      = 0.4,
    Floor2Velocity           = 130,
    Floor2Height             = 40,
    Floor2SpeedVelocity      = 50,
    Floor2CloneDelay         = 0,
    Floor2InstantCloneSpeed  = 0.05,
    Floor2InstantCloneSpeedHP= 0.1,
    Floor2BrainrotSpeed      = 0.4,
    TweenTpSpeedF1           = 140,  
    TweenTpSpeedF2           = 130,  
    AlertsEnabled = true,
    AlertSoundID = "rbxassetid://6518811702",
    GriefDetectorEnabled = true,
    GriefDetectorWebhookURL = "",
    DisableProximitySpamOnMoby = false,
    DisableAPPanelOnMoby = false,
    PanelScales = {},
    DisableClickToAPOnKawaifu = false,
    DisableProximitySpamOnKawaifu = false,
    DisableAPPanelOnKawaifu = false,
    KawaifuESPInAdminPanel = true,
    HideKawaifuFromPanel = false,
    DisableClickToAPOnAtlas = false,
    DisableProximitySpamOnAtlas = false,
    DisableAPPanelOnAtlas = false,
    AtlasESPInAdminPanel = true,
    DisableClickToAPOnBraintopia = false,
    DisableProximitySpamOnBraintopia = false,
    DisableAPPanelOnBraintopia = false,
    BraintopiaESPInAdminPanel = true,
    AutoStealSpeed = false,
    ShowJobJoiner = true,
    JobJoinerKey = "J",
    ShowServerPos = false,
    ShowMiniPanel = false,
    BlacklistedUsers = {},
}
local Config = DefaultConfig
if isfile and isfile(FileName) then
    pcall(function()
        local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(FileName)) end)
        if not ok then return end
        for k, v in pairs(DefaultConfig) do
            if decoded[k] == nil then decoded[k] = v end
        end
        if decoded.TpSettings then
            for k, v in pairs(DefaultConfig.TpSettings) do
                if decoded.TpSettings[k] == nil then decoded.TpSettings[k] = v end
            end
        end
        if decoded.Positions then
            for k, v in pairs(DefaultConfig.Positions) do
                if decoded.Positions[k] == nil then decoded.Positions[k] = v end
            end
        end
        Config = decoded
    end)
end
Config.ProximityAP = false
if Config.TweenTpV3Mode and (Config.UseTweenTp or Config.TweenTpSideMode) then
    Config.UseTweenTp = false
    Config.TweenTpSideMode = false
end
local function ApplyDarkModeLighting()
    local bright = tonumber(Config.DarkModeBrightness) or 0.3
    bright = math.clamp(bright, 0, 1.5)
    local frac = bright / 1.5  
    if Lighting.Brightness ~= bright then
        Lighting.Brightness = bright
    end
    local ambVal = math.floor(60 * frac)
    local targetAmb = Color3.fromRGB(ambVal, ambVal, ambVal)
    if Lighting.Ambient ~= targetAmb then
        Lighting.Ambient = targetAmb
    end
    local outAmbVal = math.floor(128 * frac)
    local targetOutAmb = Color3.fromRGB(outAmbVal, outAmbVal, outAmbVal)
    if Lighting.OutdoorAmbient ~= targetOutAmb then
        Lighting.OutdoorAmbient = targetOutAmb
    end
end
local function deepCopy(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = deepCopy(v)
    end
    return copy
end
local function SaveConfig()
    if writefile then
        pcall(function()
            local toSave = deepCopy(Config)
            toSave.ProximityAP = false
            writefile(FileName, HttpService:JSONEncode(toSave))
        end)
    end
end
local function isMobyUser(player)
    if not player or not player.Character then return false end
    return player.Character:FindFirstChild("_moby_highlight") ~= nil
end
local HighlightName = "KaWaifu_NeonHighlight"
local function isKawaifuUser(player)
    if not player or not player.Character then return false end
    return player.Character:FindFirstChild(HighlightName) ~= nil
end
local function isAtlasUser(player)
    if not player then return false end
    local atlasFolder = workspace:FindFirstChild("AtlasESPFolder")
    if not atlasFolder then return false end
    local espFolder = atlasFolder:FindFirstChild(player.Name .. "_ESP")
    if not espFolder then return false end
    local hl = espFolder:FindFirstChildWhichIsA("Highlight")
    if not hl then return false end
    local fc = hl.FillColor
    return fc.R > 0.99 and math.abs(fc.G - 215/255) < 0.02 and fc.B < 0.01
end
local function isBraintopiaUser(player)
    if not player or not player.Character then return false end
    return player.Character:FindFirstChild("BT_ESP") ~= nil
end
local function isBlacklisted(player)
    if not player then return false end
    local name = player.Name:lower()
    for _, n in ipairs(Config.BlacklistedUsers) do
        if n:lower() == name then return true end
    end
    return false
end
_G.InvisStealAngle = Config.InvisStealAngle
_G.SinkSliderValue = Config.SinkSliderValue
_G.AutoRecoverLagback = Config.AutoRecoverLagback
_G.AutoInvisDuringSteal = Config.AutoInvisDuringSteal
_G.ShowServerPos = Config.ShowServerPos
_G.INVISIBLE_STEAL_KEY = Enum.KeyCode[Config.InvisToggleKey] or Enum.KeyCode.I
_G.invisibleStealEnabled = false
_G.RecoveryInProgress = false
local function getControls()
	local playerScripts = LocalPlayer:WaitForChild("PlayerScripts")
	local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
	return playerModule:GetControls()
end
local Controls = getControls()
local function kickPlayer()
    game:Shutdown()
end
local function walkForward(seconds)
    local char = LocalPlayer.Character
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local Controls = getControls()
    local lookVector = hrp.CFrame.LookVector
    Controls:Disable()
    local startTime = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if os.clock() - startTime >= seconds then
            conn:Disconnect()
            hum:Move(Vector3.zero, false)
            Controls:Enable()
            return
        end
        hum:Move(lookVector, false)
    end)
end
local function instantClone(cloneSpeed, skipAutoTp)
    if _G.isCloning then return end
    _G.isCloning = true
    local ok, err = pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not (char and hum) then error("No character") end
        local cloner =
            LocalPlayer.Backpack:FindFirstChild("Quantum Cloner")
            or char:FindFirstChild("Quantum Cloner")
        if not cloner then error("No Quantum Cloner") end
        pcall(function()
            hum:EquipTool(cloner)
        end)
        local cloneGap = tonumber(cloneSpeed) or 0.05
        if cloneGap < 0 then cloneGap = 0 end
        cloner:Activate()
        task.wait(0.015)
        local cloneName = tostring(LocalPlayer.UserId) .. "_Clone"
        local pollInterval = 0.015
        local maxWait = 10
        local iters = math.max(1, math.floor(maxWait / pollInterval))
        for _ = 1, iters do
            if Workspace:FindFirstChild(cloneName) then break end
            task.wait(pollInterval)
        end
        if not Workspace:FindFirstChild(cloneName) then
            error("")
        end
        local toolsFrames = LocalPlayer.PlayerGui:FindFirstChild("ToolsFrames")
        local qcFrame = toolsFrames and toolsFrames:FindFirstChild("QuantumCloner")
        local tpButton = qcFrame and qcFrame:FindFirstChild("TeleportToClone")
        if not tpButton then error("Teleport button missing") end
        tpButton.Visible = true
        if cloneGap > 0 then task.wait(cloneGap) end
            local vim = Instance.new("VirtualInputManager")
            local inset = (cloneref and cloneref(game:GetService("GuiService")) or GuiService):GetGuiInset()
            local pos = tpButton.AbsolutePosition + (tpButton.AbsoluteSize / 2) + inset
            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
            task.wait()
            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
    end)
    _G.isCloning = false
end
local function triggerClosestUnlock(yLevel, maxY)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local playerY = yLevel or hrp.Position.Y
    local Y_THRESHOLD = 8
    local bestPrompt = nil
    local shortestDist = math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            if obj.ActionText == "Steal" then continue end
            local part = obj.Parent
            local partPos = nil
            if part and part:IsA("BasePart") then
                partPos = part.Position
            elseif part and part:IsA("Attachment") and part.Parent and part.Parent:IsA("BasePart") then
                partPos = part.Parent.Position
            end
            if partPos then
                if maxY and partPos.Y > maxY then continue end
                local yDiff = math.abs(playerY - partPos.Y)
                if yDiff > Y_THRESHOLD then continue end
                local dist = (hrp.Position - partPos).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    bestPrompt = obj
                end
            end
        end
    end
    if bestPrompt then
        if _G.firePromptDirect then
            _G.firePromptDirect(bestPrompt)
        elseif fireproximityprompt then
            fireproximityprompt(bestPrompt)
        else
            bestPrompt:InputBegan(Enum.UserInputType.MouseButton1)
            task.wait(0.05)
            bestPrompt:InputEnded(Enum.UserInputType.MouseButton1)
        end
    end
end
local Theme = {
    Background      = Color3.fromRGB(12, 0, 0),
    Surface         = Color3.fromRGB(30, 6, 6),
    SurfaceHighlight= Color3.fromRGB(80, 12, 12),
    Accent1         = Color3.fromRGB(255, 30, 30),
    Accent2         = Color3.fromRGB(200, 10, 10),
    TextPrimary     = Color3.fromRGB(255, 220, 220),
    TextSecondary   = Color3.fromRGB(220, 120, 120),
    Success         = Color3.fromRGB(220, 30, 30),
    Error           = Color3.fromRGB(255, 60, 60),
}
local PRIORITY_LIST = {
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
   "Chipso and Queso"
}
if isfile and isfile(PriorityFileName) then
    pcall(function()
        local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(PriorityFileName)) end)
        if ok and type(decoded) == "table" and #decoded > 0 then
            PRIORITY_LIST = decoded
        end
    end)
end
local function SavePriorityList()
    if writefile then
        pcall(function()
            writefile(PriorityFileName, HttpService:JSONEncode(PRIORITY_LIST))
        end)
    end
end
local KNOWN_OG_FALLBACK = {
    "Strawberry Elephant",
    "Meowl",
    "Skibidi Toilet",
    "John Pork",
    "Headless Horseman",
}
task.spawn(function()
    do
        local existing = {}
        for _, name in ipairs(PRIORITY_LIST) do
            existing[tostring(name):lower()] = true
        end
        local addedFallback = 0
        for _, ogName in ipairs(KNOWN_OG_FALLBACK) do
            if not existing[ogName:lower()] then
                table.insert(PRIORITY_LIST, ogName)
                existing[ogName:lower()] = true
                addedFallback = addedFallback + 1
            end
        end
        if addedFallback > 0 then
            pcall(SavePriorityList)
            if _G._refreshPriorityListGUI then
                pcall(_G._refreshPriorityListGUI)
            end
        end
    end
    local ok, AnimalsData = pcall(function()
        local Datas = game:GetService("ReplicatedStorage"):WaitForChild("Datas", 30)
        if not Datas then return nil end
        local mod = Datas:WaitForChild("Animals", 30)
        if not mod then return nil end
        return require(mod)
    end)
    if not ok or type(AnimalsData) ~= "table" then return end
    local function syncOGs()
        local existing = {}
        for _, name in ipairs(PRIORITY_LIST) do
            existing[tostring(name):lower()] = true
        end
        local added = 0
        for petName, data in pairs(AnimalsData) do
            if type(data) == "table" and data.Rarity
               and tostring(data.Rarity):lower() == "og"
               and not tostring(petName):find("Lucky Block") then
                local displayName = data.DisplayName or petName
                if not existing[tostring(displayName):lower()] then
                    table.insert(PRIORITY_LIST, displayName)
                    existing[tostring(displayName):lower()] = true
                    added = added + 1
                end
            end
        end
        if added > 0 then
            pcall(SavePriorityList)
            if _G._refreshPriorityListGUI then
                pcall(_G._refreshPriorityListGUI)
            end
        end
    end
    syncOGs()
    while true do
        task.wait(60)
        pcall(syncOGs)
    end
end)
local function findAdorneeGlobal(animalData)
    if not animalData then return nil end
    local plot = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(animalData.plot)
    if plot then
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if podiums then
            local podium = podiums:FindFirstChild(animalData.slot)
            if podium then
                local base = podium:FindFirstChild("Base")
                if base then
                    local spawn = base:FindFirstChild("Spawn")
                    if spawn then return spawn end
                    return base:FindFirstChildWhichIsA("BasePart") or base
                end
            end
        end
    end
    return nil
end
local function CreateGradient(parent)
    return nil
end
local function ApplyViewportUIScale(targetFrame, designWidth, designHeight, minScale, maxScale)
    if not targetFrame then return end
    if not IS_MOBILE then return end
    local existing = targetFrame:FindFirstChild("__MobileUIScale")
    if existing then existing:Destroy() end
    local sc = Instance.new("UIScale")
    sc.Name = "__MobileUIScale"
    sc.Parent = targetFrame
    SharedState.MobileScaleObjects[targetFrame] = sc
    if SharedState.RefreshMobileScale then
        SharedState.RefreshMobileScale()
    else
        sc.Scale = math.clamp(tonumber(Config.MobileGuiScale) or 0.5, 0, 1)
    end
end
SharedState.RefreshMobileScale = function()
    local s = math.clamp(tonumber(Config.MobileGuiScale) or 0.5, 0, 1)
    for frame, sc in pairs(SharedState.MobileScaleObjects) do
        if frame and frame.Parent and sc and sc.Parent == frame then
            sc.Scale = s
        else
            SharedState.MobileScaleObjects[frame] = nil
        end
    end
end
local UserInputServiceScale = game:GetService("UserInputService")
local function AddResizeHandle(frame, panelKey, posOverride)
    if not frame or not frame.Parent then return end
    if frame:FindFirstChild("__GlobalResizeHandle") then return end
    panelKey = panelKey or frame.Name or "Panel"
    local panelScale = frame:FindFirstChild("__PanelResizeScale")
    if not panelScale then
        panelScale = Instance.new("UIScale")
        panelScale.Name = "__PanelResizeScale"
        panelScale.Parent = frame
    end
    if type(Config.PanelScales) ~= "table" then Config.PanelScales = {} end
    local savedScale = tonumber(Config.PanelScales[panelKey]) or 1.0
    panelScale.Scale = math.clamp(savedScale, 0.5, 2.0)
    local handle = Instance.new("TextButton")
    handle.Name = "__GlobalResizeHandle"
    handle.Size = UDim2.new(0, 18, 0, 18)
    local autoPos = UDim2.new(1, -22, 0, 6)
    local _hdr = frame:FindFirstChildWhichIsA("Frame")
    if _hdr and _hdr:FindFirstChild("__MobileMinimize") then
        autoPos = UDim2.new(1, -52, 0, 6)
    end
    handle.Position = posOverride or autoPos
    handle.AnchorPoint = Vector2.new(0, 0)
    handle.BackgroundColor3 = Color3.fromRGB(100, 12, 12)
    handle.BackgroundTransparency = 0.25
    handle.AutoButtonColor = false
    handle.Text = "↗"
    handle.Font = Enum.Font.GothamBold
    handle.TextSize = 14
    handle.TextColor3 = Color3.fromRGB(255, 220, 220)
    handle.BorderSizePixel = 0
    handle.ZIndex = 100
    Instance.new("UICorner", handle).CornerRadius = UDim.new(0, 4)
    local hStroke = Instance.new("UIStroke", handle)
    hStroke.Color = Color3.fromRGB(200, 20, 20)
    hStroke.Thickness = 1
    hStroke.Transparency = 0.4
    handle.Parent = frame
    handle.MouseEnter:Connect(function()
        handle.BackgroundTransparency = 0.05
        hStroke.Transparency = 0.1
    end)
    handle.MouseLeave:Connect(function()
        handle.BackgroundTransparency = 0.25
        hStroke.Transparency = 0.4
    end)
    local dragging = false
    local startInputPos = nil
    local startScale = 1.0
    local moveConn, endConn
    local function clampScale(v) return math.clamp(v, 0.5, 2.0) end
    local function endDrag()
        if not dragging then return end
        dragging = false
        if moveConn then moveConn:Disconnect(); moveConn = nil end
        if endConn then endConn:Disconnect(); endConn = nil end
        if type(Config.PanelScales) ~= "table" then Config.PanelScales = {} end
        Config.PanelScales[panelKey] = panelScale.Scale
        if SaveConfig then pcall(SaveConfig) end
    end
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1
            and inp.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = true
        startInputPos = inp.Position
        startScale = panelScale.Scale or 1.0
        moveConn = UserInputServiceScale.InputChanged:Connect(function(mv)
            if not dragging then return end
            if mv.UserInputType ~= Enum.UserInputType.MouseMovement
                and mv.UserInputType ~= Enum.UserInputType.Touch then return end
            local dx = mv.Position.X - startInputPos.X
            local dy = mv.Position.Y - startInputPos.Y
            local delta = (dx + dy) / 400
            panelScale.Scale = clampScale(startScale + delta)
        end)
        endConn = UserInputServiceScale.InputEnded:Connect(function(en)
            if en.UserInputType == Enum.UserInputType.MouseButton1
                or en.UserInputType == Enum.UserInputType.Touch then
                endDrag()
            end
        end)
    end)
end
SharedState.AddResizeHandle = AddResizeHandle
local function AddMobileMinimize(frame, labelText)
    if not IS_MOBILE then return end
    if not frame or not frame.Parent then return end
    local guiParent = frame.Parent
    local header = frame:FindFirstChildWhichIsA("Frame")
    if not header then return end
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "__MobileMinimize"
    minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
    minimizeBtn.Position = UDim2.new(1, -30, 0, 6)
    minimizeBtn.BackgroundColor3 = Theme.SurfaceHighlight
    minimizeBtn.Text = "-"
    minimizeBtn.Font = Enum.Font.GothamBlack
    minimizeBtn.TextSize = 18
    minimizeBtn.TextColor3 = Theme.TextPrimary
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = header
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)
    local restoreBtn = Instance.new("TextButton")
    restoreBtn.Size = UDim2.new(0, 110, 0, 34)
    restoreBtn.Position = UDim2.new(0, 10, 1, -44)
    restoreBtn.BackgroundColor3 = Theme.SurfaceHighlight
    restoreBtn.Text = labelText or "OPEN"
    restoreBtn.Font = Enum.Font.GothamBold
    restoreBtn.TextSize = 12
    restoreBtn.TextColor3 = Theme.TextPrimary
    restoreBtn.Visible = false
    restoreBtn.AutoButtonColor = false
    restoreBtn.Parent = guiParent
    Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(0, 10)
    MakeDraggable(restoreBtn, restoreBtn)
    minimizeBtn.MouseButton1Click:Connect(function()
        frame.Visible = false
        restoreBtn.Visible = true
    end)
    restoreBtn.MouseButton1Click:Connect(function()
        frame.Visible = true
        restoreBtn.Visible = false
    end)
end
local function MakeDraggable(handle, target, saveKey)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if Config.UILocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if saveKey then
                        local parentSize = target.Parent.AbsoluteSize
                        Config.Positions[saveKey] = {
                            X = target.AbsolutePosition.X / parentSize.X,
                            Y = target.AbsolutePosition.Y / parentSize.Y,
                        }
                        SaveConfig()
                    end
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end
local function ShowNotification(title, text)
    local existing = PlayerGui:FindFirstChild("XiNotif")
    if existing then existing:Destroy() end
    local sg = Instance.new("ScreenGui", PlayerGui)
    sg.Name = "XiNotif"; sg.ResetOnSpawn = false
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 290, 0, 54)
    f.Position = UDim2.new(0.5, -145, 0, 80)
    f.BackgroundColor3 = Color3.fromRGB(12, 0, 0)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 9)
    local stroke = Instance.new("UIStroke", f)
    stroke.Thickness = 1; stroke.Color = Theme.Accent2; stroke.Transparency = 1
    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(0, 3, 1, -12); bar.Position = UDim2.new(0, 5, 0, 6)
    bar.BackgroundColor3 = Theme.Accent1; bar.BorderSizePixel = 0
    bar.BackgroundTransparency = 1
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local t1 = Instance.new("TextLabel", f)
    t1.Size = UDim2.new(1, -22, 0, 18); t1.Position = UDim2.new(0, 16, 0, 7)
    t1.BackgroundTransparency = 1; t1.Text = title:upper()
    t1.Font = Enum.Font.GothamBlack; t1.TextSize = 11
    t1.TextColor3 = Theme.Accent1; t1.TextXAlignment = Enum.TextXAlignment.Left
    t1.TextTransparency = 1
    local t2 = Instance.new("TextLabel", f)
    t2.Size = UDim2.new(1, -22, 0, 15); t2.Position = UDim2.new(0, 16, 0, 27)
    t2.BackgroundTransparency = 1; t2.Text = text
    t2.Font = Enum.Font.GothamMedium; t2.TextSize = 10
    t2.TextColor3 = Theme.TextSecondary; t2.TextXAlignment = Enum.TextXAlignment.Left
    t2.TextTransparency = 1
    local fadeIn = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(f,      fadeIn, {BackgroundTransparency = 0.08}):Play()
    TweenService:Create(stroke, fadeIn, {Transparency = 0.3}):Play()
    TweenService:Create(bar,    fadeIn, {BackgroundTransparency = 0}):Play()
    TweenService:Create(t1,     fadeIn, {TextTransparency = 0}):Play()
    TweenService:Create(t2,     fadeIn, {TextTransparency = 0}):Play()
    task.delay(2, function()
        if not sg.Parent then return end
        local fadeOut = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(f,      fadeOut, {BackgroundTransparency = 1}):Play()
        TweenService:Create(stroke, fadeOut, {Transparency = 1}):Play()
        TweenService:Create(bar,    fadeOut, {BackgroundTransparency = 1}):Play()
        TweenService:Create(t1,     fadeOut, {TextTransparency = 1}):Play()
        local last = TweenService:Create(t2, fadeOut, {TextTransparency = 1})
        last:Play(); last.Completed:Wait()
        if sg.Parent then sg:Destroy() end
    end)
end
local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end
local function handleAnimator(animator)
    local model = animator:FindFirstAncestorOfClass("Model")
    if model and isPlayerCharacter(model) then return end
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:Stop(0) end
    animator.AnimationPlayed:Connect(function(track) track:Stop(0) end)
end
local FPSBOOST_DESC_ADDED_CONN = nil
local FPSBOOST_LIGHTING_CONN   = nil
local FPSBOOST_MATERIAL_CONN   = nil
local FPSBOOST_PLAYER_CONNS    = {}
local FPSBOOST_GUARD_THREAD    = nil
local FPSBOOST_GC_THREAD       = nil
getgenv().DayLock = getgenv().DayLock or {
    Enabled = false,
    Hour    = 7,
    Refresh = 0,
}
if getgenv().DayLock.Enabled == nil then getgenv().DayLock.Enabled = false end
if type(getgenv().DayLock.Hour)    ~= "number" then getgenv().DayLock.Hour    = 7 end
if type(getgenv().DayLock.Refresh) ~= "number" then getgenv().DayLock.Refresh = 0 end
RunService.Heartbeat:Connect(function()
    local dl = getgenv().DayLock
    if dl and dl.Enabled then
        Lighting.ClockTime = dl.Hour
        Lighting.TimeOfDay = string.format("%02d:00:00", dl.Hour)
    end
    if Config.FPSBoostDarkMode then
        pcall(ApplyDarkModeLighting)
    end
end)
local setFPSBoost
do
    local TZ_XMin, TZ_XMax = -560, -240
    local TZ_ClothingClasses = {
        "Shirt","Pants","ShirtGraphic",
        "Accessory","Hat","HairAccessory",
        "FaceAccessory","NeckAccessory","ShoulderAccessory",
        "FrontAccessory","BackAccessory","WaistAccessory",
    }
    local TZ_BASE_NAMES = { "baseplate", "spawnlocation", "spawn location", "spawn" }
    local function TZ_SafeDestroy(obj)
        if obj.Name == "Overhead" then return end
        pcall(function() obj:Destroy() end)
    end
    local function TZ_IsClothing(obj)
        for _, c in ipairs(TZ_ClothingClasses) do
            if obj:IsA(c) then return true end
        end
    end
    local function TZ_IsCharacterPart(obj)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character and obj:IsDescendantOf(plr.Character) then
                return true
            end
        end
    end
    local function TZ_IsOutOfRange(obj)
        if obj:IsA("BasePart") then
            local x = obj.Position.X
            return x < TZ_XMin or x > TZ_XMax
        end
    end
    local function TZ_IsBase(obj)
        if not obj:IsA("BasePart") then return false end
        local nameLower = obj.Name:lower()
        for _, n in ipairs(TZ_BASE_NAMES) do
            if nameLower:find(n, 1, true) then return true end
        end
        return false
    end
    local function TZ_IsInBase(obj)
        local p = obj.Parent
        while p and p ~= workspace do
            if TZ_IsBase(p) then return true end
            p = p.Parent
        end
        return false
    end
    local function TZ_IsInPlot(obj)
        local p = obj.Parent
        while p and p ~= workspace do
            if p.Name == "Plots" and p.Parent == workspace then return true end
            p = p.Parent
        end
        return false
    end
    local function TZ_IsNameLabel(obj)
        return obj:IsA("BillboardGui") or obj:IsA("SurfaceGui")
    end
    local function TZ_IsInsideNameLabel(obj)
        local p = obj.Parent
        while p and p ~= workspace and p ~= game do
            if p:IsA("BillboardGui") or p:IsA("SurfaceGui") then return true end
            p = p.Parent
        end
        return false
    end
    local function TZ_MakeTransparent(obj)
        pcall(function()
            if TZ_IsBase(obj) and not TZ_IsCharacterPart(obj) then
                obj.Transparency = 1
                obj.CastShadow   = false
            end
        end)
    end
    local function TZ_StripObject(obj)
        pcall(function()
            if TZ_IsNameLabel(obj) or TZ_IsInsideNameLabel(obj) then return end
            if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then
                TZ_SafeDestroy(obj)
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
                or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                pcall(function() obj.Enabled = false end)
                TZ_SafeDestroy(obj)
            elseif obj:IsA("SurfaceAppearance") then
                TZ_SafeDestroy(obj)
            elseif obj:IsA("BasePart") then
                obj.CastShadow      = false
                obj.Material        = Enum.Material.Plastic
                obj.MaterialVariant = ""
                obj.Reflectance     = 0
            end
        end)
    end
    local function TZ_CleanObject(obj)
        pcall(function()
            if TZ_IsNameLabel(obj) or TZ_IsInsideNameLabel(obj) then return end
            if obj:IsA("SurfaceAppearance") then
                TZ_SafeDestroy(obj)
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                if not (obj.Name == "face" and obj.Parent and obj.Parent.Name == "Head") then
                    TZ_SafeDestroy(obj)
                end
            elseif obj:IsA("SpecialMesh") then
                obj.TextureId = ""
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                TZ_SafeDestroy(obj)
            elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                TZ_SafeDestroy(obj)
            elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Explosion") then
                TZ_SafeDestroy(obj)
            elseif obj:IsA("Animation") or obj:IsA("AnimationController") then
                TZ_SafeDestroy(obj)
            elseif obj:IsA("BasePart") then
                obj.CastShadow      = false
                obj.Material        = Enum.Material.Plastic
                obj.MaterialVariant = ""
                obj.Reflectance     = 0
            end
        end)
    end
    local function TZ_StopAnimations(animator)
        pcall(function()
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local isChar = false
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr.Character and animator:IsDescendantOf(plr.Character) then
                        isChar = true
                        break
                    end
                end
                if not isChar then track:Stop() end
            end
        end)
    end
    local function TZ_OptimizeCharacter(char)
        if not char then return end
        task.spawn(function()
            task.wait(0.3)
            for _, obj in ipairs(char:GetDescendants()) do
                if TZ_IsClothing(obj) then
                    TZ_SafeDestroy(obj)
                else
                    TZ_CleanObject(obj)
                end
            end
        end)
    end
    local function TZ_ApplyGreySky()
        pcall(function()
            for _, obj in ipairs(Lighting:GetChildren()) do
                if obj:IsA("Sky") then obj:Destroy() end
            end
            local sky = Instance.new("Sky")
            sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt = "", "", ""
            sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = "", "", ""
            sky.CelestialBodiesShown = false
            sky.Parent = Lighting
        end)
    end
    local function TZ_OptimizeLighting()
        Lighting.GlobalShadows            = false
        Lighting.FogEnd                   = 9e9
        Lighting.FogStart                 = 9e9
        Lighting.EnvironmentDiffuseScale  = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.Brightness               = 1.5
        Lighting.Ambient                  = Color3.fromRGB(60, 60, 60)
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("BlurEffect")
            or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect")
            or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere")
            or v:IsA("Clouds") then
                v:Destroy()
            end
        end
        TZ_ApplyGreySky()
    end
    local function TZ_ApplyTerrain()
        pcall(function()
            local T = workspace.Terrain
            T.Decoration        = false
            T.WaterWaveSize     = 0
            T.WaterWaveSpeed    = 0
            T.WaterReflectance  = 0
            T.WaterTransparency = 1
        end)
    end
    local function TZ_ProcessDescendant(obj)
        if TZ_IsInPlot(obj) then
            return
        end
        if TZ_IsNameLabel(obj) or TZ_IsInsideNameLabel(obj) then
            return
        end
        if TZ_IsBase(obj) then
            TZ_MakeTransparent(obj)
        elseif TZ_IsClothing(obj) then
            TZ_SafeDestroy(obj)
        elseif TZ_IsInBase(obj) then
        elseif TZ_IsCharacterPart(obj) then
        elseif TZ_IsOutOfRange(obj) then
            TZ_SafeDestroy(obj)
        else
            TZ_CleanObject(obj)
            TZ_StripObject(obj)
            if obj:IsA("Animator") then TZ_StopAnimations(obj) end
        end
    end
    function setFPSBoost(enabled)  
        Config.FPSBoost = enabled
        if FPSBOOST_DESC_ADDED_CONN then
            FPSBOOST_DESC_ADDED_CONN:Disconnect(); FPSBOOST_DESC_ADDED_CONN = nil
        end
        if FPSBOOST_LIGHTING_CONN then
            FPSBOOST_LIGHTING_CONN:Disconnect(); FPSBOOST_LIGHTING_CONN = nil
        end
        if FPSBOOST_MATERIAL_CONN then
            FPSBOOST_MATERIAL_CONN:Disconnect(); FPSBOOST_MATERIAL_CONN = nil
        end
        for _, c in ipairs(FPSBOOST_PLAYER_CONNS) do
            pcall(function() c:Disconnect() end)
        end
        FPSBOOST_PLAYER_CONNS = {}
        getgenv().DayLock = getgenv().DayLock or {}
        getgenv().DayLock.Hour    = 7
        getgenv().DayLock.Refresh = 0
        getgenv().DayLock.Enabled = enabled and true or false
        if enabled then
            pcall(function()
                settings().Rendering.QualityLevel        = Enum.QualityLevel.Level01
                settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
                settings().Physics.AllowSleep = true
                settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Skip
            end)
            pcall(function() setfpscap(999) end)
            TZ_OptimizeLighting()
            TZ_ApplyTerrain()
            task.spawn(function()
                task.wait(0.25)
                local descendants = workspace:GetDescendants()
                for i = 1, #descendants do
                    if not Config.FPSBoost then return end
                    TZ_ProcessDescendant(descendants[i])
                    if i % 150 == 0 then
                        RunService.Heartbeat:Wait()
                    end
                end
                pcall(function()
                    local plotsRoot = workspace:FindFirstChild("Plots")
                    if not plotsRoot then return end
                    local plotDescendants = plotsRoot:GetDescendants()
                    for i = 1, #plotDescendants do
                        local d = plotDescendants[i]
                        if (d:IsA("BillboardGui") or d:IsA("SurfaceGui"))
                            and d.Enabled == false then
                            d.Enabled = true
                        end
                        if i % 150 == 0 then
                            RunService.Heartbeat:Wait()
                        end
                    end
                end)
            end)
            FPSBOOST_DESC_ADDED_CONN = workspace.DescendantAdded:Connect(function(obj)
                if not Config.FPSBoost then return end
                task.defer(function() TZ_ProcessDescendant(obj) end)
                if (obj:IsA("BillboardGui") or obj:IsA("SurfaceGui"))
                    and TZ_IsInPlot(obj) then
                    task.defer(function()
                        if obj.Parent and obj.Enabled == false then
                            obj.Enabled = true
                        end
                    end)
                end
            end)
            FPSBOOST_LIGHTING_CONN = Lighting.DescendantAdded:Connect(function(obj)
                if not Config.FPSBoost then return end
                if obj:IsA("Atmosphere") or obj:IsA("Clouds") or obj:IsA("PostEffect") then
                    TZ_SafeDestroy(obj)
                end
            end)
            FPSBOOST_MATERIAL_CONN = game:GetService("MaterialService").DescendantAdded:Connect(function(obj)
                if not Config.FPSBoost then return end
                TZ_SafeDestroy(obj)
            end)
            for _, plr in ipairs(Players:GetPlayers()) do
                TZ_OptimizeCharacter(plr.Character)
                table.insert(FPSBOOST_PLAYER_CONNS,
                    plr.CharacterAdded:Connect(TZ_OptimizeCharacter))
            end
            table.insert(FPSBOOST_PLAYER_CONNS,
                Players.PlayerAdded:Connect(function(plr)
                    if not Config.FPSBoost then return end
                    table.insert(FPSBOOST_PLAYER_CONNS,
                        plr.CharacterAdded:Connect(TZ_OptimizeCharacter))
                end))
            if not FPSBOOST_GUARD_THREAD then
                FPSBOOST_GUARD_THREAD = task.spawn(function()
                    while true do
                        task.wait(2)
                        if Config.FPSBoost then
                            pcall(function()
                                for _, obj in ipairs(Lighting:GetChildren()) do
                                    if obj:IsA("Atmosphere") or obj:IsA("Clouds")
                                    or obj:IsA("PostEffect") then
                                        TZ_SafeDestroy(obj)
                                    end
                                end
                            end)
                        end
                    end
                end)
            end
            if not FPSBOOST_GC_THREAD then
                FPSBOOST_GC_THREAD = task.spawn(function()
                    while true do
                        task.wait(15)
                        if Config.FPSBoost then
                            pcall(function() collectgarbage("collect") end)
                        end
                    end
                end)
            end
            print("[Optimizer] Loaded ✓")
        end
        task.spawn(SaveConfig)
    end
end 
if Config.FPSBoost or Config.FPSBoostDarkMode then
    task.delay(0.1, function()
        if Config.FPSBoost then
            setFPSBoost(true)
        end
        if Config.FPSBoostDarkMode then
            pcall(ApplyDarkModeLighting)
        end
    end)
end
pcall(function() settings().Rendering.FrameRateManager = 0 end)
pcall(function() settings().Rendering.MaxFrameRate = 0 end)
local State = {
    ProximityAPActive = false,
    carpetSpeedEnabled = false,
    infiniteJumpEnabled = Config.TpSettings.InfiniteJump,
    antiRagdollMode = Config.AntiRagdoll or 0,
    floatActive = false,
    isTpMoving = false,
}
local Connections = {
    carpetSpeedConnection = nil,
    infiniteJumpConnection = nil,
    antiRagdollConn = nil,
    antiRagdollV2Task = nil,
}
local UI = {
    carpetStatusLabel = nil,
    settingsGui = nil,
}
local carpetSpeedEnabled = State.carpetSpeedEnabled
local carpetSpeedConnection = Connections.carpetSpeedConnection
local _carpetStatusLabel = UI.carpetStatusLabel
local function setCarpetSpeed(enabled)
    State.carpetSpeedEnabled = enabled
    carpetSpeedEnabled = State.carpetSpeedEnabled
    if Connections.carpetSpeedConnection then Connections.carpetSpeedConnection:Disconnect(); Connections.carpetSpeedConnection = nil end
    carpetSpeedConnection = Connections.carpetSpeedConnection
    if not enabled then return end
    if SharedState.DisableStealSpeed then SharedState.DisableStealSpeed() end
    local _carpetThread = task.spawn(function()
        while true do
            task.wait(0.03)
            if not (Connections.carpetSpeedConnection ~= false) then break end
            local c = LocalPlayer.Character
            if not c then continue end
            local hum = c:FindFirstChild("Humanoid")
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then continue end
            local toolName = Config.TpSettings.Tool
            local hasTool = c:FindFirstChild(toolName)
            if not hasTool then
                local tb = LocalPlayer.Backpack:FindFirstChild(toolName)
                if tb then hum:EquipTool(tb) end
            end
            if hasTool then
                local md = hum.MoveDirection
                if md.Magnitude > 0 then
                    hrp.Velocity = Vector3.new(md.X * 140, hrp.Velocity.Y, md.Z * 140)
                else
                    hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
                end
            end
        end
    end)
    Connections.carpetSpeedConnection = {Disconnect = function() task.cancel(_carpetThread); Connections.carpetSpeedConnection = false end}
end
do
    local function watchForToolEquip(char)
        if not char then return end
        char.ChildAdded:Connect(function(child)
            if not child:IsA("Tool") then return end
            if not State.carpetSpeedEnabled then return end
            local carpetName = Config.TpSettings.Tool
            if child.Name == carpetName then return end
            setCarpetSpeed(false)
            if _carpetStatusLabel then
                _carpetStatusLabel.Text = "OFF"
                _carpetStatusLabel.TextColor3 = Theme.Error
            end
            ShowNotification("CARPET SPEED", "OFF (auto, switched to " .. child.Name .. ")")
        end)
    end
    if LocalPlayer.Character then watchForToolEquip(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(watchForToolEquip)
end
local JumpData = {lastJumpTime = 0}
local infiniteJumpEnabled = State.infiniteJumpEnabled
local infiniteJumpConnection = Connections.infiniteJumpConnection
local function setInfiniteJump(enabled)
    State.infiniteJumpEnabled = enabled
    infiniteJumpEnabled = State.infiniteJumpEnabled
    Config.TpSettings.InfiniteJump = enabled
    SaveConfig()
    if Connections.infiniteJumpConnection then Connections.infiniteJumpConnection:Disconnect(); Connections.infiniteJumpConnection = nil end
    infiniteJumpConnection = Connections.infiniteJumpConnection
    if not enabled then return end
    local _ijThread = task.spawn(function()
        while true do
            task.wait(0.03)
            if not (Connections.infiniteJumpConnection ~= false) then break end
            if not UserInputService:IsKeyDown(Enum.KeyCode.Space) then continue end
            local now = tick()
            if now - JumpData.lastJumpTime < 0.1 then continue end
            local char = LocalPlayer.Character
            if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then continue end
            JumpData.lastJumpTime = now
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 55, hrp.Velocity.Z)
        end
    end)
    Connections.infiniteJumpConnection = {Disconnect = function() task.cancel(_ijThread); Connections.infiniteJumpConnection = false end}
end
if infiniteJumpEnabled then setInfiniteJump(true) end
local antiRagdollMode = State.antiRagdollMode
local antiRagdollConn = Connections.antiRagdollConn
local function isRagdolled()
    local char = LocalPlayer.Character; if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    local state = hum:GetState()
    local ragStates = {
        [Enum.HumanoidStateType.Physics]     = true,
        [Enum.HumanoidStateType.Ragdoll]     = true,
        [Enum.HumanoidStateType.FallingDown] = true,
    }
    if ragStates[state] then return true end
    local endTime = LocalPlayer:GetAttribute("RagdollEndTime")
    if endTime and (endTime - Workspace:GetServerTimeNow()) > 0 then return true end
    return false
end
local function stopAntiRagdoll()
    if Connections.antiRagdollConn then Connections.antiRagdollConn:Disconnect(); Connections.antiRagdollConn = nil end
    antiRagdollConn = Connections.antiRagdollConn
end
local function startAntiRagdoll(mode)
    stopAntiRagdoll()
    if Config.AntiRagdollV2 then
        stopAntiRagdollV2()
    end
    if mode == 0 then return end
    local _arThread = task.spawn(function()
        while true do
            task.wait(0.03)
            if not (Connections.antiRagdollConn ~= false) then break end
            local char = LocalPlayer.Character; if not char then continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then continue end
            if isRagdolled() then
                pcall(function() LocalPlayer:SetAttribute("RagdollEndTime", Workspace:GetServerTimeNow()) end)
                hum:ChangeState(Enum.HumanoidStateType.Running)
                hrp.Velocity = Vector3.zero
                if Workspace.CurrentCamera.CameraSubject ~= hum then
                    Workspace.CurrentCamera.CameraSubject = hum
                end
                for _, obj in ipairs(char:GetDescendants()) do
                    if obj:IsA("BallSocketConstraint") or obj.Name:find("RagdollAttachment") then
                        pcall(function() obj:Destroy() end)
                    end
                end
            end
        end
    end)
    Connections.antiRagdollConn = {Disconnect = function() task.cancel(_arThread); Connections.antiRagdollConn = false end}
end
local AntiRagdollV2Data = {
    antiRagdollConns = {},
}
local antiRagdollConns = AntiRagdollV2Data.antiRagdollConns
local cleanRagdollV2Scheduled = false
local function cleanRagdollV2(char)
    if not char then return end
    local carpetEquipped = false
    pcall(function()
        local toolName = Config.TpSettings.Tool or "Flying Carpet"
        local tool = char:FindFirstChild(toolName)
        if tool then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in ipairs(hrp:GetChildren()) do
                    if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                        carpetEquipped = true
                        break
                    end
                end
            end
            if not carpetEquipped then
                for _, obj in ipairs(tool:GetChildren()) do
                    if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                        carpetEquipped = true
                        break
                    end
                end
            end
        end
    end)
    local descendants = char:GetDescendants()
    for _, d in ipairs(descendants) do
        if d:IsA("BallSocketConstraint") or d:IsA("NoCollisionConstraint")
            or d:IsA("HingeConstraint")
            or (d:IsA("Attachment") and (d.Name == "A" or d.Name == "B")) then
            d:Destroy()
        elseif (d:IsA("BodyVelocity") or d:IsA("BodyPosition") or d:IsA("BodyGyro")) and not carpetEquipped then
            d:Destroy()
        end
    end
    for _, d in ipairs(descendants) do
        if d:IsA("Motor6D") then d.Enabled = true end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local animator = hum:FindFirstChild("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local n = track.Animation and track.Animation.Name:lower() or ""
                if n:find("rag") or n:find("fall") or n:find("hurt") or n:find("down") then
                    track:Stop(0)
                end
            end
        end
    end
    task.defer(function()
        pcall(function()
            local pm = LocalPlayer:FindFirstChild("PlayerScripts")
            if pm then pm = pm:FindFirstChild("PlayerModule") end
            if pm then require(pm):GetControls():Enable() end
        end)
    end)
end
local function cleanRagdollV2Debounced(char)
    if cleanRagdollV2Scheduled then return end
    cleanRagdollV2Scheduled = true
    task.defer(function()
        cleanRagdollV2Scheduled = false
        if char and char.Parent then cleanRagdollV2(char) end
    end)
end
local function isRagdollRelatedDescendant(obj)
    if obj:IsA("BallSocketConstraint") or obj:IsA("NoCollisionConstraint") or obj:IsA("HingeConstraint") then return true end
    if obj:IsA("Attachment") and (obj.Name == "A" or obj.Name == "B") then return true end
    if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then return true end
    return false
end
local function hookAntiRagV2(char)
    for _, c in ipairs(antiRagdollConns) do pcall(function() c:Disconnect() end) end
    AntiRagdollV2Data.antiRagdollConns = {}
    antiRagdollConns = AntiRagdollV2Data.antiRagdollConns
    local hum = char:WaitForChild("Humanoid", 10)
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if not hum or not hrp then return end
    local lastVel = Vector3.new(0, 0, 0)
    local c1 = hum.StateChanged:Connect(function()
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll
            or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.GettingUp then
            local carpetActive = false
            pcall(function()
                local toolName = Config.TpSettings.Tool or "Flying Carpet"
                local tool = char:FindFirstChild(toolName)
                if tool and hrp then
                    for _, obj in ipairs(hrp:GetChildren()) do
                        if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                            carpetActive = true
                        end
                    end
                end
            end)
            if not carpetActive then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
            cleanRagdollV2(char)
            pcall(function() Workspace.CurrentCamera.CameraSubject = hum end)
            pcall(function()
                local pm = LocalPlayer:FindFirstChild("PlayerScripts")
                if pm then pm = pm:FindFirstChild("PlayerModule") end
                if pm then require(pm):GetControls():Enable() end
            end)
        end
    end)
    table.insert(antiRagdollConns, c1)
    local c2 = char.DescendantAdded:Connect(function(desc)
        if isRagdollRelatedDescendant(desc) then
            cleanRagdollV2Debounced(char)
        end
    end)
    table.insert(antiRagdollConns, c2)
    pcall(function()
        local pkg = ReplicatedStorage:FindFirstChild("Packages")
        if pkg then
            local net = pkg:FindFirstChild("Net")
            if net then
                local applyImp = net:FindFirstChild("RE/CombatService/ApplyImpulse")
                if applyImp and applyImp:IsA("RemoteEvent") then
                    local c3 = applyImp.OnClientEvent:Connect(function()
                        local st = hum:GetState()
                        if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll
                            or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.GettingUp then
                            pcall(function() hrp.Velocity = Vector3.new(0, 0, 0) end)
                        end
                    end)
                    table.insert(antiRagdollConns, c3)
                end
            end
        end
    end)
    local _c4Active = true
    local c4Thread = task.spawn(function()
        while _c4Active do
            task.wait(0.05)
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll
                or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.GettingUp then
                cleanRagdollV2(char)
                local vel = hrp.Velocity
                if (vel - lastVel).Magnitude > 40 and vel.Magnitude > 25 then
                    hrp.Velocity = vel.Unit * math.min(vel.Magnitude, 15)
                end
            end
            lastVel = hrp.Velocity
        end
    end)
    local c4 = {Disconnect = function() _c4Active = false; task.cancel(c4Thread) end}
    table.insert(antiRagdollConns, c4)
    cleanRagdollV2(char)
end
local function stopAntiRagdollV2()
    cleanRagdollV2Scheduled = false
    for _, c in ipairs(antiRagdollConns) do pcall(function() c:Disconnect() end) end
    AntiRagdollV2Data.antiRagdollConns = {}
    antiRagdollConns = AntiRagdollV2Data.antiRagdollConns
end
local function startAntiRagdollV2(enabled)
    stopAntiRagdoll()
    stopAntiRagdollV2()
    if not enabled then
        return
    end
    local char = LocalPlayer.Character
    if char then task.spawn(function() hookAntiRagV2(char) end) end
    LocalPlayer.CharacterAdded:Connect(function(c)
        task.spawn(function() hookAntiRagV2(c) end)
    end)
end
if antiRagdollMode > 0 then startAntiRagdoll(antiRagdollMode) end
if Config.AntiRagdollV2 then startAntiRagdollV2(true) end
do
    local plotBeam = nil
    local plotBeamAttachment0 = nil
    local plotBeamAttachment1 = nil
    local function findMyPlot()
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil end
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local surfaceGui = sign:FindFirstChildWhichIsA("SurfaceGui", true)
                if surfaceGui then
                    local label = surfaceGui:FindFirstChildWhichIsA("TextLabel", true)
                    if label then
                        local text = label.Text:lower()
                        if text:find(LocalPlayer.DisplayName:lower(), 1, true) or text:find(LocalPlayer.Name:lower(), 1, true) then
                            return plot
                        end
                    end
                end
            end
        end
        return nil
    end
    local function createPlotBeam()
        if not Config.LineToBase then return end
        local myPlot = findMyPlot()
        if not myPlot or not myPlot.Parent then return end
        local character = LocalPlayer.Character
        if not character or not character.Parent then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp or not hrp.Parent then return end
        if plotBeam then pcall(function() plotBeam:Destroy() end) end
        if plotBeamAttachment0 then pcall(function() plotBeamAttachment0:Destroy() end) end
        plotBeamAttachment0 = hrp:FindFirstChild("PlotBeamAttach_Player") or Instance.new("Attachment")
        plotBeamAttachment0.Name = "PlotBeamAttach_Player"
        plotBeamAttachment0.Position = Vector3.new(0, 0, 0)
        plotBeamAttachment0.Parent = hrp
        local plotPart = myPlot:FindFirstChild("MainRootPart") or myPlot:FindFirstChildWhichIsA("BasePart")
        if not plotPart or not plotPart.Parent then return end
        plotBeamAttachment1 = plotPart:FindFirstChild("PlotBeamAttach_Plot") or Instance.new("Attachment")
        plotBeamAttachment1.Name = "PlotBeamAttach_Plot"
        plotBeamAttachment1.Position = Vector3.new(0, 5, 0)
        plotBeamAttachment1.Parent = plotPart
        plotBeam = hrp:FindFirstChild("PlotBeam") or Instance.new("Beam")
        plotBeam.Name = "PlotBeam"
        plotBeam.Attachment0 = plotBeamAttachment0
        plotBeam.Attachment1 = plotBeamAttachment1
        plotBeam.FaceCamera = true
        plotBeam.LightEmission = 1
        plotBeam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        plotBeam.Transparency = NumberSequence.new(0)
        plotBeam.Width0 = 0.7
        plotBeam.Width1 = 0.7
        plotBeam.TextureMode = Enum.TextureMode.Wrap
        plotBeam.TextureSpeed = 0
        plotBeam.Parent = hrp
    end
    local function resetPlotBeam()
        if plotBeam then pcall(function() plotBeam:Destroy() end) end
        if plotBeamAttachment0 then pcall(function() plotBeamAttachment0:Destroy() end) end
        if plotBeamAttachment1 then pcall(function() plotBeamAttachment1:Destroy() end) end
        plotBeam = nil
        plotBeamAttachment0 = nil
        plotBeamAttachment1 = nil
    end
    task.spawn(function()
        while true do
            task.wait(1.5)
            if not Config.LineToBase then continue end
            if not plotBeam or not plotBeam.Parent or not plotBeamAttachment0 or not plotBeamAttachment0.Parent then
                pcall(createPlotBeam)
            end
        end
    end)
    LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if Config.LineToBase and character then
            pcall(createPlotBeam)
        end
    end)
    if LocalPlayer.Character then
        task.spawn(function()
            task.wait(0.2)
            if Config.LineToBase then createPlotBeam() end
        end)
    end
    _G.createPlotBeam = createPlotBeam
    _G.resetPlotBeam = resetPlotBeam
end
task.spawn(function()
    local Packages = ReplicatedStorage:WaitForChild("Packages")
    local Datas    = ReplicatedStorage:WaitForChild("Datas")
    local Shared   = ReplicatedStorage:WaitForChild("Shared")
    local Utils    = ReplicatedStorage:WaitForChild("Utils")
    local Synchronizer  = _G.ZawaRawSync
    local AnimalsData   = require(Datas:WaitForChild("Animals"))
    local AnimalsShared = require(Shared:WaitForChild("Animals"))
    local NumberUtils   = require(Utils:WaitForChild("NumberUtils"))
    local autoStealEnabled   = (Config.AutoStealEnabled ~= false)
    if Config.DefaultToPriority and Config.DefaultToHighest then
        Config.DefaultToHighest = false
    end
    if Config.DefaultToPriority and Config.DefaultToNearest then
        Config.DefaultToNearest = false
    end
    if Config.DefaultToHighest and Config.DefaultToNearest then
        Config.DefaultToNearest = false
    end
    if not Config.DefaultToPriority and not Config.DefaultToHighest and not Config.DefaultToNearest then
        Config.DefaultToHighest = true
    end
    local stealNearestEnabled = false
    local stealHighestEnabled = false
    local stealPriorityEnabled = false
    if Config.DefaultToNearest then
        stealNearestEnabled = true
        Config.StealNearest = true
        Config.StealHighest = false
        Config.StealPriority = false
        Config.AutoTPPriority = true
    elseif Config.DefaultToHighest then
        stealHighestEnabled = true
        Config.StealHighest = true
        Config.StealNearest = false
        Config.StealPriority = false
        Config.AutoTPPriority = false
    elseif Config.DefaultToPriority then
        stealPriorityEnabled = true
        Config.StealPriority = true
        Config.StealNearest = false
        Config.StealHighest = false
        Config.AutoTPPriority = true
    else
        stealNearestEnabled = Config.StealNearest
        stealHighestEnabled = Config.StealHighest
        stealPriorityEnabled = Config.StealPriority
        if Config.StealPriority then
            Config.AutoTPPriority = true
        elseif Config.StealNearest then
            Config.AutoTPPriority = true
        elseif Config.StealHighest then
            Config.AutoTPPriority = false
        end
    end
    local selectedTargetIndex = 1
    local selectedTargetUID   = nil 
    local priorityLockHeld    = false  
    local allAnimalsCache    = {}
    local InternalStealCache = {}
    local PromptMemoryCache  = {}
    local activeProgressTween = nil
    local currentStealTargetUID = nil
    local petButtons         = {}
    local lastAnimalData = {}
    local scanSinglePlot   
    local updateUI         
    local function isMyBaseAnimal(animalData)
        if not animalData or not animalData.plot then return false end
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return false end
        local plot = plots:FindFirstChild(animalData.plot)
        if not plot then return false end
        local channel = Synchronizer.caches[plot.Name]
        if channel then
            local owner = channel.Owner
            if owner then
                if typeof(owner) == "Instance" and owner:IsA("Player") then return owner.UserId == LocalPlayer.UserId
                elseif typeof(owner) == "table" and owner.UserId then return owner.UserId == LocalPlayer.UserId
                elseif typeof(owner) == "Instance" then return owner == LocalPlayer end
            end
        end
        return false
    end
    local function formatMutationText(mutationName)
        if not mutationName or mutationName == "None" then return "" end
        local f = ""
        if mutationName == "Cursed" then f = "<font color='rgb(200,0,0)'>Cur</font><font color='rgb(0,0,0)'>sed</font>"
        elseif mutationName == "Gold" then f = "<font color='rgb(255,215,0)'>Gold</font>"
        elseif mutationName == "Diamond" then f = "<font color='rgb(0,255,255)'>Diamond</font>"
        elseif mutationName == "YinYang" then f = "<font color='rgb(255,255,255)'>Yin</font><font color='rgb(0,0,0)'>Yang</font>"
        elseif mutationName == "Candy" then f = "<font color='rgb(255,105,180)'>Candy</font>"
        elseif mutationName == "Divine" then f = "<font color='rgb(255,255,255)'>Divine</font>"
        elseif mutationName == "Rainbow" then
            local cols = {"rgb(255,0,0)","rgb(255,127,0)","rgb(255,255,0)","rgb(0,255,0)","rgb(0,0,255)","rgb(75,0,130)","rgb(148,0,211)"}
            for i = 1, #mutationName do f = f.."<font color='"..cols[(i-1)%#cols+1].."'>"..mutationName:sub(i,i).."</font>" end
        else f = mutationName end
        return "<font weight='800'>"..f.." </font>"
    end
    local function get_all_pets()
        local out = {}
        for _, a in ipairs(allAnimalsCache) do
            local ownerStillHere = a.owner and Players:FindFirstChild(a.owner) ~= nil
            if ownerStillHere and a.genValue >= 1 and not isMyBaseAnimal(a) then
                table.insert(out, {petName=a.name, mpsText=a.genText, mpsValue=a.genValue,
                    owner=a.owner, plot=a.plot, slot=a.slot, uid=a.uid, mutation=a.mutation, animalData=a})
            end
        end
        table.sort(out, function(a, b) return (a.mpsValue or 0) > (b.mpsValue or 0) end)
        return out
    end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoStealUI"; screenGui.ResetOnSpawn = false; screenGui.Parent = PlayerGui
    local mobileScale = IS_MOBILE and 0.6 or 1
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 340*mobileScale, 0, 600*mobileScale)
    frame.Position = UDim2.new(Config.Positions.AutoSteal.X, 0, Config.Positions.AutoSteal.Y, 0)
    frame.BackgroundColor3 = Color3.fromRGB(12, 0, 0)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = screenGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 18)
    local mainStroke = Instance.new("UIStroke", frame)
    mainStroke.Color = Color3.fromRGB(130, 15, 15)
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0
    ApplyViewportUIScale(frame, 280, 540, 0.45, 0.7)
    AddMobileMinimize(frame, "HEROZ")
    local header = Instance.new("Frame", frame)
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(20, 4, 4)
    header.BackgroundTransparency = 0
    header.BorderSizePixel = 0
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)
    local headerFix = Instance.new("Frame", header)
    headerFix.Size = UDim2.new(1, 0, 0.5, 0)
    headerFix.Position = UDim2.new(0, 0, 0.5, 0)
    headerFix.BackgroundColor3 = Color3.fromRGB(20, 4, 4)
    headerFix.BorderSizePixel = 0
    MakeDraggable(header, frame, "AutoSteal")
    AddResizeHandle(frame, "AutoSteal", UDim2.new(1, -22, 0, 6))
    local logoCircle = Instance.new("Frame", header)
    logoCircle.Size = UDim2.new(0, 28, 0, 28)
    logoCircle.Position = UDim2.new(0, 10, 0.5, 0)
    logoCircle.AnchorPoint = Vector2.new(0, 0.5)
    logoCircle.BackgroundColor3 = Color3.fromRGB(18, 3, 3)
    logoCircle.BorderSizePixel = 0
    logoCircle.Visible = false
    Instance.new("UICorner", logoCircle).CornerRadius = UDim.new(0, 8)
    local logoStroke = Instance.new("UIStroke", logoCircle)
    logoStroke.Color = Color3.fromRGB(160, 20, 20)
    logoStroke.Thickness = 1.5
    local logoLbl = Instance.new("TextLabel", logoCircle)
    logoLbl.Size = UDim2.new(1, 0, 1, 0)
    logoLbl.BackgroundTransparency = 1
    logoLbl.Text = "R"
    logoLbl.Font = Enum.Font.GothamBlack
    logoLbl.TextSize = 14
    logoLbl.TextColor3 = Color3.fromRGB(250, 210, 210)
    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = IS_MOBILE and UDim2.new(0.5, 0, 1, 0) or UDim2.new(0.55, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 14, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "HEROZ"
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 18
    titleLabel.TextColor3 = Color3.fromRGB(255, 220, 220)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    local stealRefreshBtn = Instance.new("TextButton", header)
    stealRefreshBtn.Size = UDim2.new(0, 70, 0, 26)
    stealRefreshBtn.Position = UDim2.new(1, -78, 0.5, -13)
    stealRefreshBtn.BackgroundColor3 = Color3.fromRGB(30, 6, 6)
    stealRefreshBtn.Text = "REFRESH"
    stealRefreshBtn.Font = Enum.Font.GothamBold
    stealRefreshBtn.TextSize = 11
    stealRefreshBtn.TextColor3 = Color3.fromRGB(255, 220, 220)
    stealRefreshBtn.AutoButtonColor = false
    stealRefreshBtn.BorderSizePixel = 0
    Instance.new("UICorner", stealRefreshBtn).CornerRadius = UDim.new(0, 6)
    local stealRefreshStroke = Instance.new("UIStroke", stealRefreshBtn)
    stealRefreshStroke.Color = Theme.Accent2
    stealRefreshStroke.Thickness = 1
    stealRefreshStroke.Transparency = 0.3
    stealRefreshBtn.MouseEnter:Connect(function()
        stealRefreshBtn.BackgroundColor3 = Color3.fromRGB(60, 22, 44)
        stealRefreshStroke.Transparency = 0.05
    end)
    stealRefreshBtn.MouseLeave:Connect(function()
        stealRefreshBtn.BackgroundColor3 = Color3.fromRGB(30, 6, 6)
        stealRefreshStroke.Transparency = 0.3
    end)
    stealRefreshBtn.MouseButton1Click:Connect(function()
        for i = #allAnimalsCache, 1, -1 do
            table.remove(allAnimalsCache, i)
        end
        for plotName, _ in pairs(lastAnimalData) do
            lastAnimalData[plotName] = ""
        end
        local plots = Workspace:FindFirstChild("Plots")
        if plots then
            for _, p in ipairs(plots:GetChildren()) do
                pcall(scanSinglePlot, p)
            end
        end
        SharedState.ListNeedsRedraw = true
        pcall(function() updateUI(autoStealEnabled, get_all_pets()) end)
        ShowNotification("STEAL PANEL", "List refreshed")
    end)
    local subLabel = Instance.new("TextLabel", header)
    subLabel.Size = UDim2.new(0.6, 0, 0, 14)
    subLabel.Position = UDim2.new(0, 46, 0, 28)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = ""
    subLabel.Font = Enum.Font.GothamMedium
    subLabel.TextSize = 10
    subLabel.TextColor3 = Color3.fromRGB(170, 65, 65)
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.Visible = false
    if IS_MOBILE then
        local menuToggleBtn = Instance.new("TextButton", header)
        menuToggleBtn.Size = UDim2.new(0, 60, 0, 24)
        menuToggleBtn.Position = UDim2.new(1, -68, 0.5, -12)
        menuToggleBtn.BackgroundColor3 = Color3.fromRGB(18, 3, 3)
        menuToggleBtn.Text = "MENU"
        menuToggleBtn.Font = Enum.Font.GothamBold
        menuToggleBtn.TextSize = 10
        menuToggleBtn.TextColor3 = Color3.fromRGB(240, 200, 215)
        Instance.new("UICorner", menuToggleBtn).CornerRadius = UDim.new(0, 6)
        menuToggleBtn.MouseButton1Click:Connect(function()
            if settingsGui then settingsGui.Enabled = not settingsGui.Enabled end
        end)
    end
    local statusRow = Instance.new("Frame", frame)
    statusRow.Size = UDim2.new(1, -20, 0, 42)
    statusRow.Position = UDim2.new(0, 10, 0, 58)
    statusRow.BackgroundColor3 = Color3.fromRGB(20, 4, 4)
    statusRow.BorderSizePixel = 0
    statusRow.Visible = false
    Instance.new("UICorner", statusRow).CornerRadius = UDim.new(0, 10)
    local statusDot = Instance.new("Frame", statusRow)
    statusDot.Size = UDim2.new(0, 7, 0, 7)
    statusDot.Position = UDim2.new(0, 10, 0.35, 0)
    statusDot.AnchorPoint = Vector2.new(0, 0.5)
    statusDot.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
    statusDot.BorderSizePixel = 0
    Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)
    local stealStatusLbl = Instance.new("TextLabel", statusRow)
    stealStatusLbl.Size = UDim2.new(0.5, 0, 0, 16)
    stealStatusLbl.Position = UDim2.new(0, 22, 0, 5)
    stealStatusLbl.BackgroundTransparency = 1
    stealStatusLbl.Text = "Steal: Idle"
    stealStatusLbl.Font = Enum.Font.GothamMedium
    stealStatusLbl.TextSize = 11
    stealStatusLbl.TextColor3 = Color3.fromRGB(210, 110, 110)
    stealStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
    local targetLabel = Instance.new("TextLabel", statusRow)
    targetLabel.Size = UDim2.new(1, -24, 0, 14)
    targetLabel.Position = UDim2.new(0, 22, 0, 23)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "No target"
    targetLabel.Font = Enum.Font.GothamBold
    targetLabel.TextSize = 11
    targetLabel.TextColor3 = Color3.fromRGB(185, 80, 80)
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.TextTruncate = Enum.TextTruncate.AtEnd
    local targetsLbl = Instance.new("TextLabel", statusRow)
    targetsLbl.Size = UDim2.new(0, 80, 0, 14)
    targetsLbl.Position = UDim2.new(1, -86, 0, 5)
    targetsLbl.BackgroundTransparency = 1
    targetsLbl.Text = "Targets: 0"
    targetsLbl.Font = Enum.Font.GothamBold
    targetsLbl.TextSize = 9
    targetsLbl.TextColor3 = Color3.fromRGB(170, 65, 65)
    targetsLbl.TextXAlignment = Enum.TextXAlignment.Right
    local playersLbl = Instance.new("TextLabel", statusRow)
    playersLbl.Size = UDim2.new(0, 80, 0, 14)
    playersLbl.Position = UDim2.new(1, -86, 0, 22)
    playersLbl.BackgroundTransparency = 1
    playersLbl.Text = "Players: 0"
    playersLbl.Font = Enum.Font.GothamBold
    playersLbl.TextSize = 9
    playersLbl.TextColor3 = Color3.fromRGB(170, 65, 65)
    playersLbl.TextXAlignment = Enum.TextXAlignment.Right
    local progressBg = Instance.new("Frame", statusRow)
    progressBg.Size = UDim2.new(1, 0, 0, 3)
    progressBg.Position = UDim2.new(0, 0, 1, -3)
    progressBg.BackgroundColor3 = Color3.fromRGB(35, 8, 8)
    progressBg.BorderSizePixel = 0
    local progressBarFill = Instance.new("Frame", progressBg)
    progressBarFill.Size = UDim2.new(0, 0, 1, 0)
    progressBarFill.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
    progressBarFill.BorderSizePixel = 0
    Instance.new("UICorner", progressBarFill).CornerRadius = UDim.new(1, 0)
    Instance.new("UICorner", progressBg).CornerRadius = UDim.new(1, 0)
    local selectLabel = Instance.new("TextLabel", frame)
    selectLabel.Size = UDim2.new(1, -20, 0, 16)
    selectLabel.Position = UDim2.new(0, 10, 0, 56)
    selectLabel.BackgroundTransparency = 1
    selectLabel.Text = "◆ AVAILABLE BRAINROTS ◆"
    selectLabel.Font = Enum.Font.GothamBlack
    selectLabel.TextSize = 9
    selectLabel.TextColor3 = Color3.fromRGB(170, 65, 65)
    selectLabel.TextXAlignment = Enum.TextXAlignment.Left
    local listFrame = Instance.new("ScrollingFrame", frame)
    listFrame.Size = UDim2.new(1, -12, 1, -94)
    listFrame.Position = UDim2.new(0, 6, 0, 78)
    listFrame.BackgroundTransparency = 1
    listFrame.BorderSizePixel = 0
    listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    listFrame.ScrollBarThickness = 2
    listFrame.ScrollBarImageColor3 = Color3.fromRGB(160, 20, 20)
    local uiListLayout = Instance.new("UIListLayout", listFrame)
    uiListLayout.Padding = UDim.new(0, 4)
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", listFrame).PaddingLeft = UDim.new(0, 4)
    local toggleBtnContainer = Instance.new("Frame", frame)
    toggleBtnContainer.Size = UDim2.new(1, -20, 0, 96)
    toggleBtnContainer.Position = UDim2.new(0, 10, 1, -106)
    toggleBtnContainer.BackgroundTransparency = 1
    toggleBtnContainer.Visible = false
    local enableBtn = Instance.new("TextButton", toggleBtnContainer)
    local mobileButtonScale = IS_MOBILE and 1.3 or 1
    enableBtn.Size = UDim2.new(1, 0, 0, 36*mobileButtonScale)
    enableBtn.Position = UDim2.new(0, 0, 0, 0)
    enableBtn.BackgroundColor3 = Theme.Success
    enableBtn.Text = "AUTO STEAL: ON"
    enableBtn.Font = Enum.Font.GothamBlack
    enableBtn.TextSize = 12*mobileButtonScale
    enableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enableBtn.BorderSizePixel = 0
    enableBtn.AutoButtonColor = false
    Instance.new("UICorner", enableBtn).CornerRadius = UDim.new(0, 10)
    enableBtn.MouseEnter:Connect(function()
        enableBtn.BackgroundTransparency = 0.15
    end)
    enableBtn.MouseLeave:Connect(function()
        enableBtn.BackgroundTransparency = 0
    end)
    local customizePriorityBtn = Instance.new("TextButton", toggleBtnContainer)
    customizePriorityBtn.Size = UDim2.new(1, 0, 0, 20)
    customizePriorityBtn.Position = UDim2.new(0, 0, 0, 74*mobileButtonScale)
    customizePriorityBtn.BackgroundColor3 = Color3.fromRGB(45, 10, 10)
    customizePriorityBtn.Text = "Customize Priority"
    customizePriorityBtn.Font = Enum.Font.GothamMedium
    customizePriorityBtn.TextSize = 10
    customizePriorityBtn.TextColor3 = Color3.fromRGB(180, 75, 75)
    customizePriorityBtn.BorderSizePixel = 0
    customizePriorityBtn.AutoButtonColor = false
    customizePriorityBtn.Visible = not IS_MOBILE
    Instance.new("UICorner", customizePriorityBtn).CornerRadius = UDim.new(0, 6)
    customizePriorityBtn.MouseButton1Click:Connect(function()
        local priorityGui = PlayerGui:FindFirstChild("PriorityListGUI")
        if priorityGui then priorityGui.Enabled = not priorityGui.Enabled end
    end)
    local function makeModeRow(parent, labelText, yPos, isOn, onToggle)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, 0, 0, 34)
        row.Position = UDim2.new(0, 0, 0, yPos)
        row.BackgroundTransparency = 1
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextColor3 = Color3.fromRGB(250, 215, 215)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        local pill = Instance.new("TextButton", row)
        pill.Size = UDim2.new(0, 54, 0, 24)
        pill.Position = UDim2.new(1, -64, 0.5, -12)
        pill.Font = Enum.Font.GothamBlack
        pill.TextSize = 11
        pill.BorderSizePixel = 0
        pill.AutoButtonColor = false
        Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 6)
        local function refresh(on)
            pill.Text = on and "ON" or "OFF"
            pill.BackgroundColor3 = on and Color3.fromRGB(255, 30, 30) or Color3.fromRGB(30, 6, 6)
            pill.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(185, 80, 80)
        end
        refresh(isOn)
        pill.MouseButton1Click:Connect(function()
            local newState = onToggle()
            refresh(newState)
        end)
        return row, refresh
    end
    local refreshHighest, refreshPriority, refreshNearest
    local nearestBtn = Instance.new("TextButton"); nearestBtn.Visible = false; nearestBtn.Parent = frame
    local highestBtn = Instance.new("TextButton"); highestBtn.Visible = false; highestBtn.Parent = frame
    local priorityBtn = Instance.new("TextButton"); priorityBtn.Visible = false; priorityBtn.Parent = frame
    do
        local tcGui = Instance.new("ScreenGui")
        tcGui.Name = "TargetControlsUI"
        tcGui.ResetOnSpawn = false
        tcGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        tcGui.Parent = PlayerGui
        local TC_W = 220
        local tcFrame = Instance.new("Frame", tcGui)
        tcFrame.Size = UDim2.new(0, TC_W, 0, 50)
        local _tcPos = Config.Positions.TargetControls or {X = 0.5, Y = 0.3}
        tcFrame.Position = UDim2.new(_tcPos.X, 0, _tcPos.Y, 0)
        tcFrame.BackgroundColor3 = Color3.fromRGB(12, 0, 0)
        tcFrame.BackgroundTransparency = 0.15
        tcFrame.BorderSizePixel = 0
        tcFrame.ClipsDescendants = false
        Instance.new("UICorner", tcFrame).CornerRadius = UDim.new(0, 14)
        local tcStroke = Instance.new("UIStroke", tcFrame)
        tcStroke.Color = Color3.fromRGB(255, 30, 30)
        tcStroke.Thickness = 2
        local tcHeader = Instance.new("Frame", tcFrame)
        tcHeader.Size = UDim2.new(1, 0, 0, 38)
        tcHeader.BackgroundColor3 = Color3.fromRGB(20, 4, 4)
        tcHeader.BorderSizePixel = 0
        Instance.new("UICorner", tcHeader).CornerRadius = UDim.new(0, 14)
        local tcHeaderFix = Instance.new("Frame", tcHeader)
        tcHeaderFix.Size = UDim2.new(1, 0, 0.5, 0)
        tcHeaderFix.Position = UDim2.new(0, 0, 0.5, 0)
        tcHeaderFix.BackgroundColor3 = Color3.fromRGB(20, 4, 4)
        tcHeaderFix.BorderSizePixel = 0
        local tcTitle = Instance.new("TextLabel", tcHeader)
        tcTitle.Size = UDim2.new(1, -16, 1, 0)
        tcTitle.Position = UDim2.new(0, 12, 0, 0)
        tcTitle.BackgroundTransparency = 1
        tcTitle.Text = "TARGET CONTROLS"
        tcTitle.Font = Enum.Font.GothamBlack
        tcTitle.TextSize = 12
        tcTitle.TextColor3 = Color3.fromRGB(255, 220, 220)
        tcTitle.TextXAlignment = Enum.TextXAlignment.Left
        MakeDraggable(tcHeader, tcFrame, "TargetControls")
        AddResizeHandle(tcFrame, "TargetControls", UDim2.new(1, -22, 0, 8))
        local function makeTCRow(labelText, yPos, isOn, onToggle)
            local row = Instance.new("Frame", tcFrame)
            row.Size = UDim2.new(1, -20, 0, 30)
            row.Position = UDim2.new(0, 10, 0, yPos)
            row.BackgroundTransparency = 1
            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(0.6, 0, 1, 0)
            lbl.Position = UDim2.new(0, 4, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = labelText
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 12
            lbl.TextColor3 = Color3.fromRGB(250, 210, 210)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            local pill = Instance.new("TextButton", row)
            pill.Size = UDim2.new(0, 54, 0, 22)
            pill.Position = UDim2.new(1, -58, 0.5, -11)
            pill.Font = Enum.Font.GothamBlack
            pill.TextSize = 11
            pill.BorderSizePixel = 0
            pill.AutoButtonColor = false
            Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 6)
            local function refresh(on)
                pill.Text = on and "ON" or "OFF"
                pill.BackgroundColor3 = on and Color3.fromRGB(220, 25, 25) or Color3.fromRGB(30, 6, 6)
                pill.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(185, 80, 80)
            end
            refresh(isOn)
            pill.MouseButton1Click:Connect(function()
                local newState = onToggle()
                refresh(newState)
            end)
            return refresh
        end
        local function makeTCInputRow(labelText, yPos, currentVal, placeholder, onChange)
            local row = Instance.new("Frame", tcFrame)
            row.Size = UDim2.new(1, -20, 0, 30)
            row.Position = UDim2.new(0, 10, 0, yPos)
            row.BackgroundTransparency = 1
            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(0.55, 0, 1, 0)
            lbl.Position = UDim2.new(0, 4, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = labelText
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 11
            lbl.TextColor3 = Color3.fromRGB(250, 210, 210)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            local box = Instance.new("TextBox", row)
            box.Size = UDim2.new(0, 70, 0, 22)
            box.Position = UDim2.new(1, -74, 0.5, -11)
            box.BackgroundColor3 = Color3.fromRGB(30, 6, 6)
            box.Text = tostring(currentVal or "")
            box.Font = Enum.Font.Gotham
            box.TextSize = 11
            box.TextColor3 = Color3.fromRGB(255, 220, 220)
            box.PlaceholderText = placeholder or ""
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
            local bs = Instance.new("UIStroke", box)
            bs.Color = Color3.fromRGB(130, 15, 15)
            bs.Thickness = 1
            box.FocusLost:Connect(function()
                onChange(box.Text:gsub("%s", ""))
            end)
        end
        local Y = 44
        local ROW_H = 30
        local GAP = 4
        local _rfN = makeTCRow("Nearest", Y, stealNearestEnabled, function()
            stealNearestEnabled = not stealNearestEnabled
            if stealNearestEnabled then stealHighestEnabled = false; stealPriorityEnabled = false end
            Config.StealNearest = stealNearestEnabled; Config.StealHighest = stealHighestEnabled; Config.StealPriority = stealPriorityEnabled
            SaveConfig()
            if refreshHighest then refreshHighest(stealHighestEnabled) end
            if refreshPriority then refreshPriority(stealPriorityEnabled) end
            return stealNearestEnabled
        end)
        refreshNearest = _rfN
        Y = Y + ROW_H + GAP
        local _rfH = makeTCRow("Highest", Y, stealHighestEnabled, function()
            stealHighestEnabled = not stealHighestEnabled
            if stealHighestEnabled then stealNearestEnabled = false; stealPriorityEnabled = false end
            Config.StealHighest = stealHighestEnabled; Config.StealNearest = stealNearestEnabled; Config.StealPriority = stealPriorityEnabled
            SaveConfig()
            if refreshNearest then refreshNearest(stealNearestEnabled) end
            if refreshPriority then refreshPriority(stealPriorityEnabled) end
            return stealHighestEnabled
        end)
        refreshHighest = _rfH
        Y = Y + ROW_H + GAP
        local _rfP = makeTCRow("Priority", Y, stealPriorityEnabled, function()
            stealPriorityEnabled = not stealPriorityEnabled
            if stealPriorityEnabled then stealNearestEnabled = false; stealHighestEnabled = false end
            Config.StealHighest = stealHighestEnabled; Config.StealNearest = stealNearestEnabled; Config.StealPriority = stealPriorityEnabled
            SaveConfig()
            if refreshNearest then refreshNearest(stealNearestEnabled) end
            if refreshHighest then refreshHighest(stealHighestEnabled) end
            return stealPriorityEnabled
        end)
        refreshPriority = _rfP
        Y = Y + ROW_H + GAP
        makeTCRow("Auto Turret", Y, Config.AutoDestroyTurrets, function()
            Config.AutoDestroyTurrets = not Config.AutoDestroyTurrets
            SaveConfig()
            ShowNotification("AUTO TURRET", Config.AutoDestroyTurrets and "ENABLED" or "DISABLED")
            return Config.AutoDestroyTurrets
        end)
        Y = Y + ROW_H + GAP
        makeTCRow("Auto Kick", Y, Config.AutoKickOnSteal, function()
            Config.AutoKickOnSteal = not Config.AutoKickOnSteal
            _G.autoKickEnabled = Config.AutoKickOnSteal
            SaveConfig()
            ShowNotification("AUTO KICK", Config.AutoKickOnSteal and "ENABLED" or "DISABLED")
            return Config.AutoKickOnSteal
        end)
        Y = Y + ROW_H + GAP
        makeTCRow("Auto Grab Own", Y, Config.AutoGrab, function()
            Config.AutoGrab = not Config.AutoGrab
            SaveConfig()
            ShowNotification("AUTO GRAB", Config.AutoGrab and "ENABLED" or "DISABLED")
            return Config.AutoGrab
        end)
        Y = Y + ROW_H + GAP
        makeTCInputRow("Min Value Nearest", Y, Config.TpSettings.MinGenForNearest or "", "e.g. 5k, 1m", function(raw)
            Config.TpSettings.MinGenForNearest = (raw == "" and "" or raw)
            SaveConfig()
            ShowNotification("MIN VALUE NEAREST", raw == "" and "No minimum" or "Min: " .. raw)
        end)
        Y = Y + ROW_H + 10
        tcFrame.Size = UDim2.new(0, TC_W, 0, Y)
    end
    updateUI = function(enabled, allPets)
        autoStealEnabled = enabled
        enableBtn.Text = enabled and "AUTO STEAL: ON" or "AUTO STEAL: OFF"
        enableBtn.BackgroundColor3 = enabled and Theme.Success or Color3.fromRGB(52, 18, 38)
        enableBtn.TextColor3 = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(185, 80, 80)
        if allPets then
            targetsLbl.Text = "Targets: " .. #allPets
        end
        playersLbl.Text = "Players: " .. #game:GetService("Players"):GetPlayers()
        local stealing = LocalPlayer:GetAttribute("Stealing")
        if stealing then
            statusDot.BackgroundColor3 = Color3.fromRGB(220, 25, 25)
            stealStatusLbl.Text = "Steal: Active"
            stealStatusLbl.TextColor3 = Color3.fromRGB(255, 110, 110)
        else
            statusDot.BackgroundColor3 = Color3.fromRGB(130, 30, 30)
            stealStatusLbl.Text = "Steal: Idle"
            stealStatusLbl.TextColor3 = Color3.fromRGB(200, 90, 90)
        end
        if selectedTargetUID and allPets then
            for i, p in ipairs(allPets) do
                if p.uid == selectedTargetUID then
                    selectedTargetIndex = i
                    break
                end
            end
        end
        if SharedState.ListNeedsRedraw then
            for _, c in ipairs(listFrame:GetChildren()) do
                if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
            end
            petButtons = {}
            local MUT_COLORS_UI = {
                Cursed=Color3.fromRGB(180,30,30), Gold=Color3.fromRGB(200,165,0),
                Diamond=Color3.fromRGB(50,180,200), YinYang=Color3.fromRGB(160,160,170),
                Rainbow=Color3.fromRGB(190,70,150), Lava=Color3.fromRGB(200,80,20),
                Candy=Color3.fromRGB(200,80,140), Divine=Color3.fromRGB(200,200,210)
            }
            if allPets and #allPets > 0 then
                for i = 1, #allPets do
                    local petData = allPets[i]
                    local row = Instance.new("Frame")
                    row.Size = UDim2.new(1, -8, 0, 42)
                    row.BackgroundColor3 = Color3.fromRGB(45, 10, 10)
                    row.BorderSizePixel = 0
                    row.Parent = listFrame
                    row.LayoutOrder = i
                    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
                    local bStroke = Instance.new("UIStroke", row)
                    bStroke.Color = Color3.fromRGB(130, 45, 75)
                    bStroke.Thickness = 1
                    bStroke.Transparency = 1
                    local hasMut = petData.mutation and petData.mutation ~= "None"
                    local barCol = hasMut
                        and (MUT_COLORS_UI[petData.mutation] or Color3.fromRGB(140,80,200))
                        or Color3.fromRGB(75, 28, 48)
                    local itemBar = Instance.new("Frame", row)
                    itemBar.Size = UDim2.new(0, 3, 0.7, 0)
                    itemBar.Position = UDim2.new(0, 3, 0.15, 0)
                    itemBar.BackgroundColor3 = barCol
                    itemBar.BorderSizePixel = 0
                    Instance.new("UICorner", itemBar).CornerRadius = UDim.new(1, 0)
                    local rankLabel = Instance.new("TextLabel", row)
                    rankLabel.Size = UDim2.new(0, 26, 1, 0)
                    rankLabel.Position = UDim2.new(0, 9, 0, 0)
                    rankLabel.BackgroundTransparency = 1
                    rankLabel.Text = "#"..i
                    rankLabel.Font = Enum.Font.GothamBlack
                    rankLabel.TextSize = 12
                    local infoLabel = Instance.new("TextLabel", row)
                    infoLabel.Size = UDim2.new(1, -42, 1, 0)
                    infoLabel.Position = UDim2.new(0, 36, 0, 0)
                    infoLabel.BackgroundTransparency = 1
                    infoLabel.RichText = true
                    local sideTag = ""
                    pcall(function()
                        local ps = getPlotSide and getPlotSide(petData.plot or (petData.animalData and petData.animalData.plot))
                        if ps then
                            local col = ps == "Side 1" and "rgb(80,140,220)" or "rgb(220,120,50)"
                            sideTag = " <font color='"..col.."'><b>["..ps.."]</b></font>"
                        end
                    end)
                    infoLabel.Text = formatMutationText(petData.mutation)
                        .. "<font weight='700'>" .. petData.petName .. "</font>"
                        .. " <font color='rgb(90,90,105)'>" .. petData.mpsText .. "</font>"
                        .. sideTag
                    infoLabel.Font = Enum.Font.GothamMedium
                    infoLabel.TextSize = 12
                    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
                    infoLabel.TextTruncate = Enum.TextTruncate.AtEnd
                    petButtons[i] = {button=row, stroke=bStroke, rank=rankLabel, info=infoLabel, bar=itemBar}
                    local clickOverlay = Instance.new("TextButton", row)
                    clickOverlay.Size = UDim2.new(1, 0, 1, 0)
                    clickOverlay.BackgroundTransparency = 1
                    clickOverlay.Text = ""
                    clickOverlay.ZIndex = 2
                                        clickOverlay.MouseButton1Click:Connect(function()
                        selectedTargetIndex = i
                        selectedTargetUID = petData.uid
                        stealNearestEnabled = false
                        stealHighestEnabled = false
                        stealPriorityEnabled = false
                        Config.StealNearest = false; Config.StealHighest = false; Config.StealPriority = false
                        SaveConfig()
                        SharedState.ListNeedsRedraw = false
                        updateUI(autoStealEnabled, get_all_pets())
                    end)
                end
            else
                local emptyLbl = Instance.new("TextLabel")
                emptyLbl.Size = UDim2.new(1, -8, 0, 24)
                emptyLbl.BackgroundTransparency = 1
                emptyLbl.Text = "No brainrots found"
                emptyLbl.Font = Enum.Font.GothamMedium
                emptyLbl.TextSize = 11
                emptyLbl.TextColor3 = Color3.fromRGB(170, 65, 65)
                emptyLbl.TextXAlignment = Enum.TextXAlignment.Center
                emptyLbl.LayoutOrder = 1
                emptyLbl.Parent = listFrame
            end
            SharedState.ListNeedsRedraw = false
        end
        if selectedTargetIndex > #petButtons then selectedTargetIndex = 1 end
        for i, pb in ipairs(petButtons) do
            local sel = (i == selectedTargetIndex)
            pb.stroke.Transparency = sel and 0 or 1
            pb.button.BackgroundColor3 = sel and Color3.fromRGB(30, 7, 7) or Color3.fromRGB(45, 10, 10)
            pb.rank.TextColor3  = sel and Color3.fromRGB(245, 200, 200) or Color3.fromRGB(160, 50, 50)
            pb.info.TextColor3  = sel and Color3.fromRGB(250, 215, 215) or Color3.fromRGB(190, 85, 85)
        end
        local ct = allPets and allPets[selectedTargetIndex]
        SharedState.SelectedPetData = ct
        if ct then
            local plotName = ct.plot or "?"
            local plotObj = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(plotName)
            local adornee = findAdorneeGlobal(ct.animalData or ct)
            if adornee and plotObj then
                local animalPos = adornee.Position
                local decorations = plotObj:FindFirstChild("Decorations")
                local closestSide, closestDist = nil, math.huge
                if decorations then
                    for _, child in ipairs(decorations:GetChildren()) do
                        if child.Name ~= "Side 3" and child.Name:lower():find("^side") then
                            local ok, pivot = pcall(function() return child:GetPivot() end)
                            if ok and pivot then
                                local d = (animalPos - pivot.Position).Magnitude
                                if d < closestDist then closestDist = d; closestSide = child.Name end
                            end
                        end
                    end
                end
            end
        end
        if enabled then
            targetLabel.Text = ct and string.format("%s (%s)", ct.petName, ct.mpsText) or "Searching..."
        else
            targetLabel.Text = "Disabled"
        end
        listFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(0, uiListLayout.AbsoluteContentSize.Y))
    end
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(0, uiListLayout.AbsoluteContentSize.Y))
    end)
    SharedState.UpdateAutoStealUI = function()
        updateUI(autoStealEnabled, get_all_pets())
    end
    LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
        local stealing = LocalPlayer:GetAttribute("Stealing")
        if stealing then
            statusDot.BackgroundColor3 = Color3.fromRGB(220, 25, 25)
            stealStatusLbl.Text = "Steal: Active"
            stealStatusLbl.TextColor3 = Color3.fromRGB(255, 110, 110)
        else
            statusDot.BackgroundColor3 = Color3.fromRGB(130, 30, 30)
            stealStatusLbl.Text = "Steal: Idle"
            stealStatusLbl.TextColor3 = Color3.fromRGB(200, 90, 90)
        end
    end)
    enableBtn.MouseButton1Click:Connect(function()
        autoStealEnabled = not autoStealEnabled
        SharedState.ListNeedsRedraw = false
        updateUI(autoStealEnabled, get_all_pets())
    end)
    nearestBtn.MouseButton1Click:Connect(function()
        stealNearestEnabled = not stealNearestEnabled
        if stealNearestEnabled then stealHighestEnabled = false; stealPriorityEnabled = false end
        Config.StealNearest = stealNearestEnabled; Config.StealHighest = stealHighestEnabled; Config.StealPriority = stealPriorityEnabled
        SaveConfig()
        SharedState.ListNeedsRedraw = false; updateUI(autoStealEnabled, get_all_pets())
    end)
    highestBtn.MouseButton1Click:Connect(function()
        stealHighestEnabled = not stealHighestEnabled
        if stealHighestEnabled then stealNearestEnabled = false; stealPriorityEnabled = false end
        Config.StealNearest = stealNearestEnabled; Config.StealHighest = stealHighestEnabled; Config.StealPriority = stealPriorityEnabled
        SaveConfig()
        SharedState.ListNeedsRedraw = false; updateUI(autoStealEnabled, get_all_pets())
    end)
    priorityBtn.MouseButton1Click:Connect(function()
        stealPriorityEnabled = not stealPriorityEnabled
        if stealPriorityEnabled then stealNearestEnabled = false; stealHighestEnabled = false end
        Config.StealNearest = stealNearestEnabled; Config.StealHighest = stealHighestEnabled; Config.StealPriority = stealPriorityEnabled
        SaveConfig()
        SharedState.ListNeedsRedraw = false; updateUI(autoStealEnabled, get_all_pets())
    end)
    _G.ZawaHub_SetAutoSteal = function(v)
        if autoStealEnabled == v then return end
        autoStealEnabled = v
        SharedState.ListNeedsRedraw = false
        updateUI(autoStealEnabled, get_all_pets())
    end
    _G.ZawaHub_GetAutoSteal = function() return autoStealEnabled end
    local function findProximityPromptForAnimal(animalData)
        if not animalData then return nil end
        local cp = PromptMemoryCache[animalData.uid]
        if cp and cp.Parent then return cp end
        local plot = Workspace.Plots:FindFirstChild(animalData.plot); if not plot then return nil end
        local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return nil end
        local ch = Synchronizer.caches[plot.Name]
        if not ch then
            local podium = podiums:FindFirstChild(animalData.slot)
            if podium then
                local base = podium:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local attach = spawn:FindFirstChild("PromptAttachment")
                    if attach then
                        for _, p in ipairs(attach:GetChildren()) do
                            if p:IsA("ProximityPrompt") then
                                PromptMemoryCache[animalData.uid] = p
                                return p
                            end
                        end
                    end
                end
            end
            return nil
        end
        local al = ch.AnimalList
        if not al then return nil end
        local brainrotName = animalData.name and animalData.name:lower() or ""
        local targetSlot = animalData.slot
        local foundPodium = nil
        for slot, ad in pairs(al) do
            if type(ad) == "table" and tostring(slot) == targetSlot then
                local aName, aInfo = ad.Index, AnimalsData[ad.Index]
                if aInfo and (aInfo.DisplayName or aName):lower() == brainrotName then
                    foundPodium = podiums:FindFirstChild(tostring(slot))
                    break
                end
            end
        end
        if not foundPodium then
            foundPodium = podiums:FindFirstChild(animalData.slot)
        end
        if foundPodium then
            local base = foundPodium:FindFirstChild("Base")
            local spawn = base and base:FindFirstChild("Spawn")
            if spawn then
                local attach = spawn:FindFirstChild("PromptAttachment")
                if attach then
                    for _, p in ipairs(attach:GetChildren()) do
                        if p:IsA("ProximityPrompt") and p.Enabled and p.ActionText == "Steal" then
                            PromptMemoryCache[animalData.uid] = p
                            return p
                        end
                    end
                end
                local startPos = spawn.Position
                local slotX, slotZ = startPos.X, startPos.Z
                local nearestPrompt = nil
                local minDist = math.huge
                for _, desc in pairs(plot:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.Enabled and desc.ActionText == "Steal" then
                        local part = desc.Parent
                        local promptPos = nil
                        if part and part:IsA("BasePart") then
                            promptPos = part.Position
                        elseif part and part:IsA("Attachment") and part.Parent and part.Parent:IsA("BasePart") then
                            promptPos = part.Parent.Position
                        end
                        if promptPos then
                            local checkStartY = startPos.Y
                            if brainrotName:find("la secret combinasion") then
                                checkStartY = startPos.Y - 5
                            end
                            local horizontalDist = math.sqrt((promptPos.X - slotX)^2 + (promptPos.Z - slotZ)^2)
                            if horizontalDist < 5 and promptPos.Y > checkStartY then
                                local yDist = promptPos.Y - checkStartY
                                if yDist < minDist then
                                    minDist = yDist
                                    nearestPrompt = desc
                                end
                            end
                        end
                    end
                end
                if nearestPrompt then
                    PromptMemoryCache[animalData.uid] = nearestPrompt
                    return nearestPrompt
                end
            end
        end
        return nil
    end
    local STEAL_DURATION = 0.05
    local function buildStealCallbacks(prompt)
        if InternalStealCache[prompt] and InternalStealCache[prompt].ready then return end
        local data = {holdCallbacks = {}, triggerCallbacks = {}, holdEndCallbacks = {}, ready = true}
        local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
        if ok1 and type(conns1) == "table" then
            for _, conn in ipairs(conns1) do
                if type(conn.Function) == "function" then
                    table.insert(data.holdCallbacks, conn.Function)
                end
            end
        end
        local ok2, conns2 = pcall(getconnections, prompt.Triggered)
        if ok2 and type(conns2) == "table" then
            for _, conn in ipairs(conns2) do
                if type(conn.Function) == "function" then
                    table.insert(data.triggerCallbacks, conn.Function)
                end
            end
        end
        local ok3, conns3 = pcall(getconnections, prompt.PromptButtonHoldEnded)
        if ok3 and type(conns3) == "table" then
            for _, conn in ipairs(conns3) do
                if type(conn.Function) == "function" then
                    table.insert(data.holdEndCallbacks, conn.Function)
                end
            end
        end
        if (#data.holdCallbacks > 0) or (#data.triggerCallbacks > 0) or (#data.holdEndCallbacks > 0) then
            InternalStealCache[prompt] = data
        end
    end
    local function runCallbackList(list)
        for _, fn in ipairs(list) do
            task.spawn(fn)
        end
    end
    local STEAL_RADIUS = 50
    local STEAL_DURATION = 1.4
    local isStealing = false
    local StealData = {}
    local _plotsRef = workspace:FindFirstChild("Plots")
    local _myPlotName = nil
    local _myPlotCheckTime = 0
    local function isMyPlot_Instant(plotName)
        local now = os.clock()
        if now - _myPlotCheckTime > 2 or _myPlotName == nil then
            _myPlotCheckTime = now
            local plots = _plotsRef or workspace:FindFirstChild("Plots")
            _plotsRef = plots
            if plots then
                for _, plot in ipairs(plots:GetChildren()) do
                    local sign = plot:FindFirstChild("PlotSign")
                    local yb = sign and sign:FindFirstChild("YourBase")
                    if yb and yb:IsA("BillboardGui") and yb.Enabled then
                        _myPlotName = plot.Name
                        break
                    end
                end
            end
        end
        return plotName == _myPlotName
    end
    local STEAL_HOLD_TIME = 1.4
    local STEAL_COOLDOWN = 0.02
    local stealReady = true
    local stealStartTime = nil
    local stealAttemptId = 0
    local STUN_COOLDOWN_SEC  = 3.5
    local STEAL_RESUME_LEAD  = 0.5
    local stunCooldownEnd = 0   
    local stealAllowedAt  = 0   
    local stunStartTick   = 0
    local localStunEndTick = 0
    local _stunWasActive  = false
    local _refreshStunStart
    local _effectiveStunRemaining
    local function isInStunLockout()
        _refreshStunStart()
        return _effectiveStunRemaining() > STEAL_RESUME_LEAD
    end
    local function onStunStart(durationSec)
        local now = tick()
        local selfStartedAt = tonumber(_G.ZawaHub_SelfRagdollStartedAt) or now
        if selfStartedAt > now or (now - selfStartedAt) > STUN_COOLDOWN_SEC then
            selfStartedAt = now
        end
        stunStartTick = selfStartedAt
        localStunEndTick = selfStartedAt + STUN_COOLDOWN_SEC
        stunCooldownEnd = localStunEndTick
        stealAllowedAt = math.max(0, localStunEndTick - STEAL_RESUME_LEAD)
        _stunWasActive = true
        stealAttemptId += 1
        if isStealing then
            isStealing = false
            stealReady = true
            stealStartTime = nil
        end
    end
    local function shouldPauseForSelfRagdoll()
        return (tonumber(_G.ZawaHub_SelfRagdollDetectUntil) or 0) > tick()
    end
    do
        local function syncFromAttribute()
            local endServerTime = LocalPlayer:GetAttribute("RagdollEndTime")
            if not endServerTime then return end
            local serverNow = workspace:GetServerTimeNow()
            local remaining = endServerTime - serverNow
            if remaining > 0.05 and shouldPauseForSelfRagdoll() then
                onStunStart(remaining)
            end
        end
        LocalPlayer:GetAttributeChangedSignal("RagdollEndTime"):Connect(syncFromAttribute)
        syncFromAttribute()
    end
    do
        local function watchChar(char)
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            hum.StateChanged:Connect(function(_, newState)
                if newState == Enum.HumanoidStateType.Ragdoll
                   or newState == Enum.HumanoidStateType.FallingDown then
                    if shouldPauseForSelfRagdoll() then
                        onStunStart(STUN_COOLDOWN_SEC)
                    end
                end
            end)
        end
        if LocalPlayer.Character then watchChar(LocalPlayer.Character) end
        LocalPlayer.CharacterAdded:Connect(watchChar)
    end
    _G.ZawaHub_GetStealState = function()
        return stealReady, stealStartTime
    end
    _effectiveStunRemaining = function()
        return math.max(0, localStunEndTick - tick())
    end
    _G.ZawaHub_GetStunCooldownEnd = function()
        local r = _effectiveStunRemaining()
        if r <= 0 then return 0 end
        return tick() + r
    end
    _refreshStunStart = function()
        local endServerTime = LocalPlayer:GetAttribute("RagdollEndTime")
        local active = false
        if endServerTime then
            local serverNow = workspace:GetServerTimeNow()
            if endServerTime - serverNow > 0 then active = true end
        end
        if active and not _stunWasActive and shouldPauseForSelfRagdoll() then
            stunStartTick = tick()
            localStunEndTick = math.max(localStunEndTick, stunStartTick + STUN_COOLDOWN_SEC)
            stunCooldownEnd = localStunEndTick
            stealAllowedAt = math.max(0, localStunEndTick - STEAL_RESUME_LEAD)
        end
        _stunWasActive = active
        if not active and tick() >= localStunEndTick then
            stunStartTick = 0
            localStunEndTick = 0
            stunCooldownEnd = 0
            stealAllowedAt = 0
        end
    end
    local function firePromptConnections(prompt, signalName)
        local connections = getconnections(prompt[signalName])
        for _, conn in ipairs(connections) do
            if conn.Function then
                task.spawn(conn.Function)
            end
        end
    end
    local function fireAllTriggerPaths(activePrompt)
        if not activePrompt or not activePrompt.Parent then return end
        firePromptConnections(activePrompt, "Triggered")
    end
    local function finishStealPrompt(activePrompt)
        if not activePrompt or not activePrompt.Parent then return end
        pcall(function()
            firePromptConnections(activePrompt, "Triggered")
        end)
        pcall(function()
            if typeof(fireproximityprompt) == "function" then
                fireproximityprompt(activePrompt, 0)
            end
        end)
    end
    local function executeSteal(prompt)
        if not stealReady then return false end
        stealReady = false
        isStealing = true
        stealStartTime = tick()
        stealAttemptId += 1
        local thisAttemptId = stealAttemptId
        task.spawn(function()
            local savedPlot, savedSlot
            do
                local node = prompt
                while node and node.Parent do
                    local parent = node.Parent
                    if parent and parent.Name == "AnimalPodiums" then
                        savedSlot = node.Name
                        if parent.Parent then savedPlot = parent.Parent.Name end
                        break
                    end
                    node = parent
                end
            end
            firePromptConnections(prompt, "PromptButtonHoldBegan")
            task.wait(STEAL_HOLD_TIME)
            if thisAttemptId == stealAttemptId and prompt and prompt.Parent and prompt.Enabled then
                local finishDeadline = tick() + 0.35
                repeat
                    finishStealPrompt(prompt)
                    if LocalPlayer:GetAttribute("Stealing") then break end
                    task.wait(0.05)
                until thisAttemptId ~= stealAttemptId
                   or not (prompt and prompt.Parent and prompt.Enabled)
                   or tick() >= finishDeadline
            end
            task.wait(STEAL_COOLDOWN)
            if thisAttemptId == stealAttemptId then
                stealReady = true
                isStealing = false
                stealStartTime = nil
            end
        end)
        return true
    end
    local function prebuildStealCallbacks()
        for _, prompt in pairs(PromptMemoryCache) do
            if prompt and prompt.Parent then
                buildStealCallbacks(prompt)
            end
        end
    end
    task.spawn(function()
        while task.wait(0.1) do
            if _G.ZawaHub_Suspended then continue end
            prebuildStealCallbacks()
        end
    end)
    local function getAnimalHash(al)
        if not al then return "" end; local h=""
        for slot, d in pairs(al) do if type(d)=="table" then h=h..tostring(slot)..tostring(d.Index)..tostring(d.Mutation) end end
        return h
    end
    scanSinglePlot = function(plot)
        local changed = false
        pcall(function()
            local ch = Synchronizer.caches[plot.Name]; if not ch then return end
            local al = ch.AnimalList
            local hash = getAnimalHash(al)
            if lastAnimalData[plot.Name]==hash then return end
            lastAnimalData[plot.Name]=hash; changed=true
            for i=#allAnimalsCache,1,-1 do if allAnimalsCache[i].plot==plot.Name then table.remove(allAnimalsCache,i) end end
            local owner = ch.Owner
            if not owner or not Players:FindFirstChild(owner.Name) then return end
            local ownerName = owner.Name or "Unknown"
            if not al then return end
            for slot, ad in pairs(al) do
                if type(ad)=="table" then
                    local aName, aInfo = ad.Index, AnimalsData[ad.Index]
                    if aInfo then
                        local mut = ad.Mutation or "None"
                        if mut == "Yin Yang" then mut = "YinYang" end
                        local traits = (ad.Traits and #ad.Traits>0) and table.concat(ad.Traits,", ") or "None"
                        local gv = AnimalsShared:GetGeneration(aName, ad.Mutation, ad.Traits, nil)
                        local gt = "$"..NumberUtils:ToString(gv).."/s"
                        table.insert(allAnimalsCache, {
                            name=aInfo.DisplayName or aName, genText=gt, genValue=gv,
                            mutation=mut, traits=traits, owner=ownerName,
                            plot=plot.Name, slot=tostring(slot), uid=plot.Name.."_"..tostring(slot)
                        })
                    end
                end
            end
        end)
        if changed then
            table.sort(allAnimalsCache, function(a,b) return a.genValue>b.genValue end)
            SharedState.ListNeedsRedraw = true
        end
    end
    local function eagerCachePlotPrompts(plot)
        pcall(function()
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if not podiums then return end
            for _, podium in ipairs(podiums:GetChildren()) do
                local base = podium:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if not spawn then continue end
                local attach = spawn:FindFirstChild("PromptAttachment")
                if not attach then continue end
                local uid = plot.Name .. "_" .. podium.Name
                for _, p in ipairs(attach:GetChildren()) do
                    if p:IsA("ProximityPrompt") and p.Enabled and p.ActionText == "Steal" then
                        PromptMemoryCache[uid] = p
                        pcall(buildStealCallbacks, p)
                        break
                    end
                end
            end
        end)
    end
    local function setupPlotListener(plot)
        local ch, retries = nil, 0
        while not ch and retries<50 do
            local ok, r = pcall(function() return Synchronizer.caches[plot.Name] end)
            if ok and r then ch=r; break else retries=retries+1; task.wait(0.1) end
        end
        if not ch then return end
        scanSinglePlot(plot)
        task.spawn(function() eagerCachePlotPrompts(plot) end)
        local pendingScan = false
        local function deferScan()
            if pendingScan then return end
            pendingScan = true
            task.defer(function()
                pendingScan = false
                scanSinglePlot(plot)
                eagerCachePlotPrompts(plot)
            end)
        end
        plot.DescendantAdded:Connect(deferScan)
        plot.DescendantRemoving:Connect(deferScan)
        task.spawn(function()
            while plot.Parent do
                task.wait(0.5)
                scanSinglePlot(plot)
                eagerCachePlotPrompts(plot)
            end
        end)
    end
    local plots = Workspace:WaitForChild("Plots", 8)
    if plots then
        for _, p in ipairs(plots:GetChildren()) do setupPlotListener(p) end
        SharedState.InitialScanComplete = true
        plots.ChildAdded:Connect(function(p) task.wait(0.5); setupPlotListener(p) end)
        plots.ChildRemoved:Connect(function(p)
            lastAnimalData[p.Name]=nil
            for i=#allAnimalsCache,1,-1 do if allAnimalsCache[i].plot==p.Name then table.remove(allAnimalsCache,i) end end
            SharedState.ListNeedsRedraw=true
        end)
        local function forceRescanAllPlots()
            for plotName, _ in pairs(lastAnimalData) do
                lastAnimalData[plotName] = ""
            end
            for _, p in ipairs(plots:GetChildren()) do
                pcall(scanSinglePlot, p)
            end
        end
        local function hookPlayerStealAttrs(plr)
            if plr == LocalPlayer then return end
            local function onChanged()
                forceRescanAllPlots()
            end
            pcall(function()
                plr:GetAttributeChangedSignal("Stealing"):Connect(onChanged)
                plr:GetAttributeChangedSignal("StealingIndex"):Connect(onChanged)
            end)
            local function hookCharacter(char)
                if not char then return end
                char.ChildRemoved:Connect(function(obj)
                    if obj and obj:IsA("Tool") then
                        forceRescanAllPlots()
                    end
                end)
            end
            hookCharacter(plr.Character)
            plr.CharacterAdded:Connect(hookCharacter)
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            hookPlayerStealAttrs(plr)
        end
        Players.PlayerAdded:Connect(hookPlayerStealAttrs)
    end
    local duelBaseHighlights = {}
    local duelBaseBillboards = {}
    local function clearDuelBaseVisuals()
        for _, h in pairs(duelBaseHighlights) do
            if h and h.Parent then h:Destroy() end
        end
        duelBaseHighlights = {}
        for _, b in pairs(duelBaseBillboards) do
            if b and b.Parent then b:Destroy() end
        end
        duelBaseBillboards = {}
    end
    local function createDuelBaseMarker(plot, sign)
        local plotName = plot.Name
        if duelBaseHighlights[plotName] then return end
        local highlight = Instance.new("Highlight")
        highlight.Name = "DuelBaseHighlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0.3
        highlight.Adornee = plot
        highlight.Parent = plot
        duelBaseHighlights[plotName] = highlight
        local bb = Instance.new("BillboardGui")
        bb.Name = "DuelBaseMarker"
        bb.Size = UDim2.new(0, 180, 0, 40)
        bb.StudsOffsetWorldSpace = Vector3.new(0, 8, 0)
        bb.AlwaysOnTop = true
        bb.LightInfluence = 0
        bb.ResetOnSpawn = false
        bb.Adornee = sign
        bb.Parent = sign
        local frame = Instance.new("Frame", bb)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Color3.fromRGB(255, 0, 0)
        stroke.Thickness = 2
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "DUEL BASE"
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 18
        label.TextColor3 = Color3.fromRGB(255, 50, 50)
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        duelBaseBillboards[plotName] = bb
    end
    task.spawn(function()
        while true do
            task.wait(1)
            if not Config.DuelBaseESP then
                clearDuelBaseVisuals()
            else
                local Plots = Workspace:FindFirstChild("Plots")
                if Plots then
                    for _, plot in ipairs(Plots:GetChildren()) do
                        local sign = plot:FindFirstChild("PlotSign")
                        if sign then
                            local textLabel = sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame") and sign.SurfaceGui.Frame:FindFirstChild("TextLabel")
                            local baseText = textLabel and textLabel.Text or nil
                            if baseText and baseText ~= "Empty Base" then
                                local nickname = baseText:match("^(.-)'") or baseText
                                local ownerPlayer = nil
                                for _, p in ipairs(Players:GetPlayers()) do
                                    if p.DisplayName == nickname or p.Name == nickname then
                                        ownerPlayer = p
                                        break
                                    end
                                end
                                if ownerPlayer and ownerPlayer:GetAttribute("__duels_block_steal") == true then
                                    if Config.DuelBaseESP then
                                        createDuelBaseMarker(plot, sign)
                                    end
                                else
                                    local plotName = plot.Name
                                    if duelBaseHighlights[plotName] then
                                        duelBaseHighlights[plotName]:Destroy()
                                        duelBaseHighlights[plotName] = nil
                                    end
                                    if duelBaseBillboards[plotName] then
                                        duelBaseBillboards[plotName]:Destroy()
                                        duelBaseBillboards[plotName] = nil
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    local baseTimerBillboards = {}
    local function parseTimerText(t)
        if not t or t == "" then return nil end
        local secs = t:match("^%s*(%d+)%s*[sS]%s*$")
        return secs
    end
    local function findTimerBillboardInPlot(plot)
        for _, desc in ipairs(plot:GetDescendants()) do
            if desc:IsA("BillboardGui") and desc.Enabled and desc.Name ~= "BaseTimerESP" then
                for _, child in ipairs(desc:GetDescendants()) do
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        local secs = parseTimerText(child.Text)
                        if secs then
                            return desc, secs
                        end
                    end
                end
            end
        end
        return nil, nil
    end
    local function getFloor1Door(plot)
        local unlockFolder = plot:FindFirstChild("Unlock")
        if not unlockFolder then return nil end
        local lowest, lowestY
        for _, item in ipairs(unlockFolder:GetChildren()) do
            local pos
            if item:IsA("Model") then pcall(function() pos = item:GetPivot().Position end)
            elseif item:IsA("BasePart") then pos = item.Position end
            if pos and (not lowestY or pos.Y < lowestY) then
                lowestY = pos.Y
                lowest = item
            end
        end
        return lowest
    end
    local function isPlotLocked(plot)
        local unlockFolder = plot:FindFirstChild("Unlock")
        if not unlockFolder then return false end
        for _, item in ipairs(unlockFolder:GetChildren()) do
            for _, desc in ipairs(item:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Enabled then return true end
            end
        end
        return false
    end
    local function clearBaseTimerVisuals()
        for _, b in pairs(baseTimerBillboards) do
            if b and b.Parent then b:Destroy() end
        end
        baseTimerBillboards = {}
    end
    local function makeLabel(adornee, offsetY)
        local bb = Instance.new("BillboardGui")
        bb.Name = "BaseTimerESP"
        bb.Size = UDim2.new(0, 150, 0, 32)
        bb.StudsOffsetWorldSpace = Vector3.new(0, 0, 0)
        bb.StudsOffset = Vector3.new(0, offsetY or 6, 0)
        bb.AlwaysOnTop = true
        bb.LightInfluence = 0
        bb.ResetOnSpawn = false
        bb.Adornee = adornee
        bb.Parent = adornee
        local label = Instance.new("TextLabel", bb)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = ""
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 25
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Name = "TimerLabel"
        return bb
    end
    task.spawn(function()
        while true do
            task.wait(0.25)
            if not Config.BaseTimerESP then
                if next(baseTimerBillboards) then clearBaseTimerVisuals() end
            else
                local Plots = Workspace:FindFirstChild("Plots")
                if Plots then
                    local seen = {}
                    for _, plot in ipairs(Plots:GetChildren()) do
                        seen[plot.Name] = true
                        local gameBb, secs = findTimerBillboardInPlot(plot)
                        local adornee, offsetY, baseOffsetWS, baseOffset
                        if gameBb and gameBb.Adornee and gameBb.Adornee:IsA("BasePart") then
                            adornee = gameBb.Adornee
                            offsetY = 4 
                            baseOffsetWS = gameBb.StudsOffsetWorldSpace
                            baseOffset   = gameBb.StudsOffset
                        elseif gameBb and gameBb.Parent and gameBb.Parent:IsA("BasePart") then
                            adornee = gameBb.Parent
                            offsetY = 4
                            baseOffsetWS = gameBb.StudsOffsetWorldSpace
                            baseOffset   = gameBb.StudsOffset
                        else
                            local door = getFloor1Door(plot)
                            if door then
                                if door:IsA("Model") then
                                    adornee = door.PrimaryPart or door:FindFirstChildWhichIsA("BasePart")
                                elseif door:IsA("BasePart") then
                                    adornee = door
                                end
                                offsetY = 14
                            end
                        end
                        if not adornee then
                        else
                            local bb = baseTimerBillboards[plot.Name]
                            if bb and (not bb.Parent or bb.Adornee ~= adornee) then
                                bb:Destroy()
                                bb = nil
                                baseTimerBillboards[plot.Name] = nil
                            end
                            if not bb then
                                bb = makeLabel(adornee, offsetY)
                                baseTimerBillboards[plot.Name] = bb
                            end
                            if baseOffsetWS then
                                bb.StudsOffsetWorldSpace = baseOffsetWS
                            end
                            bb.StudsOffset = Vector3.new(0, (offsetY or 4) + 2, 0)
                            local label = bb:FindFirstChild("TimerLabel")
                            if label then
                                if secs then
                                    label.Text = secs .. "s"
                                else
                                    local locked = isPlotLocked(plot)
                                    label.Text = locked and "OPENS" or "CLOSES"
                                end
                            end
                        end
                    end
                    for plotName, b in pairs(baseTimerBillboards) do
                        if not seen[plotName] then
                            if b and b.Parent then b:Destroy() end
                            baseTimerBillboards[plotName] = nil
                        end
                    end
                end
            end
        end
    end)
task.spawn(function()
        while true do
            task.wait(0.01)
            if _G.ZawaHub_Suspended then task.wait(0.5); continue end
            if autoStealEnabled then
                local pets = get_all_pets()
                if #pets > 0 then
                    local function applySelection(newIndex)
                        if newIndex and newIndex >= 1 and newIndex <= #pets then
                            local newUID = pets[newIndex].uid
                            if selectedTargetIndex ~= newIndex or selectedTargetUID ~= newUID then
                                selectedTargetIndex = newIndex
                                selectedTargetUID = newUID
                                SharedState.ListNeedsRedraw = false
                                updateUI(autoStealEnabled, pets)
                            end
                        end
                    end
                    if stealPriorityEnabled then
                        local foundPrioIndex = nil
                        local higherPriorityHeld = false
                        for _, pName in ipairs(PRIORITY_LIST) do
                            local searchName = pName:lower()
                            for i, p in ipairs(pets) do
                                if p.petName and p.petName:lower() == searchName then
                                    foundPrioIndex = i
                                    break
                                end
                            end
                            if foundPrioIndex then break end
                            for _, plr in ipairs(Players:GetPlayers()) do
                                if plr ~= LocalPlayer then
                                    local idx = plr:GetAttribute("StealingIndex")
                                    if idx and tostring(idx):lower() == searchName then
                                        higherPriorityHeld = true
                                        break
                                    end
                                end
                            end
                            if higherPriorityHeld then break end
                        end
                        priorityLockHeld = (not foundPrioIndex) and higherPriorityHeld
                        if foundPrioIndex then
                            applySelection(foundPrioIndex)
                        elseif higherPriorityHeld then
                        else
                            selectedTargetIndex = 0
                            selectedTargetUID   = nil
                            SharedState.SelectedPetData = nil
                        end
                    elseif stealNearestEnabled or stealHighestEnabled then
                        priorityLockHeld = false
                        local foundPrioIndex = nil
                        for _, pName in ipairs(PRIORITY_LIST) do
                            local searchName = pName:lower()
                            for i, p in ipairs(pets) do
                                if p.petName and p.petName:lower() == searchName then
                                    foundPrioIndex = i; break
                                end
                            end
                            if foundPrioIndex then break end
                        end
                        if foundPrioIndex then
                            applySelection(foundPrioIndex)
                        elseif stealNearestEnabled then
                            local char = LocalPlayer.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local minNearestGen = parseMinGen(Config.TpSettings.MinGenForNearest)
                                local bestIndex = nil
                                local bestDist = math.huge
                                for i, p in ipairs(pets) do
                                    if minNearestGen > 0 and (not p.genValue or p.genValue < minNearestGen) then continue end
                                    local targetPart = p.animalData and findAdorneeGlobal(p.animalData)
                                    if targetPart and targetPart:IsA("BasePart") then
                                        local d = (hrp.Position - targetPart.Position).Magnitude
                                        if d < bestDist then
                                            bestDist = d
                                            bestIndex = i
                                        end
                                    end
                                end
                                if bestIndex then
                                    applySelection(bestIndex)
                                else
                                    applySelection(1)
                                end
                            else
                                applySelection(1)
                            end
                        else
                            applySelection(1)
                        end
                    end
                end
            end
        end
    end)
    task.spawn(function()
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return end
        plots.DescendantAdded:Connect(function(obj)
            if obj and obj:IsA("ProximityPrompt") then
                if InternalStealCache[obj] and InternalStealCache[obj].ready then return end
                pcall(buildStealCallbacks, obj)
            end
        end)
    end)
    task.spawn(function()
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return end
        local _scanStartTime = os.clock()
        while true do
            local elapsed = os.clock() - _scanStartTime
            if elapsed < 30 then
                task.wait(0.15)
            else
                task.wait(0.35)
            end
            for _, plot in ipairs(plots:GetChildren()) do
                if isMyPlot_Instant(plot.Name) then continue end
                local podiums = plot:FindFirstChild("AnimalPodiums")
                if not podiums then continue end
                for _, pod in ipairs(podiums:GetChildren()) do
                    local base = pod:FindFirstChild("Base")
                    local spawn = base and base:FindFirstChild("Spawn")
                    if not spawn then continue end
                    local att = spawn:FindFirstChild("PromptAttachment")
                    if not att then continue end
                    local prompt = att:FindFirstChildOfClass("ProximityPrompt")
                    if prompt and not (InternalStealCache[prompt] and InternalStealCache[prompt].ready) then
                        pcall(buildStealCallbacks, prompt)
                    end
                end
            end
        end
    end)
    local function isMyPlotByName(pn)
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return false end
        local plot = plots:FindFirstChild(pn)
        if not plot then return false end
        local sign = plot:FindFirstChild("PlotSign")
        if sign then
            local yb = sign:FindFirstChild("YourBase")
            if yb and yb:IsA("BillboardGui") then
                return yb.Enabled == true
            end
        end
        return false
    end
    local function findNearestPrompt(ignoreStunLockout, ignoreRadius)
        if not ignoreStunLockout and isInStunLockout() then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return end
        local prioOn    = stealPriorityEnabled == true
        local highestOn = stealHighestEnabled == true
        local cacheBySlot = {}
        for _, cached in ipairs(allAnimalsCache) do
            if cached.plot and cached.slot and cached.name then
                cacheBySlot[cached.plot .. "|" .. cached.slot] = cached
            end
        end
        local function nameMatches(animalName, prioName)
            if not animalName then return false end
            local a = animalName:lower()
            local p = prioName:lower()
            if a == p then return true end
            if a:find(p, 1, true) or p:find(a, 1, true) then return true end
            return false
        end
        local skipRadius = ignoreRadius or _G.ZawaHub_IgnoreStealRadius
        local candidates = {}  
        for _, plot in ipairs(plots:GetChildren()) do
            if isMyPlotByName(plot.Name) then continue end
            local pods = plot:FindFirstChild("AnimalPodiums")
            if not pods then continue end
            for _, pod in ipairs(pods:GetChildren()) do
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local d = (spawn.Position - hrp.Position).Magnitude
                    if skipRadius or d <= STEAL_RADIUS then
                        local att = spawn:FindFirstChild("PromptAttachment")
                        if att then
                            local found
                            for _, p in ipairs(att:GetChildren()) do
                                if p:IsA("ProximityPrompt") and p.ActionText:find("Steal") then
                                    found = p; break
                                end
                            end
                            if found then
                                table.insert(candidates, {
                                    prompt = found,
                                    cached = cacheBySlot[plot.Name .. "|" .. pod.Name],
                                    plotName = plot.Name,
                                    slotName = pod.Name,
                                    dist = d,
                                })
                            end
                        end
                    end
                end
            end
        end
        local function getCandidateName(c)
            if c.cached and c.cached.name then return c.cached.name end
            if c._liveLookedUp then return c._liveName end
            c._liveLookedUp = true
            local ok, ch = pcall(function() return Synchronizer.caches[c.plotName] end)
            if not ok or not ch then return nil end
            local ok2, al = pcall(function() return ch.AnimalList end)
            if not ok2 or type(al) ~= "table" then return nil end
            local ad = al[tonumber(c.slotName)] or al[c.slotName]
            if type(ad) ~= "table" then return nil end
            local info = AnimalsData and AnimalsData[ad.Index]
            c._liveName = (info and info.DisplayName) or ad.Index
            return c._liveName
        end
        if #candidates == 0 then return nil end
        local nearestOn = stealNearestEnabled == true
        if not prioOn and not highestOn and not nearestOn then
            local sel = SharedState.SelectedPetData
            if sel then
                local selUid = sel.uid or (sel.animalData and sel.animalData.uid)
                if selUid then
                    for _, c in ipairs(candidates) do
                        if c.cached and c.cached.uid == selUid then
                            return c.prompt
                        end
                    end
                end
            end
            return nil
        end
        for _, prioName in ipairs(PRIORITY_LIST) do
            local best = nil
            for _, c in ipairs(candidates) do
                local nm = getCandidateName(c)
                if nm and nameMatches(nm, prioName) then
                    if not best or c.dist < best.dist then best = c end
                end
            end
            if best then return best.prompt end
            if prioOn then
                for _, cached in ipairs(allAnimalsCache) do
                    if cached.name
                       and cached.owner ~= LocalPlayer.Name
                       and nameMatches(cached.name, prioName) then
                        return nil
                    end
                end
            end
        end
        if prioOn then return nil end
        if highestOn then
            table.sort(candidates, function(a, b)
                local av = (a.cached and a.cached.genValue) or 0
                local bv = (b.cached and b.cached.genValue) or 0
                return av > bv
            end)
            return candidates[1].prompt
        end
        table.sort(candidates, function(a, b) return a.dist < b.dist end)
        return candidates[1].prompt
    end
    RunService.Heartbeat:Connect(function()
        if not autoStealEnabled then return end
        if LocalPlayer:GetAttribute("Stealing") then return end
        if isStealing then return end
        local stunRemaining = _effectiveStunRemaining()
        if stunRemaining > STEAL_RESUME_LEAD then
            return
        end
        local p = findNearestPrompt()
        if p then
            pcall(function()
                local node = p
                local slot, plot
                while node and node.Parent do
                    local parent = node.Parent
                    if parent and parent.Name == "AnimalPodiums" then
                        slot = node.Name
                        if parent.Parent then plot = parent.Parent.Name end
                        break
                    end
                    node = parent
                end
                if plot and slot then
                    for _, cached in ipairs(allAnimalsCache) do
                        if cached.plot == plot and cached.slot == slot then
                            _G.ZawaHub_CurrentStealTargetName = cached.name
                            _G.ZawaHub_CurrentStealTargetMps  = cached.genText
                            break
                        end
                    end
                end
            end)
            executeSteal(p)
        end
    end)
    task.spawn(function()
        while true do
            task.wait(0.1)
            updateUI(autoStealEnabled, get_all_pets())
        end
    end)
    task.delay(1, function() SharedState.ListNeedsRedraw=true; updateUI(autoStealEnabled, get_all_pets()) end)
    task.spawn(function() while true do SharedState.AllAnimalsCache=allAnimalsCache; task.wait(0.5) end end)
    Players.PlayerRemoving:Connect(function(leaving)
        local leavingName = leaving and leaving.Name
        if not leavingName then return end
        for i = #allAnimalsCache, 1, -1 do
            if allAnimalsCache[i].owner == leavingName then
                table.remove(allAnimalsCache, i)
            end
        end
        for plotName, _ in pairs(lastAnimalData) do
            lastAnimalData[plotName] = ""
        end
        SharedState.ListNeedsRedraw = true
        pcall(function() updateUI(autoStealEnabled, get_all_pets()) end)
    end)
    do 
    local beamFolder = Instance.new("Folder", Workspace)
    beamFolder.Name = "XiTracers"
    local currentBeam = nil
    local currentAtt0 = nil
    local currentAtt1 = nil
    local function updateTracer()
        if not autoStealEnabled or not Config.TracerEnabled then
            if currentBeam then currentBeam:Destroy() currentBeam=nil end
            if currentAtt0 then currentAtt0:Destroy() currentAtt0=nil end
            if currentAtt1 then currentAtt1:Destroy() currentAtt1=nil end
            return
        end
        local best = nil
        local targetPart = nil
        if Config.LineToBase then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local plots = Workspace:FindFirstChild("Plots")
                if plots then
                    for _, plot in ipairs(plots:GetChildren()) do
                        local ok, ch = pcall(function() return Synchronizer.caches[plot.Name] end)
                        if ok and ch then
                            local owner = ch.Owner
                            local ownerId = (typeof(owner) == "Instance" and owner:IsA("Player")) and owner.UserId or (type(owner) == "table" and owner.UserId)
                            if ownerId == LocalPlayer.UserId then
                                local plotPos = plot:FindFirstChild("Base") and plot.Base:FindFirstChild("Spawn")
                                if plotPos and plotPos:IsA("BasePart") then
                                    targetPart = plotPos
                                    break
                                end
                            end
                        end
                    end
                end
            end
        else
            local pets = get_all_pets()
            if #pets == 0 then
                if currentBeam then currentBeam.Enabled=false end
                return
            end
            if selectedTargetIndex > #pets then selectedTargetIndex = #pets end
            if selectedTargetIndex < 1 then selectedTargetIndex = 1 end
            best = pets[selectedTargetIndex] or pets[1]
            targetPart = findAdorneeGlobal(best.animalData)
        end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and targetPart then
            if not currentAtt0 or currentAtt0.Parent ~= hrp then
                if currentAtt0 then currentAtt0:Destroy() end
                currentAtt0 = Instance.new("Attachment", hrp)
            end
            if not currentAtt1 or currentAtt1.Parent ~= targetPart then
                if currentAtt1 then currentAtt1:Destroy() end
                currentAtt1 = Instance.new("Attachment", targetPart)
            end
            if not currentBeam then
                currentBeam = Instance.new("Beam", beamFolder)
                currentBeam.FaceCamera = true
                currentBeam.Width0 = 0.8
                currentBeam.Width1 = 0.8
                currentBeam.TextureMode = Enum.TextureMode.Static
                currentBeam.TextureSpeed = 3
            end
            currentBeam.Attachment0 = currentAtt0
            currentBeam.Attachment1 = currentAtt1
            currentBeam.Enabled = true
            do
            local MUT_COLORS_TRACE = {
                Cursed=Color3.fromRGB(200,0,0), Gold=Color3.fromRGB(255,215,0),
                Diamond=Color3.fromRGB(0,255,255), YinYang=Color3.fromRGB(220,220,220),
                Rainbow=Color3.fromRGB(255,100,200), Lava=Color3.fromRGB(255,100,20),
                Candy=Color3.fromRGB(255,105,180), Divine=Color3.fromRGB(255,255,255)
            }
            local col = Theme.Accent2
            if not Config.LineToBase then
                col = (best and best.mutation and MUT_COLORS_TRACE[best.mutation]) or Theme.Accent1
            end
            currentBeam.Color = ColorSequence.new(col)
            end 
        else
            if currentBeam then currentBeam.Enabled = false end
        end
    end
    task.spawn(function()
        while true do
            task.wait(0.05)
            updateTracer()
        end
    end)
    end 
end)
do
    local StealBar = {
        gui = nil,
        container = nil,
        fill = nil,
        percent = nil,
        fillMaxWidth = 200,
        startTime = nil,
        active = false,
    }
    _G.ZawaHub_StealBar = StealBar
    local function createStealBarGui()
        if StealBar.gui and StealBar.gui.Parent then return end
        if StealBar.gui then pcall(function() StealBar.gui:Destroy() end) end
        local pg = PlayerGui
        if not pg then return end
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
        local gui = Instance.new("ScreenGui")
        gui.Name = "ZawaHubStealBar"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.IgnoreGuiInset = false
        gui.DisplayOrder = 9998
        gui.Parent = pg
        StealBar.gui = gui
        local barWidth = IS_MOBILE and math.min(viewport.X - 80, 240) or 260
        local barHeight = IS_MOBILE and 22 or 24
        local topLabelHeight = 18      
        local statusLabelHeight = 16   
        local containerHeight = topLabelHeight + barHeight + statusLabelHeight + 6
        local topBarOffset = IS_MOBILE and -145 or -130
        local barY = topBarOffset - containerHeight - 4
        local container = Instance.new("Frame", gui)
        container.Name = "StealBarContainer"
        container.Size = UDim2.new(0, barWidth, 0, containerHeight)
        container.Position = UDim2.new(0.5, -barWidth/2, 1, barY)
        container.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        container.BackgroundTransparency = 0.15
        container.BorderSizePixel = 0
        container.Visible = false
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
        local nameLabel = Instance.new("TextLabel", container)
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, -16, 0, topLabelHeight)
        nameLabel.Position = UDim2.new(0, 8, 0, 2)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = ""
        nameLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = IS_MOBILE and 11 or 12
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        StealBar.nameLabel = nameLabel
        local statusLabel = Instance.new("TextLabel", container)
        statusLabel.Name = "StatusLabel"
        statusLabel.Size = UDim2.new(1, -16, 0, statusLabelHeight)
        statusLabel.Position = UDim2.new(0, 8, 1, -statusLabelHeight - 2)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = ""
        statusLabel.TextColor3 = Color3.fromRGB(255, 230, 100)
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.TextSize = IS_MOBILE and 10 or 11
        statusLabel.TextXAlignment = Enum.TextXAlignment.Center
        statusLabel.Visible = false
        StealBar.statusLabel = statusLabel
        local barRow = Instance.new("Frame", container)
        barRow.Name = "BarRow"
        barRow.Size = UDim2.new(1, 0, 0, barHeight)
        barRow.Position = UDim2.new(0, 0, 0, topLabelHeight + 2)
        barRow.BackgroundTransparency = 1
        StealBar.barRow = barRow
        local containerStroke = Instance.new("UIStroke", container)
        containerStroke.Color = Color3.fromRGB(45, 45, 65)
        containerStroke.Thickness = 1
        containerStroke.Transparency = 0.3
        StealBar.container = container
        local innerPadding = 8
        local innerFrame = Instance.new("Frame", barRow)
        innerFrame.Size = UDim2.new(1, -innerPadding*2, 1, -6)
        innerFrame.Position = UDim2.new(0, innerPadding, 0, 3)
        innerFrame.BackgroundTransparency = 1
        local labelWidth = IS_MOBILE and 55 or 65
        local label = Instance.new("TextLabel", innerFrame)
        label.Name = "StealLabel"
        label.Size = UDim2.new(0, labelWidth, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = "STEALING"
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Font = Enum.Font.GothamBold
        label.TextSize = IS_MOBILE and 9 or 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        local progressBarX = labelWidth + 6
        local percentBoxWidth = 42
        local progressBarWidth = barWidth - innerPadding*2 - labelWidth - percentBoxWidth - 12
        local barBg = Instance.new("Frame", innerFrame)
        barBg.Name = "BarBackground"
        barBg.Size = UDim2.new(0, progressBarWidth, 1, 0)
        barBg.Position = UDim2.new(0, progressBarX, 0, 0)
        barBg.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        barBg.BorderSizePixel = 0
        Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 4)
        local barFill = Instance.new("Frame", barBg)
        barFill.Name = "BarFill"
        barFill.Size = UDim2.new(0, 0, 1, -4)
        barFill.Position = UDim2.new(0, 2, 0, 2)
        barFill.BackgroundColor3 = Color3.fromRGB(111, 167, 254)
        barFill.BorderSizePixel = 0
        Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 3)
        local gradient = Instance.new("UIGradient", barFill)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 125, 210)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(111, 167, 254)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(111, 167, 254))
        })
        gradient.Rotation = 0
        StealBar.fill = barFill
        StealBar.fillMaxWidth = progressBarWidth - 4
        local percentBox = Instance.new("Frame", innerFrame)
        percentBox.Size = UDim2.new(0, percentBoxWidth, 1, 0)
        percentBox.Position = UDim2.new(1, -percentBoxWidth, 0, 0)
        percentBox.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        percentBox.BorderSizePixel = 0
        Instance.new("UICorner", percentBox).CornerRadius = UDim.new(0, 4)
        local percentText = Instance.new("TextLabel", percentBox)
        percentText.Name = "PercentText"
        percentText.Size = UDim2.new(1, 0, 1, 0)
        percentText.BackgroundTransparency = 1
        percentText.Text = "0%"
        percentText.TextColor3 = Color3.fromRGB(255, 255, 255)
        percentText.Font = Enum.Font.GothamBold
        percentText.TextSize = IS_MOBILE and 10 or 11
        StealBar.percent = percentText
        gui.Enabled = true
    end
    StealBar.create = createStealBarGui
    task.spawn(function()
        task.wait(2)
        local STEAL_DURATION = 1.3
        while true do
            task.wait(0.016)
            if not Config.StealBarEnabled then
                if StealBar.container then StealBar.container.Visible = false end
                continue
            end
            if not StealBar.gui or not StealBar.gui.Parent then
                pcall(createStealBarGui)
                if not StealBar.container then continue end
            end
            local now = tick()
            local progress = 0
            local hasActiveSteal = false
            pcall(function()
                local getState = _G.ZawaHub_GetStealState
                if getState then
                    local ready, startTime = getState()
                    if not ready and startTime then
                        local elapsed = now - startTime
                        progress = math.clamp(elapsed / STEAL_DURATION, 0, 1)
                        hasActiveSteal = true
                    end
                end
            end)
            if not hasActiveSteal then
                if LocalPlayer:GetAttribute("Stealing") == true then
                    progress = 0.5 + 0.4 * math.sin(now * 4)
                    hasActiveSteal = true
                end
            end
            StealBar.container.Visible = hasActiveSteal
            if StealBar.nameLabel then
                local n, m = nil, nil
                local sel = SharedState and SharedState.SelectedPetData
                local selData = sel and (sel.animalData or sel)
                if selData and selData.name then
                    n = selData.name
                    m = selData.genText
                else
                    n = _G.ZawaHub_CurrentStealTargetName
                    m = _G.ZawaHub_CurrentStealTargetMps
                end
                if n and n ~= "" then
                    if m and m ~= "" then
                        StealBar.nameLabel.Text = tostring(n) .. " - " .. tostring(m)
                    else
                        StealBar.nameLabel.Text = tostring(n)
                    end
                else
                    StealBar.nameLabel.Text = ""
                end
            end
            if StealBar.statusLabel then
                local stunEnd = 0
                pcall(function()
                    local getStun = _G.ZawaHub_GetStunCooldownEnd
                    if getStun then stunEnd = getStun() or 0 end
                end)
                local remaining = stunEnd - tick()
                if remaining > 0 then
                    StealBar.statusLabel.Text = string.format("Paused: Ragdolled (%.1fs)", remaining)
                    StealBar.statusLabel.Visible = true
                else
                    StealBar.statusLabel.Visible = false
                end
            end
            local maxW = StealBar.fillMaxWidth or 200
            if StealBar.fill then
                StealBar.fill.Size = UDim2.new(0, maxW * progress, 1, -4)
                if progress >= 0.95 then
                    StealBar.fill.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
                else
                    StealBar.fill.BackgroundColor3 = Color3.fromRGB(0, 150 + math.floor(progress * 105), 0)
                end
            end
            if StealBar.percent then
                StealBar.percent.Text = math.floor(progress * 100) .. "%"
                if progress >= 0.95 then
                    StealBar.percent.TextColor3 = Color3.fromRGB(100, 255, 100)
                else
                    StealBar.percent.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
            end
        end
    end)
    if Config.StealBarEnabled then
        task.delay(0.5, function() pcall(createStealBarGui) end)
    end
end
task.spawn(function()
    task.wait(0.15)
    local COOLDOWNS = {
        rocket = 120, ragdoll = 30, balloon = 30, inverse = 60,
        nightvision = 60, jail = 60, tiny = 60, jumpscare = 60, morph = 60
    }
    local ALL_COMMANDS = {
        "balloon", "inverse", "jail", "jumpscare", "morph",
        "nightvision", "ragdoll", "rocket", "tiny"
    }
    local activeCooldowns = {} 
    SharedState.AdminButtonCache = {} 
    local adminGui = Instance.new("ScreenGui")
    adminGui.Name = "XiAdminPanel"
    adminGui.ResetOnSpawn = false
    adminGui.Parent = PlayerGui
    local frame = Instance.new("Frame")
    local mobileScale = IS_MOBILE and 0.65 or 1
frame.Size = UDim2.new(0, 480*mobileScale, 0, 480*mobileScale)
    frame.Position = UDim2.new(Config.Positions.AdminPanel.X, 0, Config.Positions.AdminPanel.Y, 0)
    frame.BackgroundColor3 = Theme.Background
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = adminGui
    local listFrame
    local layout
    local blFrame
    ApplyViewportUIScale(frame, 400, 450, 0.45, 0.85)
    AddMobileMinimize(frame, "ADMIN")
    AddResizeHandle(frame, "AdminPanel", UDim2.new(1, -107, 0, 6))
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Theme.Accent2; stroke.Thickness = 1.5; stroke.Transparency = 0.4
    CreateGradient(stroke)
    local header = Instance.new("Frame", frame)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    MakeDraggable(header, frame, "AdminPanel")
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "admin panel"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.TextColor3 = Theme.TextPrimary
    title.TextXAlignment = Enum.TextXAlignment.Left
    local refreshBtn = Instance.new("TextButton", header)
    refreshBtn.Size = UDim2.new(0, 80, 0, 30)
    refreshBtn.Position = UDim2.new(1, -85, 0.5, -15)
    refreshBtn.BackgroundColor3 = Theme.SurfaceHighlight
    refreshBtn.Text = "REFRESH"
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 12
    refreshBtn.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 6)
    local refreshStroke = Instance.new("UIStroke", refreshBtn)
    refreshStroke.Color = Theme.Accent2
    refreshStroke.Thickness = 1
    refreshStroke.Transparency = 0.3
    refreshBtn.MouseButton1Click:Connect(function()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if Config.HideKawaifuFromPanel and isKawaifuUser(player) then continue end
            pcall(createPlayerRow, player)
        end
        sortAdminPanelList()
        ShowNotification("ADMIN PANEL", "Player list refreshed")
    end)
    local proxCont = Instance.new("Frame", frame)
    proxCont.Size = UDim2.new(1, -20, 0, 44)
    proxCont.Position = UDim2.new(0, 10, 0, 58)
    proxCont.BackgroundColor3 = Color3.fromRGB(30, 7, 7)
    proxCont.BackgroundTransparency = 0.3
    Instance.new("UICorner", proxCont).CornerRadius = UDim.new(0, 10)
    local proxContStroke = Instance.new("UIStroke", proxCont)
    proxContStroke.Color = Theme.Accent2
    proxContStroke.Thickness = 1
    proxContStroke.Transparency = 0.6
    local proxBtn = Instance.new("TextButton", proxCont)
    proxBtn.Name = "ProximityAPButton"
    proxBtn.Size = UDim2.new(0, 70, 0, 26)
    proxBtn.Position = UDim2.new(0, 6, 0.5, -13)
    proxBtn.BackgroundColor3 = ProximityAPActive and Theme.Accent1 or Color3.fromRGB(100, 12, 12)
    proxBtn.Text = "Prox"
    proxBtn.Font = Enum.Font.GothamBold; proxBtn.TextSize = 11
    proxBtn.TextColor3 = ProximityAPActive and Color3.new(255,255,255) or Theme.TextPrimary
    Instance.new("UICorner", proxBtn).CornerRadius = UDim.new(0, 6)
    local proxBtnStroke = Instance.new("UIStroke", proxBtn)
    proxBtnStroke.Color = ProximityAPActive and Theme.Accent2 or Color3.fromRGB(90, 35, 55)
    proxBtnStroke.Transparency = 0.3
    SharedState.ProximityAPButton = proxBtn
    SharedState.ProximityAPButtonStroke = proxBtnStroke
    SharedState.AdminProxBtn = proxBtn
    local spamBaseBtn = Instance.new("TextButton", proxCont)
    spamBaseBtn.Size = UDim2.new(0, 70, 0, 26)
    spamBaseBtn.Position = UDim2.new(0, 80, 0.5, -13)
    spamBaseBtn.BackgroundColor3 = Color3.fromRGB(100, 12, 12)
    spamBaseBtn.Text = "Spam Owner"
    spamBaseBtn.Font = Enum.Font.GothamBold; spamBaseBtn.TextSize = 9
    spamBaseBtn.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", spamBaseBtn).CornerRadius = UDim.new(0, 6)
    local spamBaseBtnStroke = Instance.new("UIStroke", spamBaseBtn)
    spamBaseBtnStroke.Color = Color3.fromRGB(90, 35, 55)
    spamBaseBtnStroke.Transparency = 0.3
    local ctapPanelBtn = Instance.new("TextButton", proxCont)
    ctapPanelBtn.Size = UDim2.new(0, 60, 0, 26)
    ctapPanelBtn.Position = UDim2.new(0, 154, 0.5, -13)
    ctapPanelBtn.AutoButtonColor = false
    ctapPanelBtn.Text = "Click AP"
    ctapPanelBtn.Font = Enum.Font.GothamBold
    ctapPanelBtn.TextSize = 9
    ctapPanelBtn.BorderSizePixel = 0
    local function updateCtapPanelBtn()
        ctapPanelBtn.BackgroundColor3 = Config.ClickToAP and Theme.Accent1 or Color3.fromRGB(100, 12, 12)
        ctapPanelBtn.TextColor3 = Config.ClickToAP and Color3.new(0,0,0) or Theme.TextPrimary
    end
    updateCtapPanelBtn()
    Instance.new("UICorner", ctapPanelBtn).CornerRadius = UDim.new(0, 6)
    local ctapPanelStroke = Instance.new("UIStroke", ctapPanelBtn)
    ctapPanelStroke.Color = Color3.fromRGB(90, 35, 55)
    ctapPanelStroke.Transparency = 0.3
    ctapPanelBtn.MouseButton1Click:Connect(function()
        Config.ClickToAP = not Config.ClickToAP
        if Config.ClickToAP then
            Config.ClickToAPSingleCommand = true
        end
        SaveConfig()
        updateCtapPanelBtn()
        ShowNotification("CLICK TO AP", Config.ClickToAP and "ON (single cmd)" or "DISABLED")
    end)
    spamBaseBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            ShowNotification("SPAM OWNER", "No character found")
            return
        end
        local nearestPlot = nil
        local nearestDist = math.huge
        local Plots = Workspace:FindFirstChild("Plots")
        if Plots then
            for _, plot in ipairs(Plots:GetChildren()) do
                local sign = plot:FindFirstChild("PlotSign")
                if sign then
                    local yourBase = sign:FindFirstChild("YourBase")
                    if not yourBase or not yourBase.Enabled then
                        local signPos = sign:IsA("BasePart") and sign.Position or (sign.PrimaryPart and sign.PrimaryPart.Position)
                        if not signPos then
                            local part = sign:FindFirstChildWhichIsA("BasePart", true)
                            signPos = part and part.Position
                        end
                        if signPos then
                            local dist = (hrp.Position - signPos).Magnitude
                            if dist < nearestDist then
                                nearestDist = dist
                                nearestPlot = plot
                            end
                        end
                    end
                end
            end
        end
        if not nearestPlot then
            ShowNotification("SPAM OWNER", "No nearby base found")
            return
        end
        local targetPlayer = nil
        local ok, ch = pcall(function() return Synchronizer.caches[nearestPlot.Name] end)
        if ok and ch then
            local owner = ch.Owner
            if owner then
                if typeof(owner) == "Instance" and owner:IsA("Player") then
                    targetPlayer = owner
                elseif type(owner) == "table" and owner.Name then
                    targetPlayer = Players:FindFirstChild(owner.Name)
                end
            end
        end
        if not targetPlayer then
            local sign = nearestPlot:FindFirstChild("PlotSign")
            local textLabel = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame") and sign.SurfaceGui.Frame:FindFirstChild("TextLabel")
            if textLabel then
                local baseText = textLabel.Text
                local nickname = baseText and baseText:match("^(.-)'") or baseText
                if nickname then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.DisplayName == nickname or p.Name == nickname then
                            targetPlayer = p
                            break
                        end
                    end
                end
            end
        end
        if not targetPlayer or targetPlayer == LocalPlayer then
            ShowNotification("SPAM OWNER", "Owner not found or is you")
            return
        end
        spamBaseBtn.BackgroundColor3 = Theme.Accent1
        spamBaseBtn.TextColor3 = Color3.new(1,1,1)
        ShowNotification("SPAM OWNER", "Spamming " .. targetPlayer.DisplayName)
        task.spawn(function()
            local cmds = {"balloon", "inverse", "jail", "jumpscare", "morph", "nightvision", "ragdoll", "rocket", "tiny"}
            local cmdCount = 0
            local adminFunc = _G.runAdminCommand
            if not adminFunc then
                task.wait(0.05)
                adminFunc = _G.runAdminCommand
            end
            if not adminFunc then
                spamBaseBtn.BackgroundColor3 = Color3.fromRGB(100, 12, 12)
                spamBaseBtn.TextColor3 = Theme.TextPrimary
                ShowNotification("SPAM OWNER", "Admin command not ready")
                return
            end
            for _, cmd in ipairs(cmds) do
                local success, result = pcall(function()
                    return adminFunc(targetPlayer, cmd)
                end)
                if success and result then
                    cmdCount = cmdCount + 1
                end
                task.wait(0.15)
            end
            task.wait(0.2)
            spamBaseBtn.BackgroundColor3 = Color3.fromRGB(100, 12, 12)
            spamBaseBtn.TextColor3 = Theme.TextPrimary
            ShowNotification("SPAM OWNER", "Sent " .. cmdCount .. " commands to " .. targetPlayer.DisplayName)
        end)
    end)
    local proxSliderBg = Instance.new("Frame", proxCont)
    proxSliderBg.Size = UDim2.new(0, 140, 0, 5)
    proxSliderBg.Position = UDim2.new(0, 105, 0.5, -2.5)
    proxSliderBg.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
    Instance.new("UICorner", proxSliderBg).CornerRadius = UDim.new(1,0)
    local proxFill = Instance.new("Frame", proxSliderBg)
    proxFill.BackgroundColor3 = Theme.Accent1; proxFill.Size = UDim2.new(0,0,1,0)
    Instance.new("UICorner", proxFill).CornerRadius = UDim.new(1,0)
    local proxKnob = Instance.new("Frame", proxSliderBg)
    proxKnob.Size = UDim2.new(0,12,0,12); proxKnob.BackgroundColor3 = Theme.TextPrimary
    proxKnob.AnchorPoint = Vector2.new(0.5, 0.5); proxKnob.Position = UDim2.new(0,0,0.5,0)
    Instance.new("UICorner", proxKnob).CornerRadius = UDim.new(1,0)
    local proxKnobStroke = Instance.new("UIStroke", proxKnob)
    proxKnobStroke.Color = Theme.Accent1
    proxKnobStroke.Thickness = 1.5
    proxKnobStroke.Transparency = 0.2
    local function updateProxSlider(val)
        local min, max = 5, 50
        val = math.clamp(val, min, max)
        Config.ProximityRange = val; SaveConfig()
        local pct = (val - min)/(max - min)
        proxFill.Size = UDim2.new(pct, 0, 1, 0)
        proxKnob.Position = UDim2.new(pct, 0, 0.5, 0)
        ShowNotification("PROXIMITY RANGE", string.format("%.1f", val) .. " studs")
    end
    updateProxSlider(Config.ProximityRange)
    local pDragging = false
    proxSliderBg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then pDragging=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then pDragging=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if pDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local x = i.Position.X
            local r = proxSliderBg.AbsolutePosition.X
            local w = proxSliderBg.AbsoluteSize.X
            local p = (x - r) / w
            updateProxSlider(5 + (p * 45))
        end
    end)
    local proxViz = nil
    local function updateProxViz()
        if ProximityAPActive then 
            if not proxViz then
                proxViz = Instance.new("Part")
                proxViz.Name = "XiProxViz"
                proxViz.Anchored = true; proxViz.CanCollide = false
                proxViz.Shape = Enum.PartType.Cylinder
                proxViz.Color = Theme.Accent1; proxViz.Transparency = 0.6
                proxViz.CastShadow = false
                proxViz.Parent = Workspace
            end
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                proxViz.Size = Vector3.new(0.5, Config.ProximityRange * 2, Config.ProximityRange * 2)
                proxViz.CFrame = hrp.CFrame * CFrame.Angles(0,0,math.rad(90)) + Vector3.new(0, -2.5, 0)
            end
        else
            if proxViz then proxViz:Destroy(); proxViz = nil end
        end
    end
    task.spawn(function()
        while true do
            task.wait(0.05)
            updateProxViz()
        end
    end)
    local function updateProximityAPButton()
        if SharedState.ProximityAPButton then
            SharedState.ProximityAPButton.BackgroundColor3 = ProximityAPActive and Theme.Accent1 or Color3.fromRGB(100, 12, 12)
            SharedState.ProximityAPButton.TextColor3 = ProximityAPActive and Color3.new(255,255,255) or Theme.TextPrimary
            if SharedState.ProximityAPButtonStroke then
                SharedState.ProximityAPButtonStroke.Color = ProximityAPActive and Theme.Accent2 or Color3.fromRGB(90, 35, 55)
            end
        end
    end
    proxBtn.MouseButton1Click:Connect(function()
        ProximityAPActive = not ProximityAPActive 
        updateProximityAPButton()
        ShowNotification("PROXIMITY AP", ProximityAPActive and "ENABLED" or "DISABLED")
    end)
    proxSliderBg.Position = UDim2.new(0, 220, 0.5, -2.5)
    local tabBar = Instance.new("Frame", frame)
    tabBar.Size = UDim2.new(1, -20, 0, 28)
    tabBar.Position = UDim2.new(0, 10, 0, 108)
    tabBar.BackgroundTransparency = 1
    tabBar.BorderSizePixel = 0
    local tabBarLayout = Instance.new("UIListLayout", tabBar)
    tabBarLayout.FillDirection = Enum.FillDirection.Horizontal
    tabBarLayout.Padding = UDim.new(0, 4)
    tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    local function makeTabBtn(parent, label, order)
        local btn = Instance.new("TextButton", parent)
        btn.LayoutOrder = order
    btn.Size = UDim2.new(0, 110, 0, 24)
        btn.AutoButtonColor = false
        btn.Text = label
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local s = Instance.new("UIStroke", btn)
        s.Thickness = 1
        s.Transparency = 0.4
        return btn, s
    end
    local tabPlayers, tabPlayersStroke = makeTabBtn(tabBar, "PLAYERS", 1)
    local tabBlacklist, tabBlacklistStroke = makeTabBtn(tabBar, "BLACKLIST", 2)
    local activeTab = "players"
    local function setActiveTab(name)
        activeTab = name
        if name == "players" then
            tabPlayers.BackgroundColor3 = Theme.Accent1
            tabPlayers.TextColor3 = Color3.new(0,0,0)
            tabPlayersStroke.Color = Theme.Accent1
            tabBlacklist.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
            tabBlacklist.TextColor3 = Theme.TextPrimary
            tabBlacklistStroke.Color = Color3.fromRGB(130, 30, 30)
            listFrame.Visible = true
            blFrame.Visible = false
        else
            tabBlacklist.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
            tabBlacklist.TextColor3 = Color3.fromRGB(255, 210, 210)
            tabBlacklistStroke.Color = Color3.fromRGB(180, 50, 50)
            tabPlayers.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
            tabPlayers.TextColor3 = Theme.TextPrimary
            tabPlayersStroke.Color = Color3.fromRGB(130, 30, 30)
            listFrame.Visible = false
            blFrame.Visible = true
        end
        if SharedState._RefreshAdminEmptyState then
            SharedState._RefreshAdminEmptyState()
        end
    end
    tabPlayers.MouseButton1Click:Connect(function() setActiveTab("players") end)
    tabBlacklist.MouseButton1Click:Connect(function() setActiveTab("blacklist") end)
    blFrame = Instance.new("Frame", frame)
    blFrame.Size = UDim2.new(1, -20, 1, -144)
    blFrame.Position = UDim2.new(0, 10, 0, 142)
    blFrame.BackgroundTransparency = 1
    blFrame.BorderSizePixel = 0
    blFrame.ZIndex = 5
    blFrame.Active = true
    blFrame.Visible = false
    local blInput = Instance.new("TextBox", blFrame)
    blInput.Size = UDim2.new(1, -58, 0, 26)
    blInput.Position = UDim2.new(0, 0, 0, 0)
    blInput.ZIndex = 6
    blInput.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    blInput.BorderSizePixel = 0
    blInput.Text = ""
    blInput.PlaceholderText = "Roblox username..."
    blInput.Font = Enum.Font.Gotham
    blInput.TextSize = 11
    blInput.TextColor3 = Theme.TextPrimary
    blInput.PlaceholderColor3 = Color3.fromRGB(80, 80, 95)
    blInput.ClearTextOnFocus = false
    Instance.new("UICorner", blInput).CornerRadius = UDim.new(0, 6)
    local blInputStroke = Instance.new("UIStroke", blInput)
    blInputStroke.Color = Color3.fromRGB(160, 20, 20)
    blInputStroke.Thickness = 1
    blInputStroke.Transparency = 0.3
    local blInputPad = Instance.new("UIPadding", blInput)
    blInputPad.PaddingLeft = UDim.new(0, 8)
    local blAddBtn = Instance.new("TextButton", blFrame)
    blAddBtn.Size = UDim2.new(0, 50, 0, 26)
    blAddBtn.Position = UDim2.new(1, -50, 0, 0)
    blAddBtn.ZIndex = 6
    blAddBtn.BackgroundColor3 = Color3.fromRGB(140, 35, 35)
    blAddBtn.Text = "ADD"
    blAddBtn.Font = Enum.Font.GothamBold
    blAddBtn.TextSize = 11
    blAddBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
    blAddBtn.AutoButtonColor = false
    Instance.new("UICorner", blAddBtn).CornerRadius = UDim.new(0, 6)
    local blAddStroke = Instance.new("UIStroke", blAddBtn)
    blAddStroke.Color = Color3.fromRGB(180, 50, 50)
    blAddStroke.Thickness = 1
    blAddStroke.Transparency = 0.4
    local blListScroll = Instance.new("ScrollingFrame", blFrame)
    blListScroll.Size = UDim2.new(1, 0, 1, -34)
    blListScroll.Position = UDim2.new(0, 0, 0, 32)
    blListScroll.BackgroundTransparency = 1
    blListScroll.BorderSizePixel = 0
    blListScroll.ScrollBarThickness = 4
    blListScroll.ScrollBarImageColor3 = Color3.fromRGB(140, 40, 40)
    local blListLayout = Instance.new("UIListLayout", blListScroll)
    blListLayout.Padding = UDim.new(0, 4)
    blListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    blListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        blListScroll.CanvasSize = UDim2.new(0, 0, 0, blListLayout.AbsoluteContentSize.Y + 4)
    end)
    local function rebuildBlList()
        for _, c in ipairs(blListScroll:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        for i, name in ipairs(Config.BlacklistedUsers) do
            local row = Instance.new("Frame", blListScroll)
            row.LayoutOrder = i
            row.Size = UDim2.new(1, 0, 0, 28)
            row.BackgroundColor3 = Color3.fromRGB(30, 6, 6)
            row.BorderSizePixel = 0
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
            local rowStroke = Instance.new("UIStroke", row)
            rowStroke.Color = Color3.fromRGB(80, 30, 30)
            rowStroke.Thickness = 1
            rowStroke.Transparency = 0.5
            local nameLabel = Instance.new("TextLabel", row)
            nameLabel.Size = UDim2.new(1, -36, 1, 0)
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = name
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 11
            nameLabel.TextColor3 = Color3.fromRGB(230, 180, 180)
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            local removeBtn = Instance.new("TextButton", row)
            removeBtn.Size = UDim2.new(0, 26, 0, 20)
            removeBtn.Position = UDim2.new(1, -30, 0.5, -10)
            removeBtn.BackgroundColor3 = Color3.fromRGB(100, 25, 25)
            removeBtn.Text = "X"
            removeBtn.Font = Enum.Font.GothamBold
            removeBtn.TextSize = 10
            removeBtn.TextColor3 = Color3.fromRGB(255, 160, 160)
            removeBtn.AutoButtonColor = false
            Instance.new("UICorner", removeBtn).CornerRadius = UDim.new(0, 4)
            local capName = name
            removeBtn.MouseButton1Click:Connect(function()
                for j, n in ipairs(Config.BlacklistedUsers) do
                    if n:lower() == capName:lower() then
                        table.remove(Config.BlacklistedUsers, j)
                        break
                    end
                end
                SaveConfig()
                rebuildBlList()
                ShowNotification("BLACKLIST", "Removed " .. capName)
            end)
        end
        blListScroll.CanvasSize = UDim2.new(0, 0, 0, blListLayout.AbsoluteContentSize.Y + 4)
    end
    local function addBlacklistUser(username)
        username = username:match("^%s*(.-)%s*$")
        if username == "" then return end
        local lower = username:lower()
        for _, n in ipairs(Config.BlacklistedUsers) do
            if n:lower() == lower then
                ShowNotification("BLACKLIST", username .. " is already blacklisted")
                return
            end
        end
        table.insert(Config.BlacklistedUsers, username)
        SaveConfig()
        rebuildBlList()
        blInput.Text = ""
        ShowNotification("BLACKLIST", "Blacklisted: " .. username)
    end
    blAddBtn.MouseButton1Click:Connect(function()
        addBlacklistUser(blInput.Text)
    end)
    blInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then addBlacklistUser(blInput.Text) end
    end)
    rebuildBlList()
    listFrame = Instance.new("ScrollingFrame", frame)
    listFrame.Size = UDim2.new(1, -20, 1, -144)
    listFrame.Position = UDim2.new(0, 10, 0, 142)
    listFrame.BackgroundTransparency = 1
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 5
    listFrame.ScrollBarImageColor3 = Theme.Accent1
    layout = Instance.new("UIListLayout", listFrame)
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    local playerRows = {}
    local playerRowsByUserId = {}
    local emptyPlayersLbl = Instance.new("TextLabel")
    emptyPlayersLbl.Name = "_EmptyPlayersLabel"
    emptyPlayersLbl.Size = UDim2.new(1, -20, 0, 24)
    emptyPlayersLbl.Position = UDim2.new(0, 10, 0, 154)
    emptyPlayersLbl.BackgroundTransparency = 1
    emptyPlayersLbl.Text = "No players found"
    emptyPlayersLbl.Font = Enum.Font.GothamMedium
    emptyPlayersLbl.TextSize = 11
    emptyPlayersLbl.TextColor3 = Color3.fromRGB(170, 65, 65)
    emptyPlayersLbl.TextXAlignment = Enum.TextXAlignment.Center
    emptyPlayersLbl.Visible = false
    emptyPlayersLbl.ZIndex = 5
    emptyPlayersLbl.Parent = frame  
    local function refreshEmptyPlayersState()
        if not listFrame.Visible then
            emptyPlayersLbl.Visible = false
            return
        end
        local hasAny = false
        for _, r in pairs(playerRows) do
            if r and r.Parent then hasAny = true; break end
        end
        emptyPlayersLbl.Visible = not hasAny
    end
    SharedState._RefreshAdminEmptyState = refreshEmptyPlayersState
    setActiveTab("players")
    local function getAdminPanelSortKey(plr)
        if not plr or not plr.Parent then return 3, 9999, "" end
        local stealing = plr:GetAttribute("Stealing")
        local brainrotName = plr:GetAttribute("StealingIndex")
        if not stealing then
            return 3, 9999, plr.Name or ""
        end
        if brainrotName then
            for i, pName in ipairs(PRIORITY_LIST) do
                if pName == brainrotName then
                    return 1, i, plr.Name or ""
                end
            end
            return 2, 9999, plr.Name or ""
        end
        return 2, 9999, plr.Name or ""
    end
    local function sortAdminPanelList()
        local rows = {}
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") and child.Name ~= "" then
                local plr = Players:FindFirstChild(child.Name)
                if plr then
                    table.insert(rows, {row = child, plr = plr})
                end
            end
        end
        table.sort(rows, function(a, b)
            local t1, p1, n1 = getAdminPanelSortKey(a.plr)
            local t2, p2, n2 = getAdminPanelSortKey(b.plr)
            if t1 ~= t2 then return t1 < t2 end
            if p1 ~= p2 then return p1 < p2 end
            return (n1 or "") < (n2 or "")
        end)
        for i, entry in ipairs(rows) do
            entry.row.LayoutOrder = i
        end
    end
    local function fireClick(button)
        if button then
            local x = button.AbsolutePosition.X + (button.AbsoluteSize.X / 2)
            local y = button.AbsolutePosition.Y + (button.AbsoluteSize.Y / 2) + 58
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
        end
    end
    _G.fireClick = fireClick
    local function runAdminCommand(targetPlayer, commandName)
        if isBlacklisted(targetPlayer) then return false end
        local realAdminGui = PlayerGui:WaitForChild("AdminPanel", 5)
        if not realAdminGui then return false end
        local contentScroll = realAdminGui.AdminPanel:WaitForChild("Content"):WaitForChild("ScrollingFrame")
        local cmdBtn = contentScroll:FindFirstChild(commandName)
        if not cmdBtn then return false end
        fireClick(cmdBtn)
        task.wait(0.05)
        local profilesScroll = realAdminGui:WaitForChild("AdminPanel"):WaitForChild("Profiles"):WaitForChild("ScrollingFrame")
        local playerBtn = profilesScroll:FindFirstChild(targetPlayer.Name)
        if not playerBtn then return false end
        fireClick(playerBtn)
        return true
    end
    _G.runAdminCommand = runAdminCommand
local ALL_COMMANDS = {
    "balloon", "inverse", "jail", "jumpscare", "morph", 
    "nightvision", "ragdoll", "rocket", "tiny"
}
local isOnCooldown
local function getNextAvailableCommand()
    local priorityCommands = {"ragdoll", "balloon", "rocket", "jail"}
    local otherCommands = {}
    for _, cmd in ipairs(ALL_COMMANDS) do
        local isPriority = false
        for _, priorityCmd in ipairs(priorityCommands) do
            if cmd == priorityCmd then
                isPriority = true
                break
            end
        end
        if not isPriority then
            table.insert(otherCommands, cmd)
        end
    end
    for _, cmd in ipairs(priorityCommands) do
        if not isOnCooldown(cmd) then
            return cmd
        end
    end
    for _, cmd in ipairs(otherCommands) do
        if not isOnCooldown(cmd) then
            return cmd
        end
    end
    return nil
end
isOnCooldown = function(cmd)
    local adminGui = PlayerGui:FindFirstChild("AdminPanel")
    if adminGui then
        local content = adminGui:FindFirstChild("AdminPanel")
        if content then
            local scrollFrame = content:FindFirstChild("Content")
            if scrollFrame then
                local scrollingFrame = scrollFrame:FindFirstChild("ScrollingFrame")
                if scrollingFrame then
                    local cmdButton = scrollingFrame:FindFirstChild(cmd)
                    if cmdButton then
                        local timerLabel = cmdButton:FindFirstChild("Timer")
                        if timerLabel then
                            return timerLabel.Visible
                        end
                    end
                end
            end
        end
    end
    if not activeCooldowns[cmd] then return false end
    return (tick() - activeCooldowns[cmd]) < (COOLDOWNS[cmd] or 0)
end
    local function setGlobalVisualCooldown(cmd)
        if SharedState.AdminButtonCache[cmd] then
            for _, b in ipairs(SharedState.AdminButtonCache[cmd]) do
                if b and b.Parent then
                    b.BackgroundColor3 = Theme.Error
                    task.delay(COOLDOWNS[cmd] or 5, function()
                        if b and b.Parent then
                            local hasBallooned = (cmd == "balloon" and SharedState.BalloonedPlayers and next(SharedState.BalloonedPlayers) ~= nil)
                            b.BackgroundColor3 = hasBallooned and Theme.Error or Theme.SurfaceHighlight
                        end
                    end)
                end
            end
        end
    end
    local function updateBalloonButtons()
        local hasBallooned = false
        for _, _ in pairs(SharedState.BalloonedPlayers) do
            hasBallooned = true
            break
        end
        if SharedState.AdminButtonCache and SharedState.AdminButtonCache["balloon"] then
            for _, b in ipairs(SharedState.AdminButtonCache["balloon"]) do
                if b and b.Parent then
                    b.BackgroundColor3 = hasBallooned and Theme.Error or Theme.SurfaceHighlight
                end
            end
        end
    end
    local function triggerAll(plr)
        if isBlacklisted(plr) then return end
        local count = 0
        for _, cmd in ipairs(ALL_COMMANDS) do
            if not isOnCooldown(cmd) then
                task.delay(count * 0.1, function()
                    if runAdminCommand(plr, cmd) then
                        activeCooldowns[cmd] = tick()
                        setGlobalVisualCooldown(cmd)
                        if cmd == "balloon" then
                            SharedState.BalloonedPlayers[plr.UserId] = true
                            updateBalloonButtons()
                        end
                    end
                end)
                count = count + 1
            end
        end
    end
    local function rayToCubeIntersect(rayOrigin, rayDirection, cubeCenter, cubeSize)
        local halfSize = cubeSize / 2
        local minBounds = cubeCenter - Vector3.new(halfSize, halfSize, halfSize)
        local maxBounds = cubeCenter + Vector3.new(halfSize, halfSize, halfSize)
        if rayDirection.X == 0 then rayDirection = Vector3.new(0.0001, rayDirection.Y, rayDirection.Z) end
        if rayDirection.Y == 0 then rayDirection = Vector3.new(rayDirection.X, 0.0001, rayDirection.Z) end
        if rayDirection.Z == 0 then rayDirection = Vector3.new(rayDirection.X, rayDirection.Y, 0.0001) end
        local tmin = (minBounds.X - rayOrigin.X) / rayDirection.X
        local tmax = (maxBounds.X - rayOrigin.X) / rayDirection.X
        if tmin > tmax then tmin, tmax = tmax, tmin end
        local tymin = (minBounds.Y - rayOrigin.Y) / rayDirection.Y
        local tymax = (maxBounds.Y - rayOrigin.Y) / rayDirection.Y
        if tymin > tymax then tymin, tymax = tymax, tymin end
        if tmin > tymax or tymin > tmax then return false end
        if tymin > tmin then tmin = tymin end
        if tymax < tmax then tmax = tymax end
        local tzmin = (minBounds.Z - rayOrigin.Z) / rayDirection.Z
        local tzmax = (maxBounds.Z - rayOrigin.Z) / rayDirection.Z
        if tzmin > tzmax then tzmin, tzmax = tzmax, tzmin end
        if tmin > tzmax or tzmin > tmax then return false end
        return true
    end
    local highlight = Instance.new("Highlight", game:GetService("CoreGui"))
   highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.FillTransparency = 0.3
    highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineTransparency = 0
    highlight.Adornee = nil
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    local _ctapFrame = 0
    RunService.RenderStepped:Connect(function()
        _ctapFrame = _ctapFrame + 1
        if _ctapFrame < 4 then return end
        _ctapFrame = 0
        if Config.ClickToAP then
            local camera = Workspace.CurrentCamera
            local mousePos = UserInputService:GetMouseLocation()
            local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
            local hitboxSize = 8
            local bestPlayer = nil
            local bestDistance = math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Parent then
                    local hrp = p.Character.HumanoidRootPart
                    local cubeCenter = hrp.Position
                    if rayToCubeIntersect(ray.Origin, ray.Direction, cubeCenter, hitboxSize) then
                        local distance = (ray.Origin - cubeCenter).Magnitude
                        if distance < bestDistance then
                            bestDistance = distance
                            bestPlayer = p
                        end
                    end
                end
            end
            local newAdornee = bestPlayer and bestPlayer.Character or nil
            if highlight.Adornee ~= newAdornee then
highlight.Adornee = newAdornee
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then
                local stroke = child:FindFirstChildOfClass("UIStroke")
                if stroke then
                    local hoveredName = newAdornee and newAdornee.Parent and Players:GetPlayerFromCharacter(newAdornee.Parent) and Players:GetPlayerFromCharacter(newAdornee.Parent).Name or ""
                    if newAdornee and child.Name == hoveredName then
                        stroke.Color = Color3.fromRGB(255, 50, 50)
                        stroke.Transparency = 0
                        child.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
                    else
                        stroke.Color = Theme.Accent2
                        stroke.Transparency = 0.7
                        child.BackgroundColor3 = Color3.fromRGB(30, 7, 7)
                    end
                end
            end
        end            end
        else
            highlight.Adornee = nil
        end
    end)
    UserInputService.InputBegan:Connect(function(inp, g)
        if not g and inp.UserInputType == Enum.UserInputType.MouseButton1 and Config.ClickToAP then
            local camera = Workspace.CurrentCamera
            local mousePos = UserInputService:GetMouseLocation()
            local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
            local hitboxSize = 8
            local bestPlayer = nil
            local bestDistance = math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Parent then
                    local hrp = p.Character.HumanoidRootPart
                    local cubeCenter = hrp.Position
                    if rayToCubeIntersect(ray.Origin, ray.Direction, cubeCenter, hitboxSize) then
                        local distance = (ray.Origin - cubeCenter).Magnitude
                        if distance < bestDistance then
                            bestDistance = distance
                            bestPlayer = p
                        end
                    end
                end
            end
            if bestPlayer then
                if isBlacklisted(bestPlayer) then
                    ShowNotification("CLICK TO AP", bestPlayer.Name .. " is blacklisted")
                    return
                end
                if Config.DisableClickToAPOnMoby and isMobyUser(bestPlayer) then
                    ShowNotification("CLICK TO AP", "Disabled on Moby users")
                    return
                end
                if Config.DisableClickToAPOnKawaifu and isKawaifuUser(bestPlayer) then
                    ShowNotification("CLICK TO AP", "Disabled on Kawaifu users")
                    return
                end
                if Config.DisableClickToAPOnAtlas and isAtlasUser(bestPlayer) then
                    ShowNotification("CLICK TO AP", "Disabled on Atlas users")
                    return
                end
                if Config.DisableClickToAPOnBraintopia and isBraintopiaUser(bestPlayer) then
                    ShowNotification("CLICK TO AP", "Disabled on Braintopia users")
                    return
                end
                local hasAnyAvailable = false
                for _, cmd in ipairs(ALL_COMMANDS) do
                    if not isOnCooldown(cmd) then
                        hasAnyAvailable = true
                        break
                    end
                end
                if hasAnyAvailable then
                    if Config.ClickToAPSingleCommand then
                        local nextCmd = getNextAvailableCommand()
                        if nextCmd then
                            if runAdminCommand(bestPlayer, nextCmd) then
                                activeCooldowns[nextCmd] = tick()
                                setGlobalVisualCooldown(nextCmd)
                                if nextCmd == "balloon" then
                                    SharedState.BalloonedPlayers[bestPlayer.UserId] = true
                                    updateBalloonButtons()
                                end
                                ShowNotification("CLICK AP", "Sent " .. nextCmd .. " to " .. bestPlayer.Name)
                            else
                                ShowNotification("CLICK AP", "Failed to send " .. nextCmd .. " to " .. bestPlayer.Name)
                            end
                        else
                            ShowNotification("CLICK AP", "All commands on cooldown")
                        end
                    else
                        triggerAll(bestPlayer)
                        ShowNotification("CLICK AP", "Triggered on " .. bestPlayer.Name)
                    end
                else
                    local realAdminGui = PlayerGui:WaitForChild("AdminPanel", 5)
                    if realAdminGui then
                        local profilesScroll = realAdminGui:WaitForChild("AdminPanel"):WaitForChild("Profiles"):WaitForChild("ScrollingFrame")
                        local playerBtn = profilesScroll:FindFirstChild(bestPlayer.Name)
                        if playerBtn then
                            fireClick(playerBtn)
                            ShowNotification("CLICK AP", "Selected " .. bestPlayer.Name)
                        end
                    end
                end
            end
        end
    end)
    task.spawn(function()
        while true do
            task.wait(0.2)
            if ProximityAPActive then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (p.Character.HumanoidRootPart.Position - myChar.HumanoidRootPart.Position).Magnitude
                            if dist <= Config.ProximityRange then
                                if isBlacklisted(p) or (Config.DisableProximitySpamOnMoby and isMobyUser(p)) or (Config.DisableProximitySpamOnKawaifu and isKawaifuUser(p)) or (Config.DisableProximitySpamOnAtlas and isAtlasUser(p)) or (Config.DisableProximitySpamOnBraintopia and isBraintopiaUser(p)) then
                                else
                                    local hasAnyAvailable = false
                                    for _, cmd in ipairs(ALL_COMMANDS) do
                                        if not isOnCooldown(cmd) then
                                            hasAnyAvailable = true
                                            break
                                        end
                                    end
                                    if hasAnyAvailable then
                                        triggerAll(p)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    local function createPlayerRow(plr)
        local row = Instance.new("TextButton") 
        row.Name = plr.Name
        row.LayoutOrder = 0
row.Size = UDim2.new(1, -4, 0, 74)        row.BackgroundColor3 = Color3.fromRGB(30, 7, 7)
        row.BackgroundTransparency = 0.2
        row.BorderSizePixel = 0
        row.AutoButtonColor = false
        row.Text = ""
        row.Parent = listFrame
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
        local rowStroke = Instance.new("UIStroke", row)
        rowStroke.Color = Theme.Accent2
        rowStroke.Thickness = 1.5
        rowStroke.Transparency = 0.7
        row.MouseEnter:Connect(function()
            row.BackgroundTransparency = 0.05
            rowStroke.Transparency = 0.4
            rowStroke.Color = Theme.Accent1
        end)
        row.MouseLeave:Connect(function()
            row.BackgroundTransparency = 0.2
            rowStroke.Transparency = 0.7
            rowStroke.Color = Theme.Accent2
        end)
        local headshot = Instance.new("ImageLabel", row)
        headshot.Size = UDim2.new(0, 42, 0, 42)
        headshot.Position = UDim2.new(0, 12, 0.5, -21)
        headshot.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
        task.spawn(function()
            local ok, img = pcall(function()
                return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            if ok and img and headshot and headshot.Parent then
                headshot.Image = img
            end
        end)
        Instance.new("UICorner", headshot).CornerRadius = UDim.new(1, 0)
        local headshotStroke = Instance.new("UIStroke", headshot)
        headshotStroke.Color = Theme.Accent1
        headshotStroke.Thickness = 2.5
        headshotStroke.Transparency = 0.2
        local dName = Instance.new("TextLabel", row)
    dName.Size = UDim2.new(0, 160, 0, 20); dName.Position = UDim2.new(0, 58, 0, 10)
    dName.BackgroundTransparency = 1; dName.Text = plr.Name
    dName.Font = Enum.Font.GothamBold; dName.TextSize = 14
    dName.TextColor3 = Theme.TextPrimary; dName.TextXAlignment = Enum.TextXAlignment.Left
    local uName = Instance.new("TextLabel", row)
    uName.Size = UDim2.new(0, 160, 0, 16); uName.Position = UDim2.new(0, 58, 0, 30)
    uName.BackgroundTransparency = 1; uName.Text = plr.DisplayName
    uName.Font = Enum.Font.GothamBold; uName.TextSize = 10
    uName.TextColor3 = Color3.fromRGB(210, 210, 210); uName.TextXAlignment = Enum.TextXAlignment.Left
    local apToolLbl = Instance.new("TextLabel", row)
    apToolLbl.Name = "APToolLabel"
    apToolLbl.Size = UDim2.new(0, 160, 0, 14); apToolLbl.Position = UDim2.new(0, 58, 0, 44)
    apToolLbl.BackgroundTransparency = 1
    apToolLbl.Font = Enum.Font.GothamMedium; apToolLbl.TextSize = 10
    apToolLbl.TextColor3 = Color3.fromRGB(100, 210, 255); apToolLbl.TextXAlignment = Enum.TextXAlignment.Left
    local function makeHubTag(name, text, bg, width)
        local t = Instance.new("TextLabel", row)
        t.Name = "UserTag_" .. name
        t.BackgroundColor3 = bg
        t.BorderSizePixel = 0
        t.Size = UDim2.fromOffset(width, 16)
        t.Position = UDim2.fromOffset(58 + 90 + 6, 11)
        t.Text = text
        t.Font = Enum.Font.GothamBold
        t.TextSize = 9
        t.TextColor3 = Color3.fromRGB(255, 255, 255)
        t.TextXAlignment = Enum.TextXAlignment.Center
        t.ZIndex = 11
        t.Visible = false
        Instance.new("UICorner", t).CornerRadius = UDim.new(0, 5)
        return t
    end
    local mobyTag       = makeHubTag("MOBY",       "MOBY",       Color3.fromRGB(68, 136, 255),  38)
    local kawaifuTag    = makeHubTag("KAWAIFU",    "KAWAIFU",    Color3.fromRGB(255, 105, 180), 50)
    local atlasTag      = makeHubTag("ATLAS",      "ATLAS",      Color3.fromRGB(255, 215, 0),   42)
    local braintopiaTag = makeHubTag("BRAINTOPIA", "BRAINTOPIA", Color3.fromRGB(170, 100, 255), 68)
    local function updateHubTags()
        local entries = {
            { tag = mobyTag,       cfg = Config.MobyESPInAdminPanel,       show = function() local r=false; pcall(function() r=isMobyUser(plr)==true end);       return r end },
            { tag = kawaifuTag,    cfg = Config.KawaifuESPInAdminPanel,    show = function() local r=false; pcall(function() r=isKawaifuUser(plr)==true end);    return r end },
            { tag = atlasTag,      cfg = Config.AtlasESPInAdminPanel,      show = function() local r=false; pcall(function() r=isAtlasUser(plr)==true end);      return r end },
            { tag = braintopiaTag, cfg = Config.BraintopiaESPInAdminPanel, show = function() local r=false; pcall(function() r=isBraintopiaUser(plr)==true end); return r end },
        }
        local textW = dName.TextBounds.X
        if not textW or textW <= 0 then textW = 90 end
        local cursor = 58 + math.floor(textW) + 6
        for _, e in ipairs(entries) do
            if e.cfg and e.show() then
                e.tag.Position = UDim2.fromOffset(cursor, 11)
                e.tag.Visible = true
                cursor = cursor + e.tag.Size.X.Offset + 4
            else
                e.tag.Visible = false
            end
        end
    end
    updateHubTags()
    task.spawn(function()
        while row.Parent do
            task.wait(1)
            if not plr or not plr.Parent then break end
            updateHubTags()
        end
    end)
    do
        local ht = nil
        local c = plr.Character
        if c then for _, o in ipairs(c:GetChildren()) do if o:IsA("Tool") then ht = o.Name break end end end
        apToolLbl.Text = ht or ""
        if ht and DANGER_TOOLS[ht] then
            dName.TextColor3 = Color3.fromRGB(255, 60, 60)
        end
    end
        local function refreshStealingState()
            if not row.Parent then return end
            if not plr or not plr.Parent then return end
            local stealing = plr:GetAttribute("Stealing")
            local idx = plr:GetAttribute("StealingIndex")
            if stealing then
                if idx then
                    uName.Text = tostring(idx)
                    uName.TextColor3 = Color3.fromRGB(255, 200, 0)
                    uName.Font = Enum.Font.GothamBold
                    uName.TextSize = 11
                else
                    uName.Text = "STEALING"
                    uName.TextColor3 = Color3.fromRGB(255, 150, 0)
                    uName.Font = Enum.Font.GothamBold
                    uName.TextSize = 11
                end
            else
                uName.Text = "(@" .. plr.Name .. ")"
                uName.TextColor3 = Theme.TextSecondary
                uName.Font = Enum.Font.GothamMedium
                uName.TextSize = 7
            end
        end
        refreshStealingState()
        local stealConn = plr:GetAttributeChangedSignal("Stealing"):Connect(refreshStealingState)
        local idxConn   = plr:GetAttributeChangedSignal("StealingIndex"):Connect(refreshStealingState)
        row.AncestryChanged:Connect(function()
            if not row:IsDescendantOf(game) then
                if stealConn then stealConn:Disconnect() end
                if idxConn   then idxConn:Disconnect()   end
            end
        end)
        task.spawn(function()
            while row.Parent do
                task.wait(0.5)
                if not plr or not plr.Parent or not Players:FindFirstChild(plr.Name) then
                    removePlayer(plr)
                    break
                end
                local stealing = plr:GetAttribute("Stealing")
                local nearestBrainrotName = plr:GetAttribute("StealingIndex")
                if stealing then
                    if nearestBrainrotName then
                        uName.Text = nearestBrainrotName
                        uName.TextColor3 = Color3.fromRGB(255, 200, 0)
                        uName.Font = Enum.Font.GothamBold
                        uName.TextSize = 11
                    else
                        uName.Text = "âš ï¸ STEALING"
                        uName.TextColor3 = Color3.fromRGB(255, 150, 0)
                        uName.Font = Enum.Font.GothamBold
                        uName.TextSize = 11
                    end
                else
                    uName.Text = "(@" .. plr.Name .. ")"
                    uName.TextColor3 = Theme.TextSecondary
                    uName.Font = Enum.Font.GothamMedium
                    uName.TextSize = 7
                    nearestBrainrotName = nil
                end
                pcall(function()
                    local ht = nil
                    local c = plr.Character
                    if c then for _, o in ipairs(c:GetChildren()) do if o:IsA("Tool") then ht = o.Name break end end end
                    apToolLbl.Text = ht or ""
                    if ht and DANGER_TOOLS[ht] then
                        dName.TextColor3 = Color3.fromRGB(255, 60, 60)
                    else
                        dName.TextColor3 = Theme.TextPrimary
                    end
                end)
            end
        end)
        local btnCont = Instance.new("Frame", row)
    btnCont.Size = UDim2.new(0, 220, 1, 0); btnCont.Position = UDim2.new(1, -225, 0, 0)
    btnCont.BackgroundTransparency = 1; btnCont.ZIndex = 10
        local buttonsDef = {
            {icon = "🚀", cmd = "rocket"},
            {icon = "🏃‍♂️", cmd = "ragdoll"},
            {icon = "🔒", cmd = "jail"},
            {icon = "🎈", cmd = "balloon"}
        }
        for i, def in ipairs(buttonsDef) do
            local b = Instance.new("TextButton", btnCont)
            b.Size = UDim2.new(0, 30, 0, 30)
            b.Position = UDim2.new(0, 4 + (i-1)*34, 0.5, -15)
            b.AutoButtonColor = false
            b.Text = def.icon
            b.TextSize = 18
            b.TextColor3 = Theme.TextPrimary
            b.Font = Enum.Font.GothamBlack
            b.ZIndex = 11
            b.Active = true
            local hasBallooned = SharedState.BalloonedPlayers and next(SharedState.BalloonedPlayers) ~= nil
            local isOnCD = isOnCooldown(def.cmd)
            b.BackgroundColor3 = (def.cmd == "balloon" and hasBallooned) or isOnCD and Theme.Error or Color3.fromRGB(100, 12, 12)
            b.BackgroundTransparency = 0
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            local bStroke = Instance.new("UIStroke", b)
            bStroke.Color = (def.cmd == "balloon" and hasBallooned) or isOnCD and Theme.Error or Color3.fromRGB(200, 20, 20)
            bStroke.Thickness = 1.5
            bStroke.Transparency = 0.4
            bStroke.ZIndex = 12
            b.MouseEnter:Connect(function()
                if not isOnCD and not (def.cmd == "balloon" and hasBallooned) then
                    b.BackgroundColor3 = Color3.fromRGB(68, 24, 48)
                    bStroke.Transparency = 0.2
                end
            end)
            b.MouseLeave:Connect(function()
                if not isOnCD and not (def.cmd == "balloon" and hasBallooned) then
                    b.BackgroundColor3 = Color3.fromRGB(100, 12, 12)
                    bStroke.Transparency = 0.4
                end
            end)
            if not SharedState.AdminButtonCache[def.cmd] then SharedState.AdminButtonCache[def.cmd] = {} end
            table.insert(SharedState.AdminButtonCache[def.cmd], b)
            task.spawn(function()
                while b and b.Parent do
                    task.wait(0.5)
                    if not b.Text or b.Text == "" or b.Text == "BUTTON" or b.Text == "Button" then
                        b.Text = def.icon
                        b.TextSize = 18
                        b.TextColor3 = Theme.TextPrimary
                        b.Font = Enum.Font.GothamBlack
                    end
                    local cd = isOnCooldown(def.cmd)
                    local balloon = (def.cmd == "balloon" and SharedState.BalloonedPlayers and next(SharedState.BalloonedPlayers) ~= nil)
                    if cd or balloon then
                        b.BackgroundColor3 = Theme.Error
                        b.BackgroundTransparency = 0
                        bStroke.Color = Theme.Error
                        bStroke.Transparency = 0.2
                    else
                        b.BackgroundColor3 = Color3.fromRGB(100, 12, 12)
                        b.BackgroundTransparency = 0
                        bStroke.Color = Color3.fromRGB(200, 20, 20)
                        bStroke.Transparency = 0.4
                    end
                    if b.Text ~= def.icon then
                        b.Text = def.icon
                        b.TextSize = 18
                        b.TextColor3 = Theme.TextPrimary
                        b.Font = Enum.Font.GothamBlack
                    end
                end
            end)
            b.MouseButton1Click:Connect(function()
                if def.special and def.cmd == "spambaseowner" then
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    local closestPlot = nil
                    local closestDist = math.huge
                    local plots = Workspace:FindFirstChild("Plots")
                    if plots then
                        for _, plot in ipairs(plots:GetChildren()) do
                            local plotPos = plot:FindFirstChild("Base") and plot.Base:FindFirstChild("Spawn")
                            if plotPos then
                                local dist = (hrp.Position - plotPos.Position).Magnitude
                                if dist < closestDist then
                                    closestDist = dist
                                    closestPlot = plot
                                end
                            end
                        end
                    end
                    if closestPlot then
                        task.spawn(function()
                            local Synchronizer = _G.ZawaRawSync
                            local channel = Synchronizer.caches[closestPlot.Name]
                            if channel then
                                local owner = channel.Owner
                                local targetPlayer = nil
                                if typeof(owner) == "Instance" and owner:IsA("Player") then
                                    targetPlayer = owner
                                elseif typeof(owner) == "table" and owner.UserId then
                                    targetPlayer = Players:GetPlayerByUserId(owner.UserId)
                                end
                                if targetPlayer and targetPlayer ~= LocalPlayer then
                                    local hasAnyAvailable = false
                                    for _, cmd in ipairs(ALL_COMMANDS) do
                                        if not isOnCooldown(cmd) then
                                            hasAnyAvailable = true
                                            break
                                        end
                                    end
                                    if hasAnyAvailable then
                                        triggerAll(targetPlayer)
                                        ShowNotification("AP SPAM", "Spamming " .. targetPlayer.Name)
                                    else
                                        ShowNotification("AP SPAM", "All commands on cooldown")
                                    end
                                else
                                    ShowNotification("AP SPAM", "No owner found")
                                end
                            end
                        end)
                    end
                else
                    if isBlacklisted(plr) then
                        ShowNotification("ADMIN", plr.Name .. " is blacklisted")
                        return
                    end
                    if Config.DisableAPPanelOnMoby and isMobyUser(plr) then
                        ShowNotification("ADMIN", "AP Panel disabled on Moby users")
                        return
                    end
                    if Config.DisableAPPanelOnKawaifu and isKawaifuUser(plr) then
                        ShowNotification("ADMIN", "AP Panel disabled on Kawaifu users")
                        return
                    end
                    if Config.DisableAPPanelOnAtlas and isAtlasUser(plr) then
                        ShowNotification("ADMIN", "AP Panel disabled on Atlas users")
                        return
                    end
                    if Config.DisableAPPanelOnBraintopia and isBraintopiaUser(plr) then
                        ShowNotification("ADMIN", "AP Panel disabled on Braintopia users")
                        return
                    end
                    ShowNotification("ADMIN", "Attempting " .. def.cmd .. " on " .. plr.Name)
                    if runAdminCommand(plr, def.cmd) then
                        activeCooldowns[def.cmd] = tick()
                        setGlobalVisualCooldown(def.cmd)
                        if def.cmd == "balloon" then
                            SharedState.BalloonedPlayers[plr.UserId] = true
                            for _, btn in ipairs(SharedState.AdminButtonCache["balloon"] or {}) do
                                if btn and btn.Parent then btn.BackgroundColor3 = Theme.Error end
                            end
                        end
                        ShowNotification("ADMIN", "Sent " .. def.cmd .. " to " .. plr.Name)
                    else
                        ShowNotification("ADMIN", "Failed to send " .. def.cmd .. " to " .. plr.Name)
                    end
                end
            end)
        end
        local blQuickBtn = Instance.new("TextButton", btnCont)
        blQuickBtn.Size = UDim2.new(0, 30, 0, 30)
        blQuickBtn.Position = UDim2.new(0, 4 + (#buttonsDef) * 34, 0.5, -15)
        blQuickBtn.AutoButtonColor = false
        blQuickBtn.Text = "X"
        blQuickBtn.TextSize = 14
        blQuickBtn.Font = Enum.Font.GothamBlack
        blQuickBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
        blQuickBtn.ZIndex = 11
        blQuickBtn.Active = true
        blQuickBtn.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
        blQuickBtn.BackgroundTransparency = 0
        Instance.new("UICorner", blQuickBtn).CornerRadius = UDim.new(0, 8)
        local blQuickStroke = Instance.new("UIStroke", blQuickBtn)
        blQuickStroke.Color = Color3.fromRGB(200, 50, 50)
        blQuickStroke.Thickness = 1.5
        blQuickStroke.Transparency = 0.3
        blQuickStroke.ZIndex = 12
        blQuickBtn.MouseEnter:Connect(function()
            blQuickBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
            blQuickStroke.Transparency = 0.05
        end)
        blQuickBtn.MouseLeave:Connect(function()
            blQuickBtn.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
            blQuickStroke.Transparency = 0.3
        end)
        blQuickBtn.MouseButton1Click:Connect(function()
            local targetName = plr.Name
            local alreadyIn = false
            for _, n in ipairs(Config.BlacklistedUsers) do
                if n:lower() == targetName:lower() then
                    alreadyIn = true
                    break
                end
            end
            if alreadyIn then
                ShowNotification("BLACKLIST", targetName .. " is already blacklisted")
                return
            end
            table.insert(Config.BlacklistedUsers, targetName)
            SaveConfig()
            blQuickBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 50)
            blQuickBtn.Text = "OK"
ShowNotification("BLACKLIST", "Blacklisted: " .. targetName)
            rebuildBlList()            task.delay(1.2, function()
                if blQuickBtn and blQuickBtn.Parent then
                    blQuickBtn.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
                    blQuickBtn.Text = "X"
                end
            end)
        end)
        local tpBtn = Instance.new("TextButton", btnCont)
        tpBtn.Size = UDim2.new(0, 44, 0, 30)
        tpBtn.Position = UDim2.new(0, 4 + (#buttonsDef + 1) * 34, 0.5, -15)
        tpBtn.AutoButtonColor = false
        tpBtn.Text = "TP"
        tpBtn.TextSize = 13
        tpBtn.Font = Enum.Font.GothamBlack
        tpBtn.TextColor3 = Theme.TextPrimary
        tpBtn.ZIndex = 11
        tpBtn.Active = true
        tpBtn.BackgroundColor3 = Theme.Accent2
        tpBtn.BackgroundTransparency = 0
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 8)
        local tpStroke = Instance.new("UIStroke", tpBtn)
        tpStroke.Color = Theme.Accent1
        tpStroke.Thickness = 1.5
        tpStroke.Transparency = 0.4
        tpStroke.ZIndex = 12
        tpBtn.MouseEnter:Connect(function()
            tpBtn.BackgroundColor3 = Theme.Accent1
            tpStroke.Transparency = 0.1
        end)
        tpBtn.MouseLeave:Connect(function()
            tpBtn.BackgroundColor3 = Theme.Accent2
            tpStroke.Transparency = 0.4
        end)
        tpBtn.MouseButton1Click:Connect(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then
                ShowNotification("TP TO BASE", "No character")
                return
            end
            local plots = Workspace:FindFirstChild("Plots")
            if not plots then
                ShowNotification("TP TO BASE", "Plots not found")
                return
            end
            local targetPlot = nil
            local okSync, Synchronizer = true, _G.ZawaRawSync
            if okSync and Synchronizer then
                for _, p in ipairs(plots:GetChildren()) do
                    local okCh, ch = pcall(function() return Synchronizer.caches[p.Name] end)
                    if okCh and ch then
                        local owner = ch.Owner
                        if owner then
                            if typeof(owner) == "Instance" and owner == plr then
                                targetPlot = p; break
                            elseif type(owner) == "table" and owner.UserId and plr.UserId and owner.UserId == plr.UserId then
                                targetPlot = p; break
                            elseif type(owner) == "table" and owner.Name and owner.Name == plr.Name then
                                targetPlot = p; break
                            end
                        end
                    end
                end
            end
            if not targetPlot then
                for _, p in ipairs(plots:GetChildren()) do
                    local sign = p:FindFirstChild("PlotSign")
                    local textLabel = sign
                        and sign:FindFirstChild("SurfaceGui")
                        and sign.SurfaceGui:FindFirstChild("Frame")
                        and sign.SurfaceGui.Frame:FindFirstChild("TextLabel")
                    if textLabel then
                        local baseText = tostring(textLabel.Text or "")
                        local nickname = baseText:match("^(.-)'") or baseText
                        if nickname == plr.DisplayName or nickname == plr.Name then
                            targetPlot = p
                            break
                        end
                    end
                end
            end
            if not targetPlot then
                ShowNotification("TP TO BASE", "Base not found")
                return
            end
            local signPart = nil
            do
                local sign = targetPlot:FindFirstChild("PlotSign")
                if sign then
                    if sign:IsA("BasePart") then
                        signPart = sign
                    elseif sign:IsA("Model") then
                        signPart = sign.PrimaryPart or sign:FindFirstChildWhichIsA("BasePart", true)
                    else
                        signPart = sign:FindFirstChildWhichIsA("BasePart", true)
                    end
                end
            end
            if not signPart then
                ShowNotification("TP TO BASE", "Sign not found")
                return
            end
            local carpetName = Config.TpSettings.Tool
            local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
            if carpet then
                pcall(function() hum:EquipTool(carpet) end)
                task.wait(0.01)
            end
            local function riseToY(targetY)
                local MAX_TIME = 3.0
                local start = os.clock()
                while hrp.Parent and hrp.Position.Y < targetY do
                    local dist = targetY - hrp.Position.Y
                    local speed = math.clamp(dist * 20, 280, 310)
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, speed, hrp.Velocity.Z)
                    if os.clock() - start > MAX_TIME then break end
                    RunService.Heartbeat:Wait()
                end
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
            end
            riseToY(40)
            local signCF = signPart.CFrame
            local FORWARD = signCF.LookVector
            local BACK = -signCF.LookVector
            local frontPoint = signPart.Position + (FORWARD * 20)
            local backPoint  = signPart.Position + (BACK * 20)
            local myPos = hrp.Position
            local myFlat = Vector3.new(myPos.X, 0, myPos.Z)
            local distFront = (Vector3.new(frontPoint.X, 0, frontPoint.Z) - myFlat).Magnitude
            local distBack  = (Vector3.new(backPoint.X, 0, backPoint.Z) - myFlat).Magnitude
            local chosen = (distFront < distBack) and frontPoint or backPoint
            local tpPos = Vector3.new(chosen.X, -4.8, chosen.Z)
            hrp.Velocity = Vector3.zero
            hrp.CFrame = CFrame.new(tpPos)
            hrp.Velocity = Vector3.zero
            local t = 0
            while t < 3.0 do
                local dt = RunService.Heartbeat:Wait()
                t = t + dt
                if hrp and hrp.Parent
                    and (hrp.Position - tpPos).Magnitude <= 2
                    and hum
                    and hum.FloorMaterial ~= Enum.Material.Air then
                    break
                end
            end
            hrp.Velocity = Vector3.zero
            ShowNotification("TP TO BASE", "TP'd to " .. plr.Name .. "'s base")
        end)
local rowHighlight = Instance.new("Frame", row)
        rowHighlight.Size = UDim2.new(1, 0, 1, 0)
        rowHighlight.BackgroundColor3 = Theme.Accent1
        rowHighlight.BackgroundTransparency = 1
        rowHighlight.BorderSizePixel = 0
        rowHighlight.ZIndex = 1
        Instance.new("UICorner", rowHighlight).CornerRadius = UDim.new(0, 6)
        row.MouseEnter:Connect(function()
            rowHighlight.BackgroundTransparency = 0.7
        end)
        row.MouseLeave:Connect(function()
            rowHighlight.BackgroundTransparency = 1
        end)
        row.MouseButton1Click:Connect(function()
            local hasAnyAvailable = false
            for _, cmd in ipairs(ALL_COMMANDS) do
                if not isOnCooldown(cmd) then
                    hasAnyAvailable = true
                    break
                end
            end
            if hasAnyAvailable then
                if isBlacklisted(plr) then
                    ShowNotification("ADMIN", plr.Name .. " is blacklisted")
                    return
                end
                if Config.DisableAPPanelOnMoby and isMobyUser(plr) then
                    ShowNotification("ADMIN", "AP Panel disabled on Moby users")
                    return
                end
                if Config.DisableAPPanelOnKawaifu and isKawaifuUser(plr) then
                    ShowNotification("ADMIN", "AP Panel disabled on Kawaifu users")
                    return
                end
                if Config.DisableAPPanelOnAtlas and isAtlasUser(plr) then
                    ShowNotification("ADMIN", "AP Panel disabled on Atlas users")
                    return
                end
                if Config.DisableAPPanelOnBraintopia and isBraintopiaUser(plr) then
                    ShowNotification("ADMIN", "AP Panel disabled on Braintopia users")
                    return
                end
                triggerAll(plr)
                ShowNotification("ADMIN", "Triggered ALL on " .. plr.Name)
            end
        end)
        return row
    end
    local function addPlayer(plr)
        if plr == LocalPlayer or playerRowsByUserId[plr.UserId] then return end
        if not Players:FindFirstChild(plr.Name) then return end
        if Config.HideKawaifuFromPanel and isKawaifuUser(plr) then return end
        if playerRows[plr] then return end
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") and child.Name == plr.Name then
                for cmd, buttons in pairs(SharedState.AdminButtonCache) do
                    for i = #buttons, 1, -1 do
                        if buttons[i] and buttons[i].Parent == child then
                            table.remove(buttons, i)
                        end
                    end
                end
                child:Destroy()
            end
        end
        local row = createPlayerRow(plr)
        playerRows[plr] = row
        playerRowsByUserId[plr.UserId] = {player = plr, row = row}
        listFrame.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y)
        sortAdminPanelList()
        refreshEmptyPlayersState()
    end
    local function removePlayer(plr)
        local userId = plr and plr.UserId or nil
        local entry = userId and playerRowsByUserId[userId] or nil
        local row = entry and entry.row or playerRows[plr]
        if row then
            if row.Parent then
                for cmd, buttons in pairs(SharedState.AdminButtonCache) do
                    for i = #buttons, 1, -1 do
                        if buttons[i] and buttons[i].Parent == row then
                            table.remove(buttons, i)
                        end
                    end
                end
                row:Destroy()
            end
            if plr then
                playerRows[plr] = nil
            end
            if userId then
                playerRowsByUserId[userId] = nil
            end
            if SharedState.BalloonedPlayers and userId then
                SharedState.BalloonedPlayers[userId] = nil
            end
            listFrame.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y)
            refreshEmptyPlayersState()
        end
    end
    refreshBtn.MouseButton1Click:Connect(function()
        for _, row in pairs(playerRows) do
            if row and row.Parent then
                for cmd, buttons in pairs(SharedState.AdminButtonCache) do
                    for i = #buttons, 1, -1 do
                        if buttons[i] and buttons[i].Parent == row then
                            table.remove(buttons, i)
                        end
                    end
                end
                row:Destroy()
            end
        end
        playerRows = {}
        playerRowsByUserId = {}
        SharedState.AdminButtonCache = {}
        SharedState.BalloonedPlayers = {}
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        refreshEmptyPlayersState()
        task.wait(0.1)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                pcall(addPlayer, p)
            end
        end
        sortAdminPanelList()
        refreshEmptyPlayersState()
        ShowNotification("ADMIN PANEL", "Completely refreshed - " .. #Players:GetPlayers() - 1 .. " players found")
    end)
    Players.PlayerAdded:Connect(function(plr)
        task.wait(0.1)
        if plr and plr.Parent then
            pcall(addPlayer, plr)
        end
    end)
    Players.PlayerRemoving:Connect(function(plr)
        pcall(removePlayer, plr)
    end)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then pcall(addPlayer, p) end
    end
    sortAdminPanelList()
    refreshEmptyPlayersState()
    task.spawn(function()
        while listFrame and listFrame.Parent do
            task.wait(0.5)
            pcall(sortAdminPanelList)
        end
    end)
    task.spawn(function()
        while true do
            task.wait(1)
            pcall(function()
                local currentPlayerIds = {}
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Parent then
                        currentPlayerIds[p.UserId] = true
                    end
                end
                for userId, entry in pairs(playerRowsByUserId) do
                    if not currentPlayerIds[userId] or not entry.player or not entry.player.Parent or not Players:FindFirstChild(entry.player.Name) then
                        pcall(removePlayer, entry.player)
                    end
                end
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Parent and not playerRowsByUserId[p.UserId] then
                        pcall(addPlayer, p)
                    end
                end
            end)
        end
    end)
    layout.Changed:Connect(function() listFrame.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y) end)
end)
local BASES_LOW = {
    [1] = Vector3.new(-460, -6, 219), [5] = Vector3.new(-355, -6, 217),
    [2] = Vector3.new(-460, -6, 111), [6] = Vector3.new(-355, -6, 113),
    [3] = Vector3.new(-460, -6, 5),   [7] = Vector3.new(-355, -6, 5),
    [4] = Vector3.new(-460, -6, -100),[8] = Vector3.new(-355, -6, -100) 
}
local BASES_HIGH = {
    [1] = Vector3.new(-476.474853515625, 20.732906341552734, 220.94090270996094), [5] = Vector3.new(-342.5367126464844, 20.69801902770996, 221.44737243652344),
    [2] = Vector3.new(-476.5684814453125, 20.70664405822754, 113.77315521240234), [6] = Vector3.new(-342.8604736328125, 20.669641494750977, 113.41409301757812),
    [3] = Vector3.new(-476.8675842285156, 20.74148178100586, 6.178487777709961),  [7] = Vector3.new(-342.42108154296875, 20.687667846679688, 6.249461650848389),
    [4] = Vector3.new(-476.6324768066406, 20.744949340820312, -101.07275390625), [8] = Vector3.new(-342.7937927246094, 20.748071670532227, -99.73458862304688)
}
local CLONE_POSITIONS_FLOOR = {
    Vector3.new(-476, -4, 221), Vector3.new(-476, -4, 114),
    Vector3.new(-476, -4, 7),   Vector3.new(-476, -4, -100),
    Vector3.new(-342, -4, -100),Vector3.new(-342, -4, 6),
    Vector3.new(-342, -4, 114), Vector3.new(-342, -4, 220)
}
local FACE_TARGETS = {
    Vector3.new(-519, -3, 221), Vector3.new(-519, -3, 114),
    Vector3.new(-518, -3, 7),   Vector3.new(-519, -3, -100),
    Vector3.new(-301, -3, -100),Vector3.new(-301, -3, 7),
    Vector3.new(-302, -3, 114), Vector3.new(-300, -3, 220)
}
local TeleportData = {
    bodyController = nil,
}
local bodyController = TeleportData.bodyController
local floatActive = State.floatActive
task.spawn(function()
    while true do
        task.wait(0.03)
        if State.floatActive and TeleportData.bodyController and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then TeleportData.bodyController.Position = Vector3.new(hrp.Position.X, TeleportData.bodyController.Position.Y, TeleportData.bodyController.Position.Z) end
        end
    end
end)
local function getClosestBaseIdx(pos)
    local closest, dist = 1, math.huge
    for i, basePos in pairs(BASES_LOW) do
        local d = (Vector2.new(pos.X, pos.Z) - Vector2.new(basePos.X, basePos.Z)).Magnitude
        if d < dist then dist = d; closest = i end
    end
    return closest
end
local isTpMoving = State.isTpMoving
_G._isTargetPlotUnlocked = function(plotName)
    local ok, res = pcall(function()
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return false end
        local targetPlot = plots:FindFirstChild(plotName)
        if not targetPlot then return false end
        local unlockFolder = targetPlot:FindFirstChild("Unlock")
        if not unlockFolder then return true end
        local unlockItems = {}
        for _, item in pairs(unlockFolder:GetChildren()) do
            local pos = nil
            if item:IsA("Model") then pcall(function() pos = item:GetPivot().Position end)
            elseif item:IsA("BasePart") then pos = item.Position end
            if pos then table.insert(unlockItems, {Object = item, Height = pos.Y}) end
        end
        table.sort(unlockItems, function(a, b) return a.Height < b.Height end)
        if #unlockItems == 0 then return true end
        local floor1Door = unlockItems[1].Object
        for _, desc in ipairs(floor1Door:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc.Enabled then return false end
        end
        for _, child in ipairs(floor1Door:GetChildren()) do
            if child:IsA("ProximityPrompt") and child.Enabled then return false end
        end
        return true
    end)
    return ok and res or false
end
task.spawn(function()
    while true do
        task.wait(0.5)
        local plots = Workspace:FindFirstChild("Plots")
        if plots then
            local myDispLower = (LocalPlayer.DisplayName or LocalPlayer.Name):lower()
            local myNameLower = LocalPlayer.Name:lower()
            local myPlot = nil
            for _, plot in ipairs(plots:GetChildren()) do
                local sign = plot:FindFirstChild("PlotSign")
                local sg = sign and sign:FindFirstChildWhichIsA("SurfaceGui", true)
                local lbl = sg and sg:FindFirstChildWhichIsA("TextLabel", true)
                if lbl then
                    local text = (lbl.Text or ""):lower()
                    if text:find(myDispLower, 1, true) or text:find(myNameLower, 1, true) then
                        myPlot = plot
                        break
                    end
                end
            end
            for _, plot in ipairs(plots:GetChildren()) do
                if plot ~= myPlot then
                    local sign = plot:FindFirstChild("PlotSign")
                    local yb = sign and sign:FindFirstChild("YourBase")
                    if yb and yb:IsA("BillboardGui") and yb.Enabled then
                        pcall(function() yb.Enabled = false end)
                    end
                end
            end
        end
    end
end)
local _tpCurrentPing = 0
task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function() _tpCurrentPing = math.floor(LocalPlayer:GetNetworkPing() * 1000) end)
    end
end)
local HIGH_PING_THRESHOLD_TP = 250
local function getPingMult()
    return 1.0
end
local autoGrabEnabled = Config.AutoGrab or false
task.spawn(function()
    local AUTO_GRAB_RANGE = 30
    while true do
        task.wait(0.5)
        if _G.ZawaHub_Suspended then continue end
        if not (Config.AutoGrab or autoGrabEnabled) then continue end
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local cache = SharedState.AllAnimalsCache
        if not cache then continue end
        local candidates = {}
        for _, a in ipairs(cache) do
            if a and a.genValue and a.genValue >= 1 then
                local isOwn = false
                pcall(function()
                    local plots = Workspace:FindFirstChild("Plots")
                    if not plots or not a.plot then return end
                    local plot = plots:FindFirstChild(a.plot)
                    if not plot then return end
                    local Sync = _G.ZawaRawSync
                    local channel = Sync.caches[plot.Name]
                    if channel then
                        local owner = channel.Owner
                        if typeof(owner) == "Instance" and owner:IsA("Player") then isOwn = owner.UserId == LocalPlayer.UserId
                        elseif typeof(owner) == "table" and owner.UserId then isOwn = owner.UserId == LocalPlayer.UserId
                        elseif typeof(owner) == "Instance" then isOwn = owner == LocalPlayer end
                    end
                end)
                if isOwn then
                    local adornee = findAdorneeGlobal(a)
                    if adornee then
                        local dist = (adornee.Position - hrp.Position).Magnitude
                        if dist < AUTO_GRAB_RANGE then
                            local prompt
                            local parent = adornee.Parent
                            if parent then
                                for _, desc in ipairs(parent:GetDescendants()) do
                                    if desc:IsA("ProximityPrompt") then prompt = desc; break end
                                end
                            end
                            if prompt then
                                table.insert(candidates, {a = a, dist = dist, prompt = prompt})
                            end
                        end
                    end
                end
            end
        end
        local chosenPrompt
        if #candidates > 0 then
            if Config.StealPriority then
                for _, pName in ipairs(PRIORITY_LIST) do
                    local searchName = pName:lower()
                    for _, c in ipairs(candidates) do
                        if c.a.name and c.a.name:lower() == searchName then
                            chosenPrompt = c.prompt; break
                        end
                    end
                    if chosenPrompt then break end
                end
                if not chosenPrompt then
                    table.sort(candidates, function(x, y) return (x.a.genValue or 0) > (y.a.genValue or 0) end)
                    chosenPrompt = candidates[1].prompt
                end
            elseif Config.StealHighest then
                table.sort(candidates, function(x, y) return (x.a.genValue or 0) > (y.a.genValue or 0) end)
                chosenPrompt = candidates[1].prompt
            else
                table.sort(candidates, function(x, y) return x.dist < y.dist end)
                chosenPrompt = candidates[1].prompt
            end
        end
        if chosenPrompt then
            pcall(function()
                if _G.firePromptDirect then
                    _G.firePromptDirect(chosenPrompt)
                else
                    fireproximityprompt(chosenPrompt)
                end
            end)
        end
    end
end)
local function executeReset()
    pcall(function()
        local plr = Players.LocalPlayer
        local char = plr.Character
        if not char then
            pcall(function() plr:LoadCharacter() end)
            return
        end
        pcall(function()
            local bp = plr:FindFirstChild("Backpack")
            if not bp then return end
            local carpet = bp:FindFirstChild("Flying Carpet")
            if not carpet then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:EquipTool(carpet) end
        end)
        pcall(function() char:BreakJoints() end)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Dead) end)
            pcall(function() hum.Health = 0 end)
            pcall(function() hum.MaxHealth = 0 end)
        end
        for _, obj in ipairs(char:GetDescendants()) do
            pcall(function()
                if obj:IsA("Motor6D") or obj:IsA("Weld") or obj:IsA("WeldConstraint") then
                    obj:Destroy()
                end
            end)
        end
        local targetCFrame = CFrame.new(1e25, 1e30, -5e17, 1, 0, 0, 0, 1, 0, 0, 0, 1)
        local function fling()
            for _, part in ipairs(char:GetDescendants()) do
                pcall(function()
                    if part:IsA("BasePart") and part.Parent then
                        part.Anchored = false
                        part.CFrame = targetCFrame
                        part.Velocity = Vector3.new(math.random(-1e7, 1e7), math.random(5e6, 5e7), math.random(-1e7, 1e7))
                        part.RotVelocity = Vector3.new(math.random(-1e6, 1e6), math.random(-1e6, 1e6), math.random(-1e6, 1e6))
                    end
                end)
            end
        end
        fling()
        task.spawn(function()
            local startCharRef = char
            task.wait(0.4)
            if plr.Character == startCharRef and startCharRef and startCharRef.Parent then
                pcall(function() plr:LoadCharacter() end)
            end
        end)
        local startTime = tick()
        while tick() - startTime < 1.0 and char and char.Parent and plr.Character == char do
            fling()
            task.wait()
        end
    end)
end
_G.executeReset = executeReset
UserInputService.InputBegan:Connect(function(input, _processed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if UserInputService:GetFocusedTextBox() then return end
    local ok, code = pcall(function() return Enum.KeyCode[Config.ResetKey] end)
    local resetCode = (ok and code) or Enum.KeyCode.X
    if input.KeyCode == resetCode then
        task.spawn(executeReset)
    end
end)
local function showBigAlert(text)
    local pgui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not pgui then return end
    local existing = pgui:FindFirstChild("XiBigAlert")
    if existing then existing:Destroy() end
    local sg = Instance.new("ScreenGui", pgui)
    sg.Name = "XiBigAlert"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true; sg.DisplayOrder = 1000
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 440, 0, 56)
    f.Position = UDim2.new(0.5, -220, 0, 75)
    f.BackgroundColor3 = Color3.fromRGB(12, 0, 0)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", f)
    stroke.Thickness = 1.5; stroke.Color = Theme.Accent2; stroke.Transparency = 1
    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(0, 4, 1, -14); bar.Position = UDim2.new(0, 6, 0, 7)
    bar.BackgroundColor3 = Theme.Accent1; bar.BorderSizePixel = 0
    bar.BackgroundTransparency = 1
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local t1 = Instance.new("TextLabel", f)
    t1.Size = UDim2.new(1, -28, 1, 0); t1.Position = UDim2.new(0, 14, 0, 0)
    t1.BackgroundTransparency = 1; t1.Text = text
    t1.Font = Enum.Font.GothamBlack; t1.TextSize = 17
    t1.TextColor3 = Theme.Accent1; t1.TextXAlignment = Enum.TextXAlignment.Center
    t1.TextYAlignment = Enum.TextYAlignment.Center
    t1.TextTransparency = 1
    local fadeIn = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(f,      fadeIn, {BackgroundTransparency = 0.08}):Play()
    TweenService:Create(stroke, fadeIn, {Transparency = 0.3}):Play()
    TweenService:Create(bar,    fadeIn, {BackgroundTransparency = 0}):Play()
    TweenService:Create(t1,     fadeIn, {TextTransparency = 0}):Play()
    task.delay(2, function()
        if not sg.Parent then return end
        local fadeOut = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(f,      fadeOut, {BackgroundTransparency = 1}):Play()
        TweenService:Create(stroke, fadeOut, {Transparency = 1}):Play()
        TweenService:Create(bar,    fadeOut, {BackgroundTransparency = 1}):Play()
        local last = TweenService:Create(t1, fadeOut, {TextTransparency = 1})
        last:Play(); last.Completed:Wait()
        if sg.Parent then sg:Destroy() end
    end)
end
local function noPriorityFallback(reason)
    showBigAlert(reason or "No priority brainrots detected")
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        local carpetName = Config.TpSettings.Tool
        local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
        if carpet then
            pcall(function() hum:EquipTool(carpet) end)
        end
    end
end
local function eagerCachePlotPrompts(_plot) end
local function pickCloneSpeed()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local isF2 = hrp and hrp.Position.Y > 10
    local isHP = (getPingMult and getPingMult() > 1)
    if isF2 then
        return isHP and (Config.Floor2InstantCloneSpeedHP or 0.1) or (Config.Floor2InstantCloneSpeed or 0.05)
    else
        return isHP and (Config.Floor1InstantCloneSpeedHP or 0.1) or (Config.Floor1InstantCloneSpeed or 0.05)
    end
end
local function pickTpTarget()
    local targetPetData = nil
    local cache = SharedState.AllAnimalsCache
    if _G._tpLoadOverride and _G._tpLoadTarget then
        local sd = _G._tpLoadTarget
        if sd.owner ~= LocalPlayer.Name then
            return sd
        end
    end
    local usePriority = Config.AutoTPPriority
    if usePriority then
        local bestEntry = nil
        if cache and type(cache) == "table" then
            for _, pName in ipairs(PRIORITY_LIST) do
                local searchName = pName:lower()
                for _, a in ipairs(cache) do
                    if a and a.name and a.uid
                        and a.owner ~= LocalPlayer.Name
                        and a.name:lower() == searchName then
                        bestEntry = a; break
                    end
                end
                if bestEntry then break end
            end
            if not bestEntry then
                for _, a in ipairs(cache) do
                    if a and a.owner ~= LocalPlayer.Name then bestEntry = a; break end
                end
            end
        end
        targetPetData = bestEntry or (SharedState.SelectedPetData and SharedState.SelectedPetData.animalData)
    else
        targetPetData = SharedState.SelectedPetData and SharedState.SelectedPetData.animalData
        if not targetPetData and cache and type(cache) == "table" then
            for _, a in ipairs(cache) do
                if a and a.owner ~= LocalPlayer.Name then targetPetData = a; break end
            end
        end
    end
    return targetPetData
end
local function tpToBrainrot()
    local animalData = pickTpTarget()
    if not animalData then return end
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    local targetPart = nil
    for _ = 1, 10 do
        targetPart = findAdorneeGlobal(animalData)
        if targetPart then break end
        task.wait(0.05)
    end
    if not targetPart then return end
    local carpetName = Config.TpSettings.Tool
    local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
    if carpet then hum:EquipTool(carpet) end
    local targetPos = targetPart.Position
    local verticalDiff = targetPos.Y - hrp.Position.Y
    local PICKUP_TIMEOUT = 1.5
    local pickupStart = os.clock()
    local isF2 = targetPos.Y > 10
    local cfgVel    = isF2 and (Config.Floor2Velocity or 130) or (Config.Floor1Velocity or 800)
    local cfgHeight = isF2 and (Config.Floor2Height   or 40)  or (Config.Floor1Height   or 50)
    if verticalDiff > 2 then
        local airPos = Vector3.new(targetPos.X, targetPos.Y - 4, targetPos.Z)
        local plat = Instance.new("Part")
        plat.Name = "XiTempPlatform"
        plat.Size = Vector3.new(3, 1, 3)
        plat.Position = airPos - Vector3.new(0, 4, 0)
        plat.Color = Color3.new(1, 0, 0)
        plat.Material = Enum.Material.Neon
        plat.Anchored = true
        plat.CanCollide = true
        plat.Transparency = 0.3
        plat.Parent = Workspace
        task.wait()
        while os.clock() - pickupStart < PICKUP_TIMEOUT do
            if LocalPlayer:GetAttribute("Stealing") then break end
            local fp = findAdorneeGlobal(animalData)
            if not fp then break end
            local vel = hrp.Velocity
            hrp.Velocity = Vector3.new(vel.X, math.clamp(vel.Y, -cfgVel, cfgVel), vel.Z)
            hrp.CFrame = CFrame.new(airPos)
            task.wait()
        end
        task.spawn(function()
            task.wait(0.5)
            plat:Destroy()
        end)
    else
        local brainrotDuration = isF2 and (Config.Floor2BrainrotSpeed or 0.4) or (Config.Floor1BrainrotSpeed or 0.4)
        local deadline = os.clock() + (brainrotDuration * getPingMult())
        while os.clock() < deadline do
            if LocalPlayer:GetAttribute("Stealing") then break end
            local fp = findAdorneeGlobal(animalData)
            if not fp then break end
            local floorOffset = cfgHeight / 10
            hrp.Velocity = Vector3.zero
            hrp.CFrame = CFrame.new(fp.Position + Vector3.new(0, floorOffset, 0))
            task.wait()
        end
    end
end
_G.tpToBrainrot = tpToBrainrot
local function _buildCarpetRayParams(extraIgnore)
    local rp = RaycastParams.new()
    rp.FilterType   = Enum.RaycastFilterType.Exclude
    rp.IgnoreWater  = true
    pcall(function() rp.RespectCanCollide = true end)
    local char = LocalPlayer.Character
    local filter = {}
    if char then table.insert(filter, char) end
    local carpetName = Config.TpSettings.Tool
    if char and carpetName then
        local equipped = char:FindFirstChild(carpetName)
        if equipped then table.insert(filter, equipped) end
    end
    if LocalPlayer.Backpack and carpetName then
        local stowed = LocalPlayer.Backpack:FindFirstChild(carpetName)
        if stowed then table.insert(filter, stowed) end
    end
    for _, p in ipairs(Workspace:GetChildren()) do
        if p.Name == "XiTempPlatform" then table.insert(filter, p) end
    end
    if extraIgnore then
        for _, inst in ipairs(extraIgnore) do
            if inst then table.insert(filter, inst) end
        end
    end
    rp.FilterDescendantsInstances = filter
    return rp
end
local function _carpetTweenLinear(hrp, targetCF, duration, cancelToken)
    if not (hrp and hrp.Parent) then return false end
    duration = math.max(0.05, duration or 0.5)
    hrp.Velocity = Vector3.zero
    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        { CFrame = targetCF }
    )
    tween:Play()
    local watchdog = os.clock() + duration + 0.25
    while tween.PlaybackState == Enum.PlaybackState.Playing do
        if (cancelToken and cancelToken.cancelled)
            or not (hrp and hrp.Parent)
            or os.clock() > watchdog then
            tween:Cancel()
            hrp.Velocity  = Vector3.zero
            hrp.Velocity = Vector3.zero
            return false
        end
        RunService.Heartbeat:Wait()
    end
    hrp.Velocity  = Vector3.zero
    hrp.Velocity = Vector3.zero
    return not (cancelToken and cancelToken.cancelled)
end
local _carpetActiveToken = nil
local function newCarpetCancelToken()
    if _carpetActiveToken then _carpetActiveToken.cancelled = true end
    local tok = { cancelled = false }
    _carpetActiveToken = tok
    return tok
end
local function cancelActiveCarpet()
    if _carpetActiveToken then _carpetActiveToken.cancelled = true end
end
_G.cancelActiveCarpet = cancelActiveCarpet
local function applyNoClipDefense(char, hum)
    if not Config.UseNoClipDefense then
        return function() end
    end
    if not char then return function() end end
    local prevCollide = {}
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            prevCollide[p] = p.CanCollide
            pcall(function() p.CanCollide = false end)
        end
    end
    local prevState = nil
    if hum then
        pcall(function() prevState = hum:GetState() end)
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
    end
    return function()
        for p, v in pairs(prevCollide) do
            if p and p.Parent then
                pcall(function() p.CanCollide = v end)
            end
        end
        if hum and hum.Parent and prevState then
            pcall(function() hum:ChangeState(prevState) end)
        end
    end
end
local function isCharacterReady()
    local char = LocalPlayer.Character
    if not char or not char.Parent then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not hrp.Parent then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local st = hum:GetState()
    if st == Enum.HumanoidStateType.Dead
       or st == Enum.HumanoidStateType.Ragdoll
       or st == Enum.HumanoidStateType.PlatformStanding then
        return false
    end
    return true
end
_G.isCharacterReady = isCharacterReady
local _baseBlacklist = {}  
local function blacklistBase(plotName, seconds)
    if not plotName or plotName == "" then return end
    seconds = tonumber(seconds) or tonumber(Config.BaseBlacklistSeconds) or 30
    _baseBlacklist[plotName] = tick() + seconds
end
local function isBaseBlacklisted(plotName)
    if not plotName or plotName == "" then return false end
    local until_ = _baseBlacklist[plotName]
    if not until_ then return false end
    if tick() >= until_ then
        _baseBlacklist[plotName] = nil
        return false
    end
    return true
end
_G.blacklistBase    = blacklistBase
_G.isBaseBlacklisted = isBaseBlacklisted
local function inspectTargetSafety(targetPos, rayParams)
    if not Config.UseSafetyInspection then return true, nil end
    if not (typeof(targetPos) == "Vector3") then return true, nil end
    local startPos = targetPos + Vector3.new(0, 15, 0)
    local hit = Workspace:Raycast(startPos, Vector3.new(0, -20, 0), rayParams)
    if not hit or not hit.Instance then return true, nil end
    local inst = hit.Instance
    local nameLower = tostring(inst.Name or ""):lower()
    local keywords = Config.SafetyKeywords or {}
    for _, kw in ipairs(keywords) do
        if nameLower:find(tostring(kw):lower(), 1, true) then
            return false, inst
        end
    end
    if inst:IsA("BasePart") then
        local c = inst.Color
        local isRed = c and (c.R > 0.85) and (c.G < 0.25) and (c.B < 0.25)
        if isRed and (inst.Material == Enum.Material.Neon) then
            return false, inst
        end
    end
    return true, nil
end
_G.inspectTargetSafety = inspectTargetSafety
local function findStealPromptFor(animalData)
    if not animalData then return nil end
    if animalData.plot and animalData.slot then
        local plots = Workspace:FindFirstChild("Plots")
        local plot = plots and plots:FindFirstChild(animalData.plot)
        local podiums = plot and plot:FindFirstChild("AnimalPodiums")
        local podium = podiums and podiums:FindFirstChild(animalData.slot)
        if podium then
            for _, desc in ipairs(podium:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Enabled then
                    local act = tostring(desc.ActionText or ""):lower()
                    if act:find("steal") then return desc end
                end
            end
        end
    end
    local part = findAdorneeGlobal(animalData)
    if part then
        local node = part.Parent and (part.Parent.Parent or part.Parent)
        if node then
            for _, desc in ipairs(node:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Enabled then
                    local act = tostring(desc.ActionText or ""):lower()
                    if act:find("steal") then return desc end
                end
            end
        end
    end
    return nil
end
local function autoGrab(animalData, timeoutSec)
    if not Config.AutoGrab then return false end
    if typeof(fireproximityprompt) ~= "function" then return false end
    if not animalData then return false end
    timeoutSec = tonumber(timeoutSec) or tonumber(Config.AutoGrabTimeout) or 5
    local startTime = os.clock()
    local everFired = false
    while os.clock() - startTime < timeoutSec do
        if LocalPlayer:GetAttribute("Stealing") then return true end
        local prompt = findStealPromptFor(animalData)
        if prompt and prompt.Enabled then
            pcall(function() fireproximityprompt(prompt, 0) end)
            everFired = true
        end
        task.wait(0.05)
    end
    if not everFired then
        ShowNotification("AUTO GRAB", "prompt not found for " .. tostring(animalData.name or "?"))
    end
    return LocalPlayer:GetAttribute("Stealing") == true
end
_G.findStealPromptFor = findStealPromptFor
_G.autoGrab           = autoGrab
local function findSafeLandingY(hoverPos, targetY, rayParams)
    if not (typeof(hoverPos) == "Vector3") then return targetY end
    local downRayDist = math.max(50, (hoverPos.Y - (targetY or hoverPos.Y - 50)) + 20)
    local hit = Workspace:Raycast(hoverPos, Vector3.new(0, -downRayDist, 0), rayParams)
    if not hit then return targetY end
    local inst = hit.Instance
    if inst and inst:IsA("BasePart") then
        local c = inst.Color
        if c and c.R > 0.85 and c.G < 0.25 and c.B < 0.25 then
            return targetY  
        end
    end
    return hit.Position.Y
end
local function _velocityFlyTo(hrp, hum, targetPoint, speed, timeout, arriveDist, cancelTk)
    if not (hrp and hrp.Parent) then return false end
    local startTime = os.clock()
    while os.clock() - startTime < timeout do
        if cancelTk and cancelTk.cancelled then break end
        if not (hrp and hrp.Parent) then return false end
        if not (hum and hum.Parent and hum.Health > 0) then return false end
        local toTarget = targetPoint - hrp.Position
        local dist     = toTarget.Magnitude
        if dist <= arriveDist then return true end
        hrp.Velocity = toTarget.Unit * speed
        task.wait(0.03)
    end
    return false
end
local function _doOverBase(hrp, hum, destPos, speed, timeout, arriveDist, cancelTk, rayParams)
    local origin = hrp.Position
    local floorY = math.max(origin.Y, destPos.Y)
    local lowY   = math.min(origin.Y, destPos.Y) + 4
    local function lowClear(x, z)
        local a = Vector3.new(x, lowY, z)
        local b = Vector3.new(destPos.X, lowY, destPos.Z)
        return not Workspace:Raycast(a, b - a, rayParams)
    end
    if lowClear(origin.X, origin.Z) then
        if ShowNotification then pcall(ShowNotification, "OVERBASE", "direct (path clear)") end
        return _velocityFlyTo(hrp, hum, destPos, speed, timeout, arriveDist, cancelTk)
    end
    local MAX_CLIMB = 60
    local clearY
    local h = 6
    while h <= MAX_CLIMB do
        local y = floorY + h
        if not Workspace:Raycast(Vector3.new(origin.X, y, origin.Z),
                Vector3.new(destPos.X - origin.X, 0, destPos.Z - origin.Z), rayParams) then
            clearY = y; break
        end
        h = h + 6
    end
    local safeY = (clearY or (floorY + MAX_CLIMB)) + 6
    local function dropClear(x, z)
        return Workspace:Raycast(Vector3.new(x, safeY, z),
            Vector3.new(0, lowY - safeY, 0), rayParams) == nil
    end
    local descendX, descendZ = destPos.X, destPos.Z
    local flat = Vector3.new(destPos.X - origin.X, 0, destPos.Z - origin.Z)
    local dist = flat.Magnitude
    if dist > 14 then
        local dir = flat / dist
        local d = 12
        while d < dist - 6 do
            local cx = origin.X + dir.X * d
            local cz = origin.Z + dir.Z * d
            if lowClear(cx, cz) and dropClear(cx, cz) then
                descendX, descendZ = cx, cz
                break
            end
            d = d + 8
        end
    end
    if ShowNotification then
        pcall(ShowNotification, "OVERBASE", string.format("over | climb=%.0f", safeY - origin.Y))
    end
    local descendSpeed = math.min(speed, 100)
    _velocityFlyTo(hrp, hum, Vector3.new(origin.X, safeY, origin.Z), speed, timeout * 0.3, arriveDist, cancelTk)
    if cancelTk and cancelTk.cancelled then return false end
    _velocityFlyTo(hrp, hum, Vector3.new(descendX, safeY, descendZ), speed, timeout * 0.3, arriveDist, cancelTk)
    if cancelTk and cancelTk.cancelled then return false end
    _velocityFlyTo(hrp, hum, Vector3.new(descendX, lowY, descendZ), descendSpeed, timeout * 0.2, arriveDist, cancelTk)
    if cancelTk and cancelTk.cancelled then return false end
    return _velocityFlyTo(hrp, hum, destPos, descendSpeed, timeout * 0.2, arriveDist, cancelTk)
end
local function carpetFly(hrp, targetPos, opts)
    opts = opts or {}
    if not (hrp and hrp.Parent and typeof(targetPos) == "Vector3") then return false end
    if not isCharacterReady() then return false end
    local speed      = math.clamp(tonumber(opts.speed) or 140, 30, 400)
    local pad        = tonumber(opts.safetyPad) or 3
    local cancelTk   = opts.cancelToken
    local arriveDist = tonumber(opts.arriveDist) or 3
    local timeout    = tonumber(opts.timeout) or 8
    local char       = hrp.Parent
    local hum        = char and char:FindFirstChildOfClass("Humanoid")
    local carpetName = Config.TpSettings and Config.TpSettings.Tool
    if carpetName and char and hum then
        local equipped = char:FindFirstChild(carpetName)
        if not equipped then
            local stowed = LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild(carpetName)
            if stowed then pcall(function() hum:EquipTool(stowed) end) end
        end
    end
    local destPos = targetPos + Vector3.new(0, pad, 0)
    local arrived = false
    local _velCap   = speed + 15
    local _velGuard = RunService.Heartbeat:Connect(function()
        if not (hrp and hrp.Parent) then return end
        local v = hrp.Velocity
        if v.Magnitude > _velCap then
            hrp.Velocity = v.Unit * _velCap
        end
    end)
    if opts.routeAroundObstacles then
        local rayParams = _buildCarpetRayParams(opts.ignoreList)
        arrived = _doOverBase(hrp, hum, destPos, speed, timeout, arriveDist, cancelTk, rayParams)
    else
        arrived = _velocityFlyTo(hrp, hum, destPos, speed, timeout, arriveDist, cancelTk)
    end
    _velGuard:Disconnect()
    if hrp and hrp.Parent then
        hrp.Velocity  = Vector3.zero
        hrp.Velocity = Vector3.zero
    end
    if arrived and hrp and hrp.Parent and typeof(opts.finalLook) == "Vector3" then
        local fl = Vector3.new(opts.finalLook.X, 0, opts.finalLook.Z)
        if fl.Magnitude > 0.01 then
            fl = fl.Unit
            pcall(function()
                hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + fl)
            end)
        end
    end
    return arrived and not (cancelTk and cancelTk.cancelled)
end
local function _clampRideY(pos, target)
    if typeof(pos) ~= "Vector3" then return pos end
    local rp = RaycastParams.new()
    rp.FilterType  = Enum.RaycastFilterType.Exclude
    rp.IgnoreWater = true
    local filter = {}
    if LocalPlayer.Character then table.insert(filter, LocalPlayer.Character) end
    for _, p in ipairs(Workspace:GetChildren()) do
        if p.Name == "XiTempPlatform" then table.insert(filter, p) end
    end
    if typeof(target) == "Instance" then
        table.insert(filter, target)
        local m = target:FindFirstAncestorWhichIsA("Model")
        if m then table.insert(filter, m) end
    end
    rp.FilterDescendantsInstances = filter
    local HEAD     = 3.5  
    local CEIL_GAP = 2.5  
    local hit = Workspace:Raycast(pos, Vector3.new(0, 16, 0), rp)
    if hit then
        local maxY = hit.Position.Y - HEAD - CEIL_GAP
        if pos.Y > maxY then
            return Vector3.new(pos.X, maxY, pos.Z)
        end
    end
    return pos
end
local function runAutoSnipe()
    if State.isTpMoving then return end
    local targetPetData = nil
    if Config.AutoTPPriority then
        local bestEntry = nil
        local cache = SharedState.AllAnimalsCache
        if cache and type(cache) == "table" then
            for _, pName in ipairs(PRIORITY_LIST) do
                local searchName = pName:lower()
                for _, a in ipairs(cache) do
                    if a and a.name and a.name:lower() == searchName and a.owner ~= LocalPlayer.Name then
                        bestEntry = a
                        break
                    end
                end
                if bestEntry then break end
            end
            if not bestEntry then
                for _, a in ipairs(cache) do
                    if a and a.owner ~= LocalPlayer.Name then bestEntry = a; break end
                end
            end
        end
        if bestEntry then
            targetPetData = bestEntry
        else
            if not SharedState.SelectedPetData then ShowNotification("ERROR","No target selected!"); return end
            targetPetData = SharedState.SelectedPetData.animalData
        end
    else
        if not SharedState.SelectedPetData then ShowNotification("ERROR","No target selected!"); return end
        targetPetData = SharedState.SelectedPetData.animalData
    end
    if not targetPetData then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    if not isCharacterReady() then return end
    State.isTpMoving = true
    task.delay(6, function() State.isTpMoving = false end)
    local targetPart = findAdorneeGlobal(targetPetData)
    if not targetPart then
        State.isTpMoving = false
        return
    end
    local exactPos = targetPart.Position
    local carpetName = Config.TpSettings.Tool
    local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
    local cloner = LocalPlayer.Backpack:FindFirstChild("Quantum Cloner") or char:FindFirstChild("Quantum Cloner")
    if carpet then hum:EquipTool(carpet) end
    task.wait(0.01)
    local isSecondFloor = exactPos.Y > 10
    local isFloor2 = exactPos.Y > 10 and exactPos.Y <= 25
    local floor2FromFloor1 = Config.AutoTPFloor2FromFloor1 and isFloor2
    if floor2FromFloor1 then
        isSecondFloor = false
    end
    local plotIndex = getClosestBaseIdx(exactPos)
    local targetBasePos = isSecondFloor and BASES_HIGH[plotIndex] or BASES_LOW[plotIndex]
    local jumpVel = isSecondFloor and (tonumber(Config.Floor2Velocity) or 200) or (tonumber(Config.Floor1Velocity) or 200)
    local minHeight = isSecondFloor and (tonumber(Config.Floor2Height) or 40) or (tonumber(Config.Floor1Height) or 50)
    local targetHeight = math.max(targetBasePos.Y, minHeight)
    local _flyTok = newCarpetCancelToken()
    carpetFly(hrp, targetBasePos, {
        speed       = isSecondFloor and Config.TweenTpSpeedF2 or Config.TweenTpSpeedF1,
        safetyPad   = 0,
        forceMulti  = isSecondFloor,
        routeAroundObstacles = true,
        cancelToken = _flyTok,
    })
    hrp.Velocity = Vector3.zero
    if isSecondFloor then
        hrp.CFrame = CFrame.new(targetBasePos)
        hrp.Velocity = Vector3.zero
    end
    task.wait(0.15)
    if not isSecondFloor then
        local bestSpot = CLONE_POSITIONS_FLOOR[1]
        local minDst = math.huge
        for _, v in ipairs(CLONE_POSITIONS_FLOOR) do
            local d = (targetPart.Position - v).Magnitude
            if d < minDst then minDst = d; bestSpot = v end
        end
        for _ = 1, 5 do
            hrp.Velocity  = Vector3.zero
            hrp.Velocity = Vector3.zero
            task.wait(0.02)
        end
        for i = 1, 6 do
            hrp.Velocity = Vector3.zero
            if (hrp.Position - bestSpot).Magnitude > 3 then
                hrp.CFrame = CFrame.new(bestSpot)
                hrp.Velocity = Vector3.zero
                task.wait(0.05)
            end
        end
    end
    local bestFace = FACE_TARGETS[1]
    local minFaceDist = math.huge
    for _, v in ipairs(FACE_TARGETS) do
        local d = (hrp.Position - v).Magnitude
        if d < minFaceDist then
            minFaceDist = d
            bestFace = v
        end
    end
    task.wait(0.1)
    hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(bestFace.X, hrp.Position.Y, bestFace.Z))
    local _cloneNeeded = isSecondFloor or not _G._isTargetPlotUnlocked(targetPetData.plot)
    local _cloneOk = false
    if _cloneNeeded then
        hrp.Velocity  = Vector3.zero
        hrp.Velocity = Vector3.zero
        walkForward(0.2)
        task.wait(0.2)
        local _stab = os.clock()
        while os.clock() - _stab < 0.15 do
            if not (hrp and hrp.Parent) then break end
            hrp.Velocity  = Vector3.zero
            hrp.Velocity = Vector3.zero
            task.wait(0.03)
        end
        local _anchorYaw = hrp.CFrame.LookVector
        for attempt = 1, 3 do
            if not (hrp and hrp.Parent) then break end
            hrp.Velocity  = Vector3.zero
            hrp.Velocity = Vector3.zero
            local _preClonePos = hrp.Position
            instantClone(pickCloneSpeed(), true)
            local cdl = tick() + 2.5
            while _G.isCloning and tick() < cdl do task.wait() end
            if _G.isCloning then _G.isCloning = false end
            local timeout = isSecondFloor and 1.5 or 4.0
            local _moveStart = os.clock()
            while os.clock() - _moveStart < timeout do
                if not (hrp and hrp.Parent) then break end
                if (hrp.Position - _preClonePos).Magnitude >= 3 then
                    _cloneOk = true
                    break
                end
                task.wait(0.03)
            end
            if _cloneOk then break end
            if hrp and hrp.Parent then
                hrp.Velocity  = Vector3.zero
                hrp.Velocity = Vector3.zero
                hrp.CFrame = CFrame.lookAt(_preClonePos, _preClonePos + _anchorYaw)
                hrp.Velocity = Vector3.zero
            end
            task.wait(0.08)
        end
    end
    if _cloneNeeded and not _cloneOk then
        ShowNotification("TP", "Clone failed — aborted")
        State.isTpMoving = false
        return
    end
    task.wait(0.08)
    if carpet then hum:EquipTool(carpet) end
    local verticalDiff = targetPart.Position.Y - hrp.Position.Y
    task.spawn(function() autoGrab(targetPetData, 5) end)
    if floor2FromFloor1 then
        local airPos = Vector3.new(targetPart.Position.X, 3, targetPart.Position.Z)
        local plat = Instance.new("Part")
        plat.Name = "XiTempPlatform"
        plat.Size = Vector3.new(3, 1, 3)
        plat.Position = airPos - Vector3.new(0, 4, 0)
        plat.Color = Color3.new(1, 0, 0)
        plat.Material = Enum.Material.Neon
        plat.Anchored = true
        plat.CanCollide = true
        plat.Transparency = 0.3
        plat.Parent = Workspace
        RunService.Heartbeat:Wait()
        local _flyTok = newCarpetCancelToken()
        carpetFly(hrp, airPos, {
            speed       = 130,
            safetyPad   = 0,
            ignoreList  = { plat },
            cancelToken = _flyTok,
        })
        for i = 1, 10 do
            if LocalPlayer:GetAttribute("Stealing") then break end
            hrp.Velocity = Vector3.zero
            hrp.CFrame = CFrame.new(airPos)
            task.wait(0.05)
        end
        task.spawn(function()
            local start = tick()
            while tick() - start < 20 do
                if LocalPlayer:GetAttribute("Stealing") then break end
                task.wait(0.1)
            end
            plat:Destroy()
        end)
    elseif verticalDiff > 2 then
        local airPos = _clampRideY(Vector3.new(targetPart.Position.X, targetPart.Position.Y - 4, targetPart.Position.Z), targetPart)
        local plat = Instance.new("Part")
        plat.Name = "XiTempPlatform"
        plat.Size = Vector3.new(3, 1, 3)
        plat.Position = airPos - Vector3.new(0, 4, 0)
        plat.Color = Color3.new(1, 0, 0)
        plat.Material = Enum.Material.Neon
        plat.Anchored = true
        plat.CanCollide = true
        plat.Transparency = 0.3
        plat.Parent = Workspace
        RunService.Heartbeat:Wait()
        local _flyTok = newCarpetCancelToken()
        carpetFly(hrp, airPos, {
            speed       = 130,
            safetyPad   = 0,
            ignoreList  = { plat },
            forceMulti  = true,
            cancelToken = _flyTok,
        })
        for i = 1, 10 do
            if LocalPlayer:GetAttribute("Stealing") then break end
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
            hrp.CFrame = CFrame.new(airPos)
            task.wait(0.05)
        end
        task.spawn(function()
            local start = tick()
            while tick() - start < 20 do
                if LocalPlayer:GetAttribute("Stealing") then break end
                task.wait(0.1)
            end
            plat:Destroy()
        end)
    else
        local reachPos = _clampRideY(targetPart.Position, targetPart)
        local _flyTok = newCarpetCancelToken()
        carpetFly(hrp, reachPos, {
            speed       = 140,
            safetyPad   = 0,
            cancelToken = _flyTok,
        })
        for i = 1, 10 do
            if LocalPlayer:GetAttribute("Stealing") then break end
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
            if (hrp.Position - reachPos).Magnitude > 3 then
                hrp.CFrame = CFrame.new(reachPos)
                task.wait(0.05)
            end
            task.wait(0.05)
        end
    end
    State.isTpMoving = false
end
_G.runAutoSnipe = runAutoSnipe
local function runAutoSnipeLegacy()
    if State.isTpMoving then return end
    local targetPetData = nil
    if Config.AutoTPPriority then
        local bestEntry = nil
        local cache = SharedState.AllAnimalsCache
        if cache and type(cache) == "table" then
            for _, pName in ipairs(PRIORITY_LIST) do
                local searchName = pName:lower()
                for _, a in ipairs(cache) do
                    if a and a.name and a.name:lower() == searchName and a.owner ~= LocalPlayer.Name then
                        bestEntry = a
                        break
                    end
                end
                if bestEntry then break end
            end
            if not bestEntry then
                for _, a in ipairs(cache) do
                    if a and a.owner ~= LocalPlayer.Name then bestEntry = a; break end
                end
            end
        end
        if bestEntry then
            targetPetData = bestEntry
        else
            if not SharedState.SelectedPetData then ShowNotification("ERROR","No target selected!"); return end
            targetPetData = SharedState.SelectedPetData.animalData
        end
    else
        if not SharedState.SelectedPetData then ShowNotification("ERROR","No target selected!"); return end
        targetPetData = SharedState.SelectedPetData.animalData
    end
    if not targetPetData then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    State.isTpMoving = true
    task.delay(6, function() State.isTpMoving = false end)
    local targetPart = findAdorneeGlobal(targetPetData)
    if not targetPart then
        State.isTpMoving = false
        return
    end
    local exactPos = targetPart.Position
    local carpetName = Config.TpSettings.Tool
    local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
    local cloner = LocalPlayer.Backpack:FindFirstChild("Quantum Cloner") or char:FindFirstChild("Quantum Cloner")
    if carpet then hum:EquipTool(carpet) end
    task.wait(0.01)
    local isSecondFloor = exactPos.Y > 10
    local isFloor2 = exactPos.Y > 10 and exactPos.Y <= 25
    local floor2FromFloor1 = Config.AutoTPFloor2FromFloor1 and isFloor2
    if floor2FromFloor1 then isSecondFloor = false end
    local plotIndex = getClosestBaseIdx(exactPos)
    local targetBasePos = isSecondFloor and BASES_HIGH[plotIndex] or BASES_LOW[plotIndex]
    local jumpVel = isSecondFloor and (tonumber(Config.Floor2Velocity) or 200) or (tonumber(Config.Floor1Velocity) or 200)
    local minHeight = isSecondFloor and (tonumber(Config.Floor2Height) or 40) or (tonumber(Config.Floor1Height) or 50)
    local targetHeight = math.max(targetBasePos.Y, minHeight)
    local jumpStart = tick()
    while hrp.Position.Y < targetHeight and (tick() - jumpStart) < 3 do
        hrp.Velocity = Vector3.new(hrp.Velocity.X, jumpVel, hrp.Velocity.Z)
        RunService.Heartbeat:Wait()
    end
    hrp.Velocity = Vector3.zero
    for i = 1, 10 do
        hrp.Velocity = Vector3.zero
        if (hrp.Position - targetBasePos).Magnitude > 3 then
            hrp.CFrame = CFrame.new(targetBasePos)
            task.wait(0.03)
        end
    end
    hrp.Velocity = Vector3.zero
    if not isSecondFloor then
        local bestSpot = CLONE_POSITIONS_FLOOR[1]
        local minDst = math.huge
        for _, v in ipairs(CLONE_POSITIONS_FLOOR) do
            local d = (targetPart.Position - v).Magnitude
            if d < minDst then minDst = d; bestSpot = v end
        end
        for i = 1, 6 do
            if (hrp.Position - bestSpot).Magnitude > 3 then
                hrp.CFrame = CFrame.new(bestSpot)
                task.wait(0.05)
            end
        end
    end
    local bestFace = FACE_TARGETS[1]
    local minFaceDist = math.huge
    for _, v in ipairs(FACE_TARGETS) do
        local d = (hrp.Position - v).Magnitude
        if d < minFaceDist then
            minFaceDist = d
            bestFace = v
        end
    end
    task.wait(0.1)
    hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(bestFace.X, hrp.Position.Y, bestFace.Z))
    if isSecondFloor or not _G._isTargetPlotUnlocked(targetPetData.plot) then
        walkForward(0.2)
        task.wait(0.2)
        instantClone(pickCloneSpeed(), true)
        local cdl = tick() + 2.5
        while _G.isCloning and tick() < cdl do task.wait() end
        if _G.isCloning then _G.isCloning = false end
    end
    task.wait(0.08)
    if carpet then hum:EquipTool(carpet) end
    local verticalDiff = targetPart.Position.Y - hrp.Position.Y
    if floor2FromFloor1 then
        local airPos = Vector3.new(targetPart.Position.X, 3, targetPart.Position.Z)
        local plat = Instance.new("Part")
        plat.Name = "XiTempPlatform"
        plat.Size = Vector3.new(3, 1, 3)
        plat.Position = airPos - Vector3.new(0, 4, 0)
        plat.Color = Color3.new(1, 0, 0)
        plat.Material = Enum.Material.Neon
        plat.Anchored = true
        plat.CanCollide = true
        plat.Transparency = 0.3
        plat.Parent = Workspace
        RunService.Heartbeat:Wait()
        for i = 1, 10 do
            if not LocalPlayer:GetAttribute("Stealing") then
                hrp.Velocity = Vector3.zero
                hrp.CFrame = CFrame.new(airPos)
                task.wait(0.05)
            end
        end
        task.spawn(function()
            local start = tick()
            while tick() - start < 20 do
                if LocalPlayer:GetAttribute("Stealing") then break end
                task.wait(0.1)
            end
            plat:Destroy()
        end)
    elseif verticalDiff > 2 then
        local airPos = _clampRideY(Vector3.new(targetPart.Position.X, targetPart.Position.Y - 4, targetPart.Position.Z), targetPart)
        local plat = Instance.new("Part")
        plat.Name = "XiTempPlatform"
        plat.Size = Vector3.new(3, 1, 3)
        plat.Position = airPos - Vector3.new(0, 4, 0)
        plat.Color = Color3.new(1, 0, 0)
        plat.Material = Enum.Material.Neon
        plat.Anchored = true
        plat.CanCollide = true
        plat.Transparency = 0.3
        plat.Parent = Workspace
        RunService.Heartbeat:Wait()
        for i = 1, 10 do
            if not LocalPlayer:GetAttribute("Stealing") then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                hrp.CFrame = CFrame.new(airPos)
                task.wait(0.05)
            end
        end
        task.spawn(function()
            local start = tick()
            while tick() - start < 20 do
                if LocalPlayer:GetAttribute("Stealing") then break end
                task.wait(0.1)
            end
            plat:Destroy()
        end)
    else
        local reachPos = _clampRideY(targetPart.Position, targetPart)
        for i = 1, 10 do
            if LocalPlayer:GetAttribute("Stealing") then break end
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
            if (hrp.Position - reachPos).Magnitude > 3 then
                hrp.CFrame = CFrame.new(reachPos)
                task.wait(0.05)
            end
            task.wait(0.05)
        end
    end
    State.isTpMoving = false
end
_G.runAutoSnipeLegacy = runAutoSnipeLegacy
local function getClosestBaseSign_AdminV1(brainrotPart)
    if not brainrotPart or not brainrotPart:IsA("BasePart") then return nil end
    local closestPart, closestDist = nil, math.huge
    for _, label in ipairs(Workspace:GetDescendants()) do
        if label:IsA("TextLabel") then
            local txt = tostring(label.Text or "")
            if txt ~= "" and txt:lower():find("base", 1, true) then
                local gui = label:FindFirstAncestorWhichIsA("SurfaceGui")
                if gui then
                    local part = gui.Adornee or gui.Parent
                    if part and part:IsA("BasePart") then
                        local dist = (part.Position - brainrotPart.Position).Magnitude
                        if dist < closestDist then closestDist = dist; closestPart = part end
                    end
                end
            end
        end
    end
    return closestPart
end
local function riseToY_AdminV1(hrp, targetY)
    if not hrp then return end
    local MAX_TIME, start = 3.0, os.clock()
    while hrp.Parent and hrp.Position.Y < targetY do
        local dist = targetY - hrp.Position.Y
        local speed = math.clamp(dist * 20, 280, 310)
        hrp.Velocity = Vector3.new(hrp.Velocity.X, speed, hrp.Velocity.Z)
        if os.clock() - start > MAX_TIME then break end
        RunService.Heartbeat:Wait()
    end
    hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
end
local TP_ADMIN_MED_POINTS = {
    {name = "MED1", pos = Vector3.new(-410.65, -5.68, -46.10)},
    {name = "MED2", pos = Vector3.new(-410.91, -5.68, 168.89)},
}
local function flatDist_AdminV1(a, b)
    return (Vector3.new(a.X, 0, a.Z) - Vector3.new(b.X, 0, b.Z)).Magnitude
end
local function getNearestAdminMedPoint(fromPos)
    local bestPoint, bestDist = nil, math.huge
    for _, entry in ipairs(TP_ADMIN_MED_POINTS) do
        local dist = flatDist_AdminV1(fromPos, entry.pos)
        if dist < bestDist then bestDist = dist; bestPoint = entry end
    end
    return bestPoint, bestDist
end
local function equipTpToolAndWait_AdminV1(hum)
    if not hum then return nil end
    local char = hum.Parent
    local toolName = Config.TpSettings.Tool or "Flying Carpet"
    local tool = LocalPlayer.Backpack:FindFirstChild(toolName) or (char and char:FindFirstChild(toolName))
    if tool then hum:EquipTool(tool); task.wait(0.02) end
    return tool
end
local function prepMiniTpTool_AdminV1(hum, hrp)
    if not hum or not hrp then return end
end
local function instantClone_AdminV1()
    if _G.isCloning then return end
    _G.isCloning = true
    local ok = pcall(function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local cloner = LocalPlayer.Backpack:FindFirstChild("Quantum Cloner")
            or character:FindFirstChild("Quantum Cloner")
        if not cloner then return end
        if cloner.Parent ~= character then
            humanoid:EquipTool(cloner)
            task.wait(0.02)
        end
        cloner:Activate()
        task.wait(0.015)
        local cloneName = tostring(LocalPlayer.UserId) .. "_Clone"
        local pollInterval = 0.015
        local maxWait = 4
        local iters = math.max(1, math.floor(maxWait / pollInterval))
        local tpButton
        for _ = 1, iters do
            local tf = PlayerGui:FindFirstChild("ToolsFrames")
            local qcf = tf and tf:FindFirstChild("QuantumCloner")
            tpButton = qcf and qcf:FindFirstChild("TeleportToClone")
            if tpButton or Workspace:FindFirstChild(cloneName) then break end
            task.wait(pollInterval)
        end
        if not tpButton then
            local tf = PlayerGui:FindFirstChild("ToolsFrames")
            local qcf = tf and (tf:FindFirstChild("QuantumCloner") or tf:WaitForChild("QuantumCloner", 1))
            tpButton = qcf and (qcf:FindFirstChild("TeleportToClone") or qcf:WaitForChild("TeleportToClone", 1))
        end
        if not tpButton then return end
        tpButton.Visible = true
        local x = tpButton.AbsolutePosition.X + (tpButton.AbsoluteSize.X / 2)
        local y = tpButton.AbsolutePosition.Y + (tpButton.AbsoluteSize.Y / 2) + 58
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end)
    _G.isCloning = false
end
local function waitSecondsHB_AdminV1(sec)
    local t = 0
    while t < sec do
        t += RunService.Heartbeat:Wait()
    end
end
local function waitUntilHB_AdminV1(predicate, timeoutSec)
    local t = 0
    while true do
        if predicate() then return true end
        local dt = RunService.Heartbeat:Wait()
        t += dt
        if timeoutSec and t >= timeoutSec then
            return false
        end
    end
end
if not _G._isTargetPlotUnlocked then
    _G._isTargetPlotUnlocked = function() return true end
end
if not _G.triggerSafePollBoost then
    _G.triggerSafePollBoost = function() end
end
local function flyToPosAdminV3(hrp, hum, targetPos, speed, timeout)
    if not (hrp and hrp.Parent) then return false end
    local startT = os.clock()
    while os.clock() - startT < (timeout or 6) do
        if not (hrp and hrp.Parent) then return false end
        if hum and hum.Health <= 0 then return false end
        local to = targetPos - hrp.Position
        local d = to.Magnitude
        if d <= 1.5 then break end
        local v = (d < 8) and math.max(speed * (d / 8), 50) or speed
        hrp.Velocity = to.Unit * v
        RunService.Heartbeat:Wait()
    end
    if hrp and hrp.Parent then
        hrp.Velocity = Vector3.zero
    end
    return true
end
local isOnOwnPlot
local function flyToPosAdminV3Bypass(hrp, hum, dest, speed, timeout)
    if not (hrp and hrp.Parent) or typeof(dest) ~= "Vector3" then return false end
    local origin = hrp.Position
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = { LocalPlayer.Character }
    rp.IgnoreWater = true
    pcall(function() rp.RespectCanCollide = true end)
    local function isPlotHit(inst)
        local plots = Workspace:FindFirstChild("Plots")
        return plots and inst and inst:IsDescendantOf(plots)
    end
    local function pathClear(a, b)
        local seg = b - a
        local len = seg.Magnitude
        if len < 6 then return true, nil end
        local d = seg.Unit
        local probeLen = len - 5
        local firstHit = nil
        local plotHit = nil
        local probeBaseY = math.max(a.Y, b.Y)
        for _, dy in ipairs({ 2, 5, 9, 14 }) do
            local hit = Workspace:Raycast(Vector3.new(a.X, probeBaseY + dy, a.Z), d * probeLen, rp)
            if hit then
                firstHit = firstHit or hit
                if isPlotHit(hit.Instance) then
                    plotHit = hit
                end
            end
        end
        if firstHit then
            return false, plotHit or firstHit
        end
        return true, nil
    end
    local clear, firstHit = pathClear(origin, dest)
    if clear then
        return flyToPosAdminV3(hrp, hum, dest, speed, timeout)
    end
    if firstHit and isPlotHit(firstHit.Instance) then
        local flatDir = Vector3.new(dest.X - origin.X, 0, dest.Z - origin.Z)
        if flatDir.Magnitude > 0.01 then
            local dir = flatDir.Unit
            local perp1 = Vector3.new(-dir.Z, 0, dir.X)
            local perp2 = Vector3.new(dir.Z, 0, -dir.X)
            local sideDist = 65
            local ray1 = Workspace:Raycast(origin, perp1 * (sideDist + 10), rp)
            local ray2 = Workspace:Raycast(origin, perp2 * (sideDist + 10), rp)
            local chosenDir = perp1
            if ray1 and not ray2 then
                chosenDir = perp2
            elseif ray1 and ray2 then
                if ray1.Distance < ray2.Distance then
                    chosenDir = perp2
                end
            end
            local sidePos = origin + chosenDir * sideDist
            if isOnOwnPlot and isOnOwnPlot(sidePos) then
                local altDir = -chosenDir
                local altPos = origin + altDir * sideDist
                if not isOnOwnPlot(altPos) then
                    sidePos = altPos
                end
            end
            flyToPosAdminV3(hrp, hum, Vector3.new(sidePos.X, origin.Y, sidePos.Z), speed, timeout or 6)
            if not (hrp and hrp.Parent) then return false end
        end
        return flyToPosAdminV3(hrp, hum, dest, speed, timeout or 6)
    end
    local flat = Vector3.new(dest.X - origin.X, 0, dest.Z - origin.Z)
    local dist = flat.Magnitude
    local lowY = math.min(origin.Y, dest.Y)
    local baseY = math.max(origin.Y, dest.Y)
    local clearY = baseY + 96
    for hAdd = 6, 96, 6 do
        local y = baseY + hAdd
        if not Workspace:Raycast(
            Vector3.new(origin.X, y, origin.Z),
            Vector3.new(flat.X, 0, flat.Z), rp) then
            clearY = y + 12
            break
        end
    end
    local descX, descZ = dest.X, dest.Z
    if dist > 16 then
        local dir = flat / dist
        local d = 14
        while d < dist - 8 do
            local cx = origin.X + dir.X * d
            local cz = origin.Z + dir.Z * d
            local a = Vector3.new(cx, lowY + 3, cz)
            local b = Vector3.new(dest.X, lowY + 3, dest.Z)
            if not Workspace:Raycast(a, b - a, rp) then
                descX, descZ = cx, cz
                break
            end
            d = d + 8
        end
    end
    flyToPosAdminV3(hrp, hum, Vector3.new(descX, clearY, descZ), speed, timeout)
    if not (hrp and hrp.Parent) then return false end
    local toT = Vector3.new(dest.X - descX, 0, dest.Z - descZ)
    local fwd = (toT.Magnitude > 1) and toT.Unit or Vector3.new(0, 0, 0)
    local step = math.min(toT.Magnitude * 0.5, 28)
    flyToPosAdminV3(hrp, hum, Vector3.new(descX + fwd.X * step, lowY, descZ + fwd.Z * step), speed, timeout)
    if not (hrp and hrp.Parent) then return false end
    return flyToPosAdminV3(hrp, hum, dest, speed, timeout)
end
local function runAutoSnipeAdminV1(useTweenV3)
    if State.isTpMoving then return end
    local _startDelay = Config.AutoTPStartDelay or 0.5
    if _startDelay > 0 then task.wait(_startDelay) end
    local targetPetData = nil
    local cache = SharedState.AllAnimalsCache
    if _G._tpLoadOverride and _G._tpLoadTarget then
        targetPetData = _G._tpLoadTarget
        if targetPetData.owner == LocalPlayer.Name then targetPetData = nil end
    end
    if not targetPetData and Config.AutoTPPriority and cache and type(cache) == "table" then
        for _, pName in ipairs(PRIORITY_LIST) do
            local searchName = pName:lower()
            for _, a in ipairs(cache) do
                if a and a.name and a.uid
                    and a.owner ~= LocalPlayer.Name
                    and a.name:lower() == searchName then
                    targetPetData = a
                    break
                end
            end
            if targetPetData then break end
        end
        if not targetPetData then
            for _, a in ipairs(cache) do
                if a and a.uid and a.owner ~= LocalPlayer.Name then
                    targetPetData = a
                    break
                end
            end
        end
    elseif not targetPetData and cache and type(cache) == "table" then
        if SharedState.SelectedPetData and SharedState.SelectedPetData.animalData then
            local sd = SharedState.SelectedPetData.animalData
            if sd.owner ~= LocalPlayer.Name then
                targetPetData = sd
            end
        end
        if not targetPetData then
            local _hrp2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local _bestDist = math.huge
            for _, a in ipairs(cache) do
                if a and a.uid and a.owner ~= LocalPlayer.Name then
                    if not _hrp2 then targetPetData = a; break end
                    local _p = findAdorneeGlobal(a)
                    if _p then
                        local _d = (_p.Position - _hrp2.Position).Magnitude
                        if _d < _bestDist then _bestDist = _d; targetPetData = a end
                    end
                end
            end
        end
    end
    if not targetPetData then ShowNotification("ERROR","No target selected!"); return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    State.isTpMoving = true
    local _autoStealWasOn = _G.ZawaHub_GetAutoSteal and _G.ZawaHub_GetAutoSteal()
    if useTweenV3 and _autoStealWasOn and _G.ZawaHub_SetAutoSteal then
        _G.ZawaHub_SetAutoSteal(false)
    end
    local ok, err = pcall(function()
        local targetPart = findAdorneeGlobal(targetPetData)
        if not targetPart then error("targetPart nil") end
        local targetCF
        if targetPart:IsA("Attachment") then
            targetCF = targetPart.WorldCFrame
        elseif targetPart:IsA("BasePart") then
            targetCF = targetPart.CFrame
        else
            local okPivot, pivot = pcall(function() return targetPart:GetPivot() end)
            if okPivot then targetCF = pivot end
        end
        if not targetCF then error("targetCF nil") end
        local exactPos = targetPart.Position
        local carpetName = Config.TpSettings.Tool
        local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
        local cloner = LocalPlayer.Backpack:FindFirstChild("Quantum Cloner") or char:FindFirstChild("Quantum Cloner")
        equipTpToolAndWait_AdminV1(hum)
        local isSecondFloor = exactPos.Y > 10
        local isFloor2 = exactPos.Y > 10 and exactPos.Y <= 25
        local floor2FromFloor1 = Config.AutoTPFloor2FromFloor1 and isFloor2
        if floor2FromFloor1 then isSecondFloor = false end
        local signPart = getClosestBaseSign_AdminV1(targetPart)
        if not signPart then error("signPart nil") end
        local signCF = signPart.CFrame
        local RIGHT = signCF.RightVector
        local LEFT = -RIGHT
        local FORWARD = signCF.LookVector
        local BACK = -signCF.LookVector
        local medPoint = nil
        if not useTweenV3 then
            medPoint = getNearestAdminMedPoint(hrp.Position)
            if not medPoint then error("normal tp MED point nil") end
        end
        hrp.Velocity = Vector3.zero
        if hum and hum.Parent then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        task.wait(0.01)
        if not hrp or not hrp.Parent then error("hrp lost during normal jump start") end
        local tweenSpeed = isSecondFloor and (tonumber(Config.TweenTpSpeedF2) or 130) or (tonumber(Config.TweenTpSpeedF1) or 140)
        if not useTweenV3 then
            local medFlatPos = Vector3.new(medPoint.pos.X, hrp.Position.Y, medPoint.pos.Z)
            hrp.CFrame = CFrame.new(medFlatPos)
            hrp.Velocity = Vector3.zero
            task.wait(0.1)
            if not hrp or not hrp.Parent then error("hrp lost after MED reposition") end
            waitUntilHB_AdminV1(function()
                return hrp and hrp.Parent and flatDist_AdminV1(hrp.Position, medPoint.pos) <= 2.5
            end, 1.5)
            riseToY_AdminV1(hrp, 40)
        end
        local tpPos
        if exactPos.Y <= 6.313370704650879 or floor2FromFloor1 then
            local frontPoint = signPart.Position + (FORWARD * 20)
            local backPoint = signPart.Position + (BACK * 20)
            local myPos = hrp.Position
            local distFront = (Vector3.new(frontPoint.X, 0, frontPoint.Z) - Vector3.new(myPos.X, 0, myPos.Z)).Magnitude
            local distBack = (Vector3.new(backPoint.X, 0, backPoint.Z) - Vector3.new(myPos.X, 0, myPos.Z)).Magnitude
            local chosen = (distFront < distBack) and frontPoint or backPoint
            tpPos = Vector3.new(chosen.X, -4.8, chosen.Z)
        else
            local wallAnchor = signPart.Position
            local wallOffset = useTweenV3 and 20 or 15
            local backPoint = wallAnchor + (BACK * wallOffset)
            local frontPoint = wallAnchor + (FORWARD * wallOffset)
            local myPos = hrp.Position
            local myFlat = Vector3.new(myPos.X, 0, myPos.Z)
            local distBack = (Vector3.new(backPoint.X, 0, backPoint.Z) - myFlat).Magnitude
            local distFront = (Vector3.new(frontPoint.X, 0, frontPoint.Z) - myFlat).Magnitude
            local chosen = (distBack < distFront) and backPoint or frontPoint
            local wallY = useTweenV3 and math.max(15, targetPart.Position.Y) or (signPart.Position.Y + 4)
            tpPos = Vector3.new(chosen.X, wallY, chosen.Z)
        end
        hrp.Velocity = Vector3.zero
        if useTweenV3 then
            flyToPosAdminV3Bypass(hrp, hum, tpPos, tweenSpeed, 6)
            if hrp and hrp.Parent then
                hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + LEFT)
            end
        else
            hrp.CFrame = CFrame.lookAt(tpPos, tpPos + LEFT)
        end
        hrp.Velocity = Vector3.zero
        local isFirstFloorApproach = exactPos.Y <= 6.313370704650879 or floor2FromFloor1
        if isFirstFloorApproach then
            waitUntilHB_AdminV1(function()
                if not (hrp and hrp.Parent) then return false end
                local dx = hrp.Position.X - tpPos.X
                local dz = hrp.Position.Z - tpPos.Z
                return math.sqrt(dx * dx + dz * dz) <= 4.5
            end, 4.5)
            waitUntilHB_AdminV1(function()
                return hum and hum.Parent and hum.FloorMaterial ~= Enum.Material.Air
            end, 1.25)
            waitSecondsHB_AdminV1(0.08)
            if hrp and hrp.Parent then
                hrp.Velocity = Vector3.zero
                hrp.Velocity = Vector3.zero
                local anchorPos = Vector3.new(tpPos.X, hrp.Position.Y, tpPos.Z)
                hrp.CFrame = CFrame.lookAt(anchorPos, anchorPos + LEFT)
                hrp.Velocity = Vector3.zero
            end
            waitSecondsHB_AdminV1(0.05)
        else
            waitUntilHB_AdminV1(function()
                return hrp and hrp.Parent and (hrp.Position - tpPos).Magnitude <= 2.5
            end, 3.0)
            waitSecondsHB_AdminV1(0.10)
            waitSecondsHB_AdminV1(0.05)
        end
        if useTweenV3 then
            _G.ZawaHub_IgnoreStealRadius = true
            if _G.ZawaHub_SetAutoSteal then _G.ZawaHub_SetAutoSteal(true) end
            task.delay(4, function()
                _G.ZawaHub_IgnoreStealRadius = false
            end)
            task.spawn(function()
                local deadline = tick() + 4
                while tick() < deadline do
                    if LocalPlayer:GetAttribute("Stealing") then
                        task.wait(0.5)
                        _G.ZawaHub_IgnoreStealRadius = false
                        return
                    end
                    task.wait(0.05)
                end
                _G.ZawaHub_IgnoreStealRadius = false
            end)
        end
        if isSecondFloor or not _G._isTargetPlotUnlocked(targetPetData.plot) then
            prepMiniTpTool_AdminV1(hum, hrp)
            waitSecondsHB_AdminV1(0.05)
            if isSecondFloor then
                hrp.Velocity = Vector3.zero
                waitSecondsHB_AdminV1(0.01)
                hrp.Velocity = Vector3.zero
                if not useTweenV3 then
                    hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -2.5)
                end
                hrp.Velocity = Vector3.zero
            else
                hrp.Velocity = Vector3.zero
                hrp.Velocity = Vector3.zero
                waitSecondsHB_AdminV1(0.03)
                walkForward(0.15)
            end
            waitSecondsHB_AdminV1(0.07)
            hrp.Velocity = Vector3.zero
            hrp.Velocity = Vector3.zero
            waitSecondsHB_AdminV1(0.05)
            local miniPos = hrp.Position
            local miniLook = hrp.CFrame.LookVector
            local stableTicks = 0
            local stableOk = waitUntilHB_AdminV1(function()
                if not (hrp and hrp.Parent) then return false end
                if (hrp.Position - miniPos).Magnitude <= 0.25 then
                    stableTicks = stableTicks + 1
                else
                    stableTicks = 0
                    miniPos = hrp.Position
                end
                return stableTicks >= 3
            end, 0.75)
            if not stableOk then
                if hrp and hrp.Parent then
                    hrp.Velocity = Vector3.zero
                    hrp.Velocity = Vector3.zero
                    hrp.CFrame = CFrame.lookAt(miniPos, miniPos + miniLook)
                    hrp.Velocity = Vector3.zero
                end
                waitSecondsHB_AdminV1(0.05)
                miniPos = hrp.Position
                miniLook = hrp.CFrame.LookVector
            end
            hrp.Velocity = Vector3.zero
            hrp.Velocity = Vector3.zero
            instantClone_AdminV1()
            local cloneMoved = waitUntilHB_AdminV1(function()
                return hrp and hrp.Parent and ((hrp.Position - miniPos).Magnitude >= 0.35)
            end, isSecondFloor and 1.5 or 4.0)
            if not cloneMoved and isSecondFloor then
                if hrp and hrp.Parent then
                    hrp.Velocity = Vector3.zero
                    hrp.Velocity = Vector3.zero
                    hrp.CFrame = CFrame.lookAt(miniPos, miniPos + miniLook)
                    hrp.Velocity = Vector3.zero
                end
                waitSecondsHB_AdminV1(0.08)
                miniPos = hrp.Position
                instantClone_AdminV1()
                cloneMoved = waitUntilHB_AdminV1(function()
                    return hrp and hrp.Parent and ((hrp.Position - miniPos).Magnitude >= 0.35)
                end, 2.0)
                if not cloneMoved then
                    if hrp and hrp.Parent then
                        hrp.Velocity = Vector3.zero
                        hrp.Velocity = Vector3.zero
                        hrp.CFrame = CFrame.lookAt(miniPos, miniPos + miniLook)
                        hrp.Velocity = Vector3.zero
                    end
                    waitSecondsHB_AdminV1(0.08)
                    miniPos = hrp.Position
                    instantClone_AdminV1()
                    waitUntilHB_AdminV1(function()
                        return hrp and hrp.Parent and ((hrp.Position - miniPos).Magnitude >= 0.35)
                    end, 2.5)
                end
            end
            local dl = tick() + 2
            while _G.isCloning and tick() < dl do task.wait() end
        end
        task.wait(0.15)
        equipTpToolAndWait_AdminV1(hum)
        local verticalDiff = targetPart.Position.Y - hrp.Position.Y
        if floor2FromFloor1 then
            local airPos = Vector3.new(targetPart.Position.X, 3, targetPart.Position.Z)
            local plat = Instance.new("Part")
            plat.Name = "XiTempPlatform"
            plat.Size = Vector3.new(3, 1, 3)
            plat.Position = airPos - Vector3.new(0, 3, 0)
            plat.Color = Color3.new(1, 0, 0)
            plat.Material = Enum.Material.Neon
            plat.Anchored = true
            plat.CanCollide = true
            plat.Transparency = 0.3
            plat.Parent = Workspace
            RunService.Heartbeat:Wait()
            if useTweenV3 then
                carpetFly(hrp, airPos, {
                    speed = 130,
                    safetyPad = 0,
                    ignoreList = { plat },
                    timeout = 1,
                    cancelToken = newCarpetCancelToken(),
                })
            end
            for i = 1, 10 do
                if not LocalPlayer:GetAttribute("Stealing") then
                    hrp.Velocity = Vector3.zero
                    if useTweenV3 then
                        if (hrp.Position - airPos).Magnitude > 3 then
                            hrp.CFrame = CFrame.new(airPos)
                        end
                    else
                        hrp.CFrame = CFrame.new(airPos)
                    end
                    task.wait(0.05)
                end
            end
            task.spawn(function()
                local start = tick()
                while tick() - start < 20 do
                    if LocalPlayer:GetAttribute("Stealing") then break end
                    task.wait(0.1)
                end
                plat:Destroy()
            end)
        elseif verticalDiff > 2 then
            local airPos = _clampRideY(Vector3.new(targetPart.Position.X, targetPart.Position.Y - 4, targetPart.Position.Z), targetPart)
            local plat = Instance.new("Part")
            plat.Name = "XiTempPlatform"
            plat.Size = Vector3.new(3, 1, 3)
            plat.Position = airPos - Vector3.new(0, 3, 0)
            plat.Color = Color3.new(1, 0, 0)
            plat.Material = Enum.Material.Neon
            plat.Anchored = true
            plat.CanCollide = true
            plat.Transparency = 0.3
            plat.Parent = Workspace
            RunService.Heartbeat:Wait()
            if useTweenV3 then
                carpetFly(hrp, airPos, {
                    speed = 130,
                    safetyPad = 0,
                    ignoreList = { plat },
                    timeout = 1,
                    cancelToken = newCarpetCancelToken(),
                })
            end
            for i = 1, 10 do
                if not LocalPlayer:GetAttribute("Stealing") then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                    if useTweenV3 then
                        if (hrp.Position - airPos).Magnitude > 3 then
                            hrp.CFrame = CFrame.new(airPos)
                        end
                    else
                        hrp.CFrame = CFrame.new(airPos)
                    end
                    task.wait(0.05)
                end
            end
            task.spawn(function()
                local start = tick()
                while tick() - start < 20 do
                    if LocalPlayer:GetAttribute("Stealing") then break end
                    task.wait(0.1)
                end
                plat:Destroy()
            end)
        else
            local reachPos = _clampRideY(targetPart.Position, targetPart)
            if useTweenV3 then
                carpetFly(hrp, reachPos, {
                    speed = 140,
                    safetyPad = 0,
                    timeout = 1,
                    cancelToken = newCarpetCancelToken(),
                })
            end
            for i = 1, 10 do
                if LocalPlayer:GetAttribute("Stealing") then break end
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                if (hrp.Position - reachPos).Magnitude > 3 then
                    hrp.CFrame = CFrame.new(reachPos)
                    task.wait(0.05)
                end
                task.wait(0.05)
            end
        end
    end)
    State.isTpMoving = false
    if useTweenV3 and _autoStealWasOn then
        _G.ZawaHub_IgnoreStealRadius = false
        if not (_G.ZawaHub_GetAutoSteal and _G.ZawaHub_GetAutoSteal()) then
            if _G.ZawaHub_SetAutoSteal then _G.ZawaHub_SetAutoSteal(true) end
        end
    end
    if not ok then
        warn("runAutoSnipeAdminV1 error:", err)
    end
end
_G.runAutoSnipeAdminV1 = runAutoSnipeAdminV1
local function instantCloneBestHubTp()
    if _G.isCloning then return end
    _G.isCloning = true
    pcall(function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local cloner = LocalPlayer.Backpack:FindFirstChild("Quantum Cloner")
            or character:FindFirstChild("Quantum Cloner")
        if not cloner then return end
        if cloner.Parent ~= character then
            humanoid:EquipTool(cloner)
            task.wait(0.02)
        end
        cloner:Activate()
        task.wait(0.05)
        local cloneName = tostring(LocalPlayer.UserId) .. "_Clone"
        local tpButton
        local deadline = tick() + 5
        repeat
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            local tf = pg and pg:FindFirstChild("ToolsFrames")
            local qcf = tf and tf:FindFirstChild("QuantumCloner")
            tpButton = qcf and qcf:FindFirstChild("TeleportToClone")
            if tpButton or Workspace:FindFirstChild(cloneName) then break end
            task.wait(0.015)
        until tick() >= deadline
        if not tpButton then
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            local tf = pg and (pg:FindFirstChild("ToolsFrames") or pg:WaitForChild("ToolsFrames", 2))
            local qcf = tf and (tf:FindFirstChild("QuantumCloner") or tf:WaitForChild("QuantumCloner", 2))
            tpButton = qcf and (qcf:FindFirstChild("TeleportToClone") or qcf:WaitForChild("TeleportToClone", 2))
        end
        if tpButton then
            tpButton.Visible = true
            local x = tpButton.AbsolutePosition.X + (tpButton.AbsoluteSize.X / 2)
            local y = tpButton.AbsolutePosition.Y + (tpButton.AbsoluteSize.Y / 2) + 58
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
            if _G.triggerSafePollBoost then _G.triggerSafePollBoost() end
        end
    end)
    _G.isCloning = false
end
local function waitSecondsHeartbeat(sec)
    local t = 0
    while t < sec do
        t += RunService.Heartbeat:Wait()
    end
end
local function waitUntilHeartbeat(predicate, timeoutSec)
    local t = 0
    while true do
        if predicate() then return true end
        local dt = RunService.Heartbeat:Wait()
        t += dt
        if timeoutSec and t >= timeoutSec then return false end
    end
end
local function getClosestBaseSign(brainrotPart)
    if not brainrotPart or not brainrotPart:IsA("BasePart") then return nil end
    local closestPart, closestDist = nil, math.huge
    for _, label in ipairs(Workspace:GetDescendants()) do
        if label:IsA("TextLabel") then
            local txt = tostring(label.Text or "")
            if txt ~= "" and txt:lower():find("base", 1, true) then
                local gui = label:FindFirstAncestorWhichIsA("SurfaceGui")
                if gui then
                    local part = gui.Adornee or gui.Parent
                    if part and part:IsA("BasePart") then
                        local dist = (part.Position - brainrotPart.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestPart = part
                        end
                    end
                end
            end
        end
    end
    return closestPart
end
local function riseToY(hrp, targetY)
    if not hrp then return end
    local maxTime, start = 3.0, os.clock()
    while hrp.Parent and hrp.Position.Y < targetY do
        local dist = targetY - hrp.Position.Y
        local speed = math.clamp(dist * 20, 280, 310)
        hrp.Velocity = Vector3.new(hrp.Velocity.X, speed, hrp.Velocity.Z)
        if os.clock() - start > maxTime then break end
        RunService.Heartbeat:Wait()
    end
    hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
end
local function flyToPosV2(hrp, hum, targetPos, speed, timeout)
    if not (hrp and hrp.Parent) then return false end
    local startT = os.clock()
    while os.clock() - startT < (timeout or 6) do
        if not (hrp and hrp.Parent) then return false end
        if hum and hum.Health <= 0 then return false end
        local to = targetPos - hrp.Position
        local d  = to.Magnitude
        if d <= 1.5 then break end
        local v = (d < 8) and math.max(speed * (d / 8), 50) or speed
        hrp.Velocity = to.Unit * v
        RunService.Heartbeat:Wait()
    end
    if hrp and hrp.Parent then
        hrp.Velocity = Vector3.zero
    end
    return true
end
local function flyToPosV2Bypass(hrp, hum, dest, speed, timeout)
    if not (hrp and hrp.Parent) or typeof(dest) ~= "Vector3" then return false end
    local origin = hrp.Position
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = { LocalPlayer.Character }
    rp.IgnoreWater = true
    pcall(function() rp.RespectCanCollide = true end)
    local function pathClear(a, b)
        local seg = b - a
        local len = seg.Magnitude
        if len < 6 then return true end
        local d = seg.Unit
        local probeLen = len - 5
        for _, dy in ipairs({ 3, 0, -3, -6, -9 }) do
            if Workspace:Raycast(a + Vector3.new(0, dy, 0), d * probeLen, rp) then
                return false
            end
        end
        return true
    end
    if pathClear(origin, dest) then
        return flyToPosV2(hrp, hum, dest, speed, timeout)
    end
    local flat = Vector3.new(dest.X - origin.X, 0, dest.Z - origin.Z)
    local dist = flat.Magnitude
    local lowY = math.min(origin.Y, dest.Y)
    local baseY  = math.max(origin.Y, dest.Y)
    local clearY = baseY + 96
    for hAdd = 6, 96, 6 do
        local y = baseY + hAdd
        if not Workspace:Raycast(
            Vector3.new(origin.X, y, origin.Z),
            Vector3.new(flat.X, 0, flat.Z), rp) then
            clearY = y + 12
            break
        end
    end
    local descX, descZ = dest.X, dest.Z
    if dist > 16 then
        local dir = flat / dist
        local d = 14
        while d < dist - 8 do
            local cx = origin.X + dir.X * d
            local cz = origin.Z + dir.Z * d
            local a = Vector3.new(cx, lowY + 3, cz)
            local b = Vector3.new(dest.X, lowY + 3, dest.Z)
            if not Workspace:Raycast(a, b - a, rp) then
                descX, descZ = cx, cz
                break
            end
            d = d + 8
        end
    end
    flyToPosV2(hrp, hum, Vector3.new(descX, clearY, descZ), speed, timeout)
    if not (hrp and hrp.Parent) then return false end
    local toT  = Vector3.new(dest.X - descX, 0, dest.Z - descZ)
    local fwd  = (toT.Magnitude > 1) and toT.Unit or Vector3.new(0, 0, 0)
    local step = math.min(toT.Magnitude * 0.5, 28)
    flyToPosV2(hrp, hum,
        Vector3.new(descX + fwd.X * step, lowY, descZ + fwd.Z * step),
        speed, timeout)
    if not (hrp and hrp.Parent) then return false end
    return flyToPosV2(hrp, hum, dest, speed, timeout)
end
local function _brainrotFloorPos(targetPart)
    local bp = targetPart.Position
    local rp = RaycastParams.new()
    rp.FilterType  = Enum.RaycastFilterType.Exclude
    rp.IgnoreWater = true
    local filter = {}
    if LocalPlayer.Character then table.insert(filter, LocalPlayer.Character) end
    for _, p in ipairs(Workspace:GetChildren()) do
        if p.Name == "XiTempPlatform" then table.insert(filter, p) end
    end
    if typeof(targetPart) == "Instance" then
        table.insert(filter, targetPart)
        local m = targetPart:FindFirstAncestorWhichIsA("Model")
        if m then table.insert(filter, m) end
    end
    rp.FilterDescendantsInstances = filter
    local STAND   = 3.5  
    local MAXDROP = 8    
    local floorY
    local down = Workspace:Raycast(bp + Vector3.new(0, -1, 0), Vector3.new(0, -90, 0), rp)
    if down then floorY = down.Position.Y end
    local y
    if floorY then
        y = math.max(floorY + STAND, bp.Y - MAXDROP)
    else
        y = bp.Y - 4
    end
    if y > bp.Y then y = bp.Y end
    local up = Workspace:Raycast(Vector3.new(bp.X, y, bp.Z), Vector3.new(0, 14, 0), rp)
    if up then
        local maxY = up.Position.Y - 7
        if y > maxY then
            y = (floorY and math.max(maxY, floorY + STAND)) or maxY
        end
    end
    return Vector3.new(bp.X, y, bp.Z)
end
local function equipTpToolAndWait(hum)
    if not hum then return nil end
    local char = hum.Parent
    local toolName = Config.TpSettings.Tool or "Flying Carpet"
    local tool = LocalPlayer.Backpack:FindFirstChild(toolName) or (char and char:FindFirstChild(toolName))
    if tool then
        hum:EquipTool(tool)
        task.wait(0.02)
    end
    return tool
end
local function prepMiniTpTool(hum, hrp)
    if not hum or not hrp then return end
end
local TP_V2_MED_POINTS = {
    {name = "MED1", pos = Vector3.new(-410.65, -5.68, -46.10)},
    {name = "MED2", pos = Vector3.new(-410.91, -5.68, 168.89)},
}
local TP_V2_SECOND_FLOOR_POINTS = {
    {name = "TP1",  pos = Vector3.new(-488.88, 15, 196.38), facing = "back"},
    {name = "TP2",  pos = Vector3.new(-487.79, 15, 138.13), facing = "front"},
    {name = "TP3",  pos = Vector3.new(-489.38, 15, 89.23),  facing = "back"},
    {name = "TP4",  pos = Vector3.new(-489.69, 15, 30.98),  facing = "front"},
    {name = "TP5",  pos = Vector3.new(-488.75, 15, -17.95), facing = "back"},
    {name = "TP6",  pos = Vector3.new(-490, 15, -75.90),    facing = "front"},
    {name = "TP7",  pos = Vector3.new(-331.75, 15, -75.80), facing = "back"},
    {name = "TP8",  pos = Vector3.new(-329.98, 15, -18.16), facing = "front"},
    {name = "TP9",  pos = Vector3.new(-330.04, 15, 31.14),  facing = "back"},
    {name = "TP10", pos = Vector3.new(-331.28, 15, 88.92),  facing = "front"},
    {name = "TP11", pos = Vector3.new(-330.57, 15, 138.10), facing = "back"},
    {name = "TP12", pos = Vector3.new(-330.01, 15, 195.96), facing = "front"},
}
local function flatDistance(a, b)
    return (Vector3.new(a.X, 0, a.Z) - Vector3.new(b.X, 0, b.Z)).Magnitude
end
local function getClosestBaseSignToPosition(worldPos)
    local closestPart, closestDist = nil, math.huge
    for _, label in ipairs(Workspace:GetDescendants()) do
        if label:IsA("TextLabel") then
            local txt = tostring(label.Text or "")
            if txt ~= "" and txt:lower():find("base", 1, true) then
                local gui = label:FindFirstAncestorWhichIsA("SurfaceGui")
                if gui then
                    local part = gui.Adornee or gui.Parent
                    if part and part:IsA("BasePart") then
                        local dist = (part.Position - worldPos).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestPart = part
                        end
                    end
                end
            end
        end
    end
    return closestPart
end
local function getNearestTeleportV2MedPoint(fromPos)
    local bestPoint, bestDist = nil, math.huge
    for _, entry in ipairs(TP_V2_MED_POINTS) do
        local dist = flatDistance(fromPos, entry.pos)
        if dist < bestDist then bestDist = dist; bestPoint = entry end
    end
    return bestPoint, bestDist
end
local TP_V2_ALLOWED_BY_MED = {
    MED1 = { TP6=true, TP7=true, TP8=true, TP10=true, TP12=true, TP5=true, TP3=true, TP1=true },
    MED2 = { TP1=true, TP2=true, TP4=true, TP6=true, TP7=true, TP9=true, TP11=true, TP12=true },
}
local function getBestTeleportV2SecondFloorPoint(medPoint, brainrotPos)
    local medPos = medPoint and medPoint.pos
    local medName = medPoint and medPoint.name
    if not medPos or not medName then return nil end
    local allowed = TP_V2_ALLOWED_BY_MED[medName]
    if not allowed then return nil end
    local bestPoint = nil
    local bestMedDist = math.huge
    local bestBrainrotDist = math.huge
    for _, entry in ipairs(TP_V2_SECOND_FLOOR_POINTS) do
        if allowed[entry.name] then
            local distToMed = flatDistance(medPos, entry.pos)
            local distToBrainrot = flatDistance(brainrotPos, entry.pos)
            if (distToBrainrot < bestBrainrotDist)
                or (math.abs(distToBrainrot - bestBrainrotDist) <= 0.001 and distToMed < bestMedDist) then
                bestPoint = entry
                bestMedDist = distToMed
                bestBrainrotDist = distToBrainrot
            end
        end
    end
    return bestPoint, bestMedDist, bestBrainrotDist
end
local function getOwnBaseExit(hrp)
    if not hrp then return nil end
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local meName = LocalPlayer.Name:lower()
    local meDisp = (LocalPlayer.DisplayName or LocalPlayer.Name):lower()
    for _, plot in ipairs(plots:GetChildren()) do
        local sign = plot:FindFirstChild("PlotSign")
        local mine = false
        if sign then
            local sgui  = sign:FindFirstChildWhichIsA("SurfaceGui", true)
            local label = sgui and sgui:FindFirstChildWhichIsA("TextLabel", true)
            if label then
                local t = label.Text:lower()
                if t:find(meName, 1, true) or t:find(meDisp, 1, true) then
                    mine = true
                end
            end
        end
        if mine then
            local onPlot, cf, size = false, nil, nil
            local ok, bcf, bsize = pcall(function() return plot:GetBoundingBox() end)
            if ok and bcf and bsize then
                cf, size = bcf, bsize
                local rel = cf:PointToObjectSpace(hrp.Position)
                onPlot = math.abs(rel.X) <= size.X / 2 + 15
                     and math.abs(rel.Z) <= size.Z / 2 + 15
            else
                local ref = plot:FindFirstChild("MainRootPart")
                    or plot:FindFirstChildWhichIsA("BasePart")
                if ref then
                    local dx = hrp.Position.X - ref.Position.X
                    local dz = hrp.Position.Z - ref.Position.Z
                    onPlot = math.sqrt(dx * dx + dz * dz) <= 120
                end
            end
            if not onPlot then return nil end
            for _, d in ipairs(plot:GetDescendants()) do
                if d:IsA("BasePart") and string.find(d.Name:lower(), "collect", 1, true) then
                    return Vector3.new(d.Position.X, d.Position.Y + 5, d.Position.Z)
                end
            end
            for _, d in ipairs(plot:GetDescendants()) do
                if (d:IsA("TextLabel") or d:IsA("TextButton"))
                   and string.find(tostring(d.Text or ""):lower(), "collect", 1, true) then
                    local p = d:FindFirstAncestorWhichIsA("BasePart")
                    if p then return Vector3.new(p.Position.X, p.Position.Y + 5, p.Position.Z) end
                    local g = d:FindFirstAncestorWhichIsA("SurfaceGui")
                          or d:FindFirstAncestorWhichIsA("BillboardGui")
                    if g and g.Adornee and g.Adornee:IsA("BasePart") then
                        local a = g.Adornee
                        return Vector3.new(a.Position.X, a.Position.Y + 5, a.Position.Z)
                    end
                end
            end
            if cf and size then
                local dir = Vector3.new(hrp.Position.X - cf.X, 0, hrp.Position.Z - cf.Z)
                dir = (dir.Magnitude > 0.01) and dir.Unit or Vector3.new(1, 0, 0)
                local reach = math.max(size.X, size.Z) / 2 + 30
                return Vector3.new(cf.X + dir.X * reach, hrp.Position.Y, cf.Z + dir.Z * reach)
            end
            return nil
        end
    end
    return nil
end
isOnOwnPlot = function(pos)
    if not pos then return false end
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return false end
    local meName = LocalPlayer.Name:lower()
    local meDisp = (LocalPlayer.DisplayName or LocalPlayer.Name):lower()
    for _, plot in ipairs(plots:GetChildren()) do
        local sign = plot:FindFirstChild("PlotSign")
        local mine = false
        if sign then
            local sgui  = sign:FindFirstChildWhichIsA("SurfaceGui", true)
            local label = sgui and sgui:FindFirstChildWhichIsA("TextLabel", true)
            if label then
                local t = label.Text:lower()
                if t:find(meName, 1, true) or t:find(meDisp, 1, true) then
                    mine = true
                end
            end
        end
        if mine then
            local ok, cf, size = pcall(function() return plot:GetBoundingBox() end)
            if ok and cf and size then
                local rel = cf:PointToObjectSpace(pos)
                return math.abs(rel.X) <= size.X / 2 + 15
                   and math.abs(rel.Z) <= size.Z / 2 + 15
            end
            local ref = plot:FindFirstChild("MainRootPart")
                or plot:FindFirstChildWhichIsA("BasePart")
            if ref then
                local dx = pos.X - ref.Position.X
                local dz = pos.Z - ref.Position.Z
                return math.sqrt(dx * dx + dz * dz) <= 120
            end
            return false
        end
    end
    return false
end
local function runTeleportV2SecondFloor(targetPart, hum, hrp, useTween)
    if not targetPart or not hum or not hrp then return false, "missing target/hum/hrp" end
    local tweenSpeed = tonumber(Config.TweenTpSpeedF1) or 140
    if useTween then
        local sp = getClosestBaseSign(targetPart)
        if sp then
            local fa = sp.CFrame.RightVector   
            local lv = sp.CFrame.LookVector    
            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Exclude
            rp.FilterDescendantsInstances = { LocalPlayer.Character }
            rp.IgnoreWater = true
            pcall(function() rp.RespectCanCollide = true end)
            local sideDist = 60
            local exit = getOwnBaseExit(hrp)
            local justExitedOwnBase = false
            if exit then
                flyToPosV2(hrp, hum, exit, tweenSpeed, 6)
                justExitedOwnBase = true
            end
            if justExitedOwnBase then
                local toBr0 = Vector3.new(
                    targetPart.Position.X - hrp.Position.X, 0,
                    targetPart.Position.Z - hrp.Position.Z)
                if toBr0.Magnitude > 30 then
                    local fwd = toBr0.Unit
                    local fwdLen = math.min(50, toBr0.Magnitude - 25)
                    if fwdLen > 10 then
                        local fwdDest = hrp.Position + fwd * fwdLen
                        if not isOnOwnPlot(fwdDest)
                           and not Workspace:Raycast(hrp.Position, fwd * (fwdLen + 4), rp) then
                            flyToPosV2(hrp, hum, fwdDest, tweenSpeed, 6)
                        end
                    end
                end
            end
            local toP = hrp.Position - sp.Position
            local frontComp = toP.X * fa.X + toP.Z * fa.Z
            local sideComp  = toP.X * lv.X + toP.Z * lv.Z
            local atFront = frontComp > 10 and frontComp > math.abs(sideComp)
            if atFront then
                local toBr = Vector3.new(
                    targetPart.Position.X - hrp.Position.X, 0,
                    targetPart.Position.Z - hrp.Position.Z)
                if toBr.Magnitude > 0.01 then
                    local f = toBr.Unit
                    local perp = Vector3.new(-f.Z, 0, f.X)
                    local sideDir = (sideComp >= 0) and perp or -perp
                    if Workspace:Raycast(hrp.Position, sideDir * (sideDist + 6), rp) then
                        sideDir = -sideDir
                    end
                    local dest = hrp.Position + sideDir * sideDist
                    if isOnOwnPlot(dest) then
                        local altDir = -sideDir
                        local altDest = hrp.Position + altDir * sideDist
                        if not isOnOwnPlot(altDest)
                           and not Workspace:Raycast(hrp.Position, altDir * (sideDist + 6), rp) then
                            dest = altDest
                        else
                            local fwdEsc = Vector3.new(
                                targetPart.Position.X - hrp.Position.X, 0,
                                targetPart.Position.Z - hrp.Position.Z)
                            if fwdEsc.Magnitude > 30 then
                                local fdir = fwdEsc.Unit
                                local fLen = math.min(60, fwdEsc.Magnitude - 25)
                                if fLen > 10 then
                                    local fDest = hrp.Position + fdir * fLen
                                    if not isOnOwnPlot(fDest)
                                       and not Workspace:Raycast(hrp.Position, fdir * (fLen + 4), rp) then
                                        flyToPosV2(hrp, hum, fDest, tweenSpeed, 6)
                                        local toBr2 = Vector3.new(
                                            targetPart.Position.X - hrp.Position.X, 0,
                                            targetPart.Position.Z - hrp.Position.Z)
                                        if toBr2.Magnitude > 0.01 then
                                            local f2 = toBr2.Unit
                                            local perp2 = Vector3.new(-f2.Z, 0, f2.X)
                                            local sd2 = (sideComp >= 0) and perp2 or -perp2
                                            if Workspace:Raycast(hrp.Position, sd2 * (sideDist + 6), rp) then
                                                sd2 = -sd2
                                            end
                                            local d2 = hrp.Position + sd2 * sideDist
                                            if not isOnOwnPlot(d2) then
                                                dest = d2
                                            else
                                                dest = nil
                                            end
                                        else
                                            dest = nil
                                        end
                                    else
                                        dest = nil
                                    end
                                else
                                    dest = nil
                                end
                            else
                                dest = nil
                            end
                        end
                    end
                    if dest then
                        flyToPosV2(hrp, hum, dest, tweenSpeed, 6)
                    end
                end
            end
        end
    end
    local initialPlayerPos = hrp.Position
    local medPoint = getNearestTeleportV2MedPoint(initialPlayerPos)
    if not medPoint then return false, "no MED point found" end
    local currentBrainrotPos = targetPart.Position
    local chosenPoint = getBestTeleportV2SecondFloorPoint(medPoint, currentBrainrotPos)
    if not chosenPoint then return false, "no TP1-TP12 point found" end
    local isFirstFloorBrainrot = currentBrainrotPos.Y <= 6.313370704650879
    local isFloor2 = currentBrainrotPos.Y > 10 and currentBrainrotPos.Y <= 25
    local floor2FromFloor1 = Config.AutoTPFloor2FromFloor1 and isFloor2
    local treatAsFloor1 = isFirstFloorBrainrot or floor2FromFloor1
    local chosenTargetPos = treatAsFloor1
        and Vector3.new(chosenPoint.pos.X, 1, chosenPoint.pos.Z)
        or chosenPoint.pos
    local signPart = getClosestBaseSignToPosition(chosenTargetPos) or getClosestBaseSign(targetPart)
    local faceVector = nil
    if signPart then
        faceVector = chosenPoint.facing == "front" and signPart.CFrame.LookVector or -signPart.CFrame.LookVector
        if faceVector.Magnitude <= 0 then faceVector = nil end
    end
    if faceVector then
        hrp.Velocity = Vector3.zero
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + faceVector)
        hrp.Velocity = Vector3.zero
    end
    local function finish(ok, msg)
        return ok, msg
    end
    hrp.Velocity = Vector3.zero
    local riseTargetY = 45
    if hum and hum.Parent then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    task.wait(0.01)
    if not hrp or not hrp.Parent then return finish(false, "hrp lost during jump start") end
    if useTween then
        local o = hrp.Position
        local rpr = RaycastParams.new()
        rpr.FilterType = Enum.RaycastFilterType.Exclude
        rpr.FilterDescendantsInstances = { LocalPlayer.Character }
        rpr.IgnoreWater = true
        pcall(function() rpr.RespectCanCollide = true end)
        local function isRouteBlocked(from, to)
            local baseY = math.min(from.Y, to.Y)
            local probeHeights = { baseY + 2, baseY + 6, baseY + 12, baseY + 20 }
            local hits = 0
            for _, py in ipairs(probeHeights) do
                local pa = Vector3.new(from.X, py, from.Z)
                local pb = Vector3.new(to.X, py, to.Z)
                if Workspace:Raycast(pa, pb - pa, rpr) then
                    hits = hits + 1
                end
            end
            return hits >= 2
        end
        local routeBlocked = isRouteBlocked(o, chosenTargetPos)
        if routeBlocked then
            local baseY  = math.max(o.Y, chosenTargetPos.Y)
            local clearY = baseY + 100
            for hAdd = 8, 100, 8 do
                local y  = baseY + hAdd
                local pa = Vector3.new(o.X, y, o.Z)
                local pb = Vector3.new(chosenTargetPos.X, y, chosenTargetPos.Z)
                if not Workspace:Raycast(pa, pb - pa, rpr) then
                    clearY = y + 12
                    break
                end
            end
            local outward
            if faceVector and (math.abs(faceVector.X) + math.abs(faceVector.Z)) > 0.01 then
                outward = Vector3.new(-faceVector.X, 0, -faceVector.Z)
                if outward.Magnitude > 0.01 then outward = outward.Unit end
            else
                local fwd = Vector3.new(chosenTargetPos.X - o.X, 0, chosenTargetPos.Z - o.Z)
                outward = (fwd.Magnitude > 0.01) and fwd.Unit or Vector3.new(1, 0, 0)
            end
            local outOffset = 30
            local outsidePos = Vector3.new(
                chosenTargetPos.X + outward.X * outOffset,
                clearY,
                chosenTargetPos.Z + outward.Z * outOffset
            )
            local dropPos = Vector3.new(
                outsidePos.X,
                chosenTargetPos.Y + 6,
                outsidePos.Z
            )
            flyToPosV2(hrp, hum, Vector3.new(o.X, clearY, o.Z), tweenSpeed, 6)
            if hrp and hrp.Parent then
                flyToPosV2(hrp, hum, outsidePos, tweenSpeed, 6)
            end
            if hrp and hrp.Parent then
                flyToPosV2(hrp, hum, dropPos, tweenSpeed, 6)
            end
            if hrp and hrp.Parent then
                flyToPosV2(hrp, hum, chosenTargetPos, tweenSpeed, 6)
            end
        else
            local peak = Vector3.new(
                o.X + (chosenTargetPos.X - o.X) * 0.5,
                math.max(o.Y, chosenTargetPos.Y) + 22,
                o.Z + (chosenTargetPos.Z - o.Z) * 0.5
            )
            flyToPosV2(hrp, hum, peak, tweenSpeed, 6)
            if hrp and hrp.Parent then
                flyToPosV2(hrp, hum, chosenTargetPos, tweenSpeed, 6)
            end
        end
        if not (hrp and hrp.Parent) then return finish(false, "hrp lost mid-route") end
        hrp.Velocity = Vector3.zero
        if faceVector then
            hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + faceVector)
        end
        hrp.Velocity = Vector3.zero
    else
        local medFlatPos = Vector3.new(medPoint.pos.X, hrp.Position.Y, medPoint.pos.Z)
        hrp.Velocity = Vector3.zero
        hrp.CFrame = faceVector and CFrame.new(medFlatPos, medFlatPos + faceVector) or CFrame.new(medFlatPos)
        hrp.Velocity = Vector3.zero
        task.wait(0.1)
        if not hrp or not hrp.Parent then return finish(false, "hrp lost after MED reposition") end
        local reachedMedPoint = waitUntilHeartbeat(function()
            return hrp and hrp.Parent and flatDistance(hrp.Position, medPoint.pos) <= 2.5
        end, 1.5)
        if not reachedMedPoint then return finish(false, "failed to reach MED point") end
        riseToY(hrp, riseTargetY)
        hrp.Velocity = Vector3.zero
        hrp.CFrame = faceVector and CFrame.new(chosenTargetPos, chosenTargetPos + faceVector) or CFrame.new(chosenTargetPos)
        hrp.Velocity = Vector3.zero
    end
    local reachedChosenPoint
    if treatAsFloor1 then
        reachedChosenPoint = waitUntilHeartbeat(function()
            if not (hrp and hrp.Parent) then return false end
            local dx = hrp.Position.X - chosenTargetPos.X
            local dz = hrp.Position.Z - chosenTargetPos.Z
            return math.sqrt(dx*dx + dz*dz) <= 4.5
        end, 4.5)
    else
        reachedChosenPoint = waitUntilHeartbeat(function()
            return hrp and hrp.Parent and (hrp.Position - chosenTargetPos).Magnitude <= 2.5
        end, 3.0)
    end
    if not reachedChosenPoint then return finish(false, "failed to reach TP1-TP12") end
    if treatAsFloor1 then
        waitUntilHeartbeat(function()
            return hum and hum.Parent and hum.FloorMaterial ~= Enum.Material.Air
        end, 1.25)
        waitSecondsHeartbeat(0.08)
        if hrp and hrp.Parent then
            hrp.Velocity = Vector3.zero
            hrp.Velocity = Vector3.zero
            local anchorPos = Vector3.new(chosenTargetPos.X, hrp.Position.Y, chosenTargetPos.Z)
            hrp.CFrame = faceVector and CFrame.new(anchorPos, anchorPos + faceVector) or CFrame.new(anchorPos)
            hrp.Velocity = Vector3.zero
        end
        waitSecondsHeartbeat(0.05)
    else
        waitSecondsHeartbeat(0.10)
        waitSecondsHeartbeat(0.05)
    end
    local stillAtChosenPoint
    if treatAsFloor1 then
        stillAtChosenPoint = waitUntilHeartbeat(function()
            if not (hrp and hrp.Parent) then return false end
            local dx = hrp.Position.X - chosenTargetPos.X
            local dz = hrp.Position.Z - chosenTargetPos.Z
            return math.sqrt(dx*dx + dz*dz) <= 4.5
        end, 0.75)
    else
        stillAtChosenPoint = waitUntilHeartbeat(function()
            return hrp and hrp.Parent and (hrp.Position - chosenTargetPos).Magnitude <= 2.5
        end, 0.75)
    end
    if not stillAtChosenPoint then return finish(false, "moved away from TP1-TP12 before clone") end
    if useTween then
        _G.ZawaHub_IgnoreStealRadius = true
        if _G.ZawaHub_SetAutoSteal then _G.ZawaHub_SetAutoSteal(true) end
        task.delay(4, function()
            _G.ZawaHub_IgnoreStealRadius = false
        end)
        task.spawn(function()
            local deadline = tick() + 4
            while tick() < deadline do
                if LocalPlayer:GetAttribute("Stealing") then
                    task.wait(0.5)
                    _G.ZawaHub_IgnoreStealRadius = false
                    return
                end
                task.wait(0.05)
            end
            _G.ZawaHub_IgnoreStealRadius = false
        end)
    end
    hrp.Velocity = Vector3.zero
    hrp.Velocity = Vector3.zero
    if not treatAsFloor1 and useTween then
        local snapPos = chosenTargetPos
        hrp.CFrame = faceVector
            and CFrame.new(snapPos, snapPos + faceVector)
            or  CFrame.new(snapPos)
        hrp.Velocity = Vector3.zero
        hrp.Velocity = Vector3.zero
        waitSecondsHeartbeat(0.05)
    end
    local cloneStartPos = hrp.Position
    instantCloneBestHubTp()
    local cloneMoved = waitUntilHeartbeat(function()
        return hrp and hrp.Parent and ((hrp.Position - cloneStartPos).Magnitude >= 0.35)
    end, treatAsFloor1 and 1.2 or 4.0)
    if not cloneMoved then
        if hrp and hrp.Parent then
            hrp.Velocity = Vector3.zero
            hrp.Velocity = Vector3.zero
            if treatAsFloor1 then
                local anchorPos = Vector3.new(chosenTargetPos.X, hrp.Position.Y, chosenTargetPos.Z)
                hrp.CFrame = faceVector and CFrame.new(anchorPos, anchorPos + faceVector) or CFrame.new(anchorPos)
            else
                hrp.CFrame = faceVector
                    and CFrame.new(chosenTargetPos, chosenTargetPos + faceVector)
                    or  CFrame.new(chosenTargetPos)
            end
            hrp.Velocity = Vector3.zero
        end
        waitSecondsHeartbeat(0.08)
        cloneStartPos = hrp.Position
        instantCloneBestHubTp()
        cloneMoved = waitUntilHeartbeat(function()
            return hrp and hrp.Parent and ((hrp.Position - cloneStartPos).Magnitude >= 0.35)
        end, 4.0)
    end
    if useTween and hrp and hrp.Parent and targetPart and targetPart.Parent then
        if cloneMoved then
            waitSecondsHeartbeat(0.15)
        else
            waitSecondsHeartbeat(0.08)
        end
        local goSpeed = 90
        local verticalDiff = targetPart.Position.Y - hrp.Position.Y
        if verticalDiff > 2 then
            local airPos = _clampRideY(Vector3.new(targetPart.Position.X, targetPart.Position.Y - 6, targetPart.Position.Z), targetPart)
            local plat = Instance.new("Part")
            plat.Name = "XiTempPlatform"
            plat.Size = Vector3.new(3, 1, 3)
            plat.Position = airPos - Vector3.new(0, 4, 0)
            plat.Color = Color3.new(1, 0, 0)
            plat.Material = Enum.Material.Neon
            plat.Anchored = true
            plat.CanCollide = true
            plat.Transparency = 0.3
            plat.Parent = Workspace
            RunService.Heartbeat:Wait()
            flyToPosV2(hrp, hum, airPos, goSpeed, 1)
            task.spawn(function()
                local start = tick()
                while tick() - start < 20 do
                    if LocalPlayer:GetAttribute("Stealing") then break end
                    task.wait(0.1)
                end
                if plat and plat.Parent then plat:Destroy() end
            end)
        else
            local reachPos = _clampRideY(targetPart.Position, targetPart)
            flyToPosV2(hrp, hum, reachPos, goSpeed, 1)
        end
    else
        if cloneMoved then
            waitSecondsHeartbeat(0.15)
        else
            waitSecondsHeartbeat(0.08)
        end
    end
    return finish(true, chosenPoint.name)
end
local function runBestHubTeleport(useSideTp, useTween)
    if State.isTpMoving then return end
    local startDelay = Config.AutoTPStartDelay or 0.5
    if startDelay > 0 then task.wait(startDelay) end
    local targetPetData = pickTpTarget()
    if not targetPetData then ShowNotification("ERROR", "No target selected!"); return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    State.isTpMoving = true
    local _autoStealWasOn = _G.ZawaHub_GetAutoSteal and _G.ZawaHub_GetAutoSteal()
    if useSideTp and useTween and _autoStealWasOn and _G.ZawaHub_SetAutoSteal then
        _G.ZawaHub_SetAutoSteal(false)
    end
    local ok, err = pcall(function()
        local targetPart = findAdorneeGlobal(targetPetData)
        if not targetPart then error("targetPart nil") end
        local exactPos = targetPart.Position
        local carpetName = Config.TpSettings.Tool
        local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
        local cloner = LocalPlayer.Backpack:FindFirstChild("Quantum Cloner") or char:FindFirstChild("Quantum Cloner")
        equipTpToolAndWait(hum)
        local isSecondFloor = exactPos.Y > 10
        local isFloor2 = exactPos.Y > 10 and exactPos.Y <= 25
        local floor2FromFloor1 = Config.AutoTPFloor2FromFloor1 and isFloor2
        if floor2FromFloor1 then isSecondFloor = false end
        if useSideTp then
            char = LocalPlayer.Character
            hrp = char and char:FindFirstChild("HumanoidRootPart")
            hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hrp.Parent then error("hrp lost before Side TP") end
            if not hum or hum.Health <= 0 then error("hum dead before Side TP") end
            targetPart = findAdorneeGlobal(targetPetData)
            if not targetPart or not targetPart.Parent then error("targetPart nil before Side TP") end
            local okV2, errV2 = runTeleportV2SecondFloor(targetPart, hum, hrp, useTween)
            if not okV2 then error("Side TP failed: " .. tostring(errV2)) end
        else
            local signPart = getClosestBaseSign(targetPart)
            if not signPart then error("signPart nil") end
            local signCF = signPart.CFrame
            local LEFT = -signCF.RightVector
            local FORWARD = signCF.LookVector
            local BACK = -signCF.LookVector
            local medPoint = getNearestTeleportV2MedPoint(hrp.Position)
            if not medPoint then error("normal tp MED point nil") end
            hrp.Velocity = Vector3.zero
            if hum and hum.Parent then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            task.wait(0.01)
            if not hrp or not hrp.Parent then error("hrp lost during normal jump start") end
            hrp.CFrame = CFrame.new(-409, 23, hrp.Position.Z)
            task.wait(0.1)
            if not hrp or not hrp.Parent then error("hrp lost after normal jump reposition") end
            riseToY(hrp, 40)
            local tpPos
            if exactPos.Y <= 6.313370704650879 then
                local frontPoint = signPart.Position + (FORWARD * 20)
                local backPoint = signPart.Position + (BACK * 20)
                local myPos = hrp.Position
                local distFront = (Vector3.new(frontPoint.X, 0, frontPoint.Z) - Vector3.new(myPos.X, 0, myPos.Z)).Magnitude
                local distBack = (Vector3.new(backPoint.X, 0, backPoint.Z) - Vector3.new(myPos.X, 0, myPos.Z)).Magnitude
                local chosen = (distFront < distBack) and frontPoint or backPoint
                tpPos = Vector3.new(chosen.X, -4.8, chosen.Z)
            else
                local backPoint = signPart.Position + (BACK * 15)
                local frontPoint = signPart.Position + (FORWARD * 15)
                local myPos = hrp.Position
                local myFlat = Vector3.new(myPos.X, 0, myPos.Z)
                local distBack = (Vector3.new(backPoint.X, 0, backPoint.Z) - myFlat).Magnitude
                local distFront = (Vector3.new(frontPoint.X, 0, frontPoint.Z) - myFlat).Magnitude
                local chosen = (distBack < distFront) and backPoint or frontPoint
                tpPos = Vector3.new(chosen.X, signPart.Position.Y + 4, chosen.Z)
            end
            hrp.Velocity = Vector3.zero
            hrp.CFrame = CFrame.lookAt(tpPos, tpPos + LEFT)
            hrp.Velocity = Vector3.zero
            waitUntilHeartbeat(function()
                return hrp and hrp.Parent
                    and (hrp.Position - tpPos).Magnitude <= 2
                    and hum
                    and hum.FloorMaterial ~= Enum.Material.Air
            end, 3.0)
            if isSecondFloor or not _G._isTargetPlotUnlocked(targetPetData.plot) then
                prepMiniTpTool(hum, hrp)
                waitSecondsHeartbeat(0.05)
                if isSecondFloor then
                    hrp.Velocity = Vector3.zero
                    waitSecondsHeartbeat(0.01)
                    hrp.Velocity = Vector3.zero
                    hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -2.5)
                    hrp.Velocity = Vector3.zero
                else
                    hrp.Velocity = Vector3.zero
                    hrp.Velocity = Vector3.zero
                    waitSecondsHeartbeat(0.03)
                    walkForward(0.15)
                end
                waitSecondsHeartbeat(0.07)
                local miniPos = hrp.Position
                waitSecondsHeartbeat(0.01)
                local stillAtMiniPos = waitUntilHeartbeat(function()
                    return hrp and hrp.Parent and (hrp.Position - miniPos).Magnitude <= 2.0
                end, 0.75)
                if not stillAtMiniPos then error("moved away from mini TP position before clone") end
                hrp.Velocity = Vector3.zero
                hrp.Velocity = Vector3.zero
                instantCloneBestHubTp()
                waitUntilHeartbeat(function()
                    return hrp and hrp.Parent and ((hrp.Position - miniPos).Magnitude >= 0.35)
                end, 4.0)
                local dl = tick() + 2
                while _G.isCloning and tick() < dl do task.wait() end
            end
        end
        task.wait(0.15)
        equipTpToolAndWait(hum)
        local skipPostClone = useSideTp and useTween
        local verticalDiff = targetPart.Position.Y - hrp.Position.Y
        if skipPostClone then
        elseif floor2FromFloor1 then
            local airPos = Vector3.new(targetPart.Position.X, 3, targetPart.Position.Z)
            local plat = Instance.new("Part")
            plat.Name = "XiTempPlatform"
            plat.Size = Vector3.new(3, 1, 3)
            plat.Position = airPos - Vector3.new(0, 4, 0)
            plat.Color = Color3.new(1, 0, 0)
            plat.Material = Enum.Material.Neon
            plat.Anchored = true
            plat.CanCollide = true
            plat.Transparency = 0.3
            plat.Parent = Workspace
            RunService.Heartbeat:Wait()
            for i = 1, 10 do
                if not LocalPlayer:GetAttribute("Stealing") then
                    hrp.Velocity = Vector3.zero
                    hrp.CFrame = CFrame.new(airPos)
                    task.wait(0.05)
                end
            end
            task.spawn(function()
                local start = tick()
                while tick() - start < 20 do
                    if LocalPlayer:GetAttribute("Stealing") then break end
                    task.wait(0.1)
                end
                plat:Destroy()
            end)
        elseif verticalDiff > 2 then
            local airPos = _clampRideY(Vector3.new(targetPart.Position.X, targetPart.Position.Y - 4, targetPart.Position.Z), targetPart)
            local plat = Instance.new("Part")
            plat.Name = "XiTempPlatform"
            plat.Size = Vector3.new(3, 1, 3)
            plat.Position = airPos - Vector3.new(0, 4, 0)
            plat.Color = Color3.new(1, 0, 0)
            plat.Material = Enum.Material.Neon
            plat.Anchored = true
            plat.CanCollide = true
            plat.Transparency = 0.3
            plat.Parent = Workspace
            RunService.Heartbeat:Wait()
            for i = 1, 10 do
                if not LocalPlayer:GetAttribute("Stealing") then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                    hrp.CFrame = CFrame.new(airPos)
                    task.wait(0.05)
                end
            end
            task.spawn(function()
                local start = tick()
                while tick() - start < 20 do
                    if LocalPlayer:GetAttribute("Stealing") then break end
                    task.wait(0.1)
                end
                plat:Destroy()
            end)
        else
            local reachPos = _clampRideY(targetPart.Position, targetPart)
            for i = 1, 10 do
                if LocalPlayer:GetAttribute("Stealing") then break end
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                if (hrp.Position - reachPos).Magnitude > 3 then
                    hrp.CFrame = CFrame.new(reachPos)
                    task.wait(0.05)
                end
                task.wait(0.05)
            end
        end
    end)
    State.isTpMoving = false
    if useSideTp and useTween and _autoStealWasOn then
        _G.ZawaHub_IgnoreStealRadius = false
        if not (_G.ZawaHub_GetAutoSteal and _G.ZawaHub_GetAutoSteal()) then
            if _G.ZawaHub_SetAutoSteal then _G.ZawaHub_SetAutoSteal(true) end
        end
    end
    if not ok then
        warn(useSideTp and "runAutoSnipeV2 error:" or "runAutoSnipe error:", err)
    end
end
local function runAutoSnipeV2()
    return runBestHubTeleport(true)
end
_G.runAutoSnipeV2 = runAutoSnipeV2
local function dispatchTp()
    if Config.TweenTpV3Mode then
        task.spawn(function() runAutoSnipeAdminV1(true) end)
        return
    end
    if Config.TweenTpSideMode then
        task.spawn(function() runBestHubTeleport(true, true) end)
        return
    end
    task.spawn(runAutoSnipe)
end
_G.dispatchTp = dispatchTp
if Config.TpSettings.TpOnLoad then
    task.spawn(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            char:WaitForChild("HumanoidRootPart", 30)
        end
        local t = 0
        while not (SharedState and SharedState.InitialScanComplete) and t < 600 do
            task.wait(0.025)
            t = t + 1
        end
        if not (SharedState and SharedState.InitialScanComplete) then
            noPriorityFallback("TIMEOUT - scanner did not initialize")
            return
        end
        local function findPriorityInCache()
            local cache = (SharedState and SharedState.AllAnimalsCache) or {}
            for _, pName in ipairs(PRIORITY_LIST) do
                local searchName = pName:lower()
                for _, a in ipairs(cache) do
                    if a and a.name and a.uid
                        and a.owner ~= LocalPlayer.Name
                        and a.name:lower() == searchName then
                        return a
                    end
                end
            end
            return nil
        end
        local chosen = nil
        local pollT = 0
        local pollMax = 50
        repeat
            chosen = findPriorityInCache()
            if chosen then break end
            task.wait(0.01)
            pollT = pollT + 1
        until chosen or pollT >= pollMax
        if chosen then
            showBigAlert(tostring(chosen.name) .. " detected")
        else
            noPriorityFallback("No priority brainrots detected")
            return
        end
        _G._tpLoadTarget = chosen
        SharedState.SelectedPetData = { animalData = chosen }
        _G._tpLoadOverride = true
        if Config.TweenTpV3Mode then
            task.spawn(function() runAutoSnipeAdminV1(true) end)
        elseif Config.TweenTpSideMode then
            task.spawn(function() runBestHubTeleport(true, true) end)
        else
            runAutoSnipe()
        end
        task.delay(5, function()
            _G._tpLoadOverride = false
            _G._tpLoadTarget = nil
        end)
    end)
end
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    local tpKey         = Enum.KeyCode[Config.TpSettings.TpKey]         or Enum.KeyCode.T
    local cloneKey      = Enum.KeyCode[Config.TpSettings.CloneKey]      or Enum.KeyCode.V
    if input.KeyCode == tpKey then
        if Config.TweenTpV3Mode then
            task.spawn(function() runAutoSnipeAdminV1(true) end)
        elseif Config.TweenTpSideMode then
            task.spawn(function() runBestHubTeleport(true, true) end)
        else
            runAutoSnipe()
        end
    elseif input.KeyCode == cloneKey then
        instantClone(pickCloneSpeed(), true)
    end
end)
task.spawn(function()
    local balloonPhrase = 'ran "balloon" on you'
    local sawBalloon = false
    while true do
        task.wait(1)
        if not Config.AutoResetOnBalloon then
            sawBalloon = false
            continue
        end
        local found = false
        for _, gui in ipairs(PlayerGui:GetDescendants()) do
            local txt = (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Text
            if txt and string.find(txt, balloonPhrase) then
                found = true
                break
            end
        end
        if found and not sawBalloon then
            executeReset()
        end
        sawBalloon = found
    end
end)
_G.autoKickEnabled = Config.AutoKickOnSteal
_G.autoKickEnabledTime = tick()
task.spawn(function()
    local kickTriggered = false
    local seenTexts = {}
    local function checkTextForSteal(gui)
        if kickTriggered or not _G.autoKickEnabled then return end
        if not gui:IsA("TextLabel") and not gui:IsA("TextButton") then return end
        if not gui.Text or gui.Text == "" then return end
        local text = gui.Text:lower()
        if text:find("you%s+stole%s+") then
            local uniqueId = gui:GetDebugId() .. "_" .. gui.Text
            if not seenTexts[uniqueId] then
                seenTexts[uniqueId] = tick()
                if tick() > _G.autoKickEnabledTime then
                    kickTriggered = true
                    local stolenName = gui.Text:match("[Yy]ou%s+stole%s+(.+)") or "something"
                    stolenName = stolenName:gsub("<[^>]+>", "")
                    stolenName = stolenName:gsub("%s*%([Ee]rror%s+[Cc]ode:?%s*%d+%)%s*", "")
                    stolenName = stolenName:match("^%s*(.-)%s*$")
                    _G.KICK_IN_PROGRESS = true
                    task.wait(0.001)
                    LocalPlayer:Kick("You have successfully stolen " .. stolenName)
                    if not IS_MOBILE then
                        task.delay(0.00001, function() game:Shutdown() end)
                    end
                end
            end
        end
    end
    PlayerGui.DescendantAdded:Connect(function(gui)
        if kickTriggered or not _G.autoKickEnabled then return end
        pcall(function() checkTextForSteal(gui) end)
    end)
    task.spawn(function()
        for _, gui in ipairs(PlayerGui:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                pcall(function()
                    gui:GetPropertyChangedSignal("Text"):Connect(function()
                        if kickTriggered or not _G.autoKickEnabled then return end
                        pcall(function() checkTextForSteal(gui) end)
                    end)
                end)
            end
        end
    end)
    PlayerGui.DescendantAdded:Connect(function(gui)
        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
            pcall(function()
                gui:GetPropertyChangedSignal("Text"):Connect(function()
                    if kickTriggered or not _G.autoKickEnabled then return end
                    pcall(function() checkTextForSteal(gui) end)
                end)
            end)
        end
    end)
end)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    local cloneKey = Enum.KeyCode[Config.TpSettings.CloneKey] or Enum.KeyCode.V
    if input.KeyCode == cloneKey then
        local _isHP_kb = getPingMult() > 1
        local cloneSpeed_kb = _isHP_kb and (Config.Floor1InstantCloneSpeedHP or 0.1) or (Config.Floor1InstantCloneSpeed or 0.05)
        instantClone(cloneSpeed_kb, true) 
    end
    if input.KeyCode == (Enum.KeyCode[Config.TpSettings.CarpetSpeedKey] or Enum.KeyCode.Q) then
        carpetSpeedEnabled = not carpetSpeedEnabled
        setCarpetSpeed(carpetSpeedEnabled)
        if _carpetStatusLabel then
            _carpetStatusLabel.Text = carpetSpeedEnabled and "ON" or "OFF"
            _carpetStatusLabel.TextColor3 = carpetSpeedEnabled and Theme.Success or Theme.Error
        end
        ShowNotification("CARPET SPEED", carpetSpeedEnabled and ("ON  |  "..Config.TpSettings.Tool.."  |  140") or "OFF")
    end
    if input.KeyCode == (Enum.KeyCode[Config.StealSpeedKey] or Enum.KeyCode.Z) then
        if SharedState.StealSpeedToggleFunc then
            SharedState.StealSpeedToggleFunc()
        end
    end
    if input.KeyCode == (Enum.KeyCode[Config.RagdollSelfKey] or Enum.KeyCode.R) then
        task.spawn(function()
            if _G.runAdminCommand then
                if _G.runAdminCommand(LocalPlayer, "ragdoll") then
                    if _G._ZawaHub_MarkSelfRagdoll then _G._ZawaHub_MarkSelfRagdoll() end
                    ShowNotification("RAGDOLL SELF", "Triggered")
                else
                    ShowNotification("RAGDOLL SELF", "Failed")
                end
            else
                ShowNotification("RAGDOLL SELF", "Function not available")
            end
        end)
    end
end)
local settingsGui = UI.settingsGui
if IS_MOBILE then
    local mobileGui = Instance.new("ScreenGui")
    mobileGui.Name = "XiMobileControls"
    mobileGui.ResetOnSpawn = false
    mobileGui.Parent = PlayerGui
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(0, 50, 0, 260)
    controlsFrame.Position = UDim2.new(1, -60, 0.5, -130)
    controlsFrame.BackgroundColor3 = Theme.Background
    controlsFrame.BackgroundTransparency = 0.2
    controlsFrame.BorderSizePixel = 0
    controlsFrame.Parent = mobileGui
    ApplyViewportUIScale(controlsFrame, 50, 260, 0.6, 1)
    Instance.new("UICorner", controlsFrame).CornerRadius = UDim.new(0, 10)
    local cStroke = Instance.new("UIStroke", controlsFrame)
    cStroke.Color = Theme.Accent1
    cStroke.Thickness = 1.5
    cStroke.Transparency = 0.4
    MakeDraggable(controlsFrame, controlsFrame, "MobileControls")
    local layout = Instance.new("UIListLayout", controlsFrame)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    local function createMobBtn(text, color, layoutOrder, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 40, 0, 40)
        btn.BackgroundColor3 = Theme.SurfaceHighlight
        btn.Text = text
        btn.TextColor3 = Theme.TextPrimary
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 14
        btn.LayoutOrder = layoutOrder
        btn.Parent = mobileGui 
        local posKey = "MobileBtn_" .. text
        if Config.Positions[posKey] then
            btn.Position = UDim2.new(Config.Positions[posKey].X, 0, Config.Positions[posKey].Y, 0)
        else
            local angle = (layoutOrder - 1) * (math.pi * 2 / 5) - math.pi/2
            local radius = 60
            btn.Position = UDim2.new(0.5, math.cos(angle) * radius - 20, 0.5, math.sin(angle) * radius - 20)
        end
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = color
        stroke.Thickness = 1
        stroke.Transparency = 1
        MakeDraggable(btn, btn, "MobileBtn_" .. text)
        btn.MouseButton1Click:Connect(function()
            local oldColor = btn.BackgroundColor3
            btn.BackgroundColor3 = color
            task.delay(0.1, function() btn.BackgroundColor3 = oldColor end)
            callback(btn)
        end)
        return btn
    end
    createMobBtn("CL", Theme.Accent2, 2, function()
        local _isHP_mob = getPingMult() > 1
        local cloneSpeed_mob = _isHP_mob and (Config.Floor1InstantCloneSpeedHP or 0.1) or (Config.Floor1InstantCloneSpeed or 0.05)
        instantClone(cloneSpeed_mob)
        ShowNotification("MOBILE", "Cloning...")
    end)
    createMobBtn("SP", Theme.Success, 3, function(self)
        carpetSpeedEnabled = not carpetSpeedEnabled
        setCarpetSpeed(carpetSpeedEnabled)
        self.TextColor3 = carpetSpeedEnabled and Theme.Success or Theme.TextPrimary
        ShowNotification("MOBILE", carpetSpeedEnabled and "Speed ON" or "Speed OFF")
    end)
    createMobBtn("UI", Color3.fromRGB(255, 255, 255), 4, function()
        local asUI = PlayerGui:FindFirstChild("AutoStealUI")
        if asUI then asUI.Enabled = not asUI.Enabled end
        local adUI = PlayerGui:FindFirstChild("XiAdminPanel")
        if adUI then adUI.Enabled = not adUI.Enabled end
    end)
    local resetBtn = Instance.new("TextButton")
    resetBtn.Name = "MobileResetButton"
    resetBtn.Size = UDim2.new(0, 42, 0, 42)
    resetBtn.Position = UDim2.new(1, -58, 1, -105)
    resetBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
    resetBtn.AutoButtonColor = false
    resetBtn.Text = "ðŸ”§"
    resetBtn.Font = Enum.Font.GothamBlack
    resetBtn.TextSize = 20
    resetBtn.TextColor3 = Color3.new(0, 0, 0)
    resetBtn.Parent = mobileGui
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(1, 0)
    local resetStroke = Instance.new("UIStroke", resetBtn)
    resetStroke.Color = Color3.fromRGB(255, 100, 0)
    resetStroke.Thickness = 1.5
    resetStroke.Transparency = 0.25
    MakeDraggable(resetBtn, resetBtn)
    resetBtn.MouseButton1Click:Connect(function()
        Config.Positions = {
            AdminPanel = {X = 0.1859375, Y = 0.5767123526556385}, 
            StealSpeed = {X = 0.02, Y = 0.18}, 
            Settings = {X = 0.834375, Y = 0.43590998043052839}, 
            InvisPanel = {X = 0.8578125, Y = 0.17260276361454258}, 
            AutoSteal = {X = 0.02, Y = 0.35}, 
            MobileControls = {X = 0.9, Y = 0.4},
            MobileBtn_TP = {X = 0.5, Y = 0.4},
            MobileBtn_CL = {X = 0.5, Y = 0.4},
            MobileBtn_SP = {X = 0.5, Y = 0.4},
            MobileBtn_IV = {X = 0.5, Y = 0.4},
            MobileBtn_UI = {X = 0.5, Y = 0.4},
        }
        Config.MobileGuiScale = 0.5
        SaveConfig()
        if SharedState.RefreshMobileScale then SharedState.RefreshMobileScale() end
        if mobileGui then
            mobileGui.Position = UDim2.new(Config.Positions.MobileControls.X, 0, Config.Positions.MobileControls.Y, 0)
        end
        ShowNotification("RESET", "All GUI positions and scale reset")
    end)
    local openBtn = Instance.new("TextButton")
    openBtn.Name = "MobileSettingsButton"
    openBtn.Size = UDim2.new(0, 42, 0, 42)
    openBtn.Position = UDim2.new(1, -58, 1, -58)
    openBtn.BackgroundColor3 = Theme.Accent1
    openBtn.AutoButtonColor = false
    openBtn.Text = "âš™"
    openBtn.Font = Enum.Font.GothamBlack
    openBtn.TextSize = 20
    openBtn.TextColor3 = Color3.new(0, 0, 0)
    openBtn.Parent = mobileGui
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
    local openStroke = Instance.new("UIStroke", openBtn)
    openStroke.Color = Theme.Accent2
    openStroke.Thickness = 1.5
    openStroke.Transparency = 0.25
    MakeDraggable(openBtn, openBtn)
    openBtn.MouseButton1Click:Connect(function()
        if settingsGui then
            settingsGui.Enabled = not settingsGui.Enabled
        end
        if SharedState.RefreshMobileScale then
            SharedState.RefreshMobileScale()
        end
    end)
end
settingsGui = Instance.new("ScreenGui")
settingsGui.Name = "SettingsUI"; settingsGui.ResetOnSpawn = false
settingsGui.Parent = PlayerGui; settingsGui.Enabled = false
local espToggleRef = {enabled=true, setFn=nil}
local playerESPToggleRef = {setFn=nil}
local subspaceMineESPToggleRef = {setFn=nil}
task.spawn(function() 
do
    RunService.Heartbeat:Wait()
end
local sFrame = Instance.new("Frame")
sFrame.Size = UDim2.new(0, 380, 0, 420)
sFrame.Position = UDim2.new(Config.Positions.Settings.X, 0, Config.Positions.Settings.Y, 0)
sFrame.BackgroundColor3 = Theme.Background; sFrame.BackgroundTransparency = 0.15
sFrame.BorderSizePixel = 0; sFrame.ClipsDescendants = true; sFrame.Parent = settingsGui
ApplyViewportUIScale(sFrame, 380, 420, 0.45, 0.85)
AddMobileMinimize(sFrame, "SETTINGS")
Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 12)
local sStroke = Instance.new("UIStroke", sFrame)
sStroke.Color = Theme.Accent2; sStroke.Thickness = 2; sStroke.Transparency = 0.1
CreateGradient(sStroke)
local sHeader = Instance.new("Frame", sFrame)
sHeader.Size = UDim2.new(1,0,0,40); sHeader.BackgroundTransparency = 1
MakeDraggable(sHeader, sFrame, "Settings")
AddResizeHandle(sFrame, "Settings", UDim2.new(1, -22, 0, 6))
local sTitle = Instance.new("TextLabel", sHeader)
sTitle.Size = UDim2.new(1,-20,1,0); sTitle.Position = UDim2.new(0,15,0,0)
sTitle.BackgroundTransparency = 1; sTitle.Text = "✦ HEROZ ✦"
sTitle.Font = Enum.Font.GothamBlack; sTitle.TextSize = 18
sTitle.TextColor3 = Theme.TextPrimary; sTitle.TextXAlignment = Enum.TextXAlignment.Left
local TAB_DEFS = {
    {key = "Main",   label = "Main"},
    {key = "AutoTP", label = "Auto TP"},
    {key = "ESP",    label = "ESP"},
    {key = "Steal",  label = "Steal"},
    {key = "UI",     label = "UI"},
    {key = "Misc",   label = "Misc"},
    {key = "Keys",   label = "Keys"},
}
local SECTION_TO_TAB = {
    ["Auto TP"]               = "AutoTP",
    ["CARPET SPEED"]          = "AutoTP",
    ["MOVEMENT"]              = "AutoTP",
    ["ESP"]                   = "ESP",
    ["AUTO STEAL DEFAULTS"]   = "Steal",
    ["AUTO UNLOCK"]           = "Misc",
    ["ANTI-RAGDOLL"]          = "Misc",
    ["AUTOMATION"]            = "Misc",
    ["EXTRAS"]                = "Misc",
    ["ALERTS"]                = "Misc",
    ["JOB JOINER"]            = "Misc",
    ["PROTECTION"]            = "Misc",
    ["CAMERA"]                = "Misc",
    ["ADMIN PANEL"]           = "Misc",
    ["HIDE GUIS"]             = "UI",
    ["UI CONTROLS"]           = "UI",
    ["MENU"]                  = "Keys",
}
local tabBar = Instance.new("Frame", sFrame)
tabBar.Size = UDim2.new(1, -20, 0, 32)
tabBar.Position = UDim2.new(0, 10, 0, 44)
tabBar.BackgroundColor3 = Theme.Surface
tabBar.BorderSizePixel = 0
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 8)
local tabBarPad = Instance.new("UIPadding", tabBar)
tabBarPad.PaddingLeft = UDim.new(0, 4); tabBarPad.PaddingRight = UDim.new(0, 4)
tabBarPad.PaddingTop  = UDim.new(0, 4); tabBarPad.PaddingBottom = UDim.new(0, 4)
local tabBarLayout = Instance.new("UIListLayout", tabBar)
tabBarLayout.FillDirection = Enum.FillDirection.Horizontal
tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabBarLayout.Padding = UDim.new(0, 2)
local tabContent = Instance.new("Frame", sFrame)
tabContent.Size = UDim2.new(1, -20, 1, -90)
tabContent.Position = UDim2.new(0, 10, 0, 82)
tabContent.BackgroundTransparency = 1
tabContent.BorderSizePixel = 0
local tabPages = {}
local activeTabKey = "Main"
local function makeTabPage(key)
    local sf = Instance.new("ScrollingFrame", tabContent)
    sf.Name = "Tab_" .. key
    sf.Size = UDim2.new(1, 0, 1, 0); sf.Position = UDim2.new(0, 0, 0, 0)
    sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 2; sf.ScrollBarImageColor3 = Theme.Accent1
    sf.Visible = (key == activeTabKey)
    if IS_MOBILE then
        sf.ScrollBarThickness = 6
        sf.ScrollingEnabled = true
        sf.ElasticBehavior = Enum.ElasticBehavior.Always
    end
    local lay = Instance.new("UIListLayout", sf)
    lay.Padding = UDim.new(0, 8); lay.SortOrder = Enum.SortOrder.LayoutOrder
    return {Frame = sf, Layout = lay}
end
for _, def in ipairs(TAB_DEFS) do
    tabPages[def.key] = makeTabPage(def.key)
end
local tabButtons = {}
local function setActiveTab(key)
    if not tabPages[key] then return end
    activeTabKey = key
    for k, page in pairs(tabPages) do
        page.Frame.Visible = (k == key)
    end
    for k, btn in pairs(tabButtons) do
        local on = (k == key)
        btn.BackgroundColor3 = on and Theme.Accent1 or Color3.fromRGB(0,0,0)
        btn.BackgroundTransparency = on and 0 or 1
        btn.TextColor3 = on and Color3.fromRGB(255,255,255) or Theme.TextSecondary
    end
end
for i, def in ipairs(TAB_DEFS) do
    local b = Instance.new("TextButton", tabBar)
    b.LayoutOrder = i
    b.Size = UDim2.new(0, 0, 1, 0)
    b.AutomaticSize = Enum.AutomaticSize.X
    b.BackgroundColor3 = Theme.Accent1
    b.BackgroundTransparency = 1
    b.BorderSizePixel = 0
    b.Text = def.label
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.TextColor3 = Theme.TextSecondary
    local pad = Instance.new("UIPadding", b)
    pad.PaddingLeft = UDim.new(0, 7); pad.PaddingRight = UDim.new(0, 7)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function() setActiveTab(def.key) end)
    tabButtons[def.key] = b
end
local currentTabKey = "Main"
local function getActiveList() return tabPages[currentTabKey].Frame end
local function switchTab(key)
    if tabPages[key] then currentTabKey = key end
end
local sList = tabPages["Main"].Frame
local sLayout = tabPages["Main"].Layout
setActiveTab("Main")
local function CreateToggleSwitch(parent, initialState, callback)
    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0,40,0,20); sw.Position = UDim2.new(1,-50,0.5,-10)
    sw.BackgroundColor3 = initialState and Theme.Success or Theme.SurfaceHighlight
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1,0); sw.Parent = parent
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,16,0,16)
    dot.Position = initialState and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0); dot.Parent = sw
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1; btn.Text = ""; btn.Parent = sw
    local isOn = initialState
    local function SetState(s)
        isOn = s
        local tp = isOn and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
        local tc = isOn and Theme.Success or Theme.SurfaceHighlight
        TweenService:Create(dot, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Position=tp}):Play()
        TweenService:Create(sw,  TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundColor3=tc}):Play()
    end
    btn.MouseButton1Click:Connect(function() callback(not isOn, SetState) end)
    return {Set=SetState, Container=sw}
end
local function CreateRow(text, height)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,height or 34); row.BackgroundColor3 = Theme.Surface
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.6,0,1,0); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = text
    lbl.Font = Enum.Font.GothamMedium; lbl.TextColor3 = Theme.TextPrimary
    lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left
    row.Parent = getActiveList(); return row
end
local function CreateSectionHeader(text)
    local mappedTab = SECTION_TO_TAB[text]
    if mappedTab then
        currentTabKey = mappedTab
    end
    local TABS_THAT_SHOW_HEADERS = {AutoTP=true, Misc=true, UI=true, Keys=true}
    if not TABS_THAT_SHOW_HEADERS[currentTabKey] then
        return Instance.new("Frame") 
    end
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundTransparency = 1
    row.Parent = getActiveList()
    local accent = Instance.new("Frame", row)
    accent.Size = UDim2.new(0, 3, 0, 16)
    accent.Position = UDim2.new(0, 4, 0.5, -8)
    accent.BackgroundColor3 = Theme.Accent1
    accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Accent1
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local line = Instance.new("Frame", row)
    line.Size = UDim2.new(1, -80, 0, 1)
    line.Position = UDim2.new(0, 75, 0.5, 0)
    line.BackgroundColor3 = Theme.Accent1
    line.BackgroundTransparency = 0.7
    line.BorderSizePixel = 0
    return row
end
switchTab("Main")
local rFPS = CreateRow("FPS Boost")
CreateToggleSwitch(rFPS, Config.FPSBoost, function(ns, set)
    set(ns); setFPSBoost(ns)
    ShowNotification("FPS BOOST", ns and "ENABLED" or "DISABLED")
end)
local rFPSDark = CreateRow("FPS Boost: Dark Mode")
CreateToggleSwitch(rFPSDark, Config.FPSBoostDarkMode, function(ns, set)
    set(ns); Config.FPSBoostDarkMode = ns; SaveConfig()
    pcall(function()
        if ns then
            ApplyDarkModeLighting()
        else
            Lighting.Brightness               = OriginalLighting.Brightness
            Lighting.Ambient                  = OriginalLighting.Ambient
            Lighting.OutdoorAmbient           = OriginalLighting.OutdoorAmbient
            Lighting.ClockTime                = OriginalLighting.ClockTime
            Lighting.FogEnd                   = OriginalLighting.FogEnd
            Lighting.FogStart                 = OriginalLighting.FogStart
            Lighting.GlobalShadows            = OriginalLighting.GlobalShadows
            Lighting.EnvironmentDiffuseScale  = OriginalLighting.EnvironmentDiffuseScale
            Lighting.EnvironmentSpecularScale = OriginalLighting.EnvironmentSpecularScale
        end
    end)
    ShowNotification("FPS BOOST DARK MODE", ns and "ENABLED" or "DISABLED")
end)
do
    local DARK_STEP = 0.1
    local DARK_MIN  = 0
    local DARK_MAX  = 1.5
    local rDarkBright = CreateRow("Dark Mode Brightness", 44)
    local sub = Instance.new("TextLabel", rDarkBright)
    sub.Size = UDim2.new(1, -130, 0, 12)
    sub.Position = UDim2.new(0, 14, 0, 26)
    sub.BackgroundTransparency = 1
    sub.Text = "Step 0.1 · 0 = pitch black, 1.5 = base game"
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 9
    sub.TextColor3 = Color3.fromRGB(180, 130, 160)
    sub.TextXAlignment = Enum.TextXAlignment.Left
    local controls = Instance.new("Frame", rDarkBright)
    controls.Size = UDim2.new(0, 110, 0, 22)
    controls.Position = UDim2.new(1, -120, 0.5, -11)
    controls.BackgroundTransparency = 1
    local function makeStepBtn(label, xPos)
        local b = Instance.new("TextButton", controls)
        b.Size = UDim2.new(0, 22, 0, 22)
        b.Position = UDim2.new(0, xPos, 0, 0)
        b.BackgroundColor3 = Color3.fromRGB(35, 8, 8)
        b.BorderSizePixel = 0
        b.Text = label
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        b.TextColor3 = Color3.fromRGB(255, 220, 220)
        b.AutoButtonColor = false
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        local s = Instance.new("UIStroke", b)
        s.Color = Color3.fromRGB(200, 20, 20)
        s.Thickness = 1
        b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(70, 25, 50) end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(35, 8, 8) end)
        return b
    end
    local minusBtn = makeStepBtn("−", 0)
    local plusBtn  = makeStepBtn("+", 88)
    local valueLbl = Instance.new("TextLabel", controls)
    valueLbl.Size = UDim2.new(0, 62, 0, 22)
    valueLbl.Position = UDim2.new(0, 24, 0, 0)
    valueLbl.BackgroundColor3 = Color3.fromRGB(30, 12, 24)
    valueLbl.BorderSizePixel = 0
    valueLbl.Text = string.format("%.2f", Config.DarkModeBrightness or 0.3)
    valueLbl.Font = Enum.Font.GothamBold
    valueLbl.TextSize = 12
    valueLbl.TextColor3 = Color3.fromRGB(255, 220, 220)
    Instance.new("UICorner", valueLbl).CornerRadius = UDim.new(0, 4)
    local vStroke = Instance.new("UIStroke", valueLbl)
    vStroke.Color = Color3.fromRGB(200, 20, 20)
    vStroke.Thickness = 1
    local function setValue(v)
        v = math.clamp(v, DARK_MIN, DARK_MAX)
        v = math.floor(v * 10 + 0.5) / 10
        Config.DarkModeBrightness = v
        valueLbl.Text = string.format("%.2f", v)
        SaveConfig()
        if Config.FPSBoostDarkMode then
            pcall(ApplyDarkModeLighting)
        end
    end
    minusBtn.MouseButton1Click:Connect(function()
        setValue((Config.DarkModeBrightness or 0.3) - DARK_STEP)
    end)
    plusBtn.MouseButton1Click:Connect(function()
        setValue((Config.DarkModeBrightness or 0.3) + DARK_STEP)
    end)
end
task.spawn(function()
    for i = 1, 20 do
        task.wait(0.5)
        if Config.FPSBoostDarkMode then
            pcall(ApplyDarkModeLighting)
        end
    end
    while true do
        task.wait(3)
        if Config.FPSBoostDarkMode then
            pcall(ApplyDarkModeLighting)
        end
    end
end)
local rStealBar = CreateRow("Steal Bar")
CreateToggleSwitch(rStealBar, Config.StealBarEnabled, function(ns, set)
    set(ns); Config.StealBarEnabled = ns; SaveConfig()
    if ns and _G.ZawaHub_StealBar and _G.ZawaHub_StealBar.create then
        pcall(_G.ZawaHub_StealBar.create)
    elseif _G.ZawaHub_StealBar and _G.ZawaHub_StealBar.container then
        _G.ZawaHub_StealBar.container.Visible = false
    end
    ShowNotification("STEAL BAR", ns and "ENABLED" or "DISABLED")
end)
local rTrace = CreateRow("Tracer Best Brainrot")
CreateToggleSwitch(rTrace, Config.TracerEnabled, function(ns, set)
    set(ns); Config.TracerEnabled = ns; SaveConfig()
    ShowNotification("TRACER", ns and "ENABLED" or "DISABLED")
end)
local rLineToBase = CreateRow("Line to base")
CreateToggleSwitch(rLineToBase, Config.LineToBase, function(ns, set)
    set(ns); Config.LineToBase = ns; SaveConfig()
    if not ns and _G.resetPlotBeam then pcall(_G.resetPlotBeam) end
    ShowNotification("LINE TO BASE", ns and "ENABLED" or "DISABLED")
end)
do 
switchTab("AutoTP")
local rPriorityList = CreateRow("Priority List")
local bPriorityList = Instance.new("TextButton", rPriorityList)
bPriorityList.Size = UDim2.new(0, 80, 0, 24)
bPriorityList.Position = UDim2.new(1, -90, 0.5, -12)
bPriorityList.BackgroundColor3 = Theme.Accent2
bPriorityList.Text = "OPEN"
bPriorityList.Font = Enum.Font.GothamBold
bPriorityList.TextColor3 = Color3.fromRGB(255, 255, 255)
bPriorityList.TextSize = 11
bPriorityList.BorderSizePixel = 0
bPriorityList.AutoButtonColor = false
Instance.new("UICorner", bPriorityList).CornerRadius = UDim.new(0, 6)
local bPriorityStroke = Instance.new("UIStroke", bPriorityList)
bPriorityStroke.Color = Theme.Accent1
bPriorityStroke.Thickness = 1.5
bPriorityStroke.Transparency = 0.4
bPriorityList.MouseEnter:Connect(function()
    bPriorityList.BackgroundColor3 = Theme.Accent1
    bPriorityStroke.Transparency = 0.1
end)
bPriorityList.MouseLeave:Connect(function()
    bPriorityList.BackgroundColor3 = Theme.Accent2
    bPriorityStroke.Transparency = 0.4
end)
bPriorityList.MouseButton1Click:Connect(function()
    local pg = PlayerGui:FindFirstChild("PriorityListGUI")
    if pg then
        pg.Enabled = not pg.Enabled
    else
        ShowNotification("PRIORITY LIST", "Loading…")
    end
end)
if Config.UseTweenTp and Config.TweenTpSideMode then
    Config.TweenTpSideMode = false
end
if Config.TweenTpV3Mode and (Config.UseTweenTp or Config.TweenTpSideMode) then
    Config.UseTweenTp = false
    Config.TweenTpSideMode = false
end
local rTweenTp = CreateRow("Tween TP (force V1)")
local tweenTpSwitch, tweenSideSwitch, tweenV3Switch
local function syncTpSwitches()
    if tweenTpSwitch   then tweenTpSwitch.Set(Config.UseTweenTp)      end
    if tweenSideSwitch then tweenSideSwitch.Set(Config.TweenTpSideMode) end
    if tweenV3Switch   then tweenV3Switch.Set(Config.TweenTpV3Mode)   end
end
local function setTweenTpEnabled(enabled)
    Config.UseTweenTp = enabled
    if enabled then Config.TweenTpSideMode = false; Config.TweenTpV3Mode = false end
    syncTpSwitches(); SaveConfig()
    ShowNotification("TWEEN TP", enabled and "ENABLED" or "DISABLED")
end
local function setTweenV3Enabled(enabled)
    Config.TweenTpV3Mode = enabled
    if enabled then Config.UseTweenTp = false; Config.TweenTpSideMode = false end
    syncTpSwitches(); SaveConfig()
    ShowNotification("TWEEN TP V3", enabled and "ENABLED" or "DISABLED")
end
tweenTpSwitch = CreateToggleSwitch(rTweenTp, Config.UseTweenTp, function(ns)
    setTweenTpEnabled(ns)
end)
local rTweenSide = CreateRow("Tween TP: Side Mode")
tweenSideSwitch = CreateToggleSwitch(rTweenSide, Config.TweenTpSideMode, function(ns, set)
    Config.TweenTpSideMode = ns
    if ns then Config.UseTweenTp = false; Config.TweenTpV3Mode = false end
    syncTpSwitches(); SaveConfig()
    ShowNotification("TWEEN TP", ns and "Side Mode ON" or "Side Mode OFF")
end)
local rTweenV3 = CreateRow("Tween TP V3")
tweenV3Switch = CreateToggleSwitch(rTweenV3, Config.TweenTpV3Mode, function(ns)
    setTweenV3Enabled(ns)
end)
local rFloor2From1 = CreateRow("Floor 2 from Floor 1")
CreateToggleSwitch(rFloor2From1, Config.AutoTPFloor2FromFloor1, function(ns, set)
    set(ns)
    Config.AutoTPFloor2FromFloor1 = ns
    SaveConfig()
    ShowNotification("TP", ns and "Floor 2 from Floor 1 ON" or "Floor 2 from Floor 1 OFF")
end)
local rShowPath = CreateRow("Show TP Path Line")
CreateToggleSwitch(rShowPath, Config.ShowTpPath, function(ns, set)
    set(ns)
    Config.ShowTpPath = ns
    SaveConfig()
end)
do
    local tpPathFolder
    local tpPathLastPos
    local tpPathWasMoving = false
    local tpReachedBase   = false   
    local function clearTpPath()
        if tpPathFolder then pcall(function() tpPathFolder:Destroy() end) end
        tpPathFolder = nil
        tpPathLastPos = nil
    end
    local function addTpPathSegment(a, b)
        local dist = (b - a).Magnitude
        if dist < 0.1 then return end
        if dist > 200 then return end
        if not tpPathFolder then
            tpPathFolder = Instance.new("Folder")
            tpPathFolder.Name = "ZawaTpPath"
            tpPathFolder.Parent = Workspace
        end
        local cf = CFrame.lookAt((a + b) / 2, b)
        local halo = Instance.new("Part")
        halo.Shape        = Enum.PartType.Block
        halo.Anchored     = true
        halo.CanCollide   = false
        halo.CanQuery     = false
        halo.CanTouch     = false
        halo.CastShadow   = false
        halo.Material     = Enum.Material.Neon
        halo.Color        = Color3.fromRGB(255, 25, 25)
        halo.Transparency = 0.55
        halo.Size         = Vector3.new(1.3, 1.3, dist + 2)
        halo.CFrame       = cf
        halo.Parent       = tpPathFolder
        local core = Instance.new("Part")
        core.Shape        = Enum.PartType.Block
        core.Anchored     = true
        core.CanCollide   = false
        core.CanQuery     = false
        core.CanTouch     = false
        core.CastShadow   = false
        core.Material     = Enum.Material.Neon
        core.Color        = Color3.fromRGB(255, 190, 190)
        core.Transparency = 0
        core.Size         = Vector3.new(0.4, 0.4, dist + 2)
        core.CFrame       = cf
        core.Parent       = tpPathFolder
    end
    RunService.Heartbeat:Connect(function()
        if not Config.ShowTpPath then
            if tpPathFolder then clearTpPath() end
            tpPathWasMoving = false
            return
        end
        local moving = State.isTpMoving == true
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if moving and not tpPathWasMoving then
            clearTpPath()
            tpReachedBase = false
            if hrp then tpPathLastPos = hrp.Position end
        elseif moving and hrp and tpPathLastPos and not tpReachedBase then
            if (hrp.Position - tpPathLastPos).Magnitude >= 16 then
                addTpPathSegment(tpPathLastPos, hrp.Position)
                tpPathLastPos = hrp.Position
            end
        end
        if moving and _G.isCloning then
            tpReachedBase = true
        end
        tpPathWasMoving = moving
    end)
end
local rTpNow = CreateRow("TP Now")
local bTpNow = Instance.new("TextButton", rTpNow)
bTpNow.Size = UDim2.new(0, 80, 0, 24)
bTpNow.Position = UDim2.new(1, -90, 0.5, -12)
bTpNow.BackgroundColor3 = Theme.Accent2
bTpNow.Text = "GO"
bTpNow.Font = Enum.Font.GothamBold
bTpNow.TextColor3 = Color3.fromRGB(255,255,255)
bTpNow.TextSize = 12
bTpNow.BorderSizePixel = 0
bTpNow.AutoButtonColor = false
Instance.new("UICorner", bTpNow).CornerRadius = UDim.new(0, 6)
bTpNow.MouseButton1Click:Connect(function()
    if _G.dispatchTp then _G.dispatchTp() end
end)
local rTpLoad = CreateRow("TP On Load")
CreateToggleSwitch(rTpLoad, Config.TpSettings.TpOnLoad, function(ns, set)
    set(ns); Config.TpSettings.TpOnLoad = ns; SaveConfig()
    ShowNotification("TP ON LOAD", ns and "ENABLED" or "DISABLED")
end)
local rTpPrio = CreateRow("Auto TP Priority")
CreateToggleSwitch(rTpPrio, Config.AutoTPPriority, function(ns, set)
    set(ns); Config.AutoTPPriority = ns; SaveConfig()
    ShowNotification("AUTO TP PRIORITY", ns and "ENABLED" or "DISABLED")
end)
local rTpTool = CreateRow("TP Tool", 44)
local toolSub = Instance.new("TextLabel", rTpTool)
toolSub.Size = UDim2.new(1, -160, 0, 12); toolSub.Position = UDim2.new(0, 14, 0, 26)
toolSub.BackgroundTransparency = 1
toolSub.Text = "Carpet name used by all TP versions"
toolSub.Font = Enum.Font.Gotham; toolSub.TextSize = 9
toolSub.TextColor3 = Color3.fromRGB(180, 130, 160)
toolSub.TextXAlignment = Enum.TextXAlignment.Left
local toolBox = Instance.new("TextBox", rTpTool)
toolBox.Size = UDim2.new(0, 130, 0, 22); toolBox.Position = UDim2.new(1, -140, 0.5, -11)
toolBox.BackgroundColor3 = Color3.fromRGB(35, 8, 8); toolBox.BorderSizePixel = 0
toolBox.Text = tostring(Config.TpSettings.Tool or "Flying Carpet")
toolBox.PlaceholderText = "Flying Carpet"
toolBox.Font = Enum.Font.Gotham; toolBox.TextSize = 11
toolBox.TextColor3 = Color3.fromRGB(255, 220, 220); toolBox.ClearTextOnFocus = false
Instance.new("UICorner", toolBox).CornerRadius = UDim.new(0, 4)
local toolStroke = Instance.new("UIStroke", toolBox)
toolStroke.Color = Color3.fromRGB(200, 20, 20); toolStroke.Thickness = 1
toolBox.FocusLost:Connect(function()
    local raw = toolBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if raw == "" then raw = "Flying Carpet" end
    Config.TpSettings.Tool = raw
    toolBox.Text = raw
    SaveConfig()
    ShowNotification("TP TOOL", raw)
end)
switchTab("Keys")
local rTpKey = CreateRow("TP Keybind")
local bTpKey = Instance.new("TextButton", rTpKey)
bTpKey.Size = UDim2.new(0, 60, 0, 24); bTpKey.Position = UDim2.new(1, -70, 0.5, -12)
bTpKey.BackgroundColor3 = Theme.SurfaceHighlight
bTpKey.Text = Config.TpSettings.TpKey or "T"
bTpKey.Font = Enum.Font.GothamBold; bTpKey.TextColor3 = Theme.TextPrimary; bTpKey.TextSize = 12
Instance.new("UICorner", bTpKey).CornerRadius = UDim.new(0, 4)
bTpKey.MouseButton1Click:Connect(function()
    bTpKey.Text = "..."; bTpKey.TextColor3 = Theme.Accent1
    local con; con = UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            Config.TpSettings.TpKey = inp.KeyCode.Name; bTpKey.Text = inp.KeyCode.Name
            bTpKey.TextColor3 = Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("TP KEYBIND", inp.KeyCode.Name)
        end
    end)
end)
local rCloneKey = CreateRow("Clone Keybind")
local bCloneKey = Instance.new("TextButton", rCloneKey)
bCloneKey.Size = UDim2.new(0, 60, 0, 24); bCloneKey.Position = UDim2.new(1, -70, 0.5, -12)
bCloneKey.BackgroundColor3 = Theme.SurfaceHighlight
bCloneKey.Text = Config.TpSettings.CloneKey or "V"
bCloneKey.Font = Enum.Font.GothamBold; bCloneKey.TextColor3 = Theme.TextPrimary; bCloneKey.TextSize = 12
Instance.new("UICorner", bCloneKey).CornerRadius = UDim.new(0, 4)
bCloneKey.MouseButton1Click:Connect(function()
    bCloneKey.Text = "..."; bCloneKey.TextColor3 = Theme.Accent1
    local con; con = UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            Config.TpSettings.CloneKey = inp.KeyCode.Name; bCloneKey.Text = inp.KeyCode.Name
            bCloneKey.TextColor3 = Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("CLONE KEYBIND", inp.KeyCode.Name)
        end
    end)
end)
switchTab("AutoTP")
local rTweenSpeedOpen = CreateRow("Tween TP Speed")
local bTweenSpeedOpen = Instance.new("TextButton", rTweenSpeedOpen)
bTweenSpeedOpen.Size = UDim2.new(0, 80, 0, 24)
bTweenSpeedOpen.Position = UDim2.new(1, -90, 0.5, -12)
bTweenSpeedOpen.BackgroundColor3 = Theme.Accent2
bTweenSpeedOpen.Text = "OPEN"
bTweenSpeedOpen.Font = Enum.Font.GothamBold
bTweenSpeedOpen.TextColor3 = Color3.fromRGB(255, 255, 255)
bTweenSpeedOpen.TextSize = 11
bTweenSpeedOpen.BorderSizePixel = 0
bTweenSpeedOpen.AutoButtonColor = false
Instance.new("UICorner", bTweenSpeedOpen).CornerRadius = UDim.new(0, 6)
local bTweenSpeedStroke = Instance.new("UIStroke", bTweenSpeedOpen)
bTweenSpeedStroke.Color = Theme.Accent1
bTweenSpeedStroke.Thickness = 1.5
bTweenSpeedStroke.Transparency = 0.4
local _tweenSpeedBuilt = false
local _tweenSpeedGui   = nil
local function _buildTweenSpeedGui()
    if _tweenSpeedBuilt then return end
    _tweenSpeedBuilt = true
    local sg = Instance.new("ScreenGui")
    sg.Name = "ZawaTweenSpeedGui"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = PlayerGui
    _tweenSpeedGui = sg
    local panel = Instance.new("Frame", sg)
    panel.Name = "TweenSpeedPanel"
    panel.Size = UDim2.new(0, 280, 0, 172)
    panel.Position = UDim2.new(0.42, 0, 0.18, 0)
    panel.BackgroundColor3 = Theme.Background
    panel.BorderSizePixel = 0
    panel.Active = true
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 8)
    local pStroke = Instance.new("UIStroke", panel)
    pStroke.Color = Theme.Accent2
    pStroke.Thickness = 1
    local header = Instance.new("Frame", panel)
    header.Size = UDim2.new(1, 0, 0, 28)
    header.BackgroundColor3 = Theme.Surface
    header.BorderSizePixel = 0
    header.Active = true
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)
    local hLbl = Instance.new("TextLabel", header)
    hLbl.Size = UDim2.new(1, -40, 1, 0)
    hLbl.Position = UDim2.new(0, 8, 0, 0)
    hLbl.BackgroundTransparency = 1
    hLbl.Text = "TWEEN TP SPEED"
    hLbl.Font = Enum.Font.GothamBlack
    hLbl.TextSize = 13
    hLbl.TextColor3 = Theme.Accent1
    hLbl.TextXAlignment = Enum.TextXAlignment.Left
    local close = Instance.new("TextButton", header)
    close.Size = UDim2.new(0, 24, 0, 20)
    close.Position = UDim2.new(1, -28, 0, 4)
    close.BackgroundColor3 = Theme.Accent2
    close.BorderSizePixel = 0
    close.Text = "X"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 12
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.AutoButtonColor = false
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 4)
    close.MouseButton1Click:Connect(function() panel.Visible = false end)
    do
        local dragging, dragStart, startPos
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
               or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos  = panel.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging
               and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                panel.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
    end
    local function mkSpeedSlider(labelText, configKey, defaultVal, yPos)
        local minVal, maxVal, stepSize = 80, 400, 10
        local span = maxVal - minVal
        local row = Instance.new("Frame", panel)
        row.Size = UDim2.new(1, -20, 0, 56)
        row.Position = UDim2.new(0, 10, 0, yPos)
        row.BackgroundColor3 = Theme.Surface
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
        local rs = Instance.new("UIStroke", row)
        rs.Color = Theme.Accent2; rs.Thickness = 1; rs.Transparency = 0.5
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0.6, 0, 0, 18); lbl.Position = UDim2.new(0, 12, 0, 8)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 11
        lbl.TextColor3 = Theme.TextPrimary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        local initVal = math.clamp(tonumber(Config[configKey]) or defaultVal, minVal, maxVal)
        local valLbl = Instance.new("TextLabel", row)
        valLbl.Size = UDim2.new(0, 50, 0, 18); valLbl.Position = UDim2.new(1, -62, 0, 8)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = tostring(math.floor(initVal + 0.5))
        valLbl.Font = Enum.Font.GothamBold; valLbl.TextSize = 12
        valLbl.TextColor3 = Theme.Accent1
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        local track = Instance.new("Frame", row)
        track.Size = UDim2.new(1, -24, 0, 5); track.Position = UDim2.new(0, 12, 0, 38)
        track.BackgroundColor3 = Theme.SurfaceHighlight; track.BorderSizePixel = 0
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
        local initT = math.clamp((initVal - minVal) / span, 0, 1)
        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new(initT, 0, 1, 0)
        fill.BackgroundColor3 = Theme.Accent2; fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        local knob = Instance.new("Frame", track)
        knob.Size = UDim2.new(0, 13, 0, 13)
        knob.Position = UDim2.new(initT, -6, 0.5, -6)
        knob.BackgroundColor3 = Theme.TextPrimary; knob.BorderSizePixel = 0
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        local kStroke = Instance.new("UIStroke", knob)
        kStroke.Color = Theme.Accent2; kStroke.Thickness = 1.5
        local dragging = false
        local function applyFromAbsX(absX)
            local trackAbs = track.AbsolutePosition.X
            local trackW   = track.AbsoluteSize.X
            if trackW <= 0 then return end
            local t = math.clamp((absX - trackAbs) / trackW, 0, 1)
            local raw = minVal + t * span
            local stepped = math.floor((raw - minVal) / stepSize + 0.5) * stepSize + minVal
            stepped = math.clamp(stepped, minVal, maxVal)
            local newT = (stepped - minVal) / span
            fill.Size = UDim2.new(newT, 0, 1, 0)
            knob.Position = UDim2.new(newT, -6, 0.5, -6)
            valLbl.Text = tostring(math.floor(stepped + 0.5))
            Config[configKey] = stepped
            SaveConfig()
        end
        local hit = Instance.new("TextButton", track)
        hit.Size = UDim2.new(1, 0, 0, 24); hit.Position = UDim2.new(0, 0, 0.5, -12)
        hit.BackgroundTransparency = 1; hit.Text = ""
        hit.AutoButtonColor = false; hit.ZIndex = 5
        hit.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
               or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                applyFromAbsX(inp.Position.X)
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging
               and (inp.UserInputType == Enum.UserInputType.MouseMovement
                    or inp.UserInputType == Enum.UserInputType.Touch) then
                applyFromAbsX(inp.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
               or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end
    mkSpeedSlider("1st Floor Speed (studs/sec)", "TweenTpSpeedF1", 140, 38)
    mkSpeedSlider("2nd Floor Speed (studs/sec)", "TweenTpSpeedF2", 130, 102)
end
bTweenSpeedOpen.MouseButton1Click:Connect(function()
    if not _tweenSpeedBuilt then
        _buildTweenSpeedGui()
    else
        local panel = _tweenSpeedGui and _tweenSpeedGui:FindFirstChild("TweenSpeedPanel")
        if panel then panel.Visible = not panel.Visible end
    end
end)
CreateSectionHeader("CARPET SPEED")
switchTab("Keys")
local rCarpetBind = CreateRow("Carpet Speed Keybind")
local bCarpet = Instance.new("TextButton", rCarpetBind)
bCarpet.Size=UDim2.new(0,60,0,24); bCarpet.Position=UDim2.new(1,-70,0.5,-12)
bCarpet.BackgroundColor3=Theme.SurfaceHighlight; bCarpet.Text=Config.TpSettings.CarpetSpeedKey
bCarpet.Font=Enum.Font.GothamBold; bCarpet.TextColor3=Theme.TextPrimary; bCarpet.TextSize=12
Instance.new("UICorner",bCarpet).CornerRadius=UDim.new(0,4)
bCarpet.MouseButton1Click:Connect(function()
    bCarpet.Text="..."; bCarpet.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.TpSettings.CarpetSpeedKey=inp.KeyCode.Name; bCarpet.Text=inp.KeyCode.Name
            bCarpet.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("CARPET SPEED KEYBIND", inp.KeyCode.Name)
        end
    end)
end)
local rRagdollSelf = CreateRow("Ragdoll Self Keybind")
local bRagdollSelf = Instance.new("TextButton", rRagdollSelf)
bRagdollSelf.Size=UDim2.new(0,60,0,24); bRagdollSelf.Position=UDim2.new(1,-70,0.5,-12)
bRagdollSelf.BackgroundColor3=Theme.SurfaceHighlight; bRagdollSelf.Text=Config.RagdollSelfKey ~= "" and Config.RagdollSelfKey or "NONE"
bRagdollSelf.Font=Enum.Font.GothamBold; bRagdollSelf.TextColor3=Theme.TextPrimary; bRagdollSelf.TextSize=12
Instance.new("UICorner",bRagdollSelf).CornerRadius=UDim.new(0,4)
bRagdollSelf.MouseButton1Click:Connect(function()
    bRagdollSelf.Text="..."; bRagdollSelf.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.RagdollSelfKey=inp.KeyCode.Name; bRagdollSelf.Text=inp.KeyCode.Name
            bRagdollSelf.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("RAGDOLL SELF KEYBIND", inp.KeyCode.Name)
        end
    end)
end)
switchTab("AutoTP")
local rCarpetStatus = CreateRow("Carpet Speed Status")
local carpetStatusLbl = Instance.new("TextLabel", rCarpetStatus)
carpetStatusLbl.Size=UDim2.new(0,50,0,20); carpetStatusLbl.Position=UDim2.new(1,-60,0.5,-10)
carpetStatusLbl.BackgroundTransparency=1
carpetStatusLbl.Text=carpetSpeedEnabled and "ON" or "OFF"
carpetStatusLbl.TextColor3=carpetSpeedEnabled and Theme.Success or Theme.Error
carpetStatusLbl.Font=Enum.Font.GothamBlack; carpetStatusLbl.TextSize=13
carpetStatusLbl.TextXAlignment=Enum.TextXAlignment.Right
_carpetStatusLabel = carpetStatusLbl
CreateSectionHeader("MOVEMENT")
local rInfJump = CreateRow("Infinite Jump")
CreateToggleSwitch(rInfJump, infiniteJumpEnabled, function(ns, set)
    set(ns); setInfiniteJump(ns)
    ShowNotification("INFINITE JUMP", ns and "ENABLED" or "DISABLED")
end)
local rShowSS = CreateRow("Show Steal Speed Panel")
CreateToggleSwitch(rShowSS, Config.ShowStealSpeedPanel, function(ns, set)
    set(ns); Config.ShowStealSpeedPanel = ns; SaveConfig()
    local ssGui = PlayerGui:FindFirstChild("StealSpeedUI")
    if ssGui then ssGui.Enabled = ns end
    ShowNotification("STEAL SPEED PANEL", ns and "SHOWN" or "HIDDEN")
end)
local rAutoStealSpeed = CreateRow("Auto Steal Speed")
CreateToggleSwitch(rAutoStealSpeed, Config.AutoStealSpeed, function(ns, set)
    set(ns); Config.AutoStealSpeed = ns; SaveConfig()
    ShowNotification("AUTO STEAL SPEED", ns and "ENABLED" or "DISABLED")
end)
local rAutoGrab = CreateRow("Auto Grab (own pets)")
CreateToggleSwitch(rAutoGrab, Config.AutoGrab, function(ns, set)
    set(ns); Config.AutoGrab = ns; autoGrabEnabled = ns; SaveConfig()
    ShowNotification("AUTO GRAB", ns and "ENABLED" or "DISABLED")
end)
switchTab("Keys")
local rStealSpeedKey = CreateRow("Steal Speed Keybind")
local bStealSpeedKey = Instance.new("TextButton", rStealSpeedKey)
bStealSpeedKey.Size=UDim2.new(0,60,0,24); bStealSpeedKey.Position=UDim2.new(1,-70,0.5,-12)
bStealSpeedKey.BackgroundColor3=Theme.SurfaceHighlight; bStealSpeedKey.Text=Config.StealSpeedKey
bStealSpeedKey.Font=Enum.Font.GothamBold; bStealSpeedKey.TextColor3=Theme.TextPrimary; bStealSpeedKey.TextSize=12
Instance.new("UICorner",bStealSpeedKey).CornerRadius=UDim.new(0,4)
bStealSpeedKey.MouseButton1Click:Connect(function()
    bStealSpeedKey.Text="..."; bStealSpeedKey.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.StealSpeedKey=inp.KeyCode.Name; bStealSpeedKey.Text=inp.KeyCode.Name
            bStealSpeedKey.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("STEAL SPEED KEYBIND", inp.KeyCode.Name)
        end
    end)
end)
switchTab("AutoTP")
CreateSectionHeader("AUTO UNLOCK")
local rAutoUnlock = CreateRow("Auto Unlock on Steal")
CreateToggleSwitch(rAutoUnlock, Config.AutoUnlockOnSteal, function(ns, set)
    set(ns); Config.AutoUnlockOnSteal = ns; SaveConfig()
    ShowNotification("AUTO UNLOCK", ns and "ENABLED" or "DISABLED")
end)
local rShowUnlockHUD = CreateRow("Show Unlock Buttons HUD")
CreateToggleSwitch(rShowUnlockHUD, Config.ShowUnlockButtonsHUD, function(ns, set)
    set(ns); Config.ShowUnlockButtonsHUD = ns; SaveConfig()
    local hudGui = PlayerGui:FindFirstChild("ZawaStatusHUD")
    if hudGui then
        local main = hudGui:FindFirstChild("Main")
        local unlockContainer = main and main:FindFirstChild("UnlockButtonsContainer")
        if main and unlockContainer then
            unlockContainer.Visible = ns
            if ns then
                TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 500, 0, 100)
                }):Play()
            else
                TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 500, 0, 50)
                }):Play()
            end
        end
    end
end)
CreateSectionHeader("ANTI-RAGDOLL")
local arV1SetRef, arV2SetRef = {}, {}
local rAr = CreateRow("V1")
CreateToggleSwitch(rAr, Config.AntiRagdoll > 0, function(ns, set)
    arV1SetRef.fn = set
    if ns and Config.AntiRagdollV2 then
        set(false)
        ShowNotification("ANTI-RAGDOLL", "DISABLE V2 FIRST")
        return
    end
    set(ns)
    local mode = ns and 1 or 0
    Config.AntiRagdoll = mode
    if ns then
        Config.AntiRagdollV2 = false
        if arV2SetRef.fn then arV2SetRef.fn(false) end
    end
    SaveConfig()
    startAntiRagdoll(mode)
    if ns then startAntiRagdollV2(false) end
    ShowNotification("ANTI-RAGDOLL V1", ns and "ENABLED" or "DISABLED")
end)
local rArV2 = CreateRow("V2")
CreateToggleSwitch(rArV2, Config.AntiRagdollV2, function(ns, set)
    arV2SetRef.fn = set
    if ns and Config.AntiRagdoll > 0 then
        set(false)
        ShowNotification("ANTI-RAGDOLL", "DISABLE V1 FIRST")
        return
    end
    set(ns)
    Config.AntiRagdollV2 = ns
    if ns then
        Config.AntiRagdoll = 0
        SaveConfig()
        if arV1SetRef.fn then arV1SetRef.fn(false) end
        startAntiRagdoll(0)
        startAntiRagdollV2(true)
    else
        SaveConfig()
        startAntiRagdollV2(false)
    end
    ShowNotification("ANTI-RAGDOLL V2", ns and "ENABLED" or "DISABLED")
end)
end 
task.wait() 
CreateSectionHeader("ESP")
do 
local rPlayerEsp = CreateRow("Player ESP (Hides Names)")
CreateToggleSwitch(rPlayerEsp, Config.PlayerESP, function(ns, set)
    set(ns); Config.PlayerESP = ns; SaveConfig()
    if playerESPToggleRef.setFn then playerESPToggleRef.setFn(ns) end
    ShowNotification("PLAYER ESP", ns and "ENABLED" or "DISABLED")
end)
local rEsp = CreateRow("Brainrot ESP")
local espSettingsSwitch = CreateToggleSwitch(rEsp, Config.BrainrotESP, function(ns, set)
    set(ns); Config.BrainrotESP = ns; SaveConfig()
    if espToggleRef.setFn then espToggleRef.setFn(ns) end
    ShowNotification("BRAINROT ESP", ns and "ENABLED" or "DISABLED")
end)
local rSubspaceMineEsp = CreateRow("Subspace Mine Esp")
CreateToggleSwitch(rSubspaceMineEsp, Config.SubspaceMineESP, function(ns, set)
    set(ns); Config.SubspaceMineESP = ns; SaveConfig()
    if subspaceMineESPToggleRef.setFn then subspaceMineESPToggleRef.setFn(ns) end
    ShowNotification("SUBSPACE MINE ESP", ns and "ENABLED" or "DISABLED")
end)
local rDuelBaseESP = CreateRow("Duel Base ESP")
CreateToggleSwitch(rDuelBaseESP, Config.DuelBaseESP, function(ns, set)
    set(ns); Config.DuelBaseESP = ns; SaveConfig()
    ShowNotification("DUEL BASE ESP", ns and "ENABLED" or "DISABLED")
end)
local rMobyESPInAP = CreateRow("Moby ESP (Admin Panel)")
CreateToggleSwitch(rMobyESPInAP, Config.MobyESPInAdminPanel, function(ns, set)
    set(ns); Config.MobyESPInAdminPanel = ns; SaveConfig()
    ShowNotification("MOBY ESP", ns and "ENABLED" or "DISABLED")
end)
local rKawaifuESPInAP = CreateRow("Kawaifu ESP (Admin Panel)")
CreateToggleSwitch(rKawaifuESPInAP, Config.KawaifuESPInAdminPanel, function(ns, set)
    set(ns); Config.KawaifuESPInAdminPanel = ns; SaveConfig()
    ShowNotification("KAWAIFU ESP", ns and "ENABLED" or "DISABLED")
end)
local rAtlasESPInAP = CreateRow("Atlas ESP (Admin Panel)")
CreateToggleSwitch(rAtlasESPInAP, Config.AtlasESPInAdminPanel, function(ns, set)
    set(ns); Config.AtlasESPInAdminPanel = ns; SaveConfig()
    ShowNotification("ATLAS ESP", ns and "ENABLED" or "DISABLED")
end)
local rBraintopiaESPInAP = CreateRow("Braintopia ESP (Admin Panel)")
CreateToggleSwitch(rBraintopiaESPInAP, Config.BraintopiaESPInAdminPanel, function(ns, set)
    set(ns); Config.BraintopiaESPInAdminPanel = ns; SaveConfig()
    ShowNotification("BRAINTOPIA ESP", ns and "ENABLED" or "DISABLED")
end)
end 
task.wait() 
local autoTPPriorityToggleRef = {setFn = nil} 
do 
CreateSectionHeader("AUTO STEAL DEFAULTS")
local rAutoStealMaster = CreateRow("Auto Steal")
local autoStealMasterSwitch = CreateToggleSwitch(rAutoStealMaster,
    Config.AutoStealEnabled ~= false,
    function(ns, set)
        set(ns)
        Config.AutoStealEnabled = ns
        SaveConfig()
        if _G.ZawaHub_SetAutoSteal then
            _G.ZawaHub_SetAutoSteal(ns)
        else
            task.spawn(function()
                for _ = 1, 20 do
                    task.wait(0.25)
                    if _G.ZawaHub_SetAutoSteal then
                        _G.ZawaHub_SetAutoSteal(ns)
                        break
                    end
                end
            end)
        end
        ShowNotification("AUTO STEAL", ns and "ON" or "OFF")
    end)
local nearestToggleRef = {}
local highestToggleRef = {}
local priorityToggleRef = {}
local rDefaultNearest = CreateRow("Default To Nearest")
local nearestToggleSwitch = CreateToggleSwitch(rDefaultNearest, Config.DefaultToNearest, function(ns, set)
    if ns then
        Config.DefaultToNearest = true
        Config.DefaultToHighest = false
        Config.DefaultToPriority = false
        set(true)
        if highestToggleRef.setFn then highestToggleRef.setFn(false) end
        if priorityToggleRef.setFn then priorityToggleRef.setFn(false) end
        Config.AutoTPPriority = true
        if autoTPPriorityToggleRef and autoTPPriorityToggleRef.setFn then
            autoTPPriorityToggleRef.setFn(true)
        end
    else
        local otherDefaults = Config.DefaultToHighest or Config.DefaultToPriority
        if not otherDefaults then
            set(true)
            ShowNotification("DEFAULT MODE", "At least one default must be enabled")
            return
        end
        Config.DefaultToNearest = false
        set(false)
    end
    SaveConfig()
    ShowNotification("DEFAULT TO NEAREST", ns and "ENABLED" or "DISABLED")
end)
nearestToggleRef.setFn = nearestToggleSwitch.Set
local rDefaultHighest = CreateRow("Default To Highest")
local highestToggleSwitch = CreateToggleSwitch(rDefaultHighest, Config.DefaultToHighest, function(ns, set)
    if ns then
        Config.DefaultToNearest = false
        Config.DefaultToHighest = true
        Config.DefaultToPriority = false
        set(true)
        if nearestToggleRef.setFn then nearestToggleRef.setFn(false) end
        if priorityToggleRef.setFn then priorityToggleRef.setFn(false) end
        Config.AutoTPPriority = false
        if autoTPPriorityToggleRef and autoTPPriorityToggleRef.setFn then
            autoTPPriorityToggleRef.setFn(false)
        end
    else
        local otherDefaults = Config.DefaultToNearest or Config.DefaultToPriority
        if not otherDefaults then
            set(true)
            ShowNotification("DEFAULT MODE", "At least one default must be enabled")
            return
        end
        Config.DefaultToHighest = false
        set(false)
    end
    SaveConfig()
    ShowNotification("DEFAULT TO HIGHEST", ns and "ENABLED" or "DISABLED")
end)
highestToggleRef.setFn = highestToggleSwitch.Set
local rDefaultPriority = CreateRow("Default To Priority")
local priorityToggleSwitch = CreateToggleSwitch(rDefaultPriority, Config.DefaultToPriority, function(ns, set)
    if ns then
        Config.DefaultToNearest = false
        Config.DefaultToHighest = false
        Config.DefaultToPriority = true
        set(true)
        if nearestToggleRef.setFn then nearestToggleRef.setFn(false) end
        if highestToggleRef.setFn then highestToggleRef.setFn(false) end
        Config.AutoTPPriority = true
        if autoTPPriorityToggleRef and autoTPPriorityToggleRef.setFn then
            autoTPPriorityToggleRef.setFn(true)
        end
    else
        local otherDefaults = Config.DefaultToNearest or Config.DefaultToHighest
        if not otherDefaults then
            set(true)
            ShowNotification("DEFAULT MODE", "At least one default must be enabled")
            return
        end
        Config.DefaultToPriority = false
        set(false)
    end
    SaveConfig()
    ShowNotification("DEFAULT TO PRIORITY", ns and "ENABLED" or "DISABLED")
end)
priorityToggleRef.setFn = priorityToggleSwitch.Set
end 
task.wait() 
do 
CreateSectionHeader("AUTOMATION")
local rAutoTpFail = CreateRow("Auto TP on Failed Steal")
CreateToggleSwitch(rAutoTpFail, Config.AutoTpOnFailedSteal, function(ns, set)
    set(ns); Config.AutoTpOnFailedSteal = ns; SaveConfig()
    ShowNotification("AUTO TP ON FAILED STEAL", ns and "ENABLED" or "DISABLED")
end)
local rAutoTPBack = CreateRow("Auto TP Back to Brainrot")
CreateToggleSwitch(rAutoTPBack, Config.AutoTPBackToBrainrot, function(ns, set)
    set(ns); Config.AutoTPBackToBrainrot = ns; SaveConfig()
    ShowNotification("AUTO TP BACK", ns and "ENABLED" or "DISABLED")
end)
do
    local rAntiBodySwap = CreateRow("Anti Body Swap")
    CreateToggleSwitch(rAntiBodySwap, Config.AntiBodySwap, function(ns, set)
        set(ns); Config.AntiBodySwap = ns; SaveConfig()
        ShowNotification("ANTI BODY SWAP", ns and "ENABLED" or "DISABLED")
    end)
end
local rAutoTpPriority = CreateRow("Auto TP Priority Mode")
local autoTPPriorityToggleSwitch = CreateToggleSwitch(rAutoTpPriority, Config.AutoTPPriority, function(ns, set)
    set(ns); Config.AutoTPPriority = ns; SaveConfig()
    ShowNotification("AUTO TP PRIORITY", ns and "PRIORITY" or "HIGHEST")
end)
autoTPPriorityToggleRef.setFn = autoTPPriorityToggleSwitch.Set
local rServerPos = CreateRow("Show Server Position")
CreateToggleSwitch(rServerPos, Config.ShowServerPos, function(ns, set)
    set(ns); Config.ShowServerPos = ns; _G.ShowServerPos = ns; SaveConfig()
    ShowNotification("SERVER POSITION", ns and "ENABLED" or "DISABLED")
    if _G._updateServerPosLabel then _G._updateServerPosLabel() end
end)
local rBaseTimerESP = CreateRow("Base Timer ESP")
CreateToggleSwitch(rBaseTimerESP, Config.BaseTimerESP, function(ns, set)
    set(ns); Config.BaseTimerESP = ns; SaveConfig()
    ShowNotification("BASE TIMER ESP", ns and "ENABLED" or "DISABLED")
end)
do
    local rAutoSell = CreateRow("Auto Sell")
    CreateToggleSwitch(rAutoSell, Config.AutoSell, function(ns, set)
        set(ns); Config.AutoSell = ns; SaveConfig()
        if _G.ZawaHubAutoSell_SetEnabled then
            _G.ZawaHubAutoSell_SetEnabled(ns)
        end
        ShowNotification("AUTO SELL", ns and "ENABLED" or "DISABLED")
    end)
end
do
    local rAutoSellPodium = CreateRow("Auto Sell Podium # (0=all)", 44)
    local autoSellPodiumSub = Instance.new("TextLabel", rAutoSellPodium)
    autoSellPodiumSub.Size = UDim2.new(1, -120, 0, 12)
    autoSellPodiumSub.Position = UDim2.new(0, 14, 0, 26)
    autoSellPodiumSub.BackgroundTransparency = 1
    autoSellPodiumSub.Text = "Pick which podium to sell (1-N), 0 = every podium"
    autoSellPodiumSub.Font = Enum.Font.Gotham
    autoSellPodiumSub.TextSize = 9
    autoSellPodiumSub.TextColor3 = Color3.fromRGB(180, 130, 160)
    autoSellPodiumSub.TextXAlignment = Enum.TextXAlignment.Left
    local autoSellPodiumBox = Instance.new("TextBox", rAutoSellPodium)
    autoSellPodiumBox.Size = UDim2.new(0, 75, 0, 22)
    autoSellPodiumBox.Position = UDim2.new(1, -85, 0.5, -11)
    autoSellPodiumBox.BackgroundColor3 = Color3.fromRGB(35, 8, 8)
    autoSellPodiumBox.BorderSizePixel = 0
    autoSellPodiumBox.Text = tostring(Config.AutoSellPodium or 0)
    autoSellPodiumBox.PlaceholderText = "0"
    autoSellPodiumBox.Font = Enum.Font.Gotham
    autoSellPodiumBox.TextSize = 11
    autoSellPodiumBox.TextColor3 = Color3.fromRGB(255, 220, 220)
    autoSellPodiumBox.ClearTextOnFocus = false
    Instance.new("UICorner", autoSellPodiumBox).CornerRadius = UDim.new(0, 4)
    local autoSellPodiumStroke = Instance.new("UIStroke", autoSellPodiumBox)
    autoSellPodiumStroke.Color = Color3.fromRGB(200, 20, 20)
    autoSellPodiumStroke.Thickness = 1
    autoSellPodiumBox.FocusLost:Connect(function()
        local raw = autoSellPodiumBox.Text:gsub("%s", "")
        if raw == "" then raw = "0" end
        local n = tonumber(raw)
        if n and n >= 0 and n <= 50 and n == math.floor(n) then
            Config.AutoSellPodium = n
            autoSellPodiumBox.Text = tostring(n)
            SaveConfig()
            if n == 0 then
                ShowNotification("AUTO SELL PODIUM", "All podiums")
            else
                ShowNotification("AUTO SELL PODIUM", "Podium #" .. tostring(n))
            end
        else
            autoSellPodiumBox.Text = tostring(Config.AutoSellPodium or 0)
            ShowNotification("AUTO SELL PODIUM", "Invalid (use 0 - 50)")
        end
    end)
end
do
    local rShowAutoSellZone = CreateRow("Show Auto Sell Zone")
    CreateToggleSwitch(rShowAutoSellZone, Config.ShowAutoSellZone, function(ns, set)
        set(ns); Config.ShowAutoSellZone = ns; SaveConfig()
        if _G.ZawaHubAutoSell_SetVisualizer then
            _G.ZawaHubAutoSell_SetVisualizer(ns)
        end
        ShowNotification("AUTO SELL ZONE", ns and "VISIBLE" or "HIDDEN")
    end)
end
CreateSectionHeader("HIDE GUIS")
local rShowRemoteSell = CreateRow("Show Remote Sell")
CreateToggleSwitch(rShowRemoteSell, Config.ShowRemoteSell, function(ns, set)
    set(ns); Config.ShowRemoteSell = ns; SaveConfig()
    if _G.ZawaHubRemoteSell_SetEnabled then
        _G.ZawaHubRemoteSell_SetEnabled(ns)
    end
    ShowNotification("REMOTE SELL", ns and "ENABLED" or "DISABLED")
end)
local rShowInvisPanel = CreateRow("Show Invis Panel")
CreateToggleSwitch(rShowInvisPanel, Config.ShowInvisPanel, function(ns, set)
    set(ns); Config.ShowInvisPanel = ns; SaveConfig()
    local invGui = PlayerGui:FindFirstChild("XiInvisPanel")
    if invGui then invGui.Enabled = ns end
    ShowNotification("INVIS PANEL", ns and "SHOWN" or "HIDDEN")
end)
local rAutoInvis = CreateRow("Auto Invis During Steal")
CreateToggleSwitch(rAutoInvis, Config.AutoInvisDuringSteal, function(ns, set)
    set(ns); Config.AutoInvisDuringSteal = ns; _G.AutoInvisDuringSteal = ns; SaveConfig()
    ShowNotification("AUTO INVIS", ns and "ENABLED" or "DISABLED")
end)
local rHideAdminPanel = CreateRow("Hide Admin Panel GUI")
CreateToggleSwitch(rHideAdminPanel, Config.HideAdminPanel, function(ns, set)
    set(ns); Config.HideAdminPanel = ns; SaveConfig()
    local adUI = PlayerGui:FindFirstChild("XiAdminPanel")
    if adUI then adUI.Enabled = not ns end
    ShowNotification("HIDE ADMIN PANEL", ns and "ENABLED" or "DISABLED")
end)
local rHideAutoSteal = CreateRow("Hide Auto Steal GUI")
CreateToggleSwitch(rHideAutoSteal, Config.HideAutoSteal, function(ns, set)
    set(ns); Config.HideAutoSteal = ns; SaveConfig()
    local asUI = PlayerGui:FindFirstChild("AutoStealUI")
    if asUI then asUI.Enabled = not ns end
    ShowNotification("HIDE AUTO STEAL", ns and "ENABLED" or "DISABLED")
end)
local rCompactAutoSteal = CreateRow("Compact Auto Steal GUI")
CreateToggleSwitch(rCompactAutoSteal, Config.CompactAutoSteal, function(ns, set)
    set(ns); Config.CompactAutoSteal = ns; SaveConfig()
    local asUI = PlayerGui:FindFirstChild("AutoStealUI")
    if asUI and asUI:FindFirstChild("Frame") then
        local frame = asUI.Frame
        local mobileScale = IS_MOBILE and 0.6 or 1
        local targetHeight = ns and (5 * 44 + 135) or (540 * mobileScale)
        local tween = TweenService:Create(
            frame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            {Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, targetHeight)}
        )
        tween:Play()
        tween.Completed:Connect(function()
            SharedState.ListNeedsRedraw = true
            if SharedState.UpdateAutoStealUI then
                SharedState.UpdateAutoStealUI()
            end
        end)
    end
    ShowNotification("COMPACT AUTO STEAL", ns and "ENABLED" or "DISABLED")
end)
CreateSectionHeader("EXTRAS")   
switchTab("Keys")
local rResetKey = CreateRow("Reset")
local bResetKey = Instance.new("TextButton", rResetKey)
bResetKey.Size=UDim2.new(0,60,0,24); bResetKey.Position=UDim2.new(1,-70,0.5,-12)
bResetKey.BackgroundColor3=Theme.SurfaceHighlight; bResetKey.Text=Config.ResetKey
bResetKey.Font=Enum.Font.GothamBold; bResetKey.TextColor3=Theme.TextPrimary; bResetKey.TextSize=12
Instance.new("UICorner",bResetKey).CornerRadius=UDim.new(0,4)
bResetKey.MouseButton1Click:Connect(function()
    bResetKey.Text="..."; bResetKey.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.ResetKey=inp.KeyCode.Name; bResetKey.Text=inp.KeyCode.Name
            bResetKey.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("RESET KEYBIND", inp.KeyCode.Name)
        end
    end)
end)
switchTab("Misc")
local rAutoResetBalloon = CreateRow("Auto reset on balloon")
CreateToggleSwitch(rAutoResetBalloon, Config.AutoResetOnBalloon, function(ns, set)
    set(ns); Config.AutoResetOnBalloon = ns; SaveConfig()
    ShowNotification("AUTO RESET ON BALLOON", ns and "ENABLED" or "DISABLED")
end)
switchTab("Keys")
local rKickKey = CreateRow("Kick")
local bKickKey = Instance.new("TextButton", rKickKey)
bKickKey.Size=UDim2.new(0,60,0,24); bKickKey.Position=UDim2.new(1,-70,0.5,-12)
bKickKey.BackgroundColor3=Theme.SurfaceHighlight; bKickKey.Text=Config.KickKey ~= "" and Config.KickKey or "NONE"
bKickKey.Font=Enum.Font.GothamBold; bKickKey.TextColor3=Theme.TextPrimary; bKickKey.TextSize=12
Instance.new("UICorner",bKickKey).CornerRadius=UDim.new(0,4)
bKickKey.MouseButton1Click:Connect(function()
    bKickKey.Text="..."; bKickKey.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.KickKey=inp.KeyCode.Name; bKickKey.Text=inp.KeyCode.Name
            bKickKey.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("KICK KEYBIND", inp.KeyCode.Name)
        end
    end)
end)
local rAutoTurretKey = CreateRow("Auto Turret")
local bAutoTurretKey = Instance.new("TextButton", rAutoTurretKey)
bAutoTurretKey.Size=UDim2.new(0,60,0,24); bAutoTurretKey.Position=UDim2.new(1,-70,0.5,-12)
bAutoTurretKey.BackgroundColor3=Theme.SurfaceHighlight; bAutoTurretKey.Text=Config.AutoTurretKey ~= "" and Config.AutoTurretKey or "NONE"
bAutoTurretKey.Font=Enum.Font.GothamBold; bAutoTurretKey.TextColor3=Theme.TextPrimary; bAutoTurretKey.TextSize=12
Instance.new("UICorner",bAutoTurretKey).CornerRadius=UDim.new(0,4)
bAutoTurretKey.MouseButton1Click:Connect(function()
    bAutoTurretKey.Text="..."; bAutoTurretKey.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.AutoTurretKey=inp.KeyCode.Name; bAutoTurretKey.Text=inp.KeyCode.Name
            bAutoTurretKey.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("AUTO TURRET KEYBIND", inp.KeyCode.Name)
        end
    end)
end)
switchTab("Misc")
local rCleanErrors = CreateRow("Clean Error GUIs")
CreateToggleSwitch(rCleanErrors, Config.CleanErrorGUIs, function(ns, set)
    set(ns); Config.CleanErrorGUIs = ns; SaveConfig()
    ShowNotification("CLEAN ERROR GUIS", ns and "ENABLED" or "DISABLED")
end)
CreateSectionHeader("ADMIN PANEL")
local rClickToAP = CreateRow("Click To Admin Panel")
CreateToggleSwitch(rClickToAP, Config.ClickToAP, function(ns, set)
    set(ns); Config.ClickToAP = ns; SaveConfig()
    ShowNotification("CLICK TO AP", ns and "ENABLED" or "DISABLED")
end)
local rClickToAPSingle = CreateRow("Click To AP Single Command")
CreateToggleSwitch(rClickToAPSingle, Config.ClickToAPSingleCommand, function(ns, set)
    set(ns); Config.ClickToAPSingleCommand = ns; SaveConfig()
    ShowNotification("CLICK TO AP SINGLE", ns and "ENABLED" or "DISABLED")
end)
local rDisableClickToAPOnMoby = CreateRow("Disable Click To AP On Moby")
CreateToggleSwitch(rDisableClickToAPOnMoby, Config.DisableClickToAPOnMoby, function(ns, set)
    set(ns); Config.DisableClickToAPOnMoby = ns; SaveConfig()
    ShowNotification("DISABLE CLICK TO AP ON MOBY", ns and "ENABLED" or "DISABLED")
end)
local rDisableProximitySpamOnMoby = CreateRow("Disable Proximity AP On Moby")
CreateToggleSwitch(rDisableProximitySpamOnMoby, Config.DisableProximitySpamOnMoby, function(ns, set)
    set(ns); Config.DisableProximitySpamOnMoby = ns; SaveConfig()
    ShowNotification("DISABLE PROXIMITY AP ON MOBY", ns and "ENABLED" or "DISABLED")
end)
local rDisableAPPanelOnMoby = CreateRow("Disable AP Panel On Moby")
CreateToggleSwitch(rDisableAPPanelOnMoby, Config.DisableAPPanelOnMoby, function(ns, set)
    set(ns); Config.DisableAPPanelOnMoby = ns; SaveConfig()
    ShowNotification("DISABLE AP PANEL ON MOBY", ns and "ENABLED" or "DISABLED")
end)
local rDisableClickToAPOnKawaifu = CreateRow("Disable Click To AP On Kawaifu")
CreateToggleSwitch(rDisableClickToAPOnKawaifu, Config.DisableClickToAPOnKawaifu, function(ns, set)
    set(ns); Config.DisableClickToAPOnKawaifu = ns; SaveConfig()
    ShowNotification("DISABLE CLICK TO AP ON KAWAIFU", ns and "ENABLED" or "DISABLED")
end)
local rDisableProximitySpamOnKawaifu = CreateRow("Disable Proximity AP On Kawaifu")
CreateToggleSwitch(rDisableProximitySpamOnKawaifu, Config.DisableProximitySpamOnKawaifu, function(ns, set)
    set(ns); Config.DisableProximitySpamOnKawaifu = ns; SaveConfig()
    ShowNotification("DISABLE PROXIMITY AP ON KAWAIFU", ns and "ENABLED" or "DISABLED")
end)
local rDisableAPPanelOnKawaifu = CreateRow("Disable AP Panel On Kawaifu")
CreateToggleSwitch(rDisableAPPanelOnKawaifu, Config.DisableAPPanelOnKawaifu, function(ns, set)
    set(ns); Config.DisableAPPanelOnKawaifu = ns; SaveConfig()
    ShowNotification("DISABLE AP PANEL ON KAWAIFU", ns and "ENABLED" or "DISABLED")
end)
local rDisableClickToAPOnAtlas = CreateRow("Disable Click To AP On Atlas")
CreateToggleSwitch(rDisableClickToAPOnAtlas, Config.DisableClickToAPOnAtlas, function(ns, set)
    set(ns); Config.DisableClickToAPOnAtlas = ns; SaveConfig()
    ShowNotification("DISABLE CLICK TO AP ON ATLAS", ns and "ENABLED" or "DISABLED")
end)
local rDisableProximitySpamOnAtlas = CreateRow("Disable Proximity AP On Atlas")
CreateToggleSwitch(rDisableProximitySpamOnAtlas, Config.DisableProximitySpamOnAtlas, function(ns, set)
    set(ns); Config.DisableProximitySpamOnAtlas = ns; SaveConfig()
    ShowNotification("DISABLE PROXIMITY AP ON ATLAS", ns and "ENABLED" or "DISABLED")
end)
local rDisableAPPanelOnAtlas = CreateRow("Disable AP Panel On Atlas")
CreateToggleSwitch(rDisableAPPanelOnAtlas, Config.DisableAPPanelOnAtlas, function(ns, set)
    set(ns); Config.DisableAPPanelOnAtlas = ns; SaveConfig()
    ShowNotification("DISABLE AP PANEL ON ATLAS", ns and "ENABLED" or "DISABLED")
end)
local rDisableClickToAPOnBraintopia = CreateRow("Disable Click To AP On Braintopia")
CreateToggleSwitch(rDisableClickToAPOnBraintopia, Config.DisableClickToAPOnBraintopia, function(ns, set)
    set(ns); Config.DisableClickToAPOnBraintopia = ns; SaveConfig()
    ShowNotification("DISABLE CLICK TO AP ON BRAINTOPIA", ns and "ENABLED" or "DISABLED")
end)
local rDisableProximitySpamOnBraintopia = CreateRow("Disable Proximity AP On Braintopia")
CreateToggleSwitch(rDisableProximitySpamOnBraintopia, Config.DisableProximitySpamOnBraintopia, function(ns, set)
    set(ns); Config.DisableProximitySpamOnBraintopia = ns; SaveConfig()
    ShowNotification("DISABLE PROXIMITY AP ON BRAINTOPIA", ns and "ENABLED" or "DISABLED")
end)
local rDisableAPPanelOnBraintopia = CreateRow("Disable AP Panel On Braintopia")
CreateToggleSwitch(rDisableAPPanelOnBraintopia, Config.DisableAPPanelOnBraintopia, function(ns, set)
    set(ns); Config.DisableAPPanelOnBraintopia = ns; SaveConfig()
    ShowNotification("DISABLE AP PANEL ON BRAINTOPIA", ns and "ENABLED" or "DISABLED")
end)
local rHideKawaifuFromPanel = CreateRow("Hide Kawaifu From Panel")
CreateToggleSwitch(rHideKawaifuFromPanel, Config.HideKawaifuFromPanel, function(ns, set)
    set(ns); Config.HideKawaifuFromPanel = ns; SaveConfig()
    ShowNotification("HIDE KAWAIFU FROM PANEL", ns and "ENABLED" or "DISABLED")
end)
switchTab("Keys")
local rClickToAPKeybind = CreateRow("Click To AP Keybind")
local bClickToAPKeybind = Instance.new("TextButton", rClickToAPKeybind)
bClickToAPKeybind.Size=UDim2.new(0,60,0,24); bClickToAPKeybind.Position=UDim2.new(1,-65,0.5,-12)
bClickToAPKeybind.BackgroundColor3=Theme.SurfaceHighlight; bClickToAPKeybind.Text=Config.ClickToAPKeybind or "L"
bClickToAPKeybind.Font=Enum.Font.GothamBold; bClickToAPKeybind.TextColor3=Theme.TextPrimary; bClickToAPKeybind.TextSize=12
Instance.new("UICorner",bClickToAPKeybind).CornerRadius=UDim.new(0,4)
bClickToAPKeybind.MouseButton1Click:Connect(function()
    bClickToAPKeybind.Text="..."; bClickToAPKeybind.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.ClickToAPKeybind=inp.KeyCode.Name; bClickToAPKeybind.Text=inp.KeyCode.Name
            bClickToAPKeybind.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("CLICK TO AP KEYBIND", inp.KeyCode.Name)
        end
    end)
end)
local rProximityAPKeybind = CreateRow("Proximity AP Keybind")
local bProximityAPKeybind = Instance.new("TextButton", rProximityAPKeybind)
bProximityAPKeybind.Size=UDim2.new(0,60,0,24); bProximityAPKeybind.Position=UDim2.new(1,-70,0.5,-12)
bProximityAPKeybind.BackgroundColor3=Theme.SurfaceHighlight; bProximityAPKeybind.Text=Config.ProximityAPKeybind or "P"
bProximityAPKeybind.Font=Enum.Font.GothamBold; bProximityAPKeybind.TextColor3=Theme.TextPrimary; bProximityAPKeybind.TextSize=12
Instance.new("UICorner",bProximityAPKeybind).CornerRadius=UDim.new(0,4)
bProximityAPKeybind.MouseButton1Click:Connect(function()
    bProximityAPKeybind.Text="..."; bProximityAPKeybind.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.ProximityAPKeybind=inp.KeyCode.Name; bProximityAPKeybind.Text=inp.KeyCode.Name
            bProximityAPKeybind.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("PROXIMITY AP KEYBIND", inp.KeyCode.Name)
        end
    end)
end)
switchTab("Misc")
end 
task.wait() 
do 
CreateSectionHeader("ALERTS")
local rAlertsEnabled = CreateRow("Enable Alerts")
CreateToggleSwitch(rAlertsEnabled, Config.AlertsEnabled, function(ns, set)
    set(ns); Config.AlertsEnabled = ns; SaveConfig()
    ShowNotification("PRIORITY ALERTS", ns and "ENABLED" or "DISABLED")
end)
local rAlertSound = CreateRow("Alert Sound ID")
local soundBox = Instance.new("TextBox", rAlertSound)
soundBox.Size = UDim2.new(0, 180, 0, 24)
soundBox.Position = UDim2.new(1, -185, 0.5, -12)
soundBox.BackgroundColor3 = Theme.SurfaceHighlight
soundBox.Text = Config.AlertSoundID or "rbxassetid://6518811702"
soundBox.Font = Enum.Font.Gotham
soundBox.TextSize = 10
soundBox.TextColor3 = Theme.TextPrimary
soundBox.PlaceholderText = "Sound ID"
Instance.new("UICorner", soundBox).CornerRadius = UDim.new(0, 4)
soundBox.FocusLost:Connect(function()
    Config.AlertSoundID = soundBox.Text
    SaveConfig()
    ShowNotification("ALERT SOUND", "Updated")
end)
CreateSectionHeader("GRIEF DETECTOR")
local rGriefEnabled = CreateRow("Enable Grief Detector")
CreateToggleSwitch(rGriefEnabled, Config.GriefDetectorEnabled, function(ns, set)
    set(ns); Config.GriefDetectorEnabled = ns; SaveConfig()
    ShowNotification("GRIEF DETECTOR", ns and "ENABLED" or "DISABLED")
end)
local rGriefWebhook = CreateRow("Discord Webhook URL")
local webhookBox = Instance.new("TextBox", rGriefWebhook)
webhookBox.Size = UDim2.new(0, 180, 0, 24)
webhookBox.Position = UDim2.new(1, -185, 0.5, -12)
webhookBox.BackgroundColor3 = Theme.SurfaceHighlight
webhookBox.Text = Config.GriefDetectorWebhookURL or ""
webhookBox.Font = Enum.Font.Gotham
webhookBox.TextSize = 10
webhookBox.TextColor3 = Theme.TextPrimary
webhookBox.PlaceholderText = "https://discord.com/api/..."
webhookBox.ClearTextOnFocus = false
Instance.new("UICorner", webhookBox).CornerRadius = UDim.new(0, 4)
webhookBox.FocusLost:Connect(function()
    Config.GriefDetectorWebhookURL = webhookBox.Text
    SaveConfig()
    ShowNotification("GRIEF WEBHOOK", "Updated")
end)
CreateSectionHeader("JOB JOINER")
local rJoinerRow = CreateRow("Job ID Joiner")
CreateToggleSwitch(rJoinerRow, Config.ShowJobJoiner, function(ns, set)
    set(ns); Config.ShowJobJoiner = ns; SaveConfig()
    local gui = PlayerGui:FindFirstChild("XiJobJoiner")
    if gui then gui.Enabled = Config.ShowJobJoiner end
    ShowNotification("JOB ID JOINER", ns and "ENABLED" or "DISABLED")
end)
switchTab("Keys")
local rJoinerKey = CreateRow("Job Joiner Keybind")
local bJoinerKey = Instance.new("TextButton", rJoinerKey)
bJoinerKey.Size=UDim2.new(0,60,0,24); bJoinerKey.Position=UDim2.new(1,-70,0.5,-12)
bJoinerKey.BackgroundColor3=Theme.SurfaceHighlight; bJoinerKey.Text=Config.JobJoinerKey or "J"
bJoinerKey.Font=Enum.Font.GothamBold; bJoinerKey.TextColor3=Theme.TextPrimary; bJoinerKey.TextSize=12
Instance.new("UICorner",bJoinerKey).CornerRadius=UDim.new(0,4)
bJoinerKey.MouseButton1Click:Connect(function()
    bJoinerKey.Text="..."; bJoinerKey.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.JobJoinerKey=inp.KeyCode.Name; bJoinerKey.Text=inp.KeyCode.Name
            bJoinerKey.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("JOB JOINER KEYBIND", inp.KeyCode.Name)
        end
    end)
end)
switchTab("Misc")
end 
task.wait() 
do 
CreateSectionHeader("PROTECTION")
local rAntiBeeDisco = CreateRow("Anti-Bee & Anti-Disco")
CreateToggleSwitch(rAntiBeeDisco, Config.AntiBeeDisco, function(ns, set)
    set(ns); Config.AntiBeeDisco = ns; SaveConfig()
    if ns then
        if _G.ANTI_BEE_DISCO and _G.ANTI_BEE_DISCO.Enable then
            _G.ANTI_BEE_DISCO.Enable()
        end
    else
        if _G.ANTI_BEE_DISCO and _G.ANTI_BEE_DISCO.Disable then
            _G.ANTI_BEE_DISCO.Disable()
        end
    end
    ShowNotification("ANTI-BEE & DISCO", ns and "ENABLED" or "DISABLED")
end)
end 
CreateSectionHeader("CAMERA")
local rFOV = CreateRow("FOV")
local fovSliderBg = Instance.new("Frame", rFOV)
fovSliderBg.Size = UDim2.new(0, 140, 0, 5)
fovSliderBg.Position = UDim2.new(1, -200, 0.5, -2.5)
fovSliderBg.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
Instance.new("UICorner", fovSliderBg).CornerRadius = UDim.new(1, 0)
local fovFill = Instance.new("Frame", fovSliderBg)
fovFill.BackgroundColor3 = Theme.Accent1
fovFill.Size = UDim2.new(0, 0, 1, 0)
Instance.new("UICorner", fovFill).CornerRadius = UDim.new(1, 0)
local fovKnob = Instance.new("Frame", fovSliderBg)
fovKnob.Size = UDim2.new(0, 12, 0, 12)
fovKnob.BackgroundColor3 = Theme.TextPrimary
fovKnob.AnchorPoint = Vector2.new(0.5, 0.5)
fovKnob.Position = UDim2.new(0, 0, 0.5, 0)
Instance.new("UICorner", fovKnob).CornerRadius = UDim.new(1, 0)
local fovKnobStroke = Instance.new("UIStroke", fovKnob)
fovKnobStroke.Color = Theme.Accent1
fovKnobStroke.Thickness = 1.5
fovKnobStroke.Transparency = 0.2
local fovValLbl = Instance.new("TextLabel", rFOV)
fovValLbl.Size = UDim2.new(0, 40, 0, 20)
fovValLbl.Position = UDim2.new(1, -50, 0.5, -10)
fovValLbl.BackgroundTransparency = 1
fovValLbl.Text = string.format("%.1f", Config.FOV)
fovValLbl.TextColor3 = Theme.TextPrimary
fovValLbl.Font = Enum.Font.GothamBold
fovValLbl.TextSize = 13
local function updateFOVSlider(val)
    val = math.clamp(val, 30, 180)
    Config.FOV = val
    SaveConfig()
    fovValLbl.Text = string.format("%.1f", val)
    local pct = (val - 30) / 150
    fovFill.Size = UDim2.new(pct, 0, 1, 0)
    fovKnob.Position = UDim2.new(pct, 0, 0.5, 0)
    if Workspace.CurrentCamera then
        Workspace.CurrentCamera.FieldOfView = val
    end
    ShowNotification("FIELD OF VIEW", string.format("%.1f", val))
end
updateFOVSlider(Config.FOV)
local fovDragging = false
fovSliderBg.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fovDragging = true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fovDragging = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if fovDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local x = i.Position.X
        local r = fovSliderBg.AbsolutePosition.X
        local w = fovSliderBg.AbsoluteSize.X
        local p = (x - r) / w
        updateFOVSlider(30 + (p * 150))
    end
end)
local rFOVReset = CreateRow("Reset FOV")
local bFOVReset = Instance.new("TextButton", rFOVReset)
bFOVReset.Size = UDim2.new(0, 60, 0, 24)
bFOVReset.Position = UDim2.new(1, -70, 0.5, -12)
bFOVReset.BackgroundColor3 = Theme.SurfaceHighlight
bFOVReset.Text = "Reset"
bFOVReset.Font = Enum.Font.GothamBold
bFOVReset.TextColor3 = Theme.TextPrimary
bFOVReset.TextSize = 12
Instance.new("UICorner", bFOVReset).CornerRadius = UDim.new(0, 4)
bFOVReset.MouseButton1Click:Connect(function()
    updateFOVSlider(70)
    ShowNotification("FIELD OF VIEW", "Reset to 70")
end)
CreateSectionHeader("MENU")
if not IS_MOBILE then
    local rMenu = CreateRow("Menu Toggle Key")
    local bMenu = Instance.new("TextButton", rMenu)
    bMenu.Size=UDim2.new(0,80,0,24); bMenu.Position=UDim2.new(1,-90,0.5,-12)
    bMenu.BackgroundColor3=Theme.SurfaceHighlight; bMenu.Text=Config.MenuKey
    bMenu.Font=Enum.Font.GothamBold; bMenu.TextColor3=Theme.TextPrimary; bMenu.TextSize=12
    Instance.new("UICorner",bMenu).CornerRadius=UDim.new(0,4)
    bMenu.MouseButton1Click:Connect(function()
        bMenu.Text="..."; bMenu.TextColor3=Theme.Accent1
        local con; con=UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                Config.MenuKey=inp.KeyCode.Name; bMenu.Text=inp.KeyCode.Name
                bMenu.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
                ShowNotification("MENU KEYBIND", inp.KeyCode.Name)
            end
        end)
    end)
else
    CreateRow("Menu Toggle: Touch Icon")
end
CreateSectionHeader("UI CONTROLS")
local rLock = CreateRow("Lock UI Dragging")
CreateToggleSwitch(rLock, Config.UILocked, function(ns, set)
    set(ns); Config.UILocked = ns; SaveConfig()
    ShowNotification("UI LOCK", ns and "ENABLED" or "DISABLED")
end)
if IS_MOBILE then
    local scaleUI = {}
    scaleUI.row = CreateRow("Mobile GUI Scale")
    scaleUI.bg = Instance.new("Frame", scaleUI.row)
    scaleUI.bg.Size = UDim2.new(0, 140, 0, 5)
    scaleUI.bg.Position = UDim2.new(1, -200, 0.5, -2.5)
    scaleUI.bg.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
    Instance.new("UICorner", scaleUI.bg).CornerRadius = UDim.new(1, 0)
    scaleUI.fill = Instance.new("Frame", scaleUI.bg)
    scaleUI.fill.BackgroundColor3 = Theme.Accent1
    scaleUI.fill.BorderSizePixel = 0
    scaleUI.fill.Size = UDim2.new(0, 0, 1, 0)
    Instance.new("UICorner", scaleUI.fill).CornerRadius = UDim.new(1, 0)
    scaleUI.knob = Instance.new("Frame", scaleUI.bg)
    scaleUI.knob.Size = UDim2.new(0, 14, 0, 14)
    scaleUI.knob.AnchorPoint = Vector2.new(0.5, 0.5)
    scaleUI.knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    scaleUI.knob.BorderSizePixel = 0
    Instance.new("UICorner", scaleUI.knob).CornerRadius = UDim.new(1, 0)
    scaleUI.stroke = Instance.new("UIStroke", scaleUI.knob)
    scaleUI.stroke.Color = Theme.Accent1
    scaleUI.stroke.Thickness = 2
    scaleUI.readout = Instance.new("TextLabel", scaleUI.row)
    scaleUI.readout.Size = UDim2.new(0, 50, 0, 20)
    scaleUI.readout.Position = UDim2.new(1, -145, 0.5, -10)
    scaleUI.readout.BackgroundTransparency = 1
    scaleUI.readout.Text = string.format("%.1f", Config.MobileGuiScale or 0.5)
    scaleUI.readout.Font = Enum.Font.GothamBold
    scaleUI.readout.TextSize = 11
    scaleUI.readout.TextColor3 = Theme.Accent1
    scaleUI.readout.TextXAlignment = Enum.TextXAlignment.Right
    scaleUI.dragging = false
    scaleUI.min = 0.1
    scaleUI.max = 1.0
    scaleUI.scaleToT = function(s)
        return math.clamp((s - scaleUI.min) / (scaleUI.max - scaleUI.min), 0, 1)
    end
    scaleUI.updateScaleSlider = function(val)
        local c = math.clamp(val, scaleUI.min, scaleUI.max)
        Config.MobileGuiScale = c
        SaveConfig()
        scaleUI.fill.Size = UDim2.new(scaleUI.scaleToT(c), 0, 1, 0)
        scaleUI.knob.Position = UDim2.new(0, scaleUI.scaleToT(c) * scaleUI.bg.AbsoluteSize.X, 0.5, 0)
        scaleUI.readout.Text = string.format("%.2f", c)
        if SharedState.RefreshMobileScale then SharedState.RefreshMobileScale() end
    end
    task.defer(function() scaleUI.updateScaleSlider(Config.MobileGuiScale or 0.5) end)
    scaleUI.onScaleInput = function(pos)
        scaleUI.updateScaleSlider(scaleUI.min + math.clamp((pos.X - scaleUI.bg.AbsolutePosition.X) / scaleUI.bg.AbsoluteSize.X, 0, 1) * (scaleUI.max - scaleUI.min))
    end
    scaleUI.bg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            scaleUI.dragging = true
            scaleUI.onScaleInput(inp.Position)
        end
    end)
    scaleUI.knob.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            scaleUI.dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            scaleUI.dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if scaleUI.dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            scaleUI.onScaleInput(inp.Position)
        end
    end)
end
local rReset = CreateRow("Reset UI Positions")
local bReset = Instance.new("TextButton", rReset)
bReset.Size=UDim2.new(0,80,0,24); bReset.Position=UDim2.new(1,-90,0.5,-12)
bReset.BackgroundColor3=Theme.Error; bReset.Text="RESET"
bReset.Font=Enum.Font.GothamBold; bReset.TextColor3=Theme.TextPrimary; bReset.TextSize=12
Instance.new("UICorner",bReset).CornerRadius=UDim.new(0,4)
bReset.MouseButton1Click:Connect(function()
    Config.Positions = DefaultConfig.Positions
    SaveConfig()
    ShowNotification("UI RESET", "Positions restored")
    sFrame.Position = UDim2.new(DefaultConfig.Positions.Settings.X, 0, DefaultConfig.Positions.Settings.Y, 0)
    if PlayerGui:FindFirstChild("AutoStealUI") then
        PlayerGui.AutoStealUI.Frame.Position = UDim2.new(DefaultConfig.Positions.AutoSteal.X, 0, DefaultConfig.Positions.AutoSteal.Y, 0)
    end
    if PlayerGui:FindFirstChild("StealSpeedUI") then
        PlayerGui.StealSpeedUI.Frame.Position = UDim2.new(DefaultConfig.Positions.StealSpeed.X, 0, DefaultConfig.Positions.StealSpeed.Y, 0)
    end
    if PlayerGui:FindFirstChild("XiAdminPanel") and PlayerGui.XiAdminPanel:FindFirstChild("Frame") then
        PlayerGui.XiAdminPanel.Frame.Position = UDim2.new(DefaultConfig.Positions.AdminPanel.X, 0, DefaultConfig.Positions.AdminPanel.Y, 0)
    end
    if PlayerGui:FindFirstChild("XiInvisPanel") and PlayerGui.XiInvisPanel:FindFirstChild("Frame") then
        PlayerGui.XiInvisPanel.Frame.Position = UDim2.new(DefaultConfig.Positions.InvisPanel.X, 0, DefaultConfig.Positions.InvisPanel.Y, 0)
    end
    ShowNotification("UI RESET", "Positions restored to default")
end)
local _settingsPanelScale = sFrame:FindFirstChild("__PanelResizeScale")
local function updateSettingsCanvasSize()
    local scale = (_settingsPanelScale and _settingsPanelScale.Scale) or 1
    if scale <= 0 then scale = 1 end
    for _, page in pairs(tabPages) do
        local h = page.Layout.AbsoluteContentSize.Y
        local minH = page.Frame.AbsoluteSize.Y / scale
        page.Frame.CanvasSize = UDim2.new(0, 0, 0, math.max(h + 80, minH))
    end
end
for _, page in pairs(tabPages) do
    page.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSettingsCanvasSize)
    page.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSettingsCanvasSize)
end
if _settingsPanelScale then
    _settingsPanelScale:GetPropertyChangedSignal("Scale"):Connect(function()
        task.defer(updateSettingsCanvasSize)
    end)
end
task.defer(updateSettingsCanvasSize)
if IS_MOBILE then
    for _, page in pairs(tabPages) do
        page.Frame.ScrollBarThickness = 6
        page.Frame.ScrollingEnabled = true
        page.Frame.ElasticBehavior = Enum.ElasticBehavior.Always
    end
end
if not IS_MOBILE then
    UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == (Enum.KeyCode[Config.MenuKey] or Enum.KeyCode.LeftControl) then
            settingsGui.Enabled = not settingsGui.Enabled
        end
        if Config.KickKey ~= "" and input.KeyCode == Enum.KeyCode[Config.KickKey] then
            kickPlayer()
        end
        if Config.AutoTurretKey ~= "" and input.KeyCode == Enum.KeyCode[Config.AutoTurretKey] then
            Config.AutoDestroyTurrets = not Config.AutoDestroyTurrets
            SaveConfig()
            ShowNotification("AUTO TURRET", Config.AutoDestroyTurrets and "ENABLED" or "DISABLED")
        end
        if Config.RagdollSelfKey ~= "" and input.KeyCode == Enum.KeyCode[Config.RagdollSelfKey] then
            if not isOnCooldown("ragdoll") then
                if runAdminCommand(LocalPlayer, "ragdoll") then
                    if _G._ZawaHub_MarkSelfRagdoll then _G._ZawaHub_MarkSelfRagdoll() end
                    activeCooldowns["ragdoll"] = tick()
                    setGlobalVisualCooldown("ragdoll")
                    ShowNotification("RAGDOLL SELF", "Ragdolled " .. LocalPlayer.Name)
                end
            else
                ShowNotification("RAGDOLL SELF", "Ragdoll on cooldown")
            end
        end
        if Config.ProximityAPKeybind and input.KeyCode == Enum.KeyCode[Config.ProximityAPKeybind] then
            ProximityAPActive = not ProximityAPActive
            if SharedState.ProximityAPButton then
                updateProximityAPButton()
            end
            ShowNotification("PROXIMITY AP", ProximityAPActive and "ENABLED" or "DISABLED")
        end
        if input.KeyCode == (Enum.KeyCode[Config.ClickToAPKeybind] or Enum.KeyCode.L) then
            Config.ClickToAP = not Config.ClickToAP
            SaveConfig()
            ShowNotification("CLICK TO AP", Config.ClickToAP and "ENABLED" or "DISABLED")
        end
        if Config.JobJoinerKey and input.KeyCode == Enum.KeyCode[Config.JobJoinerKey] then
            local joinerGui = PlayerGui:FindFirstChild("XiJobJoiner")
            if joinerGui then
                Config.ShowJobJoiner = not Config.ShowJobJoiner
                joinerGui.Enabled = Config.ShowJobJoiner
                SaveConfig()
                ShowNotification("JOB ID JOINER", Config.ShowJobJoiner and "OPENED" or "CLOSED")
            end
        end
    end)
end
end) 
task.spawn(function()
    task.wait(1)
    if Config.HideAdminPanel then
        local adUI = PlayerGui:FindFirstChild("XiAdminPanel")
        if adUI then adUI.Enabled = false end
    end
    if Config.HideAutoSteal then
        local asUI = PlayerGui:FindFirstChild("AutoStealUI")
        if asUI then asUI.Enabled = false end
    end
    if Config.CompactAutoSteal then
        local asUI = PlayerGui:FindFirstChild("AutoStealUI")
        if asUI and asUI:FindFirstChild("Frame") then
            local frame = asUI.Frame
            local mobileScale = IS_MOBILE and 0.6 or 1
            frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, 5 * 44 + 135)
        end
    end
end)
do
    local SWAP_DISTANCE_THRESHOLD = 15      
    local SWAPPER_MATCH_RADIUS    = 50      
    local SWAP_BACK_COOLDOWN      = 1.5     
    local SELF_TP_IGNORE_WINDOW   = 0.5     
    local lastPos              = nil
    local lastSwapBackAt       = 0
    local lastSelfTpAt         = 0
    local activeConn           = nil
    local tpClearedAt          = 0    
    local otherLastPos         = {}   
    local pendingSwap          = nil  
    _G.MarkSelfTeleport = function()
        lastSelfTpAt = os.clock()
    end
    local function isLocalSelfTeleporting()
        if (os.clock() - lastSelfTpAt) < SELF_TP_IGNORE_WINDOW then return true end
        if LocalPlayer:GetAttribute("Stealing") then return true end
        if State and State.isTpMoving then
            tpClearedAt = os.clock()  
            return true
        end
        if (os.clock() - tpClearedAt) < 3 then return true end
        return false
    end
    local function findBodySwapPotion()
        local char = LocalPlayer.Character
        local bp   = LocalPlayer:FindFirstChildOfClass("Backpack")
        if char then
            local t = char:FindFirstChild("Body Swap Potion")
            if t and t:IsA("Tool") then return t end
        end
        if bp then
            local t = bp:FindFirstChild("Body Swap Potion")
            if t and t:IsA("Tool") then return t end
        end
        return nil
    end
    local function findSwapperAt(oldPos, myNewPos)
        local best, bestDist = nil, SWAPPER_MATCH_RADIUS
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local c   = plr.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = (hrp.Position - oldPos).Magnitude
                    if d < bestDist then
                        best, bestDist = plr, d
                    end
                end
            end
        end
        return best
    end
    local function fireBodySwapAt(targetPlayer)
        local potion = findBodySwapPotion()
        if not potion then
            ShowNotification("ANTI BODY SWAP", "No Body Swap Potion in inventory")
            return false
        end
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not (hum and hrp) then return false end
        local tChar = targetPlayer.Character
        local tHRP  = tChar and tChar:FindFirstChild("HumanoidRootPart")
        if not tHRP then return false end
        local targetPos = tHRP.Position
        pcall(function()
            Camera.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 1.5, 0), targetPos)
        end)
        if potion.Parent == char then
            pcall(function() potion:Activate() end)
        else
            pcall(function() hum:EquipTool(potion) end)
            pcall(function() potion:Activate() end)
            task.wait(0.02)
            pcall(function() potion:Activate() end)
        end
        return true
    end
    local function onHeartbeat()
        if not Config.AntiBodySwap then
            lastPos = nil
            return
        end
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            lastPos = nil
            return
        end
        local pos = hrp.Position
        if lastPos then
            local myJump = (pos - lastPos).Magnitude
            if myJump >= SWAP_DISTANCE_THRESHOLD
                and not isLocalSelfTeleporting()
                and (os.clock() - lastSwapBackAt) >= SWAP_BACK_COOLDOWN then
                if not pendingSwap then
                    pendingSwap = { oldPos = lastPos, newPos = pos, until_ = os.clock() + 1.0 }
                end
            end
        end
        if pendingSwap then
            if os.clock() > pendingSwap.until_ then
                pendingSwap = nil
            else
                local swapper = findSwapperAt(pendingSwap.oldPos, pendingSwap.newPos)
                if swapper then
                    lastSwapBackAt = os.clock()
                    pendingSwap    = nil
                    ShowNotification("BODY SWAPPED", "Swapping back with " .. swapper.Name)
                    task.spawn(function()
                        fireBodySwapAt(swapper)
                    end)
                end
            end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local c = plr.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    otherLastPos[plr] = hrp.Position
                end
            end
        end
        lastPos = pos
    end
    activeConn = RunService.Heartbeat:Connect(onHeartbeat)
    LocalPlayer.CharacterAdded:Connect(function()
        lastPos = nil
        task.wait(0.5)
        lastPos = nil
    end)
end
LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
    local isStealing = LocalPlayer:GetAttribute("Stealing")
    local wasStealing = not isStealing 
    if isStealing then
        if Config.AutoUnlockOnSteal then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local playerY = hrp.Position.Y
                local maxY = nil
                if playerY < 10 then
                    maxY = 10
                elseif playerY < 35 then
                    maxY = 35
                end
                task.spawn(function()
                    task.wait(0.1)
                    triggerClosestUnlock(playerY, maxY)
                end)
            end
        end
     elseif wasStealing then
        task.spawn(function()
            task.wait(0.15)
            if LocalPlayer:GetAttribute("Stealing") then return end 
            local pets = get_all_pets()
            local petData = pets[selectedTargetIndex]
            if not petData then return end
            local part = findAdorneeGlobal(petData.animalData)
            if not part then return end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 5, 0))
        end)
    end
end)
task.spawn(function()
    local stealSpeedEnabled = false
    local STEAL_SPEED = Config.StealSpeed or 25.5
    local stealConn = nil
    local function doDisable()
        stealSpeedEnabled = false
        if stealConn then stealConn:Disconnect(); stealConn=nil end
    end
    SharedState.DisableStealSpeed = function()
        doDisable()
        if SharedState._ssUpdateBtn then SharedState._ssUpdateBtn() end
    end
    local function doEnable()
        stealSpeedEnabled = true
        if stealConn then stealConn:Disconnect(); stealConn=nil end
        local _scActive = true
        local _scThread = task.spawn(function()
            while _scActive do
                task.wait(0.03)
                local char = LocalPlayer.Character; if not char then continue end
                local hum = char:FindFirstChildOfClass("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hum or not hrp then continue end
                local md = hum.MoveDirection
                if md.Magnitude > 0 then
                    hrp.Velocity = Vector3.new(md.X * STEAL_SPEED, hrp.Velocity.Y, md.Z * STEAL_SPEED)
                end
            end
        end)
        stealConn = {Disconnect = function() _scActive = false; task.cancel(_scThread) end}
    end
    local ssGui = Instance.new("ScreenGui")
    ssGui.Name = "StealSpeedUI"; ssGui.ResetOnSpawn = false
    ssGui.Enabled = Config.ShowStealSpeedPanel
    ssGui.Parent = PlayerGui
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        ssGui.Enabled = Config.ShowStealSpeedPanel
    end)
    local ssFrame = Instance.new("Frame")
    local mobileScale = IS_MOBILE and 0.6 or 1
    local ssHeight = IS_MOBILE and 126 or (126 * mobileScale)
    ssFrame.Size = UDim2.new(0, 300 * mobileScale, 0, ssHeight)
    ssFrame.Position = UDim2.new(
        Config.Positions.StealSpeed.X, 0,
        Config.Positions.StealSpeed.Y, 0)
    ssFrame.BackgroundColor3 = Theme.Background; ssFrame.BackgroundTransparency = 0.05
    ssFrame.BorderSizePixel = 0; ssFrame.Parent = ssGui
    ApplyViewportUIScale(ssFrame, 300, 126, 0.55, 1)
    Instance.new("UICorner", ssFrame).CornerRadius = UDim.new(0,12)
    local ssStroke = Instance.new("UIStroke", ssFrame)
    ssStroke.Color=Theme.Accent2; ssStroke.Thickness=1.5; ssStroke.Transparency=0.4
    CreateGradient(ssStroke)
    local ssDragHandle = Instance.new("Frame", ssFrame)
    ssDragHandle.Size = UDim2.new(1,0,0,38)
    ssDragHandle.BackgroundTransparency = 1
    MakeDraggable(ssDragHandle, ssFrame, "StealSpeed")
    AddResizeHandle(ssFrame, "StealSpeed", UDim2.new(1, -22, 0, 6))
    local ssTitle = Instance.new("TextLabel", ssDragHandle)
    ssTitle.Size = UDim2.new(1,-15,1,0); ssTitle.Position = UDim2.new(0,15,0,0)
    ssTitle.BackgroundTransparency=1; ssTitle.Text="STEAL SPEED"
    ssTitle.Font=Enum.Font.GothamBlack; ssTitle.TextSize=15
    ssTitle.TextColor3=Theme.TextPrimary; ssTitle.TextXAlignment=Enum.TextXAlignment.Left
    local speedReadout = Instance.new("TextLabel", ssFrame)
    speedReadout.Size = UDim2.new(0,56,0,38); speedReadout.Position = UDim2.new(1,-66,0,0)
    speedReadout.BackgroundTransparency=1
    speedReadout.Text=string.format("%.1f", STEAL_SPEED)
    speedReadout.Font=Enum.Font.GothamBlack; speedReadout.TextSize=15
    speedReadout.TextColor3=Theme.Accent1; speedReadout.TextXAlignment=Enum.TextXAlignment.Right
    local SLIDER_X_PAD = 16
    local sliderBg = Instance.new("Frame", ssFrame)
    sliderBg.Size = UDim2.new(1,-SLIDER_X_PAD*2,0,6)
    sliderBg.Position = UDim2.new(0,SLIDER_X_PAD,0,46)
    sliderBg.BackgroundColor3=Theme.SurfaceHighlight; sliderBg.BorderSizePixel=0
    Instance.new("UICorner",sliderBg).CornerRadius=UDim.new(1,0)
    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.BackgroundColor3=Theme.Accent1; sliderFill.BorderSizePixel=0; sliderFill.Size=UDim2.new(0,0,1,0)
    Instance.new("UICorner",sliderFill).CornerRadius=UDim.new(1,0)
    local knob = Instance.new("Frame", ssFrame)
    knob.Size = UDim2.new(0,16,0,16); knob.AnchorPoint = Vector2.new(0.5,0.5)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local knobStroke=Instance.new("UIStroke",knob); knobStroke.Color=Theme.Accent1; knobStroke.Thickness=2
    local MIN_SPEED,MAX_SPEED = 5, 100
    local function speedToT(s) return math.clamp((s-MIN_SPEED)/(MAX_SPEED-MIN_SPEED),0,1) end
    local function updateSlider(s)
        STEAL_SPEED = math.clamp(s, MIN_SPEED, MAX_SPEED)
        Config.StealSpeed = STEAL_SPEED; SaveConfig()
        local t = speedToT(STEAL_SPEED)
        sliderFill.Size = UDim2.new(t,0,1,0)
        local frameW = ssFrame.AbsoluteSize.X
        local trackW = frameW - SLIDER_X_PAD*2
        local knobX = SLIDER_X_PAD + t*trackW
        knob.Position = UDim2.new(0, knobX, 0, 46+3)
        speedReadout.Text = string.format("%.1f", STEAL_SPEED)
    end
    task.defer(function() updateSlider(STEAL_SPEED) end)
    ssFrame.Changed:Connect(function(prop)
        if prop=="AbsoluteSize" then updateSlider(STEAL_SPEED) end
    end)
    local sliderDragging = false
    local function onSliderInput(pos)
        local trackLeft = sliderBg.AbsolutePosition.X
        local trackRight = trackLeft + sliderBg.AbsoluteSize.X
        local t = math.clamp((pos.X - trackLeft)/(trackRight-trackLeft), 0, 1)
        updateSlider(MIN_SPEED + t*(MAX_SPEED-MIN_SPEED))
    end
    sliderBg.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            sliderDragging=true; onSliderInput(inp.Position)
        end
    end)
    knob.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then sliderDragging=true end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then sliderDragging=false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if sliderDragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
            onSliderInput(inp.Position)
        end
    end)
    local minLbl=Instance.new("TextLabel",ssFrame)
    minLbl.Size=UDim2.new(0,30,0,14); minLbl.Position=UDim2.new(0,SLIDER_X_PAD,0,55)
    minLbl.BackgroundTransparency=1; minLbl.Text="5"
    minLbl.Font=Enum.Font.GothamMedium; minLbl.TextSize=10
    minLbl.TextColor3=Theme.TextSecondary; minLbl.TextXAlignment=Enum.TextXAlignment.Left
    local maxLbl=Instance.new("TextLabel",ssFrame)
    maxLbl.Size=UDim2.new(0,36,0,14); maxLbl.Position=UDim2.new(1,-SLIDER_X_PAD-36,0,55)
    maxLbl.BackgroundTransparency=1; maxLbl.Text="100"
    maxLbl.Font=Enum.Font.GothamMedium; maxLbl.TextSize=10
    maxLbl.TextColor3=Theme.TextSecondary; maxLbl.TextXAlignment=Enum.TextXAlignment.Right
    local ssBtn = Instance.new("TextButton", ssFrame)
    ssBtn.Size=UDim2.new(1,-32,0,34); ssBtn.Position=UDim2.new(0,16,1,-48)
    ssBtn.BackgroundColor3=Theme.SurfaceHighlight
    ssBtn.Text="DISABLED"; ssBtn.Font=Enum.Font.GothamBold
    ssBtn.TextSize=13; ssBtn.TextColor3=Theme.TextPrimary
    Instance.new("UICorner",ssBtn).CornerRadius=UDim.new(0,8)
    local function updateBtnVisual()
        ssBtn.Text = stealSpeedEnabled and "ENABLED" or "DISABLED"
        ssBtn.BackgroundColor3 = stealSpeedEnabled and Theme.Success or Theme.SurfaceHighlight
    end
    SharedState._ssUpdateBtn = updateBtnVisual
    SharedState.StealSpeedToggleFunc = function()
        if stealSpeedEnabled then doDisable() else doEnable() end
        updateBtnVisual()
    end
    ssBtn.MouseButton1Click:Connect(function()
        SharedState.StealSpeedToggleFunc()
    end)
    task.spawn(function()
        local lastHadSteal = nil
        while true do
            task.wait(0.3)
            if not Config.AutoStealSpeed then lastHadSteal = nil; continue end
            local hasSteal = (LocalPlayer:GetAttribute("Stealing") == true)
            if lastHadSteal == hasSteal then continue end
            lastHadSteal = hasSteal
            if hasSteal and not stealSpeedEnabled then
                doEnable(); updateBtnVisual()
            elseif not hasSteal and stealSpeedEnabled then
                doDisable(); if SharedState._ssUpdateBtn then SharedState._ssUpdateBtn() end
            end
        end
    end)
end)
task.spawn(function()
    local brainrotESPEnabled = Config.BrainrotESP
    local brainrotESPFolder = Instance.new("Folder")
    brainrotESPFolder.Name = "XiBrainrotESP"
    brainrotESPFolder.Parent = Workspace
    local brainrotBillboards = {}
    local hiddenOverheads = {}
    local MUT_COLORS = {
        Cursed = Color3.fromRGB(255, 50, 50),
        Gold = Color3.fromRGB(255, 215, 0),
        Diamond = Color3.fromRGB(0, 255, 255),
        YinYang = Color3.fromRGB(220, 220, 220),
        Rainbow = Color3.fromRGB(255, 100, 200),
        Lava = Color3.fromRGB(255, 100, 20),
        Candy = Color3.fromRGB(255, 105, 180),
        Bloodrot = Color3.fromRGB(139, 0, 0),
        Radioactive = Color3.fromRGB(0, 255, 0),
        Divine = Color3.fromRGB(255, 255, 255)
    }
    local function getOwnerHeldTool(data)
        if not data.owner then return nil end
        local ownerPlr = Players:FindFirstChild(data.owner)
        if not ownerPlr or not ownerPlr.Character then return nil end
        for _, obj in ipairs(ownerPlr.Character:GetChildren()) do
            if obj:IsA("Tool") then return obj.Name end
        end
        return nil
    end
    local function getPlotSide(plotName)
        if not plotName then return nil end
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return nil end
        local plot = plots:FindFirstChild(plotName)
        if not plot then return nil end
        local sign = plot:FindFirstChild("PlotSign")
        if not sign then return nil end
        local textLabel = sign:FindFirstChild("SurfaceGui")
            and sign.SurfaceGui:FindFirstChild("Frame")
            and sign.SurfaceGui.Frame:FindFirstChild("TextLabel")
        if not textLabel then
            textLabel = sign:FindFirstChildWhichIsA("SurfaceGui", true)
            textLabel = textLabel and textLabel:FindFirstChildWhichIsA("TextLabel", true)
        end
        if not textLabel then return nil end
        local txt = textLabel.Text or ""
        if txt:lower():find("side%s*1") then return "Side 1"
        elseif txt:lower():find("side%s*2") then return "Side 2"
        end
        return nil
    end
    local function createBrainrotBillboard(data)
        local bb = Instance.new("BillboardGui")
        bb.Name = "BrainrotESP_" .. data.uid
        bb.Size = UDim2.new(0, 220, 0, 54)
        bb.StudsOffset = Vector3.new(0, 1.8, 0)
        bb.AlwaysOnTop = true
        bb.LightInfluence = 0
        bb.MaxDistance = 3000
        local hasMut = data.mutation and data.mutation ~= "None" and data.mutation ~= "N/A"
        local nameColor = hasMut and (MUT_COLORS[data.mutation] or Color3.fromRGB(200, 100, 255)) or Color3.fromRGB(255, 220, 0)
        local heldTool = getOwnerHeldTool(data)
        local isDanger = heldTool and DANGER_TOOLS[heldTool] or false
        if isDanger then nameColor = Color3.fromRGB(255, 60, 60) end
        if isDanger then bb.Size = UDim2.new(0, 220, 0, 80) end
        if hasMut then
            local mutBadge = Instance.new("TextLabel", bb)
            mutBadge.Size = UDim2.new(1, 0, 0, 18)
            mutBadge.Position = UDim2.new(0, 0, 0, -20)
            mutBadge.BackgroundTransparency = 1
            mutBadge.Font = Enum.Font.GothamBlack
            mutBadge.TextSize = 14
            mutBadge.TextColor3 = nameColor
            mutBadge.TextStrokeTransparency = 0
            mutBadge.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            mutBadge.Text = data.mutation
            mutBadge.TextXAlignment = Enum.TextXAlignment.Center
        end
        local container = Instance.new("Frame", bb)
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        container.BackgroundTransparency = 0.65
        container.BorderSizePixel = 0
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
        local nameLabel = Instance.new("TextLabel", container)
        nameLabel.Size = UDim2.new(1, -8, 0, 26)
        nameLabel.Position = UDim2.new(0, 4, 0, 3)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamBlack
        nameLabel.TextSize = 20
        nameLabel.TextColor3 = nameColor
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Text = (data.name or data.petName) or "???"
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        nameLabel.TextScaled = false
        local genLabel = Instance.new("TextLabel", container)
        genLabel.Size = UDim2.new(1, -8, 0, 20)
        genLabel.Position = UDim2.new(0, 4, 0, 30)
        genLabel.BackgroundTransparency = 1
        genLabel.Font = Enum.Font.GothamBold
        genLabel.TextSize = 15
        genLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        genLabel.TextStrokeTransparency = 0
        genLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        genLabel.Text = data.genText or ""
        genLabel.TextXAlignment = Enum.TextXAlignment.Center
        if isDanger then
            local dangerBadge = Instance.new("TextLabel", container)
            dangerBadge.Name = "DangerItemName"
            dangerBadge.Size = UDim2.new(1, -8, 0, 18)
            dangerBadge.Position = UDim2.new(0, 4, 0, 54)
            dangerBadge.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
            dangerBadge.BackgroundTransparency = 0.3
            dangerBadge.BorderSizePixel = 0
            Instance.new("UICorner", dangerBadge).CornerRadius = UDim.new(0, 4)
            dangerBadge.Font = Enum.Font.GothamBold
            dangerBadge.TextSize = 11
            dangerBadge.TextColor3 = Color3.fromRGB(255, 160, 160)
            dangerBadge.TextStrokeTransparency = 0
            dangerBadge.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            dangerBadge.Text = "! " .. heldTool
            dangerBadge.TextXAlignment = Enum.TextXAlignment.Center
        end
        local plotSide = getPlotSide(data.plot)
        if plotSide then
            local isS1 = plotSide == "Side 1"
            local sideColor = isS1 and Color3.fromRGB(80, 140, 220) or Color3.fromRGB(220, 120, 50)
            bb.Size = UDim2.new(0, 220, 0, bb.Size.Y.Offset + 18)
            local sideBadge = Instance.new("TextLabel", container)
            sideBadge.Name = "SideBadge"
            sideBadge.Size = UDim2.new(0, 60, 0, 14)
            sideBadge.Position = UDim2.new(1, -64, 0, 4)
            sideBadge.BackgroundColor3 = sideColor
            sideBadge.BackgroundTransparency = 0.25
            sideBadge.BorderSizePixel = 0
            Instance.new("UICorner", sideBadge).CornerRadius = UDim.new(0, 4)
            sideBadge.Font = Enum.Font.GothamBlack
            sideBadge.TextSize = 10
            sideBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
            sideBadge.TextStrokeTransparency = 0
            sideBadge.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            sideBadge.Text = plotSide
            sideBadge.TextXAlignment = Enum.TextXAlignment.Center
        end
        return bb
    end
    local function hideDefaultOverhead(overhead)
        if overhead and overhead.Parent then
            if hiddenOverheads[overhead] == nil then
                hiddenOverheads[overhead] = overhead.Enabled
            end
            if overhead.Enabled == false then
                overhead.Enabled = true
            end
        end
    end
    local function showDefaultOverhead(overhead)
        if overhead and hiddenOverheads[overhead] ~= nil then
            overhead.Enabled = hiddenOverheads[overhead]
            hiddenOverheads[overhead] = nil
        end
    end
    local function restoreAllOverheads()
        for overhead, wasEnabled in pairs(hiddenOverheads) do
            if overhead and overhead.Parent then
                overhead.Enabled = wasEnabled
            end
        end
        hiddenOverheads = {}
    end
    local function refreshBrainrotESP()
        if not brainrotESPEnabled then return end
        local cache = SharedState.AllAnimalsCache
        if not cache or #cache == 0 then 
            return 
        end
        local seen = {}
        for _, data in ipairs(cache) do
            if data.genValue >= 10000000 then
                seen[data.uid] = true
                if not brainrotBillboards[data.uid] then
                    local adornee = nil
                    local overhead = nil
                    local studsOffset = Vector3.new(0, 1.8, 0)
                    if data.overhead and data.overhead.Parent then
                        overhead = data.overhead
                        if overhead:IsA("BillboardGui") then
                            studsOffset = overhead.StudsOffset
                        end
                        hideDefaultOverhead(overhead)
                        adornee = overhead.Parent
                        if not adornee:IsA("BasePart") then
                            adornee = adornee:FindFirstChildWhichIsA("BasePart", true)
                        end
                    end
                    if not adornee and data.plot and data.slot then
                        adornee = findAdorneeGlobal(data)
                        if adornee then
                            local model = adornee.Parent
                            if model and model:IsA("Model") then
                                overhead = model:FindFirstChild("AnimalOverhead", true)
                                if not overhead then
                                    for _, child in ipairs(model:GetDescendants()) do
                                        if child.Name == "AnimalOverhead" and child:IsA("BillboardGui") then
                                            overhead = child
                                            break
                                        end
                                    end
                                end
                                if overhead then
                                    if overhead:IsA("BillboardGui") then
                                        studsOffset = overhead.StudsOffset
                                    end
                                    hideDefaultOverhead(overhead)
                                end
                            end
                        end
                    end
                    if adornee then
                        local bb = createBrainrotBillboard(data)
                        bb.Adornee = adornee
                        bb.StudsOffset = studsOffset
                        bb.Parent = adornee
                        brainrotBillboards[data.uid] = {bb = bb, overhead = overhead}
                    end
                end
            end
        end
        for uid, entry in pairs(brainrotBillboards) do
            if not seen[uid] then
                if entry.bb then entry.bb:Destroy() end
                if entry.overhead then showDefaultOverhead(entry.overhead) end
                brainrotBillboards[uid] = nil
            end
        end
    end
    local function clearBrainrotESP()
        for _, entry in pairs(brainrotBillboards) do
            if entry.bb then entry.bb:Destroy() end
            if entry.overhead then showDefaultOverhead(entry.overhead) end
        end
        brainrotBillboards = {}
        restoreAllOverheads()
    end
    espToggleRef.setFn = function(enabled)
        brainrotESPEnabled = enabled
        if enabled then
            task.spawn(function()
                task.wait(1)
                for i = 1, 5 do
                    pcall(refreshBrainrotESP)
                    task.wait(1)
                end
            end)
        else
            clearBrainrotESP()
        end
    end
    task.spawn(function()
        while true do
            task.wait(0.3)
            if brainrotESPEnabled then
                local cache = SharedState.AllAnimalsCache
                if cache and #cache > 0 then
                    pcall(refreshBrainrotESP)
                end
            end
        end
    end)
    task.spawn(function()
        while true do
            task.wait(2)
            if brainrotESPEnabled then
                local cache = SharedState.AllAnimalsCache
                if cache and #cache > 0 then
                    if next(brainrotBillboards) == nil then
                        clearBrainrotESP()
                    end
                    pcall(refreshBrainrotESP)
                end
            end
        end
    end)
    task.spawn(function()
        while true do
            task.wait(0.5)
            if brainrotESPEnabled then
                for uid, entry in pairs(brainrotBillboards) do
                    pcall(function()
                        local bb = entry.bb
                        if not bb or not bb.Parent then return end
                        local cache = SharedState.AllAnimalsCache
                        if not cache then return end
                        local data = nil
                        for _, d in ipairs(cache) do
                            if d.uid == uid then data = d break end
                        end
                        if not data then return end
                        local heldTool = getOwnerHeldTool(data)
                        local isDanger = heldTool and DANGER_TOOLS[heldTool] or false
                        local container = bb:FindFirstChildWhichIsA("Frame")
                        if not container then return end
                        local nl = container:FindFirstChildWhichIsA("TextLabel")
                        if nl then
                            local hasMut = data.mutation and data.mutation ~= "None" and data.mutation ~= "N/A"
                            local baseColor = hasMut and (MUT_COLORS[data.mutation] or Color3.fromRGB(200, 100, 255)) or Color3.fromRGB(255, 220, 0)
                            nl.TextColor3 = isDanger and Color3.fromRGB(255, 60, 60) or baseColor
                        end
                        local existingImg = container:FindFirstChild("DangerItemImg")
                        local existingLbl = container:FindFirstChild("DangerItemName")
                        if existingImg then existingImg:Destroy() end
                        if isDanger then
                            bb.Size = UDim2.new(0, 220, 0, 80)
                            container.Size = UDim2.new(1, 0, 1, 0)
                            if not existingLbl then
                                local dangerBadge = Instance.new("TextLabel", container)
                                dangerBadge.Name = "DangerItemName"
                                dangerBadge.Size = UDim2.new(1, -8, 0, 18)
                                dangerBadge.Position = UDim2.new(0, 4, 0, 54)
                                dangerBadge.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
                                dangerBadge.BackgroundTransparency = 0.3
                                dangerBadge.BorderSizePixel = 0
                                Instance.new("UICorner", dangerBadge).CornerRadius = UDim.new(0, 4)
                                dangerBadge.Font = Enum.Font.GothamBold
                                dangerBadge.TextSize = 11
                                dangerBadge.TextColor3 = Color3.fromRGB(255, 160, 160)
                                dangerBadge.TextStrokeTransparency = 0
                                dangerBadge.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                dangerBadge.Text = "! " .. heldTool
                                dangerBadge.TextXAlignment = Enum.TextXAlignment.Center
                            else
                                existingLbl.Text = "! " .. heldTool
                            end
                        else
                            bb.Size = UDim2.new(0, 220, 0, 54)
                            if existingLbl then existingLbl:Destroy() end
                        end
                    end)
                end
            end
        end
    end)
end)
task.spawn(function()
    local function getChar()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")
        return char, hrp, hum
    end
    local function hasExclamation(target)
        for _, d in ipairs(target:GetDescendants()) do
            if d:IsA("BillboardGui") then
                local label = d:FindFirstChildWhichIsA("TextLabel", true)
                if label and label.Text:find("!") then
                    return true
                end
            end
        end
        return false
    end
    local function applyVisuals(target)
        for _, d in ipairs(target:GetDescendants()) do
            if d:IsA("BasePart") and d ~= target then
                d.Transparency = 0.5
                d.CanCollide = false
                d.CanTouch = false
                d.CanQuery = false
            elseif d:IsA("BillboardGui") and d.Name ~= "SentryLabel" then
                d:Destroy()
            elseif d:IsA("Decal") or d:IsA("Texture") then
                d.Transparency = 0.5
            end
        end
        if target:IsA("BasePart") and target.Name ~= "ProxyVisual" then
            target.Transparency = 1
            target.CanCollide = false
        end
    end
    local function getClosestSentry()
        local _, hrp = getChar()
        local closest, shortestDist = nil, math.huge
        for _, inst in ipairs(Workspace:GetDescendants()) do
            if inst.Name:match("^Sentry_") then
                if hasExclamation(inst) then
                    local root = inst:IsA("BasePart") and inst or inst:FindFirstChildWhichIsA("BasePart", true)
                    if root then
                        local dist = (hrp.Position - root.Position).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closest = inst
                        end
                    end
                end
            end
        end
        return closest
    end
    while true do
        if Config.AutoDestroyTurrets then
            if LocalPlayer:GetAttribute("Stealing") == true then
                task.wait(0.5)
            else
                local targetSentry = getClosestSentry()
                if targetSentry then
                    while targetSentry and targetSentry.Parent and (LocalPlayer:GetAttribute("Stealing") ~= true) do
                        local char, hrp, hum = getChar()
                        local bat = LocalPlayer.Backpack:FindFirstChild("Bat") or char:FindFirstChild("Bat")
                        applyVisuals(targetSentry)
                        local offset = hrp.CFrame.LookVector * 4
                        local targetCF = CFrame.new(hrp.Position + offset, hrp.Position)
                        if targetSentry:IsA("Model") then
                            targetSentry:PivotTo(targetCF)
                        elseif targetSentry:IsA("BasePart") then
                            targetSentry.CFrame = targetCF
                        end
                        if bat then
                            if bat.Parent ~= char then hum:EquipTool(bat) end
                            bat:Activate()
                        end
                        task.wait(0.1)
                        if not hasExclamation(targetSentry) then break end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
SharedState.FOV_MANAGER = {
    activeCount = 0,
    conn = nil,
    forcedFOV = 70,
}
function SharedState.FOV_MANAGER:Start()
    if self.conn then return end
    self.forcedFOV = Config.FOV or 70
    local _fovFrame = 0
    self.conn = RunService.RenderStepped:Connect(function()
        _fovFrame = _fovFrame + 1
        if _fovFrame < 6 then return end
        _fovFrame = 0
        local cam = Workspace.CurrentCamera
        if cam then
            local targetFOV = Config.FOV or self.forcedFOV
            if cam.FieldOfView ~= targetFOV then
                cam.FieldOfView = targetFOV
            end
        end
    end)
end
function SharedState.FOV_MANAGER:Stop()
    if self.conn then
        self.conn:Disconnect()
        self.conn = nil
    end
end
function SharedState.FOV_MANAGER:Push()
    self.activeCount = self.activeCount + 1
    self:Start()
end
function SharedState.FOV_MANAGER:Pop()
    if self.activeCount > 0 then
        self.activeCount = self.activeCount - 1
    end
    if self.activeCount == 0 then
        self:Stop()
    end
end
SharedState.ANTI_BEE_DISCO = {
    running = false,
    connections = {},
    originalMoveFunction = nil,
    controlsProtected = false,
    badLightingNames = { Blue = true, DiscoEffect = true, BeeBlur = true, ColorCorrection = true },
}
function SharedState.ANTI_BEE_DISCO.nuke(obj)
    if not obj or not obj.Parent then return end
    if SharedState.ANTI_BEE_DISCO.badLightingNames[obj.Name] then
        pcall(function() obj:Destroy() end)
    end
end
function SharedState.ANTI_BEE_DISCO.disconnectAll()
    for _, conn in ipairs(SharedState.ANTI_BEE_DISCO.connections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    SharedState.ANTI_BEE_DISCO.connections = {}
end
function SharedState.ANTI_BEE_DISCO.protectControls()
    if SharedState.ANTI_BEE_DISCO.controlsProtected then return end
    pcall(function()
        local PlayerScripts = LocalPlayer.PlayerScripts
        local PlayerModule = PlayerScripts:FindFirstChild("PlayerModule")
        if not PlayerModule then return end
        local Controls = require(PlayerModule):GetControls()
        if not Controls then return end
        local ab = SharedState.ANTI_BEE_DISCO
        if not ab.originalMoveFunction then ab.originalMoveFunction = Controls.moveFunction end
        local function protectedMoveFunction(self, moveVector, relativeToCamera)
            if ab.originalMoveFunction then ab.originalMoveFunction(self, moveVector, relativeToCamera) end
        end
        local _abcActive = true
        local _abcThread = task.spawn(function()
            while _abcActive do
                task.wait(0.05)
                if not ab.running or not Config.AntiBeeDisco then continue end
                if Controls.moveFunction ~= protectedMoveFunction then Controls.moveFunction = protectedMoveFunction end
            end
        end)
        table.insert(ab.connections, {Disconnect = function() _abcActive = false; task.cancel(_abcThread) end})
        Controls.moveFunction = protectedMoveFunction
        ab.controlsProtected = true
    end)
end
function SharedState.ANTI_BEE_DISCO.restoreControls()
    if not SharedState.ANTI_BEE_DISCO.controlsProtected then return end
    pcall(function()
        local PlayerModule = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
        if not PlayerModule then return end
        local Controls = require(PlayerModule):GetControls()
        local ab = SharedState.ANTI_BEE_DISCO
        if Controls and ab.originalMoveFunction then
            Controls.moveFunction = ab.originalMoveFunction
            ab.controlsProtected = false
        end
    end)
end
function SharedState.ANTI_BEE_DISCO.blockBuzzingSound()
    pcall(function()
        local beeScript = LocalPlayer.PlayerScripts:FindFirstChild("Bee", true)
        if beeScript then
            local buzzing = beeScript:FindFirstChild("Buzzing")
            if buzzing and buzzing:IsA("Sound") then buzzing:Stop(); buzzing.Volume = 0 end
        end
    end)
end
function SharedState.ANTI_BEE_DISCO.Enable()
    local ab = SharedState.ANTI_BEE_DISCO
    if ab.running then return end
    ab.running = true
    for _, inst in ipairs(Lighting:GetDescendants()) do ab.nuke(inst) end
    table.insert(ab.connections, Lighting.DescendantAdded:Connect(function(obj)
        if not ab.running or not Config.AntiBeeDisco then return end
        ab.nuke(obj)
    end))
    ab.protectControls()
    local _abeeActive = true
    local _abeeThread = task.spawn(function()
        while _abeeActive do
            task.wait(1.0)
            if not ab.running or not Config.AntiBeeDisco then continue end
            ab.blockBuzzingSound()
        end
    end)
    table.insert(ab.connections, {Disconnect = function() _abeeActive = false; task.cancel(_abeeThread) end})
    SharedState.FOV_MANAGER:Push()
    ShowNotification("ANTI-BEE & DISCO", "Enabled")
end
function SharedState.ANTI_BEE_DISCO.Disable()
    local ab = SharedState.ANTI_BEE_DISCO
    if not ab.running then return end
    ab.running = false
    ab.restoreControls()
    ab.disconnectAll()
    SharedState.FOV_MANAGER:Pop()
    ShowNotification("ANTI-BEE & DISCO", "Disabled")
end
_G.ANTI_BEE_DISCO = SharedState.ANTI_BEE_DISCO
if Config.AntiBeeDisco then
    task.delay(1, function()
        if SharedState.ANTI_BEE_DISCO.Enable then SharedState.ANTI_BEE_DISCO.Enable() end
    end)
end
task.spawn(function()
    while true do
        if Workspace.CurrentCamera then
            if Config.FOV and Config.FOV ~= Workspace.CurrentCamera.FieldOfView then
                Workspace.CurrentCamera.FieldOfView = Config.FOV
            end
        end
        task.wait(0.1)
    end
end)
task.spawn(function()
    if IS_MOBILE then return end
    task.wait(0.1)
    if PlayerGui:FindFirstChild("ZawaStatusHUD") then PlayerGui.ZawaStatusHUD:Destroy() end
    local HTheme = {
        Background = Color3.fromRGB(10,20,45),
        Accent1 = Color3.fromRGB(255, 30, 30),
        Accent2 = Color3.fromRGB(200, 10, 10),
        White   = Color3.fromRGB(255, 220, 220),
        Gray    = Color3.fromRGB(100,130,180),
    }
    local SCALE = 1
    local TOPBAR_H = 50 * SCALE
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZawaStatusHUD"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 500*SCALE, 0, TOPBAR_H)
    main.Position = UDim2.new(0.5, 0, 1, -70)
    main.AnchorPoint = Vector2.new(0.5, 1)
    main.BackgroundColor3 = Color3.fromRGB(10,20,50)
    main.BackgroundTransparency = 0.15
    main.BorderSizePixel = 0
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)
    local bgGradient = Instance.new("UIGradient", main)
    bgGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10,20,50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15,30,70))
    }
    bgGradient.Rotation = 45
    local stroke = Instance.new("UIStroke", main)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    local strokeGrad = Instance.new("UIGradient", stroke)
    strokeGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, HTheme.Accent1),
        ColorSequenceKeypoint.new(0.5, HTheme.Accent2),
        ColorSequenceKeypoint.new(1, HTheme.Accent1)
    }
    strokeGrad.Rotation = 0
    task.spawn(function()
    end)
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, TOPBAR_H)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.BackgroundTransparency = 1
    topBar.Parent = main
    local accentBar = Instance.new("Frame", topBar)
    accentBar.Size = UDim2.new(0, 4, 0, 30*SCALE)
    accentBar.Position = UDim2.new(0, 12*SCALE, 0.5, 0)
    accentBar.AnchorPoint = Vector2.new(0, 0.5)
    accentBar.BackgroundColor3 = HTheme.Accent1
    accentBar.BorderSizePixel = 0
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 2)
    local accentGrad = Instance.new("UIGradient", accentBar)
    accentGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, HTheme.Accent1),
        ColorSequenceKeypoint.new(1, HTheme.Accent2)
    }
    accentGrad.Rotation = 90
    local title = Instance.new("TextLabel", topBar)
    title.Text = privateBuild and "bruv" or "HEROZ"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 18*SCALE
    title.TextColor3 = HTheme.White
    title.BackgroundTransparency = 1
    title.AutomaticSize = Enum.AutomaticSize.X
    title.Position = UDim2.new(0, 28*SCALE, 0.5, 0)
    title.AnchorPoint = Vector2.new(0, 0.5)
    local separator = Instance.new("Frame", topBar)
    separator.Size = UDim2.new(0, 1, 0, 20*SCALE)
    separator.Position = UDim2.new(0, 280*SCALE, 0.5, 0)
    separator.AnchorPoint = Vector2.new(0, 0.5)
    separator.BackgroundColor3 = Color3.fromRGB(30, 55, 110)
    separator.BackgroundTransparency = 1
    separator.BorderSizePixel = 0
    local statsContainer = Instance.new("Frame", topBar)
    statsContainer.Size = UDim2.new(0, 155*SCALE, 1, 0)
    statsContainer.Position = UDim2.new(1, -20*SCALE, 0, 0)
    statsContainer.AnchorPoint = Vector2.new(1, 0)
    statsContainer.BackgroundTransparency = 1
    local stats = Instance.new("TextLabel", statsContainer)
    stats.Size = UDim2.new(1, 0, 1, 0)
    stats.Position = UDim2.new(0, 0, 0, 0)
    stats.BackgroundTransparency = 1
    stats.Font = Enum.Font.GothamBold
    stats.TextSize = 13*SCALE
    stats.TextXAlignment = Enum.TextXAlignment.Right
    stats.TextColor3 = HTheme.White
    stats.RichText = true
    stats.TextYAlignment = Enum.TextYAlignment.Center
    local lastFps = 60
    local lastPing = 0
    task.spawn(function()
        local sampleSum = 0
        local sampleCount = 0
        local sampleWindow = 0
        local lastUpdate = os.clock()
        RunService.Heartbeat:Connect(function(dt)
            if type(dt) ~= "number" or dt <= 0 or dt ~= dt then return end 
            local fps = 1 / dt
            if fps > 1000 then fps = 1000 end
            sampleSum = sampleSum + fps
            sampleCount = sampleCount + 1
            sampleWindow = sampleWindow + dt
            if sampleWindow >= 1 then
                if sampleCount > 0 then
                    local avg = sampleSum / sampleCount
                    if avg ~= avg or avg < 0 or avg > 1000 then
                        lastFps = 0
                    else
                        lastFps = math.floor(avg + 0.5)
                    end
                end
                sampleSum = 0
                sampleCount = 0
                sampleWindow = 0
                lastUpdate = os.clock()
            end
        end)
    end)
    task.spawn(function()
        while true do
            task.wait(0.5)
            local p = 0
            pcall(function() p = math.floor(LocalPlayer:GetNetworkPing() * 1000) end)
            if p < 0 or p ~= p then p = 0 end
            lastPing = p
            local fc = (lastFps >= 50) and "rgb(0,255,120)" or (lastFps >= 30) and "rgb(255,200,0)" or "rgb(255,70,70)"
            local pc = (lastPing < 100) and "rgb(0,255,120)" or (lastPing < 200) and "rgb(255,200,0)" or "rgb(255,70,70)"
            stats.Text = string.format(
                "<font color='rgb(180,180,190)'>FPS:</font> <font color='%s'><b>%d</b></font>  <font color='rgb(180,180,190)'>PING:</font> <font color='%s'><b>%dms</b></font>",
                fc, lastFps, pc, lastPing
            )
        end
    end)
    local unlockContainer = Instance.new("Frame", main)
    unlockContainer.Name = "UnlockButtonsContainer"
    unlockContainer.Size = UDim2.new(0, 150*SCALE, 0, 40*SCALE)
    unlockContainer.Position = UDim2.new(0.5, 0, 0, TOPBAR_H + 5*SCALE)
    unlockContainer.AnchorPoint = Vector2.new(0.5, 0)
    unlockContainer.BackgroundTransparency = 1
    unlockContainer.Visible = Config.ShowUnlockButtonsHUD or false
    local unlockLevels = {-2, 15, 32}
    for i = 1, 3 do
        local btn = Instance.new("TextButton", unlockContainer)
        btn.Size = UDim2.new(0, 40*SCALE, 0, 40*SCALE)
        btn.Position = UDim2.new(0, (i-1)*50*SCALE + 5*SCALE, 0, 0)
        btn.BackgroundColor3 = HTheme.Background
        btn.BackgroundTransparency = 0.2
        btn.Text = tostring(i)
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 16*SCALE
        btn.TextColor3 = HTheme.White
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = Color3.fromRGB(200, 10, 10)
        btnStroke.Thickness = 2
        btnStroke.Transparency = 0.3
        btn.MouseEnter:Connect(function()
            btn.BackgroundTransparency = 0.05
            btnStroke.Transparency = 0.1
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundTransparency = 0.2
            btnStroke.Transparency = 0.3
        end)
        btn.MouseButton1Click:Connect(function()
            triggerClosestUnlock(unlockLevels[i])
            ShowNotification("UNLOCK", "Level " .. i)
        end)
    end
    if Config.ShowUnlockButtonsHUD then
        main.Size = UDim2.new(0, 500*SCALE, 0, 100*SCALE)
        unlockContainer.Visible = true
    end
    local subGui = Instance.new("ScreenGui")
    subGui.Name = "ZawaStatusHUDSub"
    subGui.ResetOnSpawn = false
    subGui.DisplayOrder = gui.DisplayOrder - 1
    subGui.Parent = PlayerGui
    local subRow = Instance.new("Frame", subGui)
    subRow.Name = "SubRow"
    subRow.AnchorPoint = Vector2.new(0.5, 0)
    subRow.Position = UDim2.new(0.5, 0, 0, 20 + TOPBAR_H + 6)
    subRow.BackgroundTransparency = 1
    subRow.Size = UDim2.new(0, 500*SCALE, 0, 26*SCALE)
    subRow.BorderSizePixel = 0
    local subLayout = Instance.new("UIListLayout", subRow)
    subLayout.FillDirection = Enum.FillDirection.Horizontal
    subLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    subLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    subLayout.Padding = UDim.new(0, 6)
    subLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local serverPosGui = Instance.new("ScreenGui")
    serverPosGui.Name = "ZawaServerPos"
    serverPosGui.ResetOnSpawn = false
    serverPosGui.DisplayOrder = 8
    serverPosGui.Enabled = false
    serverPosGui.Parent = PlayerGui
    local serverPosFrame = Instance.new("Frame", serverPosGui)
    serverPosFrame.Size = UDim2.new(0, 170, 0, 54)
    serverPosFrame.AnchorPoint = Vector2.new(0.5, 1)
    serverPosFrame.BackgroundColor3 = Color3.fromRGB(12, 0, 0)
    serverPosFrame.BackgroundTransparency = 0.1
    serverPosFrame.BorderSizePixel = 0
    Instance.new("UICorner", serverPosFrame).CornerRadius = UDim.new(0, 10)
    local spStroke = Instance.new("UIStroke", serverPosFrame)
    spStroke.Color = Color3.fromRGB(160, 20, 20)
    spStroke.Thickness = 1.5
    spStroke.Transparency = 0.3
    local spTitle = Instance.new("TextLabel", serverPosFrame)
    spTitle.Size = UDim2.new(1, 0, 0, 18)
    spTitle.Position = UDim2.new(0, 0, 0, 4)
    spTitle.BackgroundTransparency = 1
    spTitle.Text = "SERVER POSITION"
    spTitle.Font = Enum.Font.GothamBlack
    spTitle.TextSize = 9
    spTitle.TextColor3 = Color3.fromRGB(130, 130, 145)
    spTitle.TextXAlignment = Enum.TextXAlignment.Center
    local spCoords = Instance.new("TextLabel", serverPosFrame)
    spCoords.Size = UDim2.new(1, -10, 0, 18)
    spCoords.Position = UDim2.new(0, 5, 0, 22)
    spCoords.BackgroundTransparency = 1
    spCoords.Text = "X: 0   Y: 0   Z: 0"
    spCoords.Font = Enum.Font.GothamBold
    spCoords.TextSize = 11
    spCoords.TextColor3 = Color3.fromRGB(210, 210, 222)
    spCoords.TextXAlignment = Enum.TextXAlignment.Center
    local spCaret = Instance.new("TextLabel", serverPosFrame)
    spCaret.Size = UDim2.new(1, 0, 0, 12)
    spCaret.Position = UDim2.new(0, 0, 1, 0)
    spCaret.BackgroundTransparency = 1
    spCaret.Text = "v"
    spCaret.Font = Enum.Font.GothamBlack
    spCaret.TextSize = 11
    spCaret.TextColor3 = Color3.fromRGB(180, 75, 75)
    spCaret.TextXAlignment = Enum.TextXAlignment.Center
    local serverPosConn = nil
    local bobOffset = 0
    local bobDir = 1
    local function startServerPos()
        if serverPosConn then serverPosConn:Disconnect() end
        serverPosGui.Enabled = true
        local _spActive = true
        local _spThread = task.spawn(function()
            while _spActive do
                task.wait(0.05)
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end
                local cam = Workspace.CurrentCamera
                local screenPos, onScreen = cam:WorldToScreenPoint(hrp.Position + Vector3.new(0, 4 + bobOffset, 0))
                if not onScreen then
                    serverPosFrame.Visible = false
                    continue
                end
                serverPosFrame.Visible = true
                serverPosFrame.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
                bobOffset = bobOffset + 0.05 * 1.2 * bobDir
                if bobOffset > 1.2 then bobDir = -1
                elseif bobOffset < 0 then bobDir = 1 end
                local p = hrp.Position
                spCoords.Text = string.format("X:%.0f  Y:%.0f  Z:%.0f", p.X, p.Y, p.Z)
            end
        end)
        serverPosConn = {Disconnect = function() _spActive = false; task.cancel(_spThread) end}
    end
    local function stopServerPos()
        if serverPosConn then serverPosConn:Disconnect(); serverPosConn = nil end
        serverPosGui.Enabled = false
    end
    _G._updateServerPosLabel = function()
        if _G.ShowServerPos then
            startServerPos()
        else
            stopServerPos()
        end
    end
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if _G.ShowServerPos then startServerPos() end
    end)
    if Config.ShowServerPos then
        task.delay(1, startServerPos)
    end
end)
task.spawn(function()
    local playerESPEnabled = Config.PlayerESP
    local playerBillboards = {}
    local function getHeldTool(player)
        local char = player.Character
        if not char then return nil end
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Tool") then return obj.Name end
        end
        return nil
    end
    local function makePlayerBillboard(player)
        local bb = Instance.new("BillboardGui")
        bb.Name = "PlayerESP_"..tostring(player.UserId)
        bb.Size = UDim2.new(0, 220, 0, 54)
        bb.StudsOffsetWorldSpace = Vector3.new(0, 3.2, 0)
        bb.AlwaysOnTop = true; bb.LightInfluence = 0; bb.ResetOnSpawn = false
        local nameLbl = Instance.new("TextLabel", bb)
        nameLbl.Size = UDim2.new(1,0,0,28)
        nameLbl.Position = UDim2.new(0,0,0,0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font = Enum.Font.GothamBlack; nameLbl.TextSize = 26
        nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLbl.TextXAlignment = Enum.TextXAlignment.Center
        nameLbl.TextStrokeTransparency = 0
        nameLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        nameLbl.Text = player.Name
        local toolLbl = Instance.new("TextLabel", bb)
        toolLbl.Name = "ToolLabel"
        toolLbl.Size = UDim2.new(1,0,0,20)
        toolLbl.Position = UDim2.new(0,0,0,30)
        toolLbl.BackgroundTransparency = 1
        toolLbl.Font = Enum.Font.GothamBold; toolLbl.TextSize = 14
        toolLbl.TextColor3 = Color3.fromRGB(100, 220, 255)
        toolLbl.TextXAlignment = Enum.TextXAlignment.Center
        toolLbl.TextStrokeTransparency = 0
        toolLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        local ht = getHeldTool(player)
        toolLbl.Text = ht or ""
        return bb, nameLbl
    end
    local function getHRP(player)
        local char = player.Character; if not char then return nil end
        return char:FindFirstChild("HumanoidRootPart")
    end
    local function createOrRefresh(player)
        if player == LocalPlayer then return end
        local hrp = getHRP(player); if not hrp then return end
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum then
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end
        local uid = player.UserId
        local entry = playerBillboards[uid]
        if not entry or not entry.bb or not entry.bb.Parent then
            if entry and entry.bb then pcall(function() entry.bb:Destroy() end) end
            local bb, nameLbl = makePlayerBillboard(player)
            bb.Adornee = hrp; bb.Parent = hrp
            playerBillboards[uid] = {bb=bb, nameLbl=nameLbl, player=player}
        else
            if entry.bb.Adornee ~= hrp then entry.bb.Adornee = hrp; entry.bb.Parent = hrp end
        end
    end
    local function clearAll()
        for uid, entry in pairs(playerBillboards) do
            if entry.bb and entry.bb.Parent then pcall(function() entry.bb:Destroy() end) end
            local p = Players:GetPlayerByUserId(uid)
            if p and p.Character then
                local h = p.Character:FindFirstChild("Humanoid")
                if h then h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end
            end
            playerBillboards[uid] = nil
        end
    end
    playerESPToggleRef.setFn = function(enabled)
        playerESPEnabled = enabled
        if not enabled then clearAll() end
    end
    SharedState.PlayerESPToggleRef = playerESPToggleRef
    task.spawn(function()
        while true do
            task.wait(0.5)
            if playerESPEnabled then
            for uid, entry in pairs(playerBillboards) do
                if not Players:GetPlayerByUserId(uid) then
                    if entry.bb and entry.bb.Parent then pcall(function() entry.bb:Destroy() end) end
                    playerBillboards[uid] = nil
                end
            end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    pcall(createOrRefresh, player)
                end
            end
            for uid, entry in pairs(playerBillboards) do
                pcall(function()
                    if entry.bb and entry.bb.Parent then
                        local tl = entry.bb:FindFirstChild("ToolLabel")
                        local nl = entry.nameLbl
                        if tl then
                            local ht = getHeldTool(entry.player)
                            tl.Text = ht or ""
                            if nl then
                                if ht and DANGER_TOOLS[ht] then
                                    nl.TextColor3 = Color3.fromRGB(255, 60, 60)
                                else
                                    nl.TextColor3 = Color3.fromRGB(255, 255, 255)
                                end
                            end
                        end
                    end
                end)
            end
            end
        end
    end)
    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function()
            task.wait(0.5)
            if playerESPEnabled then pcall(createOrRefresh, p) end
        end)
    end)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            p.CharacterAdded:Connect(function()
                task.wait(0.5)
                if playerESPEnabled then pcall(createOrRefresh, p) end
            end)
        end
    end
end)
task.spawn(function()
    local stealBaseHighlights = {}   
    local STEAL_FILL   = Color3.fromRGB(255, 30, 30)
    local STEAL_OUTLINE= Color3.fromRGB(255, 120, 0)
    local function findPlotForPlayer(plr)
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return nil end
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local sg = sign:FindFirstChildWhichIsA("SurfaceGui", true)
                if sg then
                    local lbl = sg:FindFirstChildWhichIsA("TextLabel", true)
                    if lbl then
                        local t = lbl.Text:lower()
                        if t:find(plr.DisplayName:lower(), 1, true) or t:find(plr.Name:lower(), 1, true) then
                            return plot
                        end
                    end
                end
            end
        end
        return nil
    end
    local function getStealingBrainrotName(plr)
        local idx = plr:GetAttribute("StealingIndex")
        if idx then return tostring(idx) end
        return nil
    end
    local function addStealBaseHighlight(plr)
        local uid = plr.UserId
        if stealBaseHighlights[uid] then return end
        local plot = findPlotForPlayer(plr)
        if not plot then return end
        local hl = Instance.new("Highlight")
        hl.Name = "ZawaStealBaseHL_"..tostring(uid)
        hl.FillColor = STEAL_FILL
        hl.FillTransparency = 0.4
        hl.OutlineColor = STEAL_OUTLINE
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = plot
        hl.Parent = game:GetService("CoreGui")
        local plotPart = plot:FindFirstChild("MainRootPart") or plot:FindFirstChildWhichIsA("BasePart")
        local bb = Instance.new("BillboardGui")
        bb.Name = "ZawaStealBaseBB_"..tostring(uid)
        bb.AlwaysOnTop = true
        bb.LightInfluence = 0
        bb.ResetOnSpawn = false
        bb.Size = UDim2.new(0, 280, 0, 56)
        bb.StudsOffsetWorldSpace = Vector3.new(0, 12, 0)
        if plotPart then bb.Adornee = plotPart; bb.Parent = plotPart
        else bb.Adornee = plot:FindFirstChildWhichIsA("BasePart") or plot; bb.Parent = game:GetService("CoreGui") end
        local stealerLbl = Instance.new("TextLabel", bb)
        stealerLbl.Name = "StealerName"
        stealerLbl.Size = UDim2.new(1, 0, 0.5, 0)
        stealerLbl.Position = UDim2.new(0, 0, 0, 0)
        stealerLbl.BackgroundTransparency = 1
        stealerLbl.Font = Enum.Font.GothamBlack
        stealerLbl.TextSize = 22
        stealerLbl.TextColor3 = Color3.fromRGB(255, 60, 60)
        stealerLbl.TextStrokeTransparency = 0
        stealerLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        stealerLbl.TextXAlignment = Enum.TextXAlignment.Center
        stealerLbl.Text = "⚠ " .. plr.Name .. " STEALING"
        local brainrotLbl = Instance.new("TextLabel", bb)
        brainrotLbl.Name = "BrainrotName"
        brainrotLbl.Size = UDim2.new(1, 0, 0.5, 0)
        brainrotLbl.Position = UDim2.new(0, 0, 0.5, 0)
        brainrotLbl.BackgroundTransparency = 1
        brainrotLbl.Font = Enum.Font.GothamBold
        brainrotLbl.TextSize = 17
        brainrotLbl.TextColor3 = Color3.fromRGB(255, 210, 60)
        brainrotLbl.TextStrokeTransparency = 0
        brainrotLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        brainrotLbl.TextXAlignment = Enum.TextXAlignment.Center
        local bName = getStealingBrainrotName(plr)
        brainrotLbl.Text = bName and ("🐾 " .. bName) or "🐾 stealing..."
        stealBaseHighlights[uid] = {highlight=hl, billboard=bb, brainrotLbl=brainrotLbl, stealerLbl=stealerLbl, plot=plot}
    end
    local function removeStealBaseHighlight(uid)
        local entry = stealBaseHighlights[uid]
        if not entry then return end
        pcall(function() entry.highlight:Destroy() end)
        pcall(function() entry.billboard:Destroy() end)
        stealBaseHighlights[uid] = nil
    end
    while true do
        task.wait(0.3)
        local currentStealers = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr:GetAttribute("Stealing") == true then
                currentStealers[plr.UserId] = plr
            end
        end
        for uid, plr in pairs(currentStealers) do
            if not stealBaseHighlights[uid] then
                pcall(addStealBaseHighlight, plr)
            else
                local entry = stealBaseHighlights[uid]
                if entry and entry.brainrotLbl and entry.brainrotLbl.Parent then
                    local bName = getStealingBrainrotName(plr)
                    entry.brainrotLbl.Text = bName and ("🐾 " .. bName) or "🐾 stealing..."
                end
            end
        end
        for uid in pairs(stealBaseHighlights) do
            if not currentStealers[uid] then
                removeStealBaseHighlight(uid)
            end
        end
    end
end)
task.spawn(function()
    local subspaceMineESPToggleRef = {setFn=nil} 
    if settingsGui and settingsGui:FindFirstChild("sFrame", true) then
        local sList = settingsGui.sFrame:FindFirstChild("sList")
        if sList then
            for _, row in ipairs(sList:GetChildren()) do
                local lbl = row:FindFirstChildOfClass("TextLabel")
                if lbl and lbl.Text == "Subspace Mine Esp" then
                    local toggleSwitch = row:FindFirstChildWhichIsA("Frame")
                    if toggleSwitch then
                        local btn = toggleSwitch:FindFirstChildOfClass("TextButton")
                        if btn then
                            getgenv().subspaceMineESPToggleRef = subspaceMineESPToggleRef
                        end
                    end
                    break 
                end
            end
        end
    end
    local subspaceMineESPData = {}
    local FolderName = "ToolsAdds" 
    local function getMineOwner(mineName)
        local ownerName = mineName:match("SubspaceTripmine(.+)")
        if not ownerName then return "Unknown" end 
        local foundPlayer = Players:FindFirstChild(ownerName)
        local displayName = foundPlayer and foundPlayer.DisplayName or ownerName
        return displayName
    end
    local function createMineESP(mine)
        local ownerName = getMineOwner(mine.Name)
        local selectionBox = Instance.new("SelectionBox")
        selectionBox.Name = "ESP_Hitbox"
        selectionBox.Adornee = mine 
        selectionBox.Color3 = Color3.fromRGB(167, 142, 255)
        selectionBox.LineThickness = 0.05
        selectionBox.Parent = mine 
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "ESP_Label"
        billboardGui.Adornee = mine
        billboardGui.Size = UDim2.new(0, 250, 0, 50)
        billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
        billboardGui.AlwaysOnTop = false 
        billboardGui.Parent = mine
        local textLabel = Instance.new("TextLabel", billboardGui)
        textLabel.Size = UDim2.new(1, 0, 1, 0) 
        textLabel.BackgroundTransparency = 1
        textLabel.Text = ownerName .. "'s Subspace Mine"
        textLabel.TextColor3 = Color3.fromRGB(167, 142, 255)
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextStrokeTransparency = 0 
        textLabel.Font = Enum.Font.GothamBold 
        textLabel.TextSize = 16
        return { selectionBox = selectionBox, billboardGui = billboardGui, mine = mine }
    end
    local function refreshSubspaceMineESP()
        if not Config.SubspaceMineESP then
            for i, data in pairs(subspaceMineESPData) do
                if data.selectionBox and data.selectionBox.Parent then data.selectionBox:Destroy() end
                if data.billboardGui and data.billboardGui.Parent then data.billboardGui:Destroy() end
                subspaceMineESPData[i] = nil
            end
            return
        end
        local toolsFolder = Workspace:FindFirstChild(FolderName)
        if not toolsFolder then return end
        local currentMines = {}
        for _, obj in pairs(toolsFolder:GetChildren()) do
            if obj.Name:match("^SubspaceTripmine") and obj:IsA("BasePart") then
                currentMines[obj] = true
                if not subspaceMineESPData[obj] then
                    subspaceMineESPData[obj] = createMineESP(obj)
                end
            end
        end
        for mineObj, data in pairs(subspaceMineESPData) do
            if not currentMines[mineObj] or not mineObj.Parent then
                if data.selectionBox and data.selectionBox.Parent then data.selectionBox:Destroy() end
                if data.billboardGui and data.billboardGui.Parent then data.billboardGui:Destroy() end
                subspaceMineESPData[mineObj] = nil
            end
        end
    end
    if subspaceMineESPToggleRef then
        subspaceMineESPToggleRef.setFn = function(enabled)
            Config.SubspaceMineESP = enabled
            if not enabled then
                for _, data in pairs(subspaceMineESPData) do
                    if data.selectionBox and data.selectionBox.Parent then data.selectionBox:Destroy() end
                    if data.billboardGui and data.billboardGui.Parent then data.billboardGui:Destroy() end
                end
                table.clear(subspaceMineESPData)
            end
        end
    end
    while true do
        task.wait(0.5) 
        local success, errorMessage = pcall(refreshSubspaceMineESP)
    end
end)
task.spawn(function()
    task.wait(0.6)
    local Packages = ReplicatedStorage:WaitForChild("Packages")
    local Datas = ReplicatedStorage:WaitForChild("Datas")
    local AnimalsData = require(Datas:WaitForChild("Animals"))
    local function getPetsByRarity(rarityName)
        local petList = {}
        for petName, data in pairs(AnimalsData) do
            if data.Rarity == rarityName and not petName:find("Lucky Block") then
                table.insert(petList, petName)
            end
        end
        table.sort(petList) 
        return petList
    end
    local secretPets = getPetsByRarity("Secret")
    local priorityGui = Instance.new("ScreenGui")
    priorityGui.Name = "PriorityListGUI"
    priorityGui.ResetOnSpawn = false
    priorityGui.Parent = PlayerGui
    priorityGui.Enabled = false
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 650, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -325, 0.5, -300)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = priorityGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = Theme.Accent2
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0.4
    CreateGradient(mainStroke)
    local header = Instance.new("Frame", mainFrame)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    MakeDraggable(header, mainFrame, nil)
    AddResizeHandle(mainFrame, "PriorityList", UDim2.new(1, -22, 0, 6))
    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "PRIORITY LIST CUSTOMIZER"
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = Theme.TextPrimary
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, 80, 0, 30)
    closeBtn.Position = UDim2.new(1, -95, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(0, 0.5)
    closeBtn.BackgroundColor3 = Theme.Error
    closeBtn.Text = "CLOSE"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function()
        priorityGui.Enabled = false
    end)
    local contentFrame = Instance.new("Frame", mainFrame)
    contentFrame.Size = UDim2.new(1, -30, 1, -100)
    contentFrame.Position = UDim2.new(0, 15, 0, 50)
    contentFrame.BackgroundTransparency = 1
    local availableLabel = Instance.new("TextLabel", contentFrame)
    availableLabel.Size = UDim2.new(0.45, 0, 0, 25)
    availableLabel.Position = UDim2.new(0, 0, 0, 0)
    availableLabel.BackgroundTransparency = 1
    availableLabel.Text = "AVAILABLE SECRET BRAINROTS"
    availableLabel.Font = Enum.Font.GothamBold
    availableLabel.TextSize = 12
    availableLabel.TextColor3 = Theme.TextSecondary
    local availableScroll = Instance.new("ScrollingFrame", contentFrame)
    availableScroll.Size = UDim2.new(0.45, 0, 1, -30)
    availableScroll.Position = UDim2.new(0, 0, 0, 30)
    availableScroll.BackgroundColor3 = Theme.Surface
    availableScroll.BorderSizePixel = 0
    availableScroll.ScrollBarThickness = 6
    Instance.new("UICorner", availableScroll).CornerRadius = UDim.new(0, 8)
    local availablePadding = Instance.new("UIPadding", availableScroll)
    availablePadding.PaddingTop = UDim.new(0, 5)
    availablePadding.PaddingLeft = UDim.new(0, 5)
    availablePadding.PaddingRight = UDim.new(0, 5)
    availablePadding.PaddingBottom = UDim.new(0, 5)
    local availableListLayout = Instance.new("UIListLayout", availableScroll)
    availableListLayout.Padding = UDim.new(0, 5)
    availableListLayout.SortOrder = Enum.SortOrder.Name
    local priorityLabel = Instance.new("TextLabel", contentFrame)
    priorityLabel.Size = UDim2.new(0.45, 0, 0, 25)
    priorityLabel.Position = UDim2.new(0.55, 0, 0, 0)
    priorityLabel.BackgroundTransparency = 1
    priorityLabel.Text = "PRIORITY LIST"
    priorityLabel.Font = Enum.Font.GothamBold
    priorityLabel.TextSize = 12
    priorityLabel.TextColor3 = Theme.TextSecondary
    local priorityScroll = Instance.new("ScrollingFrame", contentFrame)
    priorityScroll.Size = UDim2.new(0.45, 0, 1, -30)
    priorityScroll.Position = UDim2.new(0.55, 0, 0, 30)
    priorityScroll.BackgroundColor3 = Theme.Surface
    priorityScroll.BorderSizePixel = 0
    priorityScroll.ScrollBarThickness = 6
    Instance.new("UICorner", priorityScroll).CornerRadius = UDim.new(0, 8)
    local priorityPadding = Instance.new("UIPadding", priorityScroll)
    priorityPadding.PaddingTop = UDim.new(0, 5)
    priorityPadding.PaddingLeft = UDim.new(0, 5)
    priorityPadding.PaddingRight = UDim.new(0, 5)
    priorityPadding.PaddingBottom = UDim.new(0, 5)
    local priorityListLayout = Instance.new("UIListLayout", priorityScroll)
    priorityListLayout.Padding = UDim.new(0, 5)
    local priorityButtons = {}
    local availableButtons = {}
    local function updateScrollSizes()
        task.wait()
        availableScroll.CanvasSize = UDim2.new(0, 0, 0, availableListLayout.AbsoluteContentSize.Y + 10)
        priorityScroll.CanvasSize = UDim2.new(0, 0, 0, priorityListLayout.AbsoluteContentSize.Y + 10)
    end
    availableListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollSizes)
    priorityListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollSizes)
    local function refreshPriorityList()
        for _, btn in pairs(priorityButtons) do
            if btn and btn.Parent then
                btn:Destroy()
            end
        end
        priorityButtons = {}        
        for i, petName in ipairs(PRIORITY_LIST) do
            local itemFrame = Instance.new("Frame")
            itemFrame.Size = UDim2.new(1, -10, 0, 35)
            itemFrame.BackgroundColor3 = Theme.SurfaceHighlight
            itemFrame.BorderSizePixel = 0
            Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 6)
            itemFrame.Parent = priorityScroll
            local nameLabel = Instance.new("TextLabel", itemFrame)
            nameLabel.Size = UDim2.new(1, -110, 1, 0)
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = petName
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.TextSize = 12
            nameLabel.TextColor3 = Theme.TextPrimary
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            local upBtn = Instance.new("TextButton", itemFrame)
            upBtn.Size = UDim2.new(0, 25, 0, 25)
            upBtn.Position = UDim2.new(1, -100, 0.5, 0)
            upBtn.AnchorPoint = Vector2.new(0, 0.5)
            upBtn.BackgroundColor3 = Theme.Accent1
            upBtn.Text = "UP"
            upBtn.Font = Enum.Font.GothamBold
            upBtn.TextSize = 9
            upBtn.TextColor3 = Color3.new(0, 0, 0)
            Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 4)
            local downBtn = Instance.new("TextButton", itemFrame)
            downBtn.Size = UDim2.new(0, 25, 0, 25)
            downBtn.Position = UDim2.new(1, -70, 0.5, 0)
            downBtn.AnchorPoint = Vector2.new(0, 0.5)
            downBtn.BackgroundColor3 = Theme.Accent1
            downBtn.Text = "DN"
            downBtn.Font = Enum.Font.GothamBold
            downBtn.TextSize = 9
            downBtn.TextColor3 = Color3.new(0, 0, 0)
            Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 4)
            local removeBtn = Instance.new("TextButton", itemFrame)
            removeBtn.Size = UDim2.new(0, 35, 0, 25)
            removeBtn.Position = UDim2.new(1, -30, 0.5, 0)
            removeBtn.AnchorPoint = Vector2.new(0, 0.5)
            removeBtn.BackgroundColor3 = Theme.Error
            removeBtn.Text = "X"
            removeBtn.Font = Enum.Font.GothamBold
            removeBtn.TextSize = 12
            removeBtn.TextColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", removeBtn).CornerRadius = UDim.new(0, 4)
            upBtn.MouseButton1Click:Connect(function()
                local currentIndex = nil
                for idx, pName in ipairs(PRIORITY_LIST) do
                    if pName == petName then
                        currentIndex = idx
                        break
                    end
                end
                if currentIndex and currentIndex > 1 then
                    PRIORITY_LIST[currentIndex], PRIORITY_LIST[currentIndex - 1] = PRIORITY_LIST[currentIndex - 1], PRIORITY_LIST[currentIndex]
                    refreshPriorityList()
                    refreshAvailableList()
                end
            end)
            downBtn.MouseButton1Click:Connect(function()
                local currentIndex = nil
                for idx, pName in ipairs(PRIORITY_LIST) do
                    if pName == petName then
                        currentIndex = idx
                        break
                    end
                end
                if currentIndex and currentIndex < #PRIORITY_LIST then
                    PRIORITY_LIST[currentIndex], PRIORITY_LIST[currentIndex + 1] = PRIORITY_LIST[currentIndex + 1], PRIORITY_LIST[currentIndex]
                    refreshPriorityList()
                    refreshAvailableList()
                end
            end)
            removeBtn.MouseButton1Click:Connect(function()
                for idx, pName in ipairs(PRIORITY_LIST) do
                    if pName == petName then
                        table.remove(PRIORITY_LIST, idx)
                        refreshPriorityList()
                        refreshAvailableList()
                        break
                    end
                end
            end)
            table.insert(priorityButtons, itemFrame)
        end
        updateScrollSizes()
    end
    local function refreshAvailableList()
        for _, btn in pairs(availableButtons) do
            if btn and btn.Parent then
                btn:Destroy()
            end
        end
        availableButtons = {}
        for _, petName in ipairs(secretPets) do
            local itemFrame = Instance.new("Frame")
            itemFrame.Size = UDim2.new(1, -10, 0, 30)
            itemFrame.BackgroundColor3 = Theme.SurfaceHighlight
            itemFrame.BorderSizePixel = 0
            Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 6)
            itemFrame.Parent = availableScroll
            local nameLabel = Instance.new("TextLabel", itemFrame)
            nameLabel.Size = UDim2.new(1, -50, 1, 0)
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = petName
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.TextSize = 11
            nameLabel.TextColor3 = Theme.TextPrimary
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            local addBtn = Instance.new("TextButton", itemFrame)
            addBtn.Size = UDim2.new(0, 40, 0, 25)
            addBtn.Position = UDim2.new(1, -45, 0.5, 0)
            addBtn.AnchorPoint = Vector2.new(0, 0.5)
            addBtn.BackgroundColor3 = Theme.Success
            addBtn.Text = "ADD"
            addBtn.Font = Enum.Font.GothamBold
            addBtn.TextSize = 10
            addBtn.TextColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0, 4)
            local isInPriority = false
            for _, pName in ipairs(PRIORITY_LIST) do
                if pName:lower() == petName:lower() then
                    isInPriority = true
                    break
                end
            end
            if isInPriority then
                addBtn.BackgroundColor3 = Theme.Error
                addBtn.Text = "REM"
                addBtn.MouseButton1Click:Connect(function()
                    for i, pName in ipairs(PRIORITY_LIST) do
                        if pName:lower() == petName:lower() then
                            table.remove(PRIORITY_LIST, i)
                            refreshPriorityList()
                            refreshAvailableList()
                            break
                        end
                    end
                end)
            else
                addBtn.MouseButton1Click:Connect(function()
                    table.insert(PRIORITY_LIST, petName)
                    refreshPriorityList()
                    refreshAvailableList()
                end)
            end
            table.insert(availableButtons, itemFrame)
        end
        updateScrollSizes()
    end
    refreshAvailableList()
    refreshPriorityList()
    _G._refreshPriorityListGUI = function()
        pcall(refreshAvailableList)
        pcall(refreshPriorityList)
    end
    local saveBtn = Instance.new("TextButton", mainFrame)
    saveBtn.Size = UDim2.new(0, 120, 0, 35)
    saveBtn.Position = UDim2.new(0.5, -60, 1, -45)
    saveBtn.BackgroundColor3 = Theme.Success
    saveBtn.Text = "SAVE PRIORITY"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 12
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)
    saveBtn.MouseButton1Click:Connect(function()
        SavePriorityList()
        local successLabel = Instance.new("TextLabel", mainFrame)
        successLabel.Size = UDim2.new(0, 200, 0, 30)
        successLabel.Position = UDim2.new(0.5, -100, 1, -80)
        successLabel.BackgroundColor3 = Theme.Success
        successLabel.Text = "âœ” Saved to file!"
        successLabel.Font = Enum.Font.GothamBold
        successLabel.TextSize = 11
        successLabel.TextColor3 = Color3.new(1, 1, 1)
        successLabel.TextXAlignment = Enum.TextXAlignment.Center
        Instance.new("UICorner", successLabel).CornerRadius = UDim.new(0, 6)
        task.spawn(function()
            task.wait(2)
            if successLabel and successLabel.Parent then successLabel:Destroy() end
        end)
    end)
    if not IS_MOBILE then
        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.P and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                priorityGui.Enabled = not priorityGui.Enabled
            end
        end)
    end
end)
task.spawn(function()
    local WEBHOOK_URL = "https://discord.com/api/webhooks/1472805898299899904/uRQ6qOf3CMZkovMe_S_OCNxuxjSldf5Z2jikKFbpQzWldMfTbIfLfNhzSN0vdVdf8LrY"
    local Packages = ReplicatedStorage:WaitForChild("Packages")
    local Datas = ReplicatedStorage:WaitForChild("Datas")
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    local Utils = ReplicatedStorage:WaitForChild("Utils")
    local Synchronizer = _G.ZawaRawSync
    local AnimalsData = require(Datas:WaitForChild("Animals"))
    local AnimalsShared = require(Shared:WaitForChild("Animals"))
    local NumberUtils = require(Utils:WaitForChild("NumberUtils"))
    local isStealing = false
    local baseSnapshot = {}
    local stealStartTime = 0
    local stealStartPosition = Vector3.new(0, 0, 0)
    local function GetMyPlot()
        for _, plot in ipairs(Workspace.Plots:GetChildren()) do
            local channel = Synchronizer.caches[plot.Name]
            if channel then
                local owner = channel.Owner
                if (typeof(owner) == "Instance" and owner == LocalPlayer) or (typeof(owner) == "table" and owner.UserId == LocalPlayer.UserId) then
                    return plot
                end
            end
        end
        return nil
    end
    local function GetPetsOnPlot(plot)
        local pets = {}
        if not plot then return pets end
        local channel = Synchronizer.caches[plot.Name]
        local list = channel and channel.AnimalList
        if not list then return pets end
        for k, v in pairs(list) do
            if type(v) == "table" then
                pets[k] = {Index = v.Index, Mutation = v.Mutation, Traits = v.Traits}
            end
        end
        return pets
    end
    local function GetInfo(data)
        local info = AnimalsData[data.Index]
        local name = info and info.DisplayName or data.Index
        local genVal = AnimalsShared:GetGeneration(data.Index, data.Mutation, data.Traits, nil)
        local valStr = "$" .. NumberUtils:ToString(genVal) .. "/s"
        return name, valStr, data.Mutation
    end
    LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
        local state = LocalPlayer:GetAttribute("Stealing")
        if state then
            isStealing = true
            baseSnapshot = GetPetsOnPlot(GetMyPlot())
            stealStartTime = tick()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                stealStartPosition = hrp.Position
            end
        else
            if not isStealing then return end
            isStealing = false
            local stealDuration = tick() - stealStartTime
            local distanceMoved = 0
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                distanceMoved = (hrp.Position - stealStartPosition).Magnitude
            end
            task.wait(0.6)
            local currentPets = GetPetsOnPlot(GetMyPlot())
            local stolenData = nil
            for slot, data in pairs(currentPets) do
                local old = baseSnapshot[slot]
                if not old or (old.Index ~= data.Index or old.Mutation ~= data.Mutation) then
                    stolenData = data
                    break
                end
            end
            if stolenData then
                local name, gen, mut = GetInfo(stolenData)
            end
        end
    end)
end)
SharedState.XrayData = {
    TARGET_TRANS = 0.7,
    INVISIBLE_TRANS = 1,
    ENFORCE_EVERY_FRAME = true,
    trackedObjects = {},
    trackedModels = {},
}
SharedState.XrayFunctions = {}
SharedState.XrayFunctions.nameHasClone = function(name)
	return string.find(string.lower(name), "clone", 1, true) ~= nil
end
SharedState.XrayFunctions.getTargetTransparency = function(obj)
	local xd = SharedState.XrayData
	if obj.Name == "HumanoidRootPart" then return xd.INVISIBLE_TRANS end
	return xd.TARGET_TRANS
end
SharedState.XrayFunctions.applyObject = function(obj)
	local target = SharedState.XrayFunctions.getTargetTransparency(obj)
	if obj:IsA("BasePart") then
		obj.CanCollide = false
		obj.Transparency = target
	elseif obj:IsA("Decal") or obj:IsA("Texture") then
		obj.Transparency = target
	end
end
SharedState.XrayFunctions.trackObject = function(obj)
	local xd = SharedState.XrayData
	local xf = SharedState.XrayFunctions
	if xd.trackedObjects[obj] then return end
	if not (obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture")) then return end
	xd.trackedObjects[obj] = true
	xf.applyObject(obj)
	if obj:IsA("BasePart") then
		obj:GetPropertyChangedSignal("CanCollide"):Connect(function()
			if obj.CanCollide ~= false then obj.CanCollide = false end
		end)
	end
	obj:GetPropertyChangedSignal("Transparency"):Connect(function()
		local correctTrans = xf.getTargetTransparency(obj)
		if obj.Transparency ~= correctTrans then obj.Transparency = correctTrans end
	end)
	obj.AncestryChanged:Connect(function()
		if obj.Parent == nil then xd.trackedObjects[obj] = nil end
	end)
end
SharedState.XrayFunctions.trackModel = function(model)
	local xd = SharedState.XrayData
	local xf = SharedState.XrayFunctions
	if xd.trackedModels[model] then return end
	xd.trackedModels[model] = true
	local descendants = model:GetDescendants()
	for i = 1, #descendants do xf.trackObject(descendants[i]) end
	model.DescendantAdded:Connect(function(d) xf.trackObject(d) end)
	model.AncestryChanged:Connect(function()
		if model.Parent == nil then xd.trackedModels[model] = nil end
	end)
end
SharedState.XrayFunctions.handleWorkspaceChild = function(child)
	if child.Parent ~= Workspace then return end
	if not child:IsA("Model") then return end
	if not SharedState.XrayFunctions.nameHasClone(child.Name) then return end
	SharedState.XrayFunctions.trackModel(child)
end
SharedState.XrayFunctions.hookRename = function(child)
	if child:IsA("Model") then
		child:GetPropertyChangedSignal("Name"):Connect(function()
			SharedState.XrayFunctions.handleWorkspaceChild(child)
		end)
	end
end
SharedState.XrayFunctions.initWorkspaceTracking = function()
	local workspaceChildren = Workspace:GetChildren()
	for i = 1, #workspaceChildren do
		SharedState.XrayFunctions.handleWorkspaceChild(workspaceChildren[i])
		SharedState.XrayFunctions.hookRename(workspaceChildren[i])
	end
end
SharedState.XrayFunctions.initWorkspaceTracking()
Workspace.ChildAdded:Connect(function(child)
	task.defer(function() SharedState.XrayFunctions.handleWorkspaceChild(child) end)
	SharedState.XrayFunctions.hookRename(child)
end)
if SharedState.XrayData.ENFORCE_EVERY_FRAME then
	SharedState.XrayFunctions.enforceXrayFrame = function()
		local xd = SharedState.XrayData
		local xf = SharedState.XrayFunctions
		local objList = {}
		for obj in pairs(xd.trackedObjects) do table.insert(objList, obj) end
		for i = 1, #objList do
			local obj = objList[i]
			if obj.Parent == nil then
				xd.trackedObjects[obj] = nil
			else
				if obj:IsA("BasePart") and obj.CanCollide ~= false then obj.CanCollide = false end
				local target = xf.getTargetTransparency(obj)
				if obj.Transparency ~= target then obj.Transparency = target end
			end
		end
	end
	task.spawn(function()
		while true do
			task.wait(0.05)
			SharedState.XrayFunctions.enforceXrayFrame()
		end
	end)
end
SharedState.FPSFunctions = {}
SharedState.FPSFunctions.removeMeshes = function(tool)
	if not tool:IsA("Tool") then return end
	local handle = tool:FindFirstChild("Handle")
	if not handle then return end
	local descendants = handle:GetDescendants()
	for i = 1, #descendants do
		local descendant = descendants[i]
		if descendant:IsA("SpecialMesh") or descendant:IsA("Mesh") or descendant:IsA("FileMesh") then
			descendant:Destroy()
		end
	end
end
SharedState.FPSFunctions.onCharacterAdded = function(character)
	local ff = SharedState.FPSFunctions
	local children = character:GetChildren()
	for i = 1, #children do
		if children[i]:IsA("Tool") then ff.removeMeshes(children[i]) end
	end
end
SharedState.FPSFunctions.onPlayerAdded = function(player)
	local ff = SharedState.FPSFunctions
	player.CharacterAdded:Connect(ff.onCharacterAdded)
	if player.Character then ff.onCharacterAdded(player.Character) end
end
SharedState.FPSFunctions.initPlayerTracking = function()
	local ff = SharedState.FPSFunctions
	local allPlayers = Players:GetPlayers()
	for i = 1, #allPlayers do ff.onPlayerAdded(allPlayers[i]) end
	Players.PlayerAdded:Connect(ff.onPlayerAdded)
end
SharedState.FPSFunctions.initPlayerTracking()
task.spawn(function()
    local gs = cloneref and cloneref(game:GetService("GuiService")) or game:GetService("GuiService")
    local cg = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
    local ERROR_GUI_NAMES = {
        "ErrorPrompt",
        "ConnectionFailedPrompt",
        "BlockedPlayerPrompt",
        "ChatTranslationConsentPrompt",
        "RobloxErrorGui",
    }
    local function cleanErrors()
        pcall(function() gs:ClearError() end)
        for _, name in ipairs(ERROR_GUI_NAMES) do
            local g = cg:FindFirstChild(name)
            if g and g:IsA("ScreenGui") then
                pcall(function() g.Enabled = false end)
            end
        end
        for _, child in ipairs(cg:GetChildren()) do
            if child:IsA("ScreenGui") then
                local lower = child.Name:lower()
                if lower:find("error") or lower:find("disconnect") then
                    pcall(function() child.Enabled = false end)
                end
            end
        end
    end
    cleanErrors()
    while true do
        task.wait(0.05)
        pcall(cleanErrors)
    end
end)
task.spawn(function()
    task.wait(0.75)
    local HTheme = {
        Background = Color3.fromRGB(12, 0, 0),
        Accent1 = Color3.fromRGB(255, 30, 30),
        Accent2 = Color3.fromRGB(200, 10, 10),
        White   = Color3.fromRGB(255, 220, 220),
        Gray    = Color3.fromRGB(100,130,180),
        Success = Color3.fromRGB(220, 25, 25),
        Error   = Color3.fromRGB(255, 60, 80)
    }
    local SCALE = IS_MOBILE and 0.65 or 1
    local HEIGHT = 50 * SCALE
    local joinerGui = Instance.new("ScreenGui")
    joinerGui.Name = "XiJobJoiner"
    joinerGui.ResetOnSpawn = false
    joinerGui.Enabled = Config.ShowJobJoiner
    joinerGui.Parent = PlayerGui
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 500 * SCALE, 0, HEIGHT)
    local savedPos = Config.Positions.JobJoiner or {X = 0.5, Y = 0.85}
    main.AnchorPoint = Vector2.new(0.5, 0) 
    main.Position = UDim2.new(savedPos.X, 0, savedPos.Y, 0)
    main.BackgroundColor3 = Color3.fromRGB(20,22,28)
    main.BackgroundTransparency = 0.15
    main.BorderSizePixel = 0
    main.Parent = joinerGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    local bgGradient = Instance.new("UIGradient", main)
    bgGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20,22,28)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25,27,35))
    }
    bgGradient.Rotation = 45
    local stroke = Instance.new("UIStroke", main)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    local strokeGrad = Instance.new("UIGradient", stroke)
    strokeGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, HTheme.Accent1),
        ColorSequenceKeypoint.new(0.5, HTheme.Accent2),
        ColorSequenceKeypoint.new(1, HTheme.Accent1)
    }
    task.spawn(function()
    end)
    MakeDraggable(main, main, "JobJoiner")
    AddResizeHandle(main, "JobJoiner", UDim2.new(1, -22, 0, 6))
    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1, -20*SCALE, 1, 0)
    content.Position = UDim2.new(0, 10*SCALE, 0, 0)
    content.BackgroundTransparency = 1
    local layout = Instance.new("UIListLayout", content)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8 * SCALE)
    local function CreateInput(placeholder, width, default)
        local frame = Instance.new("Frame")
        frame.BackgroundTransparency = 1
        frame.Size = UDim2.new(0, width * SCALE, 0, 32 * SCALE)
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, 0, 0, 10 * SCALE)
        label.Position = UDim2.new(0, 0, 0, -10 * SCALE)
        label.BackgroundTransparency = 1
        label.Text = placeholder
        label.TextColor3 = HTheme.Accent1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 9 * SCALE
        local box = Instance.new("TextBox", frame)
        box.Size = UDim2.new(1, 0, 1, 0)
        box.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
        box.BackgroundTransparency = 0.5
        box.Text = default or ""
        box.PlaceholderText = placeholder
        box.TextColor3 = HTheme.White
        box.Font = Enum.Font.GothamBold
        box.TextSize = 12 * SCALE
        box.ClearTextOnFocus = false
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
        local s = Instance.new("UIStroke", box)
        s.Color = HTheme.Gray
        s.Thickness = 0.1
        s.Transparency = 0.6
        box.Focused:Connect(function() 
            TweenService:Create(s, TweenInfo.new(0.2), {Color = HTheme.Accent1, Transparency = 0}):Play() 
        end)
        box.FocusLost:Connect(function() 
            TweenService:Create(s, TweenInfo.new(0.2), {Color = HTheme.Gray, Transparency = 0.6}):Play() 
        end)
        return frame, box
    end
    local function CreateButton(text, width, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, width * SCALE, 0, 32 * SCALE)
        btn.BackgroundColor3 = color
        btn.BackgroundTransparency = 0.2
        btn.Text = text
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 12 * SCALE
        btn.TextColor3 = HTheme.White
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local s = Instance.new("UIStroke", btn)
        s.Color = color
        s.Thickness = 1.5
        s.Transparency = 0.4
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 0.1}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
            TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
        end)
        return btn
    end
    local joinBtn = CreateButton("JOIN", 60, HTheme.Success)
    joinBtn.Parent = content
    local idFrame, idBox = CreateInput("", 180, "")
    idBox.PlaceholderText = ""
    idFrame.Parent = content
    idBox.TextTruncate = Enum.TextTruncate.AtEnd
    local clearBtn = CreateButton("CLEAR", 50, Color3.fromRGB(30, 55, 110))
    clearBtn.Parent = content
    local attFrame, attBox = CreateInput("Attempts", 60, "2000")
    attFrame.Parent = content
    local delFrame, delBox = CreateInput("Delay", 50, "0.001")
    delFrame.Parent = content
    local isJoining = false
    joinBtn.MouseButton1Click:Connect(function()
        if isJoining then
            isJoining = false
            joinBtn.Text = "JOIN"
            joinBtn.BackgroundColor3 = HTheme.Success
            ShowNotification("JOINER", "Process Cancelled")
            return
        end
        local jobId = idBox.Text:gsub("%s+", "") 
        local attempts = tonumber(attBox.Text) or 10
        local delayTime = tonumber(delBox.Text) or 0.5
        if jobId == "" or #jobId < 5 then
            ShowNotification("ERROR", "Invalid JobID")
            return
        end
        isJoining = true
        joinBtn.Text = "STOP"
        joinBtn.BackgroundColor3 = HTheme.Error
        task.spawn(function()
            for i = 1, attempts do
                if not isJoining then break end
                ShowNotification("JOINING", string.format("Attempt %d/%d...", i, attempts))
                local success, err = pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
                end)
                if not success then
                end
                task.wait(delayTime)
            end
            isJoining = false
            if joinBtn and joinBtn.Parent then
                joinBtn.Text = "JOIN"
                joinBtn.BackgroundColor3 = HTheme.Success
            end
        end)
    end)
    clearBtn.MouseButton1Click:Connect(function()
        idBox.Text = ""
    end)
end)
do
    local wasStealingForBackTP = false
    local backTPTargetPos = nil
    LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
        local state = LocalPlayer:GetAttribute("Stealing")
        if state then
            wasStealingForBackTP = true
            backTPTargetPos = nil
            pcall(function()
                local petData = SharedState.SelectedPetData and SharedState.SelectedPetData.animalData
                if petData then
                    local targetPart = findAdorneeGlobal(petData)
                    if targetPart then
                        backTPTargetPos = targetPart.Position
                    end
                end
            end)
        else
            if not wasStealingForBackTP then return end
            wasStealingForBackTP = false
            if not Config.AutoTPBackToBrainrot then return end
            if not backTPTargetPos then return end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local closestBaseIdx = getClosestBaseIdx(hrp.Position)
            local targetBaseIdx = getClosestBaseIdx(backTPTargetPos)
            local isInTargetBase = (closestBaseIdx == targetBaseIdx)
            local playerY = hrp.Position.Y
            local brainrotY = backTPTargetPos.Y
            local function getFloor(y)
                if y <= 10 then return 1
                elseif y <= 20 then return 2
                else return 3 end
            end
            local playerFloor = getFloor(playerY)
            local brainrotFloor = getFloor(brainrotY)
            local floorOk = (playerFloor == brainrotFloor) or (brainrotFloor == 3 and playerFloor == 2)
            if isInTargetBase and floorOk then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local carpetName = Config.TpSettings and Config.TpSettings.Tool or "Flying Carpet"
                local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
                if carpet and hum then hum:EquipTool(carpet) end
                local isFloor2to3 = (brainrotFloor == 3 and playerFloor == 2)
                if isFloor2to3 then
                    local platform = Instance.new("Part")
                    platform.Name = "XiBackTPPlatform"
                    platform.Size = Vector3.new(6, 0.5, 6)
                    platform.Position = Vector3.new(backTPTargetPos.X, 18, backTPTargetPos.Z)
                    platform.Anchored = true
                    platform.CanCollide = true
                    platform.Material = Enum.Material.SmoothPlastic
                    platform.Color = Color3.fromRGB(0, 120, 255)
                    platform.Transparency = 0.4
                    platform.Parent = Workspace
                    task.spawn(function()
                        local conn
                        conn = LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
                            if LocalPlayer:GetAttribute("Stealing") == true then
                                conn:Disconnect()
                                if platform and platform.Parent then platform:Destroy() end
                            end
                        end)
                    end)
                end
                local tpY = isFloor2to3 and 21.5 or hrp.Position.Y
                local tpPos = Vector3.new(backTPTargetPos.X, tpY, backTPTargetPos.Z)
                hrp.CFrame = CFrame.new(tpPos)
                ShowNotification("AUTO TP BACK", "Teleported back to brainrot!")
            end
        end
    end)
end
task.spawn(function()
    task.wait(0.9)
    local autoBuyActive = false
    _G.AutoBuyEsteira   = false
    if not Config.AutoBuyKey   then Config.AutoBuyKey   = "K"  end
    if not Config.AutoBuyRange then Config.AutoBuyRange = 17   end
    if not Config.AutoBuyColor then Config.AutoBuyColor = {R=180,G=180,B=180} end
    local oldAB = PlayerGui:FindFirstChild("XiAutoBuyUI")
    if oldAB then oldAB:Destroy() end
    local abGui = Instance.new("ScreenGui")
    abGui.Name         = "XiAutoBuyUI"
    abGui.ResetOnSpawn = false
    abGui.DisplayOrder = 30
    abGui.Parent       = PlayerGui
    local abPanel = Instance.new("Frame", abGui)
    abPanel.Name             = "ABPanel"
    abPanel.Size             = UDim2.new(0, 280, 0, 302)
    abPanel.Position         = UDim2.new(Config.Positions.AutoBuy.X, 0, Config.Positions.AutoBuy.Y, 0)
    abPanel.BackgroundColor3 = Theme.Background
    abPanel.BackgroundTransparency = 0.08
    abPanel.BorderSizePixel  = 0
    Instance.new("UICorner", abPanel).CornerRadius = UDim.new(0, 10)
    local abStroke = Instance.new("UIStroke", abPanel)
    abStroke.Color = Theme.Accent1; abStroke.Thickness = 1.8; abStroke.Transparency = 0.35
    local abHdr = Instance.new("Frame", abPanel)
    abHdr.Size               = UDim2.new(1, 0, 0, 36)
    abHdr.BackgroundTransparency = 1
    MakeDraggable(abHdr, abPanel, "AutoBuy")
    AddResizeHandle(abPanel, "AutoBuy", UDim2.new(1, -22, 0, 6))
    local abTitle = Instance.new("TextLabel", abHdr)
    abTitle.Size             = UDim2.new(1, -12, 1, 0)
    abTitle.Position         = UDim2.new(0, 12, 0, 0)
    abTitle.BackgroundTransparency = 1
    abTitle.Text             = "AUTO BUY"
    abTitle.Font             = Enum.Font.GothamBlack
    abTitle.TextSize         = 15
    abTitle.TextColor3       = Theme.Accent1
    abTitle.TextXAlignment   = Enum.TextXAlignment.Left
    local abDiv = Instance.new("Frame", abPanel)
    abDiv.Size             = UDim2.new(1, -20, 0, 1)
    abDiv.Position         = UDim2.new(0, 10, 0, 36)
    abDiv.BackgroundColor3 = Theme.Accent1
    abDiv.BackgroundTransparency = 0.6
    abDiv.BorderSizePixel  = 0
    local abContent = Instance.new("Frame", abPanel)
    abContent.Size             = UDim2.new(1, -16, 1, -46)
    abContent.Position         = UDim2.new(0, 8, 0, 44)
    abContent.BackgroundTransparency = 1
    local abLayout = Instance.new("UIListLayout", abContent)
    abLayout.Padding   = UDim.new(0, 6)
    abLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local function makeAbRow(h, order)
        local r = Instance.new("Frame", abContent)
        r.Size             = UDim2.new(1, 0, 0, h)
        r.BackgroundColor3 = Theme.Surface
        r.BackgroundTransparency = 0.05
        r.BorderSizePixel  = 0
        r.LayoutOrder      = order
        Instance.new("UICorner", r).CornerRadius = UDim.new(0, 7)
        return r
    end
    local abToggleRow = makeAbRow(38, 1)
    local abToggleBtn = Instance.new("TextButton", abToggleRow)
    abToggleBtn.Size             = UDim2.new(1, 0, 1, 0)
    abToggleBtn.BackgroundColor3 = Theme.Surface
    abToggleBtn.BackgroundTransparency = 0
    abToggleBtn.Text             = "AUTO BUY: OFF"
    abToggleBtn.Font             = Enum.Font.GothamBlack
    abToggleBtn.TextSize         = 13
    abToggleBtn.TextColor3       = Theme.TextSecondary
    abToggleBtn.BorderSizePixel  = 0
    abToggleBtn.AutoButtonColor  = false
    Instance.new("UICorner", abToggleBtn).CornerRadius = UDim.new(0, 7)
    local abToggleStroke = Instance.new("UIStroke", abToggleBtn)
    abToggleStroke.Color = Theme.Accent1; abToggleStroke.Thickness = 1.5; abToggleStroke.Transparency = 0.5
    local abKeyRow = makeAbRow(34, 2)
    local abKeyLbl = Instance.new("TextLabel", abKeyRow)
    abKeyLbl.Size             = UDim2.new(1, -70, 1, 0)
    abKeyLbl.Position         = UDim2.new(0, 10, 0, 0)
    abKeyLbl.BackgroundTransparency = 1
    abKeyLbl.Text             = "Keybind"
    abKeyLbl.Font             = Enum.Font.GothamBold
    abKeyLbl.TextSize         = 12
    abKeyLbl.TextColor3       = Theme.TextPrimary
    abKeyLbl.TextXAlignment   = Enum.TextXAlignment.Left
    local abKeyBtn = Instance.new("TextButton", abKeyRow)
    abKeyBtn.Size             = UDim2.new(0, 56, 0, 24)
    abKeyBtn.Position         = UDim2.new(1, -62, 0.5, -12)
    abKeyBtn.BackgroundColor3 = Theme.SurfaceHighlight
    abKeyBtn.Text             = Config.AutoBuyKey or "K"
    abKeyBtn.Font             = Enum.Font.GothamBold
    abKeyBtn.TextSize         = 11
    abKeyBtn.TextColor3       = Theme.Accent1
    abKeyBtn.AutoButtonColor  = false
    abKeyBtn.BorderSizePixel  = 0
    Instance.new("UICorner", abKeyBtn).CornerRadius = UDim.new(0, 5)
    abKeyBtn.MouseButton1Click:Connect(function()
        abKeyBtn.Text = "..."; abKeyBtn.TextColor3 = Theme.TextSecondary
        local c; c = UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                Config.AutoBuyKey = inp.KeyCode.Name
                abKeyBtn.Text = inp.KeyCode.Name
                abKeyBtn.TextColor3 = Theme.Accent1
                SaveConfig(); c:Disconnect()
            end
        end)
    end)
    local abRangeRow = makeAbRow(42, 3)
    local abRangeLbl = Instance.new("TextLabel", abRangeRow)
    abRangeLbl.Size           = UDim2.new(1, -10, 0, 16)
    abRangeLbl.Position       = UDim2.new(0, 10, 0, 4)
    abRangeLbl.BackgroundTransparency = 1
    abRangeLbl.Text           = "Range: " .. (Config.AutoBuyRange or 17) .. " studs"
    abRangeLbl.Font           = Enum.Font.GothamBold
    abRangeLbl.TextSize       = 11
    abRangeLbl.TextColor3     = Theme.TextPrimary
    abRangeLbl.TextXAlignment = Enum.TextXAlignment.Left
    local abSlBg = Instance.new("Frame", abRangeRow)
    abSlBg.Size             = UDim2.new(1, -20, 0, 6)
    abSlBg.Position         = UDim2.new(0, 10, 0, 28)
    abSlBg.BackgroundColor3 = Theme.SurfaceHighlight
    abSlBg.BorderSizePixel  = 0
    Instance.new("UICorner", abSlBg).CornerRadius = UDim.new(1, 0)
    local abSlFill = Instance.new("Frame", abSlBg)
    abSlFill.BackgroundColor3 = Theme.Accent1
    abSlFill.BorderSizePixel  = 0
    Instance.new("UICorner", abSlFill).CornerRadius = UDim.new(1, 0)
    local abSlKnob = Instance.new("Frame", abSlBg)
    abSlKnob.Size         = UDim2.new(0, 13, 0, 13)
    abSlKnob.AnchorPoint  = Vector2.new(0.5, 0.5)
    abSlKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    abSlKnob.BorderSizePixel  = 0
    Instance.new("UICorner", abSlKnob).CornerRadius = UDim.new(1, 0)
    local abSlKS = Instance.new("UIStroke", abSlKnob)
    abSlKS.Color = Theme.Accent1; abSlKS.Thickness = 1.5
    local AB_MIN, AB_MAX = 5, 40
    local function updateAbSlider(v)
        v = math.clamp(math.floor(v), AB_MIN, AB_MAX)
        Config.AutoBuyRange = v; SaveConfig()
        abRangeLbl.Text = "Range: " .. v .. " studs"
        local pct = (v - AB_MIN) / (AB_MAX - AB_MIN)
        abSlFill.Size     = UDim2.new(pct, 0, 1, 0)
        abSlKnob.Position = UDim2.new(pct, 0, 0.5, 0)
        local ring = Workspace:FindFirstChild("XiAutoBuyRing")
        if ring then ring.Size = Vector3.new(0.5, v*2, v*2) end
    end
    updateAbSlider(Config.AutoBuyRange or 17)
    local abDrag = false
    abSlBg.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            abDrag=true
            updateAbSlider(AB_MIN+((i.Position.X-abSlBg.AbsolutePosition.X)/abSlBg.AbsoluteSize.X)*(AB_MAX-AB_MIN))
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then abDrag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if abDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            updateAbSlider(AB_MIN+((i.Position.X-abSlBg.AbsolutePosition.X)/abSlBg.AbsoluteSize.X)*(AB_MAX-AB_MIN))
        end
    end)
    local abCircleRow = makeAbRow(60, 4)
    local abCircleLbl = Instance.new("TextLabel", abCircleRow)
    abCircleLbl.Size             = UDim2.new(1, 0, 0, 18)
    abCircleLbl.Position         = UDim2.new(0, 10, 0, 4)
    abCircleLbl.BackgroundTransparency = 1
    abCircleLbl.Text             = "Circle Color"
    abCircleLbl.Font             = Enum.Font.GothamBold
    abCircleLbl.TextSize         = 11
    abCircleLbl.TextColor3       = Theme.TextPrimary
    abCircleLbl.TextXAlignment   = Enum.TextXAlignment.Left
    local THEME_SWATCHES = {
        Color3.fromRGB(255,120,200),
        Color3.fromRGB(0,220,255),
        Color3.fromRGB(255,215,0),
        Color3.fromRGB(210,215,235),
        Color3.fromRGB(200,200,210),
        Color3.fromRGB(180,80,255),
        Color3.fromRGB(0,220,80),
        Color3.fromRGB(255,140,0),
    }
    local abSwatchFrame = Instance.new("Frame", abCircleRow)
    abSwatchFrame.Size             = UDim2.new(1, -16, 0, 36)
    abSwatchFrame.Position         = UDim2.new(0, 8, 0, 22)
    abSwatchFrame.BackgroundTransparency = 1
    local swatchGrid = Instance.new("UIGridLayout", abSwatchFrame)
    swatchGrid.CellSize        = UDim2.new(0, 24, 0, 16)
    swatchGrid.CellPadding     = UDim2.new(0, 4, 0, 4)
    swatchGrid.SortOrder       = Enum.SortOrder.LayoutOrder
    swatchGrid.FillDirection   = Enum.FillDirection.Horizontal
    local function buildCirclePresets()
        for _, ch in ipairs(abSwatchFrame:GetChildren()) do
            if ch:IsA("TextButton") then ch:Destroy() end
        end
        for i, col in ipairs(THEME_SWATCHES) do
            local cb = Instance.new("TextButton", abSwatchFrame)
            cb.LayoutOrder      = i
            cb.Size             = UDim2.new(0, 24, 0, 16)
            cb.BackgroundColor3 = col
            cb.Text             = ""
            cb.BorderSizePixel  = 0
            cb.AutoButtonColor  = false
            Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 4)
            local selStroke = Instance.new("UIStroke", cb)
            selStroke.Thickness = 1.5
            local cur = Config.AutoBuyColor
            local match = cur and math.abs(cur.R - math.floor(col.R*255)) < 2
                              and math.abs(cur.G - math.floor(col.G*255)) < 2
                              and math.abs(cur.B - math.floor(col.B*255)) < 2
            selStroke.Color        = Color3.new(1,1,1)
            selStroke.Transparency = match and 0 or 1
            cb.MouseButton1Click:Connect(function()
                Config.AutoBuyColor = {
                    R = math.floor(col.R*255),
                    G = math.floor(col.G*255),
                    B = math.floor(col.B*255),
                }
                SaveConfig()
                local ring = Workspace:FindFirstChild("XiAutoBuyRing")
                if ring then ring.Color = col end
                buildCirclePresets()
            end)
        end
    end
    buildCirclePresets()
    local abRejoinRow = makeAbRow(34, 5)
    local abRejoinBtn = Instance.new("TextButton", abRejoinRow)
    abRejoinBtn.Size             = UDim2.new(1, -16, 0, 24)
    abRejoinBtn.Position         = UDim2.new(0, 8, 0.5, -12)
    abRejoinBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    abRejoinBtn.Text             = "⟳  REJOIN SERVER"
    abRejoinBtn.Font             = Enum.Font.GothamBlack
    abRejoinBtn.TextSize         = 12
    abRejoinBtn.TextColor3       = Color3.new(1, 1, 1)
    abRejoinBtn.BorderSizePixel  = 0
    abRejoinBtn.AutoButtonColor  = false
    Instance.new("UICorner", abRejoinBtn).CornerRadius = UDim.new(0, 6)
    local rejoinStroke = Instance.new("UIStroke", abRejoinBtn)
    rejoinStroke.Color = Color3.fromRGB(255, 100, 100)
    rejoinStroke.Thickness = 1.2
    rejoinStroke.Transparency = 0.4
    abRejoinBtn.MouseEnter:Connect(function()
        abRejoinBtn.BackgroundTransparency = 0.15
    end)
    abRejoinBtn.MouseLeave:Connect(function()
        abRejoinBtn.BackgroundTransparency = 0
    end)
    abRejoinBtn.MouseButton1Click:Connect(function()
        abRejoinBtn.Text = "Rejoining..."
        abRejoinBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        task.wait(0.3)
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end)
    local abRing = nil
    local function getCircleColor()
        if Config.AutoBuyColor then
            local c = Config.AutoBuyColor
            return Color3.fromRGB(c.R, c.G, c.B)
        end
        return Theme.Accent1
    end
    local function createRing()
        local existing = Workspace:FindFirstChild("XiAutoBuyRing")
        if existing then existing:Destroy() end
        local r = Instance.new("Part")
        r.Name         = "XiAutoBuyRing"
        r.Shape        = Enum.PartType.Cylinder
        r.Anchored     = true
        r.CanCollide   = false
        r.CanTouch     = false
        r.CanQuery     = false
        r.CastShadow   = false
        r.Material     = Enum.Material.Neon
        r.Transparency = 0.5
        r.Color        = getCircleColor()
        local range    = Config.AutoBuyRange or 17
        r.Size         = Vector3.new(0.5, range*2, range*2)
        r.Parent       = Workspace
        abRing = r
    end
    local function destroyRing()
        if abRing then abRing:Destroy(); abRing = nil end
        local existing = Workspace:FindFirstChild("XiAutoBuyRing")
        if existing then existing:Destroy() end
    end
    task.spawn(function()
        while true do
            task.wait(0.05)
            if not autoBuyActive then continue end
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp or not abRing or not abRing.Parent then continue end
            local range = Config.AutoBuyRange or 17
            abRing.Size  = Vector3.new(0.5, range*2, range*2)
            abRing.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(90)) + Vector3.new(0, -2.5, 0)
        end
    end)
    local function toggleAutoBuy()
        autoBuyActive = not autoBuyActive
        _G.AutoBuyEsteira = autoBuyActive
        if autoBuyActive then
            abToggleBtn.Text             = "AUTO BUY: ON"
            abToggleBtn.BackgroundColor3 = Theme.Accent1
            abToggleBtn.TextColor3       = Color3.new(0, 0, 0)
            abToggleStroke.Transparency  = 1
            createRing()
        else
            abToggleBtn.Text             = "AUTO BUY: OFF"
            abToggleBtn.BackgroundColor3 = Theme.Surface
            abToggleBtn.TextColor3       = Theme.TextSecondary
            abToggleStroke.Transparency  = 0.5
            destroyRing()
        end
        if _G.AutoBuyOnToggle then _G.AutoBuyOnToggle(autoBuyActive) end
        ShowNotification("AUTO BUY", autoBuyActive and "ENABLED" or "DISABLED")
    end
    abToggleBtn.MouseButton1Click:Connect(toggleAutoBuy)
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        local ok, kc = pcall(function() return Enum.KeyCode[Config.AutoBuyKey or "K"] end)
        if ok and kc and inp.KeyCode == kc then toggleAutoBuy() end
    end)
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if autoBuyActive then createRing() end
    end)
    task.spawn(function()
        local Packages  = ReplicatedStorage:WaitForChild("Packages")
        local Datas     = ReplicatedStorage:WaitForChild("Datas")
        local Shared    = ReplicatedStorage:WaitForChild("Shared")
        local Utils     = ReplicatedStorage:WaitForChild("Utils")
        local AnimData   = require(Datas:WaitForChild("Animals"))
        local AnimShared = require(Shared:WaitForChild("Animals"))
        local NumUtils   = require(Utils:WaitForChild("NumberUtils"))
        local RARITY_WORDS = {common=true,uncommon=true,rare=true,epic=true,legendary=true,
            secret=true,divine=true,rainbow=true,cursed=true,gold=true,diamond=true}
        local function getBrainrotName(model)
            if not model then return "Brainrot","" end
            local nameFound, genFound = "",""
            for _, bb in ipairs(model:GetDescendants()) do
                if bb:IsA("BillboardGui") then
                    for _, lbl in ipairs(bb:GetDescendants()) do
                        if lbl:IsA("TextLabel") and lbl.Text and lbl.Text ~= "" then
                            local t = lbl.Text:match("^%s*(.-)%s*$")
                            local tl = t:lower()
                            if RARITY_WORDS[tl] then continue end
                            if t:match("^%$[%d%.]+[KkMmBb]?/s$") then
                                if genFound=="" then genFound=t end; continue
                            end
                            if t:match("^%$[%d%.]+[KkMmBb]?$") then continue end
                            if t:match("^[%d%.]+[KkMmBb]?$") then continue end
                            if nameFound=="" and #t>1 then nameFound=t end
                        end
                    end
                end
            end
            if nameFound=="" then
                pcall(function()
                    local info = AnimData[model.Name]
                    if info and info.DisplayName then
                        nameFound = info.DisplayName
                        local gv = AnimShared:GetGeneration(model.Name,nil,nil,nil)
                        genFound = "$"..NumUtils:ToString(gv).."/s"
                    end
                end)
            end
            if nameFound=="" then nameFound = model.Name~="" and model.Name or "Brainrot" end
            return nameFound, genFound
        end
        local function scanConveyor()
            local results = {}
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if not (obj:IsA("ProximityPrompt") and obj.Enabled) then continue end
                local txt = obj.ActionText or ""
                if not (txt=="Purchase" or txt:lower():find("purchase") or txt:lower():find("comprar")) then continue end
                local part = obj.Parent
                if not part then continue end
                local realPart = part:IsA("Attachment") and part.Parent or part
                if not (realPart and realPart:IsA("BasePart")) then continue end
                local model, cur = nil, realPart
                for _ = 1, 8 do
                    if cur and cur:IsA("Model") then model=cur; break end
                    cur = cur and cur.Parent
                end
                local name, gen = getBrainrotName(model)
                table.insert(results, {
                    name=name, gen=gen, prompt=obj, part=realPart,
                    model=model, source="ESTEIRA", uid="esteira_"..tostring(obj),
                })
            end
            return results
        end
        SharedState.ConveyorAnimals = {}
        local function refreshConveyor()
            local ok, found = pcall(scanConveyor)
            if ok and found then SharedState.ConveyorAnimals = found end
        end
        refreshConveyor()
        _G.refreshConveyor = refreshConveyor
        local purchaseRemote = nil
        local function resolvePurchaseRemote()
            if purchaseRemote and purchaseRemote.Parent then return purchaseRemote end
            pcall(function()
                local net = ReplicatedStorage:FindFirstChild("Packages")
                         and ReplicatedStorage.Packages:FindFirstChild("Net")
                if not net then return end
                local kws = {"buy","purchase","animal","shop","acquire","conveyor"}
                for _, v in ipairs(net:GetChildren()) do
                    local nl = (v.Name or ""):lower()
                    for _, kw in ipairs(kws) do
                        if nl:find(kw) then purchaseRemote=v; return end
                    end
                end
                local paths = {"RF/ShopService/BuyAnimal","RF/AnimalShop/Purchase","RE/Shop/Buy","RF/Shop/Buy"}
                for _, p in ipairs(paths) do
                    local ok2, r = pcall(function() return Utility:LarpNet(p) end)
                    if ok2 and r and r.Parent then purchaseRemote=r; return end
                end
            end)
            return purchaseRemote
        end
        local function firePurchaseNatural(prompt)
            if not prompt or not prompt.Parent or not prompt.Enabled then return end
            pcall(function()
                if _G.firePromptDirect then
                    _G.firePromptDirect(prompt)
                elseif fireproximityprompt then
                    fireproximityprompt(prompt)
                end
            end)
            task.spawn(function()
                local remote = resolvePurchaseRemote()
                if remote then
                    pcall(function()
                        if remote:IsA("RemoteFunction") then
                            remote:InvokeServer(prompt.Parent)
                        elseif remote:IsA("RemoteEvent") then
                            remote:FireServer(prompt.Parent)
                        end
                    end)
                end
            end)
        end
        local carpetLockConn = nil
        local function startCarpetLock()
            if carpetLockConn then carpetLockConn:Disconnect(); carpetLockConn = nil end
            local function ensureCarpet()
                pcall(function()
                    local char = LocalPlayer.Character
                    local hum  = char and char:FindFirstChildOfClass("Humanoid")
                    if not hum then return end
                    local toolName = Config.TpSettings and Config.TpSettings.Tool or "Flying Carpet"
                    if not char:FindFirstChild(toolName) then
                        local tool = LocalPlayer.Backpack:FindFirstChild(toolName)
                        if tool then hum:EquipTool(tool) end
                    end
                end)
            end
            task.spawn(function()
                for _ = 1, 15 do
                    if not autoBuyActive then break end
                    ensureCarpet()
                    task.wait(0.3)
                    local char = LocalPlayer.Character
                    local toolName = Config.TpSettings and Config.TpSettings.Tool or "Flying Carpet"
                    if char and char:FindFirstChild(toolName) then break end
                end
            end)
            local _clActive = true
            local _clThread = task.spawn(function()
                while _clActive do
                    task.wait(0.1)
                    if not autoBuyActive then continue end
                    pcall(function()
                        local char = LocalPlayer.Character
                        local hum  = char and char:FindFirstChildOfClass("Humanoid")
                        if not hum then return end
                        local toolName = Config.TpSettings and Config.TpSettings.Tool or "Flying Carpet"
                        if not char:FindFirstChild(toolName) then
                            local tool = LocalPlayer.Backpack:FindFirstChild(toolName)
                            if tool then hum:EquipTool(tool) end
                        end
                    end)
                end
            end)
            carpetLockConn = {Disconnect = function() _clActive = false; task.cancel(_clThread) end}
        end
        local function stopCarpetLock()
            if carpetLockConn then carpetLockConn:Disconnect(); carpetLockConn = nil end
        end
        local HOVER_HEIGHT  = 5
        local BUY_INTERVAL  = 0.08
        local HOVER_DEADZONE = 0.4
        local lockedTarget = nil
        local lockedPart   = nil
        local lockedModel  = nil
        local function partAlive()
            return lockedPart  and lockedPart.Parent
                and lockedModel and lockedModel.Parent
        end
        local function promptAlive()
            return lockedTarget and lockedTarget.prompt
                and lockedTarget.prompt.Parent and lockedTarget.prompt.Enabled
        end
        local _hoverConn = nil
        local currentAbToken = nil
        local function stopHover()
            if _hoverConn then _hoverConn:Disconnect(); _hoverConn = nil end
            if currentAbToken then currentAbToken.cancelled = true; currentAbToken = nil end
        end
        local function startHover()
            stopHover()
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp or not partAlive() then return end
            local targetPos = lockedPart.Position + Vector3.new(0, HOVER_HEIGHT, 0)
            local drift = (hrp.Position - targetPos).Magnitude
            local myTok = { cancelled = false }
            currentAbToken = myTok
            if drift > 6 then
                task.spawn(function()
                    local speed = Config.TweenTpSpeedF1 or 140
                    local arrived = carpetFly(hrp, targetPos, {
                        speed = speed,
                        safetyPad = 0,
                        arriveDist = 3,
                        timeout = 6,
                        cancelToken = myTok
                    })
                    if myTok.cancelled then return end
                    if not autoBuyActive or not partAlive() then return end
                    _hoverConn = RunService.Heartbeat:Connect(function()
                        if not autoBuyActive or not partAlive() or myTok.cancelled then return end
                        local c = LocalPlayer.Character
                        local h = c and c:FindFirstChild("HumanoidRootPart")
                        if not h then return end
                        local currentTargetPos = lockedPart.Position + Vector3.new(0, HOVER_HEIGHT, 0)
                        local d = (h.Position - currentTargetPos).Magnitude
                        if d > HOVER_DEADZONE then
                            h.CFrame = CFrame.new(currentTargetPos) * (h.CFrame - h.CFrame.Position)
                        end
                    end)
                end)
            else
                _hoverConn = RunService.Heartbeat:Connect(function()
                    if not autoBuyActive or not partAlive() or myTok.cancelled then return end
                    local c = LocalPlayer.Character
                    local h = c and c:FindFirstChild("HumanoidRootPart")
                    if not h then return end
                    local currentTargetPos = lockedPart.Position + Vector3.new(0, HOVER_HEIGHT, 0)
                    local d = (h.Position - currentTargetPos).Magnitude
                    if d > HOVER_DEADZONE then
                        h.CFrame = CFrame.new(currentTargetPos) * (h.CFrame - h.CFrame.Position)
                    end
                end)
            end
        end
        startHover()
        task.spawn(function()
            while true do
                task.wait(BUY_INTERVAL)
                if not autoBuyActive then continue end
                if not partAlive()   then continue end
                if promptAlive() then
                    firePurchaseNatural(lockedTarget.prompt)
                end
            end
        end)
        task.spawn(function()
            while true do
                task.wait(0.5)
                if not autoBuyActive then continue end
                if _G.refreshConveyor then _G.refreshConveyor() end
            end
        end)
        task.spawn(function()
            while true do
                task.wait(0.1)  
                if not autoBuyActive then
                    lockedTarget=nil; lockedPart=nil; lockedModel=nil
                    stopCarpetLock()
                    stopHover()
                    continue
                end
                if lockedPart or lockedModel then
                    if not partAlive() then
                        if _G.refreshConveyor then _G.refreshConveyor() end
                        lockedTarget=nil; lockedPart=nil; lockedModel=nil
                        ShowNotification("AUTO BUY", "Bought! Scanning for next...")
                    else
                        continue
                    end
                end
                local char = LocalPlayer.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end
                local best, bestDist = nil, math.huge
                for _, entry in ipairs(SharedState.ConveyorAnimals) do
                    if entry.prompt and entry.prompt.Parent and entry.prompt.Enabled
                    and entry.part  and entry.part.Parent then
                        local d = (hrp.Position - entry.part.Position).Magnitude
                        if d < bestDist then bestDist=d; best=entry end
                    end
                end
                if best then
                    lockedTarget = best
                    lockedPart   = best.part
                    lockedModel  = best.model or best.part.Parent
                    ShowNotification("AUTO BUY", "Locked: " .. best.name)
                    startCarpetLock()
                    startHover()
                end
            end
        end)
        _G.AutoBuyOnToggle = function(active)
            if active then
                if _G.refreshConveyor then _G.refreshConveyor() end
                startCarpetLock()
            else
                stopCarpetLock()
            end
        end
    end)
end)
do
    local Players_RS = game:GetService("Players")
    local UserInputService_RS = game:GetService("UserInputService")
    local player_RS = Players_RS.LocalPlayer
    local screenGui_RS = nil
    local watcherConn_RS = nil
    local rsBuilt = false
    local lockedPlot_RS = nil
    local function findMyPlot_RS()
        if lockedPlot_RS and lockedPlot_RS.Parent then return lockedPlot_RS end
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil end
        local myName = player_RS.Name:lower()
        local myId = tostring(player_RS.UserId)
        local myDisplayName = player_RS.DisplayName:lower()
        for _, plot in ipairs(plots:GetChildren()) do
            for _, v in ipairs(plot:GetDescendants()) do
                if v:IsA("StringValue") then
                    local val = tostring(v.Value):lower()
                    if val == myName or val == myId or val == myDisplayName then
                        lockedPlot_RS = plot; return plot
                    end
                    local vname = v.Name:lower()
                    if vname:find("owner") or vname:find("player") or vname:find("user") then
                        if val == myName or val == myId or val == myDisplayName then
                            lockedPlot_RS = plot; return plot
                        end
                    end
                elseif v:IsA("IntValue") then
                    if tostring(v.Value) == myId then lockedPlot_RS = plot; return plot end
                elseif v:IsA("ObjectValue") then
                    if v.Value == player_RS then lockedPlot_RS = plot; return plot end
                end
            end
        end
        local char = player_RS.Character or player_RS.CharacterAdded:Wait()
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local closest, closestDist = nil, math.huge
            for _, plot in ipairs(plots:GetChildren()) do
                local ok, pos = pcall(function() return plot:GetPivot().Position end)
                if ok then
                    local dist = (pos - root.Position).Magnitude
                    if dist < closestDist then closest = plot; closestDist = dist end
                end
            end
            if closest then lockedPlot_RS = closest; return closest end
        end
        return nil
    end
    local function buildRemoteSell()
        if rsBuilt and screenGui_RS and screenGui_RS.Parent then return end
        rsBuilt = true
        screenGui_RS = Instance.new("ScreenGui")
        screenGui_RS.Name = "ZawaHubRemoteSell"
        screenGui_RS.ResetOnSpawn = false
        screenGui_RS.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui_RS.Parent = player_RS:WaitForChild("PlayerGui")
        local SAVE_FILE = "ZawasPublic_remotesell_pos.txt"
        local FRAME_W, FRAME_H = 265, 445
        local screenSize = workspace.CurrentCamera.ViewportSize
        local function clampPos(x, y)
            x = math.clamp(x, 0, screenSize.X - FRAME_W)
            y = math.clamp(y, 0, screenSize.Y - FRAME_H)
            return x, y
        end
        local savedX, savedY = nil, nil
        local ok, data = pcall(readfile, SAVE_FILE)
        if ok and data then
            local x, y = data:match("(-?[%d%.]+),(-?[%d%.]+)")
            if x and y then savedX, savedY = clampPos(tonumber(x), tonumber(y)) end
        end
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, FRAME_W, 0, FRAME_H)
        mainFrame.Position = (savedX and savedY)
            and UDim2.new(0, savedX, 0, savedY)
            or UDim2.new(0.5, -132, 0.5, -219)
        mainFrame.BackgroundColor3 = Theme.Background
        mainFrame.BorderSizePixel = 0
        mainFrame.Active = true
        mainFrame.Draggable = false
        mainFrame.ZIndex = 2
        mainFrame.Parent = screenGui_RS
        Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
        local stroke = Instance.new("UIStroke")
        stroke.Color = Theme.Accent1
        stroke.Thickness = 1.5
        stroke.Transparency = 0.4
        stroke.Parent = mainFrame
        do
            local dragging, dragStart, startPos
            mainFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = mainFrame.Position
                end
            end)
            UserInputService_RS.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input.Position - dragStart
                    local rawX = startPos.X.Offset + delta.X
                    local rawY = startPos.Y.Offset + delta.Y
                    local cx, cy = clampPos(rawX, rawY)
                    mainFrame.Position = UDim2.new(0, cx, 0, cy)
                end
            end)
            UserInputService_RS.InputEnded:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch) and dragging then
                    dragging = false
                    pcall(writefile, SAVE_FILE, mainFrame.Position.X.Offset .. "," .. mainFrame.Position.Y.Offset)
                end
            end)
        end
        local accentLine = Instance.new("Frame")
        accentLine.Size = UDim2.new(1, 0, 0, 2)
        accentLine.Position = UDim2.new(0, 0, 0, 48)
        accentLine.BackgroundColor3 = Theme.Accent1
        accentLine.BorderSizePixel = 0
        accentLine.ZIndex = 3
        accentLine.Parent = mainFrame
        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 48)
        titleBar.BackgroundColor3 = Color3.fromRGB(20, 4, 4)
        titleBar.BorderSizePixel = 0
        titleBar.ZIndex = 3
        titleBar.Parent = mainFrame
        Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 8, 0, 8)
        dot.Position = UDim2.new(0, 14, 0.5, -4)
        dot.BackgroundColor3 = Theme.Accent1
        dot.BorderSizePixel = 0
        dot.ZIndex = 4
        dot.Parent = titleBar
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -80, 1, 0)
        titleLabel.Position = UDim2.new(0, 30, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "REMOTE SELL"
        titleLabel.TextColor3 = Theme.Accent1
        titleLabel.Font = Enum.Font.GothamBlack
        titleLabel.TextSize = 15
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.ZIndex = 4
        titleLabel.Parent = titleBar
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 26, 0, 26)
        closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
        closeBtn.BackgroundColor3 = Theme.Accent2
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 12
        closeBtn.BorderSizePixel = 0
        closeBtn.ZIndex = 4
        closeBtn.Parent = titleBar
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
        closeBtn.MouseButton1Click:Connect(function()
            Config.ShowRemoteSell = false
            SaveConfig()
            if screenGui_RS then screenGui_RS:Destroy(); screenGui_RS = nil end
            rsBuilt = false
            if watcherConn_RS then watcherConn_RS:Disconnect(); watcherConn_RS = nil end
        end)
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, -20, 0, 22)
        statusLabel.Position = UDim2.new(0, 10, 0, 54)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "Scanning..."
        statusLabel.TextColor3 = Theme.TextSecondary
        statusLabel.Font = Enum.Font.Gotham
        statusLabel.TextSize = 11
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.ZIndex = 3
        statusLabel.Parent = mainFrame
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, -18, 1, -112)
        scrollFrame.Position = UDim2.new(0, 9, 0, 80)
        scrollFrame.BackgroundColor3 = Theme.Surface
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 3
        scrollFrame.ScrollBarImageColor3 = Theme.Accent1
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.ZIndex = 3
        scrollFrame.Parent = mainFrame
        Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 8)
        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 5)
        listLayout.Parent = scrollFrame
        local listPadding = Instance.new("UIPadding")
        listPadding.PaddingTop = UDim.new(0, 6)
        listPadding.PaddingBottom = UDim.new(0, 6)
        listPadding.PaddingLeft = UDim.new(0, 6)
        listPadding.PaddingRight = UDim.new(0, 6)
        listPadding.Parent = scrollFrame
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
        end)
        local creditLabel = Instance.new("TextLabel")
        creditLabel.Size = UDim2.new(1, 0, 0, 20)
        creditLabel.Position = UDim2.new(0, 0, 1, -22)
        creditLabel.BackgroundTransparency = 1
        creditLabel.Text = "HEROZ"
        creditLabel.TextColor3 = Theme.TextSecondary
        creditLabel.Font = Enum.Font.Gotham
        creditLabel.TextSize = 10
        creditLabel.TextXAlignment = Enum.TextXAlignment.Center
        creditLabel.ZIndex = 3
        creditLabel.Parent = mainFrame
        local shownPodiums = {}
        local function addRow(podiumNum, sellPrompt, sellText)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -12, 0, 40)
            row.BackgroundColor3 = Theme.Surface
            row.BorderSizePixel = 0
            row.LayoutOrder = podiumNum
            row.ZIndex = 4
            row.Name = "PodiumRow_" .. podiumNum
            row.Parent = scrollFrame
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
            local leftAccent = Instance.new("Frame")
            leftAccent.Size = UDim2.new(0, 3, 1, -8)
            leftAccent.Position = UDim2.new(0, 0, 0, 4)
            leftAccent.BackgroundColor3 = Theme.Accent1
            leftAccent.BorderSizePixel = 0
            leftAccent.ZIndex = 5
            leftAccent.Parent = row
            Instance.new("UICorner", leftAccent).CornerRadius = UDim.new(0, 2)
            local badge = Instance.new("TextLabel")
            badge.Size = UDim2.new(0, 28, 0, 28)
            badge.Position = UDim2.new(0, 10, 0.5, -14)
            badge.BackgroundColor3 = Theme.SurfaceHighlight
            badge.Text = tostring(podiumNum)
            badge.TextColor3 = Theme.Accent1
            badge.Font = Enum.Font.GothamBlack
            badge.TextSize = 12
            badge.BorderSizePixel = 0
            badge.ZIndex = 5
            badge.Parent = row
            Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 5)
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -110, 1, 0)
            nameLabel.Position = UDim2.new(0, 46, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = sellText
            nameLabel.TextColor3 = Theme.TextPrimary
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextSize = 11
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.ZIndex = 5
            nameLabel.Parent = row
            local sellBtn = Instance.new("TextButton")
            sellBtn.Size = UDim2.new(0, 56, 0, 28)
            sellBtn.Position = UDim2.new(1, -62, 0.5, -14)
            sellBtn.BackgroundColor3 = Theme.Accent2
            sellBtn.Text = "SELL"
            sellBtn.TextColor3 = Color3.new(1, 1, 1)
            sellBtn.Font = Enum.Font.GothamBold
            sellBtn.TextSize = 11
            sellBtn.BorderSizePixel = 0
            sellBtn.ZIndex = 5
            sellBtn.Parent = row
            Instance.new("UICorner", sellBtn).CornerRadius = UDim.new(0, 6)
            sellBtn.MouseButton1Click:Connect(function()
                local sellOk = pcall(function()
                    if _G.firePromptDirect then
                        _G.firePromptDirect(sellPrompt)
                    else
                        fireproximityprompt(sellPrompt)
                    end
                end)
                if sellOk then
                    sellBtn.Text = "OK"
                    sellBtn.BackgroundColor3 = Theme.Accent1
                    task.wait(0.4)
                    shownPodiums[podiumNum] = nil
                    row:Destroy()
                    local remaining = 0
                    for _ in pairs(shownPodiums) do remaining = remaining + 1 end
                    if remaining == 0 then
                        statusLabel.Text = "No brainrots on podiums"
                    else
                        statusLabel.Text = remaining .. " brainrot(s) ready to sell"
                    end
                else
                    sellBtn.Text = "ERR"
                    sellBtn.BackgroundColor3 = Color3.fromRGB(120, 25, 35)
                    task.wait(1)
                    sellBtn.Text = "SELL"
                    sellBtn.BackgroundColor3 = Theme.Accent2
                end
            end)
        end
        local function scan()
            local plot = findMyPlot_RS()
            if not plot then statusLabel.Text = "Base not found"; return end
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if not podiums then statusLabel.Text = "AnimalPodiums not found"; return end
            for _, podium in ipairs(podiums:GetChildren()) do
                local podiumNum = tonumber(podium.Name)
                if podiumNum and not shownPodiums[podiumNum] then
                    local base = podium:FindFirstChild("Base")
                    local spawnP = base and base:FindFirstChild("Spawn")
                    local attachment = spawnP and spawnP:FindFirstChild("PromptAttachment")
                    if attachment then
                        for _, pp in ipairs(attachment:GetChildren()) do
                            if pp:IsA("ProximityPrompt") then
                                local action = pp.ActionText or ""
                                if action:sub(1, 4) == "Sell" then
                                    shownPodiums[podiumNum] = true
                                    addRow(podiumNum, pp, action)
                                end
                            end
                        end
                    end
                end
            end
            local total = 0
            for _ in pairs(shownPodiums) do total = total + 1 end
            if total == 0 then
                statusLabel.Text = "No brainrots on podiums"
            else
                statusLabel.Text = total .. " brainrot(s) ready to sell"
            end
        end
        local function hasSellPrompt(plot)
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if not podiums then return false end
            for _, podium in ipairs(podiums:GetChildren()) do
                if tonumber(podium.Name) then
                    local base = podium:FindFirstChild("Base")
                    local spawnP = base and base:FindFirstChild("Spawn")
                    local attachment = spawnP and spawnP:FindFirstChild("PromptAttachment")
                    if attachment then
                        for _, pp in ipairs(attachment:GetChildren()) do
                            if pp:IsA("ProximityPrompt") and (pp.ActionText or ""):sub(1, 4) == "Sell" then
                                return true
                            end
                        end
                    end
                end
            end
            return false
        end
        local function startWatcher(plot)
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if not podiums then return end
            local function watchPodium(podium)
                local podiumNum = tonumber(podium.Name)
                if not podiumNum then return end
                local base = podium:FindFirstChild("Base")
                local spawnP = base and base:FindFirstChild("Spawn")
                local attachment = spawnP and spawnP:FindFirstChild("PromptAttachment")
                if not attachment then return end
                attachment.ChildAdded:Connect(function(child)
                    task.wait(0.1)
                    if child:IsA("ProximityPrompt") then
                        local action = child.ActionText or ""
                        if action:sub(1, 4) == "Sell" and not shownPodiums[podiumNum] then
                            shownPodiums[podiumNum] = true
                            addRow(podiumNum, child, action)
                            local total = 0
                            for _ in pairs(shownPodiums) do total = total + 1 end
                            statusLabel.Text = total .. " brainrot(s) ready to sell"
                        end
                    end
                end)
                attachment.ChildRemoved:Connect(function(child)
                    if child:IsA("ProximityPrompt") and (child.ActionText or ""):sub(1, 4) == "Sell" then
                        shownPodiums[podiumNum] = nil
                        local existingRow = scrollFrame:FindFirstChild("PodiumRow_" .. podiumNum)
                        if existingRow then existingRow:Destroy() end
                        local total = 0
                        for _ in pairs(shownPodiums) do total = total + 1 end
                        if total == 0 then
                            statusLabel.Text = "No brainrots on podiums"
                        else
                            statusLabel.Text = total .. " brainrot(s) ready to sell"
                        end
                    end
                end)
            end
            for _, podium in ipairs(podiums:GetChildren()) do watchPodium(podium) end
            watcherConn_RS = podiums.ChildAdded:Connect(function(podium)
                task.wait(0.2); watchPodium(podium); scan()
            end)
        end
        task.spawn(function()
            local char = player_RS.Character or player_RS.CharacterAdded:Wait()
            local root = char:WaitForChild("HumanoidRootPart", 15)
            if not root then statusLabel.Text = "Character didn't load"; return end
            local plots = workspace:WaitForChild("Plots", 30)
            if not plots then statusLabel.Text = "Plots not found"; return end
            for i = 1, 40 do
                if #plots:GetChildren() > 0 then break end
                task.wait(0.5)
            end
            local myPlot = findMyPlot_RS()
            if not myPlot then statusLabel.Text = "Could not find your base"; return end
            statusLabel.Text = "Loading brainrots..."
            for i = 1, 60 do
                if hasSellPrompt(myPlot) then break end
                task.wait(0.5)
                if i == 60 then
                    statusLabel.Text = "No brainrots on podiums"
                    startWatcher(myPlot)
                    return
                end
            end
            scan()
            startWatcher(myPlot)
        end)
    end
    _G.ZawaHubRemoteSell_SetEnabled = function(on)
        if on then
            buildRemoteSell()
            if screenGui_RS then screenGui_RS.Enabled = true end
        else
            if screenGui_RS then
                screenGui_RS:Destroy()
                screenGui_RS = nil
            end
            rsBuilt = false
            if watcherConn_RS then watcherConn_RS:Disconnect(); watcherConn_RS = nil end
        end
    end
    if Config.ShowRemoteSell then
        task.spawn(function()
            task.wait(1)
            buildRemoteSell()
        end)
    end
end
do
    local Players_AS    = game:GetService("Players")
    local RunService_AS = game:GetService("RunService")
    local player_AS     = Players_AS.LocalPlayer
    if _G.ZawaHubAutoSell_Conn then
        pcall(function() _G.ZawaHubAutoSell_Conn:Disconnect() end)
        _G.ZawaHubAutoSell_Conn = nil
    end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == "ZawaHubAutoSellZone" then
            pcall(function() obj:Destroy() end)
        end
    end
    local lockedPlot_AS = nil
    local zoneCFrame_AS, zoneSize_AS = nil, nil
    local lastFireAS = {}        
    local FIRE_COOLDOWN = 0.4
    local visualPart_AS = nil
    local visualLabel_AS = nil
    local heartbeatConn_AS = nil
    local engineRunning_AS = false
    local function findMyPlot_AS()
        if lockedPlot_AS and lockedPlot_AS.Parent then return lockedPlot_AS end
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil end
        local myNameLower = player_AS.Name:lower()
        local myDispLower = (player_AS.DisplayName or player_AS.Name):lower()
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local surfaceGui = sign:FindFirstChildWhichIsA("SurfaceGui", true)
                if surfaceGui then
                    local label = surfaceGui:FindFirstChildWhichIsA("TextLabel", true)
                    if label then
                        local text = (label.Text or ""):lower()
                        if text:find(myDispLower, 1, true) or text:find(myNameLower, 1, true) then
                            lockedPlot_AS = plot
                            return plot
                        end
                    end
                end
            end
        end
        local ok, Sync = true, _G.ZawaRawSync
        if ok and Sync then
            for _, plot in ipairs(plots:GetChildren()) do
                local ok2, ch = pcall(function() return Sync.caches[plot.Name] end)
                if ok2 and ch then
                    local ok3, owner = pcall(function() return ch.Owner end)
                    if ok3 and owner then
                        if typeof(owner) == "Instance" and owner:IsA("Player")
                           and owner == player_AS then
                            lockedPlot_AS = plot; return plot
                        elseif type(owner) == "table" then
                            if (owner.UserId and owner.UserId == player_AS.UserId)
                               or (owner.Name and owner.Name == player_AS.Name) then
                                lockedPlot_AS = plot; return plot
                            end
                        end
                    end
                end
            end
        end
        return nil
    end
    local function computeZone(plot)
        if not plot then return nil, nil end
        local FIRST_FLOOR_HEIGHT = 14
        local WIDTH_PADDING = 10
        local ZONE_DEPTH = 30
        local OUTWARD_OFFSET = 30
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then return nil, nil end
        local minX, minY, minZ =  math.huge,  math.huge,  math.huge
        local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge
        local found = 0
        for _, podium in ipairs(podiums:GetChildren()) do
            if tonumber(podium.Name) then
                local base = podium:FindFirstChild("Base")
                if base then
                    local ok, cf = pcall(function() return base:GetPivot() end)
                    if ok and cf then
                        local p = cf.Position
                        if p.X < minX then minX = p.X end
                        if p.Y < minY then minY = p.Y end
                        if p.Z < minZ then minZ = p.Z end
                        if p.X > maxX then maxX = p.X end
                        if p.Y > maxY then maxY = p.Y end
                        if p.Z > maxZ then maxZ = p.Z end
                        found = found + 1
                    end
                end
            end
        end
        if found == 0 then return nil, nil end
        local spanX = maxX - minX
        local spanZ = maxZ - minZ
        local widthAxisIsZ = spanZ >= spanX
        local widthSpan = widthAxisIsZ and spanZ or spanX
        local sizeWidth = widthSpan + WIDTH_PADDING * 2
        local podiumCx = (minX + maxX) * 0.5
        local podiumCz = (minZ + maxZ) * 0.5
        local function resolveSignPos()
            local sign = plot:FindFirstChild("PlotSign")
            if not sign then return nil end
            if sign:IsA("BasePart") then
                return sign.Position
            elseif sign:IsA("Model") then
                local pp = sign.PrimaryPart or sign:FindFirstChildWhichIsA("BasePart", true)
                if pp then return pp.Position end
                local ok, cf = pcall(function() return sign:GetPivot() end)
                if ok and cf then return cf.Position end
            else
                local pp = sign:FindFirstChildWhichIsA("BasePart", true)
                if pp then return pp.Position end
            end
            return nil
        end
        local outwardX, outwardZ = 0, 0
        local signPos = resolveSignPos()
        if signPos then
            if widthAxisIsZ then
                local d = signPos.X - podiumCx
                if d == 0 then d = 1 end
                outwardX = (d > 0) and 1 or -1
            else
                local d = signPos.Z - podiumCz
                if d == 0 then d = 1 end
                outwardZ = (d > 0) and 1 or -1
            end
        else
            local centerPart = plot:FindFirstChild("MainRootPart")
            if centerPart and centerPart:IsA("BasePart") then
                local mp = centerPart.Position
                if widthAxisIsZ then
                    local d = podiumCx - mp.X
                    if d == 0 then d = 1 end
                    outwardX = (d > 0) and 1 or -1
                else
                    local d = podiumCz - mp.Z
                    if d == 0 then d = 1 end
                    outwardZ = (d > 0) and 1 or -1
                end
            else
                if widthAxisIsZ then outwardX = 1 else outwardZ = 1 end
            end
        end
        local cx = podiumCx + outwardX * OUTWARD_OFFSET
        local cz = podiumCz + outwardZ * OUTWARD_OFFSET
        local centerY = minY + FIRST_FLOOR_HEIGHT * 0.5 - 1
        local sizeX = widthAxisIsZ and ZONE_DEPTH or sizeWidth
        local sizeZ = widthAxisIsZ and sizeWidth or ZONE_DEPTH
        return CFrame.new(cx, centerY, cz),
               Vector3.new(sizeX, FIRST_FLOOR_HEIGHT, sizeZ)
    end
    local function pointInZone(p)
        if not zoneCFrame_AS or not zoneSize_AS then return false end
        local c = zoneCFrame_AS.Position
        local hx, hy, hz = zoneSize_AS.X * 0.5, zoneSize_AS.Y * 0.5, zoneSize_AS.Z * 0.5
        return  p.X >= c.X - hx and p.X <= c.X + hx
            and p.Y >= c.Y - hy and p.Y <= c.Y + hy
            and p.Z >= c.Z - hz and p.Z <= c.Z + hz
    end
    local function destroyVisual()
        if visualPart_AS then
            pcall(function() visualPart_AS:Destroy() end)
            visualPart_AS = nil
            visualLabel_AS = nil
        end
    end
    local function buildVisual()
        destroyVisual()
        if not zoneCFrame_AS or not zoneSize_AS then return end
        local part = Instance.new("Part")
        part.Name           = "ZawaHubAutoSellZone"
        part.Anchored       = true
        part.CanCollide     = false
        part.CanQuery       = false
        part.CanTouch       = false
        part.Massless       = true
        part.CastShadow     = false
        part.Material       = Enum.Material.ForceField
        part.Color          = Color3.fromRGB(255, 60, 60)
        part.Transparency   = 0.65
        part.Size           = zoneSize_AS
        part.CFrame         = zoneCFrame_AS
        part.Parent         = workspace
        local outline = Instance.new("SelectionBox")
        outline.Adornee     = part
        outline.LineThickness = 0.08
        outline.Color3      = Color3.fromRGB(255, 40, 40)
        outline.Transparency = 0.1
        outline.SurfaceColor3 = Color3.fromRGB(255, 80, 80)
        outline.SurfaceTransparency = 0.85
        outline.Parent      = part
        local bb = Instance.new("BillboardGui")
        bb.Name              = "Label"
        bb.Adornee           = part
        bb.AlwaysOnTop       = true
        bb.Size              = UDim2.new(0, 160, 0, 32)
        bb.StudsOffsetWorldSpace = Vector3.new(0, zoneSize_AS.Y * 0.5 + 1.5, 0)
        bb.Parent            = part
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        lbl.BackgroundTransparency = 0.25
        lbl.BorderSizePixel  = 0
        lbl.Size             = UDim2.new(1, 0, 1, 0)
        lbl.Font             = Enum.Font.GothamBold
        lbl.TextSize         = 14
        lbl.TextColor3       = Color3.fromRGB(255, 255, 255)
        lbl.Text             = "Auto Sell Zone"
        lbl.Parent           = bb
        Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 6)
        visualPart_AS  = part
        visualLabel_AS = lbl
    end
    local function trySellOnPlot(plot)
        local podiums = plot and plot:FindFirstChild("AnimalPodiums")
        if not podiums then return end
        local target = tonumber(Config.AutoSellPodium) or 0
        for _, podium in ipairs(podiums:GetChildren()) do
            local podiumNum = tonumber(podium.Name)
            if podiumNum and (target == 0 or podiumNum == target) then
                local now = os.clock()
                if (now - (lastFireAS[podiumNum] or 0)) >= FIRE_COOLDOWN then
                    local base       = podium:FindFirstChild("Base")
                    local spawnP     = base and base:FindFirstChild("Spawn")
                    local attachment = spawnP and spawnP:FindFirstChild("PromptAttachment")
                    if attachment then
                        for _, pp in ipairs(attachment:GetChildren()) do
                            if pp:IsA("ProximityPrompt")
                                and (pp.ActionText or ""):sub(1, 4) == "Sell" then
                                lastFireAS[podiumNum] = now
                                pcall(function()
                                    if _G.firePromptDirect then
                                        _G.firePromptDirect(pp)
                                    elseif fireproximityprompt then
                                        fireproximityprompt(pp)
                                    end
                                end)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    local function startEngine()
        if engineRunning_AS then return end
        engineRunning_AS = true
        local lastZoneCheck = 0
        local lastPlotInvalidate = 0
        local lastVisualState = nil
        heartbeatConn_AS = RunService_AS.Heartbeat:Connect(function()
            if not Config.AutoSell and not Config.ShowAutoSellZone then return end
            local now = os.clock()
            if now - lastPlotInvalidate > 10 then
                lastPlotInvalidate = now
                lockedPlot_AS = nil
            end
            if now - lastZoneCheck > 2 or not zoneCFrame_AS then
                lastZoneCheck = now
                local plot = findMyPlot_AS()
                if plot then
                    local cf, sz = computeZone(plot)
                    if cf and sz then
                        zoneCFrame_AS, zoneSize_AS = cf, sz
                    end
                end
            end
            local wantVisual = Config.ShowAutoSellZone and zoneCFrame_AS ~= nil
            if wantVisual ~= lastVisualState then
                lastVisualState = wantVisual
                if wantVisual then buildVisual() else destroyVisual() end
            end
            if visualPart_AS and not visualPart_AS.Parent then
                visualPart_AS = nil
                visualLabel_AS = nil
                if wantVisual then buildVisual() end
            end
            if visualPart_AS and zoneCFrame_AS and zoneSize_AS then
                visualPart_AS.Anchored = true
                visualPart_AS.Size  = zoneSize_AS
                visualPart_AS.CFrame = zoneCFrame_AS
            end
            if not Config.AutoSell then return end
            local char = player_AS.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            if not pointInZone(root.Position) then return end
            local stealingIdx = player_AS:GetAttribute("StealingIndex")
            if not stealingIdx or tostring(stealingIdx) == "" then return end
            local plot = findMyPlot_AS()
            if plot then trySellOnPlot(plot) end
        end)
        _G.ZawaHubAutoSell_Conn = heartbeatConn_AS
    end
    local function stopEngine()
        if heartbeatConn_AS then
            heartbeatConn_AS:Disconnect()
            heartbeatConn_AS = nil
        end
        engineRunning_AS = false
        destroyVisual()
        zoneCFrame_AS, zoneSize_AS = nil, nil
        lastFireAS = {}
    end
    player_AS.CharacterAdded:Connect(function()
        lockedPlot_AS = nil
        zoneCFrame_AS, zoneSize_AS = nil, nil
    end)
    _G.ZawaHubAutoSell_SetEnabled = function(on)
        if on then
            startEngine()
        else
            if not Config.ShowAutoSellZone then
                stopEngine()
            end
        end
    end
    _G.ZawaHubAutoSell_SetVisualizer = function(on)
        if on then
            startEngine()
        else
            destroyVisual()
            if not Config.AutoSell then
                stopEngine()
            end
        end
    end
    if Config.AutoSell or Config.ShowAutoSellZone then
        task.spawn(function()
            task.wait(1.5)
            startEngine()
        end)
    end
end
task.spawn(function()
	task.wait(0.3)
	local animPlaying = false
	local tracks = {}
	local clone, oldRoot, hip, connection
	local folderConnections = {}
	local SINK_AMOUNT = 5
	local serverGhosts = {}
	local ghostEnabled = true
	local lagbackCallCount = 0
	local lagbackWindowStart = 0
	local lastLagbackTime = 0
	local errorOrbActive = false
	local errorOrb = nil
	local errorOrbConnection = nil
	local function clearErrorOrb()
		if errorOrb and errorOrb.Parent then errorOrb:Destroy() end
		errorOrb = nil; errorOrbActive = false
		if errorOrbConnection then errorOrbConnection:Disconnect(); errorOrbConnection = nil end
	end
	local function createErrorOrb()
		if errorOrbActive then return end
		errorOrbActive = true
		for _, ghost in pairs(serverGhosts) do if ghost and ghost.Parent then ghost:Destroy() end end
		serverGhosts = {}
		local sg = Instance.new("ScreenGui")
		sg.Name = "ErrorOrbGui"; sg.ResetOnSpawn = false
		sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
		local fr = Instance.new("Frame")
		fr.Size = UDim2.new(0, 500, 0, 60)
		fr.Position = UDim2.new(0.5, -250, 0.3, 0)
		fr.BackgroundTransparency = 1; fr.BorderSizePixel = 0; fr.Parent = sg
		local l1 = Instance.new("TextLabel")
		l1.Size = UDim2.new(1, 0, 0.5, 0); l1.BackgroundTransparency = 1
		l1.Text = "ERROR CAUSED BY PLAYER DEATH"
		l1.TextColor3 = Color3.fromRGB(255, 0, 0)
		l1.TextStrokeTransparency = 0; l1.TextStrokeColor3 = Color3.new(0, 0, 0)
		l1.Font = Enum.Font.SourceSansBold; l1.TextScaled = true; l1.Parent = fr
		local l2 = Instance.new("TextLabel")
		l2.Size = UDim2.new(1, 0, 0.5, 0); l2.Position = UDim2.new(0, 0, 0.5, 0)
		l2.BackgroundTransparency = 1; l2.Text = "MUST RESET TO FIX ERROR"
		l2.TextColor3 = Color3.fromRGB(255, 0, 0)
		l2.TextStrokeTransparency = 0; l2.TextStrokeColor3 = Color3.new(0, 0, 0)
		l2.Font = Enum.Font.SourceSansBold; l2.TextScaled = true; l2.Parent = fr
		errorOrb = sg
	end
	local function createServerGhost(position)
		if not ghostEnabled or errorOrbActive then return end
		local now = tick()
		if now - lastLagbackTime < 0.05 then return end
		lastLagbackTime = now
		if now - lagbackWindowStart > 1 then lagbackCallCount = 0; lagbackWindowStart = now end
		lagbackCallCount = lagbackCallCount + 1
		if lagbackCallCount >= 7 then createErrorOrb(); return end
		for _, g in pairs(serverGhosts) do if g and g.Parent then g:Destroy() end end
		serverGhosts = {}
		local sg = Instance.new("ScreenGui")
		sg.Name = "LagbackNotification"; sg.ResetOnSpawn = false
		sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
		local sl = Instance.new("TextLabel")
		sl.Size = UDim2.new(0, 500, 0, 30); sl.Position = UDim2.new(0.5, -250, 0.15, 0)
		sl.BackgroundTransparency = 1; sl.Text = "LAGBACK DETECTED"
		sl.TextColor3 = Color3.fromRGB(255, 0, 0)
		sl.TextStrokeTransparency = 0; sl.TextStrokeColor3 = Color3.new(0, 0, 0)
		sl.Font = Enum.Font.SourceSansBold; sl.TextScaled = true; sl.Parent = sg
		local sw = Instance.new("TextLabel")
		sw.Size = UDim2.new(0, 650, 0, 25); sw.Position = UDim2.new(0.5, -325, 0.15, 32)
		sw.BackgroundTransparency = 1
		sw.Text = "DISABLE INVISIBLE STEAL NOW OR YOU WILL BE KILLED BY ANTICHEAT"
		sw.TextColor3 = Color3.fromRGB(200, 200, 200)
		sw.TextStrokeTransparency = 0; sw.TextStrokeColor3 = Color3.new(0, 0, 0)
		sw.Font = Enum.Font.SourceSansBold; sw.TextScaled = true; sw.Parent = sg
		task.delay(1.5, function() if sg and sg.Parent then sg:Destroy() end end)
		local ghost = Instance.new("Part")
		ghost.Name = "LagbackGhost"; ghost.Shape = Enum.PartType.Ball
		ghost.Size = Vector3.new(3, 3, 3); ghost.Color = Color3.fromRGB(255, 0, 0)
		ghost.Material = Enum.Material.Glass; ghost.Transparency = 0.3
		ghost.CanCollide = false; ghost.Anchored = true; ghost.CastShadow = false
		ghost.Position = position + Vector3.new(0, 5, 0); ghost.Parent = Workspace.CurrentCamera
		local bb = Instance.new("BillboardGui")
		bb.Size = UDim2.new(0, 400, 0, 60); bb.StudsOffset = Vector3.new(0, 4, 0)
		bb.AlwaysOnTop = true; bb.Parent = ghost
		local bl = Instance.new("TextLabel")
		bl.Size = UDim2.new(1, 0, 0, 25); bl.BackgroundTransparency = 1
		bl.Text = "LAGBACK DETECTED"; bl.TextColor3 = Color3.fromRGB(255, 0, 0)
		bl.TextStrokeTransparency = 0; bl.TextStrokeColor3 = Color3.new(0, 0, 0)
		bl.Font = Enum.Font.SourceSansBold; bl.TextScaled = true; bl.Parent = bb
		local bw = Instance.new("TextLabel")
		bw.Size = UDim2.new(1, 0, 0, 25); bw.Position = UDim2.new(0, 0, 0, 25)
		bw.BackgroundTransparency = 1
		bw.Text = "DISABLE INVISIBLE STEAL NOW OR YOU WILL BE KILLED BY ANTICHEAT"
		bw.TextColor3 = Color3.fromRGB(200, 200, 200)
		bw.TextStrokeTransparency = 0; bw.TextStrokeColor3 = Color3.new(0, 0, 0)
		bw.Font = Enum.Font.SourceSansBold; bw.TextScaled = true; bw.Parent = bb
		table.insert(serverGhosts, ghost)
	end
	local function clearAllGhosts()
		for _, ghost in pairs(serverGhosts) do pcall(function() if ghost and ghost.Parent then ghost:Destroy() end end) end
		serverGhosts = {}; clearErrorOrb(); lagbackCallCount = 0; lastLagbackTime = 0
		pcall(function()
			local pg = LocalPlayer:FindFirstChild("PlayerGui")
			if pg then for _, gui in pairs(pg:GetChildren()) do if gui.Name == "LagbackNotification" then gui:Destroy() end end end
		end)
		pcall(function() if Workspace.CurrentCamera then for _, c in pairs(Workspace.CurrentCamera:GetChildren()) do if c.Name == "LagbackGhost" then c:Destroy() end end end end)
		pcall(function() for _, c in pairs(Workspace:GetDescendants()) do if c.Name == "LagbackGhost" then c:Destroy() end end end)
	end
	local function removeFolders()
		local pf = Workspace:FindFirstChild(LocalPlayer.Name)
		if not pf then return end
		local dr = pf:FindFirstChild("DoubleRig")
		if dr then
			local rr = dr:FindFirstChild("HumanoidRootPart") or dr:FindFirstChildWhichIsA("BasePart")
			if rr and ghostEnabled then createServerGhost(rr.Position) end
			dr:Destroy()
		end
		local cs = pf:FindFirstChild("Constraints")
		if cs then cs:Destroy() end
		local conn = pf.ChildAdded:Connect(function(child)
			if child.Name == "DoubleRig" then
				task.defer(function()
					local rr = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChildWhichIsA("BasePart")
					if rr and ghostEnabled then createServerGhost(rr.Position) end
					child:Destroy()
				end)
			elseif child.Name == "Constraints" then child:Destroy() end
		end)
		table.insert(folderConnections, conn)
	end
	local function doClone()
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
			hip = character.Humanoid.HipHeight
			oldRoot = character:FindFirstChild("HumanoidRootPart")
			if not oldRoot or not oldRoot.Parent then return false end
			for _, c in pairs(oldRoot:GetChildren()) do
				if c:IsA("Attachment") and (c.Name:find("Beam") or c.Name:find("Attach")) then c:Destroy() end
			end
			for _, c in pairs(oldRoot:GetChildren()) do if c:IsA("Beam") then c:Destroy() end end
			local tmp = Instance.new("Model"); tmp.Parent = game
			character.Parent = tmp
			clone = oldRoot:Clone(); clone.Parent = character
			oldRoot.Parent = Workspace.CurrentCamera
			clone.CFrame = oldRoot.CFrame; character.PrimaryPart = clone
			character.Parent = Workspace
			for _, v in pairs(character:GetDescendants()) do
				if v:IsA("Weld") or v:IsA("Motor6D") then
					if v.Part0 == oldRoot then v.Part0 = clone end
					if v.Part1 == oldRoot then v.Part1 = clone end
				end
			end
			tmp:Destroy(); return true
		end
		return false
	end
	local function revertClone()
		local character = LocalPlayer.Character
		if not oldRoot or not oldRoot:IsDescendantOf(Workspace) or not character or character.Humanoid.Health <= 0 then return end
		local hum = character:FindFirstChildOfClass("Humanoid")
		local prevPlatformStand = hum and hum.PlatformStand or false
		if hum then pcall(function() hum.PlatformStand = true end) end
		local snapCF = (clone and clone.Parent) and clone.CFrame or oldRoot.CFrame
		pcall(function()
			oldRoot.CFrame = snapCF
			oldRoot.Velocity = Vector3.zero
			oldRoot.Velocity = Vector3.zero
		end)
		local tmp = Instance.new("Model"); tmp.Parent = game
		character.Parent = tmp
		oldRoot.Parent = character; character.PrimaryPart = oldRoot
		character.Parent = Workspace; oldRoot.CanCollide = true
		for _, v in pairs(character:GetDescendants()) do
			if v:IsA("Weld") or v:IsA("Motor6D") then
				if v.Part0 == clone then v.Part0 = oldRoot end
				if v.Part1 == clone then v.Part1 = oldRoot end
			end
		end
		if clone then clone:Destroy(); clone = nil end
		pcall(function()
			oldRoot.CFrame = snapCF
			oldRoot.Velocity = Vector3.zero
			oldRoot.Velocity = Vector3.zero
		end)
		oldRoot = nil
		if character and character.Humanoid then character.Humanoid.HipHeight = hip end
		clearAllGhosts()
		if hum then
			task.spawn(function()
				RunService.Heartbeat:Wait()
				RunService.Heartbeat:Wait()
				if hum and hum.Parent then
					pcall(function() hum.PlatformStand = prevPlatformStand end)
				end
			end)
		end
	end
	local function animationTrickery()
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
			local anim = Instance.new("Animation")
			anim.AnimationId = "http://www.roblox.com/asset/?id=18537363391"
			local humanoid = character.Humanoid
			local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)
			local animTrack = animator:LoadAnimation(anim)
			animTrack.Priority = Enum.AnimationPriority.Action4
			animTrack:Play(0, 1, 0); anim:Destroy()
			table.insert(tracks, animTrack)
			animTrack.Stopped:Connect(function() if animPlaying then animationTrickery() end end)
			task.delay(0, function()
				animTrack.TimePosition = 0.7
				task.delay(0.3, function() if animTrack then animTrack:AdjustSpeed(math.huge) end end)
			end)
		end
	end
	local function turnOff()
		clearAllGhosts()
		if not animPlaying then return end
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		animPlaying = false; _G.invisibleStealEnabled = false
		for _, t in pairs(tracks) do pcall(function() t:Stop() end) end
		tracks = {}
		if connection then connection:Disconnect(); connection = nil end
		for _, c in ipairs(folderConnections) do if c then c:Disconnect() end end
		folderConnections = {}
		if oldRoot and oldRoot.Parent and clone and clone.Parent then
			pcall(function()
				local p = clone.CFrame
				oldRoot.CFrame = p
				oldRoot.Velocity = Vector3.zero
				oldRoot.Velocity = Vector3.zero
				clone.Velocity = Vector3.zero
				clone.Velocity = Vector3.zero
			end)
			RunService.Heartbeat:Wait()
			RunService.Heartbeat:Wait()
		end
		revertClone(); clearAllGhosts()
		local rootNow = character and character:FindFirstChild("HumanoidRootPart")
		if rootNow then
			pcall(function()
				rootNow.Velocity = Vector3.zero
				rootNow.Velocity = Vector3.zero
			end)
		end
		if humanoid then pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
		if _G.updateMovementPanelInvisVisual then pcall(_G.updateMovementPanelInvisVisual, false) end
		if updateVisualState then updateVisualState(false) end
	end
	local function turnOn()
		if animPlaying then return end
		local character = LocalPlayer.Character
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end
		animPlaying = true; _G.invisibleStealEnabled = true
		if _G.updateMovementPanelInvisVisual then pcall(_G.updateMovementPanelInvisVisual, true) end
		if updateVisualState then updateVisualState(true) end
		tracks = {}; removeFolders()
		local success = doClone()
		if success then
			task.wait(0.05); animationTrickery()
			task.defer(function()
				if _G.resetBrainrotBeam then pcall(_G.resetBrainrotBeam) end
				if _G.resetPlotBeam then pcall(_G.resetPlotBeam) end
				task.wait(0.1)
				if _G.updateBrainrotBeam then pcall(_G.updateBrainrotBeam) end
				if _G.createPlotBeam then pcall(_G.createPlotBeam) end
			end)
			local lastSetPosition = nil; local skipFrames = 5
			connection = RunService.PreSimulation:Connect(function()
				if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 and oldRoot then
					local root = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
					if root then
						if skipFrames > 0 then skipFrames = skipFrames - 1; lastSetPosition = nil
						elseif lastSetPosition and ghostEnabled then
							local currentPos = oldRoot.Position
							local jumpDist = (currentPos - lastSetPosition).Magnitude
							if jumpDist > 3 and not _G.RecoveryInProgress then
								lastSetPosition = nil; createServerGhost(currentPos)
								if _G.AutoRecoverLagback and _G.toggleInvisibleSteal then
									_G.RecoveryInProgress = true
									task.spawn(function()
										pcall(_G.toggleInvisibleSteal); task.wait(0.5)
										pcall(_G.toggleInvisibleSteal); _G.RecoveryInProgress = false
									end)
								end
							end
						end
						if clone then clone.CanCollide = false end
						for _, c in pairs(oldRoot:GetChildren()) do
							if c:IsA("Attachment") or c:IsA("Beam") then c:Destroy() end
						end
						local rotAngle = _G.InvisStealAngle or 180
						local sa = (_G.SinkSliderValue or 5) * 0.5
						local cf = root.CFrame - Vector3.new(0, sa, 0)
						oldRoot.CFrame = cf * CFrame.Angles(math.rad(rotAngle), 0, 0)
						oldRoot.Velocity = root.Velocity; oldRoot.CanCollide = false
						lastSetPosition = oldRoot.Position
					end
				end
			end)
		end
	end
    local invisGui = Instance.new("ScreenGui")
    invisGui.Name = "XiInvisPanel"
    invisGui.ResetOnSpawn = false
    invisGui.Parent = PlayerGui
    invisGui.Enabled = Config.ShowInvisPanel
    local iFrame = Instance.new("Frame", invisGui)
    iFrame.Size = UDim2.new(0, 250, 0, 260)
    iFrame.Position = UDim2.new(Config.Positions.InvisPanel.X, 0, Config.Positions.InvisPanel.Y, 0)
    iFrame.BackgroundColor3 = Theme.Background
    iFrame.BackgroundTransparency = 0.05
    Instance.new("UICorner", iFrame).CornerRadius = UDim.new(0, 12)
    local iStroke = Instance.new("UIStroke", iFrame)
    iStroke.Color = Theme.Accent2
    iStroke.Thickness = 1.5
    iStroke.Transparency = 0.4
    CreateGradient(iStroke)
    local iHeader = Instance.new("Frame", iFrame)
    iHeader.Size = UDim2.new(1, 0, 0, 35)
    iHeader.BackgroundTransparency = 1
    MakeDraggable(iHeader, iFrame, "InvisPanel")
    AddResizeHandle(iFrame, "InvisPanel", UDim2.new(1, -22, 0, 6))
    local iTitle = Instance.new("TextLabel", iHeader)
    iTitle.Size = UDim2.new(1, -15, 1, 0)
    iTitle.Position = UDim2.new(0, 15, 0, 0)
    iTitle.BackgroundTransparency = 1
    iTitle.Text = "INVISIBLE STEAL"
    iTitle.Font = Enum.Font.GothamBlack
    iTitle.TextSize = 14
    iTitle.TextColor3 = Theme.TextPrimary
    iTitle.TextXAlignment = Enum.TextXAlignment.Left
    local iContainer = Instance.new("Frame", iFrame)
    iContainer.Size = UDim2.new(1, -20, 1, -40)
    iContainer.Position = UDim2.new(0, 10, 0, 35)
    iContainer.BackgroundTransparency = 1
    local iLayout = Instance.new("UIListLayout", iContainer)
    iLayout.Padding = UDim.new(0, 8)
    iLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local function CreateIRow(height)
        local r = Instance.new("Frame", iContainer)
        r.Size = UDim2.new(1, 0, 0, height or 30)
        r.BackgroundTransparency = 1
        return r
    end
    local row1 = CreateIRow(30)
    local lbl1 = Instance.new("TextLabel", row1)
    lbl1.Size = UDim2.new(0.6, 0, 1, 0)
    lbl1.BackgroundTransparency = 1
    lbl1.Text = "Toggle Invis"
    lbl1.TextColor3 = Theme.TextPrimary
    lbl1.Font = Enum.Font.GothamBold
    lbl1.TextSize = 12
    lbl1.TextXAlignment = Enum.TextXAlignment.Left
    local btnInvis = Instance.new("TextButton", row1)
    btnInvis.Size = UDim2.new(0, 40, 0, 24)
    btnInvis.Position = UDim2.new(1, -40, 0.5, -12)
    btnInvis.BackgroundColor3 = Theme.SurfaceHighlight
    btnInvis.Text = "OFF"
    btnInvis.Font = Enum.Font.GothamBold
    btnInvis.TextSize = 11
    btnInvis.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", btnInvis).CornerRadius = UDim.new(0, 6)
    local keyBtn = Instance.new("TextButton", row1)
    keyBtn.Size = UDim2.new(0, 40, 0, 24)
    keyBtn.Position = UDim2.new(1, -90, 0.5, -12)
    keyBtn.BackgroundColor3 = Theme.Surface
    keyBtn.Text = Config.InvisToggleKey
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextColor3 = Theme.Accent1
    keyBtn.TextSize = 11
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 6)
    keyBtn.MouseButton1Click:Connect(function()
        keyBtn.Text = "..."
        local c
        c = UserInputService.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Keyboard then
                Config.InvisToggleKey = i.KeyCode.Name
                _G.INVISIBLE_STEAL_KEY = i.KeyCode
                keyBtn.Text = i.KeyCode.Name
                SaveConfig()
                c:Disconnect()
            end
        end)
    end)
    local row2 = CreateIRow(30)
    local lbl2 = Instance.new("TextLabel", row2)
    lbl2.Size = UDim2.new(0.6, 0, 1, 0)
    lbl2.BackgroundTransparency = 1
    lbl2.Text = "Auto Fix Lagback"
    lbl2.TextColor3 = Theme.TextPrimary
    lbl2.Font = Enum.Font.GothamBold
    lbl2.TextSize = 12
    lbl2.TextXAlignment = Enum.TextXAlignment.Left
    local btnFix = Instance.new("TextButton", row2)
    btnFix.Size = UDim2.new(0, 50, 0, 24)
    btnFix.Position = UDim2.new(1, -50, 0.5, -12)
    btnFix.BackgroundColor3 = _G.AutoRecoverLagback and Theme.Success or Theme.SurfaceHighlight
    btnFix.Text = _G.AutoRecoverLagback and "ON" or "OFF"
    btnFix.Font = Enum.Font.GothamBold
    btnFix.TextSize = 11
    btnFix.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", btnFix).CornerRadius = UDim.new(0, 6)
    btnFix.MouseButton1Click:Connect(function()
        _G.AutoRecoverLagback = not _G.AutoRecoverLagback
        Config.AutoRecoverLagback = _G.AutoRecoverLagback
        SaveConfig()
        btnFix.Text = _G.AutoRecoverLagback and "ON" or "OFF"
        btnFix.BackgroundColor3 = _G.AutoRecoverLagback and Theme.Success or Theme.SurfaceHighlight
    end)
    local function CreateFancySlider(parent, name, min, max, default, callback)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, 0, 0, IS_MOBILE and 35 or 45)
        frame.BackgroundTransparency = 1
        if IS_MOBILE then
            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(0.5, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Theme.TextSecondary
            label.Font = Enum.Font.GothamBold
            label.TextSize = 11
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Text = name .. ":"
            local textBox = Instance.new("TextBox", frame)
            textBox.Size = UDim2.new(0, 80, 0, 28)
            textBox.Position = UDim2.new(1, -80, 0.5, -14)
            textBox.BackgroundColor3 = Theme.Surface
            textBox.BorderSizePixel = 0
            textBox.TextColor3 = Theme.TextPrimary
            textBox.Font = Enum.Font.GothamBold
            textBox.TextSize = 12
            textBox.Text = tostring(default)
            textBox.PlaceholderText = tostring(default)
            textBox.ClearTextOnFocus = false
            Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 6)
            local textBoxStroke = Instance.new("UIStroke", textBox)
            textBoxStroke.Color = Theme.Accent1
            textBoxStroke.Thickness = 1.5
            textBoxStroke.Transparency = 0.3
            textBox.FocusLost:Connect(function(enterPressed)
                local num = tonumber(textBox.Text)
                if num then
                    local clamped = math.clamp(num, min, max)
                    if max > 100 then
                        clamped = math.floor(clamped)
                    else
                        clamped = math.floor(clamped * 10) / 10
                    end
                    textBox.Text = tostring(clamped)
                    callback(clamped)
                else
                    textBox.Text = tostring(default)
                end
            end)
            return frame
        else
            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1, 0, 0, 15)
            label.BackgroundTransparency = 1
            label.TextColor3 = Theme.TextSecondary
            label.Font = Enum.Font.GothamBold
            label.TextSize = 10
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Text = name .. ": " .. default
            local slideBg = Instance.new("Frame", frame)
            slideBg.Size = UDim2.new(1, 0, 0, 6)
            slideBg.Position = UDim2.new(0, 0, 0, 25)
            slideBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            Instance.new("UICorner", slideBg).CornerRadius = UDim.new(1, 0)
            slideBg.Parent = frame
            local fill = Instance.new("Frame", slideBg)
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(220, 25, 25)
            fill.ZIndex = 12
            fill.Parent = slideBg
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
            local knob = Instance.new("Frame", slideBg)
            knob.Size = UDim2.new(0, 12, 0, 12)
            knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Position = UDim2.new(0, 0, 0.5, 0)
            knob.ZIndex = 13
            knob.Parent = slideBg
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
            local function update(inputX)
                local p = math.clamp((inputX - slideBg.AbsolutePosition.X) / slideBg.AbsoluteSize.X, 0, 1)
                local val = min + (p * (max - min))
                if max > 100 then val = math.floor(val) else val = math.floor(val*10)/10 end
                fill.Size = UDim2.new(p, 0, 1, 0)
                knob.Position = UDim2.new(p, 0, 0.5, 0)
                label.Text = name .. ": " .. val
                callback(val)
            end
            local dragging = false
            slideBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    update(input.Position.X)
                end
            end)
            knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    update(input.Position.X)
                end
            end)
            local p = (default - min)/(max-min)
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, 0, 0.5, 0)
            return frame
        end
    end
    local rotationSliderManuallyChanged = false
    CreateFancySlider(iContainer, "Rotation", 180, 360, Config.InvisStealAngle, function(v)
        rotationSliderManuallyChanged = true
        Config.InvisStealAngle = v
        _G.InvisStealAngle = v
        SaveConfig()
    end)
    CreateFancySlider(iContainer, "Depth", 0.5, 10, Config.SinkSliderValue, function(v)
        Config.SinkSliderValue = v
        _G.SinkSliderValue = v
        SaveConfig()
    end)
    local function updateVisualState(on)
        if btnInvis then
            btnInvis.Text = on and "ON" or "OFF"
            btnInvis.BackgroundColor3 = on and Theme.Success or Theme.SurfaceHighlight
        end
        if _G.updateMovementPanelInvisVisual then
            pcall(_G.updateMovementPanelInvisVisual, on)
        end
    end
    btnInvis.MouseButton1Click:Connect(function()
		if _G.toggleInvisibleSteal then
			pcall(_G.toggleInvisibleSteal)
			updateVisualState(_G.invisibleStealEnabled or false)
		end
	end)
	_G.toggleInvisibleSteal = function()
		if animPlaying then turnOff() else turnOn() end
	end
	UserInputService.InputBegan:Connect(function(input)
		if UserInputService:GetFocusedTextBox() then return end
		if input.KeyCode == (_G.INVISIBLE_STEAL_KEY or Enum.KeyCode.V) then
			pcall(_G.toggleInvisibleSteal)
			if _G.updateMovementPanelInvisVisual then pcall(_G.updateMovementPanelInvisVisual, _G.invisibleStealEnabled or false) end
			if updateVisualState then updateVisualState(_G.invisibleStealEnabled or false) end
		end
	end)
	local function onCharacterAdded(newChar)
		clearErrorOrb(); clearAllGhosts(); lagbackCallCount = 0
		pcall(function() for _, c in pairs(Workspace.CurrentCamera:GetChildren()) do if c:IsA("BasePart") and c.Name == "HumanoidRootPart" then c:Destroy() end end end)
		if oldRoot then pcall(function() oldRoot:Destroy() end); oldRoot = nil end
		if clone then pcall(function() clone:Destroy() end); clone = nil end
		animPlaying = false; _G.invisibleStealEnabled = false
		if _G.updateMovementPanelInvisVisual then pcall(_G.updateMovementPanelInvisVisual, false) end
		task.wait(0.2)
		local camera = Workspace.CurrentCamera
		if camera and newChar then
			local h = newChar:FindFirstChildOfClass("Humanoid")
			if h then camera.CameraSubject = h; camera.CameraType = Enum.CameraType.Custom end
		end
	end
    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    local function setupDeathListener()
        local ch = LocalPlayer.Character
        if ch then
            local h = ch:FindFirstChildOfClass("Humanoid")
            if h then h.Died:Connect(function() clearErrorOrb(); clearAllGhosts(); lagbackCallCount = 0 end) end
        end
    end
    setupDeathListener()
    LocalPlayer.CharacterAdded:Connect(function() task.wait(0.1); setupDeathListener() end)
    task.spawn(function()
        local currentConnection = nil
        _G.AntiDieConnection = nil
        _G.AntiDieDisabled = false
        local function setupAntiDie()
            if _G.AntiDieDisabled then return end
            local character = LocalPlayer.Character
            if not character then return end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            if currentConnection then pcall(function() currentConnection:Disconnect() end) end
            currentConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if _G.AntiDieDisabled then return end
                if humanoid.Health <= 0 then
                    humanoid.Health = humanoid.MaxHealth
                end
            end)
            _G.AntiDieConnection = currentConnection
        end
        _G.setupAntiDie = setupAntiDie
        setupAntiDie()
        LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if not _G.AntiDieDisabled then
                setupAntiDie()
            end
        end)
    end)
end)
task.spawn(function()
    local wasStealingForInvis = false
    local invisWasEnabledBefore = false
    local autoEnabledInvis = false
    task.wait(1)
    while task.wait(0.1) do
        if _G.AutoInvisDuringSteal == false then
            wasStealingForInvis = false
            autoEnabledInvis = false
        else
            local isStealing = LocalPlayer:GetAttribute("Stealing")
            if isStealing and not wasStealingForInvis then
                invisWasEnabledBefore = _G.invisibleStealEnabled or false
                if not _G.invisibleStealEnabled and _G.toggleInvisibleSteal then
                    task.delay(0.25, function()
                        if LocalPlayer:GetAttribute("Stealing") and not _G.invisibleStealEnabled then
                            pcall(_G.toggleInvisibleSteal)
                            autoEnabledInvis = true
                        end
                    end)
                end
            end
            if not isStealing and autoEnabledInvis and _G.invisibleStealEnabled and _G.toggleInvisibleSteal then
                autoEnabledInvis = false
                task.spawn(function()
                    local prevSink = _G.SinkSliderValue
                    local prevAngle = _G.InvisStealAngle
                    _G.SinkSliderValue = 0
                    _G.InvisStealAngle = 0
                    task.wait(0.25)
                    if _G.invisibleStealEnabled and _G.toggleInvisibleSteal and not LocalPlayer:GetAttribute("Stealing") then
                        pcall(_G.toggleInvisibleSteal)
                    end
                    _G.SinkSliderValue = prevSink
                    _G.InvisStealAngle = prevAngle
                end)
            end
            wasStealingForInvis = isStealing
        end
    end
end)
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(3)
    local Players_GD = game:GetService("Players")
    local RunService_GD = game:GetService("RunService")
    local ReplicatedStorage_GD = game:GetService("ReplicatedStorage")
    local HttpService_GD = game:GetService("HttpService")
    local LocalPlayer_GD = Players_GD.LocalPlayer
    local PlayerGui_GD = LocalPlayer_GD:WaitForChild("PlayerGui")
    local okReq, Synchronizer_GD = true, _G.ZawaRawSync
    local AnimalsData_GD = require(ReplicatedStorage_GD.Datas.Animals)
    local AnimalsShared_GD = require(ReplicatedStorage_GD.Shared.Animals)
    local MutationsData_GD = require(ReplicatedStorage_GD.Datas.Mutations)
    local TraitsData_GD = require(ReplicatedStorage_GD.Datas.Traits)
    local NumberUtils_GD = require(ReplicatedStorage_GD.Utils.NumberUtils)
    if getgenv().ZawaHub_GriefDetectorCleanup then
        pcall(getgenv().ZawaHub_GriefDetectorCleanup)
    end
    local GD_Conns = {}
    local function GDConnect(Signal, Callback)
        local Conn = Signal:Connect(Callback)
        table.insert(GD_Conns, Conn)
        return Conn
    end
    local function GDCleanup()
        for _, conn in ipairs(GD_Conns) do
            if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
        end
        if getgenv().ZawaHub_GriefDetectorUI then
            pcall(function() getgenv().ZawaHub_GriefDetectorUI:Destroy() end)
        end
        getgenv().ZawaHub_GriefDetectorCleanup = nil
    end
    getgenv().ZawaHub_GriefDetectorCleanup = GDCleanup
    local MUTATION_EMOJIS = {
        ["Gold"]="<:Gold:1487969958347411718>",["Diamond"]="<:Diamond:1487969901816840252>",
        ["Rainbow"]="<:Rainbow:1487970016736317531>",["Galaxy"]="<:Galaxy:1487969940743913595>",
        ["Radioactive"]="<:Radioactive:1487969993269182494>",["Bloodrot"]="<:Bloodrot:1487969793876168716>",
        ["Candy"]="<:Candy:1487969850109333574>",["Divine"]="<:Divine:1487969919537647626>",
        ["Lava"]="<:Lava:1487969974659186708>",["Cursed"]="<:Cursed:1487969875359174738>",
        ["YinYang"]="<:Yinyang:1487970035912806491>",
    }
    local PendingNotifications = {}
    local CurrentStealInfo = nil
    local StealingEndedAt = 0
    local ScreenGui = Instance.new("ScreenGui")
    getgenv().ZawaHub_GriefDetectorUI = ScreenGui
    ScreenGui.Name = "ZawaHub_GriefDetector"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui_GD
    local ListFrame = Instance.new("Frame")
    ListFrame.Size = UDim2.new(0, 320, 0, 600)
    ListFrame.Position = UDim2.new(0.5, -160, 0, 10)
    ListFrame.BackgroundTransparency = 1
    ListFrame.Parent = ScreenGui
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = ListFrame
    local function getStealInfo()
        local stealingIndex = LocalPlayer_GD:GetAttribute("StealingIndex")
        if not stealingIndex then return nil end
        local bestMatch, highestGenValue = nil, -1
        for _, data in pairs(Synchronizer_GD.caches) do
            if type(data) ~= "table" or type(data.AnimalList) ~= "table" then continue end
            for _, entry in pairs(data.AnimalList) do
                if type(entry) ~= "table" or tostring(entry.Index) ~= tostring(stealingIndex) then continue end
                local info = AnimalsData_GD[entry.Index]
                local genValue = 0
                pcall(function()
                    genValue = AnimalsShared_GD:GetGeneration(entry.Index, entry.Mutation, entry.Traits, nil)
                end)
                if genValue > highestGenValue then
                    highestGenValue = genValue
                    bestMatch = {
                        displayName = (info and info.DisplayName) or entry.Index,
                        rawName = entry.Index,
                        mutation = entry.Mutation or "None",
                        traits = (entry.Traits and #entry.Traits > 0) and entry.Traits or {},
                        genValue = genValue,
                        genText = "$" .. NumberUtils_GD:ToString(genValue) .. "/s",
                    }
                end
            end
        end
        return bestMatch
    end
    local function getUserId(name)
        local ok, id = pcall(function() return Players_GD:GetUserIdFromNameAsync(name) end)
        if ok and id then return id end
        local p = Players_GD:FindFirstChild(name)
        return p and p.UserId or 1
    end
    local function getItemIcon(name)
        local ItemsFolder = ReplicatedStorage_GD:FindFirstChild("Items")
        if not ItemsFolder then return "" end
        local Item = ItemsFolder:FindFirstChild(name)
        if not Item then return "" end
        if Item:IsA("Tool") then return Item.TextureId end
        if Item:FindFirstChild("Handle") and Item.Handle:IsA("MeshPart") then return Item.Handle.TextureID end
        return ""
    end
    local function Notify(Griefer, Victim, Item, Autojoiner, StealInfo)
        if typeof(Item) == "string" and (Item == "#92FF67" or Item:sub(1,1) == "#") then return end
        local ItemIcon = getItemIcon(Item)
        local animalMutation = "Normal"
        if StealInfo and StealInfo.mutation then
            animalMutation = StealInfo.mutation:sub(1,1):upper() .. StealInfo.mutation:sub(2):lower()
        end
        local isRainbow = (animalMutation == "Rainbow")
        local mutData = MutationsData_GD[animalMutation]
        local traitColor = mutData and mutData.MainColor or Color3.fromRGB(180,180,180)
        local goldData = MutationsData_GD and MutationsData_GD["Gold"]
        local goldColor = goldData and goldData.MainColor or Color3.fromRGB(255,222,89)
        local function getRainbow(speed)
            local t = tick() * (speed or 0.2)
            local kp = {}
            for i = 0, 10 do
                kp[i+1] = ColorSequenceKeypoint.new(i/10, Color3.fromHSV((i/10 - t) % 1, 1, 1))
            end
            return ColorSequence.new(kp)
        end
        local animalName = (StealInfo and StealInfo.displayName) or "Player Griefed!"
        if #animalName > 20 then animalName = animalName:sub(1, 18) .. "..." end
        local genText = StealInfo and StealInfo.genText or ""
        local Card = Instance.new("CanvasGroup")
        Card.BackgroundColor3 = Color3.fromRGB(20,20,20)
        Card.GroupTransparency = 1
        Card.Position = UDim2.new(1.2, 0, 0, 0)
        Card.Visible = false
        Card.AutomaticSize = Enum.AutomaticSize.XY
        Card.Size = UDim2.new(0, 0, 0, 95)
        Card.Parent = ListFrame
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
        local CardGradient = Instance.new("UIGradient", Card)
        CardGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(35,35,35)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(15,15,15))
        })
        CardGradient.Rotation = 90
        local CardStroke = Instance.new("UIStroke", Card)
        CardStroke.Thickness = 2; CardStroke.Transparency = 0.05; CardStroke.Color = Color3.fromRGB(255, 30, 30)
        local StrokeGradient = Instance.new("UIGradient", CardStroke)
        if isRainbow then
            StrokeGradient.Color = getRainbow(0.3)
        else
            StrokeGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 30, 30)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 10, 10))
            })
        end
        StrokeGradient.Rotation = 90
        local CardPadding = Instance.new("UIPadding", Card)
        CardPadding.PaddingTop = UDim.new(0,4); CardPadding.PaddingBottom = UDim.new(0,4)
        CardPadding.PaddingLeft = UDim.new(0,4); CardPadding.PaddingRight = UDim.new(0,8)
        local MainLayout = Instance.new("UIListLayout", Card)
        MainLayout.FillDirection = Enum.FillDirection.Horizontal
        MainLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        MainLayout.Padding = UDim.new(0, 6)
        MainLayout.SortOrder = Enum.SortOrder.LayoutOrder
        local Viewport = Instance.new("ViewportFrame", Card)
        Viewport.Size = UDim2.new(0, 95, 0, 95)
        Viewport.BackgroundTransparency = 1
        Viewport.LayoutOrder = 1
        local WorldModel = Instance.new("WorldModel", Viewport)
        local Cam = Instance.new("Camera"); Cam.FieldOfView = 15; Cam.Parent = Viewport
        Viewport.CurrentCamera = Cam
        local InfoCol = Instance.new("Frame", Card)
        InfoCol.AutomaticSize = Enum.AutomaticSize.XY
        InfoCol.BackgroundTransparency = 1
        InfoCol.LayoutOrder = 2
        local InfoLayout = Instance.new("UIListLayout", InfoCol)
        InfoLayout.Padding = UDim.new(0,0); InfoLayout.SortOrder = Enum.SortOrder.LayoutOrder
        local HeaderRow = Instance.new("Frame", InfoCol)
        HeaderRow.AutomaticSize = Enum.AutomaticSize.XY
        HeaderRow.BackgroundTransparency = 1
        HeaderRow.LayoutOrder = 1
        local HeaderLayout = Instance.new("UIListLayout", HeaderRow)
        HeaderLayout.FillDirection = Enum.FillDirection.Horizontal
        HeaderLayout.Padding = UDim.new(0,4)
        HeaderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        local NameLabel = Instance.new("TextLabel", HeaderRow)
        NameLabel.AutomaticSize = Enum.AutomaticSize.XY
        NameLabel.BackgroundTransparency = 1
        NameLabel.TextColor3 = isRainbow and Color3.new(1,1,1) or traitColor
        NameLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
        NameLabel.TextSize = 17; NameLabel.RichText = true
        NameLabel.Text = "<b>" .. animalName .. "</b>"
        local NameGradient = Instance.new("UIGradient", NameLabel)
        if isRainbow then
            NameGradient.Color = getRainbow(0.5)
        else
            NameGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, traitColor),
                ColorSequenceKeypoint.new(0.45, Color3.new(1,1,1)),
                ColorSequenceKeypoint.new(0.55, Color3.new(1,1,1)),
                ColorSequenceKeypoint.new(1, traitColor)
            })
        end
        local GenLabel = Instance.new("TextLabel", HeaderRow)
        GenLabel.AutomaticSize = Enum.AutomaticSize.XY
        GenLabel.BackgroundTransparency = 1
        GenLabel.TextColor3 = goldColor:Lerp(Color3.new(0,0,0), 0.1)
        GenLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
        GenLabel.TextSize = 17; GenLabel.RichText = true
        GenLabel.Text = "<b>" .. genText .. "</b>"
        local function addRow(label, value, icon, order)
            local row = Instance.new("Frame", InfoCol)
            row.AutomaticSize = Enum.AutomaticSize.XY
            row.BackgroundTransparency = 1
            row.LayoutOrder = order
            local rowLayout = Instance.new("UIListLayout", row)
            rowLayout.FillDirection = Enum.FillDirection.Horizontal
            rowLayout.Padding = UDim.new(0,4)
            rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            local imgHolder = Instance.new("Frame", row)
            imgHolder.Size = UDim2.new(0,16,0,16)
            imgHolder.BackgroundColor3 = Color3.fromRGB(50,50,50)
            imgHolder.BackgroundTransparency = 0.7
            imgHolder.BorderSizePixel = 0
            Instance.new("UICorner", imgHolder).CornerRadius = UDim.new(1,0)
            local img = Instance.new("ImageLabel", imgHolder)
            img.Size = UDim2.new(1,0,1,0); img.BackgroundTransparency = 1
            img.Image = icon or ("rbxthumb://type=AvatarHeadShot&id=" .. getUserId(value) .. "&w=60&h=60")
            Instance.new("UICorner", img).CornerRadius = UDim.new(1,0)
            local txt = Instance.new("TextLabel", row)
            txt.AutomaticSize = Enum.AutomaticSize.XY
            txt.BackgroundTransparency = 1
            txt.TextColor3 = Color3.fromRGB(220,220,220)
            txt.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            txt.TextSize = 13; txt.RichText = true
            txt.Text = "<b><font color=\"rgb(255,255,255)\">" .. label .. ":</font></b> <font color=\"rgb(220,220,220)\"><b>" .. value .. "</b></font>"
        end
        addRow("Griefer", Griefer, nil, 2)
        addRow("Victim", Victim, nil, 3)
        addRow("Item", Item, (ItemIcon ~= "" and ItemIcon or "rbxassetid://16302324017"), 4)
        if Autojoiner and Autojoiner ~= "None" then
            addRow("Autojoiner", Autojoiner, "rbxassetid://16302324017", 5)
        end
        local TraitsCol = Instance.new("Frame", InfoCol)
        TraitsCol.AutomaticSize = Enum.AutomaticSize.XY
        TraitsCol.Size = UDim2.new(1,0,0,18); TraitsCol.BackgroundTransparency = 1; TraitsCol.LayoutOrder = 10
        local TraitsGrid = Instance.new("UIGridLayout", TraitsCol)
        TraitsGrid.CellSize = UDim2.new(0,16,0,16); TraitsGrid.CellPadding = UDim2.new(0,2,0,2)
        if StealInfo and typeof(StealInfo.traits) == "table" then
            for _, tName in ipairs(StealInfo.traits) do
                local tData = TraitsData_GD[tName]
                local tIcon = tData and tData.Icon or "rbxassetid://16302324017"
                local tImg = Instance.new("ImageLabel", TraitsCol)
                tImg.BackgroundTransparency = 1; tImg.Image = tIcon
                tImg.Size = UDim2.new(0,16,0,16)
            end
        end
        task.spawn(function()
            local ModelsFolder = ReplicatedStorage_GD:FindFirstChild("Models") and ReplicatedStorage_GD.Models:FindFirstChild("Animals")
            local function findModel(name)
                if not ModelsFolder or not name then return nil end
                local search = name:lower():gsub("[%s%-_]", "")
                for _, child in ipairs(ModelsFolder:GetChildren()) do
                    if child.Name:lower():gsub("[%s%-_]", "") == search then return child end
                end
            end
            local OriginalModel = StealInfo and (findModel(StealInfo.rawName) or findModel(StealInfo.displayName))
            if OriginalModel then
                local ModelClone = OriginalModel:Clone()
                ModelClone:PivotTo(CFrame.new(0,0,0))
                ModelClone.Parent = WorldModel
                local templateName = OriginalModel.Name
                local traits = StealInfo and StealInfo.traits
                if typeof(traits) == "string" then
                    pcall(function() traits = HttpService_GD:JSONDecode(traits) end)
                end
                if AnimalsShared_GD then
                    pcall(function()
                        if animalMutation ~= "Normal" then
                            AnimalsShared_GD:ApplyMutation(ModelClone, templateName, animalMutation)
                        end
                        if typeof(traits) == "table" then
                            AnimalsShared_GD:ApplyTraits(ModelClone, templateName, traits)
                        end
                    end)
                end
                task.wait(0.1)
                for _, p in ipairs(ModelClone:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.LocalTransparencyModifier = 0
                        p.Anchored = true
                        p.CanCollide = false
                    end
                end
                local _, size = ModelClone:GetBoundingBox()
                local fov = Cam.FieldOfView
                local maxSize = math.max(size.X, size.Y, size.Z)
                local distance = (maxSize/2) / math.tan(math.rad(fov/2))
                distance = distance * 1.2
                local lookAt = Vector3.new(0,0,0)
                if ModelClone:FindFirstChild("HumanoidRootPart") then
                    lookAt = ModelClone.HumanoidRootPart.Position
                elseif ModelClone.PrimaryPart then
                    lookAt = ModelClone.PrimaryPart.Position
                end
                Cam.CFrame = CFrame.new(lookAt + Vector3.new(distance*0.8, distance*0.4, distance*0.8), lookAt)
                local rot, strokeRot = 0, 0
                GDConnect(RunService_GD.Heartbeat, function(dt)
                    if not Card.Parent then return end
                    rot += dt * 0.7
                    strokeRot = (strokeRot + dt * 20) % 360
                    ModelClone:PivotTo(CFrame.new(0,0,0) * CFrame.Angles(0, rot, 0))
                    if isRainbow then
                        local rb = getRainbow(0.4)
                        NameGradient.Color = rb
                        StrokeGradient.Color = rb
                    else
                        NameGradient.Offset = Vector2.new(-1.2 + (tick() * 1.2 % 2.4), 0)
                    end
                    StrokeGradient.Rotation = strokeRot
                end)
            end
            Card.Visible = true
            game:GetService("TweenService"):Create(Card, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                GroupTransparency = 0, Position = UDim2.new(0,0,0,0)
            }):Play()
        end)
        task.delay(5, function()
            if not Card.Parent then return end
            local ExitTween = game:GetService("TweenService"):Create(Card, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                GroupTransparency = 1, Position = UDim2.new(-1.2,0,0,0)
            })
            ExitTween:Play()
            ExitTween.Completed:Connect(function() Card:Destroy() end)
        end)
    end
    local function SendWebhook(Entries, Victim, StealInfo)
        local url = Config.GriefDetectorWebhookURL or ""
        if url == "" then return end
        local firstTime = Entries[1] and Entries[1].Time or os.time()
        local timeText = string.format("<t:%d:D> <t:%d:T>", firstTime, firstTime)
        local embed = {
            title = (StealInfo and StealInfo.displayName) or "Player Griefed!",
            color = 0xff4444, fields = {}, footer = { text = "ZawaHub" }
        }
        local desc = timeText .. "\n**Victim:** " .. Victim .. "\n"
        for i, entry in ipairs(Entries) do
            desc = desc .. "**Griefer:** " .. entry.Griefer .. "\n"
            desc = desc .. "**Item used:** " .. entry.Item .. "\n"
            if entry.Autojoiner and entry.Autojoiner ~= "None" then
                desc = desc .. "**Autojoiner:** " .. entry.Autojoiner .. "\n"
            end
            if i < #Entries then desc = desc .. "---\n" end
        end
        embed.description = desc
        if StealInfo then
            local mutationText = MUTATION_EMOJIS[StealInfo.mutation] or StealInfo.mutation
            table.insert(embed.fields, { name = "Generation", value = StealInfo.genText, inline = true })
            table.insert(embed.fields, { name = "Mutation",   value = mutationText,      inline = true })
        end
        local payload = { embeds = { embed } }
        local RequestFn = request or http_request
        if RequestFn then
            pcall(function()
                RequestFn({
                    Url = url, Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService_GD:JSONEncode(payload)
                })
            end)
        end
    end
    local function GetAutojoiner(PlayerName)
        local Player = Players_GD:FindFirstChild(PlayerName)
        if not Player then return nil end
        if isMobyUser and isMobyUser(Player)         then return "Moby" end
        if isKawaifuUser and isKawaifuUser(Player)   then return "Kawaifu" end
        if isAtlasUser and isAtlasUser(Player)       then return "Atlas" end
        if isBraintopiaUser and isBraintopiaUser(Player) then return "Braintopia" end
        local Char = Player.Character
        if Char and Char:FindFirstChild("BananaUserESP") then return "Gingerini" end
        local CoreGui = game:GetService("CoreGui")
        local MorangueteESP = CoreGui:FindFirstChild("BillboardGui") and CoreGui.BillboardGui:FindFirstChild("MorangueteESP_" .. tostring(Player.UserId))
        if MorangueteESP and MorangueteESP:FindFirstChild("ESP_Highlight_" .. tostring(Player.UserId)) then
            return "Moranguete"
        end
        return nil
    end
    local RecentFires = {}
    local function QueueGriefNotification(Text, Griefer, Item)
        if not Config.GriefDetectorEnabled then return end
        if typeof(Item) == "string" and (Item == "#92FF67" or Item:sub(1,1) == "#") then return end
        local now = tick()
        local key = tostring(Griefer) .. "|" .. tostring(Item)
        if RecentFires[key] and (now - RecentFires[key]) < 3 then return end
        RecentFires[key] = now
        local isStealing = LocalPlayer_GD:GetAttribute("Stealing") == true
        local inGracePeriod = (now - StealingEndedAt) < 0.5
        if isStealing and not CurrentStealInfo then
            CurrentStealInfo = getStealInfo()
        end
        local autojoiner = GetAutojoiner(Griefer)
        if isStealing or inGracePeriod then
            for _, entry in ipairs(PendingNotifications) do
                if entry.Griefer == Griefer and entry.Item == Item then return end
            end
            table.insert(PendingNotifications, {Griefer=Griefer, Item=Item, Autojoiner=autojoiner, Time=os.time()})
        else
            Notify(Griefer, LocalPlayer_GD.Name, Item, autojoiner, nil)
            local url = Config.GriefDetectorWebhookURL or ""
            if url ~= "" then
                SendWebhook({{Griefer=Griefer, Item=Item, Autojoiner=autojoiner, Time=os.time()}}, LocalPlayer_GD.Name, nil)
            end
        end
    end
    local function FlushNotifications()
        if #PendingNotifications == 0 then return end
        for _, entry in ipairs(PendingNotifications) do
            Notify(entry.Griefer, LocalPlayer_GD.Name, entry.Item, entry.Autojoiner, CurrentStealInfo)
        end
        SendWebhook(PendingNotifications, LocalPlayer_GD.Name, CurrentStealInfo)
        PendingNotifications = {}
        CurrentStealInfo = nil
    end
    GDConnect(LocalPlayer_GD:GetAttributeChangedSignal("Stealing"), function()
        local val = LocalPlayer_GD:GetAttribute("Stealing")
        if val == true then
            CurrentStealInfo = getStealInfo()
        elseif val == nil or val == false then
            StealingEndedAt = tick()
            task.delay(0.5, FlushNotifications)
        end
    end)
    local function GetHolder(GearName)
        for _, Player in ipairs(Players_GD:GetPlayers()) do
            if Player ~= LocalPlayer_GD and Player.Character and Player.Character:FindFirstChild(GearName) then
                return Player
            end
        end
    end
    local function GetHRP()
        local Char = LocalPlayer_GD.Character
        return Char and Char:FindFirstChild("HumanoidRootPart")
    end
    local function WatchPart(Part, OnHit, radius)
        radius = radius or 5
        GDConnect(Part.Touched, function(Hit)
            local Char = LocalPlayer_GD.Character
            if Char and Hit:IsDescendantOf(Char) then OnHit() end
        end)
        GDConnect(RunService_GD.Heartbeat, function()
            if not Part.Parent then return end
            local HRP = GetHRP()
            if HRP and (Part.Position - HRP.Position).Magnitude <= radius then OnHit() end
        end)
    end
    local HitBullets, SentryOwners = {}, {}
    local function TrackBullet(Obj)
        if not Obj.Name:find("SentryBullet") or HitBullets[Obj] then return end
        local Part = Obj:IsA("BasePart") and Obj or Obj:FindFirstChildWhichIsA("BasePart")
        if not Part then return end
        WatchPart(Part, function()
            if HitBullets[Obj] then return end
            HitBullets[Obj] = true
            local owner = next(SentryOwners) or "Unknown"
            QueueGriefNotification(owner .. " sentry hit", owner, "All Seeing Sentry")
            Obj.AncestryChanged:Connect(function() if not Obj.Parent then HitBullets[Obj] = nil end end)
        end)
    end
    local BoogieDetected = {}
    local function TrackHandle(Handle)
        if not Handle:IsA("BasePart") or Handle.Parent ~= workspace then return end
        if BoogieDetected[Handle] then return end
        task.spawn(function()
            local Mesh = nil
            for _ = 1, 10 do
                Mesh = Handle:FindFirstChildWhichIsA("SpecialMesh") or Handle:FindFirstChildWhichIsA("FileMesh")
                if Mesh then break end
                task.wait(0.05)
            end
            if not Mesh or not Mesh.TextureId or not Mesh.TextureId:find("65514619") then return end
            if BoogieDetected[Handle] then return end
            local Owner = GetHolder("Boogie Bomb")
            if Owner == LocalPlayer_GD then return end
            local OwnerName = Owner and Owner.Name or "Unknown"
            WatchPart(Handle, function()
                if BoogieDetected[Handle] then return end
                local curOwner = GetHolder("Boogie Bomb")
                if curOwner == LocalPlayer_GD then return end
                BoogieDetected[Handle] = true
                QueueGriefNotification(OwnerName .. " boogied", OwnerName, "Boogie Bomb")
            end, 18)
        end)
    end
    local HitMissiles = {}
    local function TrackMissile(Child)
        local Username = Child.Name:match("Missle_(.+)")
        if not Username or Username == LocalPlayer_GD.Name or not Child:IsA("BasePart") then return end
        local function OnHit()
            if HitMissiles[Child] then return end
            HitMissiles[Child] = true
            QueueGriefNotification(Username .. " heatseekered", Username, "Heatseeker")
            GDConnect(Child.AncestryChanged, function() if not Child.Parent then HitMissiles[Child] = nil end end)
        end
        GDConnect(Child.Touched, function(Hit)
            local Char = LocalPlayer_GD.Character
            if Char and Hit:IsDescendantOf(Char) then OnHit() end
        end)
        GDConnect(RunService_GD.Heartbeat, function()
            if HitMissiles[Child] or not Child.Parent then return end
            local HRP = GetHRP()
            if HRP and (Child.Position - HRP.Position).Magnitude <= 15 then OnHit() end
        end)
    end
    local DogeLastHit, WatchedDoges = 0, {}
    local function WatchDoge(Child)
        local Username = Child.Name:match("^PlayerName_(.+)_Doge$")
        if not Username or Username == LocalPlayer_GD.Name or WatchedDoges[Child] then return end
        WatchedDoges[Child] = true
        local Parts = Child:IsA("BasePart") and {Child} or Child:GetDescendants()
        for _, Part in ipairs(Parts) do
            if not Part:IsA("BasePart") then continue end
            Part.Touched:Connect(function(Hit)
                local Char = LocalPlayer_GD.Character
                if not Char or not Hit:IsDescendantOf(Char) then return end
                if tick() - DogeLastHit < 2 then return end
                DogeLastHit = tick()
                QueueGriefNotification(Username .. " doged", Username, "Attack Doge")
            end)
        end
    end
    local PaintballLastHit = 0
    local LaserDetected, LaserLastHit = {}, 0
    local function OnLaserHit()
        if tick() - LaserLastHit < 2 then return end
        local Holder = GetHolder("Laser Cape")
        if not Holder then return end
        LaserLastHit = tick()
        QueueGriefNotification(Holder.Name .. " lasered", Holder.Name, "Laser Cape")
    end
    local MedusaLastHit = 0
    local MedusaRadius = (33.986812591552734 + 33.986873626708984) / 2 / 2 * math.pi
    local BodyPartSet = {
        LeftFoot=true, RightFoot=true, LeftLowerLeg=true, RightLowerLeg=true,
        LeftUpperLeg=true, RightUpperLeg=true, LeftHand=true, RightHand=true,
        LeftLowerArm=true, RightLowerArm=true, LeftUpperArm=true, RightUpperArm=true,
        UpperTorso=true, LowerTorso=true, Head=true
    }
    local BodySwapLastHit = {}
    local OtherPlayerLastPos = {}
    local LocalLastPos = nil
    local SELF_TP_IGNORE_WINDOW = 0.5
    local LocalSelfTpAt = 0
    GDConnect(LocalPlayer_GD.CharacterAdded, function(char)
        local tool = char:FindFirstChild("Body Swap Potion")
        if tool then
            tool.Activated:Connect(function()
                LocalSelfTpAt = tick()
            end)
        end
        char.ChildAdded:Connect(function(child)
            if child.Name == "Body Swap Potion" and child:IsA("Tool") then
                child.Activated:Connect(function() LocalSelfTpAt = tick() end)
            end
        end)
    end)
    do
        local char = LocalPlayer_GD.Character
        if char then
            local tool = char:FindFirstChild("Body Swap Potion")
            if tool then tool.Activated:Connect(function() LocalSelfTpAt = tick() end) end
            char.ChildAdded:Connect(function(child)
                if child.Name == "Body Swap Potion" and child:IsA("Tool") then
                    child.Activated:Connect(function() LocalSelfTpAt = tick() end)
                end
            end)
        end
    end
    GDConnect(workspace.ChildAdded, function(Child)
        local SentryId = Child.Name:match("Sentry_(%d+)")
        if SentryId then
            local Ok, Name = pcall(Players_GD.GetNameFromUserIdAsync, Players_GD, tonumber(SentryId))
            SentryOwners[Ok and Name or "Unknown"] = true
        end
        TrackBullet(Child)
        if Child:IsA("Model") or Child:IsA("Folder") then GDConnect(Child.DescendantAdded, TrackBullet) end
        if Child.Name == "Handle" then TrackHandle(Child) end
        TrackMissile(Child)
        WatchDoge(Child)
        if Child:IsA("BasePart") and math.abs(Child.Size.X-1) <= 0.1 and math.abs(Child.Size.Y-1) <= 0.1 and math.abs(Child.Size.Z-0.1) <= 0.1 then
            local Holder = GetHolder("Paintball Gun")
            if Holder then
                local TouchConn, HeartbeatConn
                local function OnHit()
                    if tick() - PaintballLastHit < 2 then return end
                    PaintballLastHit = tick()
                    QueueGriefNotification(Holder.Name .. " paintballed", Holder.Name, "Paintball Gun")
                    TouchConn:Disconnect(); HeartbeatConn:Disconnect()
                end
                TouchConn = GDConnect(Child.Touched, function(Hit)
                    local Char = LocalPlayer_GD.Character
                    if Char and Hit:IsDescendantOf(Char) then OnHit() end
                end)
                HeartbeatConn = GDConnect(RunService_GD.Heartbeat, function()
                    if not Child.Parent then TouchConn:Disconnect(); HeartbeatConn:Disconnect(); return end
                    local HRP = GetHRP()
                    if HRP and (Child.Position - HRP.Position).Magnitude <= 3 then OnHit() end
                end)
            end
        end
        if Child:IsA("BasePart") and Child:FindFirstChildWhichIsA("Attachment")
            and math.abs(Child.Size.X-0.2) <= 0.01 and math.abs(Child.Size.Y-0.2) <= 0.01 and math.abs(Child.Size.Z-0.2) <= 0.01
            and not LaserDetected[Child] then
            local Holder = GetHolder("Laser Cape")
            if Holder then
                local HRP = GetHRP()
                local Char = LocalPlayer_GD.Character
                local MyHead = Char and Char:FindFirstChild("Head")
                if HRP and (Child.Position - HRP.Position).Magnitude <= 8 then
                    local HolderHead = Holder.Character and Holder.Character:FindFirstChild("Head")
                    if HolderHead and HolderHead:FindFirstChildWhichIsA("Attachment") then
                        if MyHead and MyHead:FindFirstChildWhichIsA("Attachment") then
                            local HeadAtt = MyHead:FindFirstChildWhichIsA("Attachment")
                            local PartAtt = Child:FindFirstChildWhichIsA("Attachment")
                            if HeadAtt.WorldPosition == PartAtt.WorldPosition then return end
                        end
                        LaserDetected[Child] = true
                        OnLaserHit()
                    end
                end
            end
        end
        if Child:IsA("MeshPart") and BodyPartSet[Child.Name] and tick() - MedusaLastHit >= 3 then
            local Holder = GetHolder("Medusa's Head")
            if Holder then
                local HolderHRP = Holder.Character and Holder.Character:FindFirstChild("HumanoidRootPart")
                if HolderHRP then
                    local Start = tick()
                    local Conn
                    Conn = GDConnect(RunService_GD.Heartbeat, function()
                        if tick() - MedusaLastHit < 3 or tick() - Start > 1 then Conn:Disconnect() return end
                        local Char = LocalPlayer_GD.Character
                        local HRP = GetHRP()
                        if not HRP then return end
                        local D = HolderHRP.Position - HRP.Position
                        if math.sqrt(D.X^2 + D.Z^2) > MedusaRadius then return end
                        local LocalPart = Char:FindFirstChild(Child.Name)
                        if LocalPart and (Child.Position - LocalPart.Position).Magnitude <= 2 then
                            MedusaLastHit = tick()
                            Conn:Disconnect()
                            QueueGriefNotification(Holder.Name .. " medusaed", Holder.Name, "Medusa's Head")
                        end
                    end)
                end
            end
        end
        if Child.Name == "WebRope" and Child:IsA("RopeConstraint") then
            local Holder = GetHolder("Web Slinger")
            if Holder then
                local Conn
                Conn = GDConnect(RunService_GD.Heartbeat, function()
                    if not Child.Parent then Conn:Disconnect() return end
                    local Char = LocalPlayer_GD.Character
                    if not Char then return end
                    if (Child.Attachment0 and Child.Attachment0:IsDescendantOf(Char)) or (Child.Attachment1 and Child.Attachment1:IsDescendantOf(Char)) then
                        QueueGriefNotification(Holder.Name .. " webbed", Holder.Name, "Web Slinger")
                        Conn:Disconnect()
                    end
                end)
            end
        end
    end)
    GDConnect(RunService_GD.Heartbeat, function()
        local HRP = GetHRP()
        if HRP then
            for _, Child in ipairs(workspace:GetChildren()) do
                local Username = Child.Name:match("^PlayerName_(.+)_Doge$")
                if not Username or Username == LocalPlayer_GD.Name then continue end
                local Part = Child:IsA("BasePart") and Child or Child:FindFirstChildWhichIsA("BasePart", true)
                if not Part or (Part.Position - HRP.Position).Magnitude > 5 then continue end
                if tick() - DogeLastHit < 2 then continue end
                DogeLastHit = tick()
                QueueGriefNotification(Username .. " doged", Username, "Attack Doge")
            end
        end
        local LocalHRP = GetHRP()
        if not LocalHRP then
            LocalLastPos = nil
            OtherPlayerLastPos = {}
            return
        end
        local CurrLocal = LocalHRP.Position
        local prevLocal = LocalLastPos
        LocalLastPos = CurrLocal
        local prevOthers = OtherPlayerLastPos
        local nextOthers = {}
        for _, p in ipairs(Players_GD:GetPlayers()) do
            if p ~= LocalPlayer_GD and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then nextOthers[p.Name] = hrp.Position end
            end
        end
        OtherPlayerLastPos = nextOthers
        if prevLocal and (CurrLocal - prevLocal).Magnitude >= 15 then
            local ownBsp     = (tick() - LocalSelfTpAt) < SELF_TP_IGNORE_WINDOW
            local ragdollTp  = false
            local stealing   = LocalPlayer_GD:GetAttribute("Stealing") == true
            if not ownBsp and not ragdollTp and not stealing then
                local bestPlr, bestDist = nil, 10
                for _, p in ipairs(Players_GD:GetPlayers()) do
                    if p == LocalPlayer_GD then continue end
                    local pChar = p.Character
                    if not pChar then continue end
                    local pHRP = pChar:FindFirstChild("HumanoidRootPart")
                    if not pHRP then continue end
                    local d = (pHRP.Position - prevLocal).Magnitude
                    if d >= bestDist then continue end
                    local prevP = prevOthers[p.Name]
                    if not prevP then continue end
                    if (pHRP.Position - prevP).Magnitude < 10 then continue end
                    bestDist = d
                    bestPlr = p
                end
                if bestPlr then
                    local last = BodySwapLastHit[bestPlr.Name] or 0
                    if tick() - last >= 30 then
                        BodySwapLastHit[bestPlr.Name] = tick()
                        QueueGriefNotification(bestPlr.Name .. " body swapped", bestPlr.Name, "Body Swap Potion")
                    end
                end
            end
        end
    end)
    do
        local function hookSwapChar(char)
            if not char then return end
            char.ChildAdded:Connect(function(child)
                if child.Name == "Body Swap Potion" and child:IsA("Tool") then
                    child.Activated:Connect(function() LocalSelfTpAt = tick() end)
                end
            end)
            local t = char:FindFirstChild("Body Swap Potion")
            if t then t.Activated:Connect(function() LocalSelfTpAt = tick() end) end
        end
        GDConnect(LocalPlayer_GD.CharacterAdded, hookSwapChar)
        hookSwapChar(LocalPlayer_GD.Character)
    end
    local okGui, NotificationFolder = pcall(function()
        return LocalPlayer_GD.PlayerGui:WaitForChild("Notification", 30) and LocalPlayer_GD.PlayerGui.Notification:WaitForChild("Notification", 30)
    end)
    if okGui and NotificationFolder then
        GDConnect(NotificationFolder.ChildAdded, function(Child)
            if not Child:IsA("TextLabel") then return end
            local Text = Child.Text
            if not (Text:find("ragdoll") or Text:find("balloon") or Text:find("rocket")) then return end
            for _, Player in ipairs(Players_GD:GetPlayers()) do
                if Player == LocalPlayer_GD then continue end
                if Text:find(Player.Name, 1, true) then
                    local Command = Text:match('"([^"]+)"')
                    if Command then
                        local CommandName = Command:sub(1,1):upper() .. Command:sub(2)
                        QueueGriefNotification(Player.Name .. " admined", Player.Name, CommandName)
                    end
                    return
                end
            end
        end)
    end
    local LastGenericHitAt = 0
    local function attributeNearbyHit()
        if tick() - LastGenericHitAt < 1.5 then return end
        local Char = LocalPlayer_GD.Character
        local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
        if not HRP then return end
        local bestPlr, bestTool, bestDist = nil, nil, math.huge
        for _, p in ipairs(Players_GD:GetPlayers()) do
            if p == LocalPlayer_GD then continue end
            local pChar = p.Character
            if not pChar then continue end
            local pHRP = pChar:FindFirstChild("HumanoidRootPart")
            if not pHRP then continue end
            local d = (pHRP.Position - HRP.Position).Magnitude
            if d > 28 then continue end
            for _, child in ipairs(pChar:GetChildren()) do
                if child:IsA("Tool") then
                    if d < bestDist then
                        bestDist = d; bestPlr = p; bestTool = child
                    end
                    break
                end
            end
        end
        local si = LocalPlayer_GD:GetAttribute("StealingIndex")
        local holdingBrainrot = si ~= nil and tostring(si) ~= ""
        if bestPlr and bestTool and DANGER_TOOLS[bestTool.Name] and holdingBrainrot then
            LastGenericHitAt = tick()
            QueueGriefNotification(bestPlr.Name .. " hit", bestPlr.Name, bestTool.Name)
        end
    end
    local function hookLocalHumanoidForHits()
        local char = LocalPlayer_GD.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then
            task.spawn(function()
                hum = char:WaitForChild("Humanoid", 5)
                if hum then
                    hum.StateChanged:Connect(function(_, newState)
                        if newState == Enum.HumanoidStateType.Physics
                           or newState == Enum.HumanoidStateType.PlatformStanding
                           or newState == Enum.HumanoidStateType.FallingDown then
                            attributeNearbyHit()
                        end
                    end)
                end
            end)
            return
        end
        hum.StateChanged:Connect(function(_, newState)
            if newState == Enum.HumanoidStateType.Physics
               or newState == Enum.HumanoidStateType.PlatformStanding
               or newState == Enum.HumanoidStateType.FallingDown then
                attributeNearbyHit()
            end
        end)
    end
    hookLocalHumanoidForHits()
    GDConnect(LocalPlayer_GD.CharacterAdded, hookLocalHumanoidForHits)
    local function hookLocalCharAttrs()
        local char = LocalPlayer_GD.Character
        if not char then return end
        for _, attrName in ipairs({"Ragdoll", "Ragdolled", "Stunned", "KnockedBack", "Frozen"}) do
            char:GetAttributeChangedSignal(attrName):Connect(function()
                if char:GetAttribute(attrName) then
                    attributeNearbyHit()
                end
            end)
        end
    end
    hookLocalCharAttrs()
    GDConnect(LocalPlayer_GD.CharacterAdded, hookLocalCharAttrs)
    for _, C in ipairs(workspace:GetChildren()) do
        local SentryId = C.Name:match("Sentry_(%d+)")
        if SentryId then
            local Ok, Name = pcall(Players_GD.GetNameFromUserIdAsync, Players_GD, tonumber(SentryId))
            SentryOwners[Ok and Name or "Unknown"] = true
        end
        TrackBullet(C)
        if C.Name == "Handle" then TrackHandle(C) end
        WatchDoge(C)
        TrackMissile(C)
    end
    local ATTACKER_RADIUS = 80
    local Ok, Net = pcall(function() return ReplicatedStorage_GD.Packages.Net end)
    if Ok and Net then
        for _, v in ipairs(Net:GetChildren()) do
            if v.Name == "Ragdoll" and v:IsA("RemoteEvent") then
                GDConnect(v.OnClientEvent, OnLaserHit)
            end
            if v.Name:sub(1,3) ~= "RE/" then continue end
            local Children = Net:GetChildren()
            local Remote = Children[table.find(Children, v) + 1]
            if not Remote or not Remote:IsA("RemoteEvent") then continue end
            GDConnect(Remote.OnClientEvent, function(...)
                local Args = {...}
                if #Args < 1 or typeof(Args[1]) ~= "Instance" or Args[1].Name ~= "Hit" then return end
                local Hit = Args[1]
                local rawGear = Args[2]
                local Gear = (typeof(rawGear) == "string" and rawGear ~= "" and not rawGear:match("^#%x+$") and not tonumber(rawGear)) and rawGear or (Hit.Parent and Hit.Parent.Name or "Unknown")
                local Char = Hit.Parent and Hit.Parent.Parent
                if not Char then return end
                local Plr = Players_GD:GetPlayerFromCharacter(Char)
                local Attacker = Plr and Plr.Name or Char.Name
                if Attacker == "Unknown" or Attacker == LocalPlayer_GD.Name then return end
                local MyHRP = GetHRP()
                local TheirHRP = Char:FindFirstChild("HumanoidRootPart")
                if MyHRP and TheirHRP and (MyHRP.Position - TheirHRP.Position).Magnitude > ATTACKER_RADIUS then
                    return
                end
                QueueGriefNotification(Attacker .. " hit", Attacker, Gear)
            end)
        end
    end
end)