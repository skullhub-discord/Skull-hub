local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Light Hub ⛰️",
   LoadingTitle = "Light Hub is loading!",
   LoadingSubtitle = "Backdooring Escape Tsunami for Cars... 🏎️💨",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "MyScript",
      FileName = "LightHubConfig"
   },
   Discord = {
      Enabled = true,
      Invite = "https://discord.gg/TF4cyx6xyd",
      RememberJoins = true
   },
   KeySystem = false
})

-- Services & Local Player Variables
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Feature States
local cfSpeedEnabled = false
local tpWalkEnabled = false
local jumpEnabled = false
local infJumpEnabled = false
local noclipEnabled = false
local infZoomEnabled = false

local currentCFSpeed = 1000
local currentTPIncrement = 150 
local currentJumpPower = 500
local normalJumpPower = 50

local originalMaxZoom = LocalPlayer.CameraMaxZoomDistance

-- Visuals / Performance / ESP States
local fullbrightEnabled = false
local noFogEnabled = false
local fpsBoosterEnabled = false
local playerEspEnabled = false
local carEspEnabled = false
local autoFarmAllCars = false
local farmTweenSpeed = 175

-- Added Automation Global Toggle Variables
_G.AutoCollect = false
_G.AutoUpgradeBase = false
_G.AutoBuySpeed = false
_G.AutoUpgradeCar = false

-- Remote References Setup
local RS = game:GetService("ReplicatedStorage")
local Remotes = {
   Collect = RS:WaitForChild("RemoteEvents"):WaitForChild("CollectMoney"),
   Speed = RS:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeSpeed"),
   Car = RS:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeCar"),
   Base = RS:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeBase")
}

-- Lighting Backups
local origAmbient = Lighting.Ambient
local origOutdoorAmbient = Lighting.OutdoorAmbient
local origBrightness = Lighting.Brightness
local origFogEnd = Lighting.FogEnd
local origFogStart = Lighting.FogStart
local origAtmosphere = Lighting:FindFirstChildWhichIsA("Atmosphere")

-- Explicit Rarity Color Profiles
local rarityColors = {
    ["secret"]    = Color3.fromRGB(255, 215, 0),   -- Gold
    ["cosmic"]    = Color3.fromRGB(138, 43, 226),  -- Blue-Violet
    ["mythical"]  = Color3.fromRGB(255, 0, 127),   -- Hot Pink
    ["legendary"] = Color3.fromRGB(255, 69, 0),    -- Orange-Red
    ["epic"]      = Color3.fromRGB(148, 0, 211),   -- Purple
    ["rare"]      = Color3.fromRGB(30, 144, 255),  -- Deep Sky Blue
    ["uncommon"]  = Color3.fromRGB(50, 205, 50),   -- Lime Green
    ["common"]    = Color3.fromRGB(192, 192, 192)  -- Silver
}

-- ====================== TWEEN TELEPORT ENGINE ======================
local currentTween = nil
local function TweenTo(targetCFrame, speed)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if currentTween then currentTween:Cancel() end
    
    speed = speed or 150
    local distance = (root.Position - targetCFrame.Position).Magnitude
    local duration = distance / speed
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    currentTween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    currentTween:Play()
    pcall(function() currentTween.Completed:Wait() end)
end

-- ====================== ESP LOGIC HANDLING ======================
local function applyHighlight(object, color)
    local highlight = object:FindFirstChild("HubESP")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "HubESP"
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.Parent = object
    end
    highlight.FillColor = color
    highlight.FillTransparency = 0.4
    highlight.Adornee = object
end

local function removeHighlight(object)
    local highlight = object:FindFirstChild("HubESP")
    if highlight then highlight:Destroy() end
end

-- Multi-Rarity Overlay Update Loop
task.spawn(function()
    while true do
        -- Player Tracking
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if playerEspEnabled then
                    applyHighlight(player.Character, Color3.fromRGB(255, 50, 50))
                else
                    removeHighlight(player.Character)
                end
            end
        end

        -- Vehicle Structural Scanning
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if (obj:IsA("Model") or obj:IsA("Tool")) and obj:FindFirstChild("Handle") then
                if carEspEnabled then
                    local name = obj.Name:lower()
                    local matchedColor = nil
                    
                    for rarityKeyword, color in pairs(rarityColors) do
                        if name:find(rarityKeyword) or (obj:FindFirstChild("Rarity") and obj.Rarity.Value:lower() == rarityKeyword) then
                            matchedColor = color
                            break
                        end
                    end
                    
                    matchedColor = matchedColor or Color3.fromRGB(0, 255, 255)
                    applyHighlight(obj, matchedColor)
                else
                    removeHighlight(obj)
                end
            end
        end
        task.wait(1)
    end
end)

