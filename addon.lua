local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local WS = workspace

-- ============================================================
--  STATE
-- ============================================================
local AddonState = {
    StartTime = tick(),
    GoldActive = false,
    RainbowActive = false,
    LastGoldCheck = 0,
    LastRainbowCheck = 0,
}

-- ============================================================
--  UTILITIES
-- ============================================================
local function FormatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", mins, secs)
end

local function IsGoldEventActive()
    for _, obj in ipairs(WS:GetDescendants()) do
        if obj.Name == "GoldVFX" and obj.Parent then
            return true
        end
    end
    return false
end

local function IsRainbowEventActive()
    for _, obj in ipairs(WS:GetDescendants()) do
        if obj.Name == "RainbowVFX" and obj.Parent then
            return true
        end
    end
    return false
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

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 320, 0, 140)
Panel.Position = UDim2.new(1, -340, 0, 20)
Panel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Panel.BorderSizePixel = 0
Panel.Parent = CountdownGui
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(100, 80, 200)
Stroke.Thickness = 2
Stroke.Parent = Panel

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1, 0, 0, 30)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "⏱️  Session Timer"
TitleLbl.TextColor3 = Color3.fromRGB(150, 150, 255)
TitleLbl.TextSize = 14
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.Parent = Panel

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

local GoldLbl = Instance.new("TextLabel")
GoldLbl.Size = UDim2.new(1, -20, 0, 22)
GoldLbl.Position = UDim2.new(0, 10, 0, 60)
GoldLbl.BackgroundTransparency = 1
GoldLbl.Text = "🌕 Goldmoon: Waiting..."
GoldLbl.TextColor3 = Color3.fromRGB(255, 200, 80)
GoldLbl.TextSize = 11
GoldLbl.Font = Enum.Font.Gotham
GoldLbl.TextXAlignment = Enum.TextXAlignment.Left
GoldLbl.Parent = Panel

local RainbowLbl = Instance.new("TextLabel")
RainbowLbl.Size = UDim2.new(1, -20, 0, 22)
RainbowLbl.Position = UDim2.new(0, 10, 0, 85)
RainbowLbl.BackgroundTransparency = 1
RainbowLbl.Text = "🌈 Rainbow: Waiting..."
RainbowLbl.TextColor3 = Color3.fromRGB(100, 200, 255)
RainbowLbl.TextSize = 11
RainbowLbl.Font = Enum.Font.Gotham
RainbowLbl.TextXAlignment = Enum.TextXAlignment.Left
RainbowLbl.Parent = Panel

-- ============================================================
--  UPDATE LOOP
-- ============================================================
task.spawn(function()
    while true do
        local elapsed = tick() - AddonState.StartTime
        SessionLbl.Text = "Session: " .. FormatTime(math.floor(elapsed))
        
        -- Check Gold Event
        local goldActive = IsGoldEventActive()
        if goldActive then
            GoldLbl.Text = "🌕 Goldmoon: ACTIVE!"
            GoldLbl.TextColor3 = Color3.fromRGB(255, 100, 50)
            AddonState.LastGoldCheck = tick()
        else
            local goldTime = tick() - AddonState.LastGoldCheck
            if goldTime < 60 then
                GoldLbl.Text = "🌕 Goldmoon: Just ended!"
                GoldLbl.TextColor3 = Color3.fromRGB(255, 150, 80)
            else
                GoldLbl.Text = "🌕 Goldmoon: Waiting..."
                GoldLbl.TextColor3 = Color3.fromRGB(255, 200, 80)
            end
        end
        
        -- Check Rainbow Event
        local rainbowActive = IsRainbowEventActive()
        if rainbowActive then
            RainbowLbl.Text = "🌈 Rainbow: ACTIVE!"
            RainbowLbl.TextColor3 = Color3.fromRGB(50, 150, 255)
            AddonState.LastRainbowCheck = tick()
        else
            local rainbowTime = tick() - AddonState.LastRainbowCheck
            if rainbowTime < 60 then
                RainbowLbl.Text = "🌈 Rainbow: Just ended!"
                RainbowLbl.TextColor3 = Color3.fromRGB(100, 200, 255)
            else
                RainbowLbl.Text = "🌈 Rainbow: Waiting..."
                RainbowLbl.TextColor3 = Color3.fromRGB(150, 220, 255)
            end
        end
        
        task.wait(1)
    end
end)

print("[GAG2 Addon] Smart timer loaded!")
