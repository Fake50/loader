-- ============================================
-- 🔑 FIRMA MODE KEY LOADER - FINAL VERSION
-- ============================================

local SERVER_URL = "https://esp-ultra-server.onrender.com"
local SCRIPT_URL = "https://raw.githubusercontent.com/Fake50/ESP-BY-FIRMA-MODE/refs/heads/main/ESP"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- Key Storage
local KeyStorageFile = "FirmaModeKey.txt"

-- Functions
local function makeRequest(endpoint, data)
    print("[REQUEST] Запрос к:", SERVER_URL .. endpoint)
    
    local success, result = pcall(function()
        local response = request({
            Url = SERVER_URL .. endpoint,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
        
        print("[REQUEST] StatusCode:", response.StatusCode)
        print("[REQUEST] Body:", response.Body:sub(1, 200))
        
        return HttpService:JSONDecode(response.Body)
    end)
    
    if success and result then
        print("[REQUEST] ✅ Успешный ответ")
        return result
    else
        warn("[REQUEST] ❌ Ошибка:", result)
        return nil
    end
end

local function saveKey(key)
    pcall(function() writefile(KeyStorageFile, key) end)
end

local function loadKey()
    local ok, key = pcall(function() return readfile(KeyStorageFile) end)
    return ok and key or nil
end

local function deleteKey()
    pcall(function() delfile(KeyStorageFile) end)
end

local function loadScript(token)
    local code
    if token and token ~= "" then
        local ok, r = pcall(function()
            return request({Url = SCRIPT_URL, Method = "GET", Headers = {["Authorization"] = "token " .. token}}).Body
        end)
        if ok then code = r end
    else
        local ok, r = pcall(function() return game:HttpGet(SCRIPT_URL, true) end)
        if ok then code = r end
    end
    if code then
        local f = loadstring(code)
        if f then f() return true end
    end
    return false
end

-- Auto-login
local savedKey = loadKey()
if savedKey then
    local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    local res = makeRequest("/api/validate", {key = savedKey, hwid = hwid, userId = player.UserId, game = game.PlaceId})
    if res and res.success then
        _G.ESP_USER_KEY = savedKey
        _G.ESP_GITHUB_TOKEN = res.githubToken
        if loadScript(res.githubToken) then return end
    else
        deleteKey()
    end
end

-- Load Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Create Window
local Window = Fluent:CreateWindow({
    Title = "FIRMA MODE - Key System",
    SubTitle = "Premium Key + ESP",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Key System", Icon = "key" }),
    Credits = Window:AddTab({ Title = "Credits", Icon = "users" })
}

local keyInput = ""

-- Main Tab
Tabs.Main:AddParagraph({
    Title = "🔑 Получить ключ",
    Content = "Скопируйте Telegram и напишите для получения ключа."
})

Tabs.Main:AddButton({
    Title = "📱 Копировать Telegram",
    Callback = function()
        setclipboard("https://t.me/firmamodee")
        Fluent:Notify({Title = "✅ Скопировано", Content = "Telegram ссылка в буфере", Duration = 3})
    end
})

Tabs.Main:AddParagraph({Title = "🔐 Активация", Content = "Введите ключ и нажмите активировать."})

Tabs.Main:AddInput("KeyInput", {
    Title = "Ключ активации",
    Placeholder = "XXXX-XXXX-XXXX-XXXX",
    Callback = function(v) keyInput = v end
})

Tabs.Main:AddButton({
    Title = "🚀 Активировать ключ",
    Callback = function()
        if keyInput == "" or #keyInput < 10 then
            Fluent:Notify({Title = "❌ Ошибка", Content = "Введите корректный ключ", Duration = 3})
            return
        end
        
        print("[KEY LOADER] Начинаем проверку ключа:", keyInput)
        Fluent:Notify({Title = "⏳ Проверка", Content = "Проверка ключа на сервере...", Duration = 3})
        
        local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
        print("[KEY LOADER] HWID:", hwid)
        
        local requestData = {
            key = keyInput,
            hwid = hwid,
            userId = player.UserId,
            game = game.PlaceId
        }
        
        print("[KEY LOADER] Отправка запроса...")
        local res = makeRequest("/api/validate", requestData)
        
        if not res then
            print("[KEY LOADER] ❌ Сервер не ответил")
            Fluent:Notify({Title = "❌ Ошибка", Content = "Сервер не отвечает", Duration = 5})
            return
        end
        
        print("[KEY LOADER] Ответ получен. Success:", res.success)
        
        if res.success then
            print("[KEY LOADER] ✅ Ключ валидный!")
            Fluent:Notify({Title = "✅ Успешно!", Content = "Ключ активирован!", Duration = 2})
            
            saveKey(keyInput)
            print("[KEY LOADER] Ключ сохранен")
            
            _G.ESP_USER_KEY = keyInput
            _G.ESP_GITHUB_TOKEN = res.githubToken or ""
            print("[KEY LOADER] Глобальные переменные установлены")
            
            task.wait(0.5)
            print("[KEY LOADER] Закрываем GUI...")
            local closeOk = pcall(function() 
                if Window then
                    Window:Destroy()
                    print("[KEY LOADER] GUI закрыт")
                end
            end)
            if not closeOk then
                print("[KEY LOADER] Не удалось закрыть GUI")
            end
            
            task.wait(0.5)
            print("[KEY LOADER] Загружаем скрипт...")
            
            local scriptLoaded = loadScript(res.githubToken or "")
            if scriptLoaded then
                print("[KEY LOADER] ✅ ESP загружен успешно!")
            else
                print("[KEY LOADER] ❌ Не удалось загрузить ESP")
                player:Kick("❌ Не удалось загрузить ESP")
            end
        else
            print("[KEY LOADER] ❌ Ключ невалидный:", res.message or "Unknown error")
            Fluent:Notify({Title = "❌ Ошибка", Content = res.message or "Неверный ключ", Duration = 5})
        end
    end
})

-- Credits Tab
Tabs.Credits:AddParagraph({Title = "👑 Owner", Content = "firmamodee - Создатель проекта"})
Tabs.Credits:AddButton({
    Title = "📱 Telegram: firmamodee",
    Callback = function()
        setclipboard("https://t.me/firmamodee")
        Fluent:Notify({Title = "✅ Скопировано", Duration = 2})
    end
})

Tabs.Credits:AddParagraph({Title = "🧪 Tester", Content = "tgvetov - Тестировщик"})
Tabs.Credits:AddParagraph({Title = "💻 ESP Creator", Content = "ecto - Разработчик ESP"})

Tabs.Credits:AddButton({
    Title = "🗑️ Удалить сохраненный ключ",
    Callback = function()
        deleteKey()
        Fluent:Notify({Title = "✅ Удалено", Content = "Ключ удален", Duration = 3})
    end
})

Fluent:Notify({Title = "🔥 FIRMA MODE", Content = "Добро пожаловать!", Duration = 5})
