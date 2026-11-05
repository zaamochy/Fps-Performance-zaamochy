----------------------------------------------------------------
-- UI (tema glass biru)
----------------------------------------------------------------
local LOGO_ID = "rbxassetid://102535739463149"

local Gui = Instance.new("ScreenGui")
Gui.Name = "FPSPerformance"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset = true
pcall(function() if syn and syn.protect_gui then syn.protect_gui(Gui) end end)
Gui.Parent = getParent()
pcall(function() if getgenv then getgenv().FPSPerfGui = Gui end end)

local WHITE = Color3.new(1, 1, 1)
local BLUE = Color3.fromRGB(37, 99, 235)
local LIGHT = Color3.fromRGB(96, 165, 250)
local SUB = Color3.fromRGB(170, 195, 240)

local function corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = o
end

local function stroke(o, color, t, tr)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = t
    s.Transparency = tr or 0
    s.Parent = o
    return s
end

local function gradient(o, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rot or 90
    g.Parent = o
    return g
end

-- efek "glass": fill gradient transparan + border tipis
local function glass(f, c1, c2, transp)
    f.BackgroundColor3 = WHITE
    f.BackgroundTransparency = transp
    f.BorderSizePixel = 0
    return gradient(f, c1, c2, 90)
end

local function label(parent, text, size, color, font, pos, sz, align)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextSize = size
    l.TextColor3 = color
    l.Font = font or Enum.Font.GothamMedium
    l.Position = pos
    l.Size = sz
    l.TextXAlignment = align or Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function makeDraggable(handle, target)
    local dragging, start, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            start = i.Position
            startPos = target.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - start
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- Logo cadangan (blue hole dari UI) kalau gambar gagal dimuat
local spinList = {}
local function makeBlueHole(parent, size, pos)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.fromOffset(size, size)
    holder.Position = pos
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local function circle(scale, color, transp)
        local f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.Position = UDim2.fromScale(0.5, 0.5)
        f.Size = UDim2.fromScale(scale, scale)
        f.BackgroundColor3 = color
        f.BackgroundTransparency = transp or 0
        f.BorderSizePixel = 0
        f.Parent = holder
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0.5, 0)
        c.Parent = f
        return f
    end

    local function spin(frame, seq, speed)
        local g = Instance.new("UIGradient")
        g.Color = seq
        g.Parent = frame
        spinList[#spinList + 1] = { g = g, speed = speed }
    end

    circle(1, Color3.fromRGB(56, 140, 255), 0.65)
    local ring = circle(0.92, WHITE)
    spin(ring, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 211, 238)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(37, 99, 235)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(124, 58, 237)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(34, 211, 238)),
    }), 140)
    local ring2 = circle(0.7, WHITE)
    spin(ring2, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 20, 70)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(96, 165, 250)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 20, 70)),
    }), -220)
    local core = circle(0.46, Color3.fromRGB(0, 0, 8))
    stroke(core, Color3.fromRGB(147, 197, 253), 1.2, 0.3)
    return holder
end

local spinConn = RunService.RenderStepped:Connect(function(dt)
    for _, s in ipairs(spinList) do
        s.g.Rotation = (s.g.Rotation + s.speed * dt) % 360
    end
end)

-- Logo utama: pakai gambar dari ID, fallback ke blue hole buatan
local function makeLogo(parent, size, pos)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.fromOffset(size, size)
    holder.Position = pos
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local fallback = makeBlueHole(holder, size, UDim2.new())
    fallback.Visible = false

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.fromScale(1, 1)
    img.BackgroundTransparency = 1
    img.Image = LOGO_ID
    img.ScaleType = Enum.ScaleType.Fit
    img.Parent = holder

    task.spawn(function()
        local t = 0
        while not img.IsLoaded and t < 4 do
            task.wait(0.1)
            t += 0.1
        end
        if not img.IsLoaded then fallback.Visible = true end
    end)
    return holder
end

----------------------------------------------------------------
-- Jendela utama
----------------------------------------------------------------
local Window = Instance.new("Frame") -- lapisan glow luar
Window.Name = "Window"
Window.AnchorPoint = Vector2.new(0.5, 0.5)
Window.Position = UDim2.fromScale(0.5, 0.5)
Window.Size = UDim2.fromOffset(372, 338)
Window.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
Window.BackgroundTransparency = 0.85
Window.BorderSizePixel = 0
Window.Parent = Gui
corner(Window, 34)

