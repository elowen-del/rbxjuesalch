local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")

print("=======================================")
print("[SERVIDOR] Futbol Avanzado: Stats de Jugadores, Pases Tácticos y Disparos Aéreos")
print("=======================================")

--------------------------------------------------------------------------------
-- 1. CONFIGURACIÓN DE COLISIONES
--------------------------------------------------------------------------------
pcall(function()
    PhysicsService:RegisterCollisionGroup("CharactersGroup")
    PhysicsService:RegisterCollisionGroup("SoccerBallGroup")
    PhysicsService:CollisionGroupSetCollidable("SoccerBallGroup", "CharactersGroup", false)
    PhysicsService:CollisionGroupSetCollidable("SoccerBallGroup", "Default", true)
end)

local function setupCharacterCollision(character: Model)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                part.CollisionGroup = "CharactersGroup"
            end)
        end
    end
    character.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("BasePart") then
            pcall(function()
                descendant.CollisionGroup = "CharactersGroup"
            end)
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(setupCharacterCollision)
    if player.Character then
        setupCharacterCollision(player.Character)
    end
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p.Character then
        setupCharacterCollision(p.Character)
    end
end

--------------------------------------------------------------------------------
-- 2. CONSTRUCCIÓN DEL GRAN ESTADIO
--------------------------------------------------------------------------------
local FIELD_SIZE = Vector2.new(280, 170)
local WALL_HEIGHT = 22
local WALL_THICKNESS = 3
local GOAL_WIDTH = 28
local GOAL_HEIGHT = 11
local GOAL_DEPTH = 13

-- El césped tiene Y = 0 (grosor 1 stud, la cara superior está en Y = 0.5)
local FIELD_Y = 0.51

local pitchFolder = workspace:FindFirstChild("SoccerPitch")
if pitchFolder then
    pitchFolder:Destroy()
end
pitchFolder = Instance.new("Folder")
pitchFolder.Name = "SoccerPitch"
pitchFolder.Parent = workspace

local function createFieldPart(name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material, transparency: number?): Part
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Color = color
    p.Material = material
    p.Transparency = transparency or 0
    p.Anchored = true
    p.CanCollide = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = pitchFolder
    return p
end

-- Césped
createFieldPart("CespedePrincipal", Vector3.new(FIELD_SIZE.X, 1, FIELD_SIZE.Y), Vector3.new(0, 0, 0), Color3.fromRGB(40, 140, 50), Enum.Material.Grass)

-- Línea central divisoria plana al ras (Y = 0.51)
createFieldPart("LineaCentro", Vector3.new(1.2, 0.02, FIELD_SIZE.Y), Vector3.new(0, FIELD_Y, 0), Color3.fromRGB(240, 240, 240), Enum.Material.SmoothPlastic)

-- Aro central hueco y mate (exactamente alineado en Y = 0.51)
local ringMeshPart = Instance.new("Part")
ringMeshPart.Name = "AroCentralHueco"
ringMeshPart.Size = Vector3.new(30, 0.02, 30)
ringMeshPart.Position = Vector3.new(0, FIELD_Y, 0)
ringMeshPart.Color = Color3.fromRGB(240, 240, 240)
ringMeshPart.Material = Enum.Material.SmoothPlastic
ringMeshPart.Anchored = true
ringMeshPart.CanCollide = false
ringMeshPart.Parent = pitchFolder

local ringSpecialMesh = Instance.new("SpecialMesh")
ringSpecialMesh.MeshType = Enum.MeshType.FileMesh
ringSpecialMesh.MeshId = "rbxassetid://3270017"
ringSpecialMesh.Scale = Vector3.new(15, 15, 0.02)
ringSpecialMesh.Parent = ringMeshPart

-- Punto central plano para posicionar el balón
local centerDot = Instance.new("Part")
centerDot.Name = "PuntoCentralBalon"
centerDot.Shape = Enum.PartType.Cylinder
centerDot.Size = Vector3.new(0.02, 2, 2)
centerDot.CFrame = CFrame.new(0, FIELD_Y, 0) * CFrame.Angles(0, 0, math.rad(90))
centerDot.Color = Color3.fromRGB(240, 240, 240)
centerDot.Material = Enum.Material.SmoothPlastic
centerDot.Anchored = true
centerDot.CanCollide = false
centerDot.Parent = pitchFolder

-- Spawns transparentes
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("SpawnLocation") then
        obj.Transparency = 1
        obj.CanCollide = false
        local decal = obj:FindFirstChildOfClass("Decal")
        if decal then decal.Transparency = 1 end
    end
end
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("SpawnLocation") then
        obj.Transparency = 1
        obj.CanCollide = false
        local decal = obj:FindFirstChildOfClass("Decal")
        if decal then decal.Transparency = 1 end
    end
end)

-- Muros perimetrales de cristal
local halfX = FIELD_SIZE.X / 2
local halfY = FIELD_SIZE.Y / 2
local wallY = WALL_HEIGHT / 2

createFieldPart("MuroNorte", Vector3.new(FIELD_SIZE.X + WALL_THICKNESS*2, WALL_HEIGHT, WALL_THICKNESS), Vector3.new(0, wallY, -halfY - (WALL_THICKNESS/2)), Color3.fromRGB(200, 230, 255), Enum.Material.Glass, 0.5)
createFieldPart("MuroSur", Vector3.new(FIELD_SIZE.X + WALL_THICKNESS*2, WALL_HEIGHT, WALL_THICKNESS), Vector3.new(0, wallY, halfY + (WALL_THICKNESS/2)), Color3.fromRGB(200, 230, 255), Enum.Material.Glass, 0.5)

local sideWallLen = (FIELD_SIZE.Y - GOAL_WIDTH) / 2
local sideWallOffset = (GOAL_WIDTH + sideWallLen) / 2

createFieldPart("MuroOesteArriba", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, sideWallLen), Vector3.new(-halfX - (WALL_THICKNESS/2), wallY, -sideWallOffset), Color3.fromRGB(200, 230, 255), Enum.Material.Glass, 0.5)
createFieldPart("MuroOesteAbajo", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, sideWallLen), Vector3.new(-halfX - (WALL_THICKNESS/2), wallY, sideWallOffset), Color3.fromRGB(200, 230, 255), Enum.Material.Glass, 0.5)

createFieldPart("MuroEsteArriba", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, sideWallLen), Vector3.new(halfX + (WALL_THICKNESS/2), wallY, -sideWallOffset), Color3.fromRGB(200, 230, 255), Enum.Material.Glass, 0.5)
createFieldPart("MuroEsteAbajo", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, sideWallLen), Vector3.new(halfX + (WALL_THICKNESS/2), wallY, sideWallOffset), Color3.fromRGB(200, 230, 255), Enum.Material.Glass, 0.5)

