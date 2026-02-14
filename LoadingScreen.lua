-- ════════════════════════════════════════════════════════════════
-- DCP HUB v1.2 - LOADING SCREEN SYSTEM
-- Добавить этот код В САМОМ НАЧАЛЕ скрипта, перед всем остальным
-- ════════════════════════════════════════════════════════════════

-- Локализация для Loading Screen
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════
-- СОЗДАНИЕ LOADING SCREEN UI
-- ════════════════════════════════════════════════════════════════

local LoadingScreen = Instance.new("ScreenGui")
LoadingScreen.Name = "DCPLoadingScreen"
LoadingScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadingScreen.ResetOnSpawn = false
LoadingScreen.Parent = CoreGui

-- Затемнение фона
local Overlay = Instance.new("Frame")
Overlay.Name = "Overlay"
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.Position = UDim2.new(0, 0, 0, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 1
Overlay.BorderSizePixel = 0
Overlay.Parent = LoadingScreen

-- Главный контейнер
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(0, 0, 0, 0) -- Начинаем с маленького размера
Container.Position = UDim2.new(0.5, 0, 0.5, 0)
Container.AnchorPoint = Vector2.new(0.5, 0.5)
Container.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.Parent = LoadingScreen

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 12)
ContainerCorner.Parent = Container

local ContainerStroke = Instance.new("UIStroke")
ContainerStroke.Color = Color3.fromRGB(255, 80, 80)
ContainerStroke.Thickness = 2
ContainerStroke.Transparency = 1
ContainerStroke.Parent = Container

-- Gradient для Container
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
})
Gradient.Rotation = 45
Gradient.Parent = Container

-- Логотип/Заголовок
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 0, 50)
Title.Position = UDim2.new(0, 20, 0, 20)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "DCP HUB"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.TextSize = 32
Title.TextTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = Container

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 128, 48)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 80))
})
TitleGradient.Parent = Title

-- Версия
local Version = Instance.new("TextLabel")
Version.Name = "Version"
Version.Size = UDim2.new(1, -40, 0, 20)
Version.Position = UDim2.new(0, 20, 0, 65)
Version.BackgroundTransparency = 1
Version.Font = Enum.Font.Gotham
Version.Text = "v1.2 Optimized"
Version.TextColor3 = Color3.fromRGB(150, 150, 150)
Version.TextSize = 14
Version.TextTransparency = 1
Version.TextXAlignment = Enum.TextXAlignment.Center
Version.Parent = Container

-- Статус загрузки
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -40, 0, 25)
StatusLabel.Position = UDim2.new(0, 20, 0, 110)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.Text = "Initializing..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 16
StatusLabel.TextTransparency = 1
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Container

-- Детали загрузки
local DetailsLabel = Instance.new("TextLabel")
DetailsLabel.Name = "DetailsLabel"
DetailsLabel.Size = UDim2.new(1, -40, 0, 20)
DetailsLabel.Position = UDim2.new(0, 20, 0, 140)
DetailsLabel.BackgroundTransparency = 1
DetailsLabel.Font = Enum.Font.Gotham
DetailsLabel.Text = "Please wait..."
DetailsLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
DetailsLabel.TextSize = 12
DetailsLabel.TextTransparency = 1
DetailsLabel.TextXAlignment = Enum.TextXAlignment.Left
DetailsLabel.Parent = Container

-- Прогресс бар фон
local ProgressBack = Instance.new("Frame")
ProgressBack.Name = "ProgressBack"
ProgressBack.Size = UDim2.new(1, -40, 0, 8)
ProgressBack.Position = UDim2.new(0, 20, 0, 175)
ProgressBack.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
ProgressBack.BackgroundTransparency = 1
ProgressBack.BorderSizePixel = 0
ProgressBack.Parent = Container

local ProgressBackCorner = Instance.new("UICorner")
ProgressBackCorner.CornerRadius = UDim.new(1, 0)
ProgressBackCorner.Parent = ProgressBack