local uiScale = Instance.new("UIScale")
uiScale.Parent = Window
local function fit()
    local cam = workspace.CurrentCamera
    if cam then
        uiScale.Scale = math.clamp(cam.ViewportSize.Y / 400, 0.6, 1)
    end
end
fit()

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(360, 326)
Main.Position = UDim2.fromOffset(6, 6)
Main.Parent = Window
glass(Main, Color3.fromRGB(88, 135, 230), Color3.fromRGB(22, 44, 120), 0.3)
corner(Main, 28)
local mStroke = stroke(Main, WHITE, 2, 0.1)
gradient(mStroke, Color3.fromRGB(150, 200, 255), Color3.fromRGB(60, 110, 230), 90)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundTransparency = 1
Header.Parent = Main
makeDraggable(Header, Window)

makeLogo(Header, 44, UDim2.fromOffset(10, 4))

local vdiv = Instance.new("Frame")
vdiv.Size = UDim2.fromOffset(1, 32)
vdiv.Position = UDim2.fromOffset(62, 10)
vdiv.BackgroundColor3 = WHITE
vdiv.BackgroundTransparency = 0.82
vdiv.BorderSizePixel = 0
vdiv.Parent = Header

label(Header, "FPS Performance", 17, WHITE, Enum.Font.GothamBold,
    UDim2.fromOffset(72, 6), UDim2.fromOffset(170, 22))
label(Header, "by zaamochy", 12, SUB, Enum.Font.Gotham,
    UDim2.fromOffset(72, 28), UDim2.fromOffset(170, 16))

local function headBtn(txt, x)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(26, 26)
    b.Position = UDim2.new(1, x, 0, 13)
    b.Text = txt
    b.TextColor3 = WHITE
    b.TextSize = 18
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = true
    b.Parent = Header
    glass(b, Color3.fromRGB(110, 150, 235), Color3.fromRGB(40, 70, 160), 0.45)
    corner(b, 13)
    stroke(b, WHITE, 1, 0.75)
    return b
end
local MinBtn = headBtn("–", -66)
local CloseBtn = headBtn("×", -34)

local hline = Instance.new("Frame")
hline.Size = UDim2.new(1, -28, 0, 1)
hline.Position = UDim2.fromOffset(14, 52)
hline.BackgroundColor3 = WHITE
hline.BackgroundTransparency = 0.85
hline.BorderSizePixel = 0
hline.Parent = Main

-- Tab bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -24, 0, 32)
TabBar.Position = UDim2.fromOffset(12, 60)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Main
local tl = Instance.new("UIListLayout")
tl.FillDirection = Enum.FillDirection.Horizontal
tl.Padding = UDim.new(0, 6)
tl.Parent = TabBar

-- Area halaman
local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, -24, 0, 182)
Body.Position = UDim2.fromOffset(12, 100)
Body.BackgroundTransparency = 1
Body.ClipsDescendants = true
Body.Parent = Main

local pages, tabs = {}, {}

local function newPage(name)
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.fromScale(1, 1)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 2
    p.ScrollBarImageColor3 = LIGHT
    p.CanvasSize = UDim2.new()
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.Visible = false
    p.Parent = Body
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 4)
    l.Parent = p
    pages[name] = p
    return p
end

local ACTIVE1, ACTIVE2 = Color3.fromRGB(70, 150, 255), Color3.fromRGB(30, 80, 220)
local IDLE1, IDLE2 = Color3.fromRGB(40, 62, 130), Color3.fromRGB(14, 26, 70)

