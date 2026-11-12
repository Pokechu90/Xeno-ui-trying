-- =============================================================================
-- XENOHUB ULTIMATE EDITION V5 (KEYLESS) - UI REWORK
-- Target Game: Attack on Titan Revolution (AOT:R)
-- =============================================================================

if getgenv().XenoHub_Loaded then
    print("[XenoHub]: Framework is already active in this server context.")
    return
end
getgenv().XenoHub_Loaded = true

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local ORION_URL = "https://raw.githubusercontent.com/shlexware/Orion/main/source"
local FolderName = "XenoHub_Configs"
local DefaultConfigName = "DefaultProfile.json"

local HasFS = isfolder and makefolder and isfile and readfile and writefile

-- =============================================================================
-- CONFIG
-- =============================================================================
local function NewDefaults()
    return {
        WebhookURL = "",
        AutoLoad = true,

        -- UI
        ActiveTheme = "Black & Yellow",
        UITransparency = 0,        -- 0 = opaque window, 0.9 = almost invisible
        OutlineTransparent = false, -- false = opaque outline, true = invisible outline
        OutlineThickness = 2,

        AutoFarmTitans = false, ManualFarmMode = false, FarmMethod = "Behind Nape", TweenSpeed = 65,
        NapeExtender = false, NapeSize = 15, BladeMultiHit = 8, SpearMultiHit = 6,
        BossBurst = false, BossBurstHits = 10, AutoEscapeGrab = false,
        AutoLaunchMission = false, SelectedMap = "Shigu Shina", SelectedDifficulty = "Normal",
        Mod_Fatigue = false, Mod_Injuries = false, Mod_Evolution = false,
        AutoRaidMode = false, SelectedRaid = "Attack",
        AutoWavesMode = false, TitansPerSwing = 5, AutoUpgradeStats = false,
        AutoSkillTree = false, AutoPrestige = false, AutoUpgradeGear = false,
        AdaptiveBuilds = false, TargetRoutine = "Offense Overload",
        AutoOpenPremiumChest = false, AutoOpenFreeChest = false, AutoRefillResources = true,
        UseThunderSpears = false, AutoClaimAchievements = false,
        PlayerESP = false, TitanESP = false, NapeESP = false,
    }
end

getgenv().XenoHub_Config = NewDefaults()
local Cfg = getgenv().XenoHub_Config

-- =============================================================================
-- THEMES
-- =============================================================================
local ThemeProfiles = {
    ["Black & Yellow"] = {
        Background = Color3.fromRGB(10, 10, 10),
        Accent = Color3.fromRGB(255, 215, 0),
        Text = Color3.fromRGB(255, 255, 255),
    },
    ["Total Dark"] = {
        Background = Color3.fromRGB(0, 0, 0),
        Accent = Color3.fromRGB(90, 90, 90),
        Text = Color3.fromRGB(210, 210, 210),
    },
    ["Cyber Glow"] = {
        Background = Color3.fromRGB(5, 8, 15),
        Accent = Color3.fromRGB(0, 255, 200),
        Text = Color3.fromRGB(240, 255, 255),
    },
}

local OriginalTransparency = setmetatable({}, { __mode = "k" })

local function GetOrionGui()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui and hui:FindFirstChild("Orion") then return hui.Orion end
    end
    return CoreGui:FindFirstChild("Orion")
end

-- The main window is the biggest Frame directly under the ScreenGui.
local function GetMainWindow(gui)
    local best, bestArea = nil, 0
    for _, child in ipairs(gui:GetChildren()) do
        if child:IsA("Frame") then
            local area = child.AbsoluteSize.X * child.AbsoluteSize.Y
            if area > bestArea then best, bestArea = child, area end
        end
    end
    return best
end

local function UpdateUIAppearance()
    local theme = ThemeProfiles[Cfg.ActiveTheme] or ThemeProfiles["Black & Yellow"]
    local gui = GetOrionGui()
    if not gui then return end
    local main = GetMainWindow(gui)

    -- Window transparency: scale from each frame's ORIGINAL value so that
    -- frames which were invisible by design never become visible.
    for _, obj in ipairs(gui:GetDescendants()) do
        pcall(function()
            if obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
                if OriginalTransparency[obj] == nil then
                    OriginalTransparency[obj] = obj.BackgroundTransparency
                end
                local base = OriginalTransparency[obj]
                obj.BackgroundTransparency = base + (1 - base) * Cfg.UITransparency
            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
                obj.TextColor3 = theme.Text
            end
        end)
    end

    if not main then return end
    pcall(function() main.BackgroundColor3 = theme.Background end)

    -- Black & yellow outline (stroke + gradient), opaque or transparent
    local stroke = main:FindFirstChild("XenoOutline")
    if not stroke then
        stroke = Instance.new("UIStroke")
        stroke.Name = "XenoOutline"
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = main
        local grad = Instance.new("UIGradient")
        grad.Name = "XenoGradient"
        grad.Parent = stroke
    end
    stroke.Thickness = Cfg.OutlineThickness
    stroke.Color = theme.Accent
    stroke.Transparency = Cfg.OutlineTransparent and 1 or 0
    stroke.Enabled = true
    stroke.XenoGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.Accent),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, theme.Accent),
    })
end

-- =============================================================================
-- WEBHOOK
-- =============================================================================
local function SendXenoWebhook(title, description, color)
    local url = Cfg.WebhookURL
    if not url or url == "" then return end

    local payload = HttpService:JSONEncode({
        username = "XenoHub Drone Logs",
        embeds = {{
            title = "XenoHub Notification - " .. (title or "System Log"),
            description = description or "No data.",
            color = color or 65280,
            footer = { text = "XenoHub V5 | " .. os.date("%X") },
        }},
    })

    task.spawn(function()
        local req = (syn and syn.request) or request or http_request
        if req then
            pcall(req, { Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = payload })
        end
    end)
