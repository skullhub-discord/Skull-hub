if _G.AstaHubRunning then return end _G.AstaHubRunning = true AstaFloatBgDecals = { [1] = "rbxassetid://105542572852370", [2] = "rbxassetid://128997600029394", [3] = "rbxassetid://99420703803809", [4] = "rbxassetid://117186687504218", [5] = "rbxassetid://123015462349687", [6] = "rbxassetid://111195293067618", [7] = "rbxassetid://133619037676439", [8] = "rbxassetid://116985758139639", [9] = "rbxassetid://132062039944824", [10] = "rbxassetid://139571679676131", [11] = "rbxassetid://70418952815837", }
astaFloatBgLabels = {}
_G.AstaFloatBgImage = _G.AstaFloatBgImage or ""
ASTA_FLOAT_GUI_NAMES = { "InstaResetButton", "BatV2Button", "AstaHub_", "AstaHubMobilePanel" }

function astaFloatBgApplyTo(frame)
    if not frame or not frame:IsA("GuiObject") then return nil end
    local img = frame:FindFirstChild("AstaFloatBg")
    if not img then
        img = Instance.new("ImageLabel")
        img.Name = "AstaFloatBg"
        img.BackgroundTransparency = 1
        img.Size = UDim2.new(1, 0, 1, 0)
        img.Position = UDim2.new(0, 0, 0, 0)
        img.ScaleType = Enum.ScaleType.Crop
        img.ZIndex = math.max(1, (frame.ZIndex or 1))
        local c = frame:FindFirstChildOfClass("UICorner")
        local cc = Instance.new("UICorner", img)
        cc.CornerRadius = c and c.CornerRadius or UDim.new(0, 18)
        img.Parent = frame
    end
    local id = _G.AstaFloatBgImage or ""
    img.Image = id
    img.ImageTransparency = 0
    img.Visible = (id ~= "")
    return img
end

function astaCollectFloatFrames()
    local out = {}
    local roots = {}
    pcall(function() table.insert(roots, game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")) end)
    pcall(function() table.insert(roots, game:GetService("CoreGui")) end)
    pcall(function() local ok, hui = pcall(gethui) if ok and hui then table.insert(roots, hui) end end)
    for _, root in ipairs(roots) do
        if root then
            for _, name in ipairs(ASTA_FLOAT_GUI_NAMES) do
                local g = root:FindFirstChild(name)
                if g then
                    for _, d in ipairs(g:GetDescendants()) do
                        if (d:IsA("Frame") or d:IsA("TextButton") or d:IsA("ImageButton"))
                            and d.Name ~= "AstaFloatBg"
                            and d:FindFirstChildOfClass("UICorner")
                            and d.AbsoluteSize.X <= 140 and d.AbsoluteSize.Y <= 140 then
                            table.insert(out, d)
                        end
                    end
                end
            end
        end
    end
    return out
end

function astaRefreshFloatBgs()
    for i = #astaFloatBgLabels, 1, -1 do
        local lbl = astaFloatBgLabels[i]
        if lbl and lbl.Parent then
            local id = _G.AstaFloatBgImage or ""
            lbl.Image = id
            lbl.Visible = (id ~= "")
        else
            table.remove(astaFloatBgLabels, i)
        end
    end
    pcall(function()
        for _, f in ipairs(astaCollectFloatFrames()) do
            local img = astaFloatBgApplyTo(f)
            if img then
                local known = false
                for _, l in ipairs(astaFloatBgLabels) do if l == img then known = true break end end
                if not known then table.insert(astaFloatBgLabels, img) end
            end
        end
    end)
end

function astaSetFloatBg(imgId)
    _G.AstaFloatBgImage = imgId or ""
    astaRefreshFloatBgs()
end

function astaAttachFloatBg(frame, corner)
    if not frame then return nil end
    local img = astaFloatBgApplyTo(frame)
    if img then
        if corner then
            local cc = img:FindFirstChildOfClass("UICorner")
            if cc then cc.CornerRadius = UDim.new(0, corner) end
        end
        table.insert(astaFloatBgLabels, img)
    end
    return img
end

function astaAttachFloatGlow(label)
    if not label or label:FindFirstChild("AstaNameGlow") then return end
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    local glow = Instance.new("UIStroke")
    glow.Name = "AstaNameGlow"
    glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    glow.Color = Color3.fromRGB(255, 255, 255)
    glow.Thickness = 1.5
    glow.Transparency = 0.12
    glow.Parent = label
    local tweenService = game:GetService("TweenService")
    tweenService:Create(glow, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Transparency = 0.65,
        Thickness = 0.8
    }):Play()
end
local Players = game:GetService("Players") local RunService = game:GetService("RunService") local UIS = game:GetService("UserInputService") local TS = game:GetService("TweenService") local Lighting = game:GetService("Lighting") local HS = game:GetService("HttpService") local ReplicatedStorage = game:GetService("ReplicatedStorage") local LP = Players.LocalPlayer local camera = workspace.CurrentCamera NS = 60 CS = 29 LAGGER_SPEED_1 = 20 LAGGER_SPEED_2 = 10 MEDUSA_COOLDOWN = 25 BAT_AIMBOT_SPEED = 58 BYPASS_AIMBOT_SPEED = 60 MOBILE_PANEL_WIDTH = 128 MOBILE_PANEL_HEIGHT = 294 CONFIG_FILE = "AstaHub.json" BAT_V2_HIT_DIST = 4.5 _isDraggingButton = false speedMode = false antiRagdollEnabled = false jumpEnabled = false laggerToggled = false laggerLevel = 1 medusaCounterEnabled = false batCounterEnabled = false unwalkEnabled = false autoLeftEnabled = false autoRightEnabled = false autoBatEnabled = false dropMode = 1 antiLagEnabled = false removeAccessoriesEnabled = false stretchEnabled = false stretchFOV = 120 medusaAutoResetEnabled = false uiLocked = false editModeEnabled = false uiScaleValue = 100 btnScaleValue = 100 btnScaleBox = nil espEnabled = false fovSelectorVisible = false bodyLockEnabled = false bodyLockRange = 20 bodyLockRangeBox = nil _bodyLockConn = nil bodyLockSetVisual = nil _blSuppressCount = 0 _blWasEnabled = false _blRestoreTimer = nil _blSmoothRestore = false savedProgressBarPos = nil savedButtonPositions = {} savedMobilePanelPos = nil instaResetFloatingPos = nil tpBatFloatingPos = nil batV2FloatingPos = nil neonWeatherEnabled = false _originalLighting = nil setNeonWeatherVisual = nil currentAnimPack = "Off" originalTryardAnims = nil tryardHeartbeatConn = nil animSelectorLabel = nil autoBatV2Enabled = false autoBatV2SwingEnabled = true autoBatV2HitCooldown = false AUTO_BAT_V2_SPEED = 60 AUTO_BAT_V2_DIST = 1.0 AUTO_BAT_V2_HEIGHT = 1.5 AUTO_BAT_V2_V_OFF = 0.0 AUTO_BAT_V2_HIT_DIST = 4.5 AUTO_BAT_V2_SWING_CD = 0.08 _batV2Conn = nil local speedLinearVelocity = nil local speedAttachment = nil local speedConnection = nil local currentSpeedValue = NS local speedEnabled = false local lastPosition = nil local lastTime = nil local lagbackCooldown = 0 local ownershipTimer = 0 local CoreGui = game:GetService("CoreGui") local InfJumpState = { enabled = true, mode = "hold", } local _xIJBoosting = false local _xIJLastBoost = 0 local _xIJForce = 25 local _xIJFrames = 2 local _xIJCooldown = 0.12 local _xJumpHeld = false local _xHoldIJConn = nil local function _xApplyInfJumpBoost(root) if not root or _xIJBoosting then return end local now = tick() if now - _xIJLastBoost < _xIJCooldown then return end _xIJLastBoost = now _xIJBoosting = true local bv = Instance.new("BodyVelocity") bv.MaxForce = Vector3.new(0, math.huge, 0) bv.P = 1250 local cur = root.AssemblyLinearVelocity bv.Velocity = Vector3.new(cur.X, _xIJForce, cur.Z) bv.Parent = root local frames = 0 local conn conn = RunService.Heartbeat:Connect(function() if frames < _xIJFrames then frames = frames + 1 if bv and bv.Parent then bv.Velocity = bv.Velocity + Vector3.new(0, 0.01, 0) end else if bv then pcall(function() bv:Destroy() end) end if conn then conn:Disconnect() end _xIJBoosting = false end end) end task.spawn(function() local pg = LP:WaitForChild("PlayerGui", 10) if not pg then return end local function hookBtn(btn) if btn:IsA("GuiButton") and btn.Name == "JumpButton" and not btn:GetAttribute("XluIJHooked") then btn:SetAttribute("XluIJHooked", true) btn.MouseButton1Down:Connect(function() if InfJumpState.enabled then _xJumpHeld = true end end) btn.MouseButton1Up:Connect(function() _xJumpHeld = false end) btn.MouseLeave:Connect(function() _xJumpHeld = false end) end end for _, d in ipairs(pg:GetDescendants()) do pcall(hookBtn, d) end pg.DescendantAdded:Connect(function(d) pcall(hookBtn, d) end) end) UIS.JumpRequest:Connect(function() if InfJumpState.enabled and InfJumpState.mode ~= "hold" then _xJumpHeld = true task.delay(0.08, function() _xJumpHeld = false end) end end) UIS.InputBegan:Connect(function(inp, gpe) if gpe then return end if not InfJumpState.enabled then return end if (inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == Enum.KeyCode.Space) or inp.KeyCode == Enum.KeyCode.ButtonA then _xJumpHeld = true end end) UIS.InputEnded:Connect(function(inp) if (inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == Enum.KeyCode.Space) or inp.KeyCode == Enum.KeyCode.ButtonA then _xJumpHeld = false end end) RunService.Heartbeat:Connect(function() if not InfJumpState.enabled or InfJumpState.mode == "hold" then return end if not _xJumpHeld then return end local char = LP.Character if not char then return end local hum = char:FindFirstChildOfClass("Humanoid") local root = char:FindFirstChild("HumanoidRootPart") if not hum or not root or hum.Health <= 0 then return end _xApplyInfJumpBoost(root) end) local function _xStartHoldIJ() if _xHoldIJConn then _xHoldIJConn:Disconnect() end _xHoldIJConn = RunService.Heartbeat:Connect(function() if not InfJumpState.enabled or InfJumpState.mode ~= "hold" then return end local char = LP.Character if not char then return end local root = char:FindFirstChild("HumanoidRootPart") local hum = char:FindFirstChildOfClass("Humanoid") if not root or not hum or hum.Health <= 0 then return end local held = UIS:IsKeyDown(Enum.KeyCode.Space) or _xJumpHeld local vel = root.AssemblyLinearVelocity if held and vel.Y < 35 then root.AssemblyLinearVelocity = Vector3.new(vel.X, 55, vel.Z) end vel = root.AssemblyLinearVelocity if vel.Y < -120 then root.AssemblyLinearVelocity = Vector3.new(vel.X, -120, vel.Z) end end) end _xStartHoldIJ() setInfJumpInternal = function(on) InfJumpState.enabled = on and true or false if not InfJumpState.enabled then _xJumpHeld = false _xIJBoosting = false end end local function createInfJumpPanel() return nil, nil end local function getCharParts() local char = LP.Character if not char then return nil, nil end local hum = char:FindFirstChildOfClass("Humanoid") local root = char:FindFirstChild("HumanoidRootPart") if not hum or not root then return nil, nil end return hum, root end local function claimOwnership(root) pcall(function() root:SetNetworkOwner(LP) end) end local function _spdRestorePhysics() local c = LP.Character if not c then return end for _, part in ipairs(c:GetDescendants()) do if part:IsA("BasePart") then pcall(function() part.CustomPhysicalProperties = nil end) end end end
local function cleanupSpeedPhysics() if speedLinearVelocity then pcall(function() speedLinearVelocity:Destroy() end) speedLinearVelocity = nil end if speedAttachment then pcall(function() speedAttachment:Destroy() end) speedAttachment = nil end if speedConnection then speedConnection:Disconnect() speedConnection = nil end lastPosition = nil lastTime = nil speedEnabled = false _spdRestorePhysics() pcall(function() local c = LP.Character if c then local h = c:FindFirstChildOfClass("Humanoid") if h then h.AutoRotate = true h.WalkSpeed = 16 end end end) end
local function applySpeedWithLinearVelocity(spd) cleanupSpeedPhysics() if not spd or spd <= 0 then return end local hum, root = getCharParts() if root then claimOwnership(root) end speedEnabled = true currentSpeedValue = spd speedConnection = RunService.PreRender:Connect(function() if not speedEnabled then return end local char = LP.Character if not char then return end local hrp = char:FindFirstChild("HumanoidRootPart") local humanoid = char:FindFirstChildOfClass("Humanoid") if not hrp or not humanoid or humanoid.Health <= 0 then return end if humanoid.WalkSpeed < spd - 0.5 then humanoid.WalkSpeed = spd end local moveDir = humanoid.MoveDirection if moveDir.Magnitude > 0 then for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CustomPhysicalProperties = PhysicalProperties.new(100, 1, 0, 100, 100) end end hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * spd, hrp.AssemblyLinearVelocity.Y, moveDir.Z * spd) else hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0) end end) end
-- ================= ASTA SHIFT LOCK (trava reto) =================
if _G.AstaUprightOn == nil then _G.AstaUprightOn = true end
AstaShiftLock = { conn = nil, prevAutoRotate = nil, suppressed = false, lastGameLock = false }
function astaShiftLockBusy()
    if bodyLockEnabled or autoLeftEnabled or autoRightEnabled then return true end
    if tpLockEnabled then return true end
    if _G.AstaAimbotActive then return true end
    return false
end
function astaShiftLockStep()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return end
    local mbLocked = (UIS.MouseBehavior == Enum.MouseBehavior.LockCenter)
    if mbLocked then
        AstaShiftLock.suppressed = false
    elseif AstaShiftLock.lastGameLock then
        AstaShiftLock.suppressed = true
    end
    AstaShiftLock.lastGameLock = mbLocked
    if _G.AstaUprightOn == false or astaShiftLockBusy() or AstaShiftLock.suppressed then
        if AstaShiftLock.prevAutoRotate ~= nil then
            pcall(function() hum.AutoRotate = true end)
            AstaShiftLock.prevAutoRotate = nil
        end
        return
    end
    local st = hum:GetState()
    if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.Seated or st == Enum.HumanoidStateType.Dead then
        return
    end
    if AstaShiftLock.prevAutoRotate == nil then AstaShiftLock.prevAutoRotate = hum.AutoRotate end
    pcall(function()
        hum.AutoRotate = false
        root.AssemblyAngularVelocity = Vector3.zero
        local cam = workspace.CurrentCamera
        local look = cam and cam.CFrame.LookVector or root.CFrame.LookVector
        local flat = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude < 0.01 then
            flat = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
        end
        if flat.Magnitude < 0.01 then return end
        root.CFrame = CFrame.lookAt(root.Position, root.Position + flat.Unit)
    end)
end
function startAstaShiftLock()
    if AstaShiftLock.conn then return end
    AstaShiftLock.conn = RunService.RenderStepped:Connect(function()
        pcall(astaShiftLockStep)
    end)
end
function stopAstaShiftLock()
    if AstaShiftLock.conn then AstaShiftLock.conn:Disconnect() AstaShiftLock.conn = nil end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.AutoRotate = true end) end
    AstaShiftLock.prevAutoRotate = nil
end
function setAstaShiftLock(v)
    _G.AstaUprightOn = v and true or false
    AstaShiftLock.suppressed = false
    AstaShiftLock.lastGameLock = false
    if _G.AstaUprightOn then startAstaShiftLock() else
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.AutoRotate = true end) end
        AstaShiftLock.prevAutoRotate = nil
    end
end
_G.AstaSetShiftLock = setAstaShiftLock
LP.CharacterAdded:Connect(function()
    task.wait(0.4)
    AstaShiftLock.prevAutoRotate = nil
end)
startAstaShiftLock()
local ANIM_PACKS = { Zombie = { idle1 = "rbxassetid://10921344533", idle2 = "rbxassetid://10921345304", walk = "rbxassetid://10921355261", run = "rbxassetid://616163682", jump = "rbxassetid://10921351278", fall = "rbxassetid://10921350320", climb = "rbxassetid://10921343576", swim = "rbxassetid://10921352344", swimidle = "rbxassetid://10921353442", }, Vampire = { idle1 = "rbxassetid://10921315373", idle2 = "rbxassetid://10921315373", walk = "rbxassetid://10921326949", run = "rbxassetid://10921320299", jump = "rbxassetid://10921322186", fall = "rbxassetid://10921321317", climb = "rbxassetid://10921314188", swim = "rbxassetid://10921324408", swimidle = "rbxassetid://10921325443", }, Tryhard = { idle1 = "rbxassetid://133806214992291", idle2 = "rbxassetid://94970088341563", walk = "rbxassetid://707897309", run = "rbxassetid://707861613", jump = "rbxassetid://116936326516985", fall = "rbxassetid://116936326516985", climb = "rbxassetid://116936326516985", swim = "rbxassetid://116936326516985", swimidle = "rbxassetid://116936326516985", }, Crazy = { idle1 = "rbxassetid://133806214992291", idle2 = "rbxassetid://94970088341563", walk = "rbxassetid://134824450619865", run = "rbxassetid://134824450619865", jump = "rbxassetid://121454505477205", fall = "rbxassetid://94788218468396", climb = "rbxassetid://121454505477205", swim = "rbxassetid://121454505477205", swimidle = "rbxassetid://121454505477205", }, ["Ninja"] = { idle1 = "rbxassetid://656117400", idle2 = "rbxassetid://656117400", walk = "rbxassetid://656121766", run = "rbxassetid://656118852", jump = "rbxassetid://656117878", fall = "rbxassetid://656115606", climb = "rbxassetid://656114359", swim = "rbxassetid://656121766", swimidle = "rbxassetid://656117400", }, ["Knight"] = { idle1 = "rbxassetid://657595757", idle2 = "rbxassetid://657595757", walk = "rbxassetid://657552124", run = "rbxassetid://657564596", jump = "rbxassetid://658409194", fall = "rbxassetid://657600338", climb = "rbxassetid://658360781", swim = "rbxassetid://657552124", swimidle = "rbxassetid://657595757", }, ["Elder"] = { idle1 = "rbxassetid://845397899", idle2 = "rbxassetid://845397899", walk = "rbxassetid://845403856", run = "rbxassetid://845386501", jump = "rbxassetid://845398858", fall = "rbxassetid://845397673", climb = "rbxassetid://845392038", swim = "rbxassetid://845403856", swimidle = "rbxassetid://845397899", }, ["Levitate"] = { idle1 = "rbxassetid://616006778", idle2 = "rbxassetid://616006778", walk = "rbxassetid://616013216", run = "rbxassetid://616013216", jump = "rbxassetid://616008936", fall = "rbxassetid://616005863", climb = "rbxassetid://616003713", swim = "rbxassetid://616013216", swimidle = "rbxassetid://616006778", }, ["Astronaut"] = { idle1 = "rbxassetid://891621366", idle2 = "rbxassetid://891621366", walk = "rbxassetid://891636393", run = "rbxassetid://891636393", jump = "rbxassetid://891627522", fall = "rbxassetid://891617961", climb = "rbxassetid://891609353", swim = "rbxassetid://891636393", swimidle = "rbxassetid://891621366", }, ["Pirate"] = { idle1 = "rbxassetid://750781874", idle2 = "rbxassetid://750781874", walk = "rbxassetid://750785693", run = "rbxassetid://750783738", jump = "rbxassetid://750782230", fall = "rbxassetid://750780242", climb = "rbxassetid://750779899", swim = "rbxassetid://750785693", swimidle = "rbxassetid://750781874", }, ["Toy"] = { idle1 = "rbxassetid://782841498", idle2 = "rbxassetid://782841498", walk = "rbxassetid://782843345", run = "rbxassetid://782842708", jump = "rbxassetid://782847020", fall = "rbxassetid://782846423", climb = "rbxassetid://782843869", swim = "rbxassetid://782843345", swimidle = "rbxassetid://782841498", }, ["Werewolf"] = { idle1 = "rbxassetid://1083195517", idle2 = "rbxassetid://1083195517", walk = "rbxassetid://1083178339", run = "rbxassetid://1083216690", jump = "rbxassetid://1083218792", fall = "rbxassetid://1083189019", climb = "rbxassetid://1083182000", swim = "rbxassetid://1083178339", swimidle = "rbxassetid://1083195517", }, ["Rthro"] = { idle1 = "rbxassetid://2510196951", idle2 = "rbxassetid://2510196951", walk = "rbxassetid://2510202577", run = "rbxassetid://2510198475", jump = "rbxassetid://2510197830", fall = "rbxassetid://2510195892", climb = "rbxassetid://2510192778", swim = "rbxassetid://2510202577", swimidle = "rbxassetid://2510196951", }, ["Stylish"] = { idle1 = "rbxassetid://616136790", idle2 = "rbxassetid://616136790", walk = "rbxassetid://616146177", run = "rbxassetid://616140816", jump = "rbxassetid://616139451", fall = "rbxassetid://616134815", climb = "rbxassetid://616133594", swim = "rbxassetid://616146177", swimidle = "rbxassetid://616136790", }, ["Zombie X"] = { idle1 = "rbxassetid://616158929", idle2 = "rbxassetid://616160636", walk = "rbxassetid://616168032", run = "rbxassetid://616163682", jump = "rbxassetid://616161997", fall = "rbxassetid://616157476", climb = "rbxassetid://616156119", swim = "rbxassetid://616168032", swimidle = "rbxassetid://616158929", }, ["Vampire X"] = { idle1 = "rbxassetid://1083445855", idle2 = "rbxassetid://1083445855", walk = "rbxassetid://1083473930", run = "rbxassetid://1083462077", jump = "rbxassetid://1083455352", fall = "rbxassetid://1083443587", climb = "rbxassetid://1083439238", swim = "rbxassetid://1083473930", swimidle = "rbxassetid://1083445855", } } local ANIM_PACK_ORDER = {{"Off", "Off"}, {"Tryhard", "Tryhard"}, {"Crazy", "Crazy"}, {"Zombie", "Zombie"}, {"Vampire", "Vampire"}, {"Ninja", "Ninja"}, {"Knight", "Knight"}, {"Elder", "Elder"}, {"Levitate", "Levitate"}, {"Astronaut", "Astronaut"}, {"Pirate", "Pirate"}, {"Toy", "Toy"}, {"Werewolf", "Werewolf"}, {"Rthro", "Rthro"}, {"Stylish", "Stylish"}, {"Zombie X", "Zombie X"}, {"Vampire X", "Vampire X"}} local function isPackAnim(id) for _, pack in pairs(ANIM_PACKS) do for _, v in pairs(pack) do if v == id then return true end end end return false end local function saveOriginalAnims(char) local animate = char:FindFirstChild("Animate") if not animate then return end local function g(obj) return obj and obj.AnimationId or nil end local ids = { idle1 = g(animate.idle and animate.idle.Animation1), idle2 = g(animate.idle and animate.idle.Animation2), walk = g(animate.walk and animate.walk.WalkAnim), run = g(animate.run and animate.run.RunAnim), jump = g(animate.jump and animate.jump.JumpAnim), fall = g(animate.fall and animate.fall.FallAnim), climb = g(animate.climb and animate.climb.ClimbAnim), swim = g(animate.swim and animate.swim.Swim), swimidle = g(animate.swimidle and animate.swimidle.SwimIdle), } if not isPackAnim(ids.walk) then originalTryardAnims = ids end end local function applyAnimPack(packName) currentAnimPack = packName if animSelectorLabel then animSelectorLabel.Text = packName end if packName == "Off" then if originalTryardAnims and LP.Character then local animate = LP.Character:FindFirstChild("Animate") if animate then local function s(obj,id) if obj then obj.AnimationId = id end end s(animate.idle and animate.idle.Animation1, originalTryardAnims.idle1) s(animate.idle and animate.idle.Animation2, originalTryardAnims.idle2) s(animate.walk and animate.walk.WalkAnim, originalTryardAnims.walk) s(animate.run and animate.run.RunAnim, originalTryardAnims.run) s(animate.jump and animate.jump.JumpAnim, originalTryardAnims.jump) s(animate.fall and animate.fall.FallAnim, originalTryardAnims.fall) s(animate.climb and animate.climb.ClimbAnim, originalTryardAnims.climb) s(animate.swim and animate.swim.Swim, originalTryardAnims.swim) s(animate.swimidle and animate.swimidle.SwimIdle, originalTryardAnims.swimidle) end end if tryardHeartbeatConn then tryardHeartbeatConn:Disconnect(); tryardHeartbeatConn = nil end return end local pack = ANIM_PACKS[packName] if not pack then return end if tryardHeartbeatConn then tryardHeartbeatConn:Disconnect() end tryardHeartbeatConn = RunService.Heartbeat:Connect(function() local c = LP.Character if not c then return end local animate = c:FindFirstChild("Animate") if not animate then return end local function s(obj,id) if obj then obj.AnimationId = id end end s(animate.idle and animate.idle.Animation1, pack.idle1) s(animate.idle and animate.idle.Animation2, pack.idle2) s(animate.walk and animate.walk.WalkAnim, pack.walk) s(animate.run and animate.run.RunAnim, pack.run) s(animate.jump and animate.jump.JumpAnim, pack.jump) s(animate.fall and animate.fall.FallAnim, pack.fall) s(animate.climb and animate.climb.ClimbAnim, pack.climb) s(animate.swim and animate.swim.Swim, pack.swim) s(animate.swimidle and animate.swimidle.SwimIdle, pack.swimidle) end) end local function startAnimPack(packName) local char = LP.Character if char then saveOriginalAnims(char) applyAnimPack(packName) local hum = char:FindFirstChildOfClass("Humanoid") if hum then for _, track in ipairs(hum:GetPlayingAnimationTracks()) do track:Stop(0) end hum:ChangeState(Enum.HumanoidStateType.Running) end else applyAnimPack(packName) end currentAnimPack = packName end local function stopAnimPack() currentAnimPack = "Off" if animSelectorLabel then animSelectorLabel.Text = "Off" end applyAnimPack("Off") end DEFAULT_KB = { DropBrainrot = {kb = Enum.KeyCode.X, gp = nil}, AutoLeft = {kb = Enum.KeyCode.Z, gp = nil}, AutoRight = {kb = Enum.KeyCode.C, gp = nil}, AutoBat = {kb = Enum.KeyCode.E, gp = nil}, TPFloor = {kb = Enum.KeyCode.F, gp = nil}, GuiHide = {kb = Enum.KeyCode.LeftControl, gp = nil}, CarryToggle = {kb = Enum.KeyCode.Q, gp = nil}, LaggerMode = {kb = Enum.KeyCode.R, gp = nil}, InstaReset = {kb = Enum.KeyCode.G, gp = nil}, TPLock = {kb = Enum.KeyCode.B, gp = nil}, BatV2 = {kb = Enum.KeyCode.N, gp = nil}, TPBypass = {kb = Enum.KeyCode.V, gp = nil}, AntiDesync = {kb = Enum.KeyCode.B, gp = nil}, DropMode = {kb = Enum.KeyCode.T, gp = nil}, } KB = { DropBrainrot = {kb = DEFAULT_KB.DropBrainrot.kb, gp = DEFAULT_KB.DropBrainrot.gp}, AutoLeft = {kb = DEFAULT_KB.AutoLeft.kb, gp = DEFAULT_KB.AutoLeft.gp}, AutoRight = {kb = DEFAULT_KB.AutoRight.kb, gp = DEFAULT_KB.AutoRight.gp}, AutoBat = {kb = DEFAULT_KB.AutoBat.kb, gp = DEFAULT_KB.AutoBat.gp}, TPFloor = {kb = DEFAULT_KB.TPFloor.kb, gp = DEFAULT_KB.TPFloor.gp}, GuiHide = {kb = DEFAULT_KB.GuiHide.kb, gp = DEFAULT_KB.GuiHide.gp}, CarryToggle = {kb = DEFAULT_KB.CarryToggle.kb, gp = DEFAULT_KB.CarryToggle.gp}, LaggerMode = {kb = DEFAULT_KB.LaggerMode.kb, gp = DEFAULT_KB.LaggerMode.gp}, InstaReset = {kb = DEFAULT_KB.InstaReset.kb, gp = DEFAULT_KB.InstaReset.gp}, TPLock = {kb = DEFAULT_KB.TPLock.kb, gp = DEFAULT_KB.TPLock.gp}, BatV2 = {kb = DEFAULT_KB.BatV2.kb, gp = DEFAULT_KB.BatV2.gp}, TPBypass = {kb = DEFAULT_KB.TPBypass.kb, gp = DEFAULT_KB.TPBypass.gp}, AntiDesync = {kb = DEFAULT_KB.AntiDesync.kb, gp = DEFAULT_KB.AntiDesync.gp}, DropMode = {kb = DEFAULT_KB.DropMode.kb, gp = DEFAULT_KB.DropMode.gp}, } _isResetting = false _lastSavedJSON = nil _isLoading = false CONFIG = { AUTO_STEAL_ENABLED = false, STEAL_MODE = "normal", GRAB_RADIUS = 60, STEAL_DURATION = 1.3, HOLD_MIN = 1.3, HOLD_MAX = 2.6, ENTRY_DELAY = 0.3, COOLDOWN = 0.05, STEAL_RANGE = 9, PRIME_RANGE = 80, } StealState = { active = false, startTime = 0, duration = 1.3, phase = "idle", label = "", lastResult = "", lastResultTime = 0, totalSteals = 0, failedSteals = 0, } savedStealRadius = CONFIG.STEAL_RANGE savedStealDuration = CONFIG.HOLD_MAX local plots = workspace:WaitForChild("Plots") local AnimalsData = {} local syncRemotes = nil local plotAnimalSync = { caches = {}, connections = {} } local allAnimalsCache = {} local PromptMemoryCache = {} local InternalStealCache = {} local stealConnection = nil local function splitSyncPath(path) if typeof(path) == "table" then return path end local out = {} for part in string.gmatch(tostring(path), "[^%.]+") do table.insert(out, tonumber(part) or part) end return out end local function resolveSyncPath(path, root) local current = root local parent = nil local key = nil for _, part in ipairs(splitSyncPath(path)) do parent = current key = part current = current and current[part] or nil end return current, parent, key end local function applyPlotSyncDiff(channelName, packet) local cache = plotAnimalSync.caches[channelName] if typeof(cache) ~= "table" then return end local path, action, a, b = packet[1], packet[2], packet[3], packet[4] local current, parent, key = resolveSyncPath(path, cache) if action == "Changed" then if parent ~= nil then parent[key] = a end elseif action == "ArrayInsert" then if current ~= nil then table.insert(current, b, a) end elseif action == "ArrayRemoved" then if current ~= nil then table.remove(current, b) end elseif action == "DictionaryInsert" then if current ~= nil then current[b] = a end elseif action == "DictionaryRemoved" then if current ~= nil then current[b] = nil end end end local function attachPlotChannel(remote) if plotAnimalSync.connections[remote] then return end local channelName = tostring(remote.Name) if not plots:FindFirstChild(channelName) then return end if syncRemotes.requestData and plotAnimalSync.caches[channelName] == nil then local ok, data = pcall(function() return syncRemotes.requestData:InvokeServer(channelName) end) if ok and typeof(data) == "table" then plotAnimalSync.caches[channelName] = data else plotAnimalSync.caches[channelName] = {} end elseif plotAnimalSync.caches[channelName] == nil then plotAnimalSync.caches[channelName] = {} end plotAnimalSync.connections[remote] = remote.OnClientEvent:Connect(function(queue) for _, packet in ipairs(queue) do applyPlotSyncDiff(channelName, packet) end end) end local function detachPlotChannel(channelName) for remote, conn in pairs(plotAnimalSync.connections) do if tostring(remote.Name) == tostring(channelName) then conn:Disconnect() plotAnimalSync.connections[remote] = nil plotAnimalSync.caches[tostring(channelName)] = nil break end end end local function getPlotChannelData(plotName) return plotAnimalSync.caches[plotName] end local function getPlotOwner(plot) local sign = plot:FindFirstChild("PlotSign") local frame = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame") local label = frame and frame:FindFirstChild("TextLabel") if not label or label.Text == "Empty Base" then return nil end return label.Text:gsub("'s [Bb]ase$", ""):gsub("%s+$", "") end local function isMyBaseAnimal(animalData) if not animalData or not animalData.plot then return false end local plot = plots:FindFirstChild(animalData.plot) if not plot then return false end return getPlotOwner(plot) == LP.DisplayName end local function findProximityPromptForAnimal(animalData) if not animalData then return nil end local cached = PromptMemoryCache[animalData.uid] if cached and cached.Parent then return cached end local plot = plots:FindFirstChild(animalData.plot) if not plot then return nil end local podiums = plot:FindFirstChild("AnimalPodiums") if not podiums then return nil end local podium = podiums:FindFirstChild(animalData.slot) if not podium then return nil end local base = podium:FindFirstChild("Base") if not base then return nil end local spawn = base:FindFirstChild("Spawn") if not spawn then return nil end local attach = spawn:FindFirstChild("PromptAttachment") if not attach then return nil end for _, p in ipairs(attach:GetChildren()) do if p:IsA("ProximityPrompt") then PromptMemoryCache[animalData.uid] = p return p end end return nil end local function getAnimalPosition(animalData) local plot = plots:FindFirstChild(animalData.plot) if not plot then return nil end local podiums = plot:FindFirstChild("AnimalPodiums") if not podiums then return nil end local podium = podiums:FindFirstChild(animalData.slot) if not podium then return nil end return podium:GetPivot().Position end local function distToAnimal(animalData) local character = LP.Character if not character then return math.huge end local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") if not hrp then return math.huge end local pos = getAnimalPosition(animalData) if not pos then return math.huge end return (hrp.Position - pos).Magnitude end local function pickClosest() local character = LP.Character if not character then return nil end local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") if not hrp then return nil end local best, bestDist = nil, math.huge for _, animalData in ipairs(allAnimalsCache) do if isMyBaseAnimal(animalData) then continue end local pos = getAnimalPosition(animalData) if not pos then continue end local dist = (hrp.Position - pos).Magnitude if dist > CONFIG.PRIME_RANGE then continue end if dist < bestDist then bestDist = dist best = animalData end end return best end local function scanAllPlots() local newCache = {} for _, plot in ipairs(plots:GetChildren()) do local cache = getPlotChannelData(plot.Name) if not cache then continue end local animalList = cache.AnimalList if typeof(animalList) ~= "table" then continue end for slot, animalData in pairs(animalList) do if type(animalData) == "table" then local animalName = animalData.Index local animalInfo = AnimalsData[animalName] if not animalInfo then continue end table.insert(newCache, { name = animalInfo.DisplayName or animalName, plot = plot.Name, slot = tostring(slot), uid = plot.Name .. "_" .. tostring(slot), }) end end end allAnimalsCache = newCache return #allAnimalsCache end -- ===== SISTEMA DE STEAL/GRAB (Ui) =====
-- ================= STEAL SYSTEM (Auto Steal V3 + Semi) - PORTADO =================
Steal = { AutoStealEnabled = false, Data = {} }
autoStealEnabled = false
selectedStealMode = "Auto Steal V3"
autoStealRadius = 63

_G.StealBar = {
    _last = 0,
    SetProgress = function(p)
        p = tonumber(p) or 0
        if p > 0 then
            StealState.active = true
            StealState.duration = 1
            StealState.startTime = tick() - p
        else
            if _G.StealBar._last >= 0.95 then
                StealState.totalSteals = (StealState.totalSteals or 0) + 1
                StealState.lastResult = "Stole"
                StealState.lastResultTime = tick()
            end
            StealState.active = false
            StealState.phase = "idle"
        end
        _G.StealBar._last = p
    end,
    SetState = function(state)
        if state ~= "STEALING" then
            StealState.active = false
            StealState.phase = "idle"
        else
            StealState.phase = "holding"
        end
    end,
    Reset = function()
        StealState.active = false
        StealState.phase = "idle"
        _G.StealBar._last = 0
    end,
}
_G.__AdaptSetupNormalAutoSteal = function()
local getconnections_v3 = getconnections or get_signal_cons or getconnects or (syn and syn.get_signal_cons)
_G.AdaptGalaxyV3 = _G.AdaptGalaxyV3 or {
conn=nil, active=false, progress=0, paused=false, pauseTime=nil,
startTime=nil, progressConn=nil, dataCache={}, enabled=false,
StealRadius=63, StealDuration=1.3, TriggerRadius=10
}
local GS = _G.AdaptGalaxyV3

local function getHRP()
local c=LP.Character
return c and c:FindFirstChild("HumanoidRootPart")
end

local function isMyPlot(plotName)
local plots=workspace:FindFirstChild("Plots")
if not plots then return false end
local plot=plots:FindFirstChild(plotName)
if not plot then return false end
local sign=plot:FindFirstChild("PlotSign")
if sign then
local yb=sign:FindFirstChild("YourBase")
if yb and yb:IsA("BillboardGui") then return yb.Enabled==true end
end
return false
end

local function findPrompt()
local hrp=getHRP()
if not hrp then return nil,nil end
local plots=workspace:FindFirstChild("Plots")
if not plots then return nil,nil end
local bestPrompt,bestDist,bestSpawn=nil,math.huge,nil

for _,plot in ipairs(plots:GetChildren()) do
if not plot:IsA("Model") then continue end
if isMyPlot(plot.Name) then continue end
local pods=plot:FindFirstChild("AnimalPodiums")
if not pods then continue end

for _,pod in ipairs(pods:GetChildren()) do
pcall(function()
local base=pod:FindFirstChild("Base")
local spawn=base and base:FindFirstChild("Spawn")
if not spawn then return end
local dist=(spawn.Position-hrp.Position).Magnitude
if dist>=bestDist or dist>GS.StealRadius then return end

local function tryPrompt(container)
for _,ch in ipairs(container:GetChildren()) do
if ch:IsA("ProximityPrompt") and ch.Enabled then
bestPrompt=ch
bestDist=dist
bestSpawn=spawn
return true
end
end
end

local att=spawn:FindFirstChild("PromptAttachment")
if not (att and tryPrompt(att)) then
for _,ch in ipairs(spawn:GetDescendants()) do
if ch:IsA("ProximityPrompt") and ch.Enabled then
bestPrompt=ch
bestDist=dist
bestSpawn=spawn
break
end
end
end
end)
end
end
return bestPrompt,bestSpawn
end

local function distToSpawn(spawnPart)
local hrp=getHRP()
if not hrp then return math.huge end
if not spawnPart or not spawnPart.Parent then
local _,ns=findPrompt()
return ns and (hrp.Position-ns.Position).Magnitude or math.huge
end
return (hrp.Position-spawnPart.Position).Magnitude
end

local function updateBar(p,state)
if _G.StealBar then
pcall(function()
_G.StealBar.SetProgress(p or 0)
if state then _G.StealBar.SetState(state) end
end)
end
end

local function execute(prompt,spawnPart)
if GS.active then return end

if not GS.dataCache[prompt] then
local data={hold={},trigger={},ready=true}
if getconnections_v3 then
pcall(function()
for _,c in ipairs(getconnections_v3(prompt.PromptButtonHoldBegan)) do
if c.Function then table.insert(data.hold,c.Function) end
end
for _,c in ipairs(getconnections_v3(prompt.Triggered)) do
if c.Function then table.insert(data.trigger,c.Function) end
end
end)
end
GS.dataCache[prompt]=data
end

local data=GS.dataCache[prompt]
if not data.ready then return end

data.ready=false
GS.active=true
GS.paused=false
GS.startTime=tick()-(GS.progress*GS.StealDuration)
local pauseArmed=true

if GS.progressConn then GS.progressConn:Disconnect() end
updateBar(GS.progress,"STEALING")

GS.progressConn=RunService.Heartbeat:Connect(function()
if not GS.active then
if GS.progressConn then GS.progressConn:Disconnect();GS.progressConn=nil end
return
end

if not GS.enabled or not autoStealEnabled or selectedStealMode~="Auto Steal V3" then
GS.active=false
GS.progress=0
GS.paused=false
data.ready=true
updateBar(0,autoStealEnabled and "READY" or "IDLE")
return
end

if GS.paused then
local dist=distToSpawn(spawnPart)
if dist<=GS.TriggerRadius then
GS.paused=false
GS.pauseTime=nil
GS.startTime=tick()-(0.8*GS.StealDuration)
else
if not GS.pauseTime then
GS.pauseTime=tick()
elseif tick()-GS.pauseTime>=1.3 then
GS.pauseTime=nil
GS.paused=false
GS.active=false
GS.progress=0
data.ready=true
pauseArmed=true
if GS.progressConn then GS.progressConn:Disconnect();GS.progressConn=nil end
updateBar(0,autoStealEnabled and "READY" or "IDLE")
return
end
GS.progress=0.8
updateBar(0.8,"STEALING")
return
end
end

local elapsed=tick()-GS.startTime
local prog=math.clamp(elapsed/GS.StealDuration,0,1)
GS.progress=prog

if pauseArmed and prog>=0.8 then
GS.paused=true
pauseArmed=false
GS.progress=0.8
updateBar(0.8,"STEALING")
return
end

updateBar(prog,"STEALING")

if prog>=1 then
GS.active=false
GS.progress=0
GS.paused=false
pauseArmed=true
if GS.progressConn then GS.progressConn:Disconnect();GS.progressConn=nil end

for _,fn in ipairs(data.trigger) do
task.spawn(function() pcall(fn) end)
end

data.ready=true
updateBar(0,autoStealEnabled and "READY" or "IDLE")
end
end)

for _,fn in ipairs(data.hold) do
task.spawn(function() pcall(fn) end)
end
end

_G.AdaptNormalAutoStealSetRadius=function(v)
GS.StealRadius=tonumber(v) or GS.StealRadius or 63
end

_G.AdaptNormalAutoStealStart=function()
if GS.conn then GS.conn:Disconnect();GS.conn=nil end
GS.enabled=true
GS.StealRadius=tonumber(autoStealRadius) or 63
GS.StealDuration=1.3
GS.TriggerRadius=10
GS.conn=RunService.Heartbeat:Connect(function()
if not GS.enabled or GS.active then return end
if not autoStealEnabled or selectedStealMode~="Auto Steal V3" then return end
local prompt,spawnPart=findPrompt()
if prompt then execute(prompt,spawnPart) end
end)
updateBar(0,"READY")
end

_G.AdaptNormalAutoStealStop=function()
GS.enabled=false
if GS.conn then GS.conn:Disconnect();GS.conn=nil end
if GS.progressConn then GS.progressConn:Disconnect();GS.progressConn=nil end
GS.active=false
GS.progress=0
GS.paused=false
GS.pauseTime=nil
GS.dataCache={}
updateBar(0,autoStealEnabled and "READY" or "IDLE")
end

_G.AdaptNormalAutoStealSync=function()
if autoStealEnabled and selectedStealMode=="Auto Steal V3" then
_G.AdaptNormalAutoStealStart()
else
_G.AdaptNormalAutoStealStop()
end
end
end
_G.__AdaptSetupNormalAutoSteal()
_G.__AdaptSetupSemiAutoSteal = function()
local A = _G.AdaptSemiSteal
if not A then
A = {
enabled = false,
conn = nil,
scanThread = nil,
syncReady = false,
plots = nil,
animalsData = {},
syncRemotes = nil,
plotSync = {caches = {}, connections = {}},
animals = {},
promptCache = {},
internalCache = {},
radius = 9,
primeRange = 80,
holdMin = 1.3,
holdMax = 2.6,
entryDelay = 0.3,
cooldown = 0.05,
state = {
active = false,
startTime = 0,
phase = "idle",
label = "",
lastResult = "",
lastResultTime = 0,
totalSteals = 0,
failedSteals = 0,
},
}
_G.AdaptSemiSteal = A
end
local function rootPart()
local char = LP.Character
return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"))
end
local function barSet(pct, status)
pct = math.clamp(pct or 0, 0, 1)
--Leaked By Xlu0 AndPrime--
--Leaked By Xlu0 AndPrime--
if _G.StealBar then
    _G.StealBar.SetProgress(pct)
    _G.StealBar.SetState(status or "STEALING")
end
end
local function barReset()
if _G.StealBar then
    _G.StealBar.SetProgress(0)
    _G.StealBar.SetState(autoStealEnabled and "READY" or "IDLE")
end
end
local function splitSyncPath(path)
if typeof(path) == "table" then return path end
local out = {}
for part in string.gmatch(tostring(path), "[^%.]+") do table.insert(out, tonumber(part) or part) end
return out
end
local function resolveSyncPath(path, root)
local current, parent, key = root, nil, nil
for _, part in ipairs(splitSyncPath(path)) do
parent, key = current, part
current = current and current[part] or nil
end
return current, parent, key
end
local function applyPlotSyncDiff(channelName, packet)
local cache = A.plotSync.caches[channelName]
if typeof(cache) ~= "table" then return end
local path, action, a, b = packet[1], packet[2], packet[3], packet[4]
local current, parent, key = resolveSyncPath(path, cache)
if action == "Changed" then
if parent ~= nil then parent[key] = a end
elseif action == "ArrayInsert" then
if current ~= nil then table.insert(current, b, a) end
elseif action == "ArrayRemoved" then
if current ~= nil then table.remove(current, b) end
elseif action == "DictionaryInsert" then
if current ~= nil then current[b] = a end
elseif action == "DictionaryRemoved" then
if current ~= nil then current[b] = nil end
end
end
local function attachPlotChannel(remote)
if not A.syncRemotes or A.plotSync.connections[remote] then return end
local channelName = tostring(remote.Name)
if not A.plots:FindFirstChild(channelName) then return end
if A.syncRemotes.requestData and A.plotSync.caches[channelName] == nil then
local ok, data = pcall(function() return A.syncRemotes.requestData:InvokeServer(channelName) end)
A.plotSync.caches[channelName] = (ok and typeof(data) == "table") and data or {}
elseif A.plotSync.caches[channelName] == nil then
A.plotSync.caches[channelName] = {}
end
A.plotSync.connections[remote] = remote.OnClientEvent:Connect(function(queue)
for _, packet in ipairs(queue) do applyPlotSyncDiff(channelName, packet) end
end)
end
local function ensureSync()
if A.syncReady then return true end
local ok = pcall(function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
A.plots = workspace:WaitForChild("Plots")
local Packages = ReplicatedStorage:WaitForChild("Packages", 10)
local Datas = ReplicatedStorage:WaitForChild("Datas", 10)
if not Packages or not Datas then return end
A.animalsData = require(Datas:WaitForChild("Animals"))
local folder = Packages:WaitForChild("Synchronizer")
A.syncRemotes = {
channelFolder = folder:WaitForChild("Channel"),
routeRemote = folder:WaitForChild("CommunicationRoute"),
requestData = folder:FindFirstChild("RequestData"),
}
for _, child in ipairs(A.syncRemotes.channelFolder:GetChildren()) do
if child:IsA("RemoteEvent") then attachPlotChannel(child) end
end
A.syncRemotes.channelFolder.ChildAdded:Connect(function(child)
if child:IsA("RemoteEvent") then attachPlotChannel(child) end
end)
A.syncRemotes.routeRemote.OnClientEvent:Connect(function(actions)
for _, actionData in ipairs(actions) do
local kind, channelName = actionData[1], tostring(actionData[2])
if A.plots:FindFirstChild(channelName) then
if kind == "ListenerAdded" then
local remote = A.syncRemotes.channelFolder:FindFirstChild(channelName)
if remote and remote:IsA("RemoteEvent") then attachPlotChannel(remote) end
elseif kind == "ListenerRemoved" then
for remote, conn in pairs(A.plotSync.connections) do
if tostring(remote.Name) == channelName then
conn:Disconnect()
A.plotSync.connections[remote] = nil
A.plotSync.caches[channelName] = nil
break
end
end
end
end
end
end)
A.syncReady = true
end)
return ok and A.syncReady == true
end
local function getPlotOwner(plot)
local sign = plot and plot:FindFirstChild("PlotSign")
local frame = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame")
local label = frame and frame:FindFirstChild("TextLabel")
if not label or label.Text == "Empty Base" then return nil end
return label.Text:gsub("'s [Bb]ase$", ""):gsub("%s+$", "")
end
local function isMyBaseAnimal(animalData)
if not animalData or not animalData.plot or not A.plots then return false end
local plot = A.plots:FindFirstChild(animalData.plot)
if not plot then return false end
local owner = getPlotOwner(plot)
return owner == LP.DisplayName or owner == LP.Name
end
local function podiumFor(animalData)
local plot = A.plots and A.plots:FindFirstChild(animalData.plot)
local podiums = plot and plot:FindFirstChild("AnimalPodiums")
return podiums and podiums:FindFirstChild(animalData.slot) or nil
end
local function animalPos(animalData)
local podium = podiumFor(animalData)
return podium and podium:GetPivot().Position or nil
end
local function distToAnimal(animalData)
local root = rootPart()
local pos = animalPos(animalData)
return root and pos and (root.Position - pos).Magnitude or math.huge
end
local function findPromptForAnimal(animalData)
if not animalData then return nil end
local cached = A.promptCache[animalData.uid]
if cached and cached.Parent then return cached end
local podium = podiumFor(animalData)
local base = podium and podium:FindFirstChild("Base")
local spawn = base and base:FindFirstChild("Spawn")
local attach = spawn and spawn:FindFirstChild("PromptAttachment")
if not attach then return nil end
for _, prompt in ipairs(attach:GetChildren()) do
if prompt:IsA("ProximityPrompt") then
A.promptCache[animalData.uid] = prompt
return prompt
end
end
return nil
end
local function scanAllPlots()
if not ensureSync() then return 0 end
local newCache = {}
for _, plot in ipairs(A.plots:GetChildren()) do
local cache = A.plotSync.caches[plot.Name]
local animalList = cache and cache.AnimalList
if typeof(animalList) == "table" then
for slot, animalData in pairs(animalList) do
if type(animalData) == "table" then
local animalName = animalData.Index
local info = A.animalsData and A.animalsData[animalName]
if info then
table.insert(newCache, {
name = info.DisplayName or animalName,
plot = plot.Name,
slot = tostring(slot),
uid = plot.Name .. "_" .. tostring(slot),
})
end
end
end
end
end
A.animals = newCache
return #newCache
end
local function pickClosest()
local root = rootPart()
if not root then return nil end
local best, bestDist = nil, math.huge
for _, animalData in ipairs(A.animals) do
if not isMyBaseAnimal(animalData) then
local pos = animalPos(animalData)
local dist = pos and (root.Position - pos).Magnitude or math.huge
if dist <= (A.primeRange or 80) and dist < bestDist then
best, bestDist = animalData, dist
end
end
end
return best
end
local function buildStealCallbacks(prompt)
if A.internalCache[prompt] then return end
local data = {holdCallbacks = {}, triggerCallbacks = {}, ready = true}
local ok1, conns1 = false, nil
if getconnections then ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan) end
if ok1 and type(conns1) == "table" then
for _, conn in ipairs(conns1) do
if type(conn.Function) == "function" then table.insert(data.holdCallbacks, conn.Function) end
end
end
local ok2, conns2 = false, nil
if getconnections then ok2, conns2 = pcall(getconnections, prompt.Triggered) end
if ok2 and type(conns2) == "table" then
for _, conn in ipairs(conns2) do
if type(conn.Function) == "function" then table.insert(data.triggerCallbacks, conn.Function) end
end
end
if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then A.internalCache[prompt] = data end
end
local function executeCandySemi(prompt, animalData)
if not prompt or not prompt.Parent or not animalData then return false end
buildStealCallbacks(prompt)
local data = A.internalCache[prompt]
if not data or not data.ready then return false end
data.ready = false
local label = animalData.name or "Animal"
A.state.active = true
A.state.startTime = tick()
A.state.phase = "holding"
A.state.label = label
task.spawn(function()
for _, fn in ipairs(data.holdCallbacks) do task.spawn(function() pcall(fn) end) end
local holdStart = A.state.startTime
while A.enabled and selectedStealMode == "Semi" and tick() - holdStart < (A.holdMin or 1.3) do
barSet((tick() - holdStart) / (A.holdMax or 2.6), "STEALING")
task.wait()
end
A.state.phase = "waitingRange"
local alreadyInRange = distToAnimal(animalData) <= (tonumber(A.radius) or 9)
local fired = false
while A.enabled and selectedStealMode == "Semi" do
local elapsed = tick() - A.state.startTime
if elapsed > (A.holdMax or 2.6) or not prompt.Parent then break end
barSet(elapsed / (A.holdMax or 2.6), "WAITING RANGE")
if distToAnimal(animalData) <= (tonumber(A.radius) or 9) then
if not alreadyInRange then task.wait(A.entryDelay or 0.3) end
if A.enabled and selectedStealMode == "Semi" then
for _, fn in ipairs(data.triggerCallbacks) do task.spawn(function() pcall(fn) end) end
pcall(function() if _G.AutoCarrySpeed and _G.AutoCarrySpeed.WatchPickup then _G.AutoCarrySpeed.WatchPickup(1.25) end end)
fired = true
end
break
end
task.wait()
end
if fired then
A.state.totalSteals = (A.state.totalSteals or 0) + 1
A.state.lastResult = "Stole " .. label
A.state.phase = "success"
barSet(1, "SUCCESS")
else
A.state.failedSteals = (A.state.failedSteals or 0) + 1
A.state.lastResult = "Missed window: " .. label
A.state.phase = "failed"
barSet(1, "FAILED")
end
A.state.active = false
A.state.lastResultTime = tick()
task.wait(A.cooldown or 0.05)
data.ready = true
task.delay(0.8, function()
if not A.state.active then barReset() end
end)
end)
return true
end
local function ensureScanThread()
if A.scanThread then return end
A.scanThread = task.spawn(function()
while _G.AdaptSemiSteal do
if A.enabled or selectedStealMode == "Semi" then pcall(scanAllPlots) end
task.wait(5)
end
end)
end
_G.AdaptSemiAutoStealSetRadius = function(v)
local n = tonumber(v)
if n then A.radius = n end
end
_G.AdaptSemiAutoStealStop = function()
A.enabled = false
if A.conn then A.conn:Disconnect(); A.conn = nil end
A.state.active = false
A.state.phase = "idle"
barReset()
end
_G.AdaptSemiAutoStealStart = function()
A.radius = tonumber(autoStealRadius) or A.radius or 9
A.enabled = true
if not ensureSync() then return end
ensureScanThread()
pcall(scanAllPlots)
if A.conn then A.conn:Disconnect(); A.conn = nil end
A.conn = RunService.Heartbeat:Connect(function()
if not A.enabled then return end
if selectedStealMode ~= "Semi" then _G.AdaptSemiAutoStealStop(); return end
if A.state.active then return end
local target = pickClosest()
if not target then return end
local prompt = A.promptCache[target.uid]
if not prompt or not prompt.Parent then prompt = findPromptForAnimal(target) end
if prompt then executeCandySemi(prompt, target) end
end)
end
_G.AdaptSemiAutoStealSync = function()
if selectedStealMode == "Semi" and autoStealEnabled then
_G.AdaptSemiAutoStealStart()
else
_G.AdaptSemiAutoStealStop()
end
end
end
_G.__AdaptSetupSemiAutoSteal()
_G.AdaptAutoStealSync = function()
if not autoStealEnabled then
if _G.AdaptNormalAutoStealStop then _G.AdaptNormalAutoStealStop() end
if _G.AdaptSemiAutoStealStop then _G.AdaptSemiAutoStealStop() end
return
end
if selectedStealMode == "Auto Steal V3" then
if _G.AdaptSemiAutoStealStop then _G.AdaptSemiAutoStealStop() end
if _G.AdaptNormalAutoStealSync then _G.AdaptNormalAutoStealSync() end
elseif selectedStealMode == "Semi" then
if _G.AdaptNormalAutoStealStop then _G.AdaptNormalAutoStealStop() end
if _G.AdaptSemiAutoStealSync then _G.AdaptSemiAutoStealSync() end
end
end

-- ---------- BRIDGE COM A UI DO ASTA ----------
local function _syncStealRadius()
    if selectedStealMode == "Semi" then
        autoStealRadius = tonumber(CONFIG.STEAL_RANGE) or 9
        if _G.AdaptSemiAutoStealSetRadius then pcall(_G.AdaptSemiAutoStealSetRadius, autoStealRadius) end
    else
        autoStealRadius = tonumber(CONFIG.GRAB_RADIUS) or 63
        if _G.AdaptNormalAutoStealSetRadius then pcall(_G.AdaptNormalAutoStealSetRadius, autoStealRadius) end
    end
end
_G.AstaSyncStealRadius = _syncStealRadius

function startAutoSteal()
    CONFIG.AUTO_STEAL_ENABLED = true
    autoStealEnabled = true
    Steal.AutoStealEnabled = true
    selectedStealMode = (CONFIG.STEAL_MODE == "semi") and "Semi" or "Auto Steal V3"
    _syncStealRadius()
    if _G.AdaptAutoStealSync then pcall(_G.AdaptAutoStealSync) end
end

function stopAutoSteal()
    CONFIG.AUTO_STEAL_ENABLED = false
    autoStealEnabled = false
    Steal.AutoStealEnabled = false
    if _G.AdaptAutoStealSync then pcall(_G.AdaptAutoStealSync) end
    if _G.StealBar then _G.StealBar.Reset() end
end

function setStealMode(mode)
    CONFIG.STEAL_MODE = (mode == "semi") and "semi" or "normal"
    selectedStealMode = (CONFIG.STEAL_MODE == "semi") and "Semi" or "Auto Steal V3"
    _syncStealRadius()
    if CONFIG.AUTO_STEAL_ENABLED then
        pcall(startAutoSteal)
    else
        stopAutoSteal()
    end
end

function startNormalSteal() CONFIG.STEAL_MODE = "normal" startAutoSteal() end
function stopNormalSteal() if _G.AdaptNormalAutoStealStop then pcall(_G.AdaptNormalAutoStealStop) end end
function startSemiSteal() CONFIG.STEAL_MODE = "semi" startAutoSteal() end
function stopSemiSteal() if _G.AdaptSemiAutoStealStop then pcall(_G.AdaptSemiAutoStealStop) end end

SemiSteal = _G.AdaptSemiSteal or { animalCache = {}, promptCache = {}, stealCache = {}, stealConn = nil, isStealing = false }
_G.AutoSteal = Steal
_G.SemiSteal = SemiSteal
_G.StartAutoSteal = startAutoSteal
task.spawn(function()
    while task.wait(1) do
        if _G.AstaSyncStealRadius then pcall(_G.AstaSyncStealRadius) end
    end
end)

_G.StopAutoSteal = stopAutoSteal


 do local Packages = ReplicatedStorage:WaitForChild("Packages") local Datas = ReplicatedStorage:WaitForChild("Datas") AnimalsData = require(Datas:WaitForChild("Animals")) local folder = Packages:WaitForChild("Synchronizer") syncRemotes = { channelFolder = folder:WaitForChild("Channel"), routeRemote = folder:WaitForChild("CommunicationRoute"), requestData = folder:FindFirstChild("RequestData"), } for _, child in ipairs(syncRemotes.channelFolder:GetChildren()) do if child:IsA("RemoteEvent") then attachPlotChannel(child) end end syncRemotes.channelFolder.ChildAdded:Connect(function(child) if child:IsA("RemoteEvent") then attachPlotChannel(child) end end) syncRemotes.routeRemote.OnClientEvent:Connect(function(actions) for _, action in ipairs(actions) do local kind, channelName = action[1], tostring(action[2]) if not plots:FindFirstChild(channelName) then continue end if kind == "ListenerAdded" then local remote = syncRemotes.channelFolder:FindFirstChild(channelName) if remote and remote:IsA("RemoteEvent") then attachPlotChannel(remote) end elseif kind == "ListenerRemoved" then detachPlotChannel(channelName) end end end) scanAllPlots() end task.spawn(function() while task.wait(5) do scanAllPlots() end end) medusaDebounce = false medusaLastUsed = 0 dropActive = false lastDropTime = 0 lastMoveDir = Vector3.new(0,0,0) origFOV = 70 resetRemote = nil GUID = "f888ee6e-c86d-46e1-93d7-0639d6635d42" autoResetStates = { BALLOON = false, JAIL = false, TINY = false, RAGDOLL = false, ROCKET = false } _anyKeyListening = false _aimbotConn = nil _prevAutoRotate = nil tpLockEnabled = false tpLockSetVisual = nil tpLockConn = nil tpLockPrevAutoRotate = nil tpLockHitCD = false TP_LOCK_SWING_CD = 0.08 tpBatFloatingButton = nil batV2FloatingButton = nil enemySpeedConn = nil movementLoop = nil steppedConn = nil alConn = nil arConn = nil infJumpConn = nil stretchConn = nil stretchFovConn = nil antiLagDescConn = nil medusaResetConns = {} dropConnections = {} enemySpeedLabels = {} Conns = {autoSteal = nil, batCounter = nil, anchor = {}, progress = nil, autoLeft = nil, autoRight = nil} keyButtonRefs = {} progressFill = nil progressPct = nil progressRadLbl = nil pbFrame = nil speedLabel = nil modeValLbl = nil normalBox, carryBox, laggerBox, lagger2Box, radInput, batSpeedBox, uiScaleBox = nil, nil, nil, nil, nil, nil, nil grabRadiusBox, primeRangeBox, updateStealModeButtons = nil, nil, nil modeSelectBtn, dropModeBtnRef = nil, nil setJumpToggleState = nil autoBatSetVisual, autoLeftSetVisual, autoRightSetVisual, setBatCounterVisual, setMedusaVisual, setMedusaAutoResetVisual = nil, nil, nil, nil, nil, nil setAntiRagVisual, setJumpVisual, setUnwalkVisual, setAntiLagVisual, setLockUIVisual, setInstaGrab = nil, nil, nil, nil, nil, nil setEditModeVisual = nil setESPVIsual = nil mobSetAutoBat, mobSetAutoLeft, mobSetAutoRight, mobSetDropBR, mobSetTpDown, mobSetCarry, mobSetLagger1, mobSetLagger2 = nil, nil, nil, nil, nil, nil, nil, nil autoBatV2SetVisual = nil miniBtn, main, gui = nil, nil, nil MobilePanel = nil instaResetFloatingButton = nil showGui = nil hideGui = nil mainUIScale = nil animSelectorLabel = nil pbScale = nil fovToggleBtn = nil fovContainer = nil GAMEPAD_KEYS = { [Enum.KeyCode.ButtonA] = true, [Enum.KeyCode.ButtonB] = true, [Enum.KeyCode.ButtonX] = true, [Enum.KeyCode.ButtonY] = true, [Enum.KeyCode.ButtonL1] = true, [Enum.KeyCode.ButtonR1] = true, [Enum.KeyCode.ButtonL2] = true, [Enum.KeyCode.ButtonR2] = true, [Enum.KeyCode.ButtonL3] = true, [Enum.KeyCode.ButtonR3] = true, [Enum.KeyCode.ButtonStart] = true, [Enum.KeyCode.ButtonSelect] = true, [Enum.KeyCode.DPadUp] = true, [Enum.KeyCode.DPadDown] = true, [Enum.KeyCode.DPadLeft] = true, [Enum.KeyCode.DPadRight] = true, } MOVE_KEYS = { [Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true, [Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true, [Enum.KeyCode.Up] = true, [Enum.KeyCode.Left] = true, [Enum.KeyCode.Down] = true, [Enum.KeyCode.Right] = true, } BAT_COUNTER_SLAP_LIST = { "Bat", "Slap", "Iron Slap", "Gold Slap", "Diamond Slap", "Emerald Slap", "Ruby Slap", "Dark Matter Slap", "Flame Slap", "Nuclear Slap", "Galaxy Slap", "Glitched Slap" } AP = { L1 = Vector3.new(-476.48, -6.28, 92.73), L2 = Vector3.new(-483.12, -4.95, 94.80), L_FACE = Vector3.new(-482.25, -4.96, 92.09), R1 = Vector3.new(-476.16, -6.52, 25.62), R2 = Vector3.new(-483.06, -5.03, 25.48), R_FACE = Vector3.new(-482.06, -6.93, 35.47), } function isGamepadInput(inp) return inp and inp.UserInputType and inp.UserInputType.Name:match("^Gamepad") ~= nil end function isBindableInput(inp) if not inp or inp.KeyCode == Enum.KeyCode.Unknown then return false end if inp.UserInputType == Enum.UserInputType.Keyboard then return true end return isGamepadInput(inp) and GAMEPAD_KEYS[inp.KeyCode] == true end function kbMatch(entry, kc) return kc and (kc == entry.kb or (entry.gp and kc == entry.gp)) end function applyButtonScale() local sc = math.clamp((btnScaleValue or 100)/100, 0.5, 2.5) local function ap(f) if not f then return end local u = f:FindFirstChild("AstaBtnScale") if not u then u = Instance.new("UIScale") u.Name = "AstaBtnScale" u.Parent = f end u.Scale = sc end local function apGui(g) if not g then return end for _, ch in ipairs(g:GetChildren()) do if ch:IsA("GuiObject") then ap(ch) end end end pcall(function() local names = { AstaHubMobilePanel = true, InstaResetButton = true, BatV2Button = true, TpBatButton = true, AntiDesyncButton = true } local parents = {} pcall(function() table.insert(parents, game:GetService("CoreGui")) end) pcall(function() table.insert(parents, LP:FindFirstChildOfClass("PlayerGui")) end) for _, par in ipairs(parents) do if par then for _, g in ipairs(par:GetChildren()) do if g:IsA("ScreenGui") and (names[g.Name] or string.sub(g.Name, 1, 8) == "AstaHub_") then apGui(g) end end end end if MobilePanel then apGui(MobilePanel) end for _, g in ipairs({instaResetFloatingButton, tpBatFloatingButton, batV2FloatingButton, antiAntiFloatingButton}) do if g then apGui(g) end end if miniBtn then ap(miniBtn) end end) end
function resetProgressBar() if progressPct then progressPct.Text = "0%" end if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end end local function doTpDown(force) pcall(function() local char = LP.Character if not char then return end local hrp = char:FindFirstChild("HumanoidRootPart") if not hrp then return end local hum2 = char:FindFirstChildOfClass("Humanoid") if not hum2 then return end if force == false then if hum2.FloorMaterial ~= Enum.Material.Air then return end if not (hrp.Position.Y >= (tonumber(autoTPHeight) or 20)) then return end end local yaw = select(2, hrp.CFrame:ToEulerAnglesYXZ()) hrp.CFrame = CFrame.new(hrp.Position.X, -7.00, hrp.Position.Z) * CFrame.Angles(0, yaw, 0) hrp.AssemblyLinearVelocity = Vector3.zero hrp.AssemblyAngularVelocity = Vector3.zero pcall(function() hrp.Velocity = Vector3.zero end) pcall(function() hrp.RotVelocity = Vector3.zero end) end) end autoTPHeight = autoTPHeight or 20 autoTPEnabled = false local autoTPConn = nil local autoTPLastRun = 0 function stopAutoTPDown() autoTPEnabled = false if autoTPConn then pcall(function() autoTPConn:Disconnect() end) autoTPConn = nil end end function startAutoTPDown() autoTPEnabled = true if autoTPConn then pcall(function() autoTPConn:Disconnect() end) end autoTPLastRun = 0 autoTPConn = RunService.Heartbeat:Connect(function() if not autoTPEnabled then stopAutoTPDown() return end local now = tick() if now - autoTPLastRun < 0.1 then return end autoTPLastRun = now doTpDown(false) end) end function toggleAutoTPDown(on) if on then startAutoTPDown() else stopAutoTPDown() end end local antiRagResetCooldown = 0
local function forceReset()
    local char = LP.Character if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return end
    pcall(function()
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        root.Velocity = Vector3.zero
        root.RotVelocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") then obj.Enabled = true end
            if obj:IsA("Constraint") then obj.Enabled = true end
        end
        workspace.CurrentCamera.CameraSubject = hum
        local PM = LP.PlayerScripts:FindFirstChild("PlayerModule")
        if PM then local CM = require(PM:FindFirstChild("ControlModule")) if CM then CM:Enable() end end
        hum.AutoRotate = true
        hum.PlatformStand = false
        hum.Sit = false
    end)
end
local antiRagConn = nil
local function startAntiRagdoll()
    if antiRagConn then return end
    antiRagdollEnabled = true
    antiRagConn = RunService.Heartbeat:Connect(function()
        if not antiRagdollEnabled then return end
        local char = LP.Character if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local state = hum:GetState()
        local isRagdolled = (state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown)
        if isRagdolled then
            local now = tick()
            if now - antiRagResetCooldown > 0.15 then
                antiRagResetCooldown = now
                forceReset()
            end
        end
    end)
end
local function stopAntiRagdoll()
    antiRagdollEnabled = false
    if antiRagConn then antiRagConn:Disconnect() antiRagConn = nil end
end
local function setAntiRag(on) antiRagdollEnabled = on if on then startAntiRagdoll() else stopAntiRagdoll() end if setAntiRagVisual then setAntiRagVisual(on) end end do local _ragCountdownRunning = false local function _getRagBillboard() local char = LP.Character if not char then return nil, nil end local head = char:FindFirstChild("Head") if not head then return nil, nil end local pGui = LP.PlayerGui local existing = pGui:FindFirstChild("RagCountdownBillboard") if existing then existing:Destroy() end local bb = Instance.new("BillboardGui") bb.Name = "RagCountdownBillboard" bb.Size = UDim2.new(0, 84, 0, 42) bb.StudsOffset = Vector3.new(0, 4.5, 0) bb.AlwaysOnTop = true bb.Adornee = head bb.Parent = pGui local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1, 0, 1, 0) lbl.AnchorPoint = Vector2.new(0.5, 0.5) lbl.Position = UDim2.new(0.5, 0, 0.5, 0) lbl.BackgroundTransparency = 1 lbl.Font = Enum.Font.GothamBlack lbl.TextScaled = true lbl.TextColor3 = Color3.fromRGB(180, 180, 190) lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) lbl.TextStrokeTransparency = 0 lbl.Text = "" lbl.Parent = bb return bb, lbl end local function _ragPunch(lbl, text) if not (lbl and lbl.Parent) then return end lbl.Text = text end local function _startRagCountdown() if _ragCountdownRunning then return end _ragCountdownRunning = true task.spawn(function() local bb, lbl = _getRagBillboard() if not bb then _ragCountdownRunning = false; return end local timeLeft = 2.5 local step = 0.1 while timeLeft > 0 and bb.Parent do _ragPunch(lbl, string.format("%.1f", timeLeft)) task.wait(step) timeLeft = timeLeft - step end if bb and bb.Parent then _ragPunch(lbl, "READY!") task.wait(0.5) if bb and bb.Parent then bb:Destroy() end end _ragCountdownRunning = false end) end local _wasRagdolled = false RunService.Heartbeat:Connect(function() local char = LP.Character if not char then _wasRagdolled = false; return end local hum = char:FindFirstChildOfClass("Humanoid") if not hum or hum.Health <= 0 then _wasRagdolled = false; return end local st = hum:GetState() local inRag = st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown if inRag and not _wasRagdolled then _wasRagdolled = true _startRagCountdown() elseif not inRag then _wasRagdolled = false end end) end local function setupChar(char) if antiRagdollEnabled then task.wait(0.5) startAntiRagdoll() end end LP.CharacterAdded:Connect(setupChar) if LP.Character then task.spawn(function() setupChar(LP.Character) end) end profileImageCache = {}
-- ===== ESP (Player ESP + Tracer) - versao GUI Bord =====
local AceESP = { enabled = false, data = {}, conns = {} }
local ESP_TRACER_ON = true
local espTracerConn = nil
local function espCleanupPlayer(plr)
    local d = AceESP.data[plr]; if not d then return end
    pcall(function() if d.highlight then d.highlight:Destroy() end end)
    pcall(function() if d.billboard then d.billboard:Destroy() end end)
    pcall(function() if d.tracer then d.tracer.Visible=false if d.tracer.Remove then d.tracer:Remove() end end end)
    if d.conns then for _,c in ipairs(d.conns) do pcall(function() c:Disconnect() end) end end
    AceESP.data[plr] = nil
end
local function espSetup(plr, char)
    if not AceESP.enabled or plr == LP then return end
    espCleanupPlayer(plr)
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5))
    local head = char and (char:FindFirstChild("Head") or char:WaitForChild("Head", 5))
    if not hrp or not head then return end
    local hl = Instance.new("Highlight")
    hl.Name = "AceESP"
    hl.Adornee = char
    hl.FillColor = Color3.fromRGB(35, 35, 35)
    hl.FillTransparency = 0.72
    hl.OutlineColor = Color3.fromRGB(245, 245, 245)
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char
    local bb = Instance.new("BillboardGui")
    bb.Name = "AceESPTag"
    bb.Adornee = head
    bb.Size = UDim2.new(0,124,0,34)
    bb.StudsOffset = Vector3.new(0,2.7,0)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.Parent = head
    local box = Instance.new("Frame", bb)
    box.Size = UDim2.new(1,0,1,0) box.BackgroundTransparency = 1 box.BorderSizePixel = 0
    local n = Instance.new("TextLabel", box)
    n.Size = UDim2.new(1,-10,0,17) n.Position = UDim2.new(0,5,0,2) n.BackgroundTransparency = 1
    n.TextColor3 = Color3.fromRGB(255, 255, 255) n.Font = Enum.Font.GothamBlack n.TextSize = 15 n.TextStrokeTransparency = 0.38
    local sub = Instance.new("TextLabel", box)
    sub.Size = UDim2.new(1,-10,0,11) sub.Position = UDim2.new(0,5,0,19) sub.BackgroundTransparency = 1
    sub.TextColor3 = Color3.fromRGB(180, 180, 180) sub.Font = Enum.Font.GothamBold sub.TextSize = 10 sub.TextStrokeTransparency = 0.58
    local conn = RunService.Heartbeat:Connect(function()
        if not AceESP.enabled or not hrp.Parent then return end
        local v = hrp.AssemblyLinearVelocity or hrp.Velocity
        n.Text = string.format("%d speed", math.floor(Vector3.new(v.X,0,v.Z).Magnitude + 0.5))
        sub.Text = plr.Name
    end)
    local tracer = nil
    if Drawing and Drawing.new then
        local ok,obj = pcall(function() return Drawing.new("Line") end)
        if ok and obj then
            pcall(function() obj.Thickness = 2 obj.Transparency = 1 obj.Color = Color3.fromRGB(245, 245, 245) obj.Visible = false end)
            tracer = obj
        end
    end
    AceESP.data[plr] = { highlight = hl, billboard = bb, tracer = tracer, conns = { conn } }
end
local function espOriginPoint(cam)
    -- Origem do tracer: corpo do proprio boneco (torso/HRP), nao o chao da tela
    local char = LP.Character
    local part = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart"))
    if part then
        local ok, pos, on = pcall(function()
            local p, o = cam:WorldToViewportPoint(part.Position)
            return p, o
        end)
        if ok and pos and on and pos.Z > 0 then
            return Vector2.new(pos.X, pos.Y)
        end
    end
    return Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
end
local function espUpdateTracers()
    local cam = workspace.CurrentCamera
    if not cam then return end
    for plr, d in pairs(AceESP.data) do
        local t = d.tracer
        if t then
            local char = plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if (not AceESP.enabled) or (not ESP_TRACER_ON) or not root then
                pcall(function() t.Visible = false end)
            else
                local pos, on = cam:WorldToViewportPoint(root.Position)
                if on and pos.Z > 0 then
                    pcall(function()
                        t.From = espOriginPoint(cam)
                        t.To = Vector2.new(pos.X, pos.Y)
                        t.Visible = true
                    end)
                else
                    pcall(function() t.Visible = false end)
                end
            end
        end
    end
end
local function startESP()
    if AceESP.enabled then return end
    AceESP.enabled = true
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            if plr.Character then espSetup(plr, plr.Character) end
            table.insert(AceESP.conns, plr.CharacterAdded:Connect(function(c) task.defer(espSetup, plr, c) end))
        end
    end
    table.insert(AceESP.conns, Players.PlayerAdded:Connect(function(plr)
        if plr ~= LP then
            table.insert(AceESP.conns, plr.CharacterAdded:Connect(function(c) task.defer(espSetup, plr, c) end))
        end
    end))
    table.insert(AceESP.conns, Players.PlayerRemoving:Connect(espCleanupPlayer))
    if espTracerConn then espTracerConn:Disconnect() end
    espTracerConn = RunService.RenderStepped:Connect(espUpdateTracers)
end
local function stopESP()
    AceESP.enabled = false
    for _, c in ipairs(AceESP.conns or {}) do pcall(function() c:Disconnect() end) end
    AceESP.conns = {}
    if espTracerConn then espTracerConn:Disconnect() espTracerConn = nil end
    for plr, _ in pairs(AceESP.data) do espCleanupPlayer(plr) end
    AceESP.data = {}
end
function toggleESP(on)
    espEnabled = on
    if on then startESP() else stopESP() end
    if setESPVIsual then setESPVIsual(on) end
end
-- ===== fim ESP =====
 function updateEnemySpeedLabels() for _, player in ipairs(Players:GetPlayers()) do if player ~= LP then local char = player.Character if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then local hrp = char:FindFirstChild("HumanoidRootPart") local velocity = hrp.AssemblyLinearVelocity local speed = (Vector3.new(velocity.X, 0, velocity.Z).Magnitude) local label = enemySpeedLabels[player] if not label then local head = char:FindFirstChild("Head") if head then local bb = Instance.new("BillboardGui", head) bb.Size = UDim2.new(0, 100, 0, 25) bb.StudsOffset = Vector3.new(0, 5.5, 0) bb.AlwaysOnTop = true bb.Name = "EnemySpeedGui" local textLabel = Instance.new("TextLabel", bb) textLabel.Size = UDim2.new(1, 0, 1, 0) textLabel.BackgroundTransparency = 1 textLabel.Text = string.format("%.1f", speed) textLabel.TextColor3 = Color3.fromRGB(180, 180, 190) textLabel.Font = Enum.Font.GothamBold textLabel.TextScaled = true textLabel.TextStrokeTransparency = 0 textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) label = textLabel enemySpeedLabels[player] = label end elseif label and label.Parent and label.Parent.Parent ~= char then local head = char:FindFirstChild("Head") if head then label.Parent.Parent = head end end if label then label.Text = string.format("%.1f", speed) end else local label = enemySpeedLabels[player] if label and label.Parent and label.Parent.Parent then label.Parent.Parent = nil end enemySpeedLabels[player] = nil end end end for player, label in pairs(enemySpeedLabels) do if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then if label and label.Parent and label.Parent.Parent then label.Parent.Parent = nil end enemySpeedLabels[player] = nil end end end function startEnemySpeed() if enemySpeedConn then enemySpeedConn:Disconnect() end enemySpeedConn = RunService.Heartbeat:Connect(function() updateEnemySpeedLabels() end) end function stopEnemySpeed() if enemySpeedConn then enemySpeedConn:Disconnect(); enemySpeedConn = nil end end local function getClosestTargetBody() local char = LP.Character if not char then return nil end local root = char:FindFirstChild("HumanoidRootPart") if not root then return nil end local closest, minDist = nil, math.huge for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LP and plr.Character then local tRoot = plr.Character:FindFirstChild("HumanoidRootPart") local hum = plr.Character:FindFirstChildOfClass("Humanoid") if tRoot and hum and hum.Health > 0 then local dist = (tRoot.Position - root.Position).Magnitude if dist < minDist then minDist = dist closest = tRoot end end end end return closest end local function _bodyLockTick() local char = LP.Character if not char then return end local root = char:FindFirstChild("HumanoidRootPart") if not root then return end local hum = char:FindFirstChildOfClass("Humanoid") if not hum then return end local target = getClosestTargetBody() if not target then if not hum.AutoRotate then hum.AutoRotate = true end return end local dist = (target.Position - root.Position).Magnitude if dist > bodyLockRange then if not hum.AutoRotate then hum.AutoRotate = true end return end if hum.AutoRotate then hum.AutoRotate = false end local targetVel = target.AssemblyLinearVelocity local speed3 = targetVel.Magnitude local predictTime = math.clamp(speed3 / 80, 0.08, 0.35) local predictedPos = target.Position + targetVel * predictTime local targetHead = target.Parent and target.Parent:FindFirstChild("Head") local targetHeight = targetHead and targetHead.Position.Y or target.Position.Y local myHeight = root.Position.Y + (hum.HipHeight or 0) local heightDiff = targetHeight - myHeight local verticalCorrection = math.clamp(heightDiff * 0.15, -1.5, 1.5) local flatTarget = Vector3.new(predictedPos.X, root.Position.Y + verticalCorrection, predictedPos.Z) local toPredict = flatTarget - root.Position if toPredict.Magnitude > 0.1 then local goalCF = CFrame.lookAt(root.Position, flatTarget) local diffCF = root.CFrame:Inverse() * goalCF local _, ry, _ = diffCF:ToEulerAnglesXYZ() ry = math.clamp(ry, -2.5, 2.5) root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(0, ry * 42, 0)) end end function startBodyLock() bodyLockEnabled = false if _bodyLockConn then _bodyLockConn:Disconnect() _bodyLockConn = nil end do return end if _bodyLockConn then _bodyLockConn:Disconnect() end _bodyLockConn = RunService.RenderStepped:Connect(function() if not bodyLockEnabled then return end if _blSuppressCount > 0 then return end _bodyLockTick() end) end function stopBodyLock() if _bodyLockConn then _bodyLockConn:Disconnect() _bodyLockConn = nil end local c = LP.Character local root = c and c:FindFirstChild("HumanoidRootPart") if root then root.AssemblyAngularVelocity = Vector3.zero root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, -0.1, root.AssemblyLinearVelocity.Z) end local hum2 = c and c:FindFirstChildOfClass("Humanoid") if hum2 then hum2.AutoRotate = true end end function _suppressBodyLock() _blSuppressCount = _blSuppressCount + 1 if _blSuppressCount == 1 and bodyLockEnabled then _blWasEnabled = true stopBodyLock() if bodyLockSetVisual then bodyLockSetVisual(false) end if _blRestoreTimer then task.cancel(_blRestoreTimer) _blRestoreTimer = nil end _blSmoothRestore = false end end function _unsuppressBodyLock(delayed) if _blSuppressCount > 0 then _blSuppressCount = _blSuppressCount - 1 end if _blSuppressCount == 0 and _blWasEnabled then _blWasEnabled = false local function restore() if bodyLockEnabled then _blSmoothRestore = true startBodyLock() if bodyLockSetVisual then bodyLockSetVisual(true) end task.delay(0.5, function() _blSmoothRestore = false end) end _blRestoreTimer = nil end if delayed then _blRestoreTimer = task.delay(1, restore) else restore() end end end function setupSpeedIndicator(char) local head = char:WaitForChild("Head", 5) if not head then return end local oldBB = head:FindFirstChild("AstaHubSpeedIndicator") if oldBB then oldBB:Destroy() end local bb = Instance.new("BillboardGui", head) bb.Name = "AstaHubSpeedIndicator" bb.Size = UDim2.new(0, 120, 0, 32) bb.StudsOffset = Vector3.new(0, 3.2, 0) bb.AlwaysOnTop = true speedLabel = Instance.new("TextLabel", bb) speedLabel.Size = UDim2.new(1, 0, 1, 0) speedLabel.Position = UDim2.new(0, 0, 0, 0) speedLabel.BackgroundTransparency = 1 speedLabel.Text = "Spd: 0.0" speedLabel.TextColor3 = Color3.fromRGB(180, 180, 190) speedLabel.Font = Enum.Font.GothamBold speedLabel.TextScaled = true speedLabel.TextStrokeTransparency = 0 speedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) local discordBB = head:FindFirstChild("DiscordText") if discordBB then discordBB:Destroy() end discordBB = Instance.new("BillboardGui", head) discordBB.Name = "DiscordText" discordBB.Size = UDim2.new(0, 200, 0, 28) discordBB.StudsOffset = Vector3.new(0, 5.2, 0) discordBB.AlwaysOnTop = true local discordLabel = Instance.new("TextLabel", discordBB) discordLabel.Size = UDim2.new(1, 0, 1, 0) discordLabel.BackgroundTransparency = 1 discordLabel.Text = "discord.gg/hgnQtvMQZ" discordLabel.TextColor3 = Color3.fromRGB(180, 180, 190) discordLabel.Font = Enum.Font.GothamBold discordLabel.TextScaled = true discordLabel.TextStrokeTransparency = 0 discordLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) end function startUnwalk() local c = LP.Character if not c then return end local hum = c:FindFirstChildOfClass("Humanoid") if hum then for _, t in ipairs(hum:GetPlayingAnimationTracks()) do pcall(function() t:Stop() end) end end local anim = c:FindFirstChild("Animate") if anim then unwalkSavedAnimate = anim:Clone() anim:Destroy() end end function stopUnwalk() local c = LP.Character if c then local existing = c:FindFirstChild("Animate") if not existing then local src = game:GetService("StarterPlayer"):FindFirstChildOfClass("StarterCharacterScripts") local starterAnim = src and src:FindFirstChild("Animate") if starterAnim then starterAnim:Clone().Parent = c elseif unwalkSavedAnimate then unwalkSavedAnimate:Clone().Parent = c end end end unwalkSavedAnimate = nil end function refreshSpeedModeLabel() if modeValLbl then if laggerToggled then modeValLbl.Text = laggerLevel == 1 and "Lagger Spd 1" or "Lagger Spd 2" elseif speedMode then modeValLbl.Text = "Carry Mode" else modeValLbl.Text = "Normal" end end end function resetMovementState() refreshSpeedModeLabel() if mobSetCarry then mobSetCarry(speedMode) end if mobSetLagger1 then mobSetLagger1(laggerToggled and laggerLevel == 1) end if mobSetLagger2 then mobSetLagger2(laggerToggled and laggerLevel == 2) end end function toggleCarryMode() if laggerToggled then laggerToggled = false laggerLevel = 1 speedMode = true else speedMode = not speedMode if speedMode then laggerToggled = false laggerLevel = 1 end end resetMovementState() end function toggleLaggerCycle() if speedMode then speedMode = false if mobSetCarry then mobSetCarry(false) end end if not laggerToggled then laggerToggled = true laggerLevel = 1 else laggerLevel = (laggerLevel == 1) and 2 or 1 end resetMovementState() end local oldFire oldFire = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...) if not resetRemote and self.Name:sub(1,3) == "RE/" then resetRemote = self end return oldFire(self, ...) end)) task.spawn(function() task.wait(2) if not resetRemote then for _, d in pairs(game:GetDescendants()) do if d:IsA("RemoteEvent") and d.Name:sub(1,3) == "RE/" then resetRemote = d break end end end end) task.spawn(function() for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do if obj:IsA("RemoteEvent") then obj.OnClientEvent:Connect(function(...) for _, arg in ipairs({...}) do if type(arg) == "string" then local msg = arg:lower() if msg:find("jump higher") and autoResetStates.BALLOON then instareset("balloon") elseif msg:find("jail") and autoResetStates.JAIL then instareset("jail") elseif msg:find("tiny") and autoResetStates.TINY then instareset("tiny") elseif msg:find("ragdoll") and autoResetStates.RAGDOLL then instareset("ragdoll") elseif msg:find("rocket") and autoResetStates.ROCKET then instareset("rocket") end end end end) end end end) RESET_MAX_DURATION = 0.05
resetCooldown = false
resetThread = nil
resetSuccessful = false
stopResetSeq = false
function instareset(resetType)
    if resetCooldown then return end
    resetCooldown = true resetSuccessful = false stopResetSeq = false
    local character = LP.Character
    if not character then resetCooldown = false return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then resetCooldown = false return end
    local isRespawning = false
    resetThread = task.spawn(function()
        local attempts = 0
        local maxAttempts = 16
        local originalHipHeight = humanoid.HipHeight
        while character and character.Parent and humanoid and humanoid.Health > 0 and not isRespawning and not stopResetSeq do
            if LP.Character ~= character then isRespawning = true break end
            pcall(function()
                humanoid.HipHeight = 1e30
                humanoid.AutoRotate = true
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then rootPart.CanCollide = false end
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = false end
                end
            end)
            if not character or not character.Parent or not humanoid or humanoid.Health <= 0 or LP.Character ~= character then resetSuccessful = true break end
            attempts = attempts + 1
            if attempts >= maxAttempts then break end
            task.wait(RESET_MAX_DURATION)
        end
        -- HARD RESET: garante 100% de reset caso o fling nao mate o personagem
        local hardTries = 0
        while not resetSuccessful and hardTries < 25 and not stopResetSeq do
            hardTries = hardTries + 1
            local c = LP.Character
            if not c or not c.Parent then resetSuccessful = true break end
            local h = c:FindFirstChildOfClass("Humanoid")
            if not h or h.Health <= 0 then resetSuccessful = true break end
            pcall(function() h.BreakJointsOnDeath = true end)
            pcall(function() h.Health = 0 end)
            pcall(function() h:TakeDamage(h.MaxHealth * 10) end)
            pcall(function() h:ChangeState(Enum.HumanoidStateType.Dead) end)
            pcall(function() c:BreakJoints() end)
            pcall(function()
                local hrp = c:FindFirstChild("HumanoidRootPart")
                if hrp then hrp:Destroy() end
            end)
            pcall(function()
                local head = c:FindFirstChild("Head")
                if head then head:Destroy() end
            end)
            pcall(function() LP:LoadCharacter() end)
            task.wait(0.08)
            local c2 = LP.Character
            local h2 = c2 and c2:FindFirstChildOfClass("Humanoid")
            if (not c2) or (not c2.Parent) or (not h2) or h2.Health <= 0 or c2 ~= character then resetSuccessful = true end
        end
        if not resetSuccessful and character and character.Parent and humanoid then
            pcall(function()
                humanoid.HipHeight = originalHipHeight
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then rootPart.CanCollide = true end
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end
                end
            end)
        end
        resetCooldown = false resetThread = nil stopResetSeq = false
    end)
end
function stopFrameReset()
    stopResetSeq = true
    if resetThread then pcall(function() task.cancel(resetThread) end) resetThread = nil end
    resetCooldown = false
    local character = LP.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.HipHeight = 2
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then rootPart.CanCollide = true end
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end
                end
            end)
        end
    end
end
LP.CharacterAdded:Connect(function() stopFrameReset() resetCooldown = false resetSuccessful = false stopResetSeq = false end)
function instaReset() instareset("balloon") end
-- ================= KORBLOX =================
korbloxEnabled = false
setKorbloxVisual = nil
KORBLOX_ASSETS = {
    { name = "LeftLeg", id = "rbxassetid://139607673", target = "LeftUpperLeg", hide = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot"} },
    { name = "RightLeg", id = "rbxassetid://139607718", target = "RightUpperLeg", hide = {"RightUpperLeg", "RightLowerLeg", "RightFoot"} },
}
_korbloxParts = {}
_korbloxFollowConn = nil
_korbloxDiedConn = nil
_korbloxAssetCache = {}
_korbloxToken = 0

-- carrega o asset uma vez e guarda em cache (evita GetObjects toda hora e falhas ao respawnar)
function korbloxGetAsset(cfg)
    local cached = _korbloxAssetCache[cfg.name]
    if cached and cached.Parent == nil then
        return cached:Clone()
    end
    local ok, objects = pcall(function() return game:GetObjects(cfg.id) end)
    if not ok or not objects or #objects == 0 then return nil end
    local model = objects[1]
    _korbloxAssetCache[cfg.name] = model
    return model:Clone()
end

function korbloxShowLegs(char)
    if not char then return end
    for _, cfg in ipairs(KORBLOX_ASSETS) do
        for _, partName in ipairs(cfg.hide) do
            local limb = char:FindFirstChild(partName)
            if limb and limb:IsA("BasePart") then
                pcall(function() limb.LocalTransparencyModifier = 0 end)
            end
        end
    end
end

function korbloxStopFollow()
    if _korbloxFollowConn then pcall(function() _korbloxFollowConn:Disconnect() end) _korbloxFollowConn = nil end
    for _, entry in pairs(_korbloxParts) do
        if entry and entry.model then pcall(function() entry.model:Destroy() end) end
    end
    _korbloxParts = {}
    -- limpa qualquer sobra na camera
    local cam = workspace.CurrentCamera
    if cam then
        for _, obj in ipairs(cam:GetChildren()) do
            if obj.Name:sub(1, 8) == "Korblox_" then pcall(function() obj:Destroy() end) end
        end
    end
end

function korbloxRemove()
    _korbloxToken = _korbloxToken + 1
    pcall(korbloxStopFollow)
    korbloxShowLegs(LP.Character)
end

function korbloxApply()
    local char = LP.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    korbloxStopFollow()
    local container = workspace.CurrentCamera
    local applied = 0
    for _, cfg in ipairs(KORBLOX_ASSETS) do
        pcall(function()
            local targetPart = char:FindFirstChild(cfg.target)
            if not targetPart then return end
            local assetModel = korbloxGetAsset(cfg)
            if not assetModel then return end
            assetModel.Name = "Korblox_" .. cfg.name
            local mainMesh = assetModel:IsA("BasePart") and assetModel or assetModel:FindFirstChildWhichIsA("BasePart", true)
            if not mainMesh then assetModel:Destroy() return end
            mainMesh.CanCollide = false
            mainMesh.Massless = true
            mainMesh.Anchored = true
            mainMesh.CFrame = targetPart.CFrame
            -- fica FORA do personagem: nao altera o assembly, logo o jogo nao solta o pet
            assetModel.Parent = container
            -- SO esconde a perna DEPOIS que o mesh carregou (senao a perna sumia sem nada no lugar)
            for _, partName in ipairs(cfg.hide) do
                local limb = char:FindFirstChild(partName)
                if limb and limb:IsA("BasePart") then limb.LocalTransparencyModifier = 1 end
            end
            table.insert(_korbloxParts, { model = assetModel, mesh = mainMesh, target = cfg.target, hide = cfg.hide, offset = targetPart.CFrame:Inverse() * mainMesh.CFrame })
            applied = applied + 1
        end)
    end
    if #_korbloxParts > 0 then
        _korbloxFollowConn = RunService.RenderStepped:Connect(function()
            if not korbloxEnabled then korbloxStopFollow() return end
            local c = LP.Character
            if not c or c ~= char then korbloxStopFollow() return end
            local h = c:FindFirstChildOfClass("Humanoid")
            if not h or h.Health <= 0 then korbloxStopFollow() korbloxShowLegs(c) return end
            for _, entry in ipairs(_korbloxParts) do
                local limb = c:FindFirstChild(entry.target)
                if limb and entry.mesh and entry.mesh.Parent then
                    entry.mesh.CFrame = limb.CFrame * entry.offset
                end
                -- mantem TODAS as partes da perna escondidas (o Roblox reseta o modifier ao dar zoom)
                for _, partName in ipairs(entry.hide) do
                    local p = c:FindFirstChild(partName)
                    if p and p:IsA("BasePart") and p.LocalTransparencyModifier ~= 1 then p.LocalTransparencyModifier = 1 end
                end
            end
        end)
    end
    return applied == #KORBLOX_ASSETS
end

function korbloxReapply(delaySec)
    _korbloxToken = _korbloxToken + 1
    local myToken = _korbloxToken
    task.spawn(function()
        task.wait(delaySec or 0.35)
        for _ = 1, 25 do
            if myToken ~= _korbloxToken then return end
            if not korbloxEnabled then return end
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if char and hum and hum.Health > 0 and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("LeftUpperLeg") and char:FindFirstChild("RightUpperLeg") then
                if korbloxApply() then return end
            end
            task.wait(0.3)
        end
    end)
end

function toggleKorblox(on)
    korbloxEnabled = on
    if on then korbloxReapply(0.1) else korbloxRemove() end
    if setKorbloxVisual then setKorbloxVisual(on) end
end

local function korbloxSetupChar(char)
    if _korbloxDiedConn then pcall(function() _korbloxDiedConn:Disconnect() end) _korbloxDiedConn = nil end
    -- personagem novo: descarta meshes/loops do personagem antigo
    _korbloxToken = _korbloxToken + 1
    pcall(korbloxStopFollow)
    local hum = char:WaitForChild("Humanoid", 10)
    if hum then
        _korbloxDiedConn = hum.Died:Connect(function()
            _korbloxToken = _korbloxToken + 1
            pcall(korbloxStopFollow)
            korbloxShowLegs(char)
        end)
    end
    if not korbloxEnabled then return end
    pcall(function() char:WaitForChild("RightUpperLeg", 10) char:WaitForChild("LeftUpperLeg", 10) end)
    korbloxReapply(0.3)
end

LP.CharacterAdded:Connect(function(char) task.spawn(korbloxSetupChar, char) end)
if LP.Character then
    task.spawn(korbloxSetupChar, LP.Character)
end
-- ================= FIM KORBLOX =================

function stopAutoLeft() if alConn then alConn:Disconnect(); alConn = nil end alPhase = 1 local char = LP.Character if char then local hum = char:FindFirstChildOfClass("Humanoid") if hum then hum:Move(Vector3.zero, false) end end if autoLeftSetVisual then autoLeftSetVisual(false) end if mobSetAutoLeft then mobSetAutoLeft(false) end _unsuppressBodyLock(true) end function startAutoLeft() if autoRightEnabled then autoRightEnabled = false stopAutoRight() if autoRightSetVisual then autoRightSetVisual(false) end if mobSetAutoRight then mobSetAutoRight(false) end end disableAllAimbots() _suppressBodyLock() if alConn then alConn:Disconnect() end alPhase = 1 alConn = RunService.Heartbeat:Connect(function() if not autoLeftEnabled then return end local char = LP.Character if not char then return end local root = char:FindFirstChild("HumanoidRootPart") local hum = char:FindFirstChildOfClass("Humanoid") if not root or not hum then return end local spd = NS if alPhase == 1 then local tgt = Vector3.new(AP.L1.X, root.Position.Y, AP.L1.Z) if (tgt - root.Position).Magnitude < 1 then alPhase = 2 local d = AP.L2 - root.Position local mv = Vector3.new(d.X, 0, d.Z).Unit hum:Move(mv, false) root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd) return end local d = AP.L1 - root.Position local mv = Vector3.new(d.X, 0, d.Z).Unit hum:Move(mv, false) root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd) elseif alPhase == 2 then local tgt = Vector3.new(AP.L2.X, root.Position.Y, AP.L2.Z) if (tgt - root.Position).Magnitude < 1 then hum:Move(Vector3.zero, false) root.AssemblyLinearVelocity = Vector3.zero autoLeftEnabled = false if alConn then alConn:Disconnect(); alConn = nil end alPhase = 1 if autoLeftSetVisual then autoLeftSetVisual(false) end if mobSetAutoLeft then mobSetAutoLeft(false) end _unsuppressBodyLock(true) local facePos = Vector3.new(AP.L_FACE.X, root.Position.Y, AP.L_FACE.Z) if (facePos - root.Position).Magnitude > 0.01 then root.CFrame = CFrame.new(root.Position, facePos) end return end local d = AP.L2 - root.Position local mv = Vector3.new(d.X, 0, d.Z).Unit hum:Move(mv, false) root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd) end end) end function stopAutoRight() if arConn then arConn:Disconnect(); arConn = nil end arPhase = 1 local char = LP.Character if char then local hum = char:FindFirstChildOfClass("Humanoid") if hum then hum:Move(Vector3.zero, false) end end if autoRightSetVisual then autoRightSetVisual(false) end if mobSetAutoRight then mobSetAutoRight(false) end _unsuppressBodyLock(true) end function startAutoRight() if autoLeftEnabled then autoLeftEnabled = false stopAutoLeft() if autoLeftSetVisual then autoLeftSetVisual(false) end if mobSetAutoLeft then mobSetAutoLeft(false) end end disableAllAimbots() _suppressBodyLock() if arConn then arConn:Disconnect() end arPhase = 1 arConn = RunService.Heartbeat:Connect(function() if not autoRightEnabled then return end local char = LP.Character if not char then return end local root = char:FindFirstChild("HumanoidRootPart") local hum = char:FindFirstChildOfClass("Humanoid") if not root or not hum then return end local spd = NS if arPhase == 1 then local tgt = Vector3.new(AP.R1.X, root.Position.Y, AP.R1.Z) if (tgt - root.Position).Magnitude < 1 then arPhase = 2 local d = AP.R2 - root.Position local mv = Vector3.new(d.X, 0, d.Z).Unit hum:Move(mv, false) root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd) return end local d = AP.R1 - root.Position local mv = Vector3.new(d.X, 0, d.Z).Unit hum:Move(mv, false) root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd) elseif arPhase == 2 then local tgt = Vector3.new(AP.R2.X, root.Position.Y, AP.R2.Z) if (tgt - root.Position).Magnitude < 1 then hum:Move(Vector3.zero, false) root.AssemblyLinearVelocity = Vector3.zero autoRightEnabled = false if arConn then arConn:Disconnect(); arConn = nil end arPhase = 1 if autoRightSetVisual then autoRightSetVisual(false) end if mobSetAutoRight then mobSetAutoRight(false) end _unsuppressBodyLock(true) local facePos = Vector3.new(AP.R_FACE.X, root.Position.Y, AP.R_FACE.Z) if (facePos - root.Position).Magnitude > 0.01 then root.CFrame = CFrame.new(root.Position, facePos) end return end local d = AP.R2 - root.Position local mv = Vector3.new(d.X, 0, d.Z).Unit hum:Move(mv, false) root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd) end end) end function getClosestTarget() local char = LP.Character if not char then return nil end local root = char:FindFirstChild("HumanoidRootPart") if not root then return nil end local closest, minDist = nil, math.huge for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LP and plr.Character then local tRoot = plr.Character:FindFirstChild("HumanoidRootPart") local hum = plr.Character:FindFirstChildOfClass("Humanoid") if tRoot and hum and hum.Health > 0 then local dist = (tRoot.Position - root.Position).Magnitude if dist < minDist then minDist = dist closest = tRoot end end end end return closest end function trySwing() pcall(function() local char = LP.Character if not char then return end local currentTool = char:FindFirstChildOfClass("Tool") if currentTool and not isBatTool(currentTool) then return end local bat = findBat() if bat then if bat.Parent ~= char then local hum = char:FindFirstChildOfClass("Humanoid") if hum then pcall(function() hum:EquipTool(bat) end) end end pcall(function() bat:Activate() end) end end) end function stopAimbotAdapt() if _aimbotConn then pcall(function() _aimbotConn:Disconnect() end) _aimbotConn = nil end local char = LP.Character local root = char and char:FindFirstChild("HumanoidRootPart") local hum = char and char:FindFirstChildOfClass("Humanoid") if hum then hum.AutoRotate = (_prevAutoRotate == nil) and true or _prevAutoRotate hum.PlatformStand = false pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end) end if root then root.AssemblyLinearVelocity = Vector3.new(0, -0.1, 0) root.AssemblyAngularVelocity = Vector3.zero end _prevAutoRotate = nil lastMoveDir = Vector3.zero _unsuppressBodyLock(true) end function startAimbotAdapt() if _aimbotConn then return end _suppressBodyLock() local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") if hum0 then if _prevAutoRotate == nil then _prevAutoRotate = hum0.AutoRotate end hum0.AutoRotate = false end _aimbotConn = RunService.RenderStepped:Connect(function() if not autoBatEnabled then return end local char = LP.Character if not char then return end local root = char:FindFirstChild("HumanoidRootPart") local hum = char:FindFirstChildOfClass("Humanoid") if not root or not hum then return end if not char:FindFirstChildOfClass("Tool") then local bat = findBat() if bat then pcall(function() hum:EquipTool(bat) end) end end local target = getClosestTarget() if not target then return end local targetVel = target.AssemblyLinearVelocity local myPos = root.Position local targetPos = target.Position local predictPos = targetPos + targetVel * 0.14 predictPos = predictPos + target.CFrame.LookVector * 0.3 local direction = predictPos - myPos local flatDir = Vector3.new(direction.X, 0, direction.Z) if flatDir.Magnitude > 0 then flatDir = flatDir.Unit else flatDir = Vector3.new(0,0,0) end local desiredHeight = targetPos.Y + 3.7 local yVel = (desiredHeight - myPos.Y) * 19.5 + targetVel.Y * 0.8 if hum.FloorMaterial ~= Enum.Material.Air then yVel = math.max(yVel, 13) end yVel = math.clamp(yVel, -70, 110) local desiredVel = Vector3.new(flatDir.X * BAT_AIMBOT_SPEED, yVel, flatDir.Z * BAT_AIMBOT_SPEED) root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desiredVel, 0.8) local speed3 = targetVel.Magnitude local predictTime = math.clamp(speed3 / 150, 0.05, 0.2) local predictedPos = targetPos + targetVel * predictTime local toPredict = predictedPos - myPos if toPredict.Magnitude > 0.1 then local goalCF = CFrame.lookAt(myPos, predictedPos) local diffCF = root.CFrame:Inverse() * goalCF local rx, ry, rz = diffCF:ToEulerAnglesXYZ() rx = math.clamp(rx, -2.5, 2.5) ry = math.clamp(ry, -2.5, 2.5) rz = math.clamp(rz, -2.5, 2.5) root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(rx * 42, ry * 42, rz * 42)) end local distToTarget = (root.Position - target.Position).Magnitude if distToTarget <= 8 then trySwing() end end) end function disableAutoBat() autoBatEnabled = false if autoBatSetVisual then autoBatSetVisual(false) end if mobSetAutoBat then mobSetAutoBat(false) end stopAimbotAdapt() end function enableAutoBat() if autoLeftEnabled then autoLeftEnabled = false if autoLeftSetVisual then autoLeftSetVisual(false) end stopAutoLeft() end if autoRightEnabled then autoRightEnabled = false if autoRightSetVisual then autoRightSetVisual(false) end stopAutoRight() end if tpLockEnabled then toggleAntiDesyncAimbot() end if autoBatV2Enabled then disableBatV2() end autoBatEnabled = true if autoBatSetVisual then autoBatSetVisual(true) end if mobSetAutoBat then mobSetAutoBat(true) end startAimbotAdapt() end local function findAnyToolV2() local c = LP.Character if c then for _, v in ipairs(c:GetChildren()) do if v:IsA("Tool") then return v end end end local bp = LP:FindFirstChildOfClass("Backpack") if bp then for _, v in ipairs(bp:GetChildren()) do if v:IsA("Tool") then return v end end end return nil end local function getClosestPlayerV2() local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if not hrp then return nil, math.huge end local closest, bestDist = nil, math.huge for _, p in ipairs(Players:GetPlayers()) do if p ~= LP and p.Character then local tr = p.Character:FindFirstChild("HumanoidRootPart") local ph = p.Character:FindFirstChildOfClass("Humanoid") if tr and ph and ph.Health > 0 then local d = (hrp.Position - tr.Position).Magnitude if d < bestDist then bestDist = d; closest = p end end end end return closest, bestDist end local function tryHitBatV2() if autoBatV2HitCooldown or not autoBatV2SwingEnabled then return end autoBatV2HitCooldown = true local char = LP.Character if char then local hum = char:FindFirstChildOfClass("Humanoid") local tool = findAnyToolV2() if tool then if tool.Parent ~= char and hum then pcall(function() hum:EquipTool(tool) end) end local remote = tool:FindFirstChildOfClass("RemoteEvent") if remote then pcall(function() remote:FireServer() end) else pcall(function() tool:Activate() end) end end end task.delay(AUTO_BAT_V2_SWING_CD, function() autoBatV2HitCooldown = false end) end local function startBatV2Aimbot() if _batV2Conn then return end _batV2Conn = RunService.Heartbeat:Connect(function() if not autoBatV2Enabled then return end local char = LP.Character if not char then return end local root = char:FindFirstChild("HumanoidRootPart") local hum = char:FindFirstChildOfClass("Humanoid") if not root or not hum then return end local target, dist = getClosestPlayerV2() if target and target.Character then local targetRoot = target.Character:FindFirstChild("HumanoidRootPart") if targetRoot then local targetVel = targetRoot.AssemblyLinearVelocity or targetRoot.Velocity local moveDir = targetVel.Magnitude > 0.1 and targetVel.Unit or targetRoot.CFrame.LookVector local offset = moveDir * AUTO_BAT_V2_DIST + Vector3.new(0, AUTO_BAT_V2_HEIGHT + AUTO_BAT_V2_V_OFF, 0) local desiredPos = targetRoot.Position + offset local toTarget = desiredPos - root.Position if toTarget.Magnitude > 0.5 then local moveVec = toTarget.Unit * AUTO_BAT_V2_SPEED root.AssemblyLinearVelocity = Vector3.new(moveVec.X, moveVec.Y, moveVec.Z) else root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * 0.95 if root.AssemblyLinearVelocity.Magnitude < 1 then root.AssemblyLinearVelocity = Vector3.zero end end local distToTarget = (root.Position - targetRoot.Position).Magnitude if distToTarget <= AUTO_BAT_V2_HIT_DIST then tryHitBatV2() end end else root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * 0.9 if root.AssemblyLinearVelocity.Magnitude < 1 then root.AssemblyLinearVelocity = Vector3.zero end end end) end local function stopBatV2Aimbot() if _batV2Conn then _batV2Conn:Disconnect() _batV2Conn = nil end local c = LP.Character local root = c and c:FindFirstChild("HumanoidRootPart") if root then root.AssemblyLinearVelocity = Vector3.zero end autoBatV2HitCooldown = false end function enableBatV2() if autoBatV2Enabled then return end if autoBatEnabled then disableAutoBat() end if tpLockEnabled then toggleAntiDesyncAimbot() end if autoLeftEnabled then autoLeftEnabled = false stopAutoLeft() if autoLeftSetVisual then autoLeftSetVisual(false) end if mobSetAutoLeft then mobSetAutoLeft(false) end end if autoRightEnabled then autoRightEnabled = false stopAutoRight() if autoRightSetVisual then autoRightSetVisual(false) end if mobSetAutoRight then mobSetAutoRight(false) end end autoBatV2Enabled = true startBatV2Aimbot() if autoBatV2SetVisual then autoBatV2SetVisual(true) end if batV2FloatingButton then local btnFrame = batV2FloatingButton:FindFirstChild("Frame") if btnFrame then btnFrame.BackgroundColor3 = Color3.fromRGB(0,0,0) local st = btnFrame:FindFirstChild("AstaActiveStroke") if st then st.Enabled = true end local label = btnFrame:FindFirstChild("TextLabel") if label then label.TextColor3 = Color3.fromRGB(0, 255, 120) end end end end function disableBatV2() if not autoBatV2Enabled then return end autoBatV2Enabled = false stopBatV2Aimbot() if autoBatV2SetVisual then autoBatV2SetVisual(false) end if batV2FloatingButton then local btnFrame = batV2FloatingButton:FindFirstChild("Frame") if btnFrame then btnFrame.BackgroundColor3 = Color3.fromRGB(0,0,0) local label = btnFrame:FindFirstChild("TextLabel") if label then label.TextColor3 = Color3.fromRGB(255,255,255) end end end end function toggleBatV2() if autoBatV2Enabled then disableBatV2() else enableBatV2() end end 
DESYNC_RATIO = 0.85
DESYNC_MAX_DIST = 22
tpLockEnabled = false
_aimbotTargetPlr = nil
_G.AceAntiDesyncAimbotOn = _G.AceAntiDesyncAimbotOn or false
_G.AceAntiDesyncSetVisual = function(v)
    tpLockEnabled = v == true
    if tpLockSetVisual then pcall(tpLockSetVisual, v == true) end
end
_G.AceAntiDesync = _G.AceAntiDesync or {
    conn = nil,
    hittingCooldown = false,
    h = nil,
    hrp = nil
}

local ASTA_TP_BAT_NAMES = {
    "Bat","Slap","Iron Slap","Gold Slap","Diamond Slap",
    "Emerald Slap","Ruby Slap","Dark Matter Slap","Flame Slap",
    "Nuclear Slap","Galaxy Slap","Glitched Slap"
}

function _G.AceAntiDesyncGetBat()
    local char = LP.Character
    if not char then return nil end

    for _, name in ipairs(ASTA_TP_BAT_NAMES) do
        local tool = char:FindFirstChild(name)
        if tool and tool:IsA("Tool") then
            return tool
        end
    end

    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp then
        for _, name in ipairs(ASTA_TP_BAT_NAMES) do
            local tool = bp:FindFirstChild(name)
            if tool and tool:IsA("Tool") then
                tool.Parent = char
                return tool
            end
        end
    end

    return nil
end

function _G.AceAntiDesyncTrySwing()
    if _G.AceAntiDesync.hittingCooldown then return end

    -- so bate quando realmente esta perto do alvo (evita swing no ar de longe)
    local hrp = _G.AceAntiDesync.hrp
    local target = _G.AceAntiDesyncTarget
    if not hrp or not target or not target.Character then return end
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    local hitDist = (_G.AceAntiDesyncSettings and _G.AceAntiDesyncSettings.HIT_DIST) or 6
    if (targetRoot.Position - hrp.Position).Magnitude > hitDist then return end

    _G.AceAntiDesync.hittingCooldown = true

    pcall(function()
        local bat = _G.AceAntiDesyncGetBat()
        if not bat then return end

        bat:Activate()
        local ev = bat:FindFirstChildWhichIsA("RemoteEvent")
        if ev then ev:FireServer() end
    end)

    task.delay(0.08, function()
        if _G.AceAntiDesync then
            _G.AceAntiDesync.hittingCooldown = false
        end
    end)
end

function _G.AceAntiDesyncGetClosestPlayer()
    local hrp = _G.AceAntiDesync and _G.AceAntiDesync.hrp
    if not hrp then return nil end

    local closest, bestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    closest = player
                end
            end
        end
    end

    return closest, bestDist
end

function _G.AceAntiDesyncSetupChar(char)
    task.wait(0.2)
    if not _G.AceAntiDesync then return end
    _G.AceAntiDesync.h = char and char:FindFirstChildOfClass("Humanoid") or nil
    _G.AceAntiDesync.hrp = char and char:FindFirstChild("HumanoidRootPart") or nil

    if _G.AceAntiDesyncAimbotOn and not _G.AceAntiDesync.conn then
        _G.AceStartAntiDesyncAimbot()
    end
end

LP.CharacterAdded:Connect(function(char)
    pcall(function() _G.AceAntiDesyncSetupChar(char) end)
end)

if LP.Character then
    task.spawn(function()
        pcall(function() _G.AceAntiDesyncSetupChar(LP.Character) end)
    end)
end

_G.AceAntiDesyncSettings = _G.AceAntiDesyncSettings or {
    HEIGHT = 0.35,
    BACK = 0.0,
    PREDICT = 0.09,
    PREDICT_FAR = 0.18,
    FACE = true,
    FREEZE = true,
    STEP = 7,
    HIT_DIST = 6,
    SAFE_Y = true,
}

function _G.AceAntiDesyncStickStep()
    if not _G.AceAntiDesyncAimbotOn then return end

    local char = LP.Character
    if not char then return end
    local hrp = _G.AceAntiDesync.hrp
    local hum = _G.AceAntiDesync.h
    if not hrp or hrp.Parent ~= char then hrp = char:FindFirstChild("HumanoidRootPart"); _G.AceAntiDesync.hrp = hrp end
    if not hum or hum.Parent ~= char then hum = char:FindFirstChildOfClass("Humanoid"); _G.AceAntiDesync.h = hum end
    if not hrp or not hum or hum.Health <= 0 then return end

    local target = _G.AceAntiDesyncTarget
    if not target or not target.Parent or not target.Character then return end
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    local S = _G.AceAntiDesyncSettings
    local myPos = hrp.Position
    local dist = (targetRoot.Position - myPos).Magnitude

    -- previsao maior quando longe (compensa ping + movimento do alvo)
    local vel = targetRoot.AssemblyLinearVelocity or Vector3.zero
    local predict = (dist > 25) and (S.PREDICT_FAR or 0.18) or (S.PREDICT or 0.09)
    local predicted = targetRoot.Position + Vector3.new(vel.X, 0, vel.Z) * predict
    local goal = predicted + Vector3.new(0, S.HEIGHT or 0, 0)

    -- seguranca anti-reset: nunca teleportar para baixo do kill-height do mapa
    if S.SAFE_Y ~= false then
        local minY = workspace.FallenPartsDestroyHeight + 6
        if goal.Y < minY then goal = Vector3.new(goal.X, math.max(targetRoot.Position.Y + (S.HEIGHT or 0), minY), goal.Z) end
    end

    -- aproximacao em passos: evita lagback/reset do servidor em TP longo
    local toGoal = goal - myPos
    local step = S.STEP or 7
    if dist > step then
        goal = myPos + toGoal.Unit * step
    end

    local cf
    if S.FACE then
        local look = targetRoot.Position - goal
        look = Vector3.new(look.X, 0, look.Z)
        if look.Magnitude < 0.05 then
            local _, yaw = targetRoot.CFrame:ToEulerAnglesYXZ()
            cf = CFrame.new(goal) * CFrame.Angles(0, yaw, 0)
        else
            cf = CFrame.lookAt(goal, goal + look.Unit)
        end
    else
        cf = CFrame.new(goal)
    end

    hrp.CFrame = cf
    if S.FREEZE then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    hum.AutoRotate = false
end

function _G.AceStartAntiDesyncAimbot()
    if _G.AceSafeModeTryStart and not _G.AceSafeModeTryStart() then
        return false
    end

    _G.AceAntiDesyncCleanupConns()

    _G.AceAntiDesyncAimbotOn = true

    local char = LP.Character
    if char then
        _G.AceAntiDesync.h = char:FindFirstChildOfClass("Humanoid")
        _G.AceAntiDesync.hrp = char:FindFirstChild("HumanoidRootPart")
        _G.AceAntiDesync.prevAutoRotate = _G.AceAntiDesync.h and _G.AceAntiDesync.h.AutoRotate
    end

    pcall(function()
        if setsimulationradius then setsimulationradius(math.huge) end
        if sethiddenproperty then sethiddenproperty(LP, "SimulationRadius", math.huge) end
    end)

    -- target picking + ownership + swing (Heartbeat)
    _G.AceAntiDesync.conn = RunService.Heartbeat:Connect(function()
        if not _G.AceAntiDesyncAimbotOn then return end

        local currentChar = LP.Character
        if not currentChar then return end
        if not _G.AceAntiDesync.h or _G.AceAntiDesync.h.Parent ~= currentChar then
            _G.AceAntiDesync.h = currentChar:FindFirstChildOfClass("Humanoid")
        end
        if not _G.AceAntiDesync.hrp or _G.AceAntiDesync.hrp.Parent ~= currentChar then
            _G.AceAntiDesync.hrp = currentChar:FindFirstChild("HumanoidRootPart")
        end
        if not _G.AceAntiDesync.h or not _G.AceAntiDesync.hrp then return end

        local target = _G.AceAntiDesyncGetClosestPlayer()
        _G.AceAntiDesyncTarget = target
        _aimbotTargetPlr = target
        _G.AceCurrentAimbotTarget = target
        _G.AceAntiDesyncBatTarget = target

        if not target or not target.Character then return end
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end

        if sethiddenproperty then
            pcall(sethiddenproperty, _G.AceAntiDesync.hrp, "PhysicsRepRootPart", targetRoot)
        end

        _G.AceAntiDesyncStickStep()

        local cam = workspace.CurrentCamera
        if cam then
            cam.CFrame = CFrame.new(cam.CFrame.Position, targetRoot.Position)
        end

        _G.AceAntiDesyncTrySwing()
    end)

    -- glue before physics and before render for 100% stick
    _G.AceAntiDesync.stepConn = RunService.Stepped:Connect(function()
        _G.AceAntiDesyncStickStep()
    end)
    _G.AceAntiDesync.renderConn = RunService.RenderStepped:Connect(function()
        _G.AceAntiDesyncStickStep()
    end)

    if _G.AceAntiDesyncSetVisual then
        _G.AceAntiDesyncSetVisual(true)
    end

    return true
end

function _G.AceAntiDesyncCleanupConns()
    local S = _G.AceAntiDesync
    if not S then return end
    for _, key in ipairs({"conn","stepConn","renderConn"}) do
        if S[key] then
            pcall(function() S[key]:Disconnect() end)
            S[key] = nil
        end
    end
end

function _G.AceStopAntiDesyncAimbot()
    _G.AceAntiDesyncAimbotOn = false

    if _G.AceAntiDesyncCleanupConns then _G.AceAntiDesyncCleanupConns() end

    if _G.AceAntiDesync then
        _G.AceAntiDesync.hittingCooldown = false
        local hum = _G.AceAntiDesync.h
        if hum then hum.AutoRotate = (_G.AceAntiDesync.prevAutoRotate == nil) and true or _G.AceAntiDesync.prevAutoRotate end
        _G.AceAntiDesync.prevAutoRotate = nil
    end
    _G.AceAntiDesyncTarget = nil

    _G.AceAntiDesyncBatTarget = nil
    if _G.AceCurrentAimbotTarget == _aimbotTargetPlr then
        _G.AceCurrentAimbotTarget = nil
    end
    _aimbotTargetPlr = nil

    if _G.AceAntiDesyncSetVisual then
        _G.AceAntiDesyncSetVisual(false)
    end
end

function _G.AceToggleAntiDesyncAimbot()
    if _G.AceAntiDesyncAimbotOn then
        _G.AceStopAntiDesyncAimbot()
    else
        _G.AceStartAntiDesyncAimbot()
    end
end

function startAntiDesyncAimbot()
    local ok = _G.AceStartAntiDesyncAimbot()
    tpLockEnabled = _G.AceAntiDesyncAimbotOn == true
    return ok
end

function stopAntiDesyncAimbot()
    _G.AceStopAntiDesyncAimbot()
    tpLockEnabled = false
end

function toggleAntiDesyncAimbot()
    if _G.AceAntiDesyncAimbotOn then stopAntiDesyncAimbot() else startAntiDesyncAimbot() end
    return _G.AceAntiDesyncAimbotOn
end

toggleTPLock = toggleAntiDesyncAimbot
startTPLock = startAntiDesyncAimbot
stopTPLock = stopAntiDesyncAimbot
_G.AceAntiDesyncStart = startAntiDesyncAimbot
_G.AceAntiDesyncStop = stopAntiDesyncAimbot
_G.AceAntiDesyncToggle = toggleAntiDesyncAimbot


-- ===== Sistema de Climas (AdaptX) =====
skyTheme = skyTheme or "Off"
skyValueLabel = nil
SKY_PRESETS_LIST = {"Off","Night","Aurora","Sunset","Galaxy","Cyber","Sakura","Pink Night","Blood Moon","Emerald Dawn","Volcanic","Arctic","Midnight Ocean","Vaporwave","Toxic","Solar Eclipse","Hellscape","Heaven","Storm","Sunrise","Deep Space","Lavender Dream","Inferno","Mint Sky"}
SKY_PRESETS = {
    ["Off"]={kind="off"},
    ["Night"]={clock=22,brightness=2,ambient={110,100,130},outAmb={120,110,140},sky={stars=4000,moon=18,sun=0,moonTex=true},atm={dens=0.45,color={120,60,180},decay={60,20,100},glare=0.5,haze=1.2}},
    ["Aurora"]={clock=14,brightness=3,ambient={150,120,150},outAmb={160,130,150},atm={dens=0.55,color={255,80,200},decay={255,20,150},glare=2.5,haze=3},clouds={cover=0.7,dens=0.7,color={255,240,250}}},
    ["Sunset"]={clock=17.2,brightness=2.5,ambient={170,120,100},outAmb={180,130,110},sky={stars=0,sun=25,moon=0},atm={dens=0.5,color={255,130,60},decay={255,80,30},glare=2,haze=2.5},clouds={cover=0.55,dens=0.55,color={255,200,140}}},
    ["Galaxy"]={clock=0,brightness=1.5,ambient={70,60,100},outAmb={80,70,110},sky={stars=10000,moon=30,sun=0},atm={dens=0.15,color={40,20,80},decay={20,10,50},glare=0.3,haze=0.5}},
    ["Cyber"]={clock=21,brightness=2.2,ambient={90,130,170},outAmb={100,140,180},sky={stars=2000,moon=12},atm={dens=0.4,color={0,200,255},decay={150,0,255},glare=2,haze=2},clouds={cover=0.4,dens=0.6,color={100,200,255}}},
    ["Sakura"]={clock=11,brightness=3.5,ambient={170,150,160},outAmb={180,160,170},sky={sun=8},atm={dens=0.3,color={255,200,220},decay={255,170,200},glare=1,haze=1.5},clouds={cover=0.6,dens=0.4,color={255,250,252}}},
    ["Pink Night"]={clock=23,brightness=2.2,ambient={120,60,110},outAmb={140,70,120},sky={stars=5000,moon=22,sun=0,moonTex=true},atm={dens=0.5,color={255,80,180},decay={140,30,100},glare=0.7,haze=1.4},clouds={cover=0.3,dens=0.5,color={180,90,150}}},
    ["Blood Moon"]={clock=22.5,brightness=1.6,ambient={130,40,40},outAmb={150,50,50},sky={stars=1500,moon=28,sun=0,moonTex=true},atm={dens=0.6,color={220,30,30},decay={120,10,10},glare=1.4,haze=2},clouds={cover=0.5,dens=0.7,color={120,30,30}}},
    ["Emerald Dawn"]={clock=6.5,brightness=2.8,ambient={130,170,140},outAmb={140,180,150},sky={sun=18,moon=0,stars=0},atm={dens=0.4,color={80,200,140},decay={40,150,90},glare=1.8,haze=2.2},clouds={cover=0.5,dens=0.5,color={200,255,220}}},
    ["Volcanic"]={clock=19,brightness=2,ambient={180,80,40},outAmb={200,90,50},sky={stars=200,sun=12,moon=0},atm={dens=0.75,color={255,60,0},decay={180,20,0},glare=3,haze=3.5},clouds={cover=0.8,dens=0.9,color={120,40,20}}},
    ["Arctic"]={clock=9,brightness=3.2,ambient={200,220,235},outAmb={210,230,245},sky={sun=10,stars=0,moon=0},atm={dens=0.3,color={180,220,255},decay={140,200,240},glare=1.5,haze=1.8},clouds={cover=0.7,dens=0.6,color={250,253,255}}},
    ["Midnight Ocean"]={clock=1.5,brightness=1.7,ambient={60,90,130},outAmb={70,100,140},sky={stars=6000,moon=24,sun=0,moonTex=true},atm={dens=0.5,color={20,60,140},decay={10,30,90},glare=0.6,haze=1.5}},
    ["Vaporwave"]={clock=19.5,brightness=2.4,ambient={180,120,200},outAmb={190,130,210},sky={stars=1000,moon=14},atm={dens=0.45,color={255,100,220},decay={120,60,255},glare=2.2,haze=2.4},clouds={cover=0.55,dens=0.55,color={200,150,255}}},
    ["Toxic"]={clock=13,brightness=2.5,ambient={140,180,80},outAmb={150,190,90},atm={dens=0.55,color={100,220,40},decay={60,150,20},glare=1.8,haze=2.6},clouds={cover=0.65,dens=0.7,color={180,255,120}}},
    ["Solar Eclipse"]={clock=12,brightness=0.9,ambient={50,40,60},outAmb={60,50,70},sky={stars=3500,sun=22,moon=0},atm={dens=0.5,color={255,140,40},decay={30,20,40},glare=2.8,haze=1.8}},
    ["Hellscape"]={clock=18,brightness=1.8,ambient={200,60,30},outAmb={220,70,40},sky={stars=100,sun=30,moon=0},atm={dens=0.85,color={255,30,0},decay={120,0,0},glare=3.5,haze=4},clouds={cover=0.95,dens=0.95,color={80,20,10}}},
    ["Heaven"]={clock=12,brightness=4,ambient={240,235,210},outAmb={250,245,220},sky={sun=16,moon=0,stars=0},atm={dens=0.25,color={255,250,220},decay={255,240,200},glare=3,haze=1.5},clouds={cover=0.85,dens=0.5,color={255,255,255}}},
    ["Storm"]={clock=15,brightness=1.4,ambient={90,90,110},outAmb={100,100,120},sky={stars=0,sun=6,moon=0},atm={dens=0.65,color={80,90,120},decay={40,50,80},glare=0.5,haze=3},clouds={cover=0.95,dens=0.95,color={60,65,80}}},
    ["Sunrise"]={clock=6.2,brightness=2.8,ambient={220,180,130},outAmb={230,190,140},sky={sun=22,stars=0,moon=0},atm={dens=0.45,color={255,180,100},decay={255,140,80},glare=2.4,haze=2.2},clouds={cover=0.4,dens=0.4,color={255,220,180}}},
    ["Deep Space"]={clock=0,brightness=1,ambient={30,25,50},outAmb={40,35,60},sky={stars=15000,moon=0,sun=0},atm={dens=0.08,color={15,5,40},decay={5,0,20},glare=0.2,haze=0.3}},
    ["Lavender Dream"]={clock=18.5,brightness=2.6,ambient={180,160,220},outAmb={190,170,230},sky={stars=800,moon=16,sun=0},atm={dens=0.4,color={200,160,255},decay={160,120,220},glare=1.4,haze=1.8},clouds={cover=0.55,dens=0.5,color={220,200,255}}},
    ["Inferno"]={clock=17.5,brightness=2.2,ambient={220,100,40},outAmb={235,110,50},sky={sun=26,moon=0,stars=0},atm={dens=0.6,color={255,90,20},decay={200,40,0},glare=3,haze=3.2},clouds={cover=0.7,dens=0.7,color={200,80,40}}},
    ["Mint Sky"]={clock=10,brightness=3.2,ambient={180,230,210},outAmb={190,240,220},sky={sun=10},atm={dens=0.32,color={150,255,210},decay={100,220,180},glare=1.6,haze=1.6},clouds={cover=0.55,dens=0.45,color={240,255,250}}},
}


local function _vC3(t)
    return Color3.fromRGB(t[1], t[2], t[3])
end

function _v4mpClearSky()
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:GetAttribute("_AdaptDuelsSky") then
            pcall(function() child:Destroy() end)
        end
    end

    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        for _, child in ipairs(terrain:GetChildren()) do
            if child:GetAttribute("_AdaptDuelsSky") then
                pcall(function() child:Destroy() end)
            end
        end
    end
end

function applyCustomSky(mode)
    _v4mpClearSky()

    local preset = SKY_PRESETS[mode]
    if not preset or preset.kind == "off" then
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(127,127,127)
        Lighting.Ambient = Color3.fromRGB(127,127,127)
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true
        skyTheme = "Off"
        return
    end

    Lighting.FogStart = 0
    Lighting.FogEnd = 100000
    Lighting.FogColor = Color3.fromRGB(200,200,200)
    Lighting.ColorShift_Top = Color3.fromRGB(0,0,0)
    Lighting.ColorShift_Bottom = Color3.fromRGB(0,0,0)
    Lighting.GlobalShadows = true

    Lighting.ClockTime = preset.clock or 14
    Lighting.Brightness = preset.brightness or 2

    if preset.outAmb then
        Lighting.OutdoorAmbient = _vC3(preset.outAmb)
    end

    if preset.ambient then
        Lighting.Ambient = _vC3(preset.ambient)
    end

    if preset.sky then
        local skyInst = Instance.new("Sky")
        skyInst:SetAttribute("_AdaptDuelsSky", true)

        if preset.sky.stars then skyInst.StarCount = preset.sky.stars end
        if preset.sky.moon then skyInst.MoonAngularSize = preset.sky.moon end
        if preset.sky.sun then skyInst.SunAngularSize = preset.sky.sun end
        if preset.sky.moonTex then skyInst.MoonTextureId = "rbxasset://sky/moon.jpg" end

        skyInst.Parent = Lighting
    end

    if preset.atm then
        local atm = Instance.new("Atmosphere")
        atm:SetAttribute("_AdaptDuelsSky", true)
        atm.Density = preset.atm.dens or 0.3
        atm.Color = _vC3(preset.atm.color)
        atm.Decay = _vC3(preset.atm.decay)
        atm.Glare = preset.atm.glare or 1
        atm.Haze = preset.atm.haze or 1
        atm.Parent = Lighting
    end

    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if preset.clouds and terrain then
        local clouds = Instance.new("Clouds")
        clouds:SetAttribute("_AdaptDuelsSky", true)
        clouds.Cover = preset.clouds.cover or 0.5
        clouds.Density = preset.clouds.dens or 0.5
        clouds.Color = _vC3(preset.clouds.color)
        clouds.Parent = terrain
    end

    skyTheme = mode
end

function findBat() local char = LP.Character if not char then return nil end for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do local t = char:FindFirstChild(name) if t and t:IsA("Tool") then return t end end local bp = LP:FindFirstChildOfClass("Backpack") if bp then for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do local t = bp:FindFirstChild(name) if t and t:IsA("Tool") then local hum = char:FindFirstChildOfClass("Humanoid") if hum then pcall(function() hum:EquipTool(t) end) end return t end end end for _, ch in ipairs(char:GetChildren()) do if ch:IsA("Tool") and (ch.Name:lower():find("bat") or ch.Name:lower():find("slap")) then return ch end end return nil end function isBatTool(tool) if not tool then return false end for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do if tool.Name == name then return true end end return tool.Name:lower():find("bat") or tool.Name:lower():find("slap") end function findBatForCounter() local char = LP.Character if not char then return nil end local backpack = LP:FindFirstChildOfClass("Backpack") for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do local tool = char:FindFirstChild(name) or (backpack and backpack:FindFirstChild(name)) if tool then return tool end end for _, child in ipairs(char:GetChildren()) do if child:IsA("Tool") and (child.Name:lower():find("bat") or child.Name:lower():find("slap")) then return child end end if backpack then for _, child in ipairs(backpack:GetChildren()) do if child:IsA("Tool") and (child.Name:lower():find("bat") or child.Name:lower():find("slap")) then return child end end end return nil end function swingBatForCounter(bat, character) local humanoid = character:FindFirstChildOfClass("Humanoid") if bat.Parent ~= character and humanoid then pcall(function() humanoid:EquipTool(bat) end) task.wait(0.05) end local remote = bat:FindFirstChildOfClass("RemoteEvent") or bat:FindFirstChildOfClass("RemoteFunction") if remote and remote:IsA("RemoteEvent") then pcall(function() remote:FireServer() end) task.wait(0.1) pcall(function() remote:FireServer() end) else pcall(function() bat:Activate() end) task.wait(0.1) pcall(function() bat:Activate() end) end end function stopBatCounter() if Conns.batCounter then Conns.batCounter:Disconnect() Conns.batCounter = nil end batCounterDebounce = false end function startBatCounter() if Conns.batCounter then return end Conns.batCounter = RunService.Heartbeat:Connect(function() if not batCounterEnabled then return end if batCounterDebounce then return end local character = LP.Character if not character then return end local humanoid = character:FindFirstChildOfClass("Humanoid") if not humanoid then return end local state = humanoid:GetState() if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then batCounterDebounce = true _suppressBodyLock() task.spawn(function() task.wait(0.15) local bat = findBatForCounter() if bat then swingBatForCounter(bat, character) end task.wait(0.3) batCounterDebounce = false _unsuppressBodyLock(true) end) end end) end function findMedusa() local c = LP.Character if not c then return nil end for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") then local n = t.Name:lower() if n:find("medusa") or n:find("head") or n:find("stone") then return t end end end local bp = LP:FindFirstChild("Backpack") if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then local n = t.Name:lower() if n:find("medusa") or n:find("head") or n:find("stone") then return t end end end end return nil end function useMedusaCounter() if medusaDebounce then return end if tick() - medusaLastUsed < MEDUSA_COOLDOWN then return end local c = LP.Character if not c then return end medusaDebounce = true local med = findMedusa() if not med then medusaDebounce = false; return end if med.Parent ~= c then local hum2 = c:FindFirstChildOfClass("Humanoid") if hum2 then hum2:EquipTool(med) end end pcall(function() med:Activate() end) medusaLastUsed = tick() medusaDebounce = false end function onAnchorChanged(part) return part:GetPropertyChangedSignal("Anchored"):Connect(function() if medusaCounterEnabled and part.Anchored and part.Transparency == 1 then useMedusaCounter() end end) end function setupMedusa(char) for _, c in pairs(Conns.anchor) do pcall(function() c:Disconnect() end) end Conns.anchor = {} if not char or not medusaCounterEnabled then return end for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then table.insert(Conns.anchor, onAnchorChanged(part)) end end table.insert(Conns.anchor, char.DescendantAdded:Connect(function(part) if part:IsA("BasePart") then table.insert(Conns.anchor, onAnchorChanged(part)) end end)) end function stopMedusaCounter() for _, c in pairs(Conns.anchor) do pcall(function() c:Disconnect() end) end Conns.anchor = {} end function onMedusaResetAnchorChanged(part) return part:GetPropertyChangedSignal("Anchored"):Connect(function() if medusaAutoResetEnabled and part.Anchored and part.Transparency == 1 then instaReset() end end) end function setupMedusaAutoReset(char) for _, c in pairs(medusaResetConns) do pcall(function() c:Disconnect() end) end medusaResetConns = {} if not char or not medusaAutoResetEnabled then return end for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then table.insert(medusaResetConns, onMedusaResetAnchorChanged(part)) end end table.insert(medusaResetConns, char.DescendantAdded:Connect(function(part) if part:IsA("BasePart") then table.insert(medusaResetConns, onMedusaResetAnchorChanged(part)) end end)) end function stopMedusaAutoReset() for _, c in pairs(medusaResetConns) do pcall(function() c:Disconnect() end) end medusaResetConns = {} end function setMedusaCounterState(state) medusaCounterEnabled = state if state then if medusaAutoResetEnabled then medusaAutoResetEnabled = false if setMedusaAutoResetVisual then setMedusaAutoResetVisual(false) end stopMedusaAutoReset() end if LP.Character then setupMedusa(LP.Character) else stopMedusaCounter() end else stopMedusaCounter() end if setMedusaVisual then setMedusaVisual(state) end end function setMedusaAutoResetState(state) medusaAutoResetEnabled = state if state then if medusaCounterEnabled then medusaCounterEnabled = false if setMedusaVisual then setMedusaVisual(false) end stopMedusaCounter() end if LP.Character then setupMedusaAutoReset(LP.Character) else stopMedusaAutoReset() end else stopMedusaAutoReset() end if setMedusaAutoResetVisual then setMedusaAutoResetVisual(state) end end local DROP_ASCEND_DURATION = 0.15 local DROP_ASCEND_SPEED = 310 local _dropConn = nil pcall(function() if _dropRespawnConn then _dropRespawnConn:Disconnect() end _dropRespawnConn = LP.CharacterAdded:Connect(function() task.wait(0.15) if dropActive then pcall(function() stopDropBrainrot() end) end end) end) function stopDropBrainrot() dropActive = false if _dropConn then _dropConn:Disconnect() _dropConn = nil end for _, t in ipairs(dropConnections) do if type(t) == "thread" then pcall(task.cancel, t) elseif type(t) == "RBXScriptConnection" then pcall(t.Disconnect, t) end end dropConnections = {} local c = LP.Character if c then local root = c:FindFirstChild("HumanoidRootPart") if root then root.AssemblyLinearVelocity = Vector3.zero end end if dropBrainrotSetVisual then dropBrainrotSetVisual(false) end if mobSetDropBR then mobSetDropBR(false) end end function runDropBrainrot() if dropActive then if tick() - (_dropStartedAt or 0) > 1.2 then pcall(function() stopDropBrainrot() end) dropActive = false else return end end _dropStartedAt = tick() local char = LP.Character local root = char and char:FindFirstChild("HumanoidRootPart") local hum = char and char:FindFirstChildOfClass("Humanoid") if not root or not hum then return end if dropMode == 1 then local speedH = 0 if root then local vel = root.AssemblyLinearVelocity speedH = Vector3.new(vel.X, 0, vel.Z).Magnitude end local cooldown = (speedH > 5) and 0.35 or 0.12 if tick() - lastDropTime < cooldown then return end lastDropTime = tick() dropActive = true if dropBrainrotSetVisual then dropBrainrotSetVisual(true) end if mobSetDropBR then mobSetDropBR(true) end local wasAutoBat = false if autoBatEnabled then wasAutoBat = true disableAutoBat() if autoBatSetVisual then autoBatSetVisual(false) end if mobSetAutoBat then mobSetAutoBat(false) end end local function finishDrop(threadRef) if threadRef and dropConnections then for i = #dropConnections, 1, -1 do if dropConnections[i] == threadRef then table.remove(dropConnections, i) break end end end dropActive = false local c = LP.Character if c then local r = c:FindFirstChild("HumanoidRootPart") local h = c:FindFirstChildOfClass("Humanoid") if r then r.AssemblyLinearVelocity = Vector3.zero r.AssemblyAngularVelocity = Vector3.zero if r.Position.Y < -100 then r.CFrame = CFrame.new(r.Position.X, 5, r.Position.Z) end local rp = RaycastParams.new() rp.FilterDescendantsInstances = {c} rp.FilterType = Enum.RaycastFilterType.Exclude local rr = workspace:Raycast(r.Position, Vector3.new(0, -2000, 0), rp) if rr then local off = (h and h.HipHeight or 2) + (r.Size.Y / 2) r.CFrame = CFrame.new(r.Position.X, rr.Position.Y + off, r.Position.Z) end for _, pt in ipairs(c:GetDescendants()) do if pt:IsA("BasePart") then pt.AssemblyLinearVelocity = Vector3.zero pt.AssemblyAngularVelocity = Vector3.zero end end local yaw = select(2, r.CFrame:ToEulerAnglesYXZ()) r.CFrame = CFrame.new(r.Position) * CFrame.Angles(0, yaw, 0) if h then h.PlatformStand = false h.AutoRotate = true if h.Health > 0 then h:ChangeState(Enum.HumanoidStateType.GettingUp) end end end end if wasAutoBat then enableAutoBat() if autoBatSetVisual then autoBatSetVisual(true) end if mobSetAutoBat then mobSetAutoBat(true) end end if dropBrainrotSetVisual then dropBrainrotSetVisual(false) end if mobSetDropBR then mobSetDropBR(false) end end local flingThread = nil flingThread = task.spawn(function() local startTime = tick() local c0 = LP.Character local h0 = c0 and c0:FindFirstChildOfClass("Humanoid") local r0 = c0 and c0:FindFirstChild("HumanoidRootPart") local savedYaw = 0 if r0 then savedYaw = select(2, r0.CFrame:ToEulerAnglesYXZ()) end if h0 then pcall(function() h0.PlatformStand = false h0.AutoRotate = false h0:ChangeState(Enum.HumanoidStateType.Freefall) end) end pcall(function() while dropActive and (tick() - startTime) < 0.22 do local c = LP.Character local r = c and c:FindFirstChild("HumanoidRootPart") if not r then break end local vel = r.AssemblyLinearVelocity vel = Vector3.new(0, math.clamp(vel.Y, -50, 50), 0) r.AssemblyLinearVelocity = vel * 15000 + Vector3.new(0, 15000, 0) r.AssemblyAngularVelocity = Vector3.new(0, 10000, 0) RunService.RenderStepped:Wait() if r and r.Parent then r.AssemblyLinearVelocity = vel r.AssemblyAngularVelocity = Vector3.zero end RunService.Heartbeat:Wait() if r and r.Parent then r.AssemblyLinearVelocity = vel r.AssemblyAngularVelocity = Vector3.zero r.CFrame = CFrame.new(r.Position) * CFrame.Angles(0, savedYaw, 0) end end end) pcall(function() local c = LP.Character local r = c and c:FindFirstChild("HumanoidRootPart") local h = c and c:FindFirstChildOfClass("Humanoid") if c then for _, pt in ipairs(c:GetDescendants()) do if pt:IsA("BasePart") then pt.AssemblyLinearVelocity = Vector3.zero pt.AssemblyAngularVelocity = Vector3.zero pt.RotVelocity = Vector3.zero pt.Velocity = Vector3.zero end end end if r then r.CFrame = CFrame.new(r.Position) * CFrame.Angles(0, savedYaw, 0) end if h then h.PlatformStand = false h.AutoRotate = true h:ChangeState(Enum.HumanoidStateType.GettingUp) task.delay(0.1, function() pcall(function() if h.Health > 0 then h:ChangeState(Enum.HumanoidStateType.Running) end end) end) end end) finishDrop(flingThread) end) table.insert(dropConnections, flingThread) task.delay(0.42, function() if dropActive then finishDrop(flingThread) end end) task.delay(1.1, function() if dropActive then pcall(function() stopDropBrainrot() end) dropActive = false end end) return end dropActive = true if dropBrainrotSetVisual then dropBrainrotSetVisual(true) end if mobSetDropBR then mobSetDropBR(true) end local t0 = tick() if _dropConn then _dropConn:Disconnect() end _dropConn = RunService.Heartbeat:Connect(function() local c = LP.Character local r = c and c:FindFirstChild("HumanoidRootPart") if not r then if _dropConn then _dropConn:Disconnect(); _dropConn = nil end dropActive = false if dropBrainrotSetVisual then dropBrainrotSetVisual(false) end if mobSetDropBR then mobSetDropBR(false) end return end if not dropActive then if _dropConn then _dropConn:Disconnect(); _dropConn = nil end if dropBrainrotSetVisual then dropBrainrotSetVisual(false) end if mobSetDropBR then mobSetDropBR(false) end return end if tick() - t0 >= DROP_ASCEND_DURATION then if _dropConn then _dropConn:Disconnect(); _dropConn = nil end pcall(function() local rp = RaycastParams.new() rp.FilterDescendantsInstances = {c} rp.FilterType = Enum.RaycastFilterType.Exclude local rr = workspace:Raycast(r.Position, Vector3.new(0, -3000, 0), rp) local hum2 = c:FindFirstChildOfClass("Humanoid") if rr then local off = ((hum2 and hum2.HipHeight) or 2) + (r.Size.Y / 2) r.CFrame = CFrame.new(r.Position.X, rr.Position.Y + off, r.Position.Z) r.AssemblyLinearVelocity = Vector3.zero r.AssemblyAngularVelocity = Vector3.zero end if hum2 and hum2.Health > 0 then hum2:ChangeState(Enum.HumanoidStateType.Running) end end) dropActive = false if dropBrainrotSetVisual then dropBrainrotSetVisual(false) end if mobSetDropBR then mobSetDropBR(false) end return end local hj = c:FindFirstChildOfClass("Humanoid") if hj then pcall(function() hj.PlatformStand = false hj:ChangeState(Enum.HumanoidStateType.Freefall) end) end r.AssemblyAngularVelocity = Vector3.zero local lv = r.AssemblyLinearVelocity r.AssemblyLinearVelocity = Vector3.new(lv.X * 0.2, DROP_ASCEND_SPEED, lv.Z * 0.2) end) end function executeDropWithToggle(setVisual) if dropActive then return end task.spawn(function() if setVisual then setVisual(true) end runDropBrainrot() while dropActive do task.wait() end task.wait(0.1) if setVisual then setVisual(false) end end) end function applyAntiLagDerender(obj) pcall(function() if obj:IsA("Accessory") or obj:IsA("Hat") then obj:Destroy() elseif obj:IsA("BasePart") then obj.Material = Enum.Material.Plastic obj.Reflectance = 0 obj.CastShadow = false elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 1 elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then obj.Enabled = false elseif obj:IsA("AnimationController") or obj:IsA("Animator") then for _, t in ipairs(obj:GetPlayingAnimationTracks()) do pcall(function() t:Stop(0) end) end end end) end function enableAntiLag() removeAccessoriesEnabled = true antiLagEnabled = true if defLightBrightness == nil then defLightBrightness = Lighting.Brightness defLightClock = Lighting.ClockTime defLightAmbient = Lighting.OutdoorAmbient defGlobalShadows = Lighting.GlobalShadows defFogEnd = Lighting.FogEnd end Lighting.GlobalShadows = false Lighting.FogEnd = 1e10 Lighting.Brightness = 0 for _, e in pairs(Lighting:GetChildren()) do pcall(function() if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled = false end end) end for _, obj in ipairs(workspace:GetDescendants()) do applyAntiLagDerender(obj) end if antiLagDescConn then antiLagDescConn:Disconnect() end antiLagDescConn = workspace.DescendantAdded:Connect(function(obj) if removeAccessoriesEnabled then applyAntiLagDerender(obj) end end) end function disableAntiLag() removeAccessoriesEnabled = false antiLagEnabled = false if antiLagDescConn then antiLagDescConn:Disconnect(); antiLagDescConn = nil end if defLightBrightness ~= nil then Lighting.Brightness = defLightBrightness end if defLightClock ~= nil then Lighting.ClockTime = defLightClock end if defLightAmbient ~= nil then Lighting.OutdoorAmbient = defLightAmbient end if defGlobalShadows ~= nil then Lighting.GlobalShadows = defGlobalShadows end if defFogEnd ~= nil then Lighting.FogEnd = defFogEnd end for _, e in pairs(Lighting:GetChildren()) do pcall(function() if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled = true end end) end end function applyStretchFOV(val) local cam = workspace.CurrentCamera if cam then pcall(function() cam.FieldOfView = val end) end end function enableStretch() if stretchConn then return end stretchEnabled = true local cam = workspace.CurrentCamera if not cam then return end origFOV = cam.FieldOfView or 70 applyStretchFOV(stretchFOV) stretchConn = RunService.RenderStepped:Connect(function() if not stretchEnabled then stretchConn:Disconnect() stretchConn = nil return end local c = workspace.CurrentCamera if c then c.CFrame = c.CFrame * CFrame.new(0,0,0,1,0,0,0,0.7,0,0,0,1) end end) if stretchFovConn then stretchFovConn:Disconnect() end stretchFovConn = RunService.RenderStepped:Connect(function() if stretchEnabled then applyStretchFOV(stretchFOV) else stretchFovConn:Disconnect(); stretchFovConn = nil end end) end function disableStretch() stretchEnabled = false if stretchConn then stretchConn:Disconnect(); stretchConn = nil end if stretchFovConn then stretchFovConn:Disconnect(); stretchFovConn = nil end local cam = workspace.CurrentCamera if cam then pcall(function() cam.FieldOfView = origFOV or 70 end) end end local function saveLightingState() if _originalLighting then return end _originalLighting = { Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, OutdoorAmbient = Lighting.OutdoorAmbient, GlobalShadows = Lighting.GlobalShadows, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, FogColor = Lighting.FogColor, Ambient = Lighting.Ambient, ColorCorrection = nil, Bloom = nil, } for _, e in ipairs(Lighting:GetChildren()) do if e:IsA("ColorCorrectionEffect") then _originalLighting.ColorCorrection = { Enabled = e.Enabled, Brightness = e.Brightness, Contrast = e.Contrast, Saturation = e.Saturation, TintColor = e.TintColor, } elseif e:IsA("BloomEffect") then _originalLighting.Bloom = { Enabled = e.Enabled, Intensity = e.Intensity, Size = e.Size, Threshold = e.Threshold, } end end end local function restoreLightingState() if not _originalLighting then return end local old = _originalLighting Lighting.Brightness = old.Brightness Lighting.ClockTime = old.ClockTime Lighting.OutdoorAmbient = old.OutdoorAmbient Lighting.GlobalShadows = old.GlobalShadows Lighting.FogEnd = old.FogEnd Lighting.FogStart = old.FogStart Lighting.FogColor = old.FogColor Lighting.Ambient = old.Ambient if old.ColorCorrection then local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") if cc then cc.Enabled = old.ColorCorrection.Enabled cc.Brightness = old.ColorCorrection.Brightness cc.Contrast = old.ColorCorrection.Contrast cc.Saturation = old.ColorCorrection.Saturation cc.TintColor = old.ColorCorrection.TintColor end end if old.Bloom then local bloom = Lighting:FindFirstChildOfClass("BloomEffect") if bloom then bloom.Enabled = old.Bloom.Enabled bloom.Intensity = old.Bloom.Intensity bloom.Size = old.Bloom.Size bloom.Threshold = old.Bloom.Threshold end end _originalLighting = nil end local function applyNeonWeather() if not neonWeatherEnabled then restoreLightingState() return end if not _originalLighting then saveLightingState() end Lighting.Brightness = 3.5 Lighting.ClockTime = 20 Lighting.OutdoorAmbient = Color3.fromRGB(20, 40, 80) Lighting.GlobalShadows = false Lighting.FogEnd = 300 Lighting.FogStart = 0 Lighting.FogColor = Color3.fromRGB(0, 80, 200) Lighting.Ambient = Color3.fromRGB(30, 60, 120) local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") if not cc then cc = Instance.new("ColorCorrectionEffect") cc.Parent = Lighting end cc.Enabled = true cc.Brightness = 0.2 cc.Contrast = 0.15 cc.Saturation = 0.15 cc.TintColor = Color3.fromRGB(180, 180, 190) local bloom = Lighting:FindFirstChildOfClass("BloomEffect") if not bloom then bloom = Instance.new("BloomEffect") bloom.Parent = Lighting end bloom.Enabled = true bloom.Intensity = 0.6 bloom.Size = 25 bloom.Threshold = 0.8 end function toggleNeonWeather(state) if state == nil then neonWeatherEnabled = not neonWeatherEnabled else neonWeatherEnabled = state end applyNeonWeather() if setNeonWeatherVisual then setNeonWeatherVisual(neonWeatherEnabled) end end local function drag(f) local dn, ds, sp, di = false f.InputBegan:Connect(function(i) if uiLocked then return end if _isDraggingButton then return end if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dn = true; ds = i.Position; sp = f.Position i.Changed:Connect(function() if i.UserInputState == Enum.InputUserState.End then dn = false end end) end end) f.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di = i end end) UIS.InputChanged:Connect(function(i) if i == di and dn then if uiLocked then dn = false; return end if _isDraggingButton then return end local nX = sp.X.Offset + (i.Position.X - ds.X) local nY = sp.Y.Offset + (i.Position.Y - ds.Y) f.Position = UDim2.new(sp.X.Scale, nX, sp.Y.Scale, nY) end end) end function setupMovementAndIndicators(char) if steppedConn then steppedConn:Disconnect(); steppedConn = nil end if movementLoop then movementLoop:Disconnect(); movementLoop = nil end steppedConn = RunService.Stepped:Connect(function() for _, p in ipairs(Players:GetPlayers()) do if p ~= LP and p.Character then for _, part in ipairs(p.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end end end end) movementLoop = RunService.RenderStepped:Connect(function() local char2 = LP.Character if not char2 then return end local hum = char2:FindFirstChildOfClass("Humanoid") local hrp = char2:FindFirstChild("HumanoidRootPart") if not hum or not hrp then return end if not autoBatEnabled and not tpLockEnabled and not autoLeftEnabled and not autoRightEnabled and not autoBatV2Enabled then local spd if laggerToggled then spd = (laggerLevel == 2) and LAGGER_SPEED_2 or LAGGER_SPEED_1 else spd = speedMode and CS or NS end if speedEnabled and currentSpeedValue ~= spd then cleanupSpeedPhysics() end if not speedEnabled and spd > 0 then applySpeedWithLinearVelocity(spd) end else if speedEnabled then cleanupSpeedPhysics() end end if speedLabel then local shown if speedEnabled and currentSpeedValue and currentSpeedValue > 0 then shown = currentSpeedValue elseif hum.WalkSpeed and hum.WalkSpeed > 0 and hum.MoveDirection.Magnitude > 0.05 then shown = hum.WalkSpeed else local v = hrp.Velocity shown = math.sqrt(v.X * v.X + v.Z * v.Z) end speedLabel.Text = "Spd: " .. string.format("%.1f", shown) end end) setupSpeedIndicator(char) startEnemySpeed() end function toggleLockUI(state) if state == nil then uiLocked = not uiLocked else uiLocked = state end if uiLocked and editModeEnabled then editModeEnabled = false if setEditModeVisual then setEditModeVisual(false) end end if setLockUIVisual then setLockUIVisual(uiLocked) end end function toggleEditMode(state) if state == nil then state = not editModeEnabled end if state and uiLocked then state = false end editModeEnabled = state if setEditModeVisual then setEditModeVisual(editModeEnabled) end end function disableAllAimbots() if autoBatEnabled then disableAutoBat() if autoBatSetVisual then autoBatSetVisual(false) end if mobSetAutoBat then mobSetAutoBat(false) end end if tpLockEnabled then toggleAntiDesyncAimbot() end if autoBatV2Enabled then disableBatV2() if autoBatV2SetVisual then autoBatV2SetVisual(false) end if batV2FloatingButton then local btnFrame = batV2FloatingButton:FindFirstChild("Frame") if btnFrame then btnFrame.BackgroundColor3 = Color3.fromRGB(0,0,0) local label = btnFrame:FindFirstChild("TextLabel") if label then label.TextColor3 = Color3.fromRGB(255,255,255) end end end end end function stopAllBackgroundTasks() if movementLoop then movementLoop:Disconnect(); movementLoop = nil end if steppedConn then steppedConn:Disconnect(); steppedConn = nil end stopEnemySpeed() if stretchEnabled then disableStretch() end if stretchConn then stretchConn:Disconnect(); stretchConn = nil end if stretchFovConn then stretchFovConn:Disconnect(); stretchFovConn = nil end stopAntiRagdoll() stopBatCounter() stopMedusaCounter() stopMedusaAutoReset() stopAutoSteal() disableAutoBat() if tpLockEnabled then stopAntiDesyncAimbot() end if autoBatV2Enabled then disableBatV2() end stopAutoLeft() stopAutoRight() if unwalkEnabled then stopUnwalk() end if antiLagEnabled then disableAntiLag() end if espEnabled then toggleESP(false) end if dropActive then stopDropBrainrot() end if bodyLockEnabled then stopBodyLock() end cleanupSpeedPhysics() _blSuppressCount = 0 _blWasEnabled = false if _blRestoreTimer then task.cancel(_blRestoreTimer) _blRestoreTimer = nil end for _, t in ipairs(dropConnections) do if type(t) == "thread" then pcall(task.cancel, t) elseif type(t) == "RBXScriptConnection" then pcall(t.Disconnect, t) end end dropConnections = {} dropActive = false alPhase = 1 arPhase = 1 lastDropTime = 0 medusaDebounce = false medusaLastUsed = 0 end function buildConfigTable() local config = { normalSpeed = NS, carrySpeed = CS, laggerSpeed1 = LAGGER_SPEED_1, laggerSpeed2 = LAGGER_SPEED_2, stealRadius = CONFIG.STEAL_RANGE, stealDuration = CONFIG.HOLD_MAX, stealMode = CONFIG.STEAL_MODE, grabRadius = CONFIG.GRAB_RADIUS, primeRange = CONFIG.PRIME_RANGE, normalStealDuration = CONFIG.STEAL_DURATION, antiRagdoll = antiRagdollEnabled, autoSteal = CONFIG.AUTO_STEAL_ENABLED, medusaCounter = medusaCounterEnabled, batCounter = batCounterEnabled, laggerToggled = laggerToggled, laggerLevel = laggerLevel, carryMode = speedMode, batAimbotSpeed = BAT_AIMBOT_SPEED, dropMode = dropMode, medusaAutoReset = medusaAutoResetEnabled, stretchEnabled = stretchEnabled, stretchFOV = stretchFOV, uiScale = uiScaleValue, btnScale = btnScaleValue, animPack = currentAnimPack, espEnabled = espEnabled, antiLag = antiLagEnabled, tpLockEnabled = _G.AceAntiDesyncAimbotOn, neonWeather = neonWeatherEnabled, skyTheme = skyTheme, autoBatV2Enabled = autoBatV2Enabled, mobileButtonPositions = savedButtonPositions, dropBrainrotKey = {kb = KB.DropBrainrot.kb and KB.DropBrainrot.kb.Name, gp = KB.DropBrainrot.gp and KB.DropBrainrot.gp.Name}, autoLeftKey = {kb = KB.AutoLeft.kb and KB.AutoLeft.kb.Name, gp = KB.AutoLeft.gp and KB.AutoLeft.gp.Name}, autoRightKey = {kb = KB.AutoRight.kb and KB.AutoRight.kb.Name, gp = KB.AutoRight.gp and KB.AutoRight.gp.Name}, autoBatKey = {kb = KB.AutoBat.kb and KB.AutoBat.kb.Name, gp = KB.AutoBat.gp and KB.AutoBat.gp.Name}, tpFloorKey = {kb = KB.TPFloor.kb and KB.TPFloor.kb.Name, gp = KB.TPFloor.gp and KB.TPFloor.gp.Name}, carryToggleKey = {kb = KB.CarryToggle.kb and KB.CarryToggle.kb.Name, gp = KB.CarryToggle.gp and KB.CarryToggle.gp.Name}, laggerModeKey = {kb = KB.LaggerMode.kb and KB.LaggerMode.kb.Name, gp = KB.LaggerMode.gp and KB.LaggerMode.gp.Name}, instaResetKey = {kb = KB.InstaReset.kb and KB.InstaReset.kb.Name, gp = KB.InstaReset.gp and KB.InstaReset.gp.Name}, tpLockKey = {kb = KB.TPLock.kb and KB.TPLock.kb.Name, gp = KB.TPLock.gp and KB.TPLock.gp.Name}, tpBypassKey = {kb = KB.TPBypass.kb and KB.TPBypass.kb.Name, gp = KB.TPBypass.gp and KB.TPBypass.gp.Name}, antiDesyncKey = {kb = KB.AntiDesync.kb and KB.AntiDesync.kb.Name, gp = KB.AntiDesync.gp and KB.AntiDesync.gp.Name}, dropModeKey = {kb = KB.DropMode.kb and KB.DropMode.kb.Name, gp = KB.DropMode.gp and KB.DropMode.gp.Name}, batV2Key = {kb = KB.BatV2.kb and KB.BatV2.kb.Name, gp = KB.BatV2.gp and KB.BatV2.gp.Name}, instaResetFloatingPos = instaResetFloatingPos, tpBatFloatingPos = tpBatFloatingPos, batV2FloatingPos = batV2FloatingPos, antiAntiFloatingPos = antiAntiFloatingPos, bodyLockEnabled = bodyLockEnabled, bodyLockRange = bodyLockRange, autoResetStates = autoResetStates, progressBarPos = savedProgressBarPos, lockUI = uiLocked, editMode = editModeEnabled, backgroundIndex = currentBgIndex, antiDie = (_G.AstaAntiDieOn == true), antiAnti = (antiAntiEnabled == true), } if pbFrame then config.progressBarPos = { XScale = pbFrame.Position.X.Scale, XOffset = pbFrame.Position.X.Offset, YScale = pbFrame.Position.Y.Scale, YOffset = pbFrame.Position.Y.Offset } end if MobilePanel and MobilePanel:FindFirstChild("FloatingPanel") then local container = MobilePanel:FindFirstChild("FloatingPanel") config.mobilePanelPos = { XScale = container.Position.X.Scale, XOffset = container.Position.X.Offset, YScale = container.Position.Y.Scale, YOffset = container.Position.Y.Offset } end return config end function saveAllSettings() if _isResetting then return true end local config = buildConfigTable() local json = HS:JSONEncode(config) if json == _lastSavedJSON then return true end local success, err = pcall(function() writefile(CONFIG_FILE, json) end) if success then _lastSavedJSON = json end return success end function loadAllSettings() if not isfile or not isfile(CONFIG_FILE) then return false end local success, data = pcall(function() return HS:JSONDecode(readfile(CONFIG_FILE)) end) if not success or not data then return false end _isLoading = true NS = data.normalSpeed or NS CS = data.carrySpeed or CS LAGGER_SPEED_1 = data.laggerSpeed1 or LAGGER_SPEED_1 LAGGER_SPEED_2 = data.laggerSpeed2 or LAGGER_SPEED_2 CONFIG.STEAL_RANGE = data.stealRadius or CONFIG.STEAL_RANGE CONFIG.HOLD_MAX = data.stealDuration or CONFIG.HOLD_MAX CONFIG.STEAL_MODE = data.stealMode or CONFIG.STEAL_MODE CONFIG.GRAB_RADIUS = data.grabRadius or CONFIG.GRAB_RADIUS CONFIG.PRIME_RANGE = data.primeRange or CONFIG.PRIME_RANGE CONFIG.STEAL_DURATION = data.normalStealDuration or CONFIG.STEAL_DURATION uiLocked = data.lockUI or true editModeEnabled = data.editMode or false antiRagdollEnabled = data.antiRagdoll or false CONFIG.AUTO_STEAL_ENABLED = data.autoSteal or false medusaCounterEnabled = data.medusaCounter or false batCounterEnabled = data.batCounter or false unwalkEnabled = data.unwalk or false antiLagEnabled = data.antiLag or false laggerToggled = data.laggerToggled or false speedMode = data.carryMode or false laggerLevel = data.laggerLevel or 1 medusaAutoResetEnabled = data.medusaAutoReset or false if medusaAutoResetEnabled and medusaCounterEnabled then medusaCounterEnabled = false end uiScaleValue = data.uiScale or 100 if mainUIScale then mainUIScale.Scale = uiScaleValue / 100 end if pbScale then pbScale.Scale = uiScaleValue / 100 end btnScaleValue = data.btnScale or 100 pcall(applyButtonScale) espEnabled = data.espEnabled or false if espEnabled then toggleESP(true) else toggleESP(false) end autoBatV2Enabled = data.autoBatV2Enabled or false if autoBatV2Enabled then task.defer(function() enableBatV2() if autoBatV2SetVisual then autoBatV2SetVisual(true) end end) else if autoBatV2SetVisual then autoBatV2SetVisual(false) end end local antiDesyncState = data.tpLockEnabled or false if antiDesyncState then task.defer(function() startAntiDesyncAimbot() if tpLockSetVisual then tpLockSetVisual(true) end end) else if tpLockSetVisual then tpLockSetVisual(false) end end local antiDieState = data.antiDie or false if antiDieState then task.defer(function() startAntiDie() if setAntiDieVisual then setAntiDieVisual(true) end end) else task.defer(function() stopAntiDie() if setAntiDieVisual then setAntiDieVisual(false) end end) end local antiAntiState = data.antiAnti or false task.defer(function() if setAntiAnti then pcall(setAntiAnti, antiAntiState) end if antiAntiSetVisual then antiAntiSetVisual(antiAntiState) end end) neonWeatherEnabled = data.neonWeather or false if neonWeatherEnabled then task.defer(function() toggleNeonWeather(true) end) else toggleNeonWeather(false) end if data.animPack and ANIM_PACKS[data.animPack] then startAnimPack(data.animPack) else currentAnimPack = "Off" stopAnimPack() end local function lk(e, d) if not d then return end if d.kb and Enum.KeyCode[d.kb] then e.kb = Enum.KeyCode[d.kb] end if d.gp and Enum.KeyCode[d.gp] then e.gp = Enum.KeyCode[d.gp] end end lk(KB.DropBrainrot, data.dropBrainrotKey) lk(KB.AutoLeft, data.autoLeftKey) lk(KB.AutoRight, data.autoRightKey) lk(KB.AutoBat, data.autoBatKey) lk(KB.TPFloor, data.tpFloorKey) lk(KB.CarryToggle, data.carryToggleKey) lk(KB.LaggerMode, data.laggerModeKey) lk(KB.InstaReset, data.instaResetKey) lk(KB.TPLock, data.tpLockKey) lk(KB.TPBypass, data.tpBypassKey) lk(KB.AntiDesync, data.antiDesyncKey) lk(KB.DropMode, data.dropModeKey) lk(KB.BatV2, data.batV2Key) if data.mobileButtonPositions then savedButtonPositions = data.mobileButtonPositions end if data.mobilePanelPos then savedMobilePanelPos = data.mobilePanelPos end if data.instaResetFloatingPos then instaResetFloatingPos = data.instaResetFloatingPos end if data.tpBatFloatingPos then tpBatFloatingPos = data.tpBatFloatingPos end if data.batV2FloatingPos then batV2FloatingPos = data.batV2FloatingPos end if data.antiAntiFloatingPos then antiAntiFloatingPos = data.antiAntiFloatingPos end if data.progressBarPos then savedProgressBarPos = data.progressBarPos end if data.bodyLockEnabled ~= nil then bodyLockEnabled = data.bodyLockEnabled if bodyLockEnabled then task.defer(function() if bodyLockSetVisual then bodyLockSetVisual(true) end startBodyLock() end) end end if data.bodyLockRange then bodyLockRange = data.bodyLockRange if bodyLockRangeBox then bodyLockRangeBox.Text = tostring(bodyLockRange) end end if data.autoResetStates then for k, v in pairs(data.autoResetStates) do if autoResetStates[k] ~= nil then autoResetStates[k] = v end end end if type(data.skyTheme) == "string" then skyTheme = data.skyTheme if skyValueLabel then skyValueLabel.Text = skyTheme end task.defer(function() pcall(function() applyCustomSky(skyTheme) end) end) end dropMode = data.dropMode or 1 stretchEnabled = data.stretchEnabled or false stretchFOV = data.stretchFOV or 120 BAT_AIMBOT_SPEED = data.batAimbotSpeed or BAT_AIMBOT_SPEED if data.backgroundIndex then currentBgIndex = data.backgroundIndex if bgDecalRef then bgDecalRef.Image = BackgroundDecals[currentBgIndex] or "" end if bgPreviewRef then bgPreviewRef.Image = BackgroundDecals[currentBgIndex] or "" end if astaRefreshFloatBgs then astaRefreshFloatBgs() end else currentBgIndex = 1 end autoBatEnabled = false autoLeftEnabled = false autoRightEnabled = false if dropModeBtnRef then dropModeBtnRef.Text = dropMode == 1 and "Fling" or "Jump Drop" end refreshSpeedModeLabel() _lastSavedJSON = HS:JSONEncode(buildConfigTable()) _isLoading = false return true end function forceResetUI() if normalBox then normalBox.Text = tostring(NS) end if carryBox then carryBox.Text = tostring(CS) end if radInput then radInput.Text = tostring(CONFIG.STEAL_RANGE) end if grabRadiusBox then grabRadiusBox.Text = tostring(CONFIG.GRAB_RADIUS) end if primeRangeBox then primeRangeBox.Text = tostring(CONFIG.PRIME_RANGE) end if updateStealModeButtons then updateStealModeButtons() end if laggerBox then laggerBox.Text = tostring(LAGGER_SPEED_1) end if lagger2Box then lagger2Box.Text = tostring(LAGGER_SPEED_2) end if batSpeedBox then batSpeedBox.Text = tostring(BAT_AIMBOT_SPEED) end if uiScaleBox then uiScaleBox.Text = tostring(uiScaleValue) end if btnScaleBox then btnScaleBox.Text = tostring(btnScaleValue) end if dropModeBtnRef then dropModeBtnRef.Text = dropMode == 1 and "Fling" or "Jump Drop" end if bodyLockRangeBox then bodyLockRangeBox.Text = tostring(bodyLockRange) end local function safeSet(fn, val) if fn then fn(val) end end safeSet(autoBatSetVisual, false) safeSet(autoLeftSetVisual, false) safeSet(autoRightSetVisual, false) safeSet(setBatCounterVisual, false) safeSet(setMedusaVisual, false) safeSet(setMedusaAutoResetVisual, false) safeSet(setJumpVisual, InfJumpState.enabled) safeSet(setAntiRagVisual, false) safeSet(setUnwalkVisual, false) safeSet(setAntiLagVisual, false) safeSet(setLockUIVisual, false) safeSet(setEditModeVisual, false) safeSet(setInstaGrab, false) safeSet(tpLockSetVisual, false) safeSet(setESPVIsual, false) safeSet(bodyLockSetVisual, false) safeSet(setNeonWeatherVisual, false) safeSet(setAntiDieVisual, false) safeSet(autoBatV2SetVisual, false) if _G.stretchToggleSetter then _G.stretchToggleSetter(false) end safeSet(mobSetAutoBat, false) safeSet(mobSetAutoLeft, false) safeSet(mobSetAutoRight, false) safeSet(mobSetDropBR, false) safeSet(mobSetTpDown, false) safeSet(mobSetCarry, false) safeSet(mobSetLagger1, false) safeSet(mobSetLagger2, false) refreshSpeedModeLabel() updateProgressBarVisibility() disableAntiLag() toggleNeonWeather(false) disableBatV2() for _, ref in ipairs(keyButtonRefs) do local entry = ref.entry local label if ref.mode == "gp" then label = (entry.gp and entry.gp.Name) or "None" else label = (entry.kb and entry.kb.Name) or "None" end ref.btn.Text = label end currentBgIndex = 1 if bgDecalRef then bgDecalRef.Image = BackgroundDecals[1] or "" end if bgPreviewRef then bgPreviewRef.Image = BackgroundDecals[1] or "" end if astaRefreshFloatBgs then astaRefreshFloatBgs() end  end function resetFloatingPositions() if MobilePanel and MobilePanel:FindFirstChild("FloatingPanel") then local container = MobilePanel:FindFirstChild("FloatingPanel") container.Position = UDim2.new(0, 10, 0, 0) savedButtonPositions = {} for _, btn in ipairs(MobilePanel:GetDescendants()) do if btn:IsA("TextButton") and btn.Name then local defX, defY = getDefaultButtonPosition(btn.Name) btn.Position = UDim2.new(0, defX + 10, 0, defY) end end end if instaResetFloatingButton and instaResetFloatingButton:FindFirstChild("Frame") then local btnFrame = instaResetFloatingButton:FindFirstChild("Frame") btnFrame.Position = UDim2.new(0.5, -120, 0, 10) instaResetFloatingPos = nil end if tpBatFloatingButton and tpBatFloatingButton:FindFirstChild("Frame") then local btnFrame = tpBatFloatingButton:FindFirstChild("Frame") btnFrame.Position = UDim2.new(0.5, 20, 0, 10) tpBatFloatingPos = nil end if batV2FloatingButton and batV2FloatingButton:FindFirstChild("Frame") then local btnFrame = batV2FloatingButton:FindFirstChild("Frame") btnFrame.Position = UDim2.new(0.5, -50, 0, 10) batV2FloatingPos = nil end if antiAntiFloatingButton and antiAntiFloatingButton:FindFirstChild("Frame") then local aaBtnFrame = antiAntiFloatingButton:FindFirstChild("Frame") aaBtnFrame.Position = UDim2.new(0.5, 90, 0, 10) antiAntiFloatingPos = nil end if pbFrame then pbFrame.Position = UDim2.new(0.5, -140, 1, -50) savedProgressBarPos = nil end savedMobilePanelPos = nil instaResetFloatingPos = nil tpBatFloatingPos = nil batV2FloatingPos = nil antiAntiFloatingPos = nil end function resetToFactoryDefaults() _isResetting = true stopAllBackgroundTasks() stopAutoSteal() stopBatCounter() stopMedusaCounter() stopMedusaAutoReset() stopAntiRagdoll() stopUnwalk() disableAutoBat() if tpLockEnabled then stopAntiDesyncAimbot() end disableBatV2() stopBodyLock() if espEnabled then toggleESP(false) end if stretchEnabled then disableStretch() end if antiLagEnabled then disableAntiLag() end if dropActive then stopDropBrainrot() end toggleNeonWeather(false) NS = 60 CS = 29 LAGGER_SPEED_1 = 20 LAGGER_SPEED_2 = 10 CONFIG.STEAL_RANGE = 9 CONFIG.HOLD_MAX = 2.6 speedMode = false laggerToggled = false laggerLevel = 1 antiRagdollEnabled = false medusaCounterEnabled = false batCounterEnabled = false autoBatEnabled = false autoLeftEnabled = false autoRightEnabled = false unwalkEnabled = false antiLagEnabled = false uiLocked = true editModeEnabled = false CONFIG.AUTO_STEAL_ENABLED = false BAT_AIMBOT_SPEED = 58 _G.AceAntiDesyncAimbotOn = false pcall(function() stopAntiDie() if setAntiDieVisual then setAntiDieVisual(false) end end) dropMode = 1 medusaAutoResetEnabled = false stretchEnabled = false stretchFOV = 120 uiScaleValue = 100 if mainUIScale then mainUIScale.Scale = 1 end if pbScale then pbScale.Scale = 1 end btnScaleValue = 100 pcall(applyButtonScale) if btnScaleBox then btnScaleBox.Text = "100" end espEnabled = false bodyLockEnabled = false bodyLockRange = 20 autoBatV2Enabled = false for k in pairs(autoResetStates) do autoResetStates[k] = false end currentAnimPack = "Off" stopAnimPack() savedStealRadius = CONFIG.STEAL_RANGE savedStealDuration = CONFIG.HOLD_MAX CONFIG.STEAL_MODE = "normal" CONFIG.GRAB_RADIUS = 60 CONFIG.PRIME_RANGE = 80 for key, val in pairs(DEFAULT_KB) do if KB[key] then KB[key].kb = val.kb KB[key].gp = val.gp end end if isfile and isfile(CONFIG_FILE) then pcall(delfile, CONFIG_FILE) end resetFloatingPositions() forceResetUI() updateProgressBarVisibility() refreshSpeedModeLabel() _lastSavedJSON = nil saveAllSettings() _isResetting = false end function updateProgressBarVisibility() if pbFrame then pbFrame.Visible = CONFIG.AUTO_STEAL_ENABLED end end function applyShimmerToText(obj, speed) speed = speed or 0.8 local grad = Instance.new("UIGradient", obj) grad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(80,80,80)), ColorSequenceKeypoint.new(0.3, Color3.fromRGB(200,200,200)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(0.7, Color3.fromRGB(200,200,200)), ColorSequenceKeypoint.new(1, Color3.fromRGB(80,80,80)) }) grad.Rotation = 45 grad.Offset = Vector2.new(0,0) task.spawn(function() local t = 0 while grad and grad.Parent do t = t + 0.02 grad.Offset = Vector2.new(math.sin(t * speed) * 0.4, 0) task.wait(0.04) end end) return grad end function getDefaultButtonPosition(btnName) local BTN_W, BTN_H = 60, 60 local GAP = 8 local orderMap = { DropBR = 0, AutoLeft = 1, AutoBat = 2, AutoRight = 3, TpDown = 4, Carry = 5, Lagger1 = 6, Lagger2 = 7 } local order = orderMap[btnName] or 0 local row = math.floor(order / 2) local col = order % 2 return col * (BTN_W + GAP), row * (BTN_H + GAP + 10) end local BackgroundDecals = { [1] = "rbxassetid://105542572852370", [2] = "rbxassetid://128997600029394", [3] = "rbxassetid://99420703803809", [4] = "rbxassetid://117186687504218", [5] = "rbxassetid://123015462349687", [6] = "rbxassetid://111195293067618", [7] = "rbxassetid://133619037676439", [8] = "rbxassetid://116985758139639", [9] = "rbxassetid://132062039944824", [10] = "rbxassetid://139571679676131", [11] = "rbxassetid://70418952815837", } currentBgIndex = currentBgIndex or 1 local bgDecalRef = nil local bgPreviewRef = nil local currentBgIndex2 = 1 local bgDecal2Ref = nil local bgPreview2Ref = nil local function updateBackground(index) currentBgIndex = index if bgDecalRef then bgDecalRef.Image = BackgroundDecals[index] or "" end if bgPreviewRef then bgPreviewRef.Image = BackgroundDecals[index] or "" end   if astaRefreshFloatBgs then astaRefreshFloatBgs() end end  local antiDieEnabled = false local antiDieHumanoid = nil local antiDieChar = nil local antiDieConns = {} local function antiDieHeal() if not antiDieEnabled or not antiDieHumanoid then return end pcall(function() antiDieHumanoid.Health = antiDieHumanoid.MaxHealth if antiDieHumanoid.Health <= 0 then antiDieHumanoid:BreakJoints() task.wait(0.05) antiDieHumanoid.Health = antiDieHumanoid.MaxHealth end end) end local function antiDieOnHealthChanged(newHealth) if not antiDieEnabled then return end if newHealth <= 5 and antiDieHumanoid and antiDieHumanoid.Health > 0 then pcall(function() antiDieHumanoid.Health = antiDieHumanoid.MaxHealth end) return end if newHealth <= 0 then antiDieHeal() end end local function setupAntiDie(char) if not char then return end antiDieChar = char antiDieHumanoid = char:FindFirstChildOfClass("Humanoid") if not antiDieHumanoid then return end for _, c in ipairs(antiDieConns) do pcall(function() c:Disconnect() end) end antiDieConns = {} table.insert(antiDieConns, antiDieHumanoid.HealthChanged:Connect(antiDieOnHealthChanged)) table.insert(antiDieConns, antiDieHumanoid.Died:Connect(function() if antiDieEnabled then antiDieHeal() end end)) end LP.CharacterAdded:Connect(function(char) task.wait(0.1) setupAntiDie(char) end) task.spawn(function() while true do task.wait(0.1) if antiDieEnabled and antiDieHumanoid and antiDieHumanoid.Parent and antiDieHumanoid.Health > 0 then if antiDieHumanoid.Health < (antiDieHumanoid.MaxHealth * 0.5) then pcall(function() antiDieHumanoid.Health = antiDieHumanoid.MaxHealth end) end end end end) task.spawn(function() task.wait(0.2) if LP.Character then setupAntiDie(LP.Character) end end) setAntiDieVisual = nil function startAntiDie() antiDieEnabled = true _G.AstaAntiDieOn = true if LP.Character then setupAntiDie(LP.Character) end end function stopAntiDie() antiDieEnabled = false _G.AstaAntiDieOn = false end function buildGui() local SILVER = Color3.fromRGB(180, 180, 190) local SILVER_DARK = Color3.fromRGB(100, 100, 110) local SILVER_LIGHT = Color3.fromRGB(220, 220, 230) local BG = Color3.fromRGB(0,0,0) local BG2 = Color3.fromRGB(10,10,10) local ROW_BG = Color3.fromRGB(10,10,10) local ROW_BORDER = Color3.fromRGB(50,50,50) local WHITE = Color3.fromRGB(255,255,255) local GRAY = Color3.fromRGB(60,60,60) local INP = Color3.fromRGB(15,15,15) local OFF = Color3.fromRGB(25,25,30) local TAB_ACTIVE = SILVER local TAB_INACT = SILVER_DARK local SECT_LBL = SILVER local HOV = Color3.fromRGB(25,25,25) local DOT_ON = SILVER local ON_COLOR = SILVER local STROKE_COLOR = Color3.fromRGB(50,50,50) local GUI_W, GUI_H = 330, 480 local old = game:GetService("CoreGui"):FindFirstChild("AstaHub") if old then old:Destroy() end local pg = LP:FindFirstChild("PlayerGui") if pg then local o = pg:FindFirstChild("AstaHub"); if o then o:Destroy() end end gui = Instance.new("ScreenGui") gui.Name = "Asta Hub" gui.ResetOnSpawn = false gui.DisplayOrder = 10 gui.IgnoreGuiInset = true pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end) if not pcall(function() gui.Parent = game:GetService("CoreGui") end) then gui.Parent = LP:WaitForChild("PlayerGui") end main = Instance.new("Frame", gui) main.Size = UDim2.new(0, GUI_W, 0, GUI_H) main.Position = UDim2.new(0, 20, 0, 2) main.BackgroundColor3 = BG main.BackgroundTransparency = 1 main.BorderSizePixel = 0 main.ClipsDescendants = true Instance.new("UICorner", main).CornerRadius = UDim.new(0, 24) mainUIScale = Instance.new("UIScale", main) mainUIScale.Scale = uiScaleValue / 100 bgDecalRef = Instance.new("ImageLabel", main) bgDecalRef.Size = UDim2.new(1, 0, 1, 0) bgDecalRef.Position = UDim2.new(0, 0, 0, 0) bgDecalRef.BackgroundTransparency = 1 bgDecalRef.Image = BackgroundDecals[currentBgIndex] or "" bgDecalRef.ZIndex = 0 bgDecalRef.ScaleType = Enum.ScaleType.Crop _G.AstaHubBgDecal = bgDecalRef _G.AstaHubBgDecals = BackgroundDecals local decalCorner = Instance.new("UICorner", bgDecalRef) decalCorner.CornerRadius = UDim.new(0, 24) local titleLabel = Instance.new("TextLabel", main) titleLabel.Size = UDim2.new(1, -80, 0, 40) titleLabel.Position = UDim2.new(0, 12, 0, 4) titleLabel.BackgroundTransparency = 1 titleLabel.Text = "PRODIGY HUB" titleLabel.TextColor3 = WHITE titleLabel.Font = Enum.Font.GothamBlack titleLabel.TextSize = 22 titleLabel.TextXAlignment = Enum.TextXAlignment.Left titleLabel.TextStrokeColor3 = Color3.fromRGB(40,40,40) titleLabel.TextStrokeTransparency = 0.2 titleLabel.ZIndex = 20 local grad = Instance.new("UIGradient", titleLabel) grad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, WHITE), ColorSequenceKeypoint.new(0.45, WHITE), ColorSequenceKeypoint.new(0.55, SILVER), ColorSequenceKeypoint.new(1, SILVER) }) grad.Rotation = 0 local closeBtn = Instance.new("TextButton", main) closeBtn.Size = UDim2.new(0, 32, 0, 32) closeBtn.Position = UDim2.new(1, -42, 0, 8) closeBtn.BackgroundColor3 = Color3.fromRGB(30,30,35) closeBtn.BackgroundTransparency = 0.6 closeBtn.BorderSizePixel = 0 closeBtn.Text = "−" closeBtn.TextColor3 = WHITE closeBtn.Font = Enum.Font.GothamBold closeBtn.TextSize = 26 closeBtn.AutoButtonColor = false closeBtn.ZIndex = 200 Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8) closeBtn.MouseEnter:Connect(function() TS:Create(closeBtn, TweenInfo.new(0.12), {TextColor3 = WHITE, BackgroundColor3 = SILVER_DARK}):Play() end) closeBtn.MouseLeave:Connect(function() TS:Create(closeBtn, TweenInfo.new(0.12), {TextColor3 = WHITE, BackgroundColor3 = Color3.fromRGB(30,30,35)}):Play() end) miniBtn = Instance.new("ImageButton", gui) miniBtn.Name = "AstaHubOpenButton" miniBtn.Size = UDim2.new(0, 50, 0, 50) miniBtn.Position = UDim2.new(0, 16, 0, 58) miniBtn.BackgroundColor3 = BG2 miniBtn.BackgroundTransparency = 0 miniBtn.BorderSizePixel = 0 miniBtn.Image = "rbxassetid://88937938167485" miniBtn.ZIndex = 20 miniBtn.Visible = false local miniBtnCorner = Instance.new("UICorner", miniBtn) miniBtnCorner.CornerRadius = UDim.new(1, 0) showGui = function() if main then main.Visible = true end if miniBtn then miniBtn.Visible = false end end hideGui = function() if main then main.Visible = false end if miniBtn then miniBtn.Visible = true end end closeBtn.MouseButton1Click:Connect(hideGui) miniBtn.MouseButton1Click:Connect(showGui) local tabBar = Instance.new("Frame", main) tabBar.Size = UDim2.new(0, 80, 1, -96) tabBar.Position = UDim2.new(0, 12, 0, 86) tabBar.BackgroundTransparency = 1 tabBar.ZIndex = 10 local tabLayout = Instance.new("UIListLayout", tabBar) tabLayout.FillDirection = Enum.FillDirection.Vertical tabLayout.Padding = UDim.new(0, 4) tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center tabLayout.VerticalAlignment = Enum.VerticalAlignment.Top local tabContent = Instance.new("Frame", main) tabContent.Size = UDim2.new(1, -80 - 20, 1, -96) tabContent.Position = UDim2.new(0, 80 + 12, 0, 86) tabContent.BackgroundTransparency = 1 tabContent.ClipsDescendants = true tabContent.ZIndex = 5 local tabs = {"Speed", "Combat", "Main", "Visual", "Misc", "Keybinds"} local tabButtons = {} local contentPages = {} for i, name in ipairs(tabs) do local btn = Instance.new("TextButton", tabBar) btn.Size = UDim2.new(1, -8, 0, 30) btn.BackgroundColor3 = Color3.fromRGB(0,0,0) btn.BackgroundTransparency = 0.5 btn.BorderSizePixel = 0 btn.Text = name btn.TextColor3 = TAB_INACT btn.Font = Enum.Font.GothamBold btn.TextSize = 13 btn.AutoButtonColor = false btn.ZIndex = 11 Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8) local stroke = Instance.new("UIStroke", btn) stroke.Color = ROW_BORDER stroke.Thickness = 1 local page = Instance.new("ScrollingFrame", tabContent) page.Size = UDim2.new(1, 0, 1, 0) page.Position = UDim2.new(0, 0, 0, 0) page.BackgroundColor3 = Color3.fromRGB(5,5,5) page.BackgroundTransparency = 0.6 page.BorderSizePixel = 0 page.ClipsDescendants = true page.ScrollBarThickness = 2 page.ScrollBarImageColor3 = Color3.fromRGB(30,30,35) page.ScrollBarImageTransparency = 0.3 page.CanvasSize = UDim2.new(0, 0, 0, 0) page.AutomaticCanvasSize = Enum.AutomaticSize.None page.ScrollingDirection = Enum.ScrollingDirection.Y page.ZIndex = 6 Instance.new("UICorner", page).CornerRadius = UDim.new(0, 16) page.Visible = (i == 1) local layout = Instance.new("UIListLayout", page) layout.SortOrder = Enum.SortOrder.LayoutOrder layout.Padding = UDim.new(0, 6) layout.HorizontalAlignment = Enum.HorizontalAlignment.Center local padding = Instance.new("UIPadding", page) padding.PaddingLeft = UDim.new(0, 8) padding.PaddingRight = UDim.new(0, 8) padding.PaddingTop = UDim.new(0, 6) padding.PaddingBottom = UDim.new(0, 16) local function updateCanvas() local contentSize = layout.AbsoluteContentSize local padBottom = padding.PaddingBottom.Offset local padTop = padding.PaddingTop.Offset local extra = 20 page.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + padTop + padBottom + extra) end layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas) task.spawn(updateCanvas) contentPages[name] = page btn.MouseButton1Click:Connect(function() for _, pg in pairs(contentPages) do pg.Visible = false end page.Visible = true for _, b in ipairs(tabButtons) do b.TextColor3 = TAB_INACT b.BackgroundColor3 = Color3.fromRGB(0,0,0) end btn.TextColor3 = TAB_ACTIVE btn.BackgroundColor3 = Color3.fromRGB(20,20,20) task.wait(0.05) updateCanvas() end) table.insert(tabButtons, btn) end if tabButtons[1] then tabButtons[1].TextColor3 = TAB_ACTIVE tabButtons[1].BackgroundColor3 = Color3.fromRGB(20,20,20) end local pageCounters = {} local function getNextOrder(page) if not pageCounters[page] then pageCounters[page] = 0 end pageCounters[page] = pageCounters[page] + 1 return pageCounters[page] end local function mkSect(page, txt) local f = Instance.new("Frame", page) f.Size = UDim2.new(1, 0, 0, 26) f.BackgroundTransparency = 1 f.BorderSizePixel = 0 f.LayoutOrder = getNextOrder(page) f.ZIndex = 7 local l = Instance.new("TextLabel", f) l.Size = UDim2.new(1, -16, 1, 0) l.Position = UDim2.new(0, 8, 0, 0) l.BackgroundTransparency = 1 l.Text = txt:upper() l.TextColor3 = SECT_LBL l.Font = Enum.Font.GothamBlack l.TextSize = 13 l.TextXAlignment = Enum.TextXAlignment.Left l.TextStrokeColor3 = Color3.fromRGB(60,60,60) l.TextStrokeTransparency = 0.3 l.ZIndex = 8 local line = Instance.new("Frame", f) line.Size = UDim2.new(1, -24, 0, 1.5) line.Position = UDim2.new(0, 12, 1, -4) line.BackgroundColor3 = SILVER line.BackgroundTransparency = 0.6 line.BorderSizePixel = 0 line.ZIndex = 8 return f end local function mkRow(page, h) local f = Instance.new("Frame", page) f.Size = UDim2.new(1, -4, 0, h or 38) f.BackgroundColor3 = ROW_BG f.BackgroundTransparency = 0.7 f.BorderSizePixel = 0 f.LayoutOrder = getNextOrder(page) f.ZIndex = 7 Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10) local rowStroke = Instance.new("UIStroke", f) rowStroke.Color = ROW_BORDER rowStroke.Thickness = 1 rowStroke.Transparency = 0.5 f.MouseEnter:Connect(function() TS:Create(f, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(28,28,28)}):Play() end) f.MouseLeave:Connect(function() TS:Create(f, TweenInfo.new(0.1), {BackgroundColor3 = ROW_BG}):Play() end) return f end local function mkLabel(row, txt) local l = Instance.new("TextLabel", row) l.Size = UDim2.new(0.55, 0, 1, 0) l.Position = UDim2.new(0, 10, 0, 0) l.BackgroundTransparency = 1 l.Text = txt l.TextColor3 = WHITE l.Font = Enum.Font.GothamBold l.TextSize = 11 l.TextXAlignment = Enum.TextXAlignment.Left l.TextTruncate = Enum.TextTruncate.AtEnd l.TextStrokeColor3 = Color3.fromRGB(0,0,0) l.TextStrokeTransparency = 0.5 l.ZIndex = 8 return l end local function mkPill(row, offset) local pill = Instance.new("Frame", row) pill.Size = UDim2.new(0, 44, 0, 22) pill.Position = UDim2.new(1, -(offset or 52), 0.5, -11) pill.BackgroundColor3 = OFF pill.BorderSizePixel = 0 pill.ZIndex = 8 Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0) local stroke = Instance.new("UIStroke", pill) stroke.Color = ROW_BORDER stroke.Thickness = 1.2 stroke.Transparency = 0.6 local dot = Instance.new("Frame", pill) dot.Size = UDim2.new(0, 16, 0, 16) dot.Position = UDim2.new(0, 3, 0.5, -8) dot.BackgroundColor3 = GRAY dot.BorderSizePixel = 0 dot.ZIndex = 9 Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0) return pill, dot end local function animPill(pill, dot, on) TS:Create(pill, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = on and SILVER or OFF}):Play() TS:Create(dot, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = on and WHITE or GRAY }):Play() local stroke = pill:FindFirstChildOfClass("UIStroke") if stroke then TS:Create(stroke, TweenInfo.new(0.2), {Color = on and SILVER or ROW_BORDER, Transparency = on and 0 or 0.6}):Play() end end local function mkToggle(page, txt, cb) local row = mkRow(page, 38) mkLabel(row, txt) local pill, dot = mkPill(row, 52) local on = false local function sv(s) on = s; animPill(pill, dot, s) end local clk = Instance.new("TextButton", pill) clk.Size = UDim2.new(1,0,1,0) clk.BackgroundTransparency = 1 clk.Text = "" clk.AutoButtonColor = false clk.ZIndex = 10 clk.MouseButton1Click:Connect(function() if editModeEnabled and not uiLocked then pcall(cb, not on) else on = not on sv(on) pcall(cb, on) end end) return sv end local function mkSelector(parent, default, options, cb) local container = Instance.new("Frame", parent) container.Size = UDim2.new(0, 160, 1, 0) container.Position = UDim2.new(1, -168, 0, 0) container.BackgroundTransparency = 1 container.ZIndex = 8 local leftBtn = Instance.new("TextButton", container) leftBtn.Size = UDim2.new(0, 28, 0, 26) leftBtn.Position = UDim2.new(0, 0, 0.5, -13) leftBtn.BackgroundColor3 = INP leftBtn.BackgroundTransparency = 0.7 leftBtn.BorderSizePixel = 0 leftBtn.Text = "<" leftBtn.TextColor3 = WHITE leftBtn.Font = Enum.Font.GothamBold leftBtn.TextSize = 13 leftBtn.AutoButtonColor = false leftBtn.ZIndex = 9 Instance.new("UICorner", leftBtn).CornerRadius = UDim.new(0, 6) local leftStroke = Instance.new("UIStroke", leftBtn) leftStroke.Color = ROW_BORDER leftStroke.Thickness = 1 local label = Instance.new("TextLabel", container) label.Size = UDim2.new(0, 80, 0, 26) label.Position = UDim2.new(0.5, -40, 0.5, -13) label.BackgroundTransparency = 1 label.Text = default label.TextColor3 = WHITE label.Font = Enum.Font.GothamBold label.TextSize = 12 label.TextXAlignment = Enum.TextXAlignment.Center label.ZIndex = 9 local rightBtn = Instance.new("TextButton", container) rightBtn.Size = UDim2.new(0, 28, 0, 26) rightBtn.Position = UDim2.new(1, -28, 0.5, -13) rightBtn.BackgroundColor3 = INP rightBtn.BackgroundTransparency = 0.7 rightBtn.BorderSizePixel = 0 rightBtn.Text = ">" rightBtn.TextColor3 = WHITE rightBtn.Font = Enum.Font.GothamBold rightBtn.TextSize = 13 rightBtn.AutoButtonColor = false rightBtn.ZIndex = 9 Instance.new("UICorner", rightBtn).CornerRadius = UDim.new(0, 6) local rightStroke = Instance.new("UIStroke", rightBtn) rightStroke.Color = ROW_BORDER rightStroke.Thickness = 1 local function updateLabel(newText) label.Text = newText end leftBtn.MouseButton1Click:Connect(function() if cb then cb(-1, updateLabel) end end) rightBtn.MouseButton1Click:Connect(function() if cb then cb(1, updateLabel) end end) return label end local function mkBox(parent, default, w, xOff, cb) local tb = Instance.new("TextBox", parent) local bw = w or 50 local xo = math.max(xOff or 56, bw + 12) tb.Size = UDim2.new(0, bw, 0, 24) tb.Position = UDim2.new(1, -xo, 0.5, -12) tb.BackgroundColor3 = INP tb.BackgroundTransparency = 0.7 tb.BorderSizePixel = 0 tb.Text = tostring(default) tb.TextColor3 = WHITE tb.Font = Enum.Font.GothamBold tb.TextSize = 11 tb.ClearTextOnFocus = false tb.ZIndex = 8 Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6) local bs = Instance.new("UIStroke", tb) bs.Color = ROW_BORDER bs.Thickness = 1.2 bs.Transparency = 0.25 tb.Focused:Connect(function() TS:Create(bs, TweenInfo.new(0.12), {Color = SILVER, Transparency = 0}):Play() end) tb.FocusLost:Connect(function() TS:Create(bs, TweenInfo.new(0.12), {Color = ROW_BORDER, Transparency = 0.25}):Play() if cb then local n = tonumber(tb.Text); if n then cb(n) else tb.Text = tostring(default) end end end) return tb end local function mkKeyButton(parent, kbEntry, mode) mode = mode or "kb" local btn = Instance.new("TextButton", parent) btn.Size = UDim2.new(0, 80, 0, 24) btn.Position = UDim2.new(1, -88, 0.5, -12) btn.BackgroundColor3 = INP btn.BackgroundTransparency = 0.5 btn.BorderSizePixel = 0 local function getLabel() if mode == "gp" then return (kbEntry.gp and kbEntry.gp.Name) or "None" end return (kbEntry.kb and kbEntry.kb.Name) or "None" end btn.Text = getLabel() btn.TextColor3 = WHITE btn.Font = Enum.Font.GothamBold btn.TextSize = 9 btn.ZIndex = 8 btn.AutoButtonColor = false Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6) local bs = Instance.new("UIStroke", btn) bs.Color = ROW_BORDER bs.Thickness = 1 local li = false; local lc; local pv = btn.Text; local listenStart = 0 btn.Activated:Connect(function() if li then li = false; _anyKeyListening = false; if lc then lc:Disconnect(); lc = nil end; btn.Text = pv; btn.TextColor3 = WHITE; return end pv = btn.Text; li = true; _anyKeyListening = true; listenStart = tick(); btn.Text = "..."; btn.TextColor3 = WHITE lc = UIS.InputBegan:Connect(function(inp) if not li then return end if inp.KeyCode == Enum.KeyCode.Escape then li = false; _anyKeyListening = false; if lc then lc:Disconnect(); lc = nil end; btn.Text = pv; btn.TextColor3 = WHITE; return end local isGp = isGamepadInput(inp) if isGp and tick()-listenStart < 0.15 then return end if not isBindableInput(inp) then return end if mode == "gp" and not isGp then return end if mode == "kb" and isGp then return end btn.Text = inp.KeyCode.Name; pv = inp.KeyCode.Name; btn.TextColor3 = WHITE li = false; _anyKeyListening = false; if lc then lc:Disconnect(); lc = nil end if mode == "gp" then kbEntry.gp = inp.KeyCode else kbEntry.kb = inp.KeyCode end end) end) btn.MouseButton2Click:Connect(function() if mode == "gp" then kbEntry.gp = nil else kbEntry.kb = nil end btn.Text = "None" pv = "None" end) table.insert(keyButtonRefs, {btn = btn, entry = kbEntry, mode = mode}) return btn end local function addKeybindRow(page, labelText, kbEntry, mode) local row = mkRow(page, 36) mkLabel(row, labelText) mkKeyButton(row, kbEntry, mode) end local momentPage = contentPages["Speed"] mkSect(momentPage, "Speed") do local row = mkRow(momentPage, 38); mkLabel(row, "Normal Speed"); normalBox = mkBox(row, NS, 50, 56, function(v) if v > 0 and v <= 500 then NS = v end end) end do local row = mkRow(momentPage, 38); mkLabel(row, "Carry Speed"); carryBox = mkBox(row, CS, 50, 56, function(v) if v > 0 and v <= 500 then CS = v end end) end do local row = mkRow(momentPage, 38); mkLabel(row, "Lagger 1 Speed"); laggerBox = mkBox(row, LAGGER_SPEED_1, 50, 56, function(v) if v > 0 and v <= 500 then LAGGER_SPEED_1 = v end end) end do local row = mkRow(momentPage, 38); mkLabel(row, "Lagger 2 Speed"); lagger2Box = mkBox(row, LAGGER_SPEED_2, 50, 56, function(v) if v > 0 and v <= 500 then LAGGER_SPEED_2 = v end end) end do local row = mkRow(momentPage, 38) mkLabel(row, "Current Mode") modeValLbl = Instance.new("TextLabel", row) modeValLbl.Size = UDim2.new(0, 110, 1, 0) modeValLbl.Position = UDim2.new(1, -118, 0, 0) modeValLbl.BackgroundTransparency = 1 modeValLbl.Text = "Normal" modeValLbl.TextColor3 = WHITE modeValLbl.Font = Enum.Font.GothamBlack modeValLbl.TextSize = 11 modeValLbl.TextXAlignment = Enum.TextXAlignment.Right modeValLbl.ZIndex = 8 local clk = Instance.new("TextButton", row) clk.Size = UDim2.new(1,0,1,0) clk.BackgroundTransparency = 1 clk.Text = "" clk.AutoButtonColor = false clk.ZIndex = 8 clk.MouseButton1Click:Connect(function() toggleCarryMode() end) end setUnwalkVisual = mkToggle(momentPage, "Unwalk", function(on) unwalkEnabled = on if on then startUnwalk() else stopUnwalk() end end) local miscPage = contentPages["Misc"] mkSect(miscPage, "Drop") dropBrainrotSetVisual = mkToggle(miscPage, "Drop Brainrot", function(on) if on then executeDropWithToggle(function(v) dropBrainrotSetVisual(v) if mobSetDropBR then mobSetDropBR(v) end end) end end) setDropVisual = dropBrainrotSetVisual do local row = mkRow(miscPage, 38) mkLabel(row, "Drop Mode") dropModeBtnRef = mkSelector(row, dropMode == 1 and "Fling" or "Jump Drop", {"Fling", "Jump Drop"}, function(dir, update) if dropActive then stopDropBrainrot() end dropMode = dropMode == 1 and 2 or 1 update(dropMode == 1 and "Fling" or "Jump Drop")  end) end do local row = mkRow(miscPage, 38) mkLabel(row, "Anti Bat") local clk = Instance.new("TextButton", row) clk.Size = UDim2.new(1, 0, 1, 0) clk.BackgroundTransparency = 1 clk.Text = "" clk.AutoButtonColor = false clk.ZIndex = 8 clk.MouseButton1Click:Connect(function() if AstaToggleAntiBatPanel then AstaToggleAntiBatPanel() end end) local actLbl = Instance.new("TextLabel", row) actLbl.Size = UDim2.new(0, 70, 1, 0) actLbl.Position = UDim2.new(1, -78, 0, 0) actLbl.BackgroundTransparency = 1 actLbl.Text = "OPEN" actLbl.TextColor3 = SILVER actLbl.Font = Enum.Font.GothamBold actLbl.TextSize = 9 actLbl.TextXAlignment = Enum.TextXAlignment.Right actLbl.ZIndex = 8 end do local row = mkRow(miscPage, 38) mkLabel(row, "Anti Anti Desync") local clk = Instance.new("TextButton", row) clk.Size = UDim2.new(1, 0, 1, 0) clk.BackgroundTransparency = 1 clk.Text = "" clk.AutoButtonColor = false clk.ZIndex = 8 clk.MouseButton1Click:Connect(function() if AstaToggleAntiDesyncPanel then AstaToggleAntiDesyncPanel() end end) local actLbl = Instance.new("TextLabel", row) actLbl.Size = UDim2.new(0, 70, 1, 0) actLbl.Position = UDim2.new(1, -78, 0, 0) actLbl.BackgroundTransparency = 1 actLbl.Text = "OPEN" actLbl.TextColor3 = SILVER actLbl.Font = Enum.Font.GothamBold actLbl.TextSize = 9 actLbl.TextXAlignment = Enum.TextXAlignment.Right actLbl.ZIndex = 8 end mkSect(momentPage, "Auto Movement") autoLeftSetVisual = mkToggle(momentPage, "Auto Left", function(on) autoLeftEnabled = on if on then startAutoLeft() else stopAutoLeft() end if mobSetAutoLeft then mobSetAutoLeft(on) end end) autoRightSetVisual = mkToggle(momentPage, "Auto Right", function(on) autoRightEnabled = on if on then startAutoRight() else stopAutoRight() end if mobSetAutoRight then mobSetAutoRight(on) end end) mkSect(momentPage, "TP & Reset") do local row = mkRow(momentPage, 38) mkLabel(row, "TP Down") local clk = Instance.new("TextButton", row) clk.Size = UDim2.new(0.58, 0, 1, 0) clk.BackgroundTransparency = 1 clk.Text = "" clk.AutoButtonColor = false clk.ZIndex = 8 clk.MouseButton1Click:Connect(function() doTpDown() end) local actLbl = Instance.new("TextLabel", row) actLbl.Size = UDim2.new(0, 70, 1, 0) actLbl.Position = UDim2.new(1, -78, 0, 0) actLbl.BackgroundTransparency = 1 actLbl.Text = "ACTIVATE" actLbl.TextColor3 = SILVER actLbl.Font = Enum.Font.GothamBold actLbl.TextSize = 9 actLbl.TextXAlignment = Enum.TextXAlignment.Right actLbl.ZIndex = 8 end setInstaResetVisual = mkToggle(momentPage, "Insta Reset", function(on) if on then instaReset() if instaResetFloatingButton and instaResetFloatingButton:FindFirstChild("Frame") then local btnFrame = instaResetFloatingButton:FindFirstChild("Frame") local label = btnFrame and btnFrame:FindFirstChild("TextLabel") if btnFrame then btnFrame.BackgroundColor3 = SILVER if label then label.TextColor3 = Color3.fromRGB(0,0,0) end task.delay(0.1, function() if btnFrame then btnFrame.BackgroundColor3 = Color3.fromRGB(0,0,0) if label then label.TextColor3 = Color3.fromRGB(255,255,255) end end end) end end task.delay(0.3, function() if setInstaResetVisual then setInstaResetVisual(false) end end) end end) local combatPage = contentPages["Combat"] mkSect(combatPage, "Aimbots") autoBatSetVisual = mkToggle(combatPage, "Auto Bat", function(on) if on then enableAutoBat() else disableAutoBat() end if mobSetAutoBat then mobSetAutoBat(on) end end) do local row = mkRow(combatPage, 38); mkLabel(row, "Bat Aimbot Speed"); batSpeedBox = mkBox(row, BAT_AIMBOT_SPEED, 50, 56, function(v) if v > 0 and v <= 200 then BAT_AIMBOT_SPEED = v end end) end autoBatV2SetVisual = mkToggle(combatPage, "Bat V2", function(on) if on then enableBatV2() else disableBatV2() end end) if autoBatV2SetVisual then autoBatV2SetVisual(autoBatV2Enabled) end mkSect(combatPage, "Counters") setBatCounterVisual = mkToggle(combatPage, "Bat Counter", function(on) batCounterEnabled = on if on then startBatCounter() else stopBatCounter() end end) setMedusaVisual = mkToggle(combatPage, "Medusa Counter", function(on) setMedusaCounterState(on) end) setMedusaAutoResetVisual = mkToggle(combatPage, "Medusa Auto Reset", function(on) setMedusaAutoResetState(on) end) mkSect(combatPage, "Defense") setAntiRagVisual = mkToggle(combatPage, "Anti Ragdoll", function(on) setAntiRag(on) end) mkSect(combatPage, "Movement")
setJumpVisual = mkToggle(combatPage, "Infinite Jump", function(on)
    InfJumpState.enabled = on
end)
if setJumpVisual then setJumpVisual(InfJumpState.enabled) end
do
    local row = mkRow(combatPage, 38)
    mkLabel(row, "Jump Mode")
    mkSelector(row, InfJumpState.mode == "hold" and "Hold" or "Manual", {"Hold", "Manual"}, function(val, update)
        InfJumpState.mode = (val == "Hold") and "hold" or "manual"
        update(val)
    end)
end
local mainPage = contentPages["Main"] local miscPage = contentPages["Misc"] mkSect(miscPage, "Auto Steal")
setInstaGrab = mkToggle(miscPage, "Auto Steal", function(on)
    CONFIG.AUTO_STEAL_ENABLED = on
    if on then pcall(startAutoSteal) else stopAutoSteal() end
    updateProgressBarVisibility() requestSave()
end)
do
    local modeRow = mkRow(miscPage, 38) mkLabel(modeRow, "Steal Mode")
    local function mkModeBtn(txt2, xoff)
        local b = Instance.new("TextButton", modeRow)
        b.Size = UDim2.new(0, 46, 0, 24)
        b.Position = UDim2.new(1, -xoff, 0.5, -12)
        b.BackgroundColor3 = INP
        b.BackgroundTransparency = 0.5
        b.BorderSizePixel = 0
        b.Text = txt2
        b.TextColor3 = WHITE
        b.Font = Enum.Font.GothamBold
        b.TextSize = 10
        b.AutoButtonColor = false
        b.ZIndex = 8
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        local st = Instance.new("UIStroke", b) st.Color = ROW_BORDER st.Thickness = 1.2 st.Transparency = 0.25
        return b, st
    end
    local normBtn, normStroke = mkModeBtn("Norm", 104)
    local semiBtn, semiStroke = mkModeBtn("Semi", 54)

    local grabRow = mkRow(miscPage, 38) mkLabel(grabRow, "Grab Radius")
    grabRadiusBox = mkBox(grabRow, CONFIG.GRAB_RADIUS, 50, 56, function(v)
        if v and v >= 5 and v <= 500 then CONFIG.GRAB_RADIUS = math.floor(v+0.5) grabRadiusBox.Text = tostring(CONFIG.GRAB_RADIUS) requestSave() end
    end)
    local primeRow = mkRow(miscPage, 38) mkLabel(primeRow, "Prime Steal Range")
    primeRangeBox = mkBox(primeRow, CONFIG.PRIME_RANGE, 50, 56, function(v)
        if v and v >= 5 and v <= 500 then CONFIG.PRIME_RANGE = math.floor(v+0.5) primeRangeBox.Text = tostring(CONFIG.PRIME_RANGE) requestSave() end
    end)
    local rangeRow = mkRow(miscPage, 38) mkLabel(rangeRow, "Steal Range")
    radInput = mkBox(rangeRow, CONFIG.STEAL_RANGE, 50, 56, function(v)
        if v and v >= 1 and v <= 300 then CONFIG.STEAL_RANGE = math.floor(v+0.5) radInput.Text = tostring(CONFIG.STEAL_RANGE) requestSave() end
    end)

    updateStealModeButtons = function()
        local isNorm = CONFIG.STEAL_MODE ~= "semi"
        normBtn.BackgroundColor3 = isNorm and SILVER or INP
        normBtn.TextColor3 = isNorm and Color3.fromRGB(20,20,20) or WHITE
        normStroke.Color = isNorm and SILVER or ROW_BORDER
        semiBtn.BackgroundColor3 = (not isNorm) and SILVER or INP
        semiBtn.TextColor3 = (not isNorm) and Color3.fromRGB(20,20,20) or WHITE
        semiStroke.Color = (not isNorm) and SILVER or ROW_BORDER
        grabRow.Visible = isNorm
        primeRow.Visible = not isNorm
        rangeRow.Visible = not isNorm
    end
    normBtn.MouseButton1Click:Connect(function() setStealMode("normal") updateStealModeButtons() requestSave() end)
    semiBtn.MouseButton1Click:Connect(function() setStealMode("semi") updateStealModeButtons() requestSave() end)
    updateStealModeButtons()
end


mkSect(miscPage, "Defense") setAntiDieVisual = mkToggle(miscPage, "Anti Die", function(on) if on then startAntiDie() else stopAntiDie() end end) mkSect(mainPage, "Interface") setEditModeVisual = mkToggle(mainPage, "Edit Button", function(on) toggleEditMode(on) if on and uiLocked then editModeEnabled = false setEditModeVisual(false) end end) if setEditModeVisual then setEditModeVisual(editModeEnabled) end setLockUIVisual = mkToggle(mainPage, "Lock UI", function(on) toggleLockUI(on) if on and editModeEnabled then editModeEnabled = false if setEditModeVisual then setEditModeVisual(false) end end end) do local row = mkRow(mainPage, 38) mkLabel(row, "UI Scale") uiScaleBox = mkBox(row, uiScaleValue, 50, 56, function(v) local n = math.clamp(math.floor(v+0.5), 50, 150) uiScaleValue = n if mainUIScale then mainUIScale.Scale = n/100 end if pbScale then pbScale.Scale = n/100 end end) end do local row = mkRow(mainPage, 38) mkLabel(row, "Botões Scale") btnScaleBox = mkBox(row, btnScaleValue, 50, 56, function(v) local n = math.clamp(math.floor(v+0.5), 50, 250) btnScaleValue = n applyButtonScale() end) end local visualPage = contentPages["Visual"] mkSect(visualPage, "Visual") do local row = mkRow(visualPage, 38) mkLabel(row, "Fundos (BG)") local clk = Instance.new("TextButton", row) clk.Size = UDim2.new(1, 0, 1, 0) clk.BackgroundTransparency = 1 clk.Text = "" clk.AutoButtonColor = false clk.ZIndex = 8 clk.MouseButton1Click:Connect(function() if _G.AstaToggleBgPicker then _G.AstaToggleBgPicker() end end) local actLbl = Instance.new("TextLabel", row) actLbl.Size = UDim2.new(0, 70, 1, 0) actLbl.Position = UDim2.new(1, -78, 0, 0) actLbl.BackgroundTransparency = 1 actLbl.Text = "OPEN" actLbl.TextColor3 = SILVER actLbl.Font = Enum.Font.GothamBold actLbl.TextSize = 9 actLbl.TextXAlignment = Enum.TextXAlignment.Right actLbl.ZIndex = 8 end do local row = mkRow(visualPage, 38) mkLabel(row, "Clima") local idx = 1 for i, n in ipairs(SKY_PRESETS_LIST) do if n == skyTheme then idx = i break end end skyValueLabel = mkSelector(row, SKY_PRESETS_LIST[idx], SKY_PRESETS_LIST, function(dir, updateLabel) idx = idx + dir if idx < 1 then idx = #SKY_PRESETS_LIST end if idx > #SKY_PRESETS_LIST then idx = 1 end skyTheme = SKY_PRESETS_LIST[idx] pcall(function() applyCustomSky(skyTheme) end) updateLabel(skyTheme) if requestSave then requestSave() end end) end setKorbloxVisual = mkToggle(visualPage, "Korblox", function(on) toggleKorblox(on) end) if setKorbloxVisual then setKorbloxVisual(korbloxEnabled) end do local row = mkRow(visualPage, 38) mkLabel(row, "Anim Pack") local currentIndex = 1 for i, entry in ipairs(ANIM_PACK_ORDER) do if entry[2] == currentAnimPack then currentIndex = i; break end end local container = Instance.new("Frame", row) container.Size = UDim2.new(0, 160, 1, 0) container.Position = UDim2.new(1, -168, 0, 0) container.BackgroundTransparency = 1 container.ZIndex = 8 local leftBtn = Instance.new("TextButton", container) leftBtn.Size = UDim2.new(0, 28, 0, 26) leftBtn.Position = UDim2.new(0, 0, 0.5, -13) leftBtn.BackgroundColor3 = INP leftBtn.BackgroundTransparency = 0.7 leftBtn.BorderSizePixel = 0 leftBtn.Text = "<" leftBtn.TextColor3 = WHITE leftBtn.Font = Enum.Font.GothamBold leftBtn.TextSize = 13 leftBtn.AutoButtonColor = false leftBtn.ZIndex = 9 Instance.new("UICorner", leftBtn).CornerRadius = UDim.new(0, 6) local leftStroke = Instance.new("UIStroke", leftBtn) leftStroke.Color = ROW_BORDER leftStroke.Thickness = 1 animSelectorLabel = Instance.new("TextLabel", container) animSelectorLabel.Size = UDim2.new(0, 80, 0, 26) animSelectorLabel.Position = UDim2.new(0.5, -40, 0.5, -13) animSelectorLabel.BackgroundTransparency = 1 animSelectorLabel.Text = ANIM_PACK_ORDER[currentIndex][2] animSelectorLabel.TextColor3 = WHITE animSelectorLabel.Font = Enum.Font.GothamBold animSelectorLabel.TextSize = 12 animSelectorLabel.TextXAlignment = Enum.TextXAlignment.Center animSelectorLabel.ZIndex = 9 local rightBtn = Instance.new("TextButton", container) rightBtn.Size = UDim2.new(0, 28, 0, 26) rightBtn.Position = UDim2.new(1, -28, 0.5, -13) rightBtn.BackgroundColor3 = INP rightBtn.BackgroundTransparency = 0.7 rightBtn.BorderSizePixel = 0 rightBtn.Text = ">" rightBtn.TextColor3 = WHITE rightBtn.Font = Enum.Font.GothamBold rightBtn.TextSize = 13 rightBtn.AutoButtonColor = false rightBtn.ZIndex = 9 Instance.new("UICorner", rightBtn).CornerRadius = UDim.new(0, 6) local rightStroke = Instance.new("UIStroke", rightBtn) rightStroke.Color = ROW_BORDER rightStroke.Thickness = 1 local function updateAnimSelector(direction) local idx = 1 for i, entry in ipairs(ANIM_PACK_ORDER) do if entry[2] == currentAnimPack then idx = i; break end end local newIdx = idx + direction if newIdx < 1 then newIdx = #ANIM_PACK_ORDER end if newIdx > #ANIM_PACK_ORDER then newIdx = 1 end local packName = ANIM_PACK_ORDER[newIdx][2] if packName == "Off" then stopAnimPack() else startAnimPack(packName) end end leftBtn.MouseButton1Click:Connect(function() updateAnimSelector(-1) end) rightBtn.MouseButton1Click:Connect(function() updateAnimSelector(1) end) end  mkSect(mainPage, "Personalización") setESPVIsual = mkToggle(mainPage, "Player ESP", function(on) toggleESP(on) end) do local row = mkRow(mainPage, 38) mkLabel(row, "Stretch Rez") local expandBtn = Instance.new("TextButton", row) expandBtn.Size = UDim2.new(0, 28, 0, 22) expandBtn.Position = UDim2.new(0.58, 0, 0.5, -11) expandBtn.BackgroundColor3 = INP expandBtn.BackgroundTransparency = 0.7 expandBtn.BorderSizePixel = 0 expandBtn.Text = "▶" expandBtn.TextColor3 = WHITE expandBtn.Font = Enum.Font.GothamBold expandBtn.TextSize = 14 expandBtn.AutoButtonColor = false expandBtn.ZIndex = 9 Instance.new("UICorner", expandBtn).CornerRadius = UDim.new(0, 6) local expandStroke = Instance.new("UIStroke", expandBtn) expandStroke.Color = ROW_BORDER expandStroke.Thickness = 1 local stretchPill, stretchDot = mkPill(row, 52) local stretchOn = false local function setStretch(s) stretchOn = s animPill(stretchPill, stretchDot, s) if s then enableStretch() else disableStretch() end stretchEnabled = s end local stretchClk = Instance.new("TextButton", stretchPill) stretchClk.Size = UDim2.new(1,0,1,0) stretchClk.BackgroundTransparency = 1 stretchClk.Text = "" stretchClk.AutoButtonColor = false stretchClk.ZIndex = 10 stretchClk.MouseButton1Click:Connect(function() setStretch(not stretchOn) end) _G.stretchToggleSetter = setStretch fovContainer = Instance.new("Frame", mainPage) fovContainer.Size = UDim2.new(1, -4, 0, 38) fovContainer.BackgroundColor3 = ROW_BG fovContainer.BackgroundTransparency = 0.7 fovContainer.BorderSizePixel = 0 fovContainer.LayoutOrder = getNextOrder(mainPage) fovContainer.ZIndex = 7 fovContainer.Visible = false Instance.new("UICorner", fovContainer).CornerRadius = UDim.new(0, 10) local fovStroke = Instance.new("UIStroke", fovContainer) fovStroke.Color = ROW_BORDER fovStroke.Thickness = 1 fovStroke.Transparency = 0.5 local fovLabel = Instance.new("TextLabel", fovContainer) fovLabel.Size = UDim2.new(0.25, 0, 1, 0) fovLabel.Position = UDim2.new(0, 10, 0, 0) fovLabel.BackgroundTransparency = 1 fovLabel.Text = "FOV" fovLabel.TextColor3 = WHITE fovLabel.Font = Enum.Font.GothamBold fovLabel.TextSize = 11 fovLabel.TextXAlignment = Enum.TextXAlignment.Left fovLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0) fovLabel.TextStrokeTransparency = 0.5 fovLabel.ZIndex = 8 local fovBtnFrame = Instance.new("Frame", fovContainer) fovBtnFrame.Size = UDim2.new(0, 150, 1, 0) fovBtnFrame.Position = UDim2.new(1, -162, 0, 0) fovBtnFrame.BackgroundTransparency = 1 fovBtnFrame.ZIndex = 8 local function makeFOVBtn(val, x) local btn = Instance.new("TextButton", fovBtnFrame) btn.Size = UDim2.new(0, 42, 0, 26) btn.Position = UDim2.new(0, x, 0.5, -13) btn.BackgroundColor3 = INP btn.BackgroundTransparency = 0.7 btn.BorderSizePixel = 0 btn.Text = tostring(val) btn.TextColor3 = WHITE btn.Font = Enum.Font.GothamBold btn.TextSize = 11 btn.AutoButtonColor = false btn.ZIndex = 9 Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6) local stroke = Instance.new("UIStroke", btn) stroke.Color = ROW_BORDER stroke.Thickness = 1 if val == stretchFOV then btn.BackgroundColor3 = SILVER btn.TextColor3 = Color3.fromRGB(0,0,0) end btn.MouseButton1Click:Connect(function() stretchFOV = val if stretchEnabled then applyStretchFOV(val) end for _, b in ipairs(fovBtnFrame:GetChildren()) do if b:IsA("TextButton") then local v = tonumber(b.Text) if v == val then b.BackgroundColor3 = SILVER b.TextColor3 = Color3.fromRGB(0,0,0) else b.BackgroundColor3 = INP b.TextColor3 = WHITE end end end end) return btn end makeFOVBtn(90, 0) makeFOVBtn(120, 54) makeFOVBtn(180, 108) _G.fovButtons = fovBtnFrame:GetChildren() local function toggleFov() fovContainer.Visible = not fovContainer.Visible expandBtn.Text = fovContainer.Visible and "▼" or "▶" end expandBtn.MouseButton1Click:Connect(toggleFov) fovToggleBtn = expandBtn end setAntiLagVisual = mkToggle(mainPage, "Anti Lag", function(on) if on then enableAntiLag() else disableAntiLag() end end) mkSect(miscPage, "Config") do local row = mkRow(miscPage, 44) row.Size = UDim2.new(1, 0, 0, 44) local saveBtn = Instance.new("TextButton", row) saveBtn.Size = UDim2.new(1, -12, 0.8, 0) saveBtn.Position = UDim2.new(0, 6, 0.1, 0) saveBtn.BackgroundColor3 = Color3.fromRGB(30,30,35) saveBtn.BackgroundTransparency = 0.5 saveBtn.BorderSizePixel = 0 saveBtn.Text = "SAVE CONFIG" saveBtn.TextColor3 = WHITE saveBtn.Font = Enum.Font.GothamBold saveBtn.TextSize = 13 saveBtn.TextStrokeColor3 = Color3.fromRGB(60,60,60) saveBtn.TextStrokeTransparency = 0 saveBtn.AutoButtonColor = false saveBtn.ZIndex = 8 Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8) local saveStroke = Instance.new("UIStroke", saveBtn) saveStroke.Color = ROW_BORDER saveStroke.Thickness = 1.2 saveStroke.Transparency = 0.5 saveBtn.MouseButton1Click:Connect(function() local ok = saveAllSettings() saveBtn.Text = ok and "SAVED ✓" or "ERROR" task.delay(1.2, function() if saveBtn and saveBtn.Parent then saveBtn.Text = "SAVE CONFIG" end end) end) end do local row = mkRow(miscPage, 44) row.Size = UDim2.new(1, 0, 0, 44) local resetPosBtn = Instance.new("TextButton", row) resetPosBtn.Size = UDim2.new(1, -12, 0.8, 0) resetPosBtn.Position = UDim2.new(0, 6, 0.1, 0) resetPosBtn.BackgroundColor3 = Color3.fromRGB(30,30,35) resetPosBtn.BackgroundTransparency = 0.5 resetPosBtn.BorderSizePixel = 0 resetPosBtn.Text = "RESET POSITIONS" resetPosBtn.TextColor3 = WHITE resetPosBtn.Font = Enum.Font.GothamBold resetPosBtn.TextSize = 13 resetPosBtn.TextStrokeColor3 = Color3.fromRGB(60,60,60) resetPosBtn.TextStrokeTransparency = 0 resetPosBtn.AutoButtonColor = false resetPosBtn.ZIndex = 8 Instance.new("UICorner", resetPosBtn).CornerRadius = UDim.new(0, 8) local resetStroke = Instance.new("UIStroke", resetPosBtn) resetStroke.Color = ROW_BORDER resetStroke.Thickness = 1.2 resetStroke.Transparency = 0.5 local resetDebounce = false resetPosBtn.MouseButton1Click:Connect(function() if resetDebounce then return end resetDebounce = true resetFloatingPositions() resetPosBtn.Text = "RESET ✓" task.delay(1.2, function() if resetPosBtn and resetPosBtn.Parent then resetPosBtn.Text = "RESET POSITIONS" resetDebounce = false end end) end) end do local row = mkRow(miscPage, 44) row.Size = UDim2.new(1, 0, 0, 44) local delBtn = Instance.new("TextButton", row) delBtn.Size = UDim2.new(1, -12, 0.8, 0) delBtn.Position = UDim2.new(0, 6, 0.1, 0) delBtn.BackgroundColor3 = Color3.fromRGB(140, 25, 65) delBtn.BackgroundTransparency = 0.5 delBtn.BorderSizePixel = 0 delBtn.Text = "DELETE SETTINGS" delBtn.TextColor3 = WHITE delBtn.Font = Enum.Font.GothamBold delBtn.TextSize = 13 delBtn.TextStrokeColor3 = Color3.fromRGB(60,60,60) delBtn.TextStrokeTransparency = 0 delBtn.AutoButtonColor = false delBtn.ZIndex = 8 Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 8) local delStroke = Instance.new("UIStroke", delBtn) delStroke.Color = ROW_BORDER delStroke.Thickness = 1.2 delStroke.Transparency = 0.5 local deleteState = 0 local originalDeleteText = "DELETE SETTINGS" local delDebounce = false delBtn.MouseButton1Click:Connect(function() if delDebounce then return end if deleteState == 0 then deleteState = 1 delBtn.Text = "CONFIRM?" delBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 80) task.delay(2, function() if delBtn and delBtn.Parent and deleteState == 1 then deleteState = 0 delBtn.Text = originalDeleteText delBtn.BackgroundColor3 = Color3.fromRGB(140, 25, 65) end end) elseif deleteState == 1 then delDebounce = true local success = pcall(resetToFactoryDefaults) delBtn.Text = success and "DELETED ✓" or "ERROR" delBtn.BackgroundColor3 = Color3.fromRGB(140, 25, 65) deleteState = 0 task.delay(1.5, function() if delBtn and delBtn.Parent then delBtn.Text = originalDeleteText delBtn.BackgroundColor3 = Color3.fromRGB(140, 25, 65) delDebounce = false end end) end end) end local keyPage = contentPages["Keybinds"] mkSect(keyPage, "Teclado (PC)") addKeybindRow(keyPage, "Carry Mode", KB.CarryToggle, "kb") addKeybindRow(keyPage, "Lagger Mode", KB.LaggerMode, "kb") addKeybindRow(keyPage, "Auto Left", KB.AutoLeft, "kb") addKeybindRow(keyPage, "Auto Right", KB.AutoRight, "kb") addKeybindRow(keyPage, "Auto Bat", KB.AutoBat, "kb") addKeybindRow(keyPage, "Bat V2", KB.BatV2, "kb") addKeybindRow(keyPage, "TP Down", KB.TPFloor, "kb") addKeybindRow(keyPage, "Drop Brainrot", KB.DropBrainrot, "kb") addKeybindRow(keyPage, "Drop Mode", KB.DropMode, "kb") addKeybindRow(keyPage, "TP Bypass", KB.TPBypass, "kb") addKeybindRow(keyPage, "Anti Desync", KB.AntiDesync, "kb") addKeybindRow(keyPage, "Insta Reset", KB.InstaReset, "kb") addKeybindRow(keyPage, "Hide GUI", KB.GuiHide, "kb") mkSect(keyPage, "Controle (Gamepad)") addKeybindRow(keyPage, "Carry Mode", KB.CarryToggle, "gp") addKeybindRow(keyPage, "Lagger Mode", KB.LaggerMode, "gp") addKeybindRow(keyPage, "Auto Left", KB.AutoLeft, "gp") addKeybindRow(keyPage, "Auto Right", KB.AutoRight, "gp") addKeybindRow(keyPage, "Auto Bat", KB.AutoBat, "gp") addKeybindRow(keyPage, "Bat V2", KB.BatV2, "gp") addKeybindRow(keyPage, "TP Down", KB.TPFloor, "gp") addKeybindRow(keyPage, "Drop Brainrot", KB.DropBrainrot, "gp") addKeybindRow(keyPage, "Drop Mode", KB.DropMode, "gp") addKeybindRow(keyPage, "TP Bypass", KB.TPBypass, "gp") addKeybindRow(keyPage, "Anti Desync", KB.AntiDesync, "gp") addKeybindRow(keyPage, "Insta Reset", KB.InstaReset, "gp") addKeybindRow(keyPage, "Hide GUI", KB.GuiHide, "gp") do local row = mkRow(keyPage, 40) local clearBtn = Instance.new("TextButton", row) clearBtn.Size = UDim2.new(1, -12, 0.8, 0) clearBtn.Position = UDim2.new(0, 6, 0.1, 0) clearBtn.BackgroundColor3 = INP clearBtn.BackgroundTransparency = 0.5 clearBtn.BorderSizePixel = 0 clearBtn.Text = "LIMPAR CONTROLE" clearBtn.TextColor3 = WHITE clearBtn.Font = Enum.Font.GothamBold clearBtn.TextSize = 12 clearBtn.AutoButtonColor = false clearBtn.ZIndex = 8 Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 8) local cs = Instance.new("UIStroke", clearBtn) cs.Color = ROW_BORDER cs.Thickness = 1 cs.Transparency = 0.5 clearBtn.MouseButton1Click:Connect(function() for _, k in pairs(KB) do k.gp = nil end for _, ref in ipairs(keyButtonRefs) do if ref.mode == "gp" then ref.btn.Text = "None" end end if requestSave then pcall(requestSave) end clearBtn.Text = "LIMPO ✓" task.delay(1.2, function() if clearBtn and clearBtn.Parent then clearBtn.Text = "LIMPAR CONTROLE" end end) end) end local spacer = Instance.new("Frame", keyPage) spacer.Size = UDim2.new(1, 0, 0, 16) spacer.BackgroundTransparency = 1 spacer.LayoutOrder = getNextOrder(keyPage) spacer.ZIndex = 7 local profileContainer = Instance.new("Frame", main) profileContainer.Size = UDim2.new(0, 70, 0, 85) profileContainer.Position = UDim2.new(0, 12, 1, -95) profileContainer.BackgroundTransparency = 1 profileContainer.ZIndex = 30 local profileImage = Instance.new("ImageLabel", profileContainer) profileImage.Size = UDim2.new(0, 56, 0, 56) profileImage.Position = UDim2.new(0.5, -28, 0, 0) profileImage.BackgroundColor3 = Color3.fromRGB(0,0,0) profileImage.BackgroundTransparency = 0.2 profileImage.BorderSizePixel = 0 profileImage.Image = "rbxassetid://0" profileImage.ScaleType = Enum.ScaleType.Fit profileImage.ZIndex = 31 local circleCorner = Instance.new("UICorner", profileImage) circleCorner.CornerRadius = UDim.new(1, 0) local profileStroke = Instance.new("UIStroke", profileImage) profileStroke.Color = SILVER profileStroke.Thickness = 2 profileStroke.Transparency = 0 local onlineLabel = Instance.new("TextLabel", profileContainer) onlineLabel.Size = UDim2.new(1, 0, 0, 20) onlineLabel.Position = UDim2.new(0, 0, 0, 60) onlineLabel.BackgroundTransparency = 1 onlineLabel.Text = "Online" onlineLabel.TextColor3 = SILVER onlineLabel.Font = Enum.Font.GothamBold onlineLabel.TextSize = 12 onlineLabel.TextXAlignment = Enum.TextXAlignment.Center onlineLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0) onlineLabel.TextStrokeTransparency = 0.2 onlineLabel.ZIndex = 31 task.spawn(function() local userId = LP.UserId local url = profileImageCache[userId] if not url then local success, u = pcall(function() return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end) if success and u and u ~= "" then url = u profileImageCache[userId] = url else url = "rbxassetid://0" end end if profileImage then profileImage.Image = url end end) pbFrame = Instance.new("Frame", gui) pbFrame.Size = UDim2.new(0, 280, 0, 34) pbFrame.Position = UDim2.new(0.5, -140, 1, -50) pbFrame.BackgroundColor3 = BG pbFrame.BackgroundTransparency = 1 pbFrame.BorderSizePixel = 0 pbFrame.Active = true pbFrame.ClipsDescendants = true pbFrame.Visible = CONFIG.AUTO_STEAL_ENABLED pbFrame.ZIndex = 10 local pbBgImg = Instance.new("ImageLabel", pbFrame) pbBgImg.Name = "StealBarBg" pbBgImg.Size = UDim2.new(1, 0, 1, 0) pbBgImg.Position = UDim2.new(0, 0, 0, 0) pbBgImg.BackgroundTransparency = 1 pbBgImg.Image = "rbxassetid://79778461549482" pbBgImg.ScaleType = Enum.ScaleType.Crop pbBgImg.ZIndex = 9 Instance.new("UICorner", pbBgImg).CornerRadius = UDim.new(1, 0) pbScale = Instance.new("UIScale", pbFrame) pbScale.Scale = uiScaleValue / 100 if savedProgressBarPos then pbFrame.Position = UDim2.new( savedProgressBarPos.XScale or 0.5, savedProgressBarPos.XOffset or -140, savedProgressBarPos.YScale or 1, savedProgressBarPos.YOffset or -50 ) end Instance.new("UICorner", pbFrame).CornerRadius = UDim.new(1, 0) local pbSt = Instance.new("UIStroke", pbFrame) pbSt.Color = SILVER pbSt.Thickness = 2 pbSt.Transparency = 0.15 local fillRegion = Instance.new("Frame", pbFrame) fillRegion.Size = UDim2.new(0, 170, 1, -8) fillRegion.Position = UDim2.new(0, 4, 0, 4) fillRegion.BackgroundColor3 = Color3.fromRGB(20,20,25) fillRegion.BackgroundTransparency = 0.4 fillRegion.BorderSizePixel = 0 fillRegion.ClipsDescendants = true fillRegion.ZIndex = 11 Instance.new("UICorner", fillRegion).CornerRadius = UDim.new(1, 0) local fillRegStroke = Instance.new("UIStroke", fillRegion) fillRegStroke.Color = SILVER fillRegStroke.Thickness = 1.5 fillRegStroke.Transparency = 0.3 progressFill = Instance.new("Frame", fillRegion) progressFill.Size = UDim2.new(0, 0, 1, 0) progressFill.Position = UDim2.new(0, 0, 0, 0) progressFill.BackgroundColor3 = SILVER progressFill.BorderSizePixel = 0 progressFill.ZIndex = 12 Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0) local glow = Instance.new("Frame", progressFill) glow.Size = UDim2.new(1, 0, 1, 0) glow.Position = UDim2.new(0, 0, 0, 0) glow.BackgroundColor3 = Color3.fromRGB(255,255,255) glow.BackgroundTransparency = 0.85 glow.BorderSizePixel = 0 glow.ZIndex = 13 Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0) local stealLbl = Instance.new("TextLabel", fillRegion) stealLbl.Size = UDim2.new(0, 50, 1, 0) stealLbl.Position = UDim2.new(0, 8, 0, 0) stealLbl.BackgroundTransparency = 1 stealLbl.Text = "STEAL" stealLbl.TextColor3 = WHITE stealLbl.Font = Enum.Font.GothamBlack stealLbl.TextSize = 12 stealLbl.TextXAlignment = Enum.TextXAlignment.Left stealLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0) stealLbl.TextStrokeTransparency = 0.2 stealLbl.ZIndex = 14 progressPct = Instance.new("TextLabel", fillRegion) progressPct.Size = UDim2.new(0, 44, 1, 0) progressPct.Position = UDim2.new(1, -52, 0, 0) progressPct.BackgroundTransparency = 1 progressPct.Text = "0%" progressPct.TextColor3 = WHITE progressPct.Font = Enum.Font.GothamBold progressPct.TextSize = 10 progressPct.TextXAlignment = Enum.TextXAlignment.Right progressPct.TextStrokeColor3 = Color3.fromRGB(0,0,0) progressPct.TextStrokeTransparency = 0.2 progressPct.ZIndex = 14 local pbDiv = Instance.new("Frame", pbFrame) pbDiv.Size = UDim2.new(0, 1, 0, 14) pbDiv.Position = UDim2.new(0, 180, 0.5, -7) pbDiv.BackgroundColor3 = SILVER pbDiv.BackgroundTransparency = 0.4 pbDiv.BorderSizePixel = 0 pbDiv.ZIndex = 12 progressRadLbl = Instance.new("TextLabel", pbFrame) progressRadLbl.Size = UDim2.new(0, 92, 1, 0) progressRadLbl.Position = UDim2.new(0, 184, 0, 0) progressRadLbl.BackgroundTransparency = 1 progressRadLbl.Text = "--FPS · --ms" progressRadLbl.TextColor3 = Color3.fromRGB(200,200,200) progressRadLbl.Font = Enum.Font.GothamBold progressRadLbl.TextSize = 9 progressRadLbl.TextXAlignment = Enum.TextXAlignment.Center progressRadLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0) progressRadLbl.TextStrokeTransparency = 0.2 progressRadLbl.ZIndex = 14 drag(pbFrame) task.spawn(function() local lastPct = 0 while task.wait() do local targetPct = 0 if StealState.active then local elapsed = tick() - StealState.startTime local duration = StealState.duration or CONFIG.HOLD_MAX targetPct = math.clamp(elapsed / duration, 0, 1) elseif StealState.lastResultTime > 0 and (tick() - StealState.lastResultTime) < 1.2 then targetPct = 1 else targetPct = 0 end lastPct = lastPct + (targetPct - lastPct) * math.min(0.18 * 0.35 * 60, 1) local f = math.clamp(lastPct, 0, 1) if progressFill then progressFill.Size = UDim2.new(f, 0, 1, 0) end if progressPct then progressPct.Text = math.floor(f * 100) .. "%" end end end) task.spawn(function() local lastFrame = tick() local fpsSamples = {} local fpsAvg = 60 RunService.RenderStepped:Connect(function() local now = tick() local dt = now - lastFrame lastFrame = now if dt > 0 then table.insert(fpsSamples, 1 / dt) if #fpsSamples > 30 then table.remove(fpsSamples, 1) end local sum = 0 for _, v in ipairs(fpsSamples) do sum = sum + v end fpsAvg = sum / #fpsSamples end end) while true do local ping = 0 pcall(function() ping = LP:GetNetworkPing() * 1000 end) if progressRadLbl then progressRadLbl.Text = string.format("%dFPS · %dms", math.floor(fpsAvg + 0.5), math.floor(ping + 0.5)) end task.wait(0.5) end end) drag(main) end function createMobilePanel() local panel = Instance.new("ScreenGui") panel.Name = "AstaHubMobilePanel" panel.ResetOnSpawn = false panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling pcall(function() if syn and syn.protect_gui then syn.protect_gui(panel) end end) if not pcall(function() panel.Parent = game:GetService("CoreGui") end) then panel.Parent = LP:WaitForChild("PlayerGui") end local BTN_W, BTN_H = 60, 60 local GAP = 8 local COLUMNS = 2 local ROWS = 4 local PANEL_W = BTN_W * COLUMNS + GAP * (COLUMNS - 1) local PANEL_H = BTN_H * ROWS + (GAP + 10) * (ROWS - 1) local container = Instance.new("Frame", panel) container.Name = "FloatingPanel" container.Size = UDim2.new(0, PANEL_W, 0, PANEL_H) container.Position = UDim2.new(0, 10, 0, 0) container.BackgroundTransparency = 1 container.BorderSizePixel = 0 container.Active = false container.Selectable = false container.ClipsDescendants = false local btnContainer = Instance.new("Frame", container) btnContainer.Name = "ButtonsContainer" btnContainer.Size = UDim2.new(1, 0, 1, 0) btnContainer.BackgroundTransparency = 1 btnContainer.ClipsDescendants = false local SILVER = Color3.fromRGB(180, 180, 190) local WHITE = Color3.fromRGB(255, 255, 255) local INACTIVE_BG = Color3.fromRGB(10,10,10) local INACTIVE_TEXT = Color3.fromRGB(225,225,225) local STROKE_COLOR = Color3.fromRGB(70,70,70) local ACTIVE_BG = SILVER local ACTIVE_TEXT = WHITE local buttons = {} local buttonNames = {"DropBR", "AutoLeft", "AutoRight", "TpDown", "Carry", "Lagger1", "Lagger2"} local buttonTexts = {"DROP\nBR", "AUTO\nLEFT", "AUTO\nRIGHT", "TP\nDOWN", "CARRY\nSPD", "LAGGER\n1", "LAGGER\n2"} local function createButton(name, text, order, isToggle, callback) local btn = Instance.new("TextButton", panel) btn.Name = name btn.ZIndex = 50 btn.Size = UDim2.new(0, BTN_W, 0, BTN_H) btn.BackgroundColor3 = INACTIVE_BG btn.BorderSizePixel = 0 btn.Text = "" btn.AutoButtonColor = false btn.ZIndex = 10 local savedPos = savedButtonPositions[name] if savedPos then btn.Position = UDim2.new(0, savedPos.X or 0, 0, savedPos.Y or 0) else local defX, defY = getDefaultButtonPosition(name) btn.Position = UDim2.new(0, defX + 10, 0, defY) end Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 18) astaAttachFloatBg(btn, 18) local stroke = Instance.new("UIStroke", btn) stroke.Color = STROKE_COLOR stroke.Thickness = 1.2 stroke.Transparency = 0.4 stroke.Name = "NormalStroke" local label = Instance.new("TextLabel", btn) label.Size = UDim2.new(1, 0, 1, 0) label.BackgroundTransparency = 1 label.Text = text label.TextColor3 = INACTIVE_TEXT label.Font = Enum.Font.GothamBold label.TextSize = 10 label.TextWrapped = true label.ZIndex = 11 astaAttachFloatGlow(label) local active = false local function setActive(state) active = state if active then btn.BackgroundColor3 = INACTIVE_BG if name ~= "TpDown" then label.TextColor3 = Color3.fromRGB(0, 255, 120) stroke.Color = Color3.fromRGB(0, 255, 120) stroke.Thickness = 2.4 else label.TextColor3 = Color3.fromRGB(255,255,255) stroke.Color = SILVER stroke.Thickness = 1.2 end stroke.Transparency = 0 else btn.BackgroundColor3 = INACTIVE_BG label.TextColor3 = Color3.fromRGB(255,255,255) stroke.Color = STROKE_COLOR stroke.Thickness = 1.2 stroke.Transparency = 0.4 end end local dragging = false local hasMoved = false local dragStart = nil local startPos = nil local movedDistance = 0 local activeInput = nil
local function finishDrag()
    if not dragging then return end
    if movedDistance < 3 then
        if isToggle then if callback then callback(setActive) end
        else if callback then callback(setActive, active) end end
    elseif (not uiLocked) and hasMoved then
        savedButtonPositions[name] = { X = btn.Position.X.Offset, Y = btn.Position.Y.Offset }
        if requestSave then pcall(requestSave) end
    end
    dragging = false hasMoved = false dragStart = nil startPos = nil movedDistance = 0 activeInput = nil
    _isDraggingButton = false
end
local function onInputBegan(input)
    if dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true hasMoved = false movedDistance = 0
        dragStart = input.Position startPos = btn.Position activeInput = input
        _isDraggingButton = true
    end
end
local function onInputChanged(input)
    if not dragging or not dragStart then return end
    if activeInput and input ~= activeInput and input.UserInputType == Enum.UserInputType.Touch then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        movedDistance = delta.Magnitude
        if (not uiLocked) and movedDistance >= 3 then
            hasMoved = true
            btn.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
        end
    end
end
local function onInputEnded(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if activeInput and input ~= activeInput and input.UserInputType == Enum.UserInputType.Touch then return end
        finishDrag()
    end
end
UIS.InputChanged:Connect(onInputChanged)
UIS.InputEnded:Connect(onInputEnded)
btn.InputBegan:Connect(onInputBegan) btn.InputChanged:Connect(onInputChanged) btn.InputEnded:Connect(onInputEnded) buttons[name] = {btn = btn, setActive = setActive, label = label} return setActive end for i, name in ipairs(buttonNames) do local text = buttonTexts[i] local callback if name == "DropBR" then callback = function(setActive) if autoBatEnabled then return end setActive(true) executeDropWithToggle(function(v) if dropBrainrotSetVisual then dropBrainrotSetVisual(v) end end) task.delay(0.3, function() setActive(false) end) end elseif name == "AutoLeft" then callback = function(setActive) autoLeftEnabled = not autoLeftEnabled setActive(autoLeftEnabled) if autoLeftEnabled then startAutoLeft() else stopAutoLeft() end if autoLeftSetVisual then autoLeftSetVisual(autoLeftEnabled) end end elseif name == "AutoRight" then callback = function(setActive) autoRightEnabled = not autoRightEnabled setActive(autoRightEnabled) if autoRightEnabled then startAutoRight() else stopAutoRight() end if autoRightSetVisual then autoRightSetVisual(autoRightEnabled) end end elseif name == "TpDown" then callback = function(setActive) doTpDown() setActive(true) task.delay(0.2, function() setActive(false) end) end elseif name == "Carry" then callback = function(setActive) if not speedMode then speedMode = true; laggerToggled = false; laggerLevel = 1; setActive(true) if buttons.Lagger1 and buttons.Lagger1.setActive then buttons.Lagger1.setActive(false) end if buttons.Lagger2 and buttons.Lagger2.setActive then buttons.Lagger2.setActive(false) end else speedMode = false; setActive(false) end refreshSpeedModeLabel() end elseif name == "Lagger1" then callback = function(setActive) if speedMode then speedMode = false; if mobSetCarry then mobSetCarry(false) end end if not laggerToggled or laggerLevel ~= 1 then laggerToggled = true; laggerLevel = 1; setActive(true) if buttons.Lagger2 and buttons.Lagger2.setActive then buttons.Lagger2.setActive(false) end else laggerToggled = false; laggerLevel = 1; setActive(false) end refreshSpeedModeLabel() end elseif name == "Lagger2" then callback = function(setActive) if speedMode then speedMode = false; if mobSetCarry then mobSetCarry(false) end end if not laggerToggled or laggerLevel ~= 2 then laggerToggled = true; laggerLevel = 2; setActive(true) if buttons.Lagger1 and buttons.Lagger1.setActive then buttons.Lagger1.setActive(false) end else laggerToggled = false; laggerLevel = 1; setActive(false) end refreshSpeedModeLabel() end end mobSetAutoBat = buttons.AutoBat and buttons.AutoBat.setActive mobSetAutoLeft = buttons.AutoLeft and buttons.AutoLeft.setActive mobSetAutoRight = buttons.AutoRight and buttons.AutoRight.setActive mobSetDropBR = buttons.DropBR and buttons.DropBR.setActive mobSetTpDown = buttons.TpDown and buttons.TpDown.setActive mobSetCarry = buttons.Carry and buttons.Carry.setActive mobSetLagger1 = buttons.Lagger1 and buttons.Lagger1.setActive mobSetLagger2 = buttons.Lagger2 and buttons.Lagger2.setActive local setActive = createButton(name, text, i-1, true, callback) if name == "AutoBat" then mobSetAutoBat = setActive end if name == "AutoLeft" then mobSetAutoLeft = setActive end if name == "AutoRight" then mobSetAutoRight = setActive end if name == "DropBR" then mobSetDropBR = setActive end if name == "TpDown" then mobSetTpDown = setActive end if name == "Carry" then mobSetCarry = setActive end if name == "Lagger1" then mobSetLagger1 = setActive end if name == "Lagger2" then mobSetLagger2 = setActive end end if buttons.AutoBat and buttons.AutoBat.setActive then buttons.AutoBat.setActive(autoBatEnabled) end if buttons.AutoLeft and buttons.AutoLeft.setActive then buttons.AutoLeft.setActive(autoLeftEnabled) end if buttons.AutoRight and buttons.AutoRight.setActive then buttons.AutoRight.setActive(autoRightEnabled) end if buttons.Carry and buttons.Carry.setActive then buttons.Carry.setActive(speedMode) end if buttons.Lagger1 and buttons.Lagger1.setActive then buttons.Lagger1.setActive(laggerToggled and laggerLevel == 1) end if buttons.Lagger2 and buttons.Lagger2.setActive then buttons.Lagger2.setActive(laggerToggled and laggerLevel == 2) end if savedMobilePanelPos then container.Position = UDim2.new( savedMobilePanelPos.XScale or 0, savedMobilePanelPos.XOffset or 10, savedMobilePanelPos.YScale or 0, savedMobilePanelPos.YOffset or 0 ) end local draggingPanel = false local dragStartPos = nil local dragStartMousePos = nil local function startDragPanel(input) do return end if uiLocked or _isDraggingButton or editModeEnabled then return end if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingPanel = true dragStartPos = container.Position dragStartMousePos = input.Position end end local function onDragPanel(input) if not draggingPanel or uiLocked then return end if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then if dragStartPos and dragStartMousePos then local delta = input.Position - dragStartMousePos local newX = dragStartPos.X.Offset + delta.X local newY = dragStartPos.Y.Offset + delta.Y container.Position = UDim2.new(dragStartPos.X.Scale, newX, dragStartPos.Y.Scale, newY) end end end local function endDragPanel() if draggingPanel then draggingPanel = false savedMobilePanelPos = { XScale = container.Position.X.Scale, XOffset = container.Position.X.Offset, YScale = container.Position.Y.Scale, YOffset = container.Position.Y.Offset } end dragStartPos = nil dragStartMousePos = nil end container.InputBegan:Connect(startDragPanel) container.InputEnded:Connect(endDragPanel) UIS.InputChanged:Connect(onDragPanel) UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then endDragPanel() end end) return panel end function createInstaResetFloatingButton() local SILVER = Color3.fromRGB(180, 180, 190) local panel = Instance.new("ScreenGui") panel.Name = "InstaResetButton" panel.ResetOnSpawn = false panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling panel.DisplayOrder = 20 pcall(function() if syn and syn.protect_gui then syn.protect_gui(panel) end end) if not pcall(function() panel.Parent = game:GetService("CoreGui") end) then panel.Parent = LP:WaitForChild("PlayerGui") end local btnFrame = Instance.new("Frame", panel) btnFrame.Size = UDim2.new(0, 60, 0, 60) btnFrame.Name = "Frame" if instaResetFloatingPos then btnFrame.Position = UDim2.new(instaResetFloatingPos.XScale or 0.5, instaResetFloatingPos.XOffset or -120, instaResetFloatingPos.YScale or 0, instaResetFloatingPos.YOffset or 10) else btnFrame.Position = UDim2.new(0.5, -120, 0, 10) end btnFrame.BackgroundColor3 = Color3.fromRGB(0,0,0) btnFrame.BackgroundTransparency = 0 btnFrame.BorderSizePixel = 0 btnFrame.ZIndex = 20 Instance.new("UICorner", btnFrame).CornerRadius = UDim.new(0, 18) astaAttachFloatBg(btnFrame, 18) local activeStroke = Instance.new("UIStroke", btnFrame) activeStroke.Name = "AstaActiveStroke" activeStroke.Color = Color3.fromRGB(0, 255, 120) activeStroke.Thickness = 3 activeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border activeStroke.Enabled = false local label = Instance.new("TextLabel", btnFrame) label.Size = UDim2.new(1, 0, 1, 0) label.BackgroundTransparency = 1 label.Text = "RESET" label.TextColor3 = SILVER label.Font = Enum.Font.GothamBold label.TextSize = 12 label.TextWrapped = true label.ZIndex = 21 astaAttachFloatGlow(label) local function setActive(state) if state then activeStroke.Enabled = true btnFrame.BackgroundColor3 = Color3.fromRGB(0,0,0) label.TextColor3 = Color3.fromRGB(0, 255, 120) else activeStroke.Enabled = false btnFrame.BackgroundColor3 = Color3.fromRGB(0,0,0) label.TextColor3 = Color3.fromRGB(255,255,255) end end local dragging = false; local hasMoved = false; local dragStart, startPos btnFrame.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = true; hasMoved = false; dragStart = inp.Position; startPos = btnFrame.Position end end) btnFrame.InputChanged:Connect(function(inp) if not dragging then return end if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then local delta = inp.Position - dragStart if delta.Magnitude > 5 then hasMoved = true end if hasMoved and not uiLocked then btnFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end end) btnFrame.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then if dragging then if not hasMoved then setActive(true) instaReset() if setInstaResetVisual then setInstaResetVisual(true) end task.delay(0.3, function() if setInstaResetVisual then setInstaResetVisual(false) end; setActive(false) end) elseif not uiLocked and hasMoved then instaResetFloatingPos = { XScale = btnFrame.Position.X.Scale, XOffset = btnFrame.Position.X.Offset, YScale = btnFrame.Position.Y.Scale, YOffset = btnFrame.Position.Y.Offset } end dragging = false; hasMoved = false end end end) return panel end 
-- ===== ANTI ANTI (sistema portado, sem a GUI original) =====
antiAntiEnabled = false
antiAntiFloatingButton = nil
antiAntiFloatingPos = nil
antiAntiSetVisual = nil
local AceAntiAnti = {
    enabled = false,
    character = nil,
    rootPart = nil,
    fakeRoot = nil,
    repRootOwner = nil,
    stepConnection = nil,
    conns = {},
    configured = false,
}
local AA_FAKE_ROOT_NAME = "DavidDesyncRoot"
local AA_FAKE_ROOT_Y = -2500
local AA_FAKE_ROOT_VELOCITY = Vector3.new(0, -1000, 0)
local aaEnv = (getgenv and getgenv()) or _G

local function aaIsBasePart(inst)
    if not inst then return false end
    local ok, res = pcall(function() return inst:IsA("BasePart") end)
    return ok and res == true
end

local function aaGetRoot(character)
    character = character or LP.Character
    if not character then return nil end
    local ok, root = pcall(function() return character:FindFirstChild("HumanoidRootPart") end)
    if ok and aaIsBasePart(root) then return root end
    return nil
end

local function aaFindGlobal(...)
    for i = 1, select("#", ...) do
        local name = select(i, ...)
        local v = rawget(aaEnv, name)
        if type(v) == "function" then return v end
    end
    return nil
end

local function aaSetHidden(inst, prop, value)
    if not inst then return false end
    local setter = aaFindGlobal("sethiddenproperty", "set_hidden_property", "sethiddenprop", "set_hidden_prop")
    if setter then
        local ok = pcall(setter, inst, prop, value)
        if ok then return true end
    end
    return pcall(function() inst[prop] = value end)
end

local function aaGetHidden(inst, prop)
    if not inst then return false, nil end
    local getter = aaFindGlobal("gethiddenproperty", "get_hidden_property", "gethiddenprop", "get_hidden_prop")
    if getter then
        local ok, value = pcall(getter, inst, prop)
        if ok then return true, value end
    end
    local ok, value = pcall(function() return inst[prop] end)
    return ok, value
end

local function aaConfigurePhysics()
    if AceAntiAnti.configured then return end
    AceAntiAnti.configured = true
    aaSetHidden(LP, "MaximumSimulationRadius", math.huge)
    aaSetHidden(LP, "SimulationRadius", math.huge)
    pcall(function()
        settings().Network.InterpolationThrottling = Enum.InterpolationThrottlingMode.Disabled
    end)
    pcall(function()
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
        settings().Physics.AllowSleep = false
    end)
    pcall(function()
        game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge)
    end)
end

local function aaFakeUsable()
    local fake = AceAntiAnti.fakeRoot
    if not aaIsBasePart(fake) then return false end
    local ok, parent = pcall(function() return fake.Parent end)
    return ok and parent ~= nil
end

local function aaDestroyFake()
    local fake = AceAntiAnti.fakeRoot
    AceAntiAnti.fakeRoot = nil
    if fake then pcall(function() fake:Destroy() end) end
end

local function aaRestoreRepRoot()
    local owner = AceAntiAnti.repRootOwner or AceAntiAnti.rootPart
    if aaIsBasePart(owner) then
        aaSetHidden(owner, "PhysicsRepRootPart", owner)
    end
    AceAntiAnti.repRootOwner = nil
end

local function aaCreateFake(rootPart)
    aaDestroyFake()
    local fake = Instance.new("Part")
    fake.Name = AA_FAKE_ROOT_NAME
    fake.Size = Vector3.new(2, 2, 1)
    fake.Anchored = true
    fake.CanCollide = false
    fake.CanTouch = false
    fake.CanQuery = false
    fake.Transparency = 1
    fake.CFrame = CFrame.new(0, AA_FAKE_ROOT_Y, 0)
    pcall(function() fake.AssemblyLinearVelocity = AA_FAKE_ROOT_VELOCITY end)
    fake.Parent = workspace
    local ok, pos = pcall(function() return rootPart.Position end)
    if ok and pos then
        fake.CFrame = CFrame.new(pos.X, AA_FAKE_ROOT_Y, pos.Z)
    end
    AceAntiAnti.fakeRoot = fake
    return fake
end

local function aaAssignFake(rootPart, fake)
    if not aaIsBasePart(rootPart) or not aaIsBasePart(fake) then return false end
    aaSetHidden(rootPart, "PhysicsRepRootPart", rootPart)
    AceAntiAnti.repRootOwner = rootPart
    return aaSetHidden(rootPart, "PhysicsRepRootPart", fake)
end

local function aaStep()
    if not AceAntiAnti.enabled then return end
    local root = AceAntiAnti.rootPart
    if not aaIsBasePart(root) then
        root = aaGetRoot(AceAntiAnti.character)
        AceAntiAnti.rootPart = root
    end
    if not root then return end

    if not aaFakeUsable() then
        local fake = aaCreateFake(root)
        aaAssignFake(root, fake)
        return
    end

    local fake = AceAntiAnti.fakeRoot
    local ok, rp, fp = pcall(function() return root.Position, fake.Position end)
    if ok and rp and fp and (math.abs(rp.X - fp.X) > 0.01 or math.abs(rp.Z - fp.Z) > 0.01 or math.abs(fp.Y - AA_FAKE_ROOT_Y) > 0.01) then
        pcall(function() fake.CFrame = CFrame.new(rp.X, AA_FAKE_ROOT_Y, rp.Z) end)
    end
    pcall(function()
        fake.Anchored = true
        fake.AssemblyLinearVelocity = AA_FAKE_ROOT_VELOCITY
    end)
    local got, current = aaGetHidden(root, "PhysicsRepRootPart")
    if not got or current ~= fake then
        aaSetHidden(root, "PhysicsRepRootPart", fake)
    end
end

local function aaStopStep()
    if AceAntiAnti.stepConnection then
        pcall(function() AceAntiAnti.stepConnection:Disconnect() end)
        AceAntiAnti.stepConnection = nil
    end
end

local function aaStartStep()
    aaStopStep()
    AceAntiAnti.stepConnection = RunService.Stepped:Connect(aaStep)
end

local function aaBindCharacter(character)
    local oldRoot = AceAntiAnti.rootPart
    AceAntiAnti.character = character
    AceAntiAnti.rootPart = aaGetRoot(character)
    if AceAntiAnti.enabled then
        if aaIsBasePart(oldRoot) and oldRoot ~= AceAntiAnti.rootPart then
            aaSetHidden(oldRoot, "PhysicsRepRootPart", oldRoot)
        end
        aaDestroyFake()
        local root = AceAntiAnti.rootPart
        if not root and character then
            local ok, waited = pcall(function() return character:WaitForChild("HumanoidRootPart", 8) end)
            if ok and aaIsBasePart(waited) then
                root = waited
                AceAntiAnti.rootPart = root
            end
        end
        if root then
            local fake = aaCreateFake(root)
            aaAssignFake(root, fake)
            aaStartStep()
        end
    end
end

aaBindCharacter(LP.Character)
table.insert(AceAntiAnti.conns, LP.CharacterAdded:Connect(function(c)
    task.defer(aaBindCharacter, c)
end))

function setAntiAnti(value)
    value = value == true
    if AceAntiAnti.enabled == value then
        antiAntiEnabled = value
        if antiAntiSetVisual then antiAntiSetVisual(value) end
        return value
    end
    AceAntiAnti.enabled = value
    if value then
        aaConfigurePhysics()
        local root = aaGetRoot(AceAntiAnti.character or LP.Character)
        AceAntiAnti.rootPart = root
        if not root then
            AceAntiAnti.enabled = false
            antiAntiEnabled = false
            if antiAntiSetVisual then antiAntiSetVisual(false) end
            return false
        end
        local fake = aaCreateFake(root)
        aaAssignFake(root, fake)
        aaStartStep()
    else
        aaStopStep()
        aaRestoreRepRoot()
        aaDestroyFake()
    end
    antiAntiEnabled = AceAntiAnti.enabled
    if antiAntiSetVisual then antiAntiSetVisual(antiAntiEnabled) end
    return antiAntiEnabled
end

function toggleAntiAnti()
    return setAntiAnti(not AceAntiAnti.enabled)
end

function createBatV2FloatingButton() local SILVER = Color3.fromRGB(180, 180, 190) local panel = Instance.new("ScreenGui") panel.Name = "BatV2Button" panel.ResetOnSpawn = false panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling panel.DisplayOrder = 22 pcall(function() if syn and syn.protect_gui then syn.protect_gui(panel) end end) if not pcall(function() panel.Parent = game:GetService("CoreGui") end) then panel.Parent = LP:WaitForChild("PlayerGui") end local btnFrame = Instance.new("Frame", panel) btnFrame.Size = UDim2.new(0, 60, 0, 60) btnFrame.Name = "Frame" if batV2FloatingPos then btnFrame.Position = UDim2.new(batV2FloatingPos.XScale or 0.5, batV2FloatingPos.XOffset or -50, batV2FloatingPos.YScale or 0, batV2FloatingPos.YOffset or 10) else btnFrame.Position = UDim2.new(0.5, -50, 0, 10) end btnFrame.BackgroundColor3 = Color3.fromRGB(0,0,0) btnFrame.BackgroundTransparency = 0 btnFrame.BorderSizePixel = 0 btnFrame.ZIndex = 20 Instance.new("UICorner", btnFrame).CornerRadius = UDim.new(0, 18) astaAttachFloatBg(btnFrame, 18) local activeStroke = Instance.new("UIStroke", btnFrame) activeStroke.Name = "AstaActiveStroke" activeStroke.Color = Color3.fromRGB(0, 255, 120) activeStroke.Thickness = 3 activeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border activeStroke.Enabled = autoBatV2Enabled and true or false local label = Instance.new("TextLabel", btnFrame) label.Size = UDim2.new(1, 0, 1, 0) label.BackgroundTransparency = 1 label.Text = "BAT\nV2" label.TextColor3 = Color3.fromRGB(255,255,255) label.Font = Enum.Font.GothamBold label.TextSize = 11 label.TextWrapped = true label.ZIndex = 21 astaAttachFloatGlow(label) local function setActive(state) if state then activeStroke.Enabled = true btnFrame.BackgroundColor3 = Color3.fromRGB(0,0,0) label.TextColor3 = Color3.fromRGB(0, 255, 120) else activeStroke.Enabled = false btnFrame.BackgroundColor3 = Color3.fromRGB(0,0,0) label.TextColor3 = Color3.fromRGB(255,255,255) end end local dragging = false; local hasMoved = false; local dragStart, startPos btnFrame.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = true; hasMoved = false; dragStart = inp.Position; startPos = btnFrame.Position end end) btnFrame.InputChanged:Connect(function(inp) if not dragging then return end if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then local delta = inp.Position - dragStart if delta.Magnitude > 5 then hasMoved = true end if hasMoved and not uiLocked then btnFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end end) btnFrame.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then if dragging then if not hasMoved then setActive(not autoBatV2Enabled) toggleBatV2() elseif not uiLocked and hasMoved then batV2FloatingPos = { XScale = btnFrame.Position.X.Scale, XOffset = btnFrame.Position.X.Offset, YScale = btnFrame.Position.Y.Scale, YOffset = btnFrame.Position.Y.Offset } end dragging = false; hasMoved = false end end end) batV2FloatingButton = panel return panel end local refreshInfJumpUI = nil function updateUIFromLoaded() task.wait() if normalBox then normalBox.Text = tostring(NS) end if carryBox then carryBox.Text = tostring(CS) end if radInput then radInput.Text = tostring(CONFIG.STEAL_RANGE) end if grabRadiusBox then grabRadiusBox.Text = tostring(CONFIG.GRAB_RADIUS) end if primeRangeBox then primeRangeBox.Text = tostring(CONFIG.PRIME_RANGE) end if updateStealModeButtons then updateStealModeButtons() end if laggerBox then laggerBox.Text = tostring(LAGGER_SPEED_1) end if lagger2Box then lagger2Box.Text = tostring(LAGGER_SPEED_2) end if batSpeedBox then batSpeedBox.Text = tostring(BAT_AIMBOT_SPEED) end if uiScaleBox then uiScaleBox.Text = tostring(uiScaleValue) end if btnScaleBox then btnScaleBox.Text = tostring(btnScaleValue) end if dropModeBtnRef then dropModeBtnRef.Text = dropMode == 1 and "Fling" or "Jump Drop" end if bodyLockRangeBox then bodyLockRangeBox.Text = tostring(bodyLockRange) end refreshSpeedModeLabel() for _, ref in ipairs(keyButtonRefs) do local entry = ref.entry local label if ref.mode == "gp" then label = (entry.gp and entry.gp.Name) or "None" else label = (entry.kb and entry.kb.Name) or "None" end ref.btn.Text = label end if savedProgressBarPos and pbFrame then pbFrame.Position = UDim2.new( savedProgressBarPos.XScale or 0.5, savedProgressBarPos.XOffset or -140, savedProgressBarPos.YScale or 1, savedProgressBarPos.YOffset or -50 ) end if uiLocked and setLockUIVisual then setLockUIVisual(true) end if editModeEnabled and setEditModeVisual then setEditModeVisual(true) end if antiRagdollEnabled and setAntiRagVisual then setAntiRagVisual(true); startAntiRagdoll() end if CONFIG.AUTO_STEAL_ENABLED and setInstaGrab then setInstaGrab(true); pcall(startAutoSteal) end if medusaCounterEnabled then if setMedusaVisual then setMedusaVisual(true) end if LP.Character then setupMedusa(LP.Character) end if setMedusaAutoResetVisual then setMedusaAutoResetVisual(false) end stopMedusaAutoReset() elseif medusaAutoResetEnabled then if setMedusaAutoResetVisual then setMedusaAutoResetVisual(true) end if LP.Character then setupMedusaAutoReset(LP.Character) end if setMedusaVisual then setMedusaVisual(false) end stopMedusaCounter() else if setMedusaVisual then setMedusaVisual(false) end if setMedusaAutoResetVisual then setMedusaAutoResetVisual(false) end stopMedusaCounter() stopMedusaAutoReset() end if batCounterEnabled and setBatCounterVisual then setBatCounterVisual(true) startBatCounter() end if unwalkEnabled and setUnwalkVisual then setUnwalkVisual(true); task.spawn(function() task.wait(0.5); startUnwalk() end) end if antiLagEnabled then if setAntiLagVisual then setAntiLagVisual(true) end enableAntiLag() else if setAntiLagVisual then setAntiLagVisual(false) end disableAntiLag() end if espEnabled then toggleESP(true) if setESPVIsual then setESPVIsual(true) end else toggleESP(false) if setESPVIsual then setESPVIsual(false) end end if _G.AceAntiDesyncAimbotOn then if tpLockSetVisual then tpLockSetVisual(true) end if not _G.AceAntiDesync.conn then startAntiDesyncAimbot() end if tpBatFloatingButton then local btnFrame = tpBatFloatingButton:FindFirstChild("Frame") if btnFrame then btnFrame.BackgroundColor3 = Color3.fromRGB(180, 180, 190) local label = btnFrame:FindFirstChild("TextLabel") if label then label.TextColor3 = Color3.fromRGB(0,0,0) end end end else if tpLockSetVisual then tpLockSetVisual(false) end if tpBatFloatingButton then local btnFrame = tpBatFloatingButton:FindFirstChild("Frame") if btnFrame then btnFrame.BackgroundColor3 = Color3.fromRGB(0,0,0) local label = btnFrame:FindFirstChild("TextLabel") if label then label.TextColor3 = Color3.fromRGB(180, 180, 190) end end end end if autoBatV2Enabled then if autoBatV2SetVisual then autoBatV2SetVisual(true) end if not _batV2Conn then startBatV2Aimbot() end if batV2FloatingButton then local btnFrame = batV2FloatingButton:FindFirstChild("Frame") if btnFrame then btnFrame.BackgroundColor3 = Color3.fromRGB(0,0,0) local st = btnFrame:FindFirstChild("AstaActiveStroke") if st then st.Enabled = true end local label = btnFrame:FindFirstChild("TextLabel") if label then label.TextColor3 = Color3.fromRGB(0, 255, 120) end end end else if autoBatV2SetVisual then autoBatV2SetVisual(false) end if batV2FloatingButton then local btnFrame = batV2FloatingButton:FindFirstChild("Frame") if btnFrame then btnFrame.BackgroundColor3 = Color3.fromRGB(0,0,0) local st = btnFrame:FindFirstChild("AstaActiveStroke") if st then st.Enabled = false end local label = btnFrame:FindFirstChild("TextLabel") if label then label.TextColor3 = Color3.fromRGB(180, 180, 190) end end end end if neonWeatherEnabled then applyNeonWeather() if setNeonWeatherVisual then setNeonWeatherVisual(true) end else restoreLightingState() if setNeonWeatherVisual then setNeonWeatherVisual(false) end end if stretchEnabled then enableStretch() if _G.stretchToggleSetter then _G.stretchToggleSetter(true) end else if _G.stretchToggleSetter then _G.stretchToggleSetter(false) end end if _G.fovButtons then for _, btn in ipairs(_G.fovButtons) do if btn:IsA("TextButton") then local val = tonumber(btn.Text) if val == stretchFOV then btn.BackgroundColor3 = Color3.fromRGB(180, 180, 190) btn.TextColor3 = Color3.fromRGB(0,0,0) else btn.BackgroundColor3 = Color3.fromRGB(12,12,12) btn.TextColor3 = Color3.fromRGB(255,255,255) end end end end if mobSetAutoBat then mobSetAutoBat(autoBatEnabled) end if mobSetAutoLeft then mobSetAutoLeft(autoLeftEnabled) end if mobSetAutoRight then mobSetAutoRight(autoRightEnabled) end if mobSetCarry then mobSetCarry(speedMode) end if mobSetLagger1 then mobSetLagger1(laggerToggled and laggerLevel == 1) end if mobSetLagger2 then mobSetLagger2(laggerToggled and laggerLevel == 2) end if bodyLockEnabled and bodyLockSetVisual then if _blSuppressCount == 0 then bodyLockSetVisual(true) startBodyLock() else bodyLockSetVisual(false) end end updateProgressBarVisibility() startEnemySpeed() if bgDecalRef then bgDecalRef.Image = BackgroundDecals[currentBgIndex] or "" end if bgPreviewRef then bgPreviewRef.Image = BackgroundDecals[currentBgIndex] or "" end if astaRefreshFloatBgs then astaRefreshFloatBgs() end if fovContainer then fovContainer.Visible = false if fovToggleBtn then fovToggleBtn.Text = "▶" end end toggleLockUI(uiLocked) end buildGui() if loadAllSettings() then updateUIFromLoaded() end MobilePanel = createMobilePanel() instaResetFloatingButton = createInstaResetFloatingButton() batV2FloatingButton = createBatV2FloatingButton() pcall(applyButtonScale) task.defer(function() pcall(applyButtonScale) end) task.delay(1, function() pcall(applyButtonScale) end) task.delay(3, function() pcall(applyButtonScale) end) if LP.Character then task.wait(0.1) while not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") or not LP.Character:FindFirstChildOfClass("Humanoid") do task.wait() end setupMovementAndIndicators(LP.Character) if currentAnimPack ~= "Off" then startAnimPack(currentAnimPack) end end LP.CharacterAdded:Connect(function(char) local _wasAutoStealOn = CONFIG.AUTO_STEAL_ENABLED stopAutoSteal() stopAutoLeft() stopAutoRight() stopBatCounter() stopMedusaCounter() stopUnwalk() stopDropBrainrot() stopMedusaAutoReset() if autoBatEnabled then disableAutoBat() end if _G.AceAntiDesyncAimbotOn then stopAntiDesyncAimbot() end if autoBatV2Enabled then disableBatV2() end if bodyLockEnabled then stopBodyLock() end cleanupSpeedPhysics() task.wait(0.1) while not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") or not LP.Character:FindFirstChildOfClass("Humanoid") do task.wait() end setupMovementAndIndicators(char) if _wasAutoStealOn then pcall(startAutoSteal) if updateProgressBarVisibility then pcall(updateProgressBarVisibility) end end if _G.AceAntiDesyncAimbotOn then task.defer(function() startAntiDesyncAimbot() end) end if autoBatV2Enabled then task.defer(function() startBatV2Aimbot() end) end if antiRagdollEnabled then task.wait(0.5) startAntiRagdoll() end if bodyLockEnabled and _blSuppressCount == 0 then startBodyLock() end if medusaCounterEnabled then setupMedusa(char) if setMedusaVisual then setMedusaVisual(true) end if setMedusaAutoResetVisual then setMedusaAutoResetVisual(false) end stopMedusaAutoReset() elseif medusaAutoResetEnabled then setupMedusaAutoReset(char) if setMedusaAutoResetVisual then setMedusaAutoResetVisual(true) end if setMedusaVisual then setMedusaVisual(false) end stopMedusaCounter() else stopMedusaCounter() stopMedusaAutoReset() if setMedusaVisual then setMedusaVisual(false) end if setMedusaAutoResetVisual then setMedusaAutoResetVisual(false) end end if batCounterEnabled then startBatCounter() end if unwalkEnabled then startUnwalk() end if currentAnimPack ~= "Off" then task.wait(0.5) startAnimPack(currentAnimPack) end updateProgressBarVisibility() refreshSpeedModeLabel() end) local lastLaggerToggle = 0 local LAGGER_COOLDOWN = 0.3 UIS.InputBegan:Connect(function(input, gpe) if _anyKeyListening then return end if input.UserInputType == Enum.UserInputType.Keyboard then if gpe or UIS:GetFocusedTextBox() then return end elseif not isGamepadInput(input) then return end if not isBindableInput(input) then return end local kc = input.KeyCode if not kc then return end if kbMatch(KB.LaggerMode, kc) then if tick() - lastLaggerToggle >= LAGGER_COOLDOWN then lastLaggerToggle = tick() toggleLaggerCycle() end return end if kbMatch(KB.CarryToggle, kc) then toggleCarryMode(); return end if kbMatch(KB.DropBrainrot, kc) then if not dropActive then if dropBrainrotSetVisual then dropBrainrotSetVisual(true) end executeDropWithToggle(dropBrainrotSetVisual) end return end if kbMatch(KB.TPFloor, kc) then doTpDown(); return end if kbMatch(KB.TPBypass, kc) then local t = _G.AstaTPBypass if t and t.set then t.set(not t.enabled) end return end if kbMatch(KB.AntiDesync, kc) then pcall(toggleAntiDesyncAimbot) return end if kbMatch(KB.DropMode, kc) then if dropActive then pcall(stopDropBrainrot) end dropMode = dropMode == 1 and 2 or 1 if dropModeBtnRef then dropModeBtnRef.Text = dropMode == 1 and "Fling" or "Jump Drop" end if requestSave then pcall(requestSave) end return end if kbMatch(KB.InstaReset, kc) then instaReset(); return end if kbMatch(KB.AutoLeft, kc) then autoLeftEnabled = not autoLeftEnabled if autoLeftEnabled then startAutoLeft() else stopAutoLeft() end if autoLeftSetVisual then autoLeftSetVisual(autoLeftEnabled) end if mobSetAutoLeft then mobSetAutoLeft(autoLeftEnabled) end return end if kbMatch(KB.AutoRight, kc) then autoRightEnabled = not autoRightEnabled if autoRightEnabled then startAutoRight() else stopAutoRight() end if autoRightSetVisual then autoRightSetVisual(autoRightEnabled) end if mobSetAutoRight then mobSetAutoRight(autoRightEnabled) end return end if kbMatch(KB.AutoBat, kc) then if not autoBatEnabled then enableAutoBat() if autoBatSetVisual then autoBatSetVisual(true) end if mobSetAutoBat then mobSetAutoBat(true) end else disableAutoBat() if autoBatSetVisual then autoBatSetVisual(false) end if mobSetAutoBat then mobSetAutoBat(false) end end return end if kbMatch(KB.BatV2, kc) then toggleBatV2() if autoBatV2SetVisual then autoBatV2SetVisual(autoBatV2Enabled) end if batV2FloatingButton then local btnFrame = batV2FloatingButton:FindFirstChild("Frame") if btnFrame then btnFrame.BackgroundColor3 = autoBatV2Enabled and Color3.fromRGB(180, 180, 190) or Color3.fromRGB(0,0,0) local label = btnFrame:FindFirstChild("TextLabel") if label then label.TextColor3 = Color3.fromRGB(255,255,255) end end end return end if kbMatch(KB.GuiHide, kc) then if main then if main.Visible then hideGui() else showGui() end end return end end)

--==================== ASTA ANTI ANTI DESYNC :: TP BYPASS + TP DESYNC (BOTOES FLUTUANTES) ====================
do
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local TS = game:GetService("TweenService")
	local HS = game:GetService("HttpService")
	local LP = Players.LocalPlayer

	local SLAP_LIST = { "Bat", "Slap", "Iron Slap", "Gold Slap", "Diamond Slap", "Emerald Slap", "Ruby Slap", "Dark Matter Slap", "Flame Slap", "Nuclear Slap", "Galaxy Slap", "Glitched Slap" }
	local POS_FILE = "AstaHub_TPButtons.json"
	local savedTPPos = {}
	pcall(function()
		if isfile and readfile and isfile(POS_FILE) then
			local ok, data = pcall(function() return HS:JSONDecode(readfile(POS_FILE)) end)
			if ok and type(data) == "table" then savedTPPos = data end
		end
	end)
	local function saveTPPos()
		if not writefile then return end
		pcall(function() writefile(POS_FILE, HS:JSONEncode(savedTPPos)) end)
	end

	local function findBat()
		local char = LP.Character
		if not char then return nil end
		for _, name in ipairs(SLAP_LIST) do
			local t = char:FindFirstChild(name)
			if t and t:IsA("Tool") then return t end
		end
		local bp = LP:FindFirstChildOfClass("Backpack")
		if bp then
			for _, name in ipairs(SLAP_LIST) do
				local t = bp:FindFirstChild(name)
				if t and t:IsA("Tool") then
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum then pcall(function() hum:EquipTool(t) end) end
					return t
				end
			end
		end
		return nil
	end

	local function getClosest(root)
		if not root then return nil, math.huge end
		local closest, minDist = nil, math.huge
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LP and plr.Character then
				local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
				local hum = plr.Character:FindFirstChildOfClass("Humanoid")
				if tRoot and hum and hum.Health > 0 then
					local d = (tRoot.Position - root.Position).Magnitude
					if d < minDist then minDist = d; closest = tRoot end
				end
			end
		end
		return closest, minDist
	end

	-------------------------------------------------- TP BYPASS
	local TPD -- forward declaration: TPB.set precisa enxergar TPD
	local TPB = { enabled = false, conn = nil, hitCD = false, swingCD = 0.1, hitDist = 40, maxRange = 600, setActive = nil }
	TPB.swing = function()
		if TPB.hitCD then return end
		TPB.hitCD = true
		pcall(function()
			local bat = findBat()
			if bat then
				local char = LP.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if hum and bat.Parent ~= char then pcall(function() hum:EquipTool(bat) end) end
				pcall(function() bat:Activate() end)
				local ev = bat:FindFirstChildOfClass("RemoteEvent")
				if ev then pcall(function() ev:FireServer() end) end
			end
		end)
		task.delay(TPB.swingCD, function() TPB.hitCD = false end)
	end
	-- altura/recuo do TP Bypass (ajustaveis)
	TPB.heightOffset = 3.2   -- fica um pouco ACIMA do alvo
	TPB.backOffset   = 0.8   -- micro recuo pra nao entrar dentro do boneco
	TPB.stick = function(root, target, dist)
		if not root or not target then return end

		-- posicao desejada: acima do alvo, olhando pra baixo nele
		local tPos = target.Position
		local look = tPos - root.Position
		local flat = Vector3.new(look.X, 0, look.Z)
		local dirFlat = (flat.Magnitude > 0.05) and flat.Unit or (root.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit

		local desiredPos = tPos + Vector3.new(0, TPB.heightOffset, 0) - (dirFlat * TPB.backOffset)
		-- olha direto pro boneco do player (inclui Y -> olhando pra baixo)
		local desiredCF = CFrame.lookAt(desiredPos, tPos)

		if dist > 10 then
			root.CFrame = desiredCF                       -- longe: TP instantaneo
		else
			root.CFrame = root.CFrame:Lerp(desiredCF, 0.6) -- perto: cola suave (menos tremida)
		end

		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end
	TPB.update = function()
		if not TPB.enabled then return end
		local char = LP.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not root or not hum or hum.Health <= 0 then return end

		-- evita ficar preso em Physics
		local st = hum:GetState()
		if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll then
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
		end

		if not char:FindFirstChildOfClass("Tool") then
			local bat = findBat()
			if bat then pcall(function() hum:EquipTool(bat) end) end
		end

		local target, targetDist = getClosest(root)
		if not target then return end
		if targetDist > TPB.maxRange then return end

		TPB.stick(root, target, targetDist)

		if sethiddenproperty then pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", target) end) end
		local cam = workspace.CurrentCamera
		if cam then cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position) end

		-- mira ja aplicada em TPB.stick (olhando pra baixo no alvo), nao sobrescreve aqui

		if targetDist <= TPB.hitDist then TPB.swing() end
	end
	TPB.start = function()
		if TPB.conn then TPB.conn:Disconnect() TPB.conn = nil end
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.AutoRotate = false end
		TPB.conn = RunService.Heartbeat:Connect(TPB.update)
	end
	TPB.stop = function()
		if TPB.conn then TPB.conn:Disconnect() TPB.conn = nil end
		local char = LP.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if root then
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			if sethiddenproperty then pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", root) end) end
		end
		if hum then
			hum.AutoRotate = true
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
		end
		TPB.hitCD = false
	end
	TPB.set = function(on)
		TPB.enabled = on and true or false
		if TPB.enabled then
			if TPD.enabled then TPD.set(false) end -- nao usa os dois juntos
			TPB.start()
		else
			TPB.stop()
		end
		if TPB.setActive then TPB.setActive(TPB.enabled) end
	end

	-------------------------------------------------- TP DESYNC (estavel + acerto longe)
	TPD = { enabled = false, conn = nil, rconn = nil, sconn = nil, hitCD = false, setActive = nil, maxRange = 600 }
	TPD.swing = function()
		if TPD.hitCD then return end
		TPD.hitCD = true
		pcall(function()
			local bat = findBat()
			if bat then
				local char = LP.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if hum and bat.Parent ~= char then pcall(function() hum:EquipTool(bat) end) end
				pcall(function() bat:Activate() end)
				local ev = bat:FindFirstChildOfClass("RemoteEvent")
				if ev then pcall(function() ev:FireServer() end) end
			end
		end)
		task.delay(0.09, function() TPD.hitCD = false end)
	end
	TPD.offsetY = 0
	TPD.offsetZ = 0
	TPD.noclipParts = {}
	TPD._stuckTimer = 0
	TPD.setNoclip = function(char, state)
		if not char then return end
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then
				if state then
					if TPD.noclipParts[p] == nil then TPD.noclipParts[p] = p.CanCollide end
					p.CanCollide = false
				end
			end
		end
		if not state then
			for p, col in pairs(TPD.noclipParts) do
				pcall(function() if p and p.Parent then p.CanCollide = col end end)
			end
			TPD.noclipParts = {}
		end
	end
	TPD.recover = function()
		local char = LP.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		TPD.setNoclip(char, false)
		if hrp then
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			if sethiddenproperty then pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", hrp) end) end
		end
		if hum then
			hum.AutoRotate = true
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
			task.defer(function()
				pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
			end)
		end
	end
	TPD.glue = function()
		if not TPD.enabled then return end
		local char = LP.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum or hum.Health <= 0 then return end

		local target = getClosest(hrp)
		if not target then return end
		local dist = (target.Position - hrp.Position).Magnitude
		if dist > (TPD.maxRange or 600) then return end

		TPD.setNoclip(char, true)
		if hum.AutoRotate then hum.AutoRotate = false end

		-- NAO trava em Physics pra sempre (isso matava/travava)
		-- so tira ragdoll se precisar
		local st = hum:GetState()
		if st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown then
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
		end

		pcall(function() hrp:SetNetworkOwner(LP) end)
		if sethiddenproperty then pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", target) end) end

		-- cola no centro do alvo (leve offset pra hitbox)
		local goal = target.CFrame * CFrame.new(0, TPD.offsetY, TPD.offsetZ)
		hrp.CFrame = goal
		-- velocidade baixa (zero total as vezes causa morte/trava)
		hrp.AssemblyLinearVelocity = Vector3.new(0, -1, 0)
		hrp.AssemblyAngularVelocity = Vector3.zero
	end
	TPD.update = function()
		if not TPD.enabled then return end
		TPD.glue()
		local char = LP.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end

		local target = getClosest(hrp)
		if not target then return end

		local cam = workspace.CurrentCamera
		if cam then cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position) end

		-- anti-trava: se ficou parado no ar tempo demais, recupera estado
		if hrp.AssemblyLinearVelocity.Magnitude < 0.5 then
			TPD._stuckTimer = (TPD._stuckTimer or 0) + 0.03
			if TPD._stuckTimer > 2.5 then
				pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
				TPD._stuckTimer = 0
			end
		else
			TPD._stuckTimer = 0
		end

		TPD.swing()
	end
	TPD.start = function()
		if TPD.conn then TPD.conn:Disconnect() TPD.conn = nil end
		if TPD.rconn then TPD.rconn:Disconnect() TPD.rconn = nil end
		if TPD.sconn then TPD.sconn:Disconnect() TPD.sconn = nil end
		local char = LP.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.AutoRotate = false end
		TPD._stuckTimer = 0
		-- so Heartbeat + RenderStepped (Stepped demais causava trava)
		TPD.conn = RunService.Heartbeat:Connect(TPD.update)
		TPD.rconn = RunService.RenderStepped:Connect(function()
			if TPD.enabled then TPD.glue() end
		end)
	end
	TPD.stop = function()
		if TPD.conn then TPD.conn:Disconnect() TPD.conn = nil end
		if TPD.rconn then TPD.rconn:Disconnect() TPD.rconn = nil end
		if TPD.sconn then TPD.sconn:Disconnect() TPD.sconn = nil end
		TPD.hitCD = false
		TPD._stuckTimer = 0
		TPD.recover()
	end
	TPD.set = function(on)
		TPD.enabled = on and true or false
		if TPD.enabled then
			if TPB.enabled then TPB.set(false) end -- nao usa os dois juntos
			TPD.start()
		else
			TPD.stop()
		end
		if TPD.setActive then TPD.setActive(TPD.enabled) end
	end

	LP.CharacterAdded:Connect(function()
		task.wait(0.35)
		-- limpa trava ao respawnar
		TPD.recover()
		if TPB.enabled then TPB.start() end
		if TPD.enabled then TPD.start() end
	end)

	-------------------------------------------------- -------------------------------------------------- BOTOES FLUTUANTES
	local SILVER = Color3.fromRGB(180, 180, 190)
	local function makeFloatingButton(id, text, defX, defY, onToggle)
		local panel = Instance.new("ScreenGui")
		panel.Name = "AstaHub_" .. id
		panel.ResetOnSpawn = false
		panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		panel.DisplayOrder = 50
		pcall(function() if syn and syn.protect_gui then syn.protect_gui(panel) end end)
		if not pcall(function() panel.Parent = game:GetService("CoreGui") end) then
			panel.Parent = LP:WaitForChild("PlayerGui")
		end

		-- TextButton = clique mais confiavel que Frame
		local btnFrame = Instance.new("TextButton", panel)
		btnFrame.Name = "Frame"
		btnFrame.Size = UDim2.new(0, 60, 0, 60)
		btnFrame.AutoButtonColor = false
		btnFrame.Text = ""
		btnFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		btnFrame.BorderSizePixel = 0
		btnFrame.ZIndex = 50
		local sp = savedTPPos[id]
		if sp then
			btnFrame.Position = UDim2.new(sp.XScale or 0.5, sp.XOffset or defX, sp.YScale or 0, sp.YOffset or defY)
		else
			btnFrame.Position = UDim2.new(0.5, defX, 0, defY)
		end
		Instance.new("UICorner", btnFrame).CornerRadius = UDim.new(0, 18)
		pcall(function() astaAttachFloatBg(btnFrame, 18) end)

		local activeStroke = Instance.new("UIStroke", btnFrame)
		activeStroke.Name = "AstaActiveStroke"
		activeStroke.Color = Color3.fromRGB(0, 255, 120)
		activeStroke.Thickness = 3
		activeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		activeStroke.Enabled = false

		local label = Instance.new("TextLabel", btnFrame)
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = SILVER
		label.Font = Enum.Font.GothamBold
		label.TextSize = 11
		label.TextWrapped = true
		label.ZIndex = 51
		label.Active = false
		astaAttachFloatGlow(label)

		local function setActive(state)
			if state then
				activeStroke.Enabled = true
				label.TextColor3 = Color3.fromRGB(0, 255, 120)
			else
				activeStroke.Enabled = false
				btnFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				label.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end

		local dragging, hasMoved, dragStart, startPos = false, false, nil, nil

		local lastToggle = 0
		local function doToggle()
			local now = tick()
			if now - lastToggle < 0.3 then return end
			lastToggle = now
			pcall(function()
				onToggle()
			end)
		end

		btnFrame.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				hasMoved = false
				dragStart = inp.Position
				startPos = btnFrame.Position
			end
		end)

		btnFrame.InputChanged:Connect(function(inp)
			if not dragging or not dragStart then return end
			if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
				local delta = inp.Position - dragStart
				if delta.Magnitude > 12 then hasMoved = true end
				if hasMoved and uiLocked ~= true then
					btnFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				end
			end
		end)

		btnFrame.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				if dragging then
					if hasMoved then
						savedTPPos[id] = {
							XScale = btnFrame.Position.X.Scale,
							XOffset = btnFrame.Position.X.Offset,
							YScale = btnFrame.Position.Y.Scale,
							YOffset = btnFrame.Position.Y.Offset
						}
						saveTPPos()
					end
				end
				dragging = false
				task.defer(function() hasMoved = false end)
			end
		end)

		-- clique principal (TextButton)
		btnFrame.MouseButton1Click:Connect(function()
			if hasMoved then return end
			doToggle()
		end)

		return setActive
	end

	TPB.setActive = makeFloatingButton("TPBypass", "TP\nBYPASS", -190, 80, function()
		local newState = not TPB.enabled
		print("[PRODIGY] TP Bypass ->", newState)
		local ok, err = pcall(function() TPB.set(newState) end)
		if not ok then warn("[PRODIGY] TP Bypass erro:", err) end
		if TPB.setActive then TPB.setActive(TPB.enabled) end
	end)

	_G.AstaTPBypass = TPB
end

-- ============================================================
--  LARP ANTI ANTI DESYNC PANEL (INTEGRADO)
-- ============================================================
do
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = Players.LocalPlayer

    local larpConns = {}
    local larpFeatureStates = { FreezePlayer = false }

    local larpOrig = {}

    local function freezeChar(char)
        if not char then return end
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            if larpOrig[hum] == nil then
                larpOrig[hum] = { ws = hum.WalkSpeed, jp = hum.JumpPower, ar = hum.AutoRotate }
            end
            hum.WalkSpeed = 0
            hum.JumpPower = 0
            hum.AutoRotate = false
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if larpOrig[part] == nil then
                    larpOrig[part] = { anc = part.Anchored, col = part.CanCollide }
                end
                part.CanCollide = false
                part.Anchored = true
            end
        end
    end

    local function unfreezeAll()
        for obj, data in pairs(larpOrig) do
            pcall(function()
                if obj and obj.Parent then
                    if data.ws ~= nil then
                        obj.WalkSpeed = data.ws
                        obj.JumpPower = data.jp
                        obj.AutoRotate = data.ar
                    else
                        obj.Anchored = data.anc
                        obj.CanCollide = data.col
                    end
                end
            end)
        end
        larpOrig = {}
    end

    local function toggleFreeze(enabled)
        if enabled then
            if larpFeatureStates.FreezePlayer then return end
            larpFeatureStates.FreezePlayer = true
            local conn = RunService.Stepped:Connect(function()
                if not larpFeatureStates.FreezePlayer then return end
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer then
                        pcall(freezeChar, plr.Character)
                    end
                end
            end)
            table.insert(larpConns, conn)
            local addConn = Players.PlayerAdded:Connect(function(plr)
                plr.CharacterAdded:Connect(function(char)
                    task.wait(0.4)
                    if larpFeatureStates.FreezePlayer then pcall(freezeChar, char) end
                end)
            end)
            table.insert(larpConns, addConn)
        else
            if not larpFeatureStates.FreezePlayer then return end
            larpFeatureStates.FreezePlayer = false
            for _, conn in ipairs(larpConns) do
                pcall(function()
                    if typeof(conn) == "RBXScriptConnection" then
                        conn:Disconnect()
                    elseif typeof(conn) == "thread" then
                        task.cancel(conn)
                    end
                end)
            end
            larpConns = {}
            unfreezeAll()
        end
    end

    local function getGuiParent()
        if typeof(gethui) == "function" then
            local ok, result = pcall(gethui)
            if ok and result then return result end
        end
        local ok, core = pcall(function() return game:GetService("CoreGui") end)
        if ok and core then return core end
        return LocalPlayer:WaitForChild("PlayerGui")
    end

    local function newInstance(className, props, parent)
        local obj = Instance.new(className)
        for k, v in pairs(props or {}) do obj[k] = v end
        obj.Parent = parent
        return obj
    end

    local function addCorner(obj, radius)
        return newInstance("UICorner", { CornerRadius = UDim.new(0, radius) }, obj)
    end

    local function addStroke(obj, color, thickness, transparency)
        return newInstance("UIStroke", {
            Color = color,
            Thickness = thickness or 1,
            Transparency = transparency or 0,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, obj)
    end

    local parent = getGuiParent()
    local existing = parent:FindFirstChild("LarpAntiAntiDesyncGui")
    if existing then existing:Destroy() end

    local larpGui = newInstance("ScreenGui", {
        Name = "LarpAntiAntiDesyncGui",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    if type(syn) == "table" and type(syn.protect_gui) == "function" then
        pcall(syn.protect_gui, larpGui)
    elseif typeof(protectgui) == "function" then
        pcall(protectgui)
    end

    pcall(function() larpGui.Parent = parent end)
    if not larpGui.Parent then
        larpGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local frame = newInstance("Frame", {
        Size = UDim2.fromOffset(230, 92),
        Position = UDim2.new(0.5, -115, 0.5, -46),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true,
        ZIndex = 40,
        Visible = false,
    }, larpGui)
    addCorner(frame, 13)
    addStroke(frame, Color3.fromRGB(39, 39, 39), 1.3)

    local holder = newInstance("Frame", {
        Size = UDim2.new(1, -6, 1, -6),
        Position = UDim2.fromOffset(3, 3),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 40,
    }, frame)
    addCorner(holder, 10)

    newInstance("ImageLabel", {
        Name = "AstaBg",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = "rbxassetid://136208130767349",
        ScaleType = Enum.ScaleType.Crop,
        ImageTransparency = 0,
        ZIndex = 40,
    }, holder)

    newInstance("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(2, 2, 2),
        BackgroundTransparency = 0.92,
        BorderSizePixel = 0,
        ZIndex = 41,
    }, holder)

    local header = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 31),
        BackgroundColor3 = Color3.fromRGB(4, 4, 4),
        BorderSizePixel = 0,
        ZIndex = 42,
    }, holder)
    newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Color3.fromRGB(34, 34, 34),
        BorderSizePixel = 0,
        ZIndex = 43,
    }, header)
    newInstance("TextLabel", {
        Size = UDim2.new(1, -76, 1, 0),
        Position = UDim2.fromOffset(12, 0),
        BackgroundTransparency = 1,
        Text = "Asta Anti anti desync",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 43,
    }, header)

    local toggleBtn = newInstance("TextButton", {
        Size = UDim2.new(1, -18, 0, 39),
        Position = UDim2.fromOffset(9, 43),
        BackgroundColor3 = Color3.fromRGB(16, 16, 16),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "ACTIVATE",
        TextColor3 = Color3.fromRGB(226, 52, 52),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        ZIndex = 42,
    }, holder)
    addCorner(toggleBtn, 10)

    local active = false
    local function setActive(state)
        active = state
        if state then
            toggleBtn.Text = "DEACTIVATE"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(228, 34, 34)
            toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggleFreeze(true)
        else
            toggleBtn.Text = "ACTIVATE"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
            toggleBtn.TextColor3 = Color3.fromRGB(226, 52, 52)
            toggleFreeze(false)
        end
    end

    toggleBtn.Activated:Connect(function()
        setActive(not active)
    end)

    toggleBtn.MouseEnter:Connect(function()
        local target = active and Color3.fromRGB(236, 44, 44) or Color3.fromRGB(32, 32, 32)
        TweenService:Create(toggleBtn, TweenInfo.new(0.12), { BackgroundColor3 = target }):Play()
    end)
    toggleBtn.MouseLeave:Connect(function()
        local target = active and Color3.fromRGB(228, 34, 34) or Color3.fromRGB(16, 16, 16)
        TweenService:Create(toggleBtn, TweenInfo.new(0.12), { BackgroundColor3 = target }):Play()
    end)

    local dragging = false
    local dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    setActive(false)

    _G.SetLarpPanel = function(visible)
        visible = (visible == true)
        if visible then
            if not larpGui.Parent then
                pcall(function() larpGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
            end
            larpGui.Enabled = true
            frame.Visible = true
            frame.ZIndex = 400
        else
            frame.Visible = false
            if active then setActive(false) end
        end
    end
end

-- ================= Asta Anti Bat Panel (Misc) =================
do

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local CONFIG_FILE = "Asta_AntiBat_Config.json"
local AntiBatEnabled = false
local CurrentKeybind = Enum.KeyCode.N
local WaitingForKeybind = false
local isMobileMode = true
local CurrentBG = "rbxassetid://126793180958099"
local AntiBatConn = nil
local AntiRagdollConn = nil

local function saveConfig()
	local data = {
		Keybind = CurrentKeybind.Name,
		MobileMode = isMobileMode
	}
	pcall(function()
		if writefile then
			writefile(CONFIG_FILE, HttpService:JSONEncode(data))
		end
	end)
end

local function loadConfig()
	local success, result = pcall(function()
		if isfile and isfile(CONFIG_FILE) then
			return HttpService:JSONDecode(readfile(CONFIG_FILE))
		end
	end)
	if success and result then
		if result.Keybind and Enum.KeyCode[result.Keybind] then
			CurrentKeybind = Enum.KeyCode[result.Keybind]
		end
		if result.MobileMode ~= nil then
			isMobileMode = result.MobileMode
		end
	end
end
loadConfig()

local function startAntiBat()
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if AntiBatConn then AntiBatConn:Disconnect() end
	AntiBatConn = RunService.Heartbeat:Connect(function()
		if not root or not root.Parent then return end
		local origXZ = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
		root.Velocity = Vector3.new(1000, root.Velocity.Y, 1000)
		RunService.RenderStepped:Wait()
		if root and root.Parent then
			root.Velocity = Vector3.new(origXZ.X, root.Velocity.Y, origXZ.Z)
		end
	end)
end

local function stopAntiBat()
	if AntiBatConn then
		AntiBatConn:Disconnect()
		AntiBatConn = nil
	end
end

local function startAntiRagdoll()
	if AntiRagdollConn then return end
	AntiRagdollConn = RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local hum2 = char:FindFirstChildOfClass("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")
		if hum2 then
			local st = hum2:GetState()
			if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown then
				hum2:ChangeState(Enum.HumanoidStateType.Running)
				workspace.CurrentCamera.CameraSubject = hum2
				pcall(function()
					local pm = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
					if pm then
						local cm = pm:FindFirstChild("ControlModule")
						if cm then require(cm):Enable() end
					end
				end)
				if root then
					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero
				end
			end
		end
		for _, obj in ipairs(char:GetDescendants()) do
			if obj:IsA("Motor6D") and not obj.Enabled then
				obj.Enabled = true
			end
		end
	end)
end

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.3)
	if AntiBatEnabled then startAntiBat() end
	task.wait(0.5)
	startAntiRagdoll()
end)

local gui = Instance.new("ScreenGui")
gui.Name = "PRODIGY Anti-Bat"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Visible = false
Main.Name = "Main"
Main.Active = true
Main.ClipsDescendants = true
Main.Position = UDim2.new(0.5, -90, 0.5, -44)
Main.Size = UDim2.new(0, 180, 0, 88)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.BorderSizePixel = 0
Main.Parent = gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local AstaBg = Instance.new("ImageLabel")
AstaBg.Name = "AstaBg"
AstaBg.Size = UDim2.new(1, 0, 1, 0)
AstaBg.Position = UDim2.new(0, 0, 0, 0)
AstaBg.BackgroundTransparency = 1
AstaBg.ScaleType = Enum.ScaleType.Crop
AstaBg.Image = _G.AstaAntiAntiBgImage or ""
AstaBg.Visible = (AstaBg.Image ~= "")
AstaBg.ZIndex = 1
AstaBg.Parent = Main
Instance.new("UICorner", AstaBg).CornerRadius = UDim.new(0, 10)
_G.AstaAntiAntiBgLabel = AstaBg
function _G.AstaSetAntiAntiBg(imgId)
    _G.AstaAntiAntiBgImage = imgId or ""
    local lbl = _G.AstaAntiAntiBgLabel
    if lbl and lbl.Parent then
        lbl.Image = _G.AstaAntiAntiBgImage
        lbl.ImageTransparency = 0
        lbl.Visible = (_G.AstaAntiAntiBgImage ~= "")
    end
end
local AntiAntiBackground = Instance.new("ImageLabel")
AntiAntiBackground.Name = "AntiAntiBackground"
AntiAntiBackground.Size = UDim2.fromScale(1, 1)
AntiAntiBackground.BackgroundTransparency = 1
AntiAntiBackground.Image = "rbxassetid://126793180958099"
AntiAntiBackground.ScaleType = Enum.ScaleType.Crop
AntiAntiBackground.ImageTransparency = 0
AntiAntiBackground.ZIndex = 1
AntiAntiBackground.Parent = Main
Instance.new("UICorner", AntiAntiBackground).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(110, 110, 120)
stroke.Thickness = 1.5
stroke.Transparency = 0.25
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local SpaceBackground = Instance.new("ImageLabel")
SpaceBackground.Name = "SpaceBackground"
SpaceBackground.ZIndex = 0
SpaceBackground.Size = UDim2.new(1, 0, 1, 0)
SpaceBackground.BackgroundTransparency = 1
SpaceBackground.Image = CurrentBG
SpaceBackground.ScaleType = Enum.ScaleType.Crop
SpaceBackground.Parent = Main
Instance.new("UICorner", SpaceBackground).CornerRadius = UDim.new(0, 10)

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Active = true
Header.ZIndex = 2
Header.Size = UDim2.new(1, 0, 0, 28)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.ZIndex = 3
Title.Position = UDim2.new(0, 8, 0, 0)
Title.Size = UDim2.new(1, -56, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "PRODIGY Anti-Bat"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextSize = 9
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextStrokeTransparency = 0.5
Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Title.Parent = Header

local ModeToggle = Instance.new("TextButton")
ModeToggle.ZIndex = 4
ModeToggle.AnchorPoint = Vector2.new(1, 0.5)
ModeToggle.Position = UDim2.new(1, -8, 0.5, 0)
ModeToggle.Size = UDim2.new(0, 38, 0, 16)
ModeToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
ModeToggle.BackgroundTransparency = 0.25
ModeToggle.Text = isMobileMode and "PC" or "MOBILE"
ModeToggle.TextColor3 = Color3.fromRGB(240, 240, 240)
ModeToggle.TextSize = 7
ModeToggle.Font = Enum.Font.GothamBold
ModeToggle.Parent = Header
Instance.new("UICorner", ModeToggle).CornerRadius = UDim.new(0, 6)

local Content = Instance.new("Frame")
Content.ZIndex = 2
Content.Position = UDim2.new(0, 8, 0, 30)
Content.Size = UDim2.new(1, -16, 1, -40)
Content.BackgroundTransparency = 1
Content.Parent = Main

local PCContent = Instance.new("Frame")
PCContent.Size = UDim2.new(1, 0, 1, 0)
PCContent.BackgroundTransparency = 1
PCContent.Visible = not isMobileMode
PCContent.Parent = Content

local Frame2 = Instance.new("Frame")
Frame2.ZIndex = 3
Frame2.Size = UDim2.new(1, 0, 0, 26)
Frame2.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
Frame2.BackgroundTransparency = 0.2
Frame2.BorderSizePixel = 0
Frame2.Parent = PCContent
Instance.new("UICorner", Frame2)

local TextLabel = Instance.new("TextLabel")
TextLabel.ZIndex = 4
TextLabel.Position = UDim2.new(0, 8, 0, 0)
TextLabel.Size = UDim2.new(0, 52, 1, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "Anti-Bat"
TextLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TextLabel.TextSize = 10
TextLabel.Font = Enum.Font.GothamBold
TextLabel.TextXAlignment = Enum.TextXAlignment.Left
TextLabel.Parent = Frame2

local KeybindBtn = Instance.new("TextButton")
KeybindBtn.ZIndex = 10
KeybindBtn.AnchorPoint = Vector2.new(0, 0.5)
KeybindBtn.Position = UDim2.new(0, 62, 0.5, 0)
KeybindBtn.Size = UDim2.new(0, 28, 0, 14)
KeybindBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
KeybindBtn.BackgroundTransparency = 0.15
KeybindBtn.Text = CurrentKeybind.Name
KeybindBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
KeybindBtn.Font = Enum.Font.GothamBold
KeybindBtn.Parent = Frame2
Instance.new("UICorner", KeybindBtn).CornerRadius = UDim.new(0, 5)

local AntiBatToggleBg = Instance.new("Frame")
AntiBatToggleBg.ZIndex = 4
AntiBatToggleBg.AnchorPoint = Vector2.new(1, 0.5)
AntiBatToggleBg.Position = UDim2.new(1, -8, 0.5, 0)
AntiBatToggleBg.Size = UDim2.new(0, 28, 0, 14)
AntiBatToggleBg.BackgroundColor3 = Color3.fromRGB(52, 52, 58)
AntiBatToggleBg.BorderSizePixel = 0
AntiBatToggleBg.Parent = Frame2
Instance.new("UICorner", AntiBatToggleBg).CornerRadius = UDim.new(1, 0)

local AntiBatKnob = Instance.new("Frame")
AntiBatKnob.ZIndex = 5
AntiBatKnob.AnchorPoint = Vector2.new(0, 0.5)
AntiBatKnob.Position = UDim2.new(0, 2, 0.5, 0)
AntiBatKnob.Size = UDim2.new(0, 10, 0, 10)
AntiBatKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
AntiBatKnob.BorderSizePixel = 0
AntiBatKnob.Parent = AntiBatToggleBg
Instance.new("UICorner", AntiBatKnob).CornerRadius = UDim.new(1, 0)

local AntiBatClick = Instance.new("TextButton")
AntiBatClick.ZIndex = 6
AntiBatClick.Size = UDim2.new(1, 0, 1, 0)
AntiBatClick.BackgroundTransparency = 1
AntiBatClick.Text = ""
AntiBatClick.Parent = Frame2

local MobileContent = Instance.new("Frame")
MobileContent.Size = UDim2.new(1, 0, 1, 0)
MobileContent.BackgroundTransparency = 1
MobileContent.Visible = isMobileMode
MobileContent.Parent = Content

local MobileAntiBatBtn = Instance.new("TextButton")
MobileAntiBatBtn.ZIndex = 3
MobileAntiBatBtn.Size = UDim2.new(1, 0, 0, 26)
MobileAntiBatBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
MobileAntiBatBtn.BackgroundTransparency = 0.15
MobileAntiBatBtn.Text = "ANTI-BAT"
MobileAntiBatBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
MobileAntiBatBtn.TextSize = 11
MobileAntiBatBtn.Font = Enum.Font.GothamBold
MobileAntiBatBtn.AutoButtonColor = false
MobileAntiBatBtn.Parent = MobileContent
Instance.new("UICorner", MobileAntiBatBtn).CornerRadius = UDim.new(0, 8)
local UIStrokeM1 = Instance.new("UIStroke", MobileAntiBatBtn)
UIStrokeM1.Color = Color3.fromRGB(120, 120, 130)
UIStrokeM1.Transparency = 0.2

local Footer = Instance.new("TextLabel")
Footer.ZIndex = 3
Footer.Position = UDim2.new(0, 0, 1, -13)
Footer.Size = UDim2.new(1, 0, 0, 13)
Footer.BackgroundTransparency = 1
Footer.Text = "Anti-Bat | Anti Ragdoll"
Footer.TextColor3 = Color3.fromRGB(190, 190, 195)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 9
Footer.Parent = Content

local function setToggle(knob, bg, enabled)
	TweenService:Create(knob, TweenInfo.new(0.15), {
		Position = enabled and UDim2.new(1, -12, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		BackgroundColor3 = enabled and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
	}):Play()
	TweenService:Create(bg, TweenInfo.new(0.15), {
		BackgroundColor3 = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(52, 52, 58)
	}):Play()
end

local function updateMobileButtons()
	if AntiBatEnabled then
		MobileAntiBatBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
		UIStrokeM1.Transparency = 0
	else
		MobileAntiBatBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
		UIStrokeM1.Transparency = 0.2
	end
end

local function toggleAntiBat()
	AntiBatEnabled = not AntiBatEnabled
	if AntiBatEnabled then startAntiBat() else stopAntiBat() end
	setToggle(AntiBatKnob, AntiBatToggleBg, AntiBatEnabled)
	updateMobileButtons()
end

AntiBatClick.MouseButton1Click:Connect(toggleAntiBat)
MobileAntiBatBtn.MouseButton1Click:Connect(toggleAntiBat)

KeybindBtn.MouseButton1Click:Connect(function()
	if WaitingForKeybind then return end
	WaitingForKeybind = true
	KeybindBtn.Text = "..."
	KeybindBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if WaitingForKeybind then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			CurrentKeybind = input.KeyCode
			WaitingForKeybind = false
			KeybindBtn.Text = CurrentKeybind.Name
			KeybindBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
			saveConfig()
		end
		return
	end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == CurrentKeybind then
		toggleAntiBat()
	end
end)

ModeToggle.MouseButton1Click:Connect(function()
	isMobileMode = not isMobileMode
	ModeToggle.Text = isMobileMode and "PC" or "MOBILE"
	PCContent.Visible = not isMobileMode
	MobileContent.Visible = isMobileMode
	saveConfig()
end)

local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

startAntiRagdoll()
setToggle(AntiBatKnob, AntiBatToggleBg, false)
updateMobileButtons()
Main.Visible = false
function AstaToggleAntiBatPanel()
	Main.Visible = not Main.Visible
end

end

-- ================= Asta Anti Anti Desync Panel (Misc) =================
do

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local NetworkClient = game:GetService("NetworkClient")
local LocalPlayer = Players.LocalPlayer

local CONFIG_FILE = "Asta_AntiDesync_Config.json"
local DesyncEnabled = false
local CurrentKeybind = Enum.KeyCode.Delete
local WaitingForKeybind = false
local isMobileMode = true

local FAKE_ROOT_NAME = "DavidDesyncRoot"
local FAKE_ROOT_Y = -2500
local FAKE_ROOT_VELOCITY = Vector3.new(0, -1000, 0)

local envTable = (typeof(getgenv) == "function") and getgenv() or _G
local charConn = nil
local stepConn = nil
local fakeRoot = nil
local trackedChar = nil
local trackedRoot = nil
local repRootOwner = nil

local function saveConfig()
	pcall(function()
		if writefile then
			writefile(CONFIG_FILE, HttpService:JSONEncode({
				Keybind = CurrentKeybind.Name,
				MobileMode = isMobileMode,
			}))
		end
	end)
end

local function loadConfig()
	local ok, data = pcall(function()
		if isfile and isfile(CONFIG_FILE) then
			return HttpService:JSONDecode(readfile(CONFIG_FILE))
		end
	end)
	if ok and data then
		if data.Keybind and Enum.KeyCode[data.Keybind] then
			CurrentKeybind = Enum.KeyCode[data.Keybind]
		end
		if data.MobileMode ~= nil then isMobileMode = data.MobileMode end
	end
end
loadConfig()

local function isBasePart(inst)
	if not inst then return false end
	local ok, res = pcall(function() return inst:IsA("BasePart") end)
	return ok and res == true
end

local function findGlobalFunction(...)
	for i = 1, select("#", ...) do
		local name = select(i, ...)
		local value = rawget(envTable, name)
		if type(value) == "function" then return value end
	end
	return nil
end

local function setHidden(inst, prop, value)
	if not inst then return false end
	local setter = findGlobalFunction("sethiddenproperty", "set_hidden_property", "sethiddenprop", "set_hidden_prop")
	if setter then
		local ok = pcall(setter, inst, prop, value)
		if ok then return true end
	end
	return pcall(function() inst[prop] = value end)
end

local function getHidden(inst, prop)
	if not inst then return false, nil end
	local getter = findGlobalFunction("gethiddenproperty", "get_hidden_property", "gethiddenprop", "get_hidden_prop")
	if getter then
		local ok, value = pcall(getter, inst, prop)
		if ok then return true, value end
	end
	local ok, value = pcall(function() return inst[prop] end)
	return ok, value
end

local function getCurrentRoot(char)
	char = char or LocalPlayer.Character
	if not char then return nil end
	local ok, root = pcall(function() return char:FindFirstChild("HumanoidRootPart") end)
	if ok and isBasePart(root) then return root end
	return nil
end

local function configurePhysics()
	setHidden(LocalPlayer, "MaximumSimulationRadius", math.huge)
	setHidden(LocalPlayer, "SimulationRadius", math.huge)
	pcall(function()
		settings().Network.InterpolationThrottling = Enum.InterpolationThrottlingMode.Disabled
	end)
	pcall(function()
		settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
		settings().Physics.AllowSleep = false
	end)
	pcall(function() NetworkClient:SetOutgoingKBPSLimit(math.huge) end)
end
configurePhysics()

local function fakeRootIsUsable()
	if not isBasePart(fakeRoot) then return false end
	local ok, parent = pcall(function() return fakeRoot.Parent end)
	return ok and parent ~= nil
end

local function destroyFakeRoot()
	local fake = fakeRoot
	fakeRoot = nil
	if fake then pcall(function() fake:Destroy() end) end
end

local function restoreReplicationRoot()
	local owner = repRootOwner or trackedRoot
	if isBasePart(owner) then
		setHidden(owner, "PhysicsRepRootPart", owner)
	end
	repRootOwner = nil
end

local function createFakeRoot(rootPart)
	destroyFakeRoot()
	local fake = Instance.new("Part")
	fake.Name = FAKE_ROOT_NAME
	fake.Size = Vector3.new(2, 2, 1)
	fake.Anchored = true
	fake.CanCollide = false
	fake.CanTouch = false
	fake.CanQuery = false
	fake.Transparency = 1
	fake.CFrame = CFrame.new(0, FAKE_ROOT_Y, 0)
	fake.Parent = Workspace
	pcall(function() fake.AssemblyLinearVelocity = FAKE_ROOT_VELOCITY end)
	local ok, pos = pcall(function() return rootPart.Position end)
	if ok then fake.CFrame = CFrame.new(pos.X, FAKE_ROOT_Y, pos.Z) end
	fakeRoot = fake
	return fake
end

local function assignFakeReplicationRoot(rootPart, fake)
	if not isBasePart(rootPart) or not isBasePart(fake) then return false end
	setHidden(rootPart, "PhysicsRepRootPart", rootPart)
	repRootOwner = rootPart
	return setHidden(rootPart, "PhysicsRepRootPart", fake)
end

local function stepDesync()
	if not DesyncEnabled then return end
	local root = trackedRoot
	if not isBasePart(root) then
		root = getCurrentRoot(trackedChar)
		trackedRoot = root
	end
	if not root then return end

	if not fakeRootIsUsable() then
		local fake = createFakeRoot(root)
		assignFakeReplicationRoot(root, fake)
		return
	end

	local fake = fakeRoot
	local ok, rootPos, fakePos = pcall(function() return root.Position, fake.Position end)
	if ok and rootPos and fakePos and (
		math.abs(rootPos.X - fakePos.X) > 0.01
		or math.abs(rootPos.Z - fakePos.Z) > 0.01
		or math.abs(fakePos.Y - FAKE_ROOT_Y) > 0.01
	) then
		pcall(function() fake.CFrame = CFrame.new(rootPos.X, FAKE_ROOT_Y, rootPos.Z) end)
	end

	pcall(function()
		fake.Anchored = true
		fake.AssemblyLinearVelocity = FAKE_ROOT_VELOCITY
	end)

	local gotValue, current = getHidden(root, "PhysicsRepRootPart")
	if not gotValue or current ~= fake then
		setHidden(root, "PhysicsRepRootPart", fake)
	end
end

local function stopStepConnection()
	if stepConn then stepConn:Disconnect() stepConn = nil end
end

local function startStepConnection()
	stopStepConnection()
	stepConn = RunService.Stepped:Connect(stepDesync)
end

local function bindCharacter(char)
	local oldRoot = trackedRoot
	trackedChar = char
	trackedRoot = getCurrentRoot(char)

	if DesyncEnabled then
		if isBasePart(oldRoot) and oldRoot ~= trackedRoot then
			setHidden(oldRoot, "PhysicsRepRootPart", oldRoot)
		end
		destroyFakeRoot()
		local root = trackedRoot
		if not root and char then
			local ok, waited = pcall(function() return char:WaitForChild("HumanoidRootPart", 8) end)
			if ok and isBasePart(waited) then root = waited trackedRoot = root end
		end
		if root then
			local fake = createFakeRoot(root)
			assignFakeReplicationRoot(root, fake)
			startStepConnection()
		end
	end
end

bindCharacter(LocalPlayer.Character)
if charConn then charConn:Disconnect() end
charConn = LocalPlayer.CharacterAdded:Connect(function(char)
	task.defer(bindCharacter, char)
end)

-- ================= UI =================

local gui = Instance.new("ScreenGui")
gui.Name = "PRODIGY Anti Desync"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Visible = false
Main.Name = "Main"
Main.Active = true
Main.ClipsDescendants = true
Main.Position = UDim2.new(0.5, -90, 0.5, -44)
Main.Size = UDim2.new(0, 180, 0, 88)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.BorderSizePixel = 0
Main.Parent = gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(110, 110, 120)
stroke.Thickness = 1.5
stroke.Transparency = 0.25

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Active = true
Header.ZIndex = 2
Header.Size = UDim2.new(1, 0, 0, 28)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.ZIndex = 3
Title.Position = UDim2.new(0, 8, 0, 0)
Title.Size = UDim2.new(1, -56, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "PRODIGY Anti Desync"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextSize = 9
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextStrokeTransparency = 0.5
Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Title.Parent = Header

local ModeToggle = Instance.new("TextButton")
ModeToggle.ZIndex = 4
ModeToggle.AnchorPoint = Vector2.new(1, 0.5)
ModeToggle.Position = UDim2.new(1, -8, 0.5, 0)
ModeToggle.Size = UDim2.new(0, 38, 0, 16)
ModeToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
ModeToggle.BackgroundTransparency = 0.25
ModeToggle.Text = isMobileMode and "PC" or "MOBILE"
ModeToggle.TextColor3 = Color3.fromRGB(240, 240, 240)
ModeToggle.TextSize = 7
ModeToggle.Font = Enum.Font.GothamBold
ModeToggle.Parent = Header
Instance.new("UICorner", ModeToggle).CornerRadius = UDim.new(0, 6)

local Content = Instance.new("Frame")
Content.ZIndex = 2
Content.Position = UDim2.new(0, 8, 0, 30)
Content.Size = UDim2.new(1, -16, 1, -40)
Content.BackgroundTransparency = 1
Content.Parent = Main

local PCContent = Instance.new("Frame")
PCContent.Size = UDim2.new(1, 0, 1, 0)
PCContent.BackgroundTransparency = 1
PCContent.Visible = not isMobileMode
PCContent.Parent = Content

local Row = Instance.new("Frame")
Row.ZIndex = 3
Row.Size = UDim2.new(1, 0, 0, 26)
Row.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
Row.BackgroundTransparency = 0.2
Row.BorderSizePixel = 0
Row.Parent = PCContent
Instance.new("UICorner", Row)

local RowLabel = Instance.new("TextLabel")
RowLabel.ZIndex = 4
RowLabel.Position = UDim2.new(0, 8, 0, 0)
RowLabel.Size = UDim2.new(0, 52, 1, 0)
RowLabel.BackgroundTransparency = 1
RowLabel.Text = "Anti Anti"
RowLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
RowLabel.TextSize = 10
RowLabel.Font = Enum.Font.GothamBold
RowLabel.TextXAlignment = Enum.TextXAlignment.Left
RowLabel.Parent = Row

local KeybindBtn = Instance.new("TextButton")
KeybindBtn.ZIndex = 10
KeybindBtn.AnchorPoint = Vector2.new(0, 0.5)
KeybindBtn.Position = UDim2.new(0, 62, 0.5, 0)
KeybindBtn.Size = UDim2.new(0, 34, 0, 14)
KeybindBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
KeybindBtn.BackgroundTransparency = 0.15
KeybindBtn.Text = CurrentKeybind.Name
KeybindBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
KeybindBtn.TextSize = 8
KeybindBtn.Font = Enum.Font.GothamBold
KeybindBtn.Parent = Row
Instance.new("UICorner", KeybindBtn).CornerRadius = UDim.new(0, 5)

local ToggleBg = Instance.new("Frame")
ToggleBg.ZIndex = 4
ToggleBg.AnchorPoint = Vector2.new(1, 0.5)
ToggleBg.Position = UDim2.new(1, -8, 0.5, 0)
ToggleBg.Size = UDim2.new(0, 28, 0, 14)
ToggleBg.BackgroundColor3 = Color3.fromRGB(52, 52, 58)
ToggleBg.BorderSizePixel = 0
ToggleBg.Parent = Row
Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(1, 0)

local Knob = Instance.new("Frame")
Knob.ZIndex = 5
Knob.AnchorPoint = Vector2.new(0, 0.5)
Knob.Position = UDim2.new(0, 2, 0.5, 0)
Knob.Size = UDim2.new(0, 10, 0, 10)
Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Knob.BorderSizePixel = 0
Knob.Parent = ToggleBg
Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

local ToggleClick = Instance.new("TextButton")
ToggleClick.ZIndex = 6
ToggleClick.Size = UDim2.new(1, 0, 1, 0)
ToggleClick.BackgroundTransparency = 1
ToggleClick.Text = ""
ToggleClick.Parent = Row

local MobileContent = Instance.new("Frame")
MobileContent.Size = UDim2.new(1, 0, 1, 0)
MobileContent.BackgroundTransparency = 1
MobileContent.Visible = isMobileMode
MobileContent.Parent = Content

local MobileBtn = Instance.new("TextButton")
MobileBtn.ZIndex = 3
MobileBtn.Size = UDim2.new(1, 0, 0, 26)
MobileBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
MobileBtn.BackgroundTransparency = 0.15
MobileBtn.Text = "ANTI ANTI"
MobileBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
MobileBtn.TextSize = 11
MobileBtn.Font = Enum.Font.GothamBold
MobileBtn.AutoButtonColor = false
MobileBtn.Parent = MobileContent
Instance.new("UICorner", MobileBtn).CornerRadius = UDim.new(0, 8)
local MobileStroke = Instance.new("UIStroke", MobileBtn)
MobileStroke.Color = Color3.fromRGB(120, 120, 130)
MobileStroke.Transparency = 0.2

local Footer = Instance.new("TextLabel")
Footer.ZIndex = 3
Footer.Position = UDim2.new(0, 0, 1, -13)
Footer.Size = UDim2.new(1, 0, 0, 13)
Footer.BackgroundTransparency = 1
Footer.Text = "Anti Anti | Desync"
Footer.TextColor3 = Color3.fromRGB(190, 190, 195)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 9
Footer.Parent = Content

local function setToggleVisual(enabled)
	TweenService:Create(Knob, TweenInfo.new(0.15), {
		Position = enabled and UDim2.new(1, -12, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		BackgroundColor3 = enabled and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
	}):Play()
	TweenService:Create(ToggleBg, TweenInfo.new(0.15), {
		BackgroundColor3 = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(52, 52, 58)
	}):Play()
	if enabled then
		MobileBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
		MobileStroke.Transparency = 0
	else
		MobileBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
		MobileStroke.Transparency = 0.2
	end
end

local function setDesyncEnabled(value)
	value = value == true
	if value == DesyncEnabled then setToggleVisual(value) return end
	DesyncEnabled = value
	if value then
		local root = getCurrentRoot(trackedChar)
		trackedRoot = root
		if not root then
			DesyncEnabled = false
			setToggleVisual(false)
			return
		end
		local fake = createFakeRoot(root)
		assignFakeReplicationRoot(root, fake)
		startStepConnection()
	else
		stopStepConnection()
		restoreReplicationRoot()
		destroyFakeRoot()
	end
	setToggleVisual(DesyncEnabled)
end

local function toggleDesync()
	setDesyncEnabled(not DesyncEnabled)
end

ToggleClick.MouseButton1Click:Connect(toggleDesync)
MobileBtn.MouseButton1Click:Connect(toggleDesync)

KeybindBtn.MouseButton1Click:Connect(function()
	if WaitingForKeybind then return end
	WaitingForKeybind = true
	KeybindBtn.Text = "..."
	KeybindBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if WaitingForKeybind then
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
			if input.KeyCode ~= Enum.KeyCode.Escape then CurrentKeybind = input.KeyCode end
			WaitingForKeybind = false
			KeybindBtn.Text = CurrentKeybind.Name
			KeybindBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
			saveConfig()
		end
		return
	end
	if gp then return end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == CurrentKeybind then
		toggleDesync()
	end
end)

ModeToggle.MouseButton1Click:Connect(function()
	isMobileMode = not isMobileMode
	ModeToggle.Text = isMobileMode and "PC" or "MOBILE"
	PCContent.Visible = not isMobileMode
	MobileContent.Visible = isMobileMode
	saveConfig()
end)

local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

setToggleVisual(false)
Main.Visible = false
function AstaToggleAntiDesyncPanel()
	Main.Visible = not Main.Visible
end

end

-- ================= ASTA BG PICKER (quadradinhos) =================
do

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local BG_CHOICES = {
	"rbxassetid://136208130767349",
	"rbxassetid://126793180958099",
	"rbxassetid://105542572852370",
	"rbxassetid://128997600029394",
	"rbxassetid://99420703803809",
	"rbxassetid://117186687504218",
	"rbxassetid://123015462349687",
	"rbxassetid://111195293067618",
	"rbxassetid://133619037676439",
	"rbxassetid://116985758139639",
	"rbxassetid://132062039944824",
	"rbxassetid://139571679676131",
	"rbxassetid://70418952815837",
}

local pickerGui = Instance.new("ScreenGui")
pickerGui.Name = "AstaBgPicker"
pickerGui.ResetOnSpawn = false
pickerGui.DisplayOrder = 12
pickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pickerGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0, 44, 0, 20)
OpenBtn.Position = UDim2.new(0, 8, 0.5, -10)
OpenBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
OpenBtn.BackgroundTransparency = 0.1
OpenBtn.Text = "BG"
OpenBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
OpenBtn.TextSize = 10
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Parent = pickerGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 8)
local obStroke = Instance.new("UIStroke", OpenBtn)
obStroke.Color = Color3.fromRGB(120, 120, 130)
obStroke.Transparency = 0.3

local Win = Instance.new("Frame")
Win.Name = "Win"
Win.Visible = false
Win.Size = UDim2.new(0, 210, 0, 190)
Win.Position = UDim2.new(0.5, -105, 0.5, -75)
Win.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Win.BorderSizePixel = 0
Win.ClipsDescendants = true
Win.Active = true
Win.Parent = pickerGui
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 10)
local winStroke = Instance.new("UIStroke", Win)
winStroke.Color = Color3.fromRGB(110, 110, 120)
winStroke.Thickness = 1.5
winStroke.Transparency = 0.25

local WinTitle = Instance.new("TextLabel")
WinTitle.Size = UDim2.new(1, 0, 0, 24)
WinTitle.BackgroundTransparency = 1
WinTitle.Text = "Escolher fundo"
WinTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
WinTitle.TextSize = 11
WinTitle.Font = Enum.Font.GothamBold
WinTitle.Parent = Win

local target = "antibat"
local function mkTargetBtn(text, xOff)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0.5, -12, 0, 20)
	b.Position = UDim2.new(0, xOff, 0, 26)
	b.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
	b.Text = text
	b.TextColor3 = Color3.fromRGB(240, 240, 240)
	b.TextSize = 9
	b.Font = Enum.Font.GothamBold
	b.Parent = Win
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end
local BtnAntiBat = mkTargetBtn("Anti-Bat", 8)
local BtnDesync = mkTargetBtn("Anti Anti", 113)
local BtnHub = mkTargetBtn("Fundo (Interface)", 8)
BtnHub.Size = UDim2.new(0.5, -12, 0, 20)
BtnHub.Position = UDim2.new(0, 8, 0, 48)
local BtnFloat = mkTargetBtn("Botões Flutuantes", 113)
BtnFloat.Position = UDim2.new(0, 113, 0, 48)

local function refreshTargets()
	BtnAntiBat.BackgroundColor3 = (target == "antibat") and Color3.fromRGB(80, 80, 92) or Color3.fromRGB(34, 34, 40)
	BtnDesync.BackgroundColor3 = (target == "desync") and Color3.fromRGB(80, 80, 92) or Color3.fromRGB(34, 34, 40)
	BtnHub.BackgroundColor3 = (target == "hub") and Color3.fromRGB(80, 80, 92) or Color3.fromRGB(34, 34, 40)
	BtnFloat.BackgroundColor3 = (target == "float") and Color3.fromRGB(80, 80, 92) or Color3.fromRGB(34, 34, 40)
end
BtnAntiBat.MouseButton1Click:Connect(function() target = "antibat"; refreshTargets() end)
BtnDesync.MouseButton1Click:Connect(function() target = "desync"; refreshTargets() end)
BtnHub.MouseButton1Click:Connect(function() target = "hub"; refreshTargets() end)
BtnFloat.MouseButton1Click:Connect(function() target = "float"; refreshTargets() end)
refreshTargets()

local Grid = Instance.new("ScrollingFrame")
Grid.Position = UDim2.new(0, 8, 0, 74)
Grid.Size = UDim2.new(1, -16, 1, -82)
Grid.BackgroundTransparency = 1
Grid.ScrollBarThickness = 3
Grid.CanvasSize = UDim2.new(0, 0, 0, 0)
Grid.AutomaticCanvasSize = Enum.AutomaticSize.Y
Grid.Parent = Win
local gridLayout = Instance.new("UIGridLayout", Grid)
gridLayout.CellSize = UDim2.new(0, 44, 0, 44)
gridLayout.CellPadding = UDim2.new(0, 6, 0, 6)

local function applyHubBG(imgId)
	local done = false
	local hideBg = (imgId == "" or imgId == nil)
	local decal = _G.AstaHubBgDecal
	if decal and decal.Parent then
		decal.Image = imgId or ""
		decal.ImageTransparency = hideBg and 1 or 0
		done = true
	end
	local parents = { LocalPlayer:FindFirstChildOfClass("PlayerGui") }
	pcall(function() table.insert(parents, game:GetService("CoreGui")) end)
	pcall(function() local ok, hui = pcall(gethui) if ok and hui then table.insert(parents, hui) end end)
	for _, p in ipairs(parents) do
		local g = p and p:FindFirstChild("Asta Hub")
		local m = g and g:FindFirstChild("Frame")
		if g and not m then
			for _, c in ipairs(g:GetChildren()) do if c:IsA("Frame") then m = c break end end
		end
		if m then
			for _, d in ipairs(m:GetChildren()) do
				if d:IsA("ImageLabel") and d.ZIndex <= 1 then
					d.Image = imgId or ""
					d.ImageTransparency = hideBg and 1 or 0
					done = true
				end
			end
		end
	end
	return done
end

local function applyBGRaw(imgId, tgt)
	if tgt == "hub" then
		applyHubBG(imgId)
	elseif tgt == "antibat" then
		local g = LocalPlayer.PlayerGui:FindFirstChild("PRODIGY Anti-Bat")
		local main = g and g:FindFirstChild("Main")
		if main then
			local hideBg = (imgId == "" or imgId == nil)
			local sb = main:FindFirstChild("SpaceBackground")
			if sb then sb.Image = imgId or "" sb.ImageTransparency = hideBg and 1 or 0 end
			local ab = main:FindFirstChild("AntiAntiBackground")
			if ab then ab.Image = imgId or "" ab.ImageTransparency = hideBg and 1 or 0 end
		end
	elseif tgt == "float" then
		if astaSetFloatBg then astaSetFloatBg(imgId) end
	else
		if _G.AstaSetAntiAntiBg then _G.AstaSetAntiAntiBg(imgId) end
		local parents = { LocalPlayer:FindFirstChildOfClass("PlayerGui") }
		pcall(function() local ok, hui = pcall(gethui) if ok and hui then table.insert(parents, hui) end end)
		pcall(function() table.insert(parents, game:GetService("CoreGui")) end)
		for _, p in ipairs(parents) do
			local g = p and (p:FindFirstChild("PRODIGY Anti Desync") or p:FindFirstChild("LarpAntiAntiDesyncGui"))
			if g then
				local bg = g:FindFirstChild("AstaBg", true)
				if bg and bg:IsA("ImageLabel") then
					bg.Image = imgId or ""
					if imgId == "" or imgId == nil then
						bg.Visible = false
					else
						bg.ImageTransparency = 0
						bg.Visible = true
					end
				elseif imgId ~= "" and imgId ~= nil then
					local main = g:FindFirstChild("Main")
					if main then
						local img = Instance.new("ImageLabel")
						img.Name = "AstaBg"
						img.Size = UDim2.new(1, 0, 1, 0)
						img.BackgroundTransparency = 1
						img.ScaleType = Enum.ScaleType.Crop
						img.ZIndex = 1
						img.Image = imgId
						Instance.new("UICorner", img).CornerRadius = UDim.new(0, 10)
						img.Parent = main
					end
				end
			end
		end
	end
end

-- ==================== SALVAR FUNDOS (BG) ====================
local HttpService = game:GetService("HttpService")
local BG_CONFIG_FILE = "AstaHub_BGs.json"
local savedBGs = {}

local function saveBGs()
	pcall(function()
		if writefile then
			writefile(BG_CONFIG_FILE, HttpService:JSONEncode(savedBGs))
		end
	end)
end

local function loadBGs()
	local ok, data = pcall(function()
		if isfile and isfile(BG_CONFIG_FILE) then
			return HttpService:JSONDecode(readfile(BG_CONFIG_FILE))
		end
	end)
	if ok and type(data) == "table" then
		for _, k in ipairs({ "antibat", "desync", "hub", "float" }) do
			if type(data[k]) == "string" then savedBGs[k] = data[k] end
		end
	end
end
loadBGs()

local function applyBG(imgId, tgt, skipSave)
	tgt = tgt or target
	pcall(function() applyBGRaw(imgId, tgt) end)
	if not skipSave then
		savedBGs[tgt] = imgId or ""
		saveBGs()
	end
end

local function reapplySavedBGs()
	for _, k in ipairs({ "antibat", "desync", "hub", "float" }) do
		local v = savedBGs[k]
		if type(v) == "string" then
			applyBG(v, k, true)
		end
	end
end

_G.AstaReapplyBGs = reapplySavedBGs

-- reaplica varias vezes: as GUIs (Anti-Bat / Anti Desync / flutuantes)
-- podem ser criadas depois do hub carregar, e ao renascer
task.spawn(function()
	for _ = 1, 60 do
		pcall(reapplySavedBGs)
		task.wait(1)
	end
	while true do
		pcall(reapplySavedBGs)
		task.wait(5)
	end
end)

pcall(function()
	LocalPlayer.CharacterAdded:Connect(function()
		task.delay(2, function() pcall(reapplySavedBGs) end)
		task.delay(6, function() pcall(reapplySavedBGs) end)
	end)
end)


do
	local off = Instance.new("TextButton")
	off.Size = UDim2.new(0, 44, 0, 44)
	off.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	off.Text = "OFF"
	off.TextColor3 = Color3.fromRGB(255, 90, 90)
	off.TextSize = 10
	off.Font = Enum.Font.GothamBold
	off.LayoutOrder = -1
	off.Parent = Grid
	Instance.new("UICorner", off).CornerRadius = UDim.new(0, 6)
	local os2 = Instance.new("UIStroke", off)
	os2.Color = Color3.fromRGB(255, 90, 90)
	os2.Transparency = 0.4
	off.MouseButton1Click:Connect(function()
		applyBG("")
	end)
end

for _, imgId in ipairs(BG_CHOICES) do
	local sq = Instance.new("ImageButton")
	sq.Size = UDim2.new(0, 44, 0, 44)
	sq.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	sq.Image = imgId
	sq.ScaleType = Enum.ScaleType.Crop
	sq.Parent = Grid
	Instance.new("UICorner", sq).CornerRadius = UDim.new(0, 6)
	local s = Instance.new("UIStroke", sq)
	s.Color = Color3.fromRGB(120, 120, 130)
	s.Transparency = 0.4
	sq.MouseButton1Click:Connect(function()
		applyBG(imgId)
	end)
end

OpenBtn.Visible = false
OpenBtn.MouseButton1Click:Connect(function()
	Win.Visible = not Win.Visible
end)

function _G.AstaToggleBgPicker()
	Win.Visible = not Win.Visible
end

local dragging, dragStart, startPos
WinTitle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Win.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

end

-- ==================== PRODIGY HUB :: BORDA VERDE EM TODOS OS BOTOES FLUTUANTES ====================
do
	local PRODIGY_GREEN = Color3.fromRGB(0, 255, 120)
	local GUI_NAMES = { "InstaResetButton", "BatV2Button", "TpBatButton", "AntiDesyncButton", "AstaHubMobilePanel" }

	local function near(v, t, tol) return math.abs(v - t) <= tol end
	local function isGreen(c)
		if not c then return false end
		return near(c.R * 255, 0, 20) and near(c.G * 255, 255, 20) and near(c.B * 255, 120, 40)
	end
	local function isSilver(c)
		if not c then return false end
		return near(c.R * 255, 180, 8) and near(c.G * 255, 180, 8) and near(c.B * 255, 190, 8)
	end

	local function isActive(obj)
		local st = obj:FindFirstChild("AstaActiveStroke")
		if st and st:IsA("UIStroke") and st.Enabled then return true end
		for _, d in ipairs(obj:GetChildren()) do
			if d:IsA("TextLabel") and isGreen(d.TextColor3) then return true end
		end
		if obj:IsA("TextLabel") or obj:IsA("TextButton") then
			if isGreen(obj.TextColor3) then return true end
		end
		if isSilver(obj.BackgroundColor3) then return true end
		return false
	end

	local function ensureStroke(obj)
		local s = obj:FindFirstChild("ProdigyGreenStroke")
		if not s then
			s = Instance.new("UIStroke")
			s.Name = "ProdigyGreenStroke"
			s.Color = PRODIGY_GREEN
			s.Thickness = 3
			s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			s.Transparency = 0
			s.Enabled = false
			s.Parent = obj
		end
		return s
	end

	local function collect()
		local out = {}
		local roots = {}
		pcall(function() table.insert(roots, game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")) end)
		pcall(function() table.insert(roots, game:GetService("CoreGui")) end)
		pcall(function() local ok, hui = pcall(gethui) if ok and hui then table.insert(roots, hui) end end)
		for _, root in ipairs(roots) do
			if root then
				for _, g in ipairs(root:GetChildren()) do
					if g:IsA("ScreenGui") then
						local match = (string.sub(g.Name, 1, 8) == "AstaHub_")
						if not match then
							for _, n in ipairs(GUI_NAMES) do if g.Name == n then match = true break end end
						end
						if match then
							for _, d in ipairs(g:GetDescendants()) do
								if (d:IsA("Frame") or d:IsA("TextButton") or d:IsA("ImageButton"))
									and d.Name ~= "AstaFloatBg"
									and d:FindFirstChildOfClass("UICorner")
									and d.AbsoluteSize.X <= 140 and d.AbsoluteSize.Y <= 140
									and d.AbsoluteSize.X >= 20 then
									table.insert(out, d)
								end
							end
						end
					end
				end
			end
		end
		return out
	end

	task.spawn(function()
		while true do
			pcall(function()
				for _, obj in ipairs(collect()) do
					local s = ensureStroke(obj)
					local on = isActive(obj)
					s.Enabled = on
					local ns = obj:FindFirstChild("NormalStroke")
					if ns and ns:IsA("UIStroke") then
						if on then
							ns.Color = PRODIGY_GREEN
							ns.Thickness = 2.4
							ns.Transparency = 0
						else
							ns.Color = Color3.fromRGB(70, 70, 70)
							ns.Thickness = 1.2
							ns.Transparency = 0.4
						end
					end
				end
			end)
			task.wait(0.12)
		end
	end)
end

-- ==================== PRODIGY HUB :: ANTI DIE V2 (nao toma reset usando TP) ====================
do
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local LP = Players.LocalPlayer

	local AD = { on = false, conns = {}, step = nil, hum = nil, char = nil, safe = nil, lastSafe = 0 }
	_G.ProdigyAntiDie = AD

	local function clearConns()
		for _, c in ipairs(AD.conns) do pcall(function() c:Disconnect() end) end
		AD.conns = {}
	end

	local function protectHum(hum)
		if not hum then return end
		pcall(function() hum.BreakJointsOnDeath = false end)
		pcall(function() hum.RequiresNeck = false end)
		pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
		pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end)
		pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end)
		pcall(function() if hum.MaxHealth <= 0 or hum.MaxHealth ~= hum.MaxHealth then hum.MaxHealth = 100 end end)
	end

	local function unprotectHum(hum)
		if not hum then return end
		pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) end)
		pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true) end)
		pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true) end)
	end

	local function revive(hum)
		if not hum then return end
		pcall(function()
			if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
			local st = hum:GetState()
			if st == Enum.HumanoidStateType.Dead then
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
				hum.Health = hum.MaxHealth
			end
		end)
	end

	local function bind(char)
		if not AD.on or not char then return end
		clearConns()
		AD.char = char
		local hum = char:FindFirstChildOfClass("Humanoid")
		AD.hum = hum
		protectHum(hum)
		if hum then
			table.insert(AD.conns, hum.HealthChanged:Connect(function(h)
				if not AD.on then return end
				if h < hum.MaxHealth then revive(hum) end
			end))
			table.insert(AD.conns, hum.Died:Connect(function()
				if not AD.on then return end
				revive(hum)
			end))
			table.insert(AD.conns, hum.StateChanged:Connect(function(_, new)
				if not AD.on then return end
				if new == Enum.HumanoidStateType.Dead or new == Enum.HumanoidStateType.Ragdoll then
					pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
					revive(hum)
				end
			end))
		end
		-- protege contra remocao de partes vitais (morte por reset/void em TP)
		table.insert(AD.conns, char.ChildRemoved:Connect(function(obj)
			if not AD.on then return end
			if obj and (obj.Name == "Head" or obj.Name == "HumanoidRootPart" or obj.Name == "Humanoid") then
				task.defer(function()
					local h = char:FindFirstChildOfClass("Humanoid")
					if h then protectHum(h) revive(h) end
				end)
			end
		end))
	end

	local function step()
		if not AD.on then return end
		local char = LP.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hum ~= AD.hum then AD.hum = hum protectHum(hum) end
		if not hum or not hrp then return end

		-- vida sempre cheia
		if hum.Health < hum.MaxHealth then revive(hum) end

		-- estados de morte bloqueados (TP costuma jogar pra Physics/Ragdoll/Dead)
		local st = hum:GetState()
		if st == Enum.HumanoidStateType.Dead or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown then
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
			revive(hum)
		end

		-- anti void: guarda ultima posicao segura e volta se cair do mapa
		local pos = hrp.Position
		if pos.Y > -40 and hrp.AssemblyLinearVelocity.Y > -180 then
			local now = os.clock()
			if now - AD.lastSafe > 0.35 then
				AD.lastSafe = now
				AD.safe = hrp.CFrame
			end
		elseif pos.Y < -120 and AD.safe then
			pcall(function()
				hrp.CFrame = AD.safe + Vector3.new(0, 4, 0)
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end)
			revive(hum)
		end
	end

	function startAntiDie()
		AD.on = true
		_G.AstaAntiDieOn = true
		bind(LP.Character)
		if not AD.step then
			AD.step = RunService.Heartbeat:Connect(function() pcall(step) end)
		end
	end

	function stopAntiDie()
		AD.on = false
		_G.AstaAntiDieOn = false
		if AD.step then AD.step:Disconnect() AD.step = nil end
		clearConns()
		unprotectHum(AD.hum)
		AD.safe = nil
	end

	LP.CharacterAdded:Connect(function(char)
		task.wait(0.15)
		if AD.on then
			AD.safe = nil
			bind(char)
		end
	end)

	if _G.AstaAntiDieOn then task.defer(startAntiDie) end
end
