local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--------------------------------------------------------------------------------
-- 1. CONFIGURACIÓN DEL PERSONAJE: BLOQUEO DE SALTO Y SPRINT CON SHIFT BASADO EN STATS
--------------------------------------------------------------------------------
local WALK_SPEED = 16
local SPRINT_SPEED = 28

local function getCustomSpeeds(): (number, number)
    local char = player.Character
    if char then
        local spdVal = char:FindFirstChild("Stat_Speed")
        if spdVal and spdVal:IsA("NumberValue") then
            local speedStat = spdVal.Value
            local wSpd = 14 + (speedStat / 100) * 10
            local sSpd = 22 + (speedStat / 100) * 14
            return wSpd, sSpd
        end
    end
    return WALK_SPEED, SPRINT_SPEED
end

local isSprinting = false

local function setupCharacter(character: Model)
    local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
    if humanoid then
        humanoid.JumpPower = 0
        humanoid.JumpHeight = 0
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        
        local wSpd = getCustomSpeeds()
        humanoid.WalkSpeed = wSpd
        
        local spdVal = character:WaitForChild("Stat_Speed", 5)
        if spdVal and spdVal:IsA("NumberValue") then
            spdVal:GetPropertyChangedSignal("Value"):Connect(function()
                local curW, curS = getCustomSpeeds()
                humanoid.WalkSpeed = if isSprinting then curS else curW
            end)
            local curW, curS = getCustomSpeeds()
            humanoid.WalkSpeed = if isSprinting then curS else curW
        end
    end
end

if player.Character then
    setupCharacter(player.Character)
end
player.CharacterAdded:Connect(setupCharacter)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        isSprinting = true
        local char = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local _, sSpd = getCustomSpeeds()
            humanoid.WalkSpeed = sSpd
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, _gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        isSprinting = false
        local char = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local wSpd, _ = getCustomSpeeds()
            humanoid.WalkSpeed = wSpd
        end
    end
end)

--------------------------------------------------------------------------------
-- 2. LOCALIZAR REMOTE EVENTS
--------------------------------------------------------------------------------
local remoteFolder = ReplicatedStorage:WaitForChild("SoccerRemotes", 15) :: Folder
local startChargeEvent = remoteFolder:WaitForChild("StartCharge", 15) :: RemoteEvent
local releaseShotEvent = remoteFolder:WaitForChild("ReleaseShot", 15) :: RemoteEvent
local quickShotEvent = remoteFolder:WaitForChild("QuickShot", 15) :: RemoteEvent
local ballPossessionEvent = remoteFolder:WaitForChild("BallPossession", 15) :: RemoteEvent
local goalScoredEvent = remoteFolder:WaitForChild("GoalScored", 15) :: RemoteEvent
local updateScoreEvent = remoteFolder:WaitForChild("UpdateScore", 15) :: RemoteEvent
local shotCooldownEvent = remoteFolder:WaitForChild("ShotCooldown", 15) :: RemoteEvent
local matchTimeEvent = remoteFolder:WaitForChild("MatchTimeUpdate", 15) :: RemoteEvent

--------------------------------------------------------------------------------
-- 3. INTERFAZ GRÁFICA TELEVISIVA: MARCADOR + RELOJ 90 MIN + ESTADOS
--------------------------------------------------------------------------------
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SoccerPowerUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Contenedor Principal del Marcador (Estilo Broadcast)
local scoreBoard = Instance.new("Frame")
scoreBoard.Name = "ScoreBoard"
scoreBoard.Size = UDim2.new(0, 360, 0, 48)
scoreBoard.Position = UDim2.new(0.5, -180, 0.015, 0)
scoreBoard.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
scoreBoard.BorderSizePixel = 0
scoreBoard.Parent = screenGui

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 8)
sbCorner.Parent = scoreBoard

local sbStroke = Instance.new("UIStroke")
sbStroke.Color = Color3.fromRGB(255, 255, 255)
sbStroke.Thickness = 1.5
sbStroke.Transparency = 0.5
sbStroke.Parent = scoreBoard

-- 1. Caja de Tiempo / Minuto (Izquierda)
local timeBox = Instance.new("Frame")
timeBox.Name = "TimeBox"
timeBox.Size = UDim2.new(0, 95, 1, 0)
timeBox.Position = UDim2.new(0, 0, 0, 0)
timeBox.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
timeBox.BorderSizePixel = 0
timeBox.Parent = scoreBoard

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 8)
tbCorner.Parent = timeBox

local timeLabel = Instance.new("TextLabel")
timeLabel.Name = "TimeLabel"
timeLabel.Size = UDim2.new(1, 0, 1, 0)
timeLabel.BackgroundTransparency = 1
timeLabel.Text = "00:00"
timeLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
timeLabel.Font = Enum.Font.GothamBold
timeLabel.TextSize = 16
timeLabel.Parent = timeBox

