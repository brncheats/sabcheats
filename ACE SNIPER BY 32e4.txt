print("deobf by discord.gg/speedhub")
print("neymarish the goat")
print("deobf by discord.gg/speedhub")
print("neymarish the goat")
print("deobf by discord.gg/speedhub")

local fn26, fn27, TweenService, RunService, Stats, localPlayer, genv, fn28, tbl17
local createUICorner, createUIStroke, screenGui, n31, frame, flag14

do
  do
    local fn29, createFrame

    do
      local aceRemoteMapper, genv2, fn30, ReplicatedStorage

      do
        local concat, tbl18

        do
          do
            do
            end

            do
              local function fn31(arg)
                local tbl19 = {}

                if type(gethui) == "function" then
                  local ok, result = pcall(gethui)

                  if ok and result then
                    tbl19[#tbl19 + 1] = result
                  end
                end

                local ok, result = pcall(function()
                  return game:GetService("CoreGui")
                end)

                if ok and result then
                  tbl19[#tbl19 + 1] = result
                end

                if arg then
                  tbl19[#tbl19 + 1] = arg
                end

                return tbl19
              end

              fn29 = function(arg, arg2)
                for _, v75 in ipairs(fn31(arg2)) do
                  pcall(function()
                    arg.Parent = v75
                  end)

                  if arg.Parent == v75 then
                    return v75
                  end
                end

                return arg.Parent
              end

              fn30 = function(arg, ...)
                local v75 = fn31(arg)

                for _, v76 in ipairs({ ... }) do
                  for _, v77 in ipairs(v75) do
                    pcall(function()
                      local v78 = v77:FindFirstChild(v76)

                      if v78 then
                        v78:Destroy()
                      end
                    end)
                  end
                end
              end
            end
          end

          createFrame = function(parent, arg)
            local tbl19 = arg or {}
            local aceFallingDots = parent:FindFirstChild("ACEFallingDots")

            if aceFallingDots then
              aceFallingDots:Destroy()
            end

            local frame2 = Instance.new("Frame")
            frame2.Name = "ACEFallingDots"
            frame2.Size = UDim2.fromScale(1, 1)
            frame2.BackgroundTransparency = 1
            frame2.BorderSizePixel = 0
            frame2.ClipsDescendants = true
            frame2.Active = false
            frame2.ZIndex = tbl19.ZIndex or 90
            frame2.Parent = parent
            local service = game:GetService("UserInputService")
            local TweenService2 = game:GetService("TweenService")
            local count = tbl19.Count or service.TouchEnabled and not service.KeyboardEnabled and 10 or 18
            local v75 = Random.new()
            local flag15 = true

            frame2.Destroying:Connect(function()
              flag15 = false
            end)

            for i = 1, count do
              task.spawn(function()
                local frame3 = Instance.new("Frame")
                frame3.Name = "FallingDot"
                frame3.AnchorPoint = Vector2.new(0.5, 0.5)
                frame3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                frame3.BorderSizePixel = 0
                frame3.Active = false
                frame3.Visible = false
                frame3.ZIndex = frame2.ZIndex + 1
                frame3.Parent = frame2
                local instance = Instance.new("UICorner")
                instance.CornerRadius = UDim.new(1, 0)
                instance.Parent = frame3
                task.wait(v75:NextNumber(0, tbl19.InitialSpread or 4.5))

                while flag15 and frame2.Parent and parent.Parent do
                  local screenGui2 = parent:FindFirstAncestorOfClass("ScreenGui")

                  if (not screenGui2 or screenGui2.Enabled) and frame2.Visible then
                    local v76 = v75:NextInteger(2, 4)
                    local v77 = v75:NextNumber(0.03, 0.97)
                    local v78 = 0.98
                    local n32 = math.clamp(v77 + v75:NextNumber(-0.15, 0.1), 0.02, v78)
                    local v79 = v75:NextNumber(tbl19.MinDuration or 4.8, tbl19.MaxDuration or 8.2)
                    frame3.Size = UDim2.fromOffset(v76, v76)
                    frame3.Position = UDim2.new(v77, 0, -0.1, -v76)
                    frame3.BackgroundTransparency = v75:NextNumber(0.28, 0.58)
                    frame3.Visible = true

                    local tween = TweenService2:Create(frame3, TweenInfo.new(v79, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
                      Position = UDim2.new(n32, 0, 1.06, v76),
                      BackgroundTransparency = v75:NextNumber(0.48, 0.76),
                    })

                    tween:Play()
                    tween.Completed:Wait()
                    frame3.Visible = false
                  else
                    frame3.Visible = false
                    task.wait(0.35)
                  end

                  task.wait(v75:NextNumber(0.12, 0.45))
                end

                if frame3.Parent then
                  frame3:Destroy()
                end
              end)
            end

            return frame2
          end

          genv2 = getgenv and getgenv() or _G
          ReplicatedStorage = cloneref and cloneref(game:GetService("ReplicatedStorage")) or game:GetService("ReplicatedStorage")
          aceRemoteMapper = type(genv2.ACERemoteMapper) == "table" and genv2.ACERemoteMapper
            or type(genv2._RaVeNet) == "table" and genv2._RaVeNet
            or type(_G._RaVeNet) == "table" and _G._RaVeNet
            or {}
          concat = table.concat
          tbl18 = {}

          do
            local str7 = tostring(game.GameId)
            local str8 = tostring(game.PlaceId)
            local v75 = tostring
            local jobId = game.JobId
            tbl18[1] = str7
            tbl18[2] = str8

            do
              local values = table.pack(v75(jobId))
              table.move(values, 1, values.n, 3, tbl18)
            end
          end
        end

        do
          local v75 = concat(tbl18, ":")
          aceRemoteMapper.generation = tonumber(aceRemoteMapper.generation) or 0

          if aceRemoteMapper.session ~= v75 then
            aceRemoteMapper.generation = aceRemoteMapper.generation + 1
            aceRemoteMapper.bypass = nil
            aceRemoteMapper.cache = {}
            aceRemoteMapper.pending = {}
            aceRemoteMapper.blocked = false
            aceRemoteMapper.buildFailedAt = nil
            aceRemoteMapper.lastError = nil
          end

          aceRemoteMapper.session = v75
        end
      end

      do
        local fn31

        do
          aceRemoteMapper.reps = ReplicatedStorage
          aceRemoteMapper.layers = tonumber(aceRemoteMapper.layers) or 2
          aceRemoteMapper.buildRetryGap = tonumber(aceRemoteMapper.buildRetryGap) or 15
          aceRemoteMapper.cache = type(aceRemoteMapper.cache) == "table" and aceRemoteMapper.cache or {}
          aceRemoteMapper.pending = type(aceRemoteMapper.pending) == "table" and aceRemoteMapper.pending or {}
          aceRemoteMapper.sentinel = "068a6294"
          aceRemoteMapper.resolveCount = tonumber(aceRemoteMapper.resolveCount) or 0
          aceRemoteMapper.cacheHits = tonumber(aceRemoteMapper.cacheHits) or 0
          aceRemoteMapper.allowProtectedBuild = false
          aceRemoteMapper.bypass = nil
          genv2.GreenDuelsNetBypass = nil
          _G.GreenDuelsNetBypass = nil

          do
            local tbl18 = {
              getgenv = true,
              getrenv = true,
              getsenv = true,
              getreg = true,
              getgc = true,
              filtergc = true,
              cloneref = true,
              compareinstances = true,
              gethui = true,
              loadstring = true,
              newcclosure = true,
              hookfunction = true,
              hookmetamethod = true,
              replaceclosure = true,
              restorefunction = true,
              checkcaller = true,
              isexecutorclosure = true,
              isourclosure = true,
              islclosure = true,
              iscclosure = true,
              clonefunction = true,
              getcallingscript = true,
              getscriptclosure = true,
              getscriptbytecode = true,
              getconnections = true,
              firesignal = true,
              fireproximityprompt = true,
              firetouchinterest = true,
              getnamecallmethod = true,
              setnamecallmethod = true,
              setthreadidentity = true,
              getthreadidentity = true,
              setidentity = true,
              getidentity = true,
              identifyexecutor = true,
              getexecutorname = true,
              writefile = true,
              readfile = true,
              appendfile = true,
              isfile = true,
              delfile = true,
              listfiles = true,
              makefolder = true,
              isfolder = true,
              delfolder = true,
              getcustomasset = true,
              saveinstance = true,
              request = true,
              http_request = true,
              setclipboard = true,
              queue_on_teleport = true,
              decompile = true,
              syn = true,
              crypt = true,
              WebSocket = true,
              Drawing = true,
            }

            fn31 = function(arg, arg2)
              local tbl19 = {}

              for k, v75 in pairs(arg) do
                if not tbl18[k] then
                  if not (type(v75) == "function" and type(isexecutorclosure) == "function" and isexecutorclosure(v75)) then
                    tbl19[k] = v75
                  end
                end
              end

              rawset(tbl19, "script", arg2)
              rawset(tbl19, "shared", shared)
              return tbl19
            end
          end
        end

        do
          local function fn32(arg)
            local v75 = "Instance"
            if typeof(arg) ~= v75 or type(getsenv) ~= "function" then
              return nil
            end

            if arg:IsA("ModuleScript") then
              pcall(require, arg)
            end

            local ok, result = pcall(getsenv, arg)
            local flag15 = ok and type(result) == "table"

            if flag15 then
              local v76 = "Instance"
              flag15 = typeof(rawget(result, "script")) == v76
            end

            if flag15 then
              return result
            end
            return nil
          end

          aceRemoteMapper.PickEnv = function(arg)
            local controllers = arg.reps:FindFirstChild("Controllers")
            local animals = arg.reps:FindFirstChild("Datas")
            local tbl18 = {}
            local v75 = controllers and controllers:FindFirstChild("LiveboardController")
            controllers = controllers and controllers:FindFirstChild("AnimalController")
            animals = animals and animals:FindFirstChild("Animals")
            tbl18[1] = v75
            tbl18[2] = controllers
            tbl18[3] = animals
            local v76 = nil

            for i = 1, #tbl18 do
              local v77 = tbl18[i]
              if typeof(v77) ~= "Instance" then
                continue
              end
              v76 = v76 or v77
              local v78 = fn32(v77)
              if v78 then
                return v78, v77
              end
            end

            if not v76 or type(getrenv) ~= "function" then
              return nil, nil
            end
            local ok, result = pcall(getrenv)
            local flag15 = not ok
            local flag16

            if flag15 then
              flag16 = flag15
            else
              local v77 = "table"
              flag16 = type(result) ~= v77
            end

            if flag16 then
              return nil, nil
            end
            return fn31(result, v76), v76
          end
        end
      end

      aceRemoteMapper.Build = function(arg)
        if arg.blocked then
          return nil
        end

        if not arg.allowProtectedBuild then
          arg.lastError = "protected build disabled"
          return nil
        end

        if arg.bypass then
          return arg.bypass
        end
        local buildFailedAt = arg.buildFailedAt

        if buildFailedAt then
          local buildFailedAt2 = arg.buildFailedAt
          buildFailedAt = os.clock() - buildFailedAt2 < arg.buildRetryGap
        end

        if buildFailedAt then
          return nil
        end
        local bypass = nil

        local ok, result = pcall(function()
          if type(loadstring) ~= "function" or type(setfenv) ~= "function" then
            error("loadstring/setfenv unavailable", 0)
          end

          local Net = require(arg.reps.Packages.Net)

          if type(Net) ~= "table" then
            error("Packages.Net did not return a table", 0)
          end

          local v75, v76 = arg:PickEnv()

          if not v75 or not v76 then
            error("invalid input", 0)
          end

          local n32 = math.max(1, math.floor(arg.layers))

          local tbl18 = {
            "return function(__env, __out, __func, ...)",
            "\tsetfenv(0, __env)",
            ("\tlocal function l%d(...) return __func(...) end"):format(n32),
          }

          for i = n32 - 1, 1, -1 do
            tbl18[#tbl18 + 1] = ("\tlocal function l%d(...) return l%d(...) end"):format(i, i + 1)
          end

          tbl18[#tbl18 + 1] = "\t__out.result = table.pack(pcall(l1, ...))"
          tbl18[#tbl18 + 1] = "\t__out.done = true"
          tbl18[#tbl18 + 1] = "end"
          local chunk, v77 = loadstring(table.concat(tbl18, "\n"), "=" .. v76:GetFullName())

          if not chunk then
            error(v77 or "compile failed", 0)
          end

          setfenv(chunk, v75)
          local v78 = chunk()
          local v79 = getthreadidentity or getidentity
          local v80 = setthreadidentity or setidentity
          local flag15 = type(v79) ~= "function"
          local flag16

          if flag15 then
            flag16 = flag15
          else
            local v81 = "function"
            flag16 = type(v80) ~= v81
          end

          if flag16 then
            error("thread identity functions unavailable", 0)
          end

          local function fn31(arg2, ...)
            local tbl19 = {}
            local v81 = v79()
            local ok, result = pcall(v80, 2)

            if not ok then
              error(result, 3)
            end

            local thread = coroutine.create(v78)
            local resume = coroutine.resume
            local v82 = table.pack(...)
            local v83 = v75
            v82.n = 5 + v82.n - 1
            table.move(v82, 1, v82.n, 5, v82)
            v82[1] = thread
            v82[2] = v83
            v82[3] = tbl19
            v82[4] = arg2
            local v84, v85 = resume(table.unpack(v82, 1, v82.n))
            pcall(v80, v81)

            if not v84 then
              error(v85, 3)
            end

            local n33 = os.clock() + 15

            while not tbl19.done and coroutine.status(thread) ~= "dead" and os.clock() < n33 do
              task.wait()
            end

            local result2 = tbl19.result

            if not result2 then
              error("no remote", 3)
            end

            if not result2[1] then
              error(result2[2], 3)
            end

            return table.unpack(result2, 2, result2.n)
          end

          local tbl19 = {}

          bypass = setmetatable({}, {
            __index = function(arg2, arg3)
              local v81 = tbl19[arg3]
              if v81 ~= nil then
                return v81
              end
              local v82 = Net[arg3]
              if type(v82) ~= "function" then
                tbl19[arg3] = v82
                return v82
              end

              local function fn32(arg4, ...)
                if arg4 == arg2 or arg4 == Net then
                  return fn31(v82, Net, ...)
                end
                return fn31(v82, Net, arg4, ...)
              end

              tbl19[arg3] = fn32
              return fn32
            end,
            __metatable = "Instance",
          })
        end)

        arg.bypass = bypass

        if bypass then
          arg.buildFailedAt = nil
          arg.lastError = nil
        else
          arg.buildFailedAt = os.clock()
          arg.lastError = tostring(result)
        end

        genv2.GreenDuelsNetBypass = bypass
        _G.GreenDuelsNetBypass = bypass
        return bypass
      end

      aceRemoteMapper.Trip = function(arg, raVeNetBlockReason)
        arg.generation = arg.generation + 1
        arg.blocked = true
        arg.bypass = nil
        arg.buildFailedAt = os.clock()
        arg.lastError = "blocked: " .. tostring(raVeNetBlockReason)
        genv2.GreenDuelsNetBypass = nil
        genv2._RaVeNetBlockReason = raVeNetBlockReason
        _G.GreenDuelsNetBypass = nil
        _G._RaVeNetBlockReason = raVeNetBlockReason
      end

      aceRemoteMapper.IsSentinel = function(arg, arg2)
        return type(arg2) == "string" and arg2:find(arg.sentinel, 1, true) ~= nil
      end

      aceRemoteMapper.Register = function(arg, arg2, arg3, arg4)
        local v75 = "function"
        if type(arg2) ~= v75 or type(arg3) ~= "string" then
          return nil
        end

        if typeof(arg4) ~= "Instance" or not arg4:IsA(arg2) or not arg4.Parent then
          return nil
        end
        arg.cache[arg2 .. "|" .. arg3] = arg4
        return arg4
      end

      aceRemoteMapper.Resolve = function(arg, arg2, arg3, arg4)
        local flag15 = arg2 ~= "RemoteEvent" and arg2 ~= "RemoteFunction" and arg2 ~= "UnreliableRemoteEvent"

        if not flag15 then
          local v75 = "function"
          flag15 = type(arg3) ~= v75
        end

        if flag15 or arg3 == "" then
          arg.lastError = "invalid remote request"
          return nil
        end
        local resolveTimedOut = arg2 .. "|" .. arg3
        local v75 = arg.cache[resolveTimedOut]
        if typeof(v75) == "Instance" and v75:IsA(arg2) and v75.Parent then
          arg.cacheHits = arg.cacheHits + 1
          return v75
        end
        arg.cache[resolveTimedOut] = nil
        if arg.blocked or not arg.allowProtectedBuild or not arg:Build() then
          return nil
        end
        local tbl18 = arg.pending[resolveTimedOut]

        if not tbl18 then
          tbl18 = { Done = false, Found = nil, Error = nil, Generation = arg.generation }
          arg.pending[resolveTimedOut] = tbl18

          task.spawn(function()
            local ok, found = pcall(function()
              local bypass = arg.bypass and arg.bypass[arg2]

              if type(bypass) ~= "function" then
                error(arg2 .. " resolver unavailable", 0)
              end

              return bypass(arg.bypass, arg3)
            end)

            if tbl18.Generation ~= arg.generation then
              tbl18.Done = true

              if arg.pending[resolveTimedOut] == tbl18 then
                arg.pending[resolveTimedOut] = nil
              end

              return
            end

            if ok and typeof(found) == "Instance" and found:IsA(arg2) and found.Parent then
              if arg:IsSentinel(found.Name) then
                arg:Trip("sentinel remote")
              else
                tbl18.Found = found
                arg.cache[resolveTimedOut] = found
                arg.resolveCount = arg.resolveCount + 1
              end
            else
              tbl18.Error = tostring(found)
              arg.lastError = tbl18.Error

              if arg:IsSentinel(tbl18.Error) then
                arg:Trip("sentinel response")
              end
            end

            tbl18.Done = true

            if arg.pending[resolveTimedOut] == tbl18 then
              arg.pending[resolveTimedOut] = nil
            end
          end)
        end

        local n32 = math.max(0, tonumber(arg4) or 5)
        local n33 = 0

        while not tbl18.Done and n33 < n32 do
          task.wait(0.05)
          n33 += 0.05
        end

        if not tbl18.Done then
          arg.lastError = "resolve timed out: " .. resolveTimedOut
        end

        return tbl18.Found
      end

      aceRemoteMapper.Reset = function(arg)
        arg.generation = arg.generation + 1
        arg.bypass = nil
        arg.cache = {}
        arg.pending = {}
        arg.blocked = false
        arg.buildFailedAt = nil
        arg.lastError = nil
        arg.resolveCount = 0
        arg.cacheHits = 0
        arg.allowProtectedBuild = false
        genv2.GreenDuelsNetBypass = nil
        genv2._RaVeNetBlockReason = nil
        _G.GreenDuelsNetBypass = nil
        _G._RaVeNetBlockReason = nil
      end

      aceRemoteMapper.SetProtectedRoutingEnabled = function(arg, arg2)
        arg.allowProtectedBuild = arg2 == true

        if arg.allowProtectedBuild then
          arg.blocked = false
          arg.buildFailedAt = nil
          arg.lastError = nil
        else
          arg.bypass = nil
        end

        return arg.allowProtectedBuild
      end

      aceRemoteMapper.GetStatus = function(arg)
        local n32 = 0

        for k in pairs(arg.cache) do
          n32 += 1
        end

        local n33 = 0

        for k in pairs(arg.pending) do
          n33 += 1
        end

        return {
          Session = arg.session,
          Ready = arg.bypass ~= nil,
          ProtectedRouting = arg.allowProtectedBuild == true,
          Blocked = arg.blocked == true,
          Cached = n32,
          Pending = n33,
          Resolves = arg.resolveCount,
          CacheHits = arg.cacheHits,
          LastError = arg.lastError,
        }
      end

      genv2.ACERemoteMapper = aceRemoteMapper
      genv2._RaVeNet = aceRemoteMapper
      _G.ACERemoteMapper = aceRemoteMapper
      _G._RaVeNet = aceRemoteMapper

      fn26 = function()
        if not game:IsLoaded() then
          game.Loaded:Wait()
        end

        local Players, service, TweenService2, RunService2, GuiService, service2, localPlayer2, playerGui, tbl18, genv3
        local aceFinderRuntime, fn31, finderUISettingsState, tbl19, tbl20, fn32, fn33, tbl21, tweenInfo, tweenInfo2
        local tweenInfo3, fn34, fn35, createUIStroke2, createUIPadding, createTextLabel, fn36, fn37, request_, v75
        local v76, v77, remotes, tbl22, str7, fn38, createViewportFrame, fn39, flag15, n32
        local n33, n34, v78, n35, screenGui2, instance, uiScale, playOpenAnimation, imageLabel, v79
        local fn40

        do
          local v80 = setthreadidentity or setidentity

          if v80 then
            v80(2)
          end

          Players = game:GetService("Players")
          service = game:GetService("UserInputService")
          TweenService2 = game:GetService("TweenService")
          RunService2 = game:GetService("RunService")
          local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
          game:GetService("CoreGui")
          GuiService = game:GetService("GuiService")
          local SoundService = game:GetService("SoundService")
          service2 = game:GetService("HttpService")
          local shared_ = ReplicatedStorage2:WaitForChild("Shared")
          local BrainrotAssets = require(shared_:WaitForChild("BrainrotAssets"))
          local Animals = require(shared_:WaitForChild("Animals"))
          localPlayer2 = Players.LocalPlayer
          playerGui = localPlayer2:WaitForChild("PlayerGui")
          tbl18 = {}
          genv3 = getgenv and getgenv() or _G
          local aceFinderRuntime2 = genv3.ACEFinderRuntime
          local v81 = "table"

          if type(aceFinderRuntime2) == v81 and type(aceFinderRuntime2.Unload) == "function" then
            pcall(aceFinderRuntime2.Unload)
          end

          aceFinderRuntime = { Running = true, Connections = {} }
          genv3.ACEFinderRuntime = aceFinderRuntime

          fn31 = function(arg, arg2)
            local connection = arg:Connect(function(...)
              if not aceFinderRuntime.Running then
                return
              end
              local ok, result = pcall(arg2, ...)

              if not ok then
                aceFinderRuntime.LastError = tostring(result)
              end
            end)

            table.insert(aceFinderRuntime.Connections, connection)
            return connection
          end

          local v82 = "table"
          genv3.FinderUISettingsState = type(genv3.FinderUISettingsState) == v82 and genv3.FinderUISettingsState or {}
          finderUISettingsState = genv3.FinderUISettingsState
          aceFinderRuntime.ConfigFile = "FinderUISettings.json"

          aceFinderRuntime.ConfigKeys = {
            "BackgroundOptionsVersion",
            "BackgroundIndex",
            "FallingParticlesEnabled",
            "NotificationsEnabled",
            "NotificationSoundsEnabled",
            "NotificationSoundIndex",
            "NotificationVolume",
            "GuiScale",
          }

          aceFinderRuntime.SaveConfig = function()
            if type(writefile) ~= "function" then
              return
            end
            local tbl23 = {}

            for _, configKey in ipairs(aceFinderRuntime.ConfigKeys) do
              tbl23[configKey] = finderUISettingsState[configKey]
            end

            local ok, result = pcall(function()
              writefile(aceFinderRuntime.ConfigFile, service2:JSONEncode(tbl23))
            end)

            if not ok then
              aceFinderRuntime.LastConfigError = tostring(result)
            end
          end

          local flag16 = type(isfile) == "function"

          if flag16 then
            local v83 = "function"
            flag16 = type(readfile) == v83
          end

          local result = nil

          if flag16 then
            local ok, result2 = pcall(isfile, aceFinderRuntime.ConfigFile)
            local v83 = ok and result2
            result = nil

            if v83 then
              local ok2, result3 = pcall(readfile, aceFinderRuntime.ConfigFile)

              if ok2 then
                local v84 = "function"
                ok2 = type(result3) == v84
              end

              ok2 = ok2 and result3 ~= ""
              result = nil

              if ok2 then
                local ok3

                ok3, result = pcall(function()
                  return service2:JSONDecode(result3)
                end)

                if ok3 then
                  local v84 = "table"
                  ok3 = type(result) == v84
                end

                local v84 = nil

                if not ok3 then
                  result = v84
                end
              end
            end
          end

          if result then
            for _, configKey in ipairs(aceFinderRuntime.ConfigKeys) do
              local v83 = result[configKey]
              local flag17 = finderUISettingsState[configKey] == nil
              local flag18

              if flag17 then
                local flag19 = type(v83) == "number"

                if flag19 then
                  flag18 = flag19
                else
                  local v84 = "boolean"
                  flag18 = type(v83) == v84
                end
              else
                flag18 = flag17
              end

              if flag18 then
                finderUISettingsState[configKey] = v83
              end
            end
          end

          tbl19 = {
            { Name = "NONE", Image = "", ScaleType = Enum.ScaleType.Crop, IsNone = true },
            {
              Name = "CURRENT",
              Image = "rbxassetid://137692455767789",
              ScaleType = Enum.ScaleType.Stretch,
            },
            {
              Name = "ACE 1",
              Image = "rbxassetid://128081130356834",
              ScaleType = Enum.ScaleType.Crop,
            },
            { Name = "ACE 2", Image = "rbxassetid://120480454937730", ScaleType = Enum.ScaleType.Crop },
            { Name = "ACE 3", Image = "rbxassetid://85127407374728", ScaleType = Enum.ScaleType.Crop },
            { Name = "ACE 4", Image = "rbxassetid://107291541054530", ScaleType = Enum.ScaleType.Crop },
            { Name = "ACE 5", Image = "rbxassetid://124230165619007", ScaleType = Enum.ScaleType.Crop },
            { Name = "ACE 6", Image = "rbxassetid://87766822871097", ScaleType = Enum.ScaleType.Crop },
            { Name = "ACE 7", Image = "rbxassetid://90280869222992", ScaleType = Enum.ScaleType.Crop },
            { Name = "ACE 8", Image = "rbxassetid://126860692354524", ScaleType = Enum.ScaleType.Crop },
            {
              Name = "ACE 9",
              Image = "rbxassetid://105131079571166",
              ScaleType = Enum.ScaleType.Crop,
            },
            { Name = "ACE 10", Image = "rbxassetid://108751216016989", ScaleType = Enum.ScaleType.Crop },
          }

          tbl20 = {
            {
              Name = "SOUND 1",
              Url = "https://files.catbox.moe/r1gxie.mp3",
              File = "FinderUI_Notification_v5_1.mp3",
              Volume = 1.5,
            },
            { Name = "SOUND 2", Url = "https://files.catbox.moe/m0evyv.mp3", File = "FinderUI_Notification_v3_2.mp3" },
            {
              Name = "SOUND 3",
              Url = "https://files.catbox.moe/ts994h.mp3",
              File = "FinderUI_Notification_v3_4.mp3",
            },
            {
              Name = "SOUND 4",
              Url = "https://files.catbox.moe/th43w4.mp3",
              File = "FinderUI_Notification_v3_5.mp3",
            },
            { Name = "NONE", IsNone = true },
          }

          if finderUISettingsState.BackgroundOptionsVersion ~= 2 then
            local num = tonumber(finderUISettingsState.BackgroundIndex)
            finderUISettingsState.BackgroundIndex = num and num + 1 or 2
            finderUISettingsState.BackgroundOptionsVersion = 2
          end

          finderUISettingsState.BackgroundIndex = math.clamp(tonumber(finderUISettingsState.BackgroundIndex) or 2, 1, #tbl19)
          finderUISettingsState.FallingParticlesEnabled = finderUISettingsState.FallingParticlesEnabled ~= false
          finderUISettingsState.OGOnlyEnabled = true
          finderUISettingsState.NotificationsEnabled = finderUISettingsState.NotificationsEnabled == true
          finderUISettingsState.NotificationSoundsEnabled = finderUISettingsState.NotificationSoundsEnabled == true
          finderUISettingsState.NotificationSoundIndex = math.clamp(tonumber(finderUISettingsState.NotificationSoundIndex) or 1, 1, #tbl20)
          finderUISettingsState.NotificationVolume = math.clamp(tonumber(finderUISettingsState.NotificationVolume) or 1, 0, 1)
          finderUISettingsState.GuiScale = math.clamp(tonumber(finderUISettingsState.GuiScale) or 1, 0.5, 1.5)
          finderUISettingsState.SoundCache = type(finderUISettingsState.SoundCache) == "table" and finderUISettingsState.SoundCache or {}

          if genv3.FinderUINotificationSound then
            pcall(function()
              genv3.FinderUINotificationSound:Stop()
            end)

            pcall(function()
              genv3.FinderUINotificationSound:Destroy()
            end)

            genv3.FinderUINotificationSound = nil
          end

          fn32 = function()
            local finderUINotificationSound = genv3.FinderUINotificationSound
            genv3.FinderUINotificationSound = nil

            if finderUINotificationSound then
              pcall(function()
                finderUINotificationSound:Stop()
              end)

              pcall(function()
                finderUINotificationSound:Destroy()
              end)
            end
          end

          local function fn41(arg)
            local v83 = "function"
            if type(arg) ~= v83 or #arg < 64 then
              return false
            end

            if arg:sub(1, 3) == "ID3" then
              return true
            end
            local v84, v85 = string.byte(arg, 1, 2)
            return v84 == 255 and v85 ~= nil and v85 >= 224
          end

          local function fn42(arg)
            if not arg then
              return nil
            end
            local v83 = finderUISettingsState.SoundCache[arg.File]
            if type(v83) == "string" and v83 ~= "" then
              return v83
            end
            local v84 = getcustomasset or getsynasset
            if type(v84) ~= "function" then
              return nil
            end
            local result2

            if type(readfile) == "function" then
              local ok
              ok, result2 = pcall(readfile, arg.File)
              local v85 = nil

              if not ok then
                result2 = v85
              end
            else
              local v85 = "function"
              result2 = nil

              if type(isfile) == v85 then
                local ok, result3 = pcall(isfile, arg.File)
                local flag17 = not ok or not result3
                result2 = nil
                if flag17 then
                  return nil
                end
              end
            end

            if type(readfile) == "function" and not fn41(result2) then
              return nil
            end
            local ok, result3 = pcall(v84, arg.File)

            if ok then
              local v85 = "function"
              ok = type(result3) == v85
            end

            if ok and result3 ~= "" then
              finderUISettingsState.SoundCache[arg.File] = result3
              return result3
            end
            return nil
          end

          local function fn43(arg)
            local v83 = fn42(arg)
            if v83 then
              return v83
            end
            local v84 = getcustomasset or getsynasset
            if type(writefile) ~= "function" or type(v84) ~= "function" then
              return nil, "CUSTOM ASSETS UNSUPPORTED"
            end
            local body = nil

            for _, v85 in ipairs({ arg.Url, arg.FallbackUrl }) do
              if type(v85) == "string" and v85 ~= "" and not fn41(body) then
                local request_2 = syn and syn.request or http_request or request

                if type(request_2) == "function" then
                  local ok, result2 = pcall(request_2, {
                    Url = v85,
                    Method = "GET",
                    Headers = { ["User-Agent"] = "Mozilla/5.0", Accept = "audio/mpeg,*/*" },
                  })

                  local flag17 = ok and type(result2) == "table"

                  if flag17 then
                    flag17 = tonumber(result2.StatusCode or result2.Status)
                  end

                  flag17 = flag17 or nil

                  if ok then
                    local v86 = "table"
                    ok = type(result2) == v86
                  end

                  if ok and (flag17 == nil or flag17 >= 200 and flag17 < 300) then
                    body = result2.Body or result2.body
                  end
                end

                if not fn41(body) then
                  local v86 = getthreadidentity or getidentity
                  local v87 = nil

                  if type(v86) == "function" then
                    pcall(function()
                      v87 = v86()
                    end)
                  end

                  if v80 then
                    pcall(v80, 8)
                  end

                  local ok, result2 = pcall(function()
                    return game:HttpGet(v85)
                  end)

                  if v80 then
                    pcall(v80, v87 or 2)
                  end

                  if ok then
                    body = result2
                  end
                end
              end
            end

            if not fn41(body) then
              return nil, "SOUND DOWNLOAD FAILED"
            end

            if not pcall(writefile, arg.File, body) then
              return nil, "SOUND CACHE FAILED"
            end
            local ok, result2 = pcall(v84, arg.File)
            if not ok or type(result2) ~= "string" or result2 == "" then
              return nil, "SOUND LOAD FAILED"
            end
            finderUISettingsState.SoundCache[arg.File] = result2
            return result2
          end

          fn33 = function(arg)
            if not finderUISettingsState.NotificationsEnabled then
              return
            end

            if not finderUISettingsState.NotificationSoundsEnabled then
              return
            end
            local notificationSoundIndex = finderUISettingsState.NotificationSoundIndex
            local v83 = tbl20[notificationSoundIndex]
            if not v83 then
              return
            end
            fn32()

            if v83.IsNone then
              if arg then
                arg(true)
              end

              return
            end

            task.spawn(function()
              local v84, v85 = fn43(v83)
              if
                not finderUISettingsState.NotificationsEnabled
                or not finderUISettingsState.NotificationSoundsEnabled
                or finderUISettingsState.NotificationSoundIndex ~= notificationSoundIndex
              then
                return
              end

              if not v84 then
                if arg then
                  arg(false, v85)
                end

                return
              end

              local instance2 = Instance.new("Sound")
              instance2.Name = "FinderUINotificationPreview"
              instance2.SoundId = v84
              instance2.Volume = math.clamp((tonumber(v83.Volume) or 1) * finderUISettingsState.NotificationVolume, 0, 10)
              instance2.Looped = false
              instance2.Parent = SoundService
              genv3.FinderUINotificationSound = instance2

              instance2.Ended:Connect(function()
                if genv3.FinderUINotificationSound == instance2 then
                  genv3.FinderUINotificationSound = nil
                end

                instance2:Destroy()
              end)

              local v86 = 10
              local n36 = os.clock() + v86

              while instance2.Parent and not instance2.IsLoaded and os.clock() < n36 do
                task.wait(0.05)
              end

              local ok = pcall(function()
                instance2.TimePosition = 0
                instance2:Play()
              end)

              if arg then
                arg(ok, ok and nil or "SOUND PLAY FAILED")
              end
            end)
          end

          if genv3.FinderUIFilterWheelConnection then
            genv3.FinderUIFilterWheelConnection:Disconnect()
          end

          genv3.FinderUIFilterWheelConnection = service.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseWheel then
              local value = select(1, GuiService:GetGuiInset())
              local n36 = service:GetMouseLocation() - value
              local flag17

              for i = #tbl18, 1, -1 do
                local v83 = tbl18[i]

                if not v83.Parent then
                  table.remove(tbl18, i)
                else
                  local parent = v83

                  while true do
                    flag17 = true

                    if parent then
                      if parent:IsA("GuiObject") and not parent.Visible then
                        flag17 = false
                        break
                      elseif parent:IsA("LayerCollector") then
                        flag17 = parent.Enabled
                        break
                      else
                        parent = parent.Parent
                      end
                    else
                      break
                    end
                  end

                  local absolutePosition = v83.AbsolutePosition
                  local absoluteSize = v83.AbsoluteSize
                  local flag18

                  if flag17 then
                    local flag19 = v83:GetAttribute("Collapsed") == true

                    if flag19 then
                      flag18 = flag19
                    else
                      flag18 = n36.X >= absolutePosition.X
                        and n36.X <= absolutePosition.X + absoluteSize.X
                        and n36.Y >= absolutePosition.Y
                        and n36.Y <= absolutePosition.Y + absoluteSize.Y
                    end
                  else
                    flag18 = flag17
                  end

                  if flag18 then
                    local z = input.Position.Z

                    if z ~= 0 then
                      local n37 = math.max(0, v83.AbsoluteCanvasSize.X - v83.AbsoluteWindowSize.X)
                      v83.CanvasPosition = Vector2.new(math.clamp(v83.CanvasPosition.X - z * 48, 0, n37), v83.CanvasPosition.Y)
                    end

                    break
                  end
                end
              end
            end
          end)

          fn30(playerGui, "FinderUI")

          tbl21 = {
            BG = Color3.fromRGB(5, 5, 7),
            Header = Color3.fromRGB(10, 5, 7),
            Card = Color3.fromRGB(10, 10, 12),
            CardHover = Color3.fromRGB(18, 18, 22),
            Border = Color3.fromRGB(96, 98, 108),
            BorderHover = Color3.fromRGB(165, 175, 180),
            White = Color3.fromRGB(248, 246, 248),
            Dim = Color3.fromRGB(148, 150, 160),
            TabActive = Color3.fromRGB(246, 248, 250),
            TabInact = Color3.fromRGB(132, 136, 144),
            TrackOn = Color3.fromRGB(246, 246, 250),
            TrackOff = Color3.fromRGB(26, 26, 31),
            KnobOn = Color3.fromRGB(5, 5, 7),
            KnobOff = Color3.fromRGB(205, 205, 212),
            Good = Color3.fromRGB(73, 214, 112),
            AccentBg = Color3.fromRGB(246, 246, 248),
            AccentFg = Color3.fromRGB(5, 5, 7),
            SubCard = Color3.fromRGB(12, 8, 10),
            SubField = Color3.fromRGB(24, 24, 28),
            PhotoBG = Color3.fromRGB(8, 10, 12),
          }

          tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
          tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
          tweenInfo3 = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

          fn34 = function(arg, arg2, arg3)
            TweenService2:Create(arg, arg2, arg3):Play()
          end

          fn35 = function(parent, arg)
            local instance2 = Instance.new("UICorner")
            instance2.CornerRadius = UDim.new(0, arg or 8)
            instance2.Parent = parent
            return instance2
          end

          createUIStroke2 = function(parent, color, thickness, transparency)
            local uiStroke = Instance.new("UIStroke")
            uiStroke.Color = color or tbl21.Border
            uiStroke.Thickness = thickness or 1
            uiStroke.Transparency = transparency or 0
            uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            uiStroke.Parent = parent
            return uiStroke
          end

          createUIPadding = function(parent, arg, arg2, arg3, arg4)
            local uiPadding = Instance.new("UIPadding")
            uiPadding.PaddingTop = UDim.new(0, arg or 0)
            uiPadding.PaddingBottom = UDim.new(0, arg2 or 0)
            uiPadding.PaddingLeft = UDim.new(0, arg3 or 0)
            uiPadding.PaddingRight = UDim.new(0, arg4 or 0)
            uiPadding.Parent = parent
            return uiPadding
          end

          createTextLabel = function(parent, text, textSize, textColor3, font)
            local textLabel = Instance.new("TextLabel")
            textLabel.BackgroundTransparency = 1
            textLabel.Text = text or ""
            textLabel.TextSize = textSize or 13
            textLabel.TextColor3 = textColor3 or tbl21.White
            textLabel.Font = font or Enum.Font.GothamMedium
            textLabel.TextXAlignment = Enum.TextXAlignment.Left
            textLabel.Parent = parent
            return textLabel
          end

          fn36 = function(arg)
            local ok

            if setclipboard then
              ok = pcall(setclipboard, arg)
            elseif toclipboard then
              ok = pcall(toclipboard, arg)
            else
              local set = Clipboard and Clipboard.set
              ok = false

              if set then
                ok = pcall(Clipboard.set, Clipboard, arg)
              end
            end

            return ok
          end

          local tbl23 = {}

          RunService2.RenderStepped:Connect(function(deltaTime)
            for i = #tbl23, 1, -1 do
              local v83 = tbl23[i]

              if not v83.Viewport.Parent or not v83.Camera.Parent then
                table.remove(tbl23, i)
              elseif v83.Mode == "baseidle" then
                v83.Camera.CFrame = CFrame.new(v83.CameraOrigin, v83.Center + Vector3.new(0, v83.LookHeight, 0))
              else
                v83.Angle = v83.Angle + deltaTime * v83.Speed
                local radius = v83.Radius
                local n36 = math.sin(v83.Angle) * radius
                local radius2 = v83.Radius
                local n37 = math.cos(v83.Angle) * radius2
                local float = v83.Float
                v83.Camera.CFrame = CFrame.new(
                  Vector3.new(v83.Center.X + n36, v83.Center.Y + math.sin(v83.Angle * 2) * float, v83.Center.Z + n37),
                  v83.Center
                )
              end
            end
          end)

          fn37 = function(arg)
            return tostring(arg or ""):lower():gsub("[^%w]", "")
          end

          local tbl24 = {
            skibiditoilet = { "Skibidi Toilet", "Skibidi" },
            skibidi = { "Skibidi", "Skibidi Toilet" },
            johnpork = { "John Pork" },
            strawberryelephant = { "Strawberry Elephant" },
            meowl = { "Meowl" },
            dragonaquanini = { "Dragon Aquanini" },
            dragoncannelloni = { "Dragon Cannelloni" },
          }

          request_ = syn and syn.request or http_request or request

          if type(request_) ~= "function" then
            request_ = nil
          end

          local function fn44(arg)
            if not arg then
              return nil
            end
            local ok, result2 = pcall(require, arg)
            if ok and type(result2) == "table" then
              return result2
            end
            return nil
          end

          local v83 = ReplicatedStorage2:FindFirstChild("Datas")
          local controllers = ReplicatedStorage2:FindFirstChild("Controllers")
          v75 = fn44(v83 and v83:FindFirstChild("Animals"))
          v76 = fn44(controllers and controllers:FindFirstChild("TradeController"))
          v77 = fn44(controllers and controllers:FindFirstChild("DuelsMachineController"))
          local v84 = fn44(controllers and controllers:FindFirstChild("LiveboardController"))
          remotes = {}
          tbl22 = {}
          str7 = "afb005f9-6e81-4e0a-8bb0-3555938a9658"
          local net = ReplicatedStorage2:FindFirstChild("Packages")
          net = net and net:FindFirstChild("Net")
          local getupvalues_ = debug and debug.getupvalues or getupvalues
          local getconstants_ = debug and debug.getconstants or getconstants
          local info = debug and debug.info
          local getinfo

          if info then
            getinfo = info
          else
            getinfo = debug and debug.getinfo
          end

          local flag17 = false

          if net then
            for _, child in ipairs(net:GetChildren()) do
              local match = child.Name:match("^R[EF]/(.+)$") or child.Name:match("^URE/(.+)$")
              if match and #match == 64 and match:match("^%x+$") then
                flag17 = true
                break
              end
            end
          end

          local function fn45(arg, arg2)
            if not net or typeof(arg) ~= "Instance" or not arg:IsA(arg2) then
              return false
            end

            if not arg:IsDescendantOf(net) then
              return false
            end

            if aceRemoteMapper:IsSentinel(arg.Name) then
              aceRemoteMapper:Trip("sentinel remote")
              return false
            end

            if flag17 then
              local match = arg.Name:match("^R[EF]/(.+)$")
              if not match or #match ~= 64 or not match:match("^%x+$") then
                return false
              end
            end

            return true
          end

          local v85 = fn44(net)

          local function fn46(arg, arg2, arg3)
            local v86 = aceRemoteMapper:Resolve(arg, arg2, 2.5)
            if fn45(v86, arg3) then
              return v86
            end
            local v87 = v85 and v85[arg]
            if type(v87) ~= "function" then
              return nil
            end
            local ok, result2 = pcall(v87, v85, arg2)
            if ok and fn45(result2, arg3) then
              aceRemoteMapper:Register(arg3, arg2, result2)
              return result2
            end
            return nil
          end

          local function fn47(arg, arg2)
            local tbl25 = {}
            local flag18 = type(arg) ~= "function"
            local flag19

            if flag18 then
              flag19 = flag18
            else
              local v86 = "function"
              flag19 = type(getupvalues_) ~= v86
            end

            if flag19 then
              return tbl25
            end
            local ok, result2 = pcall(getupvalues_, arg)
            local flag20 = not ok

            if not flag20 then
              local v86 = "table"
              flag20 = type(result2) ~= v86
            end

            if flag20 then
              return tbl25
            end
            local tbl26 = {}

            for k, v86 in pairs(result2) do
              if type(k) == "number" and fn45(v86, arg2) then
                table.insert(tbl26, k)
              end
            end

            table.sort(tbl26)
            local tbl27 = {}

            for _, v86 in ipairs(tbl26) do
              local v87 = result2[v86]

              if not tbl27[v87] then
                tbl27[v87] = true
                table.insert(tbl25, v87)
              end
            end

            return tbl25
          end

          local function fn48(arg, arg2)
            local flag18 = not arg

            if not flag18 then
              local v86 = "function"
              flag18 = type(getconnections) ~= v86
            end

            if flag18 or type(getinfo) ~= "function" then
              return nil
            end
            local ok, result2 = pcall(getconnections, arg.OnClientEvent)
            if not ok or type(result2) ~= "table" then
              return nil
            end

            for _, v86 in ipairs(result2) do
              local ok2, result3 = pcall(function()
                return v86.Function
              end)

              if ok2 and type(result3) == "function" then
                local ok3, result4 = pcall(getinfo, result3, "s")

                if ok3 and type(result4) == "string" and result4:find(arg2, 1, true) then
                  local ok4, result5 = pcall(getinfo, result3, "a")
                  if ok4 and type(result5) == "number" then
                    return result5
                  end
                end
              end
            end

            return nil
          end

          if v84 and type(v84.Start) == "function" then
            if type(getupvalues_) == "function" then
              local ok, result2 = pcall(getupvalues_, v84.Start)

              if ok and type(result2) == "table" then
                for _, v86 in pairs(result2) do
                  if type(v86) == "table" then
                    table.insert(tbl22, v86)
                  end
                end
              end
            end

            local remoteEvent = fn47(v84.Start, "RemoteEvent")
            local v86 = nil
            local v87 = nil

            for _, v88 in ipairs(remoteEvent) do
              local liveboardController = fn48(v88, "LiveboardController")

              if liveboardController == 1 then
                v86 = v86 or v88
              elseif liveboardController and liveboardController >= 3 then
                v87 = v87 or v88
              end
            end

            remotes.NewEntry = remotes.NewEntry or v86 or remoteEvent[1]
            remotes.ClaimEntry = remotes.ClaimEntry or v87 or remoteEvent[2]
            remotes.GetEntries = remotes.GetEntries or fn47(v84.Start, "RemoteFunction")[1]
          end

          if remotes.NewEntry then
            aceRemoteMapper:Register("RemoteEvent", "Liveboard/NewEntry", remotes.NewEntry)
          end

          if remotes.ClaimEntry then
            aceRemoteMapper:Register("RemoteEvent", "Liveboard/ClaimEntry", remotes.ClaimEntry)
          end

          if remotes.GetEntries then
            aceRemoteMapper:Register("RemoteFunction", "Liveboard/GetEntries", remotes.GetEntries)
          end

          remotes.NewEntry = remotes.NewEntry or fn46("RemoteEvent", "Liveboard/NewEntry", "RemoteEvent")
          remotes.ClaimEntry = remotes.ClaimEntry or fn46("RemoteEvent", "Liveboard/ClaimEntry", "RemoteEvent")
          remotes.GetEntries = remotes.GetEntries or fn46("RemoteFunction", "Liveboard/GetEntries", "RemoteFunction")

          fn38 = function(arg)
            for _, v86 in ipairs(tbl22) do
              local value = rawget(v86, arg)

              if not value and arg ~= nil then
                value = rawget(v86, tostring(arg))
              end

              if type(value) == "table" and typeof(value.Frame) == "Instance" then
                return value.Frame
              end
            end

            return nil
          end

          local function fn49(arg)
            local v86 = fn38(arg)
            if not v86 or not v86.Parent then
              return nil
            end
            local filler = v86:FindFirstChild("Filler")
            filler = filler and filler:FindFirstChild("Container")
            local brainrotViewport = filler and filler:FindFirstChild("BrainrotViewport") or v86:FindFirstChild("BrainrotViewport", true)
            brainrotViewport = brainrotViewport and brainrotViewport:FindFirstChildOfClass("WorldModel")
            if brainrotViewport and #brainrotViewport:GetChildren() > 0 then
              return brainrotViewport
            end
            return nil
          end

          local function fn50(arg)
            local str8 = tostring(arg or "")
            if str8 == "" or str8 == "none" or str8 == "None" then
              return "Default"
            end
            return str8
          end

          local function fn51(arg, arg2)
            local v86 = fn50(arg2)
            local plots = workspace:FindFirstChild("Plots")
            local v87 = nil

            if plots then
              v87 = nil

              for _, child in ipairs(plots:GetChildren()) do
                for _, child2 in ipairs(child:GetChildren()) do
                  if child2:IsA("Model") and child2.Name == arg then
                    if fn50(child2:GetAttribute("Mutation")) == v86 then
                      return child2
                    end
                    v87 = v87 or child2
                  end
                end
              end
            end

            for _, child in ipairs(workspace:GetChildren()) do
              if child:IsA("Model") and child:GetAttribute("Index") == arg then
                if fn50(child:GetAttribute("Mutation")) == v86 then
                  return child
                end
                v87 = v87 or child
              end
            end

            return v86 == "Default" and v87 or nil
          end

          if v76 and type(v76.SendInvite) == "function" then
            remotes.Invite = fn47(v76.SendInvite, "RemoteFunction")[1]

            if type(getconstants_) == "function" then
              local ok, result2 = pcall(getconstants_, v76.SendInvite)

              if ok then
                local v86 = "table"
                ok = type(result2) == v86
              end

              if ok then
                for _, v86 in pairs(result2) do
                  if type(v86) == "string" and v86:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") then
                    str7 = v86
                    break
                  end
                end
              end
            end
          end

          local function fn52(arg)
            local v86 = v75 and v75[arg]
            local v87 = "table"
            if type(v86) == v87 and type(v86.DisplayName) == "string" then
              return v86.DisplayName
            end
            return arg
          end

          local tbl25 = {
            ["Skibidi Toilet"] = { DistanceScale = 1.15, YShift = 0.1 },
            ["Strawberry Elephant"] = { YShift = 0.06, Yaw = 0.3490658503988659 },
            ["Meowl"] = { YShift = 0.06 },
            ["Dragon Aquanini"] = { YShift = 0.06, Yaw = 0.3490658503988659 },
            ["Dragon Cannelloni"] = { YShift = 0.06, Yaw = 0.3490658503988659 },
          }

          local function fn53(arg)
            local v86 = "function"
            if type(arg) ~= v86 or arg == "" then
              return nil
            end
            local tbl26 = { arg }
            local v87 = ipairs
            local tbl27 = tbl24[fn37(arg)] or {}

            for _, v88 in v87(tbl27) do
              if not table.find(tbl26, v88) then
                table.insert(tbl26, v88)
              end
            end

            for _, v88 in ipairs(tbl26) do
              local v89 = BrainrotAssets.getModel(v88)
              if v89 and v89:IsA("Model") then
                return v89
              end
            end

            return nil
          end

          local function fn54(parent, arg)
            local animations = ReplicatedStorage2:FindFirstChild("Animations")
            animations = animations and animations:FindFirstChild("Animals")
            animations = animations and animations:FindFirstChild(arg)
            local idle = animations and animations:FindFirstChild("Idle")
            if not idle or not idle:IsA("Animation") then
              return nil
            end
            local animationController = parent:FindFirstChild("AnimationController")

            if not animationController then
              animationController = Instance.new("AnimationController")
              animationController.Name = "AnimationController"
              animationController.Parent = parent
            end

            local animator = animationController:FindFirstChildOfClass("Animator")

            if not animator then
              animator = Instance.new("Animator")
              animator.Parent = animationController
            end

            local ok, result2 = pcall(function()
              return animator:LoadAnimation(idle)
            end)

            if ok and result2 then
              result2.Looped = true
              result2:Play(0)
              return result2
            end

            return nil
          end

          createViewportFrame = function(parent, arg, arg2, arg3, arg4, arg5)
            local viewportFrame = Instance.new("ViewportFrame")
            viewportFrame.Size = UDim2.fromScale(1, 1)
            viewportFrame.BackgroundTransparency = 1
            viewportFrame.BorderSizePixel = 0
            viewportFrame.LightDirection = Vector3.new(-1, -1.5, -1)
            viewportFrame.Ambient = Color3.fromRGB(215, 215, 215)
            viewportFrame:SetAttribute("HasBrainrotModel", false)
            viewportFrame:SetAttribute("ACEModelReady", false)
            viewportFrame.Parent = parent
            local instance2 = Instance.new("WorldModel")
            instance2.Parent = viewportFrame
            local camera = Instance.new("Camera")
            camera.Parent = viewportFrame
            viewportFrame.CurrentCamera = camera
            local flag18 = typeof(arg5) == "Instance"
            local v86 = flag18 and arg5 or fn53(arg)

            if not v86 then
              local v87 = createTextLabel(viewportFrame, arg2 or "?", isMobile and 11 or 12, tbl21.White, Enum.Font.GothamBold)
              v87.Size = UDim2.fromScale(1, 1)
              v87.TextXAlignment = Enum.TextXAlignment.Center
              v87.TextYAlignment = Enum.TextYAlignment.Center
              return viewportFrame
            end

            local clone = v86:Clone()
            clone.Parent = instance2
            viewportFrame:SetAttribute("ACEModelReady", true)

            for _, descendant in ipairs(clone:GetDescendants()) do
              if descendant:IsA("BasePart") then
                descendant.Anchored = true
                descendant.CanCollide = false
                descendant.CastShadow = false
              elseif descendant:IsA("Script") or descendant:IsA("LocalScript") then
                descendant:Destroy()
              elseif not flag18 and (descendant:IsA("ParticleEmitter") or descendant:IsA("Trail")) then
                descendant.Enabled = false
              end
            end

            local v87 = nil
            local v88 = fn50(arg3)

            if flag18 or v88 == "Default" then
              viewportFrame:SetAttribute("MutationReady", true)
            else
              local ok, result2 = pcall(function()
                return Animals:ApplyMutation(clone, arg, v88)
              end)

              if ok then
                v87 = result2
                viewportFrame:SetAttribute("MutationReady", true)
              else
                aceFinderRuntime.LastMutationError = tostring(result2)
              end
            end

            viewportFrame.Destroying:Connect(function()
              if typeof(v87) == "RBXScriptConnection" then
                v87:Disconnect()
              elseif typeof(v87) == "Instance" then
                v87:Destroy()
              elseif type(v87) == "function" then
                pcall(v87)
              elseif type(v87) == "table" then
                for _, v89 in ipairs({ "Normal", "Clean", "None" }) do
                  local v90 = v87[v89]
                  local v91 = "function"
                  if type(v90) == v91 then
                    pcall(v90, v87)
                    break
                  end
                end
              end
            end)

            pcall(function()
              if clone:IsA("Model") then
                clone:PivotTo(CFrame.new(0, 0, 0))
              end
            end)

            local flag19 = arg4 == "baseidle" and tbl25[arg] or nil

            if flag19 and flag19.Yaw then
              pcall(function()
                clone:PivotTo(clone:GetPivot() * CFrame.Angles(0, flag19.Yaw, 0))
              end)
            end

            local boundingBox, v89 = clone:GetBoundingBox()
            local n36 = math.max(v89.X, v89.Y, v89.Z)
            local n37 = boundingBox.Position + Vector3.new(0, v89.Y * 0.04, 0)

            if arg4 == "baseidle" then
              local tbl26 = flag19 or {}
              local n38 = n37 - Vector3.new(0, v89.Y * (tbl26.YShift or 0), 0)
              fn54(clone, arg)

              table.insert(tbl23, {
                Mode = "baseidle",
                Viewport = viewportFrame,
                Camera = camera,
                Center = n38,
                CameraOrigin = Vector3.new(n38.X, n38.Y + v89.Y * 0.3, n38.Z - n36 * 1.6 * (tbl26.DistanceScale or 1) + 0.02),
                LookHeight = v89.Y * 0.45,
              })
            else
              local v90 = 0.2

              table.insert(tbl23, {
                Viewport = viewportFrame,
                Camera = camera,
                Center = n37,
                Radius = n36 * 0.85 + 0.08,
                Angle = 0.6108652381980153 + math.random() * v90,
                Speed = 0.62,
                Float = math.max(v89.Y * 0.03, 0.02),
              })
            end

            return viewportFrame
          end

          fn39 = function(arg, arg2, arg3)
            local brainrotName = type(arg2) == "table" and arg2.BrainrotName or nil
            local mutation = type(arg2) == "table" and arg2.Mutation or nil
            fn50(mutation)
            local v86 = createViewportFrame
            local str8

            if arg3 then
              str8 = arg3
            else
              str8 = string.sub(tostring(brainrotName or "?"), 1, 1)
            end

            local v87 = v86(arg, brainrotName, str8, mutation, nil)
            if v87:GetAttribute("ACEModelReady") then
              return v87
            end

            task.spawn(function()
              for i = 1, 250 do
                if not aceFinderRuntime.Running or not arg.Parent then
                  return
                end
                local flag18 = arg2.UID ~= nil and fn49(arg2.UID) or nil

                if not flag18 and (i == 1 or i == 40 or i % 8 == 0) then
                  flag18 = fn51(brainrotName, mutation)
                end

                if flag18 then
                  local ok, result2 = pcall(createViewportFrame, arg, brainrotName, arg3, mutation, nil, flag18)

                  if ok and result2 then
                    if v87 and v87.Parent then
                      v87:Destroy()
                    end

                    v87 = result2
                    return
                  end
                end

                task.wait(0.1)
              end
            end)

            return v87
          end

          flag15 = service.TouchEnabled and not service.KeyboardEnabled
          local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
          local flag18 = flag15 and math.min(viewportSize.X, viewportSize.Y) < 600
          n32 = flag18 and 0.7 or 1
          local v86 = flag18 and 250

          if v86 then
            n33 = v86
          else
            n33 = flag15 and 290 or 370
          end

          local v87 = flag18 and 300

          if v87 then
            n34 = v87
          else
            n34 = flag15 and 350 or 430
          end

          v78 = flag15 and 44 or 50
          n35 = flag15 and 30 or 34
          screenGui2 = Instance.new("ScreenGui")
          screenGui2.Name = "FinderUI"
          screenGui2.ResetOnSpawn = false
          screenGui2.IgnoreGuiInset = true
          screenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
          screenGui2.DisplayOrder = 9999

          pcall(function()
            screenGui2.OnTopOfCoreBlur = true
          end)

          fn29(screenGui2, playerGui)
          instance = Instance.new("Frame")
          instance.Name = "Win"
          instance.Size = UDim2.fromOffset(n33, n34)
          instance.Position = flag15 and UDim2.new(0.5, -n33 / 2, 0.1, 4) or UDim2.new(0.5, -n33 / 2, 0.5, -n34 / 2)
          instance.BackgroundColor3 = tbl21.BG
          instance.BackgroundTransparency = 0
          instance.BorderSizePixel = 0
          instance.ClipsDescendants = true
          instance.Parent = screenGui2
          fn35(instance, 17)
          uiScale = Instance.new("UIScale")
          uiScale.Name = "FinderMainScale"
          uiScale.Scale = finderUISettingsState.GuiScale * n32
          uiScale.Parent = instance

          playOpenAnimation = function()
            local n36 = finderUISettingsState.GuiScale * n32
            uiScale.Scale = math.max(0.05, n36 * 0.6)
            TweenService2:Create(uiScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = n36 }):Play()
          end

          playOpenAnimation()
          imageLabel = Instance.new("ImageLabel")
          imageLabel.Name = "Background"
          imageLabel.Size = UDim2.fromScale(1, 1)
          imageLabel.BackgroundTransparency = 1
          local v88 = tbl19[finderUISettingsState.BackgroundIndex] or tbl19[1]
          imageLabel.Image = v88.Image
          imageLabel.ImageTransparency = 0
          imageLabel.ScaleType = v88.ScaleType
          imageLabel.Visible = not v88.IsNone
          imageLabel.ZIndex = 0
          imageLabel.ImageTransparency = 0
          imageLabel.Parent = instance
          fn35(imageLabel, 17)
          local frame2 = Instance.new("Frame")
          frame2.Name = "BackgroundShade"
          frame2.Size = UDim2.fromScale(1, 1)
          frame2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
          frame2.BackgroundTransparency = 0.45
          frame2.BorderSizePixel = 0
          frame2.ZIndex = 1
          frame2.Parent = instance
          fn35(frame2, 16)
          local v89 = createFrame

          local tbl26 = {
            Count = flag18 and 6 or flag15 and 10 or 14,
            ZIndex = 90,
            MinDuration = 5.8,
            MaxDuration = 9.2,
          }

          local fallingParticlesEnabled = finderUISettingsState.FallingParticlesEnabled
          v89(instance, tbl26).Visible = fallingParticlesEnabled
          v79 = nil

          fn40 = function(arg)
            if not finderUISettingsState.NotificationsEnabled or type(arg) ~= "table" or type(arg.BrainrotName) ~= "string" then
              return
            end

            if v79 then
              v79:Destroy()
              v79 = nil
            end

            local frame3 = Instance.new("Frame")
            frame3.Name = "FinderNotification"
            frame3.Size = UDim2.fromOffset(flag15 and 278 or 360, flag15 and 58 or 64)
            frame3.AnchorPoint = Vector2.new(0.5, 0)
            frame3.Position = UDim2.new(0.5, 0, 0, -(flag15 and 72 or 80))
            frame3.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
            frame3.BackgroundTransparency = 0.02
            frame3.BorderSizePixel = 0
            frame3.ClipsDescendants = true
            frame3.ZIndex = 100
            local aceSniperTopBarGui = genv3.ACESniperTopBarGui
            frame3.Parent = aceSniperTopBarGui and aceSniperTopBarGui.Parent and aceSniperTopBarGui or screenGui2
            fn35(frame3, 12)
            local instance2 = Instance.new("Frame")
            instance2.Name = "BrainrotPhoto"
            instance2.Size = UDim2.fromOffset(flag15 and 48 or 54, flag15 and 48 or 54)
            instance2.Position = UDim2.fromOffset(6, flag15 and 5 or 5)
            instance2.BackgroundColor3 = tbl21.PhotoBG
            instance2.BorderSizePixel = 0
            instance2.ZIndex = 102
            instance2.Parent = frame3
            fn35(instance2, 12)
            local frame4 = Instance.new("Frame")
            frame4.Size = UDim2.new(1, -4, 1, -6)
            frame4.Position = UDim2.fromOffset(2, 2)
            frame4.BackgroundTransparency = 1
            frame4.ZIndex = 103
            frame4.Parent = instance2
            fn39(frame4, arg, string.sub(arg.BrainrotName, 1, 1))
            local n36 = flag15 and 64 or 72
            local v90 = ""
            local v91 =
              createTextLabel(frame3, tostring(fn52(arg.BrainrotName)) .. v90, flag15 and 11 or 13, tbl21.White, Enum.Font.GothamBlack)
            v91.Size = UDim2.new(1, -(n36 + 12), 1, 0)
            v91.Position = UDim2.fromOffset(n36, 0)
            v91.TextXAlignment = Enum.TextXAlignment.Left
            v91.TextYAlignment = Enum.TextYAlignment.Center
            v91.TextTruncate = Enum.TextTruncate.AtEnd
            v91.ZIndex = 103
            v79 = frame3
            fn34(
              frame3,
              TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
              { Position = UDim2.new(0.5, 0, 0, flag15 and 8 or 14) }
            )

            fn33(function(arg2, arg3)
              if not arg2 and arg3 then
                aceFinderRuntime.LastSoundError = tostring(arg3)
              end
            end)

            task.delay(8, function()
              if v79 ~= frame3 or not frame3.Parent then
                return
              end
              local tween = TweenService2:Create(
                frame3,
                TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { Position = UDim2.new(0.5, 0, 0, -(flag15 and 72 or 26)) }
              )
              tween:Play()

              tween.Completed:Connect(function()
                if v79 == frame3 then
                  v79 = nil
                end

                frame3:Destroy()
              end)
            end)
          end
        end

        local frame2, live, online, v80

        do
          local frame3 = Instance.new("Frame")
          frame3.Size = UDim2.new(1, 0, 0, v78)
          frame3.BackgroundColor3 = tbl21.Header
          frame3.BackgroundTransparency = 1
          frame3.BorderSizePixel = 0
          frame3.Active = true
          frame3.ZIndex = 5
          frame3.Parent = instance
          fn35(frame3, 16)
          frame2 = Instance.new("Frame")
          frame2.Size = UDim2.new(1, 0, 0, 8)
          frame2.Position = UDim2.new(0, 0, 1, -8)
          frame2.BackgroundColor3 = tbl21.Header
          frame2.BackgroundTransparency = 1
          frame2.BorderSizePixel = 0
          frame2.ZIndex = 5
          frame2.Parent = frame3
          local instance2 = Instance.new("Frame")
          instance2.Name = "BrandMark"
          instance2.Size = UDim2.fromOffset(flag15 and 27 or 34, flag15 and 24 or 30)
          instance2.Position = UDim2.fromOffset(flag15 and 13 or 17, flag15 and 11 or 13)
          instance2.BackgroundTransparency = 1
          instance2.BorderSizePixel = 0
          instance2.ClipsDescendants = true
          instance2.ZIndex = 6
          instance2.Parent = frame3
          fn35(instance2, 15)
          local instance3 = Instance.new("Frame")
          instance3.Name = "Content"
          instance3.Size = UDim2.fromScale(1, 1)
          instance3.BackgroundTransparency = 1
          instance3.Image = "rbxassetid://71891923282375"
          instance3.ScaleType = Enum.ScaleType.Fit
          instance3.ZIndex = 7
          instance3.Parent = instance2
          fn35(instance3, 15)
          local v81 = createTextLabel(frame3, "ACE", flag15 and 14 or 18, tbl21.White, Enum.Font.GothamBlack)
          v81.Size = UDim2.new(1, -130, 0, 28)
          v81.Position = UDim2.fromOffset(flag15 and 48 or 56, flag15 and 12 or 14)
          v81.TextYAlignment = Enum.TextYAlignment.Center
          v81.ZIndex = 6
          local frame4 = Instance.new("Frame")
          frame4.Name = "TitleDivider"
          frame4.Size = UDim2.new(1, -28, 0, 1)
          frame4.Position = UDim2.new(0, 17, 1, -2)
          frame4.BackgroundColor3 = tbl21.White
          frame4.BackgroundTransparency = 0.55
          frame4.BorderSizePixel = 0
          frame4.ZIndex = 6
          frame4.Parent = frame3
          local textButton = Instance.new("TextButton")
          textButton.Name = "Close"
          textButton.Size = UDim2.fromOffset(32, 32)
          textButton.Position = UDim2.new(1, -40, 0.5, -16)
          textButton.BackgroundColor3 = tbl21.Card
          textButton.BorderSizePixel = 0
          textButton.Text = ""
          textButton.AutoButtonColor = false
          textButton.ZIndex = 7
          textButton.Parent = frame3
          fn35(textButton, 7)
          createUIStroke2(textButton, tbl21.Border, 1)
          local frame5 = Instance.new("Frame")
          frame5.Name = "Horizontal"
          frame5.AnchorPoint = Vector2.new(0.5, 0.5)
          frame5.Size = UDim2.fromOffset(10, 2)
          frame5.Position = UDim2.fromScale(0.5, 0.5)
          frame5.BackgroundColor3 = tbl21.White
          frame5.BorderSizePixel = 0
          frame5.ZIndex = 8
          frame5.Parent = textButton
          fn35(frame5, 1)
          local frame6 = Instance.new("Frame")
          frame6.Name = "Vertical"
          frame6.AnchorPoint = Vector2.new(0.5, 0.5)
          frame6.Size = UDim2.fromOffset(2, 0)
          frame6.Position = UDim2.fromScale(0.5, 0.5)
          frame6.BackgroundColor3 = tbl21.White
          frame6.BorderSizePixel = 0
          frame6.ZIndex = 8
          frame6.Parent = textButton
          fn35(frame6, 1)
          local v82 = createTextLabel(instance, "discord.gg/aceduels", 8, tbl21.White, Enum.Font.GothamBold)
          v82.Name = "DiscordFooter"
          v82.Size = UDim2.new(1, 0, 0, 14)
          v82.Position = UDim2.new(0, 0, 1, -12)
          v82.TextXAlignment = Enum.TextXAlignment.Center
          v82.TextStrokeColor3 = tbl21.BG
          v82.TextStrokeTransparency = 0.45
          v82.ZIndex = 4
          local flag16 = false
          local position = nil
          local position2 = nil

          frame3.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
              flag16 = true
              position = input.Position
              position2 = instance.Position
            end
          end)

          frame3.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
              flag16 = false
            end
          end)

          service.InputChanged:Connect(function(input)
            if flag16 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
              local n36 = input.Position - position
              instance.Position = UDim2.new(position2.X.Scale, position2.X.Offset + n36.X, position2.Y.Scale, position2.Y.Offset + n36.Y)
            end
          end)

          local n36 = flag15 and 28 or 40
          local instance4 = Instance.new("Frame")
          instance4.Name = "TabsBackdrop"
          instance4.Size = UDim2.new(1, 0, 0, n36)
          instance4.Position = UDim2.new(0, 0, 0, v78 + 4)
          instance4.BackgroundColor3 = Color3.fromRGB(6, 6, 12)
          instance4.BackgroundTransparency = 0
          instance4.BorderSizePixel = 0
          instance4.ClipsDescendants = true
          instance4.ZIndex = 4
          instance4.Parent = instance
          local instance5 = Instance.new("UIListLayout")
          instance5.FillDirection = Enum.FillDirection.Horizontal
          instance5.HorizontalAlignment = Enum.HorizontalAlignment.Left
          instance5.VerticalAlignment = Enum.VerticalAlignment.Center
          instance5.Padding = UDim.new(0, 0)
          instance5.SortOrder = Enum.SortOrder.LayoutOrder
          instance5.Parent = instance4
          local frame7 = Instance.new("Frame")
          frame7.Size = UDim2.new(1, 0, 1, -(v78 + n35 + 6))
          frame7.Position = UDim2.new(0, 0, 0, v78 + n35 + 4)
          frame7.BackgroundTransparency = 1
          frame7.ClipsDescendants = true
          frame7.Parent = instance

          local function fn41(parent)
            local instance6 = Instance.new("ScrollingFrame")
            instance6.Size = UDim2.fromScale(1, 1)
            instance6.BackgroundTransparency = 1
            instance6.BorderSizePixel = 0
            instance6.ScrollBarThickness = 3
            instance6.ScrollBarImageColor3 = Color3.fromRGB(150, 75, 150)
            instance6.AutomaticCanvasSize = Enum.AutomaticSize.Y
            instance6.CanvasSize = UDim2.new()
            instance6.ScrollingDirection = Enum.ScrollingDirection.Y
            instance6.Parent = parent
            local instance7 = Instance.new("UIListLayout")
            instance7.FillDirection = Enum.FillDirection.Vertical
            instance7.HorizontalAlignment = Enum.HorizontalAlignment.Center
            instance7.Padding = UDim.new(0, 6)
            instance7.SortOrder = Enum.SortOrder.LayoutOrder
            instance7.Parent = instance6
            createUIPadding(instance6, 8, 10, 8, 8)
            return instance6
          end

          local tbl23 = {}
          local v83 = nil
          local flag17 = false

          local function fn42(arg)
            for i, v84 in ipairs(tbl23) do
              if v84 == arg then
                return i
              end
            end

            return 1
          end

          local function fn43(arg, arg2)
            fn34(arg.Button, tweenInfo, { BackgroundColor3 = arg2 and Color3.fromRGB(18, 18, 24) or Color3.fromRGB(12, 8, 11) })
            fn34(arg.Label, tweenInfo, { TextColor3 = arg2 and tbl21.White or tbl21.TabInact })
          end

          local function fn44(arg)
            if v83 == arg or flag17 then
              return
            end
            local v84 = v83
            v83 = arg

            if v84 then
              fn43(v84, false)
            end

            fn43(arg, true)
            if not v84 then
              arg.Page.Visible = true
              return
            end
            flag17 = true
            local n37 = fn42(arg) > fn42(v84) and 1 or -1
            local n38 = math.max(frame7.AbsoluteSize.X, n33)
            arg.Page.Position = UDim2.fromOffset(n37 * n38, 0)
            arg.Page.Visible = true
            fn34(v84.Page, tweenInfo3, { Position = UDim2.fromOffset(-n37 * n38, 0) })
            local tween = TweenService2:Create(arg.Page, tweenInfo3, { Position = UDim2.new() })
            tween:Play()

            tween.Completed:Connect(function()
              v84.Page.Visible = false
              v84.Page.Position = UDim2.new()
              flag17 = false
              return
            end)
          end

          local function fn45(name, layoutOrder)
            local textButton2 = Instance.new("TextButton")
            textButton2.Name = name
            textButton2.LayoutOrder = layoutOrder
            textButton2.Size = UDim2.new(0.33333333333333331, 0, 1, 0)
            textButton2.BackgroundColor3 = Color3.fromRGB(8, 8, 11)
            textButton2.BackgroundTransparency = 0
            textButton2.BorderSizePixel = 0
            textButton2.Text = ""
            textButton2.AutoButtonColor = false
            textButton2.ZIndex = 5
            textButton2.Parent = instance4

            if layoutOrder > 1 then
              local frame8 = Instance.new("Frame")
              frame8.Size = UDim2.new(0, 1, 1, -10)
              frame8.Position = UDim2.new(0, 0, 0, 5)
              frame8.BackgroundColor3 = Color3.fromRGB(88, 90, 98)
              frame8.BackgroundTransparency = 0.55
              frame8.BorderSizePixel = 0
              frame8.ZIndex = 6
              frame8.Parent = textButton2
            end

            local v84 = createTextLabel(textButton2, name, flag15 and 9 or 10, tbl21.TabInact, Enum.Font.GothamBold)
            v84.Size = UDim2.fromScale(1, 1)
            v84.TextXAlignment = Enum.TextXAlignment.Center
            v84.TextYAlignment = Enum.TextYAlignment.Center
            v84.ZIndex = 6
            local instance6 = Instance.new("Frame")
            instance6.Size = UDim2.fromScale(1, 1)
            instance6.BackgroundTransparency = 1
            instance6.Visible = false
            instance6.ClipsDescendants = true
            instance6.Parent = frame7
            local tbl24 = { Button = textButton2, Label = v84, Page = instance6, Scroll = fn41(instance6) }
            table.insert(tbl23, tbl24)

            textButton2.MouseEnter:Connect(function()
              if v83 ~= tbl24 then
                fn34(textButton2, tweenInfo, { BackgroundColor3 = Color3.fromRGB(13, 13, 17) })
                fn34(v84, tweenInfo, { TextColor3 = Color3.fromRGB(196, 190, 200) })
              end
            end)

            textButton2.MouseLeave:Connect(function()
              if v83 ~= tbl24 then
                fn43(tbl24, false)
              end
            end)

            textButton2.MouseButton1Click:Connect(function()
              fn44(tbl24)
            end)

            return tbl24
          end

          live = fn45("LIVE", 1)
          online = fn45("ONLINE", 2)
          v80 = fn45("SETTINGS", 3)
          fn44(live)
          local flag18 = false
          local flag19 = false
          local tweenInfo4 = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

          textButton.MouseButton1Click:Connect(function()
            local aceSniperBarDock = genv3.ACESniperBarDock

            if type(aceSniperBarDock) == "function" then
              task.spawn(function()
                local v84 = setthreadidentity or setidentity

                if v84 then
                  pcall(v84, 8)
                end

                pcall(aceSniperBarDock, "show")
              end)

              return
            end

            if flag19 then
              return
            end
            flag19 = true
            flag18 = not flag18

            if flag18 then
              frame7.Visible = false
              instance4.Visible = false
              frame2.Visible = false
              v82.Visible = false
              fn34(frame6, tweenInfo4, { Size = UDim2.fromOffset(2, 10) })
              local tween = TweenService2:Create(instance, tweenInfo4, { Size = UDim2.fromOffset(n33, v78) })
              tween:Play()

              tween.Completed:Connect(function()
                flag19 = false
              end)
            else
              fn34(frame6, tweenInfo4, { Size = UDim2.fromOffset(2, 0) })
              local tween = TweenService2:Create(instance, tweenInfo4, { Size = UDim2.fromOffset(n33, n34) })
              tween:Play()

              tween.Completed:Connect(function()
                frame2.Visible = true
                instance4.Visible = true
                frame7.Visible = true
                v82.Visible = true
                flag19 = false
              end)
            end
          end)
        end

        local fn41

        fn41 = function(parent, arg, layoutOrder)
          local instance2 = Instance.new("Frame")
          instance2.Size = UDim2.new(1, -12, 0, 26)
          instance2.BackgroundTransparency = 1
          instance2.LayoutOrder = layoutOrder or 0
          instance2.Parent = parent
          local frame3 = Instance.new("Frame")
          frame3.Size = UDim2.new(1, 0, 0, 1)
          frame3.Position = UDim2.new(0, 0, 0.5, 0)
          frame3.BackgroundColor3 = tbl21.Border
          frame3.BorderSizePixel = 0
          frame3.Parent = instance2
          local frame4 = Instance.new("Frame")
          frame4.Size = UDim2.fromOffset(#arg * 7 + 18, 18)
          frame4.Position = UDim2.new(0, 10, 0.5, -9)
          frame4.BackgroundColor3 = tbl21.BG
          frame4.BackgroundTransparency = 0
          frame4.BorderSizePixel = 0
          frame4.ZIndex = 2
          frame4.Parent = instance2
          fn35(frame4, 6)
          local v81 = createTextLabel(frame4, arg, 10, tbl21.Dim, Enum.Font.GothamBold)
          v81.Size = UDim2.fromScale(1, 1)
          v81.TextXAlignment = Enum.TextXAlignment.Center
          v81.ZIndex = 3
          return instance2
        end

        local sendTrade, sendDuel, tbl23, fn42, tbl24, tbl25, v81, v82

        do
          local function fn43(arg, arg2)
            arg.MouseEnter:Connect(function()
              fn34(arg, tweenInfo, { BackgroundColor3 = Color3.fromRGB(14, 14, 18) })
              fn34(arg2, tweenInfo, { Color = Color3.fromRGB(150, 96, 164) })
            end)

            arg.MouseLeave:Connect(function()
              fn34(arg, tweenInfo, { BackgroundColor3 = tbl21.Card })
              fn34(arg2, tweenInfo, { Color = tbl21.Border })
            end)
          end

          local tbl26 = nil
          aceFinderRuntime.TradeCooldownSeconds = 26
          aceFinderRuntime.DuelCooldownSeconds = 20
          finderUISettingsState.LastTradeInviteAt = tonumber(finderUISettingsState.LastTradeInviteAt) or -math.huge
          finderUISettingsState.LastDuelInviteAt = tonumber(finderUISettingsState.LastDuelInviteAt) or -math.huge

          local function fn44(arg)
            if type(arg) ~= "string" or not arg:lower():find("cooldown", 1, true) then
              return nil
            end
            return tonumber(arg:match("[%d%.]+"))
          end

          local function fn45(arg, arg2)
            local v83 = "function"
            arg = type(arg) == v83 and arg or "REJECTED"
            local num = fn44(arg)
            local str8 = arg:lower()

            if str8:find("pending trade", 1, true) or str8:find("pending duel", 1, true) or str8:find("pending request", 1, true) then
              num = tonumber(arg2)
            end

            if num then
              local v84 = "s"
              return "COOLDOWN " .. tostring(math.ceil(num)) .. v84, num
            end
            return arg, nil
          end

          local function fn46(arg)
            aceFinderRuntime.LastActionMessage = tostring(arg or "ACTION")
          end

          sendTrade = function(arg, arg2)
            local fn47 = arg2 or function() end

            if type(arg) ~= "number" or arg == localPlayer2.UserId then
              fn47(false, "ERROR")
              return
            end
            local lastTradeInviteAt = finderUISettingsState.LastTradeInviteAt
            local n36 = 26 - os.clock() - lastTradeInviteAt
            if 0 < n36 then
              fn47(false, "COOLDOWN " .. tostring(math.ceil(n36)) .. "s", n36)
              return
            end
            finderUISettingsState.LastTradeInviteAt = os.clock()

            task.spawn(function()
              if v76 and type(v76.SendInvite) == "function" then
                local flag16 = false

                local ok, result, result2 = pcall(function()
                  return v76:SendInvite(arg, function(arg3, arg4)
                    if flag16 then
                      return
                    end
                    flag16 = true

                    if arg3 == true then
                      fn47(true, arg4)
                      fn46("TRADE INVITE SENT")
                    else
                      local v83, v84 = fn45(arg4, 26)
                      fn47(false, v83, v84)
                      fn46(v83)
                    end
                  end)
                end)

                if not ok then
                  fn47(false, "ERROR")
                  fn46("TRADE INVITE ERROR")
                  return
                end

                if result == false then
                  flag16 = true
                  local v83, v84 = fn45(result2, 26)
                  fn47(false, v83, v84)
                  fn46(v83)
                  return
                end

                task.delay(15, function()
                  if flag16 or not aceFinderRuntime.Running then
                    return
                  end
                  flag16 = true
                  fn47(false, "TIMED OUT")
                  fn46("TRADE INVITE TIMED OUT")
                end)

                return
              end

              if not remotes.Invite then
                fn47(false, "NO REMOTE")
                return
              end

              local ok, result, result2 = pcall(function()
                return remotes.Invite:InvokeServer(str7, arg)
              end)

              if not ok then
                fn47(false, "ERROR")
                fn46("TRADE INVITE ERROR")
              elseif result == false then
                local v83, v84 = fn45(result2, 26)
                fn47(false, v83, v84)
                fn46(v83)
              else
                fn47(true)
                fn46("TRADE INVITE SENT")
              end
            end)
          end

          sendDuel = function(arg, arg2)
            local fn47 = arg2 or function() end

            local v83 = "number"
            if type(arg) ~= v83 or arg == localPlayer2.UserId then
              fn47(false, "ERROR")
              return
            end
            local lastDuelInviteAt = finderUISettingsState.LastDuelInviteAt
            local n36 = aceFinderRuntime.DuelCooldownSeconds - os.clock() - lastDuelInviteAt

            if 0 < n36 then
              local v84 = "s"
              fn47(false, "COOLDOWN " .. tostring(math.ceil(n36)) .. v84, n36)
              return
            end

            if not v77 or type(v77.SendInvite) ~= "function" then
              fn47(false, "TRADE UNAVAILABLE")
              return
            end

            if type(v77.IsEnabled) == "function" then
              local ok, result = pcall(function()
                return v77:IsEnabled()
              end)

              if ok and not result then
                fn47(false, "INVITES DISABLED")
                return
              end
            end

            finderUISettingsState.LastDuelInviteAt = os.clock()

            task.spawn(function()
              local ok, result, result2 = pcall(function()
                return v77:SendInvite(arg)
              end)

              if not ok then
                fn47(false, "ERROR")
                fn46("DUEL INVITE ERROR")
              elseif result == false then
                local v84, v85 = fn45(result2, aceFinderRuntime.DuelCooldownSeconds)
                fn47(false, v84, v85)
                fn46(v84)
              else
                fn47(true)
                fn46("DUEL INVITE SENT")
              end
            end)
          end

          local tbl27 = {
            { Label = "S.ELEPH", Model = "Strawberry Elephant", Match = { "strawberryelephant" } },
            { Label = "MEOWL", Model = "Meowl", Match = { "meowl" } },
            { Label = "SKIBIDI", Model = "Skibidi Toilet", Match = { "skibiditoilet", "skibidi" } },
            { Label = "J.PORK", Model = "John Pork", Match = { "johnpork" } },
          }

          tbl23 = {}

          if type(v75) == "table" then
            for k, v83 in pairs(v75) do
              local flag16 = type(k) == "string" and type(v83) == "table"

              if flag16 then
                flag16 = string.upper(tostring(v83.Rarity or v83.rarity or "")) == "OG"
              end

              if flag16 then
                tbl23[fn37(k)] = true

                if type(v83.DisplayName) == "string" then
                  local v84 = true
                  tbl23[fn37(v83.DisplayName)] = v84
                end
              end
            end
          end

          for _, v83 in ipairs(tbl27) do
            local v84 = ipairs
            local match = v83.Match or {}

            for _, v85 in v84(match) do
              local v86 = true
              tbl23[fn37(v85)] = v86
            end

            if v83.Model then
              tbl23[fn37(v83.Model)] = true
            end
          end

          local color = Color3.fromRGB(244, 242, 246)
          local photoBG = tbl21.PhotoBG
          local color2 = Color3.fromRGB(8, 8, 10)
          local photoBG2 = tbl21.PhotoBG
          local photoBG3 = tbl21.PhotoBG
          local color3 = Color3.fromRGB(70, 54, 62)
          aceFinderRuntime.FilterRefreshers = {}
          aceFinderRuntime.OGModeVisualRefreshers = {}

          aceFinderRuntime.RefreshFilters = function()
            for _, filterRefresher in ipairs(aceFinderRuntime.FilterRefreshers) do
              pcall(filterRefresher)
            end
          end

          aceFinderRuntime.RefreshOGModeVisuals = function(arg)
            for _, ogModeVisualRefresher in ipairs(aceFinderRuntime.OGModeVisualRefreshers) do
              pcall(ogModeVisualRefresher, arg == true)
            end
          end

          aceFinderRuntime.SetOGOnlyEnabled = function(arg, arg2)
            finderUISettingsState.OGOnlyEnabled = arg == true
            aceFinderRuntime.RefreshOGModeVisuals(arg2)
            aceFinderRuntime.RefreshFilters()
          end

          local function fn47(parent, arg, arg2)
            local frame3 = Instance.new("Frame")
            local n36 = flag15 and 34 or 38
            local n37 = flag15 and 46 or 50
            local n38 = n36 + 6 + n37
            frame3.Size = UDim2.new(1, -12, 0, n38)
            frame3.BackgroundTransparency = 1
            frame3.BorderSizePixel = 0
            frame3.LayoutOrder = -1
            frame3.Parent = parent
            local frame4 = Instance.new("Frame")
            frame4.Name = "Header"
            frame4.Size = UDim2.new(1, 0, 0, n36)
            frame4.BackgroundColor3 = tbl21.PhotoBG
            frame4.BorderSizePixel = 0
            frame4.Parent = frame3
            fn35(frame4, 10)
            createUIStroke2(frame4, Color3.fromRGB(48, 50, 58), 1, 0.25)
            local frame5 = Instance.new("Frame")
            frame5.Name = "BrainrotWheel"
            frame5.Size = UDim2.new(1, 0, 0, n37)
            frame5.Position = UDim2.fromOffset(0, n36 + 6)
            frame5.BackgroundColor3 = tbl21.PhotoBG
            frame5.BorderSizePixel = 0
            frame5.Parent = frame3
            fn35(frame5, 8)
            local scrollingFrame = Instance.new("ScrollingFrame")
            scrollingFrame.Size = UDim2.fromScale(1, 1)
            scrollingFrame.BackgroundTransparency = 1
            scrollingFrame.BorderSizePixel = 0
            scrollingFrame.ScrollBarThickness = 0
            scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
            scrollingFrame.CanvasSize = UDim2.new()
            scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
            scrollingFrame.Active = true
            scrollingFrame.Parent = frame5
            table.insert(tbl18, scrollingFrame)

            scrollingFrame.Destroying:Connect(function()
              local v83 = table.find(tbl18, scrollingFrame)

              if v83 then
                table.remove(tbl18, v83)
              end
            end)

            local tbl28 = {}
            local flag16 = false
            local scrollingEnabled = true
            local flag17 = false

            local function fn48()
              if not parent:IsA("ScrollingFrame") or not parent.Parent then
                return
              end
              local flag18 = flag16 or next(tbl28) ~= nil

              if flag18 and not flag17 then
                scrollingEnabled = parent.ScrollingEnabled
                parent.ScrollingEnabled = false
                flag17 = true
              elseif not flag18 and flag17 then
                parent.ScrollingEnabled = scrollingEnabled
                flag17 = false
              end
            end

            local function fn49(arg3)
              flag16 = arg3 == true
              scrollingFrame:SetAttribute("Collapsed", flag16)
              fn48()
            end

            local connection = service.InputChanged:Connect(function(input)
              if input.UserInputType ~= Enum.UserInputType.MouseMovement then
                return
              end
              local parent2 = frame3
              local flag18

              while true do
                flag18 = true

                if parent2 then
                  if parent2:IsA("GuiObject") and not parent2.Visible then
                    flag18 = false
                    break
                  elseif parent2:IsA("LayerCollector") then
                    flag18 = parent2.Enabled
                    break
                  else
                    parent2 = parent2.Parent
                  end
                else
                  break
                end
              end

              local value = select(1, GuiService:GetGuiInset())
              local n39 = service:GetMouseLocation() - value
              local absolutePosition = frame3.AbsolutePosition
              local absoluteSize = frame3.AbsoluteSize
              fn49(
                flag18
                  and n39.X >= absolutePosition.X
                  and n39.X <= absolutePosition.X + absoluteSize.X
                  and n39.Y >= absolutePosition.Y
                  and n39.Y <= absolutePosition.Y + absoluteSize.Y
              )
            end)

            frame3.MouseEnter:Connect(function()
              fn49(true)
            end)

            frame3.MouseLeave:Connect(function()
              fn49(false)
            end)

            local function fn50(input)
              if input.UserInputType ~= Enum.UserInputType.Touch or tbl28[input] then
                return
              end

              tbl28[input] = true
              fn48()
            end

            local connection2 = service.InputEnded:Connect(function(input)
              if not tbl28[input] then
                return
              end
              tbl28[input] = nil
              fn48()
            end)

            scrollingFrame.InputBegan:Connect(fn50)

            scrollingFrame.Destroying:Connect(function()
              connection2:Disconnect()
              connection:Disconnect()

              if flag17 and parent:IsA("ScrollingFrame") and parent.Parent then
                parent.ScrollingEnabled = scrollingEnabled
                flag17 = false
              end
            end)

            local uiListLayout = Instance.new("UIListLayout")
            uiListLayout.FillDirection = Enum.FillDirection.Horizontal
            uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            uiListLayout.Padding = UDim.new(0, 6)
            uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            uiListLayout.Parent = scrollingFrame
            local tbl29 = {}
            local tbl30 = {}
            local str8 = ""
            local flag18 = true
            local visible = true
            local fn51 = nil
            local v83 = createTextLabel(
              parent,
              arg2 == "ONLINE" and "No matching online owners" or "Waiting for OG spawns...",
              flag15 and 10 or 11,
              tbl21.Dim,
              Enum.Font.GothamMedium
            )
            v83.Name = tostring(arg2 or "LIVE") .. "Empty"
            v83.Size = UDim2.new(1, -12, 0, 54)
            v83.LayoutOrder = 1000000
            v83.TextXAlignment = Enum.TextXAlignment.Center
            v83.TextYAlignment = Enum.TextYAlignment.Center
            v83.Visible = true
            local v84 = flag15 and 72 or 84
            local n39 = flag15 and 54 or 64
            local n40 = n36 - 8

            local function fn52(name, text, arg3)
              local instance2 = Instance.new("TextButton")
              instance2.Name = name
              instance2.Size = UDim2.fromOffset(arg3, n40)
              instance2.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
              instance2.BorderSizePixel = 0
              instance2.Text = text
              instance2.TextSize = flag15 and 6 or 8
              instance2.TextColor3 = tbl21.White
              instance2.Font = Enum.Font.GothamBold
              instance2.AutoButtonColor = false
              instance2.Parent = frame4
              fn35(instance2, 6)
              createUIStroke2(instance2, Color3.fromRGB(66, 68, 78), 1, 0.25)
              return instance2
            end

            local RarityMode = fn52("RarityMode", "RARITY", v84)
            RarityMode.Position = UDim2.fromOffset(5, 4)
            local CollapseFilters = fn52("CollapseFilters", "-", 30)
            CollapseFilters.Position = UDim2.new(1, -35, 0, 4)
            CollapseFilters.TextSize = flag15 and 12 or 14
            local v85 = fn52("SortMode", "SORT", n39)
            v85.Position = UDim2.new(1, -(40 + n39), 0, 4)
            local textBox = Instance.new("TextBox")
            textBox.Name = "SpawnSearch"
            textBox.Size = UDim2.new(1, -(10 + v84 + n39 + 30 + 15), 0, n40)
            textBox.Position = UDim2.fromOffset(5 + v84 + 5, 4)
            textBox.BackgroundColor3 = Color3.fromRGB(16, 12, 15)
            textBox.BorderSizePixel = 0
            textBox.ClearTextOnFocus = false
            textBox.PlaceholderText = "SEARCH"
            textBox.PlaceholderColor3 = Color3.fromRGB(108, 110, 120)
            textBox.Text = ""
            textBox.TextColor3 = tbl21.White
            textBox.TextSize = flag15 and 8 or 9
            textBox.Font = Enum.Font.GothamMedium
            textBox.TextXAlignment = Enum.TextXAlignment.Left
            textBox.Parent = frame4
            fn35(textBox, 6)
            createUIStroke2(textBox, Color3.fromRGB(66, 68, 78), 1, 0.25)
            local instance2 = Instance.new("UIPadding")
            instance2.PaddingLeft = UDim.new(0, 9)
            instance2.PaddingRight = UDim.new(0, 7)
            instance2.Parent = textBox

            local function fn53(arg3)
              local ogOnlyEnabled = finderUISettingsState.OGOnlyEnabled
              RarityMode.Text = ogOnlyEnabled and "OG ONLY" or "ALL"

              local tbl31 = {
                BackgroundColor3 = ogOnlyEnabled and tbl21.White or Color3.fromRGB(18, 18, 22),
                TextColor3 = ogOnlyEnabled and tbl21.BG or tbl21.White,
              }

              if arg3 then
                fn34(RarityMode, tweenInfo, tbl31)
              else
                for k, v86 in pairs(tbl31) do
                  RarityMode[k] = v86
                end
              end
            end

            table.insert(aceFinderRuntime.OGModeVisualRefreshers, fn53)
            fn53(false)

            RarityMode.MouseButton1Click:Connect(function()
              aceFinderRuntime.SetOGOnlyEnabled(not finderUISettingsState.OGOnlyEnabled, true)
            end)

            v85.MouseButton1Click:Connect(function()
              flag18 = not flag18
              v85.Text = flag18 and "NEWEST" or "OLDEST"

              if fn51 then
                fn51()
              end
            end)

            CollapseFilters.MouseButton1Click:Connect(function()
              visible = not visible
              frame5.Visible = visible
              CollapseFilters.Text = visible and "-" or "+"
              fn34(frame3, tweenInfo2, { Size = UDim2.new(1, -12, 0, visible and n38 or n36) })
            end)

            textBox:GetPropertyChangedSignal("Text"):Connect(function()
              str8 = fn37(textBox.Text)

              if fn51 then
                fn51()
              end
            end)

            fn51 = function()
              local flag19 = false

              for _, v86 in pairs(tbl30) do
                if v86 then
                  flag19 = true
                  break
                end
              end

              local n41 = 0

              for _, v86 in ipairs(arg) do
                local v87 = fn37(v86:GetAttribute("OwnerUsername") or "")
                local v88 = fn37(v86:GetAttribute("OwnerDisplayName") or "")
                local num = tonumber(v86:GetAttribute("Income")) or 0
                v86.LayoutOrder = flag18 and -num or num
                local flag20 = not finderUISettingsState.OGOnlyEnabled or v86:GetAttribute("IsOG") == true
                local flag21 = str8 == "" or v87:find(str8, 1, true) ~= nil or v88:find(str8, 1, true) ~= nil
                local flag22 = flag20 and flag21 and not flag19
                local v89

                if flag20 and flag21 and flag19 then
                  for k, v90 in pairs(tbl30) do
                    if v90 then
                      local v91 = ipairs
                      local match = tbl27[k].Match or {}

                      for _, v92 in v91(match) do
                        if v87 == fn37(v92) then
                          flag22 = true
                          break
                        end
                      end
                    end

                    if not flag22 then
                      continue
                    end
                    break
                  end

                  v89 = flag22
                else
                  v89 = flag22
                end

                v86.Visible = v89

                if v89 then
                  n41 += 1
                end
              end

              v83.Visible = n41 == 0

              if str8 ~= "" or flag19 then
                v83.Text = "No matching spawns"
              elseif arg2 == "ONLINE" then
                v83.Text = finderUISettingsState.OGOnlyEnabled and "No online OG owners" or "No online owners"
              else
                v83.Text = finderUISettingsState.OGOnlyEnabled and "Waiting for OG spawns..." or "Waiting for live spawns..."
              end
            end

            local function fn54(arg3, arg4)
              fn34(arg3.Button, tweenInfo, { BackgroundColor3 = arg4 and color or photoBG2 })
              fn34(arg3.Stroke, tweenInfo, { Color = arg4 and Color3.fromRGB(255, 255, 255) or color3 })
              fn34(arg3.Text, tweenInfo, { TextColor3 = arg4 and color2 or tbl21.Dim })
              fn34(arg3.IconBack, tweenInfo, { BackgroundColor3 = arg4 and photoBG or photoBG3 })
            end

            local function fn55(arg3)
              tbl30[arg3] = not tbl30[arg3]

              for i, v86 in ipairs(tbl29) do
                fn54(v86, tbl30[i] == true)
              end

              fn51()
            end

            for i, v86 in ipairs(tbl27) do
              local textButton = Instance.new("TextButton")
              textButton.LayoutOrder = i
              textButton.Size = UDim2.fromOffset(flag15 and 92 or 112, flag15 and 34 or 42)
              textButton.BackgroundColor3 = photoBG2
              textButton.BorderSizePixel = 0
              textButton.Text = ""
              textButton.AutoButtonColor = false
              textButton.Parent = scrollingFrame
              textButton.InputBegan:Connect(fn50)
              fn35(textButton, 8)
              local v87 = createUIStroke2(textButton, color3, 1, 0)
              local n41 = flag15 and 34 or 38
              local frame6 = Instance.new("Frame")
              frame6.Size = UDim2.fromOffset(n41, n41)
              frame6.Position = UDim2.new(0, 10, 0.5, -(n41 / 2))
              frame6.BackgroundColor3 = photoBG3
              frame6.BorderSizePixel = 0
              frame6.Parent = textButton
              fn35(frame6, 10)
              local frame7 = Instance.new("Frame")
              frame7.Size = UDim2.new(1, -2, 1, -2)
              frame7.Position = UDim2.fromOffset(1, 1)
              frame7.BackgroundTransparency = 1
              frame7.Parent = frame6
              createViewportFrame(frame7, v86.Model, string.sub(v86.Label, 1, 1), nil, "baseidle")
              local v88 = createTextLabel(textButton, v86.Label, flag15 and 8 or 10, tbl21.Dim, Enum.Font.GothamBold)
              v88.Size = UDim2.new(1, -(flag15 and 46 or 52), 1, 0)
              v88.Position = UDim2.fromOffset(flag15 and 42 or 49, 0)
              v88.TextYAlignment = Enum.TextYAlignment.Center
              v88.TextTruncate = Enum.TextTruncate.AtEnd
              local tbl31 = { Button = textButton, Stroke = v87, Text = v88, IconBack = frame6 }
              table.insert(tbl29, tbl31)

              textButton.MouseEnter:Connect(function()
                if not tbl30[i] then
                  fn34(textButton, tweenInfo, { BackgroundColor3 = Color3.fromRGB(26, 26, 34) })
                  fn34(v87, tweenInfo, { Color = Color3.fromRGB(128, 130, 140) })
                  fn34(v88, tweenInfo, { TextColor3 = Color3.fromRGB(232, 232, 236) })
                end
              end)

              textButton.MouseLeave:Connect(function()
                if not tbl30[i] then
                  fn54(tbl31, false)
                end
              end)

              textButton.MouseButton1Click:Connect(function()
                fn55(i)
              end)
            end

            table.insert(aceFinderRuntime.FilterRefreshers, fn51)
            fn51()
            return frame3, fn51
          end

          fn42 = function(parent, arg, arg2, arg3, arg4, arg5)
            local tbl28 = arg5 or {}
            local num = tonumber(tbl28.OwnerUserId)
            local v83 = "function"
            local flag16 = type(arg2) == v83 and arg2 ~= "" and arg2 or nil
            local instance2 = Instance.new("Frame")
            instance2.Size = UDim2.new(1, -16, 0, flag15 and 84 or 88)
            instance2.BackgroundColor3 = tbl21.Card
            instance2.BackgroundTransparency = 0.38
            instance2.BorderSizePixel = 0
            instance2.Parent = parent
            fn35(instance2, 14)
            local v84 = createUIStroke2(instance2, Color3.fromRGB(108, 110, 120), 1)
            fn43(instance2, v84)
            instance2.BackgroundTransparency = 1
            v84.Transparency = 1

            task.defer(function()
              if instance2.Parent then
                local n36 = instance2:GetAttribute("Expired") == true and 0.52 or 0.38
                instance2.BackgroundTransparency = 1
                fn34(instance2, tweenInfo2, { BackgroundTransparency = n36 })
                fn34(v84, tweenInfo2, { Transparency = 0 })
              end
            end)

            local frame3 = Instance.new("Frame")
            frame3.Size = UDim2.new(1, -6, 1, -6)
            frame3.Position = UDim2.fromOffset(3, 3)
            frame3.BackgroundTransparency = 1
            frame3.BorderSizePixel = 0
            frame3.Parent = instance2
            fn35(frame3, 10)
            local n36 = flag15 and 72 or 82
            local n37 = flag15 and 17 or 19
            local n38 = n37 * 3 + 8
            local instance3 = Instance.new("Frame")
            instance3.Size = UDim2.fromOffset(n38, n38)
            instance3.Position = UDim2.new(1, -(n36 + n38 + 16), 0, 9)
            instance3.BackgroundColor3 = tbl21.PhotoBG
            instance3.BorderSizePixel = 0
            instance3.Parent = frame3
            fn35(instance3, 12)
            local instance4 = Instance.new("Frame")
            instance4.Size = UDim2.new(1, -6, 1, -6)
            instance4.Position = UDim2.fromOffset(3, 3)
            instance4.BackgroundTransparency = 1
            instance4.Parent = instance3
            fn39(instance4, { UID = tbl28.UID, BrainrotName = arg3, Mutation = arg4 }, string.sub(arg3 or "?", 1, 1))
            local v85 = createTextLabel(instance3, "0:00", flag15 and 8 or 9, tbl21.White, Enum.Font.GothamBlack)
            v85.Name = "SpawnAge"
            v85.Size = UDim2.new(1, -6, 0, 14)
            v85.AnchorPoint = Vector2.new(0.5, 0)
            v85.Position = UDim2.new(0.5, 0, 0, 2)
            v85.BackgroundColor3 = Color3.fromRGB(4, 4, 6)
            v85.BackgroundTransparency = 0.12
            v85.TextXAlignment = Enum.TextXAlignment.Center
            v85.TextYAlignment = Enum.TextYAlignment.Center
            v85.ZIndex = 6
            fn35(v85, 6)

            local function fn48(text, arg6, backgroundColor3, arg7, textColor3)
              local instance5 = Instance.new("TextButton")
              instance5.Size = UDim2.fromOffset(n36, n37)
              instance5.Position = UDim2.new(1, -(n36 + 10), 0, arg6)
              instance5.BackgroundColor3 = backgroundColor3
              instance5.BorderSizePixel = 0
              instance5.Text = text
              instance5.TextSize = flag15 and 12 or 10
              instance5.Font = Enum.Font.GothamBold
              instance5.TextColor3 = textColor3 or tbl21.White
              instance5.AutoButtonColor = false
              instance5.Parent = frame3
              fn35(instance5, 6)
              return instance5, (createUIStroke2(instance5, arg7, 1, 0))
            end

            local white = tbl21.White
            local trade, v86 = fn48("TRADE", 9, Color3.fromRGB(20, 20, 32), Color3.fromRGB(84, 86, 96), white)
            local white2 = tbl21.White
            local autoTrade, v87 = fn48("AUTO TRADE", 9 + n37 + 4, Color3.fromRGB(170, 50, 50), Color3.fromRGB(220, 95, 95), white2)
            local white3 = tbl21.White
            local duel, v88 = fn48("DUEL", 9 + (n37 + 6) * 2, Color3.fromRGB(28, 20, 24), Color3.fromRGB(84, 86, 96), white3)
            local n39 = n38 + n36 + 30
            local v89 = createTextLabel(frame3, arg3, flag15 and 11 or 13, tbl21.White, Enum.Font.GothamBold)
            v89.Size = UDim2.new(1, -(16 + n39), 0, 16)
            v89.Position = UDim2.fromOffset(16, 9)
            v89.TextTruncate = Enum.TextTruncate.AtEnd
            local frame4 = Instance.new("Frame")
            frame4.Size = UDim2.fromOffset(7, 7)
            frame4.Position = UDim2.fromOffset(16, 29)
            frame4.BackgroundColor3 = num and Color3.fromRGB(92, 96, 108) or Color3.fromRGB(110, 112, 128)
            frame4.BorderSizePixel = 0
            frame4.Parent = frame3
            fn35(frame4, 4)
            local v90 = createTextLabel
            local str8 = flag16 and "@" .. flag16 or "@unclaimed"
            local n40 = flag15 and 10 or 10
            local gotham = Enum.Font.Gotham
            local v91 = v90(frame3, str8, n40, Color3.fromRGB(200, 158, 175), gotham)
            v91.Size = UDim2.new(1, -(16 + n39 + 8), 0, 14)
            v91.Position = UDim2.fromOffset(27, 8)
            v91.TextTruncate = Enum.TextTruncate.AtEnd
            local textButton = Instance.new("TextButton")
            textButton.Size = UDim2.fromOffset(flag15 and 76 or 88, flag15 and 16 or 17)
            textButton.Position = UDim2.fromOffset(16, 8)
            textButton.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
            textButton.BorderSizePixel = 0
            textButton.Text = "COPY USERNAME"
            textButton.TextSize = flag15 and 7 or 7
            textButton.Font = Enum.Font.GothamBold
            textButton.TextColor3 = tbl21.White
            textButton.AutoButtonColor = false
            textButton.Parent = frame3
            fn35(textButton, 8)
            local v92 = 1
            local v93 = createUIStroke2(textButton, Color3.fromRGB(72, 74, 84), v92, 0)
            local unclaimed = createTextLabel(frame3, "UNCLAIMED", flag15 and 7 or 8, tbl21.Dim, Enum.Font.GothamBold)
            unclaimed.Name = "OwnerStatus"
            unclaimed.Size = UDim2.fromOffset(flag15 and 58 or 66, flag15 and 16 or 16)
            unclaimed.Position = UDim2.fromOffset(16 + (flag15 and 74 or 94), 49)
            unclaimed.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
            unclaimed.BackgroundTransparency = 0.08
            unclaimed.TextXAlignment = Enum.TextXAlignment.Center
            unclaimed.TextYAlignment = Enum.TextYAlignment.Center
            fn35(unclaimed, 8)
            local v94 = 1
            createUIStroke2(unclaimed, Color3.fromRGB(64, 40, 44), v94, 0.25)
            local flag17 = false
            local n41 = 0
            local fn49 = nil

            local function fn50(arg6)
              local flag18 = flag17 and not num
              local color4 = arg6 and Color3.fromRGB(52, 64, 120) or Color3.fromRGB(70, 210, 100)
              local color5 = arg6 and Color3.fromRGB(190, 62, 62) or Color3.fromRGB(170, 50, 50)
              local color6 = arg6 and Color3.fromRGB(140, 255, 150) or Color3.fromRGB(110, 240, 150)
              local color7 = arg6 and Color3.fromRGB(200, 120, 120) or Color3.fromRGB(220, 95, 95)
              local color8 = arg6 and Color3.fromRGB(204, 160, 58) or Color3.fromRGB(182, 140, 60)
              arg6 = arg6 and Color3.fromRGB(255, 240, 126) or Color3.fromRGB(239, 193, 91)
              local v95 = fn34
              local tbl29 = {}
              color8 = flag18 and color8

              if color8 then
                color4 = color8
              else
                local v96 = flag17

                if not flag17 then
                  color4 = v96
                end

                color4 = color4 or color5
              end

              tbl29.BackgroundColor3 = color4
              v95(autoTrade, tweenInfo2, tbl29)
              fn34(v87, tweenInfo2, { Color = flag18 and arg6 or flag17 and color6 or color7 })
              autoTrade.Text = flag18 and "WAITING" or flag17 and "AUTO: ON" or "AUTO: OFF"
            end

            local function fn51(arg6, arg7)
              flag17 = arg6 == true
              n41 += 1

              if not flag17 and tbl26 and tbl26.Button == autoTrade then
                tbl26 = nil
              end

              fn50(arg7 == true)
            end

            local function fn52(arg6, arg7, arg8)
              fn34(arg6, tweenInfo, { Color = arg8 and tbl21.White or Color3.fromRGB(84, 86, 96) })
              fn34(arg7, tweenInfo, { BackgroundColor3 = arg8 and Color3.fromRGB(30, 30, 36) or Color3.fromRGB(28, 20, 24) })
            end

            local function fn53(arg6, arg7, arg8, text)
              if not arg6 or not arg6.Parent then
                return
              end
              local text2 = arg7 and "SENT"

              if not text2 then
                text2 = tostring(arg8 or "FAILED"):upper()
              end

              arg6.Text = text2
              arg6.TextSize = #text2 > 10 and (flag15 and 6 or 7) or flag15 and 12 or 10
              arg6.TextColor3 = arg7 and tbl21.Good or Color3.fromRGB(245, 95, 95)

              task.delay(2.2, function()
                if arg6 and arg6.Parent then
                  arg6.Text = text
                  arg6.TextSize = flag15 and 12 or 10
                  arg6.TextColor3 = tbl21.White
                end
              end)
            end

            local flag18 = false

            local function fn54(arg6)
              if flag18 then
                if arg6 then
                  arg6(false, "BUSY", 1)
                end

                return
              end

              if not num then
                fn53(trade, false, "WAITING", "TRADE")

                if arg6 then
                  arg6(false, "WAITING", 1)
                end

                return
              end

              flag18 = true
              trade.Text = "SENDING"

              sendTrade(num, function(arg7, arg8, arg9)
                flag18 = false
                fn53(trade, arg7, arg8, "TRADE")

                if arg6 then
                  arg6(arg7, arg8, arg9)
                end
              end)
            end

            fn49 = function(arg6)
              local v95 = n41

              task.delay(math.max(0, tonumber(arg6) or 0), function()
                if not aceFinderRuntime.Running or not instance2.Parent or not flag17 or v95 ~= n41 then
                  return
                end

                fn54(function(arg7, arg8, arg9)
                  if not flag17 or v95 ~= n41 or not instance2.Parent then
                    return
                  end
                  fn49(math.max(26, tonumber(arg9) or 0))
                end)
              end)
            end

            local flag19 = false

            local function fn55()
              if flag19 then
                return
              end

              if not num then
                fn53(duel, false, "WAITING", "DUEL")
                return
              end
              flag19 = true
              duel.Text = "SENDING"

              sendDuel(num, function(arg6, arg7)
                flag19 = false
                fn53(duel, arg6, arg7, "DUEL")
              end)
            end

            textButton.MouseButton1Click:Connect(function()
              local v95 = flag16 and fn36(flag16)
              textButton.Text = v95 and "COPIED" or flag16 and "COPY FAILED" or "NO USER"
              textButton.TextColor3 = v95 and tbl21.Good or tbl21.White

              task.delay(1.5, function()
                if textButton and textButton.Parent then
                  textButton.Text = "COPY USERNAME"
                  textButton.TextColor3 = tbl21.White
                end
              end)
            end)

            textButton.MouseEnter:Connect(function()
              fn52(v93, textButton, true)
            end)

            textButton.MouseLeave:Connect(function()
              fn52(v93, textButton, false)
            end)

            trade.MouseEnter:Connect(function()
              fn52(v86, trade, true)
            end)

            trade.MouseLeave:Connect(function()
              fn52(v86, trade, false)
            end)

            trade.MouseButton1Click:Connect(function()
              fn54()
            end)

            duel.MouseEnter:Connect(function()
              fn52(v88, duel, true)
            end)

            duel.MouseLeave:Connect(function()
              fn52(v88, duel, false)
            end)

            duel.MouseButton1Click:Connect(fn55)

            autoTrade.MouseButton1Click:Connect(function()
              if flag17 then
                fn51(false, false)
                return
              end

              if tbl26 and tbl26.Button ~= autoTrade and tbl26.SetState then
                tbl26.SetState(false, false)
              end

              tbl26 = { Button = autoTrade, SetState = fn51, Trigger = fn54 }
              fn51(true, false)
              fn49(0)
            end)

            autoTrade.MouseEnter:Connect(function()
              fn50(true)
            end)

            autoTrade.MouseLeave:Connect(function()
              fn50(false)
            end)

            local tbl29 = {
              server = tbl21.Good,
              ingame = tbl21.Good,
              online = Color3.fromRGB(64, 64, 72),
              studio = Color3.fromRGB(64, 64, 70),
              offline = Color3.fromRGB(64, 64, 72),
              unknown = Color3.fromRGB(92, 96, 110),
            }

            local tbl30

            tbl30 = {
              SetPresence = function(arg6)
                frame4.BackgroundColor3 = tbl29[arg6] or tbl29.unknown

                if not num then
                  unclaimed.Text = "UNCLAIMED"
                  unclaimed.TextColor3 = tbl21.Dim
                elseif arg6 == "server" then
                  unclaimed.Text = "IN SERVER"
                  unclaimed.TextColor3 = tbl21.Good
                elseif arg6 == "ingame" then
                  unclaimed.Text = "IN GAME"
                  unclaimed.TextColor3 = tbl21.Good
                elseif arg6 == "online" or arg6 == "studio" then
                  unclaimed.Text = "OFFLINE"
                  unclaimed.TextColor3 = Color3.fromRGB(255, 105, 110)
                else
                  unclaimed.Text = "CLAIMED"
                  unclaimed.TextColor3 = Color3.fromRGB(190, 192, 202)
                end
              end,
              SetOwner = function(arg6, arg7)
                num = tonumber(arg6)
                flag16 = type(arg7) == "string" and arg7 ~= "" and arg7 or nil
                v91.Text = flag16 and "@" .. flag16 or "@unclaimed"
                instance2:SetAttribute("OwnerUsername", flag16 or "")
                tbl30.SetPresence(num and "online" or "offline")

                if num then
                  local v95 = num

                  task.spawn(function()
                    local ok, result = pcall(function()
                      return Players:GetNameFromUserIdAsync(v95)
                    end)

                    if ok and num == v95 and type(result) == "string" and result ~= "" and instance2.Parent then
                      flag16 = result
                      v91.Text = "@" .. result
                      instance2:SetAttribute("OwnerUsername", result)
                      aceFinderRuntime.RefreshFilters()
                    end
                  end)

                  if flag17 then
                    n41 += 1
                    fn50(false)
                    fn49(0)
                  end
                end

                aceFinderRuntime.RefreshFilters()
              end,
              SetExpired = function(arg6)
                instance2:SetAttribute("Expired", arg6 == true)
                instance2.BackgroundTransparency = arg6 and 0.52 or 0.38
              end,
              GetOwnerUserId = function()
                return num
              end,
              SetSpawnAge = function(arg6)
                local n42 = math.max(0, math.floor(tonumber(arg6) or 0))
                v85.Text = string.format("%d:%02d", math.floor(n42 / 60), n42 % 60)
              end,
              Card = instance2,
              TradeButton = trade,
              DuelButton = duel,
            }

            instance2:SetAttribute("OwnerUsername", arg3)
            instance2:SetAttribute("IsOG", tbl28.IsOG == true)
            tbl30.SetOwner(num, flag16 or arg)
            return instance2, tbl30
          end

          tbl24 = {}
          tbl25 = {}
          local live2
          live2, v81 = fn47(live.Scroll, tbl24, "LIVE")
          local online2
          online2, v82 = fn47(online.Scroll, tbl25, "ONLINE")
        end

        do
          local function fn43(arg, arg2)
            table.insert(tbl18, arg)
            local tbl26 = {}
            local flag16 = false
            local scrollingEnabled = true
            local flag17 = false

            local function fn44()
              if not arg2:IsA("ScrollingFrame") or not arg2.Parent then
                return
              end
              local flag18 = flag16 or next(tbl26) ~= nil

              if flag18 and not flag17 then
                scrollingEnabled = arg2.ScrollingEnabled
                arg2.ScrollingEnabled = false
                flag17 = true
              elseif not flag18 and flag17 then
                arg2.ScrollingEnabled = scrollingEnabled
                flag17 = false
              end
            end

            local function fn45(arg3)
              flag16 = arg3 == true
              arg:SetAttribute("PointerInsideFilter", flag16)
              fn44()
            end

            arg.MouseEnter:Connect(function()
              fn45(true)
            end)

            arg.MouseLeave:Connect(function()
              fn45(false)
            end)

            local connection = service.InputChanged:Connect(function(input)
              if input.UserInputType ~= Enum.UserInputType.MouseMovement then
                return
              end
              local flag18 = true
              local parent = arg

              while parent do
                if parent:IsA("GuiObject") and not parent.Visible then
                  flag18 = false
                  break
                elseif parent:IsA("LayerCollector") then
                  flag18 = parent.Enabled
                  break
                else
                  parent = parent.Parent
                end
              end

              local value = select(1, GuiService:GetGuiInset())
              local n36 = service:GetMouseLocation() - value
              local absolutePosition = arg.AbsolutePosition
              local absoluteSize = arg.AbsoluteSize
              fn45(
                flag18
                  and n36.X >= absolutePosition.X
                  and n36.X <= absolutePosition.X + absoluteSize.X
                  and n36.Y >= absolutePosition.Y
                  and n36.Y <= absolutePosition.Y + absoluteSize.Y
              )
            end)

            arg.InputBegan:Connect(function(input)
              if input.UserInputType ~= Enum.UserInputType.Touch or tbl26[input] then
                return
              end
              tbl26[input] = true
              fn44()
            end)

            local connection2 = service.InputEnded:Connect(function(input)
              if not tbl26[input] then
                return
              end
              tbl26[input] = nil
              fn44()
            end)

            arg.Destroying:Connect(function()
              connection:Disconnect()
              connection2:Disconnect()
              local v83 = table.find(tbl18, arg)

              if v83 then
                table.remove(tbl18, v83)
              end

              if flag17 and arg2:IsA("ScrollingFrame") and arg2.Parent then
                arg2.ScrollingEnabled = scrollingEnabled
              end
            end)
          end

          fn41(v80.Scroll, "BACKGROUND", 1)
          local frame3 = Instance.new("Frame")
          frame3.Name = "Card"
          frame3.Size = UDim2.new(1, -16, 0, flag15 and 52 or 58)
          frame3.BackgroundColor3 = tbl21.Card
          frame3.BackgroundTransparency = 0
          frame3.BorderSizePixel = 0
          frame3.LayoutOrder = 2
          frame3.ClipsDescendants = true
          frame3.Parent = v80.Scroll
          fn35(frame3, 10)
          local scrollingFrame = Instance.new("ScrollingFrame")
          scrollingFrame.Name = "BackgroundScroller"
          scrollingFrame.Size = UDim2.new(1, -8, 1, 0)
          scrollingFrame.Position = UDim2.fromOffset(6, 0)
          scrollingFrame.BackgroundTransparency = 1
          scrollingFrame.BorderSizePixel = 0
          scrollingFrame.ScrollBarThickness = 0
          scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
          scrollingFrame.CanvasSize = UDim2.new()
          scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
          scrollingFrame.Active = true
          scrollingFrame.Parent = frame3
          fn43(scrollingFrame, v80.Scroll)
          local uiListLayout = Instance.new("UIListLayout")
          uiListLayout.FillDirection = Enum.FillDirection.Horizontal
          uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
          uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
          uiListLayout.Padding = UDim.new(0, 5)
          uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
          uiListLayout.Parent = scrollingFrame
          local uiPadding = Instance.new("UIPadding")
          uiPadding.PaddingLeft = UDim.new(0, 6)
          uiPadding.PaddingRight = UDim.new(0, 4)
          uiPadding.Parent = scrollingFrame
          local tbl26 = {}

          local function fn44()
            for i, v83 in ipairs(tbl26) do
              local visible = finderUISettingsState.BackgroundIndex == i
              v83.Button.BackgroundColor3 = visible and Color3.fromRGB(32, 32, 38) or tbl21.PhotoBG
              v83.Image.ImageTransparency = visible and 0 or 0.28
              v83.Selection.Visible = visible
              v83.Caption.TextColor3 = visible and tbl21.White or Color3.fromRGB(190, 192, 202)
            end
          end

          local function fn45(arg)
            local backgroundIndex = math.clamp(tonumber(arg) or 1, 1, #tbl19)
            finderUISettingsState.BackgroundIndex = backgroundIndex
            local v83 = tbl19[backgroundIndex]

            if v83.IsNone then
              imageLabel.Visible = false
              instance.BackgroundColor3 = tbl21.BG
            else
              imageLabel.Image = v83.Image
              imageLabel.ScaleType = v83.ScaleType
              imageLabel.Visible = true
            end

            fn44()
            aceFinderRuntime.SaveConfig()
          end

          for i, v83 in ipairs(tbl19) do
            local textButton = Instance.new("TextButton")
            textButton.Name = v83.Name
            textButton.LayoutOrder = i
            textButton.Size = UDim2.fromOffset(flag15 and 38 or 42, flag15 and 38 or 42)
            textButton.BackgroundColor3 = tbl21.PhotoBG
            textButton.BorderSizePixel = 0
            textButton.Text = ""
            textButton.AutoButtonColor = false
            textButton.ClipsDescendants = true
            textButton.Parent = scrollingFrame
            fn35(textButton, 8)
            local imageLabel2 = Instance.new("ImageLabel")
            imageLabel2.Name = "Preview"
            imageLabel2.Size = UDim2.fromScale(1, 1)
            imageLabel2.BackgroundTransparency = 1
            imageLabel2.Image = v83.Image
            imageLabel2.ScaleType = v83.ScaleType
            imageLabel2.BorderSizePixel = 0
            imageLabel2.Parent = textButton
            fn35(imageLabel2, 8)

            if v83.IsNone then
              local noBg = createTextLabel(textButton, "NO BG", 6, tbl21.White, Enum.Font.GothamBold)
              noBg.Size = UDim2.new(1, 0, 1, -10)
              noBg.TextXAlignment = Enum.TextXAlignment.Center
              noBg.TextYAlignment = Enum.TextYAlignment.Center
              noBg.ZIndex = 2
            end

            local v84 = createTextLabel(textButton, v83.IsNone and "NONE" or tostring(i - 1), 8, tbl21.White, Enum.Font.GothamBold)
            v84.Size = UDim2.new(1, 0, 0, 13)
            v84.Position = UDim2.new(0, 0, 1, -15)
            v84.TextXAlignment = Enum.TextXAlignment.Center
            v84.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            v84.TextStrokeTransparency = 0
            v84.ZIndex = 3
            local frame4 = Instance.new("Frame")
            frame4.Name = "Selected"
            frame4.Size = UDim2.new(1, -12, 0, 2)
            frame4.Position = UDim2.new(0, 6, 1, -4)
            frame4.BackgroundColor3 = tbl21.White
            frame4.BorderSizePixel = 0
            frame4.ZIndex = 4
            frame4.Parent = textButton
            fn35(frame4, 1)
            tbl26[i] = { Button = textButton, Image = imageLabel2, Caption = v84, Selection = frame4 }

            textButton.MouseButton1Click:Connect(function()
              fn45(i)
            end)
          end

          fn44()
        end

        do
          local frame3 = Instance.new("Frame")
          frame3.Name = "GUI Scale"
          frame3.Size = UDim2.new(1, -16, 0, 60)
          frame3.BackgroundColor3 = tbl21.Card
          frame3.BackgroundTransparency = 0
          frame3.BorderSizePixel = 0
          frame3.LayoutOrder = 3
          frame3.Parent = v80.Scroll
          fn35(frame3, 10)
          local v83 = createTextLabel(frame3, "", flag15 and 8 or 11, tbl21.White, Enum.Font.GothamMedium)
          v83.Size = UDim2.new(1, -138, 1, 0)
          v83.Position = UDim2.fromOffset(16, 0)
          v83.TextYAlignment = Enum.TextYAlignment.Center
          local textButton = Instance.new("TextButton")
          textButton.Name = "Minus"
          textButton.Size = UDim2.fromOffset(28, 30)
          textButton.Position = UDim2.new(1, -120, 0.5, -13)
          textButton.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
          textButton.BorderSizePixel = 0
          textButton.Text = "-"
          textButton.TextColor3 = tbl21.White
          textButton.TextSize = 14
          textButton.Font = Enum.Font.GothamBlack
          textButton.AutoButtonColor = false
          textButton.Parent = frame3
          fn35(textButton, 7)
          local v84 = 1
          createUIStroke2(textButton, Color3.fromRGB(72, 74, 84), v84, 0.35)
          local white = tbl21.White
          local gothamBlack = Enum.Font.GothamBlack
          local v85 = createTextLabel(frame3, string.format("%.2f", finderUISettingsState.GuiScale), 12, white, gothamBlack)
          v85.Name = "ScaleValue"
          v85.Size = UDim2.fromOffset(48, 30)
          v85.Position = UDim2.new(1, -86, 0.5, -13)
          v85.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
          v85.BackgroundTransparency = 0.05
          v85.TextXAlignment = Enum.TextXAlignment.Center
          v85.TextYAlignment = Enum.TextYAlignment.Center
          fn35(v85, 7)
          local v86 = 1
          createUIStroke2(v85, Color3.fromRGB(72, 74, 84), v86, 0.35)
          local textButton2 = Instance.new("TextButton")
          textButton2.Name = "Plus"
          textButton2.Size = UDim2.fromOffset(28, 30)
          textButton2.Position = UDim2.new(1, -32, 0.5, -13)
          textButton2.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
          textButton2.BorderSizePixel = 0
          textButton2.Text = "+"
          textButton2.TextColor3 = tbl21.White
          textButton2.TextSize = 14
          textButton2.Font = Enum.Font.GothamBlack
          textButton2.AutoButtonColor = false
          textButton2.Parent = frame3
          fn35(textButton2, 6)
          createUIStroke2(textButton2, Color3.fromRGB(72, 74, 84), 1, 0.35)

          local function fn43(arg)
            local clamp = math.clamp
            local floor2 = math.floor
            local n36 = tonumber(arg) or 1
            local v87 = 0.5
            local v88 = 1.5
            local v89 = clamp(floor2(n36 * 100 + 0.5) / 100, v87, v88)
            finderUISettingsState.GuiScale = v89
            uiScale.Scale = v89 * n32
            v85.Text = string.format("%.2f", v89)
            aceFinderRuntime.SaveConfig()
          end

          textButton.MouseButton1Click:Connect(function()
            fn43(finderUISettingsState.GuiScale - 0.05)
          end)

          textButton2.MouseButton1Click:Connect(function()
            fn43(finderUISettingsState.GuiScale + 0.05)
          end)
        end

        do
          local frame3 = Instance.new("Frame")
          frame3.Name = "Falling Snow"
          frame3.Size = UDim2.new(1, -16, 0, 42)
          frame3.BackgroundColor3 = tbl21.Card
          frame3.BackgroundTransparency = 0
          frame3.BorderSizePixel = 0
          frame3.LayoutOrder = 4
          frame3.Parent = v80.Scroll
          fn35(frame3, 10)
          local fallingSnow = createTextLabel(frame3, "Falling snow", flag15 and 10 or 11, tbl21.White, Enum.Font.GothamMedium)
          fallingSnow.Size = UDim2.new(1, -78, 1, 0)
          fallingSnow.Position = UDim2.fromOffset(16, 0)
          fallingSnow.TextYAlignment = Enum.TextYAlignment.Center
          local instance2 = Instance.new("Frame")
          instance2.Name = "Track"
          instance2.Size = UDim2.fromOffset(44, 32)
          instance2.Position = UDim2.new(1, -56, 0.5, -16)
          instance2.BorderSizePixel = 0
          instance2.Parent = frame3
          fn35(instance2, 12)
          local frame4 = Instance.new("Frame")
          frame4.Name = "Knob"
          frame4.Size = UDim2.fromOffset(18, 18)
          frame4.BorderSizePixel = 0
          frame4.Parent = instance2
          fn35(frame4, 9)
          local instance3 = Instance.new("TextButton")
          instance3.Name = "ToggleButton"
          instance3.Size = UDim2.fromScale(1, 1)
          instance3.BackgroundTransparency = 1
          instance3.Text = ""
          instance3.ZIndex = 4
          instance3.Parent = frame3

          local function fn43(arg)
            local fallingParticlesEnabled = finderUISettingsState.FallingParticlesEnabled

            local tbl26 = {
              BackgroundColor3 = fallingParticlesEnabled and tbl21.White or tbl21.TrackOff,
              BackgroundTransparency = fallingParticlesEnabled and 0 or 0.08,
            }

            local tbl27 = {
              Position = fallingParticlesEnabled and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
              BackgroundColor3 = fallingParticlesEnabled and tbl21.BG or tbl21.KnobOff,
            }

            if arg then
              fn34(instance2, tweenInfo, tbl26)
              fn34(frame4, tweenInfo, tbl27)
            else
              for k, v83 in pairs(tbl26) do
                instance2[k] = v83
              end

              for k, v83 in pairs(tbl27) do
                frame4[k] = v83
              end
            end

            local aceFallingDots = instance:FindFirstChild("ACEFallingDots")

            if aceFallingDots then
              aceFallingDots.Visible = fallingParticlesEnabled
            end
          end

          fn43(false)

          instance3.MouseButton1Click:Connect(function()
            finderUISettingsState.FallingParticlesEnabled = not finderUISettingsState.FallingParticlesEnabled
            fn43(true)
            aceFinderRuntime.SaveConfig()
          end)
        end

        do
          local frame3 = Instance.new("Frame")
          frame3.Name = "OG Spawns Only"
          frame3.Size = UDim2.new(1, -16, 0, 42)
          frame3.BackgroundColor3 = tbl21.Card
          frame3.BackgroundTransparency = 0
          frame3.BorderSizePixel = 0
          frame3.LayoutOrder = 5
          frame3.Parent = v80.Scroll
          fn35(frame3, 8)
          local ogSpawnsOnly = createTextLabel(frame3, "OG spawns only", flag15 and 10 or 11, tbl21.White, Enum.Font.GothamMedium)
          ogSpawnsOnly.Size = UDim2.new(1, -78, 1, 0)
          ogSpawnsOnly.Position = UDim2.fromOffset(16, 0)
          ogSpawnsOnly.TextYAlignment = Enum.TextYAlignment.Center
          local frame4 = Instance.new("Frame")
          frame4.Name = "Track"
          frame4.Size = UDim2.fromOffset(44, 32)
          frame4.Position = UDim2.new(1, -56, 0.5, -12)
          frame4.BorderSizePixel = 0
          frame4.Parent = frame3
          fn35(frame4, 16)
          local frame5 = Instance.new("Frame")
          frame5.Name = "Knob"
          frame5.Size = UDim2.fromOffset(18, 18)
          frame5.BorderSizePixel = 0
          frame5.Parent = frame4
          fn35(frame5, 9)
          local textButton = Instance.new("TextButton")
          textButton.Name = "ToggleButton"
          textButton.Size = UDim2.fromScale(1, 1)
          textButton.BackgroundTransparency = 1
          textButton.Text = ""
          textButton.ZIndex = 4
          textButton.Parent = frame3

          local function fn43(arg)
            local ogOnlyEnabled = finderUISettingsState.OGOnlyEnabled

            local tbl26 = {
              BackgroundColor3 = ogOnlyEnabled and tbl21.White or tbl21.TrackOff,
              BackgroundTransparency = ogOnlyEnabled and 0 or 0.08,
            }

            local tbl27 = {
              Position = ogOnlyEnabled and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
              BackgroundColor3 = ogOnlyEnabled and tbl21.BG or tbl21.KnobOff,
            }

            if arg then
              fn34(frame4, tweenInfo, tbl26)
              fn34(frame5, tweenInfo, tbl27)
            else
              for k, v83 in pairs(tbl26) do
                frame4[k] = v83
              end

              for k, v83 in pairs(tbl27) do
                frame5[k] = v83
              end
            end
          end

          table.insert(aceFinderRuntime.OGModeVisualRefreshers, fn43)
          fn43(false)

          textButton.MouseButton1Click:Connect(function()
            aceFinderRuntime.SetOGOnlyEnabled(not finderUISettingsState.OGOnlyEnabled, true)
          end)
        end

        fn41(v80.Scroll, "NOTIFICATIONS", 6)

        do
          local frame3 = Instance.new("Frame")
          frame3.Name = "Notifications"
          frame3.Size = UDim2.new(1, -16, 0, 60)
          frame3.BackgroundColor3 = tbl21.Card
          frame3.BackgroundTransparency = 0
          frame3.BorderSizePixel = 0
          frame3.LayoutOrder = 7
          frame3.Parent = v80.Scroll
          fn35(frame3, 8)
          local notifications = createTextLabel(frame3, "Notifications", flag15 and 10 or 11, tbl21.White, Enum.Font.GothamMedium)
          notifications.Size = UDim2.new(1, -78, 1, 0)
          notifications.Position = UDim2.fromOffset(12, 0)
          notifications.TextYAlignment = Enum.TextYAlignment.Center
          local frame4 = Instance.new("Frame")
          frame4.Name = "Track"
          frame4.Size = UDim2.fromOffset(44, 32)
          frame4.Position = UDim2.new(1, -50, 0.5, -12)
          frame4.BorderSizePixel = 0
          frame4.Parent = frame3
          fn35(frame4, 12)
          local frame5 = Instance.new("Frame")
          frame5.Name = "Knob"
          frame5.Size = UDim2.fromOffset(18, 18)
          frame5.BorderSizePixel = 0
          frame5.Parent = frame4
          fn35(frame5, 9)
          local textButton = Instance.new("TextButton")
          textButton.Name = "ToggleButton"
          textButton.Size = UDim2.fromScale(1, 1)
          textButton.BackgroundTransparency = 1
          textButton.Text = ""
          textButton.ZIndex = 4
          textButton.Parent = frame3

          local function fn43(arg)
            local notificationsEnabled = finderUISettingsState.NotificationsEnabled
            local tbl26 = {
              BackgroundColor3 = notificationsEnabled and tbl21.White or tbl21.TrackOff,
              BackgroundTransparency = notificationsEnabled and 0 or 0.08,
            }

            local tbl27 = {
              Position = notificationsEnabled and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
              BackgroundColor3 = notificationsEnabled and tbl21.BG or tbl21.KnobOff,
            }

            if arg then
              fn34(frame4, tweenInfo, tbl26)
              fn34(frame5, tweenInfo, tbl27)
            else
              for k, v83 in pairs(tbl26) do
                frame4[k] = v83
              end

              for k, v83 in pairs(tbl27) do
                frame5[k] = v83
              end
            end
          end

          fn43(false)

          textButton.MouseButton1Click:Connect(function()
            finderUISettingsState.NotificationsEnabled = not finderUISettingsState.NotificationsEnabled
            fn43(true)

            if not finderUISettingsState.NotificationsEnabled then
              fn32()

              if v79 then
                v79:Destroy()
                v79 = nil
              end
            end

            aceFinderRuntime.SaveConfig()
          end)
        end

        do
          local instance2 = Instance.new("Frame")
          instance2.Name = "Notification Sounds"
          instance2.Size = UDim2.new(1, -16, 0, 42)
          instance2.BackgroundColor3 = tbl21.Card
          instance2.BackgroundTransparency = 0
          instance2.BorderSizePixel = 0
          instance2.LayoutOrder = 8
          instance2.Parent = v80.Scroll
          fn35(instance2, 10)
          local notificationSounds =
            createTextLabel(instance2, "Notification Sounds", flag15 and 10 or 11, tbl21.White, Enum.Font.GothamMedium)
          notificationSounds.Size = UDim2.new(1, -78, 1, 0)
          notificationSounds.Position = UDim2.fromOffset(16, 0)
          notificationSounds.TextYAlignment = Enum.TextYAlignment.Center
          local frame3 = Instance.new("Frame")
          frame3.Name = "Track"
          frame3.Size = UDim2.fromOffset(44, 32)
          frame3.Position = UDim2.new(1, -50, 0.5, -12)
          frame3.BorderSizePixel = 0
          frame3.Parent = instance2
          fn35(frame3, 12)
          local frame4 = Instance.new("Frame")
          frame4.Name = "Knob"
          frame4.Size = UDim2.fromOffset(18, 18)
          frame4.BorderSizePixel = 0
          frame4.Parent = frame3
          fn35(frame4, 9)
          local textButton = Instance.new("TextButton")
          textButton.Name = "ToggleButton"
          textButton.Size = UDim2.fromScale(1, 1)
          textButton.BackgroundTransparency = 1
          textButton.Text = ""
          textButton.ZIndex = 6
          textButton.Parent = instance2

          local function fn43(arg)
            local notificationSoundsEnabled = finderUISettingsState.NotificationSoundsEnabled
            local tbl26 = {
              BackgroundColor3 = notificationSoundsEnabled and tbl21.White or tbl21.TrackOff,
              BackgroundTransparency = notificationSoundsEnabled and 0 or 0.08,
            }

            local tbl27 = {
              Position = notificationSoundsEnabled and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
              BackgroundColor3 = notificationSoundsEnabled and tbl21.BG or tbl21.KnobOff,
            }

            if arg then
              fn34(frame3, tweenInfo, tbl26)
              fn34(frame4, tweenInfo, tbl27)
            else
              for k, v83 in pairs(tbl26) do
                frame3[k] = v83
              end

              for k, v83 in pairs(tbl27) do
                frame4[k] = v83
              end
            end
          end

          fn43(false)

          textButton.MouseButton1Click:Connect(function()
            finderUISettingsState.NotificationSoundsEnabled = not finderUISettingsState.NotificationSoundsEnabled
            fn43(true)

            if finderUISettingsState.NotificationSoundsEnabled then
              fn33(function(arg, arg2)
                if not arg and arg2 then
                  aceFinderRuntime.LastSoundError = tostring(arg2)
                end
              end)
            else
              fn32()
            end

            aceFinderRuntime.SaveConfig()
          end)
        end

        do
          local frame3 = Instance.new("Frame")
          frame3.Name = "Notification Sound"
          frame3.Size = UDim2.new(1, -16, 0, 42)
          frame3.BackgroundColor3 = tbl21.Card
          frame3.BackgroundTransparency = 0
          frame3.BorderSizePixel = 0
          frame3.LayoutOrder = 9
          frame3.Parent = v80.Scroll
          fn35(frame3, 10)
          local notificationSound = createTextLabel(frame3, "Notification Sound", flag15 and 9 or 11, tbl21.White, Enum.Font.GothamMedium)
          notificationSound.Size = UDim2.new(1, -(flag15 and 176 or 196), 1, 0)
          notificationSound.Position = UDim2.fromOffset(12, 0)
          notificationSound.TextYAlignment = Enum.TextYAlignment.Center
          local n36 = flag15 and 28 or 32
          local n37 = flag15 and 86 or 96
          local instance2 = Instance.new("TextButton")
          instance2.Name = "SoundLeft"
          instance2.Size = UDim2.fromOffset(n36, 28)
          instance2.Position = UDim2.new(1, -(n36 * 2 + n37 + 10 + 10), 0.5, -14)
          instance2.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
          instance2.BorderSizePixel = 0
          instance2.Text = "<"
          instance2.TextColor3 = tbl21.White
          instance2.TextSize = 12
          instance2.Font = Enum.Font.GothamSemibold
          instance2.AutoButtonColor = false
          instance2.Parent = frame3
          fn35(instance2, 6)
          createUIStroke2(instance2, Color3.fromRGB(72, 74, 84), 1, 0.35)
          local frame4 = Instance.new("Frame")
          frame4.Name = "SoundValueHolder"
          frame4.Size = UDim2.fromOffset(n37, 28)
          frame4.Position = UDim2.new(1, -(n37 + n36 + 5 + 10), 0.5, -14)
          frame4.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
          frame4.BorderSizePixel = 0
          frame4.Parent = frame3
          fn35(frame4, 6)
          createUIStroke2(frame4, Color3.fromRGB(72, 74, 84), 1, 0.35)
          local v83 = createTextLabel(
            frame4,
            tbl20[finderUISettingsState.NotificationSoundIndex].Name,
            flag15 and 9 or 8,
            tbl21.White,
            Enum.Font.GothamSemibold
          )
          v83.Size = UDim2.fromScale(1, 1)
          v83.TextXAlignment = Enum.TextXAlignment.Center
          v83.TextYAlignment = Enum.TextYAlignment.Center
          local textButton = Instance.new("TextButton")
          textButton.Name = "SoundRight"
          textButton.Size = UDim2.fromOffset(n36, 28)
          textButton.Position = UDim2.new(1, -(n36 + 8), 0.5, -14)
          textButton.BackgroundColor3 = Color3.fromRGB(8, 12, 12)
          textButton.BorderSizePixel = 0
          textButton.Text = ">"
          textButton.TextColor3 = tbl21.White
          textButton.TextSize = 12
          textButton.Font = Enum.Font.GothamSemibold
          textButton.AutoButtonColor = false
          textButton.Parent = frame3
          fn35(textButton, 7)
          createUIStroke2(textButton, Color3.fromRGB(72, 74, 84), 1, 0.35)

          local function fn43(notificationSoundIndex)
            if notificationSoundIndex < 1 then
              notificationSoundIndex = #tbl20
            end

            if #tbl20 < notificationSoundIndex then
              notificationSoundIndex = 1
            end

            finderUISettingsState.NotificationSoundIndex = notificationSoundIndex
            v83.Text = tbl20[notificationSoundIndex].Name
            aceFinderRuntime.SaveConfig()

            fn33(function(arg, arg2)
              if not arg and arg2 then
                aceFinderRuntime.LastSoundError = tostring(arg2)
              end
            end)
          end

          instance2.MouseButton1Click:Connect(function()
            fn43(finderUISettingsState.NotificationSoundIndex - 1)
          end)

          textButton.MouseButton1Click:Connect(function()
            fn43(finderUISettingsState.NotificationSoundIndex + 1)
          end)
        end

        do
          local frame3 = Instance.new("Frame")
          frame3.Name = "Notification Volume"
          frame3.Size = UDim2.new(1, -16, 0, 62)
          frame3.BackgroundColor3 = tbl21.Card
          frame3.BackgroundTransparency = 0
          frame3.BorderSizePixel = 0
          frame3.LayoutOrder = 8
          frame3.Parent = v80.Scroll
          fn35(frame3, 10)
          local notificationVolume =
            createTextLabel(frame3, "Notification Volume", flag15 and 10 or 11, tbl21.White, Enum.Font.GothamMedium)
          notificationVolume.Size = UDim2.new(0.6, 0, 0, 23)
          notificationVolume.Position = UDim2.fromOffset(16, 2)
          notificationVolume.TextYAlignment = Enum.TextYAlignment.Center
          local v83 = createTextLabel(frame3, "", flag15 and 9 or 8, tbl21.Muted, Enum.Font.GothamSemibold)
          v83.Size = UDim2.new(0.4, -12, 0, 23)
          v83.Position = UDim2.new(0.6, 0, 0, 2)
          v83.TextXAlignment = Enum.TextXAlignment.Right
          v83.TextYAlignment = Enum.TextYAlignment.Center
          local textButton = Instance.new("TextButton")
          textButton.Name = "VolumeSlider"
          textButton.Size = UDim2.new(1, -28, 0, 8)
          textButton.Position = UDim2.fromOffset(14, 29)
          textButton.BackgroundColor3 = Color3.fromRGB(43, 44, 51)
          textButton.BorderSizePixel = 0
          textButton.Text = ""
          textButton.AutoButtonColor = false
          textButton.Parent = frame3
          fn35(textButton, 4)
          local frame4 = Instance.new("Frame")
          frame4.Name = "Fill"
          frame4.Size = UDim2.fromScale(finderUISettingsState.NotificationVolume, 1)
          frame4.BackgroundColor3 = tbl21.White
          frame4.BorderSizePixel = 0
          frame4.Parent = textButton
          fn35(frame4, 4)
          local frame5 = Instance.new("Frame")
          frame5.Name = "Knob"
          frame5.Size = UDim2.fromOffset(14, 14)
          frame5.AnchorPoint = Vector2.new(0.5, 0.5)
          frame5.Position = UDim2.new(finderUISettingsState.NotificationVolume, 0, 0.5, 0)
          frame5.BackgroundColor3 = tbl21.White
          frame5.BorderSizePixel = 0
          frame5.ZIndex = textButton.ZIndex + 1
          frame5.Parent = textButton
          fn35(frame5, 7)
          local v84 = createTextLabel(frame3, "0%", flag15 and 7 or 8, tbl21.Muted, Enum.Font.GothamMedium)
          v84.Size = UDim2.new(0.33333333333333331, -8, 0, 16)
          v84.Position = UDim2.fromOffset(12, 42)
          v84.TextXAlignment = Enum.TextXAlignment.Left
          local v85 = createTextLabel(frame3, "50%", flag15 and 7 or 8, tbl21.Muted, Enum.Font.GothamMedium)
          v85.Size = UDim2.new(0.33333333333333331, 0, 0, 16)
          v85.Position = UDim2.new(0.33333333333333331, 0, 0, 42)
          v85.TextXAlignment = Enum.TextXAlignment.Center
          local v86 = createTextLabel(frame3, "100%", flag15 and 7 or 8, tbl21.Muted, Enum.Font.GothamMedium)
          v86.Size = UDim2.new(0.33333333333333331, -12, 0, 12)
          v86.Position = UDim2.new(0.66666666666666663, 0, 0, 60)
          v86.TextXAlignment = Enum.TextXAlignment.Right

          local function fn43(arg, arg2)
            local notificationVolume2 = math.clamp(tonumber(arg) or 0, 0, 1)
            finderUISettingsState.NotificationVolume = notificationVolume2
            frame4.Size = UDim2.fromScale(notificationVolume2, 1)
            frame5.Position = UDim2.new(notificationVolume2, 0, 0.5, 0)
            v83.Text = string.format("%d%%", math.floor(notificationVolume2 * 100 + 0.5))
            local finderUINotificationSound = genv3.FinderUINotificationSound

            if finderUINotificationSound and finderUINotificationSound.Parent then
              local v87 = tbl20[finderUISettingsState.NotificationSoundIndex]
              finderUINotificationSound.Volume = math.clamp((tonumber(v87 and v87.Volume) or 0.65) * notificationVolume2, 0, 10)
            elseif arg2 then
              fn33(function(arg3, arg4)
                if not arg3 and arg4 then
                  aceFinderRuntime.LastSoundError = tostring(arg4)
                end
              end)
            end
          end

          fn43(finderUISettingsState.NotificationVolume, false)
          local flag16 = false

          local function fn44(arg)
            local x = textButton.AbsoluteSize.X
            if x <= 0 then
              return
            end
            fn43((arg.Position.X - textButton.AbsolutePosition.X) / x, false)
          end

          textButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
              flag16 = true
              fn44(input)
            end
          end)

          fn31(service.InputChanged, function(arg)
            if not flag16 then
              return
            end

            if arg.UserInputType == Enum.UserInputType.MouseMovement or arg.UserInputType == Enum.UserInputType.Touch then
              fn44(arg)
            end
          end)

          fn31(service.InputEnded, function(arg)
            if flag16 and (arg.UserInputType == Enum.UserInputType.MouseButton1 or arg.UserInputType == Enum.UserInputType.Touch) then
              flag16 = false
              fn44(arg)
              aceFinderRuntime.SaveConfig()

              if 0 < finderUISettingsState.NotificationVolume then
                fn33(function(arg2, arg3)
                  if not arg2 and arg3 then
                    aceFinderRuntime.LastSoundError = tostring(arg3)
                  end
                end)
              else
                fn32()
              end
            end
          end)
        end

        do
          local entries = {}
          local tbl26 = {}
          local v83 = 0
          local v84 = 0
          aceFinderRuntime.PendingClaimsByUID = {}

          local function fn43(arg)
            if arg == nil then
              return nil
            end
            return tostring(arg)
          end

          local function fn44(arg, arg2)
            local v85 = table.find(arg, arg2)

            if v85 then
              table.remove(arg, v85)
            end
          end

          local function fn45(arg)
            local v85 = fn43(arg)
            local v86 = v85 and entries[v85]
            if not v86 then
              return
            end
            entries[v85] = nil
            aceFinderRuntime.PendingClaimsByUID[v85] = nil
            fn44(v86.LinkedCards, v86.Card)

            if v86.OnlineCard then
              fn44(tbl25, v86.OnlineCard)
            end

            for i, v87 in ipairs(tbl26) do
              if v87 == v86 then
                table.remove(tbl26, i)
                break
              end
            end

            if v86.Card and v86.Card.Parent then
              v86.Card:Destroy()
            end

            if v86.OnlineCard and v86.OnlineCard.Parent then
              v86.OnlineCard:Destroy()
            end
          end

          local function fn46(arg, arg2)
            if not arg or not arg.Controller.GetOwnerUserId() then
              return
            end
            arg.OnlineRemovalGeneration = (arg.OnlineRemovalGeneration or 0) + 1

            if not arg.OnlineCard or not arg.OnlineCard.Parent then
              local v85, v86 = fn42(
                online.Scroll,
                arg.OwnerDisplayName,
                arg.OwnerDisplayName,
                arg.BrainrotName,
                arg.Mutation,
                { OwnerUserId = arg.Controller.GetOwnerUserId(), UID = arg.UID, IsOG = arg.IsOG }
              )
              v85.LayoutOrder = arg.Card.LayoutOrder
              v85:SetAttribute("SpawnSequence", arg.Sequence or 0)
              v85:SetAttribute("LiveboardUID", tostring(arg.UID))
              v85:SetAttribute("Scope", "ONLINE")
              arg.OnlineCard = v85
              arg.OnlineController = v86
              table.insert(tbl25, v85)
              v82()
            end

            if arg.OnlineController.GetOwnerUserId() ~= arg.Controller.GetOwnerUserId() then
              local ownerDisplayName = arg.OwnerDisplayName
              arg.OnlineController.SetOwner(arg.Controller.GetOwnerUserId(), ownerDisplayName)
            end

            arg.OnlineController.SetSpawnAge(workspace:GetServerTimeNow() - arg.SpawnedAt)
            arg.OnlineController.SetPresence(arg2 or "ingame")
          end

          local function fn47(arg, presenceState)
            if not arg or entries[arg.UIDKey] ~= arg then
              return
            end
            arg.PresenceState = presenceState
            arg.Controller.SetPresence(presenceState)

            if presenceState == "server" or presenceState == "ingame" then
              fn46(arg, presenceState)
            elseif arg.OnlineCard then
              fn44(tbl25, arg.OnlineCard)

              if arg.OnlineCard.Parent then
                arg.OnlineCard:Destroy()
              end

              arg.OnlineCard = nil
              arg.OnlineController = nil
              v82()
            end
          end

          local function fn48()
            local tbl27 = {}
            local tbl28 = {}

            for _, v85 in ipairs(tbl26) do
              local v86 = v85.Controller.GetOwnerUserId()

              if v86 then
                if Players:GetPlayerByUserId(v86) then
                  fn47(v85, "server")
                elseif not tbl28[v86] then
                  tbl28[v86] = true
                  table.insert(tbl27, v86)

                  if v85.PresenceState ~= "ingame" then
                    fn47(v85, "unknown")
                  end
                end
              end
            end

            if #tbl27 == 0 or not request_ then
              return
            end
            v84 += 1
            local v85 = v84

            task.spawn(function()
              local ok, result = pcall(request_, {
                Url = "https://presence.roblox.com/v1/presence/users",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = service2:JSONEncode({ userIds = tbl27 }),
              })

              local flag16 = type(result) == "table"

              if flag16 then
                flag16 = tonumber(result.StatusCode or result.Status)
              end

              flag16 = flag16 or nil
              local flag17 = not aceFinderRuntime.Running or v85 ~= v84 or not ok
              local flag18

              if flag17 then
                flag18 = flag17
              else
                local v86 = "table"
                flag18 = type(result) ~= v86
              end

              if flag18 or flag16 ~= 200 then
                return
              end

              local ok2, result2 = pcall(function()
                return service2:JSONDecode(result.Body or result.body)
              end)

              if not ok2 or type(result2) ~= "table" or type(result2.userPresences) ~= "table" then
                return
              end
              local tbl29 = {}

              for _, userPresence in ipairs(result2.userPresences) do
                tbl29[userPresence.userId] = userPresence.userPresenceType
              end

              for _, v86 in ipairs(tbl26) do
                local v87 = v86.Controller.GetOwnerUserId()
                local v88 = v87 and tbl29[v87]

                if v88 and not Players:GetPlayerByUserId(v87) then
                  if v88 == 2 then
                    fn47(v86, "ingame")
                  else
                    fn47(v86, "offline")
                  end
                end
              end
            end)
          end

          local n36 = 0

          local function fn49(arg)
            n36 += 1
            local v85 = n36

            task.delay(math.max(0, tonumber(arg) or 0), function()
              if aceFinderRuntime.Running and v85 == n36 then
                fn48()
              end
            end)
          end

          local function fn50(arg, arg2, arg3)
            local num = tonumber(arg2)
            if not arg or not num then
              return false
            end
            local ownerDisplayName = type(arg3) == "string" and arg3 ~= "" and arg3 or arg.OwnerDisplayName
            if arg.Controller.GetOwnerUserId() == num and (not ownerDisplayName or arg.OwnerDisplayName == ownerDisplayName) then
              return true
            end
            arg.OwnerDisplayName = ownerDisplayName
            arg.Controller.SetOwner(num, ownerDisplayName)
            fn47(arg, Players:GetPlayerByUserId(num) and "server" or "unknown")
            fn49(0.15)
            return true
          end

          local function fn51(arg)
            local v85 = fn38(arg)
            if not v85 or not v85.Parent then
              return nil, nil
            end
            local filler = v85:FindFirstChild("Filler")
            filler = filler and filler:FindFirstChild("PlayerBg")
            local username = filler and filler:FindFirstChild("Username")
            if not filler or not filler.Visible or not username then
              return nil, nil
            end
            local str8 = tostring(username.Text or ""):gsub("^@", "")
            if str8 == "" or string.upper(str8) == "UNCLAIMED" then
              return nil, nil
            end
            local headshot = filler:FindFirstChild("Headshot")

            if headshot then
              headshot = tonumber(tostring(headshot.Image or ""):match("id=(%d+)"))
            end

            headshot = headshot or nil

            if not headshot then
              for _, player in ipairs(Players:GetPlayers()) do
                if player.Name == str8 or player.DisplayName == str8 then
                  headshot = player.UserId
                  break
                end
              end
            end

            return headshot, str8
          end

          local function fn52(arg, arg2)
            if type(arg) ~= "table" or type(arg.BrainrotName) ~= "string" or arg.UID == nil then
              return nil
            end
            local v85 = true
            local flag16 = tbl23[fn37(arg.BrainrotName)] == v85
            local uid = arg.UID
            local v86 = fn43(uid)
            local v87 = entries[v86]

            if v87 then
              if arg.OwnerUserId ~= nil then
                fn50(v87, arg.OwnerUserId, arg.OwnerDisplayName)
              end

              local v88 = aceFinderRuntime.PendingClaimsByUID[v86]

              if v88 then
                aceFinderRuntime.PendingClaimsByUID[v86] = nil
                fn50(v87, v88.UserId, v88.DisplayName)
              end

              return v87
            end

            local v88 = aceFinderRuntime.PendingClaimsByUID[v86]
            local userId = v88 and v88.UserId or arg.OwnerUserId
            local displayName = v88 and v88.DisplayName or arg.OwnerDisplayName
            local flag17 = arg.IsLocalServer == true
            local v89 = tbl24
            local v90, v91 = fn42(
              live.Scroll,
              displayName,
              displayName,
              arg.BrainrotName,
              arg.Mutation,
              { OwnerUserId = userId, UID = arg.UID, IsOG = flag16 }
            )
            v83 += 1
            v90:SetAttribute("SpawnSequence", v83)
            v90.LayoutOrder = -v83
            v90:SetAttribute("LiveboardUID", tostring(uid))
            v90:SetAttribute("Scope", "LIVE")
            v90:SetAttribute("SpawnScope", flag17 and "SERVER" or "GLOBAL")
            table.insert(tbl24, v90)
            v81()
            local n37 = tonumber(arg.DisplayDuration) or 0
            local serverTimeNow = tonumber(arg.Timestamp) or workspace:GetServerTimeNow()
            local serverTimeNow2 = workspace:GetServerTimeNow()
            local n38 = math.max(0, n37 - math.max(0, serverTimeNow2 - serverTimeNow))
            local n39 = math.max(0, serverTimeNow2 - serverTimeNow)

            local tbl27 = {
              UID = uid,
              UIDKey = v86,
              Card = v90,
              Controller = v91,
              LinkedCards = v89,
              BrainrotName = arg.BrainrotName,
              Mutation = arg.Mutation,
              IsOG = flag16,
              Sequence = v83,
              OwnerDisplayName = displayName,
              IsLocalServer = flag17,
              ExpiresAt = serverTimeNow2 + n38,
              Expired = n38 <= 0,
              SpawnedAt = serverTimeNow2 - n39,
              PresenceState = v91.GetOwnerUserId() and "unknown" or "offline",
              OnlineRemovalGeneration = 0,
            }

            v91.SetExpired(tbl27.Expired)
            v91.SetSpawnAge(n39)
            entries[v86] = tbl27
            local v92 = aceFinderRuntime.PendingClaimsByUID[v86]

            if v92 then
              aceFinderRuntime.PendingClaimsByUID[v86] = nil
              fn50(tbl27, v92.UserId, v92.DisplayName)
            end

            table.insert(tbl26, 1, tbl27)

            while #tbl26 > 100 do
              fn45(tbl26[#tbl26].UID)
            end

            if v91.GetOwnerUserId() then
              fn47(tbl27, Players:GetPlayerByUserId(v91.GetOwnerUserId()) and "server" or "unknown")
              fn49(0.15)
            end

            if arg2 and (not finderUISettingsState.OGOnlyEnabled or flag16) then
              fn40(arg)
            end

            return tbl27
          end

          local function fn53()
            local tbl27 = {}
            local tbl28 = {}

            for _, v85 in ipairs(tbl22) do
              for _, v86 in pairs(v85) do
                local v87 = "table"

                if type(v86) == v87 and v86.UID ~= nil and typeof(v86.Frame) == "Instance" and not tbl28[fn43(v86.UID)] then
                  local filler = v86.Frame:FindFirstChild("Filler")
                  local name = nil
                  local num = nil
                  local str8 = nil
                  local flag16 = false

                  if filler then
                    local brainrotBg = filler:FindFirstChild("BrainrotBg")
                    brainrotBg = brainrotBg and brainrotBg:FindFirstChild("BrainrotViewport")
                    brainrotBg = brainrotBg and brainrotBg:FindFirstChildOfClass("WorldModel")
                    name = nil

                    if brainrotBg then
                      name = nil

                      for _, child in ipairs(brainrotBg:GetChildren()) do
                        if child:IsA("Model") then
                          name = child.Name
                          break
                        else
                          name = nil
                        end
                      end
                    end

                    local title = filler:FindFirstChild("Title")

                    if not name and title and title:IsA("TextLabel") then
                      name = tostring(title.Text or ""):gsub("<[^>]+>", "")
                    end

                    local location = filler:FindFirstChild("Location")

                    if location and location:IsA("TextLabel") then
                      flag16 = tostring(location.Text):find("[SERVER]", 1, true) ~= nil
                    end

                    local playerBg = filler:FindFirstChild("PlayerBg")
                    local username = playerBg and playerBg:FindFirstChild("Username")
                    local headshot = playerBg and playerBg:FindFirstChild("Headshot")
                    local isTextLabel = playerBg and playerBg.Visible and username and username:IsA("TextLabel")
                    str8 = nil

                    if isTextLabel then
                      local str9 = tostring(username.Text or "")
                      local flag17 = str9 ~= "" and string.upper(str9) ~= "UNCLAIMED"
                      str8 = nil

                      if flag17 then
                        str8 = str9:gsub("^@", "")
                      end
                    end

                    local isImageLabel = headshot and (headshot:IsA("ImageLabel") or headshot:IsA("ImageButton"))
                    num = nil

                    if isImageLabel then
                      num = tonumber(tostring(headshot.Image or ""):match("[?&]id=(%d+)"))
                    end
                  end

                  local v88 = fn43(v86.UID)

                  if type(name) == "string" and name ~= "" and v88 then
                    tbl28[v88] = true

                    table.insert(tbl27, {
                      UID = v86.UID,
                      BrainrotName = name,
                      Timestamp = tonumber(v86.SpawnedAt) or workspace:GetServerTimeNow(),
                      DisplayDuration = tonumber(v86.Duration) or 300,
                      IsLocalServer = flag16,
                      OwnerUserId = num,
                      OwnerDisplayName = str8,
                    })
                  end
                end
              end
            end

            table.sort(tbl27, function(arg, arg2)
              return (tonumber(arg.Timestamp) or 0) < (tonumber(arg2.Timestamp) or 0)
            end)

            local v85 = 0

            for _, v86 in ipairs(tbl27) do
              if fn52(v86, false) then
                v85 += 1
              end
            end

            return v85
          end

          if remotes.NewEntry then
            fn31(remotes.NewEntry.OnClientEvent, function(arg)
              fn52(arg, true)
            end)
          end

          if remotes.ClaimEntry then
            fn31(remotes.ClaimEntry.OnClientEvent, function(arg, arg2, arg3)
              local v85 = fn43(arg)
              local num = tonumber(arg2)
              if not v85 or not num then
                return
              end
              local v86 = entries[v85]
              if not v86 then
                aceFinderRuntime.PendingClaimsByUID[v85] = { UserId = num, DisplayName = arg3, ReceivedAt = os.clock() }
                return
              end
              fn50(v86, num, arg3)
            end)
          end

          fn31(Players.PlayerAdded, function(arg)
            for _, v85 in ipairs(tbl26) do
              local userId = arg.UserId

              if v85.Controller.GetOwnerUserId() == userId then
                fn47(v85, "server")
              end
            end

            fn49(0.15)
          end)

          fn31(Players.PlayerRemoving, function(arg)
            for _, v85 in ipairs(tbl26) do
              local userId = arg.UserId

              if v85.Controller.GetOwnerUserId() == userId then
                fn47(v85, "unknown")
              end
            end

            fn49(0.5)
          end)

          local function fn54(arg)
            if not aceFinderRuntime.Running then
              return
            end

            if arg then
              aceFinderRuntime.InitialEntries = fn53()
              aceFinderRuntime.Status = "READY"
            end

            for _, v85 in ipairs(tbl26) do
              if not v85.Controller.GetOwnerUserId() then
                local v86, v87 = fn51(v85.UID)

                if v86 then
                  fn50(v85, v86, v87)
                end
              end
            end
          end

          fn54(true)
          local n37 = 0
          local n38 = 0
          local n39 = 0

          fn31(RunService2.Heartbeat, function(arg)
            n37 += arg
            n38 += arg
            n39 += arg

            if n37 >= 0.25 then
              n37 = 0
              local serverTimeNow = workspace:GetServerTimeNow()

              for i = #tbl26, 1, -1 do
                local v85 = tbl26[i]
                local n40 = math.max(0, serverTimeNow - v85.SpawnedAt)
                v85.Controller.SetSpawnAge(n40)

                if v85.OnlineController then
                  v85.OnlineController.SetSpawnAge(n40)
                end

                if not v85.Expired and v85.ExpiresAt <= serverTimeNow then
                  v85.Expired = true
                  v85.Controller.SetExpired(true)
                end
              end
            end

            if n38 >= 10 then
              n38 = 0
              fn48()
            end

            if n39 >= 0.75 then
              n39 = 0
              local n40 = os.clock() - 30

              for k, v85 in pairs(aceFinderRuntime.PendingClaimsByUID) do
                local flag16 = type(v85) ~= "table"

                if not flag16 then
                  flag16 = (tonumber(v85.ReceivedAt) or 0) < n40
                end

                if flag16 then
                  aceFinderRuntime.PendingClaimsByUID[k] = nil
                end
              end

              fn54(false)
            end
          end)

          aceFinderRuntime.Unload = function()
            if not aceFinderRuntime.Running then
              return
            end
            aceFinderRuntime.Running = false

            for _, connection in ipairs(aceFinderRuntime.Connections) do
              pcall(function()
                connection:Disconnect()
              end)
            end

            table.clear(aceFinderRuntime.Connections)
            fn32()
          end

          aceFinderRuntime.Remotes = remotes
          aceFinderRuntime.RemoteMapper = aceRemoteMapper
          aceFinderRuntime.Entries = entries
        end

        aceFinderRuntime.SendTrade = sendTrade
        aceFinderRuntime.SendDuel = sendDuel
        aceFinderRuntime.Gui = screenGui2
        aceFinderRuntime.PlayOpenAnimation = playOpenAnimation

        screenGui2.Destroying:Connect(function()
          if genv3.ACEFinderRuntime == aceFinderRuntime then
            aceFinderRuntime.Unload()
          end
        end)

        local function fn43(parent)
          if not parent:IsA("GuiButton") or parent:GetAttribute("ACEClickAnimated") then
            return
          end
          parent:SetAttribute("ACEClickAnimated", true)
          local aceClickScale = parent:FindFirstChild("ACEClickScale")

          if not aceClickScale then
            aceClickScale = Instance.new("UIScale")
            aceClickScale.Name = "ACEClickScale"
            aceClickScale.Scale = 1
            aceClickScale.Parent = parent
          end

          local n36 = 0

          parent.Activated:Connect(function()
            n36 += 1
            local v83 = n36
            TweenService2:Create(aceClickScale, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.92 })
              :Play()

            task.delay(0.07, function()
              if v83 ~= n36 or not aceClickScale.Parent then
                return
              end
              local tbl26 = { Scale = 1 }
              TweenService2:Create(aceClickScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), tbl26):Play()
            end)
          end)
        end

        for _, descendant in ipairs(screenGui2:GetDescendants()) do
          fn43(descendant)
        end

        screenGui2.DescendantAdded:Connect(function(descendant)
          task.defer(fn43, descendant)
        end)
      end

      fn27 = function()
        local v75, v76, v77, v78, v79, localPlayer2, playerGui, flag15, n32, tbl18
        local fn31, tbl19, codeSniper, tbl20, v80, v81, autoSubmit, aiAutoSubmit, backupRiddle, submitAfter
        local tbl21, n33, n34, n35, v82, connection, connection2, tbl22, retypeInvalid, riddleSolver
        local n36, str7, v83, v84, n37, v85, tbl23, fn32, fn33, fn34
        local fn35, str8, net, getupvalues_, v86, n38, flag16, flag17, n39, fn36
        local fn37, tbl24, fn38, fn39, fn40, fn41, fn42, fn43, fn44

        do
          local fn45 = cloneref or function(arg)
            return arg
          end

          local v87 = fn45(game:GetService("Players"))
          v75 = fn45(game:GetService("ReplicatedStorage"))
          v76 = fn45(game:GetService("RunService"))
          v77 = fn45(game:GetService("TweenService"))
          v78 = fn45(game:GetService("UserInputService"))
          local v88 = fn45(game:GetService("HttpService"))
          v79 = fn45(game:GetService("Lighting"))
          localPlayer2 = v87.LocalPlayer
          playerGui = localPlayer2:WaitForChild("PlayerGui")

          if getgenv and getgenv().StopAura then
            pcall(getgenv().StopAura)
          end

          flag15 = false

          pcall(function()
            if v78.TouchEnabled and not v78.KeyboardEnabled then
              local currentCamera = workspace.CurrentCamera
              local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1920, 1080)
              flag15 = math.min(viewportSize.X, viewportSize.Y) < 600
            end
          end)

          n32 = flag15 and 0.6 or 1

          tbl18 = {
            codeSniper = true,
            autoListen = false,
            autoSubmit = true,
            aiAutoSubmit = true,
            backupRiddle = false,
            submitAfter = 3,
            retypeInvalid = false,
            riddleSolver = false,
            backgroundIndex = 2,
            guiScale = flag15 and 1 or 0.92,
            windowPosition = nil,
            optimization = {},
            anchorBind = "",
            autoBuyBind = "",
          }

          pcall(function()
            if type(isfile) == "function" and type(readfile) == "function" and isfile("ace_code_sniper_auto_redeem_test_config.json") then
              local data = v88:JSONDecode(readfile("ace_code_sniper_auto_redeem_test_config.json"))

              if type(data) == "table" then
                if type(data.codeSniper) == "boolean" then
                  tbl18.codeSniper = data.codeSniper
                end

                local v89 = "boolean"

                if type(data.autoListen) == v89 then
                  tbl18.autoListen = data.autoListen
                end

                local v90 = "boolean"

                if type(data.autoSubmit) == v90 then
                  tbl18.autoSubmit = data.autoSubmit
                end

                if type(data.aiAutoSubmit) == "boolean" then
                  tbl18.aiAutoSubmit = data.aiAutoSubmit
                end

                if type(data.backupRiddle) == "boolean" then
                  tbl18.backupRiddle = data.backupRiddle
                end

                if type(data.submitAfter) == "number" then
                  tbl18.submitAfter = math.clamp(math.floor(data.submitAfter), 1, 4)
                end

                if type(data.retypeInvalid) == "boolean" then
                  tbl18.retypeInvalid = data.retypeInvalid
                end

                if type(data.riddleSolver) == "boolean" then
                  tbl18.riddleSolver = data.riddleSolver
                end

                local v91 = "number"

                if type(data.backgroundIndex) == v91 then
                  tbl18.backgroundIndex = math.max(1, math.floor(data.backgroundIndex))
                end

                if type(data.guiScale) == "number" then
                  tbl18.guiScale = math.clamp(data.guiScale, 0.5, 1.5)
                end

                if type(data.optimization) == "table" then
                  for k, v92 in pairs(data.optimization) do
                    local flag18 = type(k) == "string"

                    if flag18 then
                      local v93 = "boolean"
                      flag18 = type(v92) == v93
                    end

                    if flag18 then
                      tbl18.optimization[k] = v92
                    end
                  end
                end

                if type(data.anchorBind) == "string" then
                  tbl18.anchorBind = data.anchorBind
                end

                local v92 = "function"

                if type(data.autoBuyBind) == v92 then
                  tbl18.autoBuyBind = data.autoBuyBind
                end

                if
                  type(data.windowPosition) == "table"
                  and type(data.windowPosition.xScale) == "number"
                  and type(data.windowPosition.xOffset) == "number"
                  and type(data.windowPosition.yScale) == "number"
                  and type(data.windowPosition.yOffset) == "number"
                then
                  tbl18.windowPosition = {
                    xScale = data.windowPosition.xScale,
                    xOffset = data.windowPosition.xOffset,
                    yScale = data.windowPosition.yScale,
                    yOffset = data.windowPosition.yOffset,
                  }
                end
              end
            end
          end)

          fn31 = function()
            if type(writefile) ~= "function" then
              return
            end

            pcall(function()
              writefile(
                "ace_code_sniper_auto_redeem_test_config.json",
                v88:JSONEncode({
                  codeSniper = tbl18.codeSniper,
                  autoListen = tbl18.autoListen,
                  autoSubmit = tbl18.autoSubmit,
                  aiAutoSubmit = tbl18.aiAutoSubmit,
                  backupRiddle = tbl18.backupRiddle,
                  submitAfter = tbl18.submitAfter,
                  retypeInvalid = tbl18.retypeInvalid,
                  riddleSolver = tbl18.riddleSolver,
                  backgroundIndex = tbl18.backgroundIndex,
                  guiScale = tbl18.guiScale,
                  windowPosition = tbl18.windowPosition,
                  optimization = tbl18.optimization,
                  anchorBind = tbl18.anchorBind,
                  autoBuyBind = tbl18.autoBuyBind,
                })
              )
            end)
          end

          tbl19 = {
            enabled = tbl18.autoListen,
            armed = false,
            token = 0,
            timeout = 120,
            cooldown = 8,
            readyAt = 0,
            windowLimit = 6,
            windowGap = 12,
            window = {},
            windowAt = 0,
            driving = false,
            patterns = {},
            strongPatterns = {},
            triggers = {
              "code is",
              "codes is",
              "the code is",
              "use code",
              "use the code",
              "use this code",
              "using code",
              "enter code",
              "enter the code",
              "enter this code",
              "type code",
              "type the code",
              "type this code",
              "type in",
              "paste the code",
              "paste this code",
              "copy the code",
              "copy this code",
              "write this down",
              "next code",
              "new code",
              "another code",
              "code time",
              "code drop",
              "dropping a code",
              "drop a code",
              "dropping code",
              "free code",
              "secret code",
              "bonus code",
              "gift code",
              "promo code",
              "special code",
              "limited code",
              "exclusive code",
              "quick code",
              "first code",
              "last code",
              "final code",
              "one more code",
              "code word",
              "codeword",
              "code number",
              "code below",
              "code coming",
              "code incoming",
              "incoming code",
              "code for you",
              "code will be",
              "here is the code",
              "heres the code",
              "here's the code",
              "got a code",
              "have a code",
              "get this code",
              "take this code",
              "typing a code",
              "spelling a code",
              "spelling out",
              "spelling it out",
              "letter by letter",
              "redeem code",
              "redeem the code",
              "redeem this",
              "redeem this code",
              "redeem it",
              "claim this",
              "claim the code",
              "claim your",
              "grab this",
              "open your codes",
              "open the codes",
              "codes menu",
              "code alert",
              "code activated",
              "code released",
              "releasing a code",
              "releasing the code",
              "new drop",
              "big drop",
              "drop incoming",
              "drop time",
              "reward code",
              "event code",
              "update code",
              "daily code",
              "weekend code",
              "birthday code",
              "milestone code",
              "sammy code",
              "want a code",
              "who wants a code",
              "need a code",
              "code hunt",
              "in the chat",
              "watch the chat",
              "watch chat",
              "eyes on chat",
              "chat code",
              "coming up",
              "next up",
              "here it comes",
              "here goes",
              "here you go",
              "one word at a time",
              "word by word",
              "piece by piece",
              "in parts",
              "in pieces",
              "first part",
              "second part",
              "third part",
              "last part",
              "final part",
              "part one",
              "part two",
              "start typing",
              "get typing",
              "keyboard ready",
              "on three",
              "count of three",
              "3 2 1",
              "riddle",
              "riddles",
              "riddle me",
              "riddle time",
              "next riddle",
              "new riddle",
              "another riddle",
              "last riddle",
              "final riddle",
              "bonus riddle",
              "riddle number",
              "one more riddle",
              "brain teaser",
              "brainteaser",
              "quiz",
              "quiz time",
              "pop quiz",
              "solve this",
              "solve it",
              "solve the",
              "decode this",
              "decode it",
              "figure this out",
              "figure it out",
              "work it out",
              "answer this",
              "answer the",
              "answer is",
              "the answer",
              "the question is",
              "correct answer",
              "right answer",
              "guess this",
              "guess the",
              "guess what",
              "question",
              "trivia",
              "puzzle",
              "unscramble",
              "scrambled",
              "word scramble",
              "jumbled",
              "anagram",
              "math",
              "spell",
              "true or false",
              "odd one out",
              "complete the",
              "finish the",
              "rhymes with",
              "starts with",
              "ends with",
              "count the",
              "sum of",
              "add up",
              "multiply",
              "divide",
              "subtract",
              "equals",
              "what am i",
              "what has",
              "what is",
              "what goes",
              "what number",
              "what word",
              "whats the",
              "what's the",
              "who am i",
              "who's the",
              "whos the",
              "which one",
              "how many",
              "how much",
              "name the",
              "fill in the blank",
              "lets test",
              "let's test",
              "test your",
              "think fast",
              "think you know",
              "bet you cant",
              "bet you can't",
              "can you solve",
              "can you guess",
              "can you name",
              "can you answer",
              "who knows",
              "anyone know",
              "does anyone know",
              "tell me the",
              "type the answer",
              "answer fast",
              "answer quickly",
              "first correct",
              "correct answer gets",
              "no googling",
              "no cheating",
              "listen up",
              "pay attention",
              "attention",
              "heads up",
              "eyes up",
              "eyes here",
              "look here",
              "get ready",
              "ready up",
              "here we go",
              "here comes",
              "hurry",
              "be quick",
              "be fast",
              "type fast",
              "type quick",
              "hands on your keyboard",
              "first to type",
              "first to say",
              "first to answer",
              "first person to",
              "first one to",
              "fastest",
              "quickest",
              "whoever gets",
              "whoever types",
              "whoever answers",
              "giveaway",
              "for free",
              "win a",
              "the winner",
              "prize",
              "reward",
              "codigo es",
              "el codigo es",
              "codigo nuevo",
              "nuevo codigo",
              "codigo gratis",
              "usa el codigo",
              "usen el codigo",
              "usa este codigo",
              "escribe el codigo",
              "escriban el codigo",
              "aqui esta el codigo",
              "canjea",
              "canjear",
              "canjeen",
              "acertijo",
              "adivinanza",
              "adivina",
              "la respuesta es",
              "responde",
              "respondan",
              "pregunta",
              "el primero en",
              "atencion",
              "preparados",
              "preparense",
              "recompensa",
              "premio",
              "regalo",
              "codigo e",
              "o codigo e",
              "codigo novo",
              "novo codigo",
              "use o codigo",
              "usem o codigo",
              "digite o codigo",
              "aqui esta o codigo",
              "resgate",
              "resgatar",
              "adivinha",
              "adivinhe",
              "charada",
              "a resposta e",
              "responda",
              "o primeiro a",
              "premiacao",
              "code est",
              "le code est",
              "nouveau code",
              "code gratuit",
              "voici le code",
              "utilise le code",
              "utilisez le code",
              "tapez le code",
              "echangez",
              "enigme",
              "devinette",
              "la reponse est",
              "repondez",
              "le premier a",
              "recompense",
              "cadeau",
              "code ist",
              "der code ist",
              "neuer code",
              "gratis code",
              "hier ist der code",
              "code eingeben",
              "gib den code",
              "einlosen",
              "ratsel",
              "die antwort ist",
              "antworte",
              "frage",
              "der erste",
              "achtung",
              "belohnung",
              "geschenk",
              "codice e",
              "il codice e",
              "nuovo codice",
              "codice gratis",
              "usa il codice",
              "ecco il codice",
              "riscatta",
              "indovinello",
              "la risposta e",
              "rispondi",
              "domanda",
              "il primo a",
              "attenzione",
              "ricompensa",
              "de code is",
              "nieuwe code",
              "hier is de code",
              "raadsel",
              "het antwoord is",
              "beloning",
              "kod to",
              "nowy kod",
              "darmowy kod",
              "wpisz kod",
              "zagadka",
              "odpowiedz to",
              "nagroda",
              "yeni kod",
              "bedava kod",
              "kodu kullan",
              "iste kod",
              "bilmece",
              "bulmaca",
              "cevap",
              "odul",
              "kodenya",
              "kode baru",
              "kode gratis",
              "gunakan kode",
              "teka teki",
              "tebak",
              "jawabannya",
              "hadiah",
              "ang code ay",
              "bagong code",
              "libreng code",
              "bugtong",
              "sagot ay",
              "premyo",
              "ma la",
              "code moi",
              "ma moi",
              "mien phi",
              "cau do",
              "dap an",
              "tra loi",
              "phan thuong",
              "codul este",
              "cod nou",
              "ghicitoare",
              "raspunsul este",
              "premiu",
              "код это",
              "новый код",
              "бесплатный код",
              "введите код",
              "загадка",
              "ответ",
              "награда",
              "приз",
            },
          }

          local tbl25 = { ["ß"] = "ss" }

          for k, v89 in pairs({
            a = "àáâãäåĀĂĄÀÁÂÃÄÅāăą",
            e = "èéêëĒĔĖĘĚÈÉÊËēĕėęě",
            i = "ìíîïĨĪĬĮıÌÍÎÏĩīĭįİ",
            o = "òóôõöøŌŎŐÒÓÔÕÖØōŏő",
            u = "ùúûüŨŪŬŮŰŲÙÚÛÜũūŭůűų",
            y = "ýÿŷÝŶŸ",
            c = "çćĉċčÇĆĈĊČ",
            d = "ďđĎĐ",
            g = "ĝğġģĜĞĠĢ",
            l = "ĺļľłŀĹĻĽŁĿ",
            n = "ñńņňÑŃŅŇ",
            r = "ŕŗřŔŖŘ",
            s = "śŝşšŚŜŞŠ",
            t = "ţťŧŢŤŦ",
            z = "źżžŹŻŽ",
          }) do
            for match in v89:gmatch("[\194-\244][\128-\191]*") do
              tbl25[match] = k
            end
          end

          tbl19.normalize = function(arg)
            return " "
              .. tostring(arg or "")
                :gsub("[\194-\244][\128-\191]*", function(arg2)
                  return tbl25[arg2] or arg2
                end)
                :lower()
                :gsub("[^%w\128-\255]+", " ")
                :gsub("^%s+", "")
                :gsub("%s+$", "")
              .. " "
          end

          tbl19.push = function(arg)
            local windowAt = tbl19.windowAt

            if os.clock() - windowAt > tbl19.windowGap then
              tbl19.window = {}
            end

            tbl19.windowAt = os.clock()
            tbl19.window[#tbl19.window + 1] = arg

            while tbl19.windowLimit < #tbl19.window do
              table.remove(tbl19.window, 1)
            end

            return table.concat(tbl19.window, " ")
          end

          tbl19.match = function(arg)
            if #tbl19.patterns == 0 then
              for _, trigger in ipairs(tbl19.triggers) do
                local v89 = tbl19.normalize(trigger)

                if #v89 > 2 then
                  tbl19.patterns[#tbl19.patterns + 1] = v89

                  if not tbl19.isWeak(v89:match("^%s*(.-)%s*$")) then
                    tbl19.strongPatterns[#tbl19.strongPatterns + 1] = v89
                  end
                end
              end
            end

            local v89 = tbl19.normalize(arg)

            for _, strongPattern in ipairs(tbl19.strongPatterns) do
              if v89:find(strongPattern, 1, true) then
                return (strongPattern:match("^%s*(.-)%s*$"))
              end
            end

            for _, pattern in ipairs(tbl19.patterns) do
              if v89:find(pattern, 1, true) then
                return (pattern:match("^%s*(.-)%s*$"))
              end
            end

            return nil
          end

          tbl19.weak = {
            "answer is",
            "the answer",
            "answer the",
            "correct answer",
            "right answer",
            "the question is",
            "correct answer gets",
            "equals",
            "prize",
            "reward",
            "the winner",
            "win a",
            "giveaway",
            "for free",
            "riddle",
            "riddles",
            "question",
            "trivia",
            "puzzle",
            "quiz",
            "math",
            "spell",
            "attention",
            "pay attention",
            "hurry",
            "fastest",
            "quickest",
            "la respuesta es",
            "responde",
            "respondan",
            "pregunta",
            "recompensa",
            "premio",
            "regalo",
            "acertijo",
            "adivinanza",
            "adivina",
            "atencion",
            "preparados",
            "preparense",
            "a resposta e",
            "responda",
            "premiacao",
            "adivinha",
            "adivinhe",
            "charada",
            "la reponse est",
            "repondez",
            "recompense",
            "cadeau",
            "enigme",
            "devinette",
            "die antwort ist",
            "antworte",
            "frage",
            "belohnung",
            "geschenk",
            "ratsel",
            "achtung",
            "la risposta e",
            "rispondi",
            "domanda",
            "attenzione",
            "ricompensa",
            "indovinello",
            "het antwoord is",
            "raadsel",
            "beloning",
            "odpowiedz to",
            "zagadka",
            "nagroda",
            "cevap",
            "bilmece",
            "bulmaca",
            "odul",
            "jawabannya",
            "tebak",
            "teka teki",
            "hadiah",
            "sagot ay",
            "bugtong",
            "premyo",
            "dap an",
            "tra loi",
            "phan thuong",
            "cau do",
            "raspunsul este",
            "ghicitoare",
            "premiu",
          }

          tbl19.weakSet = nil

          tbl19.isWeak = function(arg)
            if not tbl19.weakSet then
              tbl19.weakSet = {}

              for _, v89 in ipairs(tbl19.weak) do
                local v90 = true
                tbl19.weakSet[tbl19.normalize(v89):match("^%s*(.-)%s*$")] = v90
              end

              for _, v89 in ipairs({ "ответ", "загадка", "награда", "приз" }) do
                tbl19.weakSet[tbl19.normalize(v89):match("^%s*(.-)%s*$")] = true
              end
            end

            return tbl19.weakSet[arg] == true
          end

          tbl19.arm = function(arg)
            if tbl19.armed then
              return
            end
            tbl19.armed = true
            tbl19.token = tbl19.token + 1
            tbl19.window = {}

            if clearAceCapture then
              clearAceCapture()
            end

            if tbl19.setTargets then
              tbl19.setTargets(true)
            end

            _lastStatusMsg = nil
            local green = COLORS.Green
            setStatus('LIVE - heard "' .. tostring(arg) .. '"', green)
            local token = tbl19.token

            task.delay(tbl19.timeout, function()
              if tbl19.armed and tbl19.token == token then
                tbl19.disarm("nothing landed")
              end
            end)
          end

          tbl19.disarm = function()
            if not tbl19.enabled then
              return
            end
            tbl19.armed = false
            tbl19.token = tbl19.token + 1
            local cooldown = tbl19.cooldown
            tbl19.readyAt = os.clock() + cooldown
            tbl19.window = {}

            if clearAceCapture then
              clearAceCapture()
            end

            if tbl19.setTargets then
              tbl19.setTargets(false)
            end

            _lastStatusMsg = nil
            setStatus("Sniper + riddles OFF - waiting for Sammy", COLORS.Dim)
          end

          tbl19.setEnabled = function(arg)
            tbl19.enabled = arg and true or false
            tbl19.armed = false
            tbl19.token = tbl19.token + 1
            tbl19.readyAt = 0
            tbl18.autoListen = tbl19.enabled
            fn31()

            if tbl19.setTargets then
              if tbl19.enabled then
                tbl19.setTargets(false)
              else
                tbl19.setTargets(nil)
              end
            end

            if tbl19.refreshRow then
              tbl19.refreshRow()
            end
          end

          tbl19.yield = function()
            if tbl19.driving or not tbl19.enabled then
              return
            end
            tbl19.enabled = false
            tbl19.armed = false
            tbl19.token = tbl19.token + 1
            tbl18.autoListen = false
            fn31()

            if tbl19.refreshRow then
              tbl19.refreshRow()
            end

            _lastStatusMsg = nil
            setStatus("Auto listen off - manual control", COLORS.Dim)
          end

          codeSniper = tbl18.codeSniper

          if tbl19.enabled then
            codeSniper = false
          end

          tbl20 = {}
          v80 = nil
          v81 = nil
          autoSubmit = tbl18.autoSubmit
          aiAutoSubmit = tbl18.aiAutoSubmit
          backupRiddle = tbl18.backupRiddle

          if backupRiddle and not aiAutoSubmit then
            aiAutoSubmit = true
            tbl18.aiAutoSubmit = true
            fn31()
          end

          submitAfter = tbl18.submitAfter
          tbl21 = {}
          n33 = 0
          n34 = 0
          n35 = 0
          v82 = nil
          connection = nil
          connection2 = nil
          tbl22 = {}
          retypeInvalid = tbl18.retypeInvalid

          if backupRiddle and retypeInvalid then
            retypeInvalid = false
            tbl18.retypeInvalid = false
            fn31()
          end

          riddleSolver = tbl18.riddleSolver
          n36 = 0

          if tbl19.enabled then
            riddleSolver = false
          end

          str7 = ""
          v83 = nil
          v84 = nil
          n37 = 0
          v85 = 0
          tbl23 = { "Codes", "Codes", "CodeRedeem", "TextBox" }
          fn32 = nil
          fn33 = nil
          fn34 = nil
          fn35 = nil
          str8 = nil
          net = v75:WaitForChild("Packages"):WaitForChild("Net")
          getupvalues_ = debug and debug.getupvalues or getupvalues
          local v89 = getconnections
          local getconnections_

          if v89 then
            getconnections_ = v89
          else
            getconnections_ = debug and debug.getconnections
          end

          local setupvalue_ = debug and debug.setupvalue or setupvalue
          local v90 = nil
          v86 = nil
          n38 = 0
          flag16 = false
          flag17 = false
          n39 = 0
          local v91 = nil

          fn36 = function()
            if v91 then
              return v91
            end
            local v92 = nil

            local function fn46(arg)
              if v92 then
                return
              end
              local ok, result = pcall(arg)

              if ok and type(result) == "function" then
                v92 = result
              end
            end

            fn46(function()
              return request
            end)

            fn46(function()
              return http_request
            end)

            fn46(function()
              return httprequest
            end)

            fn46(function()
              return syn and syn.request
            end)

            fn46(function()
              return http and http.request
            end)

            fn46(function()
              return fluxus and fluxus.request
            end)

            fn46(function()
              return krnl and krnl.request
            end)

            local genv3 = nil

            pcall(function()
              if type(getgenv) == "function" then
                genv3 = getgenv()
              end
            end)

            if genv3 then
              fn46(function()
                return genv3.request
              end)

              fn46(function()
                return genv3.http_request
              end)

              fn46(function()
                return genv3.httprequest
              end)

              fn46(function()
                return genv3.syn and genv3.syn.request
              end)

              fn46(function()
                return genv3.http and genv3.http.request
              end)

              fn46(function()
                return genv3.fluxus and genv3.fluxus.request
              end)
            end

            v91 = v92
            return v92
          end

          fn37 = function()
            local str9 = nil

            pcall(function()
              local v92 = "function"

              if type(identifyexecutor) == v92 then
                str9 = tostring(identifyexecutor())
              else
                local v93 = "function"

                if type(getexecutorname) == v93 then
                  str9 = tostring(getexecutorname())
                end
              end
            end)

            local v92 = "function"
            if type(str9) ~= v92 or str9 == "" then
              return "this executor"
            end
            return str9
          end

          tbl24 = {
            Enabled = true,
            AIRiddles = true,
            AutoTypeCodes = true,
            AutoSubmit = true,
            SubmitAfter = 3,
            AIAutoSubmit = true,
            RaceModels = false,
            PrimaryModel = "gemini-3.1-flash-lite",
            BackupModel = "gemini-3.1-flash-lite",
            RiddleURL = "https://qwen-riddle-solver.kellygrant0527.workers.dev",
            RiddleToken = "OU5sbdQj9CWPkaPRIiCby2icOmR_Q4zMQt9ZX58TOWE",
          }

          fn38 = function(arg, arg2)
            local v92 = fn36()
            if not v92 then
              return { error = "no HTTP function on " .. fn37() .. " - AI riddles need request / http_request" }
            end
            local str9 = tbl24.RiddleURL:gsub("/+$", "")
            local str10 = "/" .. tostring(arg):gsub("^/+", "")
            local json = v88:JSONEncode(arg2)
            local tbl26 = { ["Content-Type"] = "application/json", Authorization = "Bearer " .. tbl24.RiddleToken }

            local ok, result, result2 = pcall(v92, {
              Url = str9 .. str10,
              url = str9 .. str10,
              Method = "POST",
              method = "POST",
              Headers = tbl26,
              headers = tbl26,
              Body = json,
              body = json,
            })

            if not ok then
              local ok2, result3
              ok2, result3, result2 = pcall(v92, { Url = str9 .. str10, Method = "POST", Headers = tbl26, Body = json })
              if not ok2 then
                return { error = "HTTP request failed: " .. tostring(result) }
              end
              result = result3
            end

            local body, httpStatus

            if type(result) == "string" then
              body = result
              httpStatus = tonumber(result2)
            else
              if type(result) ~= "table" then
                return { error = "executor returned no HTTP response" }
              end

              httpStatus = tonumber(result.StatusCode or result.Status or result.status_code or result.statusCode)
              body = result.Body or result.body or result.Response or result.response
            end

            if type(body) ~= "string" then
              return { error = "Worker returned no response body", httpStatus = httpStatus }
            end

            local ok2, result3 = pcall(function()
              return v88:JSONDecode(body)
            end)

            if ok2 and type(result3) == "table" then
              result3.httpStatus = httpStatus
              return result3
            end
            return { error = "Worker returned invalid JSON", httpStatus = httpStatus }
          end

          fn39 = function(arg)
            if arg == nil then
              return nil
            end
            local str9 = tostring(arg):upper():gsub("[%s%?%.%,!\"'`\n\r]+", "")
            if str9 == "" then
              return nil
            end
            return str9
          end

          fn40 = function()
            local function fn46(arg)
              return typeof(arg) == "Instance" and arg:IsA("TextBox") and arg.Parent ~= nil
            end

            local function fn47(arg)
              return fn46(arg) and arg.Parent.Name == "CodeRedeem"
            end

            local function fn48(arg)
              while arg do
                if arg:IsA("GuiObject") and arg.Visible == false then
                  return false
                end

                if arg:IsA("ScreenGui") and arg.Enabled == false then
                  return false
                end
                arg = arg.Parent
              end

              return true
            end

            local focusedTextBox = v78:GetFocusedTextBox()
            if fn47(focusedTextBox) then
              return focusedTextBox
            end
            local v92 = nil

            for _, descendant in ipairs(playerGui:GetDescendants()) do
              if fn47(descendant) then
                if fn48(descendant) then
                  return descendant
                end
                v92 = v92 or descendant
              end
            end

            local codes = playerGui:FindFirstChild("Codes")

            if codes then
              local codeRedeem = (codes:FindFirstChild("Codes") or codes):FindFirstChild("CodeRedeem")
              local textBox = codeRedeem and codeRedeem:FindFirstChild("TextBox")
              if fn46(textBox) then
                return textBox
              end

              for _, descendant in ipairs(codes:GetDescendants()) do
                if fn46(descendant) then
                  return descendant
                end
              end
            end

            return v92
          end

          local function fn46()
            if v90 and v90.Parent then
              return v90
            end
            local RemoteFunction = aceRemoteMapper:Resolve("RemoteFunction", "7d14a912-1040-4867-b005-98838eb9acc4", 2.5)
            if typeof(RemoteFunction) == "Instance" and RemoteFunction:IsA("RemoteFunction") then
              v90 = RemoteFunction
              return v90
            end
            local ok, result = pcall(require, net)

            if ok and type(result) == "table" then
              local ok2, result2 = pcall(function()
                return result:RemoteFunction("7d14a912-1040-4867-b005-98838eb9acc4")
              end)

              local flag18

              if ok2 then
                local v92 = "Instance"
                flag18 = typeof(result2) == v92
              else
                flag18 = ok2
              end

              if flag18 and result2:IsA("RemoteFunction") then
                if aceRemoteMapper:IsSentinel(result2.Name) then
                  aceRemoteMapper:Trip("sentinel redeem remote")
                else
                  v90 = result2
                  aceRemoteMapper:Register("RemoteFunction", "7d14a912-1040-4867-b005-98838eb9acc4", result2)
                end
              end
            end

            return v90
          end

          local function fn47(arg)
            if not (arg and setupvalue_ and getupvalues_) then
              return
            end
            local ok, result = pcall(getupvalues_, arg)

            if ok and type(result) == "table" then
              for k, v92 in pairs(result) do
                if type(v92) == "boolean" then
                  pcall(setupvalue_, arg, k, false)
                end
              end
            end
          end

          fn41 = function(text)
            if not getconnections_ then
              return false, "no getconnections"
            end
            local v92 = fn40()
            if not v92 then
              return false, "no codebox"
            end
            local ok, result = pcall(getconnections_, v92.FocusLost)
            if not ok or type(result) ~= "table" or #result == 0 then
              return false, "no connection"
            end
            local flag18 = false

            for _, v93 in ipairs(result) do
              local function_ = nil

              pcall(function()
                function_ = v93.Function
              end)

              fn47(function_)
              v92.Text = text
              v92.Active = true
              v92.Selectable = true
              local flag19 = true

              pcall(function()
                flag19 = v93.Enabled ~= false
              end)

              local ok2 = flag19 and pcall(function()
                v93:Fire(true)
              end)

              if flag19 and ok2 then
                flag18 = true
                break
              else
              end
            end

            return flag18, flag18 and "sent" or "fire failed"
          end

          fn42 = function()
            return v78.TouchEnabled and not v78.KeyboardEnabled
          end

          local function fn48(arg)
            while arg do
              if arg:IsA("GuiObject") and not arg.Visible then
                return false
              end

              if arg:IsA("ScreenGui") then
                return arg.Enabled
              end
              arg = arg.Parent
            end

            return true
          end

          local function fn49(arg)
            if not arg then
              return false
            end

            local ok = pcall(function()
              arg.MouseButton1Click:Fire()
            end)

            ok = ok or false

            local ok2 = pcall(function()
              arg.Activated:Fire()
            end) or ok

            if type(firesignal) == "function" then
              local ok3 = pcall(firesignal, arg.MouseButton1Click) or ok2
              ok2 = pcall(firesignal, arg.Activated) or ok3
            end

            if getconnections_ then
              for _, v92 in ipairs({ arg.MouseButton1Click, arg.Activated }) do
                local ok3, result = pcall(getconnections_, v92)

                if ok3 and type(result) == "table" then
                  for _, v93 in ipairs(result) do
                    local flag18 = true

                    pcall(function()
                      flag18 = v93.Enabled ~= false
                    end)

                    if flag18 then
                      ok2 = pcall(function()
                        v93:Fire()
                      end) or ok2
                    end
                  end
                end
              end
            end

            if type(fireclick) == "function" then
              ok2 = pcall(fireclick, arg) or ok2
            end

            return ok2
          end

          local function fn50(arg)
            local ok = false

            if type(firesignal) == "function" then
              ok = pcall(firesignal, arg.FocusLost, true) or ok
            end

            local v92

            if getconnections_ then
              local ok2, result = pcall(getconnections_, arg.FocusLost)

              if ok2 and type(result) == "table" then
                for _, v93 in ipairs(result) do
                  local function_ = nil

                  pcall(function()
                    function_ = v93.Function
                  end)

                  fn47(function_)
                  local flag18 = true

                  pcall(function()
                    flag18 = v93.Enabled ~= false
                  end)

                  if flag18 then
                    ok = pcall(function()
                      v93:Fire(true)
                    end) or ok
                  end
                end

                v92 = ok
              else
                v92 = ok
              end
            else
              v92 = ok
            end

            return v92
          end

          fn43 = function(text)
            local codes = playerGui:FindFirstChild("Codes")
            if not codes then
              return false, "no codes gui"
            end

            if codes:IsA("ScreenGui") then
              codes.Enabled = true
            end

            local codes2 = codes:FindFirstChild("Codes") or codes

            if codes2:IsA("GuiObject") then
              codes2.Visible = true
            end

            local v92 = fn40()
            if not v92 then
              return false, "no codebox"
            end
            v92.Text = text
            v92.Active = true
            v92.Selectable = true
            task.wait(0.1)
            local v93 = nil

            for _, descendant in ipairs(codes2:GetDescendants()) do
              if (descendant:IsA("TextButton") or descendant:IsA("ImageButton")) and fn48(descendant) then
                local str9 = descendant.Name:lower()
                local str10 = ""

                pcall(function()
                  str10 = descendant.Text:lower()
                end)

                if
                  str9:find("submit", 1, true)
                  or str9:find("redeem", 1, true)
                  or str9:find("claim", 1, true)
                  or str9:find("confirm", 1, true)
                  or str9:find("enter", 1, true)
                  or str10:find("submit", 1, true)
                  or str10:find("redeem", 1, true)
                  or str10:find("claim", 1, true)
                  or str10:find("confirm", 1, true)
                  or str10:find("enter", 1, true)
                then
                  v93 = descendant
                  break
                else
                  v93 = nil
                end
              else
                v93 = nil
              end
            end

            local v94 = fn49(v93)
            local v95 = fn50(v92)
            return v94 or v95, (v94 or v95) and "submitted via mobile auto-enter" or "mobile auto-enter failed"
          end

          fn44 = function(arg)
            local v92 = fn46()
            if not v92 then
              return false, "no remote", false
            end

            local ok, result, result2 = pcall(function()
              return v92:InvokeServer(arg)
            end)

            if not ok then
              return false, tostring(result), false
            end
            result2 = type(result2) == "string" and result2 or nil
            if result == false then
              return false, result2 or "rejected", true
            end
            return true, result2 or result, true
          end
        end

        local fn45

        fn45 = function(arg)
          n39 += 1
          local v87 = n39
          v86 = arg
          n38 = os.clock()
          flag16 = false
          flag17 = false

          task.delay(12, function()
            if v87 == n39 then
              v86 = nil
              flag17 = false
            end
          end)

          if fn42() then
            return fn43(arg)
          end
          local v88, v89 = fn41(arg)
          if v88 then
            return true, v89
          end
          local v90, v91 = fn44(arg)
          if v90 then
            return true, v91
          end
          return false, v91 or v89
        end

        local tbl25

        tbl25 = {
          Window = Color3.fromRGB(6, 6, 7),
          Row = Color3.fromRGB(15, 15, 17),
          Control = Color3.fromRGB(35, 35, 39),
          Log = Color3.fromRGB(10, 10, 16),
          Border = Color3.fromRGB(82, 82, 89),
          White = Color3.fromRGB(245, 245, 245),
          Text = Color3.fromRGB(190, 190, 196),
          Dim = Color3.fromRGB(120, 120, 130),
          Accent = Color3.fromRGB(245, 245, 245),
          Green = Color3.fromRGB(70, 210, 100),
          Red = Color3.fromRGB(255, 70, 70),
        }

        local fn46

        fn46 = function(parent, arg)
          local instance = Instance.new("UICorner")
          instance.CornerRadius = UDim.new(0, arg)
          instance.Parent = parent
          return instance
        end

        local createUIStroke2

        createUIStroke2 = function(parent, color, thickness, transparency)
          local uiStroke = Instance.new("UIStroke")
          uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
          uiStroke.Color = color
          uiStroke.Thickness = thickness or 1
          uiStroke.Transparency = transparency or 0
          uiStroke.Parent = parent
          return uiStroke
        end

        local createTextLabel

        createTextLabel = function(parent, name, text, size, position, textSize, textColor3, font)
          local textLabel = Instance.new("TextLabel")
          textLabel.Name = name
          textLabel.Size = size
          textLabel.Position = position
          textLabel.BackgroundTransparency = 1
          textLabel.Text = text
          textLabel.TextSize = textSize
          textLabel.TextColor3 = textColor3
          textLabel.Font = font or Enum.Font.GothamMedium
          textLabel.TextXAlignment = Enum.TextXAlignment.Left
          textLabel.TextYAlignment = Enum.TextYAlignment.Center
          textLabel.Parent = parent
          return textLabel
        end

        local fn47

        fn47 = function(parent)
          local uiScale = Instance.new("UIScale")
          uiScale.Name = "PressScale"
          uiScale.Parent = parent

          parent.MouseButton1Down:Connect(function()
            v77:Create(uiScale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.92 }):Play()
          end)

          local function fn48()
            v77:Create(uiScale, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
            return
          end

          parent.MouseButton1Up:Connect(fn48)
          parent.MouseLeave:Connect(fn48)
        end

        fn30(playerGui, "ACECodeSniperUI", "AutoTypeCodesUI", "ACEPaste")
        local screenGui2
        screenGui2 = Instance.new("ScreenGui")
        screenGui2.Name = "ACECodeSniperUI"
        screenGui2.ResetOnSpawn = false
        screenGui2.IgnoreGuiInset = true
        screenGui2.DisplayOrder = 2147483646
        screenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Global

        pcall(function()
          screenGui2.OnTopOfCoreBlur = true
        end)

        fn29(screenGui2, playerGui)

        if getgenv then
          getgenv().ACECodeSniperGui = screenGui2
        end

        local frame2
        frame2 = Instance.new("Frame")
        frame2.Name = "Window"
        frame2.Size = UDim2.fromOffset(310, 446)
        frame2.AnchorPoint = Vector2.new(1, 0)

        if tbl18.windowPosition then
          local windowPosition = tbl18.windowPosition
          frame2.Position = UDim2.new(windowPosition.xScale, windowPosition.xOffset, windowPosition.yScale, windowPosition.yOffset)
        else
          frame2.Position = UDim2.new(1, -8, 0, 8)
        end

        frame2.BackgroundColor3 = tbl25.Window
        frame2.BorderSizePixel = 0
        frame2.ClipsDescendants = true
        frame2.Parent = screenGui2
        fn46(frame2, 14)
        createUIStroke2(frame2, tbl25.White, 1, 0.58)
        local uiScale
        uiScale = Instance.new("UIScale")
        uiScale.Name = "InterfaceScale"
        uiScale.Scale = tbl18.guiScale * n32
        uiScale.Parent = frame2
        local fn48

        do
          local connection3 = nil

          fn48 = function()
            local scale = tbl18.guiScale * n32
            local currentCamera = workspace.CurrentCamera
            if not currentCamera then
              uiScale.Scale = scale
              return
            end
            local viewportSize = currentCamera.ViewportSize
            local n40 = math.min(
              (viewportSize.X - 16) / 310,
              (viewportSize.Y - 16) / math.max(tonumber(frame2:GetAttribute("ACEWindowHeight")) or 446, 260)
            )
            uiScale.Scale = math.max(flag15 and 0.28 or 0.35, math.min(scale, n40))
          end

          local function fn49()
            if connection3 then
              connection3:Disconnect()
              connection3 = nil
            end

            local currentCamera = workspace.CurrentCamera

            if currentCamera then
              connection3 = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fn48)
            end

            fn48()
          end

          workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(fn49)
          fn49()
        end

        local imageLabel
        imageLabel = Instance.new("ImageLabel")
        imageLabel.Name = "Background"
        imageLabel.Size = UDim2.new(1, 0, 1, 0)
        imageLabel.Position = UDim2.fromOffset(0, 0)
        imageLabel.BackgroundTransparency = 1
        local tbl26

        tbl26 = {
          { Name = "NONE", Image = "", IsNone = true },
          { Name = "1", Image = "rbxassetid://137692455767789" },
          { Name = "2", Image = "rbxassetid://128081130356834" },
          { Name = "3", Image = "rbxassetid://120480454937730" },
          { Name = "4", Image = "rbxassetid://85127407374728" },
          { Name = "5", Image = "rbxassetid://107291541054530" },
          { Name = "6", Image = "rbxassetid://124230165619007" },
          { Name = "7", Image = "rbxassetid://87766822871097" },
          { Name = "8", Image = "rbxassetid://90280869222992" },
          { Name = "9", Image = "rbxassetid://126860692354524" },
          { Name = "10", Image = "rbxassetid://105131079571166" },
          { Name = "11", Image = "rbxassetid://108751216016989" },
        }

        tbl18.backgroundIndex = math.clamp(tbl18.backgroundIndex, 1, #tbl26)
        local v87 = tbl26[tbl18.backgroundIndex]
        imageLabel.Image = v87.Image
        imageLabel.Visible = not v87.IsNone
        imageLabel.ImageTransparency = 0
        imageLabel.ScaleType = Enum.ScaleType.Stretch
        imageLabel.ZIndex = 1
        imageLabel.Parent = frame2
        fn46(imageLabel, 14)

        do
          local v88 = createFrame

          local tbl27 = {
            Count = flag15 and 7 or v78.TouchEnabled and not v78.KeyboardEnabled and 10 or 14,
            ZIndex = 90,
            MinDuration = 5.8,
            MaxDuration = 9.2,
          }

          local visible = tbl18.optimization.fallingParticles ~= false
          v88(frame2, tbl27).Visible = visible
        end

        local frame3
        frame3 = Instance.new("Frame")
        frame3.Name = "Header"
        frame3.Size = UDim2.new(1, 0, 0, 64)
        frame3.BackgroundTransparency = 1
        frame3.Active = true
        frame3.ZIndex = 3
        frame3.Parent = frame2
        local instance
        instance = nil
        local textLabel
        textLabel = nil
        local tbl27
        tbl27 = {}
        local v88
        v88 = 0
        local fn49
        fn49 = nil
        local tbl28, tbl29, fn50
        local n40 = 0

        tbl28 = {
          chromeH = 98,
          footerBand = 37,
          statusH = 12,
          statusGap = 6,
          clearRowH = 28,
          clearRow = nil,
          maxContent = 362,
          tabHeights = { MAIN = 446, FARM = 236, SETTINGS = 402 },
          activeTab = "MAIN",
          windowHeight = 446,
          minimized = false,
          gap = 8,
          notifHeaderH = 24,
          notifCollapsedH = 58,
          consoleWant = 150,
          consoleMin = 26,
          sectionHeaderH = 30,
          rowH = 27,
          rowsMin = 90,
          rowCount = 0,
          groupH = 20,
          rowsHeight = 0,
          notifOpen = false,
          settingsOpen = true,
          notifSeen = false,
          makeSwitch = function(parent, arg, arg2, arg3)
            local tbl30 = arg3 or {}
            local size = tbl30.size or UDim2.fromOffset(34, 18)
            local offset = size.Y.Offset
            local n41 = offset - 4
            local udim2 = UDim2.new(1, -(n41 + 2), 0.5, -n41 / 2)
            local udim22 = UDim2.new(0, 2, 0.5, -n41 / 2)
            local textButton = Instance.new("TextButton")
            textButton.Name = "State"
            textButton.Size = size
            textButton.Position = tbl30.position or UDim2.new(1, -46, 0.5, -offset / 2)
            textButton.BackgroundColor3 = arg and tbl25.Accent or tbl25.Control
            textButton.BorderSizePixel = 0
            textButton.AutoButtonColor = false
            textButton.Text = ""
            textButton.ZIndex = tbl30.zIndex or 6
            textButton.Parent = parent
            fn46(textButton, offset / 2)
            local v89 = createUIStroke2(textButton, tbl25.White, 1, arg and 0.62 or 0.88)
            fn47(textButton)
            local frame4 = Instance.new("Frame")
            frame4.Name = "Knob"
            frame4.Size = UDim2.fromOffset(n41, n41)
            frame4.Position = arg and udim2 or udim22
            frame4.BackgroundColor3 = arg and tbl25.Window or tbl25.White
            frame4.BorderSizePixel = 0
            frame4.ZIndex = (tbl30.zIndex or 6) + 1
            frame4.Parent = textButton
            fn46(frame4, n41 / 2)
            local tbl31 = { state = arg and true or false }

            local function fn51()
              local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
              v77:Create(textButton, tweenInfo, { BackgroundColor3 = tbl31.state and tbl25.Accent or tbl25.Control }):Play()
              v77:Create(v89, tweenInfo, { Transparency = tbl31.state and 0.62 or 0.88 }):Play()
              v77
                :Create(
                  frame4,
                  tweenInfo,
                  { BackgroundColor3 = tbl31.state and tbl25.Window or tbl25.White, Position = tbl31.state and udim2 or udim22 }
                )
                :Play()
            end

            tbl31.Set = function(state, arg4)
              state = state and true or false
              if state == tbl31.state then
                return
              end
              tbl31.state = state
              fn51()

              if not arg4 and arg2 then
                arg2(state)
              end
            end

            tbl31.Force = function(arg4)
              tbl31.state = arg4 and true or false
              fn51()
            end

            tbl31.Toggle = function()
              tbl31.Set(not tbl31.state)
            end

            textButton.MouseButton1Click:Connect(tbl31.Toggle)

            if tbl30.rowClick then
              parent.Active = true

              parent.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
                  return
                end
                local position = input.Position
                local absolutePosition = textButton.AbsolutePosition
                local absoluteSize = textButton.AbsoluteSize
                if
                  position.X >= absolutePosition.X
                  and position.X <= absolutePosition.X + absoluteSize.X
                  and position.Y >= absolutePosition.Y
                  and position.Y <= absolutePosition.Y + absoluteSize.Y
                then
                  return
                end
                tbl31.Toggle()
              end)
            end

            return tbl31
          end,
          autoTypeSwitches = {},
          syncAutoType = function(arg, arg2)
            for _, autoTypeSwitche in ipairs(tbl28.autoTypeSwitches) do
              if arg2 then
                autoTypeSwitche.Force(arg)
              else
                autoTypeSwitche.Set(arg, true)
              end
            end
          end,
          makeGroupRow = function(arg)
            tbl28.rowCount = tbl28.rowCount + 1
            tbl28.rowsHeight = tbl28.rowsHeight + tbl28.groupH
            local frame4 = Instance.new("Frame")
            frame4.Name = "Group" .. arg
            frame4.Size = UDim2.new(1, 0, 0, tbl28.groupH)
            frame4.BackgroundTransparency = 1
            frame4.LayoutOrder = tbl28.rowCount
            frame4.ZIndex = 5
            frame4.Parent = tbl28.rows
            local frame5 = Instance.new("Frame")
            frame5.Name = "Dash"
            frame5.Size = UDim2.fromOffset(10, 1)
            frame5.Position = UDim2.new(0, 14, 0.5, 0)
            frame5.BackgroundColor3 = tbl25.Dim
            frame5.BorderSizePixel = 0
            frame5.ZIndex = 6
            frame5.Parent = frame4
            local white = tbl25.White
            local gothamBold = Enum.Font.GothamBold
            createTextLabel(frame4, "Title", arg, UDim2.fromOffset(60, tbl28.groupH), UDim2.fromOffset(30, 0), 9, white, gothamBold).ZIndex =
              6
            local frame6 = Instance.new("Frame")
            frame6.Name = "Rule"
            frame6.Size = UDim2.new(1, -106, 0, 1)
            frame6.Position = UDim2.new(0, 92, 0.5, 0)
            frame6.BackgroundColor3 = tbl25.Dim
            frame6.BackgroundTransparency = 0.2
            frame6.BorderSizePixel = 0
            frame6.ZIndex = 6
            frame6.Parent = frame4
            return frame4
          end,
          newRow = function(arg, arg2)
            tbl28.rowCount = tbl28.rowCount + 1
            tbl28.rowsHeight = tbl28.rowsHeight + tbl28.rowH
            local instance2 = Instance.new("Frame")
            instance2.Name = "Row" .. tostring(tbl28.rowCount)
            instance2.Size = UDim2.new(1, 0, 0, tbl28.rowH)
            instance2.BackgroundTransparency = 1
            instance2.LayoutOrder = tbl28.rowCount
            instance2.ZIndex = 5
            instance2.Parent = tbl28.rows
            local text = tbl25.Text
            local gothamMedium = Enum.Font.GothamMedium
            local v89 = 6
            createTextLabel(instance2, "Title", arg, UDim2.new(1, arg2, 1, 0), UDim2.fromOffset(14, 0), 10, text, gothamMedium).ZIndex = v89
            return instance2
          end,
          makeRow = function(arg, arg2, arg3)
            return tbl28.makeSwitch(tbl28.newRow(arg, -80), arg2, arg3, { rowClick = true })
          end,
          makeChoiceRow = function(arg, arg2, arg3, arg4)
            local v89 = tbl28.newRow(arg, -135)
            local frame4 = Instance.new("Frame")
            frame4.Name = "Choices"
            frame4.Size = UDim2.fromOffset(105, 24)
            frame4.Position = UDim2.new(1, -117, 0.5, -16)
            frame4.BackgroundColor3 = tbl25.Log
            frame4.BackgroundTransparency = 0.05
            frame4.BorderSizePixel = 0
            frame4.ZIndex = 6
            frame4.Parent = v89
            fn46(frame4, 7)
            createUIStroke2(frame4, tbl25.White, 1, 0.88)
            local tbl30 = {}

            local function fn51(arg5)
              local v90 = arg3()

              for k, v91 in pairs(tbl30) do
                local textColor3 = k == v90

                if arg5 then
                  local v92 = v77
                  local create = v92.Create
                  local tweenInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                  local tbl31 = { BackgroundTransparency = textColor3 and 0 or 1 }
                  textColor3 = textColor3 and tbl25.Window or tbl25.Dim
                  tbl31.TextColor3 = textColor3
                  create(v92, v91, tweenInfo, tbl31):Play()
                else
                  v91.BackgroundTransparency = textColor3 and 0 or 1
                  v91.TextColor3 = textColor3 and tbl25.Window or tbl25.Dim
                end
              end
            end

            for i, v90 in ipairs(arg2) do
              local textButton = Instance.new("TextButton")
              textButton.Name = "Choice" .. tostring(v90)
              textButton.Size = UDim2.fromOffset(24, 18)
              textButton.Position = UDim2.fromOffset(3 + (i - 1) * 25, 3)
              textButton.BackgroundColor3 = tbl25.Accent
              textButton.BackgroundTransparency = 1
              textButton.BorderSizePixel = 0
              textButton.AutoButtonColor = false
              textButton.Text = tostring(v90)
              textButton.TextSize = 11
              textButton.TextColor3 = tbl25.Dim
              textButton.Font = Enum.Font.GothamBold
              textButton.ZIndex = 6
              textButton.Parent = frame4
              fn46(textButton, 6)
              fn47(textButton)
              tbl30[v90] = textButton

              textButton.MouseButton1Click:Connect(function()
                arg4(v90)
                fn51(true)
              end)
            end

            fn51(false)
            return v89
          end,
          showSubmitAfter = function(arg)
            local rowSubmitAfter = tbl28.rowSubmitAfter
            if not rowSubmitAfter then
              return
            end
            local visible = arg and true or false
            if rowSubmitAfter.Visible == visible then
              return
            end
            rowSubmitAfter.Visible = visible

            if visible then
              tbl28.rowsHeight = tbl28.rowsHeight + tbl28.rowH
            else
              tbl28.rowsHeight = tbl28.rowsHeight - tbl28.rowH
            end

            if tbl28.relayout then
              tbl28.relayout(true)
            end
          end,
        }

        tbl29 = {
          Dim = Color3.fromRGB(124, 127, 135),
          Amber = Color3.fromRGB(214, 158, 92),
          Green = Color3.fromRGB(105, 190, 132),
          Red = Color3.fromRGB(240, 105, 105),
          Cyan = Color3.fromRGB(101, 174, 183),
        }

        fn50 = function()
          n40 += 1
          local v89 = n40

          task.defer(function()
            local preRender = v76.PreRender or v76.RenderStepped
            local n41 = -1
            local n42 = 0

            for i = 1, 8 do
              preRender:Wait()
              if v89 ~= n40 or not instance then
                return
              end

              if fn49 then
                fn49()
              end

              pcall(function()
                instance:ResetScrollVelocity()
              end)

              local y = instance.AbsoluteCanvasSize.Y
              local n43 = math.max(0, y - instance.AbsoluteWindowSize.Y)
              instance.CanvasPosition = Vector2.new(0, n43)

              if math.abs(y - n41) < 0.5 then
                n42 += 1
                if n42 >= 2 then
                  break
                end
                continue
              end

              n42 = 0
              n41 = y
            end
          end)
        end

        do
          local instance2 = Instance.new("Frame")
          instance2.Name = "BrandMark"
          instance2.Size = UDim2.fromOffset(30, 30)
          instance2.Position = UDim2.fromOffset(16, 15)
          instance2.BackgroundColor3 = tbl25.Window
          instance2.BackgroundTransparency = 1
          instance2.BorderSizePixel = 0
          instance2.ClipsDescendants = true
          instance2.Parent = frame3
          fn46(instance2, 15)
          local imageLabel2 = Instance.new("ImageLabel")
          imageLabel2.Name = "Logo"
          imageLabel2.Size = UDim2.fromScale(1, 1)
          imageLabel2.BackgroundTransparency = 1
          imageLabel2.Image = "rbxassetid://71891923282375"
          imageLabel2.ScaleType = Enum.ScaleType.Fit
          imageLabel2.Parent = instance2
          fn46(imageLabel2, 15)
        end

        do
          local white = tbl25.White
          local gothamBold = Enum.Font.GothamBold
          createTextLabel(frame3, "Title", "ACE CODE SNIPER", UDim2.fromOffset(155, 25), UDim2.fromOffset(56, 16), 15, white, gothamBold)
        end

        do
          local textButton = Instance.new("TextButton")
          textButton.Name = "MinimizeButton"
          textButton.Size = UDim2.fromOffset(24, 24)
          textButton.Position = UDim2.new(1, -94, 0, 18)
          textButton.BackgroundColor3 = tbl25.Log
          textButton.BorderSizePixel = 0
          textButton.Text = ""
          textButton.AutoButtonColor = false
          textButton.ZIndex = 6
          textButton.Parent = frame3
          fn46(textButton, 7)
          local v89 = 1
          createUIStroke2(textButton, Color3.fromRGB(96, 92, 108), v89, 0)
          fn47(textButton)
          local frame4 = Instance.new("Frame")
          frame4.Name = "Horizontal"
          frame4.AnchorPoint = Vector2.new(0.5, 0.5)
          frame4.Size = UDim2.fromOffset(10, 2)
          frame4.Position = UDim2.fromScale(0.5, 0.5)
          frame4.BackgroundColor3 = tbl25.White
          frame4.BorderSizePixel = 0
          frame4.ZIndex = 10
          frame4.Parent = textButton
          fn46(frame4, 1)
          local frame5 = Instance.new("Frame")
          frame5.Name = "Vertical"
          frame5.AnchorPoint = Vector2.new(0.5, 0.5)
          frame5.Size = UDim2.fromOffset(2, 0)
          frame5.Position = UDim2.fromScale(0.5, 0.5)
          frame5.BackgroundColor3 = tbl25.White
          frame5.BorderSizePixel = 0
          frame5.ZIndex = 5
          frame5.Parent = textButton
          fn46(frame5, 1)
          local minimized = false
          local flag18 = false
          local str9 = "MainPage"

          textButton.MouseButton1Click:Connect(function()
            local aceSniperBarDock = getgenv and getgenv().ACESniperBarDock
            if type(aceSniperBarDock) == "function" then
              pcall(aceSniperBarDock, "code")
              return
            end

            if flag18 then
              return
            end
            flag18 = true
            minimized = not minimized
            v77
              :Create(
                frame5,
                TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                { Size = minimized and UDim2.fromOffset(2, 10) or UDim2.fromOffset(2, 0) }
              )
              :Play()
            local tabBar = frame2:FindFirstChild("TabBar")
            local tbl30 = {}

            for _, v90 in ipairs({ "MainPage", "FarmPage", "SettingsPage" }) do
              local v91 = frame2:FindFirstChild(v90)

              if v91 then
                table.insert(tbl30, v91)
              end
            end

            if minimized then
              for _, v90 in ipairs(tbl30) do
                if v90.Visible then
                  str9 = v90.Name
                end
              end

              if tabBar then
                tabBar.Visible = false
              end

              for _, v90 in ipairs(tbl30) do
                v90.Visible = false
              end
            end

            tbl28.minimized = minimized
            local tween = v77:Create(
              frame2,
              TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
              { Size = minimized and UDim2.fromOffset(310, 62) or UDim2.fromOffset(310, tbl28.targetHeight()) }
            )

            tween.Completed:Connect(function()
              if not minimized then
                if tabBar then
                  tabBar.Visible = true
                end

                local mainPage = frame2:FindFirstChild(str9) or frame2:FindFirstChild("MainPage")

                if mainPage then
                  mainPage.Visible = true
                end
              end

              flag18 = false
              return
            end)

            tween:Play()
          end)
        end

        local v89

        do
          local v90 = codeSniper
          v89 = v90

          local function fn51(arg, arg2)
            local flag18 = arg and true or false
            if v90 == flag18 then
              return
            end
            v90 = flag18
            v89 = v90

            if not v90 and fn35 then
              fn35()
            end

            if arg2 ~= false then
              tbl18.codeSniper = v90
              fn31()
            end

            str8 = nil
            tbl28.syncAutoType(v90)

            if tbl28.refreshStatus then
              tbl28.refreshStatus()
            end
          end

          local v91 = tbl28.makeSwitch(frame3, v90, function(arg)
            fn51(arg, true)

            if arg then
              tbl19.yield()
            end
          end, { position = UDim2.new(1, -64, 0, 18), size = UDim2.fromOffset(47, 24), zIndex = 4 })

          table.insert(tbl28.autoTypeSwitches, v91)

          if v78.TouchEnabled then
            local textButton = Instance.new("TextButton")
            textButton.Name = "AutoTypeTouchTarget"
            textButton.Size = UDim2.fromOffset(62, 62)
            textButton.Position = UDim2.new(1, -70, 0, 1)
            textButton.BackgroundTransparency = 1
            textButton.Text = ""
            textButton.AutoButtonColor = false
            textButton.ZIndex = 10
            textButton.Parent = frame3
            textButton.Activated:Connect(v91.Toggle)
          end

          tbl19.setTargets = function(arg)
            local flag18

            if arg ~= nil then
              flag18 = arg
            else
              flag18 = tbl18.codeSniper and true or false
              arg = tbl18.riddleSolver and true or false
            end

            tbl19.driving = true
            v90 = flag18
            v89 = flag18

            if not flag18 and fn35 then
              fn35()
            end

            tbl28.syncAutoType(flag18, true)
            riddleSolver = arg

            if tbl28.btnRiddles then
              tbl28.btnRiddles.Force(arg)
            end

            if tbl28.refreshStatus then
              tbl28.refreshStatus()
            end

            tbl19.driving = false
          end
        end

        local frame4 = Instance.new("Frame")
        frame4.Name = "TitleDivider"
        frame4.Size = UDim2.new(1, -34, 0, 1)
        frame4.Position = UDim2.fromOffset(17, 54)
        frame4.BackgroundColor3 = tbl25.White
        frame4.BackgroundTransparency = 0.72
        frame4.BorderSizePixel = 0
        frame4.Parent = frame3

        do
          local frame5 = Instance.new("Frame")
          frame5.Name = "StatusBar"
          frame5.Size = UDim2.fromOffset(276, tbl28.statusH)
          frame5.Position = UDim2.fromOffset(17, 0)
          frame5.BackgroundTransparency = 1
          frame5.BorderSizePixel = 0
          frame5.ZIndex = 3
          frame5.Parent = frame2
          local instance2 = Instance.new("Frame")
          instance2.Name = "Dot"
          instance2.Size = UDim2.fromOffset(7, 7)
          instance2.Position = UDim2.new(0, 1, 0.5, -4)
          instance2.BackgroundColor3 = tbl25.Dim
          instance2.BorderSizePixel = 0
          instance2.ZIndex = 5
          instance2.Parent = frame5
          fn46(instance2, 4)
          local v90 = 8
          local dim = tbl25.Dim
          local gothamBlack = Enum.Font.GothamBlack
          local state = createTextLabel(frame5, "State", "OFF", UDim2.new(1, -14, 1, 0), UDim2.fromOffset(14, 0), v90, dim, gothamBlack)
          state.ZIndex = 5
          tbl28.statusBar = frame5

          tbl28.refreshStatus = function()
            local flag18 = v89 and true or false
            local white = flag18 and tbl25.White or tbl25.Dim
            local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            state.Text = flag18 and "READY" or "OFF"
            v77:Create(instance2, tweenInfo, { BackgroundColor3 = white }):Play()
            v77:Create(state, tweenInfo, { TextColor3 = white }):Play()
          end
        end

        tbl28.refreshStatus()

        do
          local frame5 = Instance.new("Frame")
          frame5.Name = "SniperFeed"
          frame5.Size = UDim2.fromOffset(276, tbl28.notifCollapsedH)
          frame5.Position = UDim2.fromOffset(17, 0)
          frame5.BackgroundColor3 = tbl25.Log
          frame5.BackgroundTransparency = 0.05
          frame5.BorderSizePixel = 0
          frame5.ClipsDescendants = true
          frame5.ZIndex = 3
          frame5.Parent = frame2
          fn46(frame5, 10)
          createUIStroke2(frame5, tbl25.White, 1, 0.86)
          tbl28.card = frame5
          local instance2 = Instance.new("TextButton")
          instance2.Name = "Header"
          instance2.Size = UDim2.new(1, 0, 0, tbl28.notifHeaderH)
          instance2.Position = UDim2.fromOffset(0, 10)
          instance2.BackgroundTransparency = 1
          instance2.AutoButtonColor = false
          instance2.Text = ""
          instance2.ZIndex = 5
          instance2.Parent = frame5
          local white = tbl25.White
          local gothamBlack = Enum.Font.GothamBlack
          createTextLabel(instance2, "Title", "SNIPER FEED", UDim2.new(1, -46, 1, 0), UDim2.fromOffset(14, 0), 10, white, gothamBlack).ZIndex =
            6
          local v90 = 16
          local dim = tbl25.Dim
          local gothamBold = Enum.Font.GothamBold
          local chevron = createTextLabel(
            instance2,
            "Chevron",
            ">",
            UDim2.fromOffset(20, tbl28.notifHeaderH),
            UDim2.new(1, -32, 0, 0),
            v90,
            dim,
            gothamBold
          )
          chevron.TextXAlignment = Enum.TextXAlignment.Center
          chevron.ZIndex = 6
          tbl28.feedChevron = chevron
          local dim2 = tbl25.Dim
          local code = Enum.Font.Code
          local latest = createTextLabel(
            frame5,
            "Latest",
            "nothing yet...",
            UDim2.new(1, -28, 0, 22),
            UDim2.fromOffset(14, tbl28.notifHeaderH + 6),
            11,
            dim2,
            code
          )
          latest.TextTruncate = Enum.TextTruncate.AtEnd
          latest.ZIndex = 5
          tbl28.line = latest
          local text = tbl25.Text
          local gothamBold2 = Enum.Font.GothamBold
          local latestTag = createTextLabel(
            frame5,
            "LatestTag",
            "",
            UDim2.fromOffset(36, 22),
            UDim2.new(1, -44, 0, tbl28.notifHeaderH + 6),
            12,
            text,
            gothamBold2
          )
          latestTag.TextXAlignment = Enum.TextXAlignment.Right
          latestTag.Visible = false
          latestTag.ZIndex = 5

          tbl28.setLine = function(arg, textColor3, arg2)
            tbl28.notifSeen = true
            latest.Text = tostring(arg)
            latest.TextColor3 = textColor3 or tbl25.Dim
            latest.Size = UDim2.new(1, arg2 and -68 or -28, 0, 22)
            latestTag.Text = arg2 and tostring(arg2) or ""
            latestTag.Visible = arg2 ~= nil
          end

          instance2.MouseButton1Click:Connect(function()
            tbl28.notifOpen = not tbl28.notifOpen
            tbl28.relayout(true)

            if tbl28.notifOpen then
              fn50()
            end
          end)
        end

        instance = Instance.new("ScrollingFrame")
        instance.Name = "Console"
        instance.Size = UDim2.new(1, -24, 0, 0)
        instance.Position = UDim2.fromOffset(14, 40)
        instance.Visible = false
        instance.BackgroundTransparency = 1
        instance.BorderSizePixel = 0
        instance.ClipsDescendants = true
        instance.Active = true
        instance.ScrollingEnabled = true
        instance.ScrollingDirection = Enum.ScrollingDirection.Y
        instance.ElasticBehavior = Enum.ElasticBehavior.Never
        instance.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
        instance.CanvasSize = UDim2.new(0, 0, 0, 0)
        instance.AutomaticCanvasSize = Enum.AutomaticSize.Y
        instance.ScrollBarThickness = 6
        instance.ScrollBarImageColor3 = tbl25.Dim
        instance.ZIndex = 4
        instance.Parent = tbl28.card
        local uiPadding = Instance.new("UIPadding")
        uiPadding.PaddingTop = UDim.new(0, 4)
        uiPadding.PaddingBottom = UDim.new(0, 14)
        uiPadding.PaddingLeft = UDim.new(0, 0)
        uiPadding.PaddingRight = UDim.new(0, 6)
        uiPadding.Parent = instance
        local instance2 = Instance.new("UIListLayout")
        instance2.FillDirection = Enum.FillDirection.Vertical
        instance2.HorizontalAlignment = Enum.HorizontalAlignment.Left
        instance2.SortOrder = Enum.SortOrder.LayoutOrder
        instance2.Parent = instance
        instance2.Padding = UDim.new(0, 9)
        local fn51

        fn51 = function(arg, textColor3, arg2, arg3)
          if not instance then
            return
          end

          if textLabel then
            textLabel:Destroy()
            textLabel = nil
          end

          v88 += 1
          local frame5 = Instance.new("Frame")
          frame5.Name = "Entry"
          frame5.Size = UDim2.new(1, 0, 0, 0)
          frame5.AutomaticSize = Enum.AutomaticSize.Y
          frame5.BackgroundTransparency = 1
          frame5.LayoutOrder = v88
          frame5.ZIndex = 5
          local n41 = 0

          if arg3 then
            local textLabel2 = Instance.new("TextLabel")
            textLabel2.Name = "Prefix"
            textLabel2.Size = UDim2.fromOffset(34, 15)
            textLabel2.Position = UDim2.fromOffset(0, 0)
            textLabel2.BackgroundTransparency = 1
            textLabel2.Text = tostring(arg3)
            textLabel2.TextColor3 = tbl29.Dim
            textLabel2.TextSize = 11
            textLabel2.Font = Enum.Font.GothamBold
            textLabel2.TextXAlignment = Enum.TextXAlignment.Left
            textLabel2.TextYAlignment = Enum.TextYAlignment.Top
            textLabel2.ZIndex = 10
            textLabel2.Parent = frame5
            n41 = 40
          end

          local textLabel2 = Instance.new("TextLabel")
          textLabel2.Name = "Body"
          textLabel2.Size = UDim2.new(1, -(n41 + (arg2 and 40 or 0)), 0, 0)
          textLabel2.Position = UDim2.fromOffset(n41, 0)
          textLabel2.AutomaticSize = Enum.AutomaticSize.Y
          textLabel2.BackgroundTransparency = 1
          textLabel2.Text = tostring(arg)
          textLabel2.TextColor3 = textColor3 or tbl29.Dim
          textLabel2.TextSize = 12
          textLabel2.Font = Enum.Font.Code
          textLabel2.TextXAlignment = Enum.TextXAlignment.Left
          textLabel2.TextYAlignment = Enum.TextYAlignment.Top
          textLabel2.TextWrapped = true
          textLabel2.LineHeight = 1.12
          textLabel2.ZIndex = 10
          textLabel2.Parent = frame5

          if arg2 then
            local textLabel3 = Instance.new("TextLabel")
            textLabel3.Name = "Tag"
            textLabel3.Size = UDim2.fromOffset(36, 15)
            textLabel3.Position = UDim2.new(1, -36, 0, 0)
            textLabel3.BackgroundTransparency = 1
            textLabel3.Text = tostring(arg2)
            textLabel3.TextColor3 = tbl25.Text
            textLabel3.TextSize = 12
            textLabel3.Font = Enum.Font.GothamBold
            textLabel3.TextXAlignment = Enum.TextXAlignment.Right
            textLabel3.TextYAlignment = Enum.TextYAlignment.Top
            textLabel3.ZIndex = 5
            textLabel3.Parent = frame5
          end

          frame5.Parent = instance
          tbl27[#tbl27 + 1] = frame5

          while #tbl27 > 40 do
            local v90 = table.remove(tbl27, 1)

            if v90 then
              v90:Destroy()
            end
          end
        end

        textLabel = Instance.new("TextLabel")
        textLabel.Name = "Placeholder"
        textLabel.Size = UDim2.new(1, 0, 0, 0)
        textLabel.AutomaticSize = Enum.AutomaticSize.Y
        textLabel.LayoutOrder = 0
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "nothing yet..."
        textLabel.TextColor3 = tbl29.Dim
        textLabel.TextSize = 12
        textLabel.Font = Enum.Font.Code
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.ZIndex = 5
        textLabel.Parent = instance

        fn49 = function() end

        do
          local frame5 = Instance.new("Frame")
          frame5.Name = "SettingsSection"
          frame5.Size = UDim2.fromOffset(276, tbl28.sectionHeaderH)
          frame5.Position = UDim2.fromOffset(16, tbl28.notifCollapsedH + tbl28.gap)
          frame5.BackgroundColor3 = tbl25.Log
          frame5.BackgroundTransparency = 0.05
          frame5.BorderSizePixel = 0
          frame5.ClipsDescendants = true
          frame5.ZIndex = 3
          frame5.Parent = frame2
          fn46(frame5, 9)
          createUIStroke2(frame5, tbl25.White, 1, 0.86)
          tbl28.section = frame5
          local textButton = Instance.new("TextButton")
          textButton.Name = "Header"
          textButton.Size = UDim2.new(1, 0, 0, tbl28.sectionHeaderH)
          textButton.BackgroundTransparency = 1
          textButton.AutoButtonColor = false
          textButton.Text = ""
          textButton.ZIndex = 5
          textButton.Parent = frame5
          local v90 = 8
          local white = tbl25.White
          local gothamBlack = Enum.Font.GothamBlack
          createTextLabel(textButton, "Title", "SETTINGS", UDim2.new(1, -46, 1, 0), UDim2.fromOffset(14, 0), v90, white, gothamBlack).ZIndex =
            6
          local dim = tbl25.Dim
          local gothamBold = Enum.Font.GothamBold
          local chevron = createTextLabel(
            textButton,
            "Chevron",
            ">",
            UDim2.fromOffset(20, tbl28.sectionHeaderH),
            UDim2.new(1, -40, 0, 0),
            12,
            dim,
            gothamBold
          )
          chevron.TextXAlignment = Enum.TextXAlignment.Center
          chevron.ZIndex = 6
          tbl28.chevron = chevron
          local instance3 = Instance.new("ScrollingFrame")
          instance3.Name = "Rows"
          instance3.Size = UDim2.new(1, 0, 0, 0)
          instance3.Position = UDim2.fromOffset(0, tbl28.sectionHeaderH + 2)
          instance3.BackgroundTransparency = 1
          instance3.BorderSizePixel = 0
          instance3.Active = true
          instance3.ScrollingDirection = Enum.ScrollingDirection.Y
          instance3.ElasticBehavior = Enum.ElasticBehavior.Never
          instance3.CanvasSize = UDim2.new(0, 0, 0, 0)
          instance3.AutomaticCanvasSize = Enum.AutomaticSize.Y
          instance3.ScrollBarThickness = 3
          instance3.ScrollBarImageColor3 = tbl25.Dim
          instance3.ZIndex = 4
          instance3.Parent = frame5
          tbl28.rows = instance3
          local uiListLayout = Instance.new("UIListLayout")
          uiListLayout.FillDirection = Enum.FillDirection.Vertical
          uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
          uiListLayout.Parent = instance3
          local uiPadding2 = Instance.new("UIPadding")
          uiPadding2.PaddingBottom = UDim.new(0, 6)
          uiPadding2.Parent = instance3
          tbl28.makeGroupRow("CODES")

          tbl28.btnListen = tbl28.makeRow("AUTO CODE/RIDDLE LISTEN", tbl19.enabled, function(arg)
            tbl19.setEnabled(arg)
          end)

          tbl28.btnRetypeInvalid = tbl28.makeRow("RETYPE INVALID", retypeInvalid, function(retypeInvalid2)
            retypeInvalid = retypeInvalid2
            tbl18.retypeInvalid = retypeInvalid2

            if retypeInvalid2 and backupRiddle then
              backupRiddle = false
              tbl18.backupRiddle = false

              if tbl28.btnBackupRiddle then
                tbl28.btnBackupRiddle.Force(false)
              end
            end

            if not retypeInvalid2 and fn34 then
              fn34()
            end

            fn31()
          end)

          tbl28.makeRow("AUTO SUBMIT", autoSubmit, function(autoSubmit2)
            autoSubmit = autoSubmit2
            tbl18.autoSubmit = autoSubmit2
            fn31()
            tbl28.showSubmitAfter(autoSubmit2)
          end)

          tbl28.rowSubmitAfter = tbl28.makeChoiceRow("SUBMIT AFTER", { 1, 2, 3, 6 }, function()
            return submitAfter
          end, function(submitAfter2)
            submitAfter = submitAfter2
            tbl18.submitAfter = submitAfter2
            fn35()
            fn31()
          end)

          tbl28.showSubmitAfter(autoSubmit)
          tbl28.makeGroupRow("RIDDLES")

          tbl28.btnRiddles = tbl28.makeRow("AI RIDDLES", riddleSolver, function(riddleSolver2)
            riddleSolver = riddleSolver2
            tbl18.riddleSolver = riddleSolver2
            fn31()

            if riddleSolver2 then
              if not fn36() then
                local red = tbl25.Red
                fn32("AI riddles need an HTTP function - " .. fn37() .. " exposes none", red)
              end

              tbl19.yield()
            else
              n36 += 1
            end
          end)

          tbl28.btnAiSubmit = tbl28.makeRow("AI RIDDLES AUTO SUBMIT", aiAutoSubmit, function(aiAutoSubmit2)
            aiAutoSubmit = aiAutoSubmit2
            tbl18.aiAutoSubmit = aiAutoSubmit2

            if not aiAutoSubmit2 and backupRiddle then
              backupRiddle = false
              tbl18.backupRiddle = false

              if tbl28.btnBackupRiddle then
                tbl28.btnBackupRiddle.Force(false)
              end
            end

            fn31()
          end)

          tbl28.btnBackupRiddle = tbl28.makeRow("BACKUP RIDDLE ANSWER", backupRiddle, function(backupRiddle2)
            backupRiddle = backupRiddle2
            tbl18.backupRiddle = backupRiddle2

            if backupRiddle2 and not aiAutoSubmit then
              aiAutoSubmit = true
              tbl18.aiAutoSubmit = true

              if tbl28.btnAiSubmit then
                tbl28.btnAiSubmit.Force(true)
              end
            end

            if backupRiddle2 and retypeInvalid then
              retypeInvalid = false
              tbl18.retypeInvalid = false

              if tbl28.btnRetypeInvalid then
                tbl28.btnRetypeInvalid.Force(false)
              end

              if fn34 then
                fn34()
              end
            end

            fn31()
          end)

          tbl19.refreshRow = function()
            if tbl28.btnListen then
              tbl28.btnListen.Set(tbl19.enabled, true)
            end
          end

          textButton.MouseButton1Click:Connect(function()
            tbl28.settingsOpen = not tbl28.settingsOpen
            tbl28.relayout(true)
          end)
        end

        tbl28.targetHeight = function()
          if tbl28.activeTab == "MAIN" then
            return tbl28.windowHeight
          end
          return tbl28.tabHeights[tbl28.activeTab] or tbl28.tabHeights.MAIN
        end

        tbl28.applyWindowHeight = function(arg)
          if tbl28.minimized then
            return
          end
          local v90 = tbl28.targetHeight()
          frame2:SetAttribute("ACEWindowHeight", v90)
          fn48()
          if not arg then
            frame2.Size = UDim2.fromOffset(310, v90)
            return
          end
          v77
            :Create(frame2, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(310, v90) })
            :Play()
        end

        tbl28.setActiveTab = function(activeTab)
          tbl28.activeTab = activeTab
          tbl28.applyWindowHeight(true)
        end

        tbl28.relayout = function(arg)
          local n41 = tbl28.clearRow and tbl28.clearRowH + tbl28.gap or 0
          local n42 = tbl28.notifCollapsedH + (tbl28.notifOpen and tbl28.consoleWant or 0)
          local n43 = tbl28.sectionHeaderH + (tbl28.settingsOpen and 2 + tbl28.rowsHeight + 6 or 0)
          local n44 = n42 + tbl28.gap + n43 - tbl28.maxContent - n41

          if n44 > 0 then
            if tbl28.notifOpen then
              local n45 = math.min(n44, tbl28.consoleWant - tbl28.consoleMin)
              n42 -= n45
              n44 -= n45
            end

            if n44 > 0 and tbl28.settingsOpen then
              n43 = math.max(tbl28.sectionHeaderH + 2 + tbl28.rowsMin, n43 - n44)
            end
          end

          local n45 = tbl28.statusH + tbl28.statusGap
          local n46 = n45 + n41
          local n47 = n46 + n42 + tbl28.gap
          local n48 = n47 + n43
          tbl28.windowHeight = tbl28.chromeH + n48 + tbl28.footerBand
          local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

          local function fn52(arg2, arg3)
            if not arg then
              for k, v90 in pairs(arg3) do
                arg2[k] = v90
              end

              return
            end

            v77:Create(arg2, tweenInfo, arg3):Play()
          end

          if tbl28.clearRow then
            fn52(tbl28.clearRow, { Position = UDim2.fromOffset(17, n45) })
          end

          fn52(tbl28.card, { Position = UDim2.fromOffset(17, n46), Size = UDim2.fromOffset(276, n42) })
          fn52(tbl28.section, { Position = UDim2.fromOffset(17, n47), Size = UDim2.fromOffset(276, n43) })
          fn52(tbl28.chevron, { Rotation = tbl28.settingsOpen and 90 or 0 })
          fn52(tbl28.feedChevron, { Rotation = tbl28.notifOpen and 90 or 0 })

          if tbl28.footer then
            fn52(tbl28.footer, { Position = UDim2.new(0.5, -70, 0, n48 + 8) })
          end

          tbl28.line.Visible = not tbl28.notifOpen
          instance.Visible = tbl28.notifOpen
          instance.Size = UDim2.new(1, -32, 0, math.max(0, n42 - tbl28.notifHeaderH - 16))
          tbl28.rows.Visible = tbl28.settingsOpen
          tbl28.rows.Size = UDim2.new(1, 0, 0, tbl28.settingsOpen and n43 - tbl28.sectionHeaderH - 2 or 0)
          tbl28.applyWindowHeight(arg)
        end

        uiScale:GetPropertyChangedSignal("Scale"):Connect(function()
          fn50()
        end)

        local instance3, frame5

        do
          local white = tbl25.White
          local gothamBold = Enum.Font.GothamBold
          local discordFooter = createTextLabel(
            frame2,
            "DiscordFooter",
            "discord.gg/aceduels",
            UDim2.fromOffset(140, 19),
            UDim2.new(0.5, -70, 0, 392),
            10,
            white,
            gothamBold
          )
          discordFooter.TextXAlignment = Enum.TextXAlignment.Center
          discordFooter.BackgroundColor3 = tbl25.Window
          discordFooter.BackgroundTransparency = 1
          discordFooter.TextStrokeColor3 = tbl25.Window
          discordFooter.TextStrokeTransparency = 0.35
          discordFooter.ZIndex = 3
          local frame6 = Instance.new("Frame")
          frame6.Name = "TabBar"
          frame6.Size = UDim2.new(1, 0, 0, 34)
          frame6.Position = UDim2.fromOffset(0, 60)
          frame6.BackgroundTransparency = 1
          frame6.BorderSizePixel = 0
          frame6.ZIndex = 6
          frame6.Parent = frame2
          local instance4 = Instance.new("Frame")
          instance4.Name = "MainPage"
          instance4.Size = UDim2.new(1, 0, 1, -98)
          instance4.Position = UDim2.fromOffset(0, 98)
          instance4.BackgroundTransparency = 1
          instance4.ZIndex = 2
          instance4.Parent = frame2
          instance3 = Instance.new("Frame")
          instance3.Name = "FarmPage"
          instance3.Size = instance4.Size
          instance3.Position = instance4.Position
          instance3.BackgroundTransparency = 1
          instance3.Visible = false
          instance3.ZIndex = 2
          instance3.Parent = frame2
          frame5 = Instance.new("Frame")
          frame5.Name = "SettingsPage"
          frame5.Size = instance4.Size
          frame5.Position = instance4.Position
          frame5.BackgroundTransparency = 1
          frame5.Visible = false
          frame5.ZIndex = 2
          frame5.Parent = frame2
          tbl28.statusBar.Parent = instance4
          tbl28.card.Parent = instance4
          tbl28.section.Parent = instance4
          discordFooter.Parent = instance4
          tbl28.footer = discordFooter
          tbl28.relayout(false)
          local instance5 = Instance.new("Frame")
          instance5.Name = "TabGroup"
          instance5.Size = UDim2.new(1, -34, 0, 22)
          instance5.Position = UDim2.new(0, 17, 0.5, -11)
          instance5.BackgroundColor3 = tbl25.Log
          instance5.BackgroundTransparency = 0.1
          instance5.BorderSizePixel = 0
          instance5.ZIndex = 6
          instance5.Parent = frame6
          fn46(instance5, 7)
          createUIStroke2(instance5, tbl25.White, 1, 0.55)

          local function fn52(name, text, arg)
            local textButton = Instance.new("TextButton")
            textButton.Name = name
            textButton.Size = UDim2.new(0.33333333333333331, 0, 1, 0)
            textButton.Position = UDim2.new(arg, 0, 0, 0)
            textButton.BackgroundColor3 = Color3.fromRGB(30, 26, 30)
            textButton.BackgroundTransparency = 1
            textButton.BorderSizePixel = 0
            textButton.AutoButtonColor = false
            textButton.Text = text
            textButton.TextSize = 10
            textButton.TextColor3 = tbl25.Text
            textButton.Font = Enum.Font.GothamBold
            textButton.ZIndex = 7
            textButton.Parent = instance5
            fn46(textButton, 6)
            fn47(textButton)
            return textButton, (createUIStroke2(textButton, tbl25.White, 1, 1))
          end

          local MainTab, v90 = fn52("MainTab", "MAIN", 0)
          local FarmTab, v91 = fn52("FarmTab", "FARM", 0.33333333333333331)
          local SettingsTab, v92 = fn52("SettingsTab", "SETTINGS", 0.66666666666666663)

          local function fn53(arg, arg2, arg3)
            arg.TextColor3 = arg3 and tbl25.White or tbl25.Text
            arg.BackgroundTransparency = arg3 and 0.05 or 1
            arg2.Transparency = arg3 and 0.55 or 1
          end

          local tbl30 = {
            { Key = "MAIN", Page = instance4, Button = MainTab, Outline = v90 },
            { Key = "FARM", Page = instance3, Button = FarmTab, Outline = v91 },
            { Key = "SETTINGS", Page = frame5, Button = SettingsTab, Outline = v92 },
          }

          local v93 = nil

          local function fn54(arg)
            local page = nil

            for _, v94 in ipairs(tbl30) do
              local flag18 = v94.Key == arg
              fn53(v94.Button, v94.Outline, flag18)

              if flag18 then
                page = v94.Page
              else
                v94.Page.Visible = false
              end
            end

            if not page then
              return
            end
            page.Visible = true

            if v93 ~= nil and v93 ~= arg then
              page.Position = UDim2.fromOffset(0, 108)
              v77
                :Create(page, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.fromOffset(0, 98) })
                :Play()
            else
              page.Position = UDim2.fromOffset(0, 98)
            end

            v93 = arg
            tbl28.setActiveTab(arg)
          end

          MainTab.MouseButton1Click:Connect(function()
            fn54("MAIN")
          end)

          FarmTab.MouseButton1Click:Connect(function()
            fn54("FARM")
          end)

          SettingsTab.MouseButton1Click:Connect(function()
            fn54("SETTINGS")
          end)

          fn54("MAIN")
        end

        local frame6 = Instance.new("Frame")
        frame6.Name = "AppearanceDash"
        frame6.Size = UDim2.fromOffset(10, 1)
        frame6.Position = UDim2.fromOffset(16, 19)
        frame6.BackgroundColor3 = tbl25.Dim
        frame6.BorderSizePixel = 0
        frame6.ZIndex = 3
        frame6.Parent = frame5

        do
          local v90 = 11
          local white = tbl25.White
          local gothamBold = Enum.Font.GothamBold
          local appearanceTitle = createTextLabel(
            frame5,
            "AppearanceTitle",
            "APPEARANCE",
            UDim2.fromOffset(84, 32),
            UDim2.fromOffset(33, 8),
            v90,
            white,
            gothamBold
          )
          appearanceTitle.TextStrokeColor3 = Color3.new(0, 0, 0)
          appearanceTitle.TextStrokeTransparency = 0.35
          appearanceTitle.ZIndex = 3
        end

        local frame7 = Instance.new("Frame")
        frame7.Name = "AppearanceLine"
        frame7.Size = UDim2.new(1, -140, 0, 1)
        frame7.Position = UDim2.fromOffset(123, 19)
        frame7.BackgroundColor3 = tbl25.Dim
        frame7.BackgroundTransparency = 0.35
        frame7.BorderSizePixel = 0
        frame7.ZIndex = 3
        frame7.Parent = frame5
        local fn52

        do
          local scrollingFrame = Instance.new("ScrollingFrame")
          scrollingFrame.Name = "BackgroundOptions"
          scrollingFrame.Size = UDim2.new(1, -34, 0, 82)
          scrollingFrame.Position = UDim2.fromOffset(17, 38)
          scrollingFrame.BackgroundColor3 = tbl25.Log
          scrollingFrame.BackgroundTransparency = 0.3
          scrollingFrame.BorderSizePixel = 0
          scrollingFrame.ScrollBarThickness = 3
          scrollingFrame.ScrollBarImageColor3 = tbl25.Dim
          scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
          scrollingFrame.CanvasSize = UDim2.new()
          scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
          scrollingFrame.ZIndex = 3
          scrollingFrame.Parent = frame5
          fn46(scrollingFrame, 9)
          createUIStroke2(scrollingFrame, tbl25.White, 1, 0.8)
          local uiListLayout = Instance.new("UIListLayout")
          uiListLayout.FillDirection = Enum.FillDirection.Horizontal
          uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
          uiListLayout.Padding = UDim.new(0, 6)
          uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
          uiListLayout.Parent = scrollingFrame
          local uiPadding2 = Instance.new("UIPadding")
          uiPadding2.PaddingLeft = UDim.new(0, 7)
          uiPadding2.PaddingRight = UDim.new(0, 7)
          uiPadding2.Parent = scrollingFrame
          local tbl30 = {}

          fn52 = function(arg)
            local clamp = math.clamp
            local floor2 = math.floor
            local n41 = tonumber(arg) or 2
            local v90 = 1
            local n42 = #tbl26
            local v91 = clamp(floor2(n41), v90, n42)
            tbl18.backgroundIndex = v91
            local v92 = tbl26[v91]
            imageLabel.Image = v92.Image
            imageLabel.Visible = not v92.IsNone

            for i, v93 in ipairs(tbl30) do
              local uiStroke = v93:FindFirstChildOfClass("UIStroke")

              if uiStroke then
                uiStroke.Color = i == v91 and tbl25.White or tbl25.Dim
                uiStroke.Transparency = i == v91 and 0.1 or 0.76
                uiStroke.Thickness = i == v91 and 2 or 1
              end
            end

            fn31()
          end

          for i, v90 in ipairs(tbl26) do
            local instance4 = Instance.new("TextButton")
            instance4.Name = "Background" .. tostring(i)
            instance4.Size = UDim2.fromOffset(66, 40)
            instance4.BackgroundColor3 = tbl25.Control
            instance4.BackgroundTransparency = v90.IsNone and 0.35 or 0
            instance4.BorderSizePixel = 0
            instance4.AutoButtonColor = false
            instance4.Text = ""
            instance4.LayoutOrder = i
            instance4.ZIndex = 4
            instance4.Parent = scrollingFrame
            fn46(instance4, 8)
            createUIStroke2(instance4, tbl25.Dim, 1, 0.76)

            if v90.IsNone then
              local white = tbl25.White
              local gothamBold = Enum.Font.GothamBold
              createTextLabel(instance4, "NoBg", "NO BG", UDim2.new(1, -16, 0, 14), UDim2.fromOffset(8, 17), 8, white, gothamBold).ZIndex =
                5
              local dim = tbl25.Dim
              local gothamBold2 = Enum.Font.GothamBold
              local v91 = 10
              createTextLabel(instance4, "None", "NONE", UDim2.new(1, -12, 0, 14), UDim2.fromOffset(8, 34), 8, dim, gothamBold2).ZIndex =
                v91
            else
              local instance5 = Instance.new("Frame")
              instance5.Name = "Preview"
              instance5.Size = UDim2.new(1, -4, 1, -6)
              instance5.Position = UDim2.fromOffset(2, 2)
              instance5.BackgroundColor3 = tbl25.Window
              instance5.BorderSizePixel = 0
              instance5.Image = v90.Image
              instance5.ScaleType = Enum.ScaleType.Crop
              instance5.ZIndex = 5
              instance5.Parent = instance4
              fn46(instance5, 6)
              local white = tbl25.White
              local gothamBold = Enum.Font.GothamBold
              local number =
                createTextLabel(instance4, "Number", v90.Name, UDim2.fromOffset(28, 16), UDim2.new(1, -25, 1, -17), 8, white, gothamBold)
              number.TextXAlignment = Enum.TextXAlignment.Right
              number.TextStrokeColor3 = Color3.new(0, 0, 0)
              number.TextStrokeTransparency = 0.25
              number.ZIndex = 6
            end

            fn47(instance4)
            table.insert(tbl30, instance4)

            instance4.MouseButton1Click:Connect(function()
              fn52(i)
            end)
          end
        end

        do
          local instance4 = Instance.new("Frame")
          instance4.Name = "GuiScale"
          instance4.Size = UDim2.new(1, -34, 0, 42)
          instance4.Position = UDim2.fromOffset(17, 140)
          instance4.BackgroundColor3 = tbl25.Log
          instance4.BackgroundTransparency = 0.12
          instance4.BorderSizePixel = 0
          instance4.ZIndex = 3
          instance4.Parent = frame5
          fn46(instance4, 9)
          createUIStroke2(instance4, tbl25.White, 1, 0.8)
          local white = tbl25.White
          local gothamBold = Enum.Font.GothamBold
          local scaleTitle =
            createTextLabel(instance4, "ScaleTitle", "GUI Scale", UDim2.fromOffset(120, 60), UDim2.fromOffset(12, 0), 11, white, gothamBold)
          scaleTitle.TextStrokeColor3 = Color3.new(0, 0, 0)
          scaleTitle.TextStrokeTransparency = 0.35
          scaleTitle.ZIndex = 4

          local function fn53(name, text, arg, arg2)
            local instance5 = Instance.new("TextButton")
            instance5.Name = name
            instance5.Size = UDim2.fromOffset(arg2, 24)
            instance5.Position = UDim2.new(1, arg, 0.5, -16)
            instance5.BackgroundColor3 = tbl25.White
            instance5.BorderSizePixel = 0
            instance5.AutoButtonColor = false
            instance5.Text = text
            instance5.TextSize = 12
            instance5.TextColor3 = tbl25.Window
            instance5.Font = Enum.Font.GothamBold
            instance5.ZIndex = 4
            instance5.Parent = instance4
            fn46(instance5, 12)
            return instance5
          end

          local ScaleMinus = fn53("ScaleMinus", "-", -124, 30)
          local ScaleValue = fn53("ScaleValue", "", -92, 48)
          ScaleValue.Active = false
          local ScalePlus = fn53("ScalePlus", "+", -38, 30)
          fn47(ScaleMinus)
          fn47(ScalePlus)

          local function fn54(arg)
            tbl18.guiScale = math.clamp(math.floor((tonumber(arg) or 0.92) * 20 + 0.5) / 20, 0.5, 1.5)
            ScaleValue.Text = string.format("%.2f", tbl18.guiScale)
            fn48()
            fn31()
          end

          ScaleMinus.MouseButton1Click:Connect(function()
            fn54(tbl18.guiScale - 0.05)
          end)

          ScalePlus.MouseButton1Click:Connect(function()
            fn54(tbl18.guiScale + 0.05)
          end)

          local frame8 = Instance.new("Frame")
          frame8.Name = "OptimizationDash"
          frame8.Size = UDim2.fromOffset(8, 1)
          frame8.Position = UDim2.fromOffset(17, 197)
          frame8.BackgroundColor3 = tbl25.Dim
          frame8.BorderSizePixel = 0
          frame8.ZIndex = 3
          frame8.Parent = frame5
          local white2 = tbl25.White
          local gothamBold2 = Enum.Font.GothamBold
          local optimizationTitle = createTextLabel(
            frame5,
            "OptimizationTitle",
            "OPTIMIZATION",
            UDim2.fromOffset(96, 24),
            UDim2.fromOffset(33, 186),
            11,
            white2,
            gothamBold2
          )
          optimizationTitle.TextStrokeColor3 = Color3.new(0, 0, 0)
          optimizationTitle.TextStrokeTransparency = 0.35
          optimizationTitle.ZIndex = 3
          local frame9 = Instance.new("Frame")
          frame9.Name = "OptimizationLine"
          frame9.Size = UDim2.new(1, -152, 0, 1)
          frame9.Position = UDim2.fromOffset(135, 197)
          frame9.BackgroundColor3 = tbl25.Dim
          frame9.BackgroundTransparency = 0.35
          frame9.BorderSizePixel = 0
          frame9.ZIndex = 3
          frame9.Parent = frame5
          local scrollingFrame = Instance.new("ScrollingFrame")
          scrollingFrame.Name = "OptimizationOptions"
          scrollingFrame.Size = UDim2.new(1, -34, 0, 86)
          scrollingFrame.Position = UDim2.fromOffset(16, 204)
          scrollingFrame.BackgroundTransparency = 1
          scrollingFrame.BorderSizePixel = 0
          scrollingFrame.ScrollBarThickness = 3
          scrollingFrame.ScrollBarImageColor3 = tbl25.Dim
          scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
          scrollingFrame.CanvasSize = UDim2.new()
          scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
          scrollingFrame.ZIndex = 3
          scrollingFrame.Parent = frame5
          local instance5 = Instance.new("UIListLayout")
          instance5.FillDirection = Enum.FillDirection.Vertical
          instance5.HorizontalAlignment = Enum.HorizontalAlignment.Center
          instance5.Padding = UDim.new(0, 5)
          instance5.SortOrder = Enum.SortOrder.LayoutOrder
          instance5.Parent = scrollingFrame
          local uiPadding2 = Instance.new("UIPadding")
          uiPadding2.PaddingTop = UDim.new(0, 5)
          uiPadding2.PaddingBottom = UDim.new(0, 10)
          uiPadding2.Parent = scrollingFrame
          local tbl30 = {}
          local v90 = 0
          local connection3 = nil
          local flag18 = false
          local tbl31 = nil

          local function fn55(arg)
            pcall(function()
              if arg:IsA("BasePart") then
                arg.Material = Enum.Material.Plastic
                arg.Reflectance = 0
                arg.CastShadow = false
              elseif arg:IsA("Decal") or arg:IsA("Texture") then
                arg.Transparency = 1
              elseif
                arg:IsA("ParticleEmitter")
                or arg:IsA("Trail")
                or arg:IsA("Beam")
                or arg:IsA("Fire")
                or arg:IsA("Smoke")
                or arg:IsA("Sparkles")
              then
                arg.Enabled = false
              elseif arg:IsA("AnimationController") or arg:IsA("Animator") then
                for _, v91 in ipairs(arg:GetPlayingAnimationTracks()) do
                  pcall(function()
                    v91:Stop(0)
                  end)
                end
              end
            end)
          end

          local function fn56()
            flag18 = true

            if not tbl31 then
              tbl31 = {
                brightness = v79.Brightness,
                fogEnd = v79.FogEnd,
                diffuse = v79.EnvironmentDiffuseScale,
                specular = v79.EnvironmentSpecularScale,
                shadows = v79.GlobalShadows,
              }
            end

            pcall(function()
              v79.GlobalShadows = false
              v79.FogEnd = 1e10
              v79.EnvironmentDiffuseScale = 0
              v79.EnvironmentSpecularScale = 0
            end)

            for _, child in ipairs(v79:GetChildren()) do
              pcall(function()
                if
                  child:IsA("BlurEffect")
                  or child:IsA("SunRaysEffect")
                  or child:IsA("ColorCorrectionEffect")
                  or child:IsA("BloomEffect")
                  or child:IsA("DepthOfFieldEffect")
                then
                  child.Enabled = false
                end
              end)
            end

            for _, descendant in ipairs(workspace:GetDescendants()) do
              fn55(descendant)
            end

            if connection3 then
              connection3:Disconnect()
            end

            connection3 = workspace.DescendantAdded:Connect(function(descendant)
              if flag18 then
                fn55(descendant)
              end
            end)
          end

          local function fn57()
            flag18 = false

            if connection3 then
              connection3:Disconnect()
              connection3 = nil
            end

            pcall(function()
              if tbl31 then
                v79.GlobalShadows = tbl31.shadows
                v79.Brightness = tbl31.brightness
                v79.FogEnd = tbl31.fogEnd
                v79.EnvironmentDiffuseScale = tbl31.diffuse
                v79.EnvironmentSpecularScale = tbl31.specular
              else
                v79.GlobalShadows = true
              end

              for _, child in ipairs(v79:GetChildren()) do
                pcall(function()
                  if
                    child:IsA("BlurEffect")
                    or child:IsA("SunRaysEffect")
                    or child:IsA("ColorCorrectionEffect")
                    or child:IsA("BloomEffect")
                    or child:IsA("DepthOfFieldEffect")
                  then
                    child.Enabled = true
                  end
                end)
              end
            end)
          end

          local flag19 = false
          local connection4 = nil

          local function fn58()
            local character = localPlayer2.Character
            if not character then
              return
            end

            for _, descendant in ipairs(character:GetDescendants()) do
              if descendant:IsA("Accessory") or descendant:IsA("Hat") then
                pcall(function()
                  descendant:Destroy()
                end)
              end
            end
          end

          local function fn59()
            if flag19 then
              return
            end
            flag19 = true
            fn58()

            connection4 = localPlayer2.CharacterAdded:Connect(function()
              task.wait(0.5)

              if flag19 then
                fn58()
              end
            end)
          end

          local function fn60()
            flag19 = false

            if connection4 then
              connection4:Disconnect()
              connection4 = nil
            end
          end

          local function fn61()
            for _, descendant in ipairs(workspace:GetDescendants()) do
              if
                descendant:IsA("ParticleEmitter")
                or descendant:IsA("Trail")
                or descendant:IsA("Beam")
                or descendant:IsA("Fire")
                or descendant:IsA("Smoke")
                or descendant:IsA("Sparkles")
                or descendant:IsA("Explosion")
                or descendant:IsA("PointLight")
                or descendant:IsA("SpotLight")
                or descendant:IsA("SurfaceLight")
              then
                pcall(function()
                  descendant:Destroy()
                end)
              end
            end
          end

          local function fn62(arg, visible)
            if arg == "fallingParticles" then
              local v91 = frame2:FindFirstChild("ACEFallingDots")

              if v91 then
                v91.Visible = visible
              end

              return
            end

            if arg ~= "master" then
              return
            end

            if visible then
              fn56()
              fn59()
              fn61()
            else
              fn57()
              fn60()
            end
          end

          if getgenv then
            getgenv().ACECodeSniperStopOptimization = function()
              fn57()
              fn60()
            end
          end

          local function fn63(arg, arg2, arg3)
            local flag20 = tbl18.optimization[arg]

            if type(flag20) ~= "boolean" then
              flag20 = arg3 and true or false
            end

            tbl30[arg] = flag20
            v90 += 1
            local instance6 = Instance.new("Frame")
            instance6.Name = "Row_" .. arg
            instance6.Size = UDim2.new(1, -14, 0, 30)
            instance6.LayoutOrder = v90
            instance6.BackgroundColor3 = tbl25.Log
            instance6.BackgroundTransparency = 0.12
            instance6.BorderSizePixel = 0
            instance6.ZIndex = 6
            instance6.Parent = scrollingFrame
            fn46(instance6, 6)
            createUIStroke2(instance6, tbl25.White, 1, 0.84)
            local white3 = tbl25.White
            local gothamMedium = Enum.Font.GothamMedium
            createTextLabel(instance6, "Title", arg2, UDim2.new(1, -58, 1, 0), UDim2.fromOffset(11, 0), 10, white3, gothamMedium).ZIndex = 5

            local v91 = tbl28.makeSwitch(instance6, flag20, function(arg4)
              tbl30[arg] = arg4
              tbl18.optimization[arg] = arg4
              fn31()
              fn62(arg, arg4)
            end, { zIndex = 5 })

            fn62(arg, flag20)
            return v91
          end

          fn63("fallingParticles", "Falling snow", true)
          fn63("master", "Optimization", false)

          local function fn64()
            local tbl32 = {
              XBOX = {
                ButtonA = "A",
                ButtonB = "B",
                ButtonX = "X",
                ButtonY = "Y",
                ButtonL1 = "LB",
                ButtonR1 = "RB",
                ButtonL2 = "LT",
                ButtonR2 = "RT",
                ButtonL3 = "LS",
                ButtonR3 = "RS",
                ButtonSelect = "VIEW",
                ButtonStart = "MENU",
                DPadUp = "D-UP",
                DPadDown = "D-DN",
                DPadLeft = "D-LT",
                DPadRight = "D-RT",
              },
              PS = {
                ButtonA = "CROSS",
                ButtonB = "CIRCLE",
                ButtonX = "SQUARE",
                ButtonY = "TRIANGL",
                ButtonL1 = "L1",
                ButtonR1 = "R1",
                ButtonL2 = "L2",
                ButtonR2 = "R2",
                ButtonL3 = "L3",
                ButtonR3 = "R3",
                ButtonSelect = "CREATE",
                ButtonStart = "OPTIONS",
                DPadUp = "D-UP",
                DPadDown = "D-DN",
                DPadLeft = "D-LT",
                DPadRight = "D-RT",
              },
            }

            local str9 = "XBOX"
            local platform = nil

            pcall(function()
              platform = v78:GetPlatform()
            end)

            for _, v91 in ipairs({ "PS3", "PS4", "PS5" }) do
              local v92 = nil

              pcall(function()
                v92 = Enum.Platform[v91]
              end)

              if v92 and platform == v92 then
                str9 = "PS"
                break
              else
              end
            end

            local function fn65(arg)
              local v91 = "function"
              if type(arg) ~= v91 or arg == "" or arg == "Unknown" then
                return "NONE"
              end
              local v92 = tbl32[str9][arg]
              if v92 then
                return v92
              end
              local v93 = nil

              pcall(function()
                v93 = Enum.KeyCode[arg]
              end)

              if v93 then
                local stringForKeyCode = nil

                pcall(function()
                  stringForKeyCode = v78:GetStringForKeyCode(v93)
                end)

                if type(stringForKeyCode) == "string" and stringForKeyCode ~= "" and #stringForKeyCode <= 7 then
                  return string.upper(stringForKeyCode)
                end
              end

              return string.upper(arg)
            end

            local frame10 = Instance.new("Frame")
            frame10.Name = "FarmDash"
            frame10.Size = UDim2.fromOffset(10, 1)
            frame10.Position = UDim2.fromOffset(17, 19)
            frame10.BackgroundColor3 = tbl25.Dim
            frame10.BorderSizePixel = 0
            frame10.ZIndex = 3
            frame10.Parent = instance3
            local v91 = 11
            local white3 = tbl25.White
            local gothamBold3 = Enum.Font.GothamBold
            local farmTitle =
              createTextLabel(instance3, "FarmTitle", "FARM", UDim2.fromOffset(44, 24), UDim2.fromOffset(33, 8), v91, white3, gothamBold3)
            farmTitle.TextStrokeColor3 = Color3.new(0, 0, 0)
            farmTitle.TextStrokeTransparency = 0.35
            farmTitle.ZIndex = 3
            local frame11 = Instance.new("Frame")
            frame11.Name = "FarmLine"
            frame11.Size = UDim2.new(1, -100, 0, 1)
            frame11.Position = UDim2.fromOffset(83, 19)
            frame11.BackgroundColor3 = tbl25.Dim
            frame11.BackgroundTransparency = 0.35
            frame11.BorderSizePixel = 0
            frame11.ZIndex = 3
            frame11.Parent = instance3
            local flag20 = false
            local connection5 = nil
            local connection6 = nil

            local function fn66(anchored)
              local character = localPlayer2.Character
              if not character then
                return
              end
              local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
              if not humanoidRootPart then
                return
              end

              pcall(function()
                humanoidRootPart.Anchored = anchored
              end)
            end

            local function fn67(arg)
              flag20 = arg and true or false

              if flag20 then
                fn66(true)

                if not connection5 then
                  connection5 = localPlayer2.CharacterAdded:Connect(function(character)
                    character:WaitForChild("HumanoidRootPart", 10)
                    task.wait(0.35)

                    if flag20 then
                      fn66(true)
                    end
                  end)
                end

                if not connection6 then
                  local n41 = 0

                  connection6 = v76.Heartbeat:Connect(function(deltaTime)
                    n41 += deltaTime
                    if n41 < 0.25 then
                      return
                    end
                    n41 = 0

                    if flag20 then
                      fn66(true)
                    end
                  end)
                end
              else
                if connection5 then
                  connection5:Disconnect()
                  connection5 = nil
                end

                if connection6 then
                  connection6:Disconnect()
                  connection6 = nil
                end

                fn66(false)
              end
            end

            local flag21 = false
            local tbl33 = {}
            local n41 = 0
            local tbl34 = {}

            local function fn68(arg)
              local ok, result = pcall(function()
                local parent = arg.Parent
                return string.lower(
                  tostring(arg.ActionText)
                    .. " "
                    .. tostring(arg.ObjectText)
                    .. " "
                    .. tostring(arg.Name)
                    .. " "
                    .. tostring(parent and parent.Name or "")
                )
              end)

              if not ok or type(result) ~= "string" then
                return false
              end
              return string.find(result, "buy", 1, true) ~= nil or string.find(result, "purchase", 1, true) ~= nil
            end

            local function fn69(arg)
              if typeof(arg) ~= "Instance" then
                return
              end

              if not arg:IsA("ProximityPrompt") then
                return
              end

              if fn68(arg) then
                tbl34[arg] = true
              end
            end

            local function fn70()
              for _, descendant in ipairs(workspace:GetDescendants()) do
                fn69(descendant)
              end
            end

            local function fn71(arg)
              local parent = arg.Parent
              if not parent then
                return nil
              end

              local ok, result = pcall(function()
                if parent:IsA("BasePart") then
                  return parent.Position
                end

                if parent:IsA("Attachment") then
                  return parent.WorldPosition
                end

                if parent:IsA("Model") then
                  return parent:GetPivot().Position
                end
                local basePart = parent:FindFirstChildWhichIsA("BasePart", true)
                if basePart then
                  return basePart.Position
                end
                return nil
              end)

              if ok then
                return result
              end
              return nil
            end

            local function fn72(arg)
              pcall(function()
                if arg.HoldDuration > 0 then
                  arg.HoldDuration = 0
                end
              end)

              if pcall(fireproximityprompt, arg) then
                return
              end
              pcall(fireproximityprompt, arg, 1)
            end

            local function fn73(arg)
              for k in pairs(tbl34) do
                if not k:IsDescendantOf(workspace) then
                  tbl34[k] = nil
                elseif k.Enabled then
                  local v92 = fn71(k)

                  if v92 then
                    local maxActivationDistance = k.MaxActivationDistance

                    if maxActivationDistance <= 0 then
                      maxActivationDistance = 10
                    end

                    if (v92 - arg.Position).Magnitude <= maxActivationDistance + 4 then
                      fn72(k)
                    end
                  end
                end
              end
            end

            local function fn74(arg)
              flag21 = arg and true or false
              n41 += 1

              for _, v92 in ipairs(tbl33) do
                pcall(function()
                  v92:Disconnect()
                end)
              end

              table.clear(tbl33)
              if not flag21 then
                return
              end
              local v92 = "function"

              if type(fireproximityprompt) ~= v92 then
                flag21 = false
                fn32("Auto buy needs executor fireproximityprompt", tbl25.Red)
                return false
              end

              pcall(fn70)

              table.insert(
                tbl33,
                workspace.DescendantAdded:Connect(function(descendant)
                  if typeof(descendant) == "Instance" and descendant:IsA("ProximityPrompt") then
                    task.defer(fn69, descendant)
                  end
                end)
              )

              local v93 = n41

              task.spawn(function()
                local n42 = 0

                while flag21 and v93 == n41 do
                  pcall(function()
                    local character = localPlayer2.Character
                    character = character and character:FindFirstChild("HumanoidRootPart")

                    if character then
                      fn73(character)
                    end
                  end)

                  n42 += 0.2

                  if n42 >= 2 then
                    n42 = 0
                    pcall(fn70)
                  end

                  task.wait(0.2)
                end
              end)
            end

            local function fn75()
              n35 += 1
              n34 = os.clock() + 0.6
              local n42 = 0

              for _, descendant in ipairs(playerGui:GetDescendants()) do
                if descendant:IsA("TextBox") and descendant.Parent and descendant.Parent.Name == "CodeRedeem" then
                  if descendant.Text ~= "" then
                    descendant.Text = ""
                    n42 += 1
                  end

                  pcall(function()
                    descendant:ReleaseFocus(false)
                  end)
                end
              end

              str7 = ""

              if fn35 then
                fn35()
              end

              if fn34 then
                fn34()
              end

              return n42
            end

            local function fn76()
              local ok, result = pcall(fn75)

              if not ok then
                local red = tbl25.Red
                fn32("Clear box failed: " .. tostring(result), red)
                return nil
              end

              if result > 0 then
                fn32("Cleared " .. result .. " code box" .. (result == 1 and "" or "es") .. " - submit counter reset", tbl25.Green)
              else
                fn32("Code box already empty - submit counter reset", tbl25.Dim)
              end

              return result
            end

            local tbl35 = {}
            local flag22 = nil

            local function fn77()
              for _, v92 in ipairs(tbl35) do
                v92.RefreshKey()
              end
            end

            local function fn78(arg, arg2, arg3, arg4)
              local instance6 = Instance.new("Frame")
              instance6.Name = arg .. "Row"
              instance6.Size = UDim2.new(1, -34, 0, 42)
              instance6.Position = UDim2.fromOffset(17, arg3)
              instance6.BackgroundColor3 = tbl25.Log
              instance6.BackgroundTransparency = 0.12
              instance6.BorderSizePixel = 0
              instance6.ZIndex = 3
              instance6.Parent = instance3
              fn46(instance6, 9)
              createUIStroke2(instance6, tbl25.White, 1, 0.8)
              local textButton = Instance.new("TextButton")
              textButton.Name = "Keybind"
              textButton.Size = UDim2.fromOffset(72, 24)
              textButton.Position = UDim2.fromOffset(9, 9)
              textButton.BackgroundColor3 = tbl25.Control
              textButton.BorderSizePixel = 0
              textButton.AutoButtonColor = false
              textButton.Text = ""
              textButton.TextSize = 10
              textButton.TextColor3 = tbl25.White
              textButton.Font = Enum.Font.GothamBold
              textButton.ZIndex = 5
              textButton.Parent = instance6
              fn46(textButton, 7)
              createUIStroke2(textButton, tbl25.White, 1, 0.72)
              fn47(textButton)
              local white4 = tbl25.White
              local gothamMedium = Enum.Font.GothamMedium
              local v92 = 10
              createTextLabel(instance6, "Title", arg2, UDim2.new(1, -153, 1, 0), UDim2.fromOffset(88, 0), 11, white4, gothamMedium).ZIndex =
                v92
              local textButton2 = Instance.new("TextButton")
              textButton2.Name = "Switch"
              textButton2.Size = UDim2.fromOffset(47, 24)
              textButton2.Position = UDim2.new(1, -56, 0.5, -12)
              textButton2.BackgroundColor3 = tbl25.Control
              textButton2.BorderSizePixel = 0
              textButton2.AutoButtonColor = false
              textButton2.Text = ""
              textButton2.ZIndex = 5
              textButton2.Parent = instance6
              fn46(textButton2, 12)
              local v93 = createUIStroke2(textButton2, tbl25.White, 1, 0.88)
              local frame12 = Instance.new("Frame")
              frame12.Name = "Knob"
              frame12.Size = UDim2.fromOffset(20, 28)
              frame12.Position = UDim2.new(0, 2, 0.5, -8)
              frame12.BackgroundColor3 = tbl25.White
              frame12.BorderSizePixel = 0
              frame12.ZIndex = 6
              frame12.Parent = textButton2
              fn46(frame12, 10)
              local tbl36

              tbl36 = {
                Id = arg,
                KeyName = "",
                Active = false,
                RefreshKey = function()
                  local flag23 = flag22 == tbl36
                  textButton.Text = flag23 and "..." or fn65(tbl36.KeyName)
                  textButton.TextColor3 = flag23 and tbl25.Green or tbl25.White
                end,
                SetState = function(arg5, arg6)
                  tbl36.Active = arg5 and true or false
                  local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                  v77:Create(textButton2, tweenInfo, { BackgroundColor3 = tbl36.Active and tbl25.Accent or tbl25.Control }):Play()
                  v77:Create(v93, tweenInfo, { Transparency = tbl36.Active and 0.62 or 0.88 }):Play()

                  v77
                    :Create(frame12, tweenInfo, {
                      BackgroundColor3 = tbl36.Active and tbl25.Window or tbl25.White,
                      Position = tbl36.Active and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
                    })
                    :Play()

                  if arg6 then
                    return
                  end
                  local v94 = false
                  if arg4(tbl36.Active) == v94 then
                    tbl36.SetState(false, true)
                    return
                  end
                end,
                Toggle = function()
                  tbl36.SetState(not tbl36.Active)
                end,
              }

              textButton2.MouseButton1Click:Connect(function()
                tbl36.Toggle()
              end)

              textButton.MouseButton1Click:Connect(function()
                local v94 = flag22
                flag22 = flag22 ~= tbl36 and tbl36 or nil

                if v94 then
                  v94.RefreshKey()
                end

                tbl36.RefreshKey()
              end)

              tbl36.SetState(false, true)
              table.insert(tbl35, tbl36)
              return tbl36
            end

            local anchor = fn78("anchor", "Anchor", 32, fn67)
            local autoBuy = fn78("autoBuy", "Auto buy", 82, fn74)
            local textButton = Instance.new("TextButton")
            textButton.Name = "ClearCodeBox"
            textButton.Size = UDim2.new(1, -28, 0, tbl28.clearRowH)
            textButton.Position = UDim2.fromOffset(17, 0)
            textButton.BackgroundColor3 = tbl25.Log
            textButton.BackgroundTransparency = 0.3
            textButton.BorderSizePixel = 0
            textButton.AutoButtonColor = false
            textButton.Text = "CLEAR CODE BOX"
            textButton.TextColor3 = tbl25.White
            textButton.TextSize = 11
            textButton.Font = Enum.Font.GothamBold
            textButton.ZIndex = 4
            textButton.Parent = tbl28.card.Parent
            fn46(textButton, 10)
            local v92 = createUIStroke2(textButton, tbl25.White, 1, 0.8)

            local function fn79(arg)
              v77
                :Create(
                  textButton,
                  TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                  { BackgroundTransparency = arg and 0.02 or 0.3 }
                )
                :Play()
              local v93
              v77:Create(v92, v93, { Transparency = arg and 0.55 or 0.8 }):Play()
            end

            textButton.MouseEnter:Connect(function()
              fn79(true)
            end)

            textButton.MouseLeave:Connect(function()
              fn79(false)
            end)

            textButton.MouseButton1Down:Connect(function()
              fn79(true)
            end)

            textButton.MouseButton1Up:Connect(function()
              fn79(false)
            end)

            local v93 = 0

            local function fn80(text, textColor3)
              v93 += 1
              local v94 = v93
              textButton.Text = text
              textButton.TextColor3 = textColor3

              task.delay(0.9, function()
                if v94 ~= v93 then
                  return
                end
                textButton.Text = "CLEAR CODE BOX"
                textButton.TextColor3 = tbl25.White
              end)
            end

            textButton.MouseButton1Click:Connect(function()
              local v94 = fn76()

              if v94 == nil then
                fn80("CLEAR FAILED", tbl25.Red)
              elseif v94 > 0 then
                fn80("CLEARED (" .. v94 .. ")", tbl25.Green)
              else
                fn80("ALREADY EMPTY", tbl25.Dim)
              end
            end)

            tbl28.clearRow = textButton
            tbl28.relayout(false)
            anchor.KeyName = tbl18.anchorBind
            autoBuy.KeyName = tbl18.autoBuyBind
            fn77()

            local function fn81(arg)
              return string.sub(tostring(arg.Name), 1, 7) == "Gamepad"
            end

            local connection7 = nil

            connection7 = v78.InputBegan:Connect(function(input, gameProcessed)
              if not screenGui2 or not screenGui2.Parent then
                connection7:Disconnect()
                return
              end
              local keyCode = input.KeyCode
              if keyCode == Enum.KeyCode.Unknown then
                return
              end

              if input.UserInputType ~= Enum.UserInputType.Keyboard and not fn81(input.UserInputType) then
                return
              end

              if flag22 then
                local v94 = flag22
                flag22 = nil

                if keyCode ~= Enum.KeyCode.Escape and keyCode ~= Enum.KeyCode.ButtonB then
                  if keyCode == Enum.KeyCode.Backspace or keyCode == Enum.KeyCode.Delete then
                    v94.KeyName = ""
                  else
                    v94.KeyName = keyCode.Name
                  end

                  if v94.Id == "anchor" then
                    tbl18.anchorBind = v94.KeyName
                  else
                    tbl18.autoBuyBind = v94.KeyName
                  end

                  fn31()
                end

                fn77()
                return
              end

              if gameProcessed then
                return
              end

              if v78:GetFocusedTextBox() then
                return
              end

              for _, v94 in ipairs(tbl35) do
                if v94.KeyName ~= "" and v94.KeyName == keyCode.Name then
                  v94.Toggle()
                end
              end
            end)

            if getgenv then
              getgenv().ACECodeSniperStopFarm = function()
                fn67(false)
                fn74(false)

                if connection7 then
                  pcall(function()
                    connection7:Disconnect()
                  end)

                  connection7 = nil
                end
              end
            end
          end

          fn64()
          fn52(tbl18.backgroundIndex)
          fn54(tbl18.guiScale)
        end

        local function aceCodeSniperOpenAnimation()
          local guiScale = tbl18.guiScale
          fn48()
          local scale = uiScale.Scale
          uiScale.Scale = math.max(0.05, (scale or guiScale) * 0.6)
          v77:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = scale }):Play()
        end

        if getgenv then
          getgenv().ACECodeSniperOpenAnimation = aceCodeSniperOpenAnimation
        end

        aceCodeSniperOpenAnimation()

        do
          local flag18 = false
          local v90 = nil
          local vector2 = nil
          local position = nil
          local flag19 = false
          local touchEnabled = v78.TouchEnabled and 8 or 3

          local function fn53(arg)
            if not v78.TouchEnabled then
              return false
            end
            local absolutePosition = frame3.AbsolutePosition
            local absoluteSize = frame3.AbsoluteSize
            return arg.X >= absolutePosition.X + absoluteSize.X - 76
              and arg.Y >= absolutePosition.Y
              and arg.Y <= absolutePosition.Y + absoluteSize.Y
          end

          local function fn54(arg)
            if arg ~= v90 then
              return
            end

            if flag19 then
              local position2 = frame2.Position
              tbl18.windowPosition =
                { xScale = position2.X.Scale, xOffset = position2.X.Offset, yScale = position2.Y.Scale, yOffset = position2.Y.Offset }
              fn31()
            end

            flag18 = false
            v90 = nil
            vector2 = nil
            position = nil
          end

          frame3.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
              return
            end

            if flag18 or fn53(input.Position) then
              return
            end
            flag18 = true
            v90 = input
            vector2 = Vector2.new(input.Position.X, input.Position.Y)
            position = frame2.Position
            flag19 = false

            input.Changed:Connect(function()
              if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancel then
                fn54(input)
              end
            end)
          end)

          v78.InputChanged:Connect(function(input)
            if not flag18 or not v90 then
              return
            end

            if
              not (v90.UserInputType == Enum.UserInputType.Touch and input == v90)
              and not (v90.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement)
            then
              return
            end
            local n41 = Vector2.new(input.Position.X, input.Position.Y) - vector2

            if not flag19 then
              if n41.Magnitude < touchEnabled then
                return
              end
              flag19 = true
            end

            frame2.Position = UDim2.new(position.X.Scale, position.X.Offset + n41.X, position.Y.Scale, position.Y.Offset + n41.Y)
          end)
        end

        local function fn53(arg)
          if arg == tbl25.Green then
            return tbl29.Green
          end

          if arg == tbl25.Red then
            return tbl29.Red
          end

          if arg == tbl25.Text then
            return tbl29.Amber
          end

          if arg == tbl25.White then
            return tbl29.Cyan
          end
          return tbl29.Dim
        end

        fn32 = function(arg, arg2, arg3, arg4)
          if not instance then
            return
          end
          local str9 = tostring(arg) .. "\0" .. tostring(arg3)
          if str9 == str8 then
            return
          end
          str8 = str9
          arg2 = arg2 or tbl25.Dim
          fn51(arg, fn53(arg2), arg3, arg4)

          if tbl28.setLine then
            tbl28.setLine(arg4 and arg4 .. ": " .. tostring(arg) or arg, arg2, arg3)
          end

          if tbl28.notifOpen then
            fn50()
          end
        end

        tbl28.statusLineHandle = function()
          return tbl27[#tbl27]
        end

        tbl28.updateStatusLine = function(arg, arg2, arg3, arg4)
          if not arg or not arg.Parent then
            return false
          end

          if tbl27[#tbl27] ~= arg then
            return false
          end
          arg3 = arg3 or tbl25.Dim
          local body = arg:FindFirstChild("Body")

          if body then
            body.Text = tostring(arg2)
            body.TextColor3 = fn53(arg3)
          end

          local tag = arg:FindFirstChild("Tag")

          if tag then
            tag.Text = arg4 and tostring(arg4) or ""
          end

          str8 = tostring(arg2) .. "\0" .. tostring(arg4)

          if tbl28.setLine then
            tbl28.setLine(arg2, arg3, arg4)
          end

          return true
        end

        do
          local function fn54()
            tbl21 = {}
            n33 = 0
          end

          fn35 = function()
            tbl21 = {}
            n33 = 0
          end

          local function fn55(arg, text)
            if not arg then
              return false
            end
            n34 = os.clock() + 0.4
            n35 += 1
            local v90 = n35

            pcall(function()
              arg.ClearTextOnFocus = false
            end)

            if not pcall(function()
              arg.Text = text
            end) then
              return false
            end

            task.spawn(function()
              for i = 1, 6 do
                task.wait()
                if v90 ~= n35 then
                  return
                end

                if not arg.Parent then
                  return
                end
                local text2 = arg.Text
                if text2 == text then
                  return
                end

                if text2 ~= "" and not string.find(text, text2, 1, true) then
                  return
                end
                n34 = os.clock() + 0.4

                pcall(function()
                  arg.Text = text
                end)
              end
            end)

            return true
          end

          local function fn56()
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

            for _, v90 in ipairs(tbl22) do
              pcall(function()
                v90:Disconnect()
              end)
            end

            connection = nil
            connection2 = nil
            tbl22 = {}
            v82 = nil
          end

          local function fn57(arg)
            if not arg or not arg.Parent then
              return false
            end

            while arg do
              if arg:IsA("GuiObject") and arg.Visible == false then
                return false
              end

              if arg:IsA("ScreenGui") and arg.Enabled == false then
                return false
              end
              arg = arg.Parent
            end

            return true
          end

          local function fn58()
            local v90 = playerGui

            for _, v91 in ipairs(tbl23) do
              if v90 then
                v90 = v90:FindFirstChild(v91)
                continue
              end
              break
            end

            if v90 and v90:IsA("TextBox") and fn57(v90) then
              return v90
            end

            if fn57(v80) then
              return v80
            end

            if fn57(v81) then
              return v81
            end
            return fn40()
          end

          local function fn59(arg)
            if not arg or v82 == arg then
              return
            end
            fn56()
            v82 = arg

            pcall(function()
              arg.ClearTextOnFocus = false
            end)

            if arg.Text ~= "" then
              str7 = arg.Text
            end

            connection = arg:GetPropertyChangedSignal("Text"):Connect(function()
              if arg.Text ~= "" then
                str7 = arg.Text
                return
              end

              if os.clock() < n34 then
                return
              end

              if #tbl21 > 0 and os.clock() - n33 <= 25 then
                fn55(arg, table.concat(tbl21))
                return
              end
              fn54()
            end)

            connection2 = arg.AncestryChanged:Connect(function(child, parent)
              if not parent then
                fn56()
              end
            end)

            local parent = arg

            while parent do
              if parent:IsA("GuiObject") then
                table.insert(
                  tbl22,
                  parent:GetPropertyChangedSignal("Visible"):Connect(function()
                    if not fn57(arg) then
                      fn56()
                    end
                  end)
                )
              elseif parent:IsA("ScreenGui") then
                table.insert(
                  tbl22,
                  parent:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if not fn57(arg) then
                      fn56()
                    end
                  end)
                )
              end

              parent = parent.Parent
            end
          end

          v78.TextBoxFocused:Connect(function(arg)
            if arg:IsDescendantOf(screenGui2) then
              return
            end

            if arg ~= fn40() then
              return
            end
            v80 = arg
            v81 = arg
            fn59(arg)
          end)

          v78.TextBoxFocusReleased:Connect(function(arg)
            if arg:IsDescendantOf(screenGui2) then
              return
            end
            local v90 = fn40()
            if arg ~= v90 and arg ~= v81 then
              return
            end

            if retypeInvalid and fn33 and (arg == v90 or arg == v81) then
              fn33(arg, arg.Text ~= "" and arg.Text or str7, false)
            end

            if v80 == arg then
              v80 = nil
            end

            return
          end)

          fn34 = function()
            v85 += 1
            v83 = nil
            v84 = nil
            n37 = 0
          end

          fn33 = function(arg, arg2, arg3)
            if not retypeInvalid or not arg2 or arg2 == "" then
              return
            end

            if not arg3 and v83 and os.clock() <= n37 then
              return
            end
            v85 += 1
            local v90 = v85
            v83 = arg2
            v84 = arg
            local v91 = 12
            n37 = os.clock() + v91

            task.delay(8, function()
              if v90 == v85 then
                fn34()
              end
            end)
          end

          local function fn60(arg, arg2)
            if not retypeInvalid or not arg2 or arg2 == "" then
              return false
            end
            v76.Heartbeat:Wait()
            local v90 = fn58() or arg
            if not v90 or not fn57(v90) then
              return false
            end
            local v91 = fn55(v90, arg2)

            if v91 then
              v81 = v90
              fn59(v90)
            end

            return v91
          end

          local function fn61(arg, arg2)
            if arg2 and arg2:IsDescendantOf(screenGui2) then
              return
            end
            local str9 = tostring(arg or ""):lower()

            if
              (str9:find("unexpected error", 1, true) or str9:find("something went wrong", 1, true))
              and v86
              and os.clock() - n38 <= 6
              and not flag16
              and not flag17
            then
              flag16 = true
              flag17 = true
              local redeemedAfterRetry = v86
              local v90 = n39
              fn32("Temporary redeem error - retrying...", tbl25.Text)

              task.delay(0.45, function()
                if v90 ~= n39 or not flag17 then
                  return
                end
                local success, v91

                if fn42() then
                  success, v91 = fn43(redeemedAfterRetry)
                else
                  success, v91 = fn44(redeemedAfterRetry)

                  if not success then
                    success, v91 = fn41(redeemedAfterRetry)
                  end
                end

                flag17 = false

                if success then
                  success = type(v91) ~= "table" or v91.success or v91.Success
                end

                if success then
                  fn32("Redeemed after retry: " .. redeemedAfterRetry, tbl25.Green)
                else
                  fn32("Redeem retry failed", tbl25.Red)
                end
              end)

              return
            end

            if not retypeInvalid or not v83 then
              return
            end

            if n37 < os.clock() then
              fn34()
              return
            end

            if
              not (
                str9:find("invalid code", 1, true)
                or str9:find("code is invalid", 1, true)
                or str9:find("expired", 1, true)
                or str9:find("already redeemed", 1, true)
                or str9:find("already used", 1, true)
                or str9:find("doesn't exist", 1, true)
                or str9:find("does not exist", 1, true)
                or str9:find("not found", 1, true)
                or str9:find("rejected", 1, true)
              )
            then
              return
            end
            local v90 = v83
            local v91 = fn60(v84, v83)
            fn34()

            if v91 then
              fn32("Invalid - repasted: " .. v90, tbl25.Red)
            end
          end

          local function fn62(arg)
            if not arg or arg == "" then
              return
            end

            if #tbl21 > 0 and os.clock() - n33 > 25 then
              fn54()
            end

            if v82 and not fn57(v82) then
              fn56()
            end

            n33 = os.clock()
            local v90 = fn40()
            tbl21[#tbl21 + 1] = arg
            local redeemed = table.concat(tbl21)
            local n41 = #tbl21

            if v90 then
              v81 = v90
              fn59(v90)
              local flag18 = v78:GetFocusedTextBox() == v90
              fn55(v90, redeemed)

              if flag18 then
                pcall(function()
                  local cursorPosition = #redeemed + 1
                  v90.CursorPosition = cursorPosition
                  v90.SelectionStart = cursorPosition
                end)
              end
            else
              fn32("Captured; code box is closed", tbl25.Text)
            end

            fn32(redeemed, tbl25.Green, autoSubmit and tostring(n41) .. "/" .. tostring(submitAfter) or nil, "CODE")

            if submitAfter <= n41 then
              tbl21 = {}

              if autoSubmit then
                fn33(v90, redeemed, true)
                local v91, v92 = fn45(redeemed)

                if v91 and (type(v92) ~= "table" or v92.success or v92.Success) then
                  fn34()
                  fn32("Redeemed: " .. redeemed, tbl25.Green)
                else
                  local v93 = fn60(v90, redeemed)
                  fn34()

                  if v93 then
                    fn32("Invalid - repasted: " .. redeemed, tbl25.Red)
                  else
                    fn32("Invalid / cooldown", tbl25.Red)
                  end
                end
              end

              tbl19.disarm("code submitted")
            end
          end

          local function fn63(arg)
            if not (arg:IsA("TextLabel") or arg:IsA("TextButton")) then
              return
            end
            fn61(arg.Text or "", arg)

            arg:GetPropertyChangedSignal("Text"):Connect(function()
              fn61(arg.Text or "", arg)
            end)
          end

          for _, descendant in ipairs(playerGui:GetDescendants()) do
            fn63(descendant)
          end

          playerGui.DescendantAdded:Connect(function(descendant)
            task.wait(0.04)
            fn63(descendant)
          end)

          local function fn64(arg)
            if not getupvalues_ then
              return {}
            end
            local ok, result = pcall(getupvalues_, arg)
            local tbl30 = {}

            if ok and type(result) == "table" then
              for _, v90 in pairs(result) do
                if
                  typeof(v90) == "Instance"
                  and (v90:IsA("RemoteEvent") or v90:IsA("RemoteFunction") or v90:IsA("UnreliableRemoteEvent"))
                  and v90.Parent == net
                then
                  table.insert(tbl30, v90)
                end
              end
            end

            return tbl30
          end

          local tbl30 = { "Start", "Init", "KnitStart", "KnitInit", "OnStart" }

          local function fn65()
            local ok, result = pcall(function()
              return require(v75.Controllers:FindFirstChild("NotificationController", true))
            end)

            if not (ok and type(result) == "table") then
              return {}
            end
            local tbl31 = {}
            local tbl32 = {}

            for _, v90 in ipairs(tbl30) do
              local v91 = nil

              pcall(function()
                v91 = result[v90]
              end)

              if type(v91) == "function" then
                for _, v92 in ipairs(fn64(v91)) do
                  if not tbl32[v92] then
                    tbl32[v92] = true
                    tbl31[#tbl31 + 1] = v92
                  end
                end
              end
            end

            return tbl31
          end

          local tbl31 = {
            Top = true,
            Bottom = true,
            Center = true,
            Middle = true,
            Left = true,
            Right = true,
            TopRight = true,
            TopLeft = true,
            BottomRight = true,
            BottomLeft = true,
          }

          local tbl32 = {
            "Text",
            "text",
            "Message",
            "message",
            "Title",
            "title",
            "Body",
            "body",
            "Content",
            "content",
            "Description",
            "description",
            "Announcement",
            "announcement",
          }

          local function fn66(arg)
            return arg:find("Sounds%.") ~= nil or arg:find("rbxassetid") ~= nil or tbl31[arg] ~= nil
          end

          local function fn67(...)
            local v90 = table.pack(...)
            if v90.n == 0 then
              return nil
            end

            if typeof(v90[1]) == "string" and v90[1]:match("%S") then
              return v90[1]
            end

            for i = 1, v90.n do
              local v91 = v90[i]

              if typeof(v91) == "string" then
                if v91:match("%S") and not fn66(v91) then
                  return v91
                end
                continue
              end

              if typeof(v91) == "table" then
                for _, v92 in ipairs(tbl32) do
                  local v93 = nil

                  pcall(function()
                    v93 = v91[v92]
                  end)

                  if type(v93) == "string" and v93:match("%S") then
                    return v93
                  end
                end
              end
            end

            return nil
          end

          local function fn68(...)
            return fn67(...) ~= nil
          end

          local function fn69(arg)
            local v90 = "function"
            if type(arg) ~= v90 then
              return tostring(arg)
            end
            return (arg:gsub("<[^>]->", ""))
          end

          local function fn70(arg)
            return arg
          end

          local function fn71(arg)
            local tbl33 = {}

            for match in arg:gmatch("[%w_]+") do
              tbl33[#tbl33 + 1] = match
            end

            return tbl33
          end

          local tbl33 = {
            "code is",
            "codes is",
            "code was",
            "code word is",
            "codeword is",
            "code:",
            "codes:",
            "code =",
            "use code",
            "use the code",
            "use this code",
            "using code",
            "enter code",
            "enter the code",
            "enter this code",
            "type code",
            "type the code",
            "type this code",
            "redeem code",
            "redeem the code",
            "redeem this code",
            "claim code",
            "claim the code",
            "promo code",
            "gift code",
            "bonus code",
            "free code",
            "secret code",
            "codigo es",
            "codigo e",
            "codigo:",
            "code est",
            "code ist",
            "codice e",
            "kod to",
            "kodu",
            "codul este",
            "kode",
          }

          local tbl34 = {}

          for match in
            ("a an the is are was were be it this that these those here there now then\r\nnext new soon below above coming incoming dropping drop ready go going gonna\r\nbeing get got in on at for to of and or but you your my our up out\r\none two three first second last final part parts word words\r\ncode codes codeword free time live active valid expired chat everyone guys\r\n"):gmatch(
              "%S+"
            )
          do
            tbl34[match] = true
          end

          local function fn72(arg)
            if #arg < 3 or #arg > 30 then
              return false
            end

            if tbl34[arg:lower()] then
              return false
            end

            if arg:find("%d") then
              return true
            end
            local v90 = 0

            for match in arg:gmatch("%u") do
              v90 += 1
            end

            return v90 >= 2
          end

          local function fn73(arg)
            local str9 = arg:lower()
            local v90 = nil
            local v91 = nil

            for _, v92 in ipairs(tbl33) do
              local n41 = 1

              while true do
                local pos, v93 = str9:find(v92, n41, true)

                if not v93 then
                  break
                else
                  local match = arg:match("^[%s:%-=%.]*([%w_]+)", v93 + 1)

                  if match and fn72(match) and (not v90 or v93 < v90) then
                    v90 = v93
                    v91 = match
                  end

                  n41 = v93 + 1
                end
              end
            end

            return v91
          end

          local tbl35 = {
            "next code",
            "new code",
            "another code",
            "one more code",
            "code time",
            "code drop",
            "code alert",
            "code hunt",
            "code below",
            "dropping a code",
            "drop a code",
            "dropping code",
            "code coming",
            "code incoming",
            "incoming code",
            "code for you",
            "code will be",
            "code released",
            "releasing a code",
            "releasing the code",
            "code activated",
            "code number",
            "here is the code",
            "heres the code",
            "here's the code",
            "got a code",
            "have a code",
            "get this code",
            "take this code",
            "typing a code",
            "spelling a code",
            "spelling out",
            "spelling it out",
            "letter by letter",
            "word by word",
            "one word at a time",
            "open your codes",
            "open the codes",
            "codes menu",
            "reward code",
            "event code",
            "update code",
            "daily code",
            "weekend code",
            "birthday code",
            "milestone code",
            "sammy code",
            "want a code",
            "who wants a code",
            "need a code",
            "chat code",
            "codigo nuevo",
            "nuevo codigo",
            "codigo gratis",
            "aqui esta el codigo",
            "canjea",
            "canjear",
            "canjeen",
            "codigo novo",
            "novo codigo",
            "aqui esta o codigo",
            "resgate",
            "resgatar",
            "nouveau code",
            "code gratuit",
            "voici le code",
            "echangez",
            "neuer code",
            "gratis code",
            "hier ist der code",
            "einlosen",
            "nuovo codice",
            "codice gratis",
            "ecco il codice",
            "riscatta",
            "nieuwe code",
            "hier is de code",
            "nowy kod",
            "darmowy kod",
            "wpisz kod",
            "yeni kod",
            "bedava kod",
            "iste kod",
            "kodenya",
            "kode baru",
            "kode gratis",
            "gunakan kode",
            "bagong code",
            "libreng code",
            "code moi",
            "ma moi",
            "cod nou",
          }

          local tbl36 = {
            "what",
            "which",
            "who",
            "whose",
            "when",
            "where",
            "why",
            "how",
            "riddle",
            "quiz",
            "puzzle",
            "trivia",
            "anagram",
            "unscramble",
            "scrambled",
            "jumbled",
            "solve",
            "guess",
            "answer",
            "answers",
            "brain teaser",
            "brainteaser",
            "true or false",
            "odd one out",
            "fill in the blank",
            "rhymes with",
            "name the",
            "count the",
            "acertijo",
            "adivinanza",
            "adivina",
            "adivinha",
            "charada",
            "pregunta",
            "enigme",
            "devinette",
            "ratsel",
            "frage",
            "indovinello",
            "domanda",
            "raadsel",
            "zagadka",
            "bilmece",
            "bulmaca",
            "bugtong",
            "tebak",
            "teka teki",
            "cau do",
            "ghicitoare",
            "respuesta",
            "resposta",
            "reponse",
            "antwort",
            "risposta",
            "antwoord",
            "odpowiedz",
            "cevap",
            "sagot",
            "jawabannya",
            "dap an",
            "raspunsul",
          }

          local tbl37 = nil

          local function fn74()
            if tbl37 then
              return tbl37
            end

            local function fn75(arg)
              local tbl38 = {}

              for _, v90 in ipairs(arg) do
                local v91 = tbl19.normalize(v90)

                if #v91 > 2 then
                  tbl38[#tbl38 + 1] = v91
                end
              end

              return tbl38
            end

            tbl37 = { code = fn75(tbl33), riddle = fn75(tbl36) }
            local v90 = ipairs
            local v91 = fn75(tbl35)

            for _, v92 in v90(v91) do
              tbl37.code[#tbl37.code + 1] = v92
            end

            return tbl37
          end

          local function fn75(arg)
            if arg:find("?", 1, true) then
              return false
            end
            local v90 = fn74()
            local v91 = tbl19.normalize(arg)

            for _, v92 in ipairs(v90.riddle) do
              if v91:find(v92, 1, true) then
                return false
              end
            end

            for _, v92 in ipairs(v90.code) do
              if v91:find(v92, 1, true) then
                return true
              end
            end

            return false
          end

          local function fn76(arg)
            local str9 = arg:lower()
            return str9:find("sammy%s+spawned") ~= nil or str9:find("sammy%s+activated") ~= nil
          end

          local n41 = 0
          local v90 = 0
          local v91 = 0
          local tbl38

          tbl38 = {
            limit = 34,
            log = {},
            remember = function(arg)
              tbl38.log[#tbl38.log + 1] = arg

              while #tbl38.log > tbl38.limit do
                table.remove(tbl38.log, 1)
              end
            end,
            context = function()
              local tbl39 = {}

              for _, v92 in ipairs(tbl38.log) do
                tbl39[#tbl39 + 1] = v92
              end

              return tbl39
            end,
            answerPair = function(arg)
              if not arg or arg.riddle ~= true or type(arg.answers) ~= "table" then
                return nil, nil
              end
              local v92 = nil
              local v93 = nil

              for _, answer in ipairs(arg.answers) do
                v93 = fn39(answer)

                if v93 and v93 ~= v92 then
                  if not v92 then
                    v92 = v93
                    v93 = nil
                    continue
                  end
                else
                  v93 = nil
                  continue
                end

                break
              end

              return v92, v93
            end,
          }

          local tbl39 = {}

          local function fn77(arg, arg2, arg3)
            local flag18 = arg2 ~= false
            arg3 = arg3 and " " .. arg3 or ""
            fn54()
            tbl39[arg] = os.clock() + 2.5
            local v92 = fn40()

            if v92 then
              v81 = v92
              fn59(v92)
              fn55(v92, arg)

              if not aiAutoSubmit then
                fn32("Riddle typed" .. arg3 .. ": " .. arg, tbl25.Green)
                tbl19.disarm("riddle answered")
                return true
              end

              fn33(v92, arg, true)
              local success, v93 = fn45(arg)
              success = success and (type(v93) ~= "table" or v93.success or v93.Success)

              if success then
                fn34()
                fn32("Riddle redeemed" .. arg3 .. ": " .. arg, tbl25.Green)
              else
                fn32("Riddle answer" .. arg3 .. " rejected / cooldown", tbl25.Red)
              end

              if flag18 then
                tbl19.disarm("riddle answered")
              end

              return success
            end

            fn32("Riddle solved; code box is closed", tbl25.Text)

            if flag18 then
              tbl19.disarm("riddle answered")
            end

            return false
          end

          local function fn78(arg, arg2, arg3)
            n41 += 1
            fn32("Solving riddle...", tbl25.Text)
            local v92 = n36

            task.spawn(function()
              local solve =
                fn38("/solve", { message = arg, model = tbl24.RaceModels and tbl24.BackupModel or tbl24.PrimaryModel, history = arg3 })
              n41 = math.max(0, n41 - 1)
              if not tbl24.Enabled or not tbl24.AIRiddles then
                return
              end

              if v92 ~= n36 then
                fn32("Riddle answer dropped - solver switched off", tbl25.Dim)
                return
              end
              local v93, v94 = tbl38.answerPair(solve)

              if v93 and arg2 >= v91 then
                v91 = arg2
                local flag18 = backupRiddle and aiAutoSubmit and v94 ~= nil
                fn77(v93, not flag18, flag18 and "1/2" or nil)

                if flag18 then
                  local function fn79()
                    return arg2 == v91 and tbl24.Enabled and tbl24.AIRiddles and v92 == n36 and aiAutoSubmit and backupRiddle
                  end

                  local n42 = os.clock() + 10.35

                  local function fn80(arg4)
                    return string.format("Trying backup code - code cooldown %.1fs", arg4)
                  end

                  local text = tbl25.Text
                  fn32(fn80(10.35), text)
                  local v95 = tbl28.statusLineHandle()

                  while fn79() do
                    local n43 = n42 - os.clock()

                    if not (n43 <= 0) then
                      local text2 = tbl25.Text

                      if not tbl28.updateStatusLine(v95, fn80(n43), text2) then
                        local text3 = tbl25.Text
                        fn32(fn80(n43), text3)
                        v95 = tbl28.statusLineHandle()
                      end

                      task.wait(0.1)
                      continue
                    end

                    break
                  end

                  if fn79() then
                    fn77(v94, true, "2/2")
                  else
                    tbl19.disarm("riddle backup cancelled")
                  end
                end
              elseif solve and solve.error then
                local str9 = solve.httpStatus and "AI HTTP " .. tostring(solve.httpStatus) .. ": " or "AI: "
                local red = tbl25.Red
                fn32(str9 .. tostring(solve.error), red)
              elseif not v93 then
                fn32("Riddle UNKNOWN", tbl25.Red)
              end
            end)
          end

          local tbl40 = {}

          local function fn79(arg)
            local v92 = tbl39[arg]

            if v92 then
              if os.clock() < v92 then
                return false
              end

              tbl39[arg] = nil
            end

            if tbl20[arg] then
              return false
            end
            tbl20[arg] = true

            task.delay(1.25, function()
              tbl20[arg] = nil
            end)

            fn35()
            tbl40 = {}
            local redeemed = fn70(arg)
            local v93 = fn40()

            if v93 then
              v81 = v93
              fn59(v93)
              fn55(v93, redeemed)
            else
              fn32("Captured; code box is closed", tbl25.Text)
            end

            fn32(redeemed, tbl25.Green, nil, "CODE")

            if autoSubmit then
              fn33(v93, redeemed, true)
              local v94, v95 = fn45(redeemed)

              if v94 and (type(v95) ~= "table" or v95.success or v95.Success) then
                fn34()
                fn32("Redeemed: " .. redeemed, tbl25.Green)
              else
                local v96 = fn60(v93, redeemed)
                fn34()

                if v96 then
                  fn32("Invalid - repasted: " .. redeemed, tbl25.Red)
                else
                  fn32("Invalid / cooldown", tbl25.Red)
                end
              end
            end

            tbl19.disarm("code submitted")
            return true
          end

          local v92 = nil
          local now2 = 0

          local function fn80(...)
            local match = fn69(fn67(...) or ""):match("^%s*(.-)%s*$") or ""
            if match == "" then
              return
            end

            if match == v92 and os.clock() - now2 < 0.3 then
              return
            end
            v92 = match
            now2 = os.clock()
            if fn76(match) then
              return
            end
            local flag18 = match:find("%s") ~= nil
            local flag19 = match:match("^[%d%s%+%-%*/%%%^%(%)%.]+$") ~= nil and match:find("[+%-%*/%%^]") ~= nil
            flag18 = flag18 or flag19
            local v93 = tbl19.push(match)

            if tbl19.enabled and not tbl19.armed then
              local v94 = tbl19.match(v93)
              local flag20

              if v94 then
                local readyAt = tbl19.readyAt
                flag20 = os.clock() >= readyAt or not tbl19.isWeak(v94)
              else
                flag20 = v94
              end

              if flag20 then
                tbl19.arm(v94)
              end
            end

            local v94 = tbl38.context()
            tbl38.remember(match)
            local v95 = fn73(match)

            if v95 then
              if tbl19.enabled and not tbl19.armed then
                tbl19.arm("code in message")
              end

              if v89 and fn79(v95) then
                return
              end
            end

            if tbl24.Enabled and tbl24.AIRiddles and riddleSolver and flag18 then
              if fn75(match) then
                fn32("Code cue, not a riddle: " .. match, tbl25.Dim)
              else
                v90 += 1
                fn78(match, v90, v94)
              end
            end

            if not v89 or flag18 then
              return
            end

            for _, v96 in ipairs(fn71(match)) do
              tbl40[#tbl40 + 1] = v96
            end

            local tbl41 = {}

            for i = 1, math.min(#tbl40, 1) do
              tbl41[i] = tbl40[i]
            end

            if #tbl40 < 1 then
              return
            end
            tbl40 = {}
            local v96 = fn70(table.concat(tbl41))
            local v97 = tbl39[v96]

            if v97 then
              if os.clock() < v97 then
                return
              end
              tbl39[v96] = nil
            end

            if v96 == "" or tbl20[v96] then
              return
            end
            tbl20[v96] = true

            task.delay(1.25, function()
              tbl20[v96] = nil
            end)

            fn62(v96)
          end

          local aceCodeSniperNotifyConnection = {}

          if getgenv then
            local aceCodeSniperNotifyConnection2 = getgenv().ACECodeSniperNotifyConnection

            if typeof(aceCodeSniperNotifyConnection2) == "table" then
              for _, v93 in ipairs(aceCodeSniperNotifyConnection2) do
                pcall(function()
                  v93:Disconnect()
                end)
              end
            elseif aceCodeSniperNotifyConnection2 then
              pcall(function()
                aceCodeSniperNotifyConnection2:Disconnect()
              end)
            end
          end

          local v93 = ipairs
          local v94 = fn65()

          for _, v95 in v93(v94) do
            local ok, result = pcall(function()
              return v95.OnClientEvent:Connect(function(...)
                local v96 = table.pack(...)

                if not (not v89 and not riddleSolver and not tbl19.enabled) then
                  if fn68(...) then
                    pcall(fn80, table.unpack(v96, 1, v96.n))
                    return
                  end
                end
              end)
            end)

            if ok and result then
              aceCodeSniperNotifyConnection[#aceCodeSniperNotifyConnection + 1] = result
            end
          end

          if getgenv then
            getgenv().ACECodeSniperNotifyConnection = aceCodeSniperNotifyConnection
          end

          if #aceCodeSniperNotifyConnection == 0 then
            fn32("Auto listen is deaf - no notify remote found", tbl25.Red)
          end

          if getgenv then
            getgenv().StopAura = function()
              for _, v95 in ipairs(aceCodeSniperNotifyConnection) do
                pcall(function()
                  v95:Disconnect()
                end)
              end

              aceCodeSniperNotifyConnection = {}
              local aceCodeSniperNotifyConnection2 = getgenv().ACECodeSniperNotifyConnection

              if typeof(aceCodeSniperNotifyConnection2) == "table" then
                for _, v95 in ipairs(aceCodeSniperNotifyConnection2) do
                  pcall(function()
                    v95:Disconnect()
                  end)
                end
              elseif aceCodeSniperNotifyConnection2 then
                pcall(function()
                  aceCodeSniperNotifyConnection2:Disconnect()
                end)
              end

              getgenv().ACECodeSniperNotifyConnection = nil

              if type(getgenv().ACECodeSniperStopOptimization) == "function" then
                pcall(getgenv().ACECodeSniperStopOptimization)

                getgenv().ACECodeSniperStopOptimization = nil
              end

              if type(getgenv().ACECodeSniperStopFarm) == "function" then
                pcall(getgenv().ACECodeSniperStopFarm)
                getgenv().ACECodeSniperStopFarm = nil
              end

              if getgenv().ACECodeSniperGui == screenGui2 then
                getgenv().ACECodeSniperGui = nil
              end

              getgenv().ACECodeSniperOpenAnimation = nil

              if screenGui2 then
                screenGui2:Destroy()
              end
            end
          end
        end
      end
    end

    do
      do
        local Players = game:GetService("Players")
        TweenService = game:GetService("TweenService")
        RunService = game:GetService("RunService")
        Stats = game:GetService("Stats")
        localPlayer = Players.LocalPlayer
      end

      do
        local playerGui = localPlayer:WaitForChild("PlayerGui")
        genv = getgenv and getgenv() or _G

        local function fn30(arg)
          pcall(function()
            local v75 = playerGui:FindFirstChild(arg)

            if v75 then
              v75:Destroy()
            end
          end)

          pcall(function()
            local v75 = game:GetService("CoreGui"):FindFirstChild(arg)

            if v75 then
              v75:Destroy()
            end
          end)

          if gethui then
            pcall(function()
              local v75 = gethui():FindFirstChild(arg)

              if v75 then
                v75:Destroy()
              end
            end)
          end
        end

        fn28 = function(arg)
          local v75 = playerGui:FindFirstChild(arg)
          if v75 then
            return v75
          end

          local ok, result = pcall(function()
            return game:GetService("CoreGui"):FindFirstChild(arg)
          end)

          if ok and result then
            return result
          end

          if gethui then
            local ok2, result2 = pcall(function()
              return gethui():FindFirstChild(arg)
            end)

            if ok2 and result2 then
              return result2
            end
          end

          return nil
        end

        fn30("ACESniperTopBar")
        fn30("ACESniperSelector")

        pcall(function()
          local aceSniperSelectorBlur = game:GetService("Lighting"):FindFirstChild("ACESniperSelectorBlur")

          if aceSniperSelectorBlur then
            aceSniperSelectorBlur:Destroy()
          end
        end)

        tbl17 = {
          Window = Color3.fromRGB(6, 6, 6),
          Pill = Color3.fromRGB(19, 19, 22),
          White = Color3.fromRGB(245, 245, 245),
          Dim = Color3.fromRGB(125, 127, 135),
          DotOff = Color3.fromRGB(58, 58, 64),
        }

        createUICorner = function(parent, arg)
          local uiCorner = Instance.new("UICorner")
          uiCorner.CornerRadius = UDim.new(0, arg)
          uiCorner.Parent = parent
          return uiCorner
        end

        createUIStroke = function(parent, color, thickness, transparency)
          local uiStroke = Instance.new("UIStroke")
          uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
          uiStroke.Color = color
          uiStroke.Thickness = thickness or 1
          uiStroke.Transparency = transparency or 0
          uiStroke.Parent = parent
          return uiStroke
        end

        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "ACESniperTopBar"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.DisplayOrder = 2147483645
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        pcall(function()
          screenGui.OnTopOfCoreBlur = true
        end)

        fn29(screenGui, playerGui)
      end

      genv.ACESniperTopBarGui = screenGui
      n31 = 480
      frame = Instance.new("Frame")
      frame.Name = "Bar"
      frame.AnchorPoint = Vector2.new(0.5, 0)

      do
        local UserInputService = game:GetService("UserInputService")
        flag14 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
      end
    end

    frame.Position = flag14 and UDim2.new(0.5, 0, 0, 14) or UDim2.new(0.5, 0, 0, 50)
    frame.Size = UDim2.fromOffset(480, 42)
    frame.BackgroundColor3 = Color3.new(1, 1, 1)
    frame.BackgroundTransparency = 0.02
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = screenGui
    createUICorner(frame, 14)
    createUIStroke(frame, tbl17.White, 1, 0.58)

    createFrame(frame, {
      Count = flag14 and 8 or 14,
      ZIndex = 20,
      InitialSpread = 3,
      MinDuration = 2.8,
      MaxDuration = 4.8,
    })
  end

  do
    local uiGradient = Instance.new("UIGradient")
    uiGradient.Rotation = 90
    local colorSequence = ColorSequence.new
    local tbl18 = {}
    local v75 = ColorSequenceKeypoint.new(0, Color3.fromRGB(17, 17, 28))
    local v76 = ColorSequenceKeypoint.new(0.45, Color3.fromRGB(8, 8, 8))
    local new = ColorSequenceKeypoint.new
    local v77 = 1
    local color = Color3.fromRGB
    tbl18[1] = v75
    tbl18[2] = v76

    do
      local values = table.pack(new(v77, color(5, 5, 6)))
      table.move(values, 1, values.n, 3, tbl18)
    end

    uiGradient.Color = colorSequence(tbl18)
    uiGradient.Parent = frame
  end
end

local CodeToggle, OGToggle, fn29, fn30, fn31

do
  local v75, v76, v77, v78

  do
    do
      local uiScale = Instance.new("UIScale")
      uiScale.Name = "BarFit"
      uiScale.Parent = frame

      local function fn32()
        local scale = flag14 and 0.75 or 1
        local currentCamera = workspace.CurrentCamera
        if not currentCamera then
          uiScale.Scale = scale
          return
        end
        uiScale.Scale = math.max(0.5, math.min(scale, (currentCamera.ViewportSize.X - 16) / n31))
      end

      fn32()

      pcall(function()
        workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(fn32)

        if workspace.CurrentCamera then
          workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fn32)
        end
      end)
    end

    do
      local imageLabel = Instance.new("ImageLabel")
      imageLabel.Name = "BrandLogo"
      imageLabel.Size = UDim2.fromOffset(24, 24)
      imageLabel.Position = UDim2.new(0, 12, 0.5, -12)
      imageLabel.BackgroundTransparency = 1
      imageLabel.Image = "rbxassetid://71891923282375"
      imageLabel.ScaleType = Enum.ScaleType.Fit
      imageLabel.Parent = frame
      createUICorner(imageLabel, 12)
    end

    do
      local function fn32(name, position, arg)
        local textButton = Instance.new("TextButton")
        textButton.Name = name
        textButton.Size = UDim2.fromOffset(arg, 26)
        textButton.Position = position
        textButton.BackgroundColor3 = tbl17.Pill
        textButton.BackgroundTransparency = 0.05
        textButton.BorderSizePixel = 0
        textButton.AutoButtonColor = false
        textButton.Text = ""
        textButton.Parent = frame
        createUICorner(textButton, 13)
        local v79 = createUIStroke(textButton, tbl17.White, 1, 0.72)
        local uiScale = Instance.new("UIScale")
        uiScale.Name = "PressScale"
        uiScale.Parent = textButton
        local frame2 = Instance.new("Frame")
        frame2.Name = "Dot"
        frame2.Size = UDim2.fromOffset(6, 6)
        frame2.Position = UDim2.new(0, 10, 0.5, -3)
        frame2.BackgroundColor3 = tbl17.DotOff
        frame2.BorderSizePixel = 0
        frame2.Parent = textButton
        createUICorner(frame2, 3)
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "Label"
        textLabel.Size = UDim2.new(1, -26, 1, 0)
        textLabel.Position = UDim2.fromOffset(22, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = ""
        textLabel.TextSize = 9
        textLabel.TextColor3 = tbl17.White
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextXAlignment = Enum.TextXAlignment.Center
        textLabel.Parent = textButton
        local tweenInfo = TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        textButton.MouseEnter:Connect(function()
          TweenService:Create(v79, tweenInfo, { Transparency = 0.35 }):Play()
          TweenService:Create(textButton, tweenInfo, { BackgroundColor3 = Color3.fromRGB(28, 28, 33) }):Play()
        end)

        textButton.MouseLeave:Connect(function()
          TweenService:Create(v79, tweenInfo, { Transparency = 0.72 }):Play()
          TweenService:Create(textButton, tweenInfo, { BackgroundColor3 = tbl17.Pill }):Play()
        end)

        textButton.MouseButton1Down:Connect(function()
          TweenService:Create(uiScale, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.93 }):Play()
        end)

        textButton.MouseButton1Up:Connect(function()
          TweenService:Create(uiScale, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
        end)

        return textButton, textLabel, frame2
      end

      CodeToggle, v75, v76 = fn32("CodeToggle", UDim2.new(0, 44, 0.5, -13), 148)
      OGToggle, v78, v77 = fn32("OGToggle", UDim2.new(1, -96, 0.5, -13), 140)
    end
  end

  local textLabel = Instance.new("TextLabel")
  textLabel.Name = "HubStats"
  textLabel.AnchorPoint = Vector2.new(0.5, 0)
  textLabel.Size = UDim2.new(0, 150, 1, 0)
  textLabel.Position = UDim2.new(0.5, 20, 0, 0)
  textLabel.BackgroundTransparency = 1
  textLabel.RichText = true
  textLabel.Text =
    '<font color="#96989F">FPS</font>  <font color="#F5F5F5">--</font>    <font color="#45464C">|</font>    <font color="#96989F">PING</font>  <font color="#F5F5F5">--</font>'
  textLabel.TextSize = 10
  textLabel.TextColor3 = tbl17.White
  textLabel.Font = Enum.Font.GothamBold
  textLabel.TextXAlignment = Enum.TextXAlignment.Center
  textLabel.Parent = frame
  local flag15 = false
  local position = nil
  local position2 = nil

  frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
      flag15 = true
      position = input.Position
      position2 = frame.Position

      input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancel then
          flag15 = false
        end
      end)
    end
  end)

  game:GetService("UserInputService").InputChanged:Connect(function(input)
    if flag15 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
      local n32 = input.Position - position
      frame.Position = UDim2.new(position2.X.Scale, position2.X.Offset + n32.X, position2.Y.Scale, position2.Y.Offset + n32.Y)
    end
  end)

  fn29 = function()
    local aceCodeSniperGui = genv.ACECodeSniperGui
    if aceCodeSniperGui and aceCodeSniperGui.Parent then
      return aceCodeSniperGui
    end
    return fn28("ACECodeSniperUI")
  end

  fn30 = function()
    local aceFinderRuntime = genv.ACEFinderRuntime
    if type(aceFinderRuntime) ~= "table" or not aceFinderRuntime.Running then
      return nil
    end

    if aceFinderRuntime.Gui and aceFinderRuntime.Gui.Parent then
      return aceFinderRuntime.Gui
    end
    return fn28("FinderUI")
  end

  fn31 = function()
    local v79 = fn29()
    local v80 = fn30()
    local enabled = v79 ~= nil and v79.Enabled
    local enabled2 = v80 ~= nil and v80.Enabled
    v75.Text = enabled and "CLOSE CODE SNIPER" or "OPEN CODE SNIPER"
    v78.Text = enabled2 and "CLOSE OG SNIPER" or "OPEN OG SNIPER"
    v76.BackgroundColor3 = enabled and tbl17.White or tbl17.DotOff
    v77.BackgroundColor3 = enabled2 and tbl17.White or tbl17.DotOff
  end

  task.spawn(function()
    while true do
      if screenGui and screenGui.Parent then
        local v79 = 0
        local now2 = os.clock()

        local connection = RunService.RenderStepped:Connect(function()
          v79 += 1
        end)

        task.wait(0.5)
        connection:Disconnect()

        if not screenGui.Parent then
          break
        else
          local n32 = math.floor(v79 / math.max(os.clock() - now2, 0.01) + 0.5)
          local n33 = nil

          pcall(function()
            n33 = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
          end)

          textLabel.Text = '<font color="#96989F">FPS</font>  <font color="#F5F5F5">'
            .. tostring(n32)
            .. "</font>"
            .. '    <font color="#45464C">|</font>    '
            .. '<font color="#96989F">PING</font>  <font color="#F5F5F5">'
            .. (n33 and tostring(n33) or "--")
            .. "</font>"
          fn31()
          task.wait(0.5)
          continue
        end
      end

      break
    end
  end)
end

do
  local fn32

  do
    local flag15 = false

    fn32 = function()
      local v75 = fn29()

      if v75 and v75.Parent then
        if v75.Enabled then
          v75.Enabled = false
        else
          v75.Enabled = true

          if type(genv.ACECodeSniperOpenAnimation) == "function" then
            pcall(genv.ACECodeSniperOpenAnimation)
          end
        end

        fn31()
        return
      end

      if flag15 then
        return
      end
      flag15 = true

      task.spawn(function()
        pcall(fn27)

        flag15 = false
        pcall(fn31)
      end)
    end
  end

  local flag15 = false

  local function fn33()
    local v75 = fn30()

    if v75 then
      if v75.Enabled then
        v75.Enabled = false
      else
        v75.Enabled = true
        local aceFinderRuntime = genv.ACEFinderRuntime
        local v76 = "table"

        if type(aceFinderRuntime) == v76 and type(aceFinderRuntime.PlayOpenAnimation) == "function" then
          pcall(aceFinderRuntime.PlayOpenAnimation)
        end
      end

      fn31()
      return
    end

    if flag15 then
      return
    end
    flag15 = true

    task.spawn(function()
      pcall(fn26)

      local v76 = setthreadidentity or setidentity

      if v76 then
        pcall(v76, 8)
      end

      flag15 = false
      pcall(fn31)
    end)
  end

  CodeToggle.MouseButton1Click:Connect(fn32)
  OGToggle.MouseButton1Click:Connect(fn33)
end

do
  genv.ACESniperBarDock = function(arg)
    if arg == "code" then
      local v75 = fn29()

      if v75 then
        v75.Enabled = false
      end
    else
      local v75 = fn30()

      if v75 then
        v75.Enabled = false
      end
    end

    fn31()
  end

  do
    local aceAntiRagdollStop = genv.ACEAntiRagdollStop

    if type(aceAntiRagdollStop) == "function" then
      pcall(aceAntiRagdollStop)
    end
  end
end

do
  do
    local n32 = 0

    local connection = RunService.Heartbeat:Connect(function()
      local character = localPlayer.Character
      if not character then
        return
      end
      local humanoid = character:FindFirstChildOfClass("Humanoid")
      local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
      if not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
        return
      end
      local state = humanoid:GetState()

      if
        state == Enum.HumanoidStateType.Physics
        or state == Enum.HumanoidStateType.Ragdoll
        or state == Enum.HumanoidStateType.FallingDown
      then
        local now2 = tick()
        if now2 - n32 <= 0.15 then
          return
        end
        n32 = now2

        pcall(function()
          humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
          humanoidRootPart.Velocity = Vector3.zero
          humanoidRootPart.RotVelocity = Vector3.zero
          humanoidRootPart.AssemblyAngularVelocity = Vector3.zero

          for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("Motor6D") then
              descendant.Enabled = true
            end
          end

          for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("Constraint") then
              descendant.Enabled = true
            end
          end

          if workspace.CurrentCamera then
            workspace.CurrentCamera.CameraSubject = humanoid
          end

          local playerScripts = localPlayer:FindFirstChild("PlayerScripts")
          local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")

          if playerModule then
            local ok, result = pcall(function()
              return require(playerModule:FindFirstChild("ControlModule"))
            end)

            if ok and result and result.Enable then
              pcall(function()
                result:Enable()
              end)
            end
          end

          humanoid.AutoRotate = true
          humanoid.PlatformStand = false
          humanoid.Sit = false
        end)
      end
    end)

    genv.ACEAntiRagdollStop = function()
      if connection then
        pcall(function()
          connection:Disconnect()
        end)

        connection = nil
      end

      genv.ACEAntiRagdollStop = nil
    end
  end
end

do
  local position = frame.Position
  frame.Position = UDim2.new(position.X.Scale, position.X.Offset, 0, -56)
  TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = position }):Play()
end

fn31()
