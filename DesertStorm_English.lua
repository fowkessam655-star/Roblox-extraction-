--[[
 .____                  ________ ___.    _____                           __
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  /\___  >____  /__|  \____/|__|
         \/          \/         \/    \/                \/     \/     \/
          Desert Storm -- English Translation
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

-- Destroy any existing menu instance
if CoreGui:FindFirstChild("Aura_Premium_Menu") then
    CoreGui.Aura_Premium_Menu:Destroy()
end

-- ============================================================
-- COLOR THEME
-- ============================================================
local Colors = {
    BG0    = Color3.fromRGB(12, 13, 16),
    BG1    = Color3.fromRGB(16, 18, 26),
    BG2    = Color3.fromRGB(19, 21, 30),
    BG3    = Color3.fromRGB(26, 29, 40),
    BG4    = Color3.fromRGB(32, 36, 58),
    Border = Color3.fromRGB(37, 40, 64),
    Accent = Color3.fromRGB(79, 138, 255),
    White  = Color3.fromRGB(0, 229, 160),
    Gray1  = Color3.fromRGB(0, 140, 255),
    Gray2  = Color3.fromRGB(255, 64, 96),
    Orange = Color3.fromRGB(255, 140, 0),
    Purple = Color3.fromRGB(122, 126, 153),
    Pink   = Color3.fromRGB(64, 68, 104),
}

-- ============================================================
-- SETTINGS
-- ============================================================
local Settings = {
    Aimbot_Enabled  = true,
    ESP_Enabled     = false,
    ESP_Type        = "Box",
    NPC_Enabled     = false,
    Aim_Part        = "Head",
    ESP_ShowInfo    = true,
    ESP_Skeleton    = true,
    FOV_Radius      = 1500,
    Aim_Smoothness  = 0.2,
    ESP_MaxDistance = 1000,
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

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(0, 150, 1, 0)
TitleLabel.Position = UDim2.new(0, 42, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Desert Storm"
TitleLabel.TextColor3 = Colors.White
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
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
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

local CategoryLabel = Instance.new("TextLabel", Sidebar)
CategoryLabel.Size = UDim2.new(1, -24, 0, 20)
CategoryLabel.Position = UDim2.new(0, 12, 0, 14)
CategoryLabel.BackgroundTransparency = 1
CategoryLabel.Text = "MENU"
CategoryLabel.TextColor3 = Colors.Gray2
CategoryLabel.Font = Enum.Font.GothamBold
CategoryLabel.TextSize = 10
CategoryLabel.TextXAlignment = Enum.TextXAlignment.Left

local TabScroll = Instance.new("ScrollingFrame", Sidebar)
TabScroll.Size = UDim2.new(1, 0, 1, -50)
TabScroll.Position = UDim2.new(0, 0, 0, 40)
TabScroll.BackgroundTransparency = 1

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
    btn.Text = icon .. "  " .. tabId
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

    local topPad = Instance.new("UIPadding", page)
    topPad.PaddingTop = UDim.new(0, 16)
    topPad.PaddingBottom = UDim.new(0, 8)
    BindScrollResize(page, pageLayout)

    btn.MouseButton1Click:Connect(function()
        for id, b in pairs(TabButtons) do
            b.BackgroundColor3 = (id == tabId) and Colors.BG3 or Colors.BG1
            b.TextColor3       = (id == tabId) and Colors.White or Colors.Gray1
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
    titleLabel.TextColor3 = Colors.White
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local divLine = Instance.new("Frame", section)
    divLine.Size = UDim2.new(1, -24, 0, 1)
    divLine.Position = UDim2.new(0, 12, 0, 36)
    divLine.BackgroundColor3 = Colors.Border
    divLine.BorderSizePixel = 0

    local itemContainer = Instance.new("Frame", section)
    itemContainer.Size = UDim2.new(1, 0, 0, 0)
    itemContainer.Position = UDim2.new(0, 0, 0, 37)
    itemContainer.BackgroundTransparency = 1

    local itemLayout = Instance.new("UIListLayout", itemContainer)
    itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
    itemLayout.Padding = UDim.new(0, 4)
    itemLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local pad = Instance.new("UIPadding", itemContainer)
    pad.PaddingTop    = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)

    itemLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        itemContainer.Size = UDim2.new(1, 0, 0, itemLayout.AbsoluteContentSize.Y + 16)
        section.Size = UDim2.new(1, -36, 0, 37 + itemContainer.Size.Y.Offset)
    end)

    return itemContainer
end

-- ============================================================
-- TOGGLE BUILDER
-- ============================================================
local function CreateToggle(parent, label, default, callback)
    local row = Instance.new("TextButton", parent)
    row.Size = UDim2.new(1, -24, 0, 26)
    row.Position = UDim2.new(0, 12, 0, 0)
    row.BackgroundTransparency = 1

    local labelText = Instance.new("TextLabel", row)
    labelText.Size = UDim2.new(0.7, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Colors.Gray1
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.TextXAlignment = Enum.TextXAlignment.Left

    local toggleTrack = Instance.new("TextButton", row)
    toggleTrack.Size = UDim2.new(0, 36, 0, 18)
    toggleTrack.AnchorPoint = Vector2.new(1, 0.5)
    toggleTrack.Position = UDim2.new(1, 0, 0.5, 0)
    toggleTrack.BackgroundColor3 = default and Colors.Accent or Colors.Gray2
    toggleTrack.Text = ""
    toggleTrack.AutoButtonColor = false
    Instance.new("UICorner", toggleTrack).CornerRadius = UDim.new(1, 0)

    local toggleKnob = Instance.new("Frame", toggleTrack)
    toggleKnob.Size = UDim2.new(0, 14, 0, 14)
    toggleKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    toggleKnob.Position = UDim2.new(default and 1 or 0, default and -16 or 2, 0.5, 0)
    toggleKnob.BackgroundColor3 = Colors.White
    Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(1, 0)

    local state = default
    toggleTrack.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        TweenService:Create(toggleTrack, TweenInfo.new(0.25), {
            BackgroundColor3 = state and Colors.Accent or Colors.Gray2
        }):Play()
        TweenService:Create(toggleKnob, TweenInfo.new(0.25), {
            Position = UDim2.new(state and 1 or 0, state and -16 or 2, 0.5, 0)
        }):Play()
    end)
end

-- ============================================================
-- SLIDER BUILDER
-- ============================================================
local function CreateSlider(parent, label, min, max, default, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -24, 0, 36)
    row.Position = UDim2.new(0, 12, 0, 0)
    row.BackgroundTransparency = 1

    local labelText = Instance.new("TextLabel", row)
    labelText.Size = UDim2.new(0.5, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Colors.Gray1
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.TextXAlignment = Enum.TextXAlignment.Left

    local valueText = Instance.new("TextLabel", row)
    valueText.Size = UDim2.new(0.5, 0, 1, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = tostring(default)
    valueText.TextColor3 = Colors.Accent
    valueText.Font = Enum.Font.GothamBold
    valueText.TextSize = 12
    valueText.TextXAlignment = Enum.TextXAlignment.Right

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
            local pct = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
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
    row.Position = UDim2.new(0, 12, 0, 0)
    row.BackgroundTransparency = 1

    local labelText = Instance.new("TextLabel", row)
    labelText.Size = UDim2.new(0.5, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Colors.Gray1
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.TextXAlignment = Enum.TextXAlignment.Left

    local dropBtn = Instance.new("TextButton", row)
    dropBtn.Size = UDim2.new(0, 100, 0, 22)
    dropBtn.AnchorPoint = Vector2.new(1, 0.5)
    dropBtn.Position = UDim2.new(1, 0, 0.5, 0)
    dropBtn.BackgroundColor3 = Colors.BG4
    dropBtn.TextColor3 = Colors.White
    dropBtn.Font = Enum.Font.GothamSemibold
    dropBtn.TextSize = 11
    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 4)

    local currentIndex = defaultIndex
    dropBtn.Text = options[currentIndex]

    dropBtn.MouseButton1Click:Connect(function()
        currentIndex = (currentIndex % #options) + 1
        dropBtn.Text = options[currentIndex]
        callback(options[currentIndex])
    end)
end

-- ============================================================
-- BUILD TABS
-- ============================================================
local AimbotTab = CreateTab("Aimbot", "◎")
local ESPTab    = CreateTab("ESP",    "◈")
local ConfigTab = CreateTab("Config", "⚙")
local DumpTab   = CreateTab("Dump",   "◉")

-- Aimbot tab
local aimbotSection = CreateSection(AimbotTab, "Normal Aimbot (Camera)")
CreateToggle(aimbotSection, "Camera Aimbot", Settings.Aimbot_Enabled, function(v)
    Settings.Aimbot_Enabled = v
end)

local aimbotConfig = CreateSection(AimbotTab, "Configuration")
CreateSlider(aimbotConfig, "FOV Radius", 30, 800, Settings.FOV_Radius, function(v)
    Settings.FOV_Radius = v
end)
CreateSlider(aimbotConfig, "Aim Smoothness", 1, 100, Settings.Aim_Smoothness * 100, function(v)
    Settings.Aim_Smoothness = v / 100
end)
CreateDropdown(aimbotConfig, "Aim Target Part", {"Head", "HumanoidRootPart", "Torso"}, 1, function(v)
    Settings.Aim_Part = v
end)

-- ESP tab
local espToggle = CreateSection(ESPTab, "ESP Toggles")
CreateToggle(espToggle, "ESP Enabled", Settings.ESP_Enabled, function(v) Settings.ESP_Enabled = v end)
CreateToggle(espToggle, "NPC ESP",     Settings.NPC_Enabled, function(v) Settings.NPC_Enabled = v end)

local espConfig = CreateSection(ESPTab, "ESP Options")
CreateDropdown(espConfig, "ESP Type", {"Box", "Highlight"}, 1, function(v) Settings.ESP_Type = v end)
CreateToggle(espConfig, "Show Name & Distance", Settings.ESP_ShowInfo, function(v) Settings.ESP_ShowInfo = v end)
CreateToggle(espConfig, "Skeleton ESP",         Settings.ESP_Skeleton, function(v) Settings.ESP_Skeleton = v end)
CreateSlider(espConfig,  "Maximum ESP Distance", 50, 5000, Settings.ESP_MaxDistance, function(v)
    Settings.ESP_MaxDistance = v
end)

-- Config tab
local infoSection = CreateSection(ConfigTab, "System Information")
local infoText = Instance.new("TextLabel", infoSection)
infoText.Size = UDim2.new(1, -12, 0, 50)
infoText.Position = UDim2.new(0, 12, 0, 0)
infoText.BackgroundTransparency = 1
infoText.TextColor3 = Colors.Gray1
infoText.Text = "[INSERT] or [RSHIFT] to hide the panel.\n[RIGHT CLICK] to activate Aimbot.\nAim requires line of sight and respects ESP Max Distance."
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 11
infoText.TextWrapped = true
infoText.TextXAlignment = Enum.TextXAlignment.Left

-- Default active tab
TabButtons["Aimbot"].BackgroundColor3 = Colors.BG3
TabButtons["Aimbot"].TextColor3       = Colors.White
TabPages["Aimbot"].Visible            = true

-- ============================================================
-- DRAWING SUPPORT CHECK + DUMMY FALLBACK
-- ============================================================
local DrawingSupported = (typeof(Drawing) == "table" or typeof(Drawing) == "userdata")
    and typeof(Drawing.new) == "function"

-- If the executor doesn't expose Drawing, we create a dummy
-- object factory so the rest of the script never errors on nil.
local function NewDrawing(kind)
    if DrawingSupported then
        local ok, obj = pcall(Drawing.new, kind)
        if ok then return obj end
    end
    -- Dummy: swallows all property sets silently, has no-op Remove()
    local dummy = {}
    local mt = {
        __index = function(_, k) return dummy[k] end,
        __newindex = function(_, k, v) rawset(dummy, k, v) end,
    }
    setmetatable(dummy, mt)
    dummy.Visible = false
    dummy.Remove  = function() end
    dummy.Destroy = function() end
    return dummy
end

-- ============================================================
-- ESP DRAWING
-- ============================================================
local ESPObjects = {}

local FOVCircle = NewDrawing("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color     = Colors.Accent
FOVCircle.Filled    = false

local function CreateESPEntry(model)
    local entry = {
        Box       = NewDrawing("Square"),
        Text      = NewDrawing("Text"),
        Skeleton  = {},
        Highlight = Instance.new("SelectionBox"),
    }
    entry.Box.Thickness  = 1.5
    entry.Box.Filled     = false
    entry.Text.Size      = 13
    entry.Text.Center    = true
    entry.Text.Outline   = true
    entry.Highlight.FillTransparency    = 0.5
    entry.Highlight.OutlineTransparency = 0.1
    for i = 1, 12 do
        local bone = NewDrawing("Line")
        bone.Thickness = 1.5
        table.insert(entry.Skeleton, bone)
    end
    ESPObjects[model] = entry
    return entry
end

-- ============================================================
-- BONE PAIRS
-- ============================================================
local R15Bones = {
    {"UpperTorso",    "LowerTorso"},
    {"UpperTorso",    "LeftUpperArm"},
    {"LeftUpperArm",  "LeftLowerArm"},
    {"UpperTorso",    "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"UpperTorso",    "Head"},
    {"LowerTorso",    "LeftUpperLeg"},
    {"LeftUpperLeg",  "LeftLowerLeg"},
    {"LowerTorso",    "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"LeftLowerArm",  "LeftHand"},
    {"RightLowerArm", "RightHand"},
}
local R6Bones = {
    {"Torso", "Head"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

local function HideESP(entry)
    if not entry then return end
    entry.Box.Visible  = false
    entry.Text.Visible = false
    if entry.Highlight.Parent then entry.Highlight.Parent = nil end
    for _, bone in ipairs(entry.Skeleton) do bone.Visible = false end
end

-- ============================================================
-- VISIBILITY CHECK
-- ============================================================
local function IsVisible(part)
    if not part or not part.Parent then return false end
    local char = part.Parent
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local _, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then return false end
    if not hum or hum.Health <= 0 then return false end
    local dist = (Camera.CFrame.Position - part.Position).Magnitude
    if dist > Settings.ESP_MaxDistance then return false end
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
            table.insert(targets, { Model = plr.Character, IsNPC = false, Name = plr.Name })
        end
    end
    for model in pairs(NPCTable) do
        if model and model.Parent then
            table.insert(targets, { Model = model, IsNPC = true, Name = "NPC: " .. model.Name })
        else
            NPCTable[model] = nil
        end
    end

    -- Clean stale ESP entries
    for model, entry in pairs(ESPObjects) do
        if not model or not model.Parent then
            entry.Box:Remove()
            entry.Text:Remove()
            for _, bone in ipairs(entry.Skeleton) do bone:Remove() end
            if entry.Highlight.Parent then entry.Highlight:Destroy() end
            ESPObjects[model] = nil
        end
    end

    -- ESP render
    for _, target in ipairs(targets) do
        local model = target.Model
        local hum   = model:FindFirstChildOfClass("Humanoid")
        local root  = model:FindFirstChild("HumanoidRootPart")
        local entry = ESPObjects[model] or CreateESPEntry(model)
        local shouldShow = (target.IsNPC and Settings.NPC_Enabled) or (not target.IsNPC and Settings.ESP_Enabled)

        if shouldShow and hum and hum.Health > 0 and root then
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local dist  = (Camera.CFrame.Position - root.Position).Magnitude
            local color = target.IsNPC and Colors.Orange or Colors.Accent

            if dist <= Settings.ESP_MaxDistance and onScreen then
                entry.Box.Color              = color
                entry.Text.Color             = color
                entry.Highlight.FillColor    = color
                entry.Highlight.OutlineColor = Colors.White
                for _, bone in ipairs(entry.Skeleton) do bone.Color = color end

                if Settings.ESP_Type == "Highlight" then
                    entry.Box.Visible       = false
                    entry.Highlight.Parent  = model
                    entry.Highlight.Adornee = model
                else
                    entry.Highlight.Parent = nil
                    if Settings.ESP_Type == "Box" then
                        local head = model:FindFirstChild("Head")
                        if head then
                            local topPos    = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                            local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                            local height    = math.abs(topPos.Y - bottomPos.Y)
                            local width     = height * 0.6
                            entry.Box.Size     = Vector2.new(width, height)
                            entry.Box.Position = Vector2.new(screenPos.X - width / 2, topPos.Y)
                            entry.Box.Visible  = true
                        end
                    end
                end

                if Settings.ESP_ShowInfo then
                    entry.Text.Text     = string.format("%s\n[%dm]", target.Name, math.floor(dist))
                    entry.Text.Position = Vector2.new(screenPos.X, screenPos.Y + entry.Box.Size.Y / 2 + 5)
                    entry.Text.Visible  = true
                else
                    entry.Text.Visible = false
                end

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
                                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                                if onScreen then
                                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                                    if screenDist < closest then
                                        local params = RaycastParams.new()
                                        params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                                        params.FilterType  = Enum.RaycastFilterType.Exclude
                                        params.IgnoreWater = true
                                        local ray = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
                                        if not ray or ray.Instance:IsDescendantOf(model) then
                                            closest       = screenDist
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
-- OFFSET DUMPER TAB
-- ============================================================
local dumpSection = CreateSection(DumpTab, "Offset Dumper")

-- Output box (scrolling frame with text)
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

-- Auto-resize scroll canvas when text changes
dumpOutput:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    dumpScrollFrame.CanvasSize = UDim2.new(0, 0, 0, dumpOutput.AbsoluteSize.Y + 8)
end)

-- Status label
local dumpStatus = Instance.new("TextLabel", dumpSection)
dumpStatus.Size = UDim2.new(1, -12, 0, 18)
dumpStatus.BackgroundTransparency = 1
dumpStatus.TextColor3 = Colors.Gray1
dumpStatus.Font = Enum.Font.GothamBold
dumpStatus.TextSize = 10
dumpStatus.TextXAlignment = Enum.TextXAlignment.Left
dumpStatus.Text = "status: idle"

-- Button row
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

-- ============================================================
-- DUMP LOGIC
-- ============================================================
local function RunDump()
    dumpStatus.Text = "status: scanning..."
    dumpOutput.Text = ""
    task.wait()

    local lines = {}
    local function add(s) table.insert(lines, s) end

    -- ── GAME INFO ─────────────────────────────────────────────
    add("╔══════════════════════════════════════")
    add("║  GAME INFO")
    add("╠══════════════════════════════════════")
    add("  PlaceId      : " .. tostring(game.PlaceId))
    add("  GameId       : " .. tostring(game.GameId))
    add("  PlaceVersion : " .. tostring(game.PlaceVersion))
    add("  CreatorId    : " .. tostring(game.CreatorId))
    add("  CreatorType  : " .. tostring(game.CreatorType))
    add("  Name         : " .. tostring(game.Name))
    add("")

    -- ── LOCAL PLAYER ──────────────────────────────────────────
    add("╔══════════════════════════════════════")
    add("║  LOCAL PLAYER")
    add("╠══════════════════════════════════════")
    add("  Name         : " .. LocalPlayer.Name)
    add("  UserId       : " .. tostring(LocalPlayer.UserId))
    add("  TeamColor    : " .. tostring(LocalPlayer.TeamColor))
    add("  AccountAge   : " .. tostring(LocalPlayer.AccountAge))

    local char = LocalPlayer.Character
    if char then
        local hum  = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        add("")
        add("  [ CHARACTER ]")
        add("  Path         : workspace." .. char.Name)
        if hum then
            add("  Hum.Health       : " .. tostring(hum.Health))
            add("  Hum.MaxHealth    : " .. tostring(hum.MaxHealth))
            add("  Hum.WalkSpeed    : " .. tostring(hum.WalkSpeed))
            add("  Hum.JumpPower    : " .. tostring(hum.JumpPower))
            add("  Hum.JumpHeight   : " .. tostring(hum.JumpHeight))
            add("  Hum.RigType      : " .. tostring(hum.RigType))
            add("  Hum.DisplayName  : " .. tostring(hum.DisplayName))
        end
        if root then
            add("  RootPart.Pos     : " .. tostring(root.Position))
            add("  RootPart.Vel     : " .. tostring(root.AssemblyLinearVelocity))
        end
        add("")
        add("  [ PARTS ]")
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                add("  " .. part.Name .. " @ " .. tostring(part.Position))
            end
        end
    end
    add("")

    -- ── REMOTE EVENTS ─────────────────────────────────────────
    add("╔══════════════════════════════════════")
    add("║  REMOTE EVENTS")
    add("╠══════════════════════════════════════")
    local remoteCount = 0
    local function ScanRemotes(parent, path)
        for _, obj in ipairs(parent:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                add("  [RE]  " .. path .. "." .. obj:GetFullName():gsub("^[^.]+%.", ""))
                remoteCount = remoteCount + 1
            elseif obj:IsA("RemoteFunction") then
                add("  [RF]  " .. path .. "." .. obj:GetFullName():gsub("^[^.]+%.", ""))
                remoteCount = remoteCount + 1
            elseif obj:IsA("UnreliableRemoteEvent") then
                add("  [URE] " .. path .. "." .. obj:GetFullName():gsub("^[^.]+%.", ""))
                remoteCount = remoteCount + 1
            end
        end
    end
    local RS = game:GetService("ReplicatedStorage")
    local RFS = pcall(function() return game:GetService("ReplicatedFirst") end) and game:GetService("ReplicatedFirst")
    ScanRemotes(RS, "ReplicatedStorage")
    if RFS then ScanRemotes(RFS, "ReplicatedFirst") end
    ScanRemotes(workspace, "workspace")
    add("  Total found: " .. remoteCount)
    add("")

    -- ── SCRIPTS ───────────────────────────────────────────────
    add("╔══════════════════════════════════════")
    add("║  LOCAL SCRIPTS")
    add("╠══════════════════════════════════════")
    local scriptCount = 0
    for _, obj in ipairs(LocalPlayer:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local tag = obj:IsA("LocalScript") and "[LS]" or "[MOD]"
            add("  " .. tag .. " " .. obj:GetFullName())
            scriptCount = scriptCount + 1
        end
    end
    if scriptCount == 0 then add("  none found") end
    add("")

    -- ── PLAYER GUIS ───────────────────────────────────────────
    add("╔══════════════════════════════════════")
    add("║  PLAYER GUIS")
    add("╠══════════════════════════════════════")
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg then
        for _, gui in ipairs(pg:GetChildren()) do
            add("  " .. gui.ClassName .. " : " .. gui.Name)
        end
    end
    add("")

    -- ── TOOLS / WEAPONS ───────────────────────────────────────
    add("╔══════════════════════════════════════")
    add("║  TOOLS / WEAPONS")
    add("╠══════════════════════════════════════")
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    local toolCount = 0
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                add("  [TOOL] " .. tool.Name)
                for _, v in ipairs(tool:GetDescendants()) do
                    if v:IsA("NumberValue") or v:IsA("IntValue") or v:IsA("StringValue") or v:IsA("BoolValue") then
                        add("         ." .. v.Name .. " = " .. tostring(v.Value))
                    end
                    if v:IsA("Configuration") or v:IsA("ModuleScript") then
                        add("         [" .. v.ClassName .. "] " .. v.Name)
                    end
                end
                toolCount = toolCount + 1
            end
        end
    end
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                add("  [EQUIPPED] " .. tool.Name)
                for _, v in ipairs(tool:GetDescendants()) do
                    if v:IsA("NumberValue") or v:IsA("IntValue") or v:IsA("StringValue") or v:IsA("BoolValue") then
                        add("             ." .. v.Name .. " = " .. tostring(v.Value))
                    end
                end
                toolCount = toolCount + 1
            end
        end
    end
    if toolCount == 0 then add("  none found") end
    add("")

    -- ── VALUE OBJECTS ─────────────────────────────────────────
    add("╔══════════════════════════════════════")
    add("║  PLAYER VALUE OBJECTS (leaderstats etc)")
    add("╠══════════════════════════════════════")
    local function DumpValues(parent, indent)
        for _, v in ipairs(parent:GetChildren()) do
            if v:IsA("NumberValue") or v:IsA("IntValue") or v:IsA("StringValue")
            or v:IsA("BoolValue") or v:IsA("Vector3Value") then
                add(indent .. v.Name .. " [" .. v.ClassName .. "] = " .. tostring(v.Value))
            elseif v:IsA("Folder") or v:IsA("Configuration") then
                add(indent .. "[" .. v.ClassName .. "] " .. v.Name)
                DumpValues(v, indent .. "  ")
            end
        end
    end
    DumpValues(LocalPlayer, "  ")
    add("")

    -- ── REPLICATED STORAGE ────────────────────────────────────
    add("╔══════════════════════════════════════")
    add("║  REPLICATED STORAGE (top level)")
    add("╠══════════════════════════════════════")
    for _, obj in ipairs(RS:GetChildren()) do
        add("  [" .. obj.ClassName .. "] " .. obj.Name)
    end
    add("")

    -- ── WORKSPACE MODELS ──────────────────────────────────────
    add("╔══════════════════════════════════════")
    add("║  WORKSPACE MODELS (top level)")
    add("╠══════════════════════════════════════")
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= LocalPlayer.Character then
            local hum2 = obj:FindFirstChildOfClass("Humanoid")
            local tag  = hum2 and "[NPC] " or "[MDL] "
            add("  " .. tag .. obj.Name)
        end
    end
    add("")

    -- ── BINDABLE EVENTS ───────────────────────────────────────
    add("╔══════════════════════════════════════")
    add("║  BINDABLE EVENTS / FUNCTIONS")
    add("╠══════════════════════════════════════")
    local bcount = 0
    for _, obj in ipairs(RS:GetDescendants()) do
        if obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
            add("  [" .. obj.ClassName .. "] " .. obj:GetFullName())
            bcount = bcount + 1
        end
    end
    if bcount == 0 then add("  none found in ReplicatedStorage") end
    add("")

    -- ── CAMERA ────────────────────────────────────────────────
    add("╔══════════════════════════════════════")
    add("║  CAMERA")
    add("╠══════════════════════════════════════")
    add("  CameraType     : " .. tostring(Camera.CameraType))
    add("  FieldOfView    : " .. tostring(Camera.FieldOfView))
    add("  Position       : " .. tostring(Camera.CFrame.Position))
    add("  ViewportSize   : " .. tostring(Camera.ViewportSize))
    add("")

    add("╔══════════════════════════════════════")
    add("║  DUMP COMPLETE")
    add("╚══════════════════════════════════════")

    dumpOutput.Text = table.concat(lines, "\n")
    dumpScrollFrame.CanvasSize = UDim2.new(0, 0, 0, dumpOutput.AbsoluteSize.Y + 8)
    dumpStatus.Text = "status: done — " .. #lines .. " lines dumped"
end

MakeButton(btnRow, "▶  DUMP", Colors.Accent, function()
    task.spawn(RunDump)
end)

MakeButton(btnRow, "✕  CLEAR", Colors.Gray2, function()
    dumpOutput.Text = "[ press DUMP to scan the game ]"
    dumpScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 60)
    dumpStatus.Text = "status: idle"
end)

-- ============================================================
-- TOGGLE GUI  [INSERT] or [RIGHT SHIFT]
-- ============================================================
UserInput.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.Insert
        or input.KeyCode == Enum.KeyCode.RightShift then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end
end)
