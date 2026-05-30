-- KiciaLib | UI Library for Roblox
-- Style: Dark theme, blue accent, tabs, sectors, animations
-- Usage: local lib = loadstring(game:HttpGet("YOUR_RAW_GITHUB_LINK"))()

local KiciaLib = {
    flags   = {},
    items   = {},
}

-- ============================================================
-- SERVICES
-- ============================================================
local Players        = game:GetService("Players")
local UIS            = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local TextService    = game:GetService("TextService")
local CoreGui        = game:GetService("CoreGui")
local HttpService    = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()
local Camera      = workspace.CurrentCamera

-- ============================================================
-- THEME
-- ============================================================
KiciaLib.Theme = {
    Font            = Enum.Font.GothamBold,
    FontRegular     = Enum.Font.Gotham,
    FontSize        = 13,
    TitleSize       = 14,

    Background      = Color3.fromRGB(15, 15, 18),
    TopBar          = Color3.fromRGB(20, 20, 25),
    TabBar          = Color3.fromRGB(17, 17, 22),
    SectorBG        = Color3.fromRGB(22, 22, 28),
    ItemBG          = Color3.fromRGB(28, 28, 35),
    ItemBGHover     = Color3.fromRGB(33, 33, 42),

    Accent          = Color3.fromRGB(0, 140, 255),
    AccentDark      = Color3.fromRGB(0, 90, 180),
    AccentText      = Color3.fromRGB(255, 255, 255),

    TextPrimary     = Color3.fromRGB(220, 220, 230),
    TextSecondary   = Color3.fromRGB(140, 140, 160),
    TextDisabled    = Color3.fromRGB(80, 80, 100),

    Border          = Color3.fromRGB(40, 40, 55),
    BorderAccent    = Color3.fromRGB(0, 140, 255),
    Shadow          = Color3.fromRGB(5, 5, 8),

    SliderFill      = Color3.fromRGB(0, 140, 255),
    ToggleON        = Color3.fromRGB(0, 140, 255),
    ToggleOFF       = Color3.fromRGB(35, 35, 45),
    ToggleCircle    = Color3.fromRGB(255, 255, 255),

    TopHeight       = 50,
    TabHeight       = 30,
    CornerRadius    = UDim.new(0, 6),
    CornerRadiusSm  = UDim.new(0, 4),
}
local T = KiciaLib.Theme

-- ============================================================
-- KEYBIND HELPERS
-- ============================================================
local ShortKeys = {
    LeftShift = "LSHIFT", RightShift = "RSHIFT",
    LeftControl = "LCTRL", RightControl = "RCTRL",
    LeftAlt = "LALT", RightAlt = "RALT",
}
local MouseButtons = {
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
}

local function KeybindToText(v)
    if v == "None" or v == nil then return "[None]" end
    if MouseButtons[v] then return "["..MouseButtons[v].."]" end
    if typeof(v) == "EnumItem" then return "["..(ShortKeys[v.Name] or v.Name).."]" end
    return "["..tostring(v).."]"
end

local function InputMatchesKeybind(input, value)
    if value == "None" or value == nil then return false end
    if MouseButtons[value] then return input.UserInputType == value end
    if typeof(value) == "EnumItem" then
        return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == value
    end
    return false
end

local function InputToKeybindValue(input)
    if MouseButtons[input.UserInputType] then return input.UserInputType
    elseif input.UserInputType == Enum.UserInputType.Keyboard then return input.KeyCode end
    return "None"
end

-- ============================================================
-- UTILITY
-- ============================================================
local function Tween(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

local function TweenLinear(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Linear), props):Play()
end

local function MakeCorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = radius or T.CornerRadius
    return c
end

local function MakePadding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    return p
end

local function MakeStroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color     = color     or T.Border
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function MakeListLayout(parent, direction, padding, align)
    local l = Instance.new("UIListLayout", parent)
    l.FillDirection       = direction or Enum.FillDirection.Vertical
    l.SortOrder           = Enum.SortOrder.LayoutOrder
    l.Padding             = UDim.new(0, padding or 0)
    if align then l.HorizontalAlignment = align end
    return l
end

local function TextSize(text, size, font)
    return TextService:GetTextSize(text, size or T.FontSize, font or T.FontRegular, Vector2.new(9999, 9999))
end

-- ============================================================
-- NOTIFY
-- ============================================================
function KiciaLib:Notify(title, body, duration)
    if type(body) == "number" then duration = body; body = nil end
    duration = duration or 4

    local gui = Instance.new("ScreenGui")
    gui.Name = "KiciaNotif"
    gui.DisplayOrder = 50
    gui.ResetOnSpawn = false
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer.PlayerGui end

    local w = body and 280 or 220
    local h = body and 60  or 40

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromOffset(w, h)
    frame.Position = UDim2.new(1, w + 20, 0, 12)
    frame.BackgroundColor3 = T.SectorBG
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    MakeCorner(frame, UDim.new(0, 8))
    MakeStroke(frame, T.Border, 1)

    -- Accent bar gauche
    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.fromOffset(3, h)
    bar.Position = UDim2.fromOffset(0, 0)
    bar.BackgroundColor3 = T.Accent
    bar.BorderSizePixel = 0
    MakeCorner(bar, UDim.new(0, 3))

    -- Titre
    local titleLbl = Instance.new("TextLabel", frame)
    titleLbl.Text = title or ""
    titleLbl.Font = T.Font
    titleLbl.TextSize = 13
    titleLbl.TextColor3 = T.TextPrimary
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Position = UDim2.fromOffset(12, body and 8 or 12)
    titleLbl.Size = UDim2.fromOffset(w - 20, 16)

    if body then
        local bodyLbl = Instance.new("TextLabel", frame)
        bodyLbl.Text = body
        bodyLbl.Font = T.FontRegular
        bodyLbl.TextSize = 11
        bodyLbl.TextColor3 = T.TextSecondary
        bodyLbl.BackgroundTransparency = 1
        bodyLbl.TextXAlignment = Enum.TextXAlignment.Left
        bodyLbl.TextWrapped = true
        bodyLbl.Position = UDim2.fromOffset(12, 27)
        bodyLbl.Size = UDim2.fromOffset(w - 20, 26)
    end

    -- Progress bar
    local pbg = Instance.new("Frame", frame)
    pbg.Size = UDim2.fromOffset(w, 2)
    pbg.Position = UDim2.new(0, 0, 1, -2)
    pbg.BackgroundColor3 = T.Border
    pbg.BorderSizePixel = 0

    local pb = Instance.new("Frame", pbg)
    pb.Size = UDim2.fromScale(1, 1)
    pb.BackgroundColor3 = T.Accent
    pb.BorderSizePixel = 0

    -- Slide in
    Tween(frame, 0.4, {Position = UDim2.new(1, -(w + 12), 0, 12)})

    task.delay(0.45, function()
        TweenLinear(pb, duration, {Size = UDim2.fromScale(0, 1)})
        task.delay(duration, function()
            Tween(frame, 0.35, {Position = UDim2.new(1, w + 20, 0, 12)})
            task.delay(0.4, function() gui:Destroy() end)
        end)
    end)

    return frame
end

