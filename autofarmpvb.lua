local player = game.Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local remote = game:GetService("ReplicatedStorage").Remotes.ItemSell

local keyword = "kg"
local MIN_VALUE = 900

-- ====== НАСТРОЙКИ GUI ======
local guiEnabled = true
local sellingActive = false
local buyingActive = false
local gearingActive = false

-- ====== СОЗДАНИЕ GUI ======
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoSellGUI"
screenGui.Parent = player.PlayerGui

-- Кнопка показа/скрытия (Minimize) - теперь тоже перемещаемая
local miniButton = Instance.new("TextButton")
miniButton.Size = UDim2.new(0, 30, 0, 30)
miniButton.Position = UDim2.new(0, 10, 0, 10)
miniButton.BackgroundColor3 = Color3.fromRGB(60, 60, 200)
miniButton.Text = "M"
miniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
miniButton.TextScaled = true
miniButton.Font = Enum.Font.GothamBold
miniButton.ZIndex = 10
miniButton.Parent = screenGui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(1, 0)
miniCorner.Parent = miniButton

-- Основной фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 160) -- Увеличили высоту для новой кнопки
mainFrame.Position = UDim2.new(0, 50, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
mainFrame.Visible = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Заголовок для перемещения
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.Text = "AUTO FARM"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- Крестик закрытия
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -25, 0, 2)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.ZIndex = 2
closeButton.Parent = title

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

-- Кнопка автопродажи
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0, 30)
toggleButton.Position = UDim2.new(0.1, 0, 0.2, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60) -- красный выключен
toggleButton.Text = "AUTOSELL: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = toggleButton

-- Кнопка автопокупки семян
local buyButton = Instance.new("TextButton")
buyButton.Size = UDim2.new(0.8, 0, 0, 30)
buyButton.Position = UDim2.new(0.1, 0, 0.4, 0)
buyButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60) -- красный выключен
buyButton.Text = "AUTOBUY: OFF"
buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
buyButton.TextScaled = true
buyButton.Font = Enum.Font.GothamBold
buyButton.Parent = mainFrame

local buyButtonCorner = Instance.new("UICorner")
buyButtonCorner.CornerRadius = UDim.new(0, 6)
buyButtonCorner.Parent = buyButton

-- Новая кнопка автопокупки снаряжения
local gearButton = Instance.new("TextButton")
gearButton.Size = UDim2.new(0.8, 0, 0, 30)
gearButton.Position = UDim2.new(0.1, 0, 0.6, 0)
gearButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60) -- красный выключен
gearButton.Text = "AUTOGEAR: OFF"
gearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
gearButton.TextScaled = true
gearButton.Font = Enum.Font.GothamBold
gearButton.Parent = mainFrame

local gearButtonCorner = Instance.new("UICorner")
gearButtonCorner.CornerRadius = UDim.new(0, 6)
gearButtonCorner.Parent = gearButton

-- ====== ПЕРЕМЕЩЕНИЕ GUI ======
local dragging = false
local miniDragging = false
local dragInput, dragStart, startPos, miniStartPos

-- Функция перемещения основного фрейма
local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

-- Функция перемещения кнопки M
local function updateMini(input)
    local delta = input.Position - dragStart
    miniButton.Position = UDim2.new(miniStartPos.X.Scale, miniStartPos.X.Offset + delta.X, miniStartPos.Y.Scale, miniStartPos.Y.Offset + delta.Y)
end

-- Обработчики для основного фрейма
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

-- Обработчики для кнопки M
miniButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        miniDragging = true
        dragStart = input.Position
        miniStartPos = miniButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                miniDragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        dragInput = input
    end
end)

miniButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and miniDragging then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    elseif input == dragInput and miniDragging then
        updateMini(input)
    end
end)

-- ====== ФУНКЦИИ GUI ======
local function updateButtons()
    -- Обновление кнопки автопродажи
    if sellingActive then
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 80) -- зеленый включен
        toggleButton.Text = "AUTOSELL: ON"
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60) -- красный выключен
        toggleButton.Text = "AUTOSELL: OFF"
    end
    
    -- Обновление кнопки автопокупки
    if buyingActive then
        buyButton.BackgroundColor3 = Color3.fromRGB(60, 200, 80) -- зеленый включен
        buyButton.Text = "AUTOBUY: ON"
    else
        buyButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60) -- красный выключен
        buyButton.Text = "AUTOBUY: OFF"
    end
    
    -- Обновление кнопки автопокупки снаряжения
    if gearingActive then
        gearButton.BackgroundColor3 = Color3.fromRGB(60, 200, 80) -- зеленый включен
        gearButton.Text = "AUTOGEAR: ON"
    else
        gearButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60) -- красный выключен
        gearButton.Text = "AUTOGEAR: OFF"
    end
