--[[
 .____                  ________ ___.    _____                           __
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  /\___  >____  /__|  \____/|__|
         \/          \/         \/    \/                \/     \/     \/
          Desert Storm -- Verified English Translation
]]--

-- ============================================================
-- SERVICES
-- ============================================================
local CoreGui      = game:GetService("CoreGui")
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UserInput    = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting     = game:GetService("Lighting")

local Camera      = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

if CoreGui:FindFirstChild("Aura_Premium_Menu") then
    CoreGui.Aura_Premium_Menu:Destroy()
end

-- ============================================================
-- COLOR THEME  (verified from decoded original)
-- ============================================================
local Colors = {
    BG0    = Color3.fromRGB(12,  13,  16),
    BG1    = Color3.fromRGB(16,  18,  26),
    BG2    = Color3.fromRGB(19,  21,  30),
    BG3    = Color3.fromRGB(26,  29,  40),
    BG4    = Color3.fromRGB(32,  36,  58),
    Border = Color3.fromRGB(37,  40,  64),
    Accent = Color3.fromRGB(37,  40,  191),
    Green  = Color3.fromRGB(79,  138, 255),
    Orange = Color3.fromRGB(255, 140, 0),
    Red    = Color3.fromRGB(255, 0,   160),
    White  = Color3.fromRGB(255, 64,  96),
    Gray1  = Color3.fromRGB(122, 126, 153),
    Gray2  = Color3.fromRGB(64,  68,  104),
}

-- ============================================================
-- SETTINGS  (verified from decoded original)
-- ============================================================
local Settings = {
    -- aimbot
    Aimbot_Enabled  = true,
    FOV_Radius      = 1500,
    Aim_Part        = "Head",
    Aim_Smoothness  = 0.2,
    Aim_Key         = "Right Click",
    Aim_Priority    = "FOV",
    NoRecoil        = false,
    -- esp
    ESP_Enabled     = false,
    NPC_Enabled     = false,
    ESP_Type        = "2D Box",
    ESP_ShowInfo    = true,
    ESP_Skeleton    = true,
    ESP_MaxDistance = 1000,
    HealthBar       = true,
    Tracer          = false,
    WeaponLabel     = true,
    Loot_Enabled    = false,
    Best_Loot_Only  = false,   -- only show S/A tier weapons in loot ESP
    Radar_Enabled   = false,
    -- visuals
    Crosshair_Enabled = false,
    Crosshair_Style   = "Cross",
}

-- ============================================================
-- HIGH VALUE LOOT TIER TABLE  (weapon names from official tier list)
-- ============================================================
local HighValueLoot = {
    -- S tier → gold label
    ["AK-74M"]   = "S", ["M4A1"]  = "S", ["SV-98"] = "S", ["MPX"]      = "S",
    -- A tier → orange label
    ["AKM"]      = "A", ["AK-101"]= "A", ["HK416"] = "A", ["SR-25"]    = "A",
    ["VSS"]      = "A", ["MP5SD"] = "A", ["Saiga"] = "A",
    -- always show keycards / quest items regardless of Best_Loot_Only
    ["Keycard"]  = "S", ["Key Card"]= "S", ["Access Card"]= "S",
    ["Card"]     = "S", ["Key"]   = "S",
}

local function GetLootTier(name)
    for substr, tier in pairs(HighValueLoot) do
        if name:find(substr) then return tier end
    end
    return nil
end

-- ============================================================
-- NPC TRACKING
-- ============================================================
local NPCTable = {}

local function IsNPC(model)
    if not model or not model:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    return model:FindFirstChildOfClass("Humanoid") ~= nil
end

local function TrackNPC(model)
    task.wait(0.1)
    if not model or not model.Parent then return end
    if model:IsA("Model") and IsNPC(model) then
        NPCTable[model] = true
    end
end

for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("Model") then task.spawn(TrackNPC, obj) end
end
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") then task.spawn(TrackNPC, obj) end
end)
workspace.DescendantRemoving:Connect(function(obj)
    NPCTable[obj] = nil
end)

-- ============================================================
-- GUI SETUP
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Aura_Premium_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 580, 0, 520)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -260)
MainFrame.BackgroundColor3 = Colors.BG0
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local BorderStroke = Instance.new("UIStroke", MainFrame)
BorderStroke.Color = Colors.Border
BorderStroke.Thickness = 1

-- Title bar
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Colors.BG1
TitleBar.BorderSizePixel = 0

local LogoBadge = Instance.new("Frame", TitleBar)
LogoBadge.Size = UDim2.new(0, 22, 0, 22)
LogoBadge.Position = UDim2.new(0, 12, 0.5, -11)
LogoBadge.BackgroundColor3 = Colors.Accent
Instance.new("UICorner", LogoBadge).CornerRadius = UDim.new(0, 4)

local LogoText = Instance.new("TextLabel", LogoBadge)
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "A"
LogoText.TextColor3 = Colors.BG0
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 13

-- Title: "AURA OVERLAY" (verified from decoded original)
local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 42, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "AURA OVERLAY"
TitleLabel.TextColor3 = Colors.Green
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local Divider = Instance.new("Frame", MainFrame)
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.Position = UDim2.new(0, 0, 0, 40)
Divider.BackgroundColor3 = Colors.Border
Divider.BorderSizePixel = 0

-- ============================================================
-- DRAG
-- ============================================================
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = input.Position
        startPos  = MainFrame.Position
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInput.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
UserInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ============================================================
-- SIDEBAR
-- ============================================================
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 160, 1, -41)
Sidebar.Position = UDim2.new(0, 0, 0, 41)
Sidebar.BackgroundColor3 = Colors.BG1
Sidebar.BorderSizePixel = 0

local SidebarDivider = Instance.new("Frame", MainFrame)
SidebarDivider.Size = UDim2.new(0, 1, 1, -41)
SidebarDivider.Position = UDim2.new(0, 160, 0, 41)
SidebarDivider.BackgroundColor3 = Colors.Border
SidebarDivider.BorderSizePixel = 0

-- Category label: "MENU" (verified)
local CategoryLabel = Instance.new("TextLabel", Sidebar)
CategoryLabel.Size = UDim2.new(1, -24, 0, 20)
CategoryLabel.Position = UDim2.new(0, 12, 0, 14)
CategoryLabel.BackgroundTransparency = 1
CategoryLabel.Text = "MENU"
CategoryLabel.TextColor3 = Colors.White
CategoryLabel.Font = Enum.Font.GothamBold
CategoryLabel.TextSize = 10
CategoryLabel.TextXAlignment = Enum.TextXAlignment.Left

local TabScroll = Instance.new("ScrollingFrame", Sidebar)
TabScroll.Size = UDim2.new(1, 0, 1, -50)
TabScroll.Position = UDim2.new(0, 0, 0, 40)
TabScroll.BackgroundTransparency = 1
TabScroll.ScrollBarThickness = 0

local TabLayout = Instance.new("UIListLayout", TabScroll)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 4)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ContentPanel = Instance.new("Frame", MainFrame)
ContentPanel.Size = UDim2.new(1, -161, 1, -41)
ContentPanel.Position = UDim2.new(0, 161, 0, 41)
ContentPanel.BackgroundColor3 = Colors.BG2
ContentPanel.BorderSizePixel = 0

local TabButtons = {}
local TabPages   = {}

local function BindScrollResize(scroll, layout)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 30)
    end)
end

local function CreateTab(tabId, icon)
    local btn = Instance.new("TextButton", TabScroll)
    btn.Size = UDim2.new(1, -16, 0, 32)
    btn.BackgroundColor3 = Colors.BG1
    -- original format: 3 spaces + icon + 2 spaces + name (verified from decoded strings)
    btn.Text = "   " .. icon .. "  " .. tabId
    btn.TextColor3 = Colors.Gray1
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local page = Instance.new("ScrollingFrame", ContentPanel)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Visible = false
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Colors.Border

    local pageLayout = Instance.new("UIListLayout", page)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 12)
    pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop    = UDim.new(0, 16)
    pad.PaddingBottom = UDim.new(0, 8)
    BindScrollResize(page, pageLayout)

    btn.MouseButton1Click:Connect(function()
        for id, b in pairs(TabButtons) do
            b.BackgroundColor3 = (id == tabId) and Colors.BG3 or Colors.BG1
            b.TextColor3       = (id == tabId) and Colors.Green or Colors.Gray1
        end
        for id, p in pairs(TabPages) do
            p.Visible = (id == tabId)
        end
    end)

    TabButtons[tabId] = btn
    TabPages[tabId]   = page
    return page
