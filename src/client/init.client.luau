local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--------------------------------------------------------------------------------
-- 1. CÁMARA FREECAM REAL (ESPECTADOR TOTALMENTE INDEPENDIENTE)
--------------------------------------------------------------------------------
player.CameraMinZoomDistance = 0.5
player.CameraMaxZoomDistance = 9999

local camYaw = 0
local camPitch = -math.rad(30)
local camPos = Vector3.new(0, 110, 190)

local isMouseDown = false
local keysDown = {
    [Enum.KeyCode.W] = false,
    [Enum.KeyCode.A] = false,
    [Enum.KeyCode.S] = false,
    [Enum.KeyCode.D] = false,
    [Enum.KeyCode.Q] = false,
    [Enum.KeyCode.E] = false,
    [Enum.KeyCode.LeftShift] = false,
}

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if keysDown[input.KeyCode] ~= nil then
        keysDown[input.KeyCode] = true
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        isMouseDown = true
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if keysDown[input.KeyCode] ~= nil then
        keysDown[input.KeyCode] = false
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        isMouseDown = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isMouseDown and input.UserInputType == Enum.UserInputType.MouseMovement then
        camYaw = camYaw - input.Delta.X * 0.003
        camPitch = math.clamp(camPitch - input.Delta.Y * 0.003, -math.rad(85), math.rad(85))
    elseif input.UserInputType == Enum.UserInputType.MouseWheel then
        local camRot = CFrame.Angles(0, camYaw, 0) * CFrame.Angles(camPitch, 0, 0)
        local zoomSpeed = if keysDown[Enum.KeyCode.LeftShift] then 45 else 22
        camPos = camPos + camRot.LookVector * (input.Position.Z * zoomSpeed)
    end
end)

RunService.RenderStepped:Connect(function(dt)
    camera.CameraType = Enum.CameraType.Scriptable

    local camRot = CFrame.Angles(0, camYaw, 0) * CFrame.Angles(camPitch, 0, 0)
    local moveDir = Vector3.zero

    local forward = camRot.LookVector
    local right = camRot.RightVector
    local up = Vector3.new(0, 1, 0)

    if keysDown[Enum.KeyCode.W] then moveDir = moveDir + forward end
    if keysDown[Enum.KeyCode.S] then moveDir = moveDir - forward end
    if keysDown[Enum.KeyCode.D] then moveDir = moveDir + right end
    if keysDown[Enum.KeyCode.A] then moveDir = moveDir - right end
    if keysDown[Enum.KeyCode.E] then moveDir = moveDir + up end
    if keysDown[Enum.KeyCode.Q] then moveDir = moveDir - up end

    local speed = if keysDown[Enum.KeyCode.LeftShift] then 220 else 110
    if moveDir.Magnitude > 0 then
        camPos = camPos + moveDir.Unit * (speed * dt)
    end

    camera.CFrame = CFrame.new(camPos) * camRot
end)

local function setupCharacter(character: Model)
    local hrp = character:WaitForChild("HumanoidRootPart", 5) :: BasePart?
    local hum = character:WaitForChild("Humanoid", 5) :: Humanoid?
    if hrp then
        hrp.Anchored = true
        hrp.CFrame = CFrame.new(0, 180, 0)
    end
    if hum then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
    end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        end
    end
end

if player.Character then
    setupCharacter(player.Character)
end
player.CharacterAdded:Connect(setupCharacter)

--------------------------------------------------------------------------------
-- 2. LOCALIZAR REMOTE EVENTS
--------------------------------------------------------------------------------
local remoteFolder = ReplicatedStorage:WaitForChild("SoccerRemotes") :: Folder
local startChargeEvent = remoteFolder:WaitForChild("StartCharge") :: RemoteEvent
local releaseShotEvent = remoteFolder:WaitForChild("ReleaseShot") :: RemoteEvent
local quickShotEvent = remoteFolder:WaitForChild("QuickShot") :: RemoteEvent
local ballPossessionEvent = remoteFolder:WaitForChild("BallPossession") :: RemoteEvent
local goalScoredEvent = remoteFolder:WaitForChild("GoalScored") :: RemoteEvent
local updateScoreEvent = remoteFolder:WaitForChild("UpdateScore") :: RemoteEvent
local shotCooldownEvent = remoteFolder:WaitForChild("ShotCooldown") :: RemoteEvent
local matchTimeEvent = remoteFolder:WaitForChild("MatchTimeUpdate") :: RemoteEvent
local goalAnnouncementEvent = remoteFolder:WaitForChild("GoalAnnouncement") :: RemoteEvent
local toggleMatchEvent = remoteFolder:WaitForChild("ToggleMatch") :: RemoteEvent
local foulAnnouncementEvent = remoteFolder:WaitForChild("FoulAnnouncement") :: RemoteEvent

