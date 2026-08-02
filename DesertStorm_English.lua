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
    BG0    = Color3.fromRGB(7,    8,   13),   -- near-black base
    BG1    = Color3.fromRGB(11,  14,  22),    -- sidebar
    BG2    = Color3.fromRGB(15,  18,  29),    -- content
    BG3    = Color3.fromRGB(21,  25,  41),    -- sections
    BG4    = Color3.fromRGB(29,  34,  57),    -- tracks / hover
    Border = Color3.fromRGB(42,  50,  84),    -- borders
    Accent = Color3.fromRGB(82,  130, 255),   -- electric blue
    Glow   = Color3.fromRGB(148, 182, 255),   -- lighter accent
    Green  = Color3.fromRGB(0,   210, 130),   -- teammate / success
    Orange = Color3.fromRGB(255, 165, 45),    -- NPC / warning
    Red    = Color3.fromRGB(255, 65,  85),    -- enemy / danger
    White  = Color3.fromRGB(215, 222, 255),   -- primary text
    Gray1  = Color3.fromRGB(128, 138, 174),   -- secondary text
    Gray2  = Color3.fromRGB(44,  50,  82),    -- disabled
}

-- ============================================================
-- SETTINGS  (verified from decoded original)
-- ============================================================
local Settings = {
    -- aimbot
    Aimbot_Enabled  = true,
    FOV_Radius      = 150,
    FOV_Circle      = true,
    Aim_Part        = "Head",
    Aim_Smoothness  = 0.2,
    Aim_Key         = "Right Click",
    Aim_Priority    = "FOV",
    NoRecoil        = false,
    NoSway          = false,
    SpeedHack       = false,
    SpeedValue      = 32,
    NoClip          = false,
    MagicBullet     = false,
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
ScreenGui.Name            = "Aura_Premium_Menu"
ScreenGui.ResetOnSpawn    = false
ScreenGui.IgnoreGuiInset  = true
ScreenGui.Parent          = CoreGui

local W, H = 570, 510
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size              = UDim2.new(0, W, 0, H)
MainFrame.Position          = UDim2.new(0.5, -W/2, 0.5, -H/2)
MainFrame.BackgroundColor3  = Colors.BG0
MainFrame.BorderSizePixel   = 0
MainFrame.ClipsDescendants  = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Outer border glow
local BorderStroke = Instance.new("UIStroke", MainFrame)
BorderStroke.Color     = Colors.Accent
BorderStroke.Thickness = 1
BorderStroke.Transparency = 0.6

-- ── HEADER ───────────────────────────────────────────────────
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size             = UDim2.new(1, 0, 0, 46)
TitleBar.BackgroundColor3 = Colors.BG1
TitleBar.BorderSizePixel  = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

-- Clip the bottom corners of the header so it merges cleanly
local TitleBarClip = Instance.new("Frame", TitleBar)
TitleBarClip.Size             = UDim2.new(1, 0, 0, 10)
TitleBarClip.Position         = UDim2.new(0, 0, 1, -10)
TitleBarClip.BackgroundColor3 = Colors.BG1
TitleBarClip.BorderSizePixel  = 0

-- Accent dot (logo badge)
local LogoBadge = Instance.new("Frame", TitleBar)
LogoBadge.Size             = UDim2.new(0, 26, 0, 26)
LogoBadge.Position         = UDim2.new(0, 14, 0.5, -13)
LogoBadge.BackgroundColor3 = Colors.Accent
LogoBadge.BorderSizePixel  = 0
Instance.new("UICorner", LogoBadge).CornerRadius = UDim.new(0, 6)

local LogoText = Instance.new("TextLabel", LogoBadge)
LogoText.Size                = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text                = "A"
LogoText.TextColor3          = Color3.fromRGB(255, 255, 255)
LogoText.Font                = Enum.Font.GothamBold
LogoText.TextSize             = 14

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size               = UDim2.new(0, 160, 1, 0)
TitleLabel.Position           = UDim2.new(0, 48, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text               = "AURA"
TitleLabel.TextColor3         = Colors.White
TitleLabel.Font               = Enum.Font.GothamBold
TitleLabel.TextSize           = 15
TitleLabel.TextXAlignment     = Enum.TextXAlignment.Left

local SubLabel = Instance.new("TextLabel", TitleBar)
SubLabel.Size               = UDim2.new(0, 100, 0, 14)
SubLabel.Position           = UDim2.new(0, 48, 0.5, 4)
SubLabel.BackgroundTransparency = 1
SubLabel.Text               = "OVERLAY  v2"
SubLabel.TextColor3         = Colors.Gray1
SubLabel.Font               = Enum.Font.Gotham
SubLabel.TextSize            = 10
SubLabel.TextXAlignment     = Enum.TextXAlignment.Left

-- Header bottom separator
local Divider = Instance.new("Frame", MainFrame)
Divider.Size             = UDim2.new(1, 0, 0, 1)
Divider.Position         = UDim2.new(0, 0, 0, 46)
Divider.BackgroundColor3 = Colors.Border
Divider.BorderSizePixel  = 0

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
local SIDEBAR_W = 148
local HEADER_H  = 47

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size             = UDim2.new(0, SIDEBAR_W, 1, -HEADER_H)
Sidebar.Position         = UDim2.new(0, 0, 0, HEADER_H)
Sidebar.BackgroundColor3 = Colors.BG1
Sidebar.BorderSizePixel  = 0

-- Bottom-left clip so sidebar doesn't round past main frame corners
local SidebarCornerClip = Instance.new("Frame", Sidebar)
SidebarCornerClip.Size             = UDim2.new(1, 0, 0, 10)
SidebarCornerClip.Position         = UDim2.new(0, 0, 0, 0)
SidebarCornerClip.BackgroundColor3 = Colors.BG1
SidebarCornerClip.BorderSizePixel  = 0

local SidebarDivider = Instance.new("Frame", MainFrame)
SidebarDivider.Size             = UDim2.new(0, 1, 1, -HEADER_H)
SidebarDivider.Position         = UDim2.new(0, SIDEBAR_W, 0, HEADER_H)
SidebarDivider.BackgroundColor3 = Colors.Border
SidebarDivider.BorderSizePixel  = 0

-- "NAVIGATION" micro-label
local CategoryLabel = Instance.new("TextLabel", Sidebar)
CategoryLabel.Size               = UDim2.new(1, -20, 0, 18)
CategoryLabel.Position           = UDim2.new(0, 10, 0, 14)
CategoryLabel.BackgroundTransparency = 1
CategoryLabel.Text               = "NAVIGATION"
CategoryLabel.TextColor3         = Colors.Gray1
CategoryLabel.Font               = Enum.Font.GothamBold
CategoryLabel.TextSize           = 9
CategoryLabel.TextXAlignment     = Enum.TextXAlignment.Left

local TabScroll = Instance.new("ScrollingFrame", Sidebar)
TabScroll.Size                  = UDim2.new(1, 0, 1, -42)
TabScroll.Position              = UDim2.new(0, 0, 0, 40)
TabScroll.BackgroundTransparency= 1
TabScroll.ScrollBarThickness    = 0
TabScroll.CanvasSize            = UDim2.new(0, 0, 0, 0)

local TabLayout = Instance.new("UIListLayout", TabScroll)
TabLayout.SortOrder           = Enum.SortOrder.LayoutOrder
TabLayout.Padding             = UDim.new(0, 2)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local TabPad = Instance.new("UIPadding", TabScroll)
TabPad.PaddingTop  = UDim.new(0, 4)
TabPad.PaddingLeft = UDim.new(0, 8)
TabPad.PaddingRight= UDim.new(0, 8)

local ContentPanel = Instance.new("Frame", MainFrame)
ContentPanel.Size             = UDim2.new(1, -(SIDEBAR_W+1), 1, -HEADER_H)
ContentPanel.Position         = UDim2.new(0, SIDEBAR_W+1, 0, HEADER_H)
ContentPanel.BackgroundColor3 = Colors.BG2
ContentPanel.BorderSizePixel  = 0

local TabButtons    = {}
local TabPages      = {}
local TabAccentBars = {}

local function BindScrollResize(scroll, layout)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
    end)
end

-- ── TAB BUILDER ──────────────────────────────────────────────
local function CreateTab(tabId, icon)
    -- Container so we can add the accent bar without fighting TextButton layout
    local wrap = Instance.new("Frame", TabScroll)
    wrap.Size             = UDim2.new(1, 0, 0, 36)
    wrap.BackgroundColor3 = Colors.BG1
    wrap.BorderSizePixel  = 0
    Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 7)

    -- Left accent bar (visible when active)
    local accent = Instance.new("Frame", wrap)
    accent.Size             = UDim2.new(0, 3, 0, 18)
    accent.Position         = UDim2.new(0, 0, 0.5, -9)
    accent.BackgroundColor3 = Colors.Accent
    accent.BorderSizePixel  = 0
    accent.Visible          = false
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

    local btn = Instance.new("TextButton", wrap)
    btn.Size                = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text                = "  " .. icon .. "   " .. tabId
    btn.TextColor3          = Colors.Gray1
    btn.Font                = Enum.Font.GothamSemibold
    btn.TextSize             = 12
    btn.TextXAlignment      = Enum.TextXAlignment.Left
    btn.AutoButtonColor     = false

    local page = Instance.new("ScrollingFrame", ContentPanel)
    page.Size                   = UDim2.new(1, 0, 1, 0)
    page.Visible                = false
    page.BackgroundTransparency = 1
    page.ScrollBarThickness     = 3
    page.ScrollBarImageColor3   = Colors.Border

    local pageLayout = Instance.new("UIListLayout", page)
    pageLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    pageLayout.Padding             = UDim.new(0, 10)
    pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Adaptive padding — percentage-based top/bottom, pixel left/right
    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop    = UDim.new(0, 14)
    pad.PaddingBottom = UDim.new(0, 14)
    pad.PaddingLeft   = UDim.new(0, 14)
    pad.PaddingRight  = UDim.new(0, 14)
    BindScrollResize(page, pageLayout)

    local function activate()
        for id, w in pairs(TabButtons) do
            local isActive = (id == tabId)
            w.BackgroundColor3 = isActive and Colors.BG3 or Colors.BG1
            -- find the TextButton inside the wrap
            local b = w:FindFirstChildWhichIsA("TextButton")
            if b then
                b.TextColor3 = isActive and Colors.White or Colors.Gray1
            end
            if TabAccentBars[id] then
                TabAccentBars[id].Visible = isActive
            end
        end
        for id, p in pairs(TabPages) do
            p.Visible = (id == tabId)
        end
    end

    btn.MouseButton1Click:Connect(activate)
    -- Hover highlight
    btn.MouseEnter:Connect(function()
        if TabButtons[tabId] and TabButtons[tabId].BackgroundColor3 ~= Colors.BG3 then
            TweenService:Create(wrap, TweenInfo.new(0.1), {BackgroundColor3 = Colors.BG4}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        local isActive = TabPages[tabId] and TabPages[tabId].Visible
        TweenService:Create(wrap, TweenInfo.new(0.1), {
            BackgroundColor3 = isActive and Colors.BG3 or Colors.BG1
        }):Play()
    end)

    TabButtons[tabId]    = wrap
    TabAccentBars[tabId] = accent
    TabPages[tabId]      = page
    return page
end

-- ── SECTION BUILDER ──────────────────────────────────────────
local function CreateSection(parent, title)
    local section = Instance.new("Frame", parent)
    section.BackgroundColor3 = Colors.BG3
    section.Size             = UDim2.new(1, 0, 0, 0)  -- width fills padded container
    section.BorderSizePixel  = 0
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", section)
    stroke.Color       = Colors.Border
    stroke.Thickness   = 1
    stroke.Transparency= 0.4

    -- Coloured top strip
    local topStrip = Instance.new("Frame", section)
    topStrip.Size             = UDim2.new(1, 0, 0, 3)
    topStrip.BackgroundColor3 = Colors.Accent
    topStrip.BorderSizePixel  = 0
    topStrip.BackgroundTransparency = 0.6
    local sc = Instance.new("UICorner", topStrip)
    sc.CornerRadius = UDim.new(0, 8)
    -- Clip bottom corners of the strip so it looks flush
    local stripClip = Instance.new("Frame", topStrip)
    stripClip.Size             = UDim2.new(1, 0, 0.5, 0)
    stripClip.Position         = UDim2.new(0, 0, 0.5, 0)
    stripClip.BackgroundColor3 = Colors.Accent
    stripClip.BackgroundTransparency = 0.6
    stripClip.BorderSizePixel  = 0

    local header = Instance.new("Frame", section)
    header.Size             = UDim2.new(1, 0, 0, 34)
    header.Position         = UDim2.new(0, 0, 0, 3)
    header.BackgroundTransparency = 1

    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size               = UDim2.new(1, -16, 1, 0)
    titleLabel.Position           = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text               = title:upper()
    titleLabel.TextColor3         = Colors.Glow
    titleLabel.Font               = Enum.Font.GothamBold
    titleLabel.TextSize           = 11
    titleLabel.TextXAlignment     = Enum.TextXAlignment.Left

    local divLine = Instance.new("Frame", section)
    divLine.Size             = UDim2.new(1, -20, 0, 1)
    divLine.Position         = UDim2.new(0, 10, 0, 37)
    divLine.BackgroundColor3 = Colors.Border
    divLine.BorderSizePixel  = 0
    divLine.BackgroundTransparency = 0.5

    local container = Instance.new("Frame", section)
    container.Position         = UDim2.new(0, 0, 0, 38)
    container.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", container)
    layout.SortOrder           = Enum.SortOrder.LayoutOrder
    layout.Padding             = UDim.new(0, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local cpad = Instance.new("UIPadding", container)
    cpad.PaddingTop    = UDim.new(0, 10)
    cpad.PaddingBottom = UDim.new(0, 12)
    cpad.PaddingLeft   = UDim.new(0, 10)
    cpad.PaddingRight  = UDim.new(0, 10)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local inner = layout.AbsoluteContentSize.Y + 22
        container.Size = UDim2.new(1, 0, 0, inner)
        section.Size   = UDim2.new(1, 0, 0, 38 + inner)
    end)

    return container
end

-- ── TOGGLE BUILDER ───────────────────────────────────────────
local function CreateToggle(parent, label, default, callback)
    local row = Instance.new("TextButton", parent)
    row.Size                = UDim2.new(1, 0, 0, 28)
    row.BackgroundTransparency = 1
    row.Text                = ""
    row.AutoButtonColor     = false

    local labelText = Instance.new("TextLabel", row)
    labelText.Size               = UDim2.new(1, -50, 1, 0)
    labelText.Position           = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text               = label
    labelText.TextColor3         = Colors.Gray1
    labelText.Font               = Enum.Font.Gotham
    labelText.TextSize           = 12
    labelText.TextXAlignment     = Enum.TextXAlignment.Left

    local track = Instance.new("Frame", row)
    track.Size             = UDim2.new(0, 38, 0, 20)
    track.AnchorPoint      = Vector2.new(1, 0.5)
    track.Position         = UDim2.new(1, 0, 0.5, 0)
    track.BackgroundColor3 = default and Colors.Accent or Colors.Gray2
    track.BorderSizePixel  = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Size             = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint      = Vector2.new(0.5, 0.5)
    knob.Position         = UDim2.new(default and 1 or 0, default and -17 or 3, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel  = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    -- Make the whole track clickable
    local trackBtn = Instance.new("TextButton", track)
    trackBtn.Size                = UDim2.new(1, 0, 1, 0)
    trackBtn.BackgroundTransparency = 1
    trackBtn.Text                = ""
    trackBtn.AutoButtonColor     = false

    local state = default
    local function toggle()
        state = not state
        callback(state)
        TweenService:Create(track, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            BackgroundColor3 = state and Colors.Accent or Colors.Gray2
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            Position = UDim2.new(state and 1 or 0, state and -17 or 3, 0.5, 0)
        }):Play()
        labelText.TextColor3 = state and Colors.White or Colors.Gray1
    end
    trackBtn.MouseButton1Click:Connect(toggle)
    row.MouseButton1Click:Connect(toggle)

    if default then labelText.TextColor3 = Colors.White end
end

-- ── SLIDER BUILDER ───────────────────────────────────────────
local function CreateSlider(parent, label, min, max, default, callback)
    local row = Instance.new("Frame", parent)
    row.Size                = UDim2.new(1, 0, 0, 40)
    row.BackgroundTransparency = 1

    local labelText = Instance.new("TextLabel", row)
    labelText.Size               = UDim2.new(0.62, 0, 0, 18)
    labelText.BackgroundTransparency = 1
    labelText.Text               = label
    labelText.TextColor3         = Colors.Gray1
    labelText.Font               = Enum.Font.Gotham
    labelText.TextSize           = 12
    labelText.TextXAlignment     = Enum.TextXAlignment.Left

    local valueText = Instance.new("TextLabel", row)
    valueText.Size               = UDim2.new(0.38, 0, 0, 18)
    valueText.Position           = UDim2.new(0.62, 0, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text               = tostring(default)
    valueText.TextColor3         = Colors.Accent
    valueText.Font               = Enum.Font.GothamBold
    valueText.TextSize           = 12
    valueText.TextXAlignment     = Enum.TextXAlignment.Right

    -- Track background
    local trackBG = Instance.new("Frame", row)
    trackBG.Size             = UDim2.new(1, 0, 0, 6)
    trackBG.Position         = UDim2.new(0, 0, 1, -10)
    trackBG.BackgroundColor3 = Colors.BG4
    trackBG.BorderSizePixel  = 0
    Instance.new("UICorner", trackBG).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", trackBG)
    fill.Size             = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Colors.Accent
    fill.BorderSizePixel  = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    -- Draggable knob handle
    local handle = Instance.new("Frame", trackBG)
    handle.Size             = UDim2.new(0, 12, 0, 12)
    handle.AnchorPoint      = Vector2.new(0.5, 0.5)
    handle.Position         = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    handle.BackgroundColor3 = Colors.White
    handle.BorderSizePixel  = 0
    Instance.new("UICorner", handle).CornerRadius = UDim.new(1, 0)

    -- Invisible click zone over the track
    local trackBtn = Instance.new("TextButton", trackBG)
    trackBtn.Size                = UDim2.new(1, 0, 0, 20)
    trackBtn.Position            = UDim2.new(0, 0, 0.5, -10)
    trackBtn.BackgroundTransparency = 1
    trackBtn.Text                = ""
    trackBtn.AutoButtonColor     = false

    local sliding = false
    trackBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
    end)
    UserInput.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UserInput.InputChanged:Connect(function(i)
        if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
            local pct = math.clamp(
                (i.Position.X - trackBG.AbsolutePosition.X) / trackBG.AbsoluteSize.X, 0, 1
            )
            local val = math.floor(min + (max - min) * pct)
            fill.Size        = UDim2.new(pct, 0, 1, 0)
            handle.Position  = UDim2.new(pct, 0, 0.5, 0)
            valueText.Text   = tostring(val)
            callback(val)
        end
    end)
end

-- ── DROPDOWN BUILDER ─────────────────────────────────────────
local function CreateDropdown(parent, label, options, defaultIndex, callback)
    local row = Instance.new("Frame", parent)
    row.Size                = UDim2.new(1, 0, 0, 28)
    row.BackgroundTransparency = 1

    local labelText = Instance.new("TextLabel", row)
    labelText.Size               = UDim2.new(0.5, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text               = label
    labelText.TextColor3         = Colors.Gray1
    labelText.Font               = Enum.Font.Gotham
    labelText.TextSize           = 12
    labelText.TextXAlignment     = Enum.TextXAlignment.Left

    local dropBtn = Instance.new("TextButton", row)
    dropBtn.Size             = UDim2.new(0.48, 0, 0, 22)
    dropBtn.AnchorPoint      = Vector2.new(1, 0.5)
    dropBtn.Position         = UDim2.new(1, 0, 0.5, 0)
    dropBtn.BackgroundColor3 = Colors.BG4
    dropBtn.TextColor3       = Colors.Glow
    dropBtn.Font             = Enum.Font.GothamSemibold
    dropBtn.TextSize         = 11
    dropBtn.AutoButtonColor  = false
    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 5)
    local dropStroke = Instance.new("UIStroke", dropBtn)
    dropStroke.Color     = Colors.Border
    dropStroke.Thickness = 1

    local idx = defaultIndex
    dropBtn.Text = "  " .. options[idx] .. "  ▾"

    dropBtn.MouseButton1Click:Connect(function()
        idx = (idx % #options) + 1
        dropBtn.Text = "  " .. options[idx] .. "  ▾"
        callback(options[idx])
        TweenService:Create(dropBtn, TweenInfo.new(0.08), {
            BackgroundColor3 = Colors.BG3
        }):Play()
        task.delay(0.15, function()
            TweenService:Create(dropBtn, TweenInfo.new(0.12), {
                BackgroundColor3 = Colors.BG4
            }):Play()
        end)
    end)
end

-- ── BUTTON BUILDER ───────────────────────────────────────────
local function CreateButton(parent, label, color, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size             = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = color or Colors.Accent
    btn.Text             = label
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 12
    btn.AutoButtonColor  = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color       = Color3.fromRGB(255, 255, 255)
    btnStroke.Thickness   = 1
    btnStroke.Transparency= 0.88

    local baseColor = color or Colors.Accent
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(255, math.floor(baseColor.R * 255 + 18)),
                math.min(255, math.floor(baseColor.G * 255 + 18)),
                math.min(255, math.floor(baseColor.B * 255 + 18))
            )
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = baseColor}):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.06), {
            BackgroundColor3 = Color3.fromRGB(
                math.max(0, math.floor(baseColor.R * 255 - 20)),
                math.max(0, math.floor(baseColor.G * 255 - 20)),
                math.max(0, math.floor(baseColor.B * 255 - 20))
            )
        }):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = baseColor}):Play()
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
local ConfigTab  = CreateTab("Config",  "◧")
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
CreateSlider(aimbotConfig, "FOV Radius", 10, 600, Settings.FOV_Radius, function(v)
    Settings.FOV_Radius = v
end)
CreateToggle(aimbotConfig, "FOV Circle", Settings.FOV_Circle, function(v)
    Settings.FOV_Circle = v
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
    if not v then nrPitch = nil end  -- reset tracked pitch when toggling off
end)
CreateToggle(targetingSection, "No Sway", Settings.NoSway, function(v)
    Settings.NoSway = v
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
local speedHackConn  = nil
local noClipConn     = nil

-- Speed hack — set WalkSpeed once per toggle + reapply on respawn.
-- No per-frame fighting (that causes jitter/rubber-band).
-- Moderate values (24-35) are safest; high values may rubber-band in strict games.
local function ApplySpeed()
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Settings.SpeedHack and Settings.SpeedValue or 16
    end
end

-- No-clip — dual approach:
--   1. CanCollide = false every Stepped tick (physics pre-step)
--   2. Move all character parts into a PhysicsService collision group
--      that doesn't collide with Default or itself, so collision groups
--      on walls can't override CanCollide.
local PhysicsService   = game:GetService("PhysicsService")
local NC_GROUP         = "AuraNoclip"
local _ncOrigGroups    = {}  -- [part] = original CollisionGroup string

local function _ensureNoclipGroup()
    pcall(function()
        PhysicsService:RegisterCollisionGroup(NC_GROUP)
    end)
    -- Make AuraNoclip not collide with Default and not with itself
    pcall(function()
        PhysicsService:CollisionGroupSetCollidable(NC_GROUP, "Default", false)
    end)
    pcall(function()
        PhysicsService:CollisionGroupSetCollidable(NC_GROUP, NC_GROUP, false)
    end)
end

local function ApplyNoClip(enabled)
    if enabled then
        if noClipConn then return end
        _ensureNoclipGroup()
        noClipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    -- Save original group once
                    if _ncOrigGroups[part] == nil then
                        _ncOrigGroups[part] = part.CollisionGroup or "Default"
                    end
                    part.CanCollide    = false
                    pcall(function() part.CollisionGroup = NC_GROUP end)
                end
            end
            -- HumanoidRootPart is the main physics body — make sure it's caught
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CanCollide = false
                pcall(function() root.CollisionGroup = NC_GROUP end)
            end
        end)
    else
        if noClipConn then
            noClipConn:Disconnect()
            noClipConn = nil
        end
        -- Restore collision + original collision groups
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                    local orig = _ncOrigGroups[part]
                    if orig then
                        pcall(function() part.CollisionGroup = orig end)
                    end
                end
            end
        end
        _ncOrigGroups = {}
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    if Settings.SpeedHack then
        char:WaitForChild("Humanoid", 5).WalkSpeed = Settings.SpeedValue
    end
    -- Reapply noclip on respawn — collision resets when character spawns fresh
    if Settings.NoClip then
        task.wait(0.1)
        ApplyNoClip(true)
    end
