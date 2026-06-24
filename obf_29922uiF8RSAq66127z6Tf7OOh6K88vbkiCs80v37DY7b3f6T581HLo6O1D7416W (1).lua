-- ============================================
-- 🔑 FIRMA MODE X ECTO X TGVETOV - KEY LOADER
-- ============================================

print("🔄 Загрузка Key System...")

local SERVER_URL = "https://esp-ultra-server.onrender.com"
local SCRIPT_URL = "https://raw.githubusercontent.com/Fake50/ESP-BY-FIRMA-MODE/refs/heads/main/ESP"
local GITHUB_TOKEN = ""
local USER_KEY = nil

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ============================================
-- УТИЛИТЫ
-- ============================================
local function getHWID()
    local success, hwid = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
    return success and hwid or "unknown-hwid"
end

local function makeRequest(endpoint, data)
    local success, result = pcall(function()
        local response = request({
            Url = SERVER_URL .. endpoint,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
        return HttpService:JSONDecode(response.Body)
    end)
    return success and result or nil
end

-- ============================================
-- GUI
-- ============================================
local function createKeyGUI(callback)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KeyLoaderGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
    
    local Background = Instance.new("Frame", ScreenGui)
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Background.BackgroundTransparency = 0.2
    
    local MainFrame = Instance.new("Frame", Background)
    MainFrame.Size = UDim2.new(0, 500, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -240)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
    
    -- Заголовок FIRMA MODE X ECTO X TGVETOV
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, -60, 0, 40); Title.Position = UDim2.new(0, 30, 0, 20)
    Title.BackgroundTransparency = 1; Title.Text = "FIRMA MODE X ECTO X TGVETOV"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.TextSize = 24; Title.Font = Enum.Font.GothamBold
    
    -- Подзаголовок (инструкция)
    local Subtitle = Instance.new("TextLabel", MainFrame)
    Subtitle.Size = UDim2.new(1, -60, 0, 40); Subtitle.Position = UDim2.new(0, 30, 0, 60)
    Subtitle.BackgroundTransparency = 1; Subtitle.Text = "Жми на синюю кнопку, копируй телеграм и забирай бесплатный ключ"
    Subtitle.TextColor3 = Color3.fromRGB(180, 180, 180); Subtitle.TextSize = 14; Subtitle.Font = Enum.Font.Gotham; Subtitle.TextWrapped = true
    
    -- Кнопка TG
    local TGButton = Instance.new("TextButton", MainFrame)
    TGButton.Size = UDim2.new(0, 240, 0, 45); TGButton.Position = UDim2.new(0.5, -120, 0, 110)
    TGButton.BackgroundColor3 = Color3.fromRGB(0, 136, 204); TGButton.Text = "✈ КОПИРОВАТЬ ССЫЛКУ TG"
    TGButton.TextColor3 = Color3.fromRGB(255, 255, 255); TGButton.Font = Enum.Font.GothamBold
    Instance.new("UICorner", TGButton).CornerRadius = UDim.new(0, 8)
    
    TGButton.MouseButton1Click:Connect(function()
        setclipboard("https://t.me/firmamodee")
        TGButton.Text = "ССЫЛКА СКОПИРОВАНА!"
        task.wait(1.5)
        TGButton.Text = "✈ КОПИРОВАТЬ ССЫЛКУ TG"
    end)
    
    -- Ввод
    local InputContainer = Instance.new("Frame", MainFrame)
    InputContainer.Size = UDim2.new(1, -60, 0, 55); InputContainer.Position = UDim2.new(0, 30, 0, 175)
    InputContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Instance.new("UICorner", InputContainer).CornerRadius = UDim.new(0, 10)
    
    local KeyBox = Instance.new("TextBox", InputContainer)
    KeyBox.Size = UDim2.new(1, -20, 1, 0); KeyBox.Position = UDim2.new(0, 10, 0, 0)
    KeyBox.BackgroundTransparency = 1; KeyBox.PlaceholderText = "Вставь ключ сюда..."
    KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255); KeyBox.TextSize = 16
    
    -- Кнопка проверки
    local SubmitButton = Instance.new("TextButton", MainFrame)
    SubmitButton.Size = UDim2.new(1, -60, 0, 55); SubmitButton.Position = UDim2.new(0, 30, 0, 250)
    SubmitButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    SubmitButton.Text = "ПРОВЕРИТЬ КЛЮЧ"; SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.Font = Enum.Font.GothamBold
    Instance.new("UICorner", SubmitButton).CornerRadius = UDim.new(0, 10)
    
    local StatusLabel = Instance.new("TextLabel", MainFrame)
    StatusLabel.Size = UDim2.new(1, -60, 0, 30); StatusLabel.Position = UDim2.new(0, 30, 0, 320)
    StatusLabel.BackgroundTransparency = 1; StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    
    SubmitButton.MouseButton1Click:Connect(function()
        local key = KeyBox.Text
        if key == "" then return end
        
        SubmitButton.Text = "ПРОВЕРКА..."
        local response = makeRequest("/api/validate", {key = key, hwid = getHWID(), userId = player.UserId, game = game.PlaceId})
        
        if response and response.success then
            StatusLabel.Text = "✅ Успешно!"
            GITHUB_TOKEN = response.githubToken or ""
            task.wait(1)
            ScreenGui:Destroy()
            callback(true, key)
        else
            StatusLabel.Text = "❌ Ошибка ключа"
            SubmitButton.Text = "ПРОВЕРИТЬ КЛЮЧ"
        end
    end)
end

-- ============================================
-- ЗАГРУЗКА
-- ============================================
local function loadMainScript()
    local scriptCode = GITHUB_TOKEN ~= "" and request({Url = SCRIPT_URL, Method = "GET", Headers = {["Authorization"] = "token " .. GITHUB_TOKEN}}).Body or game:HttpGet(SCRIPT_URL, true)
    local func, err = loadstring(scriptCode)
    if func then task.spawn(func) else warn("Load Error: " .. tostring(err)) end
end

createKeyGUI(function(success, key)
    if success then
        _G.ESP_USER_KEY = key
        _G.ESP_SERVER_URL = SERVER_URL
        loadMainScript()
    end
end)