local function selectTab(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, t in pairs(tabs) do
        local on = (n == name)
        t.btn.BackgroundTransparency = on and 0 or 0.35
        t.grad.Color = ColorSequence.new(on and ACTIVE1 or IDLE1, on and ACTIVE2 or IDLE2)
        t.stroke.Color = on and Color3.fromRGB(160, 205, 255) or Color3.fromRGB(120, 150, 220)
        t.stroke.Transparency = on and 0.05 or 0.75
        t.stroke.Thickness = on and 1.6 or 1
    end
end

local function newTab(name, text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1 / 3, -4, 1, 0)
    b.Text = text
    b.TextColor3 = WHITE
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.Parent = TabBar
    local g = glass(b, IDLE1, IDLE2, 0.35)
    corner(b, 16)
    local s = stroke(b, WHITE, 1, 0.75)
    tabs[name] = { btn = b, grad = g, stroke = s }
    b.Activated:Connect(function() selectTab(name) end)
    newPage(name)
end

newTab("Combat", "⚔ Combat")
newTab("Rendering", "🖥 Rendering")
newTab("Misc", "⚙ Misc")

-- Baris toggle
local ON1, ON2 = Color3.fromRGB(90, 170, 255), Color3.fromRGB(30, 90, 235)
local OFF1, OFF2 = Color3.fromRGB(75, 85, 120), Color3.fromRGB(50, 58, 90)

local function addRow(page, icon, title, desc, onFn, offFn)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 42)
    row.Parent = page
    glass(row, Color3.fromRGB(60, 85, 160), Color3.fromRGB(20, 34, 85), 0.5)
    corner(row, 14)
    stroke(row, WHITE, 1, 0.88)

    label(row, icon, 20, WHITE, Enum.Font.GothamMedium,
        UDim2.fromOffset(6, 0), UDim2.fromOffset(34, 42), Enum.TextXAlignment.Center)
    label(row, title, 14, WHITE, Enum.Font.GothamBold,
        UDim2.fromOffset(46, 4), UDim2.new(1, -110, 0, 18))
    label(row, desc, 11, SUB, Enum.Font.Gotham,
        UDim2.fromOffset(46, 22), UDim2.new(1, -110, 0, 15))

    local sw = Instance.new("TextButton")
    sw.Size = UDim2.fromOffset(44, 24)
    sw.Position = UDim2.new(1, -54, 0.5, -12)
    sw.Text = ""
    sw.AutoButtonColor = false
    sw.Parent = row
    local sg = glass(sw, OFF1, OFF2, 0)
    corner(sw, 12)
    local sstroke = stroke(sw, LIGHT, 1.2, 1)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18, 18)
    knob.Position = UDim2.fromOffset(3, 3)
    knob.BackgroundColor3 = WHITE
    knob.BorderSizePixel = 0
    knob.Parent = sw
    corner(knob, 9)

    local state = false
    local function set(v)
        if v == state then return end
        state = v
        sg.Color = ColorSequence.new(v and ON1 or OFF1, v and ON2 or OFF2)
        sstroke.Transparency = v and 0.3 or 1
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = v and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
        }):Play()
        task.spawn(function() pcall(v and onFn or offFn) end)
    end
    sw.Activated:Connect(function() set(not state) end)
    return set
end

local setters = {}
local C, R, M = pages.Combat, pages.Rendering, pages.Misc

setters[#setters + 1] = addRow(C, "☀", "Full Bright", "Make the game brighter",
    Features.FullBright.on, Features.FullBright.off)
setters[#setters + 1] = addRow(C, "🌫", "No Fog", "Remove fog effect",
    Features.NoFog.on, Features.NoFog.off)
setters[#setters + 1] = addRow(C, "◐", "No Shadow", "Disable shadows",
    Features.NoShadow.on, Features.NoShadow.off)
setters[#setters + 1] = addRow(C, "🎨", "Low Grafik", "Reduce graphic quality",
    Features.LowGrafik.on, Features.LowGrafik.off)

setters[#setters + 1] = addRow(R, "🧱", "Material Polos", "Remove textures, plain look",
    Features.PlainMaterial.on, Features.PlainMaterial.off)
setters[#setters + 1] = addRow(R, "✨", "No Efek", "Disable particles, effects & decals",
    Features.NoEffects.on, Features.NoEffects.off)

-- FPS & Ping counter (tengah atas, bisa digeser)
local Counter = Instance.new("Frame")
Counter.AnchorPoint = Vector2.new(0.5, 0)
Counter.Size = UDim2.fromOffset(160, 32)
Counter.Position = UDim2.new(0.5, 0, 0, 8)
Counter.Visible = false
Counter.Parent = Gui
glass(Counter, Color3.fromRGB(40, 80, 170), Color3.fromRGB(10, 22, 65), 0.25)
corner(Counter, 16)
local cStroke = stroke(Counter, WHITE, 1.4, 0.15)
do
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(Color3.fromRGB(34, 211, 238), Color3.fromRGB(139, 92, 246))
    g.Parent = cStroke
end
local CounterText = label(Counter, "-- FPS | --ms", 15, WHITE, Enum.Font.GothamBold,
    UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Enum.TextXAlignment.Center)
