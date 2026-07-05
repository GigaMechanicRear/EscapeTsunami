--[[
    Escape Tsunami Hub | Rayfield UI
    Auto Complete / Speed Hack / Fly / Noclip / Win Teleport
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({
    Name = "Escape Tsunami Hub",
    LoadingTitle = "NightmareHub",
    LoadingSubtitle = "Enjoy!",
    Theme = "Default",
    ConfigurationSaving = { Enabled = false }
})

local State = {
    AutoComplete = false,
    SpeedEnabled = false,
    WalkSpeed = 16,
    Fly = false,
    FlySpeed = 60,
    Noclip = false,
}

local function getRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if root and hum and hum.Health > 0 then return root, hum end
    return nil
end

-- ================= Win / finish part search =================
local function findWinPart()
    local best, bestY = nil, -math.huge
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            local n = part.Name:lower()
            if n:find("win") or n:find("finish") or n:find("end") or n:find("safe") then
                if part.Position.Y > bestY then
                    best, bestY = part, part.Position.Y
                end
            end
        end
    end
    return best
end

-- highest touchable platform as fallback target
local function findHighestPlatform()
    local best, bestY = nil, -math.huge
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide and part.Size.X >= 4 and part.Size.Z >= 4 then
            if part.Position.Y > bestY and part.Position.Y < 5000 then
                best, bestY = part, part.Position.Y
            end
        end
    end
    return best
end

-- ================= Auto Complete (tween up to finish) =================
local tweening = false
task.spawn(function()
    while task.wait(1) do
        if State.AutoComplete and not tweening then
            pcall(function()
                local root = getRoot()
                if not root then return end
                local target = findWinPart() or findHighestPlatform()
                if not target then return end
                local goal = target.CFrame + Vector3.new(0, target.Size.Y / 2 + 4, 0)
                if (root.Position - goal.Position).Magnitude < 10 then return end

                tweening = true
                local dist = (root.Position - goal.Position).Magnitude
                local tween = TweenService:Create(
                    root,
                    TweenInfo.new(dist / 120, Enum.EasingStyle.Linear),
                    {CFrame = goal}
                )
                tween:Play()
                tween.Completed:Wait()
                tweening = false
            end)
            if not State.AutoComplete then tweening = false end
        end
    end
end)

-- ================= Speed =================
RunService.Heartbeat:Connect(function()
    if State.SpeedEnabled then
        local _, hum = getRoot()
        if hum and hum.WalkSpeed ~= State.WalkSpeed then
            hum.WalkSpeed = State.WalkSpeed
        end
    end
end)

-- ================= Fly =================
local flyBV, flyGyro

local function stopFly()
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyGyro then flyGyro:Destroy() flyGyro = nil end
    local _, hum = getRoot()
    if hum then hum.PlatformStand = false end
end

local function startFly()
    local root, hum = getRoot()
    if not root then return end
    stopFly()
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = root
    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyGyro.P = 9e4
    flyGyro.CFrame = root.CFrame
    flyGyro.Parent = root
end

RunService.RenderStepped:Connect(function()
    if not State.Fly or not flyBV then return end
    pcall(function()
        local root = getRoot()
        if not root then stopFly() return end

        local dir = Vector3.zero
        local cf = Camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end

        if dir.Magnitude > 0 then
            flyBV.Velocity = dir.Unit * State.FlySpeed
        else
            flyBV.Velocity = Vector3.zero
        end
        flyGyro.CFrame = CFrame.new(root.Position, root.Position + cf.LookVector * Vector3.new(1, 0, 1))
    end)
end)

-- ================= Noclip =================
RunService.Stepped:Connect(function()
    if State.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- restore fly parts on respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if State.Fly then pcall(startFly) end
end)

-- ================= UI =================
local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateToggle({
    Name = "Auto Complete (tween to finish)",
    CurrentValue = false,
    Callback = function(Value) State.AutoComplete = Value end
})

MainTab:CreateButton({
    Name = "Win Teleport (instant)",
    Callback = function()
        pcall(function()
            local root = getRoot()
            local target = findWinPart()
            if root and target then
                root.CFrame = target.CFrame + Vector3.new(0, target.Size.Y / 2 + 4, 0)
                Rayfield:Notify({Title = "Win Teleport", Content = "Teleported to " .. target.Name, Duration = 3})
            else
                Rayfield:Notify({Title = "Win Teleport", Content = "No Win/Finish part found.", Duration = 3})
            end
        end)
    end
})

local PlayerTab = Window:CreateTab("Player", 4483362458)

PlayerTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Callback = function(Value)
        State.SpeedEnabled = Value
        if not Value then
            local _, hum = getRoot()
            if hum then hum.WalkSpeed = 16 end
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 2,
    CurrentValue = 16,
    Callback = function(Value) State.WalkSpeed = Value end
})

PlayerTab:CreateToggle({
    Name = "Fly (WASD + Space/Shift)",
    CurrentValue = false,
    Callback = function(Value)
        State.Fly = Value
        if Value then pcall(startFly) else stopFly() end
    end
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {20, 300},
    Increment = 5,
    CurrentValue = 60,
    Callback = function(Value) State.FlySpeed = Value end
})

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(Value) State.Noclip = Value end
})

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

Rayfield:Notify({Title = "Escape Tsunami Hub", Content = "Loaded successfully!", Duration = 4})