local function buildGoal(teamName: string, posX: number, primaryColor: Color3): Part
    local goalFolder = Instance.new("Folder")
    goalFolder.Name = "Porteria_" .. teamName
    goalFolder.Parent = pitchFolder

    local dirSign = if posX < 0 then -1 else 1
    local postThick = 0.8
    local barColor = Color3.fromRGB(240, 240, 240)

    local function makePost(size: Vector3, pos: Vector3): Part
        local p = Instance.new("Part")
        p.Size = size
        p.Position = pos
        p.Color = barColor
        p.Material = Enum.Material.Metal
        p.Anchored = true
        p.CanCollide = true
        p.Parent = goalFolder
        return p
    end

    makePost(Vector3.new(postThick, GOAL_HEIGHT, postThick), Vector3.new(posX, GOAL_HEIGHT/2, -GOAL_WIDTH/2))
    makePost(Vector3.new(postThick, GOAL_HEIGHT, postThick), Vector3.new(posX, GOAL_HEIGHT/2, GOAL_WIDTH/2))
    makePost(Vector3.new(postThick, postThick, GOAL_WIDTH + postThick), Vector3.new(posX, GOAL_HEIGHT, 0))

    local backX = posX + (dirSign * GOAL_DEPTH)
    makePost(Vector3.new(postThick, GOAL_HEIGHT, postThick), Vector3.new(backX, GOAL_HEIGHT/2, -GOAL_WIDTH/2))
    makePost(Vector3.new(postThick, GOAL_HEIGHT, postThick), Vector3.new(backX, GOAL_HEIGHT/2, GOAL_WIDTH/2))
    makePost(Vector3.new(postThick, postThick, GOAL_WIDTH + postThick), Vector3.new(backX, GOAL_HEIGHT, 0))

    makePost(Vector3.new(GOAL_DEPTH, postThick, postThick), Vector3.new(posX + (dirSign * GOAL_DEPTH/2), GOAL_HEIGHT, -GOAL_WIDTH/2))
    makePost(Vector3.new(GOAL_DEPTH, postThick, postThick), Vector3.new(posX + (dirSign * GOAL_DEPTH/2), GOAL_HEIGHT, GOAL_WIDTH/2))

    local netColor = primaryColor
    local function makeNet(size: Vector3, pos: Vector3)
        local n = Instance.new("Part")
        n.Size = size
        n.Position = pos
        n.Color = netColor
        n.Material = Enum.Material.DiamondPlate
        n.Transparency = 0.4
        n.Anchored = true
        n.CanCollide = true
        n.Parent = goalFolder
    end

    makeNet(Vector3.new(1, GOAL_HEIGHT, GOAL_WIDTH), Vector3.new(backX, GOAL_HEIGHT/2, 0))
    makeNet(Vector3.new(GOAL_DEPTH, 1, GOAL_WIDTH), Vector3.new(posX + (dirSign * GOAL_DEPTH/2), GOAL_HEIGHT, 0))
    makeNet(Vector3.new(GOAL_DEPTH, GOAL_HEIGHT, 1), Vector3.new(posX + (dirSign * GOAL_DEPTH/2), GOAL_HEIGHT/2, -GOAL_WIDTH/2))
    makeNet(Vector3.new(GOAL_DEPTH, GOAL_HEIGHT, 1), Vector3.new(posX + (dirSign * GOAL_DEPTH/2), GOAL_HEIGHT/2, GOAL_WIDTH/2))

    local sensor = Instance.new("Part")
    sensor.Name = "GoalSensor_" .. teamName
    sensor.Size = Vector3.new(GOAL_DEPTH - 2, GOAL_HEIGHT - 1, GOAL_WIDTH - 2)
    sensor.Position = Vector3.new(posX + (dirSign * (GOAL_DEPTH/2)), GOAL_HEIGHT/2, 0)
    sensor.Transparency = 1
    sensor.Anchored = true
    sensor.CanCollide = false
    sensor.CanTouch = true
    sensor.Parent = goalFolder
    return sensor
end

local sensorAzul = buildGoal("Azul", -halfX, Color3.fromRGB(0, 150, 255))
local sensorRojo = buildGoal("Rojo", halfX, Color3.fromRGB(255, 50, 50))

--------------------------------------------------------------------------------
-- 3. REMOTE EVENTS
--------------------------------------------------------------------------------
local remoteFolder = ReplicatedStorage:FindFirstChild("SoccerRemotes")
if not remoteFolder then
    remoteFolder = Instance.new("Folder")
    remoteFolder.Name = "SoccerRemotes"
    remoteFolder.Parent = ReplicatedStorage
end

local function getOrCreateRemote(name: string): RemoteEvent
    local remote = remoteFolder:FindFirstChild(name) :: RemoteEvent?
    if not remote then
        remote = Instance.new("RemoteEvent")
        remote.Name = name
        remote.Parent = remoteFolder
    end
    return remote
end

local startChargeEvent = getOrCreateRemote("StartCharge")
local releaseShotEvent = getOrCreateRemote("ReleaseShot")
local quickShotEvent = getOrCreateRemote("QuickShot")
local ballPossessionEvent = getOrCreateRemote("BallPossession")
local goalScoredEvent = getOrCreateRemote("GoalScored")
local updateScoreEvent = getOrCreateRemote("UpdateScore")
local shotCooldownEvent = getOrCreateRemote("ShotCooldown")

--------------------------------------------------------------------------------
-- 4. STATS DE JUGADORES (VELOCIDAD, DISPARO, DEFENSA)
--------------------------------------------------------------------------------
type PlayerStats = {
    name: string,
    role: string, -- "Delantero", "Mediocampista", "Defensa"
    speed: number,   -- 1 a 100
    shot: number,    -- 1 a 100
    defense: number, -- 1 a 100
}

local FAMOUS_PLAYERS_DATA: {PlayerStats} = {
    {name = "Kylian Mbappé", role = "Delantero", speed = 98, shot = 91, defense = 40},
    {name = "Erling Haaland", role = "Delantero", speed = 89, shot = 96, defense = 45},
    {name = "Lionel Messi", role = "Delantero", speed = 82, shot = 97, defense = 42},
    {name = "Cristiano Ronaldo", role = "Delantero", speed = 85, shot = 95, defense = 44},
    {name = "Vinicius Jr", role = "Delantero", speed = 97, shot = 86, defense = 38},
    {name = "Robert Lewandowski", role = "Delantero", speed = 76, shot = 93, defense = 48},
    {name = "Lamine Yamal", role = "Delantero", speed = 90, shot = 85, defense = 40},
    {name = "Luka Modrić", role = "Mediocampista", speed = 75, shot = 84, defense = 78},
    {name = "Kevin De Bruyne", role = "Mediocampista", speed = 78, shot = 90, defense = 72},
    {name = "Zinedine Zidane", role = "Mediocampista", speed = 79, shot = 89, defense = 75},
    {name = "Andrés Iniesta", role = "Mediocampista", speed = 80, shot = 83, defense = 74},
    {name = "Virgil van Dijk", role = "Defensa", speed = 81, shot = 60, defense = 96},
    {name = "Sergio Ramos", role = "Defensa", speed = 78, shot = 72, defense = 94},
    {name = "Carles Puyol", role = "Defensa", speed = 77, shot = 55, defense = 97},
    {name = "Paolo Maldini", role = "Defensa", speed = 83, shot = 58, defense = 98},
    {name = "Ronaldinho", role = "Delantero", speed = 88, shot = 92, defense = 40},
}

-- Mapa para almacenar stats asignados a cada modelo (Bots y Jugadores)
local characterStats: { [Model]: PlayerStats } = {}

-- Función para calcular valores mecánicos a partir de los stats
local function getWalkSpeedFromStat(speedStat: number): number
    -- 60 -> 16 walkspeed, 98 -> 24 walkspeed
    return 14 + (speedStat / 100) * 10
end

local function getSprintSpeedFromStat(speedStat: number): number
    -- 60 -> 25 sprint, 98 -> 36 sprint
    return 22 + (speedStat / 100) * 14
end

local function getStealRadiusFromStat(defenseStat: number): number
    -- Mayor defensa = roba desde más lejos (4.0 a 6.8 studs)
    return 4.0 + (defenseStat / 100) * 2.8
end

local function getStealCooldownFromStat(defenseStat: number): number
    -- Mayor defensa = roba con menos cooldown (3.2s a 1.8s)
    return 3.5 - (defenseStat / 100) * 1.7
end

local function getShotPowerMultiplier(shotStat: number): number
    -- 50 -> 0.85x, 97 -> 1.35x potencia de tiro
    return 0.6 + (shotStat / 100) * 0.75
end

local function getShotRangeFromStat(shotStat: number): number
    -- Rango de disparo del bot antes de tirar (40 studs a 85 studs para Messi/Haaland)
    return 35 + (shotStat / 100) * 50
end

--------------------------------------------------------------------------------
-- 5. VARIABLES Y CONFIGURACIÓN DEL BALÓN
--------------------------------------------------------------------------------
local BALL_SIZE = Vector3.new(1.6, 1.6, 1.6)
local BALL_ATTACH_OFFSET = Vector3.new(0, -2.2, -1.9)
local RING_COLOR_BLUE = Color3.fromRGB(0, 195, 255)
local RING_COLOR_RED = Color3.fromRGB(255, 65, 65)

local MAX_CHARGE_DURATION = 1.6
local BASE_MIN_SPEED = 40
local BASE_MAX_SPEED = 240
local SHOT_COOLDOWN_TIME = 5.0
local lastPlayerShotTime: { [Player]: number } = {}

local currentBall: Part? = nil
local currentOwner: Model? = nil
local activeWeld: WeldConstraint? = nil
local serverChargeStartTime: number? = nil
local isKickOnCooldown = false
local isGoalCelebrating = false

local scoreBlue = 0
local scoreRed = 0