end)

-- ── MAGIC BULLET ─────────────────────────────────────────────
-- Hooks RemoteEvent:FireServer so when the weapon sends a shot to the server,
-- any Vector3 / CFrame / Instance argument that looks like a hit position
-- gets replaced with the current target's head position.
-- Requires hookfunction (available in most executors: Synapse, Fluxus, etc.)
do
    local mbHookActive = false
    local _origFireServer

    local function GetMBTarget()
        -- Use aimbot CurrentTarget if available, else find nearest head
        if CurrentTarget and CurrentTarget.Parent then
            return CurrentTarget.Position
        end
        -- Fallback: nearest visible player head
        local camPos = Camera.CFrame.Position
        local best, bestDist = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local head = plr.Character:FindFirstChild("Head")
                if head then
                    local d = (camPos - head.Position).Magnitude
                    if d < bestDist then
                        bestDist = d
                        best     = head.Position
                    end
                end
            end
        end
        return best
    end

    local function PatchArgs(args, targetPos)
        local patched = table.pack(table.unpack(args))
        for i = 1, patched.n do
            local v = patched[i]
            if typeof(v) == "Vector3" then
                -- Replace any Vector3 that looks like a world position (not a direction)
                if v.Magnitude > 1 then
                    patched[i] = targetPos
                end
            elseif typeof(v) == "CFrame" then
                patched[i] = CFrame.new(targetPos)
            elseif typeof(v) == "Instance" and v:IsA("BasePart") then
                -- Some games pass the hit part — don't replace Instance args
            end
        end
        return patched
    end

    local function EnableMagicBullet()
        if mbHookActive then return end
        if not hookfunction then return end  -- executor doesn't support hooking
        _origFireServer = hookfunction(RemoteEvent.FireServer, function(self, ...)
            if not Settings.MagicBullet then
                return _origFireServer(self, ...)
            end
            -- Only intercept remotes fired while the local player has a gun
            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if not tool then
                return _origFireServer(self, ...)
            end
            local targetPos = GetMBTarget()
            if not targetPos then
                return _origFireServer(self, ...)
            end
            local args = table.pack(...)
            local patched = PatchArgs(args, targetPos)
            return _origFireServer(self, table.unpack(patched, 1, patched.n))
        end)
        mbHookActive = true
    end

    -- Also hook RemoteFunction:InvokeServer for games that use RF for damage
    local _origInvokeServer
    local function EnableMagicBulletRF()
        if not hookfunction then return end
        if _origInvokeServer then return end
        _origInvokeServer = hookfunction(RemoteFunction.InvokeServer, function(self, ...)
            if not Settings.MagicBullet then
                return _origInvokeServer(self, ...)
            end
            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if not tool then return _origInvokeServer(self, ...) end
            local targetPos = GetMBTarget()
            if not targetPos then return _origInvokeServer(self, ...) end
            local args    = table.pack(...)
            local patched = PatchArgs(args, targetPos)
            return _origInvokeServer(self, table.unpack(patched, 1, patched.n))
        end)
    end

    -- Attempt to enable — will silently no-op if hookfunction is unavailable
    pcall(EnableMagicBullet)
    pcall(EnableMagicBulletRF)
