local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

print("==========================================================================")
print("[SERVIDOR] Futbol Táctico 6v6 Automatizado: Gran Estadio, Formaciones e IA")
print("==========================================================================")

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
-- 2. CONSTRUCCIÓN DEL GRAN ESTADIO REGLAMENTARIO
--------------------------------------------------------------------------------
local FIELD_SIZE = Vector2.new(380, 230)
local WALL_HEIGHT = 28
local WALL_THICKNESS = 3
local GOAL_WIDTH = 34
local GOAL_HEIGHT = 13
local GOAL_DEPTH = 16

-- Dimensiones de áreas reglamentarias (en studs)
local PENALTY_AREA_DEPTH = 58
local PENALTY_AREA_WIDTH = 130
local GOAL_AREA_DEPTH = 22
local GOAL_AREA_WIDTH = 64
local PENALTY_SPOT_DIST = 38
local CENTER_CIRCLE_RADIUS = 32

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

local function createFieldLine(name: string, size: Vector3, position: Vector3): Part
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Color = Color3.fromRGB(245, 245, 245)
    p.Material = Enum.Material.SmoothPlastic
    p.Anchored = true
    p.CanCollide = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = pitchFolder
    return p
end

-- Césped principal (Campo gigante)
createFieldPart("CespedePrincipal", Vector3.new(FIELD_SIZE.X, 1, FIELD_SIZE.Y), Vector3.new(0, 0, 0), Color3.fromRGB(38, 140, 52), Enum.Material.Grass)

-- Césped perimetral exterior
createFieldPart("BandaExterior", Vector3.new(FIELD_SIZE.X + 30, 0.95, FIELD_SIZE.Y + 30), Vector3.new(0, -0.05, 0), Color3.fromRGB(32, 115, 42), Enum.Material.Grass)

-- Líneas de banda y fondo
local halfX = FIELD_SIZE.X / 2
local halfY = FIELD_SIZE.Y / 2
local lineThick = 1.2
local lineH = 0.02

createFieldLine("LineaBandaNorte", Vector3.new(FIELD_SIZE.X, lineH, lineThick), Vector3.new(0, FIELD_Y, -halfY))
createFieldLine("LineaBandaSur", Vector3.new(FIELD_SIZE.X, lineH, lineThick), Vector3.new(0, FIELD_Y, halfY))
createFieldLine("LineaFondoOeste", Vector3.new(lineThick, lineH, FIELD_SIZE.Y), Vector3.new(-halfX, FIELD_Y, 0))
createFieldLine("LineaFondoEste", Vector3.new(lineThick, lineH, FIELD_SIZE.Y), Vector3.new(halfX, FIELD_Y, 0))

-- Línea central divisoria
createFieldLine("LineaCentro", Vector3.new(lineThick, lineH, FIELD_SIZE.Y), Vector3.new(0, FIELD_Y, 0))

-- Círculo central (Malla hueca en Y = 0.51)
local ringMeshPart = Instance.new("Part")
ringMeshPart.Name = "AroCentralHueco"
ringMeshPart.Size = Vector3.new(CENTER_CIRCLE_RADIUS * 2, lineH, CENTER_CIRCLE_RADIUS * 2)
ringMeshPart.Position = Vector3.new(0, FIELD_Y, 0)
ringMeshPart.Color = Color3.fromRGB(245, 245, 245)
ringMeshPart.Material = Enum.Material.SmoothPlastic
ringMeshPart.Anchored = true
ringMeshPart.CanCollide = false
ringMeshPart.Parent = pitchFolder

local ringSpecialMesh = Instance.new("SpecialMesh")
ringSpecialMesh.MeshType = Enum.MeshType.FileMesh
ringSpecialMesh.MeshId = "rbxassetid://3270017"
ringSpecialMesh.Scale = Vector3.new(CENTER_CIRCLE_RADIUS, CENTER_CIRCLE_RADIUS, 0.02)
ringSpecialMesh.Parent = ringMeshPart

-- Punto central
local centerDot = Instance.new("Part")
centerDot.Name = "PuntoCentralBalon"
centerDot.Shape = Enum.PartType.Cylinder
centerDot.Size = Vector3.new(lineH, 2.4, 2.4)
centerDot.CFrame = CFrame.new(0, FIELD_Y, 0) * CFrame.Angles(0, 0, math.rad(90))
centerDot.Color = Color3.fromRGB(245, 245, 245)
centerDot.Material = Enum.Material.SmoothPlastic
centerDot.Anchored = true
centerDot.CanCollide = false
centerDot.Parent = pitchFolder

