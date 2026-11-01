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

--------------------------------------------------------------------------------
-- 3. INTERFAZ GRÁFICA: MARCADOR + BARRA DE POTENCIA + COOLDOWN + GOL
--------------------------------------------------------------------------------
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SoccerPowerUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Marcador Superior
local scoreBoard = Instance.new("Frame")
scoreBoard.Name = "ScoreBoard"
scoreBoard.Size = UDim2.new(0, 260, 0, 48)
scoreBoard.Position = UDim2.new(0.5, -130, 0.02, 0)
scoreBoard.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
scoreBoard.BorderSizePixel = 0
scoreBoard.Parent = screenGui

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 10)
sbCorner.Parent = scoreBoard

local sbStroke = Instance.new("UIStroke")
sbStroke.Color = Color3.fromRGB(255, 255, 255)
sbStroke.Thickness = 2
sbStroke.Transparency = 0.3
sbStroke.Parent = scoreBoard

local blueScoreLabel = Instance.new("TextLabel")
blueScoreLabel.Size = UDim2.new(0.42, 0, 1, 0)
blueScoreLabel.Position = UDim2.new(0, 0, 0, 0)
blueScoreLabel.BackgroundTransparency = 1
blueScoreLabel.Text = "AZUL: 0"
blueScoreLabel.TextColor3 = Color3.fromRGB(70, 175, 255)
blueScoreLabel.Font = Enum.Font.GothamBold
blueScoreLabel.TextSize = 18
blueScoreLabel.Parent = scoreBoard

local vsLabel = Instance.new("TextLabel")
vsLabel.Size = UDim2.new(0.16, 0, 1, 0)
vsLabel.Position = UDim2.new(0.42, 0, 0, 0)
vsLabel.BackgroundTransparency = 1
vsLabel.Text = "-"
vsLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
vsLabel.Font = Enum.Font.GothamBold
vsLabel.TextSize = 20
vsLabel.Parent = scoreBoard

local redScoreLabel = Instance.new("TextLabel")
redScoreLabel.Size = UDim2.new(0.42, 0, 1, 0)
redScoreLabel.Position = UDim2.new(0.58, 0, 0, 0)
redScoreLabel.BackgroundTransparency = 1
redScoreLabel.Text = "0 :ROJO"
redScoreLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
redScoreLabel.Font = Enum.Font.GothamBold
redScoreLabel.TextSize = 18
redScoreLabel.Parent = scoreBoard

updateScoreEvent.OnClientEvent:Connect(function(blueScore: number, redScore: number)
    blueScoreLabel.Text = string.format("AZUL: %d", blueScore)
    redScoreLabel.Text = string.format("%d :ROJO", redScore)

    TweenService:Create(scoreBoard, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 280, 0, 54),
        Position = UDim2.new(0.5, -140, 0.015, 0)
    }):Play()
    task.delay(0.2, function()
        TweenService:Create(scoreBoard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 260, 0, 48),
            Position = UDim2.new(0.5, -130, 0.02, 0)
        }):Play()
    end)
end)

-- Barra de potencia
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

local fillBar = Instance.new("Frame")
fillBar.Name = "FillBar"
fillBar.Size = UDim2.new(0, 0, 1, 0)
fillBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
fillBar.BorderSizePixel = 0
fillBar.Parent = barContainer

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 8)
fillCorner.Parent = fillBar

local label = Instance.new("TextLabel")
label.Name = "PowerLabel"
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "POTENCIA: 1%"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.ZIndex = 3
label.Parent = barContainer

-- Indicador de Cooldown (5 segundos)
local cdLabel = Instance.new("TextLabel")
cdLabel.Name = "ShotCooldownLabel"
cdLabel.Size = UDim2.new(0, 220, 0, 24)
cdLabel.Position = UDim2.new(0.5, -110, 0.74, 0)
cdLabel.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
cdLabel.BackgroundTransparency = 0.2
cdLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
cdLabel.Font = Enum.Font.GothamBold
cdLabel.TextSize = 13
cdLabel.Visible = false
cdLabel.Parent = screenGui

local cdCorner = Instance.new("UICorner")
cdCorner.CornerRadius = UDim.new(0, 6)
cdCorner.Parent = cdLabel