-- ============================================================
-- CREATE WINDOW
-- ============================================================
function KiciaLib:CreateWindow(config)
    config = config or {}
    local name     = config.Name     or "KiciaLib"
    local size     = config.Size     or Vector2.new(540, 420)
    local hidekey  = config.HideKey  or Enum.KeyCode.RightShift

    local window = {
        Tabs    = {},
        HideKey = hidekey,
        Open    = true,
        Theme   = T,
    }

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.DisplayOrder = 15
    gui.ResetOnSpawn = false
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer.PlayerGui end
    window._gui = gui

    -- Cleanup old
    if getgenv and getgenv().KiciaLibGui then pcall(function() getgenv().KiciaLibGui:Destroy() end) end
    if getgenv then getgenv().KiciaLibGui = gui end

    -- ── SHADOW
    local shadow = Instance.new("ImageLabel", gui)
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0,0,0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49,49,450,450)
    shadow.Size = UDim2.fromOffset(size.X + 30, size.Y + 30)
    shadow.Position = UDim2.new(0.5, -(size.X/2) - 15, 0.5, -(size.Y/2) - 15)
    shadow.ZIndex = 0

    -- ── MAIN FRAME
    local main = Instance.new("Frame", gui)
    main.Name = "Main"
    main.Size = UDim2.fromOffset(size.X, size.Y)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = T.Background
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.ZIndex = 1
    MakeCorner(main, UDim.new(0, 8))
    MakeStroke(main, T.Border, 1)
    window._main = main

    -- Intro animation
    main.Size = UDim2.fromOffset(size.X, 0)
    shadow.Size = UDim2.fromOffset(size.X + 30, 30)
    Tween(main, 0.45, {Size = UDim2.fromOffset(size.X, size.Y)})
    Tween(shadow, 0.45, {Size = UDim2.fromOffset(size.X + 30, size.Y + 30)})

    -- ── TOP BAR
    local topBar = Instance.new("Frame", main)
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, T.TopHeight)
    topBar.BackgroundColor3 = T.TopBar
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 2

    local topGrad = Instance.new("UIGradient", topBar)
    topGrad.Rotation = 90
    topGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 32)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 24)),
    })

    -- Logo / accent line
    local accentLine = Instance.new("Frame", topBar)
    accentLine.Size = UDim2.new(0, 3, 1, 0)
    accentLine.BackgroundColor3 = T.Accent
    accentLine.BorderSizePixel = 0
    accentLine.ZIndex = 3

    -- Title
    local titleLbl = Instance.new("TextLabel", topBar)
    titleLbl.Text = name
    titleLbl.Font = T.Font
    titleLbl.TextSize = T.TitleSize
    titleLbl.TextColor3 = T.TextPrimary
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Position = UDim2.fromOffset(14, 0)
    titleLbl.Size = UDim2.new(0.6, 0, 1, 0)
    titleLbl.ZIndex = 3

    -- Subtitle / game name
    local subLbl = Instance.new("TextLabel", topBar)
    subLbl.Font = T.FontRegular
    subLbl.TextSize = 11
    subLbl.TextColor3 = T.TextSecondary
    subLbl.BackgroundTransparency = 1
    subLbl.TextXAlignment = Enum.TextXAlignment.Left
    subLbl.Position = UDim2.fromOffset(14, 18)
    subLbl.Size = UDim2.new(0.5, 0, 0, 14)
    subLbl.ZIndex = 3
    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        subLbl.Text = info.Name or ""
    end)

    -- Close button
    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Text = "✕"
    closeBtn.Font = T.Font
    closeBtn.TextSize = 13
    closeBtn.TextColor3 = T.TextSecondary
    closeBtn.BackgroundTransparency = 1
    closeBtn.Size = UDim2.fromOffset(28, 28)
    closeBtn.Position = UDim2.new(1, -32, 0.5, -14)
    closeBtn.ZIndex = 4
    closeBtn.AutoButtonColor = false

    -- Minimize button
    local minBtn = Instance.new("TextButton", topBar)
    minBtn.Text = "−"
    minBtn.Font = T.Font
    minBtn.TextSize = 15
    minBtn.TextColor3 = T.TextSecondary
    minBtn.BackgroundTransparency = 1
    minBtn.Size = UDim2.fromOffset(28, 28)
    minBtn.Position = UDim2.new(1, -62, 0.5, -14)
    minBtn.ZIndex = 4
    minBtn.AutoButtonColor = false

    closeBtn.MouseEnter:Connect(function() Tween(closeBtn, 0.15, {TextColor3 = Color3.fromRGB(255, 80, 80)}) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn, 0.15, {TextColor3 = T.TextSecondary}) end)
    minBtn.MouseEnter:Connect(function() Tween(minBtn, 0.15, {TextColor3 = T.Accent}) end)
    minBtn.MouseLeave:Connect(function() Tween(minBtn, 0.15, {TextColor3 = T.TextSecondary}) end)

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(main, 0.3, {Size = UDim2.fromOffset(size.X, T.TopHeight + T.TabHeight + 2)})
        else
            Tween(main, 0.3, {Size = UDim2.fromOffset(size.X, size.Y)})
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        for _,v in pairs(KiciaLib.items) do
            pcall(function()
                if v.Set and type(v.value) == "boolean" and v.value then v:Set(false) end
            end)
        end
        Tween(main, 0.3, {Size = UDim2.fromOffset(size.X, 0)})
        task.delay(0.35, function() gui:Destroy() end)
    end)

    -- Séparateur sous topbar
    local topSep = Instance.new("Frame", main)
    topSep.Size = UDim2.new(1, 0, 0, 1)
    topSep.Position = UDim2.fromOffset(0, T.TopHeight)
    topSep.BackgroundColor3 = T.Accent
    topSep.BorderSizePixel = 0
    topSep.ZIndex = 2

    -- ── TAB BAR
    local tabBar = Instance.new("Frame", main)
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, 0, 0, T.TabHeight)
    tabBar.Position = UDim2.fromOffset(0, T.TopHeight + 1)
    tabBar.BackgroundColor3 = T.TabBar
    tabBar.BorderSizePixel = 0
    tabBar.ZIndex = 2
    tabBar.ClipsDescendants = true

    local tabListLayout = MakeListLayout(tabBar, Enum.FillDirection.Horizontal, 0)
    tabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    -- Indicateur de tab actif (underline glissant)
    local tabIndicator = Instance.new("Frame", tabBar)
    tabIndicator.Size = UDim2.fromOffset(0, 2)
    tabIndicator.Position = UDim2.new(0, 0, 1, -2)
    tabIndicator.BackgroundColor3 = T.Accent
    tabIndicator.BorderSizePixel = 0
    tabIndicator.ZIndex = 4

    -- Séparateur sous tab bar
    local tabSep = Instance.new("Frame", main)
    tabSep.Size = UDim2.new(1, 0, 0, 1)
    tabSep.Position = UDim2.fromOffset(0, T.TopHeight + 1 + T.TabHeight)
    tabSep.BackgroundColor3 = T.Border
    tabSep.BorderSizePixel = 0
    tabSep.ZIndex = 2

    -- ── CONTENT AREA
    local contentY = T.TopHeight + 1 + T.TabHeight + 1
    local content = Instance.new("Frame", main)
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -contentY)
    content.Position = UDim2.fromOffset(0, contentY)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ZIndex = 1
    content.ClipsDescendants = true

    -- ── DRAG
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = main.Position
        end
    end)
    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            shadow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X - 15, startPos.Y.Scale, startPos.Y.Offset + delta.Y - 15)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- Toggle visibilité
    UIS.InputBegan:Connect(function(key, gp)
        if gp then return end
        if InputMatchesKeybind(key, window.HideKey) then
            window.Open = not window.Open
            local targetSize = window.Open and UDim2.fromOffset(size.X, size.Y) or UDim2.fromOffset(size.X, 0)
            Tween(main, 0.3, {Size = targetSize})
        end
    end)

    -- ============================================================
    -- CREATE TAB
    -- ============================================================
    function window:CreateTab(tabName)
        local tab = { Sectors = {}, _name = tabName }

        -- Tab button
        local tw = TextSize(tabName, T.FontSize, T.Font).X + 24
        local tabBtn = Instance.new("TextButton", tabBar)
        tabBtn.Text = tabName
        tabBtn.Font = T.Font
        tabBtn.TextSize = T.FontSize
        tabBtn.TextColor3 = T.TextSecondary
        tabBtn.BackgroundTransparency = 1
        tabBtn.Size = UDim2.fromOffset(tw, T.TabHeight)
        tabBtn.BorderSizePixel = 0
        tabBtn.AutoButtonColor = false
        tabBtn.ZIndex = 3

        -- Tab content (2 colonnes)
        local tabContent = Instance.new("Frame", content)
        tabContent.Name = tabName
        tabContent.Size = UDim2.fromScale(1, 1)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.ZIndex = 1

        -- Colonne gauche
        local leftCol = Instance.new("ScrollingFrame", tabContent)
        leftCol.Size = UDim2.fromScale(0.5, 1)
        leftCol.BackgroundTransparency = 1
        leftCol.BorderSizePixel = 0
        leftCol.ScrollBarThickness = 2
        leftCol.ScrollBarImageColor3 = T.Accent
        leftCol.CanvasSize = UDim2.fromScale(0.5, 0)
        leftCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
        MakePadding(leftCol, 10, 10, 10, 5)
        MakeListLayout(leftCol, Enum.FillDirection.Vertical, 8)

        -- Colonne droite
        local rightCol = Instance.new("ScrollingFrame", tabContent)
        rightCol.Size = UDim2.fromScale(0.5, 1)
        rightCol.Position = UDim2.fromScale(0.5, 0)
        rightCol.BackgroundTransparency = 1
        rightCol.BorderSizePixel = 0
        rightCol.ScrollBarThickness = 2
        rightCol.ScrollBarImageColor3 = T.Accent
        rightCol.CanvasSize = UDim2.fromScale(0.5, 0)
        rightCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
        MakePadding(rightCol, 10, 10, 5, 10)
        MakeListLayout(rightCol, Enum.FillDirection.Vertical, 8)

        tab._content = tabContent
        tab._left    = leftCol
        tab._right   = rightCol
        tab._btn     = tabBtn

        function tab:Select()
            -- Cacher tous les autres
            for _, t in pairs(window.Tabs) do
                t._content.Visible = false
                Tween(t._btn, 0.2, {TextColor3 = T.TextSecondary})
            end
            tabContent.Visible = true
            Tween(tabBtn, 0.2, {TextColor3 = T.Accent})

            -- Animer indicateur
            local btnPos = tabBtn.AbsolutePosition.X - tabBar.AbsolutePosition.X
            Tween(tabIndicator, 0.25, {
                Size     = UDim2.fromOffset(tabBtn.AbsoluteSize.X, 2),
                Position = UDim2.new(0, btnPos, 1, -2),
            })

            -- Fade in content
            tabContent.GroupTransparency = 1
            Tween(tabContent, 0.2, {GroupTransparency = 0})
        end

        tabBtn.MouseButton1Click:Connect(function() tab:Select() end)

        if #window.Tabs == 0 then
            task.defer(function() tab:Select() end)
        end

        -- ========================================================
        -- CREATE SECTOR
        -- ========================================================
        function tab:CreateSector(sectorName, side)
            side = (side or "left"):lower()
            local parent = side == "right" and rightCol or leftCol
            local sector = {}

            -- Sector frame
            local sFrame = Instance.new("Frame", parent)
            sFrame.Name = sectorName
            sFrame.BackgroundColor3 = T.SectorBG
            sFrame.BorderSizePixel = 0
            sFrame.AutomaticSize = Enum.AutomaticSize.Y
            sFrame.Size = UDim2.new(1, 0, 0, 0)
            MakeCorner(sFrame, UDim.new(0, 6))
            MakeStroke(sFrame, T.Border, 1)

            -- Header
            local header = Instance.new("Frame", sFrame)
            header.Size = UDim2.new(1, 0, 0, 28)
            header.BackgroundColor3 = T.ItemBG
            header.BorderSizePixel = 0
            MakeCorner(header, UDim.new(0, 6))

            -- Header accent
            local hAccent = Instance.new("Frame", header)
            hAccent.Size = UDim2.fromOffset(3, 16)
            hAccent.Position = UDim2.fromOffset(8, 6)
            hAccent.BackgroundColor3 = T.Accent
            hAccent.BorderSizePixel = 0
            MakeCorner(hAccent, UDim.new(0, 2))

            local hLabel = Instance.new("TextLabel", header)
            hLabel.Text = sectorName
            hLabel.Font = T.Font
            hLabel.TextSize = 12
            hLabel.TextColor3 = T.TextPrimary
            hLabel.BackgroundTransparency = 1
            hLabel.TextXAlignment = Enum.TextXAlignment.Left
            hLabel.Position = UDim2.fromOffset(18, 0)
            hLabel.Size = UDim2.new(1, -20, 1, 0)

            -- Items container
            local items = Instance.new("Frame", sFrame)
            items.Name = "Items"
            items.BackgroundTransparency = 1
            items.AutomaticSize = Enum.AutomaticSize.Y
            items.Size = UDim2.new(1, 0, 0, 0)
            items.Position = UDim2.fromOffset(0, 28)
            MakePadding(items, 6, 8, 8, 8)
            MakeListLayout(items, Enum.FillDirection.Vertical, 6)

            sector._frame = sFrame
            sector._items = items

            -- ==================================================
            -- ADD TOGGLE
            -- ==================================================
            function sector:AddToggle(text, default, callback, flag)
                local toggle = {value = default or false, flag = flag or text or ""}
                toggle.callback = callback or function() end

                local row = Instance.new("Frame", items)
                row.BackgroundColor3 = T.ItemBG
                row.Size = UDim2.new(1, 0, 0, 28)
                row.BorderSizePixel = 0
                MakeCorner(row, T.CornerRadiusSm)

                local lbl = Instance.new("TextLabel", row)
                lbl.Text = text or ""
                lbl.Font = T.FontRegular
                lbl.TextSize = T.FontSize
                lbl.TextColor3 = T.TextPrimary
                lbl.BackgroundTransparency = 1
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Position = UDim2.fromOffset(10, 0)
                lbl.Size = UDim2.new(1, -60, 1, 0)

                -- Toggle pill
                local pill = Instance.new("Frame", row)
                pill.Size = UDim2.fromOffset(34, 18)
                pill.Position = UDim2.new(1, -44, 0.5, -9)
                pill.BackgroundColor3 = T.ToggleOFF
                pill.BorderSizePixel = 0
                MakeCorner(pill, UDim.new(0, 9))
                MakeStroke(pill, T.Border, 1)

                local circle = Instance.new("Frame", pill)
                circle.Size = UDim2.fromOffset(12, 12)
                circle.Position = UDim2.fromOffset(3, 3)
                circle.BackgroundColor3 = T.ToggleCircle
                circle.BorderSizePixel = 0
                MakeCorner(circle, UDim.new(0.5, 0))

                -- Items droite (keybind, colorpicker)
                local rightItems = Instance.new("Frame", row)
                rightItems.Name = "RightItems"
                rightItems.BackgroundTransparency = 1
                rightItems.Size = UDim2.fromOffset(50, 28)
                rightItems.Position = UDim2.new(1, -52, 0, 0)
                rightItems.ZIndex = 3
                MakeListLayout(rightItems, Enum.FillDirection.Horizontal, 4)
                rightItems.Size = UDim2.fromOffset(50, 28) -- reset for layout

                if toggle.flag ~= "" then KiciaLib.flags[toggle.flag] = toggle.value end

                function toggle:Set(v)
                    toggle.value = v
                    if toggle.flag ~= "" then KiciaLib.flags[toggle.flag] = v end
                    Tween(pill, 0.2, {BackgroundColor3 = v and T.ToggleON or T.ToggleOFF})
                    Tween(circle, 0.2, {Position = v and UDim2.fromOffset(19, 3) or UDim2.fromOffset(3, 3)})
                    Tween(lbl, 0.2, {TextColor3 = v and T.Accent or T.TextPrimary})
                    pcall(toggle.callback, v)
                end
                function toggle:Get() return toggle.value end
                toggle:Set(toggle.value)

                -- Hover
                row.MouseEnter:Connect(function() Tween(row, 0.15, {BackgroundColor3 = T.ItemBGHover}) end)
                row.MouseLeave:Connect(function() Tween(row, 0.15, {BackgroundColor3 = T.ItemBG}) end)

                -- Click
                local btn = Instance.new("TextButton", row)
                btn.Size = UDim2.fromScale(1, 1)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                btn.ZIndex = 2
                btn.MouseButton1Click:Connect(function() toggle:Set(not toggle.value) end)

                -- AddKeybind dans toggle
                function toggle:AddKeybind(kbDefault, kbFlag)
                    local kb = {value = kbDefault or "None", flag = kbFlag or (text.."_kb")}
                    if kb.flag ~= "" then KiciaLib.flags[kb.flag] = kb.value end

                    local kbBtn = Instance.new("TextButton", rightItems)
                    kbBtn.Font = T.FontRegular
                    kbBtn.TextSize = 11
                    kbBtn.TextColor3 = T.TextSecondary
                    kbBtn.BackgroundTransparency = 1
                    kbBtn.Size = UDim2.fromOffset(50, 28)
                    kbBtn.Text = KeybindToText(kb.value)
                    kbBtn.ZIndex = 5

                    function kb:Set(v)
                        kb.value = v
                        kbBtn.Text = KeybindToText(v)
                        if kb.flag ~= "" then KiciaLib.flags[kb.flag] = v end
                    end
                    function kb:Get() return kb.value end

                    kbBtn.MouseButton1Click:Connect(function()
                        kbBtn.Text = "[...]"
                        kbBtn.TextColor3 = T.Accent
                    end)
                    UIS.InputBegan:Connect(function(input, gp)
                        if gp then return end
                        if kbBtn.Text == "[...]" then
                            kbBtn.TextColor3 = T.TextSecondary
                            kb:Set(InputToKeybindValue(input))
                        elseif InputMatchesKeybind(input, kb.value) then
                            toggle:Set(not toggle.value)
                        end
                    end)
                    table.insert(KiciaLib.items, kb)
                    return kb
                end

                -- AddColorpicker dans toggle
                function toggle:AddColorpicker(cpDefault, cpCallback, cpFlag)
                    return sector:_makeColorpicker(rightItems, cpDefault, cpCallback, cpFlag or (text.."_cp"), true)
                end

                table.insert(KiciaLib.items, toggle)
                return toggle
            end

            -- ==================================================
            -- ADD BUTTON
            -- ==================================================
            function sector:AddButton(text, callback)
                local btn = {}
                callback = callback or function() end

                local row = Instance.new("TextButton", items)
                row.Text = ""
                row.BackgroundColor3 = T.ItemBG
                row.Size = UDim2.new(1, 0, 0, 28)
                row.BorderSizePixel = 0
                row.AutoButtonColor = false
                MakeCorner(row, T.CornerRadiusSm)
                MakeStroke(row, T.Border, 1)

                -- Accent bar gauche
                local abar = Instance.new("Frame", row)
                abar.Size = UDim2.fromOffset(2, 16)
                abar.Position = UDim2.fromOffset(6, 6)
                abar.BackgroundColor3 = T.Accent
                abar.BorderSizePixel = 0
                MakeCorner(abar, UDim.new(0, 2))

                local lbl = Instance.new("TextLabel", row)
                lbl.Text = text or ""
                lbl.Font = T.Font
                lbl.TextSize = T.FontSize
                lbl.TextColor3 = T.TextPrimary
                lbl.BackgroundTransparency = 1
                lbl.TextXAlignment = Enum.TextXAlignment.Center
                lbl.Size = UDim2.fromScale(1, 1)

                row.MouseEnter:Connect(function()
                    Tween(row, 0.15, {BackgroundColor3 = T.ItemBGHover})
                    Tween(abar, 0.15, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
                end)
                row.MouseLeave:Connect(function()
                    Tween(row, 0.15, {BackgroundColor3 = T.ItemBG})
                    Tween(abar, 0.15, {BackgroundColor3 = T.Accent})
                end)

                row.MouseButton1Click:Connect(function()
                    -- Flash animation
                    Tween(row, 0.05, {BackgroundColor3 = T.Accent})
                    task.delay(0.1, function() Tween(row, 0.15, {BackgroundColor3 = T.ItemBGHover}) end)
                    pcall(callback)
                end)

                function btn:SetText(t) lbl.Text = t end
                return btn
            end

            -- ==================================================
            -- ADD SLIDER
            -- ==================================================
            function sector:AddSlider(text, min, max, default, decimals, callback, flag)
                local slider = {
                    value    = default or min or 0,
                    min      = min      or 0,
                    max      = max      or 100,
                    decimals = decimals or 1,
                    flag     = flag     or text or "",
                }
                slider.callback = callback or function() end

                local wrap = Instance.new("Frame", items)
                wrap.BackgroundColor3 = T.ItemBG
                wrap.Size = UDim2.new(1, 0, 0, 42)
                wrap.BorderSizePixel = 0
                MakeCorner(wrap, T.CornerRadiusSm)
                MakeStroke(wrap, T.Border, 1)

                local lbl = Instance.new("TextLabel", wrap)
                lbl.Text = text or ""
                lbl.Font = T.FontRegular
                lbl.TextSize = T.FontSize
                lbl.TextColor3 = T.TextPrimary
                lbl.BackgroundTransparency = 1
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Position = UDim2.fromOffset(10, 5)
                lbl.Size = UDim2.new(0.6, 0, 0, 16)

                local valLbl = Instance.new("TextLabel", wrap)
                valLbl.Font = T.Font
                valLbl.TextSize = T.FontSize
                valLbl.TextColor3 = T.Accent
                valLbl.BackgroundTransparency = 1
                valLbl.TextXAlignment = Enum.TextXAlignment.Right
                valLbl.Position = UDim2.new(0, 10, 0, 5)
                valLbl.Size = UDim2.new(1, -20, 0, 16)

                -- Track
                local track = Instance.new("Frame", wrap)
                track.Size = UDim2.new(1, -20, 0, 6)
                track.Position = UDim2.new(0, 10, 0, 28)
                track.BackgroundColor3 = T.Border
                track.BorderSizePixel = 0
                MakeCorner(track, UDim.new(0, 3))

                -- Fill
                local fill = Instance.new("Frame", track)
                fill.Size = UDim2.fromScale(0, 1)
                fill.BackgroundColor3 = T.SliderFill
                fill.BorderSizePixel = 0
                MakeCorner(fill, UDim.new(0, 3))

                local fillGrad = Instance.new("UIGradient", fill)
                fillGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, T.Accent),
                    ColorSequenceKeypoint.new(1, T.AccentDark),
                })

                -- Knob
                local knob = Instance.new("Frame", track)
                knob.Size = UDim2.fromOffset(12, 12)
                knob.Position = UDim2.new(0, -6, 0.5, -6)
                knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                knob.BorderSizePixel = 0
                knob.ZIndex = 2
                MakeCorner(knob, UDim.new(0.5, 0))
                MakeStroke(knob, T.Accent, 2)

                -- Clickable overlay
                local hitbox = Instance.new("TextButton", wrap)
                hitbox.Size = UDim2.new(1, -20, 0, 20)
                hitbox.Position = UDim2.new(0, 10, 0, 22)
                hitbox.BackgroundTransparency = 1
                hitbox.Text = ""
                hitbox.ZIndex = 3

                if slider.flag ~= "" then KiciaLib.flags[slider.flag] = slider.value end

                function slider:Set(v)
                    v = math.clamp(math.floor(v * slider.decimals + 0.5) / slider.decimals, slider.min, slider.max)
                    slider.value = v
                    local pct = (v - slider.min) / (slider.max - slider.min)
                    Tween(fill, 0.08, {Size = UDim2.fromScale(pct, 1)})
                    Tween(knob, 0.08, {Position = UDim2.new(pct, -6, 0.5, -6)})
                    valLbl.Text = tostring(v).." / "..tostring(slider.max)
                    if slider.flag ~= "" then KiciaLib.flags[slider.flag] = v end
                    pcall(slider.callback, v)
                end
                function slider:Get() return slider.value end
                slider:Set(slider.value)

                local dragging = false
                local function refresh(inputPos)
                    local rel = math.clamp((inputPos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    slider:Set(slider.min + (slider.max - slider.min) * rel)
                end
                hitbox.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        Tween(knob, 0.1, {Size = UDim2.fromOffset(14, 14)})
                        refresh(i.Position)
                    end
                end)
                UIS.InputChanged:Connect(function(i)
                    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then refresh(i.Position) end
                end)
                UIS.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
                        dragging = false
                        Tween(knob, 0.1, {Size = UDim2.fromOffset(12, 12)})
                    end
                end)

                -- Hover
                wrap.MouseEnter:Connect(function() Tween(wrap, 0.15, {BackgroundColor3 = T.ItemBGHover}) end)
                wrap.MouseLeave:Connect(function() Tween(wrap, 0.15, {BackgroundColor3 = T.ItemBG}) end)

                table.insert(KiciaLib.items, slider)
                return slider
            end

            -- ==================================================
            -- ADD DROPDOWN
            -- ==================================================
            function sector:AddDropdown(text, itemsList, default, multi, callback, flag)
                local dd = {
                    values   = {},
                    items    = itemsList or {},
                    multi    = multi or false,
                    flag     = flag or text or "",
                    open     = false,
                }
                dd.callback = callback or function() end

                local wrap = Instance.new("Frame", items)
                wrap.BackgroundColor3 = T.ItemBG
                wrap.Size = UDim2.new(1, 0, 0, 42)
                wrap.BorderSizePixel = 0
                wrap.ClipsDescendants = false
                MakeCorner(wrap, T.CornerRadiusSm)
                MakeStroke(wrap, T.Border, 1)

                local lbl = Instance.new("TextLabel", wrap)
                lbl.Text = text or ""
                lbl.Font = T.FontRegular
                lbl.TextSize = T.FontSize
                lbl.TextColor3 = T.TextSecondary
                lbl.BackgroundTransparency = 1
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Position = UDim2.fromOffset(10, 5)
                lbl.Size = UDim2.new(1, -20, 0, 14)

                -- Selected display
                local selFrame = Instance.new("TextButton", wrap)
                selFrame.Text = ""
                selFrame.BackgroundColor3 = T.Background
                selFrame.Size = UDim2.new(1, -16, 0, 20)
                selFrame.Position = UDim2.new(0, 8, 0, 20)
                selFrame.BorderSizePixel = 0
                selFrame.AutoButtonColor = false
                selFrame.ZIndex = 2
                MakeCorner(selFrame, UDim.new(0, 4))
                MakeStroke(selFrame, T.Border, 1)

                local selLbl = Instance.new("TextLabel", selFrame)
                selLbl.Font = T.FontRegular
                selLbl.TextSize = T.FontSize
                selLbl.TextColor3 = T.TextPrimary
                selLbl.BackgroundTransparency = 1
                selLbl.TextXAlignment = Enum.TextXAlignment.Left
                selLbl.Position = UDim2.fromOffset(8, 0)
                selLbl.Size = UDim2.new(1, -26, 1, 0)
                selLbl.Text = "Select..."

                local arrow = Instance.new("TextLabel", selFrame)
                arrow.Text = "▾"
                arrow.Font = T.Font
                arrow.TextSize = 12
                arrow.TextColor3 = T.Accent
                arrow.BackgroundTransparency = 1
                arrow.Position = UDim2.new(1, -18, 0, 0)
                arrow.Size = UDim2.fromOffset(16, 20)

                -- Dropdown list (au-dessus du contenu parent)
                local listFrame = Instance.new("ScrollingFrame", wrap)
                listFrame.Size = UDim2.new(1, -16, 0, 0)
                listFrame.Position = UDim2.new(0, 8, 0, 44)
                listFrame.BackgroundColor3 = T.Background
                listFrame.BorderSizePixel = 0
                listFrame.ScrollBarThickness = 2
                listFrame.ScrollBarImageColor3 = T.Accent
                listFrame.Visible = false
                listFrame.ZIndex = 10
                listFrame.CanvasSize = UDim2.fromScale(0, 0)
                listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
                MakeCorner(listFrame, UDim.new(0, 4))
                MakeStroke(listFrame, T.Border, 1)
                MakePadding(listFrame, 3, 3, 3, 3)
                MakeListLayout(listFrame, Enum.FillDirection.Vertical, 2)

                if dd.flag ~= "" then KiciaLib.flags[dd.flag] = dd.multi and {} or "" end

                local function updateDisplay()
                    if #dd.values == 0 then
                        selLbl.Text = "Select..."
                        selLbl.TextColor3 = T.TextSecondary
                    elseif dd.multi then
                        selLbl.Text = table.concat(dd.values, ", ")
                        selLbl.TextColor3 = T.TextPrimary
                    else
                        selLbl.Text = dd.values[1] or ""
                        selLbl.TextColor3 = T.TextPrimary
                    end
                    if dd.flag ~= "" then
                        KiciaLib.flags[dd.flag] = dd.multi and dd.values or (dd.values[1] or "")
                    end
                end

                function dd:Set(v)
                    if type(v) == "table" then
                        dd.values = v
                    else
                        dd.values = {v}
                    end
                    updateDisplay()
                    pcall(dd.callback, dd.multi and dd.values or dd.values[1])
                end
                function dd:Get() return dd.multi and dd.values or (dd.values[1] or "") end

                local function isSelected(v)
                    for _, x in pairs(dd.values) do if x == v then return true end end
                    return false
                end

                function dd:Add(v)
                    local itemBtn = Instance.new("TextButton", listFrame)
                    itemBtn.Text = v
                    itemBtn.Font = T.FontRegular
                    itemBtn.TextSize = T.FontSize
                    itemBtn.TextColor3 = T.TextPrimary
                    itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                    itemBtn.BackgroundColor3 = T.SectorBG
                    itemBtn.Size = UDim2.new(1, 0, 0, 22)
                    itemBtn.BorderSizePixel = 0
                    itemBtn.AutoButtonColor = false
                    itemBtn.ZIndex = 11
                    MakeCorner(itemBtn, UDim.new(0, 3))
                    MakePadding(itemBtn, 0, 0, 8, 0)

                    itemBtn.MouseEnter:Connect(function() Tween(itemBtn, 0.1, {BackgroundColor3 = T.ItemBGHover}) end)
                    itemBtn.MouseLeave:Connect(function()
                        Tween(itemBtn, 0.1, {BackgroundColor3 = isSelected(v) and T.ItemBGHover or T.SectorBG})
                    end)

                    RunService.RenderStepped:Connect(function()
                        if isSelected(v) then
                            itemBtn.TextColor3 = T.Accent
                        else
                            itemBtn.TextColor3 = T.TextPrimary
                        end
                    end)

                    itemBtn.MouseButton1Click:Connect(function()
                        if dd.multi then
                            if isSelected(v) then
                                for i, x in pairs(dd.values) do if x == v then table.remove(dd.values, i); break end end
                            else
                                table.insert(dd.values, v)
                            end
                            updateDisplay()
                            pcall(dd.callback, dd.values)
                        else
                            dd:Set(v)
                            -- Close
                            dd.open = false
                            Tween(listFrame, 0.2, {Size = UDim2.new(1, -16, 0, 0)})
                            Tween(wrap, 0.2, {Size = UDim2.new(1, 0, 0, 42)})
                            task.delay(0.2, function() listFrame.Visible = false end)
                            Tween(arrow, 0.2, {Rotation = 0})
                        end
                    end)

                    table.insert(dd.items, v)
                end

                function dd:Remove(v)
                    local child = listFrame:FindFirstChild(v)
                    if child then child:Destroy() end
                    for i, x in pairs(dd.items) do if x == v then table.remove(dd.items, i); break end end
                    updateDisplay()
                end

                -- Toggle open/close
                local function toggleOpen()
                    dd.open = not dd.open
                    if dd.open then
                        local itemCount = #listFrame:GetChildren() - 2 -- subtract layout + padding
                        local h = math.min(math.max(#dd.items, 1) * 24 + 6, 120)
                        listFrame.Visible = true
                        listFrame.Size = UDim2.new(1, -16, 0, 0)
                        Tween(listFrame, 0.2, {Size = UDim2.new(1, -16, 0, h)})
                        Tween(wrap, 0.2, {Size = UDim2.new(1, 0, 0, 42 + h + 4)})
                        Tween(arrow, 0.2, {Rotation = 180})
                        Tween(selFrame, 0.1, {BackgroundColor3 = T.SectorBG})
                    else
                        Tween(listFrame, 0.2, {Size = UDim2.new(1, -16, 0, 0)})
                        Tween(wrap, 0.2, {Size = UDim2.new(1, 0, 0, 42)})
                        task.delay(0.2, function() listFrame.Visible = false end)
                        Tween(arrow, 0.2, {Rotation = 0})
                        Tween(selFrame, 0.1, {BackgroundColor3 = T.Background})
                    end
                end

                selFrame.MouseButton1Click:Connect(toggleOpen)

                -- Populate defaults
                for _, v in pairs(itemsList or {}) do dd:Add(v) end
                if default then dd:Set(default) end

                wrap.MouseEnter:Connect(function() Tween(wrap, 0.15, {BackgroundColor3 = T.ItemBGHover}) end)
                wrap.MouseLeave:Connect(function() Tween(wrap, 0.15, {BackgroundColor3 = T.ItemBG}) end)

                table.insert(KiciaLib.items, dd)
                return dd
            end

            -- ==================================================
            -- ADD LABEL
            -- ==================================================
            function sector:AddLabel(text, color)
                local row = Instance.new("Frame", items)
                row.BackgroundColor3 = T.ItemBG
                row.Size = UDim2.new(1, 0, 0, 24)
                row.BorderSizePixel = 0
                MakeCorner(row, T.CornerRadiusSm)

                local bar = Instance.new("Frame", row)
                bar.Size = UDim2.fromOffset(2, 12)
                bar.Position = UDim2.fromOffset(8, 6)
                bar.BackgroundColor3 = color or T.Accent
                bar.BorderSizePixel = 0
                MakeCorner(bar, UDim.new(0, 2))

                local lbl = Instance.new("TextLabel", row)
                lbl.Text = text or ""
                lbl.Font = T.FontRegular
                lbl.TextSize = T.FontSize
                lbl.TextColor3 = color or T.TextSecondary
                lbl.BackgroundTransparency = 1
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Position = UDim2.fromOffset(16, 0)
                lbl.Size = UDim2.new(1, -20, 1, 0)
                lbl.TextWrapped = true

                local label = {}
                function label:Set(t) lbl.Text = tostring(t) end
                function label:SetColor(c) lbl.TextColor3 = c; bar.BackgroundColor3 = c end
                return label
            end

            -- ==================================================
            -- ADD TEXTBOX
            -- ==================================================
            function sector:AddTextbox(text, placeholder, default, callback, flag)
                local tb = {value = default or "", flag = flag or text or ""}
                tb.callback = callback or function() end

                local wrap = Instance.new("Frame", items)
                wrap.BackgroundColor3 = T.ItemBG
                wrap.Size = UDim2.new(1, 0, 0, 42)
                wrap.BorderSizePixel = 0
                MakeCorner(wrap, T.CornerRadiusSm)
                MakeStroke(wrap, T.Border, 1)

                local lbl = Instance.new("TextLabel", wrap)
                lbl.Text = text or ""
                lbl.Font = T.FontRegular
                lbl.TextSize = T.FontSize
                lbl.TextColor3 = T.TextSecondary
                lbl.BackgroundTransparency = 1
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Position = UDim2.fromOffset(10, 4)
                lbl.Size = UDim2.new(1, -20, 0, 14)

                local inputFrame = Instance.new("Frame", wrap)
                inputFrame.BackgroundColor3 = T.Background
                inputFrame.Size = UDim2.new(1, -16, 0, 20)
                inputFrame.Position = UDim2.new(0, 8, 0, 20)
                inputFrame.BorderSizePixel = 0
                MakeCorner(inputFrame, UDim.new(0, 4))
                MakeStroke(inputFrame, T.Border, 1)

                local box = Instance.new("TextBox", inputFrame)
                box.PlaceholderText = placeholder or ""
                box.PlaceholderColor3 = T.TextDisabled
                box.Text = default or ""
                box.Font = T.FontRegular
                box.TextSize = T.FontSize
                box.TextColor3 = T.TextPrimary
                box.BackgroundTransparency = 1
                box.Size = UDim2.new(1, -10, 1, 0)
                box.Position = UDim2.fromOffset(8, 0)
                box.ClearTextOnFocus = false
                box.TextXAlignment = Enum.TextXAlignment.Left

                if tb.flag ~= "" then KiciaLib.flags[tb.flag] = tb.value end

                box.FocusLost:Connect(function()
                    tb.value = box.Text
                    if tb.flag ~= "" then KiciaLib.flags[tb.flag] = tb.value end
                    Tween(inputFrame, 0.15, {BackgroundColor3 = T.Background})
                    pcall(tb.callback, tb.value)
                end)
                box.Focused:Connect(function()
                    Tween(inputFrame, 0.15, {BackgroundColor3 = T.SectorBG})
                end)

                function tb:Set(v) tb.value = v; box.Text = v end
                function tb:Get() return tb.value end

                table.insert(KiciaLib.items, tb)
                return tb
            end

            -- ==================================================
            -- ADD KEYBIND
            -- ==================================================
            function sector:AddKeybind(text, default, newKeyCallback, callback, flag)
                local kb = {value = default or "None", flag = flag or text or ""}
                kb.callback    = callback       or function() end
                kb.newKeyCallback = newKeyCallback or function() end

                local row = Instance.new("Frame", items)
                row.BackgroundColor3 = T.ItemBG
                row.Size = UDim2.new(1, 0, 0, 28)
                row.BorderSizePixel = 0
                MakeCorner(row, T.CornerRadiusSm)

                local lbl = Instance.new("TextLabel", row)
                lbl.Text = text or ""
                lbl.Font = T.FontRegular
                lbl.TextSize = T.FontSize
                lbl.TextColor3 = T.TextPrimary
                lbl.BackgroundTransparency = 1
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Position = UDim2.fromOffset(10, 0)
                lbl.Size = UDim2.new(0.6, 0, 1, 0)

                local kbBtn = Instance.new("TextButton", row)
                kbBtn.Font = T.Font
                kbBtn.TextSize = 11
                kbBtn.TextColor3 = T.Accent
                kbBtn.BackgroundColor3 = T.Background
                kbBtn.Size = UDim2.fromOffset(70, 18)
                kbBtn.Position = UDim2.new(1, -78, 0.5, -9)
                kbBtn.AutoButtonColor = false
                kbBtn.Text = KeybindToText(kb.value)
                kbBtn.ZIndex = 2
                MakeCorner(kbBtn, UDim.new(0, 4))
                MakeStroke(kbBtn, T.Border, 1)

                if kb.flag ~= "" then KiciaLib.flags[kb.flag] = kb.value end

                function kb:Set(v)
                    kb.value = v
                    kbBtn.Text = KeybindToText(v)
                    if kb.flag ~= "" then KiciaLib.flags[kb.flag] = v end
                    pcall(kb.newKeyCallback, v)
                end
                function kb:Get() return kb.value end

                kbBtn.MouseButton1Click:Connect(function()
                    kbBtn.Text = "[...]"
                    kbBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
                    Tween(kbBtn, 0.1, {BackgroundColor3 = T.SectorBG})
                end)

                UIS.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if kbBtn.Text == "[...]" then
                        kbBtn.TextColor3 = T.Accent
                        Tween(kbBtn, 0.1, {BackgroundColor3 = T.Background})
                        kb:Set(InputToKeybindValue(input))
                    elseif InputMatchesKeybind(input, kb.value) then
                        pcall(kb.callback)
                    end
                end)

                row.MouseEnter:Connect(function() Tween(row, 0.15, {BackgroundColor3 = T.ItemBGHover}) end)
                row.MouseLeave:Connect(function() Tween(row, 0.15, {BackgroundColor3 = T.ItemBG}) end)

                table.insert(KiciaLib.items, kb)
                return kb
            end

            -- ==================================================
            -- ADD SEPARATOR
            -- ==================================================
            function sector:AddSeparator(text)
                local sep = Instance.new("Frame", items)
                sep.BackgroundTransparency = 1
                sep.Size = UDim2.new(1, 0, 0, 14)

                local line = Instance.new("Frame", sep)
                line.BackgroundColor3 = T.Border
                line.Size = UDim2.new(1, 0, 0, 1)
                line.Position = UDim2.fromOffset(0, 7)
                MakeCorner(line, UDim.new(0, 1))

                if text and text ~= "" then
                    local ts = TextSize(text, 11, T.FontRegular)
                    local bg = Instance.new("Frame", sep)
                    bg.BackgroundColor3 = T.SectorBG
                    bg.Size = UDim2.fromOffset(ts.X + 14, 14)
                    bg.Position = UDim2.new(0.5, -(ts.X/2 + 7), 0, 0)
                    bg.BorderSizePixel = 0

                    local sepLbl = Instance.new("TextLabel", bg)
                    sepLbl.Text = text
                    sepLbl.Font = T.FontRegular
                    sepLbl.TextSize = 11
                    sepLbl.TextColor3 = T.TextSecondary
                    sepLbl.BackgroundTransparency = 1
                    sepLbl.Size = UDim2.fromScale(1, 1)
                end
            end

            -- ==================================================
            -- ADD COLORPICKER (sector level)
            -- ==================================================
            function sector:_makeColorpicker(parent, default, callback, flag, compact)
                local cp = {value = default or Color3.fromRGB(255,255,255), flag = flag or ""}
                cp.callback = callback or function() end

                if cp.flag ~= "" then KiciaLib.flags[cp.flag] = cp.value end

                local swatch = Instance.new("TextButton", parent)
                swatch.Size = compact and UDim2.fromOffset(20, 14) or UDim2.fromOffset(24, 16)
                swatch.BackgroundColor3 = cp.value
                swatch.BorderSizePixel = 0
                swatch.Text = ""
                swatch.AutoButtonColor = false
                swatch.ZIndex = 3
                MakeCorner(swatch, UDim.new(0, 4))
                MakeStroke(swatch, T.Border, 1)

                -- Color picker popup
                local picker = Instance.new("Frame", gui)
                picker.Size = UDim2.fromOffset(200, 215)
                picker.BackgroundColor3 = T.SectorBG
                picker.BorderSizePixel = 0
                picker.Visible = false
                picker.ZIndex = 100
                MakeCorner(picker, UDim.new(0, 6))
                MakeStroke(picker, T.Border, 1)

                -- Hue/Saturation canvas
                local canvas = Instance.new("ImageLabel", picker)
                canvas.Image = "rbxassetid://4155801252"
                canvas.Size = UDim2.fromOffset(180, 150)
                canvas.Position = UDim2.fromOffset(10, 10)
                canvas.BackgroundColor3 = Color3.new(1, 0, 0)
                canvas.ZIndex = 101
                canvas.BorderColor3 = T.Border

                local canvasPointer = Instance.new("Frame", picker)
                canvasPointer.Size = UDim2.fromOffset(8, 8)
                canvasPointer.BackgroundColor3 = Color3.new(1, 1, 1)
                canvasPointer.BorderSizePixel = 0
                canvasPointer.ZIndex = 103
                MakeCorner(canvasPointer, UDim.new(0.5, 0))
                MakeStroke(canvasPointer, Color3.fromRGB(0,0,0), 1)

                local hueBar = Instance.new("TextLabel", picker)
                hueBar.Size = UDim2.fromOffset(180, 12)
                hueBar.Position = UDim2.fromOffset(10, 168)
                hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
                hueBar.Text = ""
                hueBar.ZIndex = 101
                hueBar.BorderColor3 = T.Border

                local hueGrad = Instance.new("UIGradient", hueBar)
                hueGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,    Color3.new(1,0,0)),
                    ColorSequenceKeypoint.new(0.17, Color3.new(1,0,1)),
                    ColorSequenceKeypoint.new(0.33, Color3.new(0,0,1)),
                    ColorSequenceKeypoint.new(0.5,  Color3.new(0,1,1)),
                    ColorSequenceKeypoint.new(0.67, Color3.new(0,1,0)),
                    ColorSequenceKeypoint.new(0.83, Color3.new(1,1,0)),
                    ColorSequenceKeypoint.new(1,    Color3.new(1,0,0)),
                })

                local huePointer = Instance.new("Frame", picker)
                huePointer.Size = UDim2.fromOffset(3, 14)
                huePointer.BackgroundColor3 = Color3.new(1,1,1)
                huePointer.BorderSizePixel = 0
                huePointer.ZIndex = 103
                huePointer.Position = UDim2.fromOffset(10, 167)
                MakeStroke(huePointer, Color3.new(0,0,0), 1)

                -- Hex input
                local hexFrame = Instance.new("Frame", picker)
                hexFrame.Size = UDim2.fromOffset(180, 22)
                hexFrame.Position = UDim2.fromOffset(10, 186)
                hexFrame.BackgroundColor3 = T.Background
                hexFrame.BorderSizePixel = 0
                MakeCorner(hexFrame, UDim.new(0, 4))
                MakeStroke(hexFrame, T.Border, 1)

                local hexBox = Instance.new("TextBox", hexFrame)
                hexBox.PlaceholderText = "#FFFFFF"
                hexBox.Text = ""
                hexBox.Font = T.FontRegular
                hexBox.TextSize = 11
                hexBox.TextColor3 = T.TextPrimary
                hexBox.BackgroundTransparency = 1
                hexBox.Size = UDim2.new(1, -10, 1, 0)
                hexBox.Position = UDim2.fromOffset(8, 0)
                hexBox.ClearTextOnFocus = false
                hexBox.ZIndex = 102

                cp.color = 0 -- hue 0-1

                function cp:Set(color)
                    cp.value = color
                    swatch.BackgroundColor3 = color
                    local darker = Color3.new(color.R*0.7, color.G*0.7, color.B*0.7)
                    MakeStroke(swatch, darker, 1)
                    if cp.flag ~= "" then KiciaLib.flags[cp.flag] = color end
                    local r = math.floor(color.R*255)
                    local g = math.floor(color.G*255)
                    local b = math.floor(color.B*255)
                    hexBox.Text = string.format("#%02X%02X%02X", r, g, b)
                    pcall(cp.callback, color)
                end
                function cp:Get() return cp.value end
                cp:Set(cp.value)

                local function refreshCanvas()
                    local mx = Mouse.X - canvas.AbsolutePosition.X
                    local my = Mouse.Y - canvas.AbsolutePosition.Y
                    local sx = math.clamp(mx / canvas.AbsoluteSize.X, 0, 1)
                    local sy = math.clamp(my / canvas.AbsoluteSize.Y, 0, 1)
                    canvasPointer.Position = UDim2.fromOffset(
                        10 + math.clamp(mx, 0, canvas.AbsoluteSize.X) - 4,
                        10 + math.clamp(my, 0, canvas.AbsoluteSize.Y) - 4
                    )
                    cp:Set(Color3.fromHSV(cp.color, sx, 1 - sy))
                end

                local function refreshHue()
                    local mx = Mouse.X - hueBar.AbsolutePosition.X
                    local pos = math.clamp(mx / hueBar.AbsoluteSize.X, 0, 1)
                    cp.color = pos
                    canvas.BackgroundColor3 = Color3.fromHSV(pos, 1, 1)
                    huePointer.Position = UDim2.fromOffset(
                        10 + math.clamp(mx, 0, hueBar.AbsoluteSize.X) - 1,
                        167
                    )
                    local _, s, v = Color3.toHSV(cp.value)
                    cp:Set(Color3.fromHSV(pos, s, v))
                end

                local draggingCanvas, draggingHue = false, false

                canvas.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingCanvas = true; refreshCanvas() end
                end)
                hueBar.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true; refreshHue() end
                end)
                UIS.InputChanged:Connect(function(i)
                    if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                    if draggingCanvas then refreshCanvas() end
                    if draggingHue then refreshHue() end
                end)
                UIS.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingCanvas = false
                        draggingHue = false
                    end
                end)

                hexBox.FocusLost:Connect(function()
                    local hex = hexBox.Text:gsub("#", "")
                    if #hex == 6 then
                        local r = tonumber(hex:sub(1,2), 16) or 255
                        local g = tonumber(hex:sub(3,4), 16) or 255
                        local b = tonumber(hex:sub(5,6), 16) or 255
                        cp:Set(Color3.fromRGB(r, g, b))
                    end
                end)

                local pickerOpen = false
                swatch.MouseButton1Click:Connect(function()
                    pickerOpen = not pickerOpen
                    picker.Visible = pickerOpen
                    if pickerOpen then
                        local abs = swatch.AbsolutePosition
                        picker.Position = UDim2.fromOffset(abs.X - 190, abs.Y + swatch.AbsoluteSize.Y + 4)
                        picker.Size = UDim2.fromOffset(200, 0)
                        Tween(picker, 0.25, {Size = UDim2.fromOffset(200, 215)})
                    else
                        Tween(picker, 0.2, {Size = UDim2.fromOffset(200, 0)})
                        task.delay(0.22, function() picker.Visible = false end)
                    end
                end)

                return cp
            end

            function sector:AddColorpicker(text, default, callback, flag)
                local row = Instance.new("Frame", items)
                row.BackgroundColor3 = T.ItemBG
                row.Size = UDim2.new(1, 0, 0, 28)
                row.BorderSizePixel = 0
                MakeCorner(row, T.CornerRadiusSm)

                local lbl = Instance.new("TextLabel", row)
                lbl.Text = text or ""
                lbl.Font = T.FontRegular
                lbl.TextSize = T.FontSize
                lbl.TextColor3 = T.TextPrimary
                lbl.BackgroundTransparency = 1
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Position = UDim2.fromOffset(10, 0)
                lbl.Size = UDim2.new(1, -50, 1, 0)

                local cpHolder = Instance.new("Frame", row)
                cpHolder.BackgroundTransparency = 1
                cpHolder.Size = UDim2.fromOffset(30, 28)
                cpHolder.Position = UDim2.new(1, -36, 0, 0)
                MakeListLayout(cpHolder, Enum.FillDirection.Horizontal, 4)

                local cp = sector:_makeColorpicker(cpHolder, default, callback, flag, false)

                row.MouseEnter:Connect(function() Tween(row, 0.15, {BackgroundColor3 = T.ItemBGHover}) end)
                row.MouseLeave:Connect(function() Tween(row, 0.15, {BackgroundColor3 = T.ItemBG}) end)

                return cp
            end

            table.insert(tab.Sectors, sector)
            return sector
        end

        table.insert(window.Tabs, tab)
        return tab
    end

    -- ── SETTINGS TAB automatique
    local settingsTab = window:CreateTab("⚙ Settings")
    local settingsSector = settingsTab:CreateSector("Interface", "left")
    settingsSector:AddKeybind("Hide / Show", window.HideKey, function(k)
        if k ~= "None" then window.HideKey = k end
    end, function() end, "settings_hide")

    local colorSector = settingsTab:CreateSector("Colors", "right")
    colorSector:AddColorpicker("Accent Color", T.Accent, function(c)
        T.Accent = c
        topSep.BackgroundColor3 = c
        accentLine.BackgroundColor3 = c
    end, "settings_accent")
    colorSector:AddColorpicker("Background", T.Background, function(c)
        T.Background = c
        main.BackgroundColor3 = c
    end, "settings_bg")

    return window
