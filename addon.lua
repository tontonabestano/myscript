-- ============================================================
--  GAG2 ADDON — Countdown Timer + No-Teleport Harvest/Sell
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- ============================================================
--  CONFIG
-- ============================================================
local ADDON_CONFIG = {
    GoldmoonHour = 18,      -- When goldmoon starts (6 PM)
    RainbowHour = 12,       -- When rainbow starts (12 PM / Noon)
    EventDuration = 180,    -- How long each event lasts (seconds)
}

-- ============================================================
--  STATE
-- ============================================================
local AddonState = {
    TimerActive = false,
    StartTime = 0,
    NextGoldmoon = 0,
    NextRainbow = 0,
}

-- ============================================================
--  UTILITIES
-- ============================================================
local function GetRemote(name)
    local rs = ReplicatedStorage:FindFirstChild("Remotes")
        or ReplicatedStorage:FindFirstChild("Events")
        or ReplicatedStorage
    return rs and rs:FindFirstChild(name, true)
end

local function FormatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", mins, secs)
end

-- ============================================================
--  NO-TELEPORT AUTO HARVEST (stay in place)
-- ============================================================
local function DoAutoHarvestNoTeleport()
    local remote = GetRemote("Harvest") or GetRemote("HarvestCrop")
    if not remote then return end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj:HasTag("Harvestable") or obj.Name:lower():find("crop")) then
            -- Fire remote without teleporting
            pcall(function()
                remote:FireServer(obj)
            end)
            task.wait(0.05)
        end
    end
end

-- ============================================================
--  NO-TELEPORT AUTO SELL (stay in place)
-- ============================================================
local function DoAutoSellNoTeleport()
    local remote = GetRemote("SellCrops") or GetRemote("Sell")
    if not remote then return end
    
    pcall(function()
        remote:FireServer()
    end)
end

-- ============================================================
--  COUNTDOWN TIMER GUI
-- ============================================================
if PG:FindFirstChild("CountdownGui") then
    PG.CountdownGui:Destroy()
end

local CountdownGui = Instance.new("ScreenGui")
CountdownGui.Name = "CountdownGui"
CountdownGui.ResetOnSpawn = false
CountdownGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
CountdownGui.Parent = PG

-- Background panel
local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 320, 0, 140)
Panel.Position = UDim2.new(1, -340, 0, 20)  -- Top right
Panel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Panel.BorderSizePixel = 0
Panel.Parent = CountdownGui
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(100, 80, 200)
Stroke.Thickness = 2
Stroke.Parent = Panel

-- Title
local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1, 0, 0, 30)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "⏱️  Session Timer"
TitleLbl.TextColor3 = Color3.fromRGB(150, 150, 255)
TitleLbl.TextSize = 14
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.Parent = Panel

-- Session elapsed time
local SessionLbl = Instance.new("TextLabel")
SessionLbl.Size = UDim2.new(1, -20, 0, 25)
SessionLbl.Position = UDim2.new(0, 10, 0, 32)
SessionLbl.BackgroundTransparency = 1
SessionLbl.Text = "Session: 00:00"
SessionLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
SessionLbl.TextSize = 12
SessionLbl.Font = Enum.Font.Gotham
SessionLbl.TextXAlignment = Enum.TextXAlignment.Left
SessionLbl.Parent = Panel

-- Goldmoon countdown
local GoldLbl = Instance.new("TextLabel")
GoldLbl.Size = UDim2.new(1, -20, 0, 22)
GoldLbl.Position = UDim2.new(0, 10, 0, 60)
GoldLbl.BackgroundTransparency = 1
GoldLbl.Text = "🌕 Goldmoon: --:--"
GoldLbl.TextColor3 = Color3.fromRGB(255, 200, 80)
GoldLbl.TextSize = 11
GoldLbl.Font = Enum.Font.Gotham
GoldLbl.TextXAlignment = Enum.TextXAlignment.Left
GoldLbl.Parent = Panel

-- Rainbow countdown
local RainbowLbl = Instance.new("TextLabel")
RainbowLbl.Size = UDim2.new(1, -20, 0, 22)
RainbowLbl.Position = UDim2.new(0, 10, 0, 85)
RainbowLbl.BackgroundTransparency = 1
RainbowLbl.Text = "🌈 Rainbow: --:--"
RainbowLbl.TextColor3 = Color3.fromRGB(100, 200, 255)
RainbowLbl.TextSize = 11
RainbowLbl.Font = Enum.Font.Gotham
RainbowLbl.TextXAlignment = Enum.TextXAlignment.Left
RainbowLbl.Parent = Panel

-- ============================================================
--  CALCULATE NEXT EVENT TIMES
-- ============================================================
local function CalcNextEvents()
    local lighting = game:GetService("Lighting")
    local currentHour = lighting.ClockTime
    
    -- Calculate Goldmoon (6 PM)
    if currentHour >= ADDON_CONFIG.GoldmoonHour then
        AddonState.NextGoldmoon = (24 - currentHour) * 3600 + ADDON_CONFIG.GoldmoonHour * 3600
    else
        AddonState.NextGoldmoon = (ADDON_CONFIG.GoldmoonHour - currentHour) * 3600
    end
    
    -- Calculate Rainbow (12 PM)
    if currentHour >= ADDON_CONFIG.RainbowHour then
        AddonState.NextRainbow = (24 - currentHour) * 3600 + ADDON_CONFIG.RainbowHour * 3600
    else
        AddonState.NextRainbow = (ADDON_CONFIG.RainbowHour - currentHour) * 3600
    end
end

-- ============================================================
--  UPDATE LOOP
-- ============================================================
task.spawn(function()
    AddonState.TimerActive = true
    AddonState.StartTime = tick()
    CalcNextEvents()
    
    while AddonState.TimerActive do
        local elapsed = tick() - AddonState.StartTime
        
        -- Update session time
        SessionLbl.Text = "Session: " .. FormatTime(math.floor(elapsed))
        
        -- Update event countdowns
        local goldCountdown = AddonState.NextGoldmoon - elapsed
        local rainbowCountdown = AddonState.NextRainbow - elapsed
        
        if goldCountdown > 0 then
            GoldLbl.Text = "🌕 Goldmoon: " .. FormatTime(math.floor(goldCountdown))
            GoldLbl.TextColor3 = Color3.fromRGB(255, 200, 80)
        else
            GoldLbl.Text = "🌕 Goldmoon: ACTIVE!"
            GoldLbl.TextColor3 = Color3.fromRGB(255, 100, 50)
        end
        
        if rainbowCountdown > 0 then
            RainbowLbl.Text = "🌈 Rainbow: " .. FormatTime(math.floor(rainbowCountdown))
            RainbowLbl.TextColor3 = Color3.fromRGB(100, 200, 255)
        else
            RainbowLbl.Text = "🌈 Rainbow: ACTIVE!"
            RainbowLbl.TextColor3 = Color3.fromRGB(50, 150, 255)
        end
        
        task.wait(1)
    end
end)

-- ============================================================
--  AUTO HARVEST / SELL LOOP (no teleport)
-- ============================================================
task.spawn(function()
    while true do
        pcall(function()
            DoAutoHarvestNoTeleport()
            task.wait(2)
            DoAutoSellNoTeleport()
        end)
        task.wait(3)
    end
end)

-- ============================================================
--  STARTUP
-- ============================================================
print("[GAG2 Addon] Loaded — Timer + No-Teleport Harvest/Sell active!")
```
