-- ============================================================
--  GAG2 ADDON — Smart Event Detection
-- ============================================================

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- ============================================================
--  STATE
-- ============================================================
local AddonState = {
    StartTime = tick(),
    LastEventTime = 0,
}

-- ============================================================
--  UTILITIES
-- ============================================================
local function FormatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", mins, secs)
end

local function GetEventStatus()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "GoldVFX" then
            local effects = obj:GetAttribute("ActiveWeatherEffects")
            if effects ~= nil then
                return "ACTIVE"
            end
            break
        end
    end
    return "INACTIVE"
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

local EventLbl = Instance.new("TextLabel")
EventLbl.Size = UDim2.new(1, -20, 0, 50)
EventLbl.Position = UDim2.new(0, 10, 0, 60)
EventLbl.BackgroundTransparency = 1
EventLbl.Text = "🌕 Gold: INACTIVE\n🌈 Rainbow: INACTIVE"
EventLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
EventLbl.TextSize = 11
EventLbl.Font = Enum.Font.Gotham
EventLbl.TextXAlignment = Enum.TextXAlignment.Left
EventLbl.TextYAlignment = Enum.TextYAlignment.Top
EventLbl.Parent = Panel

-- ============================================================
--  UPDATE LOOP
-- ============================================================
task.spawn(function()
    while true do
        local elapsed = tick() - AddonState.StartTime
        SessionLbl.Text = "Session: " .. FormatTime(math.floor(elapsed))
        
        local goldStatus = GetEventStatus()
        if goldStatus == "ACTIVE" then
            EventLbl.Text = "🌕 Gold: ACTIVE!\n🌈 Rainbow: INACTIVE"
            EventLbl.TextColor3 = Color3.fromRGB(255, 150, 50)
            AddonState.LastEventTime = tick()
        else
            EventLbl.Text = "🌕 Gold: INACTIVE\n🌈 Rainbow: INACTIVE"
            EventLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        
        task.wait(2)
    end
end)

print("[GAG2 Addon] Event detection loaded!")