end

local function toggleGUI()
    mainFrame.Visible = not mainFrame.Visible
    if mainFrame.Visible then
        miniButton.BackgroundColor3 = Color3.fromRGB(60, 60, 200) -- синий когда видно
        miniButton.Text = "M"
    else
        miniButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- серый когда скрыто
        miniButton.Text = "M"
    end
end

-- Функция полного закрытия GUI
local function closeGUI()
    -- Останавливаем все процессы
    sellingActive = false
    buyingActive = false
    gearingActive = false
    
    -- Скрываем оба элемента
    mainFrame.Visible = false
    miniButton.Visible = false
    
    print("🔴 GUI полностью закрыта, все процессы остановлены")
end

-- ====== АВТОПОКУПКА СЕМЯН ======
local seeds = {
    "Cactus Seed",
    "Strawberry Seed", 
    "Pumpkin Seed",
    "Sunflower Seed",
    "Dragon Fruit Seed",
    "Eggplant Seed",
    "Watermelon Seed",
    "Grape Seed",
    "Cocotank Seed",
    "Carnivorus Plant Seed",
    "Mr Carrot Seed",
    "Tomatrio Seed",
    "Shroombino Seed"
}

local function autoBuyLoop()
    if not buyingActive then return end
    
    print("🛒 ЗАПУСК АВТОПОКУПКИ СЕМЯН")
    
    local seedIndex = 1
    
    while buyingActive do
        local seed = seeds[seedIndex]
        game:GetService("ReplicatedStorage").Remotes.BuyItem:FireServer(seed)
        print(("🌱 Куплено: %s"):format(seed))
        
        seedIndex = seedIndex + 1
        if seedIndex > #seeds then
            seedIndex = 1
        end
        
        -- Ждем 0.5 секунды перед следующей покупкой
        for i = 1, 5 do
            if not buyingActive then break end
            task.wait(0.1)
        end
    end
    
    print("🛑 АВТОПОКУПКА ОСТАНОВЛЕНА")
end

-- ====== АВТОПОКУПКА СНАРЯЖЕНИЯ ======
local gearItems = {
    "Water Bucket",
    "Frost Grenade", 
    "Frost Blower",
    "Carrot Launcher"
}

local function autoGearLoop()
    if not gearingActive then return end
    
    print("🎒 ЗАПУСК АВТОПОКУПКИ СНАРЯЖЕНИЯ")
    
    local gearIndex = 1
    
    while gearingActive do
        local gear = gearItems[gearIndex]
        game:GetService("ReplicatedStorage").Remotes.BuyGear:FireServer(gear)
        print(("🎯 Куплено снаряжение: %s"):format(gear))
        
        gearIndex = gearIndex + 1
        if gearIndex > #gearItems then
            gearIndex = 1
        end
        
        -- Ждем 0.5 секунды перед следующей покупкой
        for i = 1, 5 do
            if not gearingActive then break end
            task.wait(0.1)
        end
    end
    
    print("🛑 АВТОПОКУПКА СНАРЯЖЕНИЯ ОСТАНОВЛЕНА")
end

-- ====== функция извлечения текстов ======
local function extractTexts(tool)
    local texts = {}
    for _, d in ipairs(tool:GetDescendants()) do
        if d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
            for _, g in ipairs(d:GetDescendants()) do
                if (g:IsA("TextLabel") or g:IsA("TextBox") or g:IsA("TextButton")) and g.Text and g.Text ~= "" then
                    table.insert(texts, g.Text)
                end
            end
        elseif d:IsA("StringValue") and d.Value ~= "" then
            table.insert(texts, d.Value)
        end
    end
    return texts
end

-- ====== получить число из текста ======
local function extractValue(texts)
    for _, t in ipairs(texts) do
        -- Ищем число с возможной буквой k, M, B и т.д.
        local num, suffix = string.match(t, "%$([%d%.]+)([kKmMbB]?)")
        if num then
            local value = tonumber(num)
            if suffix then
                suffix = suffix:lower()
                if suffix == "k" then
                    value = value * 1000
                elseif suffix == "m" then
                    value = value * 1000000
                elseif suffix == "b" then
                    value = value * 1000000000
                end
            end
            return value, t -- возвращаем также оригинальный текст для консоли
        end
    end
    return nil, nil
end

-- ====== быстрая проверка всех предметов ======
local function getItemsToSell()
    local items = {}
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name:lower(), keyword:lower()) then
            local success, value = pcall(function()
                return extractValue(extractTexts(tool))
            end)
            
            if success and value and value < MIN_VALUE then
                table.insert(items, {tool = tool, value = value})
            end
        end
    end
    return items
end