--------------------------------------------------------------------------------
-- 3. INTERFAZ GRÁFICA TELEVISIVA: MARCADOR + RELOJ + NOMBRES DE CLUBES
--------------------------------------------------------------------------------
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SoccerPowerUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Contenedor Principal del Marcador (Estilo Broadcast televisivo)
local scoreBoard = Instance.new("Frame")
scoreBoard.Name = "ScoreBoard"
scoreBoard.Size = UDim2.new(0, 440, 0, 50)
scoreBoard.Position = UDim2.new(0.5, -220, 0.015, 0)
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
timeBox.Size = UDim2.new(0, 105, 1, 0)
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
matchBox.Size = UDim2.new(1, -105, 1, 0)
matchBox.Position = UDim2.new(0, 105, 0, 0)
matchBox.BackgroundTransparency = 1
matchBox.Parent = scoreBoard

local blueLabel = Instance.new("TextLabel")
blueLabel.Name = "BlueLabel"
blueLabel.Size = UDim2.new(0.42, 0, 1, 0)
blueLabel.Position = UDim2.new(0, 5, 0, 0)
blueLabel.BackgroundTransparency = 1
blueLabel.Text = "EQUIPO A  0"
blueLabel.TextColor3 = Color3.fromRGB(65, 185, 255)
blueLabel.Font = Enum.Font.GothamBold
blueLabel.TextSize = 15
blueLabel.TextXAlignment = Enum.TextXAlignment.Center
blueLabel.Parent = matchBox

local dividerLabel = Instance.new("TextLabel")
dividerLabel.Name = "Divider"
dividerLabel.Size = UDim2.new(0.16, 0, 1, 0)
dividerLabel.Position = UDim2.new(0.42, 0, 0, 0)
dividerLabel.BackgroundTransparency = 1
dividerLabel.Text = "-"
dividerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
dividerLabel.Font = Enum.Font.GothamBold
dividerLabel.TextSize = 18
dividerLabel.Parent = matchBox

local redLabel = Instance.new("TextLabel")
redLabel.Name = "RedLabel"
redLabel.Size = UDim2.new(0.42, 0, 1, 0)
redLabel.Position = UDim2.new(0.58, -5, 0, 0)
redLabel.BackgroundTransparency = 1
redLabel.Text = "0  EQUIPO B"
redLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
redLabel.Font = Enum.Font.GothamBold
redLabel.TextSize = 15
redLabel.TextXAlignment = Enum.TextXAlignment.Center
redLabel.Parent = matchBox

-- 3. Banner de Estado (Descanso, Final, etc.)
local statusBanner = Instance.new("Frame")
statusBanner.Name = "StatusBanner"
statusBanner.Size = UDim2.new(0, 300, 0, 26)
statusBanner.Position = UDim2.new(0.5, -150, 0, 54)
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

-- 4. Botón Interactivo para Iniciar / Pausar Partido (reemplaza /bot)
local playButton = Instance.new("TextButton")
playButton.Name = "PlayMatchButton"
playButton.Size = UDim2.new(0, 130, 0, 36)
playButton.Position = UDim2.new(0, 18, 0.015, 0)
playButton.BackgroundColor3 = Color3.fromRGB(0, 170, 85)
playButton.BorderSizePixel = 0
playButton.Text = "▶ JUGAR"
playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
playButton.Font = Enum.Font.GothamBlack
playButton.TextSize = 14
playButton.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = playButton

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(255, 255, 255)
btnStroke.Thickness = 1.5
btnStroke.Transparency = 0.5
btnStroke.Parent = playButton

local isMatchPlaying = false

