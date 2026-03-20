-- [[ ЗАГРУЗОЧНЫЙ ЭКРАН - GUGUHUB LOAD ]]
local GuguLoader = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local HubTitle = Instance.new("TextLabel")
local StatusLabel = Instance.new("TextLabel")
local Corner = Instance.new("UICorner")

GuguLoader.Name = "GuguLoad"
GuguLoader.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
GuguLoader.ResetOnSpawn = false

MainFrame.Name = "Main"
MainFrame.Parent = GuguLoader
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -50)
MainFrame.Size = UDim2.new(0, 250, 0, 100)
Corner.Parent = MainFrame

HubTitle.Name = "Title"
HubTitle.Parent = MainFrame
HubTitle.BackgroundTransparency = 1
HubTitle.Position = UDim2.new(0, 0, 0, 20)
HubTitle.Size = UDim2.new(1, 0, 0, 30)
HubTitle.Font = Enum.Font.GothamBold
HubTitle.Text = "GuguHub: Load"
HubTitle.TextColor3 = Color3.fromRGB(0, 255, 127) -- Яркий зеленый
HubTitle.TextSize = 24

StatusLabel.Name = "Status"
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0, 60)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Проверка данных... 15%"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 14

-- Анимация загрузки
task.spawn(function()
    for i = 15, 100, 15 do
        task.wait(0.4)
        StatusLabel.Text = "Загрузка модулей рейда... " .. i .. "%"
    end
    StatusLabel.Text = "Загрузка завершена!"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    task.wait(1)
    GuguLoader:Destroy()
end)

-------------------------------------------------------------------------
-- [[ ОСНОВНОЕ МЕНЮ И КНОПКА СВЕРТЫВАНИЯ ]]
-------------------------------------------------------------------------

task.wait(4.5) -- Ждем пока загрузчик пропадет

local Library = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Глобальная конфигурация
getgenv().Config = {
    AutoRaid = false,
    HeroicEnabled = false,
    Heroic1 = false,
    Heroic2 = false,
    Heroic3 = false,
    MaxTier = 25000,
    ChestsToClaim = {
        Small = true,
        Big = true,
        Boss = true,
        Leprechaun = false -- ключи
    }
}

-- [[ 1. Кнопка Toggle GUGUHUB ]]
-- Эта кнопка появится в углу экрана и позволит открывать/скрывать меню

local ToggleButtonUI = Instance.new("ScreenGui")
local GuguToggleButton = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")

ToggleButtonUI.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
GuguToggleButton.Parent = ToggleButtonUI
GuguToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
GuguToggleButton.BorderSizePixel = 0
GuguToggleButton.Position = UDim2.new(0.01, 0, 0.95, 0) -- Внизу слева
GuguToggleButton.Size = UDim2.new(0, 100, 0, 30)
GuguToggleButton.Font = Enum.Font.GothamBold
GuguToggleButton.Text = "guguhub"
GuguToggleButton.TextColor3 = Color3.fromRGB(0, 255, 127)
GuguToggleButton.TextSize = 18
ButtonCorner.CornerRadius = UDim.new(0, 15)
ButtonCorner.Parent = GuguToggleButton

local IsMenuVisible = true
GuguToggleButton.MouseButton1Click:Connect(function()
    IsMenuVisible = not IsMenuVisible
    Library:ToggleVisibility(IsMenuVisible) -- Встроенная функция библиотеки для скрытия окна
end)


-- [[ 2. Создание главного окна ]]
local Window = Library:CreateWindow({
    Name = "Pet Hub | Lucky Raid 🍀",
    LoadingTitle = "Lucky Gargantuan Update",
    ConfigurationSaving = { Enabled = true, Folder = "GuguPS99" }
})

local Network = game:GetService("ReplicatedStorage"):WaitForChild("Network")

-- Вкладка Main (как на скриншоте)
local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateSection("Генеральные Настройки")

MainTab:CreateToggle({
    Name = "Авто-Рейд (Макс. Tier)",
    CurrentValue = false,
    Callback = function(Value) 
        getgenv().Config.AutoRaid = Value 
        if Value then
            Network:WaitForChild("Raid_Start"):InvokeServer(getgenv().Config.MaxTier)
        end
    end,
})

