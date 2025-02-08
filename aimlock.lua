local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Camera = game.Workspace.CurrentCamera

-- 🟣 Tạo giao diện menu
local screenGui = Instance.new("ScreenGui", playerGui)

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 400, 0, 150)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 120)
mainFrame.Visible = false

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -10, 0, 30)
title.Position = UDim2.new(0, 5, 0, 5)
title.Text = "Aimbot Settings"
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255, 200, 255)
title.BackgroundTransparency = 1
title.TextStrokeTransparency = 0.5
title.TextStrokeColor3 = Color3.fromRGB(150, 100, 200)
title.TextScaled = true
title.TextWrapped = true

-- ✅ Nút bật/tắt Aimbot
local aimbotToggle = Instance.new("TextButton", mainFrame)
aimbotToggle.Size = UDim2.new(0, 40, 0, 30)
aimbotToggle.Position = UDim2.new(0, 10, 0, 60)
aimbotToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
aimbotToggle.BorderSizePixel = 1
aimbotToggle.BorderColor3 = Color3.fromRGB(120, 120, 140)
aimbotToggle.Font = Enum.Font.GothamBold
aimbotToggle.TextSize = 14

-- 🛠 Nút đổi phím Aimlock
local keybindButton = Instance.new("TextButton", mainFrame)
keybindButton.Size = UDim2.new(0, 100, 0, 30)
keybindButton.Position = UDim2.new(0, 60, 0, 60)
keybindButton.Text = "🖱 Change Key"
keybindButton.BackgroundColor3 = Color3.fromRGB(90, 90, 110)
keybindButton.Font = Enum.Font.GothamBold
keybindButton.TextSize = 14

-- 🔄 Chế độ Hold/Toggle
local modeButton = Instance.new("TextButton", mainFrame)
modeButton.Size = UDim2.new(0, 100, 0, 30)
modeButton.Position = UDim2.new(0, 170, 0, 60)
modeButton.BackgroundColor3 = Color3.fromRGB(110, 110, 130)
modeButton.Font = Enum.Font.GothamBold
modeButton.TextSize = 14

-- 🎯 Hiển thị tên mục tiêu bị Aimlock
local targetLabel = Instance.new("TextLabel", screenGui)
targetLabel.Size = UDim2.new(0, 200, 0, 30)
targetLabel.Position = UDim2.new(0.5, -100, 0.8, 0)
targetLabel.BackgroundTransparency = 1
targetLabel.Font = Enum.Font.GothamBold
targetLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
targetLabel.TextStrokeTransparency = 0.5
targetLabel.TextStrokeColor3 = Color3.fromRGB(100, 0, 0)
targetLabel.Visible = false

-- 📌 Tải lại cài đặt trước đó nếu có
local aimLockEnabled = player:GetAttribute("AimLockEnabled") or false
local aimLockKey = player:GetAttribute("AimLockKey") or Enum.KeyCode.E
local holdMode = player:GetAttribute("HoldMode") or false
local menuVisible = false
local changingKey = false
local aimTarget = nil

-- 📌 Cập nhật giao diện từ cài đặt
aimbotToggle.Text = aimLockEnabled and "✅" or "❌"
modeButton.Text = holdMode and "🎯 Hold" or "🔁 Toggle"
keybindButton.Text = "🔑 " .. tostring(aimLockKey):gsub("Enum.KeyCode.", "")

-- 📌 Hàm lưu cài đặt
local function saveSettings()
    player:SetAttribute("AimLockEnabled", aimLockEnabled)
    player:SetAttribute("AimLockKey", aimLockKey)
    player:SetAttribute("HoldMode", holdMode)
end

-- 📌 Tìm mục tiêu gần nhất
function findNearestTarget()
    local closest, shortestDistance = nil, math.huge
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = otherPlayer.Character.HumanoidRootPart.Position
            local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
            if onScreen then
                local distance = (Vector2.new(player:GetMouse().X, player:GetMouse().Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closest = otherPlayer.Character
                end
            end
        end
    end

    if closest then
        targetLabel.Text = "🎯 Target: " .. closest.Name
        targetLabel.Visible = true
    else
        targetLabel.Visible = false
    end

    return closest
end

-- 🎮 Xử lý bật/tắt Aimbot
aimbotToggle.MouseButton1Click:Connect(function()
    aimLockEnabled = not aimLockEnabled
    aimbotToggle.Text = aimLockEnabled and "✅" or "❌"
    saveSettings()
end)

-- 🎮 Xử lý thay đổi phím Aimlock
keybindButton.MouseButton1Click:Connect(function()
    keybindButton.Text = "Press Key..."
    changingKey = true
end)

-- 🎮 Xử lý thay đổi chế độ Hold/Toggle
modeButton.MouseButton1Click:Connect(function()
    holdMode = not holdMode
    modeButton.Text = holdMode and "🎯 Hold" or "🔁 Toggle"
    saveSettings()
end)

-- 📌 Nhận phím mới khi người chơi nhấn
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if changingKey then
        aimLockKey = input.KeyCode
        keybindButton.Text = "🔑 " .. tostring(aimLockKey):gsub("Enum.KeyCode.", "")
        changingKey = false
        saveSettings()
        return
    end

    if input.KeyCode == aimLockKey then
        if holdMode then
            aimLockEnabled = true
            aimTarget = findNearestTarget()
        else
            aimLockEnabled = not aimLockEnabled
            aimbotToggle.Text = aimLockEnabled and "✅" or "❌"
            aimTarget = aimLockEnabled and findNearestTarget() or nil
        end
        saveSettings()
    end

    if input.KeyCode == Enum.KeyCode.F4 then
        menuVisible = not menuVisible
        mainFrame.Visible = menuVisible
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if holdMode and input.KeyCode == aimLockKey then
        aimLockEnabled = false
        aimTarget = nil
    end
end)

-- 📌 Cập nhật camera khi Aim Lock bật
RunService.RenderStepped:Connect(function()
    if aimLockEnabled and aimTarget and aimTarget:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimTarget.HumanoidRootPart.Position)
    else
        targetLabel.Visible = false
    end
end)