local eHint = Instance.new("TextLabel")
eHint.Name = "QuickShotHint"
eHint.Size = UDim2.new(0, 240, 0, 22)
eHint.Position = UDim2.new(0.5, -120, 0.84, 0)
eHint.BackgroundTransparency = 1
eHint.Text = "[E] Disparo Rápido Instantáneo"
eHint.TextColor3 = Color3.fromRGB(255, 220, 80)
eHint.Font = Enum.Font.GothamBold
eHint.TextSize = 13
eHint.Visible = false
eHint.Parent = screenGui

local goalFrame = Instance.new("Frame")
goalFrame.Name = "GoalCelebrationFrame"
goalFrame.Size = UDim2.new(1, 0, 1, 0)
goalFrame.Position = UDim2.new(0, 0, 0, 0)
goalFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
goalFrame.BackgroundTransparency = 1
goalFrame.Visible = false
goalFrame.ZIndex = 10
goalFrame.Parent = screenGui

local goalBanner = Instance.new("Frame")
goalBanner.Name = "Banner"
goalBanner.Size = UDim2.new(1, 0, 0, 140)
goalBanner.Position = UDim2.new(0, 0, 0.5, -70)
goalBanner.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
goalBanner.BackgroundTransparency = 0.2
goalBanner.BorderSizePixel = 0
goalBanner.Parent = goalFrame

local goalText = Instance.new("TextLabel")
goalText.Size = UDim2.new(1, 0, 0.65, 0)
goalText.Position = UDim2.new(0, 0, 0, 0)
goalText.BackgroundTransparency = 1
goalText.Text = "⚽ ¡¡¡GOOOOOOL!!!"
goalText.TextColor3 = Color3.fromRGB(255, 220, 0)
goalText.Font = Enum.Font.FredokaOne
goalText.TextScaled = true
goalText.Parent = goalBanner

local goalSubText = Instance.new("TextLabel")
goalSubText.Size = UDim2.new(1, 0, 0.35, 0)
goalSubText.Position = UDim2.new(0, 0, 0.65, 0)
goalSubText.BackgroundTransparency = 1
goalSubText.Text = "¡Tanto en la portería!"
goalSubText.TextColor3 = Color3.fromRGB(255, 255, 255)
goalSubText.Font = Enum.Font.GothamBold
goalSubText.TextScaled = true
goalSubText.Parent = goalBanner

goalScoredEvent.OnClientEvent:Connect(function(goalTeam: string)
    if goalTeam == "Azul" then
        goalSubText.Text = "¡Gol del Equipo Rojo!"
        goalSubText.TextColor3 = Color3.fromRGB(255, 80, 80)
    else
        goalSubText.Text = "¡Gol del Equipo Azul!"
        goalSubText.TextColor3 = Color3.fromRGB(80, 180, 255)
    end

    goalFrame.Visible = true
    goalBanner.Position = UDim2.new(0, 0, 0.5, -90)
    goalBanner.BackgroundTransparency = 0.2

    TweenService:Create(goalBanner, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0.5, -70)
    }):Play()

    task.delay(1.0, function()
        local fadeTween = TweenService:Create(goalBanner, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0, 0, 0.5, -120),
            BackgroundTransparency = 1
        })
        fadeTween:Play()
        fadeTween.Completed:Connect(function()
            goalFrame.Visible = false
        end)
    end)
end)

--------------------------------------------------------------------------------
-- 4. ESTADO LOCAL Y GESTIÓN DEL COOLDOWN DE 5s
--------------------------------------------------------------------------------
local hasBall = false
local isCharging = false
local chargeStartTime = 0
local MAX_CHARGE_DURATION = 1.6
local shotCooldownEnd = 0

shotCooldownEvent.OnClientEvent:Connect(function(duration: number)
    shotCooldownEnd = os.clock() + duration
end)

local function isCooldownActive(): boolean
    return os.clock() < shotCooldownEnd
end

ballPossessionEvent.OnClientEvent:Connect(function(state: boolean)
    hasBall = state
    eHint.Visible = hasBall
    if not hasBall and isCharging then
        isCharging = false
        barContainer.Visible = false
    end
end)

local function isHoldingBall(): boolean
    if hasBall then return true end
    local char = player.Character
    if char and char:FindFirstChild("BallControlRing") then
        return true
    end
    return false
end

