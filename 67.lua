-- WindUI Chat & Morph Script
-- Полный перенос функционала + система конфигов

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════
-- ПЕРЕМЕННЫЕ СОСТОЯНИЯ
-- ════════════════════════════════════════════════════════════════
local State = {
    -- Chata
    chatEnabled = false,
    chatMessage = "workby!88!",
    originalDisplayName = player.DisplayName ~= "" and player.DisplayName or player.Name,
    
    -- Name Changers
    usernameChangerEnabled = false,
    displayNameChangerEnabled = false,
    rankChangerEnabled = false,
    
    gameUsername = "",
    gameDisplayName = "",
    gameRank = "",
    
    -- Avatar
    avatarUsername = "",
    avatarAutoApply = true,
    savedAvatarUsername = "",
    
    -- Rainbow
    rainbowEnabled = false,
    rainbowSpeed = 1,
    rainbowCustomColor = Color3.fromRGB(255, 80, 80),
    rainbowUseCustomColor = false,
    
    -- UI Toggles
    uiHidden = false,
    killfeedHidden = false,
    
    -- Keybinds
    menuKeybind = "Insert",
    
    -- Hit Sound
    hitSoundActive = false,
    hitSoundVolume = 4.0,
    hitSoundMinDist = 50,
    hitSoundMaxDist = 500,
}

-- ════════════════════════════════════════════════════════════════
-- ЗАГРУЗКА WINDUI
-- ════════════════════════════════════════════════════════════════
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- ════════════════════════════════════════════════════════════════
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ════════════════════════════════════════════════════════════════

-- TextChat канал
local channel
pcall(function()
    channel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
end)