-- ====================== MOVEMENT & ENGINE LOOPS ======================
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if root and hum then
        if cfSpeedEnabled and hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * (currentCFSpeed / 100))
        end
        if tpWalkEnabled and hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * currentTPIncrement)
        end
        if jumpEnabled then
            hum.UseJumpPower = true
            hum.JumpPower = currentJumpPower
        else
            hum.UseJumpPower = true
            hum.JumpPower = normalJumpPower
        end
    end
end)

RunService.Stepped:Connect(function()
    if noclipEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
    
    if fullbrightEnabled then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
    end
    if noFogEnabled then
        Lighting.FogEnd = 999999
        Lighting.FogStart = 999999
        local atmos = Lighting:FindFirstChildWhichIsA("Atmosphere")
        if atmos then atmos.Parent = nil end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ====================== TABS NAVIGATION ======================
local MovementTab = Window:CreateTab("Movement", 4483362458)
local TeleportTab = Window:CreateTab("Teleports", 4483345906)
local ESPTab = Window:CreateTab("ESP Visuals", 4483359857)
local VisualsTab = Window:CreateTab("Visuals & FPS", 4483362734)
local ExtrasTab = Window:CreateTab("Extras", 4483362534)

-- ====================== MOVEMENT SECTION ======================
MovementTab:CreateSection("Speed Settings")

MovementTab:CreateToggle({
   Name = "Toggle CFrame Speed",
   CurrentValue = false,
   Flag = "ToggleCF",
   Callback = function(Value) cfSpeedEnabled = Value end,
})

MovementTab:CreateSlider({
   Name = "CFrame Speed",
   Range = {0, 1000},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 1000,
   Flag = "CFSlider",
   Callback = function(v) currentCFSpeed = v end,
})

MovementTab:CreateToggle({
   Name = "Toggle TP Walk",
   CurrentValue = false,
   Flag = "ToggleTP",
   Callback = function(Value) tpWalkEnabled = Value end,
})

MovementTab:CreateSlider({
   Name = "TP Walk Studs",
   Range = {0, 500},
   Increment = 5,
   Suffix = "Studs",
   CurrentValue = 150,
   Flag = "TPSlider",
   Callback = function(v) currentTPIncrement = v end,
})

MovementTab:CreateSection("Jump Mods & Utility")

MovementTab:CreateToggle({
   Name = "Toggle Jump Power",
   CurrentValue = false,
   Flag = "ToggleJump",
   Callback = function(Value) jumpEnabled = Value end,
})

MovementTab:CreateSlider({
   Name = "Jump Power Value",
   Range = {0, 500},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 500,
   Flag = "JumpSlider",
   Callback = function(v) currentJumpPower = v end,
})

MovementTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJumpToggle",
   Callback = function(Value) infJumpEnabled = Value end,
})

MovementTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value) noclipEnabled = Value end,
})

MovementTab:CreateToggle({
   Name = "Infinite Zoom",
   CurrentValue = false,
   Flag = "InfZoomToggle",
   Callback = function(Value)
        infZoomEnabled = Value
        if Value then
            LocalPlayer.CameraMaxZoomDistance = math.huge
            LocalPlayer.CameraMinZoomDistance = 0.5
        else
            LocalPlayer.CameraMaxZoomDistance = originalMaxZoom
            LocalPlayer.CameraMinZoomDistance = 0.5
        end
   end,
})

-- ====================== TELEPORTS SECTION ======================
TeleportTab:CreateSection("Smooth Tween Coordinate Teleports")

TeleportTab:CreateButton({ Name = "Location 1 (203, -3, 7)", Callback = function() TweenTo(CFrame.new(203, -3, 7)) end })
TeleportTab:CreateButton({ Name = "Location 2 (287, -3, -12)", Callback = function() TweenTo(CFrame.new(287, -3, -12)) end })
TeleportTab:CreateButton({ Name = "Location 3 (403, -3, -8)", Callback = function() TweenTo(CFrame.new(403, -3, -8)) end })
TeleportTab:CreateButton({ Name = "Location 4 (547, -3, -5)", Callback = function() TweenTo(CFrame.new(547, -3, -5)) end })
TeleportTab:CreateButton({ Name = "Location 5 (762, -3, -1)", Callback = function() TweenTo(CFrame.new(762, -3, -1)) end })
TeleportTab:CreateButton({ Name = "Location 6 (1084, -3, -4)", Callback = function() TweenTo(CFrame.new(1084, -3, -4)) end })
TeleportTab:CreateButton({ Name = "Location 7 (1565, -3, 8)", Callback = function() TweenTo(CFrame.new(1565, -3, 8)) end })
TeleportTab:CreateButton({ Name = "Location 8 (2260, -3, -2)", Callback = function() TweenTo(CFrame.new(2260, -3, -2)) end })