end

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

-- ── MOVEMENT ─────────────────────────────────────────────────
local movementSection = CreateSection(SettingsTab, "Movement")
local speedInfo = Instance.new("TextLabel", movementSection)
speedInfo.Size               = UDim2.new(1, -12, 0, 30)
speedInfo.BackgroundTransparency = 1
speedInfo.TextColor3         = Colors.Gray1
speedInfo.Font               = Enum.Font.Gotham
speedInfo.TextSize           = 11
speedInfo.TextXAlignment     = Enum.TextXAlignment.Left
speedInfo.TextWrapped        = true
speedInfo.Text               = "Speed: [H]  ·  No Clip: [N]"
CreateToggle(movementSection, "Speed Hack", Settings.SpeedHack, function(v)
    Settings.SpeedHack = v
    ApplySpeed()
end)
CreateSlider(movementSection, "Speed", 16, 100, Settings.SpeedValue, function(v)
    Settings.SpeedValue = v
    if Settings.SpeedHack then ApplySpeed() end
end)
CreateToggle(movementSection, "No Clip", Settings.NoClip, function(v)
    Settings.NoClip = v
    ApplyNoClip(v)
end)

-- ── COMBAT ────────────────────────────────────────────────────
local combatSection = CreateSection(SettingsTab, "Combat")
local mbInfo = Instance.new("TextLabel", combatSection)
mbInfo.Size               = UDim2.new(1, -12, 0, 28)
mbInfo.BackgroundTransparency = 1
mbInfo.TextColor3         = Colors.Gray1
mbInfo.Font               = Enum.Font.Gotham
mbInfo.TextSize           = 11
mbInfo.TextXAlignment     = Enum.TextXAlignment.Left
mbInfo.TextWrapped        = true
mbInfo.Text               = "Magic Bullet: redirects shots to target head."
CreateToggle(combatSection, "Magic Bullet", Settings.MagicBullet, function(v)
    Settings.MagicBullet = v
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

    -- ── STEP 1: find ProximityPrompts whose ActionText/ObjectText looks like extraction ──
    -- The zone Parts in workspace probably aren't named "tunnel"/"cave" etc.
    -- but the ProximityPrompts ON them will have readable text.
    local promptKeywords = {"extract", "exfil", "exit", "escape", "evac", "leave", "exfiltrate"}
    local bestPrompt = nil
    local bestDist   = math.huge

    for _, pp in ipairs(workspace:GetDescendants()) do
        if pp:IsA("ProximityPrompt") then
            local combined = (pp.ActionText .. " " .. pp.ObjectText):lower()
            for _, kw in ipairs(promptKeywords) do
                if combined:find(kw, 1, true) then
                    local anchor = pp.Parent
                    if anchor and anchor:IsA("BasePart") then
                        local d = (root.Position - anchor.Position).Magnitude
                        if d < bestDist then
                            bestDist   = d
                            bestPrompt = pp
                        end
                    end
                    break
                end
            end
        end
    end

    if bestPrompt then
        local anchor = bestPrompt.Parent
        -- Teleport into the zone first so server position checks pass
        root.CFrame = anchor.CFrame + Vector3.new(0, 4, 0)
        extractStatus.Text = "found prompt: \"" .. bestPrompt.ActionText .. "\" (" .. math.floor(bestDist) .. "m)"
        task.wait(0.25)
        -- Fire hold begin/end — skips the hold timer entirely
        pcall(function() bestPrompt:InputHoldBegin() end)
        task.wait(0.05)
        pcall(function() bestPrompt:InputHoldEnd() end)
        extractBtn.Text = "▶  FORCE EXTRACT"
        return
    end

    -- ── STEP 2: scan BillboardGuis — extract zones usually have floating labels ──
    local zoneKeywords = {"extract", "exfil", "tunnel", "cave", "boat", "mountain",
                          "southern", "western", "northern", "zone", "evac", "exit"}
    local bestBB   = nil
    bestDist = math.huge

    for _, bb in ipairs(workspace:GetDescendants()) do
        if bb:IsA("BillboardGui") then
            local text = ""
            for _, child in ipairs(bb:GetDescendants()) do
                if child:IsA("TextLabel") then text = text .. child.Text:lower() .. " " end
            end
            for _, kw in ipairs(zoneKeywords) do
                if text:find(kw, 1, true) then
                    local adornee = bb.Adornee or (bb.Parent and bb.Parent:IsA("BasePart") and bb.Parent)
                    if adornee and adornee:IsA("BasePart") then
                        local d = (root.Position - adornee.Position).Magnitude
                        if d < bestDist then
                            bestDist = d
                            bestBB   = adornee
                        end
                    end
                    break
                end
            end
        end
    end

    if bestBB then
        root.CFrame = bestBB.CFrame + Vector3.new(0, 4, 0)
        extractStatus.Text = "teleported to labeled zone (" .. math.floor(bestDist) .. "m)"
        task.wait(0.2)
        for _, pp in ipairs(bestBB:GetDescendants()) do
            if pp:IsA("ProximityPrompt") then
                pcall(function() pp:InputHoldBegin() end)
                task.wait(0.05)
                pcall(function() pp:InputHoldEnd() end)
            end
        end
        extractBtn.Text = "▶  FORCE EXTRACT"
        return
    end

    -- ── STEP 3: fire RemoteEvents — broad keyword list ──
    extractStatus.Text = "no zone/prompt found — scanning remotes..."
    local remoteKeywords = {"extract", "exfil", "exit", "escape", "evac",
                            "zone", "complete", "finish", "success", "leave"}
    local RS    = game:GetService("ReplicatedStorage")
    local fired = false
    for _, obj in ipairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = obj.Name:lower()
            for _, kw in ipairs(remoteKeywords) do
                if n:find(kw, 1, true) then
                    if obj:IsA("RemoteEvent") then
                        pcall(function() obj:FireServer() end)
                    else
                        pcall(function() obj:InvokeServer() end)
                    end
                    extractStatus.Text = "fired: " .. obj:GetFullName()
                    fired = true
                    break
                end
            end
        end
    end
    if fired then extractBtn.Text = "▶  FORCE EXTRACT" return end

    -- ── STEP 4: rejoin ──
    extractStatus.Text = "nothing found — rejoining server..."
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

-- ── DANGER ZONE (eject) ──────────────────────────────────────
local dangerSection = CreateSection(SettingsTab, "Danger Zone")
local dangerInfo = Instance.new("TextLabel", dangerSection)
dangerInfo.Size               = UDim2.new(1, -12, 0, 28)
dangerInfo.BackgroundTransparency = 1
dangerInfo.TextColor3         = Colors.Gray1
dangerInfo.Font               = Enum.Font.Gotham
dangerInfo.TextSize           = 11
dangerInfo.TextXAlignment     = Enum.TextXAlignment.Left
dangerInfo.TextWrapped        = true
dangerInfo.Text               = "Eject unloads Aura completely. Reinject mid-match is safe."
local ejectBtn = CreateButton(dangerSection, "⏏  EJECT AURA", Color3.fromRGB(180, 40, 40), function() end)

-- ── CONFIG TAB ───────────────────────────────────────────────
local HttpService = game:GetService("HttpService")
local CFG_FOLDER  = "Aura"
local CFG_EXT     = ".json"

-- Keys in Settings that get saved/loaded
local CFG_KEYS = {
    "Aimbot_Enabled","FOV_Radius","FOV_Circle","Aim_Part","Aim_Smoothness",
    "Aim_Key","Aim_Priority","NoRecoil","NoSway",
    "ESP_Enabled","NPC_Enabled","ESP_Type","ESP_ShowInfo","ESP_Skeleton",
    "ESP_MaxDistance","HealthBar","Tracer","WeaponLabel",
    "Loot_Enabled","Best_Loot_Only","Radar_Enabled",
    "Crosshair_Enabled","Crosshair_Style",
    "SpeedHack","SpeedValue","NoClip","MagicBullet",
}

local function CfgSave(name)
    local t = {}
    for _, k in ipairs(CFG_KEYS) do t[k] = Settings[k] end
    local ok, json = pcall(function() return HttpService:JSONEncode(t) end)
    if not ok then return false, "encode failed" end
    local wok = pcall(function()
        if not isfolder(CFG_FOLDER) then makefolder(CFG_FOLDER) end
        writefile(CFG_FOLDER .. "/" .. name .. CFG_EXT, json)
    end)
    return wok, wok and "saved" or "write failed (executor may not support files)"
end

local function CfgLoad(name)
    local content
    local rok = pcall(function()
        content = readfile(CFG_FOLDER .. "/" .. name .. CFG_EXT)
    end)
    if not rok or not content then return false, "file not found" end
    local ok, t = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok or type(t) ~= "table" then return false, "decode failed" end
    for _, k in ipairs(CFG_KEYS) do
        if t[k] ~= nil then Settings[k] = t[k] end
    end
    return true, "loaded"
end

local function CfgDelete(name)
    pcall(function() delfile(CFG_FOLDER .. "/" .. name .. CFG_EXT) end)
end

local function CfgList()
    local names = {}
    pcall(function()
        if not isfolder(CFG_FOLDER) then return end
        for _, path in ipairs(listfiles(CFG_FOLDER)) do
            local n = path:match("([^/\\]+)" .. CFG_EXT .. "$")
            if n then table.insert(names, n) end
        end
    end)
    return names
end

-- ── UI ───────────────────────────────────────────────────────
local cfgNameSection = CreateSection(ConfigTab, "Config Name")

local nameBoxRow = Instance.new("Frame", cfgNameSection)
nameBoxRow.Size                = UDim2.new(1, 0, 0, 28)
nameBoxRow.BackgroundTransparency = 1

local nameBox = Instance.new("TextBox", nameBoxRow)
nameBox.Size                = UDim2.new(1, 0, 1, 0)
nameBox.BackgroundColor3    = Colors.BG4
nameBox.TextColor3          = Colors.White
nameBox.PlaceholderText     = "enter config name..."
nameBox.PlaceholderColor3   = Colors.Gray1
nameBox.Font                = Enum.Font.Gotham
nameBox.TextSize             = 12
nameBox.Text                = ""
nameBox.ClearTextOnFocus    = false
nameBox.BorderSizePixel     = 0
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 6)
local nbStroke = Instance.new("UIStroke", nameBox)
nbStroke.Color     = Colors.Border
nbStroke.Thickness = 1
local nbPad = Instance.new("UIPadding", nameBox)
nbPad.PaddingLeft  = UDim.new(0, 8)
nbPad.PaddingRight = UDim.new(0, 8)