local botRed: Model? = nil
local botBlue: Model? = nil
local botRedLastShotTime = 0
local botBlueLastShotTime = 0
local botRedLastPowerShot = 0
local botBlueLastPowerShot = 0
local botRedLastStealTime = 0
local botBlueLastStealTime = 0

local botRedSprintStart = 0
local botRedSprintEnd = 0
local botBlueSprintStart = 0
local botBlueSprintEnd = 0

local BLUE_SPAWN_POS = Vector3.new(-55, 3, 0)
local RED_SPAWN_POS = Vector3.new(55, 3, 0)

local goalkeeperBlue: Model? = nil
local goalkeeperRed: Model? = nil

--------------------------------------------------------------------------------
-- 6. EFECTO DE FUEGO EN EL BALÓN
--------------------------------------------------------------------------------
local function igniteBallInFlames(duration: number)
    if not currentBall then return end

    local existingFire = currentBall:FindFirstChild("BallFire")
    if existingFire then existingFire:Destroy() end
    local existingLight = currentBall:FindFirstChild("BallFireLight")
    if existingLight then existingLight:Destroy() end

    local fire = Instance.new("Fire")
    fire.Name = "BallFire"
    fire.Size = 7
    fire.Heat = 20
    fire.Color = Color3.fromRGB(255, 80, 20)
    fire.SecondaryColor = Color3.fromRGB(255, 220, 0)
    fire.Parent = currentBall

    local light = Instance.new("PointLight")
    light.Name = "BallFireLight"
    light.Color = Color3.fromRGB(255, 100, 20)
    light.Range = 20
    light.Brightness = 7
    light.Parent = currentBall

    task.delay(duration, function()
        if fire and fire.Parent then fire:Destroy() end
        if light and light.Parent then light:Destroy() end
    end)
end

--------------------------------------------------------------------------------
-- 7. ARO NEÓN EN LOS PIES
--------------------------------------------------------------------------------
local function removeAuraRing(character: Model?)
    if character then
        local ring = character:FindFirstChild("BallControlRing")
        if ring then
            ring:Destroy()
        end
    end
end

local function createAuraRing(character: Model, color: Color3): Part?
    local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not hrp then return nil end

    removeAuraRing(character)

    local ring = Instance.new("Part")
    ring.Name = "BallControlRing"
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(0.15, 5.5, 5.5)
    ring.Material = Enum.Material.Neon
    ring.Color = color
    ring.Transparency = 0.25
    ring.CanCollide = false
    ring.CanTouch = false
    ring.CanQuery = false
    ring.CastShadow = false
    ring.Massless = true
    pcall(function() ring.CollisionGroup = "SoccerBallGroup" end)

    local light = Instance.new("PointLight")
    light.Color = color
    light.Range = 10
    light.Brightness = 3.5
    light.Parent = ring

    local attachment = Instance.new("Attachment")
    attachment.Parent = ring

    local particles = Instance.new("ParticleEmitter")
    particles.Texture = "rbxassetid://243098098"
    particles.Color = ColorSequence.new(color)
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0)
    })
    particles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1)
    })
    particles.Lifetime = NumberRange.new(0.3, 0.7)
    particles.Rate = 30
    particles.Speed = NumberRange.new(1, 3)
    particles.SpreadAngle = Vector2.new(180, 0)
    particles.Parent = attachment

    local weld = Instance.new("Weld")
    weld.Part0 = hrp
    weld.Part1 = ring
    weld.C0 = CFrame.new(0, -2.85, 0) * CFrame.Angles(0, 0, math.rad(90))
    weld.Parent = ring

    ring.Parent = character
    return ring
end

--------------------------------------------------------------------------------
-- 8. POSESIÓN Y SOLDADURA DEL BALÓN
--------------------------------------------------------------------------------
local function releaseBall()
    if activeWeld then
        activeWeld:Destroy()
        activeWeld = nil
    end

    if currentOwner then
        removeAuraRing(currentOwner)
        local prevPlayer = Players:GetPlayerFromCharacter(currentOwner)
        if prevPlayer then
            ballPossessionEvent:FireClient(prevPlayer, false)
        end
    end

    currentOwner = nil
    serverChargeStartTime = nil

    if currentBall then
        currentBall.Massless = false
    end
end

local function attachBallToPlayer(character: Model)
    if currentOwner == character or not currentBall or isKickOnCooldown or isGoalCelebrating then return end

    local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart?
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then return end

    releaseBall()

    currentOwner = character
    currentBall.Massless = true

    currentBall.CFrame = hrp.CFrame * CFrame.new(BALL_ATTACH_OFFSET)
    currentBall.AssemblyLinearVelocity = Vector3.zero
    currentBall.AssemblyAngularVelocity = Vector3.zero

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hrp
    weld.Part1 = currentBall
    weld.Parent = currentBall
    activeWeld = weld

    local isRed = (character == botRed)
    createAuraRing(character, if isRed then RING_COLOR_RED else RING_COLOR_BLUE)

    local player = Players:GetPlayerFromCharacter(character)
    if player then
        ballPossessionEvent:FireClient(player, true)
    end
end

--------------------------------------------------------------------------------
-- 9. SPAWN DEL BALÓN Y GESTIÓN DE GOLES
--------------------------------------------------------------------------------
local function spawnBall(spawnCFrame: CFrame)
    if currentBall and currentBall.Parent then
        currentBall:Destroy()
    end
    releaseBall()

    local ball = Instance.new("Part")
    ball.Name = "SoccerBall"
    ball.Shape = Enum.PartType.Ball
    ball.Size = BALL_SIZE
    ball.CFrame = spawnCFrame
    ball.Material = Enum.Material.SmoothPlastic
    ball.Color = Color3.fromRGB(245, 245, 245)
    ball.TopSurface = Enum.SurfaceType.Smooth
    ball.BottomSurface = Enum.SurfaceType.Smooth
    ball.CanCollide = true
    ball.CustomPhysicalProperties = PhysicalProperties.new(0.4, 0.4, 0.8, 1, 1)

    pcall(function()
        ball.CollisionGroup = "SoccerBallGroup"
    end)

    local soccerMesh = Instance.new("SpecialMesh")
    soccerMesh.MeshType = Enum.MeshType.Sphere
    soccerMesh.Scale = Vector3.new(1, 1, 1)
    soccerMesh.Parent = ball

    ball.Touched:Connect(function(hit)
        if isKickOnCooldown or currentOwner ~= nil or isGoalCelebrating then return end
        local character = hit.Parent
        if character and character:IsA("Model") then
            attachBallToPlayer(character)
        end
    end)

    ball.Parent = workspace
    currentBall = ball
end

local function resetPositionsToField()
    if botRed and botRed.Parent then
        local rHrp = botRed:FindFirstChild("HumanoidRootPart") :: BasePart?
        if rHrp then
            rHrp.CFrame = CFrame.new(RED_SPAWN_POS + Vector3.new(0, 0, math.random(-15, 15)))
            rHrp.AssemblyLinearVelocity = Vector3.zero
        end
    end

    if botBlue and botBlue.Parent then
        local bHrp = botBlue:FindFirstChild("HumanoidRootPart") :: BasePart?
        if bHrp then
            bHrp.CFrame = CFrame.new(BLUE_SPAWN_POS + Vector3.new(0, 0, math.random(-15, 15)))
            bHrp.AssemblyLinearVelocity = Vector3.zero
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        local pChar = p.Character
        local pHrp = pChar and pChar:FindFirstChild("HumanoidRootPart") :: BasePart?
        if pHrp then
            pHrp.CFrame = CFrame.new(-40, 3, math.random(-10, 10))
            pHrp.AssemblyLinearVelocity = Vector3.zero
        end
    end
end

local function onGoalScored(goalTeam: string)
    if isGoalCelebrating then return end
    isGoalCelebrating = true

    if goalTeam == "Azul" then
        scoreRed = scoreRed + 1
    else
        scoreBlue = scoreBlue + 1
    end

    updateScoreEvent:FireAllClients(scoreBlue, scoreRed)
    goalScoredEvent:FireAllClients(goalTeam)

    releaseBall()

    task.delay(1.2, function()
        resetPositionsToField()
        spawnBall(CFrame.new(0, 2.5, 0))
        isGoalCelebrating = false
    end)
end

