-- ============================================
-- 🔑 FIRMA MODE X ECTO X TGVETOV - ANIMATED
-- ============================================

local SERVER_URL = "https://esp-ultra-server.onrender.com"
local SCRIPT_URL = "https://raw.githubusercontent.com/Fake50/ESP-BY-FIRMA-MODE/refs/heads/main/ESP"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

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

local function animate(obj, properties, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties):Play()
end

local function createKeyGUI(callback)
    if PlayerGui:FindFirstChild("KeyLoaderGUI") then PlayerGui.KeyLoaderGUI:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui", PlayerGui)
    ScreenGui.Name = "KeyLoaderGUI"
    
    local BorderFrame = Instance.new("Frame", ScreenGui)
    BorderFrame.Size = UDim2.new(0, 0, 0, 0) -- Начальный размер для анимации
    BorderFrame.Position = UDim2.new(0.5, -227, 0.5, -225)
    BorderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", BorderFrame).CornerRadius = UDim.new(0, 14)
    
    local BorderGradient = Instance.new("UIGradient", BorderFrame)
    BorderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255))
    })

    task.spawn(function()
        while BorderFrame.Parent do
            for i = 0, 360, 5 do
                if not BorderGradient then break end
                BorderGradient.Rotation = i
                task.wait(0.05)
            end
        end
    end)
    
    -- Анимация появления окна
    BorderFrame:TweenSize(UDim2.new(0, 454, 0, 450), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5)
    
    local MainFrame = Instance.new("Frame", BorderFrame)
    MainFrame.Size = UDim2.new(1, -4, 1, -4)
    MainFrame.Position = UDim2.new(0, 2, 0, 2)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    local CloseBtn = Instance.new("TextButton", MainFrame)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0); CloseBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
    CloseBtn.MouseButton1Click:Connect(function() 
        BorderFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.3)
        task.wait(0.3)
        ScreenGui:Destroy() 
    end)
    
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, 0, 0, 50); Title.Position = UDim2.new(0, 0, 0, 10)
    Title.BackgroundTransparency = 1; Title.Text = "FIRMA MODE X ECTO X TGVETOV"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.GothamBold; Title.TextSize = 20
    
    local InfoLabel = Instance.new("TextLabel", MainFrame)
    InfoLabel.Size = UDim2.new(1, -40, 0, 40); InfoLabel.Position = UDim2.new(0, 20, 0, 60)
    InfoLabel.BackgroundTransparency = 1; InfoLabel.Text = "Жми на кнопку, копируй ТГ и забирай бесплатный ключ"
    InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150); InfoLabel.Font = Enum.Font.Gotham; InfoLabel.TextSize = 13
    
    local TGButton = Instance.new("TextButton", MainFrame)
    TGButton.Size = UDim2.new(1, -40, 0, 40); TGButton.Position = UDim2.new(0, 20, 0, 100)
    TGButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TGButton.Text = "✈ КОПИРОВАТЬ ТГ"
    TGButton.TextColor3 = Color3.fromRGB(0, 255, 255); TGButton.Font = Enum.Font.GothamBold
    Instance.new("UICorner", TGButton).CornerRadius = UDim.new(0, 6)
    TGButton.MouseButton1Click:Connect(function() 
        setclipboard("https://t.me/firmamodee") 
        animate(TGButton, {Size = UDim2.new(1, -30, 0, 40)}, 0.1)
        task.wait(0.1)
        animate(TGButton, {Size = UDim2.new(1, -40, 0, 40)}, 0.1)
    end)
    
    local KeyBox = Instance.new("TextBox", MainFrame)
    KeyBox.Size = UDim2.new(1, -40, 0, 60); KeyBox.Position = UDim2.new(0, 20, 0, 170)
    KeyBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20); KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyBox.PlaceholderText = "Введите ключ..."
    KeyBox.Font = Enum.Font.Gotham; Instance.new("UICorner", KeyBox)
    
    local Submit = Instance.new("TextButton", MainFrame)
    Submit.Size = UDim2.new(1, -40, 0, 50); Submit.Position = UDim2.new(0, 20, 0, 260)
    Submit.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Submit.Text = "ПРОВЕРИТЬ"
    Submit.TextColor3 = Color3.fromRGB(255, 255, 255); Submit.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Submit).CornerRadius = UDim.new(0, 6)
    
    Submit.MouseButton1Down:Connect(function() animate(Submit, {Size = UDim2.new(1, -50, 0, 45)}, 0.1) end)
    Submit.MouseButton1Up:Connect(function() animate(Submit, {Size = UDim2.new(1, -40, 0, 50)}, 0.1) end)
    
    local Status = Instance.new("TextLabel", MainFrame)
    Status.Size = UDim2.new(1, 0, 0, 30); Status.Position = UDim2.new(0, 0, 0, 320)
    Status.BackgroundTransparency = 1; Status.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    Submit.MouseButton1Click:Connect(function()
        Status.Text = "Проверка..."
        local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
        local res = makeRequest("/api/validate", {key = KeyBox.Text, hwid = hwid, userId = player.UserId, game = game.PlaceId})
        if res and res.success then
            Status.Text = "Успешно!"
            BorderFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.3)
            task.wait(0.3)
            ScreenGui:Destroy()
            callback(true, KeyBox.Text, res.githubToken)
        else
            Status.Text = "❌ Неверный ключ"
        end
    end)
end

createKeyGUI(function(s, k, token)
    if s then
        _G.ESP_USER_KEY = k
        local scriptCode = token ~= "" and request({Url = SCRIPT_URL, Method = "GET", Headers = {["Authorization"] = "token " .. token}}).Body or game:HttpGet(SCRIPT_URL, true)
        local f = loadstring(scriptCode)
        if f then f() end
    end
end)
