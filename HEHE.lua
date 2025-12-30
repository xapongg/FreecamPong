-- 🌐 Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Freecam vars
local freecamEnabled = false
local freecamSpeed = 2
local freecamCFrame = camera.CFrame
local freecamStartCFrame = freecamCFrame
local moveVector = Vector3.new()
local rotationY = 0
local rotationSpeed = 90
local ZPressed, CPressed = false, false

-- 🪟 Create main window
local Window = WindUI:CreateWindow({
    Title = "Freecam UI",
    Icon = "camera",
    Folder = "FreecamWindUI",
})

-- 📌 Freecam Tab
local FreecamTab = Window:Tab({
    Title = "Freecam",
    Icon = "camera",
})

-- 🔀 Toggle Freecam
FreecamTab:Toggle({
    Title = "Enable Freecam",
    Desc = "Toggle Freecam mode",
    Icon = "camera",
    Type = "Toggle",
    Value = false,
    Callback = function(state)
        freecamEnabled = state
        if freecamEnabled then
            freecamStartCFrame = camera.CFrame -- simpan posisi awal
            freecamCFrame = freecamStartCFrame
            rotationY = 0
            camera.CameraType = Enum.CameraType.Scriptable
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Anchored = true
            end
        else
            camera.CameraType = Enum.CameraType.Custom
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Anchored = false
            end
            moveVector = Vector3.new()
            ZPressed = false
            CPressed = false
        end
    end
})

-- 🎚 Speed Slider
FreecamTab:Slider({
    Title = "Speed",
    Desc = "Adjust Freecam movement speed",
    Step = 1,
    Value = {
        Min = 1,
        Max = 50,
        Default = freecamSpeed
    },
    Callback = function(value)
        freecamSpeed = value
    end
})

-- 🔁 Reset Camera Button
FreecamTab:Button({
    Title = "Reset Camera",
    Desc = "Return camera to start position",
    Callback = function()
        freecamCFrame = freecamStartCFrame
        rotationY = 0
    end
})

-- 🕹️ Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not freecamEnabled or gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then moveVector = Vector3.new(0,0,-1) end
    if input.KeyCode == Enum.KeyCode.S then moveVector = Vector3.new(0,0,1) end
    if input.KeyCode == Enum.KeyCode.A then moveVector = Vector3.new(-1,0,0) end
    if input.KeyCode == Enum.KeyCode.D then moveVector = Vector3.new(1,0,0) end
    if input.KeyCode == Enum.KeyCode.E then moveVector = Vector3.new(0,1,0) end
    if input.KeyCode == Enum.KeyCode.Q then moveVector = Vector3.new(0,-1,0) end
    if input.KeyCode == Enum.KeyCode.Z then ZPressed = true end
    if input.KeyCode == Enum.KeyCode.C then CPressed = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if not freecamEnabled then return end
    if input.KeyCode == Enum.KeyCode.W
        or input.KeyCode == Enum.KeyCode.S
        or input.KeyCode == Enum.KeyCode.A
        or input.KeyCode == Enum.KeyCode.D
        or input.KeyCode == Enum.KeyCode.E
        or input.KeyCode == Enum.KeyCode.Q then
        moveVector = Vector3.new()
    end
    if input.KeyCode == Enum.KeyCode.Z then ZPressed = false end
    if input.KeyCode == Enum.KeyCode.C then CPressed = false end
end)

-- 🔄 Freecam update loop
RunService.RenderStepped:Connect(function(deltaTime)
    if freecamEnabled then
        if ZPressed then rotationY = rotationY - rotationSpeed * deltaTime end
        if CPressed then rotationY = rotationY + rotationSpeed * deltaTime end

        local rotCFrame = CFrame.Angles(0, math.rad(rotationY), 0)
        local moveDelta = rotCFrame:VectorToWorldSpace(moveVector) * freecamSpeed
        freecamCFrame = freecamCFrame + moveDelta

        camera.CFrame = CFrame.new(freecamCFrame.Position) * rotCFrame
    end
end)