-- Focus/unfocus styling
nameBox.Focused:Connect(function()
    TweenService:Create(nbStroke, TweenInfo.new(0.1), {Color = Colors.Accent}):Play()
end)
nameBox.FocusLost:Connect(function()
    TweenService:Create(nbStroke, TweenInfo.new(0.1), {Color = Colors.Border}):Play()
    -- Sanitise: strip everything except letters, digits, underscore, hyphen
    nameBox.Text = nameBox.Text:gsub("[^%w_%-]", ""):sub(1, 32)
end)

local cfgStatus = Instance.new("TextLabel", cfgNameSection)
cfgStatus.Size               = UDim2.new(1, 0, 0, 18)
cfgStatus.BackgroundTransparency = 1
cfgStatus.TextColor3         = Colors.Gray1
cfgStatus.Font               = Enum.Font.Gotham
cfgStatus.TextSize           = 11
cfgStatus.TextXAlignment     = Enum.TextXAlignment.Left
cfgStatus.Text               = ""

local function SetStatus(msg, isErr)
    cfgStatus.Text       = msg
    cfgStatus.TextColor3 = isErr and Colors.Red or Colors.Green
    task.delay(3, function()
        if cfgStatus.Text == msg then
            TweenService:Create(cfgStatus, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
            task.delay(0.4, function() cfgStatus.Text = "" cfgStatus.TextTransparency = 0 end)
        end
    end)
end

-- forward declare so save button can call it
local RefreshCfgList

CreateButton(cfgNameSection, "💾  SAVE CONFIG", Colors.Accent, function()
    local name = nameBox.Text
    if name == "" then SetStatus("enter a name first", true) return end
    local ok, msg = CfgSave(name)
    SetStatus(ok and ("saved  →  " .. name) or msg, not ok)
    if ok and RefreshCfgList then RefreshCfgList() end
end)

-- ── SAVED CONFIGS LIST ───────────────────────────────────────
local cfgListSection = CreateSection(ConfigTab, "Saved Configs")

local cfgScroll = Instance.new("ScrollingFrame", cfgListSection)
cfgScroll.Size                  = UDim2.new(1, 0, 0, 180)
cfgScroll.BackgroundColor3      = Colors.BG0
cfgScroll.BorderSizePixel       = 0
cfgScroll.ScrollBarThickness    = 3
cfgScroll.ScrollBarImageColor3  = Colors.Accent
cfgScroll.CanvasSize            = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", cfgScroll).CornerRadius = UDim.new(0, 6)
local cfgLayout = Instance.new("UIListLayout", cfgScroll)
cfgLayout.SortOrder   = Enum.SortOrder.LayoutOrder
cfgLayout.Padding     = UDim.new(0, 3)
local cfgScrollPad = Instance.new("UIPadding", cfgScroll)
cfgScrollPad.PaddingTop    = UDim.new(0, 5)
cfgScrollPad.PaddingBottom = UDim.new(0, 5)
cfgScrollPad.PaddingLeft   = UDim.new(0, 5)
cfgScrollPad.PaddingRight  = UDim.new(0, 5)

cfgLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    cfgScroll.CanvasSize = UDim2.new(0, 0, 0, cfgLayout.AbsoluteContentSize.Y + 10)
end)