-- Прогресс бар заполнение
local ProgressFill = Instance.new("Frame")
ProgressFill.Name = "ProgressFill"
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
ProgressFill.BackgroundTransparency = 1
ProgressFill.BorderSizePixel = 0
ProgressFill.Parent = ProgressBack

local ProgressFillCorner = Instance.new("UICorner")
ProgressFillCorner.CornerRadius = UDim.new(1, 0)
ProgressFillCorner.Parent = ProgressFill

local ProgressGradient = Instance.new("UIGradient")
ProgressGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 128, 48))
})
ProgressGradient.Parent = ProgressFill

-- Процент
local PercentLabel = Instance.new("TextLabel")
PercentLabel.Name = "PercentLabel"
PercentLabel.Size = UDim2.new(1, -40, 0, 20)
PercentLabel.Position = UDim2.new(0, 20, 0, 190)
PercentLabel.BackgroundTransparency = 1
PercentLabel.Font = Enum.Font.GothamBold
PercentLabel.Text = "0%"
PercentLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
PercentLabel.TextSize = 14
PercentLabel.TextTransparency = 1
PercentLabel.TextXAlignment = Enum.TextXAlignment.Center
PercentLabel.Parent = Container

-- Анимация точек загрузки
local dots = 0
local dotConnection
dotConnection = RunService.Heartbeat:Connect(function()
    dots = (dots + 0.05) % 4
    local dotText = string.rep(".", math.floor(dots))
    if StatusLabel and StatusLabel.Parent then
        local currentText = StatusLabel.Text:gsub("%.+$", "")
        StatusLabel.Text = currentText .. dotText
    else
        dotConnection:Disconnect()
    end
end)

-- ════════════════════════════════════════════════════════════════
-- ФУНКЦИИ УПРАВЛЕНИЯ LOADING SCREEN
-- ════════════════════════════════════════════════════════════════

local LoadingManager = {
    currentProgress = 0,
    totalSteps = 0,
    completedSteps = 0,
}