-- 2. Equipos y Resultado (Centro - Derecha)
local matchBox = Instance.new("Frame")
matchBox.Name = "MatchBox"
matchBox.Size = UDim2.new(1, -95, 1, 0)
matchBox.Position = UDim2.new(0, 95, 0, 0)
matchBox.BackgroundTransparency = 1
matchBox.Parent = scoreBoard

local blueLabel = Instance.new("TextLabel")
blueLabel.Name = "BlueLabel"
blueLabel.Size = UDim2.new(0.38, 0, 1, 0)
blueLabel.Position = UDim2.new(0, 0, 0, 0)
blueLabel.BackgroundTransparency = 1
blueLabel.Text = "AZUL 0"
blueLabel.TextColor3 = Color3.fromRGB(65, 175, 255)
blueLabel.Font = Enum.Font.GothamBold
blueLabel.TextSize = 16
blueLabel.Parent = matchBox

local dividerLabel = Instance.new("TextLabel")
dividerLabel.Name = "Divider"
dividerLabel.Size = UDim2.new(0.24, 0, 1, 0)
dividerLabel.Position = UDim2.new(0.38, 0, 0, 0)
dividerLabel.BackgroundTransparency = 1
dividerLabel.Text = "-"
dividerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
dividerLabel.Font = Enum.Font.GothamBold
dividerLabel.TextSize = 18
dividerLabel.Parent = matchBox

local redLabel = Instance.new("TextLabel")
redLabel.Name = "RedLabel"
redLabel.Size = UDim2.new(0.38, 0, 1, 0)
redLabel.Position = UDim2.new(0.62, 0, 0, 0)
redLabel.BackgroundTransparency = 1
redLabel.Text = "0 ROJO"
redLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
redLabel.Font = Enum.Font.GothamBold
redLabel.TextSize = 16
redLabel.Parent = matchBox

-- 3. Banner de Estado (Descanso, Final, etc.)
local statusBanner = Instance.new("Frame")
statusBanner.Name = "StatusBanner"
statusBanner.Size = UDim2.new(0, 260, 0, 26)
statusBanner.Position = UDim2.new(0.5, -130, 0, 52)
statusBanner.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
statusBanner.BorderSizePixel = 0
statusBanner.Visible = false
statusBanner.Parent = scoreBoard

local sbCorner2 = Instance.new("UICorner")
sbCorner2.CornerRadius = UDim.new(0, 6)
sbCorner2.Parent = statusBanner

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "PRIMERA PARTE"
statusLabel.TextColor3 = Color3.fromRGB(255, 230, 120)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 13
statusLabel.Parent = statusBanner

-- Evento de actualización del tiempo de partido
matchTimeEvent.OnClientEvent:Connect(function(minuteText: string, statusText: string, showBanner: boolean)
    timeLabel.Text = minuteText
    if showBanner then
        statusBanner.Visible = true
        statusLabel.Text = statusText
    else
        statusBanner.Visible = false
    end
end)

-- Evento de actualización de goles
updateScoreEvent.OnClientEvent:Connect(function(blueScore: number, redScore: number)
    blueLabel.Text = string.format("AZUL %d", blueScore)
    redLabel.Text = string.format("%d ROJO", redScore)

    TweenService:Create(scoreBoard, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 380, 0, 52),
        Position = UDim2.new(0.5, -190, 0.012, 0)
    }):Play()
    task.delay(0.2, function()
        TweenService:Create(scoreBoard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 360, 0, 48),
            Position = UDim2.new(0.5, -180, 0.015, 0)
        }):Play()
    end)
end)

--------------------------------------------------------------------------------
-- 4. BARRA DE POTENCIA Y COOLDOWN DE DISPARO
--------------------------------------------------------------------------------
local barContainer = Instance.new("Frame")
barContainer.Name = "PowerBarContainer"
barContainer.Size = UDim2.new(0, 280, 0, 28)
barContainer.Position = UDim2.new(0.5, -140, 0.78, 0)
barContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
barContainer.BorderSizePixel = 0
barContainer.Visible = false
barContainer.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = barContainer

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 2
stroke.Parent = barContainer

local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(50, 220, 80)
fill.BorderSizePixel = 0
fill.Parent = barContainer

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 8)
fillCorner.Parent = fill

local fillGradient = Instance.new("UIGradient")
fillGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 220, 80)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 40, 40))
})
fillGradient.Parent = fill

local powerText = Instance.new("TextLabel")
powerText.Size = UDim2.new(1, 0, 1, 0)
powerText.BackgroundTransparency = 1
powerText.Text = "POTENCIA: 0%"
powerText.TextColor3 = Color3.fromRGB(255, 255, 255)
powerText.Font = Enum.Font.GothamBold
powerText.TextSize = 14
powerText.ZIndex = 2
powerText.Parent = barContainer