-- ====================== ESP SECTION ======================
ESPTab:CreateSection("Active Tracking Overlays")

ESPTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "PlayerEspToggle",
   Callback = function(Value) playerEspEnabled = Value end,
})

ESPTab:CreateToggle({
   Name = "Car Spawns ESP (Separated Rarities)",
   CurrentValue = false,
   Flag = "CarEspToggle",
   Callback = function(Value) carEspEnabled = Value end,
})

-- ====================== VISUALS & FPS SECTION ======================
VisualsTab:CreateSection("Environment Graphics")

VisualsTab:CreateToggle({
   Name = "Fullbright",
   CurrentValue = false,
   Flag = "FullbrightToggle",
   Callback = function(Value)
       fullbrightEnabled = Value
       if not Value then
           Lighting.Ambient = origAmbient
           Lighting.OutdoorAmbient = origOutdoorAmbient
           Lighting.Brightness = origBrightness
       end
   end
})

VisualsTab:CreateToggle({
   Name = "No Fog / Clear Atmosphere",
   CurrentValue = false,
   Flag = "NoFogToggle",
   Callback = function(Value)
       noFogEnabled = Value
       if not Value then
           Lighting.FogEnd = origFogEnd
           Lighting.FogStart = origFogStart
           if origAtmosphere and not origAtmosphere.Parent then
               origAtmosphere.Parent = Lighting
           end
       end
   end
})

VisualsTab:CreateSection("Performance Booster")

VisualsTab:CreateToggle({
   Name = "FPS Booster & Ping Compensation",
   CurrentValue = false,
   Flag = "FPSBoosterToggle",
   Callback = function(Value)
       fpsBoosterEnabled = Value
       if Value then
           settings().Network.IncomingReplicationLag = 0
           for _, v in ipairs(Workspace:GetDescendants()) do
               if v:IsA("BasePart") and not v:IsA("MeshPart") then
                   v.Material = Enum.Material.SmoothPlastic
               elseif v:IsA("MeshPart") then
                   v.TextureID = ""
                   v.Material = Enum.Material.SmoothPlastic
               elseif v:IsA("Decal") or v:IsA("Texture") then
                   v:Destroy()
               end
           end
           for _, v in ipairs(Lighting:GetChildren()) do
               if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                   v.Enabled = false
               end
           end
       end
   end
})

-- ====================== EXTRAS SECTION ======================
ExtrasTab:CreateSection("🏎️ All Cars Auto Farm (Tween + Spawn Loop) 🏎️")

ExtrasTab:CreateToggle({
   Name = "Enable Auto Farm All Cars",
   CurrentValue = false,
   Flag = "AllCarsAutoFarm",
   Callback = function(Value) autoFarmAllCars = Value end,
})

ExtrasTab:CreateSlider({
   Name = "Auto Farm Tween Speed",
   Range = {50, 300},
   Increment = 10,
   Suffix = "studs/s",
   CurrentValue = 175,
   Flag = "FarmTweenSpeedSlider",
   Callback = function(v) farmTweenSpeed = v end,
})