sensorAzul.Touched:Connect(function(hit)
    if hit == currentBall then
        onGoalScored("Azul")
    end
end)

sensorRojo.Touched:Connect(function(hit)
    if hit == currentBall then
        onGoalScored("Rojo")
    end
end)

task.defer(function()
    spawnBall(CFrame.new(0, 2.5, 0))
end)

--------------------------------------------------------------------------------
-- 10. EVENTOS DE DISPARO DEL JUGADOR (CON VARIACIÓN AÉREA Y STATS)
--------------------------------------------------------------------------------
local function checkPlayerCooldown(player: Player): boolean
    local lastTime = lastPlayerShotTime[player] or 0
    local elapsed = os.clock() - lastTime
    return elapsed >= SHOT_COOLDOWN_TIME
end

local function applyPlayerCooldown(player: Player)
    lastPlayerShotTime[player] = os.clock()
    shotCooldownEvent:FireClient(player, SHOT_COOLDOWN_TIME)
end

startChargeEvent.OnServerEvent:Connect(function(player)
    local char = player.Character
    if char and currentOwner == char and not isKickOnCooldown and not isGoalCelebrating and checkPlayerCooldown(player) then
        serverChargeStartTime = os.clock()
    end
end)

releaseShotEvent.OnServerEvent:Connect(function(player, clientAimDirection: Vector3)
    local char = player.Character
    if not char or currentOwner ~= char or not currentBall or isKickOnCooldown or isGoalCelebrating then
        return
    end

    if not checkPlayerCooldown(player) then
        return
    end

    applyPlayerCooldown(player)

    local startTime = serverChargeStartTime or os.clock()
    local elapsed = os.clock() - startTime
    local powerRatio = math.clamp(elapsed / MAX_CHARGE_DURATION, 0.01, 1.0)

    local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?
    local shootDir: Vector3
    if typeof(clientAimDirection) == "Vector3" and clientAimDirection.Magnitude > 0.1 then
        shootDir = clientAimDirection.Unit
    elseif hrp then
        shootDir = hrp.CFrame.LookVector
    else
        shootDir = Vector3.new(0, 0, -1)
    end

    local stats = characterStats[char]
    local shotMultiplier = if stats then getShotPowerMultiplier(stats.shot) else 1.0

    releaseBall()
    isKickOnCooldown = true

    pcall(function()
        currentBall:SetNetworkOwner(player)
    end)

    local speed = (BASE_MIN_SPEED + (powerRatio * (BASE_MAX_SPEED - BASE_MIN_SPEED))) * shotMultiplier
    -- Elevación calculada según el ángulo de mira del jugador y la potencia
    local minLift = 8
    local maxLift = 42
    local lift = minLift + (powerRatio * (maxLift - minLift))
    if shootDir.Y > 0.1 then
        lift = lift + (shootDir.Y * 35)
    end

    currentBall.CFrame = currentBall.CFrame + (shootDir * 2.2)
    currentBall.AssemblyLinearVelocity = (Vector3.new(shootDir.X, 0, shootDir.Z).Unit * speed) + Vector3.new(0, lift, 0)

    local spinAxis = Vector3.new(-shootDir.Z, 0, shootDir.X)
    currentBall.AssemblyAngularVelocity = spinAxis * (20 + (powerRatio * 60))

    task.delay(0.5, function()
        isKickOnCooldown = false
        pcall(function()
            if currentBall then
                currentBall:SetNetworkOwner(nil)
            end
        end)
    end)
end)

quickShotEvent.OnServerEvent:Connect(function(player, clientAimDirection: Vector3)
    local char = player.Character
    if not char or currentOwner ~= char or not currentBall or isKickOnCooldown or isGoalCelebrating then
        return
    end

    if not checkPlayerCooldown(player) then
        return
    end

    applyPlayerCooldown(player)

    local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?
    local shootDir = if (typeof(clientAimDirection) == "Vector3" and clientAimDirection.Magnitude > 0.1)
        then clientAimDirection.Unit
        elseif hrp then hrp.CFrame.LookVector
        else Vector3.new(0, 0, -1)

    local stats = characterStats[char]
    local shotMultiplier = if stats then getShotPowerMultiplier(stats.shot) else 1.0

    releaseBall()
    isKickOnCooldown = true

    pcall(function()
        currentBall:SetNetworkOwner(player)
    end)

    local speed = 160 * shotMultiplier
    local lift = 18
    if shootDir.Y > 0.1 then
        lift = lift + (shootDir.Y * 30)
    end

    currentBall.CFrame = currentBall.CFrame + (shootDir * 2.2)
    currentBall.AssemblyLinearVelocity = (Vector3.new(shootDir.X, 0, shootDir.Z).Unit * speed) + Vector3.new(0, lift, 0)
    currentBall.AssemblyAngularVelocity = Vector3.new(-shootDir.Z, 0, shootDir.X) * 45

    task.delay(0.5, function()
        isKickOnCooldown = false
        pcall(function()
            if currentBall then
                currentBall:SetNetworkOwner(nil)
            end
        end)
    end)
end)