end

-- ============================================================
-- SECTION BUILDER
-- ============================================================
local function CreateSection(parent, title)
    local section = Instance.new("Frame", parent)
    section.BackgroundColor3 = Colors.BG3
    section.Size = UDim2.new(1, -36, 0, 0)
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", section).Color = Colors.Border

    local header = Instance.new("Frame", section)
    header.Size = UDim2.new(1, 0, 0, 36)
    header.BackgroundTransparency = 1

    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = UDim2.new(1, -24, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Colors.Green
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local divLine = Instance.new("Frame", section)
    divLine.Size = UDim2.new(1, -24, 0, 1)
    divLine.Position = UDim2.new(0, 12, 0, 36)
    divLine.BackgroundColor3 = Colors.Border
    divLine.BorderSizePixel = 0

    local container = Instance.new("Frame", section)
    container.Size = UDim2.new(1, 0, 0, 0)
    container.Position = UDim2.new(0, 0, 0, 37)
    container.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", container)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local pad = Instance.new("UIPadding", container)
    pad.PaddingTop    = UDim.new(0, 16)  -- verified from original: 1164-(556+592) = 16
    pad.PaddingBottom = UDim.new(0, 8)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 16)
        section.Size   = UDim2.new(1, -36, 0, 37 + container.Size.Y.Offset)
    end)

    return container
end