RefreshCfgList = function()
    for _, c in ipairs(cfgScroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    local names = CfgList()
    if #names == 0 then
        local empty = Instance.new("TextLabel", cfgScroll)
        empty.Size               = UDim2.new(1, 0, 0, 28)
        empty.BackgroundTransparency = 1
        empty.TextColor3         = Colors.Gray1
        empty.Font               = Enum.Font.Gotham
        empty.TextSize           = 11
        empty.Text               = "no configs saved yet"
        return
    end
    for _, cfgName in ipairs(names) do
        local row = Instance.new("Frame", cfgScroll)
        row.Size             = UDim2.new(1, 0, 0, 30)
        row.BackgroundColor3 = Colors.BG3
        row.BorderSizePixel  = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

        local nameLabel = Instance.new("TextLabel", row)
        nameLabel.Size               = UDim2.new(1, -90, 1, 0)
        nameLabel.Position           = UDim2.new(0, 10, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3         = Colors.White
        nameLabel.Font               = Enum.Font.GothamSemibold
        nameLabel.TextSize           = 11
        nameLabel.TextXAlignment     = Enum.TextXAlignment.Left
        nameLabel.Text               = cfgName
        nameLabel.TextTruncate       = Enum.TextTruncate.AtEnd

        -- LOAD button
        local loadBtn = Instance.new("TextButton", row)
        loadBtn.Size             = UDim2.new(0, 38, 0, 20)
        loadBtn.AnchorPoint      = Vector2.new(1, 0.5)
        loadBtn.Position         = UDim2.new(1, -46, 0.5, 0)
        loadBtn.BackgroundColor3 = Colors.Accent
        loadBtn.TextColor3       = Color3.fromRGB(255,255,255)
        loadBtn.Font             = Enum.Font.GothamBold
        loadBtn.TextSize         = 10
        loadBtn.Text             = "LOAD"
        loadBtn.AutoButtonColor  = false
        Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 4)
        loadBtn.MouseButton1Click:Connect(function()
            local ok, msg = CfgLoad(cfgName)
            SetStatus(ok and ("loaded  →  " .. cfgName) or msg, not ok)
        end)

        -- DELETE button
        local delBtn = Instance.new("TextButton", row)
        delBtn.Size             = UDim2.new(0, 30, 0, 20)
        delBtn.AnchorPoint      = Vector2.new(1, 0.5)
        delBtn.Position         = UDim2.new(1, -4, 0.5, 0)
        delBtn.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
        delBtn.TextColor3       = Color3.fromRGB(255,255,255)
        delBtn.Font             = Enum.Font.GothamBold
        delBtn.TextSize         = 10
        delBtn.Text             = "✕"
        delBtn.AutoButtonColor  = false
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)
        delBtn.MouseButton1Click:Connect(function()
            CfgDelete(cfgName)
            SetStatus("deleted  →  " .. cfgName, false)
            RefreshCfgList()
        end)
    end
