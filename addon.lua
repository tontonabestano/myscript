-- ============================================================
--  GAG2 ADDON — Countdown Timer Only
-- ============================================================

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

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
local function FormatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", mins, secs)
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
    
    -- Goldmoon at 6 PM (18:00)
    if currentHour >= 18 then
        AddonState.NextGoldmoon = (24 - currentHour) * 3600 + 18 * 3600
    else
        AddonState.NextGoldmoon = (18 - currentHour) * 3600
    end
    
    -- Rainbow at 12 PM (12:00)
    if currentHour >= 12 then
        AddonState.NextRainbow = (24 - currentHour) * 3600 + 12 * 3600
    else
        AddonState.NextRainbow = (12 - currentHour) * 3600
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
--  STARTUP
-- ============================================================
print("[GAG2 Addon] Timer loaded!")