CounterText.RichText = true
makeDraggable(Counter, Counter)

local counterConn
local function counterOn()
    Counter.Visible = true
    local frames, t0 = 0, os.clock()
    counterConn = RunService.RenderStepped:Connect(function()
        frames += 1
        local now = os.clock()
        if now - t0 >= 0.5 then
            local fps = math.floor(frames / (now - t0) + 0.5)
            local ping = 0
            pcall(function()
                ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
            end)
            CounterText.Text = string.format(
                '<font color="#22D3EE">%d FPS</font> <font color="#FFFFFF">|</font> <font color="#A78BFA">%dms</font>',
                fps, ping)
            frames, t0 = 0, now
        end
    end)
end
local function counterOff()
    Counter.Visible = false
    if counterConn then counterConn:Disconnect() end
end

setters[#setters + 1] = addRow(M, "📊", "FPS & Ping", "Show counter at top center", counterOn, counterOff)
setters[#setters + 1] = addRow(M, "🛡", "Anti AFK", "Prevent idle kick",
    Features.AntiAFK.on, Features.AntiAFK.off)

-- Footer
local fline = Instance.new("Frame")
fline.Size = UDim2.new(1, -28, 0, 1)
fline.Position = UDim2.fromOffset(14, 289)
fline.BackgroundColor3 = WHITE
fline.BackgroundTransparency = 0.85
fline.BorderSizePixel = 0
fline.Parent = Main

local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 34)
Footer.Position = UDim2.new(0, 0, 1, -36)
Footer.BackgroundTransparency = 1
Footer.Parent = Main

-- ikon bar chart
for i, h in ipairs({ 8, 13, 18 }) do
    local bar = Instance.new("Frame")
    bar.Size = UDim2.fromOffset(4, h)
    bar.Position = UDim2.fromOffset(16 + (i - 1) * 6, 26 - h)
    bar.BackgroundColor3 = LIGHT
    bar.BorderSizePixel = 0
    bar.Parent = Footer
    corner(bar, 2)
end

local ft = label(Footer, "<i>Optimized for maximum FPS</i>", 11, SUB, Enum.Font.Gotham,
    UDim2.fromOffset(44, 0), UDim2.fromOffset(170, 34))
ft.RichText = true

local fdiv = Instance.new("Frame")
fdiv.Size = UDim2.fromOffset(1, 22)
fdiv.Position = UDim2.fromOffset(222, 6)
fdiv.BackgroundColor3 = WHITE
fdiv.BackgroundTransparency = 0.82
fdiv.BorderSizePixel = 0
fdiv.Parent = Footer

local Tag = Instance.new("Frame")
Tag.Size = UDim2.fromOffset(110, 26)
Tag.Position = UDim2.new(1, -120, 0, 4)
Tag.Parent = Footer
glass(Tag, Color3.fromRGB(40, 70, 150), Color3.fromRGB(10, 20, 60), 0.3)
corner(Tag, 13)
stroke(Tag, LIGHT, 1, 0.6)
makeLogo(Tag, 20, UDim2.fromOffset(6, 3))
local tagText = label(Tag, 'by <font color="#60A5FA">zaamochy</font>', 12, WHITE,
    Enum.Font.GothamBold, UDim2.fromOffset(30, 0), UDim2.new(1, -32, 1, 0))
tagText.RichText = true

-- Tombol buka/tutup menu (kotak glass dengan logo)
local Orb = Instance.new("TextButton")
Orb.Size = UDim2.fromOffset(48, 48)
Orb.Position = UDim2.new(1, -64, 0.4, 0)
Orb.Text = ""
Orb.AutoButtonColor = false
Orb.Parent = Gui
glass(Orb, Color3.fromRGB(30, 60, 140), Color3.fromRGB(6, 12, 40), 0.15)
corner(Orb, 14)
stroke(Orb, Color3.fromRGB(100, 160, 255), 2, 0.1)
makeLogo(Orb, 40, UDim2.fromOffset(4, 4))
makeDraggable(Orb, Orb)
Orb.Activated:Connect(function() Window.Visible = not Window.Visible end)
MinBtn.Activated:Connect(function() Window.Visible = false end)

CloseBtn.Activated:Connect(function()
    for _, s in ipairs(setters) do pcall(s, false) end
    spinConn:Disconnect()
    task.wait(0.3)
    Gui:Destroy()
end)

selectTab("Combat")