-- ============================================================
-- TOGGLE BUILDER
-- ============================================================
local function CreateToggle(parent, label, default, callback)
    local row = Instance.new("TextButton", parent)
    row.Size = UDim2.new(1, -24, 0, 26)
    row.BackgroundTransparency = 1
    row.Text = ""
    row.AutoButtonColor = false

    local labelText = Instance.new("TextLabel", row)
    labelText.Size = UDim2.new(0.7, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Colors.Gray1
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.TextXAlignment = Enum.TextXAlignment.Left

    local track = Instance.new("TextButton", row)
    track.Size = UDim2.new(0, 36, 0, 18)
    track.AnchorPoint = Vector2.new(1, 0.5)
    track.Position = UDim2.new(1, 0, 0.5, 0)
    track.BackgroundColor3 = default and Colors.Accent or Colors.Gray2
    track.Text = ""
    track.AutoButtonColor = false
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(default and 1 or 0, default and -16 or 2, 0.5, 0)
    knob.BackgroundColor3 = Colors.Green
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default
    local function toggle()
        state = not state
        callback(state)
        TweenService:Create(track, TweenInfo.new(0.25), {
            BackgroundColor3 = state and Colors.Accent or Colors.Gray2
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.25), {
            Position = UDim2.new(state and 1 or 0, state and -16 or 2, 0.5, 0)
        }):Play()
    end
    track.MouseButton1Click:Connect(toggle)
    row.MouseButton1Click:Connect(toggle)
end

-- ============================================================
-- SLIDER BUILDER
-- ============================================================
local function CreateSlider(parent, label, min, max, default, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -24, 0, 36)
    row.BackgroundTransparency = 1

    -- label: 0.5 width, 16px tall (verified from original: UDim2.new(0.5, 0, 0, 16))
    local labelText = Instance.new("TextLabel", row)
    labelText.Size = UDim2.new(0.5, 0, 0, 16)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Colors.Gray1
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.TextXAlignment = Enum.TextXAlignment.Left

    -- value: 0.5 width at X=0.5, right-aligned (verified)
    local valueText = Instance.new("TextLabel", row)
    valueText.Size = UDim2.new(0.5, 0, 0, 16)
    valueText.Position = UDim2.new(0.5, 0, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = tostring(default)
    valueText.TextColor3 = Colors.Accent
    valueText.Font = Enum.Font.GothamBold
    valueText.TextSize = 12
    valueText.TextXAlignment = Enum.TextXAlignment.Right

    -- track: anchored to bottom of row (verified: UDim2.new(0,0,1,-10) in original)
    local track = Instance.new("TextButton", row)
    track.Size = UDim2.new(1, 0, 0, 8)
    track.Position = UDim2.new(0, 0, 1, -10)
    track.BackgroundColor3 = Colors.BG4
    track.Text = ""
    track.AutoButtonColor = false
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Colors.Accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local sliding = false
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
    end)
    UserInput.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UserInput.InputChanged:Connect(function(i)
        if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
            local pct = math.clamp(
                (i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1
            )
            local val = math.floor(min + (max - min) * pct)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            valueText.Text = tostring(val)
            callback(val)
        end
    end)
end

-- ============================================================
-- DROPDOWN BUILDER
-- ============================================================
local function CreateDropdown(parent, label, options, defaultIndex, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -24, 0, 26)
    row.BackgroundTransparency = 1

    -- label: 0.5 width full height (verified from original: UDim2.new(0.5, 0, 1, 0))
    local labelText = Instance.new("TextLabel", row)
    labelText.Size = UDim2.new(0.5, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Colors.Gray1
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.TextXAlignment = Enum.TextXAlignment.Left

    local dropBtn = Instance.new("TextButton", row)
    dropBtn.Size = UDim2.new(0, 110, 0, 22)
    dropBtn.AnchorPoint = Vector2.new(1, 0.5)
    dropBtn.Position = UDim2.new(1, 0, 0.5, 0)
    dropBtn.BackgroundColor3 = Colors.BG4
    dropBtn.TextColor3 = Colors.Green
    dropBtn.Font = Enum.Font.GothamSemibold
    dropBtn.TextSize = 11
    dropBtn.AutoButtonColor = false
    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 4)

    local idx = defaultIndex
    dropBtn.Text = options[idx]

    dropBtn.MouseButton1Click:Connect(function()
        idx = (idx % #options) + 1
        dropBtn.Text = options[idx]
        callback(options[idx])
    end)
end

-- ============================================================
-- BUTTON BUILDER
-- ============================================================
local function CreateButton(parent, label, color, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size            = UDim2.new(1, -24, 0, 28)
    btn.BackgroundColor3 = color or Colors.Accent
    btn.Text            = label
    btn.TextColor3      = Color3.fromRGB(255, 255, 255)
    btn.Font            = Enum.Font.GothamBold
    btn.TextSize        = 12
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    -- hover tint
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(255, (color or Colors.Accent).R * 255 + 20),
                math.min(255, (color or Colors.Accent).G * 255 + 20),
                math.min(255, (color or Colors.Accent).B * 255 + 20)
            )
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {
            BackgroundColor3 = color or Colors.Accent
        }):Play()
    end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ============================================================
-- BUILD TABS  (verified names: Aimbot, Visuals, Ajustes→Settings)
-- ============================================================
local AimbotTab  = CreateTab("Aimbot",  "◎")
local VisualsTab = CreateTab("Visuals", "◈")
local SettingsTab= CreateTab("Settings","⚙")
local DumpTab    = CreateTab("Dump",    "◉")

-- ── AIMBOT TAB ──────────────────────────────────────────────
-- Section: "Normal Aimbot (Camera)"
local aimbotSection = CreateSection(AimbotTab, "Normal Aimbot (Camera)")
CreateToggle(aimbotSection, "Camera Aimbot", Settings.Aimbot_Enabled, function(v)
    Settings.Aimbot_Enabled = v
end)

-- Section: "Configuration"
local aimbotConfig = CreateSection(AimbotTab, "Configuration")
-- "Radio FOV" → "FOV Radius"
CreateSlider(aimbotConfig, "FOV Radius", 30, 800, Settings.FOV_Radius, function(v)
    Settings.FOV_Radius = v
end)
-- "Suavizado" → "Smoothness"
CreateSlider(aimbotConfig, "Smoothness", 1, 100, Settings.Aim_Smoothness * 100, function(v)
    Settings.Aim_Smoothness = v / 100
end)
-- "Hueso Objetivo" → "Target Bone"
CreateDropdown(aimbotConfig, "Target Bone",
    {"Head", "UpperTorso", "LowerTorso"}, 1,
    function(v) Settings.Aim_Part = v end
)

-- Section: "Targeting"
local targetingSection = CreateSection(AimbotTab, "Targeting")
CreateDropdown(targetingSection, "Aim Key",
    {"Right Click", "CapsLock", "F", "V"}, 1,
    function(v) Settings.Aim_Key = v end
)
CreateDropdown(targetingSection, "Priority",
    {"FOV", "Health"}, 1,
    function(v) Settings.Aim_Priority = v end
)
CreateToggle(targetingSection, "No Recoil", Settings.NoRecoil, function(v)
    Settings.NoRecoil = v
end)

-- ── VISUALS TAB ─────────────────────────────────────────────
-- Section: "ESP Filters"  (original: "Filtros ESP")
local espFilters = CreateSection(VisualsTab, "ESP Filters")
-- "ESP Jugadores" → "Player ESP"
CreateToggle(espFilters, "Player ESP", Settings.ESP_Enabled, function(v)
    Settings.ESP_Enabled = v
end)
-- "ESP NPCs"
CreateToggle(espFilters, "NPC ESP", Settings.NPC_Enabled, function(v)
    Settings.NPC_Enabled = v
end)

-- Section: "Format"  (original: "Formato")
local espFormat = CreateSection(VisualsTab, "Format")
-- "Estilo ESP" → "ESP Style" ; options: "2D Box" / "Full"  (original: "Caja 2D" / "Completo")
CreateDropdown(espFormat, "ESP Style",
    {"2D Box", "Full"}, 1,
    function(v) Settings.ESP_Type = v end
)
-- "Mostrar Nombre y Distancia" → "Show Name and Distance"
CreateToggle(espFormat, "Show Name and Distance", Settings.ESP_ShowInfo, function(v)
    Settings.ESP_ShowInfo = v
end)
-- "Mostrar Esqueleto" → "Show Skeleton"
CreateToggle(espFormat, "Show Skeleton", Settings.ESP_Skeleton, function(v)
    Settings.ESP_Skeleton = v
end)
-- "Distancia Máxima ESP" → "Max ESP Distance"
CreateSlider(espFormat, "Max ESP Distance", 50, 5000, Settings.ESP_MaxDistance, function(v)
    Settings.ESP_MaxDistance = v
end)

-- Section: "Overlays"
local overlaysSection = CreateSection(VisualsTab, "Overlays")
CreateToggle(overlaysSection, "Health Bars",   Settings.HealthBar,    function(v) Settings.HealthBar    = v end)
CreateToggle(overlaysSection, "Tracers",       Settings.Tracer,       function(v) Settings.Tracer       = v end)
CreateToggle(overlaysSection, "Weapon Label",  Settings.WeaponLabel,  function(v) Settings.WeaponLabel  = v end)
CreateToggle(overlaysSection, "Loot ESP",      Settings.Loot_Enabled,   function(v) Settings.Loot_Enabled  = v end)
CreateToggle(overlaysSection, "Best Loot Only",Settings.Best_Loot_Only, function(v) Settings.Best_Loot_Only = v end)
CreateToggle(overlaysSection, "Radar",         Settings.Radar_Enabled,  function(v) Settings.Radar_Enabled = v end)

-- Section: "Crosshair"
local crosshairSection = CreateSection(VisualsTab, "Crosshair")
CreateToggle(crosshairSection, "Crosshair", Settings.Crosshair_Enabled, function(v)
    Settings.Crosshair_Enabled = v
end)
CreateDropdown(crosshairSection, "Style",
    {"Cross", "Dot", "Circle"}, 1,
    function(v) Settings.Crosshair_Style = v end
)

-- ── SETTINGS TAB  (original: "Ajustes") ─────────────────────
-- Section: "System Information"
local infoSection = CreateSection(SettingsTab, "System Information")
local infoText = Instance.new("TextLabel", infoSection)
infoText.Size = UDim2.new(1, -12, 0, 60)
infoText.BackgroundTransparency = 1
infoText.TextColor3 = Colors.Gray1
infoText.Text =
    "[INSERT] or [RSHIFT] to hide the panel.\n" ..
    "[RIGHT CLICK] to activate Aimbot.\n" ..
    "Aim requires visibility and respects Max ESP Distance."
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 11
infoText.TextWrapped = true
infoText.TextXAlignment = Enum.TextXAlignment.Left

-- Section: "Visuals"
local visualSettingsSection = CreateSection(SettingsTab, "Visuals")

-- ── FULLBRIGHT ───────────────────────────────────────────────
-- Save original lighting values so we can restore on toggle off
local OriginalLighting = {
    Brightness      = Lighting.Brightness,
    Ambient         = Lighting.Ambient,
    OutdoorAmbient  = Lighting.OutdoorAmbient,
    ClockTime       = Lighting.ClockTime,
    GlobalShadows   = Lighting.GlobalShadows,
    FogEnd          = Lighting.FogEnd,
    FogStart        = Lighting.FogStart,
}

-- Save original post-effect states
local OriginalEffects = {}
for _, effect in ipairs(Lighting:GetChildren()) do
    if effect:IsA("PostEffect") then
        OriginalEffects[effect] = effect.Enabled
    end
end

local fullbrightConn = nil

local function SetFullbright(enabled)
    if enabled then
        -- Apply full brightness
        Lighting.Brightness     = 2
        Lighting.Ambient        = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.ClockTime      = 14   -- 2pm, peak daylight
        Lighting.GlobalShadows  = false
        Lighting.FogEnd         = 100000
        Lighting.FogStart       = 100000
        -- Disable all post-processing (bloom, blur, color correction etc)
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = false
            end
        end
        -- Enforce every frame so the game can't restore its own lighting
        fullbrightConn = RunService.Heartbeat:Connect(function()
            if Lighting.Brightness ~= 2 then
                Lighting.Brightness = 2
            end
            if Lighting.Ambient ~= Color3.fromRGB(255, 255, 255) then
                Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            end
            if Lighting.OutdoorAmbient ~= Color3.fromRGB(255, 255, 255) then
                Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            end
            if Lighting.GlobalShadows then
                Lighting.GlobalShadows = false
            end
        end)
    else
        -- Disconnect enforcer
        if fullbrightConn then
            fullbrightConn:Disconnect()
            fullbrightConn = nil
        end
        -- Restore original lighting
        Lighting.Brightness     = OriginalLighting.Brightness
        Lighting.Ambient        = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        Lighting.ClockTime      = OriginalLighting.ClockTime
        Lighting.GlobalShadows  = OriginalLighting.GlobalShadows
        Lighting.FogEnd         = OriginalLighting.FogEnd
        Lighting.FogStart       = OriginalLighting.FogStart
        -- Re-enable post effects
        for effect, wasEnabled in pairs(OriginalEffects) do
            if effect and effect.Parent then
                effect.Enabled = wasEnabled
            end
        end
    end
end

CreateToggle(visualSettingsSection, "Full Bright", false, function(v)
    SetFullbright(v)
end)

-- ── FORCE EXTRACT ────────────────────────────────────────────
local extractSection = CreateSection(SettingsTab, "Extraction")

-- Status label
local extractStatus = Instance.new("TextLabel", extractSection)
extractStatus.Size               = UDim2.new(1, -12, 0, 32)
extractStatus.BackgroundTransparency = 1
extractStatus.TextColor3         = Colors.Gray1
extractStatus.Font               = Enum.Font.Gotham
extractStatus.TextSize           = 11
extractStatus.TextXAlignment     = Enum.TextXAlignment.Left
extractStatus.TextWrapped        = true
extractStatus.Text               = "Finds extract zone → teleports you in.\nKeybind: [END]"

local extractBtn   = CreateButton(extractSection, "▶  FORCE EXTRACT", Colors.Accent, function() end)
local leaveBtn     = CreateButton(extractSection, "✕  LEAVE SERVER",  Color3.fromRGB(140, 30, 30), function() end)

-- ── FORCE EXTRACT LOGIC ──────────────────────────────────────
-- Known Desert Storm extraction zones (from in-game UI):
--   Southern Tunnel / Mountain Cave / Western Boat / Northern Mountain
-- Strategy:
--   1. Find nearest zone Part/Model matching zone keywords → teleport into it
--      then trigger any ProximityPrompt inside (skips the hold-E requirement)
--   2. Fire any RemoteEvent anywhere in the game tree that looks like extraction
--   3. TeleportService rejoin
--   4. Kick fallback
local EXTRACT_PATTERNS = {
    -- Desert Storm specific (from screenshot UI labels)
    "southern", "tunnel", "mountain", "cave", "western", "boat", "northern",
    -- Generic extraction names any game might use
    "extract", "exfil", "exzone", "exitzone", "escapezon", "exit", "evac",
}

local function MatchesExtract(name)
    local n = name:lower()
    for _, pat in ipairs(EXTRACT_PATTERNS) do
        if n:find(pat, 1, true) then return true end
    end
    return false
end

local function ForceExtract()
    extractBtn.Text    = "searching..."
    extractStatus.Text = ""
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        extractStatus.Text = "no character — try again in raid"
        extractBtn.Text    = "▶  FORCE EXTRACT"
        return
    end

    -- ── STEP 1: find closest matching Part or Model, teleport in, trigger prompts ──
    local bestObj  = nil
    local bestDist = math.huge
    local bestPos  = nil

    for _, obj in ipairs(workspace:GetDescendants()) do
        -- match on the object itself OR its parent Model name
        local nameMatch = MatchesExtract(obj.Name)
            or (obj.Parent and obj.Parent:IsA("Model") and MatchesExtract(obj.Parent.Name))

        if nameMatch and (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation")) then
            local d = (root.Position - obj.Position).Magnitude
            if d < bestDist then
                bestDist = d
                bestObj  = obj
                bestPos  = obj.Position
            end
        end
    end

    if bestObj then
        -- Teleport into zone centre, slightly above so physics settle
        root.CFrame = CFrame.new(bestPos + Vector3.new(0, 4, 0))
        extractStatus.Text = "teleported → " .. bestObj.Name .. " (" .. math.floor(bestDist) .. "m)"
        task.wait(0.15)

        -- Trigger every ProximityPrompt inside this zone or its parent Model
        -- This bypasses the hold-E timer the game requires
        local searchRoot = bestObj.Parent and bestObj.Parent:IsA("Model")
            and bestObj.Parent or bestObj
        for _, child in ipairs(searchRoot:GetDescendants()) do
            if child:IsA("ProximityPrompt") then
                pcall(function() child:InputHoldBegin() end)
                task.wait(0.05)
                pcall(function() child:InputHoldEnd() end)
                -- Also try direct trigger (works on some executors)
                pcall(function()
                    game:GetService("ProximityPromptService"):PromptTriggered(child, LocalPlayer)
                end)
                extractStatus.Text = extractStatus.Text .. "\n→ triggered prompt: " .. child.ActionText
            end
        end

        extractBtn.Text = "▶  FORCE EXTRACT"
        return
    end

    -- ── STEP 2: fire any extraction RemoteEvent across the whole game tree ──
    extractStatus.Text = "no zone found — scanning remotes..."
    local fired   = false
    local RS      = game:GetService("ReplicatedStorage")
    local RF      = game:GetService("ReplicatedFirst")
    local trees   = {RS, RF, workspace}
    for _, tree in ipairs(trees) do
        pcall(function()
            for _, obj in ipairs(tree:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    if MatchesExtract(obj.Name) then
                        if obj:IsA("RemoteEvent") then
                            pcall(function() obj:FireServer() end)
                        else
                            pcall(function() obj:InvokeServer() end)
                        end
                        extractStatus.Text = "fired remote: " .. obj:GetFullName()
                        fired = true
                    end
                end
            end
        end)
    end
    if fired then
        extractBtn.Text = "▶  FORCE EXTRACT"
        return
    end

    -- ── STEP 3: TeleportService rejoin ──
    extractStatus.Text = "no remotes found — rejoining..."
    extractBtn.Text    = "rejoining..."
    local ok = pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
    if not ok then
        task.wait(0.4)
        LocalPlayer:Kick("[Aura] Force Extracted")
    end
end

extractBtn.MouseButton1Click:Connect(ForceExtract)
leaveBtn.MouseButton1Click:Connect(function()
    LocalPlayer:Kick("[Aura] Left Server")
end)

-- ── DUMP TAB ────────────────────────────────────────────────
local dumpSection = CreateSection(DumpTab, "Offset Dumper")

local dumpScrollFrame = Instance.new("ScrollingFrame", dumpSection)
dumpScrollFrame.Size = UDim2.new(1, -12, 0, 280)
dumpScrollFrame.BackgroundColor3 = Colors.BG0
dumpScrollFrame.BorderSizePixel = 0
dumpScrollFrame.ScrollBarThickness = 3
dumpScrollFrame.ScrollBarImageColor3 = Colors.Accent
dumpScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", dumpScrollFrame).CornerRadius = UDim.new(0, 4)

local dumpOutput = Instance.new("TextLabel", dumpScrollFrame)
dumpOutput.Size = UDim2.new(1, -8, 0, 0)
dumpOutput.Position = UDim2.new(0, 4, 0, 4)
dumpOutput.BackgroundTransparency = 1
dumpOutput.TextColor3 = Colors.Accent
dumpOutput.Font = Enum.Font.Code
dumpOutput.TextSize = 11
dumpOutput.TextWrapped = true
dumpOutput.TextXAlignment = Enum.TextXAlignment.Left
dumpOutput.TextYAlignment = Enum.TextYAlignment.Top
dumpOutput.AutomaticSize = Enum.AutomaticSize.Y
dumpOutput.Text = "[ press DUMP to scan the game ]"

dumpOutput:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    dumpScrollFrame.CanvasSize = UDim2.new(0, 0, 0, dumpOutput.AbsoluteSize.Y + 8)
end)

local dumpStatus = Instance.new("TextLabel", dumpSection)
dumpStatus.Size = UDim2.new(1, -12, 0, 18)
dumpStatus.BackgroundTransparency = 1
dumpStatus.TextColor3 = Colors.Gray1
dumpStatus.Font = Enum.Font.GothamBold
dumpStatus.TextSize = 10
dumpStatus.TextXAlignment = Enum.TextXAlignment.Left
dumpStatus.Text = "status: idle"

local btnRow = Instance.new("Frame", dumpSection)
btnRow.Size = UDim2.new(1, -12, 0, 28)
btnRow.BackgroundTransparency = 1
local btnLayout = Instance.new("UIListLayout", btnRow)
btnLayout.FillDirection = Enum.FillDirection.Horizontal
btnLayout.Padding = UDim.new(0, 8)

local function MakeButton(parent, label, color, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.BackgroundColor3 = color
    btn.Text = label
    btn.TextColor3 = Colors.BG0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function RunDump()
    dumpStatus.Text = "status: scanning..."
    dumpOutput.Text = ""
    task.wait()
    local lines = {}
    local function add(s) table.insert(lines, s) end

    add("=== GAME INFO ===")
    add("PlaceId      : " .. tostring(game.PlaceId))
    add("GameId       : " .. tostring(game.GameId))
    add("PlaceVersion : " .. tostring(game.PlaceVersion))
    add("CreatorId    : " .. tostring(game.CreatorId))
    add("Name         : " .. tostring(game.Name))
    add("")

    add("=== LOCAL PLAYER ===")
    add("Name         : " .. LocalPlayer.Name)
    add("UserId       : " .. tostring(LocalPlayer.UserId))
    add("TeamColor    : " .. tostring(LocalPlayer.TeamColor))
    add("AccountAge   : " .. tostring(LocalPlayer.AccountAge))

    local char = LocalPlayer.Character
    if char then
        local hum  = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        add("")
        add("[ CHARACTER ]")
        add("Path         : workspace." .. char.Name)
        if hum then
            add("WalkSpeed    : " .. tostring(hum.WalkSpeed))
            add("JumpPower    : " .. tostring(hum.JumpPower))
            add("JumpHeight   : " .. tostring(hum.JumpHeight))
            add("MaxHealth    : " .. tostring(hum.MaxHealth))
            add("Health       : " .. tostring(hum.Health))
            add("RigType      : " .. tostring(hum.RigType))
        end
        if root then
            add("RootPos      : " .. tostring(root.Position))
            add("RootVelocity : " .. tostring(root.AssemblyLinearVelocity))
        end
        add("")
        add("[ PARTS ]")
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                add("  " .. part.Name .. " @ " .. tostring(part.Position))
            end
        end
    end
    add("")

    add("=== REMOTE EVENTS / FUNCTIONS ===")
    local remoteCount = 0
    local function ScanRemotes(parent, path)
        local ok, desc = pcall(function() return parent:GetDescendants() end)
        if not ok then return end
        for _, obj in ipairs(desc) do
            local tag
            if obj:IsA("RemoteEvent")            then tag = "[RE] "
            elseif obj:IsA("RemoteFunction")     then tag = "[RF] "
            elseif obj:IsA("UnreliableRemoteEvent") then tag = "[URE]"
            end
            if tag then
                local ok2, fullname = pcall(function() return obj:GetFullName() end)
                if ok2 then
                    add("  " .. tag .. " " .. fullname)
                    remoteCount = remoteCount + 1
                end
            end
        end
    end
    local RS = game:GetService("ReplicatedStorage")
    ScanRemotes(RS, "ReplicatedStorage")
    ScanRemotes(workspace, "workspace")
    pcall(function()
        ScanRemotes(game:GetService("ReplicatedFirst"), "ReplicatedFirst")
    end)
    add("  Total: " .. remoteCount)
    add("")

    add("=== LOCAL SCRIPTS ===")
    local scount = 0
    pcall(function()
        for _, obj in ipairs(LocalPlayer:GetDescendants()) do
            if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                add("  [" .. obj.ClassName .. "] " .. obj:GetFullName())
                scount = scount + 1
            end
        end
    end)
    if scount == 0 then add("  none found") end
    add("")

    add("=== TOOLS / WEAPONS ===")
    local tcount = 0
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                add("  [TOOL] " .. tool.Name)
                for _, v in ipairs(tool:GetDescendants()) do
                    if v:IsA("NumberValue") or v:IsA("IntValue")
                    or v:IsA("StringValue") or v:IsA("BoolValue") then
                        add("    ." .. v.Name .. " = " .. tostring(v.Value))
                    end
                end
                tcount = tcount + 1
            end
        end
    end
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                add("  [EQUIPPED] " .. tool.Name)
                for _, v in ipairs(tool:GetDescendants()) do
                    if v:IsA("NumberValue") or v:IsA("IntValue")
                    or v:IsA("StringValue") or v:IsA("BoolValue") then
                        add("    ." .. v.Name .. " = " .. tostring(v.Value))
                    end
                end
                tcount = tcount + 1
            end
        end
    end
    if tcount == 0 then add("  none found") end
    add("")

    add("=== PLAYER VALUES (leaderstats etc) ===")
    local function DumpValues(parent, indent)
        for _, v in ipairs(parent:GetChildren()) do
            if v:IsA("NumberValue") or v:IsA("IntValue")
            or v:IsA("StringValue") or v:IsA("BoolValue") then
                add(indent .. v.Name .. " [" .. v.ClassName .. "] = " .. tostring(v.Value))
            elseif v:IsA("Folder") or v:IsA("Configuration") then
                add(indent .. "[" .. v.ClassName .. "] " .. v.Name)
                DumpValues(v, indent .. "  ")
            end
        end
    end
    DumpValues(LocalPlayer, "  ")
    add("")

    add("=== REPLICATED STORAGE (top level) ===")
    for _, obj in ipairs(RS:GetChildren()) do
        add("  [" .. obj.ClassName .. "] " .. obj.Name)
    end
    add("")

    add("=== WORKSPACE MODELS ===")
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= LocalPlayer.Character then
            local hum2 = obj:FindFirstChildOfClass("Humanoid")
            add("  " .. (hum2 and "[NPC] " or "[MDL] ") .. obj.Name)
        end
    end
    add("")

    add("=== CAMERA ===")
    add("  CameraType   : " .. tostring(Camera.CameraType))
    add("  FieldOfView  : " .. tostring(Camera.FieldOfView))
    add("  Position     : " .. tostring(Camera.CFrame.Position))
    add("  ViewportSize : " .. tostring(Camera.ViewportSize))
    add("")
    add("=== DUMP COMPLETE ===")

    dumpOutput.Text = table.concat(lines, "\n")
    dumpScrollFrame.CanvasSize = UDim2.new(0, 0, 0, dumpOutput.AbsoluteSize.Y + 8)
    dumpStatus.Text = "status: done — " .. #lines .. " lines"
end

MakeButton(btnRow, "▶  DUMP",  Colors.Accent, function() task.spawn(RunDump) end)
MakeButton(btnRow, "✕  CLEAR", Colors.Gray2,  function()
    dumpOutput.Text = "[ press DUMP to scan the game ]"
    dumpScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 60)
    dumpStatus.Text = "status: idle"
end)

-- ============================================================
-- DRAWING SUPPORT + DUMMY FALLBACK
-- ============================================================
local DrawingSupported = false
pcall(function()
    local t = typeof(Drawing)
    DrawingSupported = (t == "table" or t == "userdata") and typeof(Drawing.new) == "function"
end)

local function NewDrawing(kind)
    if DrawingSupported then
        local ok, obj = pcall(Drawing.new, kind)
        if ok then return obj end
    end
    local dummy = setmetatable({}, {
        __index    = function(t, k) return rawget(t, k) end,
        __newindex = function(t, k, v) rawset(t, k, v) end,
    })
    dummy.Visible = false
    dummy.Remove  = function() end
    dummy.Destroy = function() end
    return dummy
end

-- ============================================================
-- CROSSHAIR DRAWINGS
-- ============================================================
local CrosshairLines = {}
for i = 1, 4 do
    local l = NewDrawing("Line")
    l.Thickness = 1.5
    l.Color     = Color3.fromRGB(255, 255, 255)
    l.Visible   = false
    table.insert(CrosshairLines, l)
end
local CrosshairDot = NewDrawing("Circle")
CrosshairDot.Color    = Color3.fromRGB(255, 255, 255)
CrosshairDot.Filled   = true
CrosshairDot.Visible  = false

-- ============================================================
-- RADAR GUI
-- ============================================================
local RADAR_MAX_DOTS = 24
local RadarFrame = Instance.new("Frame", ScreenGui)
RadarFrame.Name                 = "AuraRadar"
RadarFrame.Size                 = UDim2.new(0, 180, 0, 180)
RadarFrame.Position             = UDim2.new(1, -192, 1, -192)
RadarFrame.BackgroundColor3     = Color3.fromRGB(0, 0, 0)
RadarFrame.BackgroundTransparency = 0.45
RadarFrame.BorderSizePixel      = 0
RadarFrame.Visible              = false
Instance.new("UICorner", RadarFrame).CornerRadius = UDim.new(1, 0)

-- Radar border ring
local RadarStroke = Instance.new("UIStroke", RadarFrame)
RadarStroke.Color     = Colors.Border
RadarStroke.Thickness = 1

-- Player center dot
local RadarSelf = Instance.new("Frame", RadarFrame)
RadarSelf.Size             = UDim2.new(0, 8, 0, 8)
RadarSelf.AnchorPoint      = Vector2.new(0.5, 0.5)
RadarSelf.Position         = UDim2.new(0.5, 0, 0.5, 0)
RadarSelf.BackgroundColor3 = Colors.Green
RadarSelf.BorderSizePixel  = 0
Instance.new("UICorner", RadarSelf).CornerRadius = UDim.new(1, 0)

-- North tick
local RadarNorth = Instance.new("TextLabel", RadarFrame)
RadarNorth.Size               = UDim2.new(1, 0, 0, 14)
RadarNorth.Position           = UDim2.new(0, 0, 0, 4)
RadarNorth.BackgroundTransparency = 1
RadarNorth.Text               = "N"
RadarNorth.TextColor3         = Colors.Gray1
RadarNorth.Font               = Enum.Font.GothamBold
RadarNorth.TextSize           = 10

-- Enemy dots pool
local RadarDots = {}
for i = 1, RADAR_MAX_DOTS do
    local dot = Instance.new("Frame", RadarFrame)
    dot.Size             = UDim2.new(0, 6, 0, 6)
    dot.AnchorPoint      = Vector2.new(0.5, 0.5)
    dot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    dot.BorderSizePixel  = 0
    dot.Visible          = false
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    RadarDots[i] = dot
end

-- ============================================================
-- LOOT ESP
-- ============================================================
local LootObjects = {}
local LOOT_MAX    = 50
local LootLabels  = {}
for i = 1, LOOT_MAX do
    local t = NewDrawing("Text")
    t.Size    = 12
    t.Color   = Color3.fromRGB(255, 215, 0)
    t.Outline = true
    t.Center  = true
    t.Visible = false
    table.insert(LootLabels, t)
end

-- Periodic loot scanner — finds Tools sitting in workspace (dropped/world items)
task.spawn(function()
    while true do
        task.wait(2)
        if Settings.Loot_Enabled then
            local found = {}
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Tool") then
                    local held = false
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr.Character and obj:IsDescendantOf(plr.Character) then
                            held = true; break
                        end
                    end
                    if not held then table.insert(found, obj) end
                end
            end
            LootObjects = found
        end
    end
end)

-- ============================================================
-- SET DEFAULT TAB
-- ============================================================
TabButtons["Aimbot"].BackgroundColor3 = Colors.BG3
TabButtons["Aimbot"].TextColor3       = Colors.Green
TabPages["Aimbot"].Visible            = true

-- ============================================================
-- ESP OBJECTS
-- ============================================================
local ESPObjects = {}

local FOVCircle = NewDrawing("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color     = Colors.Accent
FOVCircle.Filled    = false

local function CreateESPEntry(model)
    local hl = Instance.new("Highlight")
    hl.FillTransparency    = 0.5
    hl.OutlineTransparency = 0.1

    local entry = {
        Box           = NewDrawing("Square"),
        Text          = NewDrawing("Text"),
        HealthBarBG   = NewDrawing("Square"),
        HealthBarFill = NewDrawing("Square"),
        Tracer        = NewDrawing("Line"),
        Skeleton      = {},
        Highlight     = hl,
    }
    entry.Box.Thickness           = 1.5
    entry.Box.Filled              = false
    entry.Text.Size               = 13
    entry.Text.Center             = true
    entry.Text.Outline            = true
    entry.HealthBarBG.Filled      = true
    entry.HealthBarFill.Filled    = true
    entry.Tracer.Thickness        = 1
    for i = 1, 12 do
        local bone = NewDrawing("Line")
        bone.Thickness = 1.5
        table.insert(entry.Skeleton, bone)
    end
    ESPObjects[model] = entry
    return entry
end

-- ============================================================
-- BONE PAIRS  (verified from decoded original)
-- R15: 12 pairs / R6: 5 pairs
-- ============================================================
local R15Bones = {
    {"UpperTorso",    "LowerTorso"},
    {"UpperTorso",    "LeftUpperArm"},
    {"LeftUpperArm",  "LeftLowerArm"},
    {"LeftLowerArm",  "LeftHand"},
    {"UpperTorso",    "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"UpperTorso",    "Head"},
    {"LowerTorso",    "LeftUpperLeg"},
    {"LeftUpperLeg",  "LeftLowerLeg"},
    {"LowerTorso",    "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
}
local R6Bones = {
    {"Torso",   "Head"},
    {"Torso",   "Left Arm"},
    {"Torso",   "Right Arm"},
    {"Torso",   "Left Leg"},
    {"Torso",   "Right Leg"},
}

-- ============================================================
-- HELPERS
-- ============================================================
local function HideESP(entry)
    if not entry then return end
    entry.Box.Visible           = false
    entry.Text.Visible          = false
    entry.HealthBarBG.Visible   = false
    entry.HealthBarFill.Visible = false
    entry.Tracer.Visible        = false
    if entry.Highlight.Parent then entry.Highlight.Parent = nil end
    for _, bone in ipairs(entry.Skeleton) do bone.Visible = false end
end

local function IsVisible(part)
    if not part or not part.Parent then return false end
    local char = part.Parent
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local _, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then return false end
    if not hum or hum.Health <= 0 then return false end
    if (Camera.CFrame.Position - part.Position).Magnitude > Settings.ESP_MaxDistance then return false end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    params.FilterType  = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    local ray = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
    if ray and not ray.Instance:IsDescendantOf(char) then return false end
    return true
end

-- ============================================================
-- HELPERS — AIM KEY / NO RECOIL STATE
-- ============================================================
local function IsAimKeyDown()
    local k = Settings.Aim_Key
    if k == "Right Click" then
        return UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif k == "CapsLock" then
        return UserInput:IsKeyDown(Enum.KeyCode.CapsLock)
    elseif k == "F" then
        return UserInput:IsKeyDown(Enum.KeyCode.F)
    elseif k == "V" then
        return UserInput:IsKeyDown(Enum.KeyCode.V)
    end
    return false
end

local nrPrevCF = nil   -- previous-frame CFrame for no-recoil delta

-- ============================================================
-- RENDER LOOP
-- ============================================================
local CurrentTarget = nil

RunService.RenderStepped:Connect(function()

    -- FOV circle
    if Settings.Aimbot_Enabled then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius   = Settings.FOV_Radius
        FOVCircle.Visible  = true
    else
        FOVCircle.Visible = false
    end

    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local cx = screenCenter.X
    local cy = screenCenter.Y

    -- Build target list
    local targets = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            table.insert(targets, {
                Model = plr.Character,
                IsNPC = false,
                Name  = plr.Name,
            })
        end
    end
    for model in pairs(NPCTable) do
        if model and model.Parent then
            table.insert(targets, {
                Model = model,
                IsNPC = true,
                Name  = "[NPC] " .. model.Name,
            })
        else
            NPCTable[model] = nil
        end
    end

    -- Clean stale ESP entries
    for model, entry in pairs(ESPObjects) do
        if not model or not model.Parent then
            pcall(function() entry.Box:Remove() end)
            pcall(function() entry.Text:Remove() end)
            pcall(function() entry.HealthBarBG:Remove() end)
            pcall(function() entry.HealthBarFill:Remove() end)
            pcall(function() entry.Tracer:Remove() end)
            for _, bone in ipairs(entry.Skeleton) do pcall(function() bone:Remove() end) end
            if entry.Highlight.Parent then pcall(function() entry.Highlight:Destroy() end) end
            ESPObjects[model] = nil
        end
    end

    -- ── ESP RENDER ───────────────────────────────────────────────
    for _, target in ipairs(targets) do
        local model = target.Model
        local hum   = model:FindFirstChildOfClass("Humanoid")
        local root  = model:FindFirstChild("HumanoidRootPart")
        local entry = ESPObjects[model] or CreateESPEntry(model)

        local shouldShow = (target.IsNPC and Settings.NPC_Enabled)
                        or (not target.IsNPC and Settings.ESP_Enabled)

        if shouldShow and hum and hum.Health > 0 and root then
            local head      = model:FindFirstChild("Head")
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local dist      = (Camera.CFrame.Position - root.Position).Magnitude

            -- Color: Green=teammate, Red=can shoot, Yellow=blocked, Orange=NPC
            local color
            if target.IsNPC then
                color = Colors.Orange
            else
                local plr       = Players:GetPlayerFromCharacter(model)
                local isTeammate = plr and LocalPlayer.Team and plr.Team == LocalPlayer.Team
                if isTeammate then
                    color = Color3.fromRGB(0, 220, 80)
                else
                    local aimPart = model:FindFirstChild(Settings.Aim_Part) or head or root
                    local canShoot = false
                    if aimPart then
                        local params = RaycastParams.new()
                        params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                        params.FilterType  = Enum.RaycastFilterType.Exclude
                        params.IgnoreWater = true
                        local ray = workspace:Raycast(
                            Camera.CFrame.Position,
                            aimPart.Position - Camera.CFrame.Position,
                            params
                        )
                        canShoot = not ray or ray.Instance:IsDescendantOf(model)
                    end
                    color = canShoot
                        and Color3.fromRGB(255, 50,  50)
                        or  Color3.fromRGB(255, 200, 0)
                end
            end

            if dist <= Settings.ESP_MaxDistance and onScreen then
                entry.Box.Color              = color
                entry.Text.Color             = color
                entry.Highlight.FillColor    = color
                entry.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                for _, bone in ipairs(entry.Skeleton) do bone.Color = color end

                -- Box geometry (shared by health bar + tracer)
                local boxHeight = 0
                local boxTopY   = screenPos.Y
                local rootScreen = Camera:WorldToViewportPoint(root.Position)

                if Settings.ESP_Type == "Full" then
                    entry.Box.Visible       = false
                    entry.Highlight.Adornee = model
                    entry.Highlight.Parent  = workspace
                else
                    if entry.Highlight.Parent then entry.Highlight.Parent = nil end
                    if head then
                        local topPos    = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                        boxHeight = math.abs(topPos.Y - bottomPos.Y)
                        local boxWidth = boxHeight * 0.6
                        boxTopY = topPos.Y
                        entry.Box.Size     = Vector2.new(boxWidth, boxHeight)
                        entry.Box.Position = Vector2.new(rootScreen.X - boxWidth / 2, boxTopY)
                        entry.Box.Visible  = true
                    end
                end

                -- Health bar (left of box, green→red)
                if Settings.HealthBar and boxHeight > 0 then
                    local hp    = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    local barX  = entry.Box.Position.X - 5
                    local fillH = boxHeight * hp
                    entry.HealthBarBG.Size     = Vector2.new(3, boxHeight)
                    entry.HealthBarBG.Position = Vector2.new(barX, boxTopY)
                    entry.HealthBarBG.Color    = Color3.fromRGB(20, 20, 20)
                    entry.HealthBarBG.Visible  = true
                    entry.HealthBarFill.Size     = Vector2.new(3, fillH)
                    entry.HealthBarFill.Position = Vector2.new(barX, boxTopY + (boxHeight - fillH))
                    entry.HealthBarFill.Color    = Color3.fromRGB(
                        math.floor(255 * (1 - hp)),
                        math.floor(220 * hp),
                        0
                    )
                    entry.HealthBarFill.Visible = true
                else
                    entry.HealthBarBG.Visible   = false
                    entry.HealthBarFill.Visible = false
                end

                -- Tracer (line from screen bottom-center to player feet)
                if Settings.Tracer then
                    entry.Tracer.From    = Vector2.new(cx, Camera.ViewportSize.Y)
                    entry.Tracer.To      = Vector2.new(rootScreen.X, rootScreen.Y)
                    entry.Tracer.Color   = color
                    entry.Tracer.Visible = true
                else
                    entry.Tracer.Visible = false
                end

                -- Name + distance + weapon label
                if Settings.ESP_ShowInfo then
                    local weaponTag = ""
                    if Settings.WeaponLabel then
                        local tool = model:FindFirstChildOfClass("Tool")
                        if tool then weaponTag = "\n[" .. tool.Name .. "]" end
                    end
                    entry.Text.Text     = string.format("%s  %dm%s", target.Name, math.floor(dist), weaponTag)
                    entry.Text.Position = Vector2.new(rootScreen.X, boxTopY + boxHeight + 4)
                    entry.Text.Visible  = true
                else
                    entry.Text.Visible = false
                end

                -- Skeleton
                if Settings.ESP_Skeleton then
                    local isR15 = model:FindFirstChild("UpperTorso") ~= nil
                    local bones = isR15 and R15Bones or R6Bones
                    for i = 1, math.min(#entry.Skeleton, #bones) do
                        local bone  = entry.Skeleton[i]
                        local partA = model:FindFirstChild(bones[i][1])
                        local partB = model:FindFirstChild(bones[i][2])
                        if partA and partB then
                            local posA, visA = Camera:WorldToViewportPoint(partA.Position)
                            local posB, visB = Camera:WorldToViewportPoint(partB.Position)
                            if visA and visB then
                                bone.From    = Vector2.new(posA.X, posA.Y)
                                bone.To      = Vector2.new(posB.X, posB.Y)
                                bone.Visible = true
                            else
                                bone.Visible = false
                            end
                        else
                            bone.Visible = false
                        end
                    end
                else
                    for _, bone in ipairs(entry.Skeleton) do bone.Visible = false end
                end
            else
                HideESP(entry)
            end
        else
            HideESP(entry)
        end
    end

    -- ── AIMBOT ───────────────────────────────────────────────────
    local aimActive = IsAimKeyDown()
    if Settings.Aimbot_Enabled and aimActive and not ScreenGui.Enabled then
        if CurrentTarget and IsVisible(CurrentTarget) then
            local cf = CFrame.lookAt(Camera.CFrame.Position, CurrentTarget.Position)
            Camera.CFrame = Camera.CFrame:Lerp(cf, Settings.Aim_Smoothness)
        else
            CurrentTarget = nil
            local bestScore = math.huge
            for _, target in ipairs(targets) do
                local show = (target.IsNPC and Settings.NPC_Enabled) or not target.IsNPC
                if show then
                    local model = target.Model
                    local hum   = model:FindFirstChildOfClass("Humanoid")
                    if model and hum and hum.Health > 0 then
                        local part = model:FindFirstChild(Settings.Aim_Part)
                        if part then
                            local d = (Camera.CFrame.Position - part.Position).Magnitude
                            if d <= Settings.ESP_MaxDistance then
                                local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                                if onScreen then
                                    local sd = (Vector2.new(sp.X, sp.Y) - screenCenter).Magnitude
                                    if sd < Settings.FOV_Radius then
                                        -- Priority: FOV = screen distance, Health = lowest HP first
                                        local score = Settings.Aim_Priority == "Health"
                                            and hum.Health
                                            or  sd
                                        if score < bestScore then
                                            local params = RaycastParams.new()
                                            params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                                            params.FilterType  = Enum.RaycastFilterType.Exclude
                                            params.IgnoreWater = true
                                            local ray = workspace:Raycast(
                                                Camera.CFrame.Position,
                                                part.Position - Camera.CFrame.Position,
                                                params
                                            )
                                            if not ray or ray.Instance:IsDescendantOf(model) then
                                                bestScore     = score
                                                CurrentTarget = part
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if CurrentTarget then
                local cf = CFrame.lookAt(Camera.CFrame.Position, CurrentTarget.Position)
                Camera.CFrame = Camera.CFrame:Lerp(cf, Settings.Aim_Smoothness)
            end
        end
    else
        CurrentTarget = nil
    end

    -- ── NO RECOIL ─────────────────────────────────────────────────
    -- Compares this frame's camera pitch to last frame's.
    -- If pitch rose more than mouse delta accounts for → recoil kick → cancel it.
    if Settings.NoRecoil then
        if nrPrevCF then
            local currX, currY, _ = Camera.CFrame:ToOrientation()
            local prevX,  _,   _ = nrPrevCF:ToOrientation()
            local mouseDelta      = UserInput:GetMouseDelta()
            local expectedPitch   = -mouseDelta.Y * 0.0035
            local recoilKick      = (currX - prevX) - expectedPitch
            if recoilKick > 0.003 then
                Camera.CFrame = Camera.CFrame * CFrame.Angles(-recoilKick * 0.85, 0, 0)
            end
        end
        nrPrevCF = Camera.CFrame
    else
        nrPrevCF = nil
    end

    -- ── CROSSHAIR ─────────────────────────────────────────────────
    if Settings.Crosshair_Enabled then
        local gap  = 4
        local size = 8
        if Settings.Crosshair_Style == "Cross" then
            CrosshairDot.Visible = false
            local segs = {
                {Vector2.new(cx - gap - size, cy), Vector2.new(cx - gap, cy)},
                {Vector2.new(cx + gap, cy),        Vector2.new(cx + gap + size, cy)},
                {Vector2.new(cx, cy - gap - size), Vector2.new(cx, cy - gap)},
                {Vector2.new(cx, cy + gap),        Vector2.new(cx, cy + gap + size)},
            }
            for i, seg in ipairs(segs) do
                CrosshairLines[i].From    = seg[1]
                CrosshairLines[i].To      = seg[2]
                CrosshairLines[i].Visible = true
            end
        elseif Settings.Crosshair_Style == "Dot" then
            for _, l in ipairs(CrosshairLines) do l.Visible = false end
            CrosshairDot.Radius   = 2
            CrosshairDot.Filled   = true
            CrosshairDot.Position = Vector2.new(cx, cy)
            CrosshairDot.Visible  = true
        elseif Settings.Crosshair_Style == "Circle" then
            for _, l in ipairs(CrosshairLines) do l.Visible = false end
            CrosshairDot.Radius    = 20
            CrosshairDot.Filled    = false
            CrosshairDot.Thickness = 1.5
            CrosshairDot.Position  = Vector2.new(cx, cy)
            CrosshairDot.Visible   = true
        end
    else
        for _, l in ipairs(CrosshairLines) do l.Visible = false end
        CrosshairDot.Visible = false
    end

    -- ── RADAR ─────────────────────────────────────────────────────
    if Settings.Radar_Enabled then
        RadarFrame.Visible = true
        local RADAR_SIZE  = 180
        local RADAR_RANGE = 300
        local localRoot   = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local dotIdx = 0
        if localRoot then
            local _, camYaw, _ = Camera.CFrame:ToOrientation()
            for _, target in ipairs(targets) do
                local model = target.Model
                local tRoot = model:FindFirstChild("HumanoidRootPart")
                local tHum  = model:FindFirstChildOfClass("Humanoid")
                if tRoot and tHum and tHum.Health > 0 then
                    local diff   = tRoot.Position - localRoot.Position
                    local dist2D = Vector2.new(diff.X, diff.Z).Magnitude
                    if dist2D < RADAR_RANGE then
                        dotIdx = dotIdx + 1
                        if dotIdx <= RADAR_MAX_DOTS then
                            local dot    = RadarDots[dotIdx]
                            local angle  = math.atan2(diff.X, diff.Z) - camYaw
                            local scaled = (dist2D / RADAR_RANGE) * (RADAR_SIZE / 2 - 10)
                            local dotX   = 0.5 + math.sin(angle) * scaled / RADAR_SIZE
                            local dotY   = 0.5 - math.cos(angle) * scaled / RADAR_SIZE
                            dot.Position = UDim2.new(dotX, -3, dotY, -3)
                            local plr = Players:GetPlayerFromCharacter(model)
                            local isTm = plr and LocalPlayer.Team and plr.Team == LocalPlayer.Team
                            dot.BackgroundColor3 = isTm
                                and Color3.fromRGB(0, 220, 80)
                                or  Color3.fromRGB(255, 50, 50)
                            dot.Visible = true
                        end
                    end
                end
            end
        end
        for i = dotIdx + 1, RADAR_MAX_DOTS do RadarDots[i].Visible = false end
    else
        RadarFrame.Visible = false
        for _, dot in ipairs(RadarDots) do dot.Visible = false end
    end

    -- ── LOOT ESP ──────────────────────────────────────────────────
    if Settings.Loot_Enabled then
        local lootIdx = 0
        for _, tool in ipairs(LootObjects) do
            if tool and tool.Parent then
                local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("BasePart")
                if handle then
                    local sp, onScreen = Camera:WorldToViewportPoint(handle.Position)
                    local ld = (Camera.CFrame.Position - handle.Position).Magnitude
                    if onScreen and ld <= Settings.ESP_MaxDistance then
                        -- Tier check
                        local tier = GetLootTier(tool.Name)
                        -- If Best_Loot_Only is on, skip items with no tier
                        if Settings.Best_Loot_Only and not tier then
                            -- skip
                        else
                            lootIdx = lootIdx + 1
                            if lootIdx <= LOOT_MAX then
                                local lbl = LootLabels[lootIdx]
                                -- S = gold, A = orange, unknown = white
                                lbl.Color = tier == "S" and Color3.fromRGB(255, 215, 0)
                                         or tier == "A" and Color3.fromRGB(255, 140, 0)
                                         or Color3.fromRGB(200, 200, 200)
                                local badge = tier and ("[" .. tier .. "] ") or ""
                                lbl.Text     = "◆ " .. badge .. tool.Name
                                lbl.Position = Vector2.new(sp.X, sp.Y)
                                lbl.Visible  = true
                            end
                        end
                    end
                end
            end
        end
        for i = lootIdx + 1, LOOT_MAX do LootLabels[i].Visible = false end
    else
        for _, lbl in ipairs(LootLabels) do lbl.Visible = false end
    end

end)

-- ============================================================
-- MOUSE FREEDOM  — free cursor + kill camera rotation while menu open
-- Forces MouseBehavior.Default every frame so the game can't
-- override it back, which also stops the camera from rotating.
-- No inputs are sunk so shooting still works normally.
-- ============================================================
-- Custom GUI cursor — bypasses game cursor control entirely.
-- Tracks position via InputChanged (game-space coords, stretch-res correct)
-- instead of GetMouseLocation() (OS screen coords, breaks on stretch res).
local CustomCursor = Instance.new("ImageLabel", ScreenGui)
CustomCursor.Name                   = "AuraCursor"
CustomCursor.Size                   = UDim2.new(0, 18, 0, 18)
CustomCursor.BackgroundTransparency = 1
CustomCursor.Image                  = "rbxasset://textures/Cursors/KeyboardMouse/ArrowCursor.png"
CustomCursor.ZIndex                 = 999
CustomCursor.Visible                = false
CustomCursor.AnchorPoint            = Vector2.new(0, 0)

-- Track real mouse pos in game-viewport coordinates via InputChanged.
-- input.Position for MouseMovement is already scaled to the game's
-- internal resolution, so it works correctly at any stretch res.
local realMousePos = Vector2.new(0, 0)
UserInput.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        realMousePos = Vector2.new(input.Position.X, input.Position.Y)
    end
end)

local mouseLockConn = nil

local function ApplyMenuLock()
    if mouseLockConn then return end
    CustomCursor.Visible = true
    mouseLockConn = RunService.RenderStepped:Connect(function()
        -- Keep camera frozen
        if UserInput.MouseBehavior ~= Enum.MouseBehavior.Default then
            UserInput.MouseBehavior = Enum.MouseBehavior.Default
        end
        -- Snap cursor to tracked game-space position (stretch-res correct)
        CustomCursor.Position = UDim2.new(0, realMousePos.X, 0, realMousePos.Y)
    end)
    UserInput.MouseBehavior = Enum.MouseBehavior.Default
end

local function RemoveMenuLock()
    CustomCursor.Visible = false
    if mouseLockConn then
        mouseLockConn:Disconnect()
        mouseLockConn = nil
    end
    UserInput.MouseBehavior = Enum.MouseBehavior.LockCenter
end

-- ============================================================
-- TOGGLE GUI  [INSERT] or [RSHIFT]  (verified from original info text)
-- ============================================================
-- INSERT / RSHIFT always fires — no gameProcessed guard.
-- When the menu is open and cursor is free, Roblox marks all keypresses
-- as gameProcessed (UI has focus), which would silently block the close key.
UserInput.InputBegan:Connect(function(input, _gameProcessed)
    -- Menu toggle — always fires regardless of UI focus
    if input.KeyCode == Enum.KeyCode.Insert
    or input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
        if ScreenGui.Enabled then
            ApplyMenuLock()
        else
            RemoveMenuLock()
        end
    end
    -- Force extract keybind [END]
    if input.KeyCode == Enum.KeyCode.End then
        ForceExtract()
    end
end)