end

-- Refresh button
CreateButton(cfgListSection, "↺  REFRESH LIST", Colors.BG4, function()
    RefreshCfgList()
end)

-- Initial populate
RefreshCfgList()

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
do
    local defaultId  = "Aimbot"
    local defaultWrap = TabButtons[defaultId]
    defaultWrap.BackgroundColor3 = Colors.BG3
    local defaultBtn = defaultWrap:FindFirstChildWhichIsA("TextButton")
    if defaultBtn then defaultBtn.TextColor3 = Colors.White end
    if TabAccentBars[defaultId] then TabAccentBars[defaultId].Visible = true end
    TabPages[defaultId].Visible = true
end

-- ============================================================
-- ESP OBJECTS
-- ============================================================
local ESPObjects = {}

local FOVCircle = NewDrawing("Circle")
FOVCircle.Thickness  = 1.2
FOVCircle.Color      = Color3.fromRGB(82, 130, 255)
FOVCircle.Filled     = false
FOVCircle.Visible    = false
FOVCircle.Transparency = 0.35

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

local nrPrevCF   = nil    -- previous-frame CFrame for sensitivity calibration
local nrPitch    = nil    -- our maintained pitch value (no-recoil)
local nrSensEst  = 0.0025 -- rad/pixel estimate, self-calibrates from yaw delta

-- ============================================================
-- RENDER LOOP
-- ============================================================
local CurrentTarget = nil
local EjectAura     = nil  -- forward declaration; defined after all GUI is built

-- ── TEAMMATE DETECTION ───────────────────────────────────────
-- Tries Roblox Teams first, then falls back to common attribute
-- names used by custom squad/team systems in extraction games.
local function IsSameTeam(model)
    local plr = Players:GetPlayerFromCharacter(model)
    if not plr or plr == LocalPlayer then return false end

    -- 1. Roblox built-in Team service
    if LocalPlayer.Team ~= nil then
        return plr.Team == LocalPlayer.Team
    end

    -- 2. Attribute-based squad (common in custom extraction games)
    local ATTR_KEYS = {"Team", "Squad", "Group", "Party", "Alliance", "Side", "Faction"}
    local myChar = LocalPlayer.Character
    for _, key in ipairs(ATTR_KEYS) do
        local myVal   = myChar   and myChar:GetAttribute(key)
        local theirVal= model:GetAttribute(key)
        if myVal ~= nil and myVal == theirVal then return true end
        -- Also check on the Player object itself
        local myPlrVal   = LocalPlayer:GetAttribute(key)
        local theirPlrVal= plr:GetAttribute(key)
        if myPlrVal ~= nil and myPlrVal == theirPlrVal then return true end
    end

    -- 3. IntValue/StringValue named "Team"/"Squad" inside character
    for _, key in ipairs({"Team", "Squad", "Group", "Party"}) do
        local myVal    = myChar and myChar:FindFirstChild(key)
        local theirVal = model:FindFirstChild(key)
        if myVal and theirVal and myVal.Value == theirVal.Value then return true end
    end

    return false