-- Construcción de Áreas Grande, Pequeña y Puntos de Penalti para cada portería
local function buildGoalAreas(sideSign: number, teamTag: string)
    local goalLineX = halfX * sideSign
    local inwardDir = -sideSign

    -- 1. Área Grande (Penalty Box)
    local pAreaFrontX = goalLineX + (inwardDir * PENALTY_AREA_DEPTH)
    local pAreaCenterX = goalLineX + (inwardDir * (PENALTY_AREA_DEPTH / 2))
    createFieldLine("AreaGrande_Front_" .. teamTag, Vector3.new(lineThick, lineH, PENALTY_AREA_WIDTH), Vector3.new(pAreaFrontX, FIELD_Y, 0))
    createFieldLine("AreaGrande_Top_" .. teamTag, Vector3.new(PENALTY_AREA_DEPTH, lineH, lineThick), Vector3.new(pAreaCenterX, FIELD_Y, -PENALTY_AREA_WIDTH/2))
    createFieldLine("AreaGrande_Bottom_" .. teamTag, Vector3.new(PENALTY_AREA_DEPTH, lineH, lineThick), Vector3.new(pAreaCenterX, FIELD_Y, PENALTY_AREA_WIDTH/2))

    -- 2. Área Pequeña (Goal Box)
    local gAreaFrontX = goalLineX + (inwardDir * GOAL_AREA_DEPTH)
    local gAreaCenterX = goalLineX + (inwardDir * (GOAL_AREA_DEPTH / 2))
    createFieldLine("AreaPequena_Front_" .. teamTag, Vector3.new(lineThick, lineH, GOAL_AREA_WIDTH), Vector3.new(gAreaFrontX, FIELD_Y, 0))
    createFieldLine("AreaPequena_Top_" .. teamTag, Vector3.new(GOAL_AREA_DEPTH, lineH, lineThick), Vector3.new(gAreaCenterX, FIELD_Y, -GOAL_AREA_WIDTH/2))
    createFieldLine("AreaPequena_Bottom_" .. teamTag, Vector3.new(GOAL_AREA_DEPTH, lineH, lineThick), Vector3.new(gAreaCenterX, FIELD_Y, GOAL_AREA_WIDTH/2))

    -- 3. Punto de Penalti
    local penaltySpotX = goalLineX + (inwardDir * PENALTY_SPOT_DIST)
    local penSpot = Instance.new("Part")
    penSpot.Name = "PuntoPenalti_" .. teamTag
    penSpot.Shape = Enum.PartType.Cylinder
    penSpot.Size = Vector3.new(lineH, 2.0, 2.0)
    penSpot.CFrame = CFrame.new(penaltySpotX, FIELD_Y, 0) * CFrame.Angles(0, 0, math.rad(90))
    penSpot.Color = Color3.fromRGB(245, 245, 245)
    penSpot.Material = Enum.Material.SmoothPlastic
    penSpot.Anchored = true
    penSpot.CanCollide = false
    penSpot.Parent = pitchFolder
end

buildGoalAreas(-1, "Azul")
buildGoalAreas(1, "Rojo")

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

-- Muros perimetrales
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
    local postThick = 1.0
    local barColor = Color3.fromRGB(245, 245, 245)

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
-- 4. STATS Y MODELOS DE JUGADORES
--------------------------------------------------------------------------------
type PlayerStats = {
    name: string,
    role: string, -- "Delantero", "Central", "Defensa"
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
    {name = "Luka Modrić", role = "Central", speed = 75, shot = 84, defense = 78},
    {name = "Kevin De Bruyne", role = "Central", speed = 78, shot = 90, defense = 72},
    {name = "Zinedine Zidane", role = "Central", speed = 79, shot = 89, defense = 75},
    {name = "Andrés Iniesta", role = "Central", speed = 80, shot = 83, defense = 74},
    {name = "Xavi Hernández", role = "Central", speed = 77, shot = 81, defense = 76},
    {name = "Jude Bellingham", role = "Central", speed = 84, shot = 87, defense = 79},
    {name = "Virgil van Dijk", role = "Defensa", speed = 81, shot = 60, defense = 96},
    {name = "Sergio Ramos", role = "Defensa", speed = 78, shot = 72, defense = 94},
    {name = "Carles Puyol", role = "Defensa", speed = 77, shot = 55, defense = 97},
    {name = "Paolo Maldini", role = "Defensa", speed = 83, shot = 58, defense = 98},
    {name = "Alessandro Nesta", role = "Defensa", speed = 80, shot = 52, defense = 95},
    {name = "Ronaldinho", role = "Delantero", speed = 88, shot = 92, defense = 40},
}

local characterStats: { [Model]: PlayerStats } = {}

local function getWalkSpeedFromStat(speedStat: number): number
    return 14 + (speedStat / 100) * 10
end

local function getSprintSpeedFromStat(speedStat: number): number
    return 22 + (speedStat / 100) * 14
end

local function getStealRadiusFromStat(defenseStat: number): number
    return 4.0 + (defenseStat / 100) * 3.2
end

local function getStealCooldownFromStat(defenseStat: number): number
    return 3.5 - (defenseStat / 100) * 1.8
end

local function getShotPowerMultiplier(shotStat: number): number
    return 0.6 + (shotStat / 100) * 0.75
end

local function getShotRangeFromStat(shotStat: number): number
    return 40 + (shotStat / 100) * 55
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
local SHOT_COOLDOWN_TIME = 4.5
local lastPlayerShotTime: { [Player]: number } = {}

local currentBall: Part? = nil
local currentOwner: Model? = nil
local activeWeld: WeldConstraint? = nil
local serverChargeStartTime: number? = nil
local isKickOnCooldown = false
local isGoalCelebrating = false

local scoreBlue = 0
local scoreRed = 0

local BLUE_GOAL_CENTER = Vector3.new(-halfX, 4, 0)
local RED_GOAL_CENTER = Vector3.new(halfX, 4, 0)

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

    local isRed = string.find(character.Name, "Rojo") ~= nil
    createAuraRing(character, if isRed then RING_COLOR_RED else RING_COLOR_BLUE)

    local player = Players:GetPlayerFromCharacter(character)
    if player then
        ballPossessionEvent:FireClient(player, true)
    end
