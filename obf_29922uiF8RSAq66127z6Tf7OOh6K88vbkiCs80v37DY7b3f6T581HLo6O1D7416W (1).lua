    -- ============================================
    -- 🔑 ESP ULTRA MODERN - KEY LOADER
    -- ============================================
    -- Маленький loader который проверяет ключ
    -- и загружает основной ESP код с GitHub
    -- ============================================

    print("🔄 Загрузка Key System...")

    local SERVER_URL = "https://esp-ultra-server.onrender.com"
    local SCRIPT_URL = "https://raw.githubusercontent.com/Fake50/ESP-BY-FIRMA-MODE/refs/heads/main/ESP"
    local GITHUB_TOKEN = "" -- Оставь пустым, токен придёт с сервера
    local USER_KEY = nil

    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local player = Players.LocalPlayer

    -- ============================================
    -- ПОЛУЧЕНИЕ HWID
    -- ============================================
    local function getHWID()
        local success, hwid = pcall(function()
            return game:GetService("RbxAnalyticsService"):GetClientId()
        end)
        return success and hwid or "unknown-hwid"
    end

    -- ============================================
    -- HTTP REQUEST
    -- ============================================
    local function makeRequest(endpoint, data)
        local success, result = pcall(function()
            local response = request({
                Url = SERVER_URL .. endpoint,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(data)
            })
            return HttpService:JSONDecode(response.Body)
        end)
        
        if not success then
            warn("[LOADER] Ошибка запроса:", result)
            return nil
        end
        
        return result
    end

    -- ============================================
    -- ПРОВЕРКА КЛЮЧА НА СЕРВЕРЕ
    -- ============================================
    local function validateKey(key)
        print("[AUTH] Проверка ключа на сервере...")
        
        local authData = {
            key = key,
            hwid = getHWID(),
            userId = player.UserId,
            game = game.PlaceId
        }
        
        local response = makeRequest("/api/validate", authData)
        
        if not response then
            return false, "❌ Не удалось подключиться к серверу"
        end
        
        if not response.success then
            return false, response.message or "❌ Ключ недействителен"
        end
        
        -- Получаем GitHub токен с сервера для доступа к приватному репозиторию
        if response.githubToken then
            GITHUB_TOKEN = response.githubToken
            print("[AUTH] ✅ GitHub токен получен")
        end
        
        print("[AUTH] ✅ Ключ принят!")
        print("[AUTH] Тип подписки:", response.tier)
        print("[AUTH] Истекает:", response.expiry)
        
        return true, "✅ Ключ действителен!"
    end

    -- ============================================
    -- GUI ДЛЯ ВВОДА КЛЮЧА
    -- ============================================
    local function createKeyGUI()
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "KeyLoaderGUI"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        -- Затемнение фона с blur эффектом
        local Background = Instance.new("Frame")
        Background.Size = UDim2.new(1, 0, 1, 0)
        Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Background.BackgroundTransparency = 0.2
        Background.BorderSizePixel = 0
        Background.Parent = ScreenGui
        
        -- Главное окно (больше и красивее)
        local MainFrame = Instance.new("Frame")
        MainFrame.Size = UDim2.new(0, 500, 0, 400)
        MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
        MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        MainFrame.BorderSizePixel = 0
        MainFrame.Parent = ScreenGui
        
        local MainCorner = Instance.new("UICorner")
        MainCorner.CornerRadius = UDim.new(0, 16)
        MainCorner.Parent = MainFrame
        
        -- Градиентная полоска сверху
        local TopBar = Instance.new("Frame")
        TopBar.Size = UDim2.new(1, 0, 0, 4)
        TopBar.Position = UDim2.new(0, 0, 0, 0)
        TopBar.BorderSizePixel = 0
        TopBar.Parent = MainFrame
        
        local TopBarGradient = Instance.new("UIGradient")
        TopBarGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 150, 50)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 150))
        }
        TopBarGradient.Rotation = 90
        TopBarGradient.Parent = TopBar
        
        local TopBarCorner = Instance.new("UICorner")
        TopBarCorner.CornerRadius = UDim.new(0, 16)
        TopBarCorner.Parent = TopBar
        
        -- Иконка/Эмодзи
        local Icon = Instance.new("TextLabel")
        Icon.Size = UDim2.new(0, 80, 0, 80)
        Icon.Position = UDim2.new(0.5, -40, 0, 40)
        Icon.BackgroundTransparency = 1
        Icon.Text = "🔥"
        Icon.TextSize = 60
        Icon.Font = Enum.Font.GothamBold
        Icon.Parent = MainFrame
        
        -- Заголовок
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -60, 0, 40)
        Title.Position = UDim2.new(0, 30, 0, 130)
        Title.BackgroundTransparency = 1
        Title.Text = "ESP ULTRA MODERN"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 28
        Title.Font = Enum.Font.GothamBold
        Title.TextXAlignment = Enum.TextXAlignment.Center
        Title.Parent = MainFrame
        
        -- Подзаголовок
        local Subtitle = Instance.new("TextLabel")
        Subtitle.Size = UDim2.new(1, -60, 0, 25)
        Subtitle.Position = UDim2.new(0, 30, 0, 175)
        Subtitle.BackgroundTransparency = 1
        Subtitle.Text = "Введите ваш ключ активации"
        Subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
        Subtitle.TextSize = 15
        Subtitle.Font = Enum.Font.Gotham
        Subtitle.TextXAlignment = Enum.TextXAlignment.Center
        Subtitle.Parent = MainFrame
        
        -- Контейнер для поля ввода
        local InputContainer = Instance.new("Frame")
        InputContainer.Size = UDim2.new(1, -60, 0, 55)
        InputContainer.Position = UDim2.new(0, 30, 0, 220)
        InputContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        InputContainer.BorderSizePixel = 0
        InputContainer.Parent = MainFrame
        
        local InputCorner = Instance.new("UICorner")
        InputCorner.CornerRadius = UDim.new(0, 10)
        InputCorner.Parent = InputContainer
        
        local InputStroke = Instance.new("UIStroke")
        InputStroke.Color = Color3.fromRGB(55, 55, 65)
        InputStroke.Thickness = 2
        InputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        InputStroke.Parent = InputContainer
        
        -- Иконка замка в поле ввода
        local LockIcon = Instance.new("TextLabel")
        LockIcon.Size = UDim2.new(0, 40, 1, 0)
        LockIcon.Position = UDim2.new(0, 5, 0, 0)
        LockIcon.BackgroundTransparency = 1
        LockIcon.Text = "🔑"
        LockIcon.TextSize = 22
        LockIcon.Font = Enum.Font.GothamBold
        LockIcon.Parent = InputContainer
        
        -- Поле ввода ключа (обычный текст, без маскировки)
        local KeyBox = Instance.new("TextBox")
        KeyBox.Size = UDim2.new(1, -50, 1, -10)
        KeyBox.Position = UDim2.new(0, 45, 0, 5)
        KeyBox.BackgroundTransparency = 1
        KeyBox.Text = ""
        KeyBox.PlaceholderText = "Введите ключ..."
        KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
        KeyBox.TextSize = 16
        KeyBox.Font = Enum.Font.GothamMedium
        KeyBox.ClearTextOnFocus = false
        KeyBox.TextXAlignment = Enum.TextXAlignment.Left
        KeyBox.Parent = InputContainer
        
        -- Кнопка проверки
        local SubmitButton = Instance.new("TextButton")
        SubmitButton.Size = UDim2.new(1, -60, 0, 55)
        SubmitButton.Position = UDim2.new(0, 30, 0, 295)
        SubmitButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        SubmitButton.BorderSizePixel = 0
        SubmitButton.Text = "✓  ПРОВЕРИТЬ КЛЮЧ"
        SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        SubmitButton.TextSize = 18
        SubmitButton.Font = Enum.Font.GothamBold
        SubmitButton.Parent = MainFrame
        
        local SubmitCorner = Instance.new("UICorner")
        SubmitCorner.CornerRadius = UDim.new(0, 10)
        SubmitCorner.Parent = SubmitButton
        
        -- Градиент на кнопке
        local ButtonGradient = Instance.new("UIGradient")
        ButtonGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 100))
        }
        ButtonGradient.Rotation = 90
        ButtonGradient.Parent = SubmitButton
        
        -- Статус текст
        local StatusLabel = Instance.new("TextLabel")
        StatusLabel.Size = UDim2.new(1, -60, 0, 30)
        StatusLabel.Position = UDim2.new(0, 30, 0, 365)
        StatusLabel.BackgroundTransparency = 1
        StatusLabel.Text = ""
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        StatusLabel.TextSize = 13
        StatusLabel.Font = Enum.Font.Gotham
        StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
        StatusLabel.Parent = MainFrame
        
        ScreenGui.Parent = player:WaitForChild("PlayerGui")
        
        local keyValidated = false
        
        -- Анимация появления
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame:TweenSize(
            UDim2.new(0, 500, 0, 400),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Back,
            0.5,
            true
        )
        
        -- Обработчик кнопки
        SubmitButton.MouseButton1Click:Connect(function()
            local enteredKey = KeyBox.Text
            
            if enteredKey == "" or enteredKey == " " then
                StatusLabel.Text = "❌ Введите ключ!"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                InputStroke.Color = Color3.fromRGB(255, 50, 50)
                wait(0.1)
                InputContainer.Position = UDim2.new(0, 35, 0, 220)
                wait(0.05)
                InputContainer.Position = UDim2.new(0, 25, 0, 220)
                wait(0.05)
                InputContainer.Position = UDim2.new(0, 30, 0, 220)
                return
            end
            
            -- Показываем загрузку
            SubmitButton.Text = "⏳ ПРОВЕРКА..."
            SubmitButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ButtonGradient.Enabled = false
            StatusLabel.Text = "🔄 Проверяем ключ на сервере..."
            StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            KeyBox.TextEditable = false
            InputStroke.Color = Color3.fromRGB(100, 150, 255)
            
            -- Проверяем ключ
            local success, message = validateKey(enteredKey)
            
            if success then
                USER_KEY = enteredKey
                StatusLabel.Text = "✅ " .. message
                StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                SubmitButton.Text = "✓ КЛЮЧ ПРИНЯТ!"
                SubmitButton.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
                InputStroke.Color = Color3.fromRGB(50, 255, 100)
                
                keyValidated = true
                
                task.wait(0.5)
                StatusLabel.Text = "📦 Загружаем ESP..."
                task.wait(0.3)
                
                -- Анимация исчезновения
                MainFrame:TweenSize(
                    UDim2.new(0, 0, 0, 0),
                    Enum.EasingDirection.In,
                    Enum.EasingStyle.Back,
                    0.3,
                    true
                )
                task.wait(0.4)
                ScreenGui:Destroy()
            else
                StatusLabel.Text = "❌ " .. message
                StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                SubmitButton.Text = "❌ НЕВЕРНЫЙ КЛЮЧ"
                SubmitButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                InputStroke.Color = Color3.fromRGB(255, 50, 50)
                KeyBox.TextEditable = true
                
                task.wait(2)
                SubmitButton.Text = "✓ ПРОВЕРИТЬ КЛЮЧ"
                ButtonGradient.Enabled = true
                StatusLabel.Text = ""
                InputStroke.Color = Color3.fromRGB(55, 55, 65)
            end
        end)
        
        -- Ждём валидации
        repeat
            task.wait(0.1)
        until keyValidated
        
        return true
    end

    -- ============================================
    -- ЗАГРУЗКА ОСНОВНОГО ESP КОДА
    -- ============================================
    local function loadMainScript()
        print("[LOADER] Загрузка основного ESP кода с GitHub...")
        print("[LOADER] URL:", SCRIPT_URL)
        
        local success, result = pcall(function()
            -- Загружаем скрипт
            local scriptCode
            
            if GITHUB_TOKEN and GITHUB_TOKEN ~= "" then
                print("[LOADER] Используем GitHub токен для приватного репо")
                local response = request({
                    Url = SCRIPT_URL,
                    Method = "GET",
                    Headers = {
                        ["Authorization"] = "token " .. GITHUB_TOKEN
                    }
                })
                scriptCode = response.Body
            else
                print("[LOADER] Загружаем из публичного репо")
                scriptCode = game:HttpGet(SCRIPT_URL, true)
            end
            
            print("[LOADER] Скрипт загружен, размер:", #scriptCode, "символов")
            print("[LOADER] Первые 200 символов:", scriptCode:sub(1, 200))
            
            -- Выполняем загруженный код
            local loadFunc, err = loadstring(scriptCode)
            if not loadFunc then
                error("Ошибка компиляции: " .. tostring(err))
            end
            
            print("[LOADER] Скрипт скомпилирован, запускаем...")
            loadFunc()
        end)
        
        if not success then
            warn("[LOADER] ❌ Ошибка загрузки ESP:", result)
            player:Kick("❌ Не удалось загрузить ESP код\n\nОшибка: " .. tostring(result))
            return false
        end
        
        print("[LOADER] ✅ ESP успешно загружен!")
        return true
    end

    -- ============================================
    -- ГЛАВНАЯ ФУНКЦИЯ
    -- ============================================
    local function main()
        -- 1. Показываем GUI для ввода ключа
        local keyValid = createKeyGUI()
        
        if not keyValid then
            player:Kick("❌ Доступ запрещён")
            return
        end
        
        -- 2. Сохраняем ключ в глобальную переменную для основного скрипта
        _G.ESP_USER_KEY = USER_KEY
        _G.ESP_SERVER_URL = SERVER_URL
        
        -- 3. Загружаем основной ESP код
        loadMainScript()
    end

    -- Запуск
    main()