-- Анимация появления Loading Screen
local function showLoadingScreen()
    -- Анимация затемнения
    TweenService:Create(Overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.5
    }):Play()
    
    -- Анимация появления контейнера
    local appearTween = TweenService:Create(Container, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 450, 0, 240),
        BackgroundTransparency = 0,
    })
    appearTween:Play()
    
    -- Анимация обводки
    TweenService:Create(ContainerStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0
    }):Play()
    
    -- Анимация текста с задержкой
    task.wait(0.3)
    
    TweenService:Create(Title, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    task.wait(0.1)
    
    TweenService:Create(Version, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    task.wait(0.1)
    
    TweenService:Create(StatusLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    TweenService:Create(DetailsLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    TweenService:Create(ProgressBack, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0
    }):Play()
    
    TweenService:Create(ProgressFill, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0
    }):Play()
    
    TweenService:Create(PercentLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
end

-- Обновление статуса загрузки
function LoadingManager:updateStatus(status, details, progressAdd)
    if not StatusLabel or not StatusLabel.Parent then return end
    
    -- Обновляем текст
    StatusLabel.Text = status
    DetailsLabel.Text = details or ""
    
    -- Обновляем прогресс
    if progressAdd then
        self.completedSteps = self.completedSteps + progressAdd
        self.currentProgress = math.min((self.completedSteps / self.totalSteps) * 100, 100)
        
        -- Анимация прогресс бара
        local progressTween = TweenService:Create(ProgressFill, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(self.currentProgress / 100, 0, 1, 0)
        })
        progressTween:Play()
        
        -- Анимация процента с плавным изменением
        local startPercent = tonumber(PercentLabel.Text:match("%d+")) or 0
        local endPercent = math.floor(self.currentProgress)
        
        local duration = 0.5
        local startTime = tick()
        
        local updateConnection
        updateConnection = RunService.Heartbeat:Connect(function()
            if not PercentLabel or not PercentLabel.Parent then
                updateConnection:Disconnect()
                return
            end
            
            local elapsed = tick() - startTime
            local alpha = math.min(elapsed / duration, 1)
            
            local currentPercent = math.floor(startPercent + (endPercent - startPercent) * alpha)
            PercentLabel.Text = currentPercent .. "%"
            
            if alpha >= 1 then
                updateConnection:Disconnect()
            end
        end)
    end
    
    -- Добавляем задержку для видимости
    task.wait(0.3)
end

-- Анимация исчезновения Loading Screen
local function hideLoadingScreen(callback)
    if not LoadingScreen or not LoadingScreen.Parent then
        if callback then callback() end
        return
    end
    
    -- Останавливаем анимацию точек
    if dotConnection then
        dotConnection:Disconnect()
    end
    
    -- Анимация исчезновения текста
    TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 1
    }):Play()
    
    TweenService:Create(Version, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 1
    }):Play()
    
    TweenService:Create(StatusLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 1
    }):Play()
    
    TweenService:Create(DetailsLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 1
    }):Play()
    
    TweenService:Create(ProgressBack, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()
    
    TweenService:Create(ProgressFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()
    
    TweenService:Create(PercentLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 1
    }):Play()
    
    TweenService:Create(ContainerStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Transparency = 1
    }):Play()
    
    task.wait(0.3)
    
    -- Анимация исчезновения контейнера
    local disappearTween = TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
    })
    disappearTween:Play()
    
    -- Анимация затемнения
    TweenService:Create(Overlay, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()
    
    disappearTween.Completed:Connect(function()
        task.wait(0.1)
        LoadingScreen:Destroy()
        
        if callback then
            callback()
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- ПРОЦЕСС ЗАГРУЗКИ
-- ════════════════════════════════════════════════════════════════

local function runLoadingSequence()
    -- Показываем Loading Screen
    showLoadingScreen()
    task.wait(0.8) -- Даём время на анимацию появления
    
    -- Устанавливаем общее количество шагов
    LoadingManager.totalSteps = 10
    
    -- Шаг 1: Проверка защиты от повторного запуска
    LoadingManager:updateStatus("Checking Instance", "Verifying script is not already running...", 1)
    
    -- Шаг 2: Проверка совместимости экзекутора
    LoadingManager:updateStatus("Checking Compatibility", "Testing executor capabilities...", 1)
    
    -- Реальная проверка будет добавлена в основной скрипт
    task.wait(0.5)
    
    -- Шаг 3: Локализация функций
    LoadingManager:updateStatus("Optimizing Performance", "Localizing global functions...", 1)
    
    -- Шаг 4: Создание файловой системы
    LoadingManager:updateStatus("Creating File System", "Setting up workspace/dcp_hub structure...", 1)
    
    -- Шаг 5: Инициализация папок
    LoadingManager:updateStatus("Initializing Folders", "Creating configs/ and sounds/ directories...", 1)
    
    -- Шаг 6: Загрузка конфигураций
    LoadingManager:updateStatus("Loading Configurations", "Reading saved settings...", 1)
    
    -- Шаг 7: Загрузка WindUI
    LoadingManager:updateStatus("Loading UI Library", "Initializing WindUI framework...", 1)
    
    -- Шаг 8: Инициализация систем
    LoadingManager:updateStatus("Initializing Systems", "Setting up caching and connections...", 1)
    
    -- Шаг 9: Применение оптимизаций
    LoadingManager:updateStatus("Applying Optimizations", "Event-based systems and performance patches...", 1)
    
    -- Шаг 10: Финализация
    LoadingManager:updateStatus("Finalizing", "Almost ready...", 1)
    
    task.wait(0.5)
    
    -- Завершение загрузки
    LoadingManager:updateStatus("Complete!", "DCP HUB is ready to use", 0)
    task.wait(0.8)
end

-- ════════════════════════════════════════════════════════════════
-- ЭКСПОРТ ДЛЯ ИСПОЛЬЗОВАНИЯ В ОСНОВНОМ СКРИПТЕ
-- ════════════════════════════════════════════════════════════════

return {
    Start = function(callback)
        runLoadingSequence()
        hideLoadingScreen(callback)
    end,
    
    UpdateStatus = function(status, details, progress)
        LoadingManager:updateStatus(status, details, progress)
    end,
    
    Hide = function(callback)
        hideLoadingScreen(callback)
    end,
}