-- Indicador visual de Cooldown
local cooldownLabel = Instance.new("TextLabel")
cooldownLabel.Name = "CooldownLabel"
cooldownLabel.Size = UDim2.new(0, 280, 0, 24)
cooldownLabel.Position = UDim2.new(0.5, -140, 0.825, 0)
cooldownLabel.BackgroundTransparency = 1
cooldownLabel.Text = "⏳ ENFRIAMIENTO: 0.0s"
cooldownLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
cooldownLabel.Font = Enum.Font.GothamBold
cooldownLabel.TextSize = 13
cooldownLabel.Visible = false
cooldownLabel.Parent = screenGui

shotCooldownEvent.OnClientEvent:Connect(function(duration: number)
    cooldownLabel.Visible = true
    local startTime = os.clock()
    task.spawn(function()
        while true do
            local elapsed = os.clock() - startTime
            local remaining = math.max(0, duration - elapsed)
            if remaining <= 0 then break end
            cooldownLabel.Text = string.format("⏳ ENFRIAMIENTO: %.1fs", remaining)
            task.wait(0.05)
        end
        cooldownLabel.Visible = false
    end)
end)

-- Letrero Gigante de GOL
local goalLabel = Instance.new("TextLabel")
goalLabel.Name = "GoalLabel"
goalLabel.Size = UDim2.new(0, 500, 0, 100)
goalLabel.Position = UDim2.new(0.5, -250, 0.35, 0)
goalLabel.BackgroundTransparency = 1
goalLabel.Text = "⚽ ¡GOL! ⚽"
goalLabel.TextColor3 = Color3.fromRGB(255, 230, 0)
goalLabel.Font = Enum.Font.GothamBlack
goalLabel.TextScaled = true
goalLabel.Visible = false
goalLabel.ZIndex = 10
goalLabel.Parent = screenGui

local goalStroke = Instance.new("UIStroke")
goalStroke.Color = Color3.fromRGB(0, 0, 0)
goalStroke.Thickness = 5
goalStroke.Parent = goalLabel

goalScoredEvent.OnClientEvent:Connect(function(team: string)
    goalLabel.Text = string.format("⚽ ¡GOL DEL EQUIPO %s! ⚽", string.upper(team))
    goalLabel.TextColor3 = if team == "Azul" then Color3.fromRGB(70, 175, 255) else Color3.fromRGB(255, 75, 75)
    goalLabel.Visible = true
    goalLabel.Size = UDim2.new(0, 300, 0, 60)
    goalLabel.Position = UDim2.new(0.5, -150, 0.38, 0)

    TweenService:Create(goalLabel, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 600, 0, 120),
        Position = UDim2.new(0.5, -300, 0.32, 0)
    }):Play()

    task.delay(1.5, function()
        goalLabel.Visible = false
    end)
end)

--------------------------------------------------------------------------------
-- 5. LÓGICA DE DISPARO DEL JUGADOR
--------------------------------------------------------------------------------
local hasBall = false
local isCharging = false
local chargeStartTime = 0
local MAX_CHARGE_TIME = 1.6

ballPossessionEvent.OnClientEvent:Connect(function(state: boolean)
    hasBall = state
    if not hasBall and isCharging then
        isCharging = false
        barContainer.Visible = false
        fill.Size = UDim2.new(0, 0, 1, 0)
    end
end)

local function getAimDirection(): Vector3
    local mouseRay = camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    if player.Character then
        raycastParams.FilterDescendantsInstances = {player.Character}
    end

    local result = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 1000, raycastParams)
    local hitPoint = if result then result.Position else (mouseRay.Origin + mouseRay.Direction * 200)

    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if hrp then
        local dir = (hitPoint - hrp.Position)
        if dir.Magnitude > 0.1 then
            return dir.Unit
        end
    end
    return mouseRay.Direction.Unit
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not hasBall then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isCharging = true
        chargeStartTime = os.clock()
        barContainer.Visible = true
        startChargeEvent:FireServer()
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        local aimDir = getAimDirection()
        quickShotEvent:FireServer(aimDir)
    end
end)

UserInputService.InputEnded:Connect(function(input, _gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and isCharging then
        isCharging = false
        barContainer.Visible = false
        fill.Size = UDim2.new(0, 0, 1, 0)

        local aimDir = getAimDirection()
        releaseShotEvent:FireServer(aimDir)
    end
end)

RunService.RenderStepped:Connect(function()
    if isCharging and hasBall then
        local elapsed = os.clock() - chargeStartTime
        local ratio = math.clamp(elapsed / MAX_CHARGE_TIME, 0, 1)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        powerText.Text = string.format("POTENCIA: %d%%", math.floor(ratio * 100))
    end
end)