--------------------------------------------------------------------------------
-- 11. PORTEROS IMPOSIBLES: PASE INTELIGENTE (DETRÁS DEL ALIADO SI HAY RIVAL)
--------------------------------------------------------------------------------
local function createGoalkeeper(teamName: string, posX: number, primaryColor: Color3, nameLabel: string): Model
    local gk = Instance.new("Model")
    gk.Name = "Portero_" .. teamName

    local function makePart(pName: string, size: Vector3, color: Color3): Part
        local p = Instance.new("Part")
        p.Name = pName
        p.Size = size
        p.Color = color
        p.Material = Enum.Material.SmoothPlastic
        p.CanCollide = true
        p.Parent = gk
        return p
    end

    local hrp = makePart("HumanoidRootPart", Vector3.new(2, 2, 1), Color3.fromRGB(120, 120, 120))
    hrp.Transparency = 1
    hrp.CanCollide = false
    hrp.CFrame = CFrame.new(posX, 3, 0)

    local torso = makePart("Torso", Vector3.new(2.4, 2, 1.2), primaryColor)
    local head = makePart("Head", Vector3.new(1.3, 1.3, 1.3), Color3.fromRGB(240, 200, 160))
    local headMesh = Instance.new("SpecialMesh")
    headMesh.MeshType = Enum.MeshType.Head
    headMesh.Scale = Vector3.new(1.3, 1.3, 1.3)
    headMesh.Parent = head

    local leftArm = makePart("Left Arm", Vector3.new(1.3, 2.4, 1.3), Color3.fromRGB(255, 230, 50))
    local rightArm = makePart("Right Arm", Vector3.new(1.3, 2.4, 1.3), Color3.fromRGB(255, 230, 50))
    local leftLeg = makePart("Left Leg", Vector3.new(1, 2, 1), Color3.fromRGB(30, 30, 30))
    local rightLeg = makePart("Right Leg", Vector3.new(1, 2, 1), Color3.fromRGB(30, 30, 30))

    local function makeMotor(mName: string, part0: BasePart, part1: BasePart, c0: CFrame, c1: CFrame)
        local m = Instance.new("Motor6D")
        m.Name = mName
        m.Part0 = part0
        m.Part1 = part1
        m.C0 = c0
        m.C1 = c1
        m.Parent = part0
    end

    makeMotor("RootJoint", hrp, torso, CFrame.new(0, 0, 0), CFrame.new(0, 0, 0))
    makeMotor("Neck", torso, head, CFrame.new(0, 1, 0), CFrame.new(0, -0.5, 0))
    makeMotor("Left Shoulder", torso, leftArm, CFrame.new(-1.2, 0.5, 0), CFrame.new(0.5, 0.5, 0))
    makeMotor("Right Shoulder", torso, rightArm, CFrame.new(1.2, 0.5, 0), CFrame.new(-0.5, 0.5, 0))
    makeMotor("Left Hip", torso, leftLeg, CFrame.new(-0.5, -1, 0), CFrame.new(0, 1, 0))
    makeMotor("Right Hip", torso, rightLeg, CFrame.new(0.5, -1, 0), CFrame.new(0, 1, 0))

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.WalkSpeed = 60
    humanoid.JumpPower = 0
    humanoid.Parent = gk

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 45)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🛡️ " .. nameLabel
    label.TextColor3 = primaryColor
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = billboard

    local impossibleShield = Instance.new("Part")
    impossibleShield.Name = "ImpossibleShield"
    impossibleShield.Size = Vector3.new(3.5, GOAL_HEIGHT, GOAL_WIDTH * 0.95)
    impossibleShield.Position = Vector3.new(posX, GOAL_HEIGHT/2, 0)
    impossibleShield.Transparency = 1
    impossibleShield.Anchored = true
    impossibleShield.CanCollide = false
    impossibleShield.CanTouch = true
    impossibleShield.Parent = gk

    -- Físicas y colisión del cuerpo del portero: colisionable con el balón para paradas físicas
    for _, p in ipairs(gk:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Name ~= "ImpossibleShield" then
            p.CanCollide = true
            p.CollisionGroup = "Default"
            p.CustomPhysicalProperties = PhysicalProperties.new(1.2, 0.4, 0.8, 1, 1) -- Alto rebote y fricción
        end
    end

    gk.PrimaryPart = hrp
    setupCharacterCollision(gk)

    local isHandlingBall = false
    local function catchAndPass()
        if not currentBall or isKickOnCooldown or isGoalCelebrating or isHandlingBall then return end

        -- PROBABILIDAD DE ERROR/PARADA SEGÚN EL DISPARO DEL RIVAL O VELOCIDAD DEL BALÓN
        -- Si el balón viene muy potente (ej. > 135 studs/s), existe margen de rechace o fallo
        local ballVelocity = currentBall.AssemblyLinearVelocity
        local ballSpeed = ballVelocity.Magnitude
        if ballSpeed > 130 then
            local failChance = math.clamp((ballSpeed - 130) * 1.5, 5, 25) -- 5% a 25% de error en disparos misil
            if math.random(1, 100) <= failChance then
                -- Desvío físico / rechace en vez de atrapar limpio
                local deflectDir = Vector3.new(if posX < 0 then 1 else -1, 0.4, (math.random() - 0.5) * 1.5).Unit
                currentBall.AssemblyLinearVelocity = deflectDir * (ballSpeed * 0.65)
                return
            end
        end

        isHandlingBall = true
        releaseBall()
        isKickOnCooldown = true

        currentBall.AssemblyLinearVelocity = Vector3.zero
        currentBall.AssemblyAngularVelocity = Vector3.zero
        currentBall.CFrame = hrp.CFrame * CFrame.new(0, -1, -2.5)

        task.delay(0.35, function()
            if not currentBall then
                isHandlingBall = false
                isKickOnCooldown = false
                return
            end

            -- 1. IDENTIFICAR ALIADO Y RIVALES
            local targetTeammateHrp: BasePart? = nil
            local enemyInterceptors: {BasePart} = {}

            if teamName == "Azul" then
                if botBlue and botBlue.Parent then
                    targetTeammateHrp = botBlue:FindFirstChild("HumanoidRootPart") :: BasePart?
                else
                    for _, p in ipairs(Players:GetPlayers()) do
                        local char = p.Character
                        local pHrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
                        if pHrp then targetTeammateHrp = pHrp; break end
                    end
                end
                if botRed and botRed.Parent then
                    local eHrp = botRed:FindFirstChild("HumanoidRootPart") :: BasePart?
                    if eHrp then table.insert(enemyInterceptors, eHrp) end
                end
            else
                if botRed and botRed.Parent then
                    targetTeammateHrp = botRed:FindFirstChild("HumanoidRootPart") :: BasePart?
                end
                if botBlue and botBlue.Parent then
                    local eHrp = botBlue:FindFirstChild("HumanoidRootPart") :: BasePart?
                    if eHrp then table.insert(enemyInterceptors, eHrp) end
                end
                for _, p in ipairs(Players:GetPlayers()) do
                    local char = p.Character
                    local pHrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
                    if pHrp then table.insert(enemyInterceptors, pHrp) end
                end
            end

            -- 2. CALCULAR OBJETIVO TÁCTICO: DETRÁS DEL ALIADO SI HAY RIVAL EN FRENTE
            local targetPos: Vector3
            local isRivalInFront = false

            if targetTeammateHrp then
                local matePos = targetTeammateHrp.Position
                local gkToMate = matePos - hrp.Position
                local gkToMateDir = Vector3.new(gkToMate.X, 0, gkToMate.Z).Unit

                -- Verificar si algún rival está frente al aliado (entre el portero y el aliado, o marcándolo de cerca en frente)
                for _, rivalHrp in ipairs(enemyInterceptors) do
                    local rivalPos = rivalHrp.Position
                    local mateToRival = rivalPos - matePos
                    local mateToRivalDist = mateToRival.Magnitude

                    -- Si el rival está a menos de 25 studs del aliado en dirección hacia la portería contraria o en medio
                    if mateToRivalDist < 25 then
                        local dot = gkToMateDir:Dot(Vector3.new(mateToRival.X, 0, mateToRival.Z).Unit)
                        if dot > -0.2 then
                            isRivalInFront = true
                            break
                        end
                    end
                end

                if isRivalInFront then
                    -- Tirar el balón DETRÁS del aliado (más seguro para proteger la posesión)
                    -- 'Detrás' significa hacia el campo propio del portero
                    targetPos = matePos - (gkToMateDir * 12)
                else
                    -- Tirar al espacio adelantado hacia la carrera del aliado
                    targetPos = matePos + (targetTeammateHrp.CFrame.LookVector * 6)
                end
            else
                targetPos = Vector3.new(0, 3, 0)
            end

            -- 3. CÁLCULO DE TRAYECTORIA Y ELEVACIÓN AÉREA
            local flatDir = Vector3.new(targetPos.X - hrp.Position.X, 0, targetPos.Z - hrp.Position.Z)
            local dist = flatDir.Magnitude
            local unitDir = if dist > 0.1 then flatDir.Unit else Vector3.new(if posX < 0 then 1 else -1, 0, 0)

            local speed: number
            local verticalLift: number

            if isRivalInFront or dist > 35 then
                -- Pase por el aire elevado sobre la marca
                speed = math.clamp(dist * 1.5, 75, 140)
                verticalLift = 34 + (dist * 0.28)
            else
                -- Pase tenso
                speed = math.clamp(dist * 1.8, 65, 115)
                verticalLift = 12
            end

            currentBall.CFrame = currentBall.CFrame + (unitDir * 2.5) + Vector3.new(0, 1.2, 0)
            currentBall.AssemblyLinearVelocity = (unitDir * speed) + Vector3.new(0, verticalLift, 0)
            currentBall.AssemblyAngularVelocity = Vector3.new(-unitDir.Z, 0, unitDir.X) * 35

            task.delay(0.4, function()
                isKickOnCooldown = false
                isHandlingBall = false
            end)
        end)
    end

    impossibleShield.Touched:Connect(function(hit)
        if hit == currentBall then
            catchAndPass()
        end
    end)

    gk.Parent = workspace
    return gk
end

goalkeeperBlue = createGoalkeeper("Azul", -halfX + 4, Color3.fromRGB(0, 160, 255), "Portero Imposible Azul")
goalkeeperRed = createGoalkeeper("Rojo", halfX - 4, Color3.fromRGB(255, 60, 60), "Portero Imposible Rojo")

local function updateGoalkeeperAI(gk: Model?, goalX: number)
    if not gk or not gk.Parent or isGoalCelebrating then return end
    local hrp = gk:FindFirstChild("HumanoidRootPart") :: BasePart?
    local humanoid = gk:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then return end

    local goalCenter = Vector3.new(goalX, 3, 0)
    local isLeftGoal = (goalX < 0)

    if currentBall and currentBall.Parent then
        local ballPos = currentBall.Position
        local ballVel = currentBall.AssemblyLinearVelocity
        local ballSpeed = ballVel.Magnitude

        -- 1. Predicción de trayectoria del balón hacia la línea de gol
        local predictedZ = ballPos.Z
        local timeToReach = 0
        local headingTowardsGoal = false

        if isLeftGoal and ballVel.X < -5 then
            timeToReach = (goalX - ballPos.X) / ballVel.X
            if timeToReach > 0 and timeToReach < 2.5 then
                predictedZ = ballPos.Z + (ballVel.Z * timeToReach)
                headingTowardsGoal = true
            end
        elseif (not isLeftGoal) and ballVel.X > 5 then
            timeToReach = (goalX - ballPos.X) / ballVel.X
            if timeToReach > 0 and timeToReach < 2.5 then
                predictedZ = ballPos.Z + (ballVel.Z * timeToReach)
                headingTowardsGoal = true
            end
        end

        -- Margen de error humano del portero (simula tiempo de reacción realista)
        local reactionJitter = (math.sin(os.clock() * 5) * 0.4)

        if headingTowardsGoal then
            -- 2. El balón va hacia portería: desplazarse o lanzarse (dive) hacia el punto de intercepción
            local targetZ = math.clamp(predictedZ + reactionJitter, -(GOAL_WIDTH / 2 - 1.5), (GOAL_WIDTH / 2 - 1.5))
            local distZ = math.abs(hrp.Position.Z - targetZ)

            -- Si el balón está cerca y en el aire o esquinado, lanzarse con velocidad
            if distZ > 4 and timeToReach < 0.8 then
                humanoid.WalkSpeed = 48
                -- Lanzamiento / estirada del portero
                local diveDir = Vector3.new(0, 0, math.sign(targetZ - hrp.Position.Z))
                hrp.AssemblyLinearVelocity = Vector3.new(0, 8, diveDir.Z * 32)
            else
                humanoid.WalkSpeed = 38
            end
            humanoid:MoveTo(Vector3.new(goalX, 3, targetZ))
        else
            -- 3. Posicionamiento en bisectriz: ubicarse en el arco entre el centro de la portería y el balón
            local toBall = (ballPos - goalCenter)
            local flatDir = Vector3.new(toBall.X, 0, toBall.Z).Unit
            -- Salir un poco hacia adelante del arco (hasta 6 studs de la línea) para recortar ángulo
            local advance = math.clamp(toBall.Magnitude * 0.08, 0, 7)
            local targetPos = goalCenter + (flatDir * advance)
            
            -- Delimitar el movimiento dentro de la boca del arco
            targetPos = Vector3.new(
                if isLeftGoal then math.clamp(targetPos.X, goalX, goalX + 8) else math.clamp(targetPos.X, goalX - 8, goalX),
                3,
                math.clamp(targetPos.Z, -(GOAL_WIDTH / 2 - 2), (GOAL_WIDTH / 2 - 2))
            )

            humanoid.WalkSpeed = 26
            humanoid:MoveTo(targetPos)
        end
    else
        humanoid.WalkSpeed = 20
        humanoid:MoveTo(goalCenter)
    end
end

--------------------------------------------------------------------------------
-- 12. GENERACIÓN DE BOTS (/bot) CON STATS ALEATORIOS
--------------------------------------------------------------------------------
local function buildBotModel(teamName: string, torsoColor: Color3, spawnPos: Vector3): (Model, PlayerStats)
    local statsTemplate = FAMOUS_PLAYERS_DATA[math.random(1, #FAMOUS_PLAYERS_DATA)]
    local randomName = statsTemplate.name

    local bot = Instance.new("Model")
    bot.Name = string.format("Bot_%s_%s", teamName, randomName)

    local function makePart(name: string, size: Vector3, color: Color3): Part
        local p = Instance.new("Part")
        p.Name = name
        p.Size = size
        p.Color = color
        p.Material = Enum.Material.SmoothPlastic
        p.CanCollide = true
        p.Parent = bot
        return p
    end

    local hrp = makePart("HumanoidRootPart", Vector3.new(2, 2, 1), Color3.fromRGB(150, 150, 150))
    hrp.Transparency = 1
    hrp.CanCollide = false
    hrp.CFrame = CFrame.new(spawnPos)

    local torso = makePart("Torso", Vector3.new(2, 2, 1), torsoColor)
    local head = makePart("Head", Vector3.new(1.25, 1.25, 1.25), Color3.fromRGB(240, 200, 160))
    local headMesh = Instance.new("SpecialMesh")
    headMesh.MeshType = Enum.MeshType.Head
    headMesh.Scale = Vector3.new(1.25, 1.25, 1.25)
    headMesh.Parent = head

    local leftArm = makePart("Left Arm", Vector3.new(1, 2, 1), torsoColor)
    local rightArm = makePart("Right Arm", Vector3.new(1, 2, 1), torsoColor)
    local leftLeg = makePart("Left Leg", Vector3.new(1, 2, 1), Color3.fromRGB(25, 25, 25))
    local rightLeg = makePart("Right Leg", Vector3.new(1, 2, 1), Color3.fromRGB(25, 25, 25))

    local function makeMotor(name: string, part0: BasePart, part1: BasePart, c0: CFrame, c1: CFrame)
        local m = Instance.new("Motor6D")
        m.Name = name
        m.Part0 = part0
        m.Part1 = part1
        m.C0 = c0
        m.C1 = c1
        m.Parent = part0
    end

    makeMotor("RootJoint", hrp, torso, CFrame.new(0, 0, 0), CFrame.new(0, 0, 0))
    makeMotor("Neck", torso, head, CFrame.new(0, 1, 0), CFrame.new(0, -0.5, 0))
    makeMotor("Left Shoulder", torso, leftArm, CFrame.new(-1, 0.5, 0), CFrame.new(0.5, 0.5, 0))
    makeMotor("Right Shoulder", torso, rightArm, CFrame.new(1, 0.5, 0), CFrame.new(-0.5, 0.5, 0))
    makeMotor("Left Hip", torso, leftLeg, CFrame.new(-0.5, -1, 0), CFrame.new(0, 1, 0))
    makeMotor("Right Hip", torso, rightLeg, CFrame.new(0.5, -1, 0), CFrame.new(0, 1, 0))

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.WalkSpeed = getWalkSpeedFromStat(statsTemplate.speed)
    humanoid.JumpPower = 0
    humanoid.Parent = bot

    -- Billboard con Nombre y los 3 Stats
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 240, 0, 65)
    billboard.StudsOffset = Vector3.new(0, 3.4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.48, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = string.format("[%s] ⭐ %s", string.upper(teamName), randomName)
    nameLabel.TextColor3 = torsoColor
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.Parent = billboard

    local statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(1, 0, 0.48, 0)
    statsLabel.Position = UDim2.new(0, 0, 0.50, 0)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = string.format("⚡VEL: %d | 🎯DIS: %d | 🛡️DEF: %d", statsTemplate.speed, statsTemplate.shot, statsTemplate.defense)
    statsLabel.TextColor3 = Color3.fromRGB(255, 230, 100)
    statsLabel.Font = Enum.Font.GothamBold
    statsLabel.TextScaled = true
    statsLabel.Parent = billboard

    bot.PrimaryPart = hrp
    setupCharacterCollision(bot)

    characterStats[bot] = statsTemplate
    bot.Parent = workspace
    return bot, statsTemplate
end

local function spawnBothBots(originPlayer: Player)
    if botRed and botRed.Parent then
        if currentOwner == botRed then releaseBall() end
        characterStats[botRed] = nil
        botRed:Destroy()
    end
    if botBlue and botBlue.Parent then
        if currentOwner == botBlue then releaseBall() end
        characterStats[botBlue] = nil
        botBlue:Destroy()
    end

    botRed, _ = buildBotModel("Rojo", Color3.fromRGB(235, 45, 45), RED_SPAWN_POS)
    botRedLastShotTime = 0
    botRedLastPowerShot = 0
    botRedSprintStart = 0
    botRedSprintEnd = 0
    botRedLastStealTime = 0

    botBlue, _ = buildBotModel("Azul", Color3.fromRGB(45, 145, 245), BLUE_SPAWN_POS)
    botBlueLastShotTime = 0
    botBlueLastPowerShot = 0
    botBlueSprintStart = 0
    botBlueSprintEnd = 0
    botBlueLastStealTime = 0

    print("[SERVIDOR] 2 Bots creados con Stats únicos (Velocidad, Disparo, Defensa).")
end

-- Asignar stats también al jugador humano al entrar o reaparecer
local function assignStatsToPlayerCharacter(player: Player, char: Model)
    local randomStats = FAMOUS_PLAYERS_DATA[math.random(1, #FAMOUS_PLAYERS_DATA)]
    characterStats[char] = randomStats

    local humanoid = char:WaitForChild("Humanoid", 10) :: Humanoid?
    local head = char:WaitForChild("Head", 10) :: BasePart?
    if humanoid then
        humanoid.WalkSpeed = getWalkSpeedFromStat(randomStats.speed)
    end

    if head and not head:FindFirstChild("PlayerStatsBillboard") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "PlayerStatsBillboard"
        billboard.Size = UDim2.new(0, 240, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3.2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0.48, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = string.format("⭐ %s (%s)", player.DisplayName, randomStats.name)
        titleLabel.TextColor3 = Color3.fromRGB(80, 220, 255)
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextScaled = true
        titleLabel.Parent = billboard

        local statsLabel = Instance.new("TextLabel")
        statsLabel.Size = UDim2.new(1, 0, 0.48, 0)
        statsLabel.Position = UDim2.new(0, 0, 0.50, 0)
        statsLabel.BackgroundTransparency = 1
        statsLabel.Text = string.format("⚡VEL: %d | 🎯DIS: %d | 🛡️DEF: %d", randomStats.speed, randomStats.shot, randomStats.defense)
        statsLabel.TextColor3 = Color3.fromRGB(255, 230, 100)
        statsLabel.Font = Enum.Font.GothamBold
        statsLabel.TextScaled = true
        statsLabel.Parent = billboard
    end

    -- Sincronizar stats en Values dentro del Character para el cliente
    local function setStatVal(name: string, val: number)
        local obj = char:FindFirstChild(name) :: NumberValue?
        if not obj then
            obj = Instance.new("NumberValue")
            obj.Name = name
            obj.Parent = char
        end
        obj.Value = val
    end
    setStatVal("Stat_Speed", randomStats.speed)
    setStatVal("Stat_Shot", randomStats.shot)
    setStatVal("Stat_Defense", randomStats.defense)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        assignStatsToPlayerCharacter(player, char)

        local hrp = char:WaitForChild("HumanoidRootPart", 10) :: BasePart?
        if hrp then
            hrp.Touched:Connect(function(hit)
                if (currentOwner == botRed or currentOwner == botBlue) and not isKickOnCooldown and currentBall then
                    local dist = (currentBall.Position - hrp.Position).Magnitude
                    local pStats = characterStats[char]
                    local stealRadius = if pStats then getStealRadiusFromStat(pStats.defense) else 4.8
                    if dist < stealRadius then
                        attachBallToPlayer(char)
                    end
                end
            end)
        end
    end)
    if player.Character then
        assignStatsToPlayerCharacter(player, player.Character)
    end
    updateScoreEvent:FireClient(player, scoreBlue, scoreRed)
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p.Character then
        assignStatsToPlayerCharacter(p, p.Character)
    end
end

--------------------------------------------------------------------------------
-- 13. IA AVANZADA DE BOTS CON STATS DINÁMICOS
--------------------------------------------------------------------------------
local BLUE_GOAL_CENTER = Vector3.new(-halfX, 4, 0)
local RED_GOAL_CENTER = Vector3.new(halfX, 4, 0)

local function updateBotSprint(humanoid: Humanoid, sprintStart: number, sprintEnd: number, botStats: PlayerStats?): (number, number)
    local walkSpeed = if botStats then getWalkSpeedFromStat(botStats.speed) else 18
    local sprintSpeed = if botStats then getSprintSpeedFromStat(botStats.speed) else 28

    local now = os.clock()
    if sprintStart > sprintEnd then
        if now - sprintStart >= 3.0 then
            humanoid.WalkSpeed = walkSpeed
            return sprintStart, now
        else
            humanoid.WalkSpeed = sprintSpeed
        end
    else
        if now - sprintEnd >= 7.0 then
            humanoid.WalkSpeed = sprintSpeed
            return now, sprintEnd
        else
            humanoid.WalkSpeed = walkSpeed
        end
    end
    return sprintStart, sprintEnd
end

local function calculateDribbleTarget(botHrp: BasePart, goalPos: Vector3, rivalHrp: BasePart?, botStats: PlayerStats?): Vector3
    local forwardDir = (Vector3.new(goalPos.X, 0, goalPos.Z) - Vector3.new(botHrp.Position.X, 0, botHrp.Position.Z)).Unit
    local directTarget = botHrp.Position + (forwardDir * 28)

    -- Si hay un rival cerca o en la línea de avance, calcular evasión adaptativa
    if rivalHrp then
        local toRival = rivalHrp.Position - botHrp.Position
        local distToRival = toRival.Magnitude

        -- Mayor velocidad/regate = detecta y anticipa esquive con mejor margen
        local detectRange = 28 + (if botStats then (botStats.speed / 100) * 8 else 4)

        if distToRival < detectRange then
            local rivalDir = toRival.Unit
            local dot = forwardDir:Dot(rivalDir)
            
            -- El rival está en frente o cerrando el paso
            if dot > 0.2 then
                local perpLeft = Vector3.new(-forwardDir.Z, 0, forwardDir.X)
                local perpRight = Vector3.new(forwardDir.Z, 0, -forwardDir.X)

                -- Evaluar cuál lado tiene más espacio libre
                local rivalVelocity = rivalHrp.AssemblyLinearVelocity
                local rivalMovingLeft = (perpLeft:Dot(rivalVelocity) > 0)
                
                -- Si el rival se barre o corre a la izquierda, recortar a la derecha
                local dodgeDir = if rivalMovingLeft then perpRight else perpLeft

                -- Mantenerse dentro de los límites del campo (Z entre -70 y 70)
                if botHrp.Position.Z > 55 then
                    dodgeDir = Vector3.new(0, 0, -1)
                elseif botHrp.Position.Z < -55 then
                    dodgeDir = Vector3.new(0, 0, 1)
                end

                -- Mezclar avance con desborde lateral
                local evasiveDir = (forwardDir * 0.55 + dodgeDir * 0.45).Unit
                return botHrp.Position + (evasiveDir * 24)
            end
        end
    end

    -- Buscar carril libre si el camino central está congestionado
    if math.abs(botHrp.Position.Z) < 10 and math.random(1, 100) <= 20 then
        local flankOffset = Vector3.new(0, 0, if math.random() > 0.5 then 18 else -18)
        return directTarget + flankOffset
    end

    return directTarget
end

local function updateBotPlayerAI(
    bot: Model?,
    enemyGoalPos: Vector3,
    rivalBot: Model?,
    lastShotTime: number,
    lastPowerShotTime: number,
    sprintStart: number,
    sprintEnd: number,
    lastStealTime: number
): (number, number, number, number, number)

    if not bot or not bot.Parent or isGoalCelebrating then
        return lastShotTime, lastPowerShotTime, sprintStart, sprintEnd, lastStealTime
    end

    local botHrp = bot:FindFirstChild("HumanoidRootPart") :: BasePart?
    local humanoid = bot:FindFirstChildOfClass("Humanoid")
    if not botHrp or not humanoid or humanoid.Health <= 0 then
        return lastShotTime, lastPowerShotTime, sprintStart, sprintEnd, lastStealTime
    end

    local botStats = characterStats[bot]
    sprintStart, sprintEnd = updateBotSprint(humanoid, sprintStart, sprintEnd, botStats)

    local now = os.clock()
    local rivalHrp = rivalBot and rivalBot.Parent and rivalBot:FindFirstChild("HumanoidRootPart") :: BasePart?

    -- A) CONDUCCIÓN, REGATE Y TIROS VARIADOS (RASO O AÉREO)
    if currentOwner == bot then
        local smartTarget = calculateDribbleTarget(botHrp, enemyGoalPos, rivalHrp, botStats)
        humanoid:MoveTo(smartTarget)

        local distToGoal = (enemyGoalPos - botHrp.Position).Magnitude
        local canShoot = (now - lastShotTime >= SHOT_COOLDOWN_TIME)

        local shotMultiplier = if botStats then getShotPowerMultiplier(botStats.shot) else 1.0
        local triggerRange = if botStats then getShotRangeFromStat(botStats.shot) else 50

        if canShoot and currentBall and not isKickOnCooldown then
            -- Disparo preciso con ángulo hacia los postes/escuadras para batir al portero
            local goalPostTarget = enemyGoalPos
            local shotStat = if botStats then botStats.shot else 75
            -- Jugadores con más de 85 de tiro apuntan deliberadamente a las esquinas
            if shotStat >= 85 then
                local sideOffset = if math.random() > 0.5 then (GOAL_WIDTH / 2 - 2) else -(GOAL_WIDTH / 2 - 2)
                goalPostTarget = enemyGoalPos + Vector3.new(0, math.random(2, 6), sideOffset)
            else
                -- Dispersión natural según baja estadística de disparo
                local errorSpread = (100 - shotStat) * 0.12
                goalPostTarget = enemyGoalPos + Vector3.new(0, 0, (math.random() - 0.5) * errorSpread)
            end

            -- Power Shot cada 10s (hasta desde 140 studs si tiene buen tiro)
            local maxPowerRange = 100 + (botStats and botStats.shot or 80) * 0.5
            if (now - lastPowerShotTime >= 10.0) and distToGoal < maxPowerRange then
                lastShotTime = now
                lastPowerShotTime = now
                releaseBall()
                isKickOnCooldown = true

                local shootDir = (goalPostTarget - botHrp.Position).Unit
                local isAerial = (math.random(1, 100) <= 60)
                local liftY = if isAerial then math.random(24, 36) else math.random(10, 16)

                currentBall.CFrame = currentBall.CFrame + (shootDir * 2.5)
                currentBall.AssemblyLinearVelocity = (shootDir * (165 * shotMultiplier)) + Vector3.new(0, liftY, 0)
                currentBall.AssemblyAngularVelocity = Vector3.new(-shootDir.Z, 0, shootDir.X) * 75
                igniteBallInFlames(3.0)

                task.delay(0.5, function()
                    isKickOnCooldown = false
                end)
            -- Tiro normal variado (por los aires o raso)
            elseif distToGoal < triggerRange then
                lastShotTime = now
                releaseBall()
                isKickOnCooldown = true

                local shootDir = (goalPostTarget - botHrp.Position).Unit
                local isAerial = (math.random(1, 100) <= 50)
                local liftY = if isAerial then math.random(22, 32) else math.random(8, 14)
                local speed = (110 * shotMultiplier)

                currentBall.CFrame = currentBall.CFrame + (shootDir * 2.2)
                currentBall.AssemblyLinearVelocity = (shootDir * speed) + Vector3.new(0, liftY, 0)

                task.delay(0.5, function()
                    isKickOnCooldown = false
                end)
            end
        end

        return lastShotTime, lastPowerShotTime, sprintStart, sprintEnd, lastStealTime
    end

    -- B) PERSECUCIÓN, ANTICIPACIÓN Y ROBO CON STAT DE DEFENSA
    local targetPos: Vector3? = nil
    local defenseStat = if botStats then botStats.defense else 60
    local stealCooldown = getStealCooldownFromStat(defenseStat)
    local stealRadius = getStealRadiusFromStat(defenseStat)

    if currentOwner and currentOwner.Parent and currentOwner ~= bot then
        local targetHrp = currentOwner:FindFirstChild("HumanoidRootPart") :: BasePart?
        if targetHrp then
            local toOpponent = targetHrp.Position - botHrp.Position
            local oppDist = toOpponent.Magnitude
            local oppVelocity = targetHrp.AssemblyLinearVelocity

            -- Si tiene alta defensa (>75), anticipa la trayectoria en vez de correr hacia su espalda
            if defenseStat > 75 and oppDist > 10 then
                local interceptLead = math.clamp(oppDist / 35, 0.2, 0.8)
                local anticipatedPos = targetHrp.Position + Vector3.new(oppVelocity.X, 0, oppVelocity.Z) * interceptLead
                
                -- Colocarse entre el portador y su propia portería para cerrar espacios
                local ownGoalCenter = if enemyGoalPos.X > 0 then Vector3.new(-halfX, 4, 0) else Vector3.new(halfX, 4, 0)
                local goalToCarrier = (anticipatedPos - ownGoalCenter).Unit
                targetPos = ownGoalCenter + (goalToCarrier * (ownGoalCenter - anticipatedPos).Magnitude * 0.88)
            else
                targetPos = targetHrp.Position
            end

            local canSteal = (now - lastStealTime >= stealCooldown)
            if canSteal and oppDist < stealRadius and not isKickOnCooldown then
                lastStealTime = now
                attachBallToPlayer(bot)
            end
        end
    elseif currentBall and currentBall.Parent then
        local ballPos = currentBall.Position
        local ballVel = currentBall.AssemblyLinearVelocity

        -- Anticipación a balones sueltos o en movimiento rápido
        if ballVel.Magnitude > 20 and (botHrp.Position - ballPos).Magnitude > 15 then
            local leadTime = math.clamp((botHrp.Position - ballPos).Magnitude / 40, 0.2, 0.7)
            targetPos = ballPos + Vector3.new(ballVel.X, 0, ballVel.Z) * leadTime
        else
            targetPos = ballPos
        end

        if (botHrp.Position - currentBall.Position).Magnitude < stealRadius and not isKickOnCooldown then
            attachBallToPlayer(bot)
        end
    end

    if targetPos then
        humanoid:MoveTo(targetPos)
    end

    return lastShotTime, lastPowerShotTime, sprintStart, sprintEnd, lastStealTime
end

RunService.Heartbeat:Connect(function()
    updateGoalkeeperAI(goalkeeperBlue, -halfX + 4)
    updateGoalkeeperAI(goalkeeperRed, halfX - 4)

    -- Robo del jugador humano según su stat de defensa
    if (currentOwner == botRed or currentOwner == botBlue) and currentBall and not isKickOnCooldown then
        for _, pl in ipairs(Players:GetPlayers()) do
            local pChar = pl.Character
            local pHrp = pChar and pChar:FindFirstChild("HumanoidRootPart") :: BasePart?
            local pStats = pChar and characterStats[pChar]
            local pRadius = if pStats then getStealRadiusFromStat(pStats.defense) else 4.5
            if pHrp and (pHrp.Position - currentBall.Position).Magnitude < pRadius then
                attachBallToPlayer(pChar)
                break
            end
        end
    end

    botRedLastShotTime, botRedLastPowerShot, botRedSprintStart, botRedSprintEnd, botRedLastStealTime = updateBotPlayerAI(
        botRed,
        BLUE_GOAL_CENTER,
        botBlue,
        botRedLastShotTime,
        botRedLastPowerShot,
        botRedSprintStart,
        botRedSprintEnd,
        botRedLastStealTime
    )

    botBlueLastShotTime, botBlueLastPowerShot, botBlueSprintStart, botBlueSprintEnd, botBlueLastStealTime = updateBotPlayerAI(
        botBlue,
        RED_GOAL_CENTER,
        botRed,
        botBlueLastShotTime,
        botBlueLastPowerShot,
        botBlueSprintStart,
        botBlueSprintEnd,
        botBlueLastStealTime
    )
end)

--------------------------------------------------------------------------------
-- 14. COMANDOS DE CHAT
--------------------------------------------------------------------------------
local function handleChatMessage(player: Player, rawMessage: string)
    local clean = string.lower(string.match(rawMessage, "^%s*(.-)%s*$") or rawMessage)
    
    if clean == "/bot" or clean == "bot" or clean == "!bot" then
        spawnBothBots(player)
    elseif clean == "ball!" or clean == "/ball!" or clean == "ball" then
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        local cf = (hrp and (hrp.CFrame * CFrame.new(0, 0, -4))) or CFrame.new(0, 2.5, 0)
        spawnBall(cf)
    end
end

pcall(function()
    local textChannels = TextChatService:FindFirstChild("TextChannels")
    if textChannels then
        local function attachChannel(channel: Instance)
            if channel:IsA("TextChannel") then
                channel.MessageReceived:Connect(function(textChatMessage)
                    local textSource = textChatMessage.TextSource
                    if textSource then
                        local sender = Players:GetPlayerByUserId(textSource.UserId)
                        if sender then
                            handleChatMessage(sender, textChatMessage.Text)
                        end
                    end
                end)
            end
        end
        for _, ch in ipairs(textChannels:GetChildren()) do
            attachChannel(ch)
        end
        textChannels.ChildAdded:Connect(attachChannel)
    end

    TextChatService.MessageReceived:Connect(function(textChatMessage)
        local textSource = textChatMessage.TextSource
        if textSource then
            local sender = Players:GetPlayerByUserId(textSource.UserId)
            if sender then
                handleChatMessage(sender, textChatMessage.Text)
            end
        end
    end)
end)

Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        handleChatMessage(player, msg)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if currentOwner and currentOwner.Name == player.Name then
        releaseBall()
    end
end)