end

-- ============================================================
-- EXEMPLE D'UTILISATION (commenté)
-- ============================================================
--[[
local lib = loadstring(game:HttpGet("RAW_GITHUB_URL"))()

local win = lib:CreateWindow({
    Name    = "KiciaHook V2 | Rivals",
    Size    = Vector2.new(540, 420),
    HideKey = Enum.KeyCode.RightShift,
})

local tab = win:CreateTab("Combat")

local mainSector = tab:CreateSector("Main", "left")

local toggle = mainSector:AddToggle("Enabled", false, function(v)
    print("Enabled:", v)
end, "enabled_flag")

toggle:AddKeybind(Enum.KeyCode.E)

mainSector:AddSlider("Field Of View (°)", 1, 360, 90, 1, function(v)
    print("FOV:", v)
end, "fov_flag")

local rightSector = tab:CreateSector("Anti Aim", "right")

rightSector:AddToggle("Enabled", false, function(v)
    print("Anti Aim:", v)
end, "antiaim_flag")

rightSector:AddDropdown("Pitch", {"Down", "Up", "Zero"}, "Down", false, function(v)
    print("Pitch:", v)
end, "pitch_flag")

rightSector:AddDropdown("Yaw Base", {"At Targets", "Forward", "Backward"}, "At Targets", false, function(v)
    print("Yaw Base:", v)
end, "yawbase_flag")

rightSector:AddSlider("Yaw Angle (°)", 0, 180, 0, 1, function(v)
    print("Yaw Angle:", v)
end, "yawangle_flag")

lib:Notify("KiciaHook", "Chargé avec succès !", 5)
]]

return KiciaLib