-- Completely functional, synchronized collection loop
task.spawn(function()
    while true do
        if autoFarmAllCars then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not autoFarmAllCars then break end

                    if (obj:IsA("Model") or obj:IsA("Tool")) and obj:FindFirstChild("Handle") then
                        local handle = obj:FindFirstChild("Handle")
                        
                        if handle and handle:IsA("BasePart") and handle.Parent then
                            -- Smoothly tween directly over the car model position
                            TweenTo(CFrame.new(handle.Position + Vector3.new(0, 4, 0)), farmTweenSpeed)
                            task.wait(0.15)
                            
                            -- Fire interactions
                            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt then
                                fireproximityprompt(prompt)
                            else
                                pcall(function()
                                    firetouchinterest(root, handle, 0)
                                    task.wait(0.05)
                                    firetouchinterest(root, handle, 1)
                                end)
                            end
                            task.wait(0.15)
                            
                            -- Return to lobby/spawn zone safely
                            if LocalPlayer.RespawnLocation then
                                TweenTo(CFrame.new(LocalPlayer.RespawnLocation.Position + Vector3.new(0, 5, 0)), farmTweenSpeed)
                            else
                                TweenTo(CFrame.new(0, 20, 0), farmTweenSpeed)
                            end
                            task.wait(0.3)
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- Added Automation Interfaces
ExtrasTab:CreateSection("the knowledge")

ExtrasTab:CreateToggle({
   Name = "Auto Collect Money",
   CurrentValue = false,
   Flag = "MambaAutoCollect",
   Callback = function(Value) _G.AutoCollect = Value end,
})

ExtrasTab:CreateToggle({
   Name = "Auto Buy Base (Buttons/Floors)",
   CurrentValue = false,
   Flag = "MambaAutoBase",
   Callback = function(Value) _G.AutoUpgradeBase = Value end,
})

ExtrasTab:CreateToggle({
   Name = "Auto Buy Speed",
   CurrentValue = false,
   Flag = "MambaAutoSpeed",
   Callback = function(Value) _G.AutoBuySpeed = Value end,
})

ExtrasTab:CreateToggle({
   Name = "Auto Upgrade All Cars",
   CurrentValue = false,
   Flag = "MambaAutoCar",
   Callback = function(Value) _G.AutoUpgradeCar = Value end,
})

-- Micro-Automation Core Loop
task.spawn(function()
    while true do
        task.wait(0.6)
        pcall(function()
            -- Money Collection
            if _G.AutoCollect then
                for i = 1, 50 do Remotes.Collect:FireServer("Slot"..i) end
            end
            
            -- Base Purchase Expansion
            if _G.AutoUpgradeBase then
                task.spawn(function() Remotes.Base:InvokeServer() end)
            end
            
            -- Speed Upgrades
            if _G.AutoBuySpeed then 
                task.spawn(function() Remotes.Speed:InvokeServer() end) 
            end
            
            -- Vehicle Level Management
            if _G.AutoUpgradeCar then
                for i = 1, 50 do 
                    task.spawn(function() Remotes.Car:InvokeServer("Slot"..i) end) 
                end
            end
        end)
    end
end)

ExtrasTab:CreateSection("better godmode")

local tsunamiGod = false
local godConnection

local function SetGodmode(state)
    tsunamiGod = state
    if godConnection then godConnection:Disconnect() end
    if state then
        godConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanTouch = false end
                end
                local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then hum.Health = math.huge end
            end
        end)
    else
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanTouch = true end
            end
        end
    end
end

ExtrasTab:CreateToggle({
   Name = "Tsunami Godmode",
   CurrentValue = false,
   Flag = "TsunamiGod",
   Callback = function(Value) SetGodmode(Value) end,
})

ExtrasTab:CreateSection("Item Duplicator")

local dupeEnabled = false

task.spawn(function()
    while true do
        if dupeEnabled then
            local char = LocalPlayer.Character
            local backpack = LocalPlayer.Backpack
            if char and char:FindFirstChild("Humanoid") then
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                        local clone = tool:Clone()
                        clone.Parent = backpack
                        task.wait(0.04)
                        clone.Parent = char
                        task.wait(0.06)
                        pcall(function() 
                            clone:Activate() 
                            task.wait(0.03)
                            clone.Parent = backpack
                            task.wait(0.03)
                            clone.Parent = char
                        end)
                    end
                end
                
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                        local clone = tool:Clone()
                        clone.Parent = char
                        task.wait(0.07)
                        pcall(function() clone:Activate() end)
                    end
                end
            end
        end
        task.wait(0.08)
    end
end)

ExtrasTab:CreateToggle({
   Name = "Auto-Dupe Toggle (Fixed for Cars - Equip First)",
   CurrentValue = false,
   Flag = "DupeToggle",
   Callback = function(Value) dupeEnabled = Value end,
})

ExtrasTab:CreateSection("Proximity Settings")

local instaPromptsEnabled = false

task.spawn(function()
    while true do
        if instaPromptsEnabled then
            for _, prompt in ipairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    prompt.HoldDuration = 0
                    prompt.RequiresLineOfSight = false
                end
            end
        end
        task.wait(0.5)
    end
end)

ExtrasTab:CreateToggle({
   Name = "Insta Proximity Prompts",
   CurrentValue = false,
   Flag = "InstaToggle",
   Callback = function(Value) instaPromptsEnabled = Value end,
})

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if tsunamiGod then SetGodmode(true) end
end)

print("✅ Light Hub new features")