end

--------------------------------------------------------------------------------
-- 9. ESTRUCTURA Y COORDINADOR DE EQUIPOS (6v6 BOTS)
--------------------------------------------------------------------------------
type BotSlot = {
    model: Model,
    role: string,            -- "Delantero", "Central", "Defensa"
    roleId: string,          -- "ST", "CM1", "CM2", "DEF1", "DEF2", "DEF3"
    teamName: string,        -- "Azul" | "Rojo"
    basePosition: Vector3,
    stats: PlayerStats,
    lastPassTime: number,
    lastShotTime: number,
    lastStealTime: number,
}

local teamBlueBots: { [string]: BotSlot } = {}
local teamRedBots: { [string]: BotSlot } = {}

-- Puestos de inicio de la formación 3-2-1 (relativo a las mitades del campo de 380 studs)
-- Porterías en X = -190 (Azul) y X = 190 (Rojo)
local FORMATION_BLUE: { [string]: { role: string, pos: Vector3, label: string } } = {
    ["DEF1"] = { role = "Defensa", pos = Vector3.new(-130, 3, -50), label = "Defensa Izq" },
    ["DEF2"] = { role = "Defensa", pos = Vector3.new(-140, 3, 0),   label = "Defensa Central" },
    ["DEF3"] = { role = "Defensa", pos = Vector3.new(-130, 3, 50),  label = "Defensa Der" },
    ["CM1"]  = { role = "Central", pos = Vector3.new(-75, 3, -32),  label = "Central Izq" },
    ["CM2"]  = { role = "Central", pos = Vector3.new(-75, 3, 32),   label = "Central Der" },
    ["ST"]   = { role = "Delantero", pos = Vector3.new(-25, 3, 0),  label = "Delantero" },
}

local FORMATION_RED: { [string]: { role: string, pos: Vector3, label: string } } = {
    ["DEF1"] = { role = "Defensa", pos = Vector3.new(130, 3, 50),   label = "Defensa Izq" },
    ["DEF2"] = { role = "Defensa", pos = Vector3.new(140, 3, 0),    label = "Defensa Central" },
    ["DEF3"] = { role = "Defensa", pos = Vector3.new(130, 3, -50),  label = "Defensa Der" },
    ["CM1"]  = { role = "Central", pos = Vector3.new(75, 3, 32),   label = "Central Izq" },
    ["CM2"]  = { role = "Central", pos = Vector3.new(75, 3, -32),  label = "Central Der" },
    ["ST"]   = { role = "Delantero", pos = Vector3.new(25, 3, 0),   label = "Delantero" },
}

-- Función constructora de Bot modelo R6 completo
local function buildSoccerBot(teamName: string, roleId: string, role: string, roleLabel: string, basePos: Vector3, jerseyColor: Color3): BotSlot
    local pool: {PlayerStats} = {}
    for _, item in ipairs(FAMOUS_PLAYERS_DATA) do
        if item.role == role then
            table.insert(pool, item)
        end
    end
    if #pool == 0 then pool = FAMOUS_PLAYERS_DATA end
    local statsTemplate = pool[math.random(1, #pool)]
    local randomName = statsTemplate.name

    local bot = Instance.new("Model")
    bot.Name = string.format("Bot_%s_%s_%s", teamName, roleId, randomName)

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
    hrp.CFrame = CFrame.new(basePos)

    local torso = makePart("Torso", Vector3.new(2, 2, 1), jerseyColor)
    local head = makePart("Head", Vector3.new(1.25, 1.25, 1.25), Color3.fromRGB(240, 200, 160))
    local headMesh = Instance.new("SpecialMesh")
    headMesh.MeshType = Enum.MeshType.Head
    headMesh.Scale = Vector3.new(1.25, 1.25, 1.25)
    headMesh.Parent = head

    local leftArm = makePart("Left Arm", Vector3.new(1, 2, 1), jerseyColor)
    local rightArm = makePart("Right Arm", Vector3.new(1, 2, 1), jerseyColor)
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
    humanoid.JumpHeight = 0
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    humanoid.Parent = bot

    -- Billboard informativo
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 240, 0, 68)
    billboard.StudsOffset = Vector3.new(0, 3.4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.48, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = string.format("[%s - %s] %s", string.upper(teamName), roleId, randomName)
    nameLabel.TextColor3 = jerseyColor
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

    local slot: BotSlot = {
        model = bot,
        role = role,
        roleId = roleId,
        teamName = teamName,
        basePosition = basePos,
        stats = statsTemplate,
        lastPassTime = 0,
        lastShotTime = 0,
        lastStealTime = 0,
    }

    return slot
end

local function cleanTeam(teamSlots: { [string]: BotSlot })
    for roleId, slot in pairs(teamSlots) do
        if slot.model and slot.model.Parent then
            if currentOwner == slot.model then releaseBall() end
            characterStats[slot.model] = nil
            slot.model:Destroy()
        end
        teamSlots[roleId] = nil
    end
end

local function spawnFull6v6Match()
    cleanTeam(teamBlueBots)
    cleanTeam(teamRedBots)

    -- Spawn Equipo Azul (6 jugadores)
    for roleId, data in pairs(FORMATION_BLUE) do
        local slot = buildSoccerBot("Azul", roleId, data.role, data.label, data.pos, Color3.fromRGB(35, 145, 245))
        teamBlueBots[roleId] = slot
    end

    -- Spawn Equipo Rojo (6 jugadores)
    for roleId, data in pairs(FORMATION_RED) do
        local slot = buildSoccerBot("Rojo", roleId, data.role, data.label, data.pos, Color3.fromRGB(235, 45, 45))
        teamRedBots[roleId] = slot
    end

    print("[SERVIDOR] ¡Partido 6v6 iniciado! 12 bots en el campo con roles y zonas tácticas.")
end

--------------------------------------------------------------------------------
-- 10. SPAWN DEL BALÓN Y GESTIÓN DE GOLES
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
    for roleId, slot in pairs(teamBlueBots) do
        if slot.model and slot.model.Parent then
            local hrp = slot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
            if hrp then
                hrp.CFrame = CFrame.new(slot.basePosition + Vector3.new(0, 0, math.random(-4, 4)))
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end

    for roleId, slot in pairs(teamRedBots) do
        if slot.model and slot.model.Parent then
            local hrp = slot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
            if hrp then
                hrp.CFrame = CFrame.new(slot.basePosition + Vector3.new(0, 0, math.random(-4, 4)))
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        local pChar = p.Character
        local pHrp = pChar and pChar:FindFirstChild("HumanoidRootPart") :: BasePart?
        if pHrp then
            pHrp.CFrame = CFrame.new(-60, 3, math.random(-10, 10))
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

    task.delay(1.5, function()
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
-- 11. EVENTOS DE DISPARO DEL JUGADOR HUMANO
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

    if not checkPlayerCooldown(player) then return end
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

    pcall(function() currentBall:SetNetworkOwner(player) end)

    local speed = (BASE_MIN_SPEED + (powerRatio * (BASE_MAX_SPEED - BASE_MIN_SPEED))) * shotMultiplier
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
            if currentBall then currentBall:SetNetworkOwner(nil) end
        end)
    end)
end)