MainTab:CreateToggle({
    Name = "Включить Auto Lever (Heroic)",
    CurrentValue = false,
    Callback = function(Value) getgenv().Config.HeroicEnabled = Value end,
})

MainTab:CreateSection("Выбор Рычагов (Для Героик Сундуков)")

-- Индивидуальные переключатели для рычагов (как на скриншоте)
MainTab:CreateToggle({
    Name = "Рычаг 1 (Zone 4 Boss)",
    CurrentValue = false,
    Callback = function(Value) getgenv().Config.Heroic1 = Value end,
})

MainTab:CreateToggle({
    Name = "Рычаг 2 (Zone 2 Hallway)",
    CurrentValue = false,
    Callback = function(Value) getgenv().Config.Heroic2 = Value end,
})

MainTab:CreateToggle({
    Name = "Рычаг 3 (Final Room)",
    CurrentValue = false,
    Callback = function(Value) getgenv().Config.Heroic3 = Value end,
})

-- Вкладка Сундуки
local ChestTab = Window:CreateTab("Сундуки (Авто-Открытие)", 4483362458)

ChestTab:CreateSection("Какие сундуки открывать в конце:")

ChestTab:CreateToggle({
    Name = "Открыть Small Chest",
    CurrentValue = getgenv().Config.ChestsToClaim.Small,
    Callback = function(Value) getgenv().Config.ChestsToClaim.Small = Value end,
})

ChestTab:CreateToggle({
    Name = "Открыть Big Chest",
    CurrentValue = getgenv().Config.ChestsToClaim.Big,
    Callback = function(Value) getgenv().Config.ChestsToClaim.Big = Value end,
})

ChestTab:CreateToggle({
    Name = "Открыть Boss Chest",
    CurrentValue = getgenv().Config.ChestsToClaim.Boss,
    Callback = function(Value) getgenv().Config.ChestsToClaim.Boss = Value end,
})

ChestTab:CreateToggle({
    Name = "Открыть Leprechaun Chest (Требует Ключи)",
    CurrentValue = getgenv().Config.ChestsToClaim.Leprechaun,
    Callback = function(Value) getgenv().Config.ChestsToClaim.Leprechaun = Value end,
})

-------------------------------------------------------------------------
-- [[ ЛОГИКА АВТОМАТИЗАЦИИ (ЦИКЛЫ) ]]
-------------------------------------------------------------------------

-- 1. Логика Героик Рычагов
task.spawn(function()
    while task.wait(5) do
        if getgenv().Config.HeroicEnabled then
            for _, obj in pairs(game.Workspace:GetDescendants()) do
                if obj.Name == "Lever" and obj:FindFirstChildOfClass("ProximityPrompt") then
                    -- Проверка по атрибуту зоны, к которому привязан рычаг
                    local leverId = obj:GetAttribute("LeverID") 
                    if (leverId == 1 and getgenv().Config.Heroic1) or 
                       (leverId == 2 and getgenv().Config.Heroic2) or 
                       (leverId == 3 and getgenv().Config.Heroic3) then
                           fireproximityprompt(obj:FindFirstChildOfClass("ProximityPrompt"))
                    end
                end
            end
        end
    end
end)

-- 2. Логика Авто-Сундуков
task.spawn(function()
    while task.wait(10) do
        if getgenv().Config.AutoRaid then
            local currentPlace = game.PlaceId
            local isRaidMap = (currentPlace == game.Players.LocalPlayer:GetAttribute("RaidPlaceID"))

            if isRaidMap then
                for chestName, shouldOpen in pairs(getgenv().Config.ChestsToClaim) do
                    if shouldOpen then
                        -- В Update 73 Remote Event для сбора наград
                        Network:WaitForChild("Raid_ClaimReward"):InvokeServer(chestName)
                    end
                end
            end
        end
    end
end)

-------------------------------------------------------------------------
Library:LoadConfiguration() -- Загрузка сохраненных настроек