playButton.MouseButton1Click:Connect(function()
    toggleMatchEvent:FireServer()
    isMatchPlaying = not isMatchPlaying
    if isMatchPlaying then
        playButton.Text = "⏹ DETENER"
        playButton.BackgroundColor3 = Color3.fromRGB(210, 45, 45)
    else
        playButton.Text = "▶ JUGAR"
        playButton.BackgroundColor3 = Color3.fromRGB(0, 170, 85)
    end
end)

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

-- Evento de actualización de goles con nombres de club
local curClubA = "EQUIPO A"
local curClubB = "EQUIPO B"

updateScoreEvent.OnClientEvent:Connect(function(blueScore: number, redScore: number, clubAName: string?, clubBName: string?)
    if clubAName and clubAName ~= "" then curClubA = clubAName end
    if clubBName and clubBName ~= "" then curClubB = clubBName end

    blueLabel.Text = string.format("%s  %d", curClubA, blueScore)
    redLabel.Text = string.format("%d  %s", redScore, curClubB)

    TweenService:Create(scoreBoard, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 460, 0, 54),
        Position = UDim2.new(0.5, -230, 0.012, 0)
    }):Play()
    task.delay(0.2, function()
        TweenService:Create(scoreBoard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 440, 0, 50),
            Position = UDim2.new(0.5, -220, 0.015, 0)
        }):Play()
    end)
end)

--------------------------------------------------------------------------------
-- 4. NOTIFICACIÓN VISIBLE Y ELEGANTE DE ANUNCIO DE GOL
--------------------------------------------------------------------------------
local goalAnnounceFrame = Instance.new("Frame")
goalAnnounceFrame.Name = "GoalAnnounceBanner"
goalAnnounceFrame.Size = UDim2.new(0, 620, 0, 68)
goalAnnounceFrame.Position = UDim2.new(0.5, -310, 0.12, 0)
goalAnnounceFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
goalAnnounceFrame.BorderSizePixel = 0
goalAnnounceFrame.Visible = false
goalAnnounceFrame.ZIndex = 20
goalAnnounceFrame.Parent = screenGui

local gCorner = Instance.new("UICorner")
gCorner.CornerRadius = UDim.new(0, 10)
gCorner.Parent = goalAnnounceFrame

local gStroke = Instance.new("UIStroke")
gStroke.Color = Color3.fromRGB(255, 215, 0)
gStroke.Thickness = 2.5
gStroke.Parent = goalAnnounceFrame

local goalTitleLabel = Instance.new("TextLabel")
goalTitleLabel.Name = "GoalTitle"
goalTitleLabel.Size = UDim2.new(1, 0, 0.45, 0)
goalTitleLabel.Position = UDim2.new(0, 0, 0.05, 0)
goalTitleLabel.BackgroundTransparency = 1
goalTitleLabel.Text = "⚽ ¡GOOOOL! ⚽"
goalTitleLabel.TextColor3 = Color3.fromRGB(255, 220, 40)
goalTitleLabel.Font = Enum.Font.GothamBlack
goalTitleLabel.TextSize = 22
goalTitleLabel.ZIndex = 21
goalTitleLabel.Parent = goalAnnounceFrame

local goalDetailLabel = Instance.new("TextLabel")
goalDetailLabel.Name = "GoalDetail"
goalDetailLabel.Size = UDim2.new(1, -20, 0.45, 0)
goalDetailLabel.Position = UDim2.new(0, 10, 0.5, 0)
goalDetailLabel.BackgroundTransparency = 1
goalDetailLabel.Text = "Real Madriz - Leo Messi (23')"
goalDetailLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
goalDetailLabel.Font = Enum.Font.GothamBold
goalDetailLabel.TextSize = 18
goalDetailLabel.ZIndex = 21
goalDetailLabel.Parent = goalAnnounceFrame