quickShotEvent.OnServerEvent:Connect(function(player, clientAimDirection: Vector3)
    local char = player.Character
    if not char or currentOwner ~= char or not currentBall or isKickOnCooldown or isGoalCelebrating then
        return
    end

    if not checkPlayerCooldown(player) then return end
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

    pcall(function() currentBall:SetNetworkOwner(player) end)

    local speed = 160 * shotMultiplier
    local lift = 18
    if shootDir.Y > 0.1 then
        lift = lift + (shootDir.Y * 30)
    end

    currentBall.CFrame = currentBall.CFrame + (shootDir * 2.2)
    currentBall.AssemblyLinearVelocity = (Vector3.new(shootDir.X, 0, shootDir.Z).Unit * speed) + Vector3.new(0, lift, 0)

    task.delay(0.5, function()
        isKickOnCooldown = false
        pcall(function()
            if currentBall then currentBall:SetNetworkOwner(nil) end
        end)
    end)
end)

--------------------------------------------------------------------------------
-- 12. PORTEROS INTELIGENTES Y CON CAPACIDAD DE SALTO (ÚNICOS CON SALTO)
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
    humanoid.WalkSpeed = 38
    humanoid.JumpPower = 52 -- Portero sí tiene capacidad de salto
    humanoid.JumpHeight = 7.5
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    humanoid.Parent = gk

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 45)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🧤 " .. nameLabel
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

    for _, p in ipairs(gk:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Name ~= "ImpossibleShield" then
            p.CanCollide = true
            p.CollisionGroup = "Default"
            p.CustomPhysicalProperties = PhysicalProperties.new(1.2, 0.4, 0.8, 1, 1)
        end
    end

    gk.PrimaryPart = hrp
    setupCharacterCollision(gk)

    local isHandlingBall = false
    local function catchAndPass()
        if not currentBall or isKickOnCooldown or isGoalCelebrating or isHandlingBall then return end

        local ballSpeed = currentBall.AssemblyLinearVelocity.Magnitude
        if ballSpeed > 130 then
            local failChance = math.clamp((ballSpeed - 130) * 1.5, 5, 25)
            if math.random(1, 100) <= failChance then
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

        task.delay(0.4, function()
            if not currentBall then
                isHandlingBall = false
                isKickOnCooldown = false
                return
            end

            -- Buscar compañero para sacar en largo o corto
            local allySlots = if teamName == "Azul" then teamBlueBots else teamRedBots
            local passCandidate: BasePart? = nil

            -- Priorizar pasar a un central o lateral libre
            local candidates = { allySlots["CM1"], allySlots["CM2"], allySlots["DEF1"], allySlots["DEF3"] }
            for _, c in ipairs(candidates) do
                if c and c.model and c.model.Parent then
                    local cHrp = c.model:FindFirstChild("HumanoidRootPart") :: BasePart?
                    if cHrp then
                        passCandidate = cHrp
                        break
                    end
                end
            end

            local targetPos = if passCandidate then passCandidate.Position + Vector3.new(if posX < 0 then 10 else -10, 0, 0) else Vector3.new(0, 3, 0)
            local flatDir = Vector3.new(targetPos.X - hrp.Position.X, 0, targetPos.Z - hrp.Position.Z)
            local dist = flatDir.Magnitude
            local unitDir = if dist > 0.1 then flatDir.Unit else Vector3.new(if posX < 0 then 1 else -1, 0, 0)

            local speed = math.clamp(dist * 1.6, 75, 140)
            local liftY = 28 + (dist * 0.15)

            currentBall.CFrame = currentBall.CFrame + (unitDir * 2.5) + Vector3.new(0, 1.2, 0)
            currentBall.AssemblyLinearVelocity = (unitDir * speed) + Vector3.new(0, liftY, 0)
            currentBall.AssemblyAngularVelocity = Vector3.new(-unitDir.Z, 0, unitDir.X) * 35

            task.delay(0.5, function()
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

goalkeeperBlue = createGoalkeeper("Azul", -halfX + 4, Color3.fromRGB(0, 160, 255), "Portero Azul")
goalkeeperRed = createGoalkeeper("Rojo", halfX - 4, Color3.fromRGB(255, 60, 60), "Portero Rojo")

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

        local reactionJitter = (math.sin(os.clock() * 5) * 0.4)

        if headingTowardsGoal then
            local targetZ = math.clamp(predictedZ + reactionJitter, -(GOAL_WIDTH / 2 - 1.5), (GOAL_WIDTH / 2 - 1.5))
            local distZ = math.abs(hrp.Position.Z - targetZ)

            -- Salto y estirada del portero cuando el balón viene alto
            local isBallHigh = (ballPos.Y > 6 or (ballVel.Y > 5 and timeToReach < 1.0))
            if isBallHigh and humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end

            if distZ > 4 and timeToReach < 0.8 then
                humanoid.WalkSpeed = 50
                local diveDir = Vector3.new(0, 0, math.sign(targetZ - hrp.Position.Z))
                hrp.AssemblyLinearVelocity = Vector3.new(0, 10, diveDir.Z * 34)
            else
                humanoid.WalkSpeed = 40
            end
            humanoid:MoveTo(Vector3.new(goalX, 3, targetZ))
        else
            -- Posicionamiento en arco bisectriz
            local toBall = (ballPos - goalCenter)
            local flatDir = Vector3.new(toBall.X, 0, toBall.Z).Unit
            local advance = math.clamp(toBall.Magnitude * 0.08, 0, 9)
            local targetPos = goalCenter + (flatDir * advance)
            
            targetPos = Vector3.new(
                if isLeftGoal then math.clamp(targetPos.X, goalX, goalX + 10) else math.clamp(targetPos.X, goalX - 10, goalX),
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
-- 13. SISTEMA DE PASES, INTELIGENCIA TÁCTICA Y ZONAS DE ACTUACIÓN
--------------------------------------------------------------------------------

-- Helper para encontrar si un receptor de pase está libre de intercepción rival
local function findBestPassTarget(passerSlot: BotSlot, allyTeam: { [string]: BotSlot }, enemyTeam: { [string]: BotSlot }): (BotSlot?, number)
    local passerHrp = passerSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not passerHrp then return nil, 0 end

    local passerPos = passerHrp.Position
    local bestTarget: BotSlot? = nil
    local bestScore = -9999

    for roleId, candidate in pairs(allyTeam) do
        if candidate ~= passerSlot and candidate.model and candidate.model.Parent then
            local cHumanoid = candidate.model:FindFirstChildOfClass("Humanoid")
            local cHrp = candidate.model:FindFirstChild("HumanoidRootPart") :: BasePart?
            if cHumanoid and cHumanoid.Health > 0 and cHrp then
                local toCandidate = cHrp.Position - passerPos
                local dist = toCandidate.Magnitude

                if dist > 15 and dist < 120 then
                    local passDir = Vector3.new(toCandidate.X, 0, toCandidate.Z).Unit
                    local isClear = true

                    -- Comprobar si algún rival intercepta la línea de pase
                    for _, enemySlot in pairs(enemyTeam) do
                        if enemySlot.model and enemySlot.model.Parent then
                            local eHrp = enemySlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
                            if eHrp then
                                local toEnemy = eHrp.Position - passerPos
                                local proj = toEnemy:Dot(passDir)
                                if proj > 0 and proj < dist then
                                    local perpDist = (toEnemy - (passDir * proj)).Magnitude
                                    if perpDist < 9 then
                                        isClear = false
                                        break
                                    end
                                end
                            end
                        end
                    end

                    if isClear then
                        -- Calcular puntuación táctica
                        local forwardBonus = if passerSlot.teamName == "Azul" then (cHrp.Position.X - passerPos.X) else (passerPos.X - cHrp.Position.X)
                        local roleBonus = 0
                        if candidate.role == "Delantero" then roleBonus = 40
                        elseif candidate.role == "Central" then roleBonus = 25
                        else roleBonus = 10 end

                        local totalScore = forwardBonus + roleBonus - (dist * 0.2)
                        if totalScore > bestScore then
                            bestScore = totalScore
                            bestTarget = candidate
                        end
                    end
                end
            end
        end
    end

    return bestTarget, bestScore
end

-- Ejecutar un pase limpio por el suelo o raso al compañero
local function executePass(passerSlot: BotSlot, targetSlot: BotSlot)
    if not currentBall or isKickOnCooldown or currentOwner ~= passerSlot.model then return end
    local passerHrp = passerSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
    local targetHrp = targetSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not passerHrp or not targetHrp then return end

    releaseBall()
    isKickOnCooldown = true

    -- Calcular pase al espacio (adelantado a la velocidad del compañero)
    local targetVel = targetHrp.AssemblyLinearVelocity
    local leadTime = math.clamp((targetHrp.Position - passerHrp.Position).Magnitude / 65, 0.2, 0.6)
    local leadPos = targetHrp.Position + Vector3.new(targetVel.X, 0, targetVel.Z) * leadTime

    local passDir = (leadPos - passerHrp.Position)
    local dist = passDir.Magnitude
    local unitDir = if dist > 0.1 then passDir.Unit else passerHrp.CFrame.LookVector

    local passSpeed = math.clamp(dist * 1.8, 60, 125)
    local lift = if dist > 45 then 12 else 4

    currentBall.CFrame = currentBall.CFrame + (unitDir * 2.2) + Vector3.new(0, 0.5, 0)
    currentBall.AssemblyLinearVelocity = (unitDir * passSpeed) + Vector3.new(0, lift, 0)

    passerSlot.lastPassTime = os.clock()

    task.delay(0.4, function()
        isKickOnCooldown = false
    end)
end

-- Despeje defensivo de emergencia hacia campo rival
local function executeClearance(botSlot: BotSlot, enemyGoalPos: Vector3)
    if not currentBall or isKickOnCooldown or currentOwner ~= botSlot.model then return end
    local hrp = botSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not hrp then return end

    releaseBall()
    isKickOnCooldown = true

    local clearDir = (enemyGoalPos - hrp.Position).Unit
    local liftY = math.random(32, 45)
    local speed = math.random(110, 150)

    currentBall.CFrame = currentBall.CFrame + (clearDir * 2.5) + Vector3.new(0, 1.2, 0)
    currentBall.AssemblyLinearVelocity = (clearDir * speed) + Vector3.new(0, liftY, 0)
    currentBall.AssemblyAngularVelocity = Vector3.new(-clearDir.Z, 0, clearDir.X) * 40

    task.delay(0.5, function()
        isKickOnCooldown = false
    end)
end

-- Cálculo de desmarque o reposicionamiento táctico según la zona y situación del partido
local function getTacticalPosition(
    slot: BotSlot,
    hasTeamPossession: boolean,
    hasEnemyPossession: boolean,
    ballPos: Vector3,
    enemyGoalPos: Vector3
): Vector3

    local role = slot.role
    local base = slot.basePosition
    local isBlue = (slot.teamName == "Azul")
    local attackDirX = if isBlue then 1 else -1

    -- ZONAS DE ACTUACIÓN Y POSICIONAMIENTO DINÁMICO
    if role == "Delantero" then
        if hasTeamPossession then
            -- Buscar espacios libres en tres cuartos de cancha rival
            local goalOffsetZ = math.clamp(ballPos.Z * 0.7, -45, 45)
            local attackX = (halfX - 45) * attackDirX
            return Vector3.new(attackX, 3, goalOffsetZ)
        elseif hasEnemyPossession then
            -- Posicionamiento dinámico: esperar el contragolpe en mitad de cancha
            return Vector3.new(35 * attackDirX, 3, math.clamp(ballPos.Z * 0.4, -30, 30))
        else
            return Vector3.new(50 * attackDirX, 3, 0)
        end

    elseif role == "Central" then
        if hasTeamPossession then
            -- CM1 y CM2 escalonados para que uno suba y el otro guarde la espalda
            local isPrimaryAttacker = (slot.roleId == "CM1")
            if isPrimaryAttacker then
                local advancedX = (ballPos.X * 0.6) + (25 * attackDirX)
                return Vector3.new(math.clamp(advancedX, -halfX + 60, halfX - 60), 3, base.Z + (ballPos.Z * 0.2))
            else
                local coverX = (ballPos.X * 0.5) - (20 * attackDirX)
                return Vector3.new(math.clamp(coverX, -halfX + 45, halfX - 45), 3, base.Z * 0.8)
            end
        elseif hasEnemyPossession then
            -- Regresar a la zona central para frenar la transición
            local shieldX = (ballPos.X * 0.4) - (35 * attackDirX)
            return Vector3.new(math.clamp(shieldX, -halfX + 35, halfX - 35), 3, base.Z)
        else
            return base
        end

    elseif role == "Defensa" then
        if hasEnemyPossession then
            -- Bloque defensivo compacto delante del área grande
            local defLineX = if isBlue then (-halfX + 48) else (halfX - 48)
            local shiftedZ = math.clamp(base.Z + (ballPos.Z * 0.35), -55, 55)
            return Vector3.new(defLineX, 3, shiftedZ)
        else
            -- Mantener la línea en su campo sin subir innecesariamente
            local safeLineX = if isBlue then (-halfX + 65) else (halfX - 65)
            return Vector3.new(safeLineX, 3, base.Z)
        end
    end

    return base
end

-- Actualización centralizada de un bot individual (toma de decisiones táctica)
local function updateBotSlotAI(
    slot: BotSlot,
    allyTeam: { [string]: BotSlot },
    enemyTeam: { [string]: BotSlot },
    designatedPresser: BotSlot?,
    enemyGoalPos: Vector3,
    now: number
)
    local bot = slot.model
    if not bot or not bot.Parent or isGoalCelebrating then return end

    local hrp = bot:FindFirstChild("HumanoidRootPart") :: BasePart?
    local humanoid = bot:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then return end

    -- Garantizar que ningún jugador salte (solo porteros)
    humanoid.JumpPower = 0
    humanoid.JumpHeight = 0

    local botStats = slot.stats
    local ballPos = if currentBall then currentBall.Position else Vector3.zero
    local distToBall = if currentBall then (ballPos - hrp.Position).Magnitude else 999
    local distToEnemyGoal = (enemyGoalPos - hrp.Position).Magnitude

    local isOwner = (currentOwner == bot)
    local isAllyOwner = false
    local isEnemyOwner = false

    if currentOwner then
        local isRedOwner = (string.find(currentOwner.Name, "Rojo") ~= nil)
        local isSlotRed = (slot.teamName == "Rojo")
        if isRedOwner == isSlotRed then
            isAllyOwner = true
        else
            isEnemyOwner = true
        end
    end

    ----------------------------------------------------------------------------
    -- ESTADO 1: EL BOT TIENE EL BALÓN (POSESIÓN Y ATAQUE)
    ----------------------------------------------------------------------------
    if isOwner then
        -- 1. Si es defensa y está muy cerca de su portería y presionado, despejar
        local ownGoalX = if slot.teamName == "Azul" then -halfX else halfX
        local distToOwnGoal = math.abs(hrp.Position.X - ownGoalX)
        if slot.role == "Defensa" and distToOwnGoal < 45 then
            executeClearance(slot, enemyGoalPos)
            return
        end

        -- 2. Evaluar oportunidad de disparo
        local shotMultiplier = getShotPowerMultiplier(botStats.shot)
        local triggerRange = getShotRangeFromStat(botStats.shot)

        if distToEnemyGoal < triggerRange and (now - slot.lastShotTime >= SHOT_COOLDOWN_TIME) and not isKickOnCooldown then
            slot.lastShotTime = now
            releaseBall()
            isKickOnCooldown = true

            local goalPostTarget = enemyGoalPos
            if botStats.shot >= 85 then
                local sideOffset = if math.random() > 0.5 then (GOAL_WIDTH / 2 - 2) else -(GOAL_WIDTH / 2 - 2)
                goalPostTarget = enemyGoalPos + Vector3.new(0, math.random(2, 6), sideOffset)
            else
                local errorSpread = (100 - botStats.shot) * 0.12
                goalPostTarget = enemyGoalPos + Vector3.new(0, 0, (math.random() - 0.5) * errorSpread)
            end

            local shootDir = (goalPostTarget - hrp.Position).Unit
            local isAerial = (math.random(1, 100) <= 50)
            local liftY = if isAerial then math.random(22, 34) else math.random(8, 14)
            local speed = (115 * shotMultiplier)

            currentBall.CFrame = currentBall.CFrame + (shootDir * 2.2)
            currentBall.AssemblyLinearVelocity = (shootDir * speed) + Vector3.new(0, liftY, 0)
            if botStats.shot >= 88 then igniteBallInFlames(2.5) end

            task.delay(0.5, function() isKickOnCooldown = false end)
            return
        end

        -- 3. Evaluar Pase Táctico
        local timeSincePass = now - slot.lastPassTime
        if timeSincePass > 2.0 and not isKickOnCooldown then
            local bestTarget, targetScore = findBestPassTarget(slot, allyTeam, enemyTeam)
            -- Pasar si hay buen receptor o si un rival está encima
            if bestTarget and (targetScore > 15 or distToEnemyGoal > 110) then
                executePass(slot, bestTarget)
                return
            end
        end

        -- 4. Conducción con esquive de rivales
        local forwardDir = (Vector3.new(enemyGoalPos.X, 0, enemyGoalPos.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Unit
        local moveTarget = hrp.Position + (forwardDir * 25)

        -- Buscar rival más cercano enfrente
        for _, eSlot in pairs(enemyTeam) do
            if eSlot.model and eSlot.model.Parent then
                local eHrp = eSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
                if eHrp then
                    local toRival = eHrp.Position - hrp.Position
                    if toRival.Magnitude < 22 and forwardDir:Dot(toRival.Unit) > 0.3 then
                        local perpLeft = Vector3.new(-forwardDir.Z, 0, forwardDir.X)
                        local perpRight = Vector3.new(forwardDir.Z, 0, -forwardDir.X)
                        local dodgeDir = if perpLeft:Dot(eHrp.AssemblyLinearVelocity) > 0 then perpRight else perpLeft
                        moveTarget = hrp.Position + ((forwardDir * 0.55 + dodgeDir * 0.45).Unit * 25)
                        break
                    end
                end
            end
        end

        humanoid:MoveTo(moveTarget)
        return
    end

    ----------------------------------------------------------------------------
    -- ESTADO 2: EL EQUIPO RIVAL TIENE EL BALÓN (DEFENSA ORGANIZADA)
    ----------------------------------------------------------------------------
    if isEnemyOwner then
        local stealRadius = getStealRadiusFromStat(botStats.defense)
        local stealCooldown = getStealCooldownFromStat(botStats.defense)

        -- Solo el jugador designado para presionar corre hacia el portador
        if designatedPresser == slot and currentOwner then
            local carrierHrp = currentOwner:FindFirstChild("HumanoidRootPart") :: BasePart?
            if carrierHrp then
                humanoid:MoveTo(carrierHrp.Position)

                if (carrierHrp.Position - hrp.Position).Magnitude < stealRadius and (now - slot.lastStealTime >= stealCooldown) and not isKickOnCooldown then
                    slot.lastStealTime = now
                    attachBallToPlayer(bot)
                end
                return
            end
        else
            -- Los otros mantienen posición defensiva escalonada y cubren líneas de pase
            local tacticalPos = getTacticalPosition(slot, false, true, ballPos, enemyGoalPos)
            humanoid:MoveTo(tacticalPos)
            return
        end
    end

    ----------------------------------------------------------------------------
    -- ESTADO 3: BALÓN SUELTO
    ----------------------------------------------------------------------------
    if currentOwner == nil and currentBall then
        local stealRadius = getStealRadiusFromStat(botStats.defense)

        if designatedPresser == slot then
            -- El bot asignado persigue y anticipa el balón
            local bVel = currentBall.AssemblyLinearVelocity
            local interceptPos = if bVel.Magnitude > 15 then ballPos + Vector3.new(bVel.X, 0, bVel.Z) * 0.35 else ballPos
            humanoid:MoveTo(interceptPos)

            if distToBall < stealRadius and not isKickOnCooldown then
                attachBallToPlayer(bot)
            end
            return
        else
            -- Mantenerse organizado en su zona
            local tacticalPos = getTacticalPosition(slot, false, false, ballPos, enemyGoalPos)
            humanoid:MoveTo(tacticalPos)
            return
        end
    end

    ----------------------------------------------------------------------------
    -- ESTADO 4: UN COMPAÑERO TIENE EL BALÓN (APOYO Y DESMARQUE)
    ----------------------------------------------------------------------------
    if isAllyOwner then
        local tacticalPos = getTacticalPosition(slot, true, false, ballPos, enemyGoalPos)
        humanoid:MoveTo(tacticalPos)
        return
    end
end

-- Coordinador táctico por equipo (asigna 1 solo presser para evitar aglomeraciones)
local function runTeamCoordinator(allyTeam: { [string]: BotSlot }, enemyTeam: { [string]: BotSlot }, enemyGoalPos: Vector3, now: number)
    local bestPresserSlot: BotSlot? = nil
    local minDistance = 9999

    local targetItemPos = if currentBall then currentBall.Position else Vector3.zero
    if currentOwner then
        local cHrp = currentOwner:FindFirstChild("HumanoidRootPart") :: BasePart?
        if cHrp then targetItemPos = cHrp.Position end
    end

    -- Encontrar el jugador mejor situado (generalmente más cercano y de rol acorde)
    for roleId, slot in pairs(allyTeam) do
        if slot.model and slot.model.Parent then
            local hrp = slot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
            local hum = slot.model:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - targetItemPos).Magnitude
                -- Delanteros y centrales tienen preferencia para presionar en campo rival; defensas solo si está en su tercio
                local distWeight = dist
                if slot.role == "Defensa" and (math.abs(targetItemPos.X - slot.basePosition.X) > 65) then
                    distWeight = distWeight + 60 -- No sacar a los defensas de su línea
                end

                if distWeight < minDistance then
                    minDistance = distWeight
                    bestPresserSlot = slot
                end
            end
        end
    end

    -- Actualizar cada bot con las directivas del coordinador
    for roleId, slot in pairs(allyTeam) do
        updateBotSlotAI(slot, allyTeam, enemyTeam, bestPresserSlot, enemyGoalPos, now)
    end
end

--------------------------------------------------------------------------------
-- 14. BUCLE PRINCIPAL HEARTBEAT (IA CENTRALIZADA)
--------------------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    updateGoalkeeperAI(goalkeeperBlue, -halfX + 4)
    updateGoalkeeperAI(goalkeeperRed, halfX - 4)

    local now = os.clock()

    -- Coordinador de Equipo Azul (ataca hacia la derecha: RED_GOAL_CENTER)
    runTeamCoordinator(teamBlueBots, teamRedBots, RED_GOAL_CENTER, now)

    -- Coordinador de Equipo Rojo (ataca hacia la izquierda: BLUE_GOAL_CENTER)
    runTeamCoordinator(teamRedBots, teamBlueBots, BLUE_GOAL_CENTER, now)

    -- Robo del jugador humano si entra en el radio
    if currentOwner and currentBall and not isKickOnCooldown then
        for _, pl in ipairs(Players:GetPlayers()) do
            local pChar = pl.Character
            if pChar and pChar ~= currentOwner then
                local pHrp = pChar:FindFirstChild("HumanoidRootPart") :: BasePart?
                local pStats = characterStats[pChar]
                local pRadius = if pStats then getStealRadiusFromStat(pStats.defense) else 4.5
                if pHrp and (pHrp.Position - currentBall.Position).Magnitude < pRadius then
                    attachBallToPlayer(pChar)
                    break
                end
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- 15. COMANDOS DE CHAT (/bot)
--------------------------------------------------------------------------------
local function handleChatMessage(player: Player, rawMessage: string)
    local clean = string.lower(string.match(rawMessage, "^%s*(.-)%s*$") or rawMessage)
    
    if clean == "/bot" or clean == "bot" or clean == "!bot" then
        spawnFull6v6Match()
    elseif clean == "/limpiar" or clean == "/stop" or clean == "!stop" then
        cleanTeam(teamBlueBots)
        cleanTeam(teamRedBots)
        releaseBall()
        print("[SERVIDOR] Partido detenido y bots eliminados.")
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
    updateScoreEvent:FireClient(player, scoreBlue, scoreRed)
end)

Players.PlayerRemoving:Connect(function(player)
    if currentOwner and currentOwner.Name == player.Name then
        releaseBall()
    end
end)
