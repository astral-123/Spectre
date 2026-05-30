local KiciaLib = { flags = {}, items = {} }

-- Services
local Players        = game:GetService("Players")
local UIS            = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local TextService    = game:GetService("TextService")
local CoreGui        = game:GetService("CoreGui")
local HttpService    = game:GetService("HttpService")
local MarketService  = game:GetService("MarketplaceService")

local Player = Players.LocalPlayer
local Mouse  = Player:GetMouse()
local Camera = workspace.CurrentCamera

-- ============================================================
-- THEME (copie exacte couleurs photo)
-- ============================================================
local Theme = {
    Font           = Enum.Font.Code,
    FontSize       = 13,
    TitleSize      = 15,

    Background     = Color3.fromRGB(20, 20, 20),
    TopBar         = Color3.fromRGB(30, 30, 30),
    TabBar         = Color3.fromRGB(25, 25, 25),
    SectorBG       = Color3.fromRGB(30, 30, 30),

    Accent         = Color3.fromRGB(28, 56, 139),   -- bleu fonce comme photo
    AccentBright   = Color3.fromRGB(0, 120, 255),   -- bleu clair sliders

    TextWhite      = Color3.fromRGB(240, 240, 240),
    TextGray       = Color3.fromRGB(200, 200, 200),
    TextDark       = Color3.fromRGB(136, 136, 136),

    OutlineGray    = Color3.fromRGB(60, 60, 60),
    OutlineBlack   = Color3.fromRGB(0, 0, 0),

    ButtonBG       = Color3.fromRGB(49, 49, 49),
    ButtonBG2      = Color3.fromRGB(39, 39, 39),

    ToggleON_top   = Color3.fromRGB(16, 31, 78),
    ToggleON_bot   = Color3.fromRGB(28, 56, 139),
    ToggleOFF_top  = Color3.fromRGB(30, 30, 30),
    ToggleOFF_bot  = Color3.fromRGB(45, 45, 45),

    TopHeight      = 48,
    TabHeight      = 24,
}

-- ============================================================
-- KEYBIND HELPERS
-- ============================================================
local ShortKeys = {
    LeftShift="LSHIFT", RightShift="RSHIFT",
    LeftControl="LCTRL", RightControl="RCTRL",
    LeftAlt="LALT", RightAlt="RALT",
}
local MouseBtns = {
    [Enum.UserInputType.MouseButton1]="MB1",
    [Enum.UserInputType.MouseButton2]="MB2",
    [Enum.UserInputType.MouseButton3]="MB3",
}
local function KBText(v)
    if v=="None" or v==nil then return "[None]" end
    if MouseBtns[v] then return "["..MouseBtns[v].."]" end
    if typeof(v)=="EnumItem" then return "["..(ShortKeys[v.Name] or v.Name).."]" end
    return "["..tostring(v).."]"
end
local function InputMatchesKB(input, value)
    if value=="None" or value==nil then return false end
    if MouseBtns[value] then return input.UserInputType==value end
    if typeof(value)=="EnumItem" then
        return input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==value
    end
    return false
end
local function InputToKB(input)
    if MouseBtns[input.UserInputType] then return input.UserInputType
    elseif input.UserInputType==Enum.UserInputType.Keyboard then return input.KeyCode end
    return "None"
end

-- ============================================================
-- HELPERS UI
-- ============================================================
local function Tween(obj, t, props, style)
    TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Linear, Enum.EasingDirection.In), props):Play()
end

-- Triple outline comme EchoLabs (black > gray > black)
local function AddOutlines(parent, size)
    -- Inner black
    local bo1 = Instance.new("Frame", parent)
    bo1.ZIndex = parent.ZIndex - 1
    bo1.BorderSizePixel = 0
    bo1.BackgroundColor3 = Theme.OutlineBlack
    bo1.Size = size + UDim2.fromOffset(2,2)
    bo1.Position = UDim2.fromOffset(-1,-1)

    -- Gray
    local bo2 = Instance.new("Frame", parent)
    bo2.ZIndex = parent.ZIndex - 2
    bo2.BorderSizePixel = 0
    bo2.BackgroundColor3 = Theme.OutlineGray
    bo2.Size = size + UDim2.fromOffset(4,4)
    bo2.Position = UDim2.fromOffset(-2,-2)

    -- Outer black
    local bo3 = Instance.new("Frame", parent)
    bo3.ZIndex = parent.ZIndex - 3
    bo3.BorderSizePixel = 0
    bo3.BackgroundColor3 = Theme.OutlineBlack
    bo3.Size = size + UDim2.fromOffset(6,6)
    bo3.Position = UDim2.fromOffset(-3,-3)

    -- Update sizes quand parent change
    parent:GetPropertyChangedSignal("Size"):Connect(function()
        bo1.Size = parent.Size + UDim2.fromOffset(2,2)
        bo2.Size = parent.Size + UDim2.fromOffset(4,4)
        bo3.Size = parent.Size + UDim2.fromOffset(6,6)
    end)
    return bo1, bo2, bo3
end

local function MakeGradient(parent, top, bot)
    local g = Instance.new("UIGradient", parent)
    g.Rotation = 90
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, top),
        ColorSequenceKeypoint.new(1, bot),
    })
    return g
end

local function MakeListLayout(parent, dir, padding)
    local l = Instance.new("UIListLayout", parent)
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, padding or 0)
    return l
end

local function MakePadding(parent, t,b,l,r)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    return p
end

local function GetTextSize(text, size, font)
    return TextService:GetTextSize(text, size or Theme.FontSize, font or Theme.Font, Vector2.new(9999,9999))
end

-- ============================================================
-- NOTIFY
-- ============================================================
function KiciaLib:Notify(title, body, duration)
    if type(body)=="number" then duration=body; body=nil end
    duration = duration or 5

    local nGui = Instance.new("ScreenGui")
    nGui.Name = "KiciaNotif"
    nGui.DisplayOrder = 50
    nGui.ResetOnSpawn = false
    pcall(function() nGui.Parent = CoreGui end)
    if not nGui.Parent then nGui.Parent = Player.PlayerGui end

    local h = body and 56 or 36
    local w = 260

    local frame = Instance.new("Frame", nGui)
    frame.Name = "notif"
    frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
    frame.BorderSizePixel = 0
    frame.Size = UDim2.fromOffset(w, h)
    frame.Position = UDim2.new(1, w+20, 0, 10)
    frame.ZIndex = 10
    MakeGradient(frame, Color3.fromRGB(40,40,40), Color3.fromRGB(22,22,22))
    AddOutlines(frame, frame.Size)

    -- Accent top bar
    local topBar = Instance.new("Frame", frame)
    topBar.Size = UDim2.fromOffset(0, 1)
    topBar.BackgroundColor3 = Theme.Accent
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 11

    -- Accent left bar
    local leftBar = Instance.new("Frame", frame)
    leftBar.Size = UDim2.fromOffset(2, h)
    leftBar.BackgroundColor3 = Theme.Accent
    leftBar.BorderSizePixel = 0
    leftBar.ZIndex = 11

    -- Title
    local titleLbl = Instance.new("TextLabel", frame)
    titleLbl.Text = title or ""
    titleLbl.Font = Theme.Font
    titleLbl.TextSize = 13
    titleLbl.TextColor3 = Theme.TextWhite
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextStrokeTransparency = 0
    titleLbl.Position = UDim2.fromOffset(10, body and 6 or 10)
    titleLbl.Size = UDim2.fromOffset(w-18, 16)
    titleLbl.ZIndex = 12

    if body then
        local bodyLbl = Instance.new("TextLabel", frame)
        bodyLbl.Text = body
        bodyLbl.Font = Theme.Font
        bodyLbl.TextSize = 11
        bodyLbl.TextColor3 = Theme.TextGray
        bodyLbl.BackgroundTransparency = 1
        bodyLbl.TextXAlignment = Enum.TextXAlignment.Left
        bodyLbl.TextWrapped = true
        bodyLbl.Position = UDim2.fromOffset(10, 24)
        bodyLbl.Size = UDim2.fromOffset(w-18, 26)
        bodyLbl.ZIndex = 12
    end

    -- Progress bar
    local pbg = Instance.new("Frame", frame)
    pbg.Size = UDim2.fromOffset(w, 2)
    pbg.Position = UDim2.new(0,0,1,-2)
    pbg.BackgroundColor3 = Color3.fromRGB(15,15,15)
    pbg.BorderSizePixel = 0
    pbg.ZIndex = 12

    local pb = Instance.new("Frame", pbg)
    pb.Size = UDim2.fromScale(1,1)
    pb.BackgroundColor3 = Theme.Accent
    pb.BorderSizePixel = 0
    pb.ZIndex = 13

    -- Slide in depuis droite
    Tween(frame, 0.35, {Position = UDim2.new(1, -(w+12), 0, 10)}, Enum.EasingStyle.Quint)
    Tween(topBar, 0.4, {Size = UDim2.fromOffset(w, 1)}, Enum.EasingStyle.Quint)

    task.delay(0.4, function()
        TweenService:Create(pb, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(0,1)}):Play()
        task.delay(duration, function()
            Tween(frame, 0.3, {Position = UDim2.new(1, w+20, 0, 10)}, Enum.EasingStyle.Quint)
            task.delay(0.35, function() nGui:Destroy() end)
        end)
    end)