local function playKickAnimation()
    local char = player.Character
    if not char then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local rightUpperLeg = char:FindFirstChild("RightUpperLeg") :: BasePart?
    local rightHip = rightUpperLeg and rightUpperLeg:FindFirstChild("RightHip") :: Motor6D?

    local torso = char:FindFirstChild("Torso") :: BasePart?
    local r6RightHip = torso and torso:FindFirstChild("Right Hip") :: Motor6D?

    if rightHip then
        local origC0 = rightHip.C0
        local kickC0 = origC0 * CFrame.Angles(math.rad(-75), 0, 0)
        local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tweenReturn = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

        TweenService:Create(rightHip, tweenInfo, {C0 = kickC0}):Play()
        task.delay(0.09, function()
            TweenService:Create(rightHip, tweenReturn, {C0 = origC0}):Play()
        end)
    elseif r6RightHip then
        local origC0 = r6RightHip.C0
        local kickC0 = origC0 * CFrame.Angles(math.rad(75), 0, 0)
        local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tweenReturn = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

        TweenService:Create(r6RightHip, tweenInfo, {C0 = kickC0}):Play()
        task.delay(0.09, function()
            TweenService:Create(r6RightHip, tweenReturn, {C0 = origC0}):Play()
        end)
    end
end

-- A) Carga con Click Izquierdo (Respeta Cooldown de 5s)
UserInputService.InputBegan:Connect(function(input, _gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if isHoldingBall() and not isCharging and not isCooldownActive() then
            isCharging = true
            chargeStartTime = os.clock()
            barContainer.Visible = true
            fillBar.Size = UDim2.new(0.01, 0, 1, 0)
            fillBar.BackgroundColor3 = Color3.fromRGB(255, 45, 45)
            label.Text = "POTENCIA: 1%"

            startChargeEvent:FireServer()
        end
    -- B) Disparo instantáneo con la tecla E (Respeta Cooldown de 5s)
    elseif input.KeyCode == Enum.KeyCode.E then
        if isHoldingBall() and not isCharging and not isCooldownActive() then
            hasBall = false
            eHint.Visible = false

            local lookVector = camera.CFrame.LookVector
            local shootDirection = Vector3.new(lookVector.X, math.clamp(lookVector.Y * 0.5, 0.05, 0.4), lookVector.Z).Unit

            playKickAnimation()
            quickShotEvent:FireServer(shootDirection)
        end
    end
end)

-- Soltar Click Izquierdo
UserInputService.InputEnded:Connect(function(input, _gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if isCharging then
            isCharging = false
            barContainer.Visible = false
            hasBall = false
            eHint.Visible = false

            local lookVector = camera.CFrame.LookVector
            local shootDirection = Vector3.new(lookVector.X, math.clamp(lookVector.Y * 0.6, 0.05, 0.5), lookVector.Z).Unit

            playKickAnimation()
            releaseShotEvent:FireServer(shootDirection)
        end
    end
end)

-- Actualización progresiva en pantalla (Barra de Potencia y Temporizador de Cooldown)
RunService.RenderStepped:Connect(function()
    -- Mostrar tiempo restante de Cooldown si está activo
    local now = os.clock()
    if now < shotCooldownEnd then
        local remain = shotCooldownEnd - now
        cdLabel.Visible = true
        cdLabel.Text = string.format("⏳ Disparo en: %.1fs", remain)
    else
        cdLabel.Visible = false
    end

    if isCharging and isHoldingBall() then
        local elapsed = now - chargeStartTime
        local ratio = math.clamp(elapsed / MAX_CHARGE_DURATION, 0.01, 1.0)
        local percentage = math.floor(ratio * 100)

        local color: Color3
        if ratio < 0.5 then
            local t = ratio / 0.5
            color = Color3.fromRGB(255, math.floor(45 + t * 180), 45)
        else
            local t = (ratio - 0.5) / 0.5
            color = Color3.fromRGB(math.floor(255 - t * 205), 225, 45)
        end

        fillBar.BackgroundColor3 = color
        fillBar.Size = UDim2.new(ratio, 0, 1, 0)
        label.Text = string.format("POTENCIA: %d%%", percentage)
    end
end)

print("[CLIENTE] Gran Estadio, Zona de Saque, Cooldown 5s y Sprint Bots listos.")
