-- ============================================
-- 🔑 FIRMA MODE KEY LOADER - FLUENT UI
-- Premium Design with Fluent Library
-- ============================================

local SERVER_URL = "https://esp-ultra-server.onrender.com"
local SCRIPT_URL = "https://raw.githubusercontent.com/Fake50/ESP-BY-FIRMA-MODE/refs/heads/main/ESP"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- Key Storage
local KeyStorageFile = "FirmaModeKey.txt"

-- Utility Functions
local function makeRequest(endpoint, data)
    -- Пробуем до 3 раз (для пробуждения Render.com сервера)
    for attempt = 1, 3 do
        if attempt > 1 then
            print("⏳ Попытка", attempt, "- сервер просыпается...")
            task.wait(20)
        end
        
        local success, result = pcall(function()
            local response = request({
                Url = SERVER_URL .. endpoint,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
            return HttpService:JSONDecode(response.Body)
        end)
        
        if success and result then
            return result
        end
    end
    
    return nil
end

local function saveKey(key)
    local success = pcall(function()
        writefile(KeyStorageFile, key)
    end)
    return success
end

local function loadKey()
    local success, key = pcall(function()
        return readfile(KeyStorageFile)
    end)
    return success and key or nil
end

local function deleteKey()
    pcall(function()
        delfile(KeyStorageFile)
    end)
end

local function loadMainScript(token)
    local scriptCode
    if token and token ~= "" then
        local ok, result = pcall(function()
            return request({
                Url = SCRIPT_URL,
                Method = "GET",
                Headers = {["Authorization"] = "token " .. token}
            }).Body
        end)
        if ok then scriptCode = result end
    else
        local ok, result = pcall(function()
            return game:HttpGet(SCRIPT_URL, true)
        end)
        if ok then scriptCode = result end
    end
    
    if scriptCode then
        local loadFunc = loadstring(scriptCode)
        if loadFunc then
            loadFunc()
            return true
        end
    end
    return false
end

-- Try auto-login with saved key
local savedKey = loadKey()
if savedKey then
    print("🔑 Найден сохраненный ключ, проверка...")
    
    local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    local response = makeRequest("/api/validate", {
        key = savedKey,
        hwid = hwid,
        userId = player.UserId,
        game = game.PlaceId
    })
    
    if response and response.success then
        print("✅ Ключ валидный! Автоматический вход...")
        _G.ESP_USER_KEY = savedKey
        _G.ESP_GITHUB_TOKEN = response.githubToken
        
        if loadMainScript(response.githubToken) then
            print("✅ ESP загружен автоматически!")
            return -- Exit script, don't show GUI
        end
    else
        print("❌ Сохраненный ключ больше не действителен")
        deleteKey()
    end
end

-- If we're here, show the key loader GUI
print("📱 Загрузка GUI для ввода ключа...")

-- Load Fluent UI Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

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

-- Create Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Key System", Icon = "key" }),
    Credits = Window:AddTab({ Title = "Credits", Icon = "users" })
}

-- Variables
local keyInput = ""
local isValidating = false

-- Main Tab Content
Tabs.Main:AddParagraph({
    Title = "🔑 Получить ключ",
    Content = "Для получения бесплатного ключа, скопируйте наш Telegram канал и напишите нам. Ключ будет отправлен в течение нескольких минут."
})

Tabs.Main:AddButton({
    Title = "📱 Копировать Telegram",
    Description = "Нажмите чтобы скопировать ссылку",
    Callback = function()
        setclipboard("https://t.me/firmamodee")
        Fluent:Notify({
            Title = "✅ Успешно!",
            Content = "Telegram ссылка скопирована в буфер обмена",
            Duration = 3
        })
    end
})

Tabs.Main:AddParagraph({
    Title = "🔐 Активация ключа",
    Content = "Введите полученный ключ в поле ниже и нажмите кнопку активации."
})

local KeyInput = Tabs.Main:AddInput("KeyInput", {
    Title = "Ключ активации",
    Default = "",
    Placeholder = "XXXX-XXXX-XXXX-XXXX",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        keyInput = Value
    end
})


Tabs.Main:AddButton({
    Title = "🚀 Активировать ключ",
    Description = "Проверить и активировать ключ",
    Callback = function()
        if isValidating then
            Fluent:Notify({
                Title = "⚠️ Подождите",
                Content = "Идет проверка ключа...",
                Duration = 2
            })
            return
        end
        
        if keyInput == "" or #keyInput < 10 then
            Fluent:Notify({
                Title = "❌ Ошибка",
                Content = "Введите корректный ключ активации",
                Duration = 3
            })
            return
        end
        
        isValidating = true
        
        Fluent:Notify({
            Title = "⏳ Проверка ключа",
            Content = "Подождите, идет проверка на сервере...",
            Duration = 2
        })
        
        local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
        local response = makeRequest("/api/validate", {
            key = keyInput,
            hwid = hwid,
            userId = player.UserId,
            game = game.PlaceId
        })
        
        isValidating = false
        
        if response and response.success then
            Fluent:Notify({
                Title = "✅ Ключ активирован!",
                Content = "Загрузка ESP системы...",
                Duration = 2
            })
            
            -- Save key for future use
            if saveKey(keyInput) then
                print("💾 Ключ сохранен для автоматического входа")
            end
            
            task.wait(0.5)
            
            -- Set global variables
            _G.ESP_USER_KEY = keyInput
            _G.ESP_GITHUB_TOKEN = response.githubToken
            
            -- Close window BEFORE loading script
            pcall(function() 
                Window:Destroy() 
            end)
            task.wait(0.5)
            
            -- Load main script
            if loadMainScript(response.githubToken) then
                print("✅ ESP загружен успешно!")
            else
                player:Kick("❌ Не удалось загрузить ESP. Попробуйте снова.")
            end
        else
            local errorMsg = response and response.message or "Неверный ключ или истек срок действия"
            Fluent:Notify({
                Title = "❌ Активация не удалась",
                Content = errorMsg,
                Duration = 5
            })
        end
    end
})


-- Credits Tab
Tabs.Credits:AddParagraph({
    Title = "👑 Owner",
    Content = "firmamodee - Создатель и владелец проекта"
})

Tabs.Credits:AddButton({
    Title = "📱 Telegram: firmamodee",
    Description = "Связаться с владельцем",
    Callback = function()
        setclipboard("https://t.me/firmamodee")
        Fluent:Notify({
            Title = "✅ Скопировано",
            Content = "Telegram владельца скопирован",
            Duration = 2
        })
    end
})

Tabs.Credits:AddParagraph({
    Title = "🧪 Tester",
    Content = "tgvetov - Тестировщик и помощник проекта"
})

Tabs.Credits:AddParagraph({
    Title = "💻 ESP Creator",
    Content = "ecto - Разработчик ESP системы"
})

Tabs.Credits:AddParagraph({
    Title = "📊 Статистика проекта",
    Content = "• Активных пользователей: 1000+\n• Версия: 2.0\n• Последнее обновление: " .. os.date("%d.%m.%Y")
})

Tabs.Credits:AddParagraph({
    Title = "⚙️ Возможности ESP",
    Content = "• ESP на легендарные вещи\n• ESP на аксессуары\n• Чамсы и трассеры\n• Спидхак\n• Fast Take\n• Автообновление"
})

Tabs.Credits:AddButton({
    Title = "🗑️ Удалить сохраненный ключ",
    Description = "Очистить кэш и выйти из аккаунта",
    Callback = function()
        deleteKey()
        Fluent:Notify({
            Title = "✅ Успешно",
            Content = "Сохраненный ключ удален. При следующем запуске нужно будет ввести ключ заново.",
            Duration = 5
        })
    end
})

-- Welcome notification
Fluent:Notify({
    Title = "🔥 FIRMA MODE",
    Content = "Добро пожаловать в систему активации ключей!",
    Duration = 5
})

-- Info
print("==========================================")
print("🔥 FIRMA MODE KEY LOADER - FLUENT UI")
print("==========================================")
print("👑 OWNER: firmamodee")
print("🧪 TESTER: tgvetov")
print("💻 CREATOR ESP: ecto")
print("==========================================")
print("✅ GUI загружен успешно!")
print("📱 Telegram: https://t.me/firmamodee")
print("==========================================")