end

-- ============================================================
-- CREATE WINDOW
-- ============================================================
function KiciaLib:CreateWindow(config)
    config = config or {}
    local winName   = config.Name    or "KiciaHook"
    local winSize   = config.Size    or Vector2.new(540, 420)
    local hideKey   = config.HideKey or Enum.KeyCode.RightShift

    local window = { Tabs={}, HideKey=hideKey, _size=winSize }

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = winName
    gui.DisplayOrder = 15
    gui.ResetOnSpawn = false
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = Player.PlayerGui end

    if getgenv and getgenv()._KiciaGui then pcall(function() getgenv()._KiciaGui:Destroy() end) end
    if getgenv then getgenv()._KiciaGui = gui end

    -- ── MAIN FRAME (style photo : frame plat, triple outline)
    local main = Instance.new("TextButton", gui)
    main.Name = "Main"
    main.BackgroundColor3 = Theme.Background
    main.BorderSizePixel = 0
    main.Size = UDim2.fromOffset(winSize.X, winSize.Y)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.AutoButtonColor = false
    main.Text = ""
    main.ZIndex = 5
    main.ClipsDescendants = true

    AddOutlines(main, main.Size)

    -- ── TOP BAR
    local topBar = Instance.new("Frame", main)
    topBar.Name = "TopBar"
    topBar.Size = UDim2.fromOffset(winSize.X, Theme.TopHeight)
    topBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 6
    MakeGradient(topBar, Theme.TopBar, Theme.TopBar)

    -- Ligne accent milieu topbar (separateur titre / tabs)
    local midLine = Instance.new("Frame", topBar)
    midLine.Size = UDim2.fromOffset(winSize.X, 1)
    midLine.Position = UDim2.fromOffset(0, Theme.TopHeight/2)
    midLine.BackgroundColor3 = Theme.Accent
    midLine.BorderSizePixel = 0
    midLine.ZIndex = 7

    -- Titre
    local gameName = ""
    pcall(function() gameName = MarketService:GetProductInfo(game.PlaceId).Name end)

    local titleLbl = Instance.new("TextLabel", topBar)
    titleLbl.Text = winName
    titleLbl.Font = Theme.Font
    titleLbl.TextSize = Theme.TitleSize
    titleLbl.TextColor3 = Theme.TextWhite
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextStrokeTransparency = 0
    titleLbl.Position = UDim2.fromOffset(6, -2)
    titleLbl.Size = UDim2.fromOffset(300, Theme.TopHeight/2 - 2)
    titleLbl.ZIndex = 7

    -- Tab list (bas du topbar)
    local tabList = Instance.new("Frame", topBar)
    tabList.Name = "TabList"
    tabList.BackgroundTransparency = 1
    tabList.Position = UDim2.fromOffset(0, Theme.TopHeight/2 + 1)
    tabList.Size = UDim2.fromOffset(winSize.X, Theme.TopHeight/2)
    tabList.BorderSizePixel = 0
    tabList.ZIndex = 7

    local tabLL = MakeListLayout(tabList, Enum.FillDirection.Horizontal, 0)
    tabLL.VerticalAlignment = Enum.VerticalAlignment.Center

    -- Indicateur tab actif (underline bleu)
    local tabLine = Instance.new("Frame", main)
    tabLine.Name = "TabLine"
    tabLine.Size = UDim2.fromOffset(0, 1)
    tabLine.BackgroundColor3 = Theme.Accent
    tabLine.BorderSizePixel = 0
    tabLine.ZIndex = 8
    tabLine.Position = UDim2.fromOffset(0, Theme.TopHeight - 1)

    -- Ligne noire sous topbar
    local blackLine = Instance.new("Frame", main)
    blackLine.Size = UDim2.fromOffset(winSize.X, 1)
    blackLine.Position = UDim2.fromOffset(0, Theme.TopHeight)
    blackLine.BackgroundColor3 = Theme.OutlineBlack
    blackLine.BorderSizePixel = 0
    blackLine.ZIndex = 8

    -- Background texture zone contenu
    local bgImg = Instance.new("ImageLabel", main)
    bgImg.Name = "BG"
    bgImg.BorderSizePixel = 0
    bgImg.ScaleType = Enum.ScaleType.Tile
    bgImg.Position = UDim2.fromOffset(0, Theme.TopHeight + 1)
    bgImg.Size = UDim2.fromOffset(winSize.X, winSize.Y - Theme.TopHeight - 1)
    bgImg.Image = "rbxassetid://5553946656"
    bgImg.ImageColor3 = Color3.new(0,0,0)
    bgImg.BackgroundColor3 = Theme.Background
    bgImg.TileSize = UDim2.fromOffset(90, 90)
    bgImg.ZIndex = 5

    -- Bouton minimize
    local minBtn = Instance.new("TextButton", topBar)
    minBtn.Text = "-"
    minBtn.Font = Theme.Font
    minBtn.TextSize = 16
    minBtn.TextColor3 = Color3.fromRGB(180,180,180)
    minBtn.BackgroundTransparency = 1
    minBtn.BorderSizePixel = 0
    minBtn.Size = UDim2.fromOffset(18,18)
    minBtn.Position = UDim2.new(1,-40,0,4)
    minBtn.ZIndex = 10
    minBtn.AutoButtonColor = false

    -- Bouton close
    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Text = "x"
    closeBtn.Font = Theme.Font
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Color3.fromRGB(180,180,180)
    closeBtn.BackgroundTransparency = 1
    closeBtn.BorderSizePixel = 0
    closeBtn.Size = UDim2.fromOffset(18,18)
    closeBtn.Position = UDim2.new(1,-18,0,4)
    closeBtn.ZIndex = 10
    closeBtn.AutoButtonColor = false

    minBtn.MouseEnter:Connect(function() Tween(minBtn,0.1,{TextColor3=Color3.fromRGB(255,255,255)}) end)
    minBtn.MouseLeave:Connect(function() Tween(minBtn,0.1,{TextColor3=Color3.fromRGB(180,180,180)}) end)
    closeBtn.MouseEnter:Connect(function() Tween(closeBtn,0.1,{TextColor3=Color3.fromRGB(220,60,60)}) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn,0.1,{TextColor3=Color3.fromRGB(180,180,180)}) end)

    local minimized = false
    minBtn.MouseButton1Down:Connect(function()
        minimized = not minimized
        if minimized then
            main:TweenSize(UDim2.fromOffset(winSize.X, Theme.TopHeight), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.15)
        else
            main:TweenSize(UDim2.fromOffset(winSize.X, winSize.Y), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.15)
        end
    end)

    closeBtn.MouseButton1Down:Connect(function()
        for _,v in pairs(KiciaLib.items) do
            pcall(function()
                if v.Set and type(v.value)=="boolean" and v.value then v:Set(false) end
            end)
        end
        gui:Destroy()
    end)

    -- Toggle hide avec touche
    UIS.InputBegan:Connect(function(key, gp)
        if gp then return end
        if InputMatchesKB(key, window.HideKey) then
            main.Visible = not main.Visible
        end
    end)

    -- Drag
    local dragging, dragInput, dragStart, startPos = false,nil,nil,nil
    local function dragStart_(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=input.Position; startPos=main.Position
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then dragging=false end
            end)
        end
    end
    local function dragMove_(input)
        if input.UserInputType==Enum.UserInputType.MouseMovement then dragInput=input end
    end
    topBar.InputBegan:Connect(dragStart_)
    topBar.InputChanged:Connect(dragMove_)
    tabList.InputBegan:Connect(dragStart_)
    tabList.InputChanged:Connect(dragMove_)
    UIS.InputChanged:Connect(function(input)
        if input==dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
        end
    end)

    -- ============================================================
    -- CREATE TAB
    -- ============================================================
    function window:CreateTab(tabName)
        local tab = { SectorsLeft={}, SectorsRight={}, _name=tabName }

        local sz = GetTextSize(tabName, Theme.FontSize, Theme.Font)

        local tabBtn = Instance.new("TextButton", tabList)
        tabBtn.Text = tabName
        tabBtn.Font = Theme.Font
        tabBtn.TextSize = Theme.FontSize
        tabBtn.TextColor3 = Theme.TextGray
        tabBtn.BackgroundTransparency = 1
        tabBtn.BorderSizePixel = 0
        tabBtn.Size = UDim2.fromOffset(sz.X + 16, tabList.AbsoluteSize.Y > 0 and tabList.AbsoluteSize.Y or Theme.TopHeight/2)
        tabBtn.AutoButtonColor = false
        tabBtn.ZIndex = 8
        tab._btn = tabBtn

        -- Contenu : 2 ScrollingFrames (gauche + droite)
        local contentY = Theme.TopHeight + 1

        local leftScroll = Instance.new("ScrollingFrame", main)
        leftScroll.Name = "Left"
        leftScroll.BorderSizePixel = 0
        leftScroll.BackgroundTransparency = 1
        leftScroll.ScrollBarThickness = 0
        leftScroll.ScrollingDirection = "Y"
        leftScroll.Visible = false
        leftScroll.Size = UDim2.fromOffset(winSize.X/2, winSize.Y - contentY)
        leftScroll.Position = UDim2.fromOffset(0, contentY)
        leftScroll.ZIndex = 6
        leftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        leftScroll.CanvasSize = UDim2.fromScale(0,0)

        local leftLL = MakeListLayout(leftScroll, Enum.FillDirection.Vertical, 12)
        local leftPad = MakePadding(leftScroll, 12, 12, 12, 6)

        local rightScroll = Instance.new("ScrollingFrame", main)
        rightScroll.Name = "Right"
        rightScroll.BorderSizePixel = 0
        rightScroll.BackgroundTransparency = 1
        rightScroll.ScrollBarThickness = 0
        rightScroll.ScrollingDirection = "Y"
        rightScroll.Visible = false
        rightScroll.Size = UDim2.fromOffset(winSize.X/2, winSize.Y - contentY)
        rightScroll.Position = UDim2.fromOffset(winSize.X/2, contentY)
        rightScroll.ZIndex = 6
        rightScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        rightScroll.CanvasSize = UDim2.fromScale(0,0)

        local rightLL = MakeListLayout(rightScroll, Enum.FillDirection.Vertical, 12)
        local rightPad = MakePadding(rightScroll, 12, 12, 6, 12)

        tab._left  = leftScroll
        tab._right = rightScroll

        function tab:Select()
            for _,t in pairs(window.Tabs) do
                t._btn.TextColor3 = Theme.TextGray
                t._left.Visible  = false
                t._right.Visible = false
            end
            tabBtn.TextColor3 = Theme.Accent

            leftScroll.Visible  = true
            rightScroll.Visible = true

            -- Animer la ligne indicateur
            local btnX = tabBtn.AbsolutePosition.X - (tabList.Parent and tabList.Parent.AbsolutePosition.X or 0)
            Tween(tabLine, 0.15, {
                Size     = UDim2.fromOffset(sz.X+16, 1),
                Position = UDim2.new(0, btnX, 0, Theme.TopHeight - 1),
            }, Enum.EasingStyle.Sine)
        end

        tabBtn.MouseButton1Down:Connect(function() tab:Select() end)

        if #window.Tabs == 0 then
            task.defer(function() tab:Select() end)
        end

        -- ============================================================
        -- CREATE SECTOR
        -- ============================================================
        function tab:CreateSector(sectorName, side)
            side = (side or "left"):lower()
            local parent = side=="right" and rightScroll or leftScroll
            local sectorList = side=="right" and tab.SectorsRight or tab.SectorsLeft
            local sector = {}

            local sectorW = winSize.X/2 - 24

            -- Frame secteur (style photo : fond gris foncé, triple outline, ligne accent haut-gauche)
            local sMain = Instance.new("Frame", parent)
            sMain.Name = sectorName:gsub(" ","").."Sector"
            sMain.BackgroundColor3 = Theme.SectorBG
            sMain.BorderSizePixel = 0
            sMain.ZIndex = 7
            sMain.Size = UDim2.fromOffset(sectorW, 20)
            sMain.AutomaticSize = Enum.AutomaticSize.Y

            -- Ligne accent tout en haut (bleu, 1px)
            local sLine = Instance.new("Frame", sMain)
            sLine.Size = UDim2.fromOffset(sMain.Size.X.Offset + 4, 1)
            sLine.Position = UDim2.fromOffset(-2, -2)
            sLine.BackgroundColor3 = Theme.Accent
            sLine.BorderSizePixel = 0
            sLine.ZIndex = 8

            AddOutlines(sMain, sMain.Size)

            -- Label secteur (fond coloré, au-dessus de la border)
            local labelSize = GetTextSize(sectorName, 13, Theme.Font)
            local labelBack = Instance.new("Frame", sMain)
            labelBack.Name = "LabelBack"
            labelBack.ZIndex = 9
            labelBack.Size = UDim2.fromOffset(labelSize.X + 14, labelSize.Y)
            labelBack.BorderSizePixel = 0
            labelBack.BackgroundColor3 = Theme.SectorBG
            labelBack.Position = UDim2.fromOffset(10, -labelSize.Y/2 - 1)

            local labelLbl = Instance.new("TextLabel", labelBack)
            labelLbl.Text = sectorName
            labelLbl.Font = Theme.Font
            labelLbl.TextSize = 13
            labelLbl.TextColor3 = Color3.fromRGB(255,255,255)
            labelLbl.BackgroundTransparency = 1
            labelLbl.Size = UDim2.fromScale(1,1)
            labelLbl.ZIndex = 10
            labelLbl.TextStrokeTransparency = 1

            -- Items container
            local sItems = Instance.new("Frame", sMain)
            sItems.Name = "Items"
            sItems.BackgroundTransparency = 1
            sItems.AutomaticSize = Enum.AutomaticSize.Y
            sItems.Size = UDim2.new(1, 0, 0, 0)
            sItems.BorderSizePixel = 0
            sItems.ZIndex = 7

            local sLL = MakeListLayout(sItems, Enum.FillDirection.Vertical, 10)
            MakePadding(sItems, 12, 10, 6, 6)

            sector._main  = sMain
            sector._items = sItems
            sector._w     = sectorW

            local function fixSize()
                -- AutomaticSize fait le travail
                sLine.Size = UDim2.fromOffset(sMain.AbsoluteSize.X + 4, 1)
            end
            sMain:GetPropertyChangedSignal("Size"):Connect(fixSize)

            -- ==================================================
            -- ADD TOGGLE
            -- ==================================================
            function sector:AddToggle(text, default, callback, flag)
                local toggle = {value=default or false, flag=flag or text or ""}
                toggle.callback = callback or function() end

                local row = Instance.new("Frame", sItems)
                row.BackgroundTransparency = 1
                row.Size = UDim2.new(1,0,0,14)
                row.BorderSizePixel = 0
                row.ZIndex = 7

                -- Le petit carré toggle (style photo)
                local box = Instance.new("TextButton", row)
                box.Name = "ToggleBox"
                box.BackgroundColor3 = Color3.fromRGB(255,255,255)
                box.BorderSizePixel = 0
                box.Size = UDim2.fromOffset(8,8)
                box.Position = UDim2.fromOffset(0,3)
                box.AutoButtonColor = false
                box.Text = ""
                box.ZIndex = 8

                -- gradient OFF
                local boxGrad = MakeGradient(box, Theme.ToggleOFF_top, Theme.ToggleOFF_bot)

                -- Carré intérieur (visible quand ON)
                local checkFrame = Instance.new("Frame", box)
                checkFrame.Size = box.Size
                checkFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
                checkFrame.BorderSizePixel = 0
                checkFrame.Visible = false
                checkFrame.ZIndex = 9
                MakeGradient(checkFrame, Theme.ToggleON_top, Theme.ToggleON_bot)

                -- Triple outline du toggle
                local tbo1 = Instance.new("Frame", box)
                tbo1.ZIndex=7; tbo1.BorderSizePixel=0
                tbo1.BackgroundColor3=Theme.OutlineBlack
                tbo1.Size=box.Size+UDim2.fromOffset(2,2)
                tbo1.Position=UDim2.fromOffset(-1,-1)

                local tbo2 = Instance.new("Frame", box)
                tbo2.ZIndex=6; tbo2.BorderSizePixel=0
                tbo2.BackgroundColor3=Theme.OutlineGray
                tbo2.Size=box.Size+UDim2.fromOffset(4,4)
                tbo2.Position=UDim2.fromOffset(-2,-2)

                local tbo3 = Instance.new("Frame", box)
                tbo3.ZIndex=5; tbo3.BorderSizePixel=0
                tbo3.BackgroundColor3=Theme.OutlineBlack
                tbo3.Size=box.Size+UDim2.fromOffset(6,6)
                tbo3.Position=UDim2.fromOffset(-3,-3)

                -- Label du toggle
                local lbl = Instance.new("TextButton", box)
                lbl.Name = "Label"
                lbl.AutoButtonColor = false
                lbl.BackgroundTransparency = 1
                lbl.Position = UDim2.fromOffset(box.Size.X.Offset + 8, -2)
                lbl.Size = UDim2.fromOffset(sector._w - 60, 14)
                lbl.Font = Theme.Font
                lbl.Text = text or ""
                lbl.TextColor3 = Theme.TextGray
                lbl.TextSize = Theme.FontSize
                lbl.TextStrokeTransparency = 1
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.ZIndex = 9

                -- Container pour keybind/colorpicker à droite
                local rightItems = Instance.new("Frame", row)
                rightItems.Name = "RightItems"
                rightItems.BackgroundTransparency = 1
                rightItems.Size = UDim2.fromOffset(60, 14)
                rightItems.Position = UDim2.new(1,-62,0,0)
                rightItems.ZIndex = 9
                MakeListLayout(rightItems, Enum.FillDirection.Horizontal, 6)
                rightItems.LayoutOrder = 10

                if toggle.flag~="" then KiciaLib.flags[toggle.flag] = toggle.value end

                function toggle:Set(v)
                    toggle.value = v
                    checkFrame.Visible = v
                    Tween(lbl, 0.1, {TextColor3 = v and Theme.TextWhite or Theme.TextGray})
                    if toggle.flag~="" then KiciaLib.flags[toggle.flag]=v end
                    pcall(toggle.callback, v)
                end
                function toggle:Get() return toggle.value end
                toggle:Set(toggle.value)

                local function click()
                    toggle:Set(not toggle.value)
                    -- Flash animation
                    if toggle.value then
                        Tween(tbo2, 0.08, {BackgroundColor3=Theme.Accent})
                        task.delay(0.15, function() Tween(tbo2,0.1,{BackgroundColor3=Theme.OutlineGray}) end)
                    end
                end
                box.MouseButton1Down:Connect(click)
                lbl.MouseButton1Down:Connect(click)

                -- Hover outline
                local function hoverOn()  Tween(tbo2,0.1,{BackgroundColor3=Theme.Accent}) end
                local function hoverOff() Tween(tbo2,0.1,{BackgroundColor3=Theme.OutlineGray}) end
                tbo2.MouseEnter:Connect(hoverOn);  tbo2.MouseLeave:Connect(hoverOff)
                lbl.MouseEnter:Connect(hoverOn);   lbl.MouseLeave:Connect(hoverOff)
                box.MouseEnter:Connect(hoverOn);   box.MouseLeave:Connect(hoverOff)

                -- AddKeybind dans toggle
                function toggle:AddKeybind(kbDef, kbFlag)
                    local kb = {value=kbDef or "None", flag=kbFlag or (text.."_kb")}
                    if kb.flag~="" then KiciaLib.flags[kb.flag]=kb.value end

                    local kbText = KBText(kb.value)
                    local kbSz = GetTextSize(kbText, 13, Theme.Font)

                    local kbBtn = Instance.new("TextButton", rightItems)
                    kbBtn.Font = Theme.Font
                    kbBtn.TextSize = 13
                    kbBtn.TextColor3 = Theme.TextDark
                    kbBtn.BackgroundTransparency = 1
                    kbBtn.Size = UDim2.fromOffset(kbSz.X+4, 14)
                    kbBtn.Text = kbText
                    kbBtn.ZIndex = 10
                    kbBtn.AutoButtonColor = false

                    function kb:Set(v)
                        kb.value = v
                        kbBtn.Text = KBText(v)
                        if kb.flag~="" then KiciaLib.flags[kb.flag]=v end
                    end
                    function kb:Get() return kb.value end

                    kbBtn.MouseButton1Down:Connect(function()
                        kbBtn.Text = "[...]"
                        kbBtn.TextColor3 = Theme.Accent
                    end)
                    UIS.InputBegan:Connect(function(input, gp)
                        if gp then return end
                        if kbBtn.Text=="[...]" then
                            kbBtn.TextColor3 = Theme.TextDark
                            kb:Set(InputToKB(input))
                        elseif InputMatchesKB(input, kb.value) then
                            toggle:Set(not toggle.value)
                        end
                    end)
                    table.insert(KiciaLib.items, kb)
                    return kb
                end

                -- AddColorpicker dans toggle
                function toggle:AddColorpicker(def, cb, cpFlag)
                    return sector:_makeColorpicker(rightItems, def, cb, cpFlag or (text.."_cp"), true)
                end

                -- AddSlider sous le toggle
                function toggle:AddSlider(min, default, max, decimals, callback, flag2)
                    return sector:AddSlider(text, min, default, max, decimals, callback, flag2)
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

                local btnMain = Instance.new("TextButton", sItems)
                btnMain.Name = "button"
                btnMain.BorderSizePixel = 0
                btnMain.Text = ""
                btnMain.AutoButtonColor = false
                btnMain.ZIndex = 8
                btnMain.Size = UDim2.fromOffset(sector._w - 12, 14)
                btnMain.BackgroundColor3 = Color3.fromRGB(255,255,255)

                MakeGradient(btnMain, Theme.ButtonBG, Theme.ButtonBG2)

                -- Triple outline du bouton
                local bbo2 = Instance.new("Frame", btnMain)
                bbo2.ZIndex=7; bbo2.BorderSizePixel=0
                bbo2.BackgroundColor3=Theme.OutlineBlack
                bbo2.Size=btnMain.Size+UDim2.fromOffset(6,6)
                bbo2.Position=UDim2.fromOffset(-3,-3)

                local bbo1 = Instance.new("Frame", btnMain)
                bbo1.ZIndex=6; bbo1.BorderSizePixel=0
                bbo1.BackgroundColor3=Theme.OutlineGray
                bbo1.Size=btnMain.Size+UDim2.fromOffset(4,4)
                bbo1.Position=UDim2.fromOffset(-2,-2)

                local bbo0 = Instance.new("Frame", btnMain)
                bbo0.ZIndex=5; bbo0.BorderSizePixel=0
                bbo0.BackgroundColor3=Theme.OutlineBlack
                bbo0.Size=btnMain.Size+UDim2.fromOffset(2,2)
                bbo0.Position=UDim2.fromOffset(-1,-1)

                local btnLabel = Instance.new("TextLabel", btnMain)
                btnLabel.BackgroundTransparency = 1
                btnLabel.Position = UDim2.new(0,-1,0,0)
                btnLabel.Size = btnMain.Size
                btnLabel.Font = Theme.Font
                btnLabel.Text = text or ""
                btnLabel.TextColor3 = Theme.TextGray
                btnLabel.TextSize = Theme.FontSize
                btnLabel.TextStrokeTransparency = 1
                btnLabel.TextXAlignment = Enum.TextXAlignment.Center
                btnLabel.ZIndex = 9

                -- Hover : outline devient bleu
                bbo2.MouseEnter:Connect(function() Tween(bbo2,0.1,{BackgroundColor3=Theme.Accent}) end)
                bbo2.MouseLeave:Connect(function() Tween(bbo2,0.1,{BackgroundColor3=Theme.OutlineBlack}) end)

                btnMain.MouseButton1Down:Connect(function()
                    Tween(bbo1,0.05,{BackgroundColor3=Theme.Accent})
                    task.delay(0.12, function() Tween(bbo1,0.1,{BackgroundColor3=Theme.OutlineGray}) end)
                    pcall(callback)
                end)

                function btn:SetText(t) btnLabel.Text = t end
                return btn
            end

            -- ==================================================
            -- ADD SLIDER
            -- ==================================================
            function sector:AddSlider(text, min, default, max, decimals, callback, flag)
                local slider = {
                    value    = default or min or 0,
                    min      = min      or 0,
                    max      = max      or 100,
                    decimals = decimals or 1,
                    flag     = flag     or text or "",
                }
                slider.callback = callback or function() end

                local wrap = Instance.new("Frame", sItems)
                wrap.BackgroundTransparency = 1
                wrap.Size = UDim2.fromOffset(sector._w - 12, 25)
                wrap.BorderSizePixel = 0
                wrap.ZIndex = 7

                -- Label + valeur sur la même ligne
                local lbl = Instance.new("TextLabel", wrap)
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.fromOffset(sector._w - 80, 12)
                lbl.Font = Theme.Font
                lbl.Text = text or ""
                lbl.TextColor3 = Theme.TextGray
                lbl.Position = UDim2.fromOffset(0,0)
                lbl.TextSize = Theme.FontSize
                lbl.ZIndex = 8
                lbl.TextStrokeTransparency = 1
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local valLbl = Instance.new("TextLabel", wrap)
                valLbl.BackgroundTransparency = 1
                valLbl.Size = UDim2.fromOffset(sector._w - 12, 12)
                valLbl.Font = Theme.Font
                valLbl.TextColor3 = Theme.TextWhite
                valLbl.Position = UDim2.fromOffset(0,0)
                valLbl.TextSize = Theme.FontSize
                valLbl.ZIndex = 8
                valLbl.TextStrokeTransparency = 1
                valLbl.TextXAlignment = Enum.TextXAlignment.Right

                -- Slider bar (style photo : fond gris avec fill bleu)
                local sliderMain = Instance.new("TextButton", wrap)
                sliderMain.Name = "slider"
                sliderMain.BackgroundColor3 = Color3.fromRGB(255,255,255)
                sliderMain.Position = UDim2.fromOffset(0,14)
                sliderMain.BorderSizePixel = 0
                sliderMain.Size = UDim2.fromOffset(sector._w - 12, 12)
                sliderMain.AutoButtonColor = false
                sliderMain.Text = ""
                sliderMain.ZIndex = 8

                MakeGradient(sliderMain, Color3.fromRGB(49,49,49), Color3.fromRGB(41,41,41))

                -- Triple outline slider
                local sbo2 = Instance.new("Frame", sliderMain)
                sbo2.ZIndex=7; sbo2.BorderSizePixel=0
                sbo2.BackgroundColor3=Theme.OutlineBlack
                sbo2.Size=sliderMain.Size+UDim2.fromOffset(6,6)
                sbo2.Position=UDim2.fromOffset(-3,-3)

                local sbo1 = Instance.new("Frame", sliderMain)
                sbo1.ZIndex=6; sbo1.BorderSizePixel=0
                sbo1.BackgroundColor3=Theme.OutlineGray
                sbo1.Size=sliderMain.Size+UDim2.fromOffset(4,4)
                sbo1.Position=UDim2.fromOffset(-2,-2)

                local sbo0 = Instance.new("Frame", sliderMain)
                sbo0.ZIndex=5; sbo0.BorderSizePixel=0
                sbo0.BackgroundColor3=Theme.OutlineBlack
                sbo0.Size=sliderMain.Size+UDim2.fromOffset(2,2)
                sbo0.Position=UDim2.fromOffset(-1,-1)

                -- Fill bleu
                local fill = Instance.new("Frame", sliderMain)
                fill.BackgroundColor3 = Color3.fromRGB(255,255,255)
                fill.ZIndex = 9
                fill.BorderSizePixel = 0
                fill.Size = UDim2.fromOffset(0, sliderMain.Size.Y.Offset)
                MakeGradient(fill, Theme.Accent, Theme.AccentBright)

                if slider.flag~="" then KiciaLib.flags[slider.flag]=slider.value end

                function slider:Set(v)
                    v = math.clamp(math.floor(v * slider.decimals + 0.5) / slider.decimals, slider.min, slider.max)
                    slider.value = v
                    local pct = (v - slider.min) / (slider.max - slider.min)
                    Tween(fill, 0.05, {Size = UDim2.fromOffset(pct * sliderMain.AbsoluteSize.X, sliderMain.AbsoluteSize.Y)})
                    valLbl.Text = tostring(v).." / "..tostring(slider.max)
                    if slider.flag~="" then KiciaLib.flags[slider.flag]=v end
                    pcall(slider.callback, v)
                end
                function slider:Get() return slider.value end
                slider:Set(slider.value)

                local dragging = false
                local function refresh()
                    local mousePos = Camera:WorldToViewportPoint(Mouse.Hit.p)
                    local pct = math.clamp((mousePos.X - sliderMain.AbsolutePosition.X) / sliderMain.AbsoluteSize.X, 0, 1)
                    local v = slider.min + (slider.max - slider.min) * pct
                    slider:Set(v)
                end

                sliderMain.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; refresh() end
                end)
                sliderMain.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
                end)
                UIS.InputChanged:Connect(function(i)
                    if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then refresh() end
                end)

                sbo2.MouseEnter:Connect(function() Tween(sbo2,0.1,{BackgroundColor3=Theme.Accent}) end)
                sbo2.MouseLeave:Connect(function() Tween(sbo2,0.1,{BackgroundColor3=Theme.OutlineBlack}) end)

                table.insert(KiciaLib.items, slider)
                return slider
            end

            -- ==================================================
            -- ADD DROPDOWN
            -- ==================================================
            function sector:AddDropdown(text, itemsList, default, multi, callback, flag)
                local dd = {values={}, _items=itemsList or {}, multi=multi or false, flag=flag or text or ""}
                dd.callback = callback or function() end

                -- Wrapper
                local ddWrap = Instance.new("Frame", sItems)
                ddWrap.BackgroundTransparency = 1
                ddWrap.Size = UDim2.fromOffset(sector._w - 12, 16)
                ddWrap.BorderSizePixel = 0
                ddWrap.ZIndex = 7

                -- Main frame
                local ddMain = Instance.new("TextButton", ddWrap)
                ddMain.Name = "dropdown"
                ddMain.BackgroundColor3 = Color3.fromRGB(255,255,255)
                ddMain.BorderSizePixel = 0
                ddMain.Size = UDim2.fromOffset(sector._w - 12, 16)
                ddMain.AutoButtonColor = false
                ddMain.Font = Theme.Font
                ddMain.Text = ""
                ddMain.TextSize = Theme.FontSize
                ddMain.TextXAlignment = Enum.TextXAlignment.Left
                ddMain.ZIndex = 8
                MakeGradient(ddMain, Theme.ButtonBG, Theme.ButtonBG2)

                -- Triple outline
                local dbo2 = Instance.new("Frame", ddMain)
                dbo2.ZIndex=7; dbo2.BorderSizePixel=0
                dbo2.BackgroundColor3=Theme.OutlineBlack
                dbo2.Size=ddMain.Size+UDim2.fromOffset(6,6)
                dbo2.Position=UDim2.fromOffset(-3,-3)

                local dbo1 = Instance.new("Frame", ddMain)
                dbo1.ZIndex=6; dbo1.BorderSizePixel=0
                dbo1.BackgroundColor3=Theme.OutlineGray
                dbo1.Size=ddMain.Size+UDim2.fromOffset(4,4)
                dbo1.Position=UDim2.fromOffset(-2,-2)

                local dbo0 = Instance.new("Frame", ddMain)
                dbo0.ZIndex=5; dbo0.BorderSizePixel=0
                dbo0.BackgroundColor3=Theme.OutlineBlack
                dbo0.Size=ddMain.Size+UDim2.fromOffset(2,2)
                dbo0.Position=UDim2.fromOffset(-1,-1)

                -- Selected label
                local selLbl = Instance.new("TextLabel", ddMain)
                selLbl.BackgroundTransparency = 1
                selLbl.Position = UDim2.fromOffset(5,2)
                selLbl.Size = UDim2.fromOffset(sector._w - 38, 13)
                selLbl.Font = Theme.Font
                selLbl.Text = text or ""
                selLbl.ZIndex = 9
                selLbl.TextColor3 = Theme.TextWhite
                selLbl.TextSize = Theme.FontSize
                selLbl.TextStrokeTransparency = 1
                selLbl.TextXAlignment = Enum.TextXAlignment.Left

                -- Arrow icon
                local nav = Instance.new("ImageButton", ddMain)
                nav.Name = "navigation"
                nav.BackgroundTransparency = 1
                nav.Position = UDim2.fromOffset(sector._w - 28, 5)
                nav.Rotation = 90
                nav.ZIndex = 9
                nav.Size = UDim2.fromOffset(8,8)
                nav.Image = "rbxassetid://4918373417"
                nav.ImageColor3 = Theme.TextGray

                -- Items scrollframe (apparait en dessous, ZIndex élevé)
                local itemsFrame = Instance.new("ScrollingFrame", ddMain)
                itemsFrame.Name = "itemsframe"
                itemsFrame.BorderSizePixel = 0
                itemsFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
                itemsFrame.Position = UDim2.fromOffset(0, ddMain.Size.Y.Offset + 8)
                itemsFrame.ScrollBarThickness = 2
                itemsFrame.ZIndex = 15
                itemsFrame.ScrollingDirection = "Y"
                itemsFrame.Visible = false
                itemsFrame.Size = UDim2.new(0,0,0,0)
                itemsFrame.CanvasSize = UDim2.fromScale(0,0)
                itemsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

                MakeListLayout(itemsFrame, Enum.FillDirection.Vertical, 0)
                MakePadding(itemsFrame, 2,2,2,2)

                -- Outlines itemsframe
                local ifbo2 = Instance.new("Frame", ddMain)
                ifbo2.ZIndex=14; ifbo2.BorderSizePixel=0
                ifbo2.BackgroundColor3=Theme.OutlineBlack
                ifbo2.Size=itemsFrame.Size+UDim2.fromOffset(6,6)
                ifbo2.Position=itemsFrame.Position+UDim2.fromOffset(-3,-3)
                ifbo2.Visible=false

                local ifbo1 = Instance.new("Frame", ddMain)
                ifbo1.ZIndex=13; ifbo1.BorderSizePixel=0
                ifbo1.BackgroundColor3=Theme.OutlineGray
                ifbo1.Size=itemsFrame.Size+UDim2.fromOffset(4,4)
                ifbo1.Position=itemsFrame.Position+UDim2.fromOffset(-2,-2)
                ifbo1.Visible=false

                itemsFrame:GetPropertyChangedSignal("Size"):Connect(function()
                    ifbo2.Size=itemsFrame.Size+UDim2.fromOffset(6,6)
                    ifbo1.Size=itemsFrame.Size+UDim2.fromOffset(4,4)
                end)

                if dd.flag~="" then KiciaLib.flags[dd.flag] = dd.multi and {} or "" end

                local function updateText(t)
                    if #t >= 27 then t = t:sub(1,25)..".." end
                    selLbl.Text = t
                end

                function dd:Set(v)
                    if type(v)=="table" then
                        dd.values=v; updateText(table.concat(v,", ")); pcall(dd.callback,v)
                    else
                        updateText(v); dd.values={v}; pcall(dd.callback,v)
                    end
                    if dd.flag~="" then KiciaLib.flags[dd.flag]=dd.multi and dd.values or dd.values[1] end
                end
                function dd:Get() return dd.multi and dd.values or dd.values[1] end
                local function isSel(v)
                    for _,x in pairs(dd.values) do if x==v then return true end end
                    return false
                end

                function dd:Add(v)
                    local item = Instance.new("TextButton", itemsFrame)
                    item.BackgroundColor3 = Color3.fromRGB(40,40,40)
                    item.TextColor3 = Color3.fromRGB(255,255,255)
                    item.BorderSizePixel = 0
                    item.Size = UDim2.fromOffset(ddMain.Size.X.Offset - 4, 20)
                    item.ZIndex = 16
                    item.Text = v
                    item.Name = v
                    item.AutoButtonColor = false
                    item.Font = Theme.Font
                    item.TextSize = Theme.FontSize
                    item.TextXAlignment = Enum.TextXAlignment.Left
                    item.TextStrokeTransparency = 1
                    MakePadding(item, 0,0,6,0)

                    RunService.RenderStepped:Connect(function()
                        if isSel(v) then
                            item.BackgroundColor3 = Color3.fromRGB(55,55,55)
                            item.TextColor3 = Theme.Accent
                        else
                            item.BackgroundColor3 = Color3.fromRGB(40,40,40)
                            item.TextColor3 = Color3.fromRGB(255,255,255)
                        end
                    end)

                    item.MouseButton1Down:Connect(function()
                        if dd.multi then
                            if isSel(v) then
                                for i,x in pairs(dd.values) do if x==v then table.remove(dd.values,i);break end end
                                dd:Set(dd.values)
                            else
                                table.insert(dd.values,v); dd:Set(dd.values)
                            end
                            return
                        end
                        -- Fermer le dropdown
                        nav.Rotation = 90
                        itemsFrame.Visible=false; itemsFrame.Active=false
                        ifbo2.Visible=false; ifbo1.Visible=false
                        Tween(ddWrap, 0.15, {Size=UDim2.fromOffset(sector._w-12, 16)})
                        dd:Set(v)
                        parent.ScrollingEnabled = true
                    end)

                    table.insert(dd._items, v)
                    local h = math.clamp(#dd._items * 20, 20, 156) + 4
                    itemsFrame.Size = UDim2.fromOffset(ddMain.Size.X.Offset, h)
                end

                function dd:Remove(v)
                    local item = itemsFrame:FindFirstChild(v)
                    if item then
                        for i,x in pairs(dd._items) do if x==v then table.remove(dd._items,i);break end end
                        item:Destroy()
                        local h = math.clamp(#dd._items * 20, 20, 156) + 4
                        itemsFrame.Size = UDim2.fromOffset(ddMain.Size.X.Offset, h)
                    end
                end

                local ddOpen = false
                local function toggleDD()
                    ddOpen = not ddOpen
                    if ddOpen then
                        Tween(nav,0.1,{Rotation=-90})
                        itemsFrame.Visible=true; itemsFrame.Active=true
                        ifbo2.Visible=true; ifbo1.Visible=true
                        local h = math.clamp(#dd._items * 20, 20, 156) + 4
                        itemsFrame.Size = UDim2.fromOffset(ddMain.Size.X.Offset, h)
                        Tween(ddWrap, 0.15, {Size=UDim2.fromOffset(sector._w-12, 16 + h + 10)})
                        parent.ScrollingEnabled = false
                    else
                        Tween(nav,0.1,{Rotation=90})
                        itemsFrame.Visible=false; itemsFrame.Active=false
                        ifbo2.Visible=false; ifbo1.Visible=false
                        Tween(ddWrap, 0.15, {Size=UDim2.fromOffset(sector._w-12, 16)})
                        parent.ScrollingEnabled = true
                    end
                end

                ddMain.MouseButton1Down:Connect(toggleDD)
                nav.MouseButton1Down:Connect(toggleDD)
                dbo2.MouseEnter:Connect(function() Tween(dbo2,0.1,{BackgroundColor3=Theme.Accent}) end)
                dbo2.MouseLeave:Connect(function() Tween(dbo2,0.1,{BackgroundColor3=Theme.OutlineBlack}) end)

                -- Populate
                for _,v in pairs(itemsList or {}) do dd:Add(v) end
                if default then dd:Set(default) end

                table.insert(KiciaLib.items, dd)
                return dd
            end

            -- ==================================================
            -- ADD LABEL
            -- ==================================================
            function sector:AddLabel(text, color, centered)
                local row = Instance.new("Frame", sItems)
                row.BackgroundTransparency = 1
                row.Size = UDim2.fromOffset(sector._w - 12, 16)
                row.BorderSizePixel = 0
                row.ZIndex = 7

                local bar = Instance.new("Frame", row)
                bar.Size = UDim2.fromOffset(2, 16)
                bar.BackgroundColor3 = color or Theme.Accent
                bar.BorderSizePixel = 0
                bar.ZIndex = 8

                local lbl = Instance.new("TextLabel", row)
                lbl.BackgroundTransparency = 1
                lbl.Position = UDim2.fromOffset(8, 0)
                lbl.Size = UDim2.fromOffset(sector._w - 22, 16)
                lbl.ZIndex = 8
                lbl.Font = Theme.Font
                lbl.Text = text or ""
                lbl.TextColor3 = color or Theme.TextGray
                lbl.TextSize = Theme.FontSize
                lbl.TextStrokeTransparency = 1
                lbl.TextXAlignment = centered and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
                lbl.TextWrapped = true

                local label = {}
                function label:Set(t)   lbl.Text = tostring(t) end
                function label:Get()    return lbl.Text end
                function label:SetColor(c) lbl.TextColor3=c; bar.BackgroundColor3=c end
                return label
            end

            -- ==================================================
            -- ADD KEYBIND (sector level)
            -- ==================================================
            function sector:AddKeybind(text, default, newKeyCb, callback, flag)
                local kb = {value=default or "None", flag=flag or text or ""}
                kb.callback    = callback   or function() end
                kb.newKeyCb    = newKeyCb   or function() end

                local row = Instance.new("Frame", sItems)
                row.BackgroundTransparency = 1
                row.Size = UDim2.fromOffset(sector._w - 12, 14)
                row.BorderSizePixel = 0
                row.ZIndex = 7

                local lbl = Instance.new("TextLabel", row)
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.fromOffset(sector._w - 80, 14)
                lbl.Font = Theme.Font
                lbl.Text = text or ""
                lbl.TextColor3 = Theme.TextGray
                lbl.TextSize = Theme.FontSize
                lbl.ZIndex = 8
                lbl.TextStrokeTransparency = 1
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local kbBtn = Instance.new("TextButton", row)
                kbBtn.Font = Theme.Font
                kbBtn.TextSize = Theme.FontSize
                kbBtn.TextColor3 = Theme.TextDark
                kbBtn.BackgroundTransparency = 1
                kbBtn.Size = UDim2.fromOffset(80, 14)
                kbBtn.Position = UDim2.new(1, -80, 0, 0)
                kbBtn.Text = KBText(default)
                kbBtn.ZIndex = 8
                kbBtn.AutoButtonColor = false
                kbBtn.TextXAlignment = Enum.TextXAlignment.Right

                if kb.flag~="" then KiciaLib.flags[kb.flag]=kb.value end

                function kb:Set(v)
                    kb.value = v
                    kbBtn.Text = KBText(v)
                    local sz = GetTextSize(kbBtn.Text, Theme.FontSize, Theme.Font)
                    kbBtn.Size = UDim2.fromOffset(sz.X + 4, 14)
                    kbBtn.Position = UDim2.new(1, -(sz.X+6), 0, 0)
                    if kb.flag~="" then KiciaLib.flags[kb.flag]=v end
                    pcall(kb.newKeyCb, v)
                end
                function kb:Get() return kb.value end

                kbBtn.MouseButton1Down:Connect(function()
                    kbBtn.Text = "[...]"
                    kbBtn.TextColor3 = Theme.Accent
                end)
                UIS.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if kbBtn.Text=="[...]" then
                        kbBtn.TextColor3 = Theme.TextDark
                        kb:Set(InputToKB(input))
                    elseif InputMatchesKB(input, kb.value) then
                        pcall(kb.callback)
                    end
                end)

                table.insert(KiciaLib.items, kb)
                return kb
            end

            -- ==================================================
            -- ADD TEXTBOX (sector level)
            -- ==================================================
            function sector:AddTextbox(text, default, callback, flag)
                local tb = {value=default or "", flag=flag or text or ""}
                tb.callback = callback or function() end

                local lbl = Instance.new("TextButton", sItems)
                lbl.AutoButtonColor = false
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.fromOffset(sector._w - 12, 0)
                lbl.Font = Theme.Font
                lbl.ZIndex = 7
                lbl.Text = text
                lbl.TextColor3 = Theme.TextGray
                lbl.TextSize = Theme.FontSize
                lbl.TextStrokeTransparency = 1
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local holder = Instance.new("Frame", sItems)
                holder.ZIndex = 8
                holder.Size = UDim2.fromOffset(sector._w - 12, 14)
                holder.BorderSizePixel = 0
                holder.BackgroundColor3 = Color3.fromRGB(255,255,255)
                MakeGradient(holder, Color3.fromRGB(49,49,49), Color3.fromRGB(39,39,39))

                -- Triple outline holder
                local hbo2=Instance.new("Frame",holder);hbo2.ZIndex=7;hbo2.BorderSizePixel=0
                hbo2.BackgroundColor3=Theme.OutlineBlack;hbo2.Size=holder.Size+UDim2.fromOffset(6,6);hbo2.Position=UDim2.fromOffset(-3,-3)
                local hbo1=Instance.new("Frame",holder);hbo1.ZIndex=6;hbo1.BorderSizePixel=0
                hbo1.BackgroundColor3=Theme.OutlineGray;hbo1.Size=holder.Size+UDim2.fromOffset(4,4);hbo1.Position=UDim2.fromOffset(-2,-2)
                local hbo0=Instance.new("Frame",holder);hbo0.ZIndex=5;hbo0.BorderSizePixel=0
                hbo0.BackgroundColor3=Theme.OutlineBlack;hbo0.Size=holder.Size+UDim2.fromOffset(2,2);hbo0.Position=UDim2.fromOffset(-1,-1)

                local box = Instance.new("TextBox", holder)
                box.PlaceholderText = text
                box.PlaceholderColor3 = Theme.TextDark
                box.Text = default or ""
                box.BackgroundTransparency = 1
                box.Font = Theme.Font
                box.MultiLine = false
                box.ClearTextOnFocus = false
                box.ZIndex = 9
                box.Size = holder.Size
                box.TextSize = Theme.FontSize
                box.TextColor3 = Color3.fromRGB(255,255,255)
                box.BorderSizePixel = 0
                box.TextXAlignment = Enum.TextXAlignment.Left

                if tb.flag~="" then KiciaLib.flags[tb.flag]=tb.value end

                function tb:Set(t) tb.value=t; box.Text=t; if tb.flag~="" then KiciaLib.flags[tb.flag]=t end; pcall(tb.callback,t) end
                function tb:Get() return tb.value end
                box.FocusLost:Connect(function() tb:Set(box.Text) end)

                hbo2.MouseEnter:Connect(function() Tween(hbo2,0.1,{BackgroundColor3=Theme.Accent}) end)
                hbo2.MouseLeave:Connect(function() Tween(hbo2,0.1,{BackgroundColor3=Theme.OutlineBlack}) end)

                table.insert(KiciaLib.items, tb)
                return tb
            end

            -- ==================================================
            -- ADD SEPARATOR
            -- ==================================================
            function sector:AddSeparator(text)
                local sep = Instance.new("Frame", sItems)
                sep.BackgroundTransparency = 1
                sep.Size = UDim2.fromOffset(sector._w - 12, 10)
                sep.ZIndex = 7

                local line = Instance.new("Frame", sep)
                line.BackgroundColor3 = Color3.fromRGB(70,70,70)
                line.BorderSizePixel = 0
                line.Size = UDim2.fromOffset(sector._w - 26, 1)
                line.Position = UDim2.fromOffset(7, 5)
                line.ZIndex = 8

                if text and text~="" then
                    local ts = GetTextSize(text, Theme.FontSize, Theme.Font)
                    local bg = Instance.new("Frame", sep)
                    bg.BackgroundColor3 = Theme.SectorBG
                    bg.Size = UDim2.fromOffset(ts.X + 12, 10)
                    bg.Position = UDim2.new(0.5, -(ts.X/2+6), 0, 0)
                    bg.BorderSizePixel = 0
                    bg.ZIndex = 9

                    local sepLbl = Instance.new("TextLabel", bg)
                    sepLbl.Text = text
                    sepLbl.Font = Theme.Font
                    sepLbl.TextSize = Theme.FontSize
                    sepLbl.TextColor3 = Theme.TextWhite
                    sepLbl.BackgroundTransparency = 1
                    sepLbl.Size = UDim2.fromScale(1,1)
                    sepLbl.ZIndex = 10
                    sepLbl.TextXAlignment = Enum.TextXAlignment.Center
                end
            end

            -- ==================================================
            -- COLORPICKER interne
            -- ==================================================
            function sector:_makeColorpicker(parent, default, callback, flag, compact)
                local cp = {value=default or Color3.fromRGB(255,255,255), flag=flag or "", color=0}
                cp.callback = callback or function() end
                if cp.flag~="" then KiciaLib.flags[cp.flag]=cp.value end

                local swSize = compact and UDim2.fromOffset(16,10) or UDim2.fromOffset(16,10)

                local swatch = Instance.new("TextButton", parent)
                swatch.Size = swSize
                swatch.BackgroundColor3 = cp.value
                swatch.BorderSizePixel = 0
                swatch.Text = ""
                swatch.AutoButtonColor = false
                swatch.ZIndex = 10

                -- Gradient swatch
                local swGrad = Instance.new("UIGradient", swatch)
                swGrad.Rotation = 90
                local function updateSwatchGrad(c)
                    local c2 = Color3.new(math.clamp(c.R/1.7,0,1),math.clamp(c.G/1.7,0,1),math.clamp(c.B/1.7,0,1))
                    swGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,c),ColorSequenceKeypoint.new(1,c2)})
                end
                updateSwatchGrad(cp.value)

                -- Triple outline swatch
                local swbo2=Instance.new("Frame",swatch);swbo2.ZIndex=9;swbo2.BorderSizePixel=0
                swbo2.BackgroundColor3=Theme.OutlineBlack;swbo2.Size=swatch.Size+UDim2.fromOffset(6,6);swbo2.Position=UDim2.fromOffset(-3,-3)
                local swbo1=Instance.new("Frame",swatch);swbo1.ZIndex=8;swbo1.BorderSizePixel=0
                swbo1.BackgroundColor3=Theme.OutlineGray;swbo1.Size=swatch.Size+UDim2.fromOffset(4,4);swbo1.Position=UDim2.fromOffset(-2,-2)

                swbo2.MouseEnter:Connect(function() Tween(swbo2,0.1,{BackgroundColor3=Theme.Accent}) end)
                swbo2.MouseLeave:Connect(function() Tween(swbo2,0.1,{BackgroundColor3=Theme.OutlineBlack}) end)

                -- Picker popup
                local picker = Instance.new("TextButton", gui)
                picker.Size = UDim2.fromOffset(200, 200)
                picker.BackgroundColor3 = Color3.fromRGB(40,40,40)
                picker.BorderSizePixel = 0
                picker.Visible = false
                picker.ZIndex = 100
                picker.Text = ""
                picker.AutoButtonColor = false
                AddOutlines(picker, picker.Size)

                -- Hue canvas
                local canvas = Instance.new("ImageLabel", picker)
                canvas.Image = "rbxassetid://4155801252"
                canvas.Size = UDim2.fromOffset(180, 150)
                canvas.Position = UDim2.fromOffset(10,10)
                canvas.BackgroundColor3 = Color3.new(1,0,0)
                canvas.ZIndex = 102
                canvas.BorderColor3 = Theme.OutlineBlack

                local canvasPtr = Instance.new("ImageLabel", picker)
                canvasPtr.ZIndex = 103
                canvasPtr.BackgroundTransparency = 1
                canvasPtr.BorderSizePixel = 0
                canvasPtr.Size = UDim2.fromOffset(7,7)
                canvasPtr.Position = UDim2.fromOffset(10,10)
                canvasPtr.Image = "rbxassetid://6885856475"

                local hueBar = Instance.new("TextLabel", picker)
                hueBar.Size = UDim2.fromOffset(180, 10)
                hueBar.Position = UDim2.fromOffset(10, 168)
                hueBar.BackgroundColor3 = Color3.new(1,1,1)
                hueBar.Text = ""
                hueBar.ZIndex = 101
                hueBar.BorderColor3 = Theme.OutlineBlack

                local hGrad = Instance.new("UIGradient", hueBar)
                hGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,    Color3.new(1,0,0)),
                    ColorSequenceKeypoint.new(0.17, Color3.new(1,0,1)),
                    ColorSequenceKeypoint.new(0.33, Color3.new(0,0,1)),
                    ColorSequenceKeypoint.new(0.5,  Color3.new(0,1,1)),
                    ColorSequenceKeypoint.new(0.67, Color3.new(0,1,0)),
                    ColorSequenceKeypoint.new(0.83, Color3.new(1,1,0)),
                    ColorSequenceKeypoint.new(1,    Color3.new(1,0,0)),
                })

                local huePtr = Instance.new("Frame", picker)
                huePtr.Size = UDim2.fromOffset(2, 12)
                huePtr.BackgroundColor3 = Color3.new(1,1,1)
                huePtr.BorderSizePixel = 0
                huePtr.ZIndex = 103
                huePtr.Position = UDim2.fromOffset(10, 167)

                function cp:Set(v)
                    local color = Color3.new(math.clamp(v.R,0,1),math.clamp(v.G,0,1),math.clamp(v.B,0,1))
                    cp.value = color
                    swatch.BackgroundColor3 = color
                    updateSwatchGrad(color)
                    if cp.flag~="" then KiciaLib.flags[cp.flag]=color end
                    pcall(cp.callback, color)
                end
                function cp:Get() return cp.value end

                local function refreshCanvas()
                    local x = math.clamp((Mouse.X - canvas.AbsolutePosition.X)/canvas.AbsoluteSize.X, 0, 1)
                    local y = math.clamp((Mouse.Y - canvas.AbsolutePosition.Y)/canvas.AbsoluteSize.Y, 0, 1)
                    canvasPtr:TweenPosition(UDim2.fromOffset(
                        10 + math.clamp(Mouse.X - canvas.AbsolutePosition.X, 0, canvas.AbsoluteSize.X) - 3,
                        10 + math.clamp(Mouse.Y - canvas.AbsolutePosition.Y, 0, canvas.AbsoluteSize.Y) - 3
                    ), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05)
                    cp:Set(Color3.fromHSV(cp.color, x, 1-y))
                end

                local function refreshHue()
                    local x = math.clamp((Mouse.X - hueBar.AbsolutePosition.X)/hueBar.AbsoluteSize.X, 0, 1)
                    cp.color = x
                    canvas.BackgroundColor3 = Color3.fromHSV(x,1,1)
                    huePtr:TweenPosition(UDim2.fromOffset(
                        10 + math.clamp(Mouse.X - hueBar.AbsolutePosition.X, 0, hueBar.AbsoluteSize.X) - 1, 167
                    ), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05)
                    local _,s,v2 = Color3.toHSV(cp.value)
                    cp:Set(Color3.fromHSV(x,s,v2))
                end

                local dragCanvas, dragHue = false, false
                canvas.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragCanvas=true;refreshCanvas() end end)
                canvas.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragCanvas=false end end)
                hueBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragHue=true;refreshHue() end end)
                hueBar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragHue=false end end)
                UIS.InputChanged:Connect(function(i)
                    if i.UserInputType~=Enum.UserInputType.MouseMovement then return end
                    if dragCanvas then refreshCanvas() end
                    if dragHue then refreshHue() end
                end)

                local pickerOpen = false
                swatch.MouseButton1Down:Connect(function()
                    pickerOpen = not pickerOpen
                    picker.Visible = pickerOpen
                    if pickerOpen then
                        local abs = swatch.AbsolutePosition
                        picker.Position = UDim2.fromOffset(abs.X - 185, abs.Y + swatch.AbsoluteSize.Y + 6)
                        picker.Size = UDim2.fromOffset(200, 0)
                        Tween(picker, 0.2, {Size=UDim2.fromOffset(200,200)}, Enum.EasingStyle.Sine)
                    else
                        Tween(picker, 0.15, {Size=UDim2.fromOffset(200,0)})
                        task.delay(0.18, function() picker.Visible=false end)
                    end
                end)

                table.insert(KiciaLib.items, cp)
                return cp
            end

            function sector:AddColorpicker(text, default, callback, flag)
                local row = Instance.new("Frame", sItems)
                row.BackgroundTransparency = 1
                row.Size = UDim2.fromOffset(sector._w - 12, 14)
                row.BorderSizePixel = 0
                row.ZIndex = 7

                local lbl = Instance.new("TextLabel", row)
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.fromOffset(sector._w - 40, 14)
                lbl.Font = Theme.Font
                lbl.Text = text or ""
                lbl.TextColor3 = Theme.TextGray
                lbl.TextSize = Theme.FontSize
                lbl.ZIndex = 8
                lbl.TextStrokeTransparency = 1
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local cpHolder = Instance.new("Frame", row)
                cpHolder.BackgroundTransparency = 1
                cpHolder.Size = UDim2.fromOffset(24, 14)
                cpHolder.Position = UDim2.new(1,-24,0,0)
                cpHolder.ZIndex = 9

                return sector:_makeColorpicker(cpHolder, default, callback, flag, false)
            end

            table.insert(sectorList, sector)
            return sector
        end

        table.insert(window.Tabs, tab)
        return tab
    end

    -- Settings tab auto
    local stab = window:CreateTab("⚙")
    local ssec = stab:CreateSector("Keybind", "left")
    ssec:AddKeybind("Hide / Show", window.HideKey, function(k)
        if k~="None" then window.HideKey = k end
    end, function() end, "_hide_key")

    local csec = stab:CreateSector("Couleurs UI", "right")
    csec:AddColorpicker("Accent", Theme.Accent, function(c)
        Theme.Accent = c
        midLine.BackgroundColor3 = c
        tabLine.BackgroundColor3 = c
    end, "_accent")
    csec:AddColorpicker("Background", Theme.Background, function(c)
        Theme.Background = c
        main.BackgroundColor3 = c
    end, "_bg")

    return window
end
]]

return KiciaLib
