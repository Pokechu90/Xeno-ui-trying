--[[
    XenoHub - Universal / AOTR Custom Framework
    Keybind: RightControl to Toggle UI
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- State Variables
local XenoHub = {
    Enabled = true,
    AutoFarm = false,
    AutoRaid = false,
    WalkSpeed = 16,
    JumpPower = 50
}

-- Create Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XenoHubGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -20, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "XenoHub | v1.0"
TitleText.TextColor3 = Color3.fromRGB(130, 170, 255)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 18
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Container for Controls
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -55)
Container.Position = UDim2.new(0, 10, 0, 48)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 4
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = Container

-- Helper Function to Create Toggles
local function CreateToggle(text, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    ToggleFrame.Parent = Container

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 6)
    FrameCorner.Parent = ToggleFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(235, 235, 245)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 60, 0, 26)
    Button.Position = UDim2.new(1, -72, 0.5, -13)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    Button.Text = "OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.Parent = ToggleFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Button

    local toggled = false
    Button.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            Button.Text = "ON"
            Button.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
        else
            Button.Text = "OFF"
            Button.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
        end
        callback(toggled)
    end)
end

-- Helper Function to Create Buttons
local function CreateButton(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(45, 55, 80)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.Parent = Container

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button

    Button.MouseButton1Click:Connect(callback)
end

-- Add Features to XenoHub
CreateToggle("Auto Farm (Mission / Titans)", function(state)
    XenoHub.AutoFarm = state
    print("XenoHub AutoFarm:", state)
end)

CreateToggle("Auto Raid / Wave Clear", function(state)
    XenoHub.AutoRaid = state
    print("XenoHub AutoRaid:", state)
end)

CreateToggle("Speed Boost (WalkSpeed 50)", function(state)
    XenoHub.WalkSpeed = state and 50 or 16
end)

CreateToggle("High Jump (JumpPower 100)", function(state)
    XenoHub.JumpPower = state and 100 or 50
end)

CreateButton("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

-- Main Loop for Character Stats & Farming Logic
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = XenoHub.WalkSpeed
        character.Humanoid.JumpPower = XenoHub.JumpPower
    end

    if XenoHub.AutoFarm then
        -- Insert game-specific target/remote logic here
        -- Example: Locate nearest target in workspace and fire attack remote
    end
end)

-- Toggle GUI Visibility with RightControl
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("XenoHub Loaded Successfully!")