end

-- =============================================================================
-- CONFIG FILES
-- =============================================================================
if HasFS and not isfolder(FolderName) then makefolder(FolderName) end

local function ApplyConfigData(data)
    if type(data) ~= "table" then return end
    for k, v in pairs(data) do Cfg[k] = v end
    UpdateUIAppearance()
end

local function SaveConfig(fileName)
    if not HasFS or not fileName or fileName == "" then return false end
    if not fileName:match("%.json$") then fileName = fileName .. ".json" end
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, Cfg)
    if not ok then return false end
    local wrote = pcall(writefile, FolderName .. "/" .. fileName, encoded)
    if wrote then SendXenoWebhook("Profile Saved", "Saved profile: **" .. fileName .. "**", 65280) end
    return wrote
end

local function LoadConfig(fileName)
    if not HasFS or not fileName or fileName == "" then return false end
    if not fileName:match("%.json$") then fileName = fileName .. ".json" end
    local path = FolderName .. "/" .. fileName
    if not isfile(path) then return false end
    local ok, content = pcall(readfile, path)
    if not ok then return false end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, content)
    if not ok2 then return false end
    ApplyConfigData(data)
    SendXenoWebhook("Profile Loaded", "Loaded profile: **" .. fileName .. "**", 255)
    return true
end

if HasFS then
    if Cfg.AutoLoad and isfile(FolderName .. "/" .. DefaultConfigName) then
        LoadConfig(DefaultConfigName)
    else
        SaveConfig(DefaultConfigName)
    end
end

-- =============================================================================
-- UI
-- =============================================================================
local ok, OrionLib = pcall(function() return loadstring(game:HttpGet(ORION_URL))() end)
if not ok or not OrionLib then
    warn("[XenoHub]: Failed to load Orion library: " .. tostring(OrionLib))
    getgenv().XenoHub_Loaded = nil
    return
end

local Window = OrionLib:MakeWindow({
    Name = "XenoHub Ultimate V5 | Attack on Titan: Revolution",
    HidePremium = true,
    SaveConfig = false,
    IntroText = "XenoHub Loading...",
    IntroIcon = "rbxassetid://4483362458",
})

local function Notify(name, content)
    OrionLib:MakeNotification({ Name = name, Content = content, Image = "rbxassetid://4483362458", Time = 3 })
end

local SystemTab = Window:MakeTab({ Name = "System & Profiles", Icon = "rbxassetid://4483362458", PremiumOnly = false })

SystemTab:AddSection({ Name = "Appearance" })

SystemTab:AddDropdown({
    Name = "UI Theme",
    Default = Cfg.ActiveTheme,
    Options = { "Black & Yellow", "Total Dark", "Cyber Glow" },
    Callback = function(value)
        Cfg.ActiveTheme = value
        UpdateUIAppearance()
    end,
})

SystemTab:AddSlider({
    Name = "Window Transparency",
    Min = 0, Max = 9, Increment = 1, ValueName = "/10",
    Default = math.floor(Cfg.UITransparency * 10),
    Callback = function(value)
        Cfg.UITransparency = value / 10
        UpdateUIAppearance()
    end,
})

SystemTab:AddToggle({
    Name = "Transparent Outline",
    Default = Cfg.OutlineTransparent,
    Callback = function(value)
        Cfg.OutlineTransparent = value
        UpdateUIAppearance()
    end,
})

SystemTab:AddSlider({
    Name = "Outline Thickness",
    Min = 1, Max = 5, Increment = 1, ValueName = "px",
    Default = Cfg.OutlineThickness,
    Callback = function(value)
        Cfg.OutlineThickness = value
        UpdateUIAppearance()
    end,
})

SystemTab:AddButton({
    Name = "Reset Appearance",
    Callback = function()
        local d = NewDefaults()
        Cfg.ActiveTheme, Cfg.UITransparency = d.ActiveTheme, d.UITransparency
        Cfg.OutlineTransparent, Cfg.OutlineThickness = d.OutlineTransparent, d.OutlineThickness
        UpdateUIAppearance()
        Notify("Appearance", "Reset to Black & Yellow, opaque.")
    end,
})

SystemTab:AddSection({ Name = "Profiles & Webhook" })

SystemTab:AddTextbox({
    Name = "Discord Webhook URL",
    Default = Cfg.WebhookURL,
    TextDisappear = false,
    Callback = function(text)
        Cfg.WebhookURL = text
        SendXenoWebhook("Link Validated", "Webhook connected.", 3447003)
    end,
})

local CustomConfigName = "MyCustomProfile"
SystemTab:AddTextbox({
    Name = "Profile Name",
    Default = CustomConfigName,
    TextDisappear = false,
    Callback = function(text) CustomConfigName = text end,
})

SystemTab:AddButton({
    Name = "Save Profile",
    Callback = function()
        if SaveConfig(CustomConfigName) then Notify("Saved", "Profile: " .. CustomConfigName)
        else Notify("Error", "Could not save (executor has no file access or empty name).") end
    end,
})

SystemTab:AddButton({
    Name = "Load Profile",
    Callback = function()
        if LoadConfig(CustomConfigName) then Notify("Loaded", "Profile: " .. CustomConfigName)
        else Notify("Error", "Profile not found: " .. CustomConfigName) end
    end,
})

SystemTab:AddButton({
    Name = "Close UI",
    Callback = function()
        OrionLib:Destroy()
        getgenv().XenoHub_Loaded = nil
    end,
})

OrionLib:Init()
task.delay(1.5, UpdateUIAppearance) -- wait for Orion's intro animation to finish