-- Поиск игрока по имени
local function findPlayerByName(partialName)
    if not partialName or partialName == "" then return nil end
    local searchName = partialName:lower()
    
    local localPlayer = nil
    for _, v in ipairs(Players:GetPlayers()) do
        local nameLower = v.Name:lower()
        local dNameLower = v.DisplayName:lower()
        
        if nameLower == searchName or dNameLower == searchName then
            return v
        end
        
        if nameLower:sub(1, #searchName) == searchName or dNameLower:sub(1, #searchName) == searchName then
            localPlayer = v
        end
    end
    
    if not localPlayer then
        local success, userId = pcall(function()
            return Players:GetUserIdFromNameAsync(searchName)
        end)
        if success and userId then
            return {UserId = userId, Name = searchName}
        end
    end
    
    return localPlayer
end

-- Morph к игроку
local function morphToPlayer(target)
    if not target then return end
    
    local userId = target.UserId or (type(target) == "number" and target or target.UserId)
    local targetName = target.Name or "Unknown"
    
    if userId == player.UserId then return end
    
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end

    local success, desc = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    if not success or not desc then return end

    for _, obj in ipairs(character:GetChildren()) do
        if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or
           obj:IsA("Accessory") or obj:IsA("BodyColors") then
            obj:Destroy()
        end
    end
    
    local head = character:FindFirstChild("Head")
    if head then
        for _, decal in ipairs(head:GetChildren()) do
            if decal:IsA("Decal") then decal:Destroy() end
        end
    end

    pcall(function()
        humanoid:ApplyDescriptionClientServer(desc)
    end)
end

-- Изменение nametag
local function changeNameTag(displayName, username, rank)
    local char = player.Character
    if not char then return end
    
    local head = char:FindFirstChild("Head")
    if not head then return end
    
    local nameTag = head:FindFirstChild("NameTag")
    if not nameTag then return end
    
    local usernameLabel = nameTag:FindFirstChild("Username")
    local displayLabel = nameTag:FindFirstChild("DisplayName")
    local rankLabel = nameTag:FindFirstChild("Rank")
    
    if usernameLabel and usernameLabel:IsA("TextLabel") and State.displayNameChangerEnabled and displayName ~= "" then
        usernameLabel.Text = displayName
    end
    
    if displayLabel and displayLabel:IsA("TextLabel") and State.usernameChangerEnabled and username ~= "" then
        local formattedUsername = username
        if not formattedUsername:match("^@") then
            formattedUsername = "@" .. formattedUsername
        end
        displayLabel.Text = formattedUsername
    end
    
    if rankLabel and rankLabel:IsA("TextLabel") and State.rankChangerEnabled then
        rankLabel.Text = rank or ""
    end
end

-- Применение всех настроек имени
local function applyAllNameChanges()
    changeNameTag(State.gameDisplayName, State.gameUsername, State.gameRank)
end

-- Скрытие UI элементов
local function toggleGameUI()
    local success, ui = pcall(function()
        return player.PlayerGui:WaitForChild("UI"):WaitForChild("Container"):WaitForChild("HUD")
    end)
    
    if not success or not ui then return end
    
    local map = ui:FindFirstChild("Map")
    local menu = ui:FindFirstChild("Menu")
    local topbar = ui:FindFirstChild("Topbar")
    
    if map then map.Visible = not State.uiHidden end
    if menu then menu.Visible = not State.uiHidden end
    if topbar then topbar.Visible = not State.uiHidden end
end

-- Скрытие killfeed
local function toggleKillfeed()
    local success, killfeed = pcall(function()
        return player.PlayerGui:WaitForChild("UI"):WaitForChild("Container"):WaitForChild("HUD"):WaitForChild("Killfeed")
    end)
    
    if success and killfeed then
        killfeed.Visible = not State.killfeedHidden
    end
end

-- Отправка сообщения в чат
local lastSend = 0
local function safeSend(msg)
    if not channel then return end
    local now = tick()
    if now - lastSend < 1 then return end
    lastSend = now
    pcall(function() channel:SendAsync(msg) end)
end

-- Trim строки
local function trim(s)
    return s:match("^%s*(.-)%s*$") or s
end

-- Сравнение имён
local function equalsName(text, target)
    if not text or not target then return false end
    text = trim(tostring(text))
    target = trim(tostring(target))
    if text == "" or target == "" then return false end
    return string.lower(text) == string.lower(target) or 
           string.find(string.lower(text), string.lower(target), 1, true)
end

-- ════════════════════════════════════════════════════════════════
-- HIT SOUND ФУНКЦИИ (V17)
-- ════════════════════════════════════════════════════════════════

local CUSTOM_SOUND_FILE = "head.mp3"
local SOUNDS_FOLDER = "hit_sound"

local function getAsset(path)
    if not isfile or not isfile(path) then return nil end
    local func = getcustomasset or getsynasset
    if type(func) == "function" then
        return func(path)
    end
    return nil
end

local myId = getAsset(SOUNDS_FOLDER .. "/" .. CUSTOM_SOUND_FILE) or getAsset(CUSTOM_SOUND_FILE)

local BANNED_IDS = {
    ["363818432"] = true, ["363818488"] = true, ["363818567"] = true, 
    ["363818611"] = true, ["363818653"] = true
}

local hitSoundConnection = nil

local function startHitSound()
    if hitSoundConnection then hitSoundConnection:Disconnect() end
    
    hitSoundConnection = game.DescendantAdded:Connect(function(sound)
        if not sound:IsA("Sound") then return end
        
        task.spawn(function()
            local id = sound.SoundId:match("%d+")
            if BANNED_IDS[id] then
                sound.Volume = 0
                sound:Stop()
                
                if myId then
                    local newSound = Instance.new("Sound")
                    newSound.SoundId = myId
                    newSound.Volume = State.hitSoundVolume
                    
                    -- ПРИМЕНЕНИЕ ДИСТАНЦИИ
                    newSound.RollOffMinDistance = State.hitSoundMinDist
                    newSound.RollOffMaxDistance = State.hitSoundMaxDist
                    
                    newSound.Parent = sound.Parent or game:GetService("SoundService")
                    newSound:Play()
                    game:GetService("Debris"):AddItem(newSound, 2)
                end
                
                task.wait(0.1)
                if sound then sound:Destroy() end
            end
        end)
    end)
end

local function stopHitSound()
    if hitSoundConnection then
        hitSoundConnection:Disconnect()
        hitSoundConnection = nil
    end
end

-- ════════════════════════════════════════════════════════════════
-- СОЗДАНИЕ WINDUI ОКНА
-- ════════════════════════════════════════════════════════════════
local Window = WindUI:CreateWindow({
    Title = "Chat & Morph Hub  |  by .alowyy1",
    Folder = "ChatMorphHub",
    Icon = "lucide:messages-square",
    NewElements = true,
    HideSearchBar = false,
    
    OpenButton = {
        Title = "Open Chat Hub",
        CornerRadius = UDim.new(0, 8),
        StrokeThickness = 2,
        Enabled = false,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.5,
        Color = ColorSequence.new(
            Color3.fromHex("#FF5050"), 
            Color3.fromHex("#FF8030")
        )
    },
    
    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
})

Window:Tag({
    Title = "v1.0",
    Icon = "lucide:sparkles",
    Color = Color3.fromHex("#FF5050"),
    Border = true,
})

-- ════════════════════════════════════════════════════════════════
-- ВКЛАДКА: CHAT
-- ════════════════════════════════════════════════════════════════
local ChatTab = Window:Tab({
    Title = "Chat",
    Icon = "lucide:message-square",
    IconColor = Color3.fromHex("#10C550"),
    Border = true,
})

ChatTab:Section({
    Title = "Чат настройки",
    TextSize = 18,
})

ChatTab:Input({
    Flag = "ChatMessage",
    Title = "Сообщение в чат",
    Icon = "lucide:message-circle",
    Value = State.chatMessage,
    Placeholder = "Введи сообщение...",
    Callback = function(value)
        State.chatMessage = value
    end
})

ChatTab:Space()

ChatTab:Input({
    Flag = "OriginalDisplayName",
    Title = "Твой родной DisplayName",
    Icon = "lucide:user",
    Value = State.originalDisplayName,
    Placeholder = "DisplayName...",
    Callback = function(value)
        State.originalDisplayName = value
    end
})

ChatTab:Space()

ChatTab:Toggle({
    Flag = "ChatEnabled",
    Title = "Включить чат при убийстве",
    Desc = "Автоматически отправляет сообщение когда ты убиваешь",
    Value = State.chatEnabled,
    Callback = function(value)
        State.chatEnabled = value
    end
})

ChatTab:Space()

ChatTab:Button({
    Title = "Протестировать сообщение",
    Icon = "lucide:send",
    Justify = "Center",
    Color = Color3.fromHex("#10C550"),
    Callback = function()
        safeSend(State.chatMessage)
        WindUI:Notify({
            Title = "Тест отправки",
            Content = "Сообщение отправлено: " .. State.chatMessage,
            Icon = "lucide:check",
        })
    end
})

-- ════════════════════════════════════════════════════════════════
-- ВКЛАДКА: NAME
-- ════════════════════════════════════════════════════════════════
local NameTab = Window:Tab({
    Title = "Name",
    Icon = "lucide:user-round",
    IconColor = Color3.fromHex("#7775F2"),
    Border = true,
})

-- Username Section
local UsernameSection = NameTab:Section({
    Title = "Username (@username)",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

UsernameSection:Input({
    Flag = "GameUsername",
    Title = "Username",
    Icon = "lucide:at-sign",
    Value = State.gameUsername,
    Placeholder = "Без @...",
    Callback = function(value)
        State.gameUsername = value
        if State.usernameChangerEnabled then
            applyAllNameChanges()
        end
    end
})

UsernameSection:Space()

UsernameSection:Toggle({
    Flag = "UsernameChangerEnabled",
    Title = "Включить Username Changer",
    Value = State.usernameChangerEnabled,
    Callback = function(value)
        State.usernameChangerEnabled = value
        applyAllNameChanges()
    end
})

NameTab:Space()

-- DisplayName Section
local DisplayNameSection = NameTab:Section({
    Title = "DisplayName (главное имя)",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

DisplayNameSection:Input({
    Flag = "GameDisplayName",
    Title = "DisplayName",
    Icon = "lucide:user",
    Value = State.gameDisplayName,
    Placeholder = "Новый DisplayName...",
    Callback = function(value)
        State.gameDisplayName = value
        if State.displayNameChangerEnabled then
            applyAllNameChanges()
        end
    end
})

DisplayNameSection:Space()

DisplayNameSection:Toggle({
    Flag = "DisplayNameChangerEnabled",
    Title = "Включить DisplayName Changer",
    Value = State.displayNameChangerEnabled,
    Callback = function(value)
        State.displayNameChangerEnabled = value
        applyAllNameChanges()
    end
})

NameTab:Space()

-- Rank Section
local RankSection = NameTab:Section({
    Title = "Rank (звание/статус)",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

RankSection:Input({
    Flag = "GameRank",
    Title = "Rank",
    Icon = "lucide:crown",
    Value = State.gameRank,
    Placeholder = "Новый Rank...",
    Callback = function(value)
        State.gameRank = value
        if State.rankChangerEnabled then
            applyAllNameChanges()
        end
    end
})

RankSection:Space()

RankSection:Toggle({
    Flag = "RankChangerEnabled",
    Title = "Включить Rank Changer",
    Value = State.rankChangerEnabled,
    Callback = function(value)
        State.rankChangerEnabled = value
        applyAllNameChanges()
    end
})

NameTab:Space()

-- Apply Button
NameTab:Button({
    Title = "Применить все изменения имени",
    Icon = "lucide:check",
    Justify = "Center",
    Color = Color3.fromHex("#7775F2"),
    Callback = function()
        applyAllNameChanges()
        WindUI:Notify({
            Title = "Имя обновлено",
            Content = "Все изменения применены!",
            Icon = "lucide:check",
        })
    end
})

NameTab:Space()

-- Custom Color Section
local CustomColorSection = NameTab:Section({
    Title = "Кастомный цвет имени",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

CustomColorSection:Colorpicker({
    Flag = "RainbowCustomColor",
    Title = "Цвет имени",
    Default = State.rainbowCustomColor,
    Callback = function(color)
        State.rainbowCustomColor = color
        State.rainbowUseCustomColor = true
        State.rainbowEnabled = false
    end
})

CustomColorSection:Space()

CustomColorSection:Toggle({
    Flag = "RainbowUseCustomColor",
    Title = "Использовать кастомный цвет",
    Value = State.rainbowUseCustomColor,
    Callback = function(value)
        State.rainbowUseCustomColor = value
        State.rainbowEnabled = false
    end
})

NameTab:Space()

-- Rainbow Section
local RainbowSection = NameTab:Section({
    Title = "Rainbow эффект",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

RainbowSection:Slider({
    Flag = "RainbowSpeed",
    Title = "Скорость радуги",
    Step = 0.1,
    IsTooltip = true,
    Value = {
        Min = 0.1,
        Max = 5,
        Default = State.rainbowSpeed,
    },
    Callback = function(value)
        State.rainbowSpeed = value
    end
})

RainbowSection:Space()

RainbowSection:Toggle({
    Flag = "RainbowEnabled",
    Title = "Включить LGBT режим",
    Desc = "Радужное имя",
    Value = State.rainbowEnabled,
    Callback = function(value)
        State.rainbowEnabled = value
        State.rainbowUseCustomColor = false
    end
})

-- ════════════════════════════════════════════════════════════════
-- ВКЛАДКА: AVATAR
-- ════════════════════════════════════════════════════════════════
local AvatarTab = Window:Tab({
    Title = "Avatar",
    Icon = "lucide:user-round-cog",
    IconColor = Color3.fromHex("#ECA201"),
    Border = true,
})

AvatarTab:Section({
    Title = "Avatar Changer",
    TextSize = 18,
})

AvatarTab:Input({
    Flag = "AvatarUsername",
    Title = "Username игрока",
    Icon = "lucide:user-search",
    Value = State.avatarUsername,
    Placeholder = "Введи имя игрока...",
    Callback = function(value)
        State.avatarUsername = value
    end
})

AvatarTab:Space()

AvatarTab:Button({
    Title = "Применить аватар",
    Icon = "lucide:user-round-check",
    Justify = "Center",
    Color = Color3.fromHex("#ECA201"),
    Callback = function()
        if State.avatarUsername == "" then
            WindUI:Notify({
                Title = "Ошибка",
                Content = "Введи имя игрока!",
                Icon = "lucide:x",
            })
            return
        end
        
        local target = findPlayerByName(State.avatarUsername)
        if target then
            State.savedAvatarUsername = target.Name or State.avatarUsername
            morphToPlayer(target)
            
            WindUI:Notify({
                Title = "Скин применён!",
                Content = "Скин игрока \"" .. (target.Name or State.avatarUsername) .. "\" установлен.",
                Icon = "lucide:check",
            })
        else
            WindUI:Notify({
                Title = "Игрок не найден",
                Content = "Не удалось найти игрока",
                Icon = "lucide:x",
            })
        end
    end
})

AvatarTab:Space()

AvatarTab:Toggle({
    Flag = "AvatarAutoApply",
    Title = "Auto Apply при респавне",
    Desc = "Автоматически применяет аватар после смерти",
    Value = State.avatarAutoApply,
    Callback = function(value)
        State.avatarAutoApply = value
    end
})

-- ════════════════════════════════════════════════════════════════
-- ВКЛАДКА: UI
-- ════════════════════════════════════════════════════════════════
local UITab = Window:Tab({
    Title = "UI",
    Icon = "lucide:eye-off",
    IconColor = Color3.fromHex("#257AF7"),
    Border = true,
})

UITab:Section({
    Title = "Скрытие элементов интерфейса",
    TextSize = 18,
})

UITab:Toggle({
    Flag = "HideIngameUI",
    Title = "Скрыть игровой UI",
    Desc = "Скрывает карту, меню и topbar",
    Value = State.uiHidden,
    Callback = function(value)
        State.uiHidden = value
        toggleGameUI()
    end
})

UITab:Space()

UITab:Toggle({
    Flag = "HideKillfeed",
    Title = "Скрыть килфид",
    Desc = "Скрывает список убийств",
    Value = State.killfeedHidden,
    Callback = function(value)
        State.killfeedHidden = value
        toggleKillfeed()
    end
})

UITab:Space()

UITab:Section({
    Title = "Управление меню",
    TextSize = 18,
})

UITab:Keybind({
    Flag = "MenuKeybind",
    Title = "Клавиша открытия меню",
    Value = State.menuKeybind,
    Callback = function(value)
        State.menuKeybind = value
        Window:SetToggleKey(Enum.KeyCode[value])
    end
})

-- ════════════════════════════════════════════════════════════════
-- ВКЛАДКА: MISC
-- ════════════════════════════════════════════════════════════════
local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "lucide:sliders",
    IconColor = Color3.fromHex("#FF6B6B"),
    Border = true,
})

MiscTab:Section({
    Title = "Hit Sound (V17)",
    TextSize = 18,
})

MiscTab:Button({
    Title = "Включить Hit Sound",
    Icon = "lucide:volume-2",
    Justify = "Center",
    Color = Color3.fromHex("#FF6B6B"),
    Callback = function()
        State.hitSoundActive = true
        startHitSound()
        WindUI:Notify({
            Title = "Hit Sound активирован",
            Content = "Звук при попадании включен!",
            Icon = "lucide:check",
        })
        print("✅ Hit Sound V17: Активирован")
    end
})

MiscTab:Space()

MiscTab:Button({
    Title = "Отключить Hit Sound",
    Icon = "lucide:volume-x",
    Justify = "Center",
    Color = Color3.fromHex("#555555"),
    Callback = function()
        State.hitSoundActive = false
        stopHitSound()
        WindUI:Notify({
            Title = "Hit Sound деактивирован",
            Content = "Звук при попадании отключен",
            Icon = "lucide:x",
        })
        print("❌ Hit Sound V17: Деактивирован")
    end
})

MiscTab:Space()

MiscTab:Slider({
    Flag = "HitSoundVolume",
    Title = "Громкость звука",
    Step = 0.1,
    IsTooltip = true,
    Value = {
        Min = 0,
        Max = 10,
        Default = State.hitSoundVolume,
    },
    Callback = function(value)
        State.hitSoundVolume = value
    end
})

MiscTab:Space()

MiscTab:Slider({
    Flag = "HitSoundMinDist",
    Title = "Мин. дистанция (RollOffMin)",
    Step = 10,
    IsTooltip = true,
    Value = {
        Min = 0,
        Max = 500,
        Default = State.hitSoundMinDist,
    },
    Callback = function(value)
        State.hitSoundMinDist = value
    end
})

MiscTab:Space()

MiscTab:Slider({
    Flag = "HitSoundMaxDist",
    Title = "Макс. дистанция (RollOffMax)",
    Step = 10,
    IsTooltip = true,
    Value = {
        Min = 0,
        Max = 1000,
        Default = State.hitSoundMaxDist,
    },
    Callback = function(value)
        State.hitSoundMaxDist = value
    end
})

-- ════════════════════════════════════════════════════════════════
-- ВКЛАДКА: CONFIG
-- ════════════════════════════════════════════════════════════════
local ConfigTab = Window:Tab({
    Title = "Config",
    Icon = "lucide:settings",
    IconColor = Color3.fromHex("#83889E"),
    Border = true,
})

local ConfigManager = Window.ConfigManager
local ConfigName = "default"

ConfigTab:Section({
    Title = "Система конфигов",
    TextSize = 18,
})

local ConfigNameInput = ConfigTab:Input({
    Title = "Название конфига",
    Icon = "lucide:file-cog",
    Value = ConfigName,
    Callback = function(value)
        ConfigName = value
    end
})

ConfigTab:Space()

local AllConfigs = ConfigManager:AllConfigs()
local DefaultValue = table.find(AllConfigs, ConfigName) and ConfigName or nil

local AllConfigsDropdown = ConfigTab:Dropdown({
    Title = "Выбрать конфиг",
    Desc = "Выбери существующий конфиг",
    Values = AllConfigs,
    Value = DefaultValue,
    Callback = function(value)
        ConfigName = value
        ConfigNameInput:Set(value)
    end
})

ConfigTab:Space()

local ConfigButtonsGroup = ConfigTab:Group()

ConfigButtonsGroup:Button({
    Title = "Загрузить",
    Icon = "lucide:download",
    Justify = "Center",
    Color = Color3.fromHex("#10C550"),
    Callback = function()
        Window.CurrentConfig = ConfigManager:CreateConfig(ConfigName)
        if Window.CurrentConfig:Load() then
            WindUI:Notify({
                Title = "Конфиг загружен",
                Content = "Конфиг '" .. ConfigName .. "' успешно загружен",
                Icon = "lucide:check",
            })
        end
    end
})

ConfigButtonsGroup:Space()

ConfigButtonsGroup:Button({
    Title = "Сохранить",
    Icon = "lucide:save",
    Justify = "Center",
    Color = Color3.fromHex("#257AF7"),
    Callback = function()
        Window.CurrentConfig = ConfigManager:Config(ConfigName)
        if Window.CurrentConfig:Save() then
            WindUI:Notify({
                Title = "Конфиг сохранён",
                Content = "Конфиг '" .. ConfigName .. "' успешно сохранён",
                Icon = "lucide:check",
            })
        end
        
        AllConfigsDropdown:Refresh(ConfigManager:AllConfigs())
    end
})

ConfigTab:Space()

ConfigTab:Button({
    Title = "Создать новый конфиг",
    Icon = "lucide:file-plus",
    Justify = "Center",
    Callback = function()
        if ConfigName == "" then
            WindUI:Notify({
                Title = "Ошибка",
                Content = "Введи название конфига!",
                Icon = "lucide:x",
            })
            return
        end
        
        Window.CurrentConfig = ConfigManager:Config(ConfigName)
        Window.CurrentConfig:Save()
        
        WindUI:Notify({
            Title = "Конфиг создан",
            Content = "Конфиг '" .. ConfigName .. "' создан!",
            Icon = "lucide:check",
        })
        
        AllConfigsDropdown:Refresh(ConfigManager:AllConfigs())
    end
})

-- ════════════════════════════════════════════════════════════════
-- СИСТЕМА АВТОМАТИЧЕСКОГО ПРИМЕНЕНИЯ
-- ════════════════════════════════════════════════════════════════

-- Авто-применение при респавне
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    char:WaitForChild("Head")
    
    task.wait(0.5)
    
    -- Применяем аватар если включен auto-apply
    if State.avatarAutoApply and State.savedAvatarUsername ~= "" then
        local target = findPlayerByName(State.savedAvatarUsername)
        if target then
            morphToPlayer(target)
            task.wait(0.2)
        end
    end
    
    -- Применяем изменения имени
    applyAllNameChanges()
end)

-- ════════════════════════════════════════════════════════════════
-- RAINBOW СИСТЕМА
-- ════════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    
    local head = char:FindFirstChild("Head")
    if not head then return end
    
    local nameTag = head:FindFirstChild("NameTag")
    if not nameTag then return end
    
    local usernameLabel = nameTag:FindFirstChild("Username")
    if not usernameLabel or not usernameLabel:IsA("TextLabel") then return end
    
    if State.rainbowEnabled then
        local hue = (tick() * State.rainbowSpeed * 50) % 360
        local color = Color3.fromHSV(hue / 360, 1, 1)
        usernameLabel.TextColor3 = color
    elseif State.rainbowUseCustomColor then
        usernameLabel.TextColor3 = State.rainbowCustomColor
    end
end)

-- ════════════════════════════════════════════════════════════════
-- KILLFEED HOOK СИСТЕМА
-- ════════════════════════════════════════════════════════════════
local function hookKillfeed()
    local success, feed = pcall(function()
        return player:WaitForChild("PlayerGui"):WaitForChild("UI", 5):WaitForChild("Container", 2):WaitForChild("HUD", 2):WaitForChild("Killfeed", 2):WaitForChild("Feed", 2)
    end)
    if not success or not feed then return end
    
    feed.ChildAdded:Connect(function(element)
        if not State.chatEnabled then return end
        local conns = {}
        
        local function cleanup()
            for _, c in ipairs(conns) do
                if c and c.Disconnect then pcall(function() c:Disconnect() end) end
            end
            conns = {}
        end
        
        for _, desc in ipairs(element:GetDescendants()) do
            if desc:IsA("TextLabel") then
                local targetName = State.originalDisplayName
                if equalsName(desc.Text, targetName) then
                    safeSend(State.chatMessage)
                    break
                end
            end
        end
        
        local function onDescAdded(desc)
            if desc:IsA("TextLabel") then
                local conn = desc:GetPropertyChangedSignal("Text"):Connect(function()
                    if not State.chatEnabled then
                        pcall(function() conn:Disconnect() end)
                        return
                    end
                    local targetName = State.originalDisplayName
                    if equalsName(desc.Text, targetName) then
                        safeSend(State.chatMessage)
                    end
                end)
                table.insert(conns, conn)
            end
        end
        
        table.insert(conns, element.DescendantAdded:Connect(onDescAdded))
        
        local ancestryConn
        ancestryConn = element.AncestryChanged:Connect(function(_, parent)
            if not parent then
                cleanup()
                if ancestryConn then pcall(function() ancestryConn:Disconnect() end) end
            end
        end)
        table.insert(conns, ancestryConn)
    end)
end

task.spawn(hookKillfeed)

-- ════════════════════════════════════════════════════════════════
-- АВТОМАТИЧЕСКОЕ СКРЫТИЕ UI И KILLFEED
-- ════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(3)
        
        if State.uiHidden then
            local success, ui = pcall(function()
                return player.PlayerGui:WaitForChild("UI", 1):WaitForChild("Container", 1):WaitForChild("HUD", 1)
            end)
            
            if success and ui then
                local map = ui:FindFirstChild("Map")
                local menu = ui:FindFirstChild("Menu")
                local topbar = ui:FindFirstChild("Topbar")
                
                if map and map.Visible then map.Visible = false end
                if menu and menu.Visible then menu.Visible = false end
                if topbar and topbar.Visible then topbar.Visible = false end
            end
        end
        
        if State.killfeedHidden then
            local success, killfeed = pcall(function()
                return player.PlayerGui:WaitForChild("UI", 1):WaitForChild("Container", 1):WaitForChild("HUD", 1):WaitForChild("Killfeed", 1)
            end)
            
            if success and killfeed and killfeed.Visible then
                killfeed.Visible = false
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════
-- УВЕДОМЛЕНИЕ О ЗАГРУЗКЕ
-- ════════════════════════════════════════════════════════════════
WindUI:Notify({
    Title = "Chat & Morph Hub загружен!",
    Content = "Скрипт успешно инициализирован. Нажми " .. State.menuKeybind .. " чтобы открыть меню",
    Icon = "lucide:check-circle",
    Duration = 5,
})

print("═══════════════════════════════════════════════════════════")
print("Chat & Morph Hub v1.0 by .ftgs")
print("Hit Sound V17 интегрирован")
print("Успешно загружен!")
print("═══════════════════════════════════════════════════════════")