-- ====== быстрая продажа ======
local function sellItem(tool)
    if not sellingActive then return false end
    
    -- Снимаем текущий инструмент мгновенно
    if character:FindFirstChildOfClass("Tool") then
        humanoid:UnequipTools()
    end
    
    -- Экипируем и сразу продаём
    pcall(function()
        humanoid:EquipTool(tool)
    end)
    
    -- Минимальная задержка для сервера
    task.wait(0.1)
    
    remote:FireServer(true)
    return true
end

local function monitorEquipped(tool)
    if not tool:IsA("Tool") then return end

    tool.Equipped:Connect(function()
        local success, value, displayText = pcall(function()
            return extractValue(extractTexts(tool))
        end)

        if success and displayText then
            print(("🎒 Вы взяли в руку: %s (%s)"):format(tool.Name, displayText))
        end
    end)
end

for _, tool in ipairs(backpack:GetChildren()) do
    monitorEquipped(tool)
end

-- Подключаем мониторинг для новых предметов, которые добавляются в рюкзак
backpack.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        monitorEquipped(child)
    end
end)

-- ====== основная быстрая петля ======
local function fastSellLoop()
    if not sellingActive then return end
    
    print("⚡ ЗАПУСК БЫСТРОЙ ПРОДАЖИ")
    
    local totalSold = 0
    
    while sellingActive do
        local itemsToSell = getItemsToSell()
        
        if #itemsToSell == 0 then
            print("✅ ВСЕ ПРЕДМЕТЫ ≥ $" .. MIN_VALUE)
            print("🎯 Продано всего: " .. totalSold)
            break
        end
        
        -- Продаём все подходящие предметы подряд без лишних ожиданий
        for _, item in ipairs(itemsToSell) do
            if not sellingActive then break end
            
            print(("⚡ Продаём: %s ($%d/s)"):format(item.tool.Name, item.value))
            
            if sellItem(item.tool) then
                totalSold = totalSold + 1
                print(("✅ Продано: %s | Всего: %d"):format(item.tool.Name, totalSold))
            end
            
            -- Задержка между продажами 0.2-0.3 секунды
            task.wait(0.25)
        end
        
        if sellingActive then
            -- Короткая пауза перед следующей проверкой backpack
            task.wait(0.1)
        end
    end
end

-- ====== мгновенная реакция на новые предметы ======
local function setupFastMonitor()
    backpack.ChildAdded:Connect(function(child)
        task.wait(0.1) -- Минимальная задержка для загрузки
        
        if child:IsA("Tool") and string.find(child.Name:lower(), keyword:lower()) then
            local success, value = pcall(function()
                return extractValue(extractTexts(child))
            end)
            
            if success and value and value < MIN_VALUE then
                print(("📦 Новый предмет для продажи: %s ($%d/s)"):format(child.Name, value))
                -- Немедленно запускаем продажу если автопродажа включена
                if sellingActive then
                    task.spawn(fastSellLoop)
                end
            end
        end
    end)
end

-- ====== ОБРАБОТЧИКИ КНОПОК ======
toggleButton.MouseButton1Click:Connect(function()
    sellingActive = not sellingActive
    updateButtons()
    
    if sellingActive then
        print("🚀 АВТОПРОДАЖА ВКЛЮЧЕНА")
        task.spawn(fastSellLoop)
    else
        print("🛑 АВТОПРОДАЖА ВЫКЛЮЧЕНА")
    end
end)

buyButton.MouseButton1Click:Connect(function()
    buyingActive = not buyingActive
    updateButtons()
    
    if buyingActive then
        print("🛒 АВТОПОКУПКА ВКЛЮЧЕНА")
        task.spawn(autoBuyLoop)
    else
        print("🛑 АВТОПОКУПКА ВЫКЛЮЧЕНА")
    end
end)

gearButton.MouseButton1Click:Connect(function()
    gearingActive = not gearingActive
    updateButtons()
    
    if gearingActive then
        print("🎒 АВТОПОКУПКА СНАРЯЖЕНИЯ ВКЛЮЧЕНА")
        task.spawn(autoGearLoop)
    else
        print("🛑 АВТОПОКУПКА СНАРЯЖЕНИЯ ВЫКЛЮЧЕНА")
    end
end)

miniButton.MouseButton1Click:Connect(function()
    toggleGUI()
end)

closeButton.MouseButton1Click:Connect(function()
    closeGUI()
end)

setupFastMonitor()
updateButtons()
print("✅ GUI загружена!")
print("📌 M - показать/скрыть интерфейс")
print("❌ X - полностью закрыть GUI")
print("🎯 Перетаскивайте за заголовок или кнопку M для перемещения")
print("🛒 Доступные функции: AutoSell | AutoBuy | AutoGear")
