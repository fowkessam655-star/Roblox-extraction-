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
    Aimbot_Enabled  = true,
    ESP_Enabled     = false,
    NPC_Enabled     = false,
    ESP_Type        = "2D Box",      -- original: "Caja 2D"
    ESP_ShowInfo    = true,
    ESP_Skeleton    = true,
    ESP_MaxDistance = 1000,
    FOV_Radius      = 1500,
    Aim_Part        = "Head",
    Aim_Smoothness  = 0.2,
}

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
    pad.PaddingTop    = UDim.new(0, 8)
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

    local labelText = Instance.new("TextLabel", row)
    labelText.Size = UDim2.new(0.6, 0, 0, 16)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Colors.Gray1
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.TextXAlignment = Enum.TextXAlignment.Left

    local valueText = Instance.new("TextLabel", row)
    valueText.Size = UDim2.new(0.4, 0, 0, 16)
    valueText.Position = UDim2.new(0.6, 0, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = tostring(default)
    valueText.TextColor3 = Colors.Accent
    valueText.Font = Enum.Font.GothamBold
    valueText.TextSize = 12
    valueText.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("TextButton", row)
    track.Size = UDim2.new(1, 0, 0, 8)
    track.Position = UDim2.new(0, 0, 0, 22)
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

    local labelText = Instance.new("TextLabel", row)
    labelText.Size = UDim2.new(0.55, 0, 1, 0)
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

-- ── SETTINGS TAB  (original: "Ajustes") ─────────────────────
-- Section: "System Information"
local infoSection = CreateSection(SettingsTab, "System Information")
local infoText = Instance.new("TextLabel", infoSection)
infoText.Size = UDim2.new(1, -12, 0, 60)
infoText.BackgroundTransparency = 1
infoText.TextColor3 = Colors.Gray1
-- translated from original Spanish info text
infoText.Text =
    "[INSERT] or [RSHIFT] to hide the panel.\n" ..
    "[RIGHT CLICK] to activate Aimbot.\n" ..
    "Aim requires visibility and respects Max ESP Distance."
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 11
infoText.TextWrapped = true
infoText.TextXAlignment = Enum.TextXAlignment.Left

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
-- SET DEFAULT TAB
-- ============================================================
TabButtons["Aimbot"].BackgroundColor3 = Colors.BG3
TabButtons["Aimbot"].TextColor3       = Colors.Green
TabPages["Aimbot"].Visible            = true

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
    -- Dummy: silent no-op if Drawing unavailable
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
        Box      = NewDrawing("Square"),
        Text     = NewDrawing("Text"),
        Skeleton = {},
        Highlight = hl,
    }
    entry.Box.Thickness = 1.5
    entry.Box.Filled    = false
    entry.Text.Size     = 13
    entry.Text.Center   = true
    entry.Text.Outline  = true
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
    entry.Box.Visible  = false
    entry.Text.Visible = false
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
                -- verified: original uses "[NPC] " prefix
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
            for _, bone in ipairs(entry.Skeleton) do
                pcall(function() bone:Remove() end)
            end
            if entry.Highlight.Parent then
                pcall(function() entry.Highlight:Destroy() end)
            end
            ESPObjects[model] = nil
        end
    end

    -- ESP render
    for _, target in ipairs(targets) do
        local model = target.Model
        local hum   = model:FindFirstChildOfClass("Humanoid")
        -- "HumanoidRootPart" verified from decoded strings
        local root  = model:FindFirstChild("HumanoidRootPart")
        local entry = ESPObjects[model] or CreateESPEntry(model)

        local shouldShow = (target.IsNPC and Settings.NPC_Enabled)
                        or (not target.IsNPC and Settings.ESP_Enabled)

        if shouldShow and hum and hum.Health > 0 and root then
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local dist  = (Camera.CFrame.Position - root.Position).Magnitude
            -- Orange for NPCs, Accent for players (verified from original)
            local color = target.IsNPC and Colors.Orange or Colors.Accent

            if dist <= Settings.ESP_MaxDistance and onScreen then
                entry.Box.Color              = color
                entry.Text.Color             = color
                entry.Highlight.FillColor    = color
                entry.Highlight.OutlineColor = Colors.Green

                for _, bone in ipairs(entry.Skeleton) do bone.Color = color end

                -- "Full" = Highlight overlay, "2D Box" = drawn box
                if Settings.ESP_Type == "Full" then
                    entry.Box.Visible        = false
                    entry.Highlight.Adornee  = model
                    entry.Highlight.Parent   = workspace
                else
                    if entry.Highlight.Parent then entry.Highlight.Parent = nil end
                    local head = model:FindFirstChild("Head")
                    if head then
                        local topPos, _    = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local bottomPos, _ = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                        local height = math.abs(topPos.Y - bottomPos.Y)
                        local width  = height * 0.6
                        entry.Box.Size     = Vector2.new(width, height)
                        entry.Box.Position = Vector2.new(screenPos.X - width / 2, topPos.Y)
                        entry.Box.Visible  = true
                    end
                end

                -- "Mostrar Nombre y Distancia" → Show Name and Distance
                if Settings.ESP_ShowInfo then
                    entry.Text.Text     = string.format("%s\n[%dm]", target.Name, math.floor(dist))
                    entry.Text.Position = Vector2.new(screenPos.X, screenPos.Y + (entry.Box.Size and entry.Box.Size.Y / 2 or 0) + 5)
                    entry.Text.Visible  = true
                else
                    entry.Text.Visible = false
                end

                -- "Mostrar Esqueleto" → Show Skeleton
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

    -- Aimbot (right click)
    local rmb = UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    if Settings.Aimbot_Enabled and rmb then
        if CurrentTarget and IsVisible(CurrentTarget) then
            local cf = CFrame.lookAt(Camera.CFrame.Position, CurrentTarget.Position)
            Camera.CFrame = Camera.CFrame:Lerp(cf, Settings.Aim_Smoothness)
        else
            CurrentTarget = nil
            local closest = Settings.FOV_Radius
            for _, target in ipairs(targets) do
                local show = (target.IsNPC and Settings.NPC_Enabled) or not target.IsNPC
                if show then
                    local model = target.Model
                    local hum   = model:FindFirstChildOfClass("Humanoid")
                    if model and hum and hum.Health > 0 then
                        local part = model:FindFirstChild(Settings.Aim_Part)
                        if part then
                            local dist = (Camera.CFrame.Position - part.Position).Magnitude
                            if dist <= Settings.ESP_MaxDistance then
                                local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                                if onScreen then
                                    local sd = (Vector2.new(sp.X, sp.Y) - screenCenter).Magnitude
                                    if sd < closest then
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
                                            closest       = sd
                                            CurrentTarget = part
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
end)

-- ============================================================
-- TOGGLE GUI  [INSERT] or [RSHIFT]  (verified from original info text)
-- ============================================================
UserInput.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.Insert
        or input.KeyCode == Enum.KeyCode.RightShift then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end
end)