goalAnnouncementEvent.OnClientEvent:Connect(function(scorerName: string, clubName: string, minuteText: string, isOwnGoal: boolean)
    if isOwnGoal then
        goalTitleLabel.Text = "⚠️ ¡GOL EN PROPIA PUERTA! ⚠️"
        goalTitleLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
        goalDetailLabel.Text = string.format("%s - %s (%s)", clubName, scorerName, minuteText)
    else
        goalTitleLabel.Text = "⚽ ¡GOOOOL! ⚽"
        goalTitleLabel.TextColor3 = Color3.fromRGB(255, 220, 40)
        goalDetailLabel.Text = string.format("%s - %s (%s)", clubName, scorerName, minuteText)
    end

    goalAnnounceFrame.Position = UDim2.new(0.5, -310, 0.05, 0)
    goalAnnounceFrame.Visible = true

    TweenService:Create(goalAnnounceFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -310, 0.12, 0)
    }):Play()

    task.delay(4.0, function()
        local tweenOut = TweenService:Create(goalAnnounceFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -310, 0.04, 0)
        })
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            goalAnnounceFrame.Visible = false
        end)
    end)
end)

--------------------------------------------------------------------------------
-- 4.1 BANNER DE ANUNCIO DE FALTA Y PENALTI
--------------------------------------------------------------------------------
local foulAnnounceFrame = Instance.new("Frame")
foulAnnounceFrame.Name = "FoulAnnouncementFrame"
foulAnnounceFrame.Size = UDim2.new(0, 520, 0, 80)
foulAnnounceFrame.Position = UDim2.new(0.5, -260, 0.05, 0)
foulAnnounceFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
foulAnnounceFrame.BorderSizePixel = 0
foulAnnounceFrame.Visible = false
foulAnnounceFrame.ZIndex = 25
foulAnnounceFrame.Parent = screenGui

local foulCorner = Instance.new("UICorner")
foulCorner.CornerRadius = UDim.new(0, 10)
foulCorner.Parent = foulAnnounceFrame

local foulStroke = Instance.new("UIStroke")
foulStroke.Name = "FoulStroke"
foulStroke.Color = Color3.fromRGB(255, 215, 0)
foulStroke.Thickness = 3
foulStroke.Parent = foulAnnounceFrame

local foulTitleLabel = Instance.new("TextLabel")
foulTitleLabel.Name = "FoulTitle"
foulTitleLabel.Size = UDim2.new(1, 0, 0, 42)
foulTitleLabel.Position = UDim2.new(0, 0, 0, 6)
foulTitleLabel.BackgroundTransparency = 1
foulTitleLabel.Text = "¡FALTA!"
foulTitleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
foulTitleLabel.Font = Enum.Font.GothamBlack
foulTitleLabel.TextSize = 28
foulTitleLabel.ZIndex = 26
foulTitleLabel.Parent = foulAnnounceFrame

local foulDescLabel = Instance.new("TextLabel")
foulDescLabel.Name = "FoulDesc"
foulDescLabel.Size = UDim2.new(1, -20, 0, 26)
foulDescLabel.Position = UDim2.new(0, 10, 0, 48)
foulDescLabel.BackgroundTransparency = 1
foulDescLabel.Text = "Infracción sancionada por el árbitro"
foulDescLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
foulDescLabel.Font = Enum.Font.GothamBold
foulDescLabel.TextSize = 14
foulDescLabel.ZIndex = 26
foulDescLabel.Parent = foulAnnounceFrame

foulAnnouncementEvent.OnClientEvent:Connect(function(titleText: string, descText: string, isPenalty: boolean)
    foulTitleLabel.Text = titleText
    foulDescLabel.Text = descText

    if isPenalty then
        foulTitleLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        foulStroke.Color = Color3.fromRGB(255, 60, 60)
        foulAnnounceFrame.BackgroundColor3 = Color3.fromRGB(35, 12, 12)
    else
        foulTitleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        foulStroke.Color = Color3.fromRGB(255, 215, 0)
        foulAnnounceFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    end

    foulAnnounceFrame.Position = UDim2.new(0.5, -260, 0.04, 0)
    foulAnnounceFrame.Visible = true

    TweenService:Create(foulAnnounceFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -260, 0.13, 0)
    }):Play()

    task.delay(3.2, function()
        local tweenOut = TweenService:Create(foulAnnounceFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -260, 0.04, 0)
        })
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            foulAnnounceFrame.Visible = false
        end)
    end)
end)

--------------------------------------------------------------------------------
-- 5. BARRA DE POTENCIA Y COOLDOWN DE DISPARO
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

--------------------------------------------------------------------------------
-- 6. LÓGICA DE DISPARO DEL JUGADOR
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