end

-- Frame throttle counters
local _frame        = 0
local _raycastCache = {}   -- [model] = cached color from last raycast tick
local _lootFrame    = 0

local MainRenderConn = nil
MainRenderConn = RunService.RenderStepped:Connect(function()
    _frame = _frame + 1

    -- FOV circle
    if Settings.Aimbot_Enabled and Settings.FOV_Circle then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius   = Settings.FOV_Radius
        FOVCircle.Visible  = true
    else
        FOVCircle.Visible = false
    end

    local vpX          = Camera.ViewportSize.X
    local vpY          = Camera.ViewportSize.Y
    local screenCenter = Vector2.new(vpX / 2, vpY / 2)
    local cx           = screenCenter.X
    local cy           = screenCenter.Y
    local camPos       = Camera.CFrame.Position

    -- Build target list (only when something actually needs it)
    local needTargets  = Settings.ESP_Enabled or Settings.NPC_Enabled
                      or Settings.Aimbot_Enabled or Settings.Radar_Enabled
    local targets = {}
    if needTargets then
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
            _raycastCache[model] = nil
        end
    end

    -- ── ESP RENDER ───────────────────────────────────────────────
    -- Raycast color update: every 6 frames (10fps at 60fps) — cached otherwise
    local doRaycast = (_frame % 6 == 0)

    for _, target in ipairs(targets) do
        local model = target.Model
        local entry = ESPObjects[model] or CreateESPEntry(model)

        local shouldShow = (target.IsNPC and Settings.NPC_Enabled)
                        or (not target.IsNPC and Settings.ESP_Enabled)

        -- Cache humanoid/root lookups per entry
        if not entry._hum  then entry._hum  = model:FindFirstChildOfClass("Humanoid") end
        if not entry._root then entry._root = model:FindFirstChild("HumanoidRootPart") end
        if not entry._head then entry._head = model:FindFirstChild("Head") end
        local hum  = entry._hum
        local root = entry._root
        local head = entry._head

        if shouldShow and hum and hum.Health > 0 and root then
            local rootPos          = root.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPos)
            local dist             = (camPos - rootPos).Magnitude

            -- Color: throttled raycast
            local color
            if target.IsNPC then
                color = Colors.Orange
                _raycastCache[model] = color
            else
                local isTeammate = IsSameTeam(model)
                if isTeammate then
                    color = Color3.fromRGB(0, 220, 80)
                    _raycastCache[model] = color
                elseif doRaycast or not _raycastCache[model] then
                    local aimPart = model:FindFirstChild(Settings.Aim_Part) or head or root
                    local canShoot = false
                    if aimPart then
                        local params = RaycastParams.new()
                        params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                        params.FilterType  = Enum.RaycastFilterType.Exclude
                        params.IgnoreWater = true
                        local ray = workspace:Raycast(
                            camPos,
                            aimPart.Position - camPos,
                            params
                        )
                        canShoot = not ray or ray.Instance:IsDescendantOf(model)
                    end
                    color = canShoot
                        and Color3.fromRGB(255, 50,  50)
                        or  Color3.fromRGB(255, 200, 0)
                    _raycastCache[model] = color
                else
                    color = _raycastCache[model]
                end
            end

            if dist <= Settings.ESP_MaxDistance and onScreen then
                entry.Box.Color              = color
                entry.Text.Color             = color
                entry.Highlight.FillColor    = color
                entry.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                for _, bone in ipairs(entry.Skeleton) do bone.Color = color end

                local boxHeight  = 0
                local boxTopY    = screenPos.Y
                local rootScreen = screenPos  -- already have it from WorldToViewportPoint above

                if Settings.ESP_Type == "Full" then
                    entry.Box.Visible       = false
                    entry.Highlight.Adornee = model
                    entry.Highlight.Parent  = workspace
                else
                    if entry.Highlight.Parent then entry.Highlight.Parent = nil end
                    if head then
                        local topPos    = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local bottomPos = Camera:WorldToViewportPoint(rootPos - Vector3.new(0, 3, 0))
                        boxHeight = math.abs(topPos.Y - bottomPos.Y)
                        local boxWidth = boxHeight * 0.6
                        boxTopY = topPos.Y
                        entry.Box.Size     = Vector2.new(boxWidth, boxHeight)
                        entry.Box.Position = Vector2.new(rootScreen.X - boxWidth / 2, boxTopY)
                        entry.Box.Visible  = true
                    end
                end

                -- Health bar
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

                -- Tracer
                if Settings.Tracer then
                    entry.Tracer.From    = Vector2.new(cx, vpY)
                    entry.Tracer.To      = Vector2.new(rootScreen.X, rootScreen.Y)
                    entry.Tracer.Color   = color
                    entry.Tracer.Visible = true
                else
                    entry.Tracer.Visible = false
                end

                -- Name + distance + weapon label (text changes slow, throttle to every 6 frames)
                if Settings.ESP_ShowInfo then
                    if doRaycast then  -- reuse the same throttle cadence
                        local weaponTag = ""
                        if Settings.WeaponLabel then
                            local tool = model:FindFirstChildOfClass("Tool")
                            if tool then weaponTag = "\n[" .. tool.Name .. "]" end
                        end
                        entry.Text.Text = string.format("%s  %dm%s", target.Name, math.floor(dist), weaponTag)
                    end
                    entry.Text.Position = Vector2.new(rootScreen.X, boxTopY + boxHeight + 4)
                    entry.Text.Visible  = true
                else
                    entry.Text.Visible = false
                end

                -- Skeleton
                if Settings.ESP_Skeleton then
                    if not entry._isR15 then
                        entry._isR15 = model:FindFirstChild("UpperTorso") ~= nil
                    end
                    local bones = entry._isR15 and R15Bones or R6Bones
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

    -- Aimbot + no-recoil run in AuraCameraStep (BindToRenderStep Camera+1)
    -- so they always overwrite the game's camera last. nothing here.

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

    -- ── LOOT ESP ────────────────────────────────────────────────
    -- Throttled: update positions every 4 frames, scan/hide every frame
    if Settings.Loot_Enabled then
        _lootFrame = _lootFrame + 1
        if _lootFrame >= 4 then _lootFrame = 0 end
        if _lootFrame == 0 then
            local lootIdx = 0
            local _camPos = Camera.CFrame.Position
            for _, tool in ipairs(LootObjects) do
                if tool and tool.Parent then
                    local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("BasePart")
                    if handle then
                        local sp, onScreen = Camera:WorldToViewportPoint(handle.Position)
                        local ld = (_camPos - handle.Position).Magnitude
                        if onScreen and ld <= Settings.ESP_MaxDistance then
                            local tier = GetLootTier(tool.Name)
                            if Settings.Best_Loot_Only and not tier then
                                -- skip
                            else
                                lootIdx = lootIdx + 1
                                if lootIdx <= LOOT_MAX then
                                    local lbl = LootLabels[lootIdx]
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
        end
    else
        for _, lbl in ipairs(LootLabels) do lbl.Visible = false end
    end

end)

-- ============================================================
-- CAMERA OVERRIDE STEP  (runs AFTER game camera at Camera+1 priority)
-- Handles aimbot hard-lock and no-recoil/sway.
-- Running after the game means our CFrame always wins — mouse input
-- processed by the game camera script is overwritten every frame.
-- ============================================================
RunService:BindToRenderStep("AuraCameraStep", Enum.RenderPriority.Camera.Value + 1, function()
    -- Camera.CFrame.Position is already correct here — the game's camera script
    -- (priority 200) just ran and positioned it behind the character.
    -- We only overwrite the rotation component, so walking works naturally.
    local camPos      = Camera.CFrame.Position
    local vpX, vpY    = Camera.ViewportSize.X, Camera.ViewportSize.Y
    local screenCenter= Vector2.new(vpX / 2, vpY / 2)

    -- ── AIMBOT ───────────────────────────────────────────────────
    local aimActive = IsAimKeyDown()
    if Settings.Aimbot_Enabled and aimActive and not ScreenGui.Enabled then

        -- Drop target if it died, went off screen, or left the world
        if CurrentTarget then
            local char = CurrentTarget.Parent
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not char.Parent or not hum or hum.Health <= 0 then
                CurrentTarget = nil
            end
        end

        -- Search for new target if none locked
        if not CurrentTarget then
            local bestScore = math.huge
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
            rayParams.FilterType  = Enum.RaycastFilterType.Exclude
            rayParams.IgnoreWater = true

            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local model = plr.Character
                    if IsSameTeam(model) then continue end
                    local hum  = model:FindFirstChildOfClass("Humanoid")
                    local part = model:FindFirstChild(Settings.Aim_Part)
                    if hum and hum.Health > 0 and part then
                        local partPos      = part.Position
                        local d            = (camPos - partPos).Magnitude
                        local sp, onScreen = Camera:WorldToViewportPoint(partPos)
                        if onScreen and d <= Settings.ESP_MaxDistance then
                            local sd = (Vector2.new(sp.X, sp.Y) - screenCenter).Magnitude
                            if sd < Settings.FOV_Radius then
                                local score = Settings.Aim_Priority == "Health" and hum.Health or sd
                                if score < bestScore then
                                    local ray = workspace:Raycast(camPos, partPos - camPos, rayParams)
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
            if Settings.NPC_Enabled then
                for model in pairs(NPCTable) do
                    if model and model.Parent then
                        local hum  = model:FindFirstChildOfClass("Humanoid")
                        local part = model:FindFirstChild(Settings.Aim_Part)
                        if hum and hum.Health > 0 and part then
                            local partPos      = part.Position
                            local d            = (camPos - partPos).Magnitude
                            local sp, onScreen = Camera:WorldToViewportPoint(partPos)
                            if onScreen and d <= Settings.ESP_MaxDistance then
                                local sd = (Vector2.new(sp.X, sp.Y) - screenCenter).Magnitude
                                if sd < Settings.FOV_Radius then
                                    local ray = workspace:Raycast(camPos, partPos - camPos, rayParams)
                                    if not ray or ray.Instance:IsDescendantOf(model) then
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
            -- Hard rotation lock — position stays game-managed (follows character),
            -- we only replace the look direction. Mouse input was already written
            -- by the game camera at priority 200; we stomp it here at 201.
            Camera.CFrame = CFrame.lookAt(camPos, CurrentTarget.Position)
            nrPitch = nil  -- don't let no-recoil fight the lock
            return
        end
    end

    -- No target / aim off — clear state
    CurrentTarget = nil

    -- ── NO RECOIL / NO SWAY ──────────────────────────────────────
    -- Same Camera+1 priority guarantees we overwrite the game's camera.
    if Settings.NoRecoil or Settings.NoSway then
        local mouseDelta          = UserInput:GetMouseDelta()
        local currX, currY, currZ = Camera.CFrame:ToOrientation()

        -- Self-calibrate sensitivity from yaw (yaw = pure mouse, no recoil)
        if nrPrevCF and math.abs(mouseDelta.X) > 0.8 then
            local _, prevY, _ = nrPrevCF:ToOrientation()
            local yawDelta    = currY - prevY
            if math.abs(yawDelta) > 0.00005 then
                local est = -yawDelta / mouseDelta.X
                if est > 0.0003 and est < 0.03 then
                    nrSensEst = nrSensEst * 0.88 + est * 0.12
                end
            end
        end

        if Settings.NoRecoil then
            if nrPitch == nil then nrPitch = currX end
            nrPitch = math.clamp(nrPitch - mouseDelta.Y * nrSensEst, -1.45, 1.45)
            local finalZ = Settings.NoSway and 0 or currZ
            Camera.CFrame = CFrame.new(Camera.CFrame.Position)
                          * CFrame.fromOrientation(nrPitch, currY, finalZ)
        elseif Settings.NoSway then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position)
                          * CFrame.fromOrientation(currX, currY, 0)
        end
        nrPrevCF = Camera.CFrame
    else
        nrPitch  = nil
        nrPrevCF = nil
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
    -- Speed hack toggle [H]
    if input.KeyCode == Enum.KeyCode.H then
        Settings.SpeedHack = not Settings.SpeedHack
        ApplySpeed()
    end
    -- No clip toggle [N]
    if input.KeyCode == Enum.KeyCode.N then
        Settings.NoClip = not Settings.NoClip
        ApplyNoClip(Settings.NoClip)
    end
end)

-- ============================================================
-- EJECT SYSTEM
-- Cleanly tears down every connection, drawing object, and GUI.
-- Safe to reinject after ejecting.
-- ============================================================
EjectAura = function()
    -- Kill render loop
    if MainRenderConn then
        MainRenderConn:Disconnect()
        MainRenderConn = nil
    end

    -- Kill camera override step
    pcall(function() RunService:UnbindFromRenderStep("AuraCameraStep") end)

    -- Kill mouse lock loop
    if mouseLockConn then
        mouseLockConn:Disconnect()
        mouseLockConn = nil
    end

    -- Kill fullbright enforcer
    if fullbrightConn then
        fullbrightConn:Disconnect()
        fullbrightConn = nil
    end

    -- Kill speed hack enforcer
    if speedHackConn then
        speedHackConn:Disconnect()
        speedHackConn = nil
    end

    -- Kill noclip + restore collision
    if noClipConn then
        noClipConn:Disconnect()
        noClipConn = nil
    end
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end)

    -- Restore mouse + lighting
    pcall(function() UserInput.MouseBehavior = Enum.MouseBehavior.LockCenter end)
    pcall(function()
        Lighting.Brightness     = OriginalLighting.Brightness
        Lighting.Ambient        = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        Lighting.ClockTime      = OriginalLighting.ClockTime
        Lighting.GlobalShadows  = OriginalLighting.GlobalShadows
        Lighting.FogEnd         = OriginalLighting.FogEnd
        Lighting.FogStart       = OriginalLighting.FogStart
        for effect, state in pairs(OriginalEffects) do
            pcall(function() effect.Enabled = state end)
        end
    end)

    -- Remove Drawing objects: FOV circle, crosshair, loot labels, ESP
    pcall(function() FOVCircle:Remove() end)
    pcall(function()
        for _, l in ipairs(CrosshairLines) do l:Remove() end
        CrosshairDot:Remove()
    end)
    pcall(function()
        for _, lbl in ipairs(LootLabels) do lbl:Remove() end
    end)
    pcall(function()
        for _, entry in pairs(ESPObjects) do
            entry.Box:Remove()
            entry.Text:Remove()
            entry.HealthBarBG:Remove()
            entry.HealthBarFill:Remove()
            entry.Tracer:Remove()
            for _, bone in ipairs(entry.Skeleton) do bone:Remove() end
            if entry.Highlight and entry.Highlight.Parent then
                entry.Highlight:Destroy()
            end
        end
    end)

    -- Destroy the GUI last (so no more input handling)
    pcall(function() ScreenGui:Destroy() end)

    -- Signal ejected so reinject scripts can check _G.AuraLoaded
    _G.AuraLoaded = nil
end

ejectBtn.MouseButton1Click:Connect(EjectAura